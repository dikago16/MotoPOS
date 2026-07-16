import 'package:intl/intl.dart';

class CurrencyUtil {
  static String formatRupiah(double v) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(v);

  static String formatNumber(double v) =>
      NumberFormat('#,###', 'id_ID').format(v);
}
