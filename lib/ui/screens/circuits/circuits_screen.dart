import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/circuits_provider.dart';
import '../../../data/models/circuit_model.dart';
import '../../../core/services/api_service.dart';
import 'circuit_image_screen.dart';

// Enterprise Design Tokens
const _kAccent = Color(0xFF2563EB);
const _kBgPage = Color(0xFFF1F5F9);
const _kBorder = Color(0xFFE2E8F0);
const _kTxtMid = Color(0xFF475569);

class CircuitsScreen extends StatefulWidget {
  const CircuitsScreen({super.key});

  @override
  State<CircuitsScreen> createState() => _CircuitsScreenState();
}

class _CircuitsScreenState extends State<CircuitsScreen> {
  CircuitBrand? _selectedBrand;
  CircuitMotorModel? _selectedModel;
  CircuitType? _selectedType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CircuitsProvider>().fetchCircuits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgPage,
      appBar: AppBar(
        title: const Text('Circuits Diagram'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Consumer<CircuitsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: _kAccent));
          }
          if (provider.error.isNotEmpty) {
            return Center(child: Text(provider.error, style: const TextStyle(color: Colors.red)));
          }
          if (provider.brands.isEmpty) {
            return const Center(child: Text('No circuits available.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDropdown<CircuitBrand>(
                  label: 'Brand Motor',
                  value: _selectedBrand,
                  items: provider.brands,
                  getName: (item) => item.name,
                  onChanged: (val) {
                    setState(() {
                      _selectedBrand = val;
                      _selectedModel = null;
                      _selectedType = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                if (_selectedBrand != null)
                  _buildDropdown<CircuitMotorModel>(
                    label: 'Model Motor',
                    value: _selectedModel,
                    items: _selectedBrand!.models,
                    getName: (item) => item.name,
                    onChanged: (val) {
                      setState(() {
                        _selectedModel = val;
                        _selectedType = null;
                      });
                    },
                  ),
                if (_selectedBrand != null) const SizedBox(height: 12),
                
                if (_selectedModel != null)
                  _buildDropdown<CircuitType>(
                    label: 'Tipe / Tahun',
                    value: _selectedType,
                    items: _selectedModel!.types,
                    getName: (item) => item.name,
                    onChanged: (val) {
                      setState(() {
                        _selectedType = val;
                      });
                    },
                  ),
                if (_selectedModel != null) const SizedBox(height: 12),

                if (_selectedType != null) ...[
                  const Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      'Daftar Sirkuit:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _kTxtMid),
                    ),
                  ),
                  ..._selectedType!.circuits.map((circuit) {
                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: _kBorder),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(circuit.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        trailing: const Icon(Icons.zoom_out_map, size: 18, color: _kAccent),
                        onTap: () async {
                          final deviceId = await ActivationService.getDeviceId();
                          final imageUrl = '${AiService.baseUrl}/circuits/image/${Uri.encodeComponent(_selectedBrand!.name)}/${Uri.encodeComponent(_selectedModel!.name)}/${Uri.encodeComponent(_selectedType!.name)}/${Uri.encodeComponent(circuit.filename)}?device_id=$deviceId';
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CircuitImageScreen(
                                title: circuit.name,
                                imageUrl: imageUrl,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) getName,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          hint: Text('Pilih $label', style: const TextStyle(color: _kTxtMid)),
          value: value,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(getName(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
