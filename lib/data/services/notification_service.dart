// ============================================================================
// data/services/notification_service.dart - VERSIÓN CORREGIDA PARA WINDOWS
// ============================================================================

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;


class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();
  final Random _random = Random();

  bool _isInitialized = false;
  int _notificationIdCounter = 1000;

  // IDs fijos para diferentes tipos
  static const int dailyReviewNotificationId = 1;
  static const int randomCheckInBaseId = 100;

  /// Inicializar el servicio de notificaciones
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _logger.i('🔔 Inicializando servicio de notificaciones');

      // Solo inicializar en plataformas móviles
      if (!_isMobilePlatform()) {
        _logger.i('📱 Notificaciones no disponibles en esta plataforma');
        _isInitialized = true;
        return true;
      }

      // Inicializar timezone
      tz.initializeTimeZones();

      // Configuración para Android
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuración para iOS
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        defaultPresentAlert: true,
        defaultPresentSound: true,
        defaultPresentBadge: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Inicializar plugin
      final bool? result = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      if (result == true) {
        _isInitialized = true;
        _logger.i('✅ Notificaciones inicializadas correctamente');

        // Configurar notificaciones después de inicializar
        await _setupDailyNotifications();

        return true;
      } else {
        _logger.e('❌ Error inicializando notificaciones');
        return false;
      }

    } catch (e) {
      _logger.e('❌ Error en inicialización de notificaciones: $e');
      _isInitialized = true; // Marcar como inicializado para evitar errores
      return false;
    }
  }

  /// Verificar si es plataforma móvil
  bool _isMobilePlatform() {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Solicitar permisos de notificaciones
  Future<bool> requestPermissions() async {
    if (!_isMobilePlatform()) {
      _logger.i('📱 Permisos no necesarios en esta plataforma');
      return true;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final status = await Permission.notification.request();
        return status == PermissionStatus.granted;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final bool? result = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return result ?? false;
      }
      return true;
    } catch (e) {
      _logger.e('❌ Error solicitando permisos: $e');
      return false;
    }
  }

  /// Configurar todas las notificaciones diarias
  Future<void> _setupDailyNotifications() async {
    if (!_isMobilePlatform()) return;

    try {
      // Cancelar notificaciones existentes
      await cancelAllNotifications();

      // Configurar notificación nocturna (obligatoria a las 22:30)
      await _scheduleNightlyReviewReminder();

      // Configurar recordatorios aleatorios del día
      await _scheduleRandomDayCheckIns();

      _logger.i('🔔 Notificaciones diarias configuradas');
    } catch (e) {
      _logger.e('❌ Error configurando notificaciones diarias: $e');
    }
  }


  Future<void> _scheduleNightlyReviewReminder() async {
    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, 22, 30);

      // Si ya pasó la hora, programar para mañana
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'daily_review_channel',
        'Revisión Diaria',
        channelDescription: 'Recordatorio para completar la revisión del día',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // ✅ CORREGIR: Usar zonedSchedule con timezone local correcto
      await _notificationsPlugin.zonedSchedule(
        dailyReviewNotificationId,
        '🌙 Último llamado para tu día zen',
        '💫 A las 00:00 se guardará tu resumen automáticamente. ¿Has registrado todos tus momentos?',
        tz.TZDateTime(
          tz.local,
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          scheduledDate.hour,
          scheduledDate.minute,
        ),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'nightly_review',
      );

      _logger.i('🌙 Notificación nocturna programada para ${scheduledDate.hour}:${scheduledDate.minute.toString().padLeft(2, '0')}');

    } catch (e) {
      _logger.e('❌ Error programando notificación nocturna: $e');
    }
  }
  /// Programar recordatorios aleatorios durante el día
  Future<void> _scheduleRandomDayCheckIns() async {
    if (!_isMobilePlatform()) return;

    try {
      final now = DateTime.now();

      // Generar 3-5 notificaciones aleatorias por día
      final numberOfNotifications = 3 + _random.nextInt(3); // 3-5 notificaciones

      for (int i = 0; i < numberOfNotifications; i++) {
        await _scheduleRandomCheckIn(now, i);
      }

      _logger.i('🎲 $numberOfNotifications recordatorios aleatorios programados');

    } catch (e) {
      _logger.e('❌ Error programando recordatorios aleatorios: $e');
    }
  }

  /// Programar una notificación aleatoria específica
  Future<void> _scheduleRandomCheckIn(DateTime baseDate, int index) async {
    try {
      final timeWindows = [
        {'start': 9, 'end': 11},   // 9:00 - 11:00
        {'start': 12, 'end': 14},  // 12:00 - 14:00
        {'start': 15, 'end': 17},  // 15:00 - 17:00
        {'start': 18, 'end': 20},  // 18:00 - 20:00
      ];

      final window = timeWindows[index % timeWindows.length];
      final hour = (window['start'] as int) + _random.nextInt((window['end'] as int) - (window['start'] as int));
      final minute = _random.nextInt(60);

      var scheduledDate = DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);

      if (scheduledDate.isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final messages = _getRandomCheckInMessages();
      final message = messages[_random.nextInt(messages.length)];

      const androidDetails = AndroidNotificationDetails(
        'random_checkin_channel',
        'Momentos Zen',
        channelDescription: 'Recordatorios aleatorios para registrar momentos',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notificationId = randomCheckInBaseId + index;

      // ✅ CORREGIR: Usar zonedSchedule con timezone local correcto
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        message['title']!,
        message['body']!,
        tz.TZDateTime(
          tz.local,
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          scheduledDate.hour,
          scheduledDate.minute,
        ),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'random_checkin',
      );

      _logger.d('🎲 Recordatorio aleatorio #$index programado: ${scheduledDate.hour}:${scheduledDate.minute.toString().padLeft(2, '0')}');

    } catch (e) {
      _logger.e('❌ Error programando recordatorio aleatorio #$index: $e');
    }
  }
  /// Obtener mensajes aleatorios para los check-ins
  List<Map<String, String>> _getRandomCheckInMessages() {
    return [
      {
        'title': '🌸 ¿Cómo va tu día zen?',
        'body': 'Tómate un momento para registrar cómo te sientes ahora mismo.',
      },
      {
        'title': '✨ Momento de reflexión',
        'body': '¿Ha pasado algo especial en las últimas horas? Cuéntanos tu momento.',
      },
      {
        'title': '🧘‍♀️ Pausa consciente',
        'body': 'Respira profundo. ¿Qué está sucediendo en tu mundo interior?',
      },
      {
        'title': '🌟 Check-in zen',
        'body': '¿Hay algún momento que te gustaría recordar de hoy?',
      },
      {
        'title': '💫 Tu bienestar importa',
        'body': 'Registra tu estado actual. Cada momento cuenta en tu viaje zen.',
      },
      {
        'title': '🎯 Momento presente',
        'body': '¿Cómo está siendo este momento de tu día? Compártelo con tu yo del futuro.',
      },
      {
        'title': '🌈 Estado emocional',
        'body': 'Tu día está lleno de matices. ¿Cuál es el color de este momento?',
      },
      {
        'title': '🕯️ Instante de calma',
        'body': 'Detente un segundo. ¿Qué está pasando en tu corazón ahora mismo?',
      },
      {
        'title': '🦋 Transformación diaria',
        'body': 'Cada hora te transforma. ¿Cómo has cambiado desde esta mañana?',
      },
      {
        'title': '🌅 Tu historia personal',
        'body': 'Estás escribiendo la historia de hoy. ¿Qué capítulo estás viviendo ahora?',
      },
    ];
  }

  /// Manejar respuesta a notificaciones
  void _onNotificationResponse(NotificationResponse response) {
    _logger.d('🔔 Notificación tocada: ${response.payload} - Acción: ${response.actionId}');

    final payload = response.payload ?? '';
    final actionId = response.actionId ?? '';

    // TODO: Aquí puedes manejar las acciones específicas
    // Por ejemplo, navegar a pantallas específicas o abrir diálogos

    if (payload == 'nightly_review') {
      _handleNightlyReviewAction(actionId);
    } else if (payload == 'random_checkin') {
      _handleRandomCheckInAction(actionId);
    }
  }

  /// Manejar acciones de la notificación nocturna
  void _handleNightlyReviewAction(String actionId) {
    switch (actionId) {
      case 'review_now':
        _logger.i('🌙 Usuario eligió revisar ahora');
        // TODO: Navegar a daily_review_screen
        break;
      case 'add_moments':
        _logger.i('✨ Usuario eligió añadir momentos');
        // TODO: Navegar a interactive_moments_screen
        break;
      default:
        _logger.i('🌙 Notificación nocturna abierta');
        // TODO: Navegar a pantalla principal o daily_review
        break;
    }
  }

  /// Manejar acciones de check-in aleatorio
  void _handleRandomCheckInAction(String actionId) {
    switch (actionId) {
      case 'add_positive':
        _logger.i('✨ Usuario eligió añadir momento positivo');
        // TODO: Abrir quick add para momento positivo
        break;
      case 'add_negative':
        _logger.i('☁️ Usuario eligió añadir momento difícil');
        // TODO: Abrir quick add para momento difícil
        break;
      default:
        _logger.i('🎲 Check-in aleatorio abierto');
        // TODO: Navegar a interactive_moments_screen
        break;
    }
  }

  /// Enviar notificación inmediata de prueba
  Future<void> sendTestNotification() async {
    if (!_isMobilePlatform()) {
      _logger.i('📱 Notificación de prueba no disponible en esta plataforma');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Pruebas',
        channelDescription: 'Canal para notificaciones de prueba',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        _notificationIdCounter++,
        '🧪 Notificación de prueba',
        'ReflectApp está configurado correctamente. ¡Tu sistema zen funciona!',
        details,
        payload: 'test',
      );

      _logger.i('🧪 Notificación de prueba enviada');

    } catch (e) {
      _logger.e('❌ Error enviando notificación de prueba: $e');
    }
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      _logger.i('🗑️ Todas las notificaciones canceladas');
    } catch (e) {
      _logger.e('❌ Error cancelando notificaciones: $e');
    }
  }

  /// Cancelar notificación específica
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      _logger.d('🗑️ Notificación $id cancelada');
    } catch (e) {
      _logger.e('❌ Error cancelando notificación $id: $e');
    }
  }

  /// Reconfigurar notificaciones (útil para cuando cambian configuraciones)
  Future<void> reconfigureNotifications() async {
    await _setupDailyNotifications();
  }

  /// Obtener notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      _logger.e('❌ Error obteniendo notificaciones pendientes: $e');
      return [];
    }
  }

  /// Verificar si las notificaciones están habilitadas
  Future<bool> areNotificationsEnabled() async {
    if (!_isMobilePlatform()) {
      return true; // En desktop consideramos que están "habilitadas"
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return await Permission.notification.isGranted;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Simplificado para evitar errores de API
        return true; // Asumimos que están habilitadas por ahora
      }
      return false;
    } catch (e) {
      _logger.e('❌ Error verificando estado de notificaciones: $e');
      return false;
    }
  }

  /// Obtener estadísticas de notificaciones
  Future<Map<String, dynamic>> getNotificationStats() async {
    try {
      final pending = await getPendingNotifications();
      final dailyReview = pending.where((n) => n.id == dailyReviewNotificationId).length;
      final randomCheckins = pending.where((n) => n.id >= randomCheckInBaseId && n.id < randomCheckInBaseId + 10).length;

      return {
        'total_pending': pending.length,
        'daily_review_scheduled': dailyReview > 0,
        'random_checkins_scheduled': randomCheckins,
        'enabled': await areNotificationsEnabled(),
        'initialized': _isInitialized,
        'platform_supported': _isMobilePlatform(),
      };
    } catch (e) {
      _logger.e('❌ Error obteniendo estadísticas: $e');
      return {
        'total_pending': 0,
        'daily_review_scheduled': false,
        'random_checkins_scheduled': 0,
        'enabled': _isMobilePlatform(),
        'initialized': _isInitialized,
        'platform_supported': _isMobilePlatform(),
      };
    }
  }
}