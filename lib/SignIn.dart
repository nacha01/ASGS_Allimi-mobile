import 'package:asgshighschool/Screens/HomePage.dart';
import 'package:asgshighschool/SignUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
////////////////// Login PAGE ////////////////////////////

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.books}) : super(key: key);
  var books;
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _loading = false;
  String email = '';
  String password = '';
  bool _isChecked = false;
  bool _logging = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  SharedPreferences _pref;
  double _opacity = 1.0;
  @override
  void initState() {
    super.initState();
    _loadLoginInfo();
    // _emailController.text = 'pipi3425@naver.com';
    // _passwordController.text = '12345678';
  }

  _loadLoginInfo() async {
    _pref = await SharedPreferences.getInstance();
    setState(() {
      _isChecked = _pref.getBool('checked') ?? false;
      if (_isChecked) {
        _emailController.text = _pref.getString('email') ?? '';
        _passwordController.text = _pref.getString('password') ?? '';
      }
    });
    if(_isChecked){
      await _emailSignIn();
      FirebaseAuth.instance.onAuthStateChanged.listen((fu) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
              return HomePage(
                user: fu,
                books: widget.books,
              );
            }));
      });
    }
  }

  Future<FirebaseUser> _emailSignIn() async {
    setState(() {
      _logging = true;
      _opacity = 0.15;
    });
    var email = _emailController.text ?? "";
    var pw = _passwordController.text ?? "";
    AuthResult result;
    try {
      result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pw);
    } catch (e) {
      print(e);
      return null;
    }
    print("signed in "); //firebase 로그인 완료
    //Future.delayed(Duration(seconds: 2));
    Firestore.instance
        .collection("users")
        .document(result.user.uid)
        .get()
        .then((value) async {
      if (value.data == null) {
        await Firestore.instance
            .collection('users')
            .document(result.user.uid)
            .setData({'email': result.user.email, 'create': DateTime.now()});
        print('Create data');
      }
    });
    // setState(() {
    //   _logging = false;
    // });
    return result.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Sign In Page'),
        ),
        body: Container(
          color: _logging ? Colors.grey[700] : Color(0x00000000),
          child: /*Indexed*/Stack(/*index: _logging ? 0 : 1,*/
            children: [
              Center(
                child: _logging
                    ? Column(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        Padding(padding: EdgeInsets.symmetric(vertical: 10),),
                        Text('로그인 중입니다.',textScaleFactor: 1.3,style: TextStyle(fontWeight: FontWeight.bold),),
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
                            controller: _emailController,
                            style: TextStyle(fontSize: 18.0, color: Colors.black),
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
                            style: TextStyle(fontSize: 18.0, color: Colors.black),
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
                            if (_emailController.text.isEmpty ||
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
                                'email', _emailController.text.toString());
                            _pref.setString(
                                'password', _passwordController.text.toString());
                            _pref.setBool('checked', _isChecked);
                            try {
                              setState(() {
                                _loading = true;
                              });
                              await _emailSignIn();
                              FirebaseAuth.instance.onAuthStateChanged
                                  .listen((fu) {
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return HomePage(
                                    user: fu,
                                    books: widget.books,
                                  );
                                }));
                              });
                              _loading = false;
                            } catch (e) {
                              print(e.toString());
                            }
                          },
                          color: Colors.orangeAccent,
                          child: Text('로그인 하기', style: TextStyle(fontSize: 17.0)),
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
                                        books: widget.books,
                                      )),
                            );
                          },
                          color: Colors.orangeAccent,
                          child: Text('이메일 방식으로 가입하기 ',
                              style: TextStyle(fontSize: 17.0)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
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
