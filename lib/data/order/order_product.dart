import 'package:asgshighschool/data/category.dart';

class OrderProduct {
  int productID;
  String name;
  String category;
  int price;
  double? discount;
  bool isOnSale;

  OrderProduct(this.productID, this.name, this.category, this.price,
      this.discount, this.isOnSale);

  OrderProduct.fromJson(Map<String, dynamic> json)
      : productID = int.parse(json['productID']),
        name = json['productName'],
        category =
            Category.categoryIndexToStringMap[int.parse(json['category'])]!,
        price = int.parse(json['price']),
        discount =
            json['discount'] == '0' ? null : double.parse(json['discount']),
        isOnSale = int.parse(json['onSale']) == 1;
}
