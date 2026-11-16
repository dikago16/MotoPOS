class UserModel {
  final int? id;
  final String username;
  final String pin; // Hashed PIN
  final String role; // 'owner' or 'cashier'
  final bool isActive;
  final String createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.pin,
    required this.role,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isOwner => role.toLowerCase() == 'owner';
  bool get isCashier => role.toLowerCase() == 'cashier';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'pin': pin,
      'role': role,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toInt(),
      username: map['username'] ?? '',
      pin: map['pin'] ?? '',
      role: map['role'] ?? 'cashier',
      isActive: (map['isActive'] ?? 1) == 1,
      createdAt: map['createdAt'] ?? '',
    );
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? pin,
    String? role,
    bool? isActive,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      pin: pin ?? this.pin,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
