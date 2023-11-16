import 'dart:async';
import 'dart:developer';
import 'package:asgshighschool/main/MealsAPI.dart';
import 'package:asgshighschool/notification/NotificationManager.dart';
import 'package:asgshighschool/util/GlobalVariable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/provider/exist_cart.dart';
import 'data/provider/renew_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main/SplashPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

var notificationManager = NotificationManager();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await notificationManager.setupFlutterNotifications();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  MealsAPI.API_KEY = dotenv.env['api_key'] ?? "";
  // Background 실행
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp();

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
