import 'package:asgshighschool/Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ignore: must_be_immutable
class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.books}) : super(key: key);
  static const routeName = '/signin';
  var books;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // login type check
  bool _loading = false;
  TextEditingController emailController;
  TextEditingController pwController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    pwController = TextEditingController();
    emailController.text = 'pipi3425@naver.com';
    pwController.text = '12345678';
  }

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  _googleSignIn() async {
    // account check
    final bool isSignedIn =
        await GoogleSignIn().isSignedIn(); // already account check

    // user data
    GoogleSignInAccount googleUser;

    if (isSignedIn)
      googleUser = await GoogleSignIn().signInSilently(); // not ui
    else
      googleUser = await GoogleSignIn().signIn(); // select google account

    // google Auth data
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication; //token

    // Trust information
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken, //접근 권한
      idToken: googleAuth.idToken, // 현재 아이디
    );

    // data save(real login code)
    final FirebaseUser user =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;
    print("signed in " + user.displayName); //firebase 인증 시작

    // new data create(firestore)
    Firestore.instance
        .collection("users")
        .document(user.uid)
        .get()
        .then((value) async {
      if (value.data == null) {
        await Firestore.instance
            .collection('users')
            .document(user.uid)
            .setData({'email': user.email, 'create': DateTime.now()});
      }
    });
    return user;
  }

  Future<FirebaseUser> _emailSignIn() async {
    var email = emailController.text ?? "";
    var pw = pwController.text ?? "";
    AuthResult result;
    try {
      print('eeeee');
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
    print('SignInPage');
    return Scaffold(
        appBar: AppBar(
          title: Text('Login Page'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 120.0),
                  _loading ? Text('로그인 중입니다....') : Text('버튼을 눌러 로그인해 주세요'),
                  _loading
                      ? CircularProgressIndicator()
                      : Column(
                          children: [
                            /*
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextField(
                                controller: emailController,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextField(
                                controller: pwController,
                              ),
                            ),
                            */
                            SizedBox(height: 50.0),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (ctx) {
                                  return EmailPasswordAuth(
                                    books: widget.books,
                                  );
                                }));
                              },
                              child: Text(
                                '일반 이메일으로 로그인 하기',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            SizedBox(height: 50.0),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              onPressed: () async {
                                try {
                                  setState(() {
                                    _loading = true;
                                  });
                                  await _googleSignIn();
                                  FirebaseAuth.instance.onAuthStateChanged
                                      .listen((fu) {
                                    Navigator.pushReplacementNamed(
                                        context, '/home',
                                        arguments: {
                                          'user': fu,
                                          'books': widget.books // empty
                                        });
                                  });
                                  _loading = false;
                                } catch (e) {
                                  print(e);
                                }
                              },

                              // onPressed: () =>
                              //     Navigator.pushNamed(context, '/google'),
                              child: Text(
                                '구글 이메일으로 로그인 하기',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            SizedBox(height: 20.0),
                            /*
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/phone'),
                              child: Text(
                                'Continue with Phone',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextField(
                                controller: emailController,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextField(
                                controller: pwController,
                              ),
                            ),
                            SignInButton(
                              Buttons.Google,
                              onPressed: () async {
                                try {
                                  setState(() {
                                    _loading = true;
                                  });
                                  await _googleSignIn();
                                  FirebaseAuth.instance.onAuthStateChanged
                                      .listen((fu) {
                                    Navigator.pushReplacementNamed(
                                        context, '/home',
                                        arguments: {
                                          'user': fu,
                                          'books': widget.books // empty
                                        });
                                  });
                                  _loading = false;
                                } catch (e) {
                                  print(e);
                                }
                              },
                            ),
                            SignInButton(
                              Buttons.Email,
                              onPressed: () async {
                                try {
                                  setState(() {
                                    _loading = true;
                                  });
                                  await _emailSignIn();
                                  FirebaseAuth.instance.onAuthStateChanged
                                      .listen((fu) {
                                    Navigator.pushReplacementNamed(
                                        context, '/home',
                                        arguments: {
                                          'user': fu,
                                          'books': widget.books // empty
                                        });
                                  });
                                  _loading = false;
                                } catch (e) {
                                  print(e);
                                }
                              },
                            ),
                            */
                          ],
                        )
                ],
              ),
            ),
          ),
        ));
  }
}
