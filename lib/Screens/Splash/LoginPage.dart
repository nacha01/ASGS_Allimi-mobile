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
        await googleUser.authentication;

    // Trust information
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // data save(real login code)
    final FirebaseUser user =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);

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
        print('Create data');
      }
    });
    return user;
  }

  @override
  Widget build(BuildContext context) {
    print('SignInPage');
    return Scaffold(
        appBar: AppBar(
          title: Text('Login Page'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _loading ? Text('Logging in...') : Text('Click to Login'),
              _loading
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
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
                          Buttons.Email,
                          onPressed: () {
                            var email = emailController.text..trim();
                            var pw = pwController.text..trim();
                            print("email  = ${email}  & pw = ${pw}");

                            //파이어베이스 이메일 회원가입
                            // FirebaseAuth.instance
                            //     .createUserWithEmailAndPassword(
                            //         email: email, password: pw);

                            //파이어베이스 이메일 로그인
                            FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: email, password: pw);
                          },
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
                                Navigator.pushReplacementNamed(context, '/home',
                                    arguments: {
                                      'user': fu,
                                      'books': widget.books
                                    });
                              });
                              _loading = false;
                            } catch (e) {
                              print(e);
                            }
                          },
                        ),
                      ],
                    )
            ],
          ),
        ));
  }
}
