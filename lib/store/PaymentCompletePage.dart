import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/category.dart';
import '../data/provider/exist_cart.dart';
import 'package:asgshighschool/data/product.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:cp949/cp949.dart' as cp949;
import 'package:provider/provider.dart';

class PaymentCompletePage extends StatefulWidget {
  PaymentCompletePage(
      {this.totalPrice,
      this.responseData,
      this.direct,
      this.cart,
      this.productCount,
      this.user,
      this.optionList,
      this.selectList,
      this.isCart,
      this.location,
      this.option,
      this.receiveMethod});

  final int totalPrice;
  final Map responseData;
  final bool isCart;
  final Product direct; // 바로 결제 시 그 단일 상품 하나
  final List<Map> cart; // 장바구니에서 결제시 장바구니 리스트 Map 데이터
  final int productCount; // 바로 결제시 상품의 개수
  final User user;
  final List optionList;
  final List selectList;
  final String receiveMethod;
  final String option;
  final String location;

  @override
  _PaymentCompletePageState createState() => _PaymentCompletePageState();
}

class _PaymentCompletePageState extends State<PaymentCompletePage> {
  bool _isCreditSuccess = true;
  String _resultMessage = '';
  bool _isFinished = false;
  Map _cancelResponse;
  String _resultCode = '';
  static const _KEY =
      '0DVRz8vSDD5HvkWRwSxpjVhhx7OlXEViTciw5lBQAvSyYya9yf0K0Is+JbwiR9yYC96rEH2XIbfzeHXgqzSAFQ==';
  static const _MID = 'asgscoop1m';
  String _ediDate = '';
  bool _corporationInfoClicked = false;

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

