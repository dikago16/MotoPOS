import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionInfo {
  final String versionName;
  final int versionCode;
  final String storeUrl;
  final String releaseNotes;
  final bool forceUpdate;

  AppVersionInfo({
    required this.versionName,
    required this.versionCode,
    required this.storeUrl,
    required this.releaseNotes,
    required this.forceUpdate,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      versionName: json['version_name'] ?? '0.0.0',
      versionCode: json['version_code'] ?? 0,
      storeUrl: json['store_url'] ?? 'https://play.google.com/store/apps/details?id=com.dxbytes.motopos',
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

      final String cacheBuster = DateTime.now().millisecondsSinceEpoch
          .toString();
      final response = await http
          .get(Uri.parse('$_checkVersionUrl?t=$cacheBuster'))
          .timeout(const Duration(seconds: 30));

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

  static Future<PackageInfo> getCurrentVersion() async {
    return PackageInfo.fromPlatform();
  }
}
