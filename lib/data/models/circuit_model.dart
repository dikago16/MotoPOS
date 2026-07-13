class CircuitBrand {
  final String name;
  final List<CircuitMotorModel> models;

  CircuitBrand({required this.name, required this.models});
}

class CircuitMotorModel {
  final String name;
  final List<CircuitType> types;

  CircuitMotorModel({required this.name, required this.types});
}

class CircuitType {
  final String name;
  final List<CircuitDetail> circuits;

  CircuitType({required this.name, required this.circuits});
}

class CircuitDetail {
  final String name;
  final String filename;

  CircuitDetail({required this.name, required this.filename});

  factory CircuitDetail.fromJson(Map<String, dynamic> json) {
    return CircuitDetail(
      name: json['NAME'] ?? '',
      filename: json['FILENAME'] ?? '',
    );
  }
}
