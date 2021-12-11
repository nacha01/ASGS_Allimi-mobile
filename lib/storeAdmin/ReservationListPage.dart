import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/storeAdmin/AdminDetailReservation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class ReservationListPage extends StatefulWidget {
  final User user;
  ReservationListPage({this.user});
  @override
  _ReservationListPageState createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  bool _isOrderTime = true;
  List _reservationListForTime = [];
  final _categoryReverseMap = {
    0: '음식류',
    1: '간식류',
    2: '음료류',
    3: '문구류',
    4: '핸드메이드'
  };
  Map<int, Map> _productCountMap = Map();
  List<ProductCount> _pcList = [];
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
      setState(() {});
      print(_reservationListForTime);
      return true;
    } else {
      return false;
    }
  }

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

  void _processProductCount() {
    for (int i = 0; i < _reservationListForTime.length; ++i) {
      if (_productCountMap.containsKey(
              int.parse(_reservationListForTime[i]['detail'][0]['oPID'])) &&
          int.parse(_reservationListForTime[i]['orderState']) != 0) {
        _productCountMap[
                int.parse(_reservationListForTime[i]['detail'][0]['oPID'])]
            ['count']++;
      } else if (int.parse(_reservationListForTime[i]['orderState']) != 0) {
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
    print(_productCountMap);
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
      ),
      body: Column(
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
          Divider(),
          _isOrderTime
              ? Expanded(
                  child: ListView.builder(
                  itemBuilder: (context, index) {
                    return _itemTileForTime(
                        _reservationListForTime[index], size, index);
                  },
                  itemCount: _reservationListForTime.length,
                ))
              : Expanded(
                  child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: size.height * 0.02,
                      crossAxisSpacing: size.width * 0.01),
                  itemCount: _pcList.length,
                  itemBuilder: (context, index) {
                    return _itemTileForProduct(_pcList[index], size);
                  },
                  padding: EdgeInsets.all(size.width * 0.02),
                ))
        ],
      ),
    );
  }

  Widget _itemTileForTime(Map data, Size size, int index) {
    return FlatButton(
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
                      Text(
                        '예약 번호 ${data['oID']}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey),
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
                              fontSize: 13,
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
                      Text('${data['name']}',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.008,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Text(
                            ' [${_categoryReverseMap[int.parse(data['detail'][0]['pInfo']['category'])]}]',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 13),
                          ),
                          Text(' ${data['detail'][0]['pInfo']['pName']} ',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('${data['detail'][0]['quantity']}개',
                              style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      SizedBox(
                        width: size.width * 0.01,
                      ),
                      Text(
                        '총 금액 ${_formatPrice(int.parse(data['detail'][0]['quantity']) * int.parse(data['detail'][0]['pInfo']['price']))}원',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  )
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
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminDetailReservation(
                        user: widget.user,
                        productCount: data,
                        reservationList: _reservationListForTime,
                      )));
        },
        padding: EdgeInsets.all(0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '[${_categoryReverseMap[data.category]}] ',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      data.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.grey,
                    ),
                    Text(
                      '  ${data.count}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    )
                  ],
                )
              ],
            ),
            Divider(
              thickness: 1,
            ),
            Expanded(
              child: CachedNetworkImage(
                imageUrl: data.imgUrl,
                fit: BoxFit.fill,
                width: size.width * 0.5,
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
