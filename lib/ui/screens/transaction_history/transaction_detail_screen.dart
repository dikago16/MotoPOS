import '../../../core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_item_model.dart';
import '../../../data/database_service.dart';
import '../../../providers/printer_provider.dart';
import '../../../providers/selling_provider.dart';
import '../../../data/models/customer_model.dart';
import '../../../core/services/app_localizations.dart';
import '../../widgets/app_loading.dart';
import 'package:whatsapp_share_plus/whatsapp_share_plus.dart';
import '../../../services/receipt_image_service.dart';
import '../../widgets/security_pin_dialog.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────

const _kColHeader = TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.w700,
  color: Color(0xFF94A3B8),
  letterSpacing: 0.9,
);
// ──────────────────────────────────────────────────────────────────────────────

class TransactionDetailScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  List<TransactionItemModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    final items = await context.read<DatabaseService>().getTransactionItems(
      widget.transaction.id ?? 0,
    );
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  String _formatRupiah(double v) =>
      'Rp ${NumberFormat('#,###', 'id_ID').format(v)}';

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.transaction.transactionDate);
    final printerProvider = context.watch<PrinterProvider>();
    final bool isPrinterConnected = printerProvider.isConnected;

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
              AppLocalizations.get('transaction_details'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${AppLocalizations.get('txn')} #${widget.transaction.id}',
              style: const TextStyle(
                color: Color(0xFF90AAC8),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'edit') {
                final verified = await SecurityPinDialog.verify(
                  context,
                  reason: AppLocalizations.get('security_pin_reason_edit_txn'),
                );
                if (!verified || !context.mounted) return;

                CustomerModel? customer;
                if (widget.transaction.customerId != null) {
                  final customers =
                      await context.read<DatabaseService>().getCustomers();
                  customer = customers
                      .where((c) => c.id == widget.transaction.customerId)
                      .firstOrNull;
                }
                if (context.mounted) {
                  context.read<SellingProvider>().loadTransactionForEdit(
                        widget.transaction,
                        _items,
                        customer,
                      );
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              } else if (value == 'print') {
                if (isPrinterConnected) {
                  _showPrintConfirmationDialog(printerProvider);
                }
              } else if (value == 'wa') {
                _showWhatsAppChooser();
              } else if (value == 'delete') {
                final verified = await SecurityPinDialog.verify(
                  context,
                  reason: AppLocalizations.get('security_pin_reason_delete_txn'),
                );
                if (!verified || !context.mounted) return;

                _confirmDeleteTransaction();
              }
            },
            itemBuilder: (context) {
              String formatLabel(String text) {
                if (text.isEmpty) return text;
                return text[0].toUpperCase() + text.substring(1).toLowerCase();
              }
              return [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(formatLabel(AppLocalizations.get('edit'))),
                ),
                PopupMenuItem(
                  value: 'print',
                  enabled: isPrinterConnected,
                  child: Text(
                    formatLabel(AppLocalizations.get('print')),
                    style: TextStyle(
                      color: isPrinterConnected ? AppColors.txtHigh : AppColors.txtLow,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'wa',
                  child: Text('Send WA'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(formatLabel(AppLocalizations.get('delete'))),
                ),
              ];
            },
            color: AppColors.bgCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTransactionInfo(date),
            Expanded(
              child: _isLoading
                  ? const Center(child: AppLoading())
                  : _buildItemsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionInfo(DateTime date) {
    return Container(
      width: double.infinity,
      color: AppColors.bgCard,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.get('vehicle_no'),
                      style: _kColHeader,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (widget.transaction.vehicleNo == null ||
                              widget.transaction.vehicleNo!.isEmpty)
                          ? '-'
                          : widget.transaction.vehicleNo!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.txtHigh,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppLocalizations.get('date'), style: _kColHeader),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMMM yyyy HH:mm').format(date),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.txtMid,
                    ),
                  ),
                  if (widget.transaction.cashierName != null &&
                      widget.transaction.cashierName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${AppLocalizations.get('role_cashier')}: ${widget.transaction.cashierName}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.get('cash_amount'), style: _kColHeader),
                  const SizedBox(height: 4),
                  Text(
                    _formatRupiah(widget.transaction.cashAmount),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.txtMid,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppLocalizations.get('change_amount'),
                    style: _kColHeader,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRupiah(widget.transaction.changeAmount),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.txtMid,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Container(
      color: AppColors.bgCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.tableHead,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _colHeader(AppLocalizations.get('item'), flex: 4),
                _colHeaderCenter(AppLocalizations.get('qty'), flex: 1),
                _colHeaderRight(AppLocalizations.get('price'), flex: 3),
                _colHeaderRight(AppLocalizations.get('subtotal'), flex: 3),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final item = _items[index];
                final isAlt = index % 2 == 1;
                return Container(
                  color: isAlt ? AppColors.rowAlt : AppColors.bgCard,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.itemName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.txtHigh,
                              ),
                            ),
                            Text(
                              item.category,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.txtLow,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.txtMid,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _formatRupiah(item.price),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.txtMid,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _formatRupiah(item.subtotal),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.txtHigh,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            color: AppColors.tableHead,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${AppLocalizations.get('total_amount')}:  ',
                  style: _kColHeader,
                ),
                Text(
                  _formatRupiah(widget.transaction.totalAmount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colHeader(String label, {required int flex}) => Expanded(
    flex: flex,
    child: Text(label, style: _kColHeader),
  );

  Widget _colHeaderCenter(String label, {required int flex}) => Expanded(
    flex: flex,
    child: Center(child: Text(label, style: _kColHeader)),
  );

  Widget _colHeaderRight(String label, {required int flex}) => Expanded(
    flex: flex,
    child: Align(
      alignment: Alignment.centerRight,
      child: Text(label, style: _kColHeader),
    ),
  );

  void _confirmDeleteTransaction() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.get('delete') ,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.txtHigh,
              ),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.get('delete_confirm_msg') ,
          style: const TextStyle(fontSize: 13, color: AppColors.txtMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.get('cancel'),
              style: const TextStyle(
                color: AppColors.txtLow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<DatabaseService>().deleteTransaction(widget.transaction.id!);
              if (mounted) {
                Navigator.pop(context, true); // Pop out of detail screen and return true to refresh
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              AppLocalizations.get('delete') ,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrintConfirmationDialog(PrinterProvider printerProvider) {
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
                color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.print,
                color: Color(0xFF16A34A),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.get('print_receipt'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.txtHigh,
              ),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.get('print_confirm_msg'),
          style: const TextStyle(fontSize: 13, color: AppColors.txtMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.get('cancel'),
              style: const TextStyle(
                color: AppColors.txtLow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await printerProvider.printReceipt(
                transaction: widget.transaction,
                items: _items,
                transactionId: widget.transaction.id ?? 0,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? AppLocalizations.get('print_success')
                          : AppLocalizations.get('print_failed'),
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.print, size: 16),
            label: Text(
              AppLocalizations.get('print'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWhatsAppChooser() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.share_rounded,
                color: Color(0xFF25D366),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.get('send_via'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.txtHigh,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFF25D366),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              title: const Text(
                'WhatsApp',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.txtHigh,
                ),
              ),
              subtitle: Text(
                AppLocalizations.get('send_wa_subtitle'),
                style: const TextStyle(fontSize: 12, color: AppColors.txtMid),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _shareReceiptImage(WhatsAppTarget.standard);
              },
            ),
            const SizedBox(height: 6),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFF128C7E),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'B',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              title: const Text(
                'WhatsApp Business',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.txtHigh,
                ),
              ),
              subtitle: Text(
                AppLocalizations.get('send_wa_business_subtitle'),
                style: const TextStyle(fontSize: 12, color: AppColors.txtMid),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _shareReceiptImage(WhatsAppTarget.business);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareReceiptImage(WhatsAppTarget target) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    var dialogClosed = false;

    void closeLoading() {
      if (!dialogClosed) {
        dialogClosed = true;
        navigator.pop();
      }
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF25D366),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    AppLocalizations.get('generating_receipt'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.txtHigh,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final dbService = context.read<DatabaseService>();
      final storeInfo = await dbService.getStoreInfo();

      final imagePath = await ReceiptImageService.generateReceiptFile(
        transaction: widget.transaction,
        items: _items,
        storeInfo: storeInfo,
      );

      closeLoading();

      await WhatsAppShare.share(
        files: [
          ShareFile.fromPath(imagePath, mimeType: 'image/png'),
        ],
        target: target,
      );
    } catch (e) {
      closeLoading();

      String errorMsg = e.toString();
      if (e is WhatsAppNotInstalledException) {
        errorMsg = target == WhatsAppTarget.business
            ? AppLocalizations.get('whatsapp_business_not_installed')
            : AppLocalizations.get('whatsapp_not_installed');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
