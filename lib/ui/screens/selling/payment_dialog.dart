import '../../../core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/services/app_localizations.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────











const _kGreenSoft = Color(0xFFF0FDF4);

// ──────────────────────────────────────────────────────────────────────────────

class PaymentDialog extends StatefulWidget {
  final double totalAmount;
  final String? initialVehicleNo;
  final bool isPrinterConnected;
  final bool initialPrintReceipt;

  const PaymentDialog({
    super.key,
    required this.totalAmount,
    this.initialVehicleNo,
    this.isPrinterConnected = false,
    this.initialPrintReceipt = false,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _vehicleNoController = TextEditingController();
  double _cashAmount = 0.0;
  late bool _printReceipt;

  @override
  void initState() {
    super.initState();
    _cashController.addListener(_onCashChanged);
    if (widget.initialVehicleNo != null) {
      _vehicleNoController.text = widget.initialVehicleNo!;
    }
    // Initialize print receipt based on printer connection and previous preference
    _printReceipt = widget.isPrinterConnected && widget.initialPrintReceipt;
  }

  void _onCashChanged() {
    setState(() {
      _cashAmount =
          double.tryParse(
            _cashController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0.0;
    });
  }

  @override
  void dispose() {
    _cashController.dispose();
    _vehicleNoController.dispose();
    super.dispose();
  }

  String _formatRupiah(double v) =>
      'Rp ${NumberFormat('#,###', 'id_ID').format(v)}';

  String _formatNumber(double v) => NumberFormat('#,###', 'id_ID').format(v);

  List<double> _getQuickNominals() {
    List<double> nominals = [];

    if (widget.totalAmount < 20000) nominals.add(20000);
    if (widget.totalAmount < 50000) nominals.add(50000);
    if (widget.totalAmount < 100000) nominals.add(100000);

    double next50k = ((widget.totalAmount / 50000).floor() + 1) * 50000.0;
    if (!nominals.contains(next50k)) nominals.add(next50k);

    double next100k = ((widget.totalAmount / 100000).floor() + 1) * 100000.0;
    if (!nominals.contains(next100k)) nominals.add(next100k);

    return nominals.take(4).toList();
  }

  void _setCash(double amount) {
    _cashController.text = amount.toInt().toString();
  }

  InputDecoration _inputDeco(String label, {String? prefix, String? hint}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 11, color: AppColors.txtMid),
      floatingLabelStyle: const TextStyle(fontSize: 11, color: AppColors.accent),
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.txtLow),
      prefixText: prefix,
      prefixStyle: const TextStyle(
        color: AppColors.txtHigh,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      filled: true,
      fillColor: AppColors.bgCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    double changeAmount = _cashAmount - widget.totalAmount;
    if (changeAmount < 0) changeAmount = 0;
    final bool isValid = _cashAmount >= widget.totalAmount;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.navy, Color(0xFF1B2D45)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.point_of_sale,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.get('payment'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            AppLocalizations.get('complete_transaction'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF90AAC8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // ── Total Amount Banner ─────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  color: AppColors.bgPage,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.get('amount_due'),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.txtLow,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(widget.totalAmount),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.txtHigh,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form Body ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicle No
                    TextFormField(
                      controller: _vehicleNoController,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      decoration:
                          _inputDeco(
                            AppLocalizations.get('vehicle_no_optional'),
                            hint: 'e.g. B 1234 ABC',
                          ).copyWith(
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 10, right: 6),
                              child: Icon(
                                Icons.two_wheeler,
                                size: 16,
                                color: AppColors.txtLow,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 0,
                            ),
                          ),
                    ),
                    const SizedBox(height: 14),

                    // Cash Amount
                    TextFormField(
                      controller: _cashController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: _inputDeco(AppLocalizations.get('cash_received'), prefix: 'Rp '),
                    ),
                    const SizedBox(height: 10),

                    // Quick Nominals
                    Row(
                      children: [
                        _quickChip(AppLocalizations.get('exact'), widget.totalAmount, isExact: true),
                        const SizedBox(width: 6),
                        ..._getQuickNominals().map(
                          (nom) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _quickChip(_formatNumber(nom), nom),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Change Display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isValid ? _kGreenSoft : AppColors.bgPage,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isValid
                              ? AppColors.green.withValues(alpha: 0.25)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isValid
                                  ? AppColors.green.withValues(alpha: 0.12)
                                  : AppColors.border.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              isValid
                                  ? Icons.check_circle_outline
                                  : Icons.info_outline,
                              size: 16,
                              color: isValid ? AppColors.green : AppColors.txtLow,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isValid ? AppLocalizations.get('change') : AppLocalizations.get('insufficient'),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: isValid ? AppColors.green : AppColors.txtLow,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                isValid
                                    ? _formatRupiah(changeAmount)
                                    : _formatRupiah(
                                        widget.totalAmount - _cashAmount,
                                      ),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isValid ? AppColors.green : AppColors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Print Receipt Checkbox ──────────────────────────────
                    _buildPrintReceiptOption(),
                    const SizedBox(height: 14),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.txtMid,
                                side: const BorderSide(color: AppColors.borderMid),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.get('cancel'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: isValid
                                  ? () {
                                      Navigator.pop(context, {
                                        'cashAmount': _cashAmount,
                                        'vehicleNo': _vehicleNoController.text,
                                        'printReceipt': _printReceipt,
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.check, size: 16),
                              label: Text(
                                AppLocalizations.get('confirm_payment'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.border,
                                disabledForegroundColor: AppColors.txtLow,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the print receipt checkbox option
  Widget _buildPrintReceiptOption() {
    final bool canPrint = widget.isPrinterConnected;

    return InkWell(
      onTap: canPrint
          ? () {
              setState(() {
                _printReceipt = !_printReceipt;
              });
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: canPrint ? (_printReceipt ? _kGreenSoft : AppColors.bgCard) : AppColors.bgPage,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: canPrint
                ? (_printReceipt ? AppColors.green.withValues(alpha: 0.3) : AppColors.border)
                : AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Checkbox icon
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: canPrint
                    ? (_printReceipt ? AppColors.green : AppColors.bgCard)
                    : AppColors.bgPage,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: canPrint
                      ? (_printReceipt ? AppColors.green : AppColors.borderMid)
                      : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: _printReceipt && canPrint
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            // Label
            Icon(Icons.print, size: 16, color: canPrint ? AppColors.txtMid : AppColors.txtLow),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.get('print_receipt'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: canPrint ? AppColors.txtHigh : AppColors.txtLow,
                    ),
                  ),
                  Text(
                    canPrint
                        ? AppLocalizations.get('printer_is_connected')
                        : AppLocalizations.get('printer_not_connected'),
                    style: TextStyle(
                      fontSize: 9,
                      color: canPrint ? AppColors.txtMid : AppColors.txtLow,
                    ),
                  ),
                ],
              ),
            ),
            if (!canPrint)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  AppLocalizations.get('offline'),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.red,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _quickChip(String label, double value, {bool isExact = false}) {
    final bool isSelected = _cashAmount == value;
    return InkWell(
      onTap: () => _setCash(value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent
              : isExact
              ? AppColors.accentSoft
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : isExact
                ? AppColors.accent.withValues(alpha: 0.3)
                : AppColors.borderMid,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? Colors.white
                : isExact
                ? AppColors.accent
                : AppColors.txtMid,
          ),
        ),
      ),
    );
  }
}
