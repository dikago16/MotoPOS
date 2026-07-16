import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/app_localizations.dart';

import '../../manage_customer/manage_customer_screen.dart';
import '../../manage_item/manage_item_screen.dart';
import '../../manage_category/manage_category_screen.dart';
import '../../manage_supplier/manage_supplier_screen.dart';
import '../../purchase_invoice/manage_purchase_invoice_screen.dart';
import '../../daily_report/daily_report_screen.dart';
import '../../transaction_history/transaction_history_screen.dart';
import '../../notes/notes_screen.dart';
import '../../ask_ai/ask_ai_screen.dart';
import '../../circuits/circuits_screen.dart';
import '../../settings/settings_screen.dart';

class SellingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onProductsChanged;

  const SellingAppBar({
    super.key,
    required this.onProductsChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(54);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.navy,
      elevation: 0,
      toolbarHeight: 54,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'MotoPOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
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
          icon: const Icon(Icons.settings, color: Colors.white, size: 20),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
          color: AppColors.bgCard,
          onSelected: (value) async {
            if (value == 'manage_customer') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageCustomerScreen(),
                ),
              );
            } else if (value == 'manage_item') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageItemScreen(),
                ),
              );
              onProductsChanged();
            } else if (value == 'manage_category') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageCategoryScreen(),
                ),
              );
              onProductsChanged();
            } else if (value == 'manage_supplier') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageSupplierScreen(),
                ),
              );
            } else if (value == 'purchase_invoice') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManagePurchaseInvoiceScreen(),
                ),
              );
              onProductsChanged();
            } else if (value == 'daily_report') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DailyReportScreen(),
                ),
              );
            } else if (value == 'transaction_history') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionHistoryScreen(),
                ),
              );
            } else if (value == 'notes') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotesScreen(),
                ),
              );
            } else if (value == 'ask_ai') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AskAiScreen(),
                ),
              );
            } else if (value == 'circuits') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CircuitsScreen(),
                ),
              );
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                value: 'manage_customer',
                child: Text(
                  AppLocalizations.get('manage_customer'),
                  style: const TextStyle(fontSize: 13, color: AppColors.txtHigh),
                ),
              ),
              PopupMenuItem(
                value: 'manage_item',
                child: Text(
                  AppLocalizations.get('manage_item'),
                  style: const TextStyle(fontSize: 13, color: AppColors.txtHigh),
                ),
              ),
              PopupMenuItem(
                value: 'manage_category',
                child: Text(
                  AppLocalizations.get('manage_category'),
                  style: const TextStyle(fontSize: 13, color: AppColors.txtHigh),
                ),
              ),
              PopupMenuItem(
                value: 'manage_supplier',
                child: Text(
                  AppLocalizations.get('manage_supplier'),
                  style: const TextStyle(fontSize: 13, color: AppColors.txtHigh),
                ),
              ),
              PopupMenuItem(
                value: 'purchase_invoice',
                child: Text(
                  AppLocalizations.get('purchase_invoice'),
                  style: const TextStyle(fontSize: 13, color: AppColors.txtHigh),
                ),
              ),
              PopupMenuItem(
                value: 'daily_report',
                child: Text(
                  AppLocalizations.get('daily_report'),
                  style: const TextStyle(fontSize: 13, color: AppColors.txtHigh),
                ),
              ),
              PopupMenuItem(
                value: 'transaction_history',
                child: Text(
                  AppLocalizations.get('transaction_history'),
                  style: const TextStyle(fontSize: 13, color: AppColors.txtHigh),
                ),
              ),
              PopupMenuItem(
                value: 'notes',
                child: Text(
                  AppLocalizations.get('notes'),
                  style: const TextStyle(fontSize: 13, color: AppColors.txtHigh),
                ),
              ),
              PopupMenuItem(
                value: 'ask_ai',
                child: Text(
                  AppLocalizations.get('ask_ai'),
                  style: const TextStyle(fontSize: 13, color: AppColors.txtHigh),
                ),
              ),
              PopupMenuItem(
                value: 'circuits',
                child: Text(
                  AppLocalizations.get('circuits'),
                  style: const TextStyle(fontSize: 13, color: AppColors.txtHigh),
                ),
              ),
            ];
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
