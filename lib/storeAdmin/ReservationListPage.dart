import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/category_data.dart';
import 'package:asgshighschool/data/status_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/storeAdmin/AdminDetailReservation.dart';
import 'package:asgshighschool/storeAdmin/FullListPage.dart';
import 'package:asgshighschool/storeAdmin/QrReservationPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ReservationListPage extends StatefulWidget {
  final User user;

  ReservationListPage({this.user});

  @override
  _ReservationListPageState createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  bool _isOrderTime = true;
  bool _isFinished = false;
  List _reservationListForTime = [];
  Map<int, Map> _productCountMap = Map();
  List<ProductCount> _pcList = [];

  /// 모든 예약 데이터를 가져오는 요청
  Future<bool> _getAllReservationData() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_getAllReservation.php';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List map1st = json.decode(result);
      _reservationListForTime.clear();
      _pcList.clear();
      _productCountMap = Map();
      for (int i = 0; i < map1st.length; ++i) {
        _reservationListForTime.add(json.decode(map1st[i]));
        for (int j = 0; j < _reservationListForTime[i]['detail'].length; ++j) {
          _reservationListForTime[i]['detail'][j] =
              json.decode(_reservationListForTime[i]['detail'][j]);
          _reservationListForTime[i]['detail'][j]['pInfo'] =
              json.decode(_reservationListForTime[i]['detail'][j]['pInfo']);
        }
      }
      _processProductCount();
      setState(() {
        _isFinished = true;
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _forceCancellationForReservation(String oid) async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_cancelReservation.php?${'oid=' + oid + '&pm=A'}';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      if (result == '1') return true;
      return false;
    } else {
      return false;
    }
  }

  Future<bool> _updateReservationCurrentCount(
      String pid, String quantity) async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_updateResvCurrent.php';
    final response = await http.post(url, body: <String, String>{
      'pid': pid,
      'count': quantity,
      'operation': 'sub'
    });

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      if (result != '1') return false;
      return true;
    } else {
      return false;
    }
  }

  Future<User> _getUserInformation(String uid) async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_getOneUser.php?uid=$uid';
    final response = await http.get(url);

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

  /// 특정 예약 데이터의 '주문 상태'를 변경하는 요청을 하는 작업
  /// @param : 예약 ID, 변경할 상태
  /// @return : 업데이트 성공 여부
  Future<bool> _updateOrderState(String oid, String state) async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_updateOrderState.php?${'oid=' + oid + '&state=' + state}';
    final response = await http.get(url);
    if (response.statusCode == 200) {
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

  /// 모든 예약 정보들을 담은 리스트들을 상품별로 보여주기 위해
  /// 상품별로 예약된 수와 관련 데이터를 함께 분류해서 새로운 리스트에 추가하는 작업
  void _processProductCount() {
    for (int i = 0; i < _reservationListForTime.length; ++i) {
      if (_productCountMap.containsKey(
              int.parse(_reservationListForTime[i]['detail'][0]['oPID'])) &&
          int.parse(_reservationListForTime[i]['orderState']) != 0 &&
          (int.parse(_reservationListForTime[i]['orderState']) >= 1 &&
              int.parse(_reservationListForTime[i]['orderState']) < 3 &&
              int.parse(_reservationListForTime[i]['resvState']) == 1)) {
        _productCountMap[
                int.parse(_reservationListForTime[i]['detail'][0]['oPID'])]
            ['count']++;
      } else if (int.parse(_reservationListForTime[i]['orderState']) != 0 &&
          (int.parse(_reservationListForTime[i]['orderState']) >= 1 &&
              int.parse(_reservationListForTime[i]['orderState']) < 3 &&
              int.parse(_reservationListForTime[i]['resvState']) == 1)) {
        _productCountMap[
            int.parse(_reservationListForTime[i]['detail'][0]['oPID'])] = {
          'count': 1
        };
        _productCountMap[
                    int.parse(_reservationListForTime[i]['detail'][0]['oPID'])]
                ['pName'] =
            _reservationListForTime[i]['detail'][0]['pInfo']['pName'];
        _productCountMap[
                    int.parse(_reservationListForTime[i]['detail'][0]['oPID'])]
                ['category'] =
            _reservationListForTime[i]['detail'][0]['pInfo']['category'];
        _productCountMap[
                    int.parse(_reservationListForTime[i]['detail'][0]['oPID'])]
                ['price'] =
            _reservationListForTime[i]['detail'][0]['pInfo']['price'];
        _productCountMap[
                    int.parse(_reservationListForTime[i]['detail'][0]['oPID'])]
                ['imgUrl'] =
            _reservationListForTime[i]['detail'][0]['pInfo']['imgUrl'];
      }
    }
    _pcList = _productCountMap.entries
        .map((e) => ProductCount(
            e.key,
            e.value['count'],
            e.value['pName'].toString(),
            int.parse(e.value['category']),
            int.parse(e.value['price']),
            e.value['imgUrl'].toString()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _getAllReservationData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '예약 목록 [관리자]',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        actions: [
          IconButton(
              iconSize: 32,
              onPressed: () async {
                var res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => QrReservationPage(
                              user: widget.user,
                            )));
                if (res) {
                  await _getAllReservationData();
                }
              },
              icon: Icon(
                Icons.qr_code_scanner,
                color: Colors.deepPurple,
              )),
          IconButton(
            onPressed: () async {
              var res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FullListPage(
                            user: widget.user,
                            isResv: true,
                          )));
              if (res) {
                await _getAllReservationData();
              }
            },
            icon: Icon(
              Icons.list_alt_rounded,
              color: Colors.black,
            ),
            iconSize: 32,
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                onPressed: () {
                  setState(() {
                    _isOrderTime = true;
                  });
                },
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        color: _isOrderTime ? Colors.blueAccent : Colors.grey),
                    Text(
                      ' 시간순 [결제 처리]',
                      style: TextStyle(
                          color:
                              _isOrderTime ? Colors.blueAccent : Colors.grey),
                    )
                  ],
                ),
              ),
              FlatButton(
                onPressed: () {
                  setState(() {
                    _isOrderTime = false;
                  });
                },
                child: Row(
                  children: [
                    Icon(Icons.shopping_bag,
                        color: _isOrderTime ? Colors.grey : Colors.blueAccent),
                    Text(' 상품별 [예약 처리]',
                        style: TextStyle(
                            color:
                                _isOrderTime ? Colors.grey : Colors.blueAccent))
                  ],
                ),
              ),
            ],
          ),
          Divider(
            thickness: 1,
          ),
          Padding(
            padding: EdgeInsets.all(size.width * 0.02),
            child: Text(
              "* '시간순'의 경우 모든 예약 정보들을 보여주며 결제 처리를 담당 ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(size.width * 0.02),
            child: Text(
                "* '상품별'의 경우 '결제 완료' 상태인 예약 정보들만 상품별로 보여주며 예약 처리를 담당 (※ 수령 완료된 예약 제외) \n* 푸시 메세지를 보냈다면 → '결제 완료'이면서 '수령 준비' 상태",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          Padding(
            padding: EdgeInsets.all(size.width * 0.02),
            child: Text(
                "* '시간순'의 경우 \n예약번호 클릭 시 '요청사항 및 상품 옵션' 출력\n시간 클릭 시 '예약한 날짜' 출력\n이름 클릭 시 '예약자 정보' 출력\n클릭 시 '결제 전환'\n길게 클릭 시 '예약 강제 삭제' 요청 ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          Divider(),
          _isFinished
              ? _isOrderTime
                  ? _reservationListForTime.length != 0
                      ? Expanded(
                          child: ListView.builder(
                          itemBuilder: (context, index) {
                            return _itemTileForTime(
                                _reservationListForTime[index], size, index);
                          },
                          itemCount: _reservationListForTime.length,
                        ))
                      : Expanded(
                          child: Center(
                              child: Text(
                          '예약된 내역이 없습니다!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )))
                  : _pcList.length != 0
                      ? Expanded(
                          child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: size.height * 0.02,
                                  crossAxisSpacing: size.width * 0.01),
                          itemCount: _pcList.length,
                          itemBuilder: (context, index) {
                            return _itemTileForProduct(_pcList[index], size);
                          },
                          padding: EdgeInsets.all(size.width * 0.02),
                        ))
                      : Expanded(
                          child: Center(
                          child: Text('예약 처리할 목록이 없습니다!',
                              style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _itemTileForTime(Map data, Size size, int index) {
    return FlatButton(
      onLongPress: () async {
        await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('[관리자] 예약 강제 취소'),
                  content: Text(
                    '정말 해당 예약 [${data['oID']}]을 강제로 취소(삭제)하시겠습니까?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  actions: [
                    FlatButton(
                        onPressed: () async {
                          var res = await _forceCancellationForReservation(
                              data['oID']);
                          if (res) {
                            var r = await _updateReservationCurrentCount(
                                data['detail'][0]['pInfo']['pid'],
                                data['detail'][0]['quantity']);
                            if (r) {
                              Fluttertoast.showToast(msg: '성공적으로 예약이 삭제되었습니다.');
                            } else {
                              Fluttertoast.showToast(
                                  msg: '[Error] 예약 수령 변경에 실패');
                            }
                            await _getAllReservationData();
                          } else {
                            Fluttertoast.showToast(msg: '예약 삭제에 실패하였습니다!');
                          }
                          Navigator.pop(context);
                        },
                        child: Text('예')),
                    FlatButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('아니오'))
                  ],
                ));
      },
      onPressed: () async {
        if (int.parse(data['orderState']) == 3 &&
            int.parse(data['resvState']) == 2) {
          showDialog(
              context: this.context,
              builder: (context) => AlertDialog(
                    title: Text('결제 전환 불가'),
                    content: Text(
                      '이미 상품을 수령한 예약 정보입니다. 결제 전환이 불가합니다.',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      FlatButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            '확인',
                            style: TextStyle(color: Colors.blue),
                          )),
                    ],
                  ));
          return;
        }
        if (int.parse(data['orderState']) == 0) {
          await showDialog(
              context: this.context,
              builder: (context) => AlertDialog(
                    title: Text('결제 전환'),
                    content: Row(
                      children: [
                        Text(
                          '[결제 완료] ',
                          style: TextStyle(
                              color: Colors.teal,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                        Text('상태로 전환하시겠습니까?', style: TextStyle(fontSize: 13))
                      ],
                    ),
                    actions: [
                      FlatButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () async {
                            await _updateOrderState(data['oID'], '1');
                            setState(() {
                              _reservationListForTime[index]['orderState'] =
                                  '1';
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            '예',
                            style: TextStyle(color: Colors.blue),
                          )),
                      FlatButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            '아니요',
                            style: TextStyle(color: Colors.red),
                          ))
                    ],
                  ));
          await _getAllReservationData();
        } else {
          await showDialog(
              context: this.context,
              builder: (context) => AlertDialog(
                    title: Text('결제 전환'),
                    content: Row(
                      children: [
                        Text(
                          '[미결제] ',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                        Text('상태로 전환하시겠습니까?', style: TextStyle(fontSize: 13))
                      ],
                    ),
                    actions: [
                      FlatButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () async {
                            await _updateOrderState(data['oID'], '0');
                            setState(() {
                              _reservationListForTime[index]['orderState'] =
                                  '0';
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            '예',
                            style: TextStyle(color: Colors.blue),
                          )),
                      FlatButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            '아니요',
                            style: TextStyle(color: Colors.red),
                          ))
                    ],
                  ));
          await _getAllReservationData();
        }
      },
      padding: EdgeInsets.all(0),
      child: Container(
        width: size.width,
        padding: EdgeInsets.all(size.width * 0.02),
        margin: EdgeInsets.all(size.width * 0.008),
        decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.grey),
            borderRadius: BorderRadius.circular(6)),
        child: Row(
          children: [
            Container(
              alignment: Alignment.center,
              width: size.width * 0.15,
              height: size.height * 0.07,
              padding: EdgeInsets.all(size.width * 0.01),
              child: Text(
                int.parse(data['orderState']) == 0 ? '미결제' : '결제 완료',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 10),
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 1, color: Colors.black),
                  color: int.parse(data['orderState']) == 0
                      ? Colors.redAccent
                      : Colors.teal),
            ),
            SizedBox(
              width: size.width * 0.015,
            ),
            Container(
              alignment: Alignment.center,
              width: size.width * 0.15,
              height: size.height * 0.07,
              padding: EdgeInsets.all(size.width * 0.01),
              child: Text(
                  int.parse(data['resvState']) == 1
                      ? '예약 중'
                      : (int.parse(data['orderState']) == 3 &&
                              int.parse(data['resvState']) == 2)
                          ? '수령 완료'
                          : '수령 준비',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 10)),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 1, color: Colors.black),
                  color: int.parse(data['resvState']) == 1
                      ? Colors.deepOrangeAccent
                      : (int.parse(data['orderState']) == 3 &&
                              int.parse(data['resvState']) == 2)
                          ? Colors.lightGreen
                          : Colors.blueAccent),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text(
                                      '요청사항 및 상품 옵션 내역',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    content: Padding(
                                      padding:
                                          EdgeInsets.all(size.width * 0.02),
                                      child: Text(
                                        data['options'] == null ||
                                                data['options'] == ''
                                            ? '없음'
                                            : data['options'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    actions: [
                                      FlatButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          '확인',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      )
                                    ],
                                  ));
                        },
                        child: Text(
                          '예약 번호 ${data['oID']}',
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    content: Text(
                                      data['oDate'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    actions: [
                                      FlatButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('확인'),
                                        padding: EdgeInsets.all(0),
                                      )
                                    ],
                                  ));
                        },
                        child: Text(
                          _formatDateTimeForToday(data['oDate']),
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              decoration: TextDecoration.underline),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.05,
                      ),
                      Text('예약자: ',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () async {
                          var user = await _getUserInformation(data['uid']);
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text('예약자 정보'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '아이디 : ${user.uid}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text('이름 : ${user.name}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            '신분 : ${Status.statusList[user.identity - 1]}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            '학번 : ${user.studentId == null || user.studentId == '' ? 'X' : user.studentId}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text('닉네임 : ${user.nickName}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))
                                      ],
                                    ),
                                    actions: [
                                      FlatButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('확인',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueAccent)),
                                        padding: EdgeInsets.all(0),
                                      )
                                    ],
                                  ));
                        },
                        child: Text('${data['name']}',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.008,
                  ),
                  Wrap(
                    children: [
                      Text(
                        ' [${Category.categoryIndexToStringMap[int.parse(data['detail'][0]['pInfo']['category'])]}]',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                      Text(' ${data['detail'][0]['pInfo']['pName']} ',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('  ${data['detail'][0]['quantity']}개',
                          style: TextStyle(fontSize: 12)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [],
                      ),
                      Text(
                        '  총 금액 ${_formatPrice(int.parse(data['totalPrice']))}원',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemTileForProduct(ProductCount data, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.015),
      width: size.width * 0.48,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(width: 0.5, color: Colors.black)),
      child: FlatButton(
        onPressed: () async {
          var res = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminDetailReservation(
                        user: widget.user,
                        productCount: data,
                        reservationList: _reservationListForTime,
                      )));
          if (res) {
            await _getAllReservationData();
          }
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                children: [
                  Text(
                    '[${Category.categoryIndexToStringMap[data.category]}] ',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  Text(
                    data.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 18,
                      ),
                      Text(
                        ' ${data.count}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11),
                      )
                    ],
                  ),
                ],
                spacing: size.width * 0.2,
              ),
            ),
            Divider(
              thickness: 1,
            ),
            Expanded(
              child: CachedNetworkImage(
                imageUrl: data.imgUrl,
                width: size.width * 0.35,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                progressIndicatorBuilder: (context, url, progress) => Center(
                  child: CircularProgressIndicator(
                    value: progress.progress,
                  ),
                ),
                errorWidget: (context, url, error) {
                  return Container(
                      alignment: Alignment.center,
                      color: Colors.grey[400],
                      child: Text('No Image'));
                  //placeholder 추가하기 -> 로고로
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ProductCount {
  int pid;
  int count;
  String name;
  int category;
  int price;
  String imgUrl;

  ProductCount(
      this.pid, this.count, this.name, this.category, this.price, this.imgUrl);
}
