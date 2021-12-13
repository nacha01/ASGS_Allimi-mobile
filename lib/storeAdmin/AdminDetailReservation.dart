import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/LocalNotifyManager.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/storeAdmin/ReservationListPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AdminDetailReservation extends StatefulWidget {
  final List reservationList;
  final User user;
  final ProductCount productCount;
  AdminDetailReservation({this.reservationList, this.user, this.productCount});
  @override
  _AdminDetailReservationState createState() => _AdminDetailReservationState();
}

class _AdminDetailReservationState extends State<AdminDetailReservation> {
  List _productReservationList = [];
  int _newCount = 0;
  List<int> _indexList = [];
  bool _simulationOn = false;
  TextEditingController _countController = TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void _preProcessing() {
    for (int i = 0; i < widget.reservationList.length; ++i) {
      if (widget.productCount.pid ==
              int.parse(widget.reservationList[i]['detail'][0]['oPID']) &&
          int.parse(widget.reservationList[i]['orderState']) != 0) {
        _productReservationList.add(widget.reservationList[i]);
      }
    }
    _productReservationList = List.from(_productReservationList.reversed);
    _newCount = int.parse(
        _productReservationList[0]['detail'][0]['pInfo']['stockCount']);
    setState(() {});
  }

  Future<bool> _updateNewCount() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_updateProductCountForResv.php?pid=${widget.productCount.pid.toString() + '&count=' + _countController.text}';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _sendPushMessage(Map data) async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_sendPushForResv.php';
    print(data['token']);
    final response = await http.post(url, body: <String, String>{
      'token': data['token'],
      'title': '[두루두루 상품 입고]',
      'message': '예약하신 "${widget.productCount.name}" 상품이 입고되었습니다.\n 상품 수령바랍니다.'
    });

