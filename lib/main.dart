//https://github.com/railsgem/FlutterTutorial/tree/master/03_flutter_firebase_push_notification

import 'dart:async';
import 'package:asgshighschool/data/exist_cart.dart';
import 'package:asgshighschool/data/renewUser_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main/SplashPage.dart';

void main() {
  runZoned(() {
    runApp(MultiProvider(
      providers : [
        ChangeNotifierProvider(
        create: (_) => ExistCart()),
        ChangeNotifierProvider(create: (_) => RenewUserData(null))
      ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          // page or widget
          //     domain/pageName <= route
          //     HTML  <= widget
          // home: PushMessagingExample(), // single page
          // multi page
          home: SplashPage(),
        ),
      ),
    );
  }, onError: (e) {
    print('Error occurred : ${e.toString()}');
  });
}
