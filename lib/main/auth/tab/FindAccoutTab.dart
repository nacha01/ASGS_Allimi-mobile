import 'dart:math';
import 'package:asgshighschool/main/auth/component/AuthFrameComp.dart';
import 'package:asgshighschool/main/auth/controller/AuthController.dart';
import 'package:flutter/material.dart';
import '../../../component/DefaultButtonComp.dart';

class FindAccountTab extends StatefulWidget {
  const FindAccountTab({Key? key}) : super(key: key);

  @override
  State<FindAccountTab> createState() => _FindAccountTabState();
}

class _FindAccountTabState extends State<FindAccountTab> {
  TextEditingController _findEmailControllerID = TextEditingController();
  TextEditingController _findNameControllerID = TextEditingController();
  TextEditingController _findGradeControllerID = TextEditingController();
  TextEditingController _findIdControllerPW = TextEditingController();
  TextEditingController _findEmailControllerPW = TextEditingController();
  TextEditingController _findNameControllerPW = TextEditingController();
  TextEditingController _findGradeControllerPW = TextEditingController();
  AuthController _authController = AuthController();
  String _resultID = '';
  String _resultPW = '';
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

  String _getRandomPassword() {
    // 0~F 까지의 랜덤 값을 6자리로 생성
    String value = '';
    for (int i = 0; i < 6; ++i) {
      int rdIndex = Random().nextInt(15);
      value += _hexValueList[rdIndex];
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AuthFrameComp(
      children: [
        Padding(
          padding: EdgeInsets.all(size.width * 0.01),
          child: Text(
            '아이디 찾기',
            style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: size.height * 0.01,
        ),
        Container(
          decoration: BoxDecoration(
              border: Border.all(width: 0.5, color: Colors.black),
              color: Colors.grey[100]),
          width: size.width * 0.85,
          child: TextField(
            style: TextStyle(fontSize: 13),
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
          width: size.width * 0.85,
          child: TextField(
            style: TextStyle(fontSize: 13),
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
          width: size.width * 0.85,
          child: TextField(
            style: TextStyle(fontSize: 13),
            controller: _findGradeControllerID,
            decoration: InputDecoration(hintText: '학번을 입력하세요.(재학생이 아닌 경우 입력X)'),
          ),
        ),
        SizedBox(
          height: size.height * 0.01,
        ),
        DefaultButtonComp(
            onPressed: () async {
              var res = await _authController.getFoundUserID(
                  _findNameControllerID.text,
                  _findEmailControllerID.text,
                  _findGradeControllerID.text);
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
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
          height: size.height * 0.01,
        ),
        Divider(
          thickness: 1,
        ),
        SizedBox(
          height: size.height * 0.01,
        ),
        Padding(
          padding: EdgeInsets.all(size.width * 0.01),
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
          width: size.width * 0.85,
          child: TextField(
            style: TextStyle(fontSize: 13),
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
          width: size.width * 0.85,
          child: TextField(
            style: TextStyle(fontSize: 13),
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
          width: size.width * 0.85,
          child: TextField(
            style: TextStyle(fontSize: 13),
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
          width: size.width * 0.85,
          child: TextField(
            controller: _findGradeControllerPW,
            style: TextStyle(fontSize: 13),
            decoration: InputDecoration(
                hintText: '학번을 입력하세요.(재학생이 아닌 경우 입력X)',
                hintStyle: TextStyle(fontSize: 13)),
          ),
        ),
        DefaultButtonComp(
            onPressed: () async {
              var changedPW = _getRandomPassword();
              var result = await _authController.changeRandomPassword(
                  _findIdControllerPW.text,
                  _findEmailControllerPW.text,
                  _findNameControllerPW.text,
                  _findGradeControllerPW.text,
                  changedPW);
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
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.black),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.lightGreenAccent),
            )),
        Padding(
          padding: EdgeInsets.all(size.width * 0.01),
          child: Text(
            '$_resultPW',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
