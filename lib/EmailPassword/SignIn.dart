import 'package:asgshighschool/Screens/HomePage.dart';
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
  String email = '';
  String password = '';
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _emailController.text = 'pipi3425@naver.com';
    _passwordController.text = '12345678';
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
                '이메일과 Password\n Authentication',
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
                onPressed: () {
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                        email: _emailController.text.toString(),
                        password: _passwordController.text.toString(),
                      )
                      .then(
                        //is success
                        (firebaseUsers) => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (ctx) => HomePage(
                                      books: widget.books,
                                    ))),
                        // Navigator.pushReplacementNamed(context, '/home',
                        // arguments: {
                        // 'user': firebaseUsers,
                        // 'books': {}
                        // }),
                      )
                      .catchError(
                        (e) => print(e),
                      );

                  FirebaseAuth.instance.currentUser();
                  // empty = not login, not empty = loging
                },
                color: Colors.orangeAccent,
                child: Text('Login', style: TextStyle(fontSize: 17.0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              SizedBox(height: 20.0),
              RaisedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/SignUp',
                      arguments: widget.books);
                },
                color: Colors.orangeAccent,
                child: Text('Sign Up ', style: TextStyle(fontSize: 17.0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
            ],
          ),
        ));
  }
}
