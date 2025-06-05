// ============================================================================
// data/services/notification_service.dart - SOLUCIÓN ESPECÍFICA ANDROID
// ============================================================================

import 'dart:io';
import 'dart:math';
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
  bool _hasPermissions = false;
  int _notificationIdCounter = 1000;

  // IDs fijos para diferentes tipos
  static const int dailyReviewNotificationId = 1;
  static const int randomCheckInBaseId = 100;

  /// Inicializar el servicio con enfoque específico en Android
  Future<bool> initialize() async {
    if (_isInitialized) return _hasPermissions;

    try {
      _logger.i('🔔 [INIT] Iniciando NotificationService...');

      if (!_isMobilePlatform()) {
        _logger.i('💻 [INIT] Plataforma desktop - simulando éxito');
        _isInitialized = true;
        _hasPermissions = true;
        return true;
      }

      // ✅ PASO 1: Inicializar timezone con fallback robusto
      await _initializeTimezoneRobust();

      // ✅ PASO 2: Configurar notificaciones básicas
      await _initializeNotificationPlugin();

      // ✅ PASO 3: Verificar y solicitar TODOS los permisos necesarios
      await _requestAllRequiredPermissions();

      _isInitialized = true;
      _logger.i('✅ [INIT] NotificationService inicializado correctamente');

      return _hasPermissions;

    } catch (e, stackTrace) {
      _logger.e('❌ [INIT] Error fatal: $e');
      _logger.e('[INIT] Stack trace: $stackTrace');

      _isInitialized = true;
      _hasPermissions = false;
      return false;
    }
  }

  /// ✅ MEJORADO: Configuración de timezone más robusta
  Future<void> _initializeTimezoneRobust() async {
    try {
      _logger.d('🕐 [TZ] Configurando timezone...');

      tz.initializeTimeZones();

      // ✅ CORREGIR: Usar timezone de España por defecto
      String timezoneName = 'Europe/Madrid';

      try {
        tz.setLocalLocation(tz.getLocation(timezoneName));
        _logger.i('🕐 [TZ] ✅ Timezone configurado: $timezoneName');
      } catch (e) {
        _logger.w('⚠️ [TZ] Error con $timezoneName, usando UTC: $e');
        tz.setLocalLocation(tz.getLocation('UTC'));
        timezoneName = 'UTC';
      }

      // ✅ VERIFICAR: Probar que el timezone funciona
      final now = tz.TZDateTime.now(tz.local);
      _logger.d('🕐 [TZ] Hora actual: ${now.toString()}');

    } catch (e) {
      _logger.e('❌ [TZ] Error configurando timezone: $e');
      rethrow;
    }
  }

  /// ✅ MEJORADO: Inicialización del plugin con configuración Android específica
  Future<void> _initializeNotificationPlugin() async {
    try {
      _logger.d('📱 [PLUGIN] Configurando notificaciones...');

      final InitializationSettings initSettings;

      if (Platform.isAndroid) {
        const AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
          '@mipmap/ic_launcher',
          // ✅ NUEVO: Configuraciones específicas para Android
        );

        initSettings = const InitializationSettings(
          android: androidSettings,
        );
      } else if (Platform.isIOS) {
        const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
          defaultPresentAlert: true,
          defaultPresentSound: true,
          defaultPresentBadge: true,
        );

        initSettings = const InitializationSettings(
          iOS: iosSettings,
        );
      } else {
        throw Exception('Plataforma no soportada');
      }

      final bool? result = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      if (result != true) {
        throw Exception('Plugin initialize() devolvió: $result');
      }

      _logger.i('📱 [PLUGIN] ✅ Plugin inicializado correctamente');

    } catch (e) {
      _logger.e('❌ [PLUGIN] Error: $e');
      rethrow;
    }
  }

  /// ✅ NUEVO: Solicitar TODOS los permisos necesarios paso a paso
  Future<void> _requestAllRequiredPermissions() async {
    try {
      _logger.d('🔐 [PERMS] Verificando permisos necesarios...');

      if (Platform.isAndroid) {
        await _requestAndroidPermissions();
      } else if (Platform.isIOS) {
        await _requestIOSPermissions();
      }

      _logger.i('🔐 [PERMS] Estado final: ${_hasPermissions ? "✅ OTORGADOS" : "❌ DENEGADOS"}');

    } catch (e) {
      _logger.e('❌ [PERMS] Error: $e');
      _hasPermissions = false;
      rethrow;
    }
  }

  /// ✅ MEJORADO: Permisos Android con verificación paso a paso
  Future<void> _requestAndroidPermissions() async {
    try {
      _logger.d('📱 [ANDROID] Verificando permisos Android...');

      // ✅ PASO 1: Permiso básico de notificaciones
      PermissionStatus notificationStatus = await Permission.notification.status;
      _logger.d('📱 [ANDROID] Permiso notificaciones: $notificationStatus');

      if (notificationStatus.isDenied) {
        _logger.i('📱 [ANDROID] Solicitando permiso de notificaciones...');
        notificationStatus = await Permission.notification.request();
        _logger.d('📱 [ANDROID] Resultado solicitud: $notificationStatus');
      }

      if (!notificationStatus.isGranted) {
        throw Exception('Permiso de notificaciones denegado: $notificationStatus');
      }

      // ✅ PASO 2: Permiso de alarmas exactas (Android 12+)
      await _requestExactAlarmPermission();

      // ✅ PASO 3: Verificar que el sistema Android permite notificaciones
      await _verifyAndroidNotificationSettings();

      _hasPermissions = true;
      _logger.i('📱 [ANDROID] ✅ Todos los permisos Android otorgados');

    } catch (e) {
      _logger.e('❌ [ANDROID] Error en permisos: $e');
      _hasPermissions = false;
      rethrow;
    }
  }

  /// ✅ NUEVO: Verificar permiso de alarmas exactas
  Future<void> _requestExactAlarmPermission() async {
    try {
      _logger.d('⏰ [EXACT] Verificando permiso de alarmas exactas...');

      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      _logger.d('⏰ [EXACT] Estado: $exactAlarmStatus');

      if (exactAlarmStatus.isDenied) {
        _logger.i('⏰ [EXACT] Solicitando permiso de alarmas exactas...');
        final result = await Permission.scheduleExactAlarm.request();
        _logger.d('⏰ [EXACT] Resultado: $result');
      }

      // ✅ IMPORTANTE: Este permiso es crítico para notificaciones programadas
      final finalStatus = await Permission.scheduleExactAlarm.status;
      if (!finalStatus.isGranted) {
        _logger.w('⚠️ [EXACT] Permiso de alarmas exactas no otorgado - las notificaciones podrían no funcionar');
      }

    } catch (e) {
      _logger.w('⚠️ [EXACT] Error verificando alarmas exactas: $e');
      // No es crítico, continuar
    }
  }

  /// ✅ NUEVO: Verificar configuración del sistema Android
  Future<void> _verifyAndroidNotificationSettings() async {
    try {
      _logger.d('🔍 [VERIFY] Verificando configuración del sistema...');

      // Verificar que el plugin puede crear canales
      if (Platform.isAndroid) {
        await _createNotificationChannels();
      }

      _logger.i('🔍 [VERIFY] ✅ Configuración del sistema verificada');

    } catch (e) {
      _logger.e('❌ [VERIFY] Error verificando sistema: $e');
      rethrow;
    }
  }

  /// ✅ NUEVO: Crear canales de notificación explícitamente
  Future<void> _createNotificationChannels() async {
    try {
      _logger.d('📺 [CHANNELS] Creando canales de notificación...');

      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation == null) {
        throw Exception('No se pudo obtener implementación Android');
      }

      // Canal para notificación nocturna
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_review_channel',
          'Revisión Diaria',
          description: 'Recordatorio nocturno para completar el día',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Canal para recordatorios aleatorios
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'random_checkin_channel',
          'Momentos Zen',
          description: 'Recordatorios aleatorios durante el día',
          importance: Importance.defaultImportance,
          playSound: true,
          enableVibration: false,
        ),
      );

      // Canal para pruebas
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'test_channel',
          'Pruebas',
          description: 'Canal para notificaciones de prueba',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      _logger.i('📺 [CHANNELS] ✅ Canales creados correctamente');

    } catch (e) {
      _logger.e('❌ [CHANNELS] Error creando canales: $e');
      rethrow;
    }
  }

  /// Permisos iOS
  Future<void> _requestIOSPermissions() async {
    try {
      _logger.d('🍎 [IOS] Solicitando permisos iOS...');

      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      _hasPermissions = result ?? false;
      _logger.i('🍎 [IOS] ${_hasPermissions ? "✅ OTORGADOS" : "❌ DENEGADOS"}');

    } catch (e) {
      _logger.e('❌ [IOS] Error: $e');
      _hasPermissions = false;
      rethrow;
    }
  }

  /// ✅ MEJORADO: Reconfigurar con verificación exhaustiva
  Future<void> reconfigureNotifications() async {
    if (!_hasPermissions) {
      throw Exception('No hay permisos para configurar notificaciones');
    }

    try {
      _logger.i('🔄 [RECONFIG] Iniciando reconfiguración...');

      // ✅ PASO 1: Limpiar completamente
      await _clearAllNotificationsCompletely();

      // ✅ PASO 2: Esperar un momento para que el sistema procese
      await Future.delayed(const Duration(milliseconds: 1000));

      // ✅ PASO 3: Programar notificación nocturna con verificación
      final nightlyResult = await _scheduleNightlyWithVerification();

      // ✅ PASO 4: Programar recordatorios aleatorios con verificación
      final randomResult = await _scheduleRandomWithVerification();

      // ✅ PASO 5: Verificar resultado final
      await Future.delayed(const Duration(milliseconds: 500));
      final finalStats = await getNotificationStats();

      _logger.i('🔄 [RECONFIG] Resultado final:');
      _logger.i('   🌙 Nocturna: ${nightlyResult ? "✅" : "❌"}');
      _logger.i('   🎲 Aleatorias: ${randomResult ? "✅" : "❌"}');
      _logger.i('   📊 Pendientes: ${finalStats["total_pending"]}');

      if (!nightlyResult || !randomResult) {
        throw Exception('Error en configuración: Nocturna=$nightlyResult, Aleatorias=$randomResult');
      }

      _logger.i('✅ [RECONFIG] Reconfiguración exitosa');

    } catch (e, stackTrace) {
      _logger.e('❌ [RECONFIG] Error: $e');
      _logger.e('[RECONFIG] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// ✅ NUEVO: Limpiar completamente con verificación
  Future<void> _clearAllNotificationsCompletely() async {
    try {
      _logger.d('🗑️ [CLEAR] Limpiando todas las notificaciones...');

      await _notificationsPlugin.cancelAll();

      // Verificar que se limpiaron
      await Future.delayed(const Duration(milliseconds: 500));
      final pending = await _notificationsPlugin.pendingNotificationRequests();

      if (pending.isNotEmpty) {
        _logger.w('⚠️ [CLEAR] Aún quedan ${pending.length} notificaciones pendientes');

        // Cancelar una por una si es necesario
        for (final notification in pending) {
          await _notificationsPlugin.cancel(notification.id);
        }
      }

      _logger.i('🗑️ [CLEAR] ✅ Limpieza completada');

    } catch (e) {
      _logger.e('❌ [CLEAR] Error: $e');
      rethrow;
    }
  }

  /// ✅ NUEVO: Programar notificación nocturna con verificación
  Future<bool> _scheduleNightlyWithVerification() async {
    try {
      _logger.i('🌙 [NIGHTLY] Programando notificación nocturna...');

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 22, 30);

      // Si ya pasó, programar para mañana
      if (scheduledDate.isBefore(now.add(const Duration(minutes: 5)))) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      _logger.d('🌙 [NIGHTLY] Fecha programada: $scheduledDate');

      // ✅ CONFIGURACIÓN ESPECÍFICA ANDROID
      const androidDetails = AndroidNotificationDetails(
        'daily_review_channel',
        'Revisión Diaria',
        channelDescription: 'Recordatorio nocturno para completar el día',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        // ✅ NUEVO: Configuraciones adicionales para Android
        ongoing: false,
        autoCancel: true,
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

      // ✅ PROGRAMAR CON ERROR HANDLING ESPECÍFICO
      await _notificationsPlugin.zonedSchedule(
        dailyReviewNotificationId,
        '🌙 Último llamado para tu día zen',
        '💫 A las 00:00 se guardará tu resumen automáticamente. ¿Has registrado todos tus momentos?',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'nightly_review',
      );

      // ✅ VERIFICAR QUE SE PROGRAMÓ
      await Future.delayed(const Duration(milliseconds: 500));
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      final nightlyExists = pending.any((n) => n.id == dailyReviewNotificationId);

      if (nightlyExists) {
        _logger.i('🌙 [NIGHTLY] ✅ Notificación nocturna programada correctamente');
        return true;
      } else {
        _logger.e('🌙 [NIGHTLY] ❌ Notificación nocturna NO aparece en pendientes');
        return false;
      }

    } catch (e, stackTrace) {
      _logger.e('❌ [NIGHTLY] Error: $e');
      _logger.e('[NIGHTLY] Stack trace: $stackTrace');
      return false;
    }
  }

  /// ✅ NUEVO: Programar aleatorias con verificación
  Future<bool> _scheduleRandomWithVerification() async {
    try {
      _logger.i('🎲 [RANDOM] Programando recordatorios aleatorios...');

      final numberOfNotifications = 3 + _random.nextInt(3); // 3-5
      int successCount = 0;

      for (int i = 0; i < numberOfNotifications; i++) {
        final success = await _scheduleOneRandomNotification(i);
        if (success) successCount++;

        // Pausa entre programaciones
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // ✅ VERIFICAR RESULTADO
      await Future.delayed(const Duration(milliseconds: 500));
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      final randomCount = pending.where((n) =>
      n.id >= randomCheckInBaseId && n.id < randomCheckInBaseId + 10).length;

      _logger.i('🎲 [RANDOM] Programados: $successCount/$numberOfNotifications, Verificados: $randomCount');

      return randomCount > 0;

    } catch (e, stackTrace) {
      _logger.e('❌ [RANDOM] Error: $e');
      _logger.e('[RANDOM] Stack trace: $stackTrace');
      return false;
    }
  }

  /// ✅ NUEVO: Programar una notificación aleatoria individual
  Future<bool> _scheduleOneRandomNotification(int index) async {
    try {
      final timeWindows = [
        {'start': 9, 'end': 11},
        {'start': 12, 'end': 14},
        {'start': 15, 'end': 17},
        {'start': 18, 'end': 20},
        {'start': 20, 'end': 22},
      ];

      final window = timeWindows[index % timeWindows.length];
      final hour = (window['start'] as int) + _random.nextInt((window['end'] as int) - (window['start'] as int));
      final minute = _random.nextInt(60);

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

      if (scheduledDate.isBefore(now.add(const Duration(minutes: 10)))) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final messages = _getRandomCheckInMessages();
      final message = messages[_random.nextInt(messages.length)];

      const androidDetails = AndroidNotificationDetails(
        'random_checkin_channel',
        'Momentos Zen',
        channelDescription: 'Recordatorios aleatorios durante el día',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        enableVibration: false,
        playSound: true,
        ongoing: false,
        autoCancel: true,
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
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'random_checkin',
      );

      _logger.d('🎲 [RANDOM] Aleatorio #${index + 1} programado para ${scheduledDate.hour}:${scheduledDate.minute.toString().padLeft(2, '0')}');
      return true;

    } catch (e) {
      _logger.e('❌ [RANDOM] Error en aleatorio #${index + 1}: $e');
      return false;
    }
  }

  /// Solicitar permisos (método público)
  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_hasPermissions) {
      _logger.i('🔐 [REQ] Permisos ya otorgados, reconfigurando...');
      await reconfigureNotifications();
      return true;
    }

    await _requestAllRequiredPermissions();

    if (_hasPermissions) {
      await reconfigureNotifications();
    }

    return _hasPermissions;
  }

  /// Enviar notificación de prueba
  Future<void> sendTestNotification() async {
    if (!_hasPermissions) {
      throw Exception('No hay permisos para enviar notificaciones');
    }

    try {
      _logger.i('🧪 [TEST] Enviando notificación de prueba...');

      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Pruebas',
        channelDescription: 'Canal para notificaciones de prueba',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
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
        '🧪 ¡Prueba exitosa!',
        'ReflectApp funciona perfectamente. Sistema zen activado 🌟',
        details,
        payload: 'test',
      );

      _logger.i('🧪 [TEST] ✅ Notificación de prueba enviada');

    } catch (e, stackTrace) {
      _logger.e('❌ [TEST] Error: $e');
      _logger.e('[TEST] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Verificar si las notificaciones están habilitadas
  Future<bool> areNotificationsEnabled() async {
    if (!_isMobilePlatform()) return true;
    return _isInitialized && _hasPermissions;
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _clearAllNotificationsCompletely();
  }

  /// Obtener estadísticas detalladas
  Future<Map<String, dynamic>> getNotificationStats() async {
    try {
      final pending = _isMobilePlatform()
          ? await _notificationsPlugin.pendingNotificationRequests()
          : <PendingNotificationRequest>[];

      final dailyReview = pending.where((n) => n.id == dailyReviewNotificationId).length;
      final randomCheckins = pending.where((n) =>
      n.id >= randomCheckInBaseId && n.id < randomCheckInBaseId + 10).length;

      final stats = {
        'total_pending': pending.length,
        'daily_review_scheduled': dailyReview > 0,
        'random_checkins_scheduled': randomCheckins,
        'enabled': await areNotificationsEnabled(),
        'initialized': _isInitialized,
        'has_permissions': _hasPermissions,
        'platform_supported': _isMobilePlatform(),
        'pending_details': pending.map((p) => {
          'id': p.id,
          'title': p.title,
          'body': p.body,
        }).toList(),
        'debug_info': {
          'timezone': tz.local.name,
          'current_time': tz.TZDateTime.now(tz.local).toString(),
          'platform': Platform.operatingSystem,
        },
      };

      _logger.d('📊 [STATS] $stats');
      return stats;

    } catch (e, stackTrace) {
      _logger.e('❌ [STATS] Error: $e');
      _logger.e('[STATS] Stack trace: $stackTrace');
      return {
        'total_pending': 0,
        'daily_review_scheduled': false,
        'random_checkins_scheduled': 0,
        'enabled': false,
        'initialized': _isInitialized,
        'has_permissions': _hasPermissions,
        'platform_supported': _isMobilePlatform(),
        'error': e.toString(),
      };
    }
  }

  /// Verificar si es plataforma móvil
  bool _isMobilePlatform() {
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  }

  /// Mensajes para check-ins aleatorios
  List<Map<String, String>> _getRandomCheckInMessages() {
    return [
      {'title': '🌸 ¿Cómo va tu día zen?', 'body': 'Registra cómo te sientes ahora mismo.'},
      {'title': '✨ Momento de reflexión', 'body': '¿Ha pasado algo especial? Cuéntanos.'},
      {'title': '🧘‍♀️ Pausa consciente', 'body': '¿Qué está sucediendo en tu mundo interior?'},
      {'title': '🌟 Check-in zen', 'body': '¿Hay algún momento que recordar de hoy?'},
      {'title': '💫 Tu bienestar importa', 'body': 'Cada momento cuenta en tu viaje zen.'},
      {'title': '🎯 Momento presente', 'body': '¿Cómo está siendo este momento?'},
      {'title': '🌈 Estado emocional', 'body': '¿Cuál es el color de este momento?'},
      {'title': '🕯️ Instante de calma', 'body': '¿Qué está pasando en tu corazón?'},
    ];
  }

  /// Manejar respuesta a notificaciones
  void _onNotificationResponse(NotificationResponse response) {
    _logger.d('🔔 [RESPONSE] Notificación tocada: ${response.payload}');
  }
}