import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/db_helper.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/supplier_model.dart';
import '../../../data/models/purchase_invoice_model.dart';
import '../../../data/models/purchase_invoice_item_model.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────
const _kNavy = Color(0xFF0D1B2A);
const _kAccent = Color(0xFF2563EB);
const _kAccentSoft = Color(0xFFEFF6FF);
const _kBgPage = Color(0xFFF1F5F9);
const _kBgCard = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE2E8F0);
const _kBorderMid = Color(0xFFCBD5E1);
const _kTableHead = Color(0xFFF8FAFC);
const _kRowAlt = Color(0xFFFAFBFD);
const _kTxtHigh = Color(0xFF0F172A);
const _kTxtMid = Color(0xFF475569);
const _kTxtLow = Color(0xFF94A3B8);
const _kRed = Color(0xFFDC2626);
const _kGreen = Color(0xFF16A34A);

const _kColHeader = TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.w700,
  color: Color(0xFF94A3B8),
  letterSpacing: 0.9,
);
// ──────────────────────────────────────────────────────────────────────────────

class PurchaseInvoiceScreen extends StatefulWidget {
  const PurchaseInvoiceScreen({super.key});

  @override
  State<PurchaseInvoiceScreen> createState() => _PurchaseInvoiceScreenState();
}

class _PurchaseInvoiceScreenState extends State<PurchaseInvoiceScreen> {
  TextEditingController? _autoCompleteController;
  final _notesCtrl = TextEditingController();

  List<Product> _products = [];
  List<SupplierModel> _suppliers = [];
  List<_PurchaseItem> _invoiceItems = [];

