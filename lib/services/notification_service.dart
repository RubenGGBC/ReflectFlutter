import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:logger/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();
  
  // Notification IDs
  static const int _dailyReviewId = 1;
  static const int _momentReminderMorningId = 2;
  static const int _momentReminderAfternoonId = 3;
  static const int _momentReminderEveningId = 4;
  static const int _weeklyReflectionId = 5;

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const macos = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: android, 
      iOS: ios,
      macOS: macos,
    );
    await _notifications.initialize(settings);
    _logger.i('✅ Notification service initialized');
  }

  Future<void> showNotification(String title, String body, {int id = 0}) async {
    const android = AndroidNotificationDetails(
      'reflect_channel',
      'Reflect Notifications',
      channelDescription: 'Mental health and wellness reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );
    
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const macos = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(android: android, iOS: ios, macOS: macos);
    await _notifications.show(id, title, body, details);
  }

  /// Schedule daily review reminder
  Future<void> scheduleDailyReviewReminder({int hour = 20, int minute = 0}) async {
    try {
      await _notifications.zonedSchedule(
        _dailyReviewId,
        '📝 Reflexión Diaria',
        '¿Cómo te sientes hoy? Tómate un momento para reflexionar',
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_review',
            'Daily Review',
            channelDescription: 'Daily reflection reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      _logger.i('📅 Daily review reminder scheduled for $hour:${minute.toString().padLeft(2, '0')}');
    } catch (e) {
      _logger.w('⚠️ Could not schedule exact alarm, using inexact: $e');
      // Fallback to inexact scheduling
      await _scheduleInexactNotification(
        _dailyReviewId,
        '📝 Reflexión Diaria',
        '¿Cómo te sientes hoy? Tómate un momento para reflexionar',
        hour,
        minute,
      );
    }
  }

  /// Schedule moment capture reminders
  Future<void> scheduleMomentReminders() async {
    try {
      // Morning reminder
      await _notifications.zonedSchedule(
        _momentReminderMorningId,
        '🌅 Momento Matutino',
        '¡Buenos días! Captura un momento especial para empezar el día',
        _nextInstanceOfTime(9, 0),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'moment_reminders',
            'Moment Reminders',
            channelDescription: 'Reminders to capture special moments',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // Afternoon reminder
      await _notifications.zonedSchedule(
        _momentReminderAfternoonId,
        '☀️ Momento de Mediodía',
        '¿Qué tal tu día? Comparte un momento que te haya llamado la atención',
        _nextInstanceOfTime(14, 30),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'moment_reminders',
            'Moment Reminders',
            channelDescription: 'Reminders to capture special moments',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // Evening reminder
      await _notifications.zonedSchedule(
        _momentReminderEveningId,
        '🌙 Momento Nocturno',
        'Antes de descansar, captura un momento que te haya marcado hoy',
        _nextInstanceOfTime(18, 0),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'moment_reminders',
            'Moment Reminders',
            channelDescription: 'Reminders to capture special moments',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      
      _logger.i('📅 Moment reminders scheduled for 9:00, 14:30, and 18:00');
    } catch (e) {
      _logger.w('⚠️ Could not schedule exact moment reminders, using inexact: $e');
      // Fallback to inexact scheduling
      await _scheduleInexactNotification(_momentReminderMorningId, '🌅 Momento Matutino', '¡Buenos días! Captura un momento especial para empezar el día', 9, 0);
      await _scheduleInexactNotification(_momentReminderAfternoonId, '☀️ Momento de Mediodía', '¿Qué tal tu día? Comparte un momento que te haya llamado la atención', 14, 30);
      await _scheduleInexactNotification(_momentReminderEveningId, '🌙 Momento Nocturno', 'Antes de descansar, captura un momento que te haya marcado hoy', 18, 0);
    }
  }

  /// Schedule weekly reflection reminder
  Future<void> scheduleWeeklyReflection() async {
    try {
      await _notifications.zonedSchedule(
        _weeklyReflectionId,
        '🔄 Reflexión Semanal',
        'Ha pasado una semana. ¿Cómo te sientes? Revisa tu progreso',
        _nextInstanceOfWeekday(DateTime.sunday, 19, 0),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'weekly_reflection',
            'Weekly Reflection',
            channelDescription: 'Weekly reflection reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      _logger.i('📅 Weekly reflection reminder scheduled for Sundays at 19:00');
    } catch (e) {
      _logger.w('⚠️ Could not schedule exact weekly reflection, using inexact: $e');
      // For weekly, we'll schedule a simple notification for next Sunday
      await _scheduleInexactNotification(_weeklyReflectionId, '🔄 Reflexión Semanal', 'Ha pasado una semana. ¿Cómo te sientes? Revisa tu progreso', 19, 0);
    }
  }

  /// Setup all default reminders
  Future<void> setupDefaultReminders() async {
    await scheduleDailyReviewReminder(hour: 20, minute: 0);
    await scheduleMomentReminders();
    await scheduleWeeklyReflection();
    _logger.i('✅ All default reminders set up');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    _logger.i('🔕 All notifications cancelled');
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    _logger.i('🔕 Notification $id cancelled');
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await _notifications.getNotificationAppLaunchDetails();
    return settings?.notificationResponse != null;
  }

  /// Get next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  /// Get next instance of a specific weekday and time
  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    
    return scheduledDate;
  }

  /// Show instant daily reminder
  Future<void> showDailyReminder() async {
    await showNotification(
      '📝 Reflexión Diaria',
      'Tómate un momento para reflexionar sobre tu día y registrar tu estado de ánimo',
      id: _dailyReviewId,
    );
  }

  /// Show instant moment reminder
  Future<void> showMomentReminder() async {
    await showNotification(
      '📸 Captura un Momento',
      '¿Hay algo especial que quieras recordar de este momento?',
      id: _momentReminderMorningId,
    );
  }

  /// Fallback method for inexact scheduling when exact alarms are not permitted
  Future<void> _scheduleInexactNotification(
    int id,
    String title,
    String body,
    int hour,
    int minute,
  ) async {
    // Schedule a simple notification without exact timing
    final scheduledDate = _nextInstanceOfTime(hour, minute);
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'inexact_reminders',
          'Inexact Reminders',
          channelDescription: 'Inexact timing reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    
    _logger.i('📅 Inexact notification scheduled for $hour:${minute.toString().padLeft(2, '0')}');
  }
}
