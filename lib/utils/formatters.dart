import 'package:intl/intl.dart';

class Formatters {
  // Currency formatter
  static final currencyFormatter = NumberFormat.currency(
    // Use en_US grouping (commas) and prefix the currency symbol manually
    // to match test expectations like "₫100,000".
    locale: 'en_US',
    symbol: '',
    decimalDigits: 0,
  );
  
  // Date formatters
  static final dateFormatter = DateFormat('dd/MM/yyyy');
  static final dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');
  static final monthYearFormatter = DateFormat('MM/yyyy');
  static final dayMonthFormatter = DateFormat('dd/MM');
  static final timeFormatter = DateFormat('HH:mm');
  
  // Format currency
  static String formatCurrency(double amount) {
    final s = currencyFormatter.format(amount);
    return '₫$s';
  }
  
  // Format date
  static String formatDate(DateTime date) {
    return dateFormatter.format(date);
  }
  
  // Format date time
  static String formatDateTime(DateTime date) {
    return dateTimeFormatter.format(date);
  }
  
  // Format month year
  static String formatMonthYear(DateTime date) {
    return monthYearFormatter.format(date);
  }
  
  // Format time
  static String formatTime(DateTime date) {
    return timeFormatter.format(date);
  }
  
  // Format percentage
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
  
  // Abbreviate large numbers
  static String abbreviateNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}T';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}Tr';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }
}