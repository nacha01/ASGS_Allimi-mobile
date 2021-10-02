import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// 우선 리스트만 받는 형식
/// 실시간 (주기적으로 갱신) 기능은 아직 구현 안함 추후에 추가 요망
class OrderListPage extends StatefulWidget {
  OrderListPage({this.user});
  final User user;
  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  List _orderList = [];
  List _noneList = [];
  bool _isChecked = true;
  final statusList = ['재학생', '학부모', '교사', '졸업생', '기타'];

  String _formatDateTimeForToday(String origin) {
    var today = DateTime.now();

    int dayDiff =
        int.parse(today.difference(DateTime.parse(origin)).inDays.toString());
    if (dayDiff < 1) {
      int hourDiff = int.parse(
          today.difference(DateTime.parse(origin)).inHours.toString());
      if (hourDiff < 1) {
        int minDiff = int.parse(
            today.difference(DateTime.parse(origin)).inMinutes.toString());
        return minDiff.toString() + '분 전';
      }
      return hourDiff.toString() + '시간 전';
    } else {
      return dayDiff.toString() + '일 전';
    }
  }

  Future<bool> _getAllOrderData() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getAllOrder.php';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List map1st = json.decode(result);

      for (int i = 0; i < map1st.length; ++i) {
        _orderList.add(json.decode(map1st[i]));
        for (int j = 0; j < _orderList[i]['detail'].length; ++j) {
          _orderList[i]['detail'][j] = json.decode(_orderList[i]['detail'][j]);
          _orderList[i]['detail'][j]['pInfo'] =
              json.decode(_orderList[i]['detail'][j]['pInfo']);
        }
        if (int.parse(_orderList[i]['orderState']) == 0 ||
            int.parse(_orderList[i]['orderState']) == 1) {
          _noneList.add(_orderList[i]);
        }
      }
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  Future<Map> _getAdminUserInfoByID(String uid) async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_getUserInfo.php?uid=' + uid;
    final response = await http.get(url);

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      return jsonDecode(result);
    } else {
      return null;
    }
  }

  @override
  void initState() {
    _getAllOrderData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '실시간 주문 목록',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: FlatButton(
                  child: Row(
                    children: [
                      Icon(
                        _isChecked ? Icons.check_box : Icons.check_box_outlined,
                        color: Colors.blue,
                      ),
                      Text('주문 처리 완료 안보기')
                    ],
                  ),
                  onPressed: () {
                    setState(() {
                      _isChecked = !_isChecked;
                    });
                  },
                ),
              )
            ],
          ),
          Divider(),
          _isChecked
              ? Expanded(
                  child: ListView.builder(
                  itemBuilder: (context, index) {
                    return _itemTile(
                        _noneList[index]['oID'],
                        _noneList[index]['uID'],
                        int.parse(_noneList[index]['receiveMethod']),
                        _noneList[index]['oDate'],
                        int.parse(_noneList[index]['orderState']),
                        _noneList[index],
                        size);
                  },
                  itemCount: _noneList.length,
                ))
              : Expanded(
                  child: ListView.builder(
                  itemBuilder: (context, index) {
                    return _itemTile(
                        _orderList[index]['oID'],
                        _orderList[index]['uID'],
                        int.parse(_orderList[index]['receiveMethod']),
                        _orderList[index]['oDate'],
                        int.parse(_orderList[index]['orderState']),
                        _orderList[index],
                        size);
                  },
                  itemCount: _orderList.length,
                ))
        ],
      ),
    );
  }

  Widget _itemTile(String oid, String uid, int recv, String date,
      int orderState, Map data, Size size) {
    return Container(
      width: size.width,
      margin: EdgeInsets.all(size.width * 0.01),
      padding: EdgeInsets.all(size.width * 0.01),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(width: 0.5, color: Colors.black)),
      child: FlatButton(
        onPressed: () {},
        child: Container(
          width: size.width * 0.9,
          padding: EdgeInsets.all(size.width * 0.005),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '주문번호 : $oid',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatDateTimeForToday(date),
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  )
                ],
              ),
              Text('주문자 ID : $uid',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('[${recv == 0 ? '직접 수령' : '배달'}]',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  orderState == 2
                      ? Row(
                          children: [
                            Container(
                              width: size.width * 0.18,
                              height: size.height * 0.026,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.lightBlueAccent),
                              child: Text(
                                '처리 중',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              alignment: Alignment.center,
                            ),
                            GestureDetector(
                              onTap: () async {
                                var user = await _getAdminUserInfoByID(
                                    data['chargerID']);
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          shape: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          title: Text('관리자 정보'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'ID : ${user['uid']}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                  '이름 : ${user['name']} [${statusList[int.parse(user['identity']) - 1]}]',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                  '학번 : ${user['student_id'] == '' ? 'X' : user['student_id']}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ],
                                          ),
                                          actions: [
                                            FlatButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text('닫기'))
                                          ],
                                        ));
                              },
                              child: Row(
                                children: [
                                  Text(
                                    '  담당자 [',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(data['chargerID'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue)),
                                  Text(']',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            )
                          ],
                        )
                      : SizedBox(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
