import 'dart:ui';

import 'package:asgshighschool/data/exist_cart.dart';
import 'package:asgshighschool/data/product_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/store/CartPage.dart';
import 'package:asgshighschool/store/OrderPage.dart';
import 'package:asgshighschool/store/ReservationPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// 상품의 재고는 실제 재고보다 5개 작게 보여준다. 2021/09/21
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
  bool _isDiscountZero; // 할인율이 0.0%인지 아닌지 판단
  int _count = 1; // 버튼으로 누른 수량
  bool _isCart = false; // 장바구니에 담았는지 판단
  bool _isClicked = false; // 구매하기 버튼을 눌렀는지 판단

  /// 일반 숫자에 ,를 붙여서 직관적인 가격을 보이게 하는 작업
  /// @param : 직관적인 가격을 보여줄 실제 int 가격[price]
  /// @return : 직관적인 가격 문자열
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

  /// 문자열을 뒤집는 작업
  /// @param : 뒤집고 싶은 문자열[str]
  /// @return : 뒤집은 문자열
  String _reverseString(String str) {
    String newStr = '';
    for (int i = str.length - 1; i >= 0; --i) {
      newStr += str[i];
    }
    return newStr;
  }

  /// 상품을 장바구니에 추가하는 요청을 하는 작업
  /// @response : 성공 시, '1' or 'Already Exists1'
  Future<bool> _addCartProductRequest() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_addCart.php';
    final response = await http.post(url, body: <String, String>{
      'uid': widget.user.uid,
      'pid': widget.product.prodID.toString(),
      'quantity': _count.toString()
    });

    if (response.statusCode == 200) {
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

  @override
  void initState() {
    super.initState();
    _isDiscountZero = widget.product.discount.toString() == '0.0';
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
                      height: size.width * 0.9 * 1.4,
                      child: CachedNetworkImage(
                        imageUrl: widget.product.imgUrl1,
                        fit: BoxFit.cover,
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
                            '상품 재고 : ${(widget.product.stockCount - 5) < 0 ? 0 : (widget.product.stockCount - 5)}개',
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
                  (widget.product.stockCount - 5) < 0
                      ? Container(
                          child: Text(
                            '재고가 없습니다.',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.black),
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: size.width * 0.15,
                                height: size.height * 0.06,
                                child: IconButton(
                                  onPressed: () {
                                    if (_count > 1) {
                                      setState(() {
                                        --_count;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.remove),
                                ),
                              ),
                              Container(
                                width: size.width * 0.16,
                                height: size.height * 0.06,
                                alignment: Alignment.center,
                                child: Text(
                                  '$_count',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                width: size.width * 0.15,
                                height: size.height * 0.06,
                                child: IconButton(
                                  onPressed: () {
                                    if (_count <
                                        widget.product.stockCount - 5) {
                                      setState(() {
                                        ++_count;
                                      });
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: '더 추가할 수 없습니다!',
                                          gravity: ToastGravity.BOTTOM,
                                          toastLength: Toast.LENGTH_SHORT);
                                    }
                                  },
                                  icon: Icon(Icons.add),
                                ),
                              ),
                            ],
                          ),
                        ),
                  SizedBox(
                    height: size.height * 0.03,
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
          _isClicked
              ? Container(
                  height: size.height * 0.06,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (_count < 1 || widget.product.stockCount - 5 < 1) {
                            Fluttertoast.showToast(
                                msg: '상품의 재고가 없어 장바구니에 담을 수 없습니다!',
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_SHORT);
                            return;
                          }
                          if (!_isCart) {
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
                            setState(() {
                              _isCart = true;
                            });
                          } else {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CartPage(
                                          user: widget.user,
                                          isFromDetail: true,
                                        )));
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          color: Color(0xFF9EE1E5),
                          alignment: Alignment.center,
                          width: size.width * 0.48,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(
                                Icons.shopping_cart,
                                size: 33,
                              ),
                              Text(_isCart ? '장바구니로 이동' : '장바구니 담기',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _isCart
                                          ? Colors.indigo
                                          : Colors.black))
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_count < 1 || widget.product.stockCount - 5 < 1) {
                            Fluttertoast.showToast(
                                msg: '상품의 재고가 없어 결제할 수가 없습니다!',
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_SHORT);
                            return;
                          }
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrderPage(
                                        user: widget.user,
                                        direct: widget.product,
                                        productCount: _count,
                                        cart: null,
                                      )));
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          color: Colors.cyan[700],
                          alignment: Alignment.center,
                          width: size.width * 0.52,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.payment_rounded,
                                  color: Colors.grey[300], size: 33),
                              Text(
                                '${_formatPrice(((widget.product.price * (1 - (widget.product.discount / 100.0)) * _count)).round())}원 결제하기',
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
              : FlatButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    if (widget.product.stockCount - 5 < 1) {
                      // Fluttertoast.showToast(
                      //     msg: '상품의 재고가 없어 구매가 불가능합니다.',
                      //     gravity: ToastGravity.BOTTOM,
                      //     toastLength: Toast.LENGTH_SHORT);
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text(
                                  '재고 없음',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                content: Text(
                                    '현재 상품의 재고가 없어 예약만 가능합니다. 예약하러 가시겠습니까?'),
                                actions: [
                                  FlatButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ReservationPage(
                                                      user: widget.user,
                                                      product: widget.product,
                                                    )));
                                      },
                                      child: Text(
                                        '예',
                                        style:
                                            TextStyle(color: Colors.lightBlue),
                                      )),
                                  FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        '아니오',
                                        style:
                                            TextStyle(color: Colors.deepOrange),
                                      ))
                                ],
                              ));
                      return;
                    } else {
                      setState(() {
                        _isClicked = !_isClicked;
                      });
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: size.width * 0.98,
                    padding: EdgeInsets.all(size.width * 0.025),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: widget.product.stockCount - 5 < 1
                            ? Colors.deepOrange
                            : Colors.blueAccent),
                    child: Text(
                      widget.product.stockCount - 5 < 1 ? '예약하기' : '구매하기',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ))
        ],
      ),
    );
  }
}
