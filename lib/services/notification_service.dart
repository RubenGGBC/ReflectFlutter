import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(settings);
  }

  Future<void> showNotification(String title, String body) async {
    const android = AndroidNotificationDetails(
      'reflect_channel',
      'Reflect Notifications',
      channelDescription: 'Mental health and wellness reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const details = NotificationDetails(android: android);
    await _notifications.show(0, title, body, details);
  }

  Future<void> showDailyReminder() async {
    await showNotification(
      'Daily Reflection',
      'Take a moment to reflect on your day and log your mood',
    );
  }
}
