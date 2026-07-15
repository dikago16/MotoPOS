import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import '../data/db_helper.dart';
import 'package:intl/intl.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  static const String _folderName = 'MotoPOS_Backup';

  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        final authHeaders = await _currentUser!.authHeaders;
        final authenticateClient = GoogleAuthClient(authHeaders);
        _driveApi = drive.DriveApi(authenticateClient);
      }
      return _currentUser;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
  }

  GoogleSignInAccount? get currentUser => _currentUser;
  
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      if (_currentUser != null) {
         final authHeaders = await _currentUser!.authHeaders;
         final authenticateClient = GoogleAuthClient(authHeaders);
         _driveApi = drive.DriveApi(authenticateClient);
      }
      return _currentUser;
    } catch (e) {
       print("Error signing in silently: $e");
       return null;
    }
  }

  Future<String?> _getFolderId() async {
    if (_driveApi == null) return null;

    try {
      final drive.FileList folderList = await _driveApi!.files.list(
        q: "mimeType='application/vnd.google-apps.folder' and name='$_folderName' and trashed=false",
        spaces: 'drive',
      );
      
      if (folderList.files != null && folderList.files!.isNotEmpty) {
        return folderList.files!.first.id;
      }

      final drive.File folder = drive.File();
      folder.name = _folderName;
      folder.mimeType = "application/vnd.google-apps.folder";

      final drive.File createdFolder = await _driveApi!.files.create(folder);
      return createdFolder.id;
    } catch (e) {
      print("Error getting folder ID: $e");
      return null;
    }
  }

  Future<bool> backupData() async {
    if (_driveApi == null) return false;

    try {
      final folderId = await _getFolderId();
      if (folderId == null) return false;

      final data = await DBHelper.exportAllData();
      final String jsonString = jsonEncode(data);
      
      final dateStr = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
      final String fileName = 'motopos_backup_$dateStr.json';

      final drive.File driveFile = drive.File();
      driveFile.name = fileName;
      driveFile.parents = [folderId];

      final media = drive.Media(
        Stream.value(utf8.encode(jsonString)),
        utf8.encode(jsonString).length,
      );

      await _driveApi!.files.create(driveFile, uploadMedia: media);
      return true;
    } catch (e) {
      print("Error backing up data: $e");
      return false;
    }
  }

  Future<List<drive.File>> getBackupList() async {
    if (_driveApi == null) return [];

    try {
      final folderId = await _getFolderId();
      if (folderId == null) return [];

      final drive.FileList fileList = await _driveApi!.files.list(
        q: "'$folderId' in parents and trashed=false",
        orderBy: "createdTime desc",
        spaces: 'drive',
        $fields: "files(id, name, createdTime)",
      );

      return fileList.files ?? [];
    } catch (e) {
      print("Error getting backup list: $e");
      return [];
    }
  }

  Future<bool> restoreData(String fileId) async {
    if (_driveApi == null) return false;

    try {
      final drive.Media media = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> dataBytes = [];
      await for (var chunk in media.stream) {
        dataBytes.addAll(chunk);
      }

      final String jsonString = utf8.decode(dataBytes);
      final Map<String, dynamic> data = jsonDecode(jsonString);

      await DBHelper.importAllData(data);
      return true;
    } catch (e) {
      print("Error restoring data: $e");
      return false;
    }
  }

  Future<bool> deleteBackup(String fileId) async {
    if (_driveApi == null) return false;

    try {
      await _driveApi!.files.delete(fileId);
      return true;
    } catch (e) {
      print("Error deleting backup: $e");
      return false;
    }
  }
}
