class PurchaseInvoiceModel {
  final int? id;
  final String invoiceCode;
  final String invoiceDate;
  final int supplierId;
  final String supplierName;
  final double totalAmount;
  final String notes;

  PurchaseInvoiceModel({
    this.id,
    required this.invoiceCode,
    required this.invoiceDate,
    required this.supplierId,
    required this.supplierName,
    required this.totalAmount,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceCode': invoiceCode,
      'invoiceDate': invoiceDate,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'totalAmount': totalAmount,
      'notes': notes,
    };
  }

  factory PurchaseInvoiceModel.fromMap(Map<String, dynamic> map) {
    return PurchaseInvoiceModel(
      id: map['id']?.toInt(),
      invoiceCode: map['invoiceCode'] ?? '',
      invoiceDate: map['invoiceDate'] ?? '',
      supplierId: map['supplierId']?.toInt() ?? 0,
      supplierName: map['supplierName'] ?? '',
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      notes: map['notes'] ?? '',
    );
  }
}
