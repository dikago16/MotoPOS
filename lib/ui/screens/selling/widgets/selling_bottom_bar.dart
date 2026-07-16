import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/app_localizations.dart';
import '../../../../data/database_service.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/transaction_item_model.dart';
import '../../../../providers/printer_provider.dart';
import '../../../../providers/selling_provider.dart';
import '../payment_dialog.dart';
import 'paired_devices_dialog.dart';

class SellingBottomBar extends StatefulWidget {
  const SellingBottomBar({super.key});

  @override
  State<SellingBottomBar> createState() => _SellingBottomBarState();
}

class _SellingBottomBarState extends State<SellingBottomBar> {
  Future<void> _handlePrinterTap() async {
    final printerProvider = context.read<PrinterProvider>();

    if (printerProvider.isConnected) {
      _showPrinterInfoDialog(printerProvider);
      return;
    }

    final isBluetoothOn = await printerProvider.isBluetoothEnabled();

    if (!isBluetoothOn) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.bgCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.bluetooth_disabled,
                  color: AppColors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.get('bluetooth_off'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.txtHigh,
                  ),
                ),
              ],
            ),
            content: Text(
              AppLocalizations.get('bluetooth_off_message'),
              style: const TextStyle(fontSize: 13, color: AppColors.txtMid),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
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
      return;
    }

    if (mounted) {
      _showPairedDevicesDialog(printerProvider);
    }
  }

  void _showPairedDevicesDialog(PrinterProvider printerProvider) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => PairedDevicesDialog(printerProvider: printerProvider),
    );
  }

  void _showPrinterInfoDialog(PrinterProvider printerProvider) {
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
              AppLocalizations.get('printer_connected'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.txtHigh,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.bluetooth_connected,
                    size: 18,
                    color: Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      printerProvider.connectedDeviceName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.txtHigh,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.get('close'),
              style: const TextStyle(
                color: AppColors.txtLow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              printerProvider.disconnect();
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.bluetooth_disabled, size: 16),
            label: Text(
              AppLocalizations.get('disconnect'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SellingProvider>();
    final printerProvider = context.watch<PrinterProvider>();
    final bool isPrinterConnected = printerProvider.isConnected;

    final Color printerBgColor = isPrinterConnected
        ? const Color(0xFFF0FDF4)
        : const Color(0xFFFEF2F2);
    final Color printerBorderColor = isPrinterConnected
        ? const Color(0xFF16A34A).withValues(alpha: 0.3)
        : AppColors.red.withValues(alpha: 0.3);
    final Color printerIconColor = isPrinterConnected
        ? const Color(0xFF16A34A)
        : AppColors.red;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
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
                onTap: _handlePrinterTap,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: printerBgColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: printerBorderColor),
                  ),
                  child: Icon(Icons.print, color: printerIconColor, size: 20),
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
                      backgroundColor: AppColors.bgPage,
                      foregroundColor: AppColors.txtMid,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: AppColors.borderMid),
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
                                    initialVehicleNo:
                                        provider.selectedCustomer?.vehicleNo,
                                    isPrinterConnected:
                                        printerProvider.isConnected,
                                    initialPrintReceipt:
                                        printerProvider.isPrintReceiptEnabled,
                                  ),
                                );

                            if (result != null) {
                              final double cashAmount = result['cashAmount'];
                              final String vehicleNo = result['vehicleNo'];
                              final bool printReceipt =
                                  result['printReceipt'] ?? false;

                              printerProvider.setPrintReceiptEnabled(
                                printReceipt,
                              );

                              final trx = TransactionModel(
                                transactionDate: DateTime.now()
                                    .toIso8601String(),
                                totalAmount: provider.totalAmount,
                                cashAmount: cashAmount,
                                changeAmount: cashAmount - provider.totalAmount,
                                vehicleNo: vehicleNo.isEmpty ? null : vehicleNo,
                                customerId: provider.selectedCustomer?.id,
                                customerName: provider.selectedCustomer?.name,
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

                              final transactionId =
                                  await context.read<DatabaseService>().saveTransaction(trx, items);

                              if (printReceipt && printerProvider.isConnected) {
                                final printSuccess = await printerProvider
                                    .printReceipt(
                                      transaction: trx,
                                      items: items,
                                      transactionId: transactionId,
                                    );
                                if (mounted) {
                                  if (printSuccess) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.get(
                                            'transaction_saved_printed',
                                          ),
                                        ),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.get(
                                            'transaction_saved_print_failed',
                                          ),
                                        ),
                                        backgroundColor: Colors.orange,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.get(
                                          'transaction_saved',
                                        ),
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }

                              provider.clearTransaction();
                            }
                          },
                    icon: const Icon(Icons.check, size: 16),
                    label: Text(
                      AppLocalizations.get('process'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
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
