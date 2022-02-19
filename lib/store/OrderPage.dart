import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/product_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/store/PaymentWebViewPage.dart';
import 'package:asgshighschool/store/StoreMainPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderPage extends StatefulWidget {
  OrderPage(
      {this.direct,
      this.cart,
      this.productCount,
      this.user,
      this.optionList,
      this.selectList,
      this.additionalPrice});
  final Product direct; // 바로 결제 시 그 단일 상품 하나
  final List<Map> cart; // 장바구니에서 결제시 장바구니 리스트 Map 데이터
  final int productCount; // 바로 결제시 상품의 개수
  final User user;
  final List optionList;
  final List selectList;
  final int additionalPrice; // 장바구니에서 결제시 모든 상품들의 상품 옵션의 총 가격
  @override
  _OrderPageState createState() => _OrderPageState();
}

enum ReceiveMethod { DELIVERY, DIRECT }

class _OrderPageState extends State<OrderPage> {
  ReceiveMethod _receiveMethod = ReceiveMethod.DIRECT;
  TextEditingController _requestOptionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  bool _isCart = true;
  String _generatedOID;
  String _checkMessage;
  bool _isSelected = false;
  String _optionString = '';
  int _additionalPrice = 0;
  String _entireOptionForCart = '';

  @override
  void initState() {
    if (widget.direct == null) {
      _isCart = true;
      _sumOptionStringForCart();
    }
    if (widget.cart == null) {
      _isCart = false;
    }
    _preProcessForOptions();
    super.initState();
  }

  void _preProcessForOptions() {
    if (widget.selectList == null || widget.selectList.length == 0) {
      return;
    }
    for (int i = 0; i < widget.selectList.length; ++i) {
      if (widget.selectList[i] != -1) {
        _isSelected = true;
        break;
      }
    }
    if (!_isSelected) {
      return;
    }
    for (int j = 0; j < widget.productCount; ++j) {
      _optionString += '[ 상품 옵션 : ';
      for (int i = 0; i < widget.optionList.length; ++i) {
        if (widget.selectList[i] != -1) {
          _additionalPrice += int.parse(widget.optionList[i]['detail']
              [widget.selectList[i]]['optionPrice']);
          _optionString += widget.optionList[i]['optionCategory'] +
              ' ' +
              widget.optionList[i]['detail'][widget.selectList[i]]
                  ['optionName'] +
              ' , ';
        }
      }
      if (j == widget.productCount - 1) {
        _optionString += ']';
      } else {
        _optionString += ']\n';
      }
    }
    setState(() {});
  }

  /// 장바구니의 경우에 각 상품의 옵션 텍스트를 합치는 기능
  void _sumOptionStringForCart() {
    for (int i = 0; i < widget.cart.length; ++i) {
      _entireOptionForCart += widget.cart[i]['options'] + '\n';
    }
    _entireOptionForCart =
        _entireOptionForCart.substring(0, _entireOptionForCart.length - 1);
  }

