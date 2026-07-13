import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivationUtil {
  static const String _secretSalt = "MY_APP_SECURE_SALT_2026";
  static const String _activationKey = "is_activated";

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
      // fallback if getting device info fails
      deviceId = "UNKNOWN_DEVICE";
    }
    return deviceId;
  }

  static String generateExpectedCode(String deviceId) {
    final String rawString = deviceId + _secretSalt;
    final List<int> bytes = utf8.encode(rawString);
    final Digest hash = sha256.convert(bytes);
    
    String hexHash = hash.toString().toUpperCase();
    
    // Take first 12 characters
    if (hexHash.length > 12) {
      hexHash = hexHash.substring(0, 12);
    }
    
    // Format as XXXX-XXXX-XXXX
    if (hexHash.length == 12) {
      return "${hexHash.substring(0,4)}-${hexHash.substring(4,8)}-${hexHash.substring(8,12)}";
    }
    return hexHash;
  }

  static Future<bool> isActivated() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_activationKey) ?? false;
  }

  static Future<void> setActivated(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_activationKey, value);
  }
}
