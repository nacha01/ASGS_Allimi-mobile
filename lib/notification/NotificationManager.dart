import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/foreground_noti.dart';
import '../util/GlobalVariable.dart';
import '../util/ToastMessage.dart';
import 'NotificationAction.dart';

class NotificationManager {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel _channel = AndroidNotificationChannel(
      'high_importance_channel', 'High Importance Notifications',
      description: 'This channel is used for important notifications',
      importance: Importance.high);
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  void showFlutterNotifications(RemoteMessage message) {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      // 로컬 Notification 띄우기
      _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(_channel.id, _channel.name,
                  channelDescription: _channel.description,
                  icon: '@mipmap/ic_launcher')));
    }
  }

  Future<void> setupFlutterNotifications() async {
    // Android 13 (API level 33) 이상부터 notification permission 설정이 필요
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    // iOS permission 설정
    NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    // iOS foreground notification 설정
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);

    // Android Notification 채널 생성
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  void actForegroundNotification() {
    final androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final darwinInitializationSettings = DarwinInitializationSettings();
    final initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: darwinInitializationSettings);

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (!GlobalVariable.isAuthorized) {
          NotificationPayload.isTap = true;
          ToastMessage.show('로그인이 필요합니다.');
          if (response.payload != null) {
            NotificationPayload.setPayload(response.payload);
          }
          return;
        }
        if (response.payload != null) {
          NotificationAction.selectLocation(response.payload!);
        }
      },
    );
  }

  void foregroundEventListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _flutterLocalNotificationsPlugin.show(
            message.hashCode, // 아이디
            message.notification?.title, // 제목
            message.notification?.body, // 내용
            NotificationDetails(
              android: AndroidNotificationDetails(_channel.id, _channel.name,
                  channelDescription: _channel.description,
                  icon: '@mipmap/ic_launcher'),
            ),
            payload: message.data['screen']); // payload 값 전달
      }
    });
  }
}
