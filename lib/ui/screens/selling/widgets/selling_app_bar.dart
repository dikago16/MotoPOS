import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/app_localizations.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../data/models/user_model.dart';

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
import '../../../widgets/security_pin_dialog.dart';

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
        Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final user = auth.currentUser;
            final isOwner = user?.isOwner ?? false;
            final name = user?.username ?? 'Admin';

            return InkWell(
              onTap: () => _showSwitchUserDialog(context, auth),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isOwner
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOwner ? Icons.admin_panel_settings : Icons.person,
                      size: 13,
                      color: isOwner ? const Color(0xFFFBBF24) : Colors.white,
                    ),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 80),
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 14,
                      color: Color(0xFF90AAC8),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white, size: 20),
          onPressed: () async {
            final auth = context.read<AuthProvider>();
            if (!auth.isOwner) {
              final verified = await SecurityPinDialog.verify(
                context,
                reason: AppLocalizations.get('security_pin_reason_settings'),
              );
              if (!verified || !context.mounted) return;
            }
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
            final auth = context.read<AuthProvider>();
            if (value == 'manage_customer') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageCustomerScreen(),
                ),
              );
            } else if (value == 'manage_item') {
              if (!auth.isOwner) {
                final verified = await SecurityPinDialog.verify(
                  context,
                  reason: AppLocalizations.get('security_pin_reason_manage_item'),
                );
                if (!verified || !context.mounted) return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageItemScreen(),
                ),
              );
              onProductsChanged();
            } else if (value == 'manage_category') {
              if (!auth.isOwner) {
                final verified = await SecurityPinDialog.verify(
                  context,
                  reason: AppLocalizations.get('security_pin_reason_category'),
                );
                if (!verified || !context.mounted) return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageCategoryScreen(),
                ),
              );
              onProductsChanged();
            } else if (value == 'manage_supplier') {
              if (!auth.isOwner) {
                final verified = await SecurityPinDialog.verify(
                  context,
                  reason: AppLocalizations.get('security_pin_reason_supplier'),
                );
                if (!verified || !context.mounted) return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageSupplierScreen(),
                ),
              );
            } else if (value == 'purchase_invoice') {
              if (!auth.isOwner) {
                final verified = await SecurityPinDialog.verify(
                  context,
                  reason: AppLocalizations.get('security_pin_reason_purchase_invoice'),
                );
                if (!verified || !context.mounted) return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManagePurchaseInvoiceScreen(),
                ),
              );
              onProductsChanged();
            } else if (value == 'daily_report') {
              if (!auth.isOwner) {
                final verified = await SecurityPinDialog.verify(
                  context,
                  reason: AppLocalizations.get('security_pin_reason_daily_report'),
                );
                if (!verified || !context.mounted) return;
              }
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

  void _showSwitchUserDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.people_outline, color: AppColors.navy, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.get('switch_user'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih staf/kasir yang bertugas:',
                style: const TextStyle(fontSize: 12, color: AppColors.txtMid),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: auth.activeUsers.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final user = auth.activeUsers[index];
                    final isCurrent = user.id == auth.currentUser?.id;
                    final isOwner = user.isOwner;

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: isOwner
                            ? AppColors.navy.withValues(alpha: 0.1)
                            : AppColors.green.withValues(alpha: 0.1),
                        child: Icon(
                          isOwner ? Icons.admin_panel_settings : Icons.person,
                          color: isOwner ? AppColors.navy : AppColors.green,
                          size: 16,
                        ),
                      ),
                      title: Text(
                        user.username,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.txtHigh,
                        ),
                      ),
                      subtitle: Text(
                        isOwner
                            ? AppLocalizations.get('role_owner')
                            : AppLocalizations.get('role_cashier'),
                        style: TextStyle(
                          fontSize: 10,
                          color: isOwner ? AppColors.navy : AppColors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: isCurrent
                          ? const Icon(Icons.check_circle,
                              color: AppColors.green, size: 20)
                          : null,
                      onTap: () async {
                        Navigator.pop(ctx);
                        if (!isCurrent) {
                          _promptPinAndSwitch(context, auth, user);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.get('close')),
          ),
        ],
      ),
    );
  }

  void _promptPinAndSwitch(
      BuildContext context, AuthProvider auth, UserModel targetUser) {
    final pinCtrl = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            '${AppLocalizations.get('enter_staff_pin')} ${targetUser.username}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinCtrl,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  hintText: '••••••',
                  filled: true,
                  fillColor: AppColors.bgPage,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onSubmitted: (_) async {
                  final pin = pinCtrl.text.trim();
                  final success =
                      await auth.verifyAndSwitchUser(targetUser, pin);
                  if (ctx.mounted) {
                    if (success) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${AppLocalizations.get('login_as')}: ${targetUser.username}'),
                          backgroundColor: AppColors.green,
                        ),
                      );
                    } else {
                      setDialogState(() {
                        error = AppLocalizations.get('security_pin_incorrect');
                        pinCtrl.clear();
                      });
                    }
                  }
                },
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!,
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.get('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final pin = pinCtrl.text.trim();
                final success =
                    await auth.verifyAndSwitchUser(targetUser, pin);
                if (ctx.mounted) {
                  if (success) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${AppLocalizations.get('login_as')}: ${targetUser.username}'),
                        backgroundColor: AppColors.green,
                      ),
                    );
                  } else {
                    setDialogState(() {
                      error = AppLocalizations.get('security_pin_incorrect');
                      pinCtrl.clear();
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(AppLocalizations.get('confirm')),
            ),
          ],
        ),
      ),
    );
  }
}
