// ============================================================================
// presentation/providers/notifications_provider.dart - VERSIÓN CORREGIDA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../data/services/notification_service.dart';

class NotificationsProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final Logger _logger = Logger();

  bool _isEnabled = false;
  bool _isInitialized = false;
  bool _isLoading = false;
  Map<String, dynamic> _stats = {};
  String? _errorMessage;
  String? _lastOperationResult;

  // Getters
  bool get isEnabled => _isEnabled;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get stats => _stats;
  String? get errorMessage => _errorMessage;
  String? get lastOperationResult => _lastOperationResult;

  /// Inicializar provider de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.i('🔔 Inicializando NotificationsProvider...');
    _setLoading(true);
    _clearMessages();

    try {
      // Inicializar servicio
      _logger.d('🔧 Inicializando servicio de notificaciones...');
      final initialized = await _notificationService.initialize();

      if (initialized) {
        _logger.d('✅ Servicio inicializado, verificando permisos...');

        // Verificar permisos
        _isEnabled = await _notificationService.areNotificationsEnabled();
        _logger.d('🔐 Estado de permisos: $_isEnabled');

        // Obtener estadísticas iniciales
        await _updateStats();

        _isInitialized = true;
        _setOperationResult('✅ Sistema de notificaciones inicializado correctamente');
        _logger.i('✅ NotificationsProvider inicializado - Habilitado: $_isEnabled');
      } else {
        throw Exception('El servicio de notificaciones no se pudo inicializar');
      }

    } catch (e, stackTrace) {
      _logger.e('❌ Error en inicialización: $e');
      _logger.e('Stack trace: $stackTrace');
      _setError('Error configurando notificaciones: ${e.toString()}');

      // Marcar como inicializado para evitar loops infinitos
      _isInitialized = true;
      _isEnabled = false;
    } finally {
      _setLoading(false);
    }
  }

  /// Solicitar permisos de notificaciones con feedback detallado
  Future<bool> requestPermissions() async {
    _logger.i('🔔 Solicitando permisos de notificaciones...');
    _setLoading(true);
    _clearMessages();

    try {
      // Verificar si ya tenemos permisos
      if (_isEnabled) {
        _setOperationResult('ℹ️ Los permisos ya estaban otorgados');
        return true;
      }

      _logger.d('📱 Iniciando proceso de solicitud de permisos...');
      final granted = await _notificationService.requestPermissions();

      if (granted) {
        _isEnabled = true;
        _setOperationResult('✅ Permisos otorgados correctamente. Configurando notificaciones...');

        // Actualizar estadísticas para reflejar el cambio
        await _updateStats();

        _logger.i('✅ Permisos de notificaciones otorgados y configurados');
        return true;
      } else {
        _isEnabled = false;
        _setError('❌ Permisos de notificaciones denegados. Puedes cambiar esto en la configuración del dispositivo.');
        _logger.w('⚠️ Permisos de notificaciones denegados por el usuario');
        return false;
      }

    } catch (e, stackTrace) {
      _logger.e('❌ Error solicitando permisos: $e');
      _logger.e('Stack trace: $stackTrace');
      _setError('Error solicitando permisos: ${e.toString()}');
      _isEnabled = false;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Enviar notificación de prueba con mejor feedback
  Future<void> sendTestNotification() async {
    if (!_isEnabled) {
      _setError('❌ Las notificaciones no están habilitadas. Actívalas primero.');
      return;
    }

    _logger.i('🧪 Enviando notificación de prueba...');
    _setLoading(true);
    _clearMessages();

    try {
      await _notificationService.sendTestNotification();
      _setOperationResult('🧪 ¡Notificación de prueba enviada! Deberías verla en unos segundos.');
      _logger.i('🧪 Notificación de prueba enviada correctamente');

      // Actualizar estadísticas después de un momento
      Future.delayed(const Duration(seconds: 2), () async {
        if (!_isLoading) { // Solo si no hay otra operación en curso
          await _updateStats();
        }
      });

    } catch (e, stackTrace) {
      _logger.e('❌ Error enviando notificación de prueba: $e');
      _logger.e('Stack trace: $stackTrace');
      _setError('Error enviando notificación de prueba: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Reconfigurar todas las notificaciones con feedback detallado
  Future<void> reconfigureNotifications() async {
    if (!_isEnabled) {
      _setError('❌ Las notificaciones no están habilitadas. Actívalas primero.');
      return;
    }

    _logger.i('🔄 Reconfigurando todas las notificaciones...');
    _setLoading(true);
    _clearMessages();

    try {
      await _notificationService.reconfigureNotifications();

      // Actualizar estadísticas para verificar que todo se configuró bien
      await _updateStats();

      final randomCount = _stats['random_checkins_scheduled'] ?? 0;
      final dailyScheduled = _stats['daily_review_scheduled'] ?? false;

      if (dailyScheduled && randomCount > 0) {
        _setOperationResult('✅ Notificaciones reconfiguradas: $randomCount recordatorios aleatorios + 1 nocturna programados');
      } else {
        _setError('⚠️ Configuración incompleta: Nocturna=${dailyScheduled ? "OK" : "FALLO"}, Aleatorias=${randomCount}');
      }

      _logger.i('✅ Notificaciones reconfiguradas - Nocturna: $dailyScheduled, Aleatorias: $randomCount');

    } catch (e, stackTrace) {
      _logger.e('❌ Error reconfigurando notificaciones: $e');
      _logger.e('Stack trace: $stackTrace');
      _setError('Error reconfigurando notificaciones: ${e.toString()}');

      // Intentar obtener estadísticas para debugging
      try {
        await _updateStats();
      } catch (statsError) {
        _logger.e('❌ Error adicional obteniendo estadísticas: $statsError');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Cancelar todas las notificaciones con confirmación
  Future<void> cancelAllNotifications() async {
    _logger.i('🗑️ Cancelando todas las notificaciones...');
    _setLoading(true);
    _clearMessages();

    try {
      await _notificationService.cancelAllNotifications();

      // Verificar que realmente se cancelaron
      await _updateStats();

      final totalPending = _stats['total_pending'] ?? 0;
      if (totalPending == 0) {
        _setOperationResult('✅ Todas las notificaciones han sido canceladas correctamente');
      } else {
        _setError('⚠️ Algunas notificaciones podrían no haberse cancelado (pendientes: $totalPending)');
      }

      _logger.i('✅ Proceso de cancelación completado - Pendientes restantes: $totalPending');

    } catch (e, stackTrace) {
      _logger.e('❌ Error cancelando notificaciones: $e');
      _logger.e('Stack trace: $stackTrace');
      _setError('Error cancelando notificaciones: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar estadísticas con mejor error handling
  Future<void> _updateStats() async {
    try {
      _logger.d('📊 Actualizando estadísticas de notificaciones...');
      final newStats = await _notificationService.getNotificationStats();

      // Log detallado de las estadísticas para debugging
      _logger.d('📊 Estadísticas recibidas: $newStats');

      _stats = newStats;
      notifyListeners();

    } catch (e, stackTrace) {
      _logger.e('❌ Error actualizando estadísticas: $e');
      _logger.e('Stack trace: $stackTrace');

      // Proporcionar estadísticas por defecto en caso de error
      _stats = {
        'total_pending': 0,
        'daily_review_scheduled': false,
        'random_checkins_scheduled': 0,
        'enabled': _isEnabled,
        'initialized': _isInitialized,
        'error': 'Error obteniendo estadísticas: ${e.toString()}',
      };
      notifyListeners();
    }
  }

  /// Actualizar estadísticas (método público)
  Future<void> updateStats() async {
    if (_isLoading) {
      _logger.w('⚠️ Ya hay una operación en curso, saltando actualización de estadísticas');
      return;
    }

    _setLoading(true);
    await _updateStats();
    _setLoading(false);
  }

  /// Verificar estado de notificaciones con refresco completo
  Future<void> checkNotificationStatus() async {
    _logger.d('🔍 Verificando estado completo de notificaciones...');
    _setLoading(true);
    _clearMessages();

    try {
      _isEnabled = await _notificationService.areNotificationsEnabled();
      await _updateStats();

      _setOperationResult('🔍 Estado verificado correctamente');
      _logger.d('🔍 Verificación completada - Habilitado: $_isEnabled');

    } catch (e) {
      _logger.e('❌ Error verificando estado: $e');
      _setError('Error verificando estado: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener información de configuración mejorada para la UI
  Map<String, dynamic> getConfigInfo() {
    if (!_isInitialized) {
      return {
        'status': 'not_initialized',
        'title': 'Configurando sistema...',
        'description': 'Inicializando el sistema de recordatorios zen',
        'action': null,
        'color': 'orange',
      };
    }

    if (!_isEnabled) {
      return {
        'status': 'disabled',
        'title': 'Notificaciones deshabilitadas',
        'description': 'Activa las notificaciones para recibir recordatorios zen durante el día',
        'action': 'enable',
        'color': 'red',
      };
    }

    final dailyScheduled = _stats['daily_review_scheduled'] ?? false;
    final randomCheckins = _stats['random_checkins_scheduled'] ?? 0;

    if (!dailyScheduled || randomCheckins == 0) {
      return {
        'status': 'partially_configured',
        'title': 'Configuración incompleta',
        'description': 'Nocturna: ${dailyScheduled ? "✅" : "❌"} | Aleatorias: $randomCheckins',
        'action': 'reconfigure',
        'color': 'orange',
      };
    }

    return {
      'status': 'active',
      'title': 'Sistema zen activo',
      'description': '$randomCheckins recordatorios aleatorios + 1 notificación nocturna configurados',
      'action': null,
      'color': 'green',
    };
  }

  /// Obtener mensaje de estado detallado
  String getStatusMessage() {
    final config = getConfigInfo();
    final description = config['description'] as String;

    if (_lastOperationResult != null) {
      return _lastOperationResult!;
    }

    if (_errorMessage != null) {
      return _errorMessage!;
    }

    return description;
  }

  /// Verificar si necesita acción del usuario
  bool needsUserAction() {
    final config = getConfigInfo();
    return config['action'] != null;
  }

  /// Obtener acción sugerida
  String? getSuggestedAction() {
    final config = getConfigInfo();
    return config['action'] as String?;
  }

  /// Obtener diagnóstico detallado para debugging
  Map<String, dynamic> getDiagnosticInfo() {
    return {
      'provider_state': {
        'is_initialized': _isInitialized,
        'is_enabled': _isEnabled,
        'is_loading': _isLoading,
        'error_message': _errorMessage,
        'last_operation_result': _lastOperationResult,
      },
      'stats': _stats,
      'config_info': getConfigInfo(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Helpers para manejar estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _lastOperationResult = null;
    _logger.w('⚠️ Error en provider: $error');
    notifyListeners();
  }

  void _setOperationResult(String result) {
    _lastOperationResult = result;
    _errorMessage = null;
    _logger.i('ℹ️ Resultado de operación: $result');
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _lastOperationResult = null;
    notifyListeners();
  }

  /// Limpiar provider
  @override
  void dispose() {
    _logger.d('🧹 Limpiando NotificationsProvider');
    super.dispose();
  }
}