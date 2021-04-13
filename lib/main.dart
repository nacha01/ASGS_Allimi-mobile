//https://github.com/railsgem/FlutterTutorial/tree/master/03_flutter_firebase_push_notification

// import 'dart:html';

import 'dart:async';

import 'package:asgshighschool/LocalNotifyManager.dart';
import 'package:asgshighschool/web_loading.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Home.dart';
import 'ScreenSecond.dart';
import 'Screens/Splash/LoginPage.dart';
import 'Screens/Splash/SplashPage.dart';
import 'Screens/HomePage.dart';
import 'first.dart';

class PushMessagingExample extends StatefulWidget {
  static const routeName = '/';
  @override
  _PushMessagingExampleState createState() => _PushMessagingExampleState();
}

class _PushMessagingExampleState extends State<PushMessagingExample> {
  String _homeScreenText = "Waiting for token...";
  String _messageText = "Waiting for message...";

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onMessage: $message");
        localNotifyManager.showNotification(
            'gangseo', message["notification"]["body"].toString());
      },
      onLaunch: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _homeScreenText = "Push Messaging token: $token";
      });
      print(_homeScreenText);
    });

    localNotifyManager.setOnNotificationClick(onNotificationClick);
    localNotifyManager.setOnNotificationReceive(onNotificationReceive);
    //
    Timer.run(() {
      print("timer call");
      Navigator.of(context).pushReplacementNamed("/SplashPage");
      //Navigator.of(context).pushNamed("/MyApp");
    });
  }

  onNotificationClick(String payload) {
    print('Payload $payload');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return ScreenSecond(payload: payload);
    }));
  }

  onNotificationReceive(ReceiveNotification notification) {
    print('notification Receive : ${notification.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Push Messaging Demo'),
        ),
        body: Material(
          child: Column(
            children: <Widget>[
              Center(
                child: Text(_homeScreenText),
              ),
              Row(children: <Widget>[
                Expanded(
                  child: Text(_messageText),
                ),
              ])
            ],
          ),
        ));
  }
}

void main() {
  runApp(ChangeNotifierProvider<LoadingData>(
    create: (_) => LoadingData(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      // page or widget
      //     domain/pageName <= route
      //     HTML  <= widget
      // home: PushMessagingExample(), // single page
      // multi page
      initialRoute: PushMessagingExample.routeName,
      onGenerateRoute: (settings) {
        print('redirect page name : $settings');
        switch (settings.name) {
          case MyApp.routeName:
            print('call myapp');
            {
              return MaterialPageRoute(builder: (context) => MyApp());
            }
            break;
          case SplashPage.routeName:
            print('call SplashPage');
            {
              return MaterialPageRoute(builder: (context) => SplashPage());
            }
            break;
          case HomePage.routeName:
            {
              return MaterialPageRoute(
                  builder: (context) => HomePage(
                        user: (settings.arguments as Map)['user'],
                        books: (settings.arguments as Map)['books'],
                      ));
            }
            break;
          case LoginPage.routeName:
            {
              return MaterialPageRoute(
                  builder: (context) => LoginPage(books: settings.arguments));
            }
            break;
          case EmailPasswordAuth.routeName:
            print('call EmailPasswordAuth');
            {
              return MaterialPageRoute(
                  builder: (context) => EmailPasswordAuth());
            }
            break;
          default:
            print('call default');
            {
              return MaterialPageRoute(
                  builder: (context) => PushMessagingExample());
            }
            break;
        }
      },
    ),
  ));
}
