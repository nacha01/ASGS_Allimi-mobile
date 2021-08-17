import 'dart:convert';

import 'HomePage.dart';
import 'SignUp.dart';
import 'package:asgshighschool/WebView.dart';
import '../data/user_data.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../LocalNotifyManager.dart';
////////////////// Login PAGE ////////////////////////////

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.token}) : super(key: key);
  var token;
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _loading = false;
  String email = '';
  String password = '';
  bool _isChecked = false;
  bool _logging = false;
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  SharedPreferences _pref;
  double _opacity = 1.0;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String _messageText = "default";

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message Messageeeeeeeeeee";
        });
        print("onMessage: $message");

        localNotifyManager.showNotification(message['notification']["title"],
            message["notification"]["body"].toString(), message);

        String screenLoc = message['data']['screen'];

        //selectLocation(screenLoc);
      },
      onLaunch: (Map<String, dynamic> message) async {
        String screenLoc = message['data']['screen'];

        selectLocation(screenLoc);
        setState(() {
          _messageText = "Push Messaging message: $message Launchhhhhhhhh";
        });
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        String screenLoc = message['data']['screen'];

        selectLocation(screenLoc);
        setState(() {
          _messageText = "Push Messaging message: $message Resumeeeeeeeeeeeeee";
        });
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
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
      var result = await _requestLogin();
      if (result == null) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('로그인 에러'),
                  content: Text('입력한 정보가 맞지 않습니다!'),
                ));
        return;
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      user: result,
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

  Future _postRequest(String token) async {
    String url = 'http://nacha01.dothome.co.kr/sin/push_send.php';
    http.Response response =
        await http.post(Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
    }, body: <String, String>{
      'user_token': widget.token,
      'title': '제목',
      'message': '테스트용 메세지'
    });
    print('${response.statusCode}');
    print(response.body);
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
        return User('tmp', 'tmp', 'tmp', 5, 'tmp', 'tmp', 'tmp', 'tmp', 0, 0);
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
    if(response.statusCode == 200){
      if(response.body.contains('ADMIN')){
        return true;
      }
      else{
        return false;
      }
    }
    else{
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
    return Scaffold(
        // resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text('로그인 하기'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          color: _logging ? Colors.grey[700] : Color(0x00000000),
          child: /*Indexed*/ Stack(
            /*index: _logging ? 0 : 1,*/
            children: [
              Center(
                child: _logging
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          Text(
                            '로그인 중입니다.',
                            textScaleFactor: 1.3,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Stack(),
              ),
              Opacity(
                opacity: _opacity,
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '이메일 방식으로 로그인하기',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                        SizedBox(height: 50.0),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: TextFormField(
                            cursorColor: Colors.black,
                            controller: _idController,
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.black),
                            decoration: InputDecoration(
                              fillColor: Colors.orange.withOpacity(0.1),
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                              prefixIcon: Icon(Icons.account_circle),
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                email = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            cursorColor: Colors.black,
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.black),
                            decoration: InputDecoration(
                              fillColor: Colors.orange.withOpacity(0.1),
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                              prefixIcon: Icon(Icons.vpn_key),
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                password = value;
                              });
                            },
                          ),
                        ),
                        Row(
                          children: [
                            Checkbox(
                                value: _isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    _isChecked = value;
                                  });
                                }),
                            Text('자동 로그인')
                          ],
                        ),
                        SizedBox(height: 10.0),
                        RaisedButton(
                          /////////
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
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('확인'))
                                      ],
                                    );
                                  });
                              return;
                            }
                            _pref.setString(
                                'uid', _idController.text.toString());
                            _pref.setString('password',
                                _passwordController.text.toString());
                            _pref.setBool('checked', _isChecked);
                            try {
                              setState(() {
                                _loading = true;
                              });
                              var result = await _requestLogin();
                              if (result == null) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: Text('로그인 에러'),
                                          content: Text('입력한 정보가 맞지 않습니다!'),
                                        ));
                                return;
                              } else {
                                result.isAdmin = await _judgeIsAdminAccount();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage(
                                              user: result,
                                            )));
                              }
                              _loading = false;
                            } catch (e) {
                              print(e.toString());
                            }
                          },
                          color: Colors.orangeAccent,
                          child:
                              Text('로그인 하기', style: TextStyle(fontSize: 17.0)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
                        SizedBox(height: 20.0),
                        RaisedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage(
                                        token: widget.token,
                                      )),
                            );
                          },
                          color: Colors.orangeAccent,
                          child: Text('회원가입하러 가기 ',
                              style: TextStyle(fontSize: 17.0)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
                        FlatButton(
                            onPressed: () async {
                              print(widget.token);
                              await _postRequest(widget.token);
                            },
                            child: Text('Show Push Message')),
                        Text(_messageText)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
