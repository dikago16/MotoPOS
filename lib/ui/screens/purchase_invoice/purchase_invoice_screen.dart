import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/database_service.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/supplier_model.dart';
import '../../../data/models/purchase_invoice_model.dart';
import '../../../data/models/purchase_invoice_item_model.dart';
import '../../../core/services/app_localizations.dart';

import 'purchase_invoice_constants.dart';
import 'purchase_invoice_info_view.dart';
import 'purchase_invoice_add_items_view.dart';

class PurchaseInvoiceScreen extends StatefulWidget {
  const PurchaseInvoiceScreen({super.key});

  @override
  State<PurchaseInvoiceScreen> createState() => _PurchaseInvoiceScreenState();
}

class _PurchaseInvoiceScreenState extends State<PurchaseInvoiceScreen> {
  int _currentPage = 0; // 0 = Invoice Info, 1 = Add Items

  TextEditingController? _autoCompleteController;
  final _notesCtrl = TextEditingController();

  List<Product> _products = [];
  List<SupplierModel> _suppliers = [];
  final List<PurchaseItemData> _invoiceItems = [];

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
    final products = await context.read<DatabaseService>().getProducts();
    final suppliers = await context.read<DatabaseService>().getSuppliers();
    final code = await context.read<DatabaseService>().getNextPurchaseInvoiceCode();
    setState(() {
      _products = products;
      _suppliers = suppliers;
      _invoiceCode = code;
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _totalAmount =>
      _invoiceItems.fold(0, (sum, item) => sum + item.subtotal);

  void _addProduct(Product product) {
    setState(() {
      final existingIdx = _invoiceItems.indexWhere(
        (e) => e.product.id == product.id,
      );
      if (existingIdx >= 0) {
        _invoiceItems[existingIdx].quantity++;
        _invoiceItems[existingIdx].recalculate();
      } else {
        _invoiceItems.add(PurchaseItemData(product: product));
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
      _invoiceItems[index].recalculate();
    });
  }

  void _updatePrice(int index, double price) {
    setState(() {
      _invoiceItems[index].price = price;
      _invoiceItems[index].recalculate();
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
              primary: kNavy,
              onPrimary: Colors.white,
              surface: kBgCard,
              onSurface: kTxtHigh,
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
      _currentPage = 0;
    });
    _loadData();
  }

  void _goToAddItems() {
    if (_selectedSupplier == null) {
      _showSnackBar(AppLocalizations.get('please_select_supplier'), isError: true);
      return;
    }
    setState(() => _currentPage = 1);
  }

  void _goBackToInfo() {
    setState(() => _currentPage = 0);
  }

  Future<void> _saveInvoice() async {
    if (_selectedSupplier == null) {
      _showSnackBar(AppLocalizations.get('please_select_supplier'), isError: true);
      return;
    }
    if (_invoiceItems.isEmpty) {
      _showSnackBar(AppLocalizations.get('please_add_at_least_one_item'), isError: true);
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

      await context.read<DatabaseService>().savePurchaseInvoice(invoice, items);

      if (!mounted) return;
      _showSnackBar('${AppLocalizations.get('invoice')} $_invoiceCode ${AppLocalizations.get('saved_successfully')}');
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('${AppLocalizations.get('failed_to_save')}: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? kRed : kGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  void _showQtyDialog(int idx, PurchaseItemData item) {
    final ctrl = TextEditingController(text: '${item.quantity}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kBgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          AppLocalizations.get('edit_quantity'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        content: TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(fontSize: 14),
          decoration: inputDeco(AppLocalizations.get('quantity')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.get('cancel'), style: const TextStyle(color: kTxtLow)),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(ctrl.text) ?? 1;
              _updateQty(idx, qty);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(AppLocalizations.get('ok')),
          ),
        ],
      ),
    );
  }

  void _showPriceDialog(int idx, PurchaseItemData item) {
    final ctrl = TextEditingController(text: item.price.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kBgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          AppLocalizations.get('edit_buying_price'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        content: TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(fontSize: 14),
          decoration: inputDeco(AppLocalizations.get('price')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.get('cancel'), style: const TextStyle(color: kTxtLow)),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(ctrl.text) ?? 0;
              _updatePrice(idx, price);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(AppLocalizations.get('ok')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _currentPage == 0
            ? PurchaseInvoiceInfoView(
                invoiceCode: _invoiceCode,
                invoiceDate: _invoiceDate,
                selectedSupplier: _selectedSupplier,
                suppliers: _suppliers,
                notesCtrl: _notesCtrl,
                onPickDate: _pickDate,
                onSupplierChanged: (val) {
                  setState(() {
                    _selectedSupplier = _suppliers.firstWhere((s) => s.id == val);
                  });
                },
                onClearForm: _clearForm,
                onNext: _goToAddItems,
              )
            : PurchaseInvoiceAddItemsView(
                invoiceCode: _invoiceCode,
                invoiceDate: _invoiceDate,
                selectedSupplier: _selectedSupplier,
                products: _products,
                invoiceItems: _invoiceItems,
                totalAmount: _totalAmount,
                isSaving: _isSaving,
                onGoBack: _goBackToInfo,
                onClearForm: _clearForm,
                onSaveInvoice: _saveInvoice,
                onAddProduct: _addProduct,
                onRemoveItem: _removeItem,
                onShowQtyDialog: _showQtyDialog,
                onShowPriceDialog: _showPriceDialog,
                onAutoCompleteControllerCreated: (controller) {
                  _autoCompleteController = controller;
                },
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kNavy,
      elevation: 0,
      toolbarHeight: 54,
      iconTheme: const IconThemeData(color: Colors.white, size: 20),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (_currentPage == 1) {
            _goBackToInfo();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _currentPage == 0 ? 'Purchase Invoice' : 'Add Items',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            _currentPage == 0
                ? 'Invoice Information'
                : 'Search & Add Products',
            style: const TextStyle(
              color: Color(0xFF90AAC8),
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
