import 'dart:async';
import 'dart:convert';
import 'package:asgshighschool/data/status.dart';
import 'package:asgshighschool/data/user.dart';
import '../../component/DefaultButtonComp.dart';
import '../../component/ThemeAppBar.dart';
import 'AdminDetailOrder.dart';
import 'package:asgshighschool/storeAdmin/FullListPage.dart';
import '../qr/QrSearchScannerPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:audioplayers/audio_cache.dart';

/// 우선 리스트만 받는 형식
/// 실시간 (주기적으로 갱신) 기능은 아직 구현 안함 추후에 추가 요망
class OrderListPage extends StatefulWidget {
  OrderListPage({this.user});

  final User? user;

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  // AudioCache player = new AudioCache();

  List _orderList = [];
  List _noneList = [];
  bool _isChecked = true;
  bool _isFinished = false;
  int jumun = 0;

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

  Future<User?> _getUserInformation(String? uid) async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_getOneUser.php?uid=$uid';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      return User.fromJson(json.decode(result));
    } else {
      return null;
    }
  }

  /// 모든 주문 내역을 요청하는 작업
  /// 이미 주문 처리가 된 것과 안된 것을 구분하여 각각의 List 에 저장
  Future<bool> _getAllOrderData() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getAllOrder.php';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List map1st = json.decode(result);
      _orderList.clear();
      _noneList.clear();
      for (int i = 0; i < map1st.length; ++i) {
        _orderList.add(json.decode(map1st[i]));

        for (int j = 0; j < _orderList[i]['detail'].length; ++j) {
          _orderList[i]['detail'][j] = json.decode(_orderList[i]['detail'][j]);
          _orderList[i]['detail'][j]['pInfo'] =
              json.decode(_orderList[i]['detail'][j]['pInfo']);
        }
        if (int.parse(_orderList[i]['orderState']) != 3 &&
            int.parse(_orderList[i]['orderState']) != 4) {
          _noneList.add(_orderList[i]);
        }
        if (int.parse(_orderList[i]['orderState']) == 1) {
          jumun = 1;
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

  /// 특정 uid 값을 통해 그 관리자의 사용자 정보를 가져오는 요청
  Future<Map?> _getAdminUserInfoByID(String uid) async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_getUserInfo.php?uid=' + uid;
    final response = await http.get(Uri.parse(url));

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
    // Timer.periodic(Duration(seconds: 5), (timer) {
    //   if (jumun ==1) {
    //     print(DateTime.now());
    //
    //     //AudioCache player = AudioCache(prefix: 'audio/');
    //     //player.play('explosion.mp3');
    //
    //     /*
    //
    //
    //     Future audioPlayer() async{
    //       await player.setVolume(75);
    //       await player.setSpeed(1);
    //       await player.setAsset('assets/audio/game.mp3');
    //       player.play();
    //     }
    //     */
    //
    //
    //   }
    // });
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
            icon: Icon(
              Icons.list_alt_rounded,
              color: Colors.black,
            ),
            iconSize: 30,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.qr_code_scanner),
        onPressed: () async {
          var res = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QrSearchScannerPage(
                        admin: widget.user,
                      )));
          if (res) await _getAllOrderData();
        },
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DefaultButtonComp(
                child: Row(
                  children: [
                    Icon(
                      _isChecked
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.blue,
                    ),
                    Text(
                      ' 주문 처리 완료 및 결제 취소 안보기',
                      style: TextStyle(fontSize: 11, color: Colors.black),
                    )
                  ],
                ),
                onPressed: () {
                  setState(() {
                    _isChecked = !_isChecked;
                  });
                },
              )
            ],
          ),
          _isFinished
              ? _isChecked
                  ? _noneList.length == 0
                      ? Expanded(
                          child: Center(
                          child: Text(
                            '업로드된 주문 내역이 없습니다!',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ))
                      : Expanded(
                          child: ListView.builder(
                          itemBuilder: (context, index) {
                            return _itemTile(
                                _noneList[index]['oID'],
                                _noneList[index]['uID'],
                                int.parse(_noneList[index]['receiveMethod']),
                                _noneList[index]['oDate'],
                                _noneList[index]['eDate'],
                                int.parse(_noneList[index]['orderState']),
                                _noneList[index],
                                size);
                          },
                          itemCount: _noneList.length,
                        ))
                  : _orderList.length == 0
                      ? Expanded(
                          child: Center(
                          child: Text(
                            '업로드 된 주문 내역이 없습니다!',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ))
                      : Expanded(
                          child: ListView.builder(
                          itemBuilder: (context, index) {
                            return _itemTile(
                                _orderList[index]['oID'],
                                _orderList[index]['uID'],
                                int.parse(_orderList[index]['receiveMethod']),
                                _orderList[index]['oDate'],
                                _orderList[index]['eDate'],
                                int.parse(_orderList[index]['orderState']),
                                _orderList[index],
                                size);
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

  Widget _itemTile(String? oid, String? uid, int recv, String oDate,
      String? eDate, int orderState, Map? data, Size size) {
    return Container(
      width: size.width,
      margin: EdgeInsets.all(size.width * 0.01),
      padding: EdgeInsets.all(size.width * 0.01),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(width: 0.5, color: Colors.black)),
      child: DefaultButtonComp(
        onPressed: () async {
          var res = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminDetailOrder(
                        user: widget.user,
                        data: data,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '주문번호 : $oid',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatDateTimeForToday(oDate),
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ],
              ),
              SizedBox(
                height: size.height * 0.005,
              ),
              GestureDetector(
                onTap: () async {
                  var user = await _getUserInformation(uid); //개인 정보 가져오기
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text('구매자 정보'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '아이디 : ${user!.uid}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('이름 : ${user.name}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                    '신분 : ${Status.statusList[user.identity - 1]}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                    '학번 : ${user.studentId == null || user.studentId == '' ? 'X' : user.studentId}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('닉네임 : ${user.nickName}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold))
                              ],
                            ),
                            actions: [
                              DefaultButtonComp(
                                onPressed: () => Navigator.pop(context),
                                child: Text('확인',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent)),
                              )
                            ],
                          ));
                },
                child: Text('주문자 ID : $uid',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: Colors.teal)),
              ),
              SizedBox(
                height: size.height * 0.005,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('주문 완료 일자',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  Text(
                    '${eDate == null || eDate == '0000-00-00 00:00:00' ? '-' : eDate}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('[${recv == 0 ? '직접 수령' : '배달'}]',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: recv == 0 ? Colors.lightBlue : Colors.green)),
                  orderState == 2
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(data!['chargerID'],
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
                      : orderState == 3
                          ? Container(
                              width: size.width * 0.22,
                              height: size.height * 0.026,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.5, color: Colors.black),
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.lightGreenAccent),
                              child: Text(
                                '처리 완료',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              alignment: Alignment.center,
                            )
                          : orderState == 4
                              ? Container(
                                  width: size.width * 0.22,
                                  height: size.height * 0.026,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0.5, color: Colors.black),
                                      borderRadius: BorderRadius.circular(6),
                                      color: Colors.grey[300]),
                                  child: Text(
                                    '결제 취소',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                  alignment: Alignment.center,
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
