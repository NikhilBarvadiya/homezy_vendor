import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
  }

  Future createNotificationChat(title, description, payload) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      '150',
      'chat_sound',
      channelDescription: 'Chat Notification',
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      showWhen: true,
      subText: 'Need to respond',
      visibility: NotificationVisibility.public,
      enableVibration: true,
    );
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    var nPayload = json.encode(payload);
    await flutterLocalNotificationsPlugin.show(0, title, description, platformChannelSpecifics, payload: nPayload);
  }

  Future<String?> getToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
      if (Platform.isIOS) {
        String? fcmToken = await FirebaseMessaging.instance.getAPNSToken();
        return fcmToken;
      } else {
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        return fcmToken;
      }
    } catch (err) {
      return null;
    }
  }
}

NotificationService notificationService = NotificationService();
