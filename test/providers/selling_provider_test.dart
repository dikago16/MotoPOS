import 'package:flutter_test/flutter_test.dart';
import 'package:motopos/providers/selling_provider.dart';
import 'package:motopos/data/models/sale_item_model.dart';
import 'package:motopos/data/models/customer_model.dart';

void main() {
  group('SellingProvider Tests', () {
    late SellingProvider sellingProvider;

    setUp(() {
      sellingProvider = SellingProvider();
    });

    test('Initial state should be empty', () {
      expect(sellingProvider.items, isEmpty);
      expect(sellingProvider.cash, 0.0);
      expect(sellingProvider.selectedCustomer, isNull);
      expect(sellingProvider.totalAmount, 0.0);
      expect(sellingProvider.changeAmount, 0.0);
    });

    test('Adding an item should increase items count and total amount', () {
      final item = SaleItemModel(
        id: '1',
        name: 'Oli Mesin',
        price: 50000,
        quantity: 1,
      );

      sellingProvider.addItem(item);

      expect(sellingProvider.items.length, 1);
      expect(sellingProvider.totalAmount, 50000.0);
    });

    test('Adding same item should increase quantity, not items list length', () {
      final item1 = SaleItemModel(
        id: '1',
        name: 'Oli Mesin',
        price: 50000,
        quantity: 1,
      );
      final item2 = SaleItemModel(
        id: '1',
        name: 'Oli Mesin',
        price: 50000,
        quantity: 2, // adding 2 more
      );

      sellingProvider.addItem(item1);
      sellingProvider.addItem(item2);

      expect(sellingProvider.items.length, 1);
      expect(sellingProvider.items.first.quantity, 3);
      expect(sellingProvider.totalAmount, 150000.0);
    });

    test('Update quantity should correctly recalculate total', () {
      final item = SaleItemModel(
        id: '1',
        name: 'Busi',
        price: 20000,
        quantity: 1,
      );

      sellingProvider.addItem(item);
      sellingProvider.updateQuantity(item, 5);

      expect(sellingProvider.items.first.quantity, 5);
      expect(sellingProvider.totalAmount, 100000.0);
    });

    test('Remove item should decrease total amount', () {
      final item1 = SaleItemModel(id: '1', name: 'Busi', price: 20000, quantity: 1);
      final item2 = SaleItemModel(id: '2', name: 'Oli', price: 50000, quantity: 1);

      sellingProvider.addItem(item1);
      sellingProvider.addItem(item2);
      expect(sellingProvider.totalAmount, 70000.0);

      sellingProvider.removeItem(item1);
      expect(sellingProvider.items.length, 1);
      expect(sellingProvider.totalAmount, 50000.0);
    });

    test('Change amount is calculated correctly', () {
      final item = SaleItemModel(id: '1', name: 'Oli', price: 50000, quantity: 1);
      sellingProvider.addItem(item);
      
      sellingProvider.updateCash('60000');
      
      expect(sellingProvider.cash, 60000.0);
      expect(sellingProvider.changeAmount, 10000.0);
    });

    test('Change amount is zero if cash is less than total', () {
      final item = SaleItemModel(id: '1', name: 'Oli', price: 50000, quantity: 1);
      sellingProvider.addItem(item);
      
      sellingProvider.updateCash('40000');
      
      expect(sellingProvider.changeAmount, 0.0);
    });

    test('Clear transaction resets everything', () {
      final item = SaleItemModel(id: '1', name: 'Oli', price: 50000, quantity: 1);
      final customer = CustomerModel(
        id: 1, 
        customerCode: 'C-001',
        name: 'Budi', 
        phone: '08123', 
        vehicleNo: 'AB 123 CD',
        vehicleType: 'Matic',
        address: 'Jl. Melati',
      );
      
      sellingProvider.addItem(item);
      sellingProvider.updateCash('100000');
      sellingProvider.setCustomer(customer);

      sellingProvider.clearTransaction();

      expect(sellingProvider.items, isEmpty);
      expect(sellingProvider.cash, 0.0);
      expect(sellingProvider.selectedCustomer, isNull);
      expect(sellingProvider.totalAmount, 0.0);
      expect(sellingProvider.changeAmount, 0.0);
    });
  });
}
