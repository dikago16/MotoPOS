import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/selling_provider.dart';
import '../manage_item/manage_item_screen.dart';
import '../manage_category/manage_category_screen.dart';
import '../../../data/db_helper.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/sale_item_model.dart';
import 'payment_dialog.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_item_model.dart';

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

const _kColHeader = TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.w700,
  color: Color(0xFF94A3B8),
  letterSpacing: 0.9,
);
// ──────────────────────────────────────────────────────────────────────────────

class SellingScreen extends StatefulWidget {
  const SellingScreen({super.key});

  @override
  State<SellingScreen> createState() => _SellingScreenState();
}

class _SellingScreenState extends State<SellingScreen> {
  TextEditingController? _autoCompleteController;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final products = await DBHelper.getProducts();
    setState(() {
      _products = products;
    });
  }

  @override
  void dispose() {
    _autoCompleteController?.dispose();
    super.dispose();
  }

  String _formatNumber(double v) => NumberFormat('#,###', 'id_ID').format(v);

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
                    _buildFormCard(),
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Selling',
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
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
          color: _kBgCard,
          onSelected: (value) async {
            if (value == 'manage_item') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageItemScreen(),
                ),
              );
              _fetchProducts();
            } else if (value == 'manage_category') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageCategoryScreen(),
                ),
              );
              _fetchProducts();
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem(
                value: 'manage_item',
                child: Text(
                  'Manage Item',
                  style: TextStyle(fontSize: 13, color: _kTxtHigh),
                ),
              ),
              const PopupMenuItem(
                value: 'manage_category',
                child: Text(
                  'Manage Category',
                  style: TextStyle(fontSize: 13, color: _kTxtHigh),
                ),
              ),
            ];
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFormCard() {
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
          _sectionLabel('Input Item', icon: Icons.qr_code_scanner),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Autocomplete<Product>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<Product>.empty();
                        }
                        final query = textEditingValue.text.toLowerCase();
                        return _products.where((Product product) {
                          return product.itemName.toLowerCase().contains(
                                query,
                              ) ||
                              product.itemCode.toLowerCase().contains(query);
                        });
                      },
                      displayStringForOption: (Product option) =>
                          option.itemName.isEmpty
                          ? 'Unknown Item'
                          : option.itemName,
                      onSelected: (Product selection) {
                        final provider = context.read<SellingProvider>();
                        provider.addItem(
                          SaleItemModel(
                            id: selection.id.toString(),
                            name: selection.itemName.isEmpty
                                ? 'Unknown Item'
                                : selection.itemName,
                            category: selection.category,
                            price: selection.sellingPrice,
                            quantity: 1,
                          ),
                        );
                        // Clear the input after selection
                        Future.delayed(Duration.zero, () {
                          _autoCompleteController?.clear();
                        });
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onEditingComplete) {
                            _autoCompleteController = controller;
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              style: const TextStyle(fontSize: 13),
                              decoration: _inputDeco(
                                'Code / Name (Type to search)',
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
                                  final Product option = options.elementAt(
                                    index,
                                  );
                                  return InkWell(
                                    onTap: () {
                                      onSelected(option);
                                    },
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
                                                Text(
                                                  option.category,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: _kTxtMid,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            'Rp ${NumberFormat('#,###', 'id_ID').format(option.sellingPrice)}',
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
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  // Scanner action
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 38,
                  width: 44,
                  decoration: BoxDecoration(
                    color: _kAccentSoft,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _kAccent.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: _kAccent,
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

  Widget _buildItemsTable() {
    final provider = context.watch<SellingProvider>();
    final items = provider.items;

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
              'Sales Items',
              icon: Icons.shopping_basket_outlined,
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

          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              width: double.infinity,
              child: Column(
                children: const [
                  Icon(Icons.inbox_outlined, size: 30, color: _kTxtLow),
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
            ...items.asMap().entries.map((entry) {
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
                                item.name.isEmpty ? 'Unknown Item' : item.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _kTxtHigh,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.category,
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
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _formatNumber(item.price),
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
                              _formatNumber(item.total),
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
                            onTap: () {
                              // Handle remove item (Need to update provider)
                            },
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

          if (items.isNotEmpty)
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
                      '${items.length} Items${items.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: _kTxtMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'SUBTOTAL',
                    style: TextStyle(
                      fontSize: 9,
                      color: _kTxtMid,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatNumber(provider.totalAmount),
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
    final provider = context.watch<SellingProvider>();

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: _kAccentSoft,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _kAccent.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.print, color: _kAccent, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.clearTransaction();
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
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: provider.items.isEmpty
                        ? null
                        : () async {
                            final result =
                                await showDialog<Map<String, dynamic>>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => PaymentDialog(
                                    totalAmount: provider.totalAmount,
                                  ),
                                );

                            if (result != null) {
                              final double cashAmount = result['cashAmount'];
                              final String vehicleNo = result['vehicleNo'];

                              // User confirmed payment
                              final trx = TransactionModel(
                                transactionDate: DateTime.now()
                                    .toIso8601String(),
                                totalAmount: provider.totalAmount,
                                cashAmount: cashAmount,
                                changeAmount: cashAmount - provider.totalAmount,
                                vehicleNo: vehicleNo.isEmpty ? null : vehicleNo,
                              );

                              final items = provider.items
                                  .map(
                                    (item) => TransactionItemModel(
                                      transactionId: 0,
                                      itemName: item.name,
                                      category: item.category,
                                      price: item.price,
                                      quantity: item.quantity,
                                      subtotal: item.total,
                                    ),
                                  )
                                  .toList();

                              await DBHelper.saveTransaction(trx, items);
                              provider.clearTransaction();

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Transaksi Berhasil!'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text(
                      'PROCESS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
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
        ],
      ),
    );
  }
}
