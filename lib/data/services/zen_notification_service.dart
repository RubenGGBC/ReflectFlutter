// ============================================================================
// data/services/zen_notification_service.dart - NUEVO ENFOQUE SIMPLIFICADO
// ============================================================================

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// Configuración simple para notificaciones
class ZenNotificationConfig {
  final bool enabled;
  final int dailyCheckInsCount;
  final int nightlyHour;
  final int nightlyMinute;
  final List<String> enabledTypes;
  final Map<String, bool> timeSlots;

  const ZenNotificationConfig({
    this.enabled = true,
    this.dailyCheckInsCount = 4,
    this.nightlyHour = 22,
    this.nightlyMinute = 30,
    this.enabledTypes = const ['checkin', 'nightly', 'motivation'],
    this.timeSlots = const {
      'morning': true,    // 9-11
      'midday': true,     // 12-14
      'afternoon': true,  // 15-17
      'evening': true,    // 18-20
    },
  });

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'dailyCheckInsCount': dailyCheckInsCount,
    'nightlyHour': nightlyHour,
    'nightlyMinute': nightlyMinute,
    'enabledTypes': enabledTypes,
    'timeSlots': timeSlots,
  };

  factory ZenNotificationConfig.fromJson(Map<String, dynamic> json) {
    return ZenNotificationConfig(
      enabled: json['enabled'] ?? true,
      dailyCheckInsCount: json['dailyCheckInsCount'] ?? 4,
      nightlyHour: json['nightlyHour'] ?? 22,
      nightlyMinute: json['nightlyMinute'] ?? 30,
      enabledTypes: List<String>.from(json['enabledTypes'] ?? ['checkin', 'nightly']),
      timeSlots: Map<String, bool>.from(json['timeSlots'] ?? {
        'morning': true,
        'midday': true,
        'afternoon': true,
        'evening': true,
      }),
    );
  }
}

/// Servicio principal de notificaciones Zen - NUEVO Y SIMPLIFICADO
class ZenNotificationService {
  static final ZenNotificationService _instance = ZenNotificationService._internal();
  factory ZenNotificationService() => _instance;
  ZenNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();
  final Random _random = Random();

  bool _initialized = false;
  ZenNotificationConfig _config = const ZenNotificationConfig();

  // IDs únicos para cada tipo
  static const int baseCheckInId = 100;
  static const int nightlyId = 1;
  static const int motivationId = 200;

  /// Inicializar servicio
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      _logger.i('🔔 Inicializando sistema de notificaciones Zen');

      // Solo funciona en móviles
      if (!_isMobile()) {
        _logger.i('💻 Plataforma desktop - notificaciones simuladas');
        _initialized = true;
        return true;
      }

      // Configurar timezone
      tz.initializeTimeZones();

      // Configuración básica
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const settings = InitializationSettings(android: android, iOS: ios);

      final result = await _plugin.initialize(settings);

