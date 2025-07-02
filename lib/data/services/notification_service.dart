// lib/services/notification_service.dart
// ============================================================================
// SERVICIO DE NOTIFICACIONES LOCALES
// ============================================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final Logger _logger = Logger();

  // IDs de notificaciones
  static const int dailyReflectionId = 1;
  static const int eveningCheckInId = 2;
  static const int weeklyReviewId = 3;
  static const int motivationalId = 4;

  // Callback para cuando se toca una notificación
  static Function(String?)? onNotificationTap;

  /// Inicializar el servicio de notificaciones
  static Future<void> initialize() async {
    _logger.i('🔔 Inicializando servicio de notificaciones...');

    try {
      // Inicializar timezone
      tz.initializeTimeZones();

      // Configuración para Android
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuración para iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      // Solicitar permisos
      await _requestPermissions();

      _logger.i('✅ Servicio de notificaciones inicializado');
    } catch (e) {
      _logger.e('❌ Error inicializando notificaciones: $e');
    }
  }

  /// Solicitar permisos de notificaciones
  static Future<bool> _requestPermissions() async {
    try {
      // Android 13+ requiere permiso explícito
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        if (status != PermissionStatus.granted) {
          _logger.w('⚠️ Permisos de notificación denegados');
          return false;
        }
      }

      // iOS
      final bool? granted = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      _logger.i('✅ Permisos de notificación: ${granted ?? true}');
      return granted ?? true;
    } catch (e) {
      _logger.e('❌ Error solicitando permisos: $e');
      return false;
    }
  }

  /// Callback cuando se toca una notificación
  static void _onNotificationResponse(NotificationResponse response) {
    _logger.i('🔔 Notificación tocada: ${response.payload}');
    if (onNotificationTap != null) {
      onNotificationTap!(response.payload);
    }
  }

  /// Programar notificación diaria de reflexión
  static Future<void> scheduleDailyReflection({
    int hour = 20, // 8 PM por defecto
    int minute = 0,
    bool enabled = true,
  }) async {
    if (!enabled) {
      await cancelNotification(dailyReflectionId);
      return;
    }

    try {
      final messages = _getDailyReflectionMessages();
      final randomMessage = messages[Random().nextInt(messages.length)];

      await _notifications.zonedSchedule(
        dailyReflectionId,
        '🌙 ¿Cómo fue tu día?',
        randomMessage,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reflection',
            'Reflexión Diaria',
            channelDescription: 'Recordatorios para reflexionar sobre tu día',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF4ECDC4),
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_reflection',
      );

      _logger.i('✅ Notificación diaria programada para las $hour:${minute.toString().padLeft(2, '0')}');
    } catch (e) {
      _logger.e('❌ Error programando notificación diaria: $e');
    }
  }

  /// Programar check-in vespertino
  static Future<void> scheduleEveningCheckIn({
    int hour = 21, // 9 PM por defecto
    int minute = 30,
    bool enabled = true,
  }) async {
    if (!enabled) {
      await cancelNotification(eveningCheckInId);
      return;
    }

    try {
      final messages = _getEveningCheckInMessages();
      final randomMessage = messages[Random().nextInt(messages.length)];

      await _notifications.zonedSchedule(
        eveningCheckInId,
        '🌟 Momento de reflexión',
        randomMessage,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'evening_checkin',
            'Check-in Vespertino',
            channelDescription: 'Recordatorios vespertinos para el bienestar',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF9B59B6),
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'evening_checkin',
      );

      _logger.i('✅ Check-in vespertino programado para las $hour:${minute.toString().padLeft(2, '0')}');
    } catch (e) {
      _logger.e('❌ Error programando check-in vespertino: $e');
    }
  }

  /// Programar recordatorio semanal
  static Future<void> scheduleWeeklyReview({
    int weekday = 7, // Domingo
    int hour = 19, // 7 PM
    int minute = 0,
    bool enabled = true,
  }) async {
    if (!enabled) {
      await cancelNotification(weeklyReviewId);
      return;
    }

    try {
      await _notifications.zonedSchedule(
        weeklyReviewId,
        '📊 Revisión Semanal',
        '¡Es momento de revisar tu progreso de la semana!',
        _nextInstanceOfWeekday(weekday, hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'weekly_review',
            'Revisión Semanal',
            channelDescription: 'Recordatorios semanales para revisar progreso',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF45B7D1),
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'weekly_review',
      );

      _logger.i('✅ Revisión semanal programada para los domingos a las $hour:${minute.toString().padLeft(2, '0')}');
    } catch (e) {
      _logger.e('❌ Error programando revisión semanal: $e');
    }
  }

  /// Enviar notificación motivacional instantánea
  static Future<void> sendMotivationalNotification() async {
    try {
      final messages = _getMotivationalMessages();
      final randomMessage = messages[Random().nextInt(messages.length)];

      await _notifications.show(
        motivationalId,
        '💪 ¡Tú puedes!',
        randomMessage,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'motivational',
            'Mensajes Motivacionales',
            channelDescription: 'Mensajes de motivación y ánimo',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFFFFD700),
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
        ),
        payload: 'motivational',
      );

      _logger.i('✅ Notificación motivacional enviada');
    } catch (e) {
      _logger.e('❌ Error enviando notificación motivacional: $e');
    }
  }

  /// Notificación personalizada
  static Future<void> sendCustomNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    try {
      await _notifications.show(
        id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'custom',
            'Notificaciones Personalizadas',
            channelDescription: 'Notificaciones personalizadas de la app',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF4ECDC4),
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
        ),
        payload: payload,
      );

      _logger.i('✅ Notificación personalizada enviada: $title');
    } catch (e) {
      _logger.e('❌ Error enviando notificación personalizada: $e');
    }
  }

  /// Cancelar una notificación específica
  static Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      _logger.i('✅ Notificación $id cancelada');
    } catch (e) {
      _logger.e('❌ Error cancelando notificación $id: $e');
    }
  }

  /// Cancelar todas las notificaciones
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      _logger.i('✅ Todas las notificaciones canceladas');
    } catch (e) {
      _logger.e('❌ Error cancelando todas las notificaciones: $e');
    }
  }

  /// Obtener notificaciones pendientes
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      _logger.e('❌ Error obteniendo notificaciones pendientes: $e');
      return [];
    }
  }

  /// Verificar si las notificaciones están habilitadas
  static Future<bool> areNotificationsEnabled() async {
    try {
      final status = await Permission.notification.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      _logger.e('❌ Error verificando estado de notificaciones: $e');
      return false;
    }
  }

  // ============================================================================
  // MÉTODOS PRIVADOS
  // ============================================================================

  /// Calcular próxima instancia de una hora específica
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Calcular próxima instancia de un día de la semana específico
  static tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Mensajes para reflexión diaria
  static List<String> _getDailyReflectionMessages() {
    return [
      'Tómate unos minutos para reflexionar sobre tu día 🌅',
      '¿Qué fue lo mejor de tu día hoy? ✨',
      'Es momento de registrar tus pensamientos del día 📝',
      '¿Cómo te sientes al final de este día? 😊',
      'Reflexiona sobre los momentos especiales de hoy 🌟',
      '¿Qué aprendiste hoy sobre ti mismo? 🤔',
      'Comparte tus emociones del día conmigo 💭',
      '¿Hubo algo que te hizo sonreír hoy? 😄',
      'Es hora de hacer tu reflexión diaria 🧘‍♀️',
      '¿Qué te gustaría mejorar mañana? 🌱',
    ];
  }

  /// Mensajes para check-in vespertino
  static List<String> _getEveningCheckInMessages() {
    return [
      '¿Cómo está tu energía al finalizar el día? ⚡',
      'Registra un momento positivo de hoy 🌈',
      '¿Te sientes satisfecho con tu día? 💫',
      'Comparte algo por lo que te sientes agradecido 🙏',
      '¿Qué emoción predominó en tu día? 🎭',
      'Reflexiona sobre tu bienestar de hoy 💚',
      '¿Cómo fue tu nivel de estrés hoy? 😌',
      'Comparte un pequeño logro del día 🏆',
      '¿Te cuidaste bien hoy? 💆‍♀️',
      'Prepárate para un buen descanso 🌙',
    ];
  }

  /// Mensajes motivacionales
  static List<String> _getMotivationalMessages() {
    return [
      'Cada día es una nueva oportunidad para crecer 🌱',
      'Tu bienestar mental es una prioridad 💚',
      'Pequeños pasos llevan a grandes cambios ✨',
      'Eres más fuerte de lo que piensas 💪',
      'La reflexión es el camino hacia el autoconocimiento 🧘‍♀️',
      'Cada momento de autorreflexión cuenta 🌟',
      'Tu crecimiento personal importa 📈',
      'Está bien sentir lo que sientes 🤗',
      'Eres capaz de superar cualquier desafío 🚀',
      'La constancia es la clave del progreso 🔑',
    ];
  }
}