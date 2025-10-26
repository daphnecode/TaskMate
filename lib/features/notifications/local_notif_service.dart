// lib/features/notifications/local_notif_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotifService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (payload) {
        // 클릭 시 동작(필요시 처리)
      },
    );
  }

  static Future<void> showFromRemote(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'taskmate_channel_id',
          'TaskMate Notifications',
          channelDescription: 'Channel for TaskMate reminders',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(
      notif.hashCode,
      notif.title,
      notif.body,
      platformDetails,
      payload: message.data.isNotEmpty ? message.data.toString() : null,
    );
  }
}
