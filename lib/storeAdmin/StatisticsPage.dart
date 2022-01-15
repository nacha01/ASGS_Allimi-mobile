import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      print(jsonDecode(result));
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _getTotalSales() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_statisticsSales.php';
    final response = await http.post(url, body: <String, String>{
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
      print(result);
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
                                    if (diff.inDays >= 0 &&
                                        _startTime != '설정 없음') {
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
            FlatButton(
                onPressed: () {
                  _getAllOrderDataInProduct();
                  _getTotalSales();
                },
                child: Text('버튼'))
          ],
        ),
      ),
    );
  }

  Widget _salesTapLayout() {}

  Widget _productTapLayout() {}

  Widget _buyerTapLayout() {}
}
