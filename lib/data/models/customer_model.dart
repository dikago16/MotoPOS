class CustomerModel {
  final int? id;
  final String customerCode;
  final String name;
  final String phone;
  final String vehicleNo;
  final String vehicleType;
  final String address;

  CustomerModel({
    this.id,
    required this.customerCode,
    required this.name,
    required this.phone,
    required this.vehicleNo,
    required this.vehicleType,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerCode': customerCode,
      'name': name,
      'phone': phone,
      'vehicleNo': vehicleNo,
      'vehicleType': vehicleType,
      'address': address,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id']?.toInt(),
      customerCode: map['customerCode'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      vehicleNo: map['vehicleNo'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
      address: map['address'] ?? '',
    );
  }
}
