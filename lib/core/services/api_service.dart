import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import '../../data/database_service.dart';
import 'trial_service.dart';

class ActivationService {
  static const String baseUrl = "https://api.dx-bytes.com/api/v1";
  static const String _licenseKeyPref = "saved_license_key";
  static const String _lastOnlineValidPref = "last_online_valid_time";

  // Cek apakah ada lisensi lokal yang tersimpan
  static Future<bool> hasLocalLicense() async {
    final prefs = await SharedPreferences.getInstance();
    final String? licenseKey = prefs.getString(_licenseKeyPref);
    return licenseKey != null && licenseKey.isNotEmpty;
  }

  // Memformat ID menjadi 16 digit hex dengan pemisah minus per 4 karakter
  static String _formatDeviceId(String rawId) {
    final bytes = utf8.encode(rawId);
    final digest = md5.convert(bytes);
    final String hex16 = digest.toString().substring(0, 16).toUpperCase();
    
    List<String> chunks = [];
    for (int i = 0; i < hex16.length; i += 4) {
      chunks.add(hex16.substring(i, i + 4));
    }
    return chunks.join('-');
  }

  // Mendapatkan Device ID Unik
  static Future<String> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = "UNKNOWN_DEVICE";

    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "UNKNOWN_IOS";
      } else if (Platform.isWindows) {
        final WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        deviceId = windowsInfo.deviceId;
      }
    } catch (e) {
      deviceId = "UNKNOWN_DEVICE";
    }
    return _formatDeviceId(deviceId);
  }

  // Melakukan Aktivasi Lisensi Baru
  static Future<Map<String, dynamic>> activateLicense(String licenseKey) async {
    try {
      final String deviceId = await getDeviceId();
      final response = await http.post(
        Uri.parse("$baseUrl/activate"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"license_key": licenseKey, "device_id": deviceId}),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Simpan key jika aktivasi berhasil
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_licenseKeyPref, licenseKey);
        await prefs.setString(_lastOnlineValidPref, DateTime.now().toIso8601String());
        
        // Hapus mode trial jika sebelumnya aktif
        await TrialService.deactivateTrial();
        
        return {
          "success": true,
          "message": data['message'] ?? "Aktivasi Berhasil",
        };
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "Gagal melakukan aktivasi",
          "statusCode": response.statusCode,
        };
      }
    } catch (e) {
      debugPrint("API ERROR (activateLicense): $e");
      return {
        "success": false,
        "message": "Terjadi kesalahan jaringan atau server.",
      };
    }
  }

  // Memvalidasi Lisensi yang Sudah Ada
  static Future<Map<String, dynamic>> validateLicense() async {
    final prefs = await SharedPreferences.getInstance();
    final String? licenseKey = prefs.getString(_licenseKeyPref);

    if (licenseKey == null || licenseKey.isEmpty) {
      return {
        "success": false,
        "message": "Lisensi tidak ditemukan",
        "is_missing": true,
      };
    }

    try {
      final String deviceId = await getDeviceId();
      final response = await http.post(
        Uri.parse("$baseUrl/validate"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"license_key": licenseKey, "device_id": deviceId}),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await prefs.setString(_lastOnlineValidPref, DateTime.now().toIso8601String());
        return {"success": true, "message": data['message'] ?? "Lisensi Valid"};
      } else if (response.statusCode == 403 || response.statusCode == 404) {
        // Lisensi invalid (expired/banned/device mismatch/not found)
        await prefs.remove(_licenseKeyPref);
        return {
          "success": false,
          "message": data['message'] ?? "Lisensi tidak valid",
          "is_invalid": true,
        };
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "Gagal memvalidasi lisensi",
        };
      }
    } on SocketException catch (_) {
      return _checkOfflineGracePeriod(prefs);
    } catch (e) {
      // Jika terjadi error jaringan lain
      debugPrint("API ERROR (validateLicense): $e");
      return _checkOfflineGracePeriod(prefs);
    }
  }

  static Map<String, dynamic> _checkOfflineGracePeriod(SharedPreferences prefs) {
    final String? lastOnlineStr = prefs.getString(_lastOnlineValidPref);
    if (lastOnlineStr != null) {
      final DateTime lastOnline = DateTime.parse(lastOnlineStr);
      final int offlineDays = DateTime.now().difference(lastOnline).inDays;
      if (offlineDays >= 3) {
        return {
          "success": false,
          "message": "Anda telah offline > 3 hari. Harap hubungkan ke internet untuk memvalidasi lisensi.",
        };
      }
    }
    return {
      "success": true,
      "message": "Offline mode: Lisensi dilewati sementara.",
      "is_offline": true,
    };
  }

  // Cek lisensi harian secara diam-diam (background)
  static Future<void> performDailyCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final String? licenseKey = prefs.getString(_licenseKeyPref);

    if (licenseKey == null || licenseKey.isEmpty) return;

    try {
      final String deviceId = await getDeviceId();
      final response = await http
          .post(
            Uri.parse("$baseUrl/daily-check"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({"license_key": licenseKey, "device_id": deviceId}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        await prefs.setString(_lastOnlineValidPref, DateTime.now().toIso8601String());
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        if (data['is_invalid'] == true) {
          // Lisensi tidak valid atau expired, hapus dari perangkat
          await prefs.remove(_licenseKeyPref);
        }
      }
    } catch (_) {
      // Abaikan error jaringan/timeout agar pengguna tetap bisa menggunakan aplikasi
    }
  }

  // Mendapatkan informasi lisensi
  static Future<Map<String, dynamic>> checkLicenseInfo(
    String licenseKey,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/check-license"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"license_key": licenseKey}),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": data['data'],
          "message": data['message'] ?? "Informasi lisensi berhasil didapatkan",
        };
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "Gagal mendapatkan informasi lisensi",
        };
      }
    } on SocketException catch (_) {
      return {
        "success": false,
        "message":
            "Offline mode: Tidak dapat memeriksa lisensi tanpa koneksi internet.",
      };
    } catch (e) {
      debugPrint("API ERROR (checkLicenseInfo): $e");
      return {
        "success": false,
        "message": "Terjadi kesalahan jaringan atau server.",
      };
    }
  }
}

class AiService {
  // Karena ask-ai ada di luar prefix v1 pada route api.php
  static const String baseUrl = "https://api.dx-bytes.com/api";

  static Future<Map<String, dynamic>> ask(String prompt) async {
    try {
      final String deviceId = await ActivationService.getDeviceId();
      final storeInfo = await DatabaseService().getStoreInfo();
      final String storeName = storeInfo.storeName == 'My Store' ? 'My Shop' : storeInfo.storeName;

      final response = await http.post(
        Uri.parse("$baseUrl/ask-ai"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"prompt": prompt, "device_id": deviceId, "store_name": storeName}),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"success": true, "answer": data['ai_answer']};
      } else {
        return {
          "success": false,
          "message": data['ai_answer'] ?? "Terjadi kesalahan",
        };
      }
    } catch (e) {
      debugPrint("API ERROR (AiService): $e");
      return {"success": false, "message": "Gagal menghubungi server AI."};
    }
  }
}
