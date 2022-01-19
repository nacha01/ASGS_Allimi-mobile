import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class StatisticsPage extends StatefulWidget {
  final User user;
  StatisticsPage({this.user});
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 1));
  String _startTime = '설정 없음';
  String _endTime = '설정 없음';
  int _currentTap = 1;
  String _resultExplainText = '';
  int _salesOption = 0; // 0 : 전체, 1 : 구매, 2 : 예약
  final _salesTextList = ['전체', '구매', '예약'];
  bool _isClicked = false;
  String _salesValue = '';
  List _orderList = [];
  List _reservationList = [];
  Map<int, Map> _productCountMap = Map();
  List<ProductCount> _countList = [];
  final _categoryReverseMap = {
    0: '음식류',
    1: '간식류',
    2: '음료류',
    3: '문구류',
    4: '핸드메이드'
  };

  Future<bool> _getAllOrderDataInProduct() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_statisticsProduct.php';
    final response = await http.post(url, body: <String, String>{
      'flag': '0',
      'start': _formatStartDateTime(),
      'end': _formatEndDateTime()
    });

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List map1st = jsonDecode(result);
      for (int i = 0; i < map1st.length; ++i) {
        map1st[i] = jsonDecode(map1st[i]);
      }

      setState(() {
        _orderList = map1st;
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _getAllReservationDataInProduct() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_statisticsProduct.php';
    final response = await http.post(url, body: <String, String>{
      'flag': '1',
      'start': _formatStartDateTime(),
      'end': _formatEndDateTime()
    });

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List map1st = jsonDecode(result);
      for (int i = 0; i < map1st.length; ++i) {
        map1st[i] = jsonDecode(map1st[i]);
      }
      setState(() {
        _reservationList = map1st;
      });
      return true;
    } else {
      return false;
    }
  }

  void _classifyProduct() {
    for (int i = 0; i < _orderList.length; ++i) {
      int pid = int.parse(_orderList[i]['pid']);
      if (!_productCountMap.containsKey(pid)) {
        _productCountMap[pid] = {
          'order': 0,
          'resv': 0,
          'pName': _orderList[i]['pName'],
          'category': _categoryReverseMap[int.parse(_orderList[i]['category'])]
        };
      }
      if (_productCountMap[pid].containsKey('order')) {
        _productCountMap[pid]['order'] = int.parse(_orderList[i]['quantity']);
      }
    }
    for (int i = 0; i < _reservationList.length; ++i) {
      int pid = int.parse(_reservationList[i]['pid']);
      if (!_productCountMap.containsKey(pid)) {
        _productCountMap[pid] = {
          'order': 0,
          'resv': 0,
          'pName': _reservationList[i]['pName'],
          'category':
              _categoryReverseMap[int.parse(_reservationList[i]['category'])]
        };
      }
      if (_productCountMap[pid].containsKey('resv')) {
        _productCountMap[pid]['resv'] =
            int.parse(_reservationList[i]['quantity']);
      }
    }
    print(_productCountMap);
    _countList = _productCountMap.entries
        .map((e) => ProductCount(e.key, e.value['pName'], e.value['category'],
            e.value['order'], e.value['resv']))
        .toList();
    _countList.sort((a, b) => a.pid.compareTo(b.pid));
  }

  Future<bool> _getTotalSales() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_statisticsSales.php';
    final response = await http.post(url, body: <String, String>{
      'start': _formatStartDateTime(),
      'end': _formatEndDateTime(),
      'option': _salesOption.toString()
    });
    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      print(result);
      if (result == '' || result == null) {
        _salesValue = 'NO RESULT';
      } else {
        _salesValue = result;
      }
      return true;
    } else {
      return false;
    }
  }

  String _formatStartDateTime() {
    return _startDate.toString().split(' ')[0] +
        ' ' +
        (_startTime == '설정 없음' ? '00:00' : _startTime);
  }

  String _formatEndDateTime() {
    return _endDate.toString().split(' ')[0] +
        ' ' +
        (_endTime == '설정 없음' ? '00:00' : _endTime);
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
    super.initState();
    print(_formatStartDateTime());
    print(_formatEndDateTime());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '통계 페이지',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                FlatButton(
                  onPressed: () {
                    setState(() {
                      _isClicked = false;
                      _currentTap = 1;
                    });
                  },
                  child: Container(
                    height: size.height * 0.05,
                    width: size.width * 0.3,
                    child: Text('매출 통계',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color:
                            _currentTap == 1 ? Colors.green[200] : Colors.white,
                        border: Border.all(width: 0.2, color: Colors.grey)),
                  ),
                  padding: EdgeInsets.all(0),
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      _isClicked = false;
                      _currentTap = 2;
                    });
                  },
                  child: Container(
                    child: Text('상품 통계',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    width: size.width * 0.3,
                    height: size.height * 0.05,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color:
                            _currentTap == 2 ? Colors.green[200] : Colors.white,
                        border: Border.all(width: 0.2, color: Colors.grey)),
                  ),
                  padding: EdgeInsets.all(0),
                ),
                Expanded(
                    child: FlatButton(
                  onPressed: () {
                    setState(() {
                      _isClicked = false;
                      _currentTap = 3;
                    });
                  },
                  child: Container(
                    child: Text(
                      '구매자 통계',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    height: size.height * 0.05,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color:
                            _currentTap == 3 ? Colors.green[200] : Colors.white,
                        border: Border.all(width: 0.2, color: Colors.grey)),
                  ),
                  padding: EdgeInsets.all(0),
                )),
              ],
            ),
            SizedBox(
              height: size.height * 0.015,
            ),
            Container(
              padding: EdgeInsets.all(size.width * 0.015),
              width: size.width,
              height: size.height * 0.07,
              margin: EdgeInsets.all(size.width * 0.005),
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.grey)),
              child: Row(
                children: [
                  Container(
                    height: size.height * 0.07,
                    alignment: Alignment.center,
                    child: Text(
                      '시작 날짜',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    width: size.width * 0.17,
                  ),
                  Container(
                    width: size.width * 0.45,
                    height: size.height * 0.07,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: size.width * 0.1,
                          height: size.height * 0.045,
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.black),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.blue[200]),
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              Future<DateTime> selectDate = showDatePicker(
                                helpText: '날짜를 선택하세요',
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2021),
                                lastDate: DateTime(2031),
                                builder: (BuildContext context, Widget child) {
                                  return Theme(
                                    data: ThemeData.light(), // 밝은테마
                                    child: child,
                                  );
                                },
                              );
                              selectDate.then((dateTime) {
                                setState(() {
                                  if (dateTime != null) {
                                    _startDate = dateTime;
                                  }
                                });
                              });
                            },
                            icon: Icon(Icons.calendar_today),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.03,
                        ),
                        Text('${_startDate.toString().split(' ')[0]}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Container(
                            width: size.width * 0.1,
                            height: size.height * 0.045,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.black),
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.blue[200]),
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                Future<TimeOfDay> selectTime = showTimePicker(
                                    helpText: '시간을 선택하세요',
                                    context: context,
                                    initialTime: TimeOfDay.now());

                                selectTime.then((value) {
                                  setState(() {
                                    if (value != null) {
                                      _startTime =
                                          '${value.hour}:${value.minute}';
                                    }
                                  });
                                });
                              },
                              icon: Icon(Icons.access_time),
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.03,
                          ),
                          Text('$_startTime',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(size.width * 0.015),
              width: size.width,
              height: size.height * 0.07,
              margin: EdgeInsets.all(size.width * 0.005),
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.grey)),
              child: Row(
                children: [
                  Container(
                    height: size.height * 0.07,
                    alignment: Alignment.center,
                    child: Text(
                      '종료 날짜',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    width: size.width * 0.17,
                  ),
                  Container(
                    width: size.width * 0.45,
                    height: size.height * 0.07,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: size.width * 0.1,
                          height: size.height * 0.045,
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.black),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.blue[200]),
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              Future<DateTime> selectDate = showDatePicker(
                                helpText: '날짜를 선택하세요',
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2021),
                                lastDate: DateTime(2031),
                                builder: (BuildContext context, Widget child) {
                                  return Theme(
                                    data: ThemeData.light(), // 밝은테마
                                    child: child,
                                  );
                                },
                              );
                              selectDate.then((dateTime) {
                                setState(() {
                                  if (dateTime != null) {
                                    var diff = dateTime.difference(_startDate);
                                    if (diff.inDays >= 0) {
                                      _endDate = dateTime;
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: '종료 날짜는 시작 날짜보다 같거나 작을 수 없습니다');
                                    }
                                  }
                                });
                              });
                            },
                            icon: Icon(Icons.calendar_today),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.03,
                        ),
                        Text('${_endDate.toString().split(' ')[0]}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Container(
                            width: size.width * 0.1,
                            height: size.height * 0.045,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.black),
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.blue[200]),
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                Future<TimeOfDay> selectTime = showTimePicker(
                                    helpText: '시간을 선택하세요',
                                    context: context,
                                    initialTime: TimeOfDay.now());

                                selectTime.then((value) {
                                  setState(() {
                                    if (value != null) {
                                      _endTime =
                                          '${value.hour}:${value.minute}';
                                    }
                                  });
                                });
                              },
                              icon: Icon(Icons.access_time),
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.03,
                          ),
                          Text('$_endTime',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.red,
              thickness: 1,
            ),
            // FlatButton(
            //     onPressed: () {
            //       _getAllOrderDataInProduct();
            //       _getTotalSales();
            //     },
            //     child: Text('버튼')),
            _setLayoutAccordingToTap(size)
          ],
        ),
      ),
    );
  }

  Widget _salesTapLayout(Size size) {
    return Column(
      children: [
        Divider(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FlatButton(
              onPressed: () {
                setState(() {
                  _salesOption = 0;
                });
              },
              child: Row(
                children: [
                  Icon(
                      _salesOption == 0
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.blue),
                  Text(
                    ' 전체',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  _salesOption = 1;
                });
              },
              child: Row(
                children: [
                  Icon(
                    _salesOption == 1
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: Colors.blue,
                  ),
                  Text(' 구매', style: TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  _salesOption = 2;
                });
              },
              child: Row(
                children: [
                  Icon(
                      _salesOption == 2
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.blue),
                  Text(' 예약', style: TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ],
        ),
        Divider(
          height: 0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FlatButton(
                onPressed: () async {
                  await _getTotalSales();
                  setState(() {
                    _isClicked = true;
                    _resultExplainText = _formatStartDateTime() +
                        " ~ " +
                        _formatEndDateTime() +
                        "\n[${_salesTextList[_salesOption]}] 매출 통계";
                  });
                },
                child: Container(
                  child: Text(
                    '조회하기',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  width: size.width * 0.3,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                      vertical: size.width * 0.02,
                      horizontal: size.height * 0.01),
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.black),
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6)),
                )),
          ],
        ),
        _isClicked
            ? Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(size.width * 0.03),
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.3, color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.orange[200]),
                    child: Text(
                      '$_resultExplainText',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Card(
                    child: Container(
                      width: size.width * 0.9,
                      height: size.height * 0.1,
                      alignment: Alignment.center,
                      child: Text(
                        '${_salesValue == 'NO RESULT' ? _salesValue : _formatPrice(int.parse(_salesValue)) + '원'}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  )
                ],
              )
            : SizedBox(),
      ],
    );
  }

  Widget _productTapLayout(Size size) {
    return Column(
      children: [
        FlatButton(
            onPressed: () async {
              await _getAllOrderDataInProduct();
              await _getAllReservationDataInProduct();
              _classifyProduct();
              setState(() {
                _isClicked = true;
                _resultExplainText = _formatStartDateTime() +
                    " ~ " +
                    _formatEndDateTime() +
                    "\n상품 통계";
              });
            },
            child: Text('조회하기')),
        _isClicked
            ? Column(
                children: [
                  Divider(
                    thickness: 1,
                  ),
                  Container(
                    padding: EdgeInsets.all(size.width * 0.03),
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.3, color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.orange[200]),
                    child: Text(
                      '$_resultExplainText',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                ],
              )
            : SizedBox(),
        Container(
          padding: EdgeInsets.all(size.width * 0.01),
          decoration:
              BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
          child: Row(
            children: [
              Container(
                child:
                    Text('상품번호', style: TextStyle(fontWeight: FontWeight.bold)),
                width: size.width * 0.18,
                alignment: Alignment.center,
              ),
              Container(
                child: Text('[카테고리] 상품이름',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                width: size.width * 0.4,
                alignment: Alignment.center,
              ),
              Container(
                child:
                    Text('구매수', style: TextStyle(fontWeight: FontWeight.bold)),
                width: size.width * 0.18,
                alignment: Alignment.center,
              ),
              Container(
                child:
                    Text('예약수', style: TextStyle(fontWeight: FontWeight.bold)),
                width: size.width * 0.18,
                alignment: Alignment.center,
              )
            ],
          ),
        ),
        Container(
          height: size.height * 0.4,
          child: _countList.length == 0
              ? Center(
                  child: Text(
                    'NO RESULT',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemBuilder: (context, index) {
                    return _productItemLayout(_countList[index], size);
                  },
                  itemCount: _countList.length,
                ),
        )
      ],
    );
  }

  Widget _buyerTapLayout(Size size) {
    return SizedBox();
  }

  Widget _setLayoutAccordingToTap(Size size) {
    switch (_currentTap) {
      case 1:
        return _salesTapLayout(size);
      case 2:
        return _productTapLayout(size);
      case 3:
        return _buyerTapLayout(size);
      default:
        return SizedBox();
    }
  }

  Widget _productItemLayout(ProductCount data, Size size) {
    return Container(
      width: size.width * 0.98,
      padding: EdgeInsets.all(size.width * 0.02),
      margin: EdgeInsets.all(size.width * 0.008),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(width: 0.5, color: Colors.grey)),
      child: Row(
        children: [
          Container(
            child: Text(
              '${data.pid}',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            width: size.width * 0.13,
          ),
          Container(
            width: size.width * 0.45,
            child: Wrap(
              children: [
                Text(
                  '[${data.category}] ',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '${data.name}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Container(
            width: size.width * 0.15,
            child: Column(
              children: [
                Text(
                  '구매',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${data.orderCount}', style: TextStyle(color: Colors.red))
              ],
            ),
          ),
          Container(
            width: size.width * 0.15,
            child: Column(
              children: [
                Text('예약', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${data.reservationCount}',
                    style: TextStyle(color: Colors.red))
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ProductCount {
  int pid;
  String name;
  String category;
  int orderCount;
  int reservationCount;

  ProductCount(this.pid, this.name, this.category, this.orderCount,
      this.reservationCount);
}
