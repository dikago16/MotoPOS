import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/models/circuit_model.dart';
import '../core/services/api_service.dart';

class CircuitsProvider with ChangeNotifier {
  List<CircuitBrand> _brands = [];
  bool _isLoading = false;
  String _error = '';

  List<CircuitBrand> get brands => _brands;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchCircuits() async {
    if (_brands.isNotEmpty) return; // Cache locally

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final String deviceId = await ActivationService.getDeviceId();
      final response = await http.get(Uri.parse('${AiService.baseUrl}/circuits?device_id=$deviceId'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _brands = _parseBrands(data);
      } else {
        _error = 'Failed to load circuits: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching circuits: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<CircuitBrand> _parseBrands(List<dynamic> data) {
    List<CircuitBrand> parsedBrands = [];
    for (var brandMap in data) {
      if (brandMap is Map<String, dynamic>) {
        brandMap.forEach((brandName, modelsData) {
          List<CircuitMotorModel> parsedModels = [];
          if (modelsData is List) {
            for (var modelMap in modelsData) {
              if (modelMap is Map<String, dynamic>) {
                modelMap.forEach((modelName, typesData) {
                  List<CircuitType> parsedTypes = [];
                  if (typesData is List) {
                    for (var typeMap in typesData) {
                      if (typeMap is Map<String, dynamic>) {
                        typeMap.forEach((typeName, circuitsData) {
                          List<CircuitDetail> parsedCircuits = [];
                          if (circuitsData is List) {
                            parsedCircuits = circuitsData
                                .map((c) => CircuitDetail.fromJson(c as Map<String, dynamic>))
                                .toList();
                          }
                          parsedTypes.add(CircuitType(name: typeName, circuits: parsedCircuits));
                        });
                      }
                    }
                  }
                  parsedModels.add(CircuitMotorModel(name: modelName, types: parsedTypes));
                });
              }
            }
          }
          parsedBrands.add(CircuitBrand(name: brandName, models: parsedModels));
        });
      }
    }
    return parsedBrands;
  }
}
