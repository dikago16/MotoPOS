class PurchaseInvoiceItemModel {
  final int? id;
  final int? invoiceId;
  final int productId;
  final String itemCode;
  final String itemName;
  final int quantity;
  final double buyingPrice;
  final double subtotal;

  PurchaseInvoiceItemModel({
    this.id,
    this.invoiceId,
    required this.productId,
    required this.itemCode,
    required this.itemName,
    required this.quantity,
    required this.buyingPrice,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'productId': productId,
      'itemCode': itemCode,
      'itemName': itemName,
      'quantity': quantity,
      'buyingPrice': buyingPrice,
      'subtotal': subtotal,
    };
  }

  factory PurchaseInvoiceItemModel.fromMap(Map<String, dynamic> map) {
    return PurchaseInvoiceItemModel(
      id: map['id']?.toInt(),
      invoiceId: map['invoiceId']?.toInt(),
      productId: map['productId']?.toInt() ?? 0,
      itemCode: map['itemCode'] ?? '',
      itemName: map['itemName'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      buyingPrice: map['buyingPrice']?.toDouble() ?? 0.0,
      subtotal: map['subtotal']?.toDouble() ?? 0.0,
    );
  }
}
