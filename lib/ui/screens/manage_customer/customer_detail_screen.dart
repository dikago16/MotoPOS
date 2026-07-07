import 'package:flutter/material.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/db_helper.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────
const _kNavy = Color(0xFF0D1B2A);
const _kAccent = Color(0xFF2563EB);
const _kBgPage = Color(0xFFF1F5F9);
const _kBgCard = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE2E8F0);
const _kTxtMid = Color(0xFF475569);
const _kTxtHigh = Color(0xFF0F172A);
const _kRed = Color(0xFFDC2626);
// ──────────────────────────────────────────────────────────────────────────────

class CustomerDetailScreen extends StatefulWidget {
  final CustomerModel? customer;

  const CustomerDetailScreen({super.key, this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _vehicleNoCtrl = TextEditingController();
  final _vehicleTypeCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String _customerCode = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    if (widget.customer != null) {
      _customerCode = widget.customer!.customerCode;
      _nameCtrl.text = widget.customer!.name;
      _phoneCtrl.text = widget.customer!.phone;
      _vehicleNoCtrl.text = widget.customer!.vehicleNo;
      _vehicleTypeCtrl.text = widget.customer!.vehicleType;
      _addressCtrl.text = widget.customer!.address;
    } else {
      _customerCode = await DBHelper.getNextCustomerCode();
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _vehicleNoCtrl.dispose();
    _vehicleTypeCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final customer = CustomerModel(
      id: widget.customer?.id,
      customerCode: _customerCode,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      vehicleNo: _vehicleNoCtrl.text.trim(),
      vehicleType: _vehicleTypeCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
    );

    if (widget.customer == null) {
      await DBHelper.insertCustomer(customer);
    } else {
      await DBHelper.updateCustomer(customer);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.customer == null
                ? 'Customer saved successfully'
                : 'Customer updated successfully',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _deleteCustomer() async {
    if (widget.customer?.id == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this customer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: _kTxtMid)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: _kRed),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DBHelper.deleteCustomer(widget.customer!.id!);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    );
  }

  Widget _sectionLabel(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
            const SizedBox(width: 6),
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
    final isEditing = widget.customer != null;

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
              isEditing ? 'Edit Customer' : 'Add Customer',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!isEditing)
              const Text(
                'Create new customer record',
                style: TextStyle(
                  color: Color(0xFF90AAC8),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: _kRed, size: 20),
              onPressed: _deleteCustomer,
              tooltip: 'Delete',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kAccent))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                            _sectionLabel('Customer Info', icon: Icons.person),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    initialValue: _customerCode,
                                    enabled: false,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: _kTxtMid,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: _inputDeco('Customer Code'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 5,
                                  child: TextFormField(
                                    controller: _nameCtrl,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _kTxtHigh,
                                    ),
                                    decoration: _inputDeco('Name *'),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Name is required';
                                      }
                                      return null;
                                    },
                                    textCapitalization: TextCapitalization.words,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneCtrl,
                              style: const TextStyle(fontSize: 13),
                              decoration: _inputDeco('Phone Number'),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _addressCtrl,
                              style: const TextStyle(fontSize: 13),
                              decoration: _inputDeco('Address'),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
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
                            _sectionLabel('Vehicle Info', icon: Icons.directions_car),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    controller: _vehicleNoCtrl,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _kTxtHigh,
                                    ),
                                    decoration: _inputDeco('Vehicle No (Plat)'),
                                    textCapitalization: TextCapitalization.characters,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _vehicleTypeCtrl,
                              style: const TextStyle(fontSize: 13),
                              decoration: _inputDeco('Vehicle Type (e.g. Honda Beat 2019)'),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _saveCustomer,
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text(
                            'SAVE CUSTOMER',
                            style: TextStyle(
                              fontSize: 13,
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
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
