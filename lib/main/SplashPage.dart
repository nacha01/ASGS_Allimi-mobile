import 'dart:async';
import 'package:asgshighschool/notification/NotificationAction.dart';
import 'package:asgshighschool/util/GlobalVariable.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../data/foreground_noti.dart';
import 'SignIn.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
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
      if (!GlobalVariable.isAuthorized) {
        // 로그인이 되어있지 않은 경우 => 로그인 페이지 상태에서 백그라운드 전환 시
        Fluttertoast.showToast(msg: '로그인이 필요합니다.');
        NotificationPayload.isTap = true;
        NotificationPayload.setPayload(event.data['screen']);
      } else {
        // 이외 다른 페이지에 있는 경우 즉시 페이지 이동
        NotificationAction.selectLocation(event.data['screen']);
      }
    });
    _loading();
  }

  Future<void> _getToken() async {
    var token = await _firebaseMessaging.getToken();
    GlobalVariable.token = token ?? "token is null";
    print("Token: $token");
  }

  Future<void> _loading() async {
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _message = '접속 중입니다...';
    });
    await _getToken();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignInPage()));
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