  /// 주문을 등록하는 요청
  Future<bool> _addOrderRequest() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_addOrder.php';
    final response = await http.post(url, body: <String, String>{
      'oid': widget.responseData['Moid'],
      'uid': widget.user.uid,
      'oDate': DateTime.now().toString(),
      'price': int.parse(widget.responseData['Amt']).toString(),
      'oState': '1', // '결제완료' 상태
      'recvMethod': widget.receiveMethod,
      'pay': '0', // 신용카드
      'option': widget.option.toString().trim(),
      'location': widget.location,
      'TID': widget.responseData['TID'],
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// orderDetail 테이블에 oid인 값에 대하여 어떤 상품인지 등록하는 http 요청
  Future<bool> _addOrderDetailRequest(int pid, int quantity) async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_addOrderDetail.php';
    final response = await http.post(url, body: <String, String>{
      'oid': widget.responseData['Moid'],
      'pid': pid.toString(),
      'quantity': quantity.toString()
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// 최종적으로 주문을 등록하는 과정
  Future<bool> _registerOrderRequest() async {
    var orderRes = await _addOrderRequest();

    if (!orderRes) return false;

    if (widget.isCart) {
      for (int i = 0; i < widget.cart.length; ++i) {
        var cartRes = await _addOrderDetailRequest(
            int.parse(widget.cart[i]['cPID']),
            int.parse(widget.cart[i]['quantity']));

        var deleteRes =
            await _deleteCartRequest(int.parse(widget.cart[i]['cID']));

        var renewCountRes = await _updateProductCountRequest(
            int.parse(widget.cart[i]['cPID']),
            int.parse(widget.cart[i]['quantity']),
            '-');

        var sellCountRes = await _updateEachProductSellCountRequest(
            int.parse(widget.cart[i]['cPID']),
            int.parse(widget.cart[i]['quantity']),
            '+');

        var buyerCountRes = await _updateUserBuyCountRequest('+');

        if (!cartRes) return false;
        if (!deleteRes) return false;
        if (!renewCountRes) return false;
        if (!sellCountRes) return false;
        if (!buyerCountRes) return false;
      }
    } else {
      var detRes = await _addOrderDetailRequest(
          widget.direct.prodID, widget.productCount);
      var renewCountRes = await _updateProductCountRequest(
          widget.direct.prodID, widget.productCount, '-');

      var sellCountRes = await _updateEachProductSellCountRequest(
          widget.direct.prodID, widget.productCount, '+');

      var buyerCountRes = await _updateUserBuyCountRequest('+');

      if (!detRes) return false;
      if (!renewCountRes) return false;
      if (!sellCountRes) return false;
      if (!buyerCountRes) return false;
    }
    return true;
  }

  Future<bool> _cancelOrderHandling() async {
    var code = await _cancelPaymentRequest();
    if (code == '2001') {
      var res = await _updateOrderState(4);
      if (!res) return false;
      if (widget.isCart) {
        for (int i = 0; i < widget.cart.length; ++i) {
          var renewCountRes = await _updateProductCountRequest(
              int.parse(widget.cart[i]['cPID']),
              int.parse(widget.cart[i]['quantity']),
              '+');
          // 재고 수정

          var sellCountRes = await _updateEachProductSellCountRequest(
              int.parse(widget.cart[i]['cPID']),
              int.parse(widget.cart[i]['quantity']),
              '-');
          // 누적 판매수 수정

          var buyerCountRes = await _updateUserBuyCountRequest('-');
          // 누적 구매수 수정

          if (!renewCountRes) return false;
          if (!sellCountRes) return false;
          if (!buyerCountRes) return false;
        }
      } else {
        var renewCountRes = await _updateProductCountRequest(
            widget.direct.prodID, widget.productCount, '+');

        var sellCountRes = await _updateEachProductSellCountRequest(
            widget.direct.prodID, widget.productCount, '-');

        var buyerCountRes = await _updateUserBuyCountRequest('-');

        if (!renewCountRes) return false;
        if (!sellCountRes) return false;
        if (!buyerCountRes) return false;
      }
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _updateOrderState(int state) async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_updateOrderState.php?oid=${widget.responseData['Moid']}&state=$state';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// 장바구니에서 결제를 시도한다면 장바구니에 있는 데이터들을 지우는 요청
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

  /// 각 상품의 수량을 [quantity]만큼 [operator] 연산자로 수정하는 요청
  Future<bool> _updateProductCountRequest(
      int pid, int quantity, String operator) async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_updateProductCount.php';
    final response = await http.post(url, body: <String, String>{
      'pid': pid.toString(),
      'quantity': quantity.toString(),
      'oper': operator
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// 각 상품의 누적 판매수를 반영하는 요청
  Future<bool> _updateEachProductSellCountRequest(
      int pid, int quantity, String operator) async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_updateProductSellCount.php';
    final response =
        await http.get(url + '?pid=$pid&quantity=$quantity&oper=$operator');
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// 이 주문을 요청한 사용자의 누적 구매수를 [operator]대로 연산하는 요청
  Future<bool> _updateUserBuyCountRequest(String operator) async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_updateUserBuyCount.php?uid=${widget.user.uid}&oper=$operator';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> _cancelPaymentRequest() async {
    String url = 'https://webapi.nicepay.co.kr/webapi/cancel_process.jsp';
    _ediDate = DateTime.now()
        .toString()
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .replaceAll(':', '')
        .split('.')[0];
    final response = await http.post(url, body: <String, String>{
      'TID': widget.responseData['TID'],
      'MID': _MID,
      'Moid': widget.responseData['Moid'],
      'CancelAmt': int.parse(widget.responseData['Amt']).toString(),
      'CancelMsg': '결제자의 요청에 의한 취소',
      'PartialCancelCode': '0',
      'EdiDate': _ediDate,
      'SignData': _getSignData(int.parse(widget.responseData['Amt'])),
      'CharSet': 'euc-kr',
      'EdiType': 'JSON'
    });

    if (response.statusCode == 200) {
      _cancelResponse = jsonDecode(cp949.decode(response.bodyBytes)); //???
      return _cancelResponse['ResultCode'];
    } else {
      return 'Error';
    }
  }

  @override
  void initState() {
    _isCreditSuccess =
        widget.responseData['ResultCode'] == '3001' ? true : false;
    _resultMessage = widget.responseData['ResultMsg'];
    _resultCode = widget.responseData['ResultCode'];
    super.initState();
    _processAfterPaying();
  }

  String _getSignData(int cancelAmt) {
    return HEX.encode(sha256
        .convert(utf8.encode(_MID + cancelAmt.toString() + _ediDate + _KEY))
        .bytes);
  }

  void _processAfterPaying() async {
    if (_isCreditSuccess) {
      var res = await _registerOrderRequest();
      // Provider.of<ExistCart>(context).setExistCart(false);
      if (!res) {
        _resultCode = 'O001'; // 커스텀 코드로 결제는 되었으나 DB에 주문 등록이 실패했다는 의미
      }
    }
    setState(() {
      _isFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            color: Colors.black,
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          backgroundColor: Color(0xFF9EE1E5),
          title: Text(
            '결제 결과 페이지',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          centerTitle: true,
        ),
        body: _isFinished
            ? Column(
                children: [
                  Expanded(
                      child: _layoutAccordingToResultCode(_resultCode, size)),
                  _corpInfoLayout(size)
                ],
              )
            : Container(
                height: size.height,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '주문 등록 중입니다..',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    CircularProgressIndicator()
                  ],
                ),
              ),
      ),
    );
  }

  Widget _layoutAccordingToResultCode(String resultCode, Size size) {
    switch (resultCode) {
      case '3001': // 카드 결제 성공
        return SingleChildScrollView(
          child: Column(
            children: [
              Icon(
                Icons.check,
                color: Colors.lightGreenAccent,
                size: 85,
              ),
              Text(
                '결제가 성공적으로 완료되었습니다!',
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              Divider(
                thickness: 0.5,
                indent: 3,
                endIndent: 3,
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Text(
                '주문번호 ${widget.responseData['Moid']}',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.lightBlue),
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              Column(
                children: _getProductList(size),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              widget.option.isNotEmpty //여기는 뭐지? ???
                  ? Container(
                      width: size.width * 0.8,
                      padding: EdgeInsets.all(size.width * 0.02),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          Text(
                            '요청 사항 및 상품 옵션',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Colors.black54),
                          ),
                          Text(
                            widget.option,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                height: size.height * 0.01,
              ),
              Card(
                child: Container(
                  alignment: Alignment.center,
                  width: size.width * 0.6,
                  padding: EdgeInsets.all(size.width * 0.02),
                  child: Text(
                    '결제 금액  ${_formatPrice(int.parse(widget.responseData['Amt']))}원',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              Text(
                '주문 현황 및 상세 정보는 ',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Text(
                '마이페이지 → 내 주문 현황',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 15),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Text(' 에서도 확인할 수 있습니다.', style: TextStyle(fontSize: 12)),
              SizedBox(
                height: size.height * 0.02,
              ),
              Divider(
                thickness: 0.5,
                indent: 3,
                endIndent: 3,
              ),
              Text(
                '주문 인증용 QR 코드',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              SizedBox(
                height: size.height * 0.015,
              ),
              Text(
                'QR 코드는 "내 주문 현황"에서 확인 가능합니다.',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.blueGrey),
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              Text(
                '* QR 코드나 주문 번호는 본인이 주문을 했다는 것을 인증할 수 있는 수단으로써 상품을 수령하기 위해서는 반드시 필요한 것입니다.',
                style: TextStyle(fontSize: 10, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Divider(
                thickness: 2,
                indent: 3,
                endIndent: 3,
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text('결제 취소 요청',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              content: Text('정말로 결제를 취소하시겠습니까?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      var res = await _cancelOrderHandling();
                                      if (res) {
                                        showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  title: Text('결제취소 성공',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.green,
                                                          fontSize: 16)),
                                                  content: Text(
                                                      '${_cancelResponse['ResultMsg']}',
                                                      //여기가 취소 성공이라는 메세지인가?
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14)),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              this.context);
                                                        },
                                                        child: Text('확인'))
                                                  ],
                                                ));
                                      } else {
                                        showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  title: Text(
                                                    '결제취소 실패',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.red,
                                                        fontSize: 16),
                                                  ),
                                                  content: Text(
                                                      '${_cancelResponse['ResultMsg']} (code-${_cancelResponse['ResultCode']}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14)),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text('확인'))
                                                  ],
                                                ));
                                      }
                                    },
                                    child: Text('예')),
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('아니오'))
                              ],
                            ));
                  },
                  child: Container(
                    child: Text(
                      '결제 취소하기',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 0.5, color: Colors.black),
                        color: Colors.red),
                    padding: EdgeInsets.all(size.width * 0.01),
                    width: size.width * 0.6,
                    height: size.height * 0.04,
                  )),
              Text(
                '※ 결제 취소는 이 페이지에서만 가능합니다. 신중하게 판단해주세요.',
                style: TextStyle(fontSize: 10, color: Colors.red),
              )
            ],
          ),
        );
      case '2001': // 망취소
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cancel_outlined,
                color: Colors.deepOrange,
                size: 85,
              ),
              Text(
                '결제가 취소되었습니다.',
                style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              Padding(
                padding: EdgeInsets.all(size.width * 0.03),
                child: Text(
                  '네트워크 오류로 인해 결제 정상승인이 이루어지지 않아 결제가 자동으로 취소되었습니다.\n(Connection time-out)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                '* 결제를 원하시면 다시 시도 바랍니다.',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              SizedBox(
                height: size.height * 0.08,
              )
            ],
          ),
        );
      case 'O001':
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.help_outline,
                size: 85,
                color: Colors.grey,
              ),
              Text(
                '결제에 성공했으나 주문 등록에는 실패하였습니다. ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              Text(
                '결제는 정상승인 되었으나 결제 정보를 저장하는데 실패하였습니다.',
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(size.width * 0.03),
                child: Text(
                  '* 결제 취소 후 결제를 원하시면 다시 시도바랍니다.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.grey),
                ),
              ),
              TextButton(
                  onPressed: () async {
                    var res = await _cancelPaymentRequest();
                    if (res == '2001') {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text('결제취소 성공',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontSize: 16)),
                                content: Text('${_cancelResponse['ResultMsg']}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(this.context);
                                      },
                                      child: Text('확인'))
                                ],
                              ));
                    } else {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text(
                                  '결제취소 실패',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      fontSize: 16),
                                ),
                                content: Text(
                                    '${_cancelResponse['ResultMsg']} (code-${_cancelResponse['ResultCode']}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('확인'))
                                ],
                              ));
                    }
                  },
                  child: Text('결제 취소하기'))
            ],
          ),
        );
      default: // 이외에 결제 실패 오류
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: Colors.red,
                size: 85,
              ),
              Text(
                '결제에 실패했습니다!',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 20),
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              Text(
                ' | 실패 사유 |\n$_resultMessage (code-${widget.responseData['ResultCode']})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(size.width * 0.03),
                child: Text(
                  '* 결제를 다시 시도하거나 실패 사유에 대한 문제를 해결하고 시도해주세요.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Colors.grey),
                ),
              ),
              SizedBox(
                height: size.height * 0.08,
              )
            ],
          ),
        );
    }
  }

  Widget _productLayout(String name, int quantity, int category, Size size) {
    return Container(
      width: size.width * 0.8,
      alignment: Alignment.center,
      padding: EdgeInsets.all(size.width * 0.02),
      margin: EdgeInsets.all(size.width * 0.008),
      decoration: BoxDecoration(
          border: Border.all(width: 0.8, color: Colors.black),
          borderRadius: BorderRadius.circular(10)),
      child: Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          spacing: size.width * 0.01,
          children: [
            Text(
              '[${Category.categoryIndexToStringMap[category]}]',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              ' $name $quantity개 ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getProductList(Size size) {
    List<Widget> list = [];
    if (widget.isCart) {
      for (int i = 0; i < widget.cart.length; ++i) {
        list.add(_productLayout(
            widget.cart[i]['prodName'],
            int.parse(widget.cart[i]['quantity']),
            int.parse(widget.cart[i]['category']),
            size));
      }
    } else {
      list.add(_productLayout(widget.direct.prodName, widget.productCount,
          widget.direct.category, size));
    }
    return list;
  }

  Widget _corpInfoLayout(Size size) {
    return Container(
      width: size.width,
      padding: EdgeInsets.all(
          _corporationInfoClicked ? size.width * 0.02 : size.width * 0.01),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _corporationInfoClicked = !_corporationInfoClicked;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: size.width * 0.04,
                ),
                Text(
                  '회사 정보',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
                Icon(_corporationInfoClicked
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down)
              ],
            ),
          ),
          _corporationInfoClicked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.height * 0.005,
                    ),
                    Text(
                      '사업자 번호: 135-82-17822',
                      style: TextStyle(color: Colors.grey, fontSize: 9),
                    ),
                    Text('회사명: 안산강서고등학교 교육경제공동체 사회적협동조합',
                        style: TextStyle(color: Colors.grey, fontSize: 9)),
                    Text('대표자: 김은미',
                        style: TextStyle(color: Colors.grey, fontSize: 9)),
                    Text('위치: 경기도 안산시 단원구 와동 삼일로 367, 5층 공작관 다목적실 (안산강서고등학교)',
                        style: TextStyle(color: Colors.grey, fontSize: 9)),
                    Text('대표 전화: 031-485-9742',
                        style: TextStyle(color: Colors.grey, fontSize: 9)),
                    Text('대표 이메일: asgscoop@naver.com',
                        style: TextStyle(color: Colors.grey, fontSize: 9))
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
