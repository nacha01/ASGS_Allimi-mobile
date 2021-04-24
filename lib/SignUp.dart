import 'package:asgshighschool/Screens/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

////////////////// SIGN UP PAGE ////////////////////////////

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.books}) : super(key: key);
  var books;
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Sign Up Page'),
      ),
      body: SingleChildScrollView(
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
                                  _auth
                                      .createUserWithEmailAndPassword(
                                    email: _emailController.text.toString(),
                                    password:
                                        _passwordController.text.toString(),
                                  )
                                      .then((signedInUser) {
                                    _fireStore.collection('users').add({
                                      'identity': _selectedValue,
                                      'name': _nameController.text.toString(),
                                      'student_id':
                                          _gradeController.text.toString(),
                                      'email': _emailController.text.toString(),
                                    }).then((value) {
                                      if (signedInUser != null) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (ctx) => HomePage(
                                                      books: widget.books,
                                                    )));
                                      }
                                    }).catchError((e) {
                                      print(e);
                                    });
                                  }).catchError((e) {
                                    print(e);
                                  });
                                },
                                child: Text('예'))
                          ],
                        );
                      });
                },
                color: Colors.orangeAccent,
                child: Text('Sign Up ', style: TextStyle(fontSize: 17.0)),
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

/*RaisedButton(
            onPressed: () async {
              try {
                final newUser = await _auth.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                if (newUser != null) {
                  Navigator.pushNamed(context, '/SignIn');
                }
              } catch (e) {
                print(e);
              }
            },
            color: Colors.orangeAccent,
            child: Text('Sign Up ', style: TextStyle(fontSize: 17.0)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
          ),*/
