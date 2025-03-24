import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;


  Future<void> initNotification() async {
    if (_isInitialized) return;

    notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

// prepare ios init settings
    const initializationSettingIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    var initialzationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingIOS,
    );

    await notificationsPlugin.initialize(
      initialzationSettings,
      //   onDidReceiveNotificationResponse: selectNotificationStream.add,
      // onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }


  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'Channel Name',
        channelDescription: 'Daily Notification Cannel',
        icon: '@mipmap/ic_launcher',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker'
      ),
      iOS: DarwinNotificationDetails(),
    );
  }



  Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(
        0, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
  }
  
}
