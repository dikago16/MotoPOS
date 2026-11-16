import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motopos/core/services/security_pin_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('SecurityPinService Tests', () {
    test('isPinSet returns false when no PIN is saved', () async {
      expect(await SecurityPinService.isPinSet(), isFalse);
    });

    test('setPin and verifyPin work correctly with correct PIN', () async {
      await SecurityPinService.setPin('123456');

      expect(await SecurityPinService.isPinSet(), isTrue);
      expect(await SecurityPinService.verifyPin('123456'), isTrue);
      expect(await SecurityPinService.verifyPin('654321'), isFalse);
      expect(await SecurityPinService.verifyPin('1234'), isFalse);
    });

    test('removePin clears the stored PIN', () async {
      await SecurityPinService.setPin('889900');
      expect(await SecurityPinService.isPinSet(), isTrue);

      await SecurityPinService.removePin();
      expect(await SecurityPinService.isPinSet(), isFalse);
    });

    test('verifyRecovery matches license key', () async {
      SharedPreferences.setMockInitialValues({
        'saved_license_key': 'ABCD-1234-EFGH-5678',
      });

      expect(await SecurityPinService.verifyRecovery('ABCD-1234-EFGH-5678'), isTrue);
      expect(await SecurityPinService.verifyRecovery('abcd1234efgh5678'), isTrue);
      expect(await SecurityPinService.verifyRecovery('WRONG-KEY'), isFalse);
    });
  });
}
