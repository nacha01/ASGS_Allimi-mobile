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
  String _currentOrderQuery = '';
  String _currentReservationQuery = '';
  String _salesValue = '';
  String _resultExplainText = '';
  String _selectedDate = '일';
  int _currentTap = 1;
  int _salesOption = 0; // 0 : 전체, 1 : 구매, 2 : 예약
  bool _isClicked = false;
  bool _noPayedOrder = true;
  bool _noPayedResv = true;
  bool _firstSelectionInOrder = true;
  bool _secondSelectionInOrder = false;
  bool _thirdSelectionInOrder = false;
  bool _firstSelectionInResv = true;
  bool _secondSelectionInResv = false;
  bool _thirdSelectionInResv = false;
  final List _salesTextList = ['전체', '구매', '예약'];
  final List _monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  List _orderList = [];
  List _reservationList = [];
  List<ProductCount> _countList = [];
  List<List> _salesListForDate = [];
  Map<int, Map> _productCountMap = Map();
  final Map<int, String> _categoryReverseMap = {
    0: '음식류',
    1: '간식류',
    2: '음료류',
    3: '문구류',
    4: '핸드메이드'
  };
  final _dateUnitList = ['일', '주', '월'];
  TextEditingController _dateController = TextEditingController();

  Future<bool> _getAllOrderDataInProduct() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_statisticsProduct.php';
    _currentOrderQuery = _getOrderQueryFromSetting();
    final response = await http.post(url, body: <String, String>{
      'flag': '0',
      'start': _formatStartDateTime(),
      'end': _formatEndDateTime(),
      'query': _currentOrderQuery
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

  DateTime _getStartDate() {
    var today = DateTime.now();
    var startPointDate =
        DateTime(today.year, today.month - int.parse(_dateController.text), 1);
    return startPointDate;
  }

  /// 2^3 = 8가지 경우
  String _getReservationQueryFromSetting() {
    // 미결제 시
    if (!_noPayedResv) {
      return 'orderState = 0 AND resv_state = 1';
    }

    // 단일 체크 시
    if (_firstSelectionInResv &&
        !_secondSelectionInResv &&
        !_thirdSelectionInResv) {
      return 'orderState = 1 AND resv_state = 1';
    } else if (!_firstSelectionInResv &&
        _secondSelectionInResv &&
        !_thirdSelectionInResv) {
      return 'orderState = 2 AND resv_state = 2';
    } else if (!_firstSelectionInResv &&
        !_secondSelectionInResv &&
        _thirdSelectionInResv) {
      return 'orderState = 3 AND resv_state = 2';
    }

    // 다중 체크 시
    if (_firstSelectionInResv &&
        _secondSelectionInResv &&
        !_thirdSelectionInResv) {
      return '(orderState >= 1 AND orderState <= 2) AND (resv_state >= 1 AND resv_state <= 2)';
    } else if (!_firstSelectionInResv &&
        _secondSelectionInResv &&
        _thirdSelectionInResv) {
      return '(orderState >= 2 AND orderState <= 2) AND resv_state = 2';
    } else if (_firstSelectionInResv &&
        !_secondSelectionInResv &&
        _thirdSelectionInResv) {
      return '(orderState = 1 AND resv_state = 1) OR (orderState = 3 AND resv_state = 2)';
    } else if (_firstSelectionInResv &&
        _secondSelectionInResv &&
        _thirdSelectionInResv) {
      return 'orderState >= 1 AND resv_state >= 1';
    }
    return 'orderState = 1 AND resv_state = 1';
  }

  /// 2Π3 = 2^3 = 8가지 경우
  String _getOrderQueryFromSetting() {
    // 미결제 시
    if (!_noPayedOrder) {
      return 'orderState = 0 AND resv_state = 0';
    }
    // 단일 체크 시
    if (_firstSelectionInOrder &&
        !_secondSelectionInOrder &&
        !_thirdSelectionInOrder) {
      return 'orderState = 1 AND resv_state = 0';
    } else if (!_firstSelectionInOrder &&
        _secondSelectionInOrder &&
        !_thirdSelectionInOrder) {
      return 'orderState = 2 AND resv_state = 0';
    } else if (!_firstSelectionInOrder &&
        !_secondSelectionInOrder &&
        _thirdSelectionInOrder) {
      return 'orderState = 3 AND resv_state = 0';
    }

    // 다중 체크 시
    if (_firstSelectionInOrder &&
        _secondSelectionInOrder &&
        !_thirdSelectionInOrder) {
      return '(orderState >= 1 AND orderState <= 2) AND resv_state = 0';
    } else if (!_firstSelectionInOrder &&
        _secondSelectionInOrder &&
        _thirdSelectionInOrder) {
      return 'orderState >= 2 AND resv_state = 0';
    } else if (_firstSelectionInOrder &&
        !_secondSelectionInOrder &&
        _thirdSelectionInOrder) {
      return '(orderState = 1 AND resv_state = 0) OR (orderState = 3 AND resv_state = 0)';
    } else if (_firstSelectionInOrder &&
        _secondSelectionInOrder &&
        _thirdSelectionInOrder) {
      return 'orderState >= 1 AND resv_state = 0';
    }
    return 'orderState => 1 AND resv_state = 0';
  }

  Future<bool> _getAllReservationDataInProduct() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_statisticsProduct.php';
    _currentReservationQuery = _getReservationQueryFromSetting();
    final response = await http.post(url, body: <String, String>{
      'flag': '1',
      'start': _formatStartDateTime(),
      'end': _formatEndDateTime(),
      'query': _currentReservationQuery
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

  int _totalBuyCount() {
    int sum = 0;
    for (int i = 0; i < _countList.length; ++i) {
      sum += _countList[i].orderCount;
    }
    return sum;
  }

  int _totalResvCount() {
    int sum = 0;
    for (int i = 0; i < _countList.length; ++i) {
      sum += _countList[i].reservationCount;
    }
    return sum;
  }

  void _classifyProduct() {
    _productCountMap = Map();
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
      // print(result);
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
    // print(_getStartDate().toString());
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
                    height: size.height * 0.04,
                    width: size.width * 0.3,
                    child: Text('매출 통계',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    width: size.width * 0.3,
                    height: size.height * 0.04,
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    height: size.height * 0.04,
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
              height: size.height * 0.005,
            ),
            Container(
              padding: EdgeInsets.all(size.width * 0.015),
              width: size.width,
              height: size.height * 0.06,
              margin: EdgeInsets.all(size.width * 0.005),
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.grey)),
              child: Row(
                children: [
                  Container(
                    height: size.height * 0.06,
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
                    height: size.height * 0.06,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: size.width * 0.1,
                          height: size.height * 0.043,
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
                            height: size.height * 0.043,
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
              height: size.height * 0.06,
              margin: EdgeInsets.all(size.width * 0.005),
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.grey)),
              child: Row(
                children: [
                  Container(
                    height: size.height * 0.06,
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
                    height: size.height * 0.06,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: size.width * 0.1,
                          height: size.height * 0.043,
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
              height: 10,
            ),
            _setLayoutAccordingToTap(size)
          ],
        ),
      ),
    );
  }

  Widget _salesTapLayout(Size size) {
    return Column(
      children: [
        Row(
          children: [
            Text('시간 간격'),
            Text('최근'),
            Container(
              width: size.width * 0.2,
              child: TextField(
                controller: _dateController,
              ),
            ),
            Text('개월 동안'),
            DropdownButton(
              value: _selectedDate,
              items: _dateUnitList.map((e) {
                return DropdownMenuItem(
                  child: Text(e),
                  value: e,
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDate = value;
                });
              },
            ),
            Text('간 통계')
          ],
        ),
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
                  var start = _getStartDate();
                  switch (_selectedDate) {
                    case '일':
                      var current = start;
                      while (true) {
                        if (DateTime.now().compareTo(current) < 0) {
                          break;
                        }
                        print('현재 : ${current.toString()}');
                        current = current.add(Duration(days: 1));
                      }
                      break;
                    case '주':
                      var current = start;
                      while (true) {
                        print('현재 시작 : ${current.toString()}');
                        if (DateTime.now()
                                .difference(current.add(Duration(days: 6)))
                                .inDays <
                            0) {
                          print(
                              '현재 종료 : ${current.add(Duration(days: DateTime.now().difference(current).inDays))}');
                          break;
                        }
                        current = current.add(Duration(days: 6));
                        print('현재 종료 : ${current.toString()}');
                        current = current.add(Duration(days: 1));
                      }
                      break;
                    case '월':
                      var current = start;
                      while (true) {
                        print('현재 시작 : ${current.toString()}');
                        if (current.month == DateTime.now().month &&
                            current.year == DateTime.now().year) {
                          print(
                              '차이 : ${DateTime.now().difference(current).inDays}일');
                          print(
                              '현재 종료 : ${current.add(Duration(days: DateTime.now().difference(current).inDays))}');
                          break;
                        }
                        var next = DateTime(
                            current.year, current.month + 1, current.day);

                        print('차이 : ${next.difference(current).inDays}일');
                        current = next.subtract(Duration(days: 1));
                        print('현재 종료 : ${current.toString()}');
                        print('-----------------------------');
                        current = current.add(Duration(days: 1));
                      }
                      break;
                  }
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
                        '${_salesValue == 'NO RESULT' ? '0원' : _formatPrice(int.parse(_salesValue)) + '원'}',
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
        Container(
          height: size.height * 0.06,
          decoration:
              BoxDecoration(border: Border.all(width: 0.3, color: Colors.grey)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                ' 구매 설정',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _noPayedOrder = false;
                    _firstSelectionInOrder = false;
                    _secondSelectionInOrder = false;
                    _thirdSelectionInOrder = false;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      _noPayedOrder
                          ? Icons.check_box_outline_blank
                          : Icons.check_box,
                      size: 18,
                      color: _noPayedOrder ? Colors.grey : Colors.blue,
                    ),
                    Text(' 미결제',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            color: _noPayedOrder ? Colors.grey : Colors.black))
                  ],
                ),
              ),
              Container(
                width: size.width * 0.005,
                height: size.height * 0.03,
                color: Colors.black,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _noPayedOrder = true;
                    _firstSelectionInOrder = !_firstSelectionInOrder;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _firstSelectionInOrder
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 18,
                      color: _noPayedOrder ? Colors.blue : Colors.grey,
                    ),
                    Text(' 결제 완료',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            color: _noPayedOrder ? Colors.black : Colors.grey))
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _noPayedOrder = true;
                    _secondSelectionInOrder = !_secondSelectionInOrder;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _secondSelectionInOrder
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 18,
                      color: _noPayedOrder ? Colors.blue : Colors.grey,
                    ),
                    Text(' 주문 처리 중',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            color: _noPayedOrder ? Colors.black : Colors.grey))
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _noPayedOrder = true;
                    _thirdSelectionInOrder = !_thirdSelectionInOrder;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _thirdSelectionInOrder
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 18,
                      color: _noPayedOrder ? Colors.blue : Colors.grey,
                    ),
                    Text(' 수령 완료',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            color: _noPayedOrder ? Colors.black : Colors.grey))
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: size.height * 0.06,
          decoration:
              BoxDecoration(border: Border.all(width: 0.3, color: Colors.grey)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                ' 예약 설정',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _noPayedResv = false;
                    _firstSelectionInResv = false;
                    _secondSelectionInResv = false;
                    _thirdSelectionInResv = false;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      _noPayedResv
                          ? Icons.check_box_outline_blank
                          : Icons.check_box,
                      size: 18,
                      color: _noPayedResv ? Colors.grey : Colors.blue,
                    ),
                    Text(' 미결제',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            color: _noPayedResv ? Colors.grey : Colors.black))
                  ],
                ),
              ),
              Container(
                width: size.width * 0.005,
                height: size.height * 0.03,
                color: Colors.black,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _noPayedResv = true;
                    _firstSelectionInResv = !_firstSelectionInResv;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _firstSelectionInResv
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 19,
                      color: _noPayedResv ? Colors.blue : Colors.grey,
                    ),
                    Text(' 예약 중',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: _noPayedResv ? Colors.black : Colors.grey,
                        ))
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _noPayedResv = true;
                    _secondSelectionInResv = !_secondSelectionInResv;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _secondSelectionInResv
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 19,
                      color: _noPayedResv ? Colors.blue : Colors.grey,
                    ),
                    Text(' 예약 완료',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: _noPayedResv ? Colors.black : Colors.grey,
                        ))
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _noPayedResv = true;
                    _thirdSelectionInResv = !_thirdSelectionInResv;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _thirdSelectionInResv
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 19,
                      color: _noPayedResv ? Colors.blue : Colors.grey,
                    ),
                    Text(' 수령 완료',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: _noPayedResv ? Colors.black : Colors.grey,
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () async {
                  await _getAllOrderDataInProduct();
                  await _getAllReservationDataInProduct();
                  _classifyProduct();
                  setState(() {
                    _isClicked = true;
                    _resultExplainText = _formatStartDateTime() +
                        " ~ " +
                        _formatEndDateTime() +
                        "\n[주문 검색 조건] : ${_currentOrderQuery.replaceAll('orderState', '주문 상태').replaceAll('resv_state', '예약 상태')}\n[예약 검색 조건] : ${_currentReservationQuery.replaceAll('orderState', '주문 상태').replaceAll('resv_state', '예약 상태')}\n상품 통계";
                  });
                },
                child: Container(
                  child: Text(
                    '조회하기',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                  width: size.width * 0.25,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(size.width * 0.015),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.red),
                )),
          ],
        ),
        _isClicked
            ? Column(
                children: [
                  Divider(
                    thickness: 1,
                    height: 3,
                  ),
                  Container(
                    padding: EdgeInsets.all(size.width * 0.025),
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.3, color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.orange[200]),
                    child: Text(
                      '$_resultExplainText',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    height: 8,
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
        _isClicked
            ? Container(
                padding: EdgeInsets.all(size.width * 0.01),
                decoration: BoxDecoration(
                    border: Border.all(width: 0.2, color: Colors.black)),
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Total',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.red),
                      ),
                      width: size.width * 0.2,
                    ),
                    SizedBox(
                      width: size.width * 0.43,
                    ),
                    Container(
                      child: Text(
                        '${_totalBuyCount()}개',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      width: size.width * 0.15,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text('${_totalResvCount()}개',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                      width: size.width * 0.15,
                    ),
                  ],
                ),
              )
            : SizedBox(),
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
        ),
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
