import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/supplier_model.dart';
import '../../../core/services/app_localizations.dart';
import 'purchase_invoice_constants.dart';
import '../../widgets/app_loading.dart';

class PurchaseInvoiceAddItemsView extends StatelessWidget {
  final String invoiceCode;
  final DateTime invoiceDate;
  final SupplierModel? selectedSupplier;
  final List<Product> products;
  final List<PurchaseItemData> invoiceItems;
  final double totalAmount;
  final bool isSaving;
  final VoidCallback onGoBack;
  final VoidCallback onClearForm;
  final VoidCallback onSaveInvoice;
  final ValueChanged<Product> onAddProduct;
  final ValueChanged<int> onRemoveItem;
  final void Function(int idx, PurchaseItemData item) onShowQtyDialog;
  final void Function(int idx, PurchaseItemData item) onShowPriceDialog;
  final ValueChanged<TextEditingController> onAutoCompleteControllerCreated;

  const PurchaseInvoiceAddItemsView({
    super.key,
    required this.invoiceCode,
    required this.invoiceDate,
    required this.selectedSupplier,
    required this.products,
    required this.invoiceItems,
    required this.totalAmount,
    required this.isSaving,
    required this.onGoBack,
    required this.onClearForm,
    required this.onSaveInvoice,
    required this.onAddProduct,
    required this.onRemoveItem,
    required this.onShowQtyDialog,
    required this.onShowPriceDialog,
    required this.onAutoCompleteControllerCreated,
  });

  String _formatRupiah(double v) =>
      'Rp ${NumberFormat('#,###', 'id_ID').format(v)}';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInvoiceInfoBanner(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildItemSearch(),
                const SizedBox(height: 8),
                _buildItemsTable(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildInvoiceInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: kAccentSoft,
        border: Border(
          bottom: BorderSide(color: kBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, size: 14, color: kAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Text(
                  invoiceCode,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: kAccent,
                  ),
                ),
                const Text(
                  '  •  ',
                  style: TextStyle(fontSize: 10, color: kTxtLow),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(invoiceDate),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: kTxtMid,
                  ),
                ),
                const Text(
                  '  •  ',
                  style: TextStyle(fontSize: 10, color: kTxtLow),
                ),
                Flexible(
                  child: Text(
                    selectedSupplier?.supplierName ?? '-',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: kTxtMid,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemSearch() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionLabel(AppLocalizations.get('add_items'), icon: Icons.add_shopping_cart),
          LayoutBuilder(
            builder: (context, constraints) {
              return Autocomplete<Product>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Product>.empty();
                  }
                  final query = textEditingValue.text.toLowerCase();
                  return products.where((Product product) {
                    return product.itemName.toLowerCase().contains(query) ||
                        product.itemCode.toLowerCase().contains(query);
                  });
                },
                displayStringForOption: (Product option) =>
                    option.itemName.isEmpty ? AppLocalizations.get('unknown_item') : option.itemName,
                onSelected: onAddProduct,
                fieldViewBuilder:
                    (context, controller, focusNode, onEditingComplete) {
                  onAutoCompleteControllerCreated(controller);
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    style: const TextStyle(fontSize: 13),
                    decoration: inputDeco(
                      AppLocalizations.get('search_item_hint'),
                      suffixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: kTxtLow,
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
                          color: kBgCard,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: kBorder),
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1, color: kBorder),
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
                                                ? AppLocalizations.get('unknown_item')
                                                : option.itemName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: kTxtHigh,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                option.itemCode,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: kTxtMid,
                                                ),
                                              ),
                                              const Text(
                                                ' • ',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: kTxtLow,
                                                ),
                                              ),
                                              Text(
                                                option.isCountStock
                                                    ? '${AppLocalizations.get('stock')}: ${option.stockQty}'
                                                    : AppLocalizations.get('non_stock'),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: option.isCountStock
                                                      ? kTxtMid
                                                      : kTxtLow,
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
                                          : AppLocalizations.get('not_set'),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: kAccent,
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
        color: kBgCard,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: sectionLabel(AppLocalizations.get('purchase_items'), icon: Icons.list_alt),
          ),
          Container(
            color: kTableHead,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              children: [
                _colHeader(AppLocalizations.get('item'), flex: 3),
                _colHeaderCenter(AppLocalizations.get('qty'), flex: 2),
                _colHeaderRight(AppLocalizations.get('price'), flex: 3),
                _colHeaderRight(AppLocalizations.get('subtotal'), flex: 3),
                const SizedBox(width: 26),
              ],
            ),
          ),
          const Divider(height: 1, color: kBorder),

          if (invoiceItems.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              width: double.infinity,
              child: Column(
                children: [
                  const Icon(Icons.add_shopping_cart, size: 30, color: kTxtLow),
                  const SizedBox(height: 7),
                  Text(
                    AppLocalizations.get('no_items_added'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: kTxtLow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ...invoiceItems.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isAlt = idx % 2 == 1;
              return Column(
                children: [
                  Container(
                    color: isAlt ? kRowAlt : kBgCard,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.itemName.isEmpty
                                    ? AppLocalizations.get('unknown_item')
                                    : item.product.itemName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: kTxtHigh,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.product.itemCode,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: kTxtLow,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: InkWell(
                              onTap: () => onShowQtyDialog(idx, item),
                              borderRadius: BorderRadius.circular(3),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: kAccentSoft,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: kAccent.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: kAccent,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.visible,
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
                              onTap: () => onShowPriceDialog(idx, item),
                              child: Text(
                                _formatRupiah(item.price),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: kTxtMid,
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
                                color: kTxtHigh,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 26,
                          child: InkWell(
                            onTap: () => onRemoveItem(idx),
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.remove_circle_outline,
                                size: 16,
                                color: kRed,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: kBorder),
                ],
              );
            }),

          if (invoiceItems.isNotEmpty)
            Container(
              color: kTableHead,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: kBgCard,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: kBorderMid),
                    ),
                    child: Text(
                      '${invoiceItems.length} ${AppLocalizations.get('items')}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: kTxtMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${AppLocalizations.get('total').toUpperCase()} :',
                    style: const TextStyle(
                      fontSize: 9,
                      color: kTxtMid,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatRupiah(totalAmount),
                    style: const TextStyle(
                      fontSize: 14,
                      color: kAccent,
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

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: kBgCard,
        border: Border(top: BorderSide(color: kBorder, width: 1)),
        boxShadow: [
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
                onPressed: onClearForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBgPage,
                  foregroundColor: kTxtMid,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: kBorderMid),
                  ),
                ),
                child: Text(
                  AppLocalizations.get('abort').toUpperCase(),
                  style: const TextStyle(
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
                onPressed: isSaving ? null : onSaveInvoice,
                icon: isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: const AppLoading(),
                      )
                    : const Icon(Icons.check, size: 16),
                label: Text(
                  isSaving ? 'SAVING...' : 'SAVE',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNavy,
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

  Widget _colHeader(String label, {required int flex}) => Expanded(
        flex: flex,
        child: Text(label, style: kColHeader),
      );

  Widget _colHeaderCenter(String label, {required int flex}) => Expanded(
        flex: flex,
        child: Center(child: Text(label, style: kColHeader)),
      );

  Widget _colHeaderRight(String label, {required int flex}) => Expanded(
        flex: flex,
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(label, style: kColHeader),
        ),
      );
}
