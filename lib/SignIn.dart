import 'dart:convert';

import 'package:asgshighschool/Screens/HomePage.dart';
import 'package:asgshighschool/SignUp.dart';
import 'package:asgshighschool/WebView.dart';
import 'package:asgshighschool/user_data.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'LocalNotifyManager.dart';
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
        if (message['data']['screen'] == '공지사항') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebViewPage(
                        title: '공지사항',
                        baseUrl:
                            'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030200&searchMasterSid=4',
                      )));
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        if (message['data']['screen'] == '공지사항') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebViewPage(
                        title: 'dw',
                        baseUrl:
                            'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030200&searchMasterSid=4',
                      )));
        }
        setState(() {
          _messageText = "Push Messaging message: $message Launchhhhhhhhh";
        });
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        if (message['data']['screen'] == '공지사항') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebViewPage(
                        title: 'dw',
                        baseUrl:
                            'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030200&searchMasterSid=4',
                      )));
        }
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

  Future _postRequest(String token) async {
    String url = 'http://nacha01.dothome.co.kr/sin/push_send.php';
    http.Response response = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
    }, body: <String, String>{
      'user_token': widget.token,
      'title': '제목',
      'message': '테스트용 메세지'
    });
    print('${response.statusCode}');
    print(response.body);

    String url2 =
        'http://nacha01.dothome.co.kr/sin/getting_data_test.php?title=제목&ms=테스트+메세지';

    final response2 = await http.get(
      url2,
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response2.statusCode == 200) {
      // final userMap = json.decode(response2.body);
      // print(userMap);
      print(response2.body);
    }
  }

  Future<User> _requestLogin() async {
    String uri =
        'http://nacha01.dothome.co.kr/sin/arlimi_login.php?uid=${_idController.text}&pw=${_passwordController.text}';
    final response = await http.get(uri, headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded'
    });
    if (response.statusCode == 200) {
      if (utf8.decode(response.bodyBytes).contains('NOT EXIST ACCOUNT')) {
        return null;
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

  onNotificationClick(String payload) {
    print(payload);
    var map = json.decode(payload);
    print(map);
    print(map['data']);
    // if(map['data']['screen'] == '공지사항'){
    //   Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewPage(title : 'dw',baseUrl: 'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030200&searchMasterSid=4',)));
    // }
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
    //   return ScreenSecond(payload: payload);
    // }));
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
