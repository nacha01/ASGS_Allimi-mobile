import 'dart:convert';
import 'package:asgshighschool/data/payment_cancel.dart';
import 'package:asgshighschool/util/OrderUtil.dart';
import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:cp949_dart/cp949_dart.dart' as cp949;

import '../data/order/order.dart';

class PaymentUtil {
  static const _KEY =
      '0DVRz8vSDD5HvkWRwSxpjVhhx7OlXEViTciw5lBQAvSyYya9yf0K0Is+JbwiR9yYC96rEH2XIbfzeHXgqzSAFQ==';
  static const MID = 'asgscoop1m';
  static const REDIRECT_URL =
      'http://nacha01.dothome.co.kr/sin/payment_redirect.php';
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

  static Future<PaymentCancelResponse?> cancelPayment(
      String tid, String orderID, int totalPrice, bool isAuthenticated) async {
    var ediDate = getEdiDate();
    final response =
        await http.post(Uri.parse(CANCEL_API_URL), body: <String, String>{
      'TID': tid,
      'MID': MID,
      'Moid': orderID,
      'CancelAmt': totalPrice.toString(),
      'CancelMsg': isAuthenticated ? '관리자에 의한 취소' : '결제자의 요청에 의한 취소',
      'PartialCancelCode': '0',
      'EdiDate': ediDate,
      'SignData': encryptCancel(totalPrice, ediDate),
      'CharSet': 'euc-kr',
      'EdiType': 'JSON'
    });
    if (response.statusCode == 200) {
      return PaymentCancelResponse.fromJson(
          jsonDecode(cp949.decode(response.bodyBytes)));
    } else {
      return null;
    }
  }

  static Future<bool> cancelOrderHandling(
      String uid, Order order, PaymentCancelResponse cancelResponse) async {
    var orderManager = OrderUtil();

    if (cancelResponse.resultCode == '2001') {
      var res = await orderManager.updateOrderState(order.orderID, 4);
      if (!res) return false;

      for (var detail in order.detail) {
        var result = await orderManager.updateProductCountRequest(
            detail.product.productID, detail.quantity, '+');
        if (!result) return false;
      }

      for (var detail in order.detail) {
        var result = await orderManager.updateEachProductSellCountRequest(
            detail.product.productID, detail.quantity, '-');
        if (!result) return false;
      }

      var buyerCountRes =
          await orderManager.updateUserBuyCountRequest(uid, '-');
      if (!buyerCountRes) return false;

      return true;
    } else {
      return false;
    }
  }
}
