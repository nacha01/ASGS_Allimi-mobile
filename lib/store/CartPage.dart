import 'dart:convert';

import 'package:asgshighschool/data/exist_cart.dart';
import 'package:asgshighschool/data/product_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

/// 장바구니 Item Field
/// 1. cID[hidden]
/// 2. cUID[hidden]
/// 3. cPID[hidden]
/// 4. quantity[visible]
/// 5. prodName[visible]
/// 6. category[visible]
/// 7. price[visible]
/// 8. stockCount[visible]
/// 9. discount[visible]
/// 10. imgUrl1[visible] 고민중..
class CartPage extends StatefulWidget {
  CartPage({this.user});
  final User user;
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map> _cartProductList = []; // 원본 장바구니 데이터
  final _categoryReverseMap = {
    0: '음식류',
    1: '간식류',
    2: '음료류',
    3: '문구류',
    4: '핸드메이드'
  };
  List<int> _countList = [];
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

  Future<bool> _updateCartQuantity(
      int cid, int currentQuantity) async {
    String uri = 'http://nacha01.dothome.co.kr/sin/arlimi_updateCartCount.php';
    final response = await http
        .get(uri + '?cid=$cid&quantity=$currentQuantity');

    if (response.statusCode == 200) {
      print(response.body);
      return true;
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

  int _calculateTotalEachPrice(int price, double discount, int count) {
    if (discount.toString() == '0.0') {
      return price * count;
    } else {
      return ((price * (1 - (discount / 100))) * count).round();
    }
  }
  int _totalPrice(){
    int sum = 0;
    for(int i=0; i<_cartProductList.length; ++i){
      sum += _calculateTotalEachPrice(int.parse(_cartProductList[i]['price']), double.parse(_cartProductList[i]['discount']), _countList[i]);
    }
    return sum;
  }
  void _renewCartCount() async{
    for(int i=0; i<_cartProductList.length; ++i){
      if(int.parse(_cartProductList[i]['quantity']) != _countList[i]){
        await _updateCartQuantity(int.parse(_cartProductList[i]['cID']), _countList[i]);
      }
    }
  }
  @override
  void initState() {
    super.initState();
    _getCartForUserRequest();
  }
  @override
  void dispose() {
    print('dispose area');
    _renewCartCount();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var data = Provider.of<ExistCart>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: SizedBox(),
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
          : Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemBuilder: (context, index) {
                      _countList.add(int.parse(_cartProductList[index]['quantity']));
                      return _cartItemTile(
                          _cartProductList[index], size, data, index);
                    },
                    itemCount: _cartProductList.length),
              ),
              Container(
                color: Color(0xFF9EE1E5),
                height: size.height * 0.05,
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      child: Text('${_cartProductList.length}'),
                      backgroundColor: Colors.white,
                    ),
                    Text('${_formatPrice(_totalPrice())}원 결제하기')
                  ],
                ),
              )
            ],
          ),
    );
  }

  Widget _cartItemTile(
      Map cartItem, Size size, ExistCart existCart, int index) {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(width: 0.5, color: Colors.grey)),
      width: size.width,
      height: size.height * 0.2,
      padding: EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: size.height * 0.2 * 0.8,
            width: size.width * 0.25,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
          ),
          Container(
            // width: size.width * 0.5,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    ? Text(
                        '[ ${double.parse(cartItem['discount'])}% 할인 ]',
                        style: TextStyle(color: Colors.black54),
                      )
                    : SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: size.width * 0.115,
                      height: size.height * 0.05,
                      decoration: BoxDecoration(
                          color: Colors.black38,
                          border:
                              Border.all(width: 1, color: Colors.grey[400])),
                      child: IconButton(
                        onPressed: () async{
                          if (_countList[index] > 1) {
                            setState(() {
                              _countList[index]--;
                            });
                          }
                        },
                        icon: Icon(Icons.remove),
                      ),
                    ),
                    Container(
                      width: size.width * 0.12,
                      height: size.height * 0.05,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.black38,
                          border:
                              Border.all(width: 1, color: Colors.grey[400])),
                      child: Text(
                        '${_countList[index]}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      width: size.width * 0.115,
                      height: size.height * 0.05,
                      decoration: BoxDecoration(
                          color: Colors.black38,
                          border:
                              Border.all(width: 1, color: Colors.grey[400])),
                      child: IconButton(
                        onPressed: () async {
                          setState(() {
                            _countList[index]++;
                          });
                        },
                        icon: Icon(Icons.add),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            // width: size.width * 0.2,
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
                          if (_cartProductList.length == 0) {
                            existCart.setExistCart(false);
                          }
                          Fluttertoast.showToast(
                              msg: '장바구니에서 상품을 삭제하였습니다.',
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_SHORT);
                        } else {
                          Fluttertoast.showToast(
                              msg: '장바구니에서 상품을 삭제하는데 실패했습니다!!',
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_SHORT);
                        }
                      },
                      icon: Icon(
                        Icons.clear,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(bottom: 5),
                    child: Text(
                      '${_formatPrice(_calculateTotalEachPrice(int.parse(cartItem['price']), double.parse(cartItem['discount']), _countList[index]))}원',
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
