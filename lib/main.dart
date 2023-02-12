import 'dart:async';
import 'dart:developer';
import 'package:asgshighschool/notification/NotificationManager.dart';
import 'package:asgshighschool/util/GlobalVariable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'data/provider/exist_cart.dart';
import 'data/provider/renew_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main/SplashPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification/NotificationAction.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  /**
   * 서버에서 전송한 json 포맷이 들어옴
   * 핵심은 "data" 필드와 "notification" 필드
   */
  NotificationAction.selectLocation(message.data['screen']);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  var notificationManager = NotificationManager();

  // Background 실행
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Notification Configurations
  if (!kIsWeb) {
    await notificationManager.setupFlutterNotifications();
  }
  // Notification Foreground Click Action
  notificationManager.actForegroundNotification();

  // Foreground Notification Event Listener
  notificationManager.foregroundEventListener();

  runZonedGuarded(() {
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
        ),
      ),
    );
  }, (error, stack) {
    log('Error occurred [runZoned] : $error $stack');
  });
}
