import 'package:flutter_test/flutter_test.dart';
import 'package:motopos/data/models/product_model.dart';

void main() {
  group('ProductModel Tests', () {
    test('toMap() returns correct map structure', () {
      final product = Product(
        id: 1,
        itemCode: 'P-001',
        itemName: 'Oli Mesin',
        category: 'Oli',
        buyingPrice: 40000,
        packetBuyPrice: 0,
        packetBuyQty: 0,
        sellingPrice: 50000,
        packetSellPrice: 0,
        packetSellQty: 0,
        discountType: 'none',
        discountValue: 0,
        unit: 'Pcs',
        isCountStock: true,
        stockQty: 10,
      );

      final map = product.toMap();

      expect(map['id'], 1);
      expect(map['itemCode'], 'P-001');
      expect(map['itemName'], 'Oli Mesin');
      expect(map['category'], 'Oli');
      expect(map['sellingPrice'], 50000);
      expect(map['buyingPrice'], 40000);
      expect(map['stockQty'], 10);
    });

    test('fromMap() correctly parses data from database', () {
      final map = {
        'id': 2,
        'itemCode': 'P-002',
        'itemName': 'Busi',
        'category': 'Sparepart',
        'buyingPrice': 15000.0,
        'packetBuyPrice': 0.0,
        'packetBuyQty': 0,
        'sellingPrice': 25000.0,
        'packetSellPrice': 0.0,
        'packetSellQty': 0,
        'discountType': 'none',
        'discountValue': 0.0,
        'unit': 'Pcs',
        'isCountStock': 1,
        'stockQty': 100,
      };

      final product = Product.fromMap(map);

      expect(product.id, 2);
      expect(product.itemCode, 'P-002');
      expect(product.itemName, 'Busi');
      expect(product.category, 'Sparepart');
      expect(product.sellingPrice, 25000.0);
      expect(product.buyingPrice, 15000.0);
      expect(product.stockQty, 100);
      expect(product.isCountStock, true);
    });
  });
}
