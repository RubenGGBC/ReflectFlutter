// ============================================================================
// data/services/notification_service.dart - SOLO ANDROID FUNCIONAL
// ============================================================================

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:logger/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  bool _isInitialized = false;
  static const int dailyReviewNotificationId = 1;

  /// Inicializar el servicio SOLO para Android
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _logger.i('🔔 Inicializando notificaciones Android');

      // Solo Android
      if (defaultTargetPlatform != TargetPlatform.android) {
        _logger.i('📱 Solo Android soportado');
        _isInitialized = true;
        return true;
      }

      // Inicializar timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Madrid')); // ✅ Timezone español

      // Configuración MÍNIMA para Android
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
      );

      // Inicializar
      final bool? result = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      if (result == true) {
        _isInitialized = true;
        _logger.i('✅ Notificaciones Android inicializadas');

        // Configurar solo la notificación nocturna
        await _scheduleNightlyNotification();

        return true;
      } else {
        _logger.e('❌ Error inicializando notificaciones');
        return false;
      }

    } catch (e) {
      _logger.e('❌ Error en inicialización: $e');
      _isInitialized = true;
      return false;
    }
  }

  /// Programar SOLO la notificación de las 22:30
  Future<void> _scheduleNightlyNotification() async {
    try {
      // Cancelar notificación existente
      await _notificationsPlugin.cancel(dailyReviewNotificationId);

      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, 22, 30);

      // Si ya pasó, programar para mañana
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Configuración Android simplificada
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'daily_review',
        'Revisión Diaria',
        channelDescription: 'Recordatorio nocturno para completar el día',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      // Programar notificación
      await _notificationsPlugin.zonedSchedule(
        dailyReviewNotificationId,
        '🌙 Último llamado para tu día zen',
        '💫 A las 00:00 se guardará tu resumen automáticamente. ¿Has registrado todos tus momentos?',
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // ✅ Cambiado a inexact
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'nightly_review',
      );

      _logger.i('🌙 Notificación nocturna programada para ${scheduledDate.hour}:${scheduledDate.minute.toString().padLeft(2, '0')}');

    } catch (e) {
      _logger.e('❌ Error programando notificación nocturna: $e');
    }
  }

  /// Solicitar permisos (Android 13+)
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;

    try {
      // Para Android 13+ necesitamos permiso POST_NOTIFICATIONS
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation.requestNotificationsPermission();

        if (granted == true) {
          _logger.i('✅ Permisos de notificación otorgados');
          // Reconfigurar después de obtener permisos
          await _scheduleNightlyNotification();
          return true;
        } else {
          _logger.w('⚠️ Permisos de notificación denegados');
          return false;
        }
      }

      return true; // Para versiones anteriores de Android

    } catch (e) {
      _logger.e('❌ Error solicitando permisos: $e');
      return false;
    }
  }

  /// Enviar notificación de prueba INMEDIATA
  Future<void> sendTestNotification() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      _logger.i('📱 Solo Android soportado');
      return;
    }

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Pruebas',
        channelDescription: 'Notificaciones de prueba',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        999,
        '🧪 ¡Funciona!',
        'ReflectApp notificaciones configuradas correctamente a las ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        details,
        payload: 'test',
      );

      _logger.i('🧪 Notificación de prueba enviada');

    } catch (e) {
      _logger.e('❌ Error enviando notificación de prueba: $e');
    }
  }

  /// Reconfigurar notificaciones
  Future<void> reconfigureNotifications() async {
    await _scheduleNightlyNotification();
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

  /// Verificar si están habilitadas
  Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;

    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? enabled = await androidImplementation.areNotificationsEnabled();
        return enabled ?? false;
      }
      return false;
    } catch (e) {
      _logger.e('❌ Error verificando notificaciones: $e');
      return false;
    }
  }

  /// Obtener estadísticas
  Future<Map<String, dynamic>> getNotificationStats() async {
    try {
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      final hasNightly = pending.any((n) => n.id == dailyReviewNotificationId);

      return {
        'total_pending': pending.length,
        'daily_review_scheduled': hasNightly,
        'random_checkins_scheduled': 0, // No las usamos
        'enabled': await areNotificationsEnabled(),
        'initialized': _isInitialized,
        'platform_supported': defaultTargetPlatform == TargetPlatform.android,
      };
    } catch (e) {
      _logger.e('❌ Error obteniendo estadísticas: $e');
      return {
        'total_pending': 0,
        'daily_review_scheduled': false,
        'random_checkins_scheduled': 0,
        'enabled': false,
        'initialized': _isInitialized,
        'platform_supported': defaultTargetPlatform == TargetPlatform.android,
      };
    }
  }

  /// Manejar respuesta a notificaciones
  void _onNotificationResponse(NotificationResponse response) {
    _logger.d('🔔 Notificación tocada: ${response.payload}');

    // TODO: Aquí puedes manejar la navegación
    // Por ejemplo, abrir la app en daily_review_screen
  }
}