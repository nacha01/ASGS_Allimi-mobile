import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/status_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  int _successCount = 0;
  int _failCount = 0;
  int _sentTotalCount = 0;
  int _currentTap = 0;
  int _selectedGrade = 1;
  int _selectedClass = 1;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  bool _isSent = false;
  final _gradeList = [1, 2, 3];
  final _classList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
  final _targetList = ['전체', '학년 별', '반 별', '개별'];

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
          _userWidgetList.add(_eachUserLayoutInDialog(map1st[i], size, i));
          _isSelectedEachList.add(false);
        }
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _sendPushNotification(
      {@required bool isEntire, String token}) async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_pushNotification.php';
    final response = await http.post(url, body: <String, String>{
      'title': _titleController.text,
      'message': _contentController.text,
      'target': isEntire ? 'ENTIRE' : 'EACH',
      'token': isEntire ? 'NONE' : token
    });

    if (response.statusCode == 200) {
      Map result = jsonDecode(response.body);
      if (result['success'] == 1) {
        _successCount++;
      } else {
        _failCount++;
      }
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
      body: SingleChildScrollView(
        child: Column(
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
                      '개별',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    width: size.width * 0.2,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                  ],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(6)),
                      width: size.width * 0.9,
                      child: TextField(
                          controller: _contentController,
                          maxLines: null,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '내용을 입력하세요.',
                              hintStyle: TextStyle(color: Colors.grey))),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Align(
                  alignment: Alignment.center,
                  child: FlatButton(
                      onPressed: () async {
                        if (_titleController.text.isEmpty) {
                          Fluttertoast.showToast(msg: '제목을 입력하세요!');
                          return;
                        }
                        if (_contentController.text.isEmpty) {
                          Fluttertoast.showToast(msg: '내용을 입력하세요!');
                          return;
                        }
                        await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('푸시 전송 준비'),
                                  content: Text(
                                      '정말로 전송하시겠습니까? [${_targetList[_currentTap]}]'),
                                  actions: [
                                    FlatButton(
                                        onPressed: () async {
                                          _successCount = 0;
                                          _failCount = 0;
                                          switch (_currentTap) {
                                            case 0: // 전체
                                              _sentTotalCount =
                                                  _userList.length;
                                              await _sendPushNotification(
                                                  isEntire: true);
                                              break;
                                            case 1: // 학년
                                              _classifyByGrade();
                                              _sentTotalCount =
                                                  _classificationList.length;
                                              for (int i = 0;
                                                  i <
                                                      _classificationList
                                                          .length;
                                                  ++i) {
                                                await _sendPushNotification(
                                                    isEntire: false,
                                                    token:
                                                        _classificationList[i]
                                                            ['token']);
                                              }
                                              break;
                                            case 2: // 반
                                              _classifyByGradeWithClass();
                                              _sentTotalCount =
                                                  _classificationList.length;
                                              for (int i = 0;
                                                  i <
                                                      _classificationList
                                                          .length;
                                                  ++i) {
                                                print(_classificationList[i]
                                                    ['token']);
                                                await _sendPushNotification(
                                                    isEntire: false,
                                                    token:
                                                        _classificationList[i]
                                                            ['token']);
                                              }
                                              break;
                                            case 3: // 개별
                                              _sentTotalCount =
                                                  _eachList.length;
                                              for (int i = 0;
                                                  i < _eachList.length;
                                                  ++i) {
                                                await _sendPushNotification(
                                                    isEntire: false,
                                                    token: _eachList[i]
                                                        ['token']);
                                              }
                                              break;
                                          }
                                          Navigator.pop(context);
                                          setState(() {
                                            _isSent = true;
                                          });
                                        },
                                        child: Text('예')),
                                    FlatButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('아니오'))
                                  ],
                                ));
                      },
                      child: Container(
                        child: Text(
                          '전송하기',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 13),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.03,
                            vertical: size.width * 0.02),
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5, color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.redAccent),
                      )),
                ),
                _isSent
                    ? Column(
                        children: [
                          Divider(
                            thickness: 1,
                          ),
                          Text(
                            '전송 결과 - 전송 된 푸시 $_sentTotalCount개 중   성공: $_successCount개, 실패: $_failCount개',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.all(size.width * 0.02),
                            child: Text(
                                '※ 실패의 이유로는 해당 기기의 고유 토큰 값이 만료되거나 등록되지 않은 기기이거나 잘못된 고유 토큰 값 때문입니다.',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: Colors.grey)),
                          )
                        ],
                      )
                    : SizedBox()
              ],
            )
          ],
        ),
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
    return Container(
      width: size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(size.width * 0.01),
            child: Text(
              '전송 대상 설정 - 개인 별',
              style: TextStyle(
                  color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(size.width * 0.015),
            child: Text(
              '전송 대상 추가된 사용자 목록',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 12),
            ),
          ),
          _eachLayoutList.length == 0
              ? Text('없음')
              : Column(
                  children: _eachLayoutList,
                ),
          FlatButton(
              padding: EdgeInsets.all(0),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (ctx) {
                      Future.delayed(Duration(milliseconds: 200), () {
                        Navigator.pop(ctx);
                      });
                      return Center(child: CircularProgressIndicator());
                    });
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    actionsPadding: EdgeInsets.all(0),
                    title: Text('유저 목록 [신분, 학번, 이름]'),
                    content: Container(
                      height: size.height * 0.5,
                      child: SingleChildScrollView(
                        child: Column(
                          children: _userWidgetList,
                        ),
                      ),
                    ),
                    actions: [
                      FlatButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('닫기'),
                        padding: EdgeInsets.all(0),
                      )
                    ],
                  ),
                );
              },
              child: Container(
                child: Text(
                  '+ 사용자 추가하기',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                padding: EdgeInsets.all(size.width * 0.015),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(width: 0.5, color: Colors.black),
                    color: Colors.lightGreen),
              )),
          Text(
            '↑ 전체 사용자 목록을 띄우고 원하는 사용자를 클릭하면 추가됩니다.',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
          )
        ],
      ),
    );
  }

  Widget _eachUserLayoutInDialog(Map data, Size size, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (!_isSelectedEachList[index]) {
            _isSelectedEachList[index] = true;
            _userWidgetList.clear();
            for (int i = 0; i < _userList.length; ++i) {
              _userWidgetList
                  .add(_eachUserLayoutInDialog(_userList[i], size, i));
            }
            _eachLayoutList.add(_eachUserLayoutInScreen(data, size, index));
            _eachList.add(data);
            Navigator.pop(context);
          }
        });
      },
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.015),
        child: Container(
          padding: EdgeInsets.all(size.width * 0.02),
          decoration: BoxDecoration(
              color: _isSelectedEachList.length > index
                  ? _isSelectedEachList[index]
                      ? Colors.orange
                      : null
                  : null,
              border: Border.all(width: 0.2, color: Colors.grey)),
          width: size.width * 0.8,
          child: Row(
            children: [
              Container(
                child: Text(
                  '${Status.statusList[int.parse(data['identity']) - 1]}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                alignment: Alignment.center,
              ),
              Expanded(
                  child: Center(
                      child: Text(
                '${data['student_id'] == null || data['student_id'] == '' ? 'X' : data['student_id']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ))),
              Container(
                child: Text(
                  '${data['name']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                alignment: Alignment.center,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _eachUserLayoutInScreen(Map data, Size size, int index) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.01),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.02),
        decoration: BoxDecoration(
            color: Colors.grey[300],
            border: Border.all(width: 0.5, color: Colors.black),
            borderRadius: BorderRadius.circular(5)),
        width: size.width * 0.7,
        child: Row(
          children: [
            Container(
              child: Text(
                '${Status.statusList[int.parse(data['identity']) - 1]}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              alignment: Alignment.center,
            ),
            Expanded(
                child: Center(
                    child: Text(
              '${data['student_id'] == null || data['student_id'] == '' ? 'X' : data['student_id']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ))),
            Container(
              child: Text(
                '${data['name']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              alignment: Alignment.center,
            )
          ],
        ),
      ),
    );
  }
}
