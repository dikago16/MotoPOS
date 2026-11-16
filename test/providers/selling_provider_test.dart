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

    test('Quantity update must reject zero and negative values', () {
      final item = SaleItemModel(id: '1', name: 'Kampas Rem', price: 35000, quantity: 2);
      sellingProvider.addItem(item);

      expect(sellingProvider.updateQuantity(item, 0), isFalse);
      expect(sellingProvider.items.first.quantity, 2);

      expect(sellingProvider.updateQuantity(item, -3), isFalse);
      expect(sellingProvider.items.first.quantity, 2);

      expect(sellingProvider.updateQuantity(item, 4), isTrue);
      expect(sellingProvider.items.first.quantity, 4);
      expect(sellingProvider.totalAmount, 140000.0);
    });

    test('Stock limit is enforced when isCountStock is true', () {
      final stockItem = SaleItemModel(
        id: '2',
        name: 'Aki Motor',
        price: 250000,
        quantity: 1,
        isCountStock: true,
        stockQty: 2,
      );

      // Adding 1 should succeed
      expect(sellingProvider.addItem(stockItem), isTrue);
      expect(sellingProvider.items.first.quantity, 1);

      // Adding 1 more should succeed (total 2 = maxStock)
      expect(sellingProvider.addItem(SaleItemModel(
        id: '2',
        name: 'Aki Motor',
        price: 250000,
        quantity: 1,
        isCountStock: true,
        stockQty: 2,
      )), isTrue);
      expect(sellingProvider.items.first.quantity, 2);

      // Adding another should fail because stock is 2
      expect(sellingProvider.addItem(SaleItemModel(
        id: '2',
        name: 'Aki Motor',
        price: 250000,
        quantity: 1,
        isCountStock: true,
        stockQty: 2,
      )), isFalse);
      expect(sellingProvider.items.first.quantity, 2);

      // Updating quantity beyond stock should fail
      expect(sellingProvider.updateQuantity(stockItem, 5), isFalse);
      expect(sellingProvider.items.first.quantity, 2);
    });

    test('Supervisor price override updates unit price and recalculates total', () {
      final item = SaleItemModel(id: '3', name: 'Jasa Servis Karbu', price: 40000, quantity: 2);
      sellingProvider.addItem(item);
      expect(sellingProvider.totalAmount, 80000.0);

      // Owner overrides price to Rp 35.000 (diskon langganan)
      sellingProvider.updateItemPrice(item, 35000);
      expect(sellingProvider.items.first.price, 35000.0);
      expect(sellingProvider.items.first.isPriceOverridden, isTrue);
      expect(sellingProvider.totalAmount, 70000.0);
    });
  });
}