    if (response.statusCode == 200) {
      print(response.body);
      return true;
    } else {
      return false;
    }
  }

  /// 등록된 날짜와 오늘의 날짜를 비교해서 어느 정도 차이가 있는지에 대한 문자열을 반환하는 작업
  /// n일 전, n시간 전, n분 전
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
    _preProcessing();
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        localNotifyManager.showNotification(message['notification']["title"],
            message["notification"]["body"].toString(), message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        localNotifyManager.showNotification(message['notification']["title"],
            message["notification"]["body"].toString(), message);
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        localNotifyManager.showNotification(message['notification']["title"],
            message["notification"]["body"].toString(), message);
        print("onResume: $message");
      },
      onBackgroundMessage: (Map<String, dynamic> message) async {
        localNotifyManager.showNotification(message['notification']["title"],
            message["notification"]["body"].toString(), message);
        print("onBackground: $message");
      }
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));


    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    localNotifyManager.setOnNotificationClick(onNotificationClick);
    localNotifyManager.setOnNotificationReceive(onNotificationReceive);
  }

  onNotificationClick(String payload) {
    print(payload);
    Map message = json.decode(payload);
  }

  onNotificationReceive(ReceiveNotification notification) {
    print('notification Receive : ${notification.id}');
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
          backgroundColor: Color(0xFF9EE1E5),
          title: Text(
            '[${widget.productCount.name}] 예약 정보',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.pop(context, true),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
        ),
        body: Column(
          children: [
            SizedBox(
              height: size.height * 0.01,
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.01),
              child: Row(
                children: [
                  Text(
                    '*상품 정보',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.02),
              child: Row(
                children: [
                  Text(
                    '- 현재 재고',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    ' $_newCount개',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(
                    width: size.width * 0.03,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  '* 재고 수정하기',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: size.width * 0.01,
                ),
                Container(
                  width: size.width * 0.18,
                  child: TextField(
                    controller: _countController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.01,
                ),
                Container(
                  width: size.width * 0.23,
                  height: size.height * 0.04,
                  child: FlatButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text('재고 수정'),
                                content: Text('정말로 수정하시겠습니까?'),
                                actions: [
                                  FlatButton(
                                      onPressed: () async {
                                        await _updateNewCount();
                                        setState(() {
                                          _newCount =
                                              int.parse(_countController.text);
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text('예')),
                                  FlatButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('아니오'))
                                ],
                              ));
                    },
                    child: Text(
                      '수정하기',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(9),
                      color: Colors.green),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.02),
              child: Row(
                children: [
                  Text(
                    '- 가격',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    ' ${_formatPrice(int.parse(_productReservationList[0]['detail'][0]['pInfo']['price']))}원',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  )
                ],
              ),
            ),
            Divider(
              thickness: 1,
            ),
            Expanded(
                child: ListView.builder(
              itemBuilder: (context, index) {
                return _personDataTile(_productReservationList[index], size,
                    _indexList.contains(index));
              },
              itemCount: _productReservationList.length,
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: EdgeInsets.all(size.width * 0.01),
                  child: FlatButton(
                    onPressed: int.parse(_productReservationList[0]['detail'][0]
                                ['pInfo']['stockCount']) <
                            1
                        ? null
                        : () {
                            if (int.parse(_productReservationList[0]['detail']
                                    [0]['pInfo']['stockCount']) <
                                1) {
                              return;
                            }
                            setState(() {
                              _simulationOn = !_simulationOn;
                            });
                            if (_simulationOn) {
                              int tmp = _newCount;
                              _indexList.clear();

                            // 순서대로 처리하다가 개수 안맞으면 다음 사람으로 넘어가기
                              for (int i = 0;
                                  i < _productReservationList.length;
                                  ++i) {
                                if (tmp >=
                                    int.parse(_productReservationList[i]
                                        ['detail'][0]['quantity'])) {
                                  tmp -= int.parse(_productReservationList[i]
                                      ['detail'][0]['quantity']);
                                  _indexList.add(i);
                                }
                              }
                            } else {
                              _indexList.clear();
                            }
                          },
                    child: Text(
                      '시뮬레이션 ${_simulationOn ? 'off' : 'on'}',
                      style: TextStyle(
                          color: _simulationOn ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                  width: size.width * 0.35,
                  height: size.height * 0.05,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 1, color: Colors.black),
                      color: int.parse(_productReservationList[0]['detail'][0]
                                  ['pInfo']['stockCount']) <
                              1
                          ? Colors.grey
                          : Colors.deepOrange),
                ),
                Container(
                  margin: EdgeInsets.all(size.width * 0.01),
                  child: FlatButton(
                    onPressed: int.parse(_productReservationList[0]['detail'][0]
                                ['pInfo']['stockCount']) <
                            1
                        ? null
                        : () async {
                            if (int.parse(_productReservationList[0]['detail']
                                    [0]['pInfo']['stockCount']) <
                                1) {
                              print('아직 재고 없음');
                              return;
                            }
                            if (_simulationOn) {
                              for (int i = 0; i < _indexList.length; ++i) {
                                await _sendPushMessage(
                                    _productReservationList[_indexList[i]]);
                              }
                            }
                          },
                    child: Text(
                      '자동 예약 알림 전송하기',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                  width: size.width * 0.5,
                  height: size.height * 0.05,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 1, color: Colors.black),
                      color: int.parse(_productReservationList[0]['detail'][0]
                                  ['pInfo']['stockCount']) <
                              1
                          ? Colors.grey
                          : Colors.lightBlue),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _personDataTile(Map data, Size size, bool containAllocate) {
    return Container(
      width: size.width,
      padding: EdgeInsets.all(size.width * 0.015),
      margin: EdgeInsets.all(size.width * 0.008),
      decoration: BoxDecoration(
          border: Border.all(width: 1.5, color: Colors.black),
          borderRadius: BorderRadius.circular(6),
          color: containAllocate ? Colors.deepOrange[200] : Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            Icons.person,
            color: Colors.grey,
          ),
          Text(
            '예약 번호',
            style: TextStyle(fontSize: 10),
          ),
          Text('${data['oID']}',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          SizedBox(
            width: size.width * 0.01,
          ),
          Text('${data['name']}',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
          Text('${data['detail'][0]['quantity']}개',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          Text('${_formatDateTimeForToday(data['oDate'])}',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}
