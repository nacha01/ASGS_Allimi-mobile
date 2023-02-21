import 'dart:convert';
import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/data/status.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:asgshighschool/util/NumberFormatter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../component/DefaultButtonComp.dart';
import '../../component/ThemeAppBar.dart';
import '../../data/order/order.dart';
import '../../util/DateFormatter.dart';
import '../../util/OrderUtil.dart';

class FullListPage extends StatefulWidget {
  final User? user;
  final bool? isResv;

  FullListPage({this.user, this.isResv});

  @override
  _FullListPageState createState() => _FullListPageState();
}

class _FullListPageState extends State<FullListPage> {
  List<Order> _orderList = [];
  List _reservationList = [];
  bool _isFinished = false;
  final _payState = ['미결제', '결제완료'];
  final _reservationState = ['예약 중', '수령준비', '수령완료'];
  final _orderState = [
    '미결제',
    '결제완료 및 미수령',
    '주문 처리 중',
    '결제완료 및 수령완료',
    '결제취소'
  ];

  Future<bool> _getReservationList() async {
    String url = '${ApiUtil.API_HOST}arlimi_getAllReservation.php';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      List map1st = json.decode(result);
      _reservationList.clear();
      for (int i = 0; i < map1st.length; ++i) {
        _reservationList.add(json.decode(map1st[i]));
        for (int j = 0; j < _reservationList[i]['detail'].length; ++j) {
          _reservationList[i]['detail'][j] =
              json.decode(_reservationList[i]['detail'][j]);
          _reservationList[i]['detail'][j]['pInfo'] =
              json.decode(_reservationList[i]['detail'][j]['pInfo']);
        }
      }
      setState(() {
        _isFinished = true;
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _getOrderList() async {
    String url = '${ApiUtil.API_HOST}arlimi_getAllOrder.php';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      _orderList = OrderUtil.serializeOrderJson(result, true);

      setState(() {
        _isFinished = true;
      });
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    if (widget.isResv!) {
      _getReservationList();
    } else {
      _getOrderList();
    }
    super.initState();
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
        appBar: ThemeAppBar(
            barTitle: '전체 ${widget.isResv! ? '예약 리스트' : '구매 리스트'}',
            leadingClick: () => Navigator.pop(context, true)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(size.width * 0.015),
              child: Text(
                '※ 각 항목 클릭 시 "요청사항" 및 "배달 장소" 출력',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.015),
              child: Text('※ 각 항목 길게 클릭 시 "예약 및 주문 결제 상태" 출력',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            Divider(
              thickness: 1,
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.01),
              child: Row(
                children: [
                  Text('학번', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('이름', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('상품들(세로 정렬)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('개수', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('결제 금액', style: TextStyle(fontWeight: FontWeight.bold))
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            ),
            _isFinished
                ? Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) => _itemEach(
                          size,
                          widget.isResv!
                              ? _reservationList[index]
                              : _orderList[index]),
                      itemCount: widget.isResv!
                          ? _reservationList.length
                          : _orderList.length,
                    ),
                  )
                : Expanded(
                    child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('불러오는 중..'),
                        CircularProgressIndicator(),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _itemEach(Size size, Order order) {
    return DefaultButtonComp(
      padding: 0,
      onPressed: () {
        showDialog(
            context: (context),
            builder: (context) => AlertDialog(
                  title: Text('세부 정보'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '* ${widget.isResv! ? '예약 일시: ' : '구매 일시: '} ${order.orderDate}',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      Text(
                          '* 요청 사항 및 상품 옵션:  ${(order.options == '') ? 'X' : order.options}'),
                      Divider(
                        thickness: 1,
                      ),
                    ],
                  ),
                  actions: [
                    DefaultButtonComp(
                        onPressed: () => Navigator.pop(context),
                        child: Text('확인'))
                  ],
                ));
      },
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('결제 및 준비 상태'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.isResv!
                        ? [
                            Text('결제 상태 : ${_payState[order.orderState]}'),
                            Text(
                                '예약 상태 : ${_reservationState[order.orderState - 1]}')
                          ]
                        : [
                            Text('주문 상태 : ' + _orderState[order.orderState]),
                          ],
                  ),
                  actions: [
                    DefaultButtonComp(
                        onPressed: () => Navigator.pop(context),
                        child: Text('확인'))
                  ],
                ));
      },
      child: Container(
        width: size.width,
        margin: EdgeInsets.all(size.width * 0.01),
        padding: EdgeInsets.all(size.width * 0.03),
        decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.black),
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '${order.user!.studentID ?? Status.statusList[order.user!.identity - 1]} |',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(
                  width: size.width * 0.01,
                ),
                Text('${order.user!.name} |',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 13)),
                SizedBox(
                  width: size.width * 0.01,
                ),
                widget.isResv!
                    ? Text(
                        '${order.detail[0].product.name}  ${order.detail[0].quantity}개 ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _multipleProductListForOrder(order),
                      ),
              ],
            ),
            SizedBox(height: size.height * 0.01),
            Row(
              children: [
                Text(
                    '총 금액 ${NumberFormatter.formatPrice(order.totalPrice)}원  | ',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                  ' ${DateFormatter.formatDateTimeCmp(order.orderDate)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      fontSize: 13),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _multipleProductListForOrder(Order order) {
    List<Widget> list = [];
    for (int i = 0; i < order.detail.length; ++i) {
      list.add(Text(
          '${order.detail[i].product.name}  ${order.detail[i].quantity}개,',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13)));
    }
    return list;
  }
}
