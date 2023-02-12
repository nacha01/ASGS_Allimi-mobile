//https://github.com/railsgem/FlutterTutorial/tree/master/03_flutter_firebase_push_notification

import 'dart:async';
import 'dart:developer';
import 'package:asgshighschool/util/GlobalVariable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'WebViewPage.dart';
import 'data/provider/exist_cart.dart';
import 'data/provider/renew_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main/SplashPage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

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

void _moveScreenAccordingToPush({required String title, required String url}) {
  Navigator.push(
      GlobalVariable.navigatorState.currentContext!,
      MaterialPageRoute(
          builder: (context) => WebViewPage(
                title: title,
                baseUrl: url,
              )));
}

void selectLocation(String screenLoc) {
  switch (screenLoc) {
    case '공지사항':
      _moveScreenAccordingToPush(
          title: '공지사항',
          url:
              'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030100&searchMasterSid=3');
      break;
    case '학교 행사':
      _moveScreenAccordingToPush(
          title: '학교 행사',
          url:
              'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030200&searchMasterSid=4');
      break;
    case '학습 자료실':
      _moveScreenAccordingToPush(
          title: '학습 자료실',
          url:
              'http://www.asgs.hs.kr/home/formError.do?code=NONE_LEVEL&menugrp=040300&gm=http%3A%2F%2Fgm7.goeia.go.kr&siteKey=QzlWVUd0ZVZHdFR1R3I3QXlpeHgzNDI1YVRkQk5sT09LbWhZSWlnbjA5bz0%3D');
      break;
    case '학교 앨범':
      _moveScreenAccordingToPush(
          title: '학교 앨범',
          url:
              'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030600&searchMasterSid=6');
      break;
    case '오늘의 식단':
      _moveScreenAccordingToPush(
          title: '오늘의 식단',
          url: 'http://www.asgs.hs.kr/meal/formList.do?menugrp=040801');
      break;
    case '이 달의 일정':
      _moveScreenAccordingToPush(
          title: '이 달의 일정',
          url:
              'http://www.asgs.hs.kr/diary/formList.do?menugrp=030500&searchMasterSid=1');
      break;
    case '가정 통신문':
      _moveScreenAccordingToPush(
          title: '가정 통신문',
          url:
              'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030400&searchMasterSid=49');
      break;
    case '도서 검색':
      _moveScreenAccordingToPush(
          title: '도서 검색',
          url:
              'https://reading.gglec.go.kr/r/newReading/search/schoolCodeSetting.jsp?schoolCode=895&returnUrl=');
      break;
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await setupFlutterNotifications();
  showFlutterNotifications(message);
  print("Handling a background message: ${message.notification?.toMap()}");
  print("Handling a background message: ${message.data}");
  print(message.data['screen']);
  selectLocation(message.data['screen']);
  // _setUpInteractedMessage();
}

void showFlutterNotifications(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  // AndroidNotification? android = message.notification?.an

  if(notification != null){
    flutterLocalNotificationsPlugin.show(notification.hashCode, notification.title, notification.body, NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: '@mipmap/ic_launcher'
      )
    ));
  }
}

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
late AndroidNotificationChannel channel;

Future<void> setupFlutterNotifications() async {
  channel = AndroidNotificationChannel(
      'high_importance_channel', 'High Importance Notifications',
      description: 'This channel is used for important notifications',
      importance: Importance.high);
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.
  resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true
  );
}

Future<void> _setUpInteractedMessage() async {
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) _handleMessage(initialMessage);

  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
}

void _handleMessage(RemoteMessage message) {
  selectLocation(message.data['screen']);
}

Future<void> setForegroundMessage() async {
  var channel = const AndroidNotificationChannel(
      'high_importance_channel', 'High Importance Notifications',
      importance: Importance.high);

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestPermission();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);


  // Foreground 메시지 처리
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('onMessage data: ${message.data}');

    if (message.notification != null) {
      print(
          'Message also contained a notification: ${message.notification?.toMap()}');

      // flutterLocalNotificationsPlugin.initialize(initializationSettings)
      flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification?.title,
          message.notification?.body,
          NotificationDetails(
              android: AndroidNotificationDetails(channel.id, channel.name,
                  channelDescription: channel.description,
                  icon: '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(
                  badgeNumber: 1,
                  subtitle: 'ths subtitle',
                  sound: 'slow_spring_board.aiff')),
      payload: message.data['screen']);
    }
  });
}

Future<void> _setMessagingPermission() async {
  var permission = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true);
  // permission.authorizationStatus;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if(!kIsWeb)
    await setupFlutterNotifications();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('onMessage data: ${message.data}');

    if (message.notification != null) {
      print(
          'Message also contained a notification: ${message.notification?.toMap()}');
      flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification?.title,
          message.notification?.body,
          NotificationDetails(
              android: AndroidNotificationDetails(channel.id, channel.name,
                  channelDescription: channel.description,
                  icon: '@mipmap/ic_launcher'),
              iOS: DarwinNotificationDetails(
                  badgeNumber: 1,
                  subtitle: 'ths subtitle',
                  sound: 'slow_spring_board.aiff')),
      payload: message.data['screen']);
    }
  });

  var androidInitializationSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  var darwinInitializationSettings = DarwinInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings);

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (response) {
      if(response.payload != null) {
        print('response ss: ' + response.payload!);
        selectLocation(response.payload!);
      }
    },
  );
  // _setMessagingPermission();

  // setForegroundMessage();
  // var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // _setUpInteractedMessage();
  runZoned(() {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ExistCart()),
          ChangeNotifierProvider(create: (_) => RenewUserData(null))
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: GlobalVariable.navigatorState,
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
                  DefaultButtonComp(
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
