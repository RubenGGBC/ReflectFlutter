// ============================================================================
// presentation/providers/zen_notification_provider.dart - PROVIDER SIMPLIFICADO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../data/services/zen_notification_service.dart';

class ZenNotificationProvider with ChangeNotifier {
  final ZenNotificationService _service = ZenNotificationService();
  final Logger _logger = Logger();

  // Estado
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _stats = {};
  ZenNotificationConfig _config = const ZenNotificationConfig();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get stats => _stats;
  ZenNotificationConfig get config => _config;
  bool get isEnabled => _config.enabled && _service.isInitialized;
  bool get isInitialized => _service.isInitialized;

  /// Inicializar provider
  Future<void> initialize() async {
    _logger.i('🔔 Inicializando ZenNotificationProvider');
    _setLoading(true);

    try {
      final success = await _service.initialize();

      if (success) {
        _config = _service.config;
        await _updateStats();
        _logger.i('✅ ZenNotificationProvider inicializado');
      } else {
        _setError('Error inicializando notificaciones');
      }
    } catch (e) {
      _logger.e('❌ Error en inicialización: $e');
      _setError('Error configurando notificaciones');
    } finally {
      _setLoading(false);
    }
  }

  /// Solicitar permisos y configurar notificaciones
  Future<bool> requestAndSetup() async {
    _setLoading(true);
    _clearError();

    try {
      // 1. Solicitar permisos
      final permissionsGranted = await _service.requestPermissions();

      if (!permissionsGranted) {
        _setError('Permisos de notificaciones denegados');
        return false;
      }

      // 2. Configurar notificaciones
      final configured = await _service.setupNotifications();

      if (configured) {
        _config = _service.config;
        await _updateStats();
        _logger.i('✅ Notificaciones configuradas correctamente');
        return true;
      } else {
        _setError('Error configurando notificaciones');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error en configuración: $e');
      _setError('Error configurando notificaciones');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Enviar notificación de prueba
  Future<void> sendTest() async {
    _setLoading(true);

    try {
      await _service.sendTestNotification();
      await _updateStats();
      _logger.i('🧪 Notificación de prueba enviada');
    } catch (e) {
      _logger.e('❌ Error enviando prueba: $e');
      _setError('Error enviando notificación de prueba');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar configuración
  Future<void> updateConfig({
    bool? enabled,
    int? dailyCheckInsCount,
    int? nightlyHour,
    int? nightlyMinute,
    List<String>? enabledTypes,
    Map<String, bool>? timeSlots,
  }) async {
    _setLoading(true);

    try {
      final newConfig = ZenNotificationConfig(
        enabled: enabled ?? _config.enabled,
        dailyCheckInsCount: dailyCheckInsCount ?? _config.dailyCheckInsCount,
        nightlyHour: nightlyHour ?? _config.nightlyHour,
        nightlyMinute: nightlyMinute ?? _config.nightlyMinute,
        enabledTypes: enabledTypes ?? _config.enabledTypes,
        timeSlots: timeSlots ?? _config.timeSlots,
      );

      await _service.updateConfig(newConfig);
      _config = newConfig;
      await _updateStats();

      _logger.i('🔄 Configuración actualizada');
    } catch (e) {
      _logger.e('❌ Error actualizando configuración: $e');
      _setError('Error actualizando configuración');
    } finally {
      _setLoading(false);
    }
  }

  /// Deshabilitar todas las notificaciones
  Future<void> disable() async {
    await updateConfig(enabled: false);
  }

  /// Habilitar notificaciones
  Future<void> enable() async {
    await updateConfig(enabled: true);
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAll() async {
    _setLoading(true);

    try {
      await _service.cancelAll();
      await _updateStats();
      _logger.i('🗑️ Notificaciones canceladas');
    } catch (e) {
      _logger.e('❌ Error cancelando: $e');
      _setError('Error cancelando notificaciones');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar estadísticas
  Future<void> _updateStats() async {
    try {
      _stats = await _service.getStats();
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error actualizando estadísticas: $e');
    }
  }

  /// Método público para actualizar estadísticas
  Future<void> refreshStats() async {
    await _updateStats();
  }

  /// Obtener estado resumido para UI
  String getStatusSummary() {
    if (!isInitialized) {
      return 'Inicializando sistema...';
    }

    if (!isEnabled) {
      return 'Notificaciones deshabilitadas';
    }

    final pending = _stats['total_pending'] ?? 0;
    return 'Sistema activo: $pending notificaciones programadas';
  }

  /// Verificar si necesita acción del usuario
  bool needsUserAction() {
    return !isEnabled && isInitialized;
  }

  /// Obtener recomendación de acción
  String? getActionRecommendation() {
    if (!isInitialized) return null;

    if (!isEnabled) {
      return 'Activa las notificaciones para recibir recordatorios zen';
    }

    final pending = _stats['total_pending'] ?? 0;
    if (pending == 0) {
      return 'Configura tus recordatorios zen';
    }

    return null;
  }

  /// Helpers para manejar estado
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
    notifyListeners();
  }
}

