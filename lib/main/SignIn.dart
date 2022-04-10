import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:asgshighschool/data/status_data.dart';
import 'package:asgshighschool/main/ReportBugPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yaml/yaml.dart';

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
  TextEditingController _emailController = TextEditingController();
  TextEditingController _updateEmailController = TextEditingController();
  TextEditingController _findEmailControllerID = TextEditingController();
  TextEditingController _findNameControllerID = TextEditingController();
  TextEditingController _findGradeControllerID = TextEditingController();
  TextEditingController _findIdControllerPW = TextEditingController();
  TextEditingController _findEmailControllerPW = TextEditingController();
  TextEditingController _findNameControllerPW = TextEditingController();
  TextEditingController _findGradeControllerPW = TextEditingController();
  SharedPreferences _pref;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String _key = '';
  String _resultID = '';
  String _resultPW = '';
  bool _isChecked = false;
  int _tapState = 1;
  var _selectedValue = '재학생';
  final _hexValueList = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'a',
    'b',
    'c',
    'd',
    'e',
    'f'
  ];

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

  Future<String> _getLatestVersion() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getLatestVersion.php';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      return result;
    } else {
      return null;
    }
  }

  void _checkCurrentAppVersion() async {
    var latest = await _getLatestVersion();
    var yaml = await rootBundle.loadString('pubspec.yaml');
    var current = loadYaml(yaml)['version'];
    if (latest != current) {
      await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  content: Text(
                    '최신버전의 앱으로 업데이트 바랍니다.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          //exit(0);
                          Navigator.pop(context);
                        },
                        child: Text('확인'))
                  ],
                ),
              ));
    } else {
      await _loadLoginInfo();
    }
  }

  @override
  void initState() {
    _checkCurrentAppVersion();
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

  String _getRandomPassword() {
    // 0~F 까지의 랜덤 값을 6자리로 생성
    String value = '';
    for (int i = 0; i < 6; ++i) {
      int rdIndex = Random().nextInt(15);
      value += _hexValueList[rdIndex];
    }
    return value;
  }

  Future<void> _loadLoginInfo() async {
    _pref = await SharedPreferences.getInstance();
    if (_pref != null) {
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '로그인 중입니다.\n(3초 이상 지속될 경우 앱을 껐다 켜주세요)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
          if (result.email.isEmpty) {
            await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => AlertDialog(
                      title: Text(
                        '이메일 필수 입력 안내',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '※ 버전 업데이트로 인해 본인인증 수단으로 기존에 가입했던 사용자분들의 이메일 정보를 저장하기 위해 이메일을 필수로 입력바랍니다.',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.5, color: Colors.black),
                                color: Colors.grey[200]),
                            child: TextField(
                              controller: _updateEmailController,
                              decoration: InputDecoration(
                                hintText: '이메일을 입력해주세요.',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          )
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () async {
                              if (_updateEmailController.text.isEmpty ||
                                  !_updateEmailController.text.contains('@')) {
                                return;
                              }
                              var res = await _updateEmailRequest();
                              if (res) {
                                Navigator.pop(context);
                                Fluttertoast.showToast(msg: '이메일 등록 성공');
                                result.email = _updateEmailController.text;
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      Future.delayed(
                                          Duration(milliseconds: 300), () {
                                        Navigator.pop(context);
                                      });
                                      return AlertDialog(
                                        title: Text(
                                          '등록 실패',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    });
                              }
                            },
                            child: Text('등록하기'))
                      ],
                    ));
          }
          result.isAdmin = await _judgeIsAdminAccount();
          if (result.isAdmin) {
            result.adminKey = _key;
          }
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
    } else {
      Fluttertoast.showToast(msg: 'pref value is null');
      _pref = await SharedPreferences.getInstance();
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

  Future<bool> _updateEmailRequest() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_updateEmail.php';
    final response = await http.post(url, body: <String, String>{
      'uid': _idController.text,
      'email': _updateEmailController.text
    });

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      if (result.contains('UPDATED')) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<String> _getFoundUserID() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_findUserID.php';
    final response = await http.post(url, body: <String, String>{
      'name': _findNameControllerID.text,
      'email': _findEmailControllerID.text,
      'grade': _findGradeControllerID.text.isEmpty
          ? 'X'
          : _findGradeControllerID.text
    });

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      if (result.contains('NOT FOUND')) {
        return '해당하는 ID가 존재하지 않습니다!';
      } else {
        return result;
      }
    } else {
      return '아이디 요청 실패';
    }
  }

  Future<bool> _changeRandomPassword(String pw) async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_changePasswordForFind.php';
    final response = await http.post(url, body: <String, String>{
      'uid': _findIdControllerPW.text,
      'email': _findEmailControllerPW.text,
      'name': _findNameControllerPW.text,
      'grade': _findGradeControllerPW.text.isEmpty
          ? 'X'
          : _findGradeControllerPW.text,
      'password': pw
    });

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      print(result);
      if (result.contains('UPDATED')) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
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
      'identity': Status.statusMap[_selectedValue].toString(),
      'student_id': isTwoRow() ? _gradeController.text.toString() : 'NULL',
      'email': _emailController.text
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
        return User(
            'tmp', 'tmp', 'tmp', 5, 'tmp', 'tmp', 'tmp', 0, 0, 'tmp@tmp');
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
        'http://nacha01.dothome.co.kr/sin/arlimi_isAdmin.php?uid=${_idController.text}';
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
                    textScaleFactor: _tapState == 1 ? 1.2 : 1.1,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  width: size.width * 0.3,
                  height: size.height * 0.08,
                  alignment: Alignment.center,
                  color: _tapState == 1 ? Color(0xFFF9F7F8) : Color(0xFFDAE2EF),
                ),
                onPressed: () {
                  setState(() {
                    _tapState = 1;
                  });
                },
              ),
              FlatButton(
                padding: EdgeInsets.all(0),
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.01),
                  child: Text('회원가입 하기\nJoin Membership',
                      textAlign: TextAlign.center,
                      textScaleFactor: _tapState == 2 ? 1.2 : 1.1,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  width: size.width * 0.4,
                  height: size.height * 0.08,
                  alignment: Alignment.center,
                  color: _tapState == 2 ? Color(0xFFF9F7F8) : Color(0xFFDAE2EF),
                ),
                onPressed: () {
                  setState(() {
                    _tapState = 2;
                  });
                },
              ),
              Expanded(
                child: FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Container(
                    padding: EdgeInsets.all(size.width * 0.01),
                    child: Text('ID/PW 찾기\nFind ID/PW',
                        textAlign: TextAlign.center,
                        textScaleFactor: _tapState == 3 ? 1.2 : 1.1,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    height: size.height * 0.08,
                    alignment: Alignment.center,
                    color:
                        _tapState == 3 ? Color(0xFFF9F7F8) : Color(0xFF4072A7),
                  ),
                  onPressed: () {
                    setState(() {
                      _tapState = 3;
                    });
                  },
                ),
              ),
            ],
          ),
          _switchTap(size)
        ],
      ),
    ));
  }

  Widget _switchTap(Size size) {
    switch (_tapState) {
      case 1:
        return Expanded(child: _loginTap(size));
      case 2:
        return Expanded(child: _registerTap(size));
      case 3:
        return Expanded(child: _findAccountTap(size));
      default:
        return SizedBox();
    }
  }

  Widget _loginTap(Size size) {
    return SingleChildScrollView(
      child: Container(
        width: size.width,
        height: size.height * 0.95,
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
                            content: Text('내용을 입력하세요',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            actions: [
                              FlatButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('확인',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)))
                            ],
                          );
                        });
                    return;
                  }
                  if (_pref == null) {
                    _pref = await SharedPreferences.getInstance();
                  }
                  await _pref.setString('uid', _idController.text.toString());
                  await _pref.setString(
                      'password', _passwordController.text.toString());
                  await _pref.setBool('checked', _isChecked);

                  showDialog(
                      barrierDismissible: false,
                      context: (context),
                      builder: (context) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '로그인 중입니다.\n(3초 이상 지속될 경우 앱을 껐다 켜주세요)',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.normal),
                                textAlign: TextAlign.center,
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
                                    fontWeight: FontWeight.bold, fontSize: 14),
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
                    if (result.email.isEmpty) {
                      await showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text(
                                  '이메일 필수 입력 안내',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '※ 버전 업데이트로 인해 본인인증 수단으로 기존에 가입했던 사용자분들의 이메일 정보를 저장하기 위해 이메일을 필수로 입력바랍니다.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                    SizedBox(
                                      height: 25,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 0.5, color: Colors.black),
                                          color: Colors.grey[200]),
                                      child: TextField(
                                        controller: _updateEmailController,
                                        decoration: InputDecoration(
                                          hintText: '이메일을 입력해주세요.',
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                        ),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      ),
                                    )
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () async {
                                        if (_updateEmailController
                                                .text.isEmpty ||
                                            !_updateEmailController.text
                                                .contains('@')) {
                                          return;
                                        }
                                        var res = await _updateEmailRequest();
                                        if (res) {
                                          Navigator.pop(context);
                                          Fluttertoast.showToast(
                                              msg: '이메일 등록 성공');
                                          result.email =
                                              _updateEmailController.text;
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                Future.delayed(
                                                    Duration(milliseconds: 300),
                                                    () {
                                                  Navigator.pop(context);
                                                });
                                                return AlertDialog(
                                                  title: Text(
                                                    '등록 실패',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                );
                                              });
                                        }
                                      },
                                      child: Text('등록하기'))
                                ],
                              ));
                    }
                    result.isAdmin = await _judgeIsAdminAccount();
                    if (result.isAdmin) {
                      result.adminKey = _key;
                    }
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(
                                  user: result,
                                  token: widget.token,
                                )));
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
                  TextButton(
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
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
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
        height: size.height * 0.95,
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
                      items: Status.statusList.map((value) {
                        return DropdownMenuItem(
                          child: Text(value),
                          value: value,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedValue = value;
                          if (Status.statusMap[_selectedValue] > 1) {
                            _gradeController.text = '';
                          }
                        });
                      },
                    ),
                  ),
                  isTwoRow()
                      ? Container(
                          width: size.width * 0.85,
                          child: TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                            controller: _gradeController,
                            cursorColor: Colors.black,
                            onChanged: (value) {},
                            decoration: InputDecoration(
                                hintText: '학번',
                                hintStyle: TextStyle(color: Colors.grey)),
                          ),
                        )
                      : SizedBox(),
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
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      cursorColor: Colors.black,
                      onChanged: (value) {},
                      decoration: InputDecoration(
                          hintText: '이메일',
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
                      _nickNameController.text.isEmpty ||
                      _emailController.text.isEmpty) {
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
                              Text('이메일 : ${_emailController.text}',
                                  style: TextStyle(fontWeight: FontWeight.bold))
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

  Widget _findAccountTap(Size size) {
    return SingleChildScrollView(
        child: Container(
      width: size.width,
      height: size.height * 0.9,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [Color(0xFFF9F7F8), Color(0xFFF9F7F8), Colors.lightBlue[100]],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      )),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(size.width * 0.015),
              child: Text(
                '아이디 찾기',
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: size.height * 0.015,
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.black),
                  color: Colors.grey[100]),
              width: size.width * 0.8,
              child: TextField(
                controller: _findNameControllerID,
                decoration: InputDecoration(hintText: '이름을 입력하세요.'),
              ),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.black),
                  color: Colors.grey[100]),
              width: size.width * 0.8,
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _findEmailControllerID,
                decoration: InputDecoration(hintText: '이메일을 입력하세요.'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.015),
              child: Text(
                '* 이메일을 미입력한 기존에 가입한 유저의 경우 이메일란을 비우고 진행해주세요.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.black),
                  color: Colors.grey[100]),
              width: size.width * 0.8,
              child: TextField(
                controller: _findGradeControllerID,
                decoration: InputDecoration(
                    hintText: '학번을 입력하세요.(재학생이 아닌 경우 입력X)',
                    hintStyle: TextStyle(fontSize: 13)),
              ),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            TextButton(
                onPressed: () async {
                  var res = await _getFoundUserID();
                  setState(() {
                    _resultID = res;
                  });
                },
                child: Container(
                  width: size.width * 0.2,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(size.width * 0.02),
                  child: Text(
                    '찾기',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.black),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.lightBlueAccent),
                )),
            SizedBox(
              height: size.height * 0.01,
            ),
            Text(
              ' 검색 결과:  $_resultID',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(
              height: size.height * 0.015,
            ),
            Divider(
              thickness: 1,
            ),
            SizedBox(
              height: size.height * 0.015,
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.015),
              child: Text(
                '비밀번호 찾기',
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: size.height * 0.015,
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.black),
                  color: Colors.grey[100]),
              width: size.width * 0.8,
              child: TextField(
                controller: _findIdControllerPW,
                decoration: InputDecoration(hintText: 'ID를 입력하세요.'),
              ),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.black),
                  color: Colors.grey[100]),
              width: size.width * 0.8,
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _findEmailControllerPW,
                decoration: InputDecoration(hintText: '이메일을 입력하세요.'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.015),
              child: Text(
                '* 이메일을 미입력한 기존에 가입한 유저의 경우 이메일란을 비우고 진행해주세요.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.black),
                  color: Colors.grey[100]),
              width: size.width * 0.8,
              child: TextField(
                controller: _findNameControllerPW,
                decoration: InputDecoration(hintText: '이름을 입력하세요.'),
              ),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.black),
                  color: Colors.grey[100]),
              width: size.width * 0.8,
              child: TextField(
                controller: _findGradeControllerPW,
                decoration: InputDecoration(
                    hintText: '학번을 입력하세요.(재학생이 아닌 경우 입력X)',
                    hintStyle: TextStyle(fontSize: 13)),
              ),
            ),
            TextButton(
                onPressed: () async {
                  var changedPW = _getRandomPassword();
                  var result = await _changeRandomPassword(changedPW);
                  if (result) {
                    setState(() {
                      _resultPW =
                          '해당 계정의 비밀번호를 "$changedPW"로 초기화하였습니다. 해당 비밀번호로 로그인 후 비밀번호를 변경해주세요.';
                    });
                  } else {
                    setState(() {
                      _resultPW = '존재하지 않는 계정이거나 문제가 발생했습니다. 재시도 바랍니다.';
                    });
                  }
                },
                child: Container(
                  width: size.width * 0.2,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(size.width * 0.02),
                  child: Text(
                    '찾기',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.black),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.lightGreenAccent),
                )),
            Padding(
              padding: EdgeInsets.all(size.width * 0.015),
              child: Text(
                '$_resultPW',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
