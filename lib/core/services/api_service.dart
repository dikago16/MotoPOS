import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ActivationService {
  static const String baseUrl = "https://api.dx-bytes.com/api/v1";
  static const String _licenseKeyPref = "saved_license_key";

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
    return deviceId;
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
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Simpan key jika aktivasi berhasil
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_licenseKeyPref, licenseKey);
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
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
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
      // Jika ingin STRICT OFFLINE BLOCK (tidak bisa dipakai tanpa internet sama sekali):
      // Ubah nilai success di bawah ini menjadi false dan is_offline menjadi false.
      //
      // Contoh Strict Block:
      // return {"success": false, "message": "Koneksi internet diperlukan untuk validasi lisensi."};
      return {
        "success": true,
        "message": "Offline mode: Lisensi dilewati sementara.",
        "is_offline": true,
      };
    } catch (e) {
      // Jika terjadi error jaringan lain
      debugPrint("API ERROR (validateLicense): $e");
      return {
        "success": true,
        "message": "Offline mode (Error): Lisensi dilewati.",
        "is_offline": true,
      };
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
      );

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
      final response = await http.post(
        Uri.parse("$baseUrl/ask-ai"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"prompt": prompt, "device_id": deviceId}),
      );

      final data = jsonDecode(response.body);
      debugPrint("RESPONSE DATA: $data");
      if (response.statusCode == 200) {
        return {"success": true, "answer": data['ai_answer']};
      } else {
        debugPrint(data['ai_answer']);
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
