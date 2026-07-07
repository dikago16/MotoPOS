class SupplierModel {
  final int? id;
  final String supplierCode;
  final String supplierName;
  final String phone;
  final String address;

  SupplierModel({
    this.id,
    required this.supplierCode,
    required this.supplierName,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplierCode': supplierCode,
      'supplierName': supplierName,
      'phone': phone,
      'address': address,
    };
  }

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'],
      supplierCode: map['supplierCode'],
      supplierName: map['supplierName'],
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
    );
  }
}
