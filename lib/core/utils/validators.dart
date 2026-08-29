import '../services/app_localizations.dart';

class AppValidators {
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName ${AppLocalizations.get('is_required')}';
    }
    return null;
  }

  static String? minLength(String? value, int min, String fieldName) {
    final req = required(value, fieldName);
    if (req != null) return req;

    if (value!.trim().length < min) {
      return '$fieldName ${AppLocalizations.get('must_be_at_least')} $min ${AppLocalizations.get('characters')}';
    }
    return null;
  }

  static String? numeric(String? value, String fieldName, {bool allowNegative = false}) {
    final req = required(value, fieldName);
    if (req != null) return req;

    final number = num.tryParse(value!.replaceAll(RegExp(r'[,.]'), '').trim());
    if (number == null) {
      return '$fieldName ${AppLocalizations.get('must_be_a_valid_number')}';
    }

    if (!allowNegative && number < 0) {
      return '$fieldName ${AppLocalizations.get('cannot_be_negative')}';
    }

    return null;
  }

  static String? phone(String? value, String fieldName, {bool isRequired = false}) {
    if (!isRequired && (value == null || value.trim().isEmpty)) {
      return null;
    }

    final req = required(value, fieldName);
    if (req != null) return req;

    final phoneRegExp = RegExp(r'^[0-9\-\+\s\(\)]{8,20}$');
    if (!phoneRegExp.hasMatch(value!.trim())) {
      return '$fieldName ${AppLocalizations.get('is_invalid')}';
    }

    return null;
  }
}
