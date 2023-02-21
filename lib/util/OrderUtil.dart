import 'dart:convert';

import 'package:asgshighschool/data/order/order_detail.dart';
import 'package:http/http.dart' as http;
import '../api/ApiUtil.dart';
import '../data/order/order.dart';

class OrderUtil {
  static List<Order> serializeOrderList(String jsonString, bool containUser) {
    List<Order> orderList = [];
    List outerJson = jsonDecode(jsonString);

    for (int i = 0; i < outerJson.length; ++i) {
      var current = jsonDecode(outerJson[i]);

      List<OrderDetail> details = [];
      if (containUser) current['user'] = jsonDecode(current['user']);

      for (int j = 0; j < current['detail'].length; ++j) {
        current['detail'][j] = jsonDecode(current['detail'][j]);
        current['detail'][j]['product'] =
            jsonDecode(current['detail'][j]['product']);
        details.add(OrderDetail.fromJson(current['detail'][j]));
      }
      orderList.add(Order.fromJson(current, details));
    }
    return orderList;
  }

  /// [orderID]의 주문 상태를 [state]로 변경하는 요청
  Future<bool> updateOrderState(String orderID, int state) async {
    String url =
        '${ApiUtil.API_HOST}arlimi_updateOrderState.php?oid=$orderID&state=$state';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// 각 상품의 수량을 [quantity]만큼 [operator] 연산자로 수정하는 요청
  Future<bool> updateProductCountRequest(
      int pid, int quantity, String operator) async {
    String url = '${ApiUtil.API_HOST}arlimi_updateProductCount.php';
    final response = await http.post(Uri.parse(url), body: <String, String>{
      'pid': pid.toString(),
      'quantity': quantity.toString(),
      'oper': operator
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// 각 상품의 누적 판매수를 반영하는 요청
  Future<bool> updateEachProductSellCountRequest(
      int? pid, int? quantity, String operator) async {
    String url = '${ApiUtil.API_HOST}arlimi_updateProductSellCount.php';
    final response = await http
        .get(Uri.parse(url + '?pid=$pid&quantity=$quantity&oper=$operator'));
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// 이 주문을 요청한 사용자의 누적 구매수를 [operator]대로 연산하는 요청
  Future<bool> updateUserBuyCountRequest(String uid, String operator) async {
    String url =
        '${ApiUtil.API_HOST}arlimi_updateUserBuyCount.php?uid=$uid&oper=$operator';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
