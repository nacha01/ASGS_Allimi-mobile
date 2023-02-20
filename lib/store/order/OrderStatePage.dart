import 'dart:convert';
import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:asgshighschool/data/order/order.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:asgshighschool/store/order/DetailOrderStatePage.dart';
import 'package:asgshighschool/util/DateFormatter.dart';
import 'package:asgshighschool/util/PaymentUtil.dart';
import 'package:flutter/material.dart';
import 'package:cp949_dart/cp949_dart.dart' as cp949;
import 'package:http/http.dart' as http;

import '../../component/DefaultButtonComp.dart';
import '../../data/order/order_detail.dart';
import '../../util/NumberFormatter.dart';

class OrderStatePage extends StatefulWidget {
  OrderStatePage({this.user});

  final User? user;

  @override
  _OrderStatePageState createState() => _OrderStatePageState();
}

class _OrderStatePageState extends State<OrderStatePage> {
  List<Order> _orderList = [];
  Map? _cancelResponse;
  String _ediDate = '';

  /// 나(uid)의 모든 주문한 내역(현황)들을 요청하는 작업
  Future<bool> _getOrderInfoRequest() async {
    String url =
        '${ApiUtil.API_HOST}arlimi_getAllOrderInfo.php?uid=${widget.user!.uid}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      List outerJson = jsonDecode(result);

      for (int i = 0; i < outerJson.length; ++i) {
        var current = jsonDecode(outerJson[i]);

        List<OrderDetail> details = [];

        for (int j = 0; j < current['detail'].length; ++j) {
          current['detail'][j] = jsonDecode(current['detail'][j]);
          current['detail'][j]['product'] =
              jsonDecode(current['detail'][j]['product']);
          details.add(OrderDetail.fromJson(current['detail'][j]));
        }
        _orderList.add(Order.fromJson(current, details));
      }
      setState(() {});
      return true;
    } else {
      return false;
    }
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
  String? _extractDetailProductText(List<OrderDetail> details) {
    if (details.length == 1) {
      return details[0].product.name +
          ' ' +
          details[0].quantity.toString() +
          '개';
    } else {
      return details[0].product.name +
          ' ' +
          details[0].quantity.toString() +
          '개 외 ${details.length - 1}개';
    }
  }

  Future<String?> _cancelPaymentRequest(Order order) async {
    _ediDate = PaymentUtil.getEdiDate();

    final response = await http
        .post(Uri.parse(PaymentUtil.CANCEL_API_URL), body: <String, String?>{
      'TID': order.tid,
      'MID': PaymentUtil.MID,
      'Moid': order.orderID,
      'CancelAmt': order.totalPrice.toString(),
      'CancelMsg': '결제자의 요청에 의한 취소',
      'PartialCancelCode': '0',
      'EdiDate': _ediDate,
      'SignData': PaymentUtil.encryptCancel(order.totalPrice, _ediDate),
      'CharSet': 'euc-kr',
      'EdiType': 'JSON'
    });
    if (response.statusCode == 200) {
      _cancelResponse = jsonDecode(cp949.decode(response.bodyBytes));
      return _cancelResponse!['ResultCode'];
    } else {
      return 'Error';
    }
  }

  Future<bool> _updateOrderState(int state, _oID) async {
    String url =
        '${ApiUtil.API_HOST}arlimi_updateOrderState.php?oid=$_oID&state=$state';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// 각 상품의 수량을 [quantity]만큼 [operator] 연산자로 수정하는 요청
  Future<bool> _updateProductCountRequest(
      int pid, int quantity, String operator) async {
    String url = '${ApiUtil.API_HOST}arlimi_updateProductCount.php';
    final response = await http.post(Uri.parse(url), body: <String, String>{
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
      int? pid, int? quantity, String operator) async {
    String url = '${ApiUtil.API_HOST}arlimi_updateProductSellCount.php';
    final response = await http
        .get(Uri.parse(url + '?pid=$pid&quantity=$quantity&oper=$operator'));
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// 이 주문을 요청한 사용자의 누적 구매수를 [operator]대로 연산하는 요청
  Future<bool> _updateUserBuyCountRequest(String operator) async {
    String url =
        '${ApiUtil.API_HOST}arlimi_updateUserBuyCount.php?uid=${widget.user!.uid}&oper=$operator';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _cancelOrderHandling(Order order) async {
    var code = await _cancelPaymentRequest(order);

    var _oid = order.orderID;

    if (code == '2001') {
      var res = await _updateOrderState(4, _oid);
      if (!res) return false;

      for (var detail in order.detail) {
        var result = await _updateProductCountRequest(
            detail.product.productID, detail.quantity, '+');
        if (!result) return false;
      }

      for (var detail in order.detail) {
        var result = await _updateEachProductSellCountRequest(
            detail.product.productID, detail.quantity, '-');
        if (!result) return false;
      }

      var buyerCountRes = await _updateUserBuyCountRequest('-');
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
      appBar: ThemeAppBar(barTitle: '내 주문 현황'),
      body: Column(
        children: [
          _orderList.length == 0
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
                    return orderListItemLayout(_orderList[index], size);
                  },
                  itemCount: _orderList.length,
                ))
        ],
      ),
    );
  }

  Widget orderListItemLayout(Order order, Size size) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailOrderStatePage(
                      order: order,
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
                    '주문번호 : ${order.orderID}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    '${DateFormatter.formatShortDate(order.orderDate)}',
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
                    '[${order.detail[0].product.category}] ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    ' ${_extractDetailProductText(order.detail)} ',
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
                    '${_getTextAccordingToOrderState(order.orderState)}',
                    style: TextStyle(
                        color:
                            _getColorAccordingToOrderState(order.orderState)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(size.width * 0.01),
                  child: Text(
                    '${NumberFormatter.formatPrice(order.totalPrice)}원',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                )
              ],
            ),
            order.orderState == 1
                ? DefaultButtonComp(
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
                                  DefaultButtonComp(
                                      onPressed: () async {
                                        var res =
                                            await _cancelOrderHandling(order);
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
                                                        '${_cancelResponse!['ResultMsg']}',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14)),
                                                    actions: [
                                                      DefaultButtonComp(
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
                                                        '${_cancelResponse!['ResultMsg']} (code-${_cancelResponse!['ResultCode']})',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14)),
                                                    actions: [
                                                      DefaultButtonComp(
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
                                  DefaultButtonComp(
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
