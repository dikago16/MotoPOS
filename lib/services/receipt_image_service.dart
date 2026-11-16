import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/store_info_model.dart';
import '../data/models/transaction_item_model.dart';
import '../data/models/transaction_model.dart';

/// Service to generate thermal receipt images (gambar nota)
/// formatted like real thermal POS paper printouts.
class ReceiptImageService {
  static const double receiptWidth = 550.0;
  static const double horizontalPadding = 32.0;
  static const double verticalPadding = 36.0;
  static const double contentWidth = receiptWidth - (horizontalPadding * 2);

  // Monospace styling for authentic thermal receipt look
  static const String fontFamily = 'monospace';

  static String _formatNumber(double amount) {
    return NumberFormat('#,###', 'id_ID').format(amount);
  }

  /// Generates PNG image bytes for a transaction receipt.
  static Future<Uint8List> generateReceiptImage({
    required TransactionModel transaction,
    required List<TransactionItemModel> items,
    required StoreInfoModel storeInfo,
  }) async {
    final dateTime =
        DateTime.tryParse(transaction.transactionDate) ?? DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);

    // Styles
    const styleStoreName = TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      height: 1.25,
    );
    const styleStoreInfo = TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.black,
      height: 1.3,
    );
    const styleDivider = TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      height: 1.2,
    );
    const styleMeta = TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.black,
      height: 1.3,
    );
    const styleItemName = TextStyle(
      fontFamily: fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      height: 1.25,
    );
    const styleItemDetail = TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.black,
      height: 1.25,
    );
    const styleTotalLabel = TextStyle(
      fontFamily: fontFamily,
      fontSize: 19,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      height: 1.3,
    );
    const styleTotalValue = TextStyle(
      fontFamily: fontFamily,
      fontSize: 19,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      height: 1.3,
    );
    const styleSummaryLabel = TextStyle(
      fontFamily: fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.normal,
      color: Colors.black,
      height: 1.3,
    );
    const styleSummaryValue = TextStyle(
      fontFamily: fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.normal,
      color: Colors.black,
      height: 1.3,
    );
    const styleFooter = TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: Colors.black,
      height: 1.35,
    );

    // Calculate divider string length
    final sampleCharPainter = TextPainter(
      text: const TextSpan(text: '=', style: styleDivider),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final charWidth = sampleCharPainter.width > 0 ? sampleCharPainter.width : 9.5;
    final dividerCharCount = (contentWidth / charWidth).floor();
    final dividerString = '=' * dividerCharCount;

    // Build layout elements
    final List<_ReceiptElement> elements = [];

    void addCenterText(String text, TextStyle style, {double spacingAfter = 4.0}) {
      if (text.trim().isEmpty) return;
      final painter = TextPainter(
        text: TextSpan(text: text.trim(), style: style),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: contentWidth);
      elements.add(_CenterTextElement(painter, spacingAfter));
    }

    void addDivider({double spacingAfter = 8.0}) {
      final painter = TextPainter(
        text: TextSpan(text: dividerString, style: styleDivider),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: contentWidth);
      elements.add(_CenterTextElement(painter, spacingAfter));
    }

    void addTwoColumn(
      String left,
      String right, {
      TextStyle leftStyle = styleMeta,
      TextStyle rightStyle = styleMeta,
      double spacingAfter = 4.0,
    }) {
      final rightPainter = TextPainter(
        text: TextSpan(text: right, style: rightStyle),
        textAlign: TextAlign.right,
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: contentWidth * 0.5);

      final leftMaxWidth = max(10.0, contentWidth - rightPainter.width - 8.0);
      final leftPainter = TextPainter(
        text: TextSpan(text: left, style: leftStyle),
        textAlign: TextAlign.left,
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: leftMaxWidth);

      elements.add(_TwoColumnElement(leftPainter, rightPainter, spacingAfter));
    }

    // ── 1. Header (Store info) ────────────────────────────────────────────────
    addCenterText(storeInfo.storeName.toUpperCase(), styleStoreName, spacingAfter: 6.0);
    if (storeInfo.address.isNotEmpty) {
      addCenterText(storeInfo.address, styleStoreInfo, spacingAfter: 4.0);
    }
    if (storeInfo.phone.isNotEmpty) {
      addCenterText(storeInfo.phone, styleStoreInfo, spacingAfter: 8.0);
    }

    // ── 2. Top Divider ────────────────────────────────────────────────────────
    addDivider(spacingAfter: 8.0);

    // ── 3. Transaction Meta ───────────────────────────────────────────────────
    if (transaction.id != null) {
      addTwoColumn('Receipt #', '#${transaction.id}', spacingAfter: 4.0);
    }
    addTwoColumn('Tanggal', dateStr, spacingAfter: 4.0);
    if (transaction.vehicleNo != null && transaction.vehicleNo!.trim().isNotEmpty) {
      addTwoColumn('No. Pol', transaction.vehicleNo!.trim(), spacingAfter: 4.0);
    }
    if (transaction.customerName != null && transaction.customerName!.trim().isNotEmpty) {
      addTwoColumn('Customer', transaction.customerName!.trim(), spacingAfter: 4.0);
    }
    if (transaction.cashierName != null && transaction.cashierName!.trim().isNotEmpty) {
      addTwoColumn('Kasir', transaction.cashierName!.trim(), spacingAfter: 4.0);
    }

    // ── 4. Item Divider ───────────────────────────────────────────────────────
    addDivider(spacingAfter: 8.0);

    // ── 5. Items ──────────────────────────────────────────────────────────────
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      // Item name line
      final namePainter = TextPainter(
        text: TextSpan(text: item.itemName, style: styleItemName),
        textAlign: TextAlign.left,
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: contentWidth);
      elements.add(_LeftTextElement(namePainter, 3.0));

      // Quantity x Price and Subtotal line
      final qtyPrice = '${item.quantity} x ${_formatNumber(item.price)}';
      final subtotal = _formatNumber(item.subtotal);
      addTwoColumn(
        qtyPrice,
        subtotal,
        leftStyle: styleItemDetail,
        rightStyle: styleItemDetail,
        spacingAfter: i < items.length - 1 ? 8.0 : 8.0,
      );
    }

    // ── 6. Summary Divider ────────────────────────────────────────────────────
    addDivider(spacingAfter: 8.0);

    // ── 7. Summary / Totals ───────────────────────────────────────────────────
    addTwoColumn(
      'Total  Rp.',
      _formatNumber(transaction.totalAmount),
      leftStyle: styleTotalLabel,
      rightStyle: styleTotalValue,
      spacingAfter: 6.0,
    );
    addTwoColumn(
      'Cash   Rp.',
      _formatNumber(transaction.cashAmount),
      leftStyle: styleSummaryLabel,
      rightStyle: styleSummaryValue,
      spacingAfter: 4.0,
    );
    addTwoColumn(
      'Change Rp.',
      _formatNumber(transaction.changeAmount),
      leftStyle: styleSummaryLabel,
      rightStyle: styleSummaryValue,
      spacingAfter: 12.0,
    );

    // ── 8. Footer ─────────────────────────────────────────────────────────────
    addCenterText('Terima kasih sudah menggunakan', styleFooter, spacingAfter: 3.0);
    addCenterText('layanan kami.', styleFooter, spacingAfter: 10.0);
    addCenterText('====== $dateStr ======', styleFooter, spacingAfter: 0.0);

    // ── Calculate Total Height ────────────────────────────────────────────────
    double totalHeight = verticalPadding * 2;
    for (final el in elements) {
      totalHeight += el.height + el.spacingAfter;
    }

    // ── Paint to Canvas ───────────────────────────────────────────────────────
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // White background
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, receiptWidth, totalHeight), bgPaint);

    double currentY = verticalPadding;
    for (final el in elements) {
      el.paint(canvas, currentY, horizontalPadding, contentWidth, receiptWidth);
      currentY += el.height + el.spacingAfter;
    }

    // Convert to Image and PNG bytes
    final picture = recorder.endRecording();
    final img = await picture.toImage(
      receiptWidth.toInt(),
      totalHeight.toInt(),
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Generates the receipt image and writes it to a temporary file.
  /// Returns the absolute file path of the saved PNG image.
  static Future<String> generateReceiptFile({
    required TransactionModel transaction,
    required List<TransactionItemModel> items,
    required StoreInfoModel storeInfo,
  }) async {
    final bytes = await generateReceiptImage(
      transaction: transaction,
      items: items,
      storeInfo: storeInfo,
    );

    final tempDir = await getTemporaryDirectory();
    final txnId = transaction.id ?? DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/nota_$txnId.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}

// ── Internal Layout Elements ──────────────────────────────────────────────────

abstract class _ReceiptElement {
  double get height;
  double get spacingAfter;
  void paint(
    Canvas canvas,
    double y,
    double paddingLeft,
    double contentWidth,
    double totalWidth,
  );
}

class _CenterTextElement extends _ReceiptElement {
  final TextPainter painter;
  @override
  final double spacingAfter;

  _CenterTextElement(this.painter, this.spacingAfter);

  @override
  double get height => painter.height;

  @override
  void paint(
    Canvas canvas,
    double y,
    double paddingLeft,
    double contentWidth,
    double totalWidth,
  ) {
    final x = (totalWidth - painter.width) / 2.0;
    painter.paint(canvas, Offset(x, y));
  }
}

class _LeftTextElement extends _ReceiptElement {
  final TextPainter painter;
  @override
  final double spacingAfter;

  _LeftTextElement(this.painter, this.spacingAfter);

  @override
  double get height => painter.height;

  @override
  void paint(
    Canvas canvas,
    double y,
    double paddingLeft,
    double contentWidth,
    double totalWidth,
  ) {
    painter.paint(canvas, Offset(paddingLeft, y));
  }
}

class _TwoColumnElement extends _ReceiptElement {
  final TextPainter leftPainter;
  final TextPainter rightPainter;
  @override
  final double spacingAfter;

  _TwoColumnElement(this.leftPainter, this.rightPainter, this.spacingAfter);

  @override
  double get height => max(leftPainter.height, rightPainter.height);

  @override
  void paint(
    Canvas canvas,
    double y,
    double paddingLeft,
    double contentWidth,
    double totalWidth,
  ) {
    leftPainter.paint(canvas, Offset(paddingLeft, y));
    final rightX = totalWidth - paddingLeft - rightPainter.width;
    rightPainter.paint(canvas, Offset(rightX, y));
  }
}
