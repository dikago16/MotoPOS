import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../data/models/transaction_model.dart';
import '../data/models/transaction_item_model.dart';

/// Service class for generating ESC/POS receipt commands
/// and managing Bluetooth printer communication.
class BluetoothPrinterService {
  // ─── ESC/POS Command Constants ────────────────────────────────────────────
  static const int _lineWidth = 48; // 48 characters for 80mm paper

  // ESC/POS commands
  static final List<int> _cmdInit = [0x1B, 0x40]; // Initialize printer
  static final List<int> _cmdAlignCenter = [0x1B, 0x61, 0x01];
  static final List<int> _cmdAlignLeft = [0x1B, 0x61, 0x00];
  // ignore: unused_field - standard ESC/POS command, kept for future use
  static final List<int> _cmdAlignRight = [0x1B, 0x61, 0x02];
  static final List<int> _cmdBoldOn = [0x1B, 0x45, 0x01];
  static final List<int> _cmdBoldOff = [0x1B, 0x45, 0x00];
  static final List<int> _cmdFeedAndCut = [0x1D, 0x56, 0x00]; // Full cut
  static final List<int> _cmdFeed3Lines = [0x1B, 0x64, 0x03]; // Feed 3 lines
  static final List<int> _cmdNewLine = [0x0A]; // Line feed

  // ─── Receipt Generation ───────────────────────────────────────────────────

  /// Generate the full receipt bytes for a transaction
  static Uint8List generateReceipt({
    required TransactionModel transaction,
    required List<TransactionItemModel> items,
    required int transactionId,
    String storeName = 'My Store',
    String storeAddress = 'Jl. Bunga Melati',
    String storePhone = '08123456789',
  }) {
    final List<int> bytes = [];

    // Initialize printer
    bytes.addAll(_cmdInit);

    // ── Store Header (centered) ──
    bytes.addAll(_cmdAlignCenter);
    bytes.addAll(_cmdBoldOn);
    bytes.addAll(_textToBytes(storeName));
    bytes.addAll(_cmdNewLine);
    bytes.addAll(_cmdBoldOff);
    bytes.addAll(_textToBytes(storeAddress));
    bytes.addAll(_cmdNewLine);
    bytes.addAll(_textToBytes(storePhone));
    bytes.addAll(_cmdNewLine);

    // ── Separator ──
    bytes.addAll(_cmdAlignLeft);
    bytes.addAll(_textToBytes(_separator()));
    bytes.addAll(_cmdNewLine);

    // ── Date/Time & Cashier ──
    final dateTime =
        DateTime.tryParse(transaction.transactionDate) ?? DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    const cashier = 'Admin';
    bytes.addAll(_textToBytes(_twoColumn(dateStr, cashier)));
    bytes.addAll(_cmdNewLine);

    // ── Transaction Number ──
    final trxNo = 'TRX-${transactionId.toString().padLeft(8, '0')}';
    bytes.addAll(_textToBytes('No. $trxNo'));
    bytes.addAll(_cmdNewLine);

    // ── Separator ──
    bytes.addAll(_textToBytes(_separator()));
    bytes.addAll(_cmdNewLine);

    // ── Items ──
    double subTotal = 0;
    for (var item in items) {
      // Item name line
      bytes.addAll(_textToBytes(item.itemName));
      bytes.addAll(_cmdNewLine);

      // Qty x Price = Subtotal line (right-aligned detail)
      final qtyPriceStr = '  ${item.quantity} x ${_formatNumber(item.price)}';
      final subtotalStr = _formatRupiah(item.subtotal);
      bytes.addAll(_textToBytes(_twoColumn(qtyPriceStr, subtotalStr)));
      bytes.addAll(_cmdNewLine);

      subTotal += item.subtotal;
    }

    // ── Separator ──
    bytes.addAll(_textToBytes(_separator()));
    bytes.addAll(_cmdNewLine);

    // ── Sub Total ──
    bytes.addAll(
      _textToBytes(_twoColumn('Sub Total', _formatRupiah(subTotal))),
    );
    bytes.addAll(_cmdNewLine);

    // ── Separator ──
    bytes.addAll(_textToBytes(_separator()));
    bytes.addAll(_cmdNewLine);

    // ── Total ──
    bytes.addAll(_cmdBoldOn);
    bytes.addAll(
      _textToBytes(_twoColumn('TOTAL', _formatRupiah(transaction.totalAmount))),
    );
    bytes.addAll(_cmdNewLine);
    bytes.addAll(_cmdBoldOff);

    // ── Payment ──
    bytes.addAll(
      _textToBytes(
        _twoColumn('Paid (Cash)', _formatRupiah(transaction.cashAmount)),
      ),
    );
    bytes.addAll(_cmdNewLine);

    // ── Change ──
    bytes.addAll(
      _textToBytes(
        _twoColumn('Change', _formatRupiah(transaction.changeAmount)),
      ),
    );
    bytes.addAll(_cmdNewLine);

    // ── Separator ──
    bytes.addAll(_textToBytes(_separator()));
    bytes.addAll(_cmdNewLine);

    // ── Footer (centered) ──
    bytes.addAll(_cmdAlignCenter);
    bytes.addAll(_cmdNewLine);
    bytes.addAll(_textToBytes('Terimakasih Telah Menggunakan Layanan Kami'));
    bytes.addAll(_cmdNewLine);

    // ── Feed & Cut ──
    bytes.addAll(_cmdFeed3Lines);
    bytes.addAll(_cmdFeedAndCut);

    return Uint8List.fromList(bytes);
  }

  // ─── Helper Methods ───────────────────────────────────────────────────────

  /// Convert text string to bytes
  static List<int> _textToBytes(String text) {
    return text.codeUnits;
  }

  /// Create separator line (40 dashes)
  static String _separator() {
    return '-' * _lineWidth;
  }

  /// Format number as Rupiah: "Rp 90.000"
  static String _formatRupiah(double v) {
    return 'Rp ${NumberFormat('#,###', 'id_ID').format(v)}';
  }

  /// Format number without prefix
  static String _formatNumber(double v) {
    return NumberFormat('#,###', 'id_ID').format(v);
  }

  /// Create two-column text that fills the line width
  /// Left text aligned left, right text aligned right
  static String _twoColumn(String left, String right) {
    final totalLen = left.length + right.length;
    if (totalLen >= _lineWidth) {
      return '$left $right';
    }
    final spaces = _lineWidth - totalLen;
    return '$left${' ' * spaces}$right';
  }
}
