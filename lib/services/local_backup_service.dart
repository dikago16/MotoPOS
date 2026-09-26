import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../data/database_service.dart';

class LocalBackupService {
  final DatabaseService _dbService;

  LocalBackupService(this._dbService);

  Future<bool> backupData() async {
    try {
      final data = await _dbService.exportAllData();
      final String jsonString = jsonEncode(data);

      final dateStr = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
      final String fileName = 'motopos_backup_$dateStr.json';

      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Save Backup',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(utf8.encode(jsonString)),
      );

      if (outputFile == null) {
        // User canceled
        return false;
      }
      
      // Since we provided 'bytes', file_picker automatically writes the file on all platforms.
      // Trying to access the file via dart:io File(outputFile) can throw a FileSystemException 
      // on Android 10+ due to Scoped Storage, which causes the false negative error.
      return true;
    } catch (e) {
      debugPrint("Error backing up data locally: $e");
      return false;
    }
  }

  Future<bool> restoreData() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        // User canceled
        return false;
      }

      final file = File(result.files.single.path!);
      final String jsonString = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      await _dbService.importAllData(data);
      return true;
    } catch (e) {
      debugPrint("Error restoring data locally: $e");
      return false;
    }
  }
}
