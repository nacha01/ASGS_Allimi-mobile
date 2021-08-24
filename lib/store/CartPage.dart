import 'dart:convert';

import 'package:asgshighschool/data/exist_cart.dart';
import 'package:asgshighschool/data/product_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

/// 장바구니 Item Field
/// 1. cID
/// 2. cUID
/// 3. cPID
/// 4. quantity[visible]
/// 5. prodName[visible]
/// 6. category[visible]
/// 7. price[visible]
/// 8. stockCount[visible]
/// 9. discount[visible]
/// 10. imgUrl1[visible]
class CartPage extends StatefulWidget {
  CartPage({this.user});
  final User user;
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map> _cartProductList = [];
  final _categoryReverseMap = {
    0: '음식류',
    1: '간식류',
    2: '음료류',
    3: '문구류',
    4: '핸드메이드'
  };
  Future<bool> _getCartForUserRequest() async {
    String uri = 'http://nacha01.dothome.co.kr/sin/arlimi_getAllCart.php';
    final response = await http.get(uri + '?uid=${widget.user.uid}');
    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List cartProduct = json.decode(result);
      _cartProductList.clear();
      for (int i = 0; i < cartProduct.length; ++i) {
        _cartProductList.add(json.decode(cartProduct[i]));
      }
      print(_cartProductList);
      print(_cartProductList.length);
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _deleteCartForUserRequest(int cid) async {
    String uri = 'http://nacha01.dothome.co.kr/sin/arlimi_deleteCart.php';
    final response = await http.get(uri + '?cid=$cid');

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      print(result);
      if (result == 'DELETED') {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  String _formatPrice(int price) {
    String p = price.toString();
    String newFormat = '';
    int count = 0;
    for (int i = p.length - 1; i >= 0; --i) {
      if ((count + 1) % 4 == 0) {
        newFormat += ',';
        ++i;
      } else
        newFormat += p[i];
      ++count;
    }
    return _reverseString(newFormat);
  }

  String _reverseString(String str) {
    String newStr = '';
    for (int i = str.length - 1; i >= 0; --i) {
      newStr += str[i];
    }
    return newStr;
  }

  int _calculTotalPrice(int price, double discount, int count) {
    if (discount.toString() == '0.0') {
      return price * count;
    } else {
      return ((price * (1 - (discount / 100))) * count).round();
    }
  }

  @override
  void initState() {
    super.initState();
    _getCartForUserRequest();
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<ExistCart>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '장바구니',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _cartProductList.length == 0
          ? Center(
              child: Text('장바구니에 상품이 없습니다!'),
            )
          : ListView.builder(
              itemBuilder: (context, index) {
                return _cartItemTile(_cartProductList[index], size, data);
              },
              itemCount: _cartProductList.length),
    );
  }

  Widget _cartItemTile(Map cartItem, Size size, ExistCart existCart) {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(width: 0.5, color: Colors.grey)),
      width: size.width,
      height: size.height * 0.2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: size.height * 0.2 * 0.8,
            width: size.width * 0.25,
            child: CachedNetworkImage(
              imageUrl: cartItem['imgUrl1'],
              fit: BoxFit.fill,
              progressIndicatorBuilder: (context, string, progress) => Center(
                child: CircularProgressIndicator(
                  value: progress.progress,
                ),
              ),
            ),
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      cartItem['prodName'],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '  [${_categoryReverseMap[int.parse(cartItem['category'])]}]',
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
                Text('· 정가 : ${_formatPrice(int.parse(cartItem['price']))}원'),
                double.parse(cartItem['discount']).toString() != '0.0'
                    ? Text('· 할인 : ${double.parse(cartItem['discount'])}%')
                    : SizedBox(),
                Row(
                  children: [
                    Container(
                      width: size.width * 0.12,
                      height: size.height * 0.05,
                      decoration: BoxDecoration(
                          color: Colors.black38,
                          border:
                              Border.all(width: 1, color: Colors.grey[400])),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.remove),
                      ),
                    ),
                    Container(
                      width: size.width * 0.13,
                      height: size.height * 0.05,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.black38,
                          border:
                              Border.all(width: 1, color: Colors.grey[400])),
                      child: Text(
                        '${cartItem['quantity']}개',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      width: size.width * 0.12,
                      height: size.height * 0.05,
                      decoration: BoxDecoration(
                          color: Colors.black38,
                          border:
                              Border.all(width: 1, color: Colors.grey[400])),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.add),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () async {
                        var result = await _deleteCartForUserRequest(
                            int.parse(cartItem['cID']));
                        if (result) {
                          var res = await _getCartForUserRequest();
                          if(_cartProductList.length == 0){
                            existCart.setExistCart(false);
                          }
                          print('성공');
                        } else {
                          print('실패');
                        }
                      },
                      icon: Icon(Icons.clear),
                    ),
                  ),
                ),
                Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                      '${_formatPrice(_calculTotalPrice(int.parse(cartItem['price']), double.parse(cartItem['discount']), int.parse(cartItem['quantity'])))}원',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
