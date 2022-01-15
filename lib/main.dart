//https://github.com/railsgem/FlutterTutorial/tree/master/03_flutter_firebase_push_notification

import 'dart:async';
import 'dart:ui';
import 'package:asgshighschool/data/exist_cart.dart';
import 'package:asgshighschool/data/renewUser_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main/SplashPage.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

void main() {
  runZoned(() {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ExistCart()),
          ChangeNotifierProvider(create: (_) => RenewUserData(null))
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashPage(),
          navigatorKey: navigatorKey,
        ),
      ),
    );
  }, onError: (e) {
    try {
      showDialog(
          context: navigatorKey.currentContext,
          builder: (context) => AlertDialog(
                title: Text(
                  '에러 메세지 (버그 제보 바랍니다)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                content: Text(
                  e.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  FlatButton(
                    onPressed: () => Navigator.pop(navigatorKey.currentContext),
                    child: Text('확인',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    padding: EdgeInsets.all(0),
                  )
                ],
              ));
    } catch (e) {}
    print('Error occurred [runZoned] : ${e.toString()}');
  });
}
