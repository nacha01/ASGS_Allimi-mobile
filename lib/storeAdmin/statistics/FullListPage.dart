import 'dart:convert';
import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../component/DefaultButtonComp.dart';
import '../../component/ThemeAppBar.dart';
import '../../util/DateFormatter.dart';

class FullListPage extends StatefulWidget {
  final User? user;
  final bool? isResv;

  FullListPage({this.user, this.isResv});

  @override
  _FullListPageState createState() => _FullListPageState();
}

class _FullListPageState extends State<FullListPage> {
  List _orderList = [];
  List _reservationList = [];
  bool _isFinished = false;
  final _payState = ['미결제', '결제 완료'];
  final _reservationState = ['예약 중', '수령 준비', '수령 완료'];
  final _orderState = [
    '미결제',
    '결제 완료 및 미수령',
    '주문 처리 중',
    '결제완료 및 수령 완료',
    '결제 취소'
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
      List map1st = json.decode(result);
      _orderList.clear();
      for (int i = 0; i < map1st.length; ++i) {
        _orderList.add(json.decode(map1st[i]));
        for (int j = 0; j < _orderList[i]['detail'].length; ++j) {
          _orderList[i]['detail'][j] = json.decode(_orderList[i]['detail'][j]);
          _orderList[i]['detail'][j]['pInfo'] =
              json.decode(_orderList[i]['detail'][j]['pInfo']);
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
              padding: EdgeInsets.all(size.width * 0.02),
              child: Text(
                '※ 각 항목 클릭 시 "요청사항" 및 "배달 장소" 출력',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.02),
              child: Text('※ 각 항목 길게 클릭 시 "예약 및 주문 결제 상태" 출력',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            Divider(
              thickness: 1,
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.02),
              child: Row(
                children: [
                  Text('학번',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('이름',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('상품들(세로 정렬)',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('개수',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('결제 금액',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15))
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            ),
            _isFinished
                ? Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) => _itemEach(
                          size,
                          index,
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

  Widget _itemEach(Size size, int index, Map data) {
    return DefaultButtonComp(
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
                        '* ${widget.isResv! ? '예약 일시: ' : '구매 일시: '} ${data['oDate']}',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      Text(
                          '* 요청 사항 및 상품 옵션:  ${(data['options'] == '' || data['options'] == null) ? 'X' : data['options']}'),
                      Divider(
                        thickness: 1,
                      ),
                      Text(
                          '* 수령(배달) 장소:  ${(data['location'] == null || data['location'] == '') ? 'X' : data['location']}')
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
                            Text(
                                '결제 상태 : ${_payState[int.parse(data['orderState'])]}'),
                            Text(
                                '예약 상태 : ${_reservationState[int.parse(data['resvState']) - 1]}')
                          ]
                        : [
                            Text('주문 상태 : ' +
                                _orderState[int.parse(data['orderState'])]),
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
        margin: EdgeInsets.all(size.width * 0.015),
        padding: EdgeInsets.all(size.width * 0.03),
        decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.black),
            borderRadius: BorderRadius.circular(8)),
        child: Wrap(
          children: [
            Text(
              '${data['student_id'] == '' || data['student_id'] == null ? '[재학생 X]' : data['student_id']} |',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: size.width * 0.01,
            ),
            Text('${data['name']} |',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.green)),
            SizedBox(
              width: size.width * 0.01,
            ),
            widget.isResv!
                ? Text(
                    '${data['detail'][0]['pInfo']['pName']}  ${data['detail'][0]['quantity']}개 ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _multipleProductListForOrder(data),
                  ),
            SizedBox(
              width: size.width * 0.01,
            ),
            Text('| 총 ${data['totalPrice']}원 | ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              ' ${DateFormatter.formatDateTimeCmp(data['oDate'])}',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.redAccent),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _multipleProductListForOrder(Map data) {
    List<Widget> list = [];
    for (int i = 0; i < data['detail'].length; ++i) {
      list.add(Text(
          '${data['detail'][i]['pInfo']['pName']}  ${data['detail'][i]['quantity']}개,',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)));
    }
    return list;
  }
}