  String _invoiceCode = '';
  SupplierModel? _selectedSupplier;
  DateTime _invoiceDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final products = await DBHelper.getProducts();
    final suppliers = await DBHelper.getSuppliers();
    final code = await DBHelper.getNextPurchaseInvoiceCode();
    setState(() {
      _products = products;
      _suppliers = suppliers;
      _invoiceCode = code;
    });
  }

  @override
  void dispose() {
    _autoCompleteController?.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _formatRupiah(double v) =>
      'Rp ${NumberFormat('#,###', 'id_ID').format(v)}';

  double get _totalAmount =>
      _invoiceItems.fold(0, (sum, item) => sum + item.subtotal);

  void _addProduct(Product product) {
    setState(() {
      final existingIdx = _invoiceItems.indexWhere(
        (e) => e.product.id == product.id,
      );
      if (existingIdx >= 0) {
        _invoiceItems[existingIdx].quantity++;
        _invoiceItems[existingIdx]._recalculate();
      } else {
        _invoiceItems.add(_PurchaseItem(product: product));
      }
    });
    Future.delayed(Duration.zero, () {
      _autoCompleteController?.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _invoiceItems.removeAt(index);
    });
  }

  void _updateQty(int index, int qty) {
    if (qty < 1) return;
    setState(() {
      _invoiceItems[index].quantity = qty;
      _invoiceItems[index]._recalculate();
    });
  }

  void _updatePrice(int index, double price) {
    setState(() {
      _invoiceItems[index].price = price;
      _invoiceItems[index]._recalculate();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2099),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _kNavy,
              onPrimary: Colors.white,
              surface: _kBgCard,
              onSurface: _kTxtHigh,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _invoiceDate = picked);
    }
  }

  void _clearForm() {
    setState(() {
      _invoiceItems.clear();
      _selectedSupplier = null;
      _notesCtrl.clear();
      _invoiceDate = DateTime.now();
    });
    _loadData();
  }

  Future<void> _saveInvoice() async {
    if (_selectedSupplier == null) {
      _showSnackBar('Please select a supplier', isError: true);
      return;
    }
    if (_invoiceItems.isEmpty) {
      _showSnackBar('Please add at least one item', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final invoice = PurchaseInvoiceModel(
        invoiceCode: _invoiceCode,
        invoiceDate: _invoiceDate.toIso8601String(),
        supplierId: _selectedSupplier!.id ?? 0,
        supplierName: _selectedSupplier!.supplierName,
        totalAmount: _totalAmount,
        notes: _notesCtrl.text,
      );

      final items = _invoiceItems
          .map(
            (e) => PurchaseInvoiceItemModel(
              productId: e.product.id ?? 0,
              itemCode: e.product.itemCode,
              itemName: e.product.itemName,
              quantity: e.quantity,
              buyingPrice: e.price,
              subtotal: e.subtotal,
            ),
          )
          .toList();

      await DBHelper.savePurchaseInvoice(invoice, items);

      if (!mounted) return;
      _showSnackBar('Invoice $_invoiceCode saved successfully!');
      _clearForm();
    } catch (e) {
      _showSnackBar('Failed to save: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _kRed : _kGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
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
                    _buildInvoiceHeader(),
                    const SizedBox(height: 10),
                    _buildItemSearch(),
                    const SizedBox(height: 10),
                    _buildItemsTable(),
                    const SizedBox(height: 8),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _kNavy,
      elevation: 0,
      toolbarHeight: 54,
      iconTheme: const IconThemeData(color: Colors.white, size: 20),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Purchase Invoice',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Record Item Purchases',
            style: TextStyle(
              color: Color(0xFF90AAC8),
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceHeader() {
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
          _sectionLabel('Invoice Information', icon: Icons.receipt_long),
          // Invoice Code & Date
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  style: const TextStyle(fontSize: 13, color: _kTxtMid),
                  decoration: _inputDeco('Invoice Code').copyWith(
                    fillColor: _kBgPage,
                  ),
                  controller: TextEditingController(text: _invoiceCode),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(6),
                  child: InputDecorator(
                    decoration: _inputDeco('Invoice Date'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy').format(_invoiceDate),
                          style: const TextStyle(
                            fontSize: 13,
                            color: _kTxtHigh,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: _kAccent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Supplier Dropdown
          DropdownButtonFormField<int>(
            value: _selectedSupplier?.id,
            decoration: _inputDeco('Select Supplier'),
            style: const TextStyle(fontSize: 13, color: _kTxtHigh),
            dropdownColor: _kBgCard,
            isExpanded: true,
            items: _suppliers.map((s) {
              return DropdownMenuItem<int>(
                value: s.id,
                child: Text(
                  '${s.supplierCode} — ${s.supplierName}',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedSupplier = _suppliers.firstWhere(
                  (s) => s.id == val,
                );
              });
            },
          ),
          const SizedBox(height: 10),
          // Notes
          TextFormField(
            controller: _notesCtrl,
            style: const TextStyle(fontSize: 13),
            maxLines: 2,
            decoration: _inputDeco('Notes (Optional)'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemSearch() {
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
          _sectionLabel('Add Items', icon: Icons.add_shopping_cart),
          LayoutBuilder(
            builder: (context, constraints) {
              return Autocomplete<Product>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Product>.empty();
                  }
                  final query = textEditingValue.text.toLowerCase();
                  return _products.where((Product product) {
                    return product.itemName.toLowerCase().contains(query) ||
                        product.itemCode.toLowerCase().contains(query);
                  });
                },
                displayStringForOption: (Product option) =>
                    option.itemName.isEmpty ? 'Unknown Item' : option.itemName,
                onSelected: (Product selection) {
                  _addProduct(selection);
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onEditingComplete) {
                  _autoCompleteController = controller;
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    style: const TextStyle(fontSize: 13),
                    decoration: _inputDeco(
                      'Search item by code or name',
                      suffixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: _kTxtLow,
                      ),
                    ),
                    onEditingComplete: onEditingComplete,
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: constraints.maxWidth,
                        constraints: const BoxConstraints(maxHeight: 250),
                        decoration: BoxDecoration(
                          color: _kBgCard,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _kBorder),
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1, color: _kBorder),
                          itemBuilder: (context, index) {
                            final Product option = options.elementAt(index);
                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            option.itemName.isEmpty
                                                ? 'Unknown Item'
                                                : option.itemName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: _kTxtHigh,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                option.itemCode,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: _kTxtMid,
                                                ),
                                              ),
                                              const Text(
                                                ' • ',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: _kTxtLow,
                                                ),
                                              ),
                                              Text(
                                                option.isCountStock
                                                    ? 'Stok: ${option.stockQty}'
                                                    : 'Non Stok',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: option.isCountStock
                                                      ? _kTxtMid
                                                      : _kTxtLow,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      option.buyingPrice > 0
                                          ? _formatRupiah(option.buyingPrice)
                                          : 'Not set',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: _kAccent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
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
            child: _sectionLabel(
              'Purchase Items',
              icon: Icons.list_alt,
            ),
          ),
          Container(
            color: _kTableHead,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              children: [
                _colHeader('ITEM', flex: 4),
                _colHeaderCenter('QTY', flex: 1),
                _colHeaderRight('PRICE', flex: 3),
                _colHeaderRight('SUBTOTAL', flex: 3),
                const SizedBox(width: 26),
              ],
            ),
          ),
          const Divider(height: 1, color: _kBorder),

          if (_invoiceItems.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              width: double.infinity,
              child: Column(
                children: const [
                  Icon(
                    Icons.add_shopping_cart,
                    size: 30,
                    color: _kTxtLow,
                  ),
                  SizedBox(height: 7),
                  Text(
                    'No items added yet',
                    style: TextStyle(
                      fontSize: 12,
                      color: _kTxtLow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._invoiceItems.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isAlt = idx % 2 == 1;
              return Column(
                children: [
                  Container(
                    color: isAlt ? _kRowAlt : _kBgCard,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.itemName.isEmpty
                                    ? 'Unknown Item'
                                    : item.product.itemName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _kTxtHigh,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.product.itemCode,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: _kTxtLow,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: InkWell(
                              onTap: () => _showQtyDialog(idx, item),
                              borderRadius: BorderRadius.circular(3),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _kAccentSoft,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: _kAccent.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _kAccent,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => _showPriceDialog(idx, item),
                              child: Text(
                                _formatRupiah(item.price),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _kTxtMid,
                                  decoration: TextDecoration.underline,
                                ),
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
                        SizedBox(
                          width: 26,
                          child: InkWell(
                            onTap: () => _removeItem(idx),
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.remove_circle_outline,
                                size: 16,
                                color: _kRed,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: _kBorder),
                ],
              );
            }),

          if (_invoiceItems.isNotEmpty)
            Container(
              color: _kTableHead,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _kBgCard,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: _kBorderMid),
                    ),
                    child: Text(
                      '${_invoiceItems.length} Item${_invoiceItems.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: _kTxtMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'TOTAL :',
                    style: TextStyle(
                      fontSize: 9,
                      color: _kTxtMid,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatRupiah(_totalAmount),
                    style: const TextStyle(
                      fontSize: 14,
                      color: _kAccent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 26),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showQtyDialog(int idx, _PurchaseItem item) {
    final ctrl = TextEditingController(text: '${item.quantity}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _kBgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Edit Quantity',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        content: TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(fontSize: 14),
          decoration: _inputDeco('Quantity'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: _kTxtLow)),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(ctrl.text) ?? 1;
              _updateQty(idx, qty);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _kNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPriceDialog(int idx, _PurchaseItem item) {
    final ctrl = TextEditingController(text: item.price.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _kBgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Edit Buying Price',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        content: TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(fontSize: 14),
          decoration: _inputDeco('Price'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: _kTxtLow)),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(ctrl.text) ?? 0;
              _updatePrice(idx, price);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _kNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('OK'),
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

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: _kBgCard,
        border: const Border(top: BorderSide(color: _kBorder, width: 1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: _clearForm,
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
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveInvoice,
                icon: _isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
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

// ─── Helper class for managing purchase items in-memory ──────────────────────
class _PurchaseItem {
  final Product product;
  int quantity;
  double price;
  double subtotal;

  _PurchaseItem({
    required this.product,
    this.quantity = 1,
    double? price,
  })  : price = price ?? product.buyingPrice,
        subtotal = (price ?? product.buyingPrice) * 1;

  void _recalculate() {
    subtotal = price * quantity;
  }
}
