class TransactionModel {
  final int? id;
  final String transactionDate;
  final double totalAmount;
  final double cashAmount;
  final double changeAmount;
  final String? vehicleNo;
  final int? customerId;
  final String? customerName;

  TransactionModel({
    this.id,
    required this.transactionDate,
    required this.totalAmount,
    required this.cashAmount,
    required this.changeAmount,
    this.vehicleNo,
    this.customerId,
    this.customerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionDate': transactionDate,
      'totalAmount': totalAmount,
      'cashAmount': cashAmount,
      'changeAmount': changeAmount,
      'vehicleNo': vehicleNo,
      'customerId': customerId,
      'customerName': customerName,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id']?.toInt(),
      transactionDate: map['transactionDate'] ?? '',
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      cashAmount: map['cashAmount']?.toDouble() ?? 0.0,
      changeAmount: map['changeAmount']?.toDouble() ?? 0.0,
      vehicleNo: map['vehicleNo'],
      customerId: map['customerId']?.toInt(),
      customerName: map['customerName'],
    );
  }
}
