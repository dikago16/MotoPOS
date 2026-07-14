import 'package:flutter/material.dart';
import 'supplier_detail_screen.dart';
import '../../../data/models/supplier_model.dart';
import '../../../data/db_helper.dart';
import '../../../core/services/app_localizations.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────
const _kNavy = Color(0xFF0D1B2A);
const _kAccent = Color(0xFF2563EB);
const _kAccentSoft = Color(0xFFEFF6FF);
const _kBgPage = Color(0xFFF1F5F9);
const _kBgCard = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE2E8F0);
const _kTableHead = Color(0xFFF8FAFC);
const _kTxtMid = Color(0xFF475569);
const _kTxtLow = Color(0xFF94A3B8);
const _kTxtHigh = Color(0xFF0F172A);

const _kColHeader = TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.w700,
  color: Color(0xFF94A3B8),
  letterSpacing: 0.9,
);
// ──────────────────────────────────────────────────────────────────────────────

class ManageSupplierScreen extends StatefulWidget {
  const ManageSupplierScreen({super.key});

  @override
  State<ManageSupplierScreen> createState() => _ManageSupplierScreenState();
}

class _ManageSupplierScreenState extends State<ManageSupplierScreen> {
  List<SupplierModel> _suppliers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  Future<void> _fetchSuppliers() async {
    setState(() => _isLoading = true);
    final suppliers = await DBHelper.getSuppliers();
    setState(() {
      _suppliers = suppliers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgPage,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchCard(),
                    const SizedBox(height: 10),
                    _buildSuppliersList(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _kNavy,
      elevation: 0,
      toolbarHeight: 54,
      iconTheme: const IconThemeData(color: Colors.white, size: 20),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.get('manage_suppliers'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            AppLocalizations.get('add_edit_supplier'),
            style: const TextStyle(
              color: Color(0xFF90AAC8),
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SupplierDetailScreen(),
              ),
            );
            if (result == true) {
              _fetchSuppliers();
            }
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  InputDecoration _inputDeco(String label, {Widget? suffixIcon}) {
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      suffixIcon: suffixIcon,
    );
  }

  Widget _sectionLabel(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
            Icon(icon, size: 12, color: _kAccent),
            const SizedBox(width: 5),
          ],
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: _kTxtMid,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: _kBgCard,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(AppLocalizations.get('search_supplier'), icon: Icons.search),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  style: const TextStyle(fontSize: 13),
                  decoration: _inputDeco(AppLocalizations.get('code_name')),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  // Filter action
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 38,
                  width: 44,
                  decoration: BoxDecoration(
                    color: _kAccentSoft,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _kAccent.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: _kAccent,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuppliersList() {
    return Container(
      decoration: BoxDecoration(
        color: _kBgCard,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: _sectionLabel(AppLocalizations.get('supplier_list'), icon: Icons.business),
          ),
          Container(
            color: _kTableHead,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              children: [
                Expanded(flex: 5, child: Text(AppLocalizations.get('supplier'), style: _kColHeader)),
                Expanded(flex: 3, child: Text(AppLocalizations.get('contact'), style: _kColHeader)),
                const SizedBox(width: 26), // Space for action button
              ],
            ),
          ),
          const Divider(height: 1, color: _kBorder),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_suppliers.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              width: double.infinity,
              child: Column(
                children: [
                  const Icon(Icons.business, size: 30, color: _kTxtLow),
                  const SizedBox(height: 7),
                  Text(
                    AppLocalizations.get('no_suppliers_found'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: _kTxtLow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suppliers.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: _kBorder),
              itemBuilder: (context, index) {
                final supplier = _suppliers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              supplier.supplierName.isEmpty
                                  ? AppLocalizations.get('unknown_supplier')
                                  : supplier.supplierName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _kTxtHigh,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              supplier.supplierCode,
                              style: const TextStyle(
                                fontSize: 10,
                                color: _kTxtMid,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              supplier.phone.isEmpty ? '-' : supplier.phone,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _kTxtMid,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              supplier.address.isEmpty ? '-' : supplier.address,
                              style: const TextStyle(
                                fontSize: 10,
                                color: _kTxtLow,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          size: 16,
                          color: _kTxtMid,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SupplierDetailScreen(supplier: supplier),
                              ),
                            );
                            if (result == true) {
                              _fetchSuppliers();
                            }
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(supplier);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Text(
                                  AppLocalizations.get('edit'),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text(
                                  AppLocalizations.get('delete'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(SupplierModel supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _kBgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.get('delete_supplier'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kTxtHigh,
                ),
              ),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: _kTxtMid,
                height: 1.5,
              ),
              children: [
                TextSpan(text: '${AppLocalizations.get('delete_confirm')}\n'),
                TextSpan(
                  text:
                      '${supplier.supplierName.isEmpty ? AppLocalizations.get('unknown_supplier') : supplier.supplierName} (${supplier.supplierCode})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _kTxtHigh,
                  ),
                ),
                const TextSpan(text: '?\nThis action cannot be undone.'),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: _kTxtMid,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(AppLocalizations.get('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                AppLocalizations.get('delete'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && supplier.id != null) {
      await DBHelper.deleteSupplier(supplier.id!);
      _fetchSuppliers();
    }
  }
}
