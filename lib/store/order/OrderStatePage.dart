import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:asgshighschool/data/order/order.dart';
import 'package:asgshighschool/data/order/order_state.dart';
import 'package:asgshighschool/data/payment_cancel.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:asgshighschool/store/order/DetailOrderStatePage.dart';
import 'package:asgshighschool/util/DateFormatter.dart';
import 'package:asgshighschool/util/OrderUtil.dart';
import 'package:asgshighschool/util/PaymentUtil.dart';
import 'package:flutter/material.dart';
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
  bool _isFinished = false;
  PaymentCancelResponse? _cancelResponse;

  /// 나(uid)의 모든 주문한 내역(현황)들을 요청하는 작업
  Future<bool> _getOrderInfoRequest() async {
    String url =
        '${ApiUtil.API_HOST}arlimi_getAllOrderInfo.php?uid=${widget.user!.uid}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      setState(() {
        _orderList = OrderUtil.serializeOrderList(result, false);
        _isFinished = true;
      });
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: ThemeAppBar(barTitle: '내 주문 현황'),
      body: Column(
        children: [
          _isFinished
              ? _orderList.length == 0
                  ? Expanded(
                      child: Center(
                      child: Text(
                        '주문 내역이 없습니다!',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ))
                  : Expanded(
                      child: ListView.builder(
                      itemBuilder: (context, index) {
                        return orderListItemLayout(_orderList[index], size);
                      },
                      itemCount: _orderList.length,
                    ))
              : Expanded(
                  child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('불러오는 중..'),
                      CircularProgressIndicator(),
                    ],
                  ),
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
                    '${OrderState.orderStateList[order.orderState]}',
                    style: TextStyle(
                        color: OrderState.colorState[order.orderState]),
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
                                        _cancelResponse =
                                            await PaymentUtil.cancelPayment(
                                                order.tid,
                                                order.orderID,
                                                order.totalPrice,
                                                false);
                                        var res = await PaymentUtil
                                            .cancelOrderHandling(
                                                widget.user!.uid!,
                                                order,
                                                _cancelResponse!);
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
                                                        '${_cancelResponse!.resultMsg}',
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
                                                        '${_cancelResponse!.resultMsg} (code-${_cancelResponse!.resultCode})',
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
