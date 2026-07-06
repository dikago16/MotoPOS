class TransactionModel {
  final int? id;
  final String transactionDate;
  final double totalAmount;
  final double cashAmount;
  final double changeAmount;
  final String? vehicleNo;

  TransactionModel({
    this.id,
    required this.transactionDate,
    required this.totalAmount,
    required this.cashAmount,
    required this.changeAmount,
    this.vehicleNo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionDate': transactionDate,
      'totalAmount': totalAmount,
      'cashAmount': cashAmount,
      'changeAmount': changeAmount,
      'vehicleNo': vehicleNo,
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
    );
  }
}
