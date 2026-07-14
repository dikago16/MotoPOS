import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/purchase_invoice_model.dart';
import '../../../data/models/purchase_invoice_item_model.dart';
import '../../../data/db_helper.dart';
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

class PurchaseInvoiceDetailScreen extends StatefulWidget {
  final PurchaseInvoiceModel invoice;

  const PurchaseInvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<PurchaseInvoiceDetailScreen> createState() =>
      _PurchaseInvoiceDetailScreenState();
}

class _PurchaseInvoiceDetailScreenState
    extends State<PurchaseInvoiceDetailScreen> {
  List<PurchaseInvoiceItemModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    final items = await DBHelper.getPurchaseInvoiceItems(
      widget.invoice.id ?? 0,
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
    final date = DateTime.parse(widget.invoice.invoiceDate);

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
              AppLocalizations.get('invoice_detail'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              widget.invoice.invoiceCode,
              style: const TextStyle(
                color: Color(0xFF90AAC8),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildInvoiceInfo(date),
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

  Widget _buildInvoiceInfo(DateTime date) {
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
                    Text(AppLocalizations.get('supplier'), style: _kColHeader),
                    const SizedBox(height: 4),
                    Text(
                      widget.invoice.supplierName.isEmpty ? AppLocalizations.get('unknown_supplier') : widget.invoice.supplierName,
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
                    DateFormat('dd MMMM yyyy').format(date),
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
          if (widget.invoice.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(AppLocalizations.get('notes'), style: _kColHeader),
            const SizedBox(height: 4),
            Text(
              widget.invoice.notes,
              style: const TextStyle(fontSize: 12, color: _kTxtMid),
            ),
          ],
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
                              item.itemCode,
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
                            _formatRupiah(item.buyingPrice),
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
                const Text('TOTAL AMOUNT:  ', style: _kColHeader),
                Text(
                  _formatRupiah(widget.invoice.totalAmount),
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
}
