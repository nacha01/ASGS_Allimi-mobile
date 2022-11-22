import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/category_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/store/DetailOrderStatePage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:cp949/cp949.dart' as cp949;

class OrderStatePage extends StatefulWidget {
  OrderStatePage({this.user});

  final User user;

  @override
  _OrderStatePageState createState() => _OrderStatePageState();
}

class _OrderStatePageState extends State<OrderStatePage> {
  List _orderMap = [];
  Map _cancelResponse;

  //final bool isCart;
  String _ediDate = '';
  static const _KEY =
      '0DVRz8vSDD5HvkWRwSxpjVhhx7OlXEViTciw5lBQAvSyYya9yf0K0Is+JbwiR9yYC96rEH2XIbfzeHXgqzSAFQ==';
  static const _MID = 'asgscoop1m';

  /// 나(uid)의 모든 주문한 내역(현황)들을 요청하는 작업
  Future<bool> _getOrderInfoRequest() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_getAllOrderInfo.php?uid=${widget.user.uid}';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      /// json decode 를 3번 해야한다. detail 까지 위해서는
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List map1st = json.decode(result);

      /// json 의 가장 바깥쪽 껍데기 파싱

      for (int i = 0; i < map1st.length; ++i) {
        map1st[i] = json.decode(map1st[i]);
        print('maplst $map1st[i]');

        /// 2차 내부 json 내용 파싱
        for (int j = 0; j < map1st[i]['detail'].length; ++j) {
          map1st[i]['detail'][j] = json.decode(map1st[i]['detail'][j]);
          map1st[i]['detail'][j]['pInfo'] =
              json.decode(map1st[i]['detail'][j]['pInfo']);

          /// 내부 detail 의 json 파싱
        }
      }
      setState(() {
        _orderMap = map1st;
      });
      return true;
    } else {
      return false;
    }
  }

  /// 주문의 date 필드를 사용자에게 직관적으로 보이게 하는 날짜 formatting 작업
  /// yyyy-mm-dd hh:mm:ss  ->  mm/dd hh:mm
  String _formatForItemDate(String date) {
    return date.substring(5, 16).replaceAll('-', '/');
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

  @override
  void initState() {
    super.initState();
    _getOrderInfoRequest();
  }

  /// 주문 상태 field 값에 따른 사용자에게 보여줄 mapping 색상을 반환
  /// @param : DB에 저장된 '주문 상태 필드'의 정수 값
  Color _getColorAccordingToOrderState(int state) {
    switch (state) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orangeAccent;
      case 2:
        return Colors.lightBlue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// 주문 상태 field 값에 따른 사용자에게 보여줄 mapping 문자열을 반환
  /// @param : DB에 저장된 '주문 상태 필드'의 정수 값
  String _getTextAccordingToOrderState(int state) {
    switch (state) {
      case 0:
        return '미결제 및 미수령';
      case 1:
        return '결제완료 및 미수령';
      case 2:
        return '주문 처리 중';
      case 3:
        return '결제완료 및 수령완료';
      case 4:
        return '결제취소 및 주문취소';
      default:
        return 'Error';
    }
  }

  /// 목록에서 어떤 상품을 구매했는지에 대한 간략 소개를 위한 텍스트 작업
  /// @param : 특정 주문 데이터에 대한 상품 목록 List
  /// format : 상품이 한 종류 시, xxx n개 | 두 종류 이상 시, xxx n개 외 y개
  String _extractDetailProductText(List detail) {
    if (detail.length == 1) {
      return detail[0]['pInfo']['pName'] + ' ' + detail[0]['quantity'] + '개';
    } else {
      return detail[0]['pInfo']['pName'] +
          ' ' +
          detail[0]['quantity'] +
          '개 외 ${detail.length - 1}개';
    }
  }

  String _getSignData(int cancelAmt) {
    return HEX.encode(sha256
        .convert(utf8.encode(_MID + cancelAmt.toString() + _ediDate + _KEY))
        .bytes);
  }

  Future<String> _cancelPaymentRequest(orderJson) async {
    String url = 'https://webapi.nicepay.co.kr/webapi/cancel_process.jsp';
    _ediDate = DateTime.now()
        .toString()
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .replaceAll(':', '')
        .split('.')[0];

    final response = await http.post(url, body: <String, String>{
      'TID': orderJson['tid'],
      'MID': _MID,
      'Moid': orderJson['oID'],
      'CancelAmt': int.parse(orderJson['totalPrice']).toString(),
      'CancelMsg': '결제자의 요청에 의한 취소',
      'PartialCancelCode': '0',
      'EdiDate': _ediDate,
      'SignData': _getSignData(int.parse(orderJson['totalPrice'])),
      'CharSet': 'euc-kr',
      'EdiType': 'JSON'
    });
    print(response.statusCode);
    if (response.statusCode == 200) {
      _cancelResponse = jsonDecode(cp949.decode(response.bodyBytes)); //???
      return _cancelResponse['ResultCode'];
    } else {
      return 'Error';
    }
  }

  Future<bool> _updateOrderState(int state, _oID) async {
    print(_oID);
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_updateOrderState.php?oid=$_oID&state=$state';
    // 'http://nacha01.dothome.co.kr/sin/arlimi_updateOrderState.php?oid=${widget.responseData['Moid']}&state=$state';
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

  Future<bool> _cancelOrderHandling(orderJson) async {
    var code = await _cancelPaymentRequest(orderJson);

    var _oid = orderJson['oID'];

    if (code == '2001') {
      var res = await _updateOrderState(4, _oid);
      if (!res) return false;
      var renewCountRes = await _updateProductCountRequest(
          int.parse(orderJson['detail'][0]['oPID']),
          int.parse(orderJson['detail'][0]['quantity']),
          '+');
      var sellCountRes = await _updateEachProductSellCountRequest(
          orderJson['detail'][0]['prodID'],
          orderJson['detail'][0]['productCount'],
          '-');
      var buyerCountRes = await _updateUserBuyCountRequest('-');
      if (!renewCountRes) return false;
      if (!sellCountRes) return false;
      if (!buyerCountRes) return false;

      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '내 주문 현황',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _orderMap.length == 0
              ? Expanded(
                  child: Center(
                  child: Text(
                    '주문 내역이 없습니다!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ))
              : Expanded(
                  child: ListView.builder(
                  itemBuilder: (context, index) {
                    return orderListItemLayout(_orderMap[index], size);
                  },
                  itemCount: _orderMap.length,
                ))
        ],
      ),
    );
  }

  Widget orderListItemLayout(Map orderJson, Size size) {
    return GestureDetector(
      onTap: () {
        // 상세 주문 현황 페이지로 이동
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailOrderStatePage(
                      order: orderJson,
                      user: widget.user,
                    )));
      },
      child: Container(
        padding: EdgeInsets.all(size.width * 0.02),
        width: size.width,
        decoration: BoxDecoration(
          border: Border.all(width: 0.5, color: Colors.black26),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: EdgeInsets.all(size.width * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '주문번호 : ${orderJson['oID']}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    '${_formatForItemDate(orderJson['oDate'])}',
                    style: TextStyle(color: Colors.black45),
                  )
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                children: [
                  Text(
                    '[${Category.categoryIndexToStringMap[int.parse(orderJson['detail'][0]['pInfo']['category'])]}] ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    ' ${_extractDetailProductText(orderJson['detail'])} ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(size.width * 0.01),
                  child: Text(
                    '${_getTextAccordingToOrderState(int.parse(orderJson['orderState']))}',
                    style: TextStyle(
                        color: _getColorAccordingToOrderState(
                            int.parse(orderJson['orderState']))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(size.width * 0.01),
                  child: Text(
                    '${_formatPrice(int.parse(orderJson['totalPrice']))}원',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                )
              ],
            ),
            int.parse(orderJson['orderState']) == 1
                ? TextButton(
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
                                        var res = await _cancelOrderHandling(
                                            orderJson);
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
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 12),
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 0.5, color: Colors.black),
                          color: Colors.red),
                      padding: EdgeInsets.all(size.width * 0.01),
                      width: size.width * 0.95,
                      height: size.height * 0.035,
                    ))
                : SizedBox()
          ],
        ),
      ),
    );
  }
}
