class Product {
  final int? id;
  final String itemCode;
  final String itemName;
  final String category;
  final double buyingPrice;
  final double packetBuyPrice;
  final int packetBuyQty;
  final double sellingPrice;
  final double packetSellPrice;
  final int packetSellQty;
  final String discountType;
  final double discountValue;
  final String unit;
  final bool isCountStock;
  final int stockQty;

  Product({
    this.id,
    required this.itemCode,
    required this.itemName,
    this.category = 'uncategorized',
    required this.buyingPrice,
    required this.packetBuyPrice,
    required this.packetBuyQty,
    required this.sellingPrice,
    required this.packetSellPrice,
    required this.packetSellQty,
    required this.discountType,
    required this.discountValue,
    required this.unit,
    required this.isCountStock,
    required this.stockQty,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemCode': itemCode,
      'itemName': itemName,
      'category': category,
      'buyingPrice': buyingPrice,
      'packetBuyPrice': packetBuyPrice,
      'packetBuyQty': packetBuyQty,
      'sellingPrice': sellingPrice,
      'packetSellPrice': packetSellPrice,
      'packetSellQty': packetSellQty,
      'discountType': discountType,
      'discountValue': discountValue,
      'unit': unit,
      'isCountStock': isCountStock ? 1 : 0,
      'stockQty': stockQty,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      itemCode: map['itemCode'] ?? '',
      itemName: map['itemName'] ?? '',
      category: map['category'] ?? 'uncategorized',
      buyingPrice: map['buyingPrice']?.toDouble() ?? 0.0,
      packetBuyPrice: map['packetBuyPrice']?.toDouble() ?? 0.0,
      packetBuyQty: map['packetBuyQty']?.toInt() ?? 0,
      sellingPrice: map['sellingPrice']?.toDouble() ?? 0.0,
      packetSellPrice: map['packetSellPrice']?.toDouble() ?? 0.0,
      packetSellQty: map['packetSellQty']?.toInt() ?? 0,
      discountType: map['discountType'] ?? 'Percent',
      discountValue: map['discountValue']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      isCountStock: map['isCountStock'] == 1,
      stockQty: map['stockQty']?.toInt() ?? 0,
    );
  }
}
