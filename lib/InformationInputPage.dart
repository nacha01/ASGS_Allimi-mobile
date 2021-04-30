import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class InputPage extends StatefulWidget {
  InputPage({@required this.user});
  var user;
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  String email;
  String password;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _gradeController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _fireStore = Firestore.instance;
  final statusList = ['학생', '학부모', '교사', '졸업생', '기타'];
  var _selectedValue = '학생';
  bool isTwoRow() {
    if (_selectedValue == '학생' || _selectedValue == '학부모') {
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
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
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
                  });
                },
              ),
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
                prefixIcon: Icon(Icons.account_circle),
                labelText: '이름',
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
                  prefixIcon: Icon(Icons.account_circle),
                  labelText: '학번',
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
            SizedBox(height: 20.0),
            TextFormField(
              controller: _emailController,
              cursorColor: Colors.black,
              style: TextStyle(fontSize: 18.0, color: Colors.black),
              decoration: InputDecoration(
                fillColor: Colors.orange.withOpacity(0.1),
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
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
            SizedBox(height: 20.0),
            RaisedButton(
              onPressed: () async {
                if (_passwordController.text.toString().length < 6) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Text('비밀번호를 6자리 이상 입력하세요!'),
                      ));
                  return;
                }
                if (!_emailController.text.toString().contains('@') ||
                    !_emailController.text.toString().contains('.')) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Text('이메일 입력을 확인하세요!'),
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
                                  ? Text('"학번: ${_gradeController.text}')
                                  : Text(''),
                              Text('이메일: ${_emailController.text}')
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
                                  await Firestore.instance
                                      .collection('users')
                                      .document(widget.user.uid)
                                      .setData({'identity' : _selectedValue,
                                    'name' : _nameController.text.toString(),
                                    'student_id' : _gradeController.text.toString(),
                                    'email': widget.user.email,});
                                  Navigator.pop(context);
                                },
                                child: Text('예'))
                          ],
                        );
                      });
                } // 개인정보 입력 창 끝.
              },
              color: Colors.orangeAccent,
              child: Text('Sign Up ', style: TextStyle(fontSize: 17.0)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
            ),
          ],
        ),
      ),
    );
  }
}
