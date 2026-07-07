import 'package:flutter/material.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/db_helper.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────
const _kNavy = Color(0xFF0D1B2A);
const _kAccent = Color(0xFF2563EB);
const _kAccentSoft = Color(0xFFEFF6FF);
const _kBgPage = Color(0xFFF1F5F9);
const _kBgCard = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE2E8F0);
const _kBorderMid = Color(0xFFCBD5E1);
const _kTxtHigh = Color(0xFF0F172A);
const _kTxtMid = Color(0xFF475569);
const _kTxtLow = Color(0xFF94A3B8);
// ──────────────────────────────────────────────────────────────────────────────

class ItemDetailScreen extends StatefulWidget {
  final Product? product;

  const ItemDetailScreen({super.key, this.product});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _autoItemCode = true;
  bool _isSaving = false;
  bool _countStock = false;
  String _discountType = 'Percent';
  String _generatedCode = '';
  String _selectedCategory = 'uncategorized';
  List<CategoryModel> _categories = [];

  final _itemCodeCtrl = TextEditingController();
  final _itemNameCtrl = TextEditingController();
  final _buyingPriceCtrl = TextEditingController();
  final _packetBuyPriceCtrl = TextEditingController();
  final _packetBuyQtyCtrl = TextEditingController();
  final _sellingPriceCtrl = TextEditingController();
  final _packetSellPriceCtrl = TextEditingController();
  final _packetSellQtyCtrl = TextEditingController();
  final _discountValueCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _stockQtyCtrl = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    if (widget.product != null) {
      _autoItemCode = false;
      _itemCodeCtrl.text = widget.product!.itemCode;
      _itemNameCtrl.text = widget.product!.itemName;
      _selectedCategory = widget.product!.category;
      _buyingPriceCtrl.text = widget.product!.buyingPrice.toStringAsFixed(0);
      _packetBuyPriceCtrl.text = widget.product!.packetBuyPrice.toStringAsFixed(
        0,
      );
      _packetBuyQtyCtrl.text = widget.product!.packetBuyQty.toString();
      _sellingPriceCtrl.text = widget.product!.sellingPrice.toStringAsFixed(0);
      _packetSellPriceCtrl.text = widget.product!.packetSellPrice
          .toStringAsFixed(0);
      _packetSellQtyCtrl.text = widget.product!.packetSellQty.toString();
      _discountType = widget.product!.discountType;
      _discountValueCtrl.text = widget.product!.discountValue.toStringAsFixed(
        0,
      );
      _unitCtrl.text = widget.product!.unit;
      _countStock = widget.product!.isCountStock;
      _stockQtyCtrl.text = widget.product!.stockQty.toString();
    } else {
      _fetchNextCode();
    }
  }

  Future<void> _fetchCategories() async {
    final categories = await DBHelper.getCategories();
    setState(() {
      _categories = categories;
      bool exists = _categories.any((c) => c.categoryName == _selectedCategory);
      if (!exists && _selectedCategory != 'uncategorized') {
        _selectedCategory = 'uncategorized';
      }
    });
  }

  Future<void> _fetchNextCode() async {
    String nextCode = await DBHelper.getNextItemCode();
    setState(() {
      _generatedCode = nextCode;
      if (_autoItemCode) {
        _itemCodeCtrl.text = _generatedCode;
      }
    });
  }

  @override
  void dispose() {
    _itemCodeCtrl.dispose();
    _itemNameCtrl.dispose();
    _buyingPriceCtrl.dispose();
    _packetBuyPriceCtrl.dispose();
    _packetBuyQtyCtrl.dispose();
    _sellingPriceCtrl.dispose();
    _packetSellPriceCtrl.dispose();
    _packetSellQtyCtrl.dispose();
    _discountValueCtrl.dispose();
    _unitCtrl.dispose();
    _stockQtyCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco(
    String label, {
    Widget? suffixIcon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 12, color: _kTxtLow),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      suffixIcon: suffixIcon,
    );
  }

  Widget _sectionLabel(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
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
            Icon(icon, size: 14, color: _kAccent),
            const SizedBox(width: 5),
          ],
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
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
    final isEdit = widget.product != null;
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
              isEdit ? 'Edit Item' : 'New Item',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              isEdit ? 'Update Details' : 'Add New Item',
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _kBgCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionLabel(
                            'Basic Information',
                            icon: Icons.info_outline,
                          ),
                          if (widget.product == null)
                            Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _autoItemCode,
                                    activeColor: _kAccent,
                                    onChanged: (val) {
                                      setState(() {
                                        _autoItemCode = val ?? true;
                                        if (_autoItemCode) {
                                          _itemCodeCtrl.text = _generatedCode;
                                        } else {
                                          _itemCodeCtrl.text = '';
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Auto Code',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _kTxtMid,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      // Item Code with Barcode Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _itemCodeCtrl,
                              readOnly: _autoItemCode,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _kTxtMid,
                              ),
                              decoration: _inputDeco('Item Code').copyWith(
                                fillColor: _autoItemCode ? _kBgPage : _kBgCard,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              height: 38,
                              width: 40,
                              decoration: BoxDecoration(
                                color: _kAccentSoft,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _kAccent.withValues(alpha: 0.2),
                                ),
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner,
                                color: _kAccent,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Item Name
                      TextFormField(
                        controller: _itemNameCtrl,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDeco('Item Name'),
                      ),
                      const SizedBox(height: 8),

                      // Category
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: _inputDeco('Category'),
                        style: const TextStyle(fontSize: 13, color: _kTxtHigh),
                        dropdownColor: _kBgCard,
                        items: [
                          const DropdownMenuItem(
                            value: 'uncategorized',
                            child: Text('Uncategorized'),
                          ),
                          ..._categories.map(
                            (c) => DropdownMenuItem(
                              value: c.categoryName,
                              child: Text(
                                c.categoryName.isEmpty
                                    ? 'Unknown Category'
                                    : c.categoryName,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCategory = val);
                          }
                        },
                      ),
                      const SizedBox(height: 8),

                      // Buying Price
                      TextFormField(
                        controller: _buyingPriceCtrl,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDeco('Buying Price'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),

                      // Packet Buy Price & Packet Quantity
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _packetBuyPriceCtrl,
                              style: const TextStyle(fontSize: 13),
                              decoration: _inputDeco('Packet Buy Price'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Per',
                              style: TextStyle(fontSize: 12, color: _kTxtMid),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _packetBuyQtyCtrl,
                              style: const TextStyle(fontSize: 13),
                              decoration: _inputDeco('Packet Quantity'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Selling Price
                      TextFormField(
                        controller: _sellingPriceCtrl,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDeco('Selling Price'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),

                      // Packet Sell Price & Packet Quantity
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _packetSellPriceCtrl,
                              style: const TextStyle(fontSize: 13),
                              decoration: _inputDeco('Packet Sell Price'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Per',
                              style: TextStyle(fontSize: 12, color: _kTxtMid),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _packetSellQtyCtrl,
                              style: const TextStyle(fontSize: 13),
                              decoration: _inputDeco('Paket Quantity'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Discount
                      Row(
                        children: [
                          const Text(
                            'Discount',
                            style: TextStyle(fontSize: 12, color: _kTxtMid),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: _kBorder),
                              borderRadius: BorderRadius.circular(6),
                              color: _kBgCard,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _discountType,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: _kTxtMid,
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _kTxtHigh,
                                ),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _discountType = newValue;
                                    });
                                  }
                                },
                                items: <String>['Percent', 'Amount']
                                    .map<DropdownMenuItem<String>>((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    })
                                    .toList(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _discountValueCtrl,
                              style: const TextStyle(fontSize: 13),
                              decoration: _inputDeco(''),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Unit
                      TextFormField(
                        controller: _unitCtrl,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDeco('Unit', hintText: 'Example: Kg'),
                      ),
                      const SizedBox(height: 8),

                      // Count stock Checkbox
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _countStock,
                              activeColor: _kAccent,
                              onChanged: (val) {
                                setState(() {
                                  _countStock = val ?? true;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Count stock when transaction',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _kTxtHigh,
                            ),
                          ),
                        ],
                      ),

                      // Conditionally show Stock Quantity
                      if (_countStock) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _stockQtyCtrl,
                          style: const TextStyle(fontSize: 13),
                          decoration: _inputDeco('Stock Quantity'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: _kBgCard,
        border: Border(top: BorderSide(color: _kBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  _itemCodeCtrl.clear();
                  _itemNameCtrl.clear();
                  _buyingPriceCtrl.clear();
                  _packetBuyPriceCtrl.clear();
                  _packetBuyQtyCtrl.clear();
                  _sellingPriceCtrl.clear();
                  _packetSellPriceCtrl.clear();
                  _packetSellQtyCtrl.clear();
                  _discountValueCtrl.clear();
                  _unitCtrl.clear();
                  _stockQtyCtrl.text = '0';
                  setState(() {
                    _autoItemCode = true;
                    _countStock = false;
                    _discountType = 'Percent';
                    _itemCodeCtrl.text = _generatedCode;
                    _selectedCategory = 'uncategorized';
                  });
                },
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
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (_itemNameCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Item name cannot be empty!'),
                              backgroundColor: Colors.red.shade600,
                            ),
                          );
                          return;
                        }

                        setState(() => _isSaving = true);

                        try {
                          final product = Product(
                            id: widget.product?.id,
                            itemCode: _itemCodeCtrl.text,
                            itemName: _itemNameCtrl.text,
                            category: _selectedCategory,
                            buyingPrice: double.tryParse(_buyingPriceCtrl.text) ?? 0,
                            packetBuyPrice:
                                double.tryParse(_packetBuyPriceCtrl.text) ?? 0,
                            packetBuyQty: int.tryParse(_packetBuyQtyCtrl.text) ?? 0,
                            sellingPrice: double.tryParse(_sellingPriceCtrl.text) ?? 0,
                            packetSellPrice:
                                double.tryParse(_packetSellPriceCtrl.text) ?? 0,
                            packetSellQty: int.tryParse(_packetSellQtyCtrl.text) ?? 0,
                            discountType: _discountType,
                            discountValue:
                                double.tryParse(_discountValueCtrl.text) ?? 0,
                            unit: _unitCtrl.text,
                            isCountStock: _countStock,
                            stockQty: int.tryParse(_stockQtyCtrl.text) ?? 0,
                          );
                          if (widget.product != null) {
                            await DBHelper.updateProduct(product);
                          } else {
                            await DBHelper.insertProduct(product);
                          }
                          
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item saved successfully!'),
                              backgroundColor: Color(0xFF16A34A),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.pop(context, true);
                        } catch (e) {
                          if (!mounted) return;
                          setState(() => _isSaving = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save item: $e'),
                              backgroundColor: const Color(0xFFDC2626),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                icon: _isSaving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
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
