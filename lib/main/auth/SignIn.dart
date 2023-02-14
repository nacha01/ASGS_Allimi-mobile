import 'dart:convert';
import 'dart:io';
import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/data/foreground_noti.dart';
import 'package:asgshighschool/main/auth/controller/AuthController.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yaml/yaml.dart';

import '../../component/DefaultButtonComp.dart';
import '../HomePage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'tab/FindAccoutTab.dart';
import 'tab/LoginTab.dart';
import 'tab/RegisterTab.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _updateEmailController = TextEditingController();
  late SharedPreferences _pref;
  String _key = '';
  AuthController _authController = AuthController();
  bool _isChecked = false;
  int _tapState = 1;

  Future<String?> _getLatestVersion() async {
    String url = '${ApiUtil.API_HOST}arlimi_getLatestVersion.php';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      Map? json = jsonDecode(result);

      if (Platform.isIOS) // ios 디바이스라면
        return json!['ios']; // 최신 ios 앱 버전 리턴
      else if (Platform.isAndroid) // android 디바이스라면
        return json!['android']; // 최신 android 앱 버전 리턴

      return json!['ios'];
    } else {
      return null;
    }
  }

  void _checkCurrentAppVersion() async {
    var latest = await _getLatestVersion(); // DB에 저장된 최신버전

    var yaml = await rootBundle.loadString('pubspec.yaml');
    var current = loadYaml(yaml)['version']; // 현재 설치된 앱의 버전

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
                    DefaultButtonComp(
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
    _checkCurrentAppVersion(); //서버에 있는 버전과 앱 버전의 차이 찾기
    super.initState();
  }

  Future<void> _loadLoginInfo() async {
    _pref = await SharedPreferences.getInstance();
    setState(() {
      _isChecked = _pref.getBool('checked') ?? false;
      if (_isChecked) {
        LoginTabState.idController.text = _pref.getString('uid') ?? '';
        LoginTabState.passwordController.text =
            _pref.getString('password') ?? '';
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
                    '로그인 중입니다.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
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
      var result = await _authController.requestLogin(
          LoginTabState.idController.text,
          LoginTabState.passwordController.text);
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
                    DefaultButtonComp(
                      onPressed: () => Navigator.pop(context),
                      child: Text('확인',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ));
        return;
      } else {
        if (result.email!.isEmpty) {
          await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => AlertDialog(
                    title: Text(
                      '이메일 필수 입력 안내',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      DefaultButtonComp(
                          onPressed: () async {
                            if (_updateEmailController.text.isEmpty ||
                                !_updateEmailController.text.contains('@')) {
                              return;
                            }
                            var res = await _authController.updateEmailRequest(
                                LoginTabState.idController.text,
                                LoginTabState.updateEmailController.text);
                            if (res) {
                              Navigator.pop(context);
                              Fluttertoast.showToast(msg: '이메일 등록 성공');
                              result.email = _updateEmailController.text;
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    Future.delayed(Duration(milliseconds: 300),
                                        () {
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
        var status = await _authController
            .judgeIsAdminAccount(LoginTabState.idController.text);
        if (status.isNotEmpty) {
          result.isAdmin = true;
          result.adminKey = _key;
        }
        Navigator.pop(context);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      user: result,
                    )));
      }
    } else {
      if (NotificationPayload.isTap) Fluttertoast.showToast(msg: '로그인이 필요합니다.');
    }
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
              DefaultButtonComp(
                padding: 0,
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.01),
                  child: Text(
                    '로그인 하기\nLogin',
                    textAlign: TextAlign.center,
                    textScaleFactor: _tapState == 1 ? 1.2 : 1.1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
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
              DefaultButtonComp(
                padding: 0,
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.01),
                  child: Text('회원가입 하기\nJoin Membership',
                      textAlign: TextAlign.center,
                      textScaleFactor: _tapState == 2 ? 1.2 : 1.1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
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
                child: DefaultButtonComp(
                  padding: 0,
                  child: Container(
                    padding: EdgeInsets.all(size.width * 0.01),
                    child: Text('ID/PW 찾기\nFind ID/PW',
                        textAlign: TextAlign.center,
                        textScaleFactor: _tapState == 3 ? 1.2 : 1.1,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
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
        return Expanded(child: LoginTab());
      case 2:
        return Expanded(child: RegisterTab());
      case 3:
        return Expanded(child: FindAccountTab());
      default:
        return SizedBox();
    }
  }
}
