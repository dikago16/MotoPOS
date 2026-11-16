import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/app_localizations.dart';
import '../../../../core/utils/currency_util.dart';
import '../../../../data/models/sale_item_model.dart';
import '../../../../providers/selling_provider.dart';
import '../../../widgets/security_pin_dialog.dart';

const _kColHeader = TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.w700,
  color: Color(0xFF94A3B8),
  letterSpacing: 0.9,
);

class CartItemsTable extends StatelessWidget {
  const CartItemsTable({super.key});

  InputDecoration _inputDeco(String label, {String? prefix, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 10, color: AppColors.txtMid),
      floatingLabelStyle: const TextStyle(
        fontSize: 9,
        color: AppColors.accent,
        fontWeight: FontWeight.w600,
      ),
      prefixText: prefix,
      prefixStyle: const TextStyle(
        color: AppColors.txtHigh,
        fontSize: 13,
        fontWeight: FontWeight.w700,
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

  void _showQtyDialog(SaleItemModel item, BuildContext context) {
    final ctrl = TextEditingController(text: '${item.quantity}');
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(
            AppLocalizations.get('edit_quantity'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.txtHigh,
                ),
              ),
              if (item.isCountStock) ...[
                const SizedBox(height: 2),
                Text(
                  '${AppLocalizations.get('stock')}: ${item.stockQty}',
                  style: const TextStyle(fontSize: 10, color: AppColors.txtMid),
                ),
              ],
              const SizedBox(height: 10),
              TextFormField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(fontSize: 14),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDeco(AppLocalizations.get('quantity')),
                onChanged: (_) {
                  if (error != null) {
                    setDialogState(() => error = null);
                  }
                },
              ),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(
                  error!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                AppLocalizations.get('cancel'),
                style: const TextStyle(color: AppColors.txtLow),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final qty = int.tryParse(ctrl.text) ?? 0;
                if (qty <= 0) {
                  setDialogState(() {
                    error = AppLocalizations.get('qty_min_one');
                  });
                  return;
                }
                if (item.isCountStock && qty > item.stockQty) {
                  setDialogState(() {
                    error =
                        '${AppLocalizations.get('stock_exceeded')} (${item.stockQty})';
                  });
                  return;
                }
                context.read<SellingProvider>().updateQuantity(item, qty);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
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
      ),
    );
  }

  void _showPriceInfoOrOverrideDialog(BuildContext context, SaleItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.lock, size: 18, color: AppColors.accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.get('price_locked'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.txtHigh,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.txtHigh,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.get('price_locked_desc'),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.txtMid,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Harga Satuan Resmi:',
                    style: TextStyle(fontSize: 11, color: AppColors.txtMid),
                  ),
                  Text(
                    CurrencyUtil.formatRupiah(item.originalPrice),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.txtHigh,
                    ),
                  ),
                ],
              ),
            ),
            if (item.isPriceOverridden) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Harga Khusus (Disetujui):',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      CurrencyUtil.formatRupiah(item.price),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.get('close'),
              style: const TextStyle(color: AppColors.txtLow),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              _handlePriceOverride(context, item);
            },
            icon: const Icon(Icons.key, size: 14),
            label: Text(AppLocalizations.get('override_price')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
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

  Future<void> _handlePriceOverride(BuildContext context, SaleItemModel item) async {
    final verified = await SecurityPinDialog.verify(
      context,
      reason: '${AppLocalizations.get('override_price_reason')} ${item.name}',
    );

    if (!verified || !context.mounted) return;

    final priceCtrl = TextEditingController(text: item.price.toInt().toString());
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            AppLocalizations.get('override_price_title'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.name} (${AppLocalizations.get('override_price_desc')})',
                style: const TextStyle(fontSize: 12, color: AppColors.txtMid),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDeco('Harga Satuan Baru', prefix: 'Rp '),
                onChanged: (_) {
                  if (error != null) {
                    setDialogState(() => error = null);
                  }
                },
              ),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(error!, style: const TextStyle(fontSize: 11, color: AppColors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                AppLocalizations.get('cancel'),
                style: const TextStyle(color: AppColors.txtLow),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newPrice = double.tryParse(priceCtrl.text) ?? -1;
                if (newPrice < 0) {
                  setDialogState(() {
                    error = 'Harga tidak valid';
                  });
                  return;
                }
                context.read<SellingProvider>().updateItemPrice(item, newPrice);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.get('custom_price_applied')),
                    backgroundColor: AppColors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(AppLocalizations.get('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveItemDialog(BuildContext context, SaleItemModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.get('remove_item'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.txtHigh,
                ),
              ),
            ],
          ),
          content: Text(
            AppLocalizations.get('remove_item_confirm'),
            style: const TextStyle(fontSize: 13, color: AppColors.txtMid),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.get('cancel'),
                style: const TextStyle(
                  color: AppColors.txtLow,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<SellingProvider>().removeItem(item);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                AppLocalizations.get('remove'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SellingProvider>();
    final items = provider.items;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.tableHead,
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
          const Divider(height: 1, color: AppColors.border),

          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              width: double.infinity,
              child: Column(
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 30,
                    color: AppColors.txtLow,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    AppLocalizations.get('no_items_added'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.txtLow,
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
                    color: isAlt ? AppColors.rowAlt : AppColors.bgCard,
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
                                item.name.isEmpty ? 'Unknown Item' : item.name,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.txtHigh,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.category,
                                style: const TextStyle(
                                  fontSize: 7,
                                  color: AppColors.txtLow,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: InkWell(
                              onTap: () {
                                _showQtyDialog(item, context);
                              },
                              borderRadius: BorderRadius.circular(3),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentSoft,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.accent,
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
                          child: InkWell(
                            onTap: () {
                              _showPriceInfoOrOverrideDialog(context, item);
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 2,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.lock_outline,
                                        size: 9,
                                        color: AppColors.txtLow,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        CurrencyUtil.formatNumber(item.price),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: item.isPriceOverridden
                                              ? AppColors.accent
                                              : AppColors.txtMid,
                                          fontWeight: item.isPriceOverridden
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (item.isPriceOverridden)
                                    Container(
                                      margin: const EdgeInsets.only(top: 1),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentSoft,
                                        borderRadius: BorderRadius.circular(2),
                                        border: Border.all(
                                          color: AppColors.accent.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.get('special_price_tag'),
                                        style: const TextStyle(
                                          fontSize: 7,
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              CurrencyUtil.formatNumber(item.total),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.txtHigh,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 26,
                          child: InkWell(
                            onTap: () {
                              _showRemoveItemDialog(context, item);
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.remove_circle_outline,
                                size: 16,
                                color: AppColors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                ],
              );
            }),

          if (items.isNotEmpty)
            Container(
              color: AppColors.tableHead,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: AppColors.borderMid),
                    ),
                    child: Text(
                      '${items.length} Item${items.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.txtMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppLocalizations.get('total'),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.txtMid,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    CurrencyUtil.formatRupiah(provider.totalAmount),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
