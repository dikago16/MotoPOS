import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database_service.dart';

class SecurityPinService {
  static const String _pinKey = 'owner_security_pin_hash';
  static const String _salt = 'MotoPOS_Sec_2026_Workshop';
  static const String _savedLicenseKeyPref = 'saved_license_key';

  /// Hash the PIN with salt using SHA-256
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin.trim() + _salt);
    return sha256.convert(bytes).toString();
  }

  static String _hashPin(String pin) => hashPin(pin);

  /// Check whether an Owner Security PIN is currently set
  static Future<bool> isPinSet() async {
    final prefs = await SharedPreferences.getInstance();
    final hash = prefs.getString(_pinKey);
    return hash != null && hash.trim().isNotEmpty;
  }

  /// Verify entered PIN against stored hash
  static Future<bool> verifyPin(String enteredPin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedHash = prefs.getString(_pinKey);
    if (savedHash == null || savedHash.isEmpty) {
      return true; // No PIN configured
    }
    return savedHash == _hashPin(enteredPin);
  }

  /// Set or update the Owner Security PIN
  static Future<void> setPin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, _hashPin(newPin));
  }

  /// Remove / Disable the Owner Security PIN
  static Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
  }

  /// Verify recovery credential (either License Key or Store Phone) to allow PIN reset
  static Future<bool> verifyRecovery(String credential) async {
    final cleaned = credential.trim();
    if (cleaned.isEmpty) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLicense = prefs.getString(_savedLicenseKeyPref)?.trim();

      // Check match with license key (case-insensitive and ignore dashes)
      if (savedLicense != null && savedLicense.isNotEmpty) {
        final normInput = cleaned.replaceAll('-', '').toUpperCase();
        final normLicense = savedLicense.replaceAll('-', '').toUpperCase();
        if (normInput == normLicense) {
          return true;
        }
      }

      // Check match with store phone number from database
      final storeInfo = await DatabaseService().getStoreInfo();
      final storePhone = storeInfo.phone.replaceAll(RegExp(r'[^0-9]'), '');
      final inputPhone = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
      if (storePhone.isNotEmpty && inputPhone.isNotEmpty && storePhone == inputPhone) {
        return true;
      }
    } catch (e) {
      debugPrint('SecurityPinService.verifyRecovery error: $e');
    }

    return false;
  }
}
