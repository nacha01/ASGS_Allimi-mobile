import 'dart:convert';
import 'HomePage.dart';
import '../data/user_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
////////////////// SIGN UP PAGE ////////////////////////////

class SignUpPage extends StatefulWidget {
  SignUpPage({this.token});
  final token;
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _gradeController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nickNameController = TextEditingController();
  TextEditingController _telController = TextEditingController();
  final statusList = ['재학생', '학부모', '교사', '졸업생', '기타'];
  final statusMap = {'재학생': 1, '학부모': 2, '교사': 3, '졸업생': 4, '기타': 5};
  var _selectedValue = '학생';

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

  Future<void> _postRegisterRequest() async {
    Navigator.pop(context);
    String uri = 'http://nacha01.dothome.co.kr/sin/arlimi_register.php';
    http.Response response = await http.post(uri, headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
    }, body: <String, String>{
      'uid': _idController.text.toString(),
      'pw': _passwordController.text.toString(),
      'token': widget.token,
      'name': _nameController.text.toString(),
      'nickname': _nickNameController.text.toString(),
      'identity': statusMap[_selectedValue].toString(),
      'tel': _telController.text.toString(),
      'student_id': isTwoRow() ? _gradeController.text.toString() : 'NULL'
    });

    if (response.statusCode == 200) {
      String result = utf8.decode(response.bodyBytes);
      if (result.contains('PRIMARY') && result.contains('Duplicate entry')) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('회원 가입 실패'),
              content: Text('이미 사용중인 아이디입니다!'),
            ));
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('회원 가입 성공'),
              content: Text('성공적으로 회원가입이 되었습니다. \n메인 화면으로 이동합니다.'),
              actions: [
                FlatButton(onPressed: _getUserData, child: Text('확인'))
              ],
            ));
        //_getUserData();
      }
    } else {
      print('전송 실패');
    }
  }
  Future<void> _getUserData() async{
      String uri = 'http://nacha01.dothome.co.kr/sin/arlimi_login.php?uid=${_idController.text}&pw=${_passwordController.text}';
      final response= await http.get(uri, headers: <String,String>{
        'Content-Type' : 'application/x-www-form-urlencoded'
      });
      if(response.statusCode == 200){
        String result = utf8.decode(response.bodyBytes).replaceAll('<meta http-equiv="Content-Type" content="text/html; charset=utf-8">', '').trim();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
        HomePage(user: User.fromJson(json.decode(result)),)));
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('회원가입'),
        leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){
            Navigator.pop(context);
        },),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(5.0),
                child: DropdownButton(
                  isExpanded: true,
                  iconSize: 50,
                  value: _selectedValue,
                  items: statusList.map((value) {
                    return DropdownMenuItem(
                      child: Text(value),
                      value: value,
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedValue = value;
                      if(statusMap[_selectedValue] > 1){
                        _gradeController.text = '';
                      }
                    });
                  },
                ),
              ),
              SizedBox(height: 20.0),
              Opacity(
                opacity: isTwoRow() ? 1.0 : 0.0,
                child: TextFormField(
                  controller: _gradeController,
                  cursorColor: Colors.black,
                  style: TextStyle(fontSize: 18.0, color: Colors.black),
                  decoration: InputDecoration(
                    fillColor: Colors.orange.withOpacity(0.1),
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    prefixIcon: Icon(Icons.school),
                    labelText: '학번',
                    labelStyle: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  onChanged: (value) {

                  },
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _idController,
                cursorColor: Colors.black,
                style: TextStyle(fontSize: 18.0, color: Colors.black),
                decoration: InputDecoration(
                  fillColor: Colors.orange.withOpacity(0.1),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  prefixIcon: Icon(Icons.account_circle),
                  labelText: 'ID',
                  labelStyle: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                onChanged: (value) {

                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                cursorColor: Colors.black,
                style: TextStyle(fontSize: 18.0, color: Colors.black),
                decoration: InputDecoration(
                  fillColor: Colors.orange.withOpacity(0.1),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  prefixIcon: Icon(Icons.vpn_key),
                  labelText: '비밀번호',
                  labelStyle: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                onChanged: (value) {

                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _nameController,
                cursorColor: Colors.black,
                style: TextStyle(fontSize: 18.0, color: Colors.black),
                decoration: InputDecoration(
                  fillColor: Colors.orange.withOpacity(0.1),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  prefixIcon: Icon(Icons.account_box),
                  labelText: '이름',
                  labelStyle: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                onChanged: (value) {

                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _telController,
                cursorColor: Colors.black,
                style: TextStyle(fontSize: 18.0, color: Colors.black),
                decoration: InputDecoration(
                  fillColor: Colors.orange.withOpacity(0.1),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  prefixIcon: Icon(Icons.contact_phone_rounded),
                  labelText: '전화번호',
                  labelStyle: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                onChanged: (value) {

                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _nickNameController,
                cursorColor: Colors.black,
                style: TextStyle(fontSize: 18.0, color: Colors.black),
                decoration: InputDecoration(
                  fillColor: Colors.orange.withOpacity(0.1),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  prefixIcon: Icon(Icons.person),
                  labelText: '닉네임',
                  labelStyle: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                onChanged: (value) {

                },
              ),
              SizedBox(height: 20.0),
              RaisedButton(
                onPressed: () async {
                  if(_idController.text.isEmpty || _nameController.text.isEmpty || _nickNameController.text.isEmpty
                  || _telController.text.isEmpty){
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Text('입력하지 않은 정보가 있습니다!'),
                        ));
                  }
                  if (_passwordController.text.toString().length < 6) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Text('비밀번호를 6자리 이상 입력하세요!'),
                            ));
                    return;
                  }
                  if (_idController.text.toString().length < 1) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Text('ID를 4자리 이상 입력하세요!'),
                            ));
                    return;
                  } else {
                    //개인정보 입력 시작
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('입력하신 내용이 맞습니까?'),
                                Text('그룹명: $_selectedValue'),
                                Text('이 름: ${_nameController.text}'),
                                isTwoRow()
                                    ? Text('학번: ${_gradeController.text}')
                                    : SizedBox(height: 0.0,),
                                Text('ID: ${_idController.text}'),
                                Text('닉네임: ${_nickNameController.text}'),
                                Text('전화번호: ${_telController.text}'),
                              ],
                            ),
                            actions: [
                              FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('아니오')),
                              FlatButton(
                                  onPressed: () async {
                                    _postRegisterRequest();
                                  },
                                  child: Text('예'))
                            ],
                          );
                        });
                  } // 개인정보 입력 창 끝.
                },
                color: Colors.orangeAccent,
                child: Text('회원가입 하기', style: TextStyle(fontSize: 17.0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
