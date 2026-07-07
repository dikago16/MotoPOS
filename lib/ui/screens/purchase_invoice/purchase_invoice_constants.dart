import 'package:flutter/material.dart';
import '../../../data/models/product_model.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────
const kNavy = Color(0xFF0D1B2A);
const kAccent = Color(0xFF2563EB);
const kAccentSoft = Color(0xFFEFF6FF);
const kBgPage = Color(0xFFF1F5F9);
const kBgCard = Color(0xFFFFFFFF);
const kBorder = Color(0xFFE2E8F0);
const kBorderMid = Color(0xFFCBD5E1);
const kTableHead = Color(0xFFF8FAFC);
const kRowAlt = Color(0xFFFAFBFD);
const kTxtHigh = Color(0xFF0F172A);
const kTxtMid = Color(0xFF475569);
const kTxtLow = Color(0xFF94A3B8);
const kRed = Color(0xFFDC2626);
const kGreen = Color(0xFF16A34A);

const kColHeader = TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.w700,
  color: Color(0xFF94A3B8),
  letterSpacing: 0.9,
);
// ──────────────────────────────────────────────────────────────────────────────

class PurchaseItemData {
  final Product product;
  int quantity;
  double price;
  double subtotal;

  PurchaseItemData({
    required this.product,
    this.quantity = 1,
    double? price,
  })  : price = price ?? product.buyingPrice,
        subtotal = (price ?? product.buyingPrice) * 1;

  void recalculate() {
    subtotal = price * quantity;
  }
}

InputDecoration inputDeco(String label, {Widget? suffixIcon}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontSize: 12, color: kTxtMid),
    floatingLabelStyle: const TextStyle(
      fontSize: 11,
      color: kAccent,
      fontWeight: FontWeight.w600,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: kBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: kBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: kAccent, width: 1.5),
    ),
    filled: true,
    fillColor: kBgCard,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    suffixIcon: suffixIcon,
  );
}

Widget sectionLabel(String text, {IconData? icon}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(2),
          ),
          margin: const EdgeInsets.only(right: 8),
        ),
        if (icon != null) ...[
          Icon(icon, size: 12, color: kAccent),
          const SizedBox(width: 5),
        ],
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: kTxtMid,
          ),
        ),
      ],
    ),
  );
}
