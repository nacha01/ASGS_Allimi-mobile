import 'package:asgshighschool/main/auth/component/AuthFrameComp.dart';
import 'package:asgshighschool/main/auth/controller/AuthController.dart';
import 'package:asgshighschool/util/ToastMessage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../component/DefaultButtonComp.dart';
import '../../HomePage.dart';
import '../../ReportBugPage.dart';

class LoginTab extends StatefulWidget {
  const LoginTab({Key? key}) : super(key: key);

  @override
  State<LoginTab> createState() => LoginTabState();
}

class LoginTabState extends State<LoginTab> {
  static TextEditingController idController = TextEditingController();
  static TextEditingController passwordController = TextEditingController();
  static TextEditingController updateEmailController = TextEditingController();
  late SharedPreferences _pref;
  String _key = '';
  bool _isChecked = false;
  AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AuthFrameComp(
      children: [
        SizedBox(
          height: size.height * 0.05,
        ),
        Text(
          '안산강서고등학교 알리미\n\n로그인 하기',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: size.height * 0.05,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: size.width * 0.85,
                child: TextField(
                  controller: idController,
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
                  controller: passwordController,
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: '비밀번호를 입력하세요',
                      icon: Icon(Icons.vpn_key)),
                  obscureText: true,
                ),
              ),
              DefaultButtonComp(
                  onPressed: () {
                    setState(() {
                      _isChecked = !_isChecked;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
        DefaultButtonComp(
            onPressed: () async {
              if (idController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text('내용을 입력하세요',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        actions: [
                          DefaultButtonComp(
                              onPressed: () => Navigator.pop(context),
                              child: Text('확인',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)))
                        ],
                      );
                    });
                return;
              }
              _pref = await SharedPreferences.getInstance();

              await _pref.setString('uid', idController.text.toString());
              await _pref.setString(
                  'password', passwordController.text.toString());
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
                            '로그인 중입니다.',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.center,
                          ),
                          CircularProgressIndicator(),
                        ],
                      ),
                    );
                  });
              var result = await _authController.requestLogin(
                  idController.text, passwordController.text);
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
                            DefaultButtonComp(
                              onPressed: () => Navigator.pop(context),
                              child: Text('확인',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
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
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
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
                                    controller: updateEmailController,
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
                                    if (updateEmailController.text.isEmpty ||
                                        !updateEmailController.text
                                            .contains('@')) {
                                      return;
                                    }
                                    var res = await _authController
                                        .updateEmailRequest(idController.text,
                                            updateEmailController.text);
                                    if (res) {
                                      Navigator.pop(context);
                                      ToastMessage.show('이메일 등록 성공');
                                      result.email = updateEmailController.text;
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
                var status = await _authController
                    .judgeIsAdminAccount(idController.text);
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
            },
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
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              DefaultButtonComp(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ReportBugPage()));
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
    );
  }
}
