import 'order_detail.dart';
import 'order_user.dart';

class Order {
  String orderID;
  String orderDate;
  String editDate;
  int totalPrice;
  int orderState;
  int receiveMethod;
  int payMethod;
  String options;
  String? chargerID;
  String tid;
  List<OrderDetail> detail;
  OrderUser? user;

  Order(
      this.orderID,
      this.orderDate,
      this.editDate,
      this.totalPrice,
      this.orderState,
      this.receiveMethod,
      this.payMethod,
      this.options,
      this.chargerID,
      this.tid,
      this.detail,
      this.user);

  Order.fromJson(Map<String, dynamic> json, List<OrderDetail> details)
      : orderID = json['oID'],
        orderDate = json['oDate'],
        editDate = json['eDate'],
        totalPrice = int.parse(json['totalPrice']),
        orderState = int.parse(json['orderState']),
        receiveMethod = int.parse(json['receiveMethod']),
        payMethod = int.parse(json['payMethod']),
        options = json['options'],
        chargerID = json['chargerID'],
        tid = json['tid'],
        detail = details,
        user = json['user'] != null ? OrderUser.fromJson(json['user']) : null;
}
