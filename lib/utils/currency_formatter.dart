import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    symbol: '₹',  // Rupee symbol
    locale: 'en_IN',  // Indian locale
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }

  static String formatInt(int amount) {
    return _formatter.format(amount.toDouble());
  }
} 