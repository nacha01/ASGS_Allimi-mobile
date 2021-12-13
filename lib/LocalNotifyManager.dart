import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:rxdart/subjects.dart';

class LocalNotifyManager {
  var initSetting;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  BehaviorSubject<ReceiveNotification> get didReceiveLocalNotificationSubject =>
      BehaviorSubject<ReceiveNotification>();

  LocalNotifyManager.init() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      requestIOSPermission();
    }
    initializePlatform();
  }
  requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(alert: true, badge: true, sound: true);
  }

  initializePlatform() {
    var initSettingAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initSettingIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestAlertPermission: true,
        requestBadgePermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          ReceiveNotification notification = ReceiveNotification(
              id: id, title: title, body: body, payload: payload);
          didReceiveLocalNotificationSubject.add(notification);
        });
    initSetting = InitializationSettings(
        android: initSettingAndroid, iOS: initSettingIOS);
  }

  setOnNotificationReceive(Function onNotificationReceive) {
    didReceiveLocalNotificationSubject.listen((notification) {
      onNotificationReceive(notification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(initSetting,
        onSelectNotification: (String payload) async {
      onNotificationClick(payload);
    });
  }

  Future<void> showNotification(
      String head, String body, Map<String, dynamic> data) async {
    var androidChannel = AndroidNotificationDetails(
        'CHANNEL_ID', 'CHENNEL_NAME', 'CHANNEL_DESCRIPTION',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        //만일 필요하다면 넣어라
        // sound: RawResourceAndroidNotificationSound('notification_sound'), //my sound
        // icon: '@mipmap/ic_launcher',
        //영상 13분
        //largeIcon: DrawableResourceAndroidBitmap('icon_large_notification')
        enableLights: true);
    var iosChannel =
        IOSNotificationDetails(/* sound: 'notification_sound.mp3' */);
    var platformChannel =
        NotificationDetails(android: androidChannel, iOS: iosChannel);
    await flutterLocalNotificationsPlugin.show(0, head, body, platformChannel,
        payload: json.encode(data));
  }

  Future<void> scheduleNotification() async {
    var scheduleNotificationDataTime =
        DateTime.now().add(Duration(seconds: 10));

    var androidChannel = AndroidNotificationDetails(
      'CHANNEL_ID', 'CHENNEL_NAME', 'CHANNEL_DESCRIPTION',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      //만일 필요하다면 넣어라
      // sound: RawResourceAndroidNotificationSound('notification_sound'), //my sound
      // icon: '@mipmap/ic_launcher',
      //영상 13분
      //largeIcon: DrawableResourceAndroidBitmap('icon_large_notification')
      enableLights: true,
    );
    var iosChannel = IOSNotificationDetails(
        /* sound: 'notification_sound.mp3' */ );
    var platformChannel = NotificationDetails(
      android: androidChannel,
      iOS: iosChannel,
    );
    await flutterLocalNotificationsPlugin.schedule(0, 'schedul Test Title',
        'schedul Test body', scheduleNotificationDataTime, platformChannel,
        payload: 'New PayLoad');
  }
}

LocalNotifyManager localNotifyManager = LocalNotifyManager.init();

class ReceiveNotification {
  final int id;
  final String title;
  final String body;
  final String payload;
  ReceiveNotification(
      {@required this.id,
      @required this.title,
      @required this.body,
      @required this.payload});
}
