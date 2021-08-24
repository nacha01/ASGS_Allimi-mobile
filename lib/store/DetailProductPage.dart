import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/exist_cart.dart';
import 'package:asgshighschool/data/product_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class DetailProductPage extends StatefulWidget {
  DetailProductPage({this.product, this.user});
  final Product product;
  final User user;
  @override
  _DetailProductPageState createState() => _DetailProductPageState();
}

class _DetailProductPageState extends State<DetailProductPage> {
  final _categoryReverseMap = {
    0: '음식류',
    1: '간식류',
    2: '음료류',
    3: '문구류',
    4: '핸드메이드'
  };
  bool _isDiscountZero;
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

  Future<bool> _addCartProductRequest() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_addCart.php';
    final response = await http.post(url, body: <String, String>{
      'uid': widget.user.uid,
      'pid': widget.product.prodID.toString()
    });

    if (response.statusCode == 200) {
      // print(response.body);
      var replace = response.body
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      print(replace);
      if (replace != '1' && replace != 'Already Exists1') return false;
      return true;
    } else {
      return false;
    }
  }
  Future<bool> _checkExistCart() async{
    String uri = 'http://nacha01.dothome.co.kr/sin/arlimi_checkCart.php';
    final response = await http.get(uri+'?uid=${widget.user.uid}');

    if(response.statusCode == 200){
      print(response.body);
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
          '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
          '')
          .trim();
      if(int.parse(result) >= 1){
        // Provider.of<ExistCart>(this.context).setExistCart(true);
        return true;
      }
      else{
        // Provider.of<ExistCart>(this.context).setExistCart(false);
        return false;
      }
    }
    else{
      return false;
    }
  }
  @override
  void initState() {
    super.initState();
    _isDiscountZero = widget.product.discount.toString() == '0.0';
    print(widget.product.imgUrl2 == null ? '이미지 2는 null' : '2 존재');
    print(widget.product.imgUrl3 == null ? '이미지 3은 null' : '3 존재');
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    var data = Provider.of<ExistCart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '상품 세부정보',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF9EE1E5),
        leading: IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Container(
                      width: size.width * 0.9,
                      height: size.height * 0.5,
                      child: CachedNetworkImage(
                        imageUrl: widget.product.imgUrl1,
                        fit: BoxFit.fill,
                        progressIndicatorBuilder: (context, string, progress) =>
                            Center(child: CircularProgressIndicator()),
                      )),
                  Divider(
                    thickness: 1,
                    endIndent: 15,
                    indent: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widget.product.isBest == 1
                          ? Container(
                              margin: EdgeInsets.symmetric(horizontal: 6),
                              width: size.width * 0.16,
                              height: size.height * 0.08,
                              child: CircleAvatar(
                                backgroundColor: Colors.greenAccent,
                                child: Text(
                                  'BEST MENU',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : SizedBox(),
                      widget.product.isNew == 1
                          ? Container(
                              margin: EdgeInsets.symmetric(horizontal: 6),
                              width: size.width * 0.16,
                              height: size.height * 0.08,
                              child: CircleAvatar(
                                backgroundColor: Colors.limeAccent,
                                child: Text('NEW MENU',
                                    textAlign: TextAlign.center),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                  widget.product.isBest == 1 || widget.product.isNew == 1
                      ? Divider(
                          thickness: 1,
                          endIndent: 15,
                          indent: 15,
                        )
                      : SizedBox(),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Text(
                    '${widget.product.prodName}',
                    textScaleFactor: 3,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '[${_categoryReverseMap[widget.product.category]}]',
                    textScaleFactor: 1.7,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Container(
                      padding: EdgeInsets.all(8),
                      alignment: Alignment.center,
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.black54),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 6))
                          ]),
                      child: Text(
                        '${widget.product.prodInfo}',
                        textScaleFactor: 2,
                        style: TextStyle(),
                        textAlign: TextAlign.center,
                      )),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Container(
                    width: size.width * 0.85,
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.production_quantity_limits,
                          size: 40,
                          color: Colors.grey[700],
                        ),
                        title: Center(
                          child: Text(
                            '상품 재고 : ${widget.product.stockCount}개',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Container(
                    width: size.width * 0.85,
                    child: Card(
                        child: ListTile(
                      leading: Icon(
                        Icons.attach_money,
                        size: 40,
                        color: Colors.green,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_formatPrice(widget.product.price)}원',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: _isDiscountZero
                                    ? TextDecoration.none
                                    : TextDecoration.lineThrough,
                                color:
                                    _isDiscountZero ? Colors.black : Colors.red,
                                fontSize: 19),
                          ),
                          _isDiscountZero
                              ? Text('')
                              : Text(
                                  ' → ${_formatPrice((widget.product.price * (1 - (widget.product.discount / 100.0))).round())}원',
                                  style: TextStyle(fontSize: 19),
                                )
                        ],
                      ),
                      subtitle: _isDiscountZero
                          ? null
                          : Center(
                              child: Text(
                                '${widget.product.discount}% 할인 중',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                    )),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Divider(
                    thickness: 1,
                    endIndent: 15,
                    indent: 15,
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  widget.product.imgUrl2 == null
                      ? SizedBox()
                      : Container(
                          width: size.width * 0.8,
                          height: size.height * 0.4,
                          child: CachedNetworkImage(
                            imageUrl: widget.product.imgUrl2,
                            fit: BoxFit.fill,
                            progressIndicatorBuilder:
                                (context, string, progress) =>
                                    Center(child: CircularProgressIndicator()),
                          )),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  widget.product.imgUrl3 == null
                      ? SizedBox()
                      : Container(
                          width: size.width * 0.8,
                          height: size.height * 0.4,
                          child: CachedNetworkImage(
                            imageUrl: widget.product.imgUrl3,
                            fit: BoxFit.fill,
                            progressIndicatorBuilder:
                                (context, string, progress) =>
                                    Center(child: CircularProgressIndicator()),
                          )),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: size.height * 0.06,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () async {
                    print('장바구니 이동');
                    var result = await _addCartProductRequest();
                    print(result);
                    if (result) {
                      data.setExistCart(true);
                      Fluttertoast.showToast(
                          msg: '장바구니에 추가되었습니다.',
                          gravity: ToastGravity.BOTTOM,
                          toastLength: Toast.LENGTH_SHORT);
                    } else {
                      Fluttertoast.showToast(
                          msg: '장바구니에 추가하는데 문제가 발생했습니다!',
                          gravity: ToastGravity.BOTTOM,
                          toastLength: Toast.LENGTH_SHORT);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: Color(0xFF9EE1E5),
                    alignment: Alignment.center,
                    width: size.width * 0.5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          size: 35,
                        ),
                        Text('장바구니 담기',
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print('결제 이동');
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.cyan[700],
                    alignment: Alignment.center,
                    width: size.width * 0.5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(Icons.payment_rounded,
                            color: Colors.grey[300], size: 35),
                        Text(
                          '결제하기',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[300]),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
