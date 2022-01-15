import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:asgshighschool/main/ReportBugPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'HomePage.dart';
import 'package:asgshighschool/WebView.dart';
import '../data/user_data.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../LocalNotifyManager.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.token}) : super(key: key);
  final token;
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _gradeController = TextEditingController();
  TextEditingController _idRegisterController = TextEditingController();
  TextEditingController _passwordRegisterController = TextEditingController();
  TextEditingController _nickNameController = TextEditingController();
  SharedPreferences _pref;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String _key;
  bool _isLogin = true;
  bool _isChecked = false;
  final _statusList = ['재학생', '학부모', '교사', '졸업생', '기타'];
  final _statusMap = {'재학생': 1, '학부모': 2, '교사': 3, '졸업생': 4, '기타': 5};
  var _selectedValue = '재학생';

  bool isTwoRow() {
    if (_selectedValue == '재학생' || _selectedValue == '학부모') {
      return true;
    } else if (_selectedValue == '교사' ||
        _selectedValue == '졸업생' ||
        _selectedValue == '기타') {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        localNotifyManager.showNotification(message['notification']["title"],
            message["notification"]["body"].toString(), message);
        String screenLoc = message['data']['screen'];
        selectLocation(screenLoc);
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        String screenLoc = message['data']['screen'];
        selectLocation(screenLoc);
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        String screenLoc = message['data']['screen'];
        selectLocation(screenLoc);
        print("onResume: $message");
      },
    );
    if (Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));

      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
    }
    localNotifyManager.setOnNotificationClick(onNotificationClick);
    localNotifyManager.setOnNotificationReceive(onNotificationReceive);
    _loadLoginInfo();
  }

  void selectLocation(String screenLoc) {
    switch (screenLoc) {
      case '공지사항':
        _moveScreenAccordingToPush(
            title: '공지사항',
            url:
                'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030100&searchMasterSid=3');
        break;
      case '학교 행사':
        _moveScreenAccordingToPush(
            title: '학교 행사',
            url:
                'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030200&searchMasterSid=4');
        break;
      case '학습 자료실':
        _moveScreenAccordingToPush(
            title: '학습 자료실',
            url:
                'http://www.asgs.hs.kr/home/formError.do?code=NONE_LEVEL&menugrp=040300&gm=http%3A%2F%2Fgm7.goeia.go.kr&siteKey=QzlWVUd0ZVZHdFR1R3I3QXlpeHgzNDI1YVRkQk5sT09LbWhZSWlnbjA5bz0%3D');
        break;
      case '학교 앨범':
        _moveScreenAccordingToPush(
            title: '학교 앨범',
            url:
                'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030600&searchMasterSid=6');
        break;
      case '오늘의 식단':
        _moveScreenAccordingToPush(
            title: '오늘의 식단',
            url: 'http://www.asgs.hs.kr/meal/formList.do?menugrp=040801');
        break;
      case '이 달의 일정':
        _moveScreenAccordingToPush(
            title: '이 달의 일정',
            url:
                'http://www.asgs.hs.kr/diary/formList.do?menugrp=030500&searchMasterSid=1');
        break;
      case '가정 통신문':
        _moveScreenAccordingToPush(
            title: '가정 통신문',
            url:
                'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030400&searchMasterSid=49');
        break;
      case '도서 검색':
        _moveScreenAccordingToPush(
            title: '도서 검색',
            url:
                'https://reading.gglec.go.kr/r/newReading/search/schoolCodeSetting.jsp?schoolCode=895&returnUrl=');
        break;
    }
  }

  _loadLoginInfo() async {
    _pref = await SharedPreferences.getInstance();
    setState(() {
      _isChecked = _pref.getBool('checked') ?? false;
      if (_isChecked) {
        _idController.text = _pref.getString('uid') ?? '';
        _passwordController.text = _pref.getString('password') ?? '';
      }
    });
    if (_isChecked) {
      showDialog(
          barrierDismissible: false,
          context: (context),
          builder: (context) {
            if (!this.mounted) {
              Future.delayed(Duration(seconds: 5), () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                          title: Text(
                            '요청시간 초과',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          actions: [
                            FlatButton(
                              onPressed: () => Navigator.pop(c),
                              child: Text('확인',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              padding: EdgeInsets.all(0),
                            )
                          ],
                        ));
              });
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '로그인 중입니다.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.normal),
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            );
          });
      var result = await _requestLogin();
      if (result == null) {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    '로그인 실패',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  content: Text(
                    '입력한 정보가 맞지 않습니다!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  actions: [
                    FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('확인',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      padding: EdgeInsets.all(0),
                    )
                  ],
                ));
        return;
      } else {
        result.isAdmin = await _judgeIsAdminAccount();
        if (result.isAdmin) {
          result.adminKey = _key;
        }
        await _checkUserToken(_idController.text);
        Navigator.pop(context);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      user: result,
                      token: widget.token,
                    )));
      }
    }
  }

  void _moveScreenAccordingToPush(
      {@required String title, @required String url}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewPage(
                  title: title,
                  baseUrl: url,
                )));
  }

  Future<void> _postRegisterRequest() async {
    Navigator.pop(context);
    String uri = 'http://nacha01.dothome.co.kr/sin/arlimi_register.php';
    http.Response response = await http.post(uri, headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
    }, body: <String, String>{
      'uid': _idRegisterController.text.toString(),
      'pw': _passwordRegisterController.text.toString(),
      'token': widget.token,
      'name': _nameController.text.toString(),
      'nickname': _nickNameController.text.toString(),
      'identity': _statusMap[_selectedValue].toString(),
      'student_id': isTwoRow() ? _gradeController.text.toString() : 'NULL'
    });

    if (response.statusCode == 200) {
      String result = utf8.decode(response.bodyBytes);
      if (result.contains('PRIMARY') && result.contains('Duplicate entry')) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    '회원 가입 실패',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  content: Text('이미 사용중인 아이디입니다!',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  actions: [
                    FlatButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('확인',
                            style: TextStyle(fontWeight: FontWeight.bold)))
                  ],
                ));
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('회원 가입 성공',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  content: Text('성공적으로 회원가입이 되었습니다. 메인 화면으로 이동합니다.',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  actions: [
                    FlatButton(
                        onPressed: () async {
                          var res = await _getUserData();
                          if (res == null) {
                          } else {
                            res.isAdmin = await _judgeIsAdminAccount();
                            if (res.isAdmin) {
                              res.adminKey = _key;
                            }
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage(
                                          user: res,
                                          token: widget.token,
                                        )));
                          }
                        },
                        child: Text('확인',
                            style: TextStyle(fontWeight: FontWeight.bold)))
                  ],
                ));
      }
    } else {
      print('전송 실패');
    }
  }

  Future<User> _getUserData() async {
    String uri =
        'http://nacha01.dothome.co.kr/sin/arlimi_login.php?uid=${_idRegisterController.text}&pw=${_passwordRegisterController.text}';
    final response = await http.get(uri, headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded'
    });
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

  Future<bool> _checkUserToken(String uid) async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_checkUserToken.php';
    final response = await http
        .post(url, body: <String, String>{'uid': uid, 'token': widget.token});
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<User> _requestLogin() async {
    String uri =
        'http://nacha01.dothome.co.kr/sin/arlimi_login.php?uid=${_idController.text}&pw=${_passwordController.text}';
    final response = await http.get(Uri.parse(uri), headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded'
    });

    if (response.statusCode == 200) {
      if (utf8.decode(response.bodyBytes).contains('NOT EXIST ACCOUNT')) {
        return null;
      }
      if (response.body.contains('일일 트래픽을 모두 사용하였습니다.')) {
        print('일일 트래픽 모두 사용 in 로그인');
        // 임시 유저로 이동
        return User('tmp', 'tmp', 'tmp', 5, 'tmp', 'tmp', 'tmp', 0, 0);
      }
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

  Future<bool> _judgeIsAdminAccount() async {
    String uri =
        'http://nacha01.dothome.co.kr/sin/arlimi_isAdmin.php?uid=${_idController.text}&pw=${_passwordController.text}';
    final response = await http.get(uri, headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded'
    });
    if (response.statusCode == 200) {
      print(response.body);
      if (response.body.contains('ADMIN')) {
        String body = response.body.replaceAll(
            '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
            '');
        body = body.replaceAll('ADMIN', '');
        _key = body.trim();
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  onNotificationClick(String payload) {
    print(payload);
    Map message = json.decode(payload);
    selectLocation(message['data']['screen']);
  }

  onNotificationReceive(ReceiveNotification notification) {
    print('notification Receive : ${notification.id}');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Row(
            children: [
              FlatButton(
                padding: EdgeInsets.all(0),
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.01),
                  child: Text(
                    '로그인 하기\nLogin',
                    textAlign: TextAlign.center,
                    textScaleFactor: _isLogin ? 1.2 : 1.1,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  width: size.width * 0.3,
                  height: size.height * 0.08,
                  alignment: Alignment.center,
                  color: _isLogin ? Color(0xFFF9F7F8) : Color(0xFFDAE2EF),
                ),
                onPressed: () {
                  setState(() {
                    _isLogin = true;
                  });
                },
              ),
              FlatButton(
                padding: EdgeInsets.all(0),
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.01),
                  child: Text('회원가입 하기\nJoin Membership',
                      textAlign: TextAlign.center,
                      textScaleFactor: _isLogin ? 1.1 : 1.2,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  width: size.width * 0.4,
                  height: size.height * 0.08,
                  alignment: Alignment.center,
                  color: _isLogin ? Color(0xFFDAE2EF) : Color(0xFFF9F7F8),
                ),
                onPressed: () {
                  setState(() {
                    _isLogin = false;
                  });
                },
              ),
              Expanded(
                child: Container(
                  color: Color(0xFF4072AF),
                  height: size.height * 0.08,
                  child: SizedBox(),
                ),
              )
            ],
          ),
          _isLogin
              ? Expanded(child: _loginTap(size))
              : Expanded(child: _registerTap(size)),
        ],
      ),
    ));
  }

  Widget _loginTap(Size size) {
    return SingleChildScrollView(
      child: Container(
        width: size.width,
        height: size.height * 0.92,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [Color(0xFFF9F7F8), Color(0xFFF9F7F8), Colors.lightBlue[100]],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: size.width * 0.15,
            ),
            Text(
              '안산강서고등학교 알리미\n\n로그인 하기',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: size.width * 0.15,
            ),
            Container(
              padding: EdgeInsets.all(size.width * 0.03),
              width: size.width * 0.95,
              height: size.height * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 3, color: Colors.indigo),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: size.width * 0.85,
                    child: TextField(
                      controller: _idController,
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: '아이디를 입력하세요',
                          icon: Icon(Icons.account_circle)),
                    ),
                  ),
                  Container(
                    width: size.width * 0.85,
                    child: TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: '비밀번호를 입력하세요',
                          icon: Icon(Icons.vpn_key)),
                      obscureText: true,
                    ),
                  ),
                  FlatButton(
                      onPressed: () {
                        setState(() {
                          _isChecked = !_isChecked;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            _isChecked
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: Colors.blue,
                          ),
                          Text(' 자동 로그인')
                        ],
                      ))
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            FlatButton(
                onPressed: () async {
                  if (_idController.text.isEmpty ||
                      _passwordController.text.isEmpty) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text('내용을 입력하세요'),
                            actions: [
                              FlatButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('확인'))
                            ],
                          );
                        });
                    return;
                  }
                  _pref.setString('uid', _idController.text.toString());
                  _pref.setString(
                      'password', _passwordController.text.toString());
                  _pref.setBool('checked', _isChecked);

                  try {
                    showDialog(
                        barrierDismissible: false,
                        context: (context),
                        builder: (context) {
                          if (!this.mounted) {
                            Future.delayed(Duration(seconds: 5), () {
                              Navigator.pop(context);
                              showDialog(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                        title: Text('요청 시간 초과',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        actions: [
                                          FlatButton(
                                            onPressed: () => Navigator.pop(c),
                                            child: Text('확인',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            padding: EdgeInsets.all(0),
                                          )
                                        ],
                                      ));
                            });
                          }
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '로그인 중입니다.',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.normal),
                                ),
                                CircularProgressIndicator(),
                              ],
                            ),
                          );
                        });
                    var result = await _requestLogin();
                    if (result == null) {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                actionsPadding: EdgeInsets.all(0),
                                title: Text(
                                  '로그인 실패',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                content: Text(
                                  '입력한 정보가 맞지 않습니다!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                actions: [
                                  FlatButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('확인',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    padding: EdgeInsets.all(0),
                                  )
                                ],
                              ));
                      return;
                    } else {
                      result.isAdmin = await _judgeIsAdminAccount();
                      if (result.isAdmin) {
                        result.adminKey = _key;
                      }
                      await _checkUserToken(_idController.text);
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage(
                                    user: result,
                                    token: widget.token,
                                  )));
                    }
                  } catch (e) {
                    print(e.toString());
                  }
                },
                padding: EdgeInsets.all(size.width * 0.02),
                highlightColor: Colors.blue[200],
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.01),
                  width: size.width * 0.4,
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.black),
                      borderRadius: BorderRadius.circular(6),
                      color: Color(0xFF000066)),
                  alignment: Alignment.center,
                  child: Text(
                    '로그인 하기\nLog in',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )),
            SizedBox(
              height: size.height * 0.09,
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.015),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FlatButton(
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportBugPage()));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bug_report,
                          color: Colors.green,
                          size: 22,
                        ),
                        Text(
                          '버그 제보하기',
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _registerTap(Size size) {
    return SingleChildScrollView(
      child: Container(
        width: size.width,
        height: size.height * 0.92,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [Color(0xFFF9F7F8), Color(0xFFF9F7F8), Colors.lightBlue[100]],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: size.width * 0.15,
            ),
            Text(
              '안산강서고등학교 알리미\n\n회원가입 하기',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: size.width * 0.15,
            ),
            Container(
              padding: EdgeInsets.all(size.width * 0.03),
              width: size.width * 0.95,
              height: size.height * 0.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 3, color: Colors.indigo),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    child: DropdownButton(
                      isExpanded: true,
                      iconSize: 50,
                      value: _selectedValue,
                      items: _statusList.map((value) {
                        return DropdownMenuItem(
                          child: Text(value),
                          value: value,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedValue = value;
                          if (_statusMap[_selectedValue] > 1) {
                            _gradeController.text = '';
                          }
                        });
                      },
                    ),
                  ),
                  Container(
                    width: size.width * 0.85,
                    child: TextField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      controller: _gradeController,
                      cursorColor: Colors.black,
                      onChanged: (value) {},
                      decoration: InputDecoration(
                          hintText: '학번',
                          hintStyle: TextStyle(
                              color: isTwoRow() ? Colors.grey : Colors.red)),
                      readOnly: !isTwoRow(),
                    ),
                  ),
                  Container(
                    width: size.width * 0.85,
                    child: TextField(
                      controller: _idRegisterController,
                      cursorColor: Colors.black,
                      onChanged: (value) {},
                      decoration: InputDecoration(
                          hintText: '아이디(ID)',
                          hintStyle: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  Container(
                    width: size.width * 0.85,
                    child: TextField(
                      controller: _passwordRegisterController,
                      cursorColor: Colors.black,
                      onChanged: (value) {},
                      obscureText: true,
                      decoration: InputDecoration(
                          hintText: '비밀번호',
                          hintStyle: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  Container(
                    width: size.width * 0.85,
                    child: TextField(
                      controller: _nameController,
                      cursorColor: Colors.black,
                      onChanged: (value) {},
                      decoration: InputDecoration(
                          hintText: '이름',
                          hintStyle: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  Container(
                    width: size.width * 0.85,
                    child: TextField(
                      controller: _nickNameController,
                      cursorColor: Colors.black,
                      onChanged: (value) {},
                      decoration: InputDecoration(
                          hintText: '닉네임',
                          hintStyle: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            FlatButton(
                onPressed: () async {
                  if (_idRegisterController.text.isEmpty ||
                      _nameController.text.isEmpty ||
                      _nickNameController.text.isEmpty) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Text('입력하지 않은 정보가 있습니다!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              actions: [
                                FlatButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('확인',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  padding: EdgeInsets.all(0),
                                )
                              ],
                            ));
                    return;
                  }
                  if (_passwordRegisterController.text.toString().length < 6) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Text('비밀번호를 6자리 이상 입력하세요!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              actions: [
                                FlatButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('확인',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  padding: EdgeInsets.all(0),
                                )
                              ],
                            ));
                    return;
                  }
                  if (_idRegisterController.text.toString().length < 4) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Text('ID를 4자리 이상 입력하세요!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              actions: [
                                FlatButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('확인',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  padding: EdgeInsets.all(0),
                                )
                              ],
                            ));
                    return;
                  }
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '입력하신 내용이 맞습니까?\n',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('그룹명 : $_selectedValue',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('이름 : ${_nameController.text}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              isTwoRow()
                                  ? Text('학번 : ${_gradeController.text}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))
                                  : SizedBox(),
                              Text('ID : ${_idRegisterController.text}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('닉네임 : ${_nickNameController.text}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          actions: [
                            FlatButton(
                                onPressed: () async {
                                  await _postRegisterRequest();
                                },
                                child: Text('예',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('아니오',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                        );
                      });
                },
                padding: EdgeInsets.all(size.width * 0.02),
                highlightColor: Colors.blue[200],
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.01),
                  width: size.width * 0.4,
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.black),
                      borderRadius: BorderRadius.circular(6),
                      color: Color(0xFF000066)),
                  alignment: Alignment.center,
                  child: Text(
                    '회원가입 하기\nJoin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
