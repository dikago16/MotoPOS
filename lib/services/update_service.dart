import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class AppVersionInfo {
  final String versionName;
  final int versionCode;
  final String downloadUrl;
  final String releaseNotes;
  final bool forceUpdate;

  AppVersionInfo({
    required this.versionName,
    required this.versionCode,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.forceUpdate,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      versionName: json['version_name'] ?? '0.0.0',
      versionCode: json['version_code'] ?? 0,
      downloadUrl: json['download_url'] ?? '',
      releaseNotes: json['release_notes'] ?? '',
      forceUpdate: json['force_update'] ?? false,
    );
  }
}

class UpdateCheckResult {
  final bool updateAvailable;
  final AppVersionInfo? versionInfo;
  final String? currentVersion;
  final int? currentBuildNumber;
  final String? errorMessage;

  UpdateCheckResult({
    required this.updateAvailable,
    this.versionInfo,
    this.currentVersion,
    this.currentBuildNumber,
    this.errorMessage,
  });
}

class UpdateService {
  static const String _checkVersionUrl =
      'https://www.dx-bytes.com/mobile/check-version.json';

  static Future<UpdateCheckResult> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      final response = await http
          .get(Uri.parse(_checkVersionUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return UpdateCheckResult(
          updateAvailable: false,
          errorMessage: 'Server error: ${response.statusCode}',
        );
      }

      final Map<String, dynamic> json = jsonDecode(response.body);
      final versionInfo = AppVersionInfo.fromJson(json);

      final isUpdateAvailable = versionInfo.versionCode > currentBuildNumber;

      return UpdateCheckResult(
        updateAvailable: isUpdateAvailable,
        versionInfo: versionInfo,
        currentVersion: packageInfo.version,
        currentBuildNumber: currentBuildNumber,
      );
    } on SocketException {
      return UpdateCheckResult(
        updateAvailable: false,
        errorMessage: 'Tidak ada koneksi internet.',
      );
    } catch (e) {
      debugPrint('UpdateService.checkForUpdate error: $e');
      return UpdateCheckResult(
        updateAvailable: false,
        errorMessage: 'Gagal memeriksa pembaruan.',
      );
    }
  }

  static Future<String?> downloadApk(
    String url,
    void Function(double progress) onProgress,
  ) async {
    try {
      final request = http.Request('GET', Uri.parse(url));
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 10),
      );

      if (streamedResponse.statusCode != 200) {
        debugPrint('Download failed: ${streamedResponse.statusCode}');
        return null;
      }

      final contentLength = streamedResponse.contentLength ?? 0;
      final dir = await getTemporaryDirectory();

      String fileName = 'motopos_update.apk';
      try {
        final uri = Uri.parse(url);
        if (uri.pathSegments.isNotEmpty) {
          fileName = uri.pathSegments.last;
        }
      } catch (_) {}

      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }

      final sink = file.openWrite();
      int receivedBytes = 0;

      await for (final chunk in streamedResponse.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (contentLength > 0) {
          onProgress(receivedBytes / contentLength);
        }
      }

      await sink.close();
      return filePath;
    } catch (e) {
      debugPrint('UpdateService.downloadApk error: $e');
      return null;
    }
  }

  static Future<bool> installApk(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      return result.type == ResultType.done;
    } catch (e) {
      debugPrint('UpdateService.installApk error: $e');
      return false;
    }
  }

  static Future<PackageInfo> getCurrentVersion() async {
    return PackageInfo.fromPlatform();
  }
}
