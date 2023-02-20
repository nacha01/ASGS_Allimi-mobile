import 'package:asgshighschool/data/order/order_product.dart';

class OrderDetail {
  int detailID;
  int quantity;
  OrderProduct product;

  OrderDetail(this.detailID, this.quantity, this.product);

  OrderDetail.fromJson(Map<String, dynamic> json)
      : detailID = int.parse(json['detailID']),
        quantity = int.parse(json['quantity']),
        product = OrderProduct.fromJson(json['product']);
}
