import 'dart:convert';

import 'package:asgshighschool/data/order/order_detail.dart';

import '../data/order/order.dart';

class OrderUtil {
  static List<Order> serializeOrderJson(String jsonString, bool containUser) {
    List<Order> orderList = [];
    List outerJson = jsonDecode(jsonString);

    for (int i = 0; i < outerJson.length; ++i) {
      var current = jsonDecode(outerJson[i]);

      List<OrderDetail> details = [];
      if(containUser)
        current['user'] = jsonDecode(current['user']);

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
}
