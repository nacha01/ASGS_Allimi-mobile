import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import 'package:crypto/crypto.dart';

class PaymentUtil {
  static const _KEY =
      '0DVRz8vSDD5HvkWRwSxpjVhhx7OlXEViTciw5lBQAvSyYya9yf0K0Is+JbwiR9yYC96rEH2XIbfzeHXgqzSAFQ==';
  static const MID = 'asgscoop1m';
  static const REDIRECT_URL =
      'http://nacha01.dothome.co.kr/sin/result_test.php';
  static const PLATFORM_CHANNEL = MethodChannel('asgs');
  static const CANCEL_API_URL =
      'https://webapi.nicepay.co.kr/webapi/cancel_process.jsp';
  static const PAY_API_URL = 'https://web.nicepay.co.kr/v3/v3Payment.jsp';

  /// 결제 인증 위변조 검증 암호화 데이터
  static String encryptAuthentication(int totalPrice, String ediDate) {
    return HEX.encode(sha256
        .convert(utf8.encode(ediDate + MID + totalPrice.toString() + _KEY))
        .bytes);
  }

  /// 결제 취소 위변조 검증 암호화 데이터
  static String encryptCancel(int cancelAmt, String ediDate) {
    return HEX.encode(sha256
        .convert(utf8.encode(MID + cancelAmt.toString() + ediDate + _KEY))
        .bytes);
  }

  static String getEdiDate() {
    return DateTime.now()
        .toString()
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .replaceAll(':', '')
        .split('.')[0];
  }
}
