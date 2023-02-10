//https://github.com/railsgem/FlutterTutorial/tree/master/03_flutter_firebase_push_notification

import 'dart:async';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';

import 'data/provider/exist_cart.dart';
import 'data/provider/renew_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main/SplashPage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

//final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

Future<void> _sendErrorReport(String message) async {
  String url = 'http://nacha01.dothome.co.kr/sin/arlimi_addReport.php';
  final response = await http.post(Uri.parse(url), body: <String, String>{
    'errorMessage': message,
    'date': DateTime.now().toString(),
    'extra': '',
    'isRunning': '1'
  });
  if (response.statusCode == 200) {
    print('성공');
  }
}
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


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
          // navigatorKey: navigatorKey,
        ),
      ),
    );
  }, onError: (e) {
      /*showDialog(
          context: navigatorKey.currentContext,
          builder: (context) =>
              AlertDialog(
                title: Text(
                  '예상치 못한 에러 발생',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                content: Text(
                  e.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await _sendErrorReport(e.toString());
                      Navigator.pop(navigatorKey.currentContext);
                    },
                    child: Text('보고하기',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ));
       */
    log('Error occurred [runZoned] : $e ');
  });
}
