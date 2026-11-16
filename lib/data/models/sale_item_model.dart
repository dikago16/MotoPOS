class SaleItemModel {
  final String id;
  final String name;
  final String category;
  double price;
  int quantity;
  final bool isCountStock;
  final int stockQty;
  bool isPriceOverridden;
  final double originalPrice;

  SaleItemModel({
    required this.id,
    required this.name,
    this.category = '',
    required this.price,
    this.quantity = 1,
    this.isCountStock = false,
    this.stockQty = 0,
    this.isPriceOverridden = false,
    double? originalPrice,
  }) : originalPrice = originalPrice ?? price;

  double get total => price * quantity;
}
