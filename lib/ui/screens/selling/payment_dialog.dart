import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Enterprise Design Tokens
const _kNavy = Color(0xFF0D1B2A);
const _kAccent = Color(0xFF2563EB);
const _kAccentSoft = Color(0xFFEFF6FF);
const _kBgCard = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE2E8F0);
const _kTxtHigh = Color(0xFF0F172A);
const _kTxtMid = Color(0xFF475569);

class PaymentDialog extends StatefulWidget {
  final double totalAmount;

  const PaymentDialog({super.key, required this.totalAmount});

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

  String _formatNumber(double v) => NumberFormat('#,###', 'id_ID').format(v);

  List<double> _getQuickNominals() {
    List<double> nominals = [];

    // Nearest multiples
    if (widget.totalAmount < 20000) nominals.add(20000);
    if (widget.totalAmount < 50000) nominals.add(50000);
    if (widget.totalAmount < 100000) nominals.add(100000);

    double next50k = ((widget.totalAmount / 50000).floor() + 1) * 50000.0;
    if (!nominals.contains(next50k)) nominals.add(next50k);

    double next100k = ((widget.totalAmount / 100000).floor() + 1) * 100000.0;
    if (!nominals.contains(next100k)) nominals.add(next100k);

    return nominals.take(3).toList();
  }

  void _setCash(double amount) {
    _cashController.text = amount.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    double changeAmount = _cashAmount - widget.totalAmount;
    if (changeAmount < 0) changeAmount = 0;

    return Dialog(
      backgroundColor: _kBgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.payment, color: _kAccent),
                  const SizedBox(width: 8),
                  const Text(
                    'Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kTxtHigh,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: _kTxtMid),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(height: 16, color: _kBorder),

              // TOTAL
              Center(
                child: Column(
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _kTxtMid,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rp ${_formatNumber(widget.totalAmount)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _kTxtHigh,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // VEHICLE NO
              const Text(
                'Vehicle No (Optional)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _kTxtMid,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _vehicleNoController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'e.g. B 1234 ABC',
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),

              // INPUT CASH
              const Text(
                'Cash Amount',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _kTxtMid,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _cashController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(
                    color: _kTxtHigh,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),

              // QUICK BUTTONS
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _quickBtn('EXACT', widget.totalAmount),
                  ..._getQuickNominals().map(
                    (nom) => _quickBtn(_formatNumber(nom), nom),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // CHANGE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _kAccentSoft,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _kAccent.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CHANGE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _kTxtMid,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Rp ${_formatNumber(changeAmount)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _kAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: _cashAmount >= widget.totalAmount
                      ? () {
                          Navigator.pop(context, {
                            'cashAmount': _cashAmount,
                            'vehicleNo': _vehicleNoController.text,
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kNavy,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _kBorder,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'CONFIRM PAYMENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickBtn(String label, double value) {
    return InkWell(
      onTap: () => _setCash(value),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: _kBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _kTxtMid,
          ),
        ),
      ),
    );
  }
}
