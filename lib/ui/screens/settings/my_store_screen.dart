import '../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../data/database_service.dart';
import '../../../data/models/store_info_model.dart';
import '../../../core/services/app_localizations.dart';
import '../../widgets/app_loading.dart';
import '../../../core/utils/validators.dart';

class MyStoreScreen extends StatefulWidget {
  const MyStoreScreen({super.key});

  @override
  State<MyStoreScreen> createState() => _MyStoreScreenState();
}

class _MyStoreScreenState extends State<MyStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadStoreInfo();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStoreInfo() async {
    final info = await context.read<DatabaseService>().getStoreInfo();
    if (mounted) {
      setState(() {
        _nameCtrl.text = info.storeName;
        _addressCtrl.text = info.address;
        _phoneCtrl.text = info.phone;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final info = StoreInfoModel(
      storeName: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );

    await context.read<DatabaseService>().saveStoreInfo(info);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.get('store_saved')),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: Text(
          AppLocalizations.get('my_store'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const AppLoading(isFullScreen: true)
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.get(
                                'store_information',
                              ).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.txtLow,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Store Name
                            _buildLabel(AppLocalizations.get('store_name')),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: _inputDecoration(
                                hint: AppLocalizations.get('e_g_my_store'),
                                icon: Icons.store_outlined,
                              ),
                              validator: (v) => AppValidators.required(
                                v,
                                AppLocalizations.get('store_name'),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Address
                            _buildLabel(AppLocalizations.get('address')),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _addressCtrl,
                              maxLines: 2,
                              decoration: _inputDecoration(
                                hint: AppLocalizations.get('e_g_address'),
                                icon: Icons.location_on_outlined,
                              ),
                              validator: (v) => AppValidators.required(
                                v,
                                AppLocalizations.get('address'),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Phone
                            _buildLabel(AppLocalizations.get('phone_number')),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: _inputDecoration(
                                hint: AppLocalizations.get('e_g_phone'),
                                icon: Icons.phone_outlined,
                              ),
                              validator: (v) => AppValidators.phone(
                                v,
                                AppLocalizations.get('phone_number'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ── Receipt preview ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.get(
                                'receipt_preview',
                              ).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.txtLow,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBF0),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFE8E0CC),
                                ),
                              ),
                              child: ValueListenableBuilder(
                                valueListenable: _nameCtrl,
                                builder: (context, value, child) {
                                  return Column(
                                    children: [
                                      Text(
                                        _nameCtrl.text.isEmpty
                                            ? StoreInfoModel.defaultStoreName
                                            : _nameCtrl.text,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: 'monospace',
                                          color: AppColors.txtHigh,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _addressCtrl.text.isEmpty
                                            ? StoreInfoModel.defaultAddress
                                            : _addressCtrl.text,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                          color: AppColors.txtMid,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _phoneCtrl.text.isEmpty
                                            ? StoreInfoModel.defaultPhone
                                            : _phoneCtrl.text,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                          color: AppColors.txtMid,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '-' * 32,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'monospace',
                                          color: AppColors.txtLow,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        '... receipt items ...',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'monospace',
                                          color: AppColors.txtLow,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Save button ──
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            disabledBackgroundColor: AppColors.accent
                                .withValues(alpha: 0.4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: AppLoading(),
                                )
                              : Text(
                                  AppLocalizations.get('save'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.txtHigh,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 10, color: AppColors.txtLow),
      prefixIcon: Icon(icon, size: 18, color: AppColors.txtMid),
      filled: true,
      fillColor: AppColors.bgPage,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      isDense: true,
    );
  }
}
