class TransactionItemModel {
  final int? id;
  final int transactionId;
  final String itemName;
  final String category;
  final double price;
  final int quantity;
  final double subtotal;

  TransactionItemModel({
    this.id,
    required this.transactionId,
    required this.itemName,
    this.category = '',
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'itemName': itemName,
      'category': category,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory TransactionItemModel.fromMap(Map<String, dynamic> map) {
    return TransactionItemModel(
      id: map['id']?.toInt(),
      transactionId: map['transactionId']?.toInt() ?? 0,
      itemName: map['itemName'] ?? '',
      category: map['category'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toInt() ?? 0,
      subtotal: map['subtotal']?.toDouble() ?? 0.0,
    );
  }
}
