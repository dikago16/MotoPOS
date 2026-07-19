import '../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_empty_state.dart';
import 'supplier_detail_screen.dart';
import '../../../data/models/supplier_model.dart';
import '../../../data/database_service.dart';
import '../../../core/services/app_localizations.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────

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
    final suppliers = await context.read<DatabaseService>().getSuppliers();
    setState(() {
      _suppliers = suppliers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
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
      backgroundColor: AppColors.navy,
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
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.only(right: 8),
          ),
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.accent),
            const SizedBox(width: 5),
          ],
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppColors.txtMid,
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
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(
            AppLocalizations.get('search_supplier'),
            icon: Icons.search,
          ),
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
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: AppColors.accent,
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
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: _sectionLabel(
              AppLocalizations.get('supplier_list'),
              icon: Icons.business,
            ),
          ),
          Container(
            color: AppColors.tableHead,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    AppLocalizations.get('supplier'),
                    style: _kColHeader,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    AppLocalizations.get('contact'),
                    style: _kColHeader,
                  ),
                ),
                const SizedBox(width: 26), // Space for action button
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: AppLoading(),
            )
          else if (_suppliers.isEmpty)
            AppEmptyState(
              icon: Icons.business,
              title: AppLocalizations.get('no_suppliers_found'),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suppliers.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.border),
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
                                color: AppColors.txtHigh,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              supplier.supplierCode,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.txtMid,
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
                                color: AppColors.txtMid,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              supplier.address.isEmpty ? '-' : supplier.address,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.txtLow,
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
                          color: AppColors.txtMid,
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
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.get('delete_supplier'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.txtHigh,
                ),
              ),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.txtMid,
                height: 1.5,
              ),
              children: [
                TextSpan(text: '${AppLocalizations.get('delete_confirm')}\n'),
                TextSpan(
                  text:
                      '${supplier.supplierName.isEmpty ? AppLocalizations.get('unknown_supplier') : supplier.supplierName} (${supplier.supplierCode})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.txtHigh,
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
                foregroundColor: AppColors.txtMid,
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
      if (!mounted) return;
      await context.read<DatabaseService>().deleteSupplier(supplier.id!);
      _fetchSuppliers();
    }
  }
}
