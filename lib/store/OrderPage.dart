import 'dart:ui';

import 'package:asgshighschool/data/exist_cart.dart';
import 'package:asgshighschool/data/product_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/store/PaymentCompletePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class OrderPage extends StatefulWidget {
  OrderPage({this.direct, this.cart, this.productCount, this.user});
  final Product direct; // 바로 결제 시 그 단일 상품 하나
  final List<Map> cart; // 장바구니에서 결제시 장바구니 리스트 Map 데이터
  final int productCount; // 바로 결제시 상품의 개수
  final User user;
  @override
  _OrderPageState createState() => _OrderPageState();
}

enum ReceiveMethod { DELIVERY, DIRECT }

class _OrderPageState extends State<OrderPage> {
  ReceiveMethod _receiveMethod = ReceiveMethod.DIRECT;
  TextEditingController _requestOptionController = TextEditingController();
  bool _isCart = true;
  String _generatedOID;
  @override
  void initState() {
    if (widget.direct == null) {
      _isCart = true;
    }
    if (widget.cart == null) {
      _isCart = false;
    }
    super.initState();
  }

  Future<bool> _addOrderRequest() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_addOrder.php';
    _generatedOID = DateTime.now().millisecondsSinceEpoch.toString();
    final response = await http.post(url, body: <String, String>{
      'oid': _generatedOID,
      'uid': widget.user.uid,
      'oDate': DateTime.now().toString(),
      'price': (_getOriginTotalPrice() - _getTotalDiscount()).toString(),
      'oState': '1', // 임시 설정
      'recvMethod': _receiveMethod == ReceiveMethod.DIRECT ? '0' : '1',
      'pay': '0', // 임시 설정
      'option': _requestOptionController.text
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _addOrderDetailRequest(int pid, int quantity) async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_addOrderDetail.php';
    final response = await http.post(url, body: <String, String>{
      'oid': _generatedOID,
      'pid': pid.toString(),
      'quantity': quantity.toString()
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _registerOrderRequest() async {
    var orderRes = await _addOrderRequest();
    if (!orderRes) return false;

    if (_isCart) {
      for (int i = 0; i < widget.cart.length; ++i) {
        var cartRes = await _addOrderDetailRequest(
            int.parse(widget.cart[i]['cPID']),
            int.parse(widget.cart[i]['quantity']));
        var deleteRes =
            await _deleteCartRequest(int.parse(widget.cart[i]['cID']));
        var renewCountRes = await _updateProductCountRequest(
            int.parse(widget.cart[i]['cPID']),
            int.parse(widget.cart[i]['quantity']));

        if (!cartRes) return false;
        if (!deleteRes) return false;
        if (!renewCountRes) return false;
      }
    } else {
      var detRes = await _addOrderDetailRequest(
          widget.direct.prodID, widget.productCount);
      var renewCountRes = await _updateProductCountRequest(
          widget.direct.prodID, widget.productCount);

      if (!detRes) return false;
      if (!renewCountRes) return false;
    }
    return true;
  }

  Future<bool> _deleteCartRequest(int cid) async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_deleteCart.php?cid=$cid';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _updateProductCountRequest(int pid, int quantity) async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_updateProductCount.php';
    final response = await http.post(url, body: <String, String>{
      'pid': pid.toString(),
      'quantity': quantity.toString()
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  int _getTotalDiscount() {
    int sum = 0;
    if (_isCart) {
      for (int i = 0; i < widget.cart.length; ++i) {
        sum += ((int.parse(widget.cart[i]['price']) *
                    (widget.cart[i]['discount'].toString() == '0.0'
                        ? 0
                        : double.parse(widget.cart[i]['discount']) / 100)) *
                int.parse(widget.cart[i]['quantity']))
            .round();
      }
    } else {
      sum += ((widget.direct.price *
                  (widget.direct.discount.toString() == '0.0'
                      ? 0
                      : widget.direct.discount / 100)) *
              widget.productCount)
          .round();
    }
    return sum;
  }

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

  int _getOriginTotalPrice() {
    int sum = 0;
    if (_isCart) {
      for (int i = 0; i < widget.cart.length; ++i) {
        sum += int.parse(widget.cart[i]['price']) *
            int.parse(widget.cart[i]['quantity']);
      }
    } else {
      sum = widget.direct.price * widget.productCount;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ExistCart>(context);
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (_isCart)
          Navigator.pop(context, true);
        else {
          Navigator.pop(context);
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              if (_isCart)
                Navigator.pop(context, true);
              else {
                Navigator.pop(context);
              }
            },
            color: Colors.black,
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          backgroundColor: Color(0xFF9EE1E5),
          title: Text(
            '주문하기',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.height * 0.05,
                    ),
                    Divider(
                      thickness: 0.5,
                      indent: 5,
                      endIndent: 5,
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Text(
                      ' * 수령 방식 선택',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black54),
                    ),
                    RadioListTile(
                        subtitle: Text('직접 오셔서 물건을 수령하셔야 합니다.'),
                        title: Text('직접 수령'),
                        value: ReceiveMethod.DIRECT,
                        groupValue: _receiveMethod,
                        onChanged: (value) {
                          setState(() {
                            _receiveMethod = value;
                          });
                        }),
                    RadioListTile(
                        subtitle: Text('요청하신 장소로 배달해드립니다.'),
                        title: Text('배달'),
                        value: ReceiveMethod.DELIVERY,
                        groupValue: _receiveMethod,
                        onChanged: (value) {
                          setState(() {
                            _receiveMethod = value;
                          });
                        }),
                    Divider(
                      thickness: 0.5,
                      indent: 5,
                      endIndent: 5,
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Text(' * 결제 수단 선택',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black54)),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Divider(
                      thickness: 0.5,
                      indent: 5,
                      endIndent: 5,
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Text(' * 휴대폰 본인 인증',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black54)),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Divider(
                      thickness: 0.5,
                      indent: 5,
                      endIndent: 5,
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Text('  추가 요청 사항',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black54)),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Center(
                      child: Container(
                        width: size.width * 0.9,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black),
                            borderRadius: BorderRadius.circular(5)),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: ' 필요시 요청 사항을 입력하세요.',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          controller: _requestOptionController,
                          maxLines: null,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Divider(
                      thickness: 0.5,
                      indent: 5,
                      endIndent: 5,
                    ),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Card(
                      child: Container(
                        height: size.height * 0.2,
                        padding: EdgeInsets.all(size.width * 0.05),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('결제 금액'),
                                Text(
                                    '${_formatPrice(_getOriginTotalPrice())} 원')
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('총 할인 금액'),
                                Text('- ${_formatPrice(_getTotalDiscount())} 원')
                              ],
                            ),
                            Divider(
                              thickness: 2,
                              indent: 1,
                              endIndent: 1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '최종 금액',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    '${_formatPrice(_getOriginTotalPrice() - _getTotalDiscount())} 원',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                  ],
                ),
              ),
            ),
            FlatButton(
              onPressed: () async {
                var res = await _registerOrderRequest();

                if (res) {
                  if (_isCart) {
                    data.setExistCart(false);
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentCompletePage(
                              result: {'orderID': _generatedOID})));
                }
              },
              child: Container(
                alignment: Alignment.center,
                height: size.height * 0.05,
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    color: Color(0xFF9EE1E5)),
                width: size.width,
                child: Text(
                  '${_formatPrice(_getOriginTotalPrice() - _getTotalDiscount())} 원  결제하기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
