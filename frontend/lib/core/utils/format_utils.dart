import 'package:intl/intl.dart';

class FormatUtils {
  static final NumberFormat _currencyFormat = NumberFormat('#,##0.00');

  /// Formats a number with commas and 2 decimal places
  /// Example: 1234.56 -> "1,234.56"
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Formats a number with commas (no decimal places)
  /// Example: 1234 -> "1,234"
  static String formatNumber(int number) {
    return NumberFormat('#,##0').format(number);
  }
}