  /// 최종적으로 결제 하기 전 그 순간에서 재고 상황을 체크하는 작업(단일 상품)
  Future<bool> _checkSynchronousStockCountForProduct() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getOneProduct.php';
    final response = await http.get(url + '?pid=${widget.direct.prodID}');

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      Map p = json.decode(result);
      if (widget.productCount <= int.parse(p['stockCount'])) {
        _checkMessage = '성공적으로 처리가 완료되었습니다.';
        return true;
      } else {
        _checkMessage = '"${widget.direct.prodName}"상품의 선택 수량이 현재 재고보다 많습니다.';
        return false;
      }
    } else {
      return false;
    }
  }

  /// 최종적으로 결제 하기 전 그 순간에서 재고 상황을 체크하는 작업(장바구니)
  Future<bool> _checkSynchronousStockCountForCart() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getAllCart.php';
    final response = await http.get(url + '?uid=${widget.user.uid}');
    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List cartProduct = json.decode(result);
      List<Map> checksum = [];
      for (int i = 0; i < cartProduct.length; ++i) {
        checksum.add(json.decode(cartProduct[i]));
      }
      for (int i = 0; i < checksum.length; ++i) {
        if (int.parse(widget.cart[i]['quantity']) >=
            (int.parse(checksum[i]['stockCount']))) {
          _checkMessage =
              '"${widget.cart[i]['prodName']}"상품의 선택 수량이 현재 재고보다 많습니다.';
          return false;
        }
      }
      _checkMessage = '성공적으로 처리가 완료되었습니다.';
      return true;
    } else {
      return false;
    }
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

  /// 총 원가격의 금액을 구하는 작업
  int _getOriginTotalPrice() {
    int sum = 0;
    if (_isCart) {
      for (int i = 0; i < widget.cart.length; ++i) {
        sum += int.parse(widget.cart[i]['price']) *
            int.parse(widget.cart[i]['quantity']);
      }
      sum += widget.additionalPrice;
    } else {
      sum = (widget.direct.price) * widget.productCount;
      sum += _additionalPrice; // 이미 여기서 개수만큼 다 구해놓음 (개수 곱할 필요 없음)
    }
    return sum;
  }

  /// 총 할인 금액을 구하는 작업
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
      sum += (((widget.direct.price * widget.productCount) *
              (widget.direct.discount.toString() == '0.0'
                  ? 0
                  : widget.direct.discount / 100.0)))
          .round();
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
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
                    _receiveMethod == ReceiveMethod.DELIVERY
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: size.width * 0.95,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.black),
                                    borderRadius: BorderRadius.circular(6)),
                                child: TextField(
                                  controller: _locationController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: ' 배달 장소를 입력해주세요.',
                                      hintStyle: TextStyle(color: Colors.grey)),
                                ),
                              ),
                            ],
                          )
                        : SizedBox(),
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
                      height: size.height * 0.01,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: size.width * 0.05,
                        ),
                        Icon(
                          Icons.radio_button_checked,
                          color: Colors.grey,
                        ),
                        Text(
                          '   신용카드',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: size.width * 0.05,
                        ),
                        Icon(
                          Icons.radio_button_off,
                          color: Colors.grey,
                        ),
                        Text(
                          '   기타 (준비중입니다.)',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    SizedBox(
                      height: size.height * 0.02,
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
                      height: size.height * 0.02,
                    ),
                    Divider(
                      thickness: 0.5,
                      indent: 5,
                      endIndent: 5,
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Text(' 상품 옵션',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black54)),
                    Container(
                      padding: EdgeInsets.all(size.width * 0.02),
                      width: size.width * 0.95,
                      child: Text(
                        _isCart ? _entireOptionForCart : _optionString,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Divider(
                      thickness: 0.5,
                      indent: 5,
                      endIndent: 5,
                    ),
                    SizedBox(
                      height: size.height * 0.02,
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
                                Row(
                                  children: [
                                    Text('결제 금액'),
                                    Text(
                                      '(상품 옵션 값 포함)',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 10),
                                    )
                                  ],
                                ),
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
                                    '${_formatPrice((_getOriginTotalPrice() - _getTotalDiscount()))} 원',
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
                      height: size.height * 0.02,
                    ),
                    Container(
                      width: size.width,
                      padding: EdgeInsets.all(size.width * 0.02),
                      color: Colors.grey[200],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '회사 정보',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                          SizedBox(
                            height: size.height * 0.005,
                          ),
                          Text(
                            '사업자 번호: 135-82-17822',
                            style: TextStyle(color: Colors.grey, fontSize: 9),
                          ),
                          Text('회사명: 안산강서고등학교 교육경제공동체 사회적협동조합',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 9)),
                          Text('대표자: 김은미',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 9)),
                          Text(
                              '위치: 경기도 안산시 단원구 와동 삼일로 367, 5층 공작관 다목적실 (안산강서고등학교)',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 9)),
                          Text('대표 전화: 031-485-9742',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 9)),
                          Text('대표 이메일: asgscoop@naver.com',
                              style: TextStyle(color: Colors.grey, fontSize: 9))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (ctx) {
                      Future.delayed(Duration(milliseconds: 500),
                          () => Navigator.pop(ctx));
                      return AlertDialog(
                        title: Padding(
                          padding: EdgeInsets.all(size.width * 0.015),
                          child: Text(
                            '동기화 및 재고 점검중',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        content: LinearProgressIndicator(),
                        shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.black, width: 1)),
                      );
                    });
                bool syncChk = false;
                if (_isCart) {
                  syncChk = await _checkSynchronousStockCountForCart();
                } else {
                  syncChk = await _checkSynchronousStockCountForProduct();
                }

                if (!syncChk) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text('구매 불가',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                            content: Text(
                                '실시간 재고 점검 결과 수량이 부족하여 해당 상품을 구매하실 수 없습니다!\n$_checkMessage',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold)),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('확인'))
                            ],
                          ));
                  return;
                }

                StoreMainPageState.currentNav = 0;
                _generatedOID =
                    DateTime.now().millisecondsSinceEpoch.toString();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaymentWebViewPage(
                              isCart: _isCart,
                              oID: _generatedOID,
                              additionalPrice: _isCart
                                  ? widget.additionalPrice
                                  : _additionalPrice,
                              user: widget.user,
                              productCount: widget.productCount,
                              selectList: widget.selectList,
                              optionList: widget.optionList,
                              cart: widget.cart,
                              direct: widget.direct,
                              receiveMethod:
                                  _receiveMethod == ReceiveMethod.DIRECT
                                      ? '0'
                                      : '1',
                              option: _isCart
                                  ? _entireOptionForCart
                                  : _optionString +
                                      (_requestOptionController.text.isEmpty
                                          ? ''
                                          : '\n' +
                                              _requestOptionController.text),
                              location: _receiveMethod == ReceiveMethod.DELIVERY
                                  ? _locationController.text
                                  : 'NULL',
                            )));
              },
              child: Container(
                alignment: Alignment.center,
                height: size.height * 0.045,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFF9EE1E5)),
                width: size.width,
                child: Text(
                  '${_formatPrice((_getOriginTotalPrice() - _getTotalDiscount()))} 원 결제 및 구매하기',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
