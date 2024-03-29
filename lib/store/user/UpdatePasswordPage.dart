import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../component/DefaultButtonComp.dart';
import '../../component/ThemeAppBar.dart';
import '../../util/ToastMessage.dart';

class UpdatePasswordPage extends StatefulWidget {
  UpdatePasswordPage({this.user});

  final User? user;

  @override
  _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  TextEditingController _currentController = TextEditingController();
  TextEditingController _newController = TextEditingController();
  TextEditingController _againController = TextEditingController();
  bool _isValid = true;

  /// 새로운 비밀번호 업데이트 요청을 하는 작업
  Future<int> _updatePasswordRequest() async {
    String url = '${ApiUtil.API_HOST}arlimi_updatePassword.php';
    final response = await http.post(Uri.parse(url), body: <String, String?>{
      'uid': widget.user!.uid,
      'origin': _currentController.text,
      'new': _newController.text
    });

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      if (result.contains('INVALID')) {
        return 0;
      } else {
        return 1;
      }
    } else {
      return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: ThemeAppBar(barTitle: '비밀번호 변경하기'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              '※ 보안을 위해 8자 이상 영어, 숫자를 적절히 조합하여 변경하세요.',
              style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            children: [
              Container(
                  alignment: Alignment.center,
                  width: size.width * 0.37,
                  height: size.height * 0.07,
                  child: Text('* 현재 비밀번호',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Container(
                width: size.width * 0.6,
                height: size.height * 0.05,
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: _currentController,
                  obscureText: true,
                ),
              )
            ],
          ),
          SizedBox(
            height: size.height * 0.05,
          ),
          Row(
            children: [
              Container(
                  alignment: Alignment.center,
                  width: size.width * 0.37,
                  height: size.height * 0.07,
                  child: Text(
                    '* 새 비밀번호',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              Container(
                width: size.width * 0.6,
                height: size.height * 0.05,
                child: TextField(
                  onChanged: (value) {
                    if (_againController.text != value) {
                      setState(() {
                        _isValid = false;
                      });
                    } else {
                      setState(() {
                        _isValid = true;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _isValid ? Colors.white24 : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                  controller: _newController,
                  obscureText: true,
                ),
              )
            ],
          ),
          SizedBox(
            height: size.height * 0.035,
          ),
          Row(
            children: [
              Container(
                  alignment: Alignment.center,
                  width: size.width * 0.37,
                  height: size.height * 0.07,
                  child: Text('* 새 비밀번호 확인',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Container(
                width: size.width * 0.6,
                height: size.height * 0.05,
                child: TextField(
                  onChanged: (value) {
                    if (_newController.text != value) {
                      setState(() {
                        _isValid = false;
                      });
                    } else {
                      setState(() {
                        _isValid = true;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _isValid ? Colors.white24 : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                  controller: _againController,
                  obscureText: true,
                ),
              )
            ],
          ),
          SizedBox(
            height: size.height * 0.035,
          ),
          Container(
            width: size.width * 0.5,
            height: size.height * 0.06,
            decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: Colors.black),
                borderRadius: BorderRadius.circular(6),
                color: Colors.white24),
            child: DefaultButtonComp(
                onPressed: () async {
                  if (_newController.text != _againController.text) {
                    setState(() {
                      _isValid = false;
                    });
                    return;
                  }
                  var res = await _updatePasswordRequest();
                  String msg = '';
                  switch (res) {
                    case -1:
                      msg = '서버에 문제 발생하여 요청에 실패하였습니다!';
                      break;
                    case 0:
                      msg = '입력한 현재 비밀번호가 올바르지 않습니다!';
                      break;
                    case 1:
                      msg = '성공적으로 변경이 완료되었습니다.';
                      break;
                  }
                  ToastMessage.show(msg);

                  if (res == 1) {
                    Navigator.pop(context);
                  }
                },
                child: Text('비밀번호 변경하기')),
          )
        ],
      ),
    );
  }
}
