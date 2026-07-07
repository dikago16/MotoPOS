import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
const _kGreen = Color(0xFF16A34A);
const _kGreenSoft = Color(0xFFF0FDF4);
const _kRed = Color(0xFFDC2626);
// ──────────────────────────────────────────────────────────────────────────────

class PaymentDialog extends StatefulWidget {
  final double totalAmount;
  final String? initialVehicleNo;

  const PaymentDialog({
    super.key,
    required this.totalAmount,
    this.initialVehicleNo,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _vehicleNoController = TextEditingController();
  double _cashAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _cashController.addListener(_onCashChanged);
    if (widget.initialVehicleNo != null) {
      _vehicleNoController.text = widget.initialVehicleNo!;
    }
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
      labelStyle: const TextStyle(fontSize: 11, color: _kTxtMid),
      floatingLabelStyle: const TextStyle(fontSize: 11, color: _kAccent),
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: _kTxtLow),
      prefixText: prefix,
      prefixStyle: const TextStyle(
        color: _kTxtHigh,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _kAccent, width: 1.5),
      ),
      filled: true,
      fillColor: _kBgCard,
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
          color: _kBgCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _kNavy.withValues(alpha: 0.15),
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
                    colors: [_kNavy, Color(0xFF1B2D45)],
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Complete your transaction',
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
                  color: _kBgPage,
                  border: Border(bottom: BorderSide(color: _kBorder)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'AMOUNT DUE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: _kTxtLow,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(widget.totalAmount),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _kTxtHigh,
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
                            'Vehicle No (Optional)',
                            hint: 'e.g. B 1234 ABC',
                          ).copyWith(
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 10, right: 6),
                              child: Icon(
                                Icons.two_wheeler,
                                size: 16,
                                color: _kTxtLow,
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
                      decoration: _inputDeco('Cash Received', prefix: 'Rp '),
                    ),
                    const SizedBox(height: 10),

                    // Quick Nominals
                    Row(
                      children: [
                        _quickChip('EXACT', widget.totalAmount, isExact: true),
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
                        color: isValid ? _kGreenSoft : _kBgPage,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isValid
                              ? _kGreen.withValues(alpha: 0.25)
                              : _kBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isValid
                                  ? _kGreen.withValues(alpha: 0.12)
                                  : _kBorder.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              isValid
                                  ? Icons.check_circle_outline
                                  : Icons.info_outline,
                              size: 16,
                              color: isValid ? _kGreen : _kTxtLow,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isValid ? 'CHANGE' : 'INSUFFICIENT',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: isValid ? _kGreen : _kTxtLow,
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
                                  color: isValid ? _kGreen : _kRed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _kTxtMid,
                                side: const BorderSide(color: _kBorderMid),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'CANCEL',
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
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text(
                                'CONFIRM PAYMENT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kGreen,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: _kBorder,
                                disabledForegroundColor: _kTxtLow,
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

  Widget _quickChip(String label, double value, {bool isExact = false}) {
    final bool isSelected = _cashAmount == value;
    return InkWell(
      onTap: () => _setCash(value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? _kAccent
              : isExact
              ? _kAccentSoft
              : _kBgCard,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? _kAccent
                : isExact
                ? _kAccent.withValues(alpha: 0.3)
                : _kBorderMid,
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
                ? _kAccent
                : _kTxtMid,
          ),
        ),
      ),
    );
  }
}
