//https://github.com/railsgem/FlutterTutorial/tree/master/03_flutter_firebase_push_notification

import 'dart:async';
import 'package:flutter/material.dart';
import 'main/SplashPage.dart';

void main() {
  runZoned(() {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      // page or widget
      //     domain/pageName <= route
      //     HTML  <= widget
      // home: PushMessagingExample(), // single page
      // multi page
      home: SplashPage(),
    ));
  },onError: (e){
    print('Error occurred : ${e.toString()}');
  });
}
