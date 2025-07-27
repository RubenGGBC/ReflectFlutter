import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

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

  // Notification Channels
  static const String _dailyReviewChannel = 'daily_review';
  static const String _momentRemindersChannel = 'moment_reminders';
  static const String _weeklyReflectionChannel = 'weekly_reflection';
  static const String _generalChannel = 'reflect_general';

  Future<void> init() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Madrid')); // Adjust to your timezone
    } catch (e) {
      _logger.w('⚠️ Could not set timezone, using local: $e');
    }

    // Initialize notification settings
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

    // Initialize with notification response handler
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    // Request additional permissions if needed (for Android)
    await _requestAdditionalPermissions();

    _logger.i('✅ Notification service initialized with system-level notifications');
  }

  // Request additional permissions after initialization
  Future<void> _requestAdditionalPermissions() async {
    // Android 13+ requires POST_NOTIFICATIONS permission
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (status != PermissionStatus.granted) {
        _logger.w('⚠️ Android notification permission denied');
      } else {
        _logger.i('✅ Android notification permission granted');
      }
    }
  }

  // Handle notification taps
  void _onNotificationTapped(NotificationResponse response) {
    _logger.i('📱 Notification tapped: ${response.id} - ${response.payload}');
    // Add your navigation logic here based on notification ID
    switch (response.id) {
      case _dailyReviewId:
      // Navigate to daily review screen
        break;
      case _momentReminderMorningId:
      case _momentReminderAfternoonId:
      case _momentReminderEveningId:
      // Navigate to moment capture screen
        break;
      case _weeklyReflectionId:
      // Navigate to weekly reflection screen
        break;
    }
  }

  // Request all necessary permissions
  Future<bool> _requestPermissions() async {
    bool allGranted = true;

    // Android 13+ requires POST_NOTIFICATIONS permission
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (status != PermissionStatus.granted) {
        _logger.w('⚠️ Notification permission denied');
        allGranted = false;
      }
    }

    // iOS permissions
    final result = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (result == false) {
      _logger.w('⚠️ iOS notification permissions denied');
      allGranted = false;
    }

    // macOS permissions
    await _notifications
        .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (allGranted) {
      _logger.i('✅ All notification permissions granted');
    }

    return allGranted;
  }

  // Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Daily Review Channel
    const dailyReviewChannel = AndroidNotificationChannel(
      _dailyReviewChannel,
      'Daily Reviews',
      description: 'Daily mental health check-ins and reflections',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // Moment Reminders Channel
    const momentRemindersChannel = AndroidNotificationChannel(
      _momentRemindersChannel,
      'Moment Reminders',
      description: 'Reminders to capture special moments throughout the day',
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // Weekly Reflection Channel
    const weeklyReflectionChannel = AndroidNotificationChannel(
      _weeklyReflectionChannel,
      'Weekly Reflections',
      description: 'Weekly mental health progress reviews',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // General Channel
    const generalChannel = AndroidNotificationChannel(
      _generalChannel,
      'General Notifications',
      description: 'General app notifications and reminders',
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // Create all channels
    await androidPlugin.createNotificationChannel(dailyReviewChannel);
    await androidPlugin.createNotificationChannel(momentRemindersChannel);
    await androidPlugin.createNotificationChannel(weeklyReflectionChannel);
    await androidPlugin.createNotificationChannel(generalChannel);

    _logger.i('✅ Notification channels created');
  }

  // Show immediate notification
  Future<void> showNotification(String title, String body, {int id = 0, String? payload}) async {
    const android = AndroidNotificationDetails(
      _generalChannel,
      'General Notifications',
      channelDescription: 'General app notifications and reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(''),
    );

    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );

    const macos = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );

    const details = NotificationDetails(android: android, iOS: ios, macOS: macos);
    await _notifications.show(id, title, body, details, payload: payload);
    _logger.i('📱 Immediate notification shown: $title');
  }

  // Schedule daily review reminder
  Future<void> scheduleDailyReviewReminder({int hour = 20, int minute = 0}) async {
    try {
      await _notifications.zonedSchedule(
        _dailyReviewId,
        '📝 Reflexión Diaria',
        '¿Cómo te sientes hoy? Es momento de reflexionar sobre tu día',
        _nextInstanceOfTime(hour, minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _dailyReviewChannel,
            'Daily Reviews',
            channelDescription: 'Daily mental health check-ins',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            styleInformation: const BigTextStyleInformation(
              '¿Cómo te sientes hoy? Es momento de reflexionar sobre tu día',
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 1,
          ),
          macOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 1,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_review',
      );
      _logger.i('📅 Daily review reminder scheduled for $hour:${minute.toString().padLeft(2, '0')}');
    } catch (e) {
      _logger.w('⚠️ Could not schedule exact daily reminder, using inexact: $e');
      await _scheduleInexactNotification(
        _dailyReviewId,
        '📝 Reflexión Diaria',
        '¿Cómo te sientes hoy? Es momento de reflexionar sobre tu día',
        hour,
        minute,
        _dailyReviewChannel,
      );
    }
  }

  // Schedule moment reminders
  Future<void> scheduleMomentReminders() async {
    try {
      // Morning reminder
      await _notifications.zonedSchedule(
        _momentReminderMorningId,
        '🌅 Momento Matutino',
        '¡Buenos días! Captura un momento especial para empezar el día',
        _nextInstanceOfTime(9, 0),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _momentRemindersChannel,
            'Moment Reminders',
            channelDescription: 'Reminders to capture special moments',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'moment_morning',
      );

      // Afternoon reminder
      await _notifications.zonedSchedule(
        _momentReminderAfternoonId,
        '☀️ Momento de Mediodía',
        '¿Qué tal tu día? Comparte un momento que te haya llamado la atención',
        _nextInstanceOfTime(14, 30),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _momentRemindersChannel,
            'Moment Reminders',
            channelDescription: 'Reminders to capture special moments',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'moment_afternoon',
      );

      // Evening reminder
      await _notifications.zonedSchedule(
        _momentReminderEveningId,
        '🌙 Momento Nocturno',
        'Antes de descansar, captura un momento que te haya marcado hoy',
        _nextInstanceOfTime(18, 0),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _momentRemindersChannel,
            'Moment Reminders',
            channelDescription: 'Reminders to capture special moments',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'moment_evening',
      );

      _logger.i('📅 Moment reminders scheduled for 9:00, 14:30, and 18:00');
    } catch (e) {
      _logger.w('⚠️ Could not schedule exact moment reminders, using inexact: $e');
      await _scheduleInexactNotification(_momentReminderMorningId, '🌅 Momento Matutino', '¡Buenos días! Captura un momento especial para empezar el día', 9, 0, _momentRemindersChannel);
      await _scheduleInexactNotification(_momentReminderAfternoonId, '☀️ Momento de Mediodía', '¿Qué tal tu día? Comparte un momento que te haya llamado la atención', 14, 30, _momentRemindersChannel);
      await _scheduleInexactNotification(_momentReminderEveningId, '🌙 Momento Nocturno', 'Antes de descansar, captura un momento que te haya marcado hoy', 18, 0, _momentRemindersChannel);
    }
  }

  // Schedule weekly reflection reminder
  Future<void> scheduleWeeklyReflection() async {
    try {
      await _notifications.zonedSchedule(
        _weeklyReflectionId,
        '🔄 Reflexión Semanal',
        'Ha pasado una semana. ¿Cómo te sientes? Revisa tu progreso',
        _nextInstanceOfWeekday(DateTime.sunday, 19, 0),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _weeklyReflectionChannel,
            'Weekly Reflections',
            channelDescription: 'Weekly mental health progress reviews',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            styleInformation: const BigTextStyleInformation(
              'Ha pasado una semana. ¿Cómo te sientes? Revisa tu progreso',
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 1,
          ),
          macOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 1,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'weekly_reflection',
      );
      _logger.i('📅 Weekly reflection reminder scheduled for Sundays at 19:00');
    } catch (e) {
      _logger.w('⚠️ Could not schedule exact weekly reflection, using inexact: $e');
      await _scheduleInexactNotification(_weeklyReflectionId, '🔄 Reflexión Semanal', 'Ha pasado una semana. ¿Cómo te sientes? Revisa tu progreso', 19, 0, _weeklyReflectionChannel);
    }
  }

  // Setup all default reminders
  Future<void> setupDefaultReminders() async {
    try {
      await scheduleDailyReviewReminder(hour: 20, minute: 0);
      await scheduleMomentReminders();
      await scheduleWeeklyReflection();
      _logger.i('✅ All default reminders set up');
    } catch (e) {
      _logger.w('⚠️ Some reminders could not be set up: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    _logger.i('🔕 All notifications cancelled');
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    _logger.i('🔕 Notification $id cancelled');
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    // Check Android permissions
    if (await Permission.notification.isDenied) {
      return false;
    }

    // Check iOS permissions
    final iosPermissions = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.checkPermissions();
    
    if (iosPermissions != null) {
      final hasPermissions = iosPermissions.isEnabled == true;
      if (!hasPermissions) {
        _logger.w('⚠️ iOS notification permissions not granted');
        return false;
      }
    }

    return true;
  }

  // Get detailed permission status for debugging
  Future<void> logPermissionStatus() async {
    _logger.i('📋 Checking notification permissions...');

    // Android
    final androidStatus = await Permission.notification.status;
    _logger.i('🤖 Android notification permission: $androidStatus');

    // iOS
    final iosPermissions = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.checkPermissions();
    
    if (iosPermissions != null) {
      _logger.i('🍎 iOS notification permissions:');
      _logger.i('  - Enabled: ${iosPermissions.isEnabled}');
    }

    // macOS
    final macosPermissions = await _notifications
        .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
        ?.checkPermissions();
    
    if (macosPermissions != null) {
      _logger.i('💻 macOS notification permissions:');
      _logger.i('  - Enabled: ${macosPermissions.isEnabled}');
    }
  }

  // Fallback method for inexact scheduling
  Future<void> _scheduleInexactNotification(
      int id,
      String title,
      String body,
      int hour,
      int minute,
      String channelId,
      ) async {
    final scheduledDate = _nextInstanceOfTime(hour, minute);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Inexact Reminders',
          channelDescription: 'Inexact timing reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: const DarwinNotificationDetails(
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

  // Get next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Get next instance of a specific weekday and time
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

  // Test notification (for debugging)
  Future<void> showTestNotification() async {
    await showNotification(
      'Test Notification 🔔',
      'This is a test system notification. If you see this, notifications are working!',
      id: 999,
      payload: 'test',
    );
  }

  // Show instant daily reminder
  Future<void> showDailyReminder() async {
    await showNotification(
      '📝 Reflexión Diaria',
      'Tómate un momento para reflexionar sobre tu día y registrar tu estado de ánimo',
      id: _dailyReviewId,
      payload: 'daily_review',
    );
  }

  // Show instant moment reminder
  Future<void> showMomentReminder() async {
    await showNotification(
      '📸 Captura un Momento',
      '¿Hay algo especial que quieras recordar de este momento?',
      id: _momentReminderMorningId,
      payload: 'moment_capture',
    );
  }
}