import 'package:asgshighschool/main/auth/component/AuthFrameComp.dart';
import 'package:asgshighschool/main/auth/controller/AuthController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../component/DefaultButtonComp.dart';
import '../../../data/status.dart';
import '../../HomePage.dart';

class RegisterTab extends StatefulWidget {
  const RegisterTab({Key? key}) : super(key: key);

  @override
  State<RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<RegisterTab> {
  TextEditingController _gradeController = TextEditingController();
  TextEditingController _passwordRegisterController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _nickNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _idRegisterController = TextEditingController();

  AuthController _authController = AuthController();
  var _selectedValue = '재학생';
  String _key = '';

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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AuthFrameComp(
      children: [
        SizedBox(
          height: size.height * 0.05,
        ),
        Text(
          '안산강서고등학교 알리미\n\n회원가입 하기',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: size.height * 0.05,
        ),
        Container(
          padding: EdgeInsets.all(size.width * 0.03),
          width: size.width * 0.95,
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
                  iconSize: 40,
                  value: _selectedValue,
                  items: Status.statusList.map((value) {
                    return DropdownMenuItem(
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 13),
                      ),
                      value: value,
                    );
                  }).toList(),
                  onChanged: (dynamic value) {
                    setState(() {
                      _selectedValue = value;
                      if (Status.statusMap[_selectedValue]! > 1) {
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
                        style: TextStyle(fontSize: 13),
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
                  style: TextStyle(fontSize: 13),
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
                  style: TextStyle(fontSize: 13),
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
                  style: TextStyle(fontSize: 13),
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
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                      hintText: '이름', hintStyle: TextStyle(color: Colors.grey)),
                ),
              ),
              Container(
                width: size.width * 0.85,
                child: TextField(
                  controller: _nickNameController,
                  cursorColor: Colors.black,
                  onChanged: (value) {},
                  style: TextStyle(fontSize: 13),
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
        DefaultButtonComp(
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
                                  fontWeight: FontWeight.bold, fontSize: 14)),
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
              }
              if (_passwordRegisterController.text.toString().length < 6) {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          content: Text('비밀번호를 6자리 이상 입력하세요!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
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
              }
              if (_idRegisterController.text.toString().length < 4) {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          content: Text('ID를 4자리 이상 입력하세요!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
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
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('이름 : ${_nameController.text}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          isTwoRow()
                              ? Text('학번 : ${_gradeController.text}',
                                  style: TextStyle(fontWeight: FontWeight.bold))
                              : SizedBox(),
                          Text('ID : ${_idRegisterController.text}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('닉네임 : ${_nickNameController.text}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('이메일 : ${_emailController.text}',
                              style: TextStyle(fontWeight: FontWeight.bold))
                        ],
                      ),
                      actions: [
                        DefaultButtonComp(
                            onPressed: () async {
                              Navigator.pop(context);

                              var result =
                                  await _authController.postRegisterRequest(
                                      _idRegisterController.text,
                                      _passwordRegisterController.text,
                                      _nameController.text,
                                      _nickNameController.text,
                                      _selectedValue,
                                      isTwoRow()
                                          ? _gradeController.text
                                          : 'NULL',
                                      _emailController.text);
                              if (result) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: Text('회원 가입 성공',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                          content: Text(
                                              '성공적으로 회원가입이 되었습니다. 메인 화면으로 이동합니다.',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                          actions: [
                                            DefaultButtonComp(
                                                onPressed: () async {
                                                  var res = await _authController
                                                      .requestLogin(
                                                          _idRegisterController
                                                              .text,
                                                          _passwordRegisterController
                                                              .text);
                                                  if (res != null) {
                                                    var status =
                                                        await _authController
                                                            .judgeIsAdminAccount(
                                                                _idRegisterController
                                                                    .text);
                                                    if (status.isNotEmpty) {
                                                      res.isAdmin = true;
                                                      res.adminKey = _key;
                                                    }
                                                    Navigator.pop(context);
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    HomePage(
                                                                      user: res,
                                                                    )));
                                                  }
                                                },
                                                child: Text('확인',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)))
                                          ],
                                        ));
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: Text(
                                            '회원 가입 실패',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          content: Text('이미 사용중인 아이디입니다!',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                          actions: [
                                            DefaultButtonComp(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text('확인',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)))
                                          ],
                                        ));
                              }
                            },
                            child: Text('예',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DefaultButtonComp(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('아니오',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    );
                  });
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
                '회원가입 하기\nJoin',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ))
      ],
    );
  }
}
