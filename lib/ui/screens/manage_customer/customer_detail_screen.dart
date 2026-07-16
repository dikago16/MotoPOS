import '../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/database_service.dart';
import '../../../core/services/app_localizations.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────

// ──────────────────────────────────────────────────────────────────────────────

class CustomerDetailScreen extends StatefulWidget {
  final CustomerModel? customer;

  const CustomerDetailScreen({super.key, this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  bool _autoCode = true;
  bool _isSaving = false;
  String _generatedCode = '';

  final _customerCodeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _vehicleNoCtrl = TextEditingController();
  final _vehicleTypeCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _autoCode = false;
      _customerCodeCtrl.text = widget.customer!.customerCode;
      _nameCtrl.text = widget.customer!.name;
      _phoneCtrl.text = widget.customer!.phone;
      _vehicleNoCtrl.text = widget.customer!.vehicleNo;
      _vehicleTypeCtrl.text = widget.customer!.vehicleType;
      _addressCtrl.text = widget.customer!.address;
    } else {
      _fetchNextCode();
    }
  }

  Future<void> _fetchNextCode() async {
    String nextCode = await context
        .read<DatabaseService>()
        .getNextCustomerCode();
    setState(() {
      _generatedCode = nextCode;
      if (_autoCode) {
        _customerCodeCtrl.text = _generatedCode;
      }
    });
  }

  @override
  void dispose() {
    _customerCodeCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _vehicleNoCtrl.dispose();
    _vehicleTypeCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _deleteCustomer() async {
    if (widget.customer?.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Delete Customer',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.txtHigh,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this customer? This action cannot be undone.',
          style: TextStyle(fontSize: 13, color: AppColors.txtMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppColors.txtLow),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      await context.read<DatabaseService>().deleteCustomer(
        widget.customer!.id!,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  InputDecoration _inputDeco(
    String label, {
    Widget? suffixIcon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.txtLow),
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.txtMid),
      floatingLabelStyle: const TextStyle(
        fontSize: 11,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      suffixIcon: suffixIcon,
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
    final isEdit = widget.customer != null;
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
                  ? AppLocalizations.get('edit_customer')
                  : AppLocalizations.get('new_customer'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              isEdit
                  ? AppLocalizations.get('update_details')
                  : AppLocalizations.get('add_new_customer'),
              style: const TextStyle(
                color: Color(0xFF90AAC8),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.red,
                size: 20,
              ),
              onPressed: _deleteCustomer,
              tooltip: 'Delete',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // ── Customer Info Card ──
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
                                'Customer Information',
                                icon: Icons.person_outline,
                              ),
                              if (!isEdit)
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _autoCode,
                                        activeColor: AppColors.accent,
                                        onChanged: (val) {
                                          setState(() {
                                            _autoCode = val ?? true;
                                            if (_autoCode) {
                                              _customerCodeCtrl.text =
                                                  _generatedCode;
                                            } else {
                                              _customerCodeCtrl.text = '';
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.get('auto_code'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.txtMid,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),

                          // Customer Code
                          TextFormField(
                            controller: _customerCodeCtrl,
                            readOnly: _autoCode,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.txtMid,
                            ),
                            decoration:
                                _inputDeco(
                                  AppLocalizations.get('customer_code'),
                                ).copyWith(
                                  fillColor: _autoCode
                                      ? AppColors.bgPage
                                      : AppColors.bgCard,
                                ),
                          ),
                          const SizedBox(height: 8),

                          // Name
                          TextFormField(
                            controller: _nameCtrl,
                            style: const TextStyle(fontSize: 13),
                            decoration: _inputDeco(
                              AppLocalizations.get('customer_name'),
                            ),
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 8),

                          // Phone
                          TextFormField(
                            controller: _phoneCtrl,
                            style: const TextStyle(fontSize: 13),
                            decoration: _inputDeco(
                              'Phone Number',
                              hintText: 'e.g. 08123456789',
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 8),

                          // Address
                          TextFormField(
                            controller: _addressCtrl,
                            style: const TextStyle(fontSize: 13),
                            decoration: _inputDeco(
                              AppLocalizations.get('address'),
                            ),
                            maxLines: 2,
                            textCapitalization: TextCapitalization.words,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Vehicle Info Card ──
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
                            AppLocalizations.get('basic_information'),
                            icon: Icons.two_wheeler,
                          ),

                          // Vehicle No
                          TextFormField(
                            controller: _vehicleNoCtrl,
                            style: const TextStyle(fontSize: 13),
                            decoration: _inputDeco(
                              'Vehicle No (Plat)',
                              hintText: 'e.g. B 1234 ABC',
                            ),
                            textCapitalization: TextCapitalization.characters,
                          ),
                          const SizedBox(height: 8),

                          // Vehicle Type
                          TextFormField(
                            controller: _vehicleTypeCtrl,
                            style: const TextStyle(fontSize: 13),
                            decoration: _inputDeco(
                              'Vehicle Type',
                              hintText: 'e.g. Honda Beat 2019',
                            ),
                            textCapitalization: TextCapitalization.words,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.customer != null) {
                    Navigator.pop(context);
                  } else {
                    _customerCodeCtrl.clear();
                    _nameCtrl.clear();
                    _phoneCtrl.clear();
                    _vehicleNoCtrl.clear();
                    _vehicleTypeCtrl.clear();
                    _addressCtrl.clear();
                    setState(() {
                      _autoCode = true;
                      _customerCodeCtrl.text = _generatedCode;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bgPage,
                  foregroundColor: AppColors.txtMid,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: AppColors.borderMid),
                  ),
                ),
                child: Text(
                  AppLocalizations.get('abort'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (_nameCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.get('customer_name_empty'),
                              ),
                              backgroundColor: Colors.red.shade600,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        setState(() => _isSaving = true);

                        try {
                          final customer = CustomerModel(
                            id: widget.customer?.id,
                            customerCode: _customerCodeCtrl.text.trim(),
                            name: _nameCtrl.text.trim(),
                            phone: _phoneCtrl.text.trim(),
                            vehicleNo: _vehicleNoCtrl.text.trim(),
                            vehicleType: _vehicleTypeCtrl.text.trim(),
                            address: _addressCtrl.text.trim(),
                          );

                          if (widget.customer != null) {
                            await context
                                .read<DatabaseService>()
                                .updateCustomer(customer);
                          } else {
                            await context
                                .read<DatabaseService>()
                                .insertCustomer(customer);
                          }

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.get('customer_saved'),
                              ),
                              backgroundColor: Color(0xFF16A34A),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.pop(context, true);
                        } catch (e) {
                          if (!mounted) return;
                          setState(() => _isSaving = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${AppLocalizations.get('customer_save_failed')}: $e',
                              ),
                              backgroundColor: const Color(0xFFDC2626),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                icon: _isSaving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check, size: 16),
                label: Text(
                  _isSaving
                      ? AppLocalizations.get('saving')
                      : AppLocalizations.get('save_customer'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
