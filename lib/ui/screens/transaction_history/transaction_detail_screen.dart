import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_item_model.dart';
import '../../../data/db_helper.dart';
import '../../../providers/printer_provider.dart';
import '../../../core/services/app_localizations.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────
const _kNavy = Color(0xFF0D1B2A);
const _kAccent = Color(0xFF2563EB);
const _kBgPage = Color(0xFFF1F5F9);
const _kBgCard = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE2E8F0);
const _kTableHead = Color(0xFFF8FAFC);
const _kRowAlt = Color(0xFFFAFBFD);
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
    final items = await DBHelper.getTransactionItems(
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
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: isPrinterConnected
                  ? () => _showPrintConfirmationDialog(printerProvider)
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.print,
                  color: isPrinterConnected
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                  size: 20,
                ),
              ),
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
                  ? const Center(
                      child: CircularProgressIndicator(color: _kAccent),
                    )
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
      color: _kBgCard,
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
                    Text(AppLocalizations.get('vehicle_no'), style: _kColHeader),
                    const SizedBox(height: 4),
                    Text(
                      (widget.transaction.vehicleNo == null ||
                              widget.transaction.vehicleNo!.isEmpty)
                          ? '-'
                          : widget.transaction.vehicleNo!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kTxtHigh,
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
                      color: _kTxtMid,
                    ),
                  ),
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
                    style: const TextStyle(fontSize: 12, color: _kTxtMid),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppLocalizations.get('change_amount'), style: _kColHeader),
                  const SizedBox(height: 4),
                  Text(
                    _formatRupiah(widget.transaction.changeAmount),
                    style: const TextStyle(fontSize: 12, color: _kTxtMid),
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
      color: _kBgCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: _kTableHead,
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
          const Divider(height: 1, color: _kBorder),
          Expanded(
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: _kBorder),
              itemBuilder: (context, index) {
                final item = _items[index];
                final isAlt = index % 2 == 1;
                return Container(
                  color: isAlt ? _kRowAlt : _kBgCard,
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
                                color: _kTxtHigh,
                              ),
                            ),
                            Text(
                              item.category,
                              style: const TextStyle(
                                fontSize: 10,
                                color: _kTxtLow,
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
                              color: _kTxtMid,
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
                              color: _kTxtMid,
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
                              color: _kTxtHigh,
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
            color: _kTableHead,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${AppLocalizations.get('total_amount')}:  ', style: _kColHeader),
                Text(
                  _formatRupiah(widget.transaction.totalAmount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _kAccent,
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

  void _showPrintConfirmationDialog(PrinterProvider printerProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kBgCard,
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
                color: _kTxtHigh,
              ),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.get('print_confirm_msg'),
          style: const TextStyle(fontSize: 13, color: _kTxtMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.get('cancel'),
              style: const TextStyle(color: _kTxtLow, fontWeight: FontWeight.w600),
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
                    content: Text(success ? AppLocalizations.get('print_success') : AppLocalizations.get('print_failed')),
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
}
