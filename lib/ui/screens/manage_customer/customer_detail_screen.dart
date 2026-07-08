import 'package:flutter/material.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/db_helper.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────
const _kNavy = Color(0xFF0D1B2A);
const _kAccent = Color(0xFF2563EB);
const _kBgPage = Color(0xFFF1F5F9);
const _kBgCard = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE2E8F0);
const _kBorderMid = Color(0xFFCBD5E1);
const _kTxtHigh = Color(0xFF0F172A);
const _kTxtMid = Color(0xFF475569);
const _kTxtLow = Color(0xFF94A3B8);
const _kRed = Color(0xFFDC2626);
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
    String nextCode = await DBHelper.getNextCustomerCode();
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
        backgroundColor: _kBgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Delete Customer',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: _kTxtHigh,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this customer? This action cannot be undone.',
          style: TextStyle(fontSize: 13, color: _kTxtMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL', style: TextStyle(color: _kTxtLow)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kRed,
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
      await DBHelper.deleteCustomer(widget.customer!.id!);
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
      hintStyle: const TextStyle(fontSize: 12, color: _kTxtLow),
      labelStyle: const TextStyle(fontSize: 12, color: _kTxtMid),
      floatingLabelStyle: const TextStyle(
        fontSize: 11,
        color: _kAccent,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _kAccent, width: 1.5),
      ),
      filled: true,
      fillColor: _kBgCard,
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
              color: _kAccent,
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.only(right: 8),
          ),
          if (icon != null) ...[
            Icon(icon, size: 14, color: _kAccent),
            const SizedBox(width: 5),
          ],
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: _kTxtMid,
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
      backgroundColor: _kBgPage,
      appBar: AppBar(
        backgroundColor: _kNavy,
        elevation: 0,
        toolbarHeight: 54,
        iconTheme: const IconThemeData(color: Colors.white, size: 20),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isEdit ? 'Edit Customer' : 'New Customer',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              isEdit ? 'Update Details' : 'Add New Customer',
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
              icon: const Icon(Icons.delete_outline, color: _kRed, size: 20),
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
                        color: _kBgCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _kBorder),
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
                                        activeColor: _kAccent,
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
                                    const Text(
                                      'Auto Code',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _kTxtMid,
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
                              color: _kTxtMid,
                            ),
                            decoration: _inputDeco('Customer Code').copyWith(
                              fillColor: _autoCode ? _kBgPage : _kBgCard,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Name
                          TextFormField(
                            controller: _nameCtrl,
                            style: const TextStyle(fontSize: 13),
                            decoration: _inputDeco('Customer Name'),
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
                            decoration: _inputDeco('Address'),
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
                        color: _kBgCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel(
                            'Vehicle Information',
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
        color: _kBgCard,
        border: Border(top: BorderSide(color: _kBorder, width: 1)),
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
                  backgroundColor: _kBgPage,
                  foregroundColor: _kTxtMid,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: _kBorderMid),
                  ),
                ),
                child: const Text(
                  'ABORT',
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
                              content: const Text(
                                'Customer name cannot be empty!',
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
                            await DBHelper.updateCustomer(customer);
                          } else {
                            await DBHelper.insertCustomer(customer);
                          }

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Customer saved successfully!'),
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
                              content: Text('Failed to save customer: $e'),
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
                  _isSaving ? 'SAVING...' : 'SAVE',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kNavy,
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
