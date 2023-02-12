import 'dart:async';
import '../data/foreground_noti.dart';
import 'SignIn.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  var _token;
  String _message = '';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    // Background message 클릭 시 호출
    _firebaseMessaging.getInitialMessage().then((value) => setState(() {
          if (value != null) {
            NotificationPayload.isTap = true;
            NotificationPayload.setPayload(value.data['screen']);
          }
        }));

    // Background message 처리 (종료된 상태에서의 처리 x)
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      NotificationPayload.isTap = true;
      NotificationPayload.setPayload(event.data['screen']);
    });
    loading();
  }

  getToken() {
    _firebaseMessaging.getToken().then((String? token) {
      setState(() {
        _token = token;
        print("Token : $token");
      });
    });
  }

  loading() async {
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _message = '접속 중입니다...';
    });
    await getToken();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SignInPage(
                  token: _token,
                )));
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
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white),
            ),
            Text(
              '$_message',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.white),
            ),
            Text(
              'Copyright 테라바이트',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.white),
            )
          ],
        ),
      ),
    ));
  }
}