      if (result == true) {
        await _loadConfig();
        _initialized = true;
        _logger.i('✅ Notificaciones Zen inicializadas');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('❌ Error inicializando notificaciones: $e');
      _initialized = true; // Evitar bucles de error
      return false;
    }
  }

  /// Solicitar permisos
  Future<bool> requestPermissions() async {
    if (!_isMobile()) return true;

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // En Android 13+ pedir permisos explícitamente
        // Por simplicidad, asumimos que están concedidos
        return true;
      } else {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        return granted ?? false;
      }
    } catch (e) {
      _logger.e('❌ Error solicitando permisos: $e');
      return false;
    }
  }

  /// Configurar todas las notificaciones según la configuración actual
  Future<bool> setupNotifications() async {
    if (!_initialized || !_config.enabled) {
      _logger.w('⚠️ Servicio no inicializado o deshabilitado');
      return false;
    }

    try {
      // Cancelar notificaciones existentes
      await cancelAll();

      int scheduled = 0;

      // 1. Configurar check-ins diarios
      if (_config.enabledTypes.contains('checkin')) {
        scheduled += await _scheduleCheckIns();
      }

      // 2. Configurar notificación nocturna
      if (_config.enabledTypes.contains('nightly')) {
        if (await _scheduleNightly()) scheduled++;
      }

      // 3. Configurar motivación matutina
      if (_config.enabledTypes.contains('motivation')) {
        if (await _scheduleMorningMotivation()) scheduled++;
      }

      _logger.i('✅ $scheduled notificaciones programadas');
      return scheduled > 0;
    } catch (e) {
      _logger.e('❌ Error configurando notificaciones: $e');
      return false;
    }
  }

  /// Programar check-ins diarios
  Future<int> _scheduleCheckIns() async {
    final timeSlots = _getAvailableTimeSlots();
    final count = _config.dailyCheckInsCount.clamp(1, timeSlots.length);

    // Seleccionar slots aleatorios
    final selectedSlots = (timeSlots.toList()..shuffle()).take(count);

    int scheduled = 0;
    for (int i = 0; i < selectedSlots.length; i++) {
      final slot = selectedSlots.elementAt(i);
      if (await _scheduleCheckIn(baseCheckInId + i, slot)) {
        scheduled++;
      }
    }

    return scheduled;
  }

  /// Obtener slots de tiempo disponibles según configuración
  List<Map<String, int>> _getAvailableTimeSlots() {
    final slots = <Map<String, int>>[];

    if (_config.timeSlots['morning'] == true) {
      slots.addAll([
        {'start': 9, 'end': 11},
        {'start': 10, 'end': 11},
      ]);
    }

    if (_config.timeSlots['midday'] == true) {
      slots.addAll([
        {'start': 12, 'end': 14},
        {'start': 13, 'end': 14},
      ]);
    }

    if (_config.timeSlots['afternoon'] == true) {
      slots.addAll([
        {'start': 15, 'end': 17},
        {'start': 16, 'end': 17},
      ]);
    }

    if (_config.timeSlots['evening'] == true) {
      slots.addAll([
        {'start': 18, 'end': 20},
        {'start': 19, 'end': 20},
      ]);
    }

    return slots;
  }

  /// Programar un check-in específico
  Future<bool> _scheduleCheckIn(int id, Map<String, int> timeSlot) async {
    try {
      final now = DateTime.now();
      final startHour = timeSlot['start']!;
      final endHour = timeSlot['end']!;

      // Hora aleatoria en el slot
      final hour = startHour + _random.nextInt(endHour - startHour);
      final minute = _random.nextInt(60);

      var scheduleTime = DateTime(now.year, now.month, now.day, hour, minute);

      // Si ya pasó, programar para mañana
      if (scheduleTime.isBefore(now)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      final message = _getRandomCheckInMessage();

      await _scheduleNotification(
        id: id,
        title: message['title']!,
        body: message['body']!,
        scheduledTime: scheduleTime,
        payload: 'checkin',
      );

      _logger.d('📱 Check-in programado: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
      return true;
    } catch (e) {
      _logger.e('❌ Error programando check-in: $e');
      return false;
    }
  }

  /// Programar notificación nocturna
  Future<bool> _scheduleNightly() async {
    try {
      final now = DateTime.now();
      var scheduleTime = DateTime(
          now.year,
          now.month,
          now.day,
          _config.nightlyHour,
          _config.nightlyMinute
      );

      if (scheduleTime.isBefore(now)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      await _scheduleNotification(
        id: nightlyId,
        title: '🌙 Último llamado zen',
        body: '⏰ Faltan 90 minutos para el nuevo día. ¿Has registrado todo lo importante?',
        scheduledTime: scheduleTime,
        payload: 'nightly',
      );

      _logger.d('🌙 Notificación nocturna programada: ${_config.nightlyHour}:${_config.nightlyMinute.toString().padLeft(2, '0')}');
      return true;
    } catch (e) {
      _logger.e('❌ Error programando notificación nocturna: $e');
      return false;
    }
  }

  /// Programar motivación matutina
  Future<bool> _scheduleMorningMotivation() async {
    try {
      final now = DateTime.now();
      final hour = 8 + _random.nextInt(2); // 8-9 AM
      final minute = _random.nextInt(60);

      var scheduleTime = DateTime(now.year, now.month, now.day, hour, minute);

      if (scheduleTime.isBefore(now)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      final motivations = _getMorningMotivations();
      final message = motivations[_random.nextInt(motivations.length)];

      await _scheduleNotification(
        id: motivationId,
        title: message['title']!,
        body: message['body']!,
        scheduledTime: scheduleTime,
        payload: 'motivation',
      );

      _logger.d('🌅 Motivación matutina programada: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
      return true;
    } catch (e) {
      _logger.e('❌ Error programando motivación: $e');
      return false;
    }
  }

  /// Método genérico para programar notificaciones
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    if (!_isMobile()) {
      _logger.d('💻 Notificación simulada: $title');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'zen_channel',
      'Momentos Zen',
      channelDescription: 'Recordatorios para registrar momentos zen',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Mensajes aleatorios para check-ins
  Map<String, String> _getRandomCheckInMessage() {
    final messages = [
      {
        'title': '🌸 ¿Cómo van las cosas?',
        'body': 'Tómate un momento para registrar tu estado actual'
      },
      {
        'title': '✨ Check-in zen',
        'body': '¿Qué momento te gustaría recordar de las últimas horas?'
      },
      {
        'title': '🧘‍♀️ Pausa consciente',
        'body': 'Respira y reflexiona: ¿cómo te sientes ahora?'
      },
      {
        'title': '💫 Estado de ánimo',
        'body': '¿Ha pasado algo especial desde tu último registro?'
      },
      {
        'title': '🌟 Momento presente',
        'body': 'Tu día está lleno de pequeños momentos importantes'
      },
    ];

    return messages[_random.nextInt(messages.length)];
  }

  /// Motivaciones matutinas
  List<Map<String, String>> _getMorningMotivations() {
    return [
      {
        'title': '🌅 ¡Buenos días, alma zen!',
        'body': 'Un nuevo día lleno de posibilidades te espera'
      },
      {
        'title': '☀️ Energía matutina',
        'body': 'Cada día es una oportunidad para crecer y reflexionar'
      },
      {
        'title': '🌱 Despertar consciente',
        'body': 'Hoy es perfecto para registrar momentos especiales'
      },
      {
        'title': '✨ Día de oportunidades',
        'body': 'Tu bienestar emocional es importante. ¡Cuídalo hoy!'
      },
    ];
  }

  /// Enviar notificación inmediata (para pruebas)
  Future<void> sendTestNotification() async {
    if (!_isMobile()) {
      _logger.i('🧪 Notificación de prueba (simulada): ¡Todo funciona!');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Pruebas',
      channelDescription: 'Notificaciones de prueba',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      999,
      '🧪 ¡Prueba exitosa!',
      'ReflectApp está configurado correctamente para notificaciones zen',
      details,
      payload: 'test',
    );

    _logger.i('🧪 Notificación de prueba enviada');
  }

  /// Actualizar configuración
  Future<void> updateConfig(ZenNotificationConfig newConfig) async {
    _config = newConfig;
    await _saveConfig();

    if (_config.enabled) {
      await setupNotifications();
      _logger.i('🔄 Configuración actualizada y notificaciones reprogramadas');
    } else {
      await cancelAll();
      _logger.i('🔕 Notificaciones deshabilitadas');
    }
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAll() async {
    if (!_isMobile()) {
      _logger.d('💻 Cancelación simulada');
      return;
    }

    await _plugin.cancelAll();
    _logger.d('🗑️ Todas las notificaciones canceladas');
  }

  /// Verificar si las notificaciones están habilitadas
  Future<bool> areEnabled() async {
    if (!_isMobile()) return true;

    // Simplificado - en un caso real verificarías permisos específicos
    return _config.enabled;
  }

  /// Obtener estadísticas
  Future<Map<String, dynamic>> getStats() async {
    try {
      final pending = _isMobile()
          ? await _plugin.pendingNotificationRequests()
          : <PendingNotificationRequest>[];

      return {
        'total_pending': pending.length,
        'config': _config.toJson(),
        'platform_supported': _isMobile(),
        'initialized': _initialized,
        'last_setup': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _logger.e('❌ Error obteniendo estadísticas: $e');
      return {
        'total_pending': 0,
        'config': _config.toJson(),
        'platform_supported': _isMobile(),
        'initialized': _initialized,
        'error': e.toString(),
      };
    }
  }

  /// Helpers privados
  bool _isMobile() {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Persistencia de configuración
  Future<void> _saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = _config.toJson();
      await prefs.setString('zen_notification_config', configJson.toString());
    } catch (e) {
      _logger.e('❌ Error guardando configuración: $e');
    }
  }

  Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configString = prefs.getString('zen_notification_config');

      if (configString != null) {
        // En un caso real parsearías el JSON correctamente
        // Por simplicidad usamos configuración por defecto
        _config = const ZenNotificationConfig();
      }
    } catch (e) {
      _logger.e('❌ Error cargando configuración: $e');
      _config = const ZenNotificationConfig();
    }
  }

  /// Getters públicos
  ZenNotificationConfig get config => _config;
  bool get isInitialized => _initialized;
}