// lib/presentation/providers/notifications_provider.dart
// ============================================================================
// PROVIDER PARA GESTIÓN DE NOTIFICACIONES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/notification_service.dart';

class NotificationsProvider extends ChangeNotifier {
  final Logger _logger = Logger();

  // Estado de las notificaciones
  bool _notificationsEnabled = true;
  bool _dailyReflectionEnabled = true;
  bool _eveningCheckInEnabled = true;
  bool _weeklyReviewEnabled = true;
  bool _motivationalEnabled = false;

  // Horarios de notificaciones
  TimeOfDay _dailyReflectionTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _eveningCheckInTime = const TimeOfDay(hour: 21, minute: 30);
  TimeOfDay _weeklyReviewTime = const TimeOfDay(hour: 19, minute: 0);
  int _weeklyReviewDay = 7; // Domingo

  // Estado de carga
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get dailyReflectionEnabled => _dailyReflectionEnabled;
  bool get eveningCheckInEnabled => _eveningCheckInEnabled;
  bool get weeklyReviewEnabled => _weeklyReviewEnabled;
  bool get motivationalEnabled => _motivationalEnabled;

  TimeOfDay get dailyReflectionTime => _dailyReflectionTime;
  TimeOfDay get eveningCheckInTime => _eveningCheckInTime;
  TimeOfDay get weeklyReviewTime => _weeklyReviewTime;
  int get weeklyReviewDay => _weeklyReviewDay;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Inicializar provider
  Future<void> initialize() async {
    _logger.i('🔔 Inicializando NotificationsProvider...');
    _setLoading(true);

    try {
      await _loadPreferences();
      await _scheduleAllNotifications();
      _logger.i('✅ NotificationsProvider inicializado');
    } catch (e) {
      _logger.e('❌ Error inicializando NotificationsProvider: $e');
      _setError('Error inicializando notificaciones');
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar preferencias guardadas
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _dailyReflectionEnabled = prefs.getBool('daily_reflection_enabled') ?? true;
      _eveningCheckInEnabled = prefs.getBool('evening_checkin_enabled') ?? true;
      _weeklyReviewEnabled = prefs.getBool('weekly_review_enabled') ?? true;
      _motivationalEnabled = prefs.getBool('motivational_enabled') ?? false;

      // Cargar horarios
      final dailyHour = prefs.getInt('daily_reflection_hour') ?? 20;
      final dailyMinute = prefs.getInt('daily_reflection_minute') ?? 0;
      _dailyReflectionTime = TimeOfDay(hour: dailyHour, minute: dailyMinute);

      final eveningHour = prefs.getInt('evening_checkin_hour') ?? 21;
      final eveningMinute = prefs.getInt('evening_checkin_minute') ?? 30;
      _eveningCheckInTime = TimeOfDay(hour: eveningHour, minute: eveningMinute);

      final weeklyHour = prefs.getInt('weekly_review_hour') ?? 19;
      final weeklyMinute = prefs.getInt('weekly_review_minute') ?? 0;
      _weeklyReviewTime = TimeOfDay(hour: weeklyHour, minute: weeklyMinute);

      _weeklyReviewDay = prefs.getInt('weekly_review_day') ?? 7;

      _logger.d('✅ Preferencias de notificaciones cargadas');
    } catch (e) {
      _logger.e('❌ Error cargando preferencias: $e');
    }
  }

  /// Guardar preferencias
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('daily_reflection_enabled', _dailyReflectionEnabled);
      await prefs.setBool('evening_checkin_enabled', _eveningCheckInEnabled);
      await prefs.setBool('weekly_review_enabled', _weeklyReviewEnabled);
      await prefs.setBool('motivational_enabled', _motivationalEnabled);

      // Guardar horarios
      await prefs.setInt('daily_reflection_hour', _dailyReflectionTime.hour);
      await prefs.setInt('daily_reflection_minute', _dailyReflectionTime.minute);
      await prefs.setInt('evening_checkin_hour', _eveningCheckInTime.hour);
      await prefs.setInt('evening_checkin_minute', _eveningCheckInTime.minute);
      await prefs.setInt('weekly_review_hour', _weeklyReviewTime.hour);
      await prefs.setInt('weekly_review_minute', _weeklyReviewTime.minute);
      await prefs.setInt('weekly_review_day', _weeklyReviewDay);

      _logger.d('✅ Preferencias guardadas');
    } catch (e) {
      _logger.e('❌ Error guardando preferencias: $e');
    }
  }

  /// Programar todas las notificaciones
  Future<void> _scheduleAllNotifications() async {
    if (!_notificationsEnabled) {
      await NotificationService.cancelAllNotifications();
      return;
    }

    try {
      // Reflexión diaria
      await NotificationService.scheduleDailyReflection(
        hour: _dailyReflectionTime.hour,
        minute: _dailyReflectionTime.minute,
        enabled: _dailyReflectionEnabled,
      );

      // Check-in vespertino
      await NotificationService.scheduleEveningCheckIn(
        hour: _eveningCheckInTime.hour,
        minute: _eveningCheckInTime.minute,
        enabled: _eveningCheckInEnabled,
      );

      // Revisión semanal
      await NotificationService.scheduleWeeklyReview(
        weekday: _weeklyReviewDay,
        hour: _weeklyReviewTime.hour,
        minute: _weeklyReviewTime.minute,
        enabled: _weeklyReviewEnabled,
      );

      _logger.i('✅ Todas las notificaciones programadas');
    } catch (e) {
      _logger.e('❌ Error programando notificaciones: $e');
    }
  }

  /// Habilitar/deshabilitar notificaciones globalmente
  Future<void> setNotificationsEnabled(bool enabled) async {
    _setLoading(true);
    _clearError();

    try {
      _notificationsEnabled = enabled;
      await _savePreferences();
      await _scheduleAllNotifications();

      _logger.i('✅ Notificaciones ${enabled ? 'habilitadas' : 'deshabilitadas'}');
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error cambiando estado de notificaciones: $e');
      _setError('Error actualizando notificaciones');
    } finally {
      _setLoading(false);
    }
  }

  /// Configurar reflexión diaria
  Future<void> setDailyReflection({
    bool? enabled,
    TimeOfDay? time,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (enabled != null) _dailyReflectionEnabled = enabled;
      if (time != null) _dailyReflectionTime = time;

      await _savePreferences();

      await NotificationService.scheduleDailyReflection(
        hour: _dailyReflectionTime.hour,
        minute: _dailyReflectionTime.minute,
        enabled: _notificationsEnabled && _dailyReflectionEnabled,
      );

      _logger.i('✅ Reflexión diaria actualizada');
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error configurando reflexión diaria: $e');
      _setError('Error configurando reflexión diaria');
    } finally {
      _setLoading(false);
    }
  }

  /// Configurar check-in vespertino
  Future<void> setEveningCheckIn({
    bool? enabled,
    TimeOfDay? time,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (enabled != null) _eveningCheckInEnabled = enabled;
      if (time != null) _eveningCheckInTime = time;

      await _savePreferences();

      await NotificationService.scheduleEveningCheckIn(
        hour: _eveningCheckInTime.hour,
        minute: _eveningCheckInTime.minute,
        enabled: _notificationsEnabled && _eveningCheckInEnabled,
      );

      _logger.i('✅ Check-in vespertino actualizado');
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error configurando check-in vespertino: $e');
      _setError('Error configurando check-in vespertino');
    } finally {
      _setLoading(false);
    }
  }

  /// Configurar revisión semanal
  Future<void> setWeeklyReview({
    bool? enabled,
    TimeOfDay? time,
    int? weekday,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (enabled != null) _weeklyReviewEnabled = enabled;
      if (time != null) _weeklyReviewTime = time;
      if (weekday != null) _weeklyReviewDay = weekday;

      await _savePreferences();

      await NotificationService.scheduleWeeklyReview(
        weekday: _weeklyReviewDay,
        hour: _weeklyReviewTime.hour,
        minute: _weeklyReviewTime.minute,
        enabled: _notificationsEnabled && _weeklyReviewEnabled,
      );

      _logger.i('✅ Revisión semanal actualizada');
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error configurando revisión semanal: $e');
      _setError('Error configurando revisión semanal');
    } finally {
      _setLoading(false);
    }
  }

  /// Configurar mensajes motivacionales
  Future<void> setMotivationalMessages(bool enabled) async {
    _setLoading(true);
    _clearError();

    try {
      _motivationalEnabled = enabled;
      await _savePreferences();

      _logger.i('✅ Mensajes motivacionales ${enabled ? 'habilitados' : 'deshabilitados'}');
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error configurando mensajes motivacionales: $e');
      _setError('Error configurando mensajes motivacionales');
    } finally {
      _setLoading(false);
    }
  }

  /// Enviar mensaje motivacional ahora
  Future<void> sendMotivationalNow() async {
    if (!_notificationsEnabled || !_motivationalEnabled) {
      _setError('Las notificaciones o mensajes motivacionales están deshabilitados');
      return;
    }

    try {
      await NotificationService.sendMotivationalNotification();
      _logger.i('✅ Mensaje motivacional enviado');
    } catch (e) {
      _logger.e('❌ Error enviando mensaje motivacional: $e');
      _setError('Error enviando mensaje motivacional');
    }
  }

  /// Probar notificación
  Future<void> testNotification() async {
    try {
      await NotificationService.sendCustomNotification(
        title: '🧪 Notificación de Prueba',
        body: '¡Las notificaciones están funcionando correctamente!',
        payload: 'test',
      );
      _logger.i('✅ Notificación de prueba enviada');
    } catch (e) {
      _logger.e('❌ Error enviando notificación de prueba: $e');
      _setError('Error enviando notificación de prueba');
    }
  }

  /// Verificar estado de permisos
  Future<bool> checkPermissions() async {
    try {
      return await NotificationService.areNotificationsEnabled();
    } catch (e) {
      _logger.e('❌ Error verificando permisos: $e');
      return false;
    }
  }

  /// Obtener notificaciones pendientes
  Future<List<Map<String, dynamic>>> getPendingNotifications() async {
    try {
      final pending = await NotificationService.getPendingNotifications();
      return pending.map((notification) => {
        'id': notification.id,
        'title': notification.title,
        'body': notification.body,
        'payload': notification.payload,
      }).toList();
    } catch (e) {
      _logger.e('❌ Error obteniendo notificaciones pendientes: $e');
      return [];
    }
  }

  /// Obtener nombre del día de la semana
  String getWeekdayName(int weekday) {
    const days = [
      '', // 0 no existe
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return days[weekday] ?? 'Desconocido';
  }

  /// Formatear hora
  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Restablecer configuración por defecto
  Future<void> resetToDefaults() async {
    _setLoading(true);
    _clearError();

    try {
      _notificationsEnabled = true;
      _dailyReflectionEnabled = true;
      _eveningCheckInEnabled = true;
      _weeklyReviewEnabled = true;
      _motivationalEnabled = false;

      _dailyReflectionTime = const TimeOfDay(hour: 20, minute: 0);
      _eveningCheckInTime = const TimeOfDay(hour: 21, minute: 30);
      _weeklyReviewTime = const TimeOfDay(hour: 19, minute: 0);
      _weeklyReviewDay = 7;

      await _savePreferences();
      await _scheduleAllNotifications();

      _logger.i('✅ Configuración restablecida a valores por defecto');
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error restableciendo configuración: $e');
      _setError('Error restableciendo configuración');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener resumen de configuración
  Map<String, dynamic> getConfigurationSummary() {
    return {
      'notifications_enabled': _notificationsEnabled,
      'daily_reflection': {
        'enabled': _dailyReflectionEnabled,
        'time': formatTime(_dailyReflectionTime),
      },
      'evening_checkin': {
        'enabled': _eveningCheckInEnabled,
        'time': formatTime(_eveningCheckInTime),
      },
      'weekly_review': {
        'enabled': _weeklyReviewEnabled,
        'time': formatTime(_weeklyReviewTime),
        'day': getWeekdayName(_weeklyReviewDay),
      },
      'motivational': {
        'enabled': _motivationalEnabled,
      },
    };
  }

  // ============================================================================
  // MÉTODOS PRIVADOS
  // ============================================================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}