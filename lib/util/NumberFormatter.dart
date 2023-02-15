import 'package:intl/intl.dart';

class NumberFormatter {
  static String formatNumber(int number) {
    return NumberFormat('###,###,###,###').format(number);
  }
}
