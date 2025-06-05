// ============================================================================
// data/services/notification_service.dart - VERSIÓN CORREGIDA
// ============================================================================

import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();
  final Random _random = Random();

  bool _isInitialized = false;
  bool _permissionsGranted = false;
  int _notificationIdCounter = 1000;

  // IDs fijos para diferentes tipos
  static const int dailyReviewNotificationId = 1;
  static const int randomCheckInBaseId = 100;

  /// Inicializar el servicio de notificaciones
  Future<bool> initialize() async {
    if (_isInitialized) return _permissionsGranted;

    try {
      _logger.i('🔔 Inicializando servicio de notificaciones');

      // Verificar si es plataforma compatible
      if (!_isSupportedPlatform()) {
        _logger.i('📱 Notificaciones no soportadas en esta plataforma');
        _isInitialized = true;
        _permissionsGranted = false;
        return false;
      }

      // ✅ CORREGIR: Inicializar timezone correctamente
      await _initializeTimezone();

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

      // Inicializar plugin con manejo de errores mejorado
      try {
        final bool? result = await _notificationsPlugin.initialize(
          initSettings,
          onDidReceiveNotificationResponse: _onNotificationResponse,
        );

        if (result != true) {
          _logger.e('❌ Plugin de notificaciones falló en inicializar');
          _isInitialized = true;
          _permissionsGranted = false;
          return false;
        }
      } catch (e) {
        _logger.e('❌ Error inicializando plugin: $e');
        _isInitialized = true;
        _permissionsGranted = false;
        return false;
      }

      // Verificar permisos existentes
      _permissionsGranted = await _checkExistingPermissions();
      _isInitialized = true;

      _logger.i('✅ Notificaciones inicializadas - Permisos: $_permissionsGranted');
      return _permissionsGranted;

    } catch (e) {
      _logger.e('❌ Error crítico en inicialización: $e');
      _isInitialized = true;
      _permissionsGranted = false;
      return false;
    }
  }

  /// ✅ NUEVO: Inicializar timezone correctamente
  Future<void> _initializeTimezone() async {
    try {
      tz.initializeTimeZones();

      // Configurar zona horaria local
      if (Platform.isAndroid || Platform.isIOS) {
        // Para móviles, usar zona horaria del sistema
        final String timeZoneName = await _getDeviceTimeZone();
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } else {
        // Para desktop, usar UTC por defecto
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      _logger.d('🌍 Timezone configurado: ${tz.local.name}');
    } catch (e) {
      _logger.w('⚠️ Error configurando timezone, usando UTC: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  /// ✅ NUEVO: Obtener zona horaria del dispositivo
  Future<String> _getDeviceTimeZone() async {
    try {
      // Lista de zonas horarias comunes por si falla la detección
      const commonTimeZones = [
        'Europe/Madrid',     // España
        'America/New_York',  // US Este
        'America/Los_Angeles', // US Oeste
        'Europe/London',     // Reino Unido
        'UTC',              // Fallback
      ];

      // Intentar detectar automáticamente
      final now = DateTime.now();
      final offset = now.timeZoneOffset.inHours;

      // Mapear offset común a zona horaria
      String timeZone = 'UTC';
      switch (offset) {
        case 1:
          timeZone = 'Europe/Madrid';
          break;
        case 0:
          timeZone = 'Europe/London';
          break;
        case -5:
          timeZone = 'America/New_York';
          break;
        case -8:
          timeZone = 'America/Los_Angeles';
          break;
        default:
          timeZone = 'UTC';
      }

      // Verificar que la zona horaria existe
      try {
        tz.getLocation(timeZone);
        return timeZone;
      } catch (e) {
        _logger.w('⚠️ Timezone $timeZone no encontrado, usando UTC');
        return 'UTC';
      }
    } catch (e) {
      _logger.w('⚠️ Error detectando timezone: $e');
      return 'UTC';
    }
  }

  /// Verificar si es plataforma soportada
  bool _isSupportedPlatform() {
    return Platform.isAndroid || Platform.isIOS;
  }

  /// ✅ MEJORADO: Verificar permisos existentes
  Future<bool> _checkExistingPermissions() async {
    try {
      if (Platform.isAndroid) {
        // Para Android 13+ necesitamos permisos específicos
        final status = await Permission.notification.status;
        _logger.d('📱 Estado permisos Android: $status');
        return status == PermissionStatus.granted;
      } else if (Platform.isIOS) {
        // Para iOS, verificar con el plugin
        final bool? result = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
          alert: false, // No solicitar, solo verificar
          badge: false,
          sound: false,
        );
        _logger.d('📱 Permisos iOS verificados: $result');
        return result ?? false;
      }
      return false;
    } catch (e) {
      _logger.e('❌ Error verificando permisos: $e');
      return false;
    }
  }

  /// ✅ MEJORADO: Solicitar permisos con mejor manejo
  Future<bool> requestPermissions() async {
    try {
      _logger.i('🔔 Solicitando permisos de notificaciones');

      if (!_isSupportedPlatform()) {
        _logger.w('📱 Plataforma no soportada para notificaciones');
        return false;
      }

      bool granted = false;

      if (Platform.isAndroid) {
        // Solicitar permisos en Android
        final status = await Permission.notification.request();
        granted = status == PermissionStatus.granted;

        if (!granted) {
          _logger.w('⚠️ Permisos Android denegados: $status');
          if (status == PermissionStatus.permanentlyDenied) {
            _logger.i('📱 Permisos permanentemente denegados - abrir configuración');
            // TODO: Mostrar diálogo para abrir configuración
          }
        }
      } else if (Platform.isIOS) {
        // Solicitar permisos en iOS
        final bool? result = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        granted = result ?? false;

        if (!granted) {
          _logger.w('⚠️ Permisos iOS denegados');
        }
      }

      _permissionsGranted = granted;

      if (granted) {
        _logger.i('✅ Permisos otorgados - configurando notificaciones');
        await _setupDailyNotifications();
      } else {
        _logger.w('❌ Permisos denegados - no se configurarán notificaciones');
      }

      return granted;
    } catch (e) {
      _logger.e('❌ Error solicitando permisos: $e');
      return false;
    }
  }

  /// ✅ MEJORADO: Configurar notificaciones con mejor manejo de errores
  Future<void> _setupDailyNotifications() async {
    if (!_permissionsGranted) {
      _logger.w('⚠️ No hay permisos para configurar notificaciones');
      return;
    }

    try {
      _logger.i('🔄 Configurando notificaciones diarias...');

      // Cancelar notificaciones existentes
      await cancelAllNotifications();

      // Configurar notificación nocturna
      final nightlySuccess = await _scheduleNightlyReviewReminder();

      // Configurar recordatorios aleatorios
      final randomSuccess = await _scheduleRandomDayCheckIns();

      _logger.i('✅ Notificaciones configuradas - Nocturna: $nightlySuccess, Aleatorias: $randomSuccess');

    } catch (e) {
      _logger.e('❌ Error configurando notificaciones diarias: $e');
      throw e; // Re-lanzar para que el caller pueda manejar el error
    }
  }

  /// ✅ CORREGIDO: Programar notificación nocturna con manejo de errores
  Future<bool> _scheduleNightlyReviewReminder() async {
    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, 22, 30);

      // Si ya pasó la hora, programar para mañana
      if (scheduledDate.isBefore(now.add(const Duration(minutes: 5)))) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // ✅ CORREGIR: Crear TZDateTime correctamente
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      const androidDetails = AndroidNotificationDetails(
        'daily_review_channel',
        'Revisión Diaria',
        channelDescription: 'Recordatorio para completar la revisión del día',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
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

      await _notificationsPlugin.zonedSchedule(
        dailyReviewNotificationId,
        '🌙 Último llamado para tu día zen',
        '💫 A las 00:00 se guardará tu resumen automáticamente. ¿Has registrado todos tus momentos?',
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'nightly_review',
        matchDateTimeComponents: DateTimeComponents.time, // ✅ AÑADIR: Repetir diariamente
      );

      _logger.i('🌙 Notificación nocturna programada para ${scheduledDate.hour}:${scheduledDate.minute.toString().padLeft(2, '0')}');
      return true;

    } catch (e) {
      _logger.e('❌ Error programando notificación nocturna: $e');
      return false;
    }
  }

  /// ✅ CORREGIDO: Programar recordatorios aleatorios con mejor manejo
  Future<bool> _scheduleRandomDayCheckIns() async {
    try {
      final now = DateTime.now();
      int successCount = 0;

      // Generar 3-5 notificaciones aleatorias por día
      final numberOfNotifications = 3 + _random.nextInt(3);

      for (int i = 0; i < numberOfNotifications; i++) {
        final success = await _scheduleRandomCheckIn(now, i);
        if (success) successCount++;
      }

      _logger.i('🎲 $successCount/$numberOfNotifications recordatorios aleatorios configurados');
      return successCount > 0;

    } catch (e) {
      _logger.e('❌ Error programando recordatorios aleatorios: $e');
      return false;
    }
  }

  /// ✅ CORREGIDO: Programar notificación aleatoria individual
  Future<bool> _scheduleRandomCheckIn(DateTime baseDate, int index) async {
    try {
      // Ventanas de tiempo más amplias
      final timeWindows = [
        {'start': 9, 'end': 11, 'name': 'mañana'},
        {'start': 13, 'end': 15, 'name': 'tarde'},
        {'start': 16, 'end': 18, 'name': 'tarde'},
        {'start': 19, 'end': 21, 'name': 'noche'},
      ];

      final window = timeWindows[index % timeWindows.length];
      final hour = (window['start'] as int) + _random.nextInt((window['end'] as int) - (window['start'] as int));
      final minute = _random.nextInt(60);

      var scheduledDate = DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);

      // Si ya pasó, programar para mañana
      if (scheduledDate.isBefore(DateTime.now().add(const Duration(minutes: 10)))) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // ✅ CORREGIR: Crear TZDateTime correctamente
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      final messages = _getRandomCheckInMessages();
      final message = messages[_random.nextInt(messages.length)];

      const androidDetails = AndroidNotificationDetails(
        'random_checkin_channel',
        'Momentos Zen',
        channelDescription: 'Recordatorios aleatorios para registrar momentos',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
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

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        message['title']!,
        message['body']!,
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'random_checkin',
        matchDateTimeComponents: DateTimeComponents.time, // ✅ AÑADIR: Repetir diariamente
      );

      _logger.d('🎲 Recordatorio #$index programado: ${window['name']} ${scheduledDate.hour}:${scheduledDate.minute.toString().padLeft(2, '0')}');
      return true;

    } catch (e) {
      _logger.e('❌ Error programando recordatorio #$index: $e');
      return false;
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
    ];
  }

  /// Manejar respuesta a notificaciones
  void _onNotificationResponse(NotificationResponse response) {
    _logger.d('🔔 Notificación tocada: ${response.payload}');
    // TODO: Implementar navegación según el payload
  }

  /// ✅ MEJORADO: Enviar notificación de prueba con mejor feedback
  Future<bool> sendTestNotification() async {
    try {
      if (!_permissionsGranted) {
        _logger.w('⚠️ No hay permisos para enviar notificación de prueba');
        return false;
      }

      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Pruebas',
        channelDescription: 'Canal para notificaciones de prueba',
        importance: Importance.high,
        priority: Priority.high,
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
        'ReflectApp está configurado correctamente. ¡Tu sistema zen funciona! ${DateTime.now().toString().substring(11, 19)}',
        details,
        payload: 'test',
      );

      _logger.i('🧪 Notificación de prueba enviada');
      return true;

    } catch (e) {
      _logger.e('❌ Error enviando notificación de prueba: $e');
      return false;
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

  /// ✅ NUEVO: Reconfigurar notificaciones (método público)
  Future<bool> reconfigureNotifications() async {
    try {
      if (!_permissionsGranted) {
        _logger.w('⚠️ No hay permisos para reconfigurar notificaciones');
        return false;
      }

      _logger.i('🔄 Reconfigurando notificaciones...');
      await _setupDailyNotifications();
      return true;
    } catch (e) {
      _logger.e('❌ Error reconfigurando notificaciones: $e');
      return false;
    }
  }

  /// Verificar si las notificaciones están habilitadas
  Future<bool> areNotificationsEnabled() async {
    return _permissionsGranted && _isInitialized;
  }

  /// ✅ MEJORADO: Obtener estadísticas detalladas
  Future<Map<String, dynamic>> getNotificationStats() async {
    try {
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      final dailyReview = pending.where((n) => n.id == dailyReviewNotificationId).length;
      final randomCheckins = pending.where((n) => n.id >= randomCheckInBaseId && n.id < randomCheckInBaseId + 10).length;

      // ✅ AÑADIR: Información de debug detallada
      _logger.d('📊 Estadísticas: Total=${pending.length}, Nocturna=$dailyReview, Aleatorias=$randomCheckins');

      for (final notification in pending) {
        _logger.d('📋 Pendiente: ID=${notification.id}, Título="${notification.title}"');
      }

      return {
        'total_pending': pending.length,
        'daily_review_scheduled': dailyReview > 0,
        'random_checkins_scheduled': randomCheckins,
        'enabled': _permissionsGranted,
        'initialized': _isInitialized,
        'platform_supported': _isSupportedPlatform(),
        'timezone': tz.local.name,
        'pending_details': pending.map((n) => {
          'id': n.id,
          'title': n.title,
          'body': n.body,
        }).toList(),
      };
    } catch (e) {
      _logger.e('❌ Error obteniendo estadísticas: $e');
      return {
        'total_pending': 0,
        'daily_review_scheduled': false,
        'random_checkins_scheduled': 0,
        'enabled': false,
        'initialized': _isInitialized,
        'platform_supported': _isSupportedPlatform(),
        'error': e.toString(),
      };
    }
  }
}