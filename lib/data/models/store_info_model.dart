class StoreInfoModel {
  final int? id;
  final String storeName;
  final String address;
  final String phone;

  static const String defaultStoreName = 'My Store';
  static const String defaultAddress = 'Jl. Bunga Melati';
  static const String defaultPhone = '08123456789';

  StoreInfoModel({
    this.id,
    required this.storeName,
    required this.address,
    required this.phone,
  });

  /// Returns a model populated with default values.
  factory StoreInfoModel.defaults() {
    return StoreInfoModel(
      storeName: defaultStoreName,
      address: defaultAddress,
      phone: defaultPhone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeName': storeName,
      'address': address,
      'phone': phone,
    };
  }

  factory StoreInfoModel.fromMap(Map<String, dynamic> map) {
    return StoreInfoModel(
      id: map['id'],
      storeName: map['storeName'] ?? defaultStoreName,
      address: map['address'] ?? defaultAddress,
      phone: map['phone'] ?? defaultPhone,
    );
  }
}
