import 'package:flutter_test/flutter_test.dart';
import 'package:motopos/data/models/user_model.dart';
import 'package:motopos/core/services/security_pin_service.dart';

void main() {
  group('UserModel Tests', () {
    test('toMap() and fromMap() preserve user attributes and role helpers', () {
      final pinHash = SecurityPinService.hashPin('123456');
      final owner = UserModel(
        id: 1,
        username: 'Budi Owner',
        pin: pinHash,
        role: 'owner',
        isActive: true,
        createdAt: '2026-11-13T10:00:00',
      );

      expect(owner.isOwner, isTrue);
      expect(owner.isCashier, isFalse);

      final map = owner.toMap();
      expect(map['username'], 'Budi Owner');
      expect(map['role'], 'owner');
      expect(map['isActive'], 1);

      final parsed = UserModel.fromMap(map);
      expect(parsed.id, 1);
      expect(parsed.username, 'Budi Owner');
      expect(parsed.pin, pinHash);
      expect(parsed.isOwner, isTrue);
      expect(parsed.isActive, isTrue);
    });

    test('copyWith updates specified fields correctly for cashier role', () {
      final cashier = UserModel(
        id: 2,
        username: 'Andi Kasir',
        pin: SecurityPinService.hashPin('1111'),
        role: 'cashier',
        isActive: true,
        createdAt: '2026-11-13T11:00:00',
      );

      expect(cashier.isCashier, isTrue);
      expect(cashier.isOwner, isFalse);

      final deactivated = cashier.copyWith(isActive: false);
      expect(deactivated.isActive, isFalse);
      expect(deactivated.username, 'Andi Kasir');
    });
  });
}
