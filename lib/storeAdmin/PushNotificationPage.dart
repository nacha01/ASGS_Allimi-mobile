import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PushNotificationPage extends StatefulWidget {
  final User user;
  PushNotificationPage({this.user});
  @override
  _PushNotificationPageState createState() => _PushNotificationPageState();
}

class _PushNotificationPageState extends State<PushNotificationPage> {
  List _userList = [];
  List<Widget> _userWidgetList = [];
  List _classificationList = [];
  List _eachList = [];
  List<bool> _isSelectedEachList = [];
  List<Widget> _eachLayoutList = [];
  int _currentTap = 0;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  int _selectedGrade = 1;
  int _selectedClass = 1;
  final _gradeList = [1, 2, 3];
  final _classList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
  final _statusList = ['재학생', '학부모', '교사', '졸업생', '기타'];

  Future<bool> _getAllUserInformation() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getAllUsers.php';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List map1st = jsonDecode(result);
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < map1st.length; ++i) {
        map1st[i] = jsonDecode(map1st[i]);
      }
      setState(() {
        _userList = map1st;
        _userList.sort(
            (a, b) => a['name'].toString().compareTo(b['name'].toString()));
        for (int i = 0; i < _userList.length; ++i) {
          _userWidgetList.add(_eachUserLayout(map1st[i], size, i));
          _isSelectedEachList.add(false);
        }
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _sendPushNotification({@required bool isEntire}) async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_pushNotification.php';
    final response = await http.post(url, body: <String, String>{
      'title': _titleController.text,
      'message': _contentController.text,
      'target': isEntire ? 'ENTIRE' : 'EACH'
    });

    if (response.statusCode == 200) {
      print(response.body);
      return true;
    } else {
      return false;
    }
  }

  /// [학년 별] 사용했을 경우
  /// 모든 사용자 정보 중에서 학생 신분이면서
  /// 선택한 학년에 해당하는 모든 학생들을 분류하는 작업
  void _classifyByGrade() {
    _classificationList.clear();
    for (int i = 0; i < _userList.length; ++i) {
      if (int.parse(_userList[i]['identity']) == 1) {
        int currentGrade =
            int.parse(_userList[i]['student_id'].toString().substring(0, 1));
        if (currentGrade == _selectedGrade) {
          _classificationList.add(_userList[i]);
        }
      }
    }
  }

  /// [반 별] 사용했을 경우
  /// 모든 사용자 정보 중에서 학생 신분이면서
  /// (선택한 학년 && 선택한 반)에 해당하는 모든 학생들을 분류하는 작업
  void _classifyByGradeWithClass() {
    _classificationList.clear();
    for (int i = 0; i < _userList.length; ++i) {
      if (int.parse(_userList[i]['identity']) == 1 &&
          _userList[i]['student_id'].toString().length == 5) {
        int currentGrade =
            int.parse(_userList[i]['student_id'].toString().substring(0, 1));
        int currentClass =
            int.parse(_userList[i]['student_id'].toString().substring(1, 3));
        if (currentGrade == _selectedGrade && currentClass == _selectedClass) {
          _classificationList.add(_userList[i]);
          print(_userList[i]['student_id']);
        }
      }
    }
  }

  @override
  void initState() {
    _getAllUserInformation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '푸시 알림 보내기 [Push Notification]',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Center(
                      child: Text(
                '전송 대상',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.blueGrey),
              ))),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentTap = 0;
                  });
                },
                child: Container(
                  child: Text(
                    '전체',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  width: size.width * 0.16,
                  height: size.height * 0.05,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: _currentTap == 0 ? Colors.green : Colors.white,
                      border: Border.all(width: 0.5, color: Colors.black)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentTap = 1;
                  });
                },
                child: Container(
                  child: Text(
                    '학년 별',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  width: size.width * 0.2,
                  height: size.height * 0.05,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: _currentTap == 1 ? Colors.green : Colors.white,
                      border: Border.all(width: 0.5, color: Colors.black)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentTap = 2;
                  });
                },
                child: Container(
                  child: Text(
                    '반 별',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  width: size.width * 0.2,
                  height: size.height * 0.05,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: _currentTap == 2 ? Colors.green : Colors.white,
                      border: Border.all(width: 0.5, color: Colors.black)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentTap = 3;
                  });
                },
                child: Container(
                  child: Text(
                    '특정 개인',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  width: size.width * 0.22,
                  height: size.height * 0.05,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: _currentTap == 3 ? Colors.green : Colors.white,
                      border: Border.all(width: 0.5, color: Colors.black)),
                ),
              ),
            ],
          ),
          Divider(
            thickness: 1,
          ),
          _setLayoutAccordingToCurrentTap(size),
          Divider(
            thickness: 1,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(size.width * 0.02),
                child: Text(
                  '제목',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black54),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.circular(6)),
                width: size.width * 0.9,
                child: TextField(
                  controller: _titleController,
                  maxLines: null,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '제목을 입력하세요.',
                      hintStyle: TextStyle(color: Colors.grey)),
                ),
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              Padding(
                padding: EdgeInsets.all(size.width * 0.02),
                child: Text('내용',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black54)),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.circular(6)),
                width: size.width * 0.9,
                child: TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '내용을 입력하세요.',
                        hintStyle: TextStyle(color: Colors.grey))),
              ),
              FlatButton(
                  onPressed: () async {
                    // await _sendPushNotification();
                    // _classifyByGrade();
                    _classifyByGradeWithClass();
                  },
                  child: Text('전송'))
            ],
          )
        ],
      ),
    );
  }

  Widget _setLayoutAccordingToCurrentTap(Size size) {
    switch (_currentTap) {
      case 0:
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(size.width * 0.01),
              child: Text(
                '전송 대상 설정 - 전체',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      case 1:
        return _gradeLayout(size);
      case 2:
        return _classLayout(size);
      case 3:
        return _eachLayout(size);
      default:
        return SizedBox();
    }
  }

  Widget _gradeLayout(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(size.width * 0.01),
          child: Text(
            '전송 대상 설정 - 학년 별',
            style: TextStyle(
                color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(size.width * 0.01),
          child: Text(
            '* "학년 별"은 1,2,3 학년 중 한 학년을 선택해 해당 학년에 해당한 모든 학생들에게 전송합니다.',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '학년',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            FlatButton(
                padding: EdgeInsets.all(0),
                onPressed: () {
                  setState(() {
                    _selectedGrade = 1;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.025),
                  child: Text(
                    '1학년',
                    style: TextStyle(
                        color:
                            _selectedGrade == 1 ? Colors.white : Colors.black),
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.black),
                      borderRadius: BorderRadius.circular(6),
                      color: _selectedGrade == 1 ? Colors.blue : Colors.white),
                )),
            FlatButton(
                padding: EdgeInsets.all(0),
                onPressed: () {
                  setState(() {
                    _selectedGrade = 2;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.025),
                  child: Text('2학년',
                      style: TextStyle(
                          color: _selectedGrade == 2
                              ? Colors.white
                              : Colors.black)),
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.black),
                      borderRadius: BorderRadius.circular(6),
                      color: _selectedGrade == 2 ? Colors.blue : Colors.white),
                )),
            FlatButton(
                padding: EdgeInsets.all(0),
                onPressed: () {
                  setState(() {
                    _selectedGrade = 3;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.025),
                  child: Text('3학년',
                      style: TextStyle(
                          color: _selectedGrade == 3
                              ? Colors.white
                              : Colors.black)),
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.black),
                      borderRadius: BorderRadius.circular(6),
                      color: _selectedGrade == 3 ? Colors.blue : Colors.white),
                )),
          ],
        ),
        SizedBox(
          height: size.height * 0.01,
        ),
      ],
    );
  }

  Widget _classLayout(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(size.width * 0.01),
          child: Text(
            '전송 대상 설정 - 반 별',
            style: TextStyle(
                color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: size.height * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: Text(
                '학년',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              width: size.width * 0.35,
              child: DropdownButton(
                value: _selectedGrade,
                isExpanded: true,
                items: _gradeList
                    .map((e) => DropdownMenuItem(
                          child: Center(child: Text(e.toString())),
                          value: e,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGrade = value;
                  });
                },
              ),
            ),
            Text(
              '/',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            Text('반', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              width: size.width * 0.35,
              child: DropdownButton(
                value: _selectedClass,
                isExpanded: true,
                items: _classList
                    .map((e) => DropdownMenuItem(
                          child: Center(child: Text(e.toString())),
                          value: e,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClass = value;
                  });
                },
              ),
            )
          ],
        ),
        SizedBox(
          height: size.height * 0.01,
        ),
      ],
    );
  }

  Widget _eachLayout(Size size) {
    return Column(
      children: [
        Column(
          children: _eachLayoutList,
        ),
        FlatButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('유저 목록'),
                  content: StatefulBuilder(
                    builder: (context, setState) => Container(
                      height: size.height * 0.5,
                      child: SingleChildScrollView(
                        child: Column(
                          children: _userWidgetList,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Text('사용자 추가하기'))
      ],
    );
  }

  Widget _eachUserLayout(Map data, Size size, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          print(index);
          _isSelectedEachList[index] = true;
          _userWidgetList.clear();
          for (int i = 0; i < _userList.length; ++i) {
            _userWidgetList.add(_eachUserLayout(_userList[i], size, i));
          }
          _eachLayoutList.add(_eachUserLayout(data, size, index));
        });
        Navigator.pop(context);
      },
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.015),
        child: Container(
          color: _isSelectedEachList.length > index
              ? _isSelectedEachList[index]
                  ? Colors.orange
                  : null
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('${_statusList[int.parse(data['identity']) - 1]}'),
              Text('${data['student_id']}'),
              Text('${data['name']}')
            ],
          ),
        ),
      ),
    );
  }
}
