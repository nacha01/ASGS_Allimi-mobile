import 'package:intl/intl.dart';

class NumberFormatter {
  /// 정수 값의 세자리마다 콤마를 붙힌 가격 format 문자열
  static String formatPrice(int number) {
    return NumberFormat('###,###,###,###').format(number);
  }

  /// 정수 값의 날짜 혹은 시간을 두자리의 문자열로 formatting 하는 작업
  static String formatZero(int value) {
    return value > 9 ? value.toString() : '0' + value.toString();
  }
}
