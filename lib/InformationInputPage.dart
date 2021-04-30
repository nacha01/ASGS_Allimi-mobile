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
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(''),
                SizedBox(
                  height: 50,
                ),
                Container(
                  child: DropdownButton(
                    dropdownColor: Colors.amber,
                    elevation: 3,
                    isExpanded: false,
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
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
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
                SizedBox(height: 20.0),
                RaisedButton(
                  onPressed: () async {
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
                                    : Text(''),
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
                                    //개인정보 입력 시작
                                    if (_nameController.text.isEmpty ||
                                            isTwoRow()
                                        ? _gradeController.text.isEmpty
                                        : _gradeController.text.isNotEmpty) {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                content: Text('!'),
                                              ));
                                      return;
                                    }
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    await Firestore.instance
                                        .collection('users')
                                        .document(widget.user.uid)
                                        .setData({
                                      'identity': _selectedValue,
                                      'name': _nameController.text.toString(),
                                      'student_id':
                                          _gradeController.text.toString(),
                                      'email': widget.user.email,
                                    });
                                  },
                                  child: Text('예'))
                            ],
                          );
                        });
                    // 개인정보 입력 창 끝.
                  },
                  color: Colors.orangeAccent,
                  child: Text('update info', style: TextStyle(fontSize: 17.0)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
              ],
            ),
          )),
    ));
  }
}
