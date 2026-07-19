import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/app_localizations.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../data/database_service.dart';
import '../../../../providers/selling_provider.dart';
import '../../../widgets/app_loading.dart';

class CustomerSelector extends StatelessWidget {
  const CustomerSelector({super.key});

  void _showCustomerSelectionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgPage,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return const CustomerSelectionBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SellingProvider>();
    final selectedCustomer = provider.selectedCustomer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.get('customer'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.txtMid,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedCustomer != null
                        ? (selectedCustomer.vehicleNo.isNotEmpty
                              ? '${selectedCustomer.name} (${selectedCustomer.vehicleNo})'
                              : selectedCustomer.name)
                        : AppLocalizations.get('no_customer_selected'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selectedCustomer != null ? AppColors.txtHigh : AppColors.txtLow,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (selectedCustomer != null)
            SizedBox(
              height: 30,
              width: 30,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.txtLow, size: 18),
                onPressed: () {
                  context.read<SellingProvider>().setCustomer(null);
                },
                tooltip: AppLocalizations.get('remove_customer'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            )
          else
            SizedBox(
              height: 30,
              child: TextButton(
                onPressed: () => _showCustomerSelectionDialog(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppLocalizations.get('select'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomerSelectionBottomSheet extends StatefulWidget {
  const CustomerSelectionBottomSheet({super.key});

  @override
  State<CustomerSelectionBottomSheet> createState() =>
      _CustomerSelectionBottomSheetState();
}

class _CustomerSelectionBottomSheetState
    extends State<CustomerSelectionBottomSheet> {
  List<CustomerModel> _allCustomers = [];
  List<CustomerModel> _filteredCustomers = [];
  bool _isLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    final customers = await context.read<DatabaseService>().getCustomers();
    if (mounted) {
      setState(() {
        _allCustomers = customers;
        _filteredCustomers = customers;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCustomers = _allCustomers;
      });
    } else {
      final lowerQuery = query.toLowerCase();
      setState(() {
        _filteredCustomers = _allCustomers.where((c) {
          return c.name.toLowerCase().contains(lowerQuery) ||
              c.customerCode.toLowerCase().contains(lowerQuery) ||
              c.phone.toLowerCase().contains(lowerQuery) ||
              c.vehicleNo.toLowerCase().contains(lowerQuery);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.85,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.get('select_customer'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.txtHigh,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.get('search_customer_hint'),
                      hintStyle: const TextStyle(fontSize: 10, color: AppColors.txtLow),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: AppColors.txtMid,
                      ),
                      filled: true,
                      fillColor: AppColors.bgPage,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.accent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const AppLoading(isFullScreen: true)
                  : _filteredCustomers.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.get('no_customers_found'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.txtMid),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredCustomers.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final customer = _filteredCustomers[index];
                        return ListTile(
                          title: Text(
                            customer.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.txtHigh,
                            ),
                          ),
                          subtitle: Text(
                            '${customer.phone}\n${customer.vehicleNo}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.txtMid,
                            ),
                          ),
                          isThreeLine: true,
                          onTap: () {
                            context.read<SellingProvider>().setCustomer(
                              customer,
                            );
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
