class CategoryModel {
  final int? id;
  final String categoryCode;
  final String categoryName;

  CategoryModel({
    this.id,
    required this.categoryCode,
    required this.categoryName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryCode': categoryCode,
      'categoryName': categoryName,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      categoryCode: map['categoryCode'] ?? '',
      categoryName: map['categoryName'] ?? '',
    );
  }
}
