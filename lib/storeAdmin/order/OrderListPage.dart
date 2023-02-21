import 'dart:async';
import 'dart:convert';
import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/data/order/order.dart';
import 'package:asgshighschool/data/status.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:asgshighschool/util/DateFormatter.dart';
import 'package:asgshighschool/util/OrderUtil.dart';
import '../../component/DefaultButtonComp.dart';
import '../../component/ThemeAppBar.dart';
import 'AdminDetailOrder.dart';
import 'package:asgshighschool/storeAdmin/statistics/FullListPage.dart';
import '../qr/QrSearchScannerPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// 우선 리스트만 받는 형식
/// 실시간 (주기적으로 갱신) 기능은 아직 구현 안함 추후에 추가 요망
class OrderListPage extends StatefulWidget {
  OrderListPage({this.user});

  final User? user;

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  List<Order> _orderList = [];
  List<Order> _noneList = [];
  bool _isChecked = true;
  bool _isFinished = false;

  /// 모든 주문 내역을 요청하는 작업
  /// 이미 주문 처리가 된 것과 안된 것을 구분하여 각각의 List 에 저장
  Future<bool> _getAllOrderData() async {
    String url = '${ApiUtil.API_HOST}arlimi_getAllOrder.php';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);

      _noneList.clear();
      _orderList = OrderUtil.serializeOrderJson(result, true);
      for (var order in _orderList) {
        if (order.orderState != 3 && order.orderState != 4)
          _noneList.add(order);
      }
      setState(() {
        _isFinished = true;
      });
      return true;
    } else {
      return false;
    }
  }

  /// 특정 uid 값을 통해 그 관리자의 사용자 정보를 가져오는 요청
  Future<Map?> _getAdminUserInfoByID(String uid) async {
    String url = '${ApiUtil.API_HOST}arlimi_getUserInfo.php?uid=' + uid;
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
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
      appBar: ThemeAppBar(
        barTitle: '주문 목록',
        actions: [
          IconButton(
              onPressed: () async {
                var res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FullListPage(
                              user: widget.user,
                              isResv: false,
                            )));
                if (res) {
                  await _getAllOrderData();
                }
              },
              icon: Icon(Icons.list_alt_rounded, color: Colors.black),
              iconSize: 30)
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.qr_code_scanner),
          onPressed: () async {
            var res = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        QrSearchScannerPage(admin: widget.user)));
            if (res) await _getAllOrderData();
          }),
      body: RefreshIndicator(
        onRefresh: _getAllOrderData,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DefaultButtonComp(
                    child: Row(children: [
                      Icon(
                          _isChecked
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: Colors.blue),
                      Text(' 주문 처리 완료 및 결제 취소 안보기',
                          style: TextStyle(fontSize: 11, color: Colors.black))
                    ]),
                    onPressed: () {
                      setState(() {
                        _isChecked = !_isChecked;
                      });
                    })
              ],
            ),
            _isFinished
                ? _isChecked
                    ? _noneList.length == 0
                        ? Expanded(
                            child: Center(
                            child: Text('업로드 된 주문 내역이 없습니다!',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ))
                        : Expanded(
                            child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return _itemTile(_noneList[index], size);
                                },
                                itemCount: _noneList.length))
                    : _orderList.length == 0
                        ? Expanded(
                            child: Center(
                            child: Text('업로드 된 주문 내역이 없습니다!',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ))
                        : Expanded(
                            child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return _itemTile(_orderList[index], size);
                                },
                                itemCount: _orderList.length))
                : Expanded(
                    child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('불러오는 중..'), CircularProgressIndicator()],
                    ),
                  ))
          ],
        ),
      ),
    );
  }

  Widget _itemTile(Order order, Size size) {
    return Container(
      width: size.width,
      margin: EdgeInsets.all(size.width * 0.01),
      padding: EdgeInsets.all(size.width * 0.01),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(width: 0.5, color: Colors.black)),
      child: DefaultButtonComp(
        onLongPress: () {},
        onPressed: () async {
          var res = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminDetailOrder(
                        user: widget.user,
                        order: order,
                      )));
          if (res) {
            await _getAllOrderData();
          }
        },
        child: Container(
          width: size.width * 0.9,
          padding: EdgeInsets.all(size.width * 0.005),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  '주문번호 : ${order.orderID}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  DateFormatter.formatDateTimeCmp(order.orderDate),
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ]),
              SizedBox(height: size.height * 0.003),
              Text(
                  '주문자: [${Status.statusList[order.user!.identity - 1]}] ${order.user!.studentID ?? ''} ${order.user!.name}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.teal)),
              SizedBox(height: size.height * 0.01),
              Row(
                children: [
                  Text('주문 완료 일자: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(width: size.width * 0.02),
                  Text(
                      '${order.editDate == '0000-00-00 00:00:00' ? '-' : order.editDate}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
                ],
              ),
              SizedBox(height: size.height * 0.005),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('[${order.receiveMethod == 0 ? '직접 수령' : '배달'}]',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: order.receiveMethod == 0
                              ? Colors.lightBlue
                              : Colors.green)),
                  order.orderState == 2
                      ? Row(
                          children: [
                            Container(
                                width: size.width * 0.25,
                                height: size.height * 0.026,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.lightBlueAccent),
                                child: Text(
                                  '처리 담당 중',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                                alignment: Alignment.center),
                            GestureDetector(
                              onTap: () async {
                                var user = await _getAdminUserInfoByID(
                                    order.chargerID!);
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          shape: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          title: Text('관리자 정보'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'ID : ${user!['uid']}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                  '이름 : ${user['name']} [${Status.statusList[int.parse(user['identity']) - 1]}]',
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
                                            DefaultButtonComp(
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
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                  Text(order.chargerID!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontSize: 13)),
                                  Text(']',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            )
                          ],
                        )
                      : order.orderState == 3
                          ? _adminStateBar(
                              '처리 완료', Colors.lightGreenAccent, size)
                          : order.orderState == 4
                              ? _adminStateBar('결제 취소', Colors.grey[300]!, size)
                              : SizedBox(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminStateBar(String title, Color color, Size size) {
    return Container(
        width: size.width * 0.21,
        height: size.height * 0.026,
        decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.black),
            borderRadius: BorderRadius.circular(6),
            color: color),
        child: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        alignment: Alignment.center);
  }
}
