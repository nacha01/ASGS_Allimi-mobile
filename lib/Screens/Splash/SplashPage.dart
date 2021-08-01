// Script
import 'dart:async';
import 'package:asgshighschool/SignIn.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// Flutter Default Setting

class SplashPage extends StatefulWidget {
  static const routeName = '/SplashPage';
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  var _token;
  String _message = '';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    loading();
  }

  getToken(){
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _token = token;
        print("Token : $token");
      });
    });
  }

  loading() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _message = 'Network Connect...';
    });
    await getToken();
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)
    => SignInPage(token: _token,)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Theme.of(context).primaryColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(),
            Text(
              '안산강서고 알리미',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.white),
            ),
            Text(
              '$_message',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Colors.white),
            ),
            Text(
              'Copyright 테라바이트',
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(color: Colors.white),
            )
          ],
        ),
      ),
    ));
  }
}
