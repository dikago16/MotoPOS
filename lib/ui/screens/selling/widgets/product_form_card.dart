import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/app_localizations.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/sale_item_model.dart';
import '../../../../providers/selling_provider.dart';
import '../../scanner/scanner_screen.dart';

class ProductFormCard extends StatefulWidget {
  final List<Product> products;

  const ProductFormCard({super.key, required this.products});

  @override
  State<ProductFormCard> createState() => _ProductFormCardState();
}

class _ProductFormCardState extends State<ProductFormCard> {
  TextEditingController? _autoCompleteController;

  @override
  void dispose() {
    super.dispose();
  }

  InputDecoration _inputDeco(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 10, color: AppColors.txtMid),
      floatingLabelStyle: const TextStyle(
        fontSize: 9,
        color: AppColors.accent,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      filled: true,
      fillColor: AppColors.bgCard,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        return widget.products.where((Product product) {
                          final matchQuery =
                              product.itemName.toLowerCase().contains(query) ||
                              product.itemCode.toLowerCase().contains(query);
                          final hasStock =
                              !product.isCountStock || product.stockQty > 0;
                          return matchQuery && hasStock;
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
                                AppLocalizations.get('code_name_search'),
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
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1, color: AppColors.border),
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
                                                    color: AppColors.txtHigh,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      option.category,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: AppColors.txtMid,
                                                      ),
                                                    ),
                                                    const Text(
                                                      ' • ',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: AppColors.txtLow,
                                                      ),
                                                    ),
                                                    Text(
                                                      option.isCountStock
                                                          ? 'Stok: ${option.stockQty}'
                                                          : 'Non Stok',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color:
                                                            option.isCountStock
                                                            ? AppColors.txtMid
                                                            : AppColors.txtLow,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            'Rp ${NumberFormat('#,###', 'id_ID').format(option.sellingPrice)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.accent,
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
                onTap: () async {
                  final String? barcode = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScannerScreen(),
                    ),
                  );
                  if (barcode != null && barcode.isNotEmpty) {
                    if (_autoCompleteController != null) {
                      _autoCompleteController!.text = barcode;
                    }
                  }
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 38,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.accent,
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
}
