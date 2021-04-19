import 'package:asgshighschool/Screens/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // _emailController.text = 'pipi3425@naver.com';
    // _passwordController.text = '12345678';
  }

  Future<FirebaseUser> _emailSignIn() async {
    var email = _emailController.text ?? "";
    var pw = _passwordController.text ?? "";
    AuthResult result;
    try {
      print('eeeee');
      print(email);
      print(pw);
      result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pw);
      print(result?.toString());
      print('ffff');
    } catch (e) {
      print(e);
      print('hhhhh');
      //에러 Dialog 추가 필요
      return null;
    }
    print('rrrrr');
    print("signed in "); //firebase 로그인 완료

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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '이메일 방식으로 로그인하기',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
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
              ),
              SizedBox(height: 10.0),
              RaisedButton(
                /////////
                onPressed: () async {
                  try {
                    setState(() {
                      _loading = true;
                    });
                    print('ttt');
                    await _emailSignIn();
                    print('xxxx');
                    FirebaseAuth.instance.onAuthStateChanged.listen((fu) {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return HomePage(
                          user: fu,
                          books: widget.books,
                        );
                      }));
                    });
                    print('ppppp');
                    _loading = false;
                  } catch (e) {
                    print(e);
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
                  Navigator.pushReplacementNamed(context, '/SignUp',
                      arguments: widget.books);
                },
                color: Colors.orangeAccent,
                child: Text('이메일 방식으로 가입하기 ', style: TextStyle(fontSize: 17.0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
            ],
          ),
        ));
  }
}
