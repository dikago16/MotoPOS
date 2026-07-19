import '../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/supplier_model.dart';
import '../../../data/database_service.dart';
import '../../../core/services/app_localizations.dart';
import '../../widgets/app_loading.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────

// ──────────────────────────────────────────────────────────────────────────────

class SupplierDetailScreen extends StatefulWidget {
  final SupplierModel? supplier;
  const SupplierDetailScreen({super.key, this.supplier});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;

  bool _isSaving = false;
  bool _isAutoCode = true;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(
      text: widget.supplier?.supplierCode ?? '',
    );
    _nameCtrl = TextEditingController(
      text: widget.supplier?.supplierName ?? '',
    );
    _phoneCtrl = TextEditingController(text: widget.supplier?.phone ?? '');
    _addressCtrl = TextEditingController(text: widget.supplier?.address ?? '');

    if (widget.supplier == null) {
      _generateCode();
    } else {
      _isAutoCode = false;
    }
  }

  void _toggleAutoCode(bool? value) {
    setState(() {
      _isAutoCode = value ?? true;
    });
    if (_isAutoCode) {
      _generateCode();
    } else {
      if (widget.supplier == null) {
        _codeCtrl.text = '';
      }
    }
  }

  Future<void> _generateCode() async {
    final code = await context.read<DatabaseService>().getNextSupplierCode();
    if (mounted) {
      setState(() {
        _codeCtrl.text = code;
      });
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final supplier = SupplierModel(
        id: widget.supplier?.id,
        supplierCode: _codeCtrl.text,
        supplierName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );

      if (widget.supplier == null) {
        await context.read<DatabaseService>().insertSupplier(supplier);
      } else {
        await context.read<DatabaseService>().updateSupplier(supplier);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.get('supplier_saved')),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.get('supplier_save_failed')}: $e',
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  InputDecoration _inputDeco(String label, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      labelStyle: const TextStyle(fontSize: 10, color: AppColors.txtMid),
      floatingLabelStyle: const TextStyle(
        fontSize: 9,
        color: AppColors.accent,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      filled: true,
      fillColor: AppColors.bgCard,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _sectionLabel(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.only(right: 8),
          ),
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.accent),
            const SizedBox(width: 5),
          ],
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppColors.txtMid,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        toolbarHeight: 54,
        iconTheme: const IconThemeData(color: Colors.white, size: 20),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isEdit
                  ? AppLocalizations.get('edit_supplier')
                  : AppLocalizations.get('new_supplier'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              isEdit
                  ? AppLocalizations.get('update_details')
                  : AppLocalizations.get('add_new_supplier'),
              style: const TextStyle(
                color: Color(0xFF90AAC8),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _sectionLabel(
                                  'Basic Information',
                                  icon: Icons.info_outline,
                                ),
                                if (widget.supplier == null)
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: _isAutoCode,
                                          onChanged: _toggleAutoCode,
                                          activeColor: AppColors.accent,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        AppLocalizations.get('auto_code'),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.txtMid,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            TextFormField(
                              controller: _codeCtrl,
                              readOnly: _isAutoCode,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.txtMid,
                              ),
                              decoration:
                                  _inputDeco(
                                    AppLocalizations.get('supplier_code'),
                                  ).copyWith(
                                    fillColor: _isAutoCode
                                        ? AppColors.bgPage
                                        : AppColors.bgCard,
                                  ),
                              validator: (v) => AppValidators.required(
                                v,
                                AppLocalizations.get('supplier_code'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameCtrl,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.txtHigh,
                              ),
                              decoration: _inputDeco(
                                AppLocalizations.get('supplier_name'),
                              ),
                              validator: (v) => AppValidators.required(
                                v,
                                AppLocalizations.get('supplier_name'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel(
                              'Contact Details',
                              icon: Icons.contact_phone_outlined,
                            ),
                            TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.txtHigh,
                              ),
                              decoration: _inputDeco(
                                AppLocalizations.get('phone_number'),
                                hintText: 'e.g. 0812...',
                              ),
                              validator: (v) => AppValidators.phone(
                                v,
                                AppLocalizations.get('phone_number'),
                                isRequired: false,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _addressCtrl,
                              maxLines: 3,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.txtHigh,
                              ),
                              decoration: _inputDeco(
                                AppLocalizations.get('address'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                border: const Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.txtMid,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.get('abort'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveSupplier,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: AppLoading(),
                              )
                            : Text(
                                _isSaving
                                    ? AppLocalizations.get('saving')
                                    : AppLocalizations.get('save_supplier'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
