// ============================================================================
// presentation/providers/notifications_provider.dart - PROVIDER DE NOTIFICACIONES
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

  // Getters
  bool get isEnabled => _isEnabled;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get stats => _stats;
  String? get errorMessage => _errorMessage;

  /// Inicializar provider de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.i('🔔 Inicializando NotificationsProvider');
    _setLoading(true);

    try {
      // Inicializar servicio
      final initialized = await _notificationService.initialize();

      if (initialized) {
        // Verificar permisos
        _isEnabled = await _notificationService.areNotificationsEnabled();

        // Obtener estadísticas
        await _updateStats();

        _isInitialized = true;
        _logger.i('✅ NotificationsProvider inicializado - Habilitado: $_isEnabled');
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

  /// Solicitar permisos de notificaciones
  Future<bool> requestPermissions() async {
    _logger.i('🔔 Solicitando permisos de notificaciones');
    _setLoading(true);
    _clearError();

    try {
      final granted = await _notificationService.requestPermissions();

      if (granted) {
        _isEnabled = true;
        await _updateStats();
        _logger.i('✅ Permisos de notificaciones otorgados');
      } else {
        _setError('Permisos de notificaciones denegados');
        _logger.w('⚠️ Permisos de notificaciones denegados');
      }

      return granted;

    } catch (e) {
      _logger.e('❌ Error solicitando permisos: $e');
      _setError('Error solicitando permisos');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Enviar notificación de prueba
  Future<void> sendTestNotification() async {
    if (!_isEnabled) {
      _setError('Las notificaciones no están habilitadas');
      return;
    }

    _setLoading(true);

    try {
      await _notificationService.sendTestNotification();
      _logger.i('🧪 Notificación de prueba enviada');

      // Actualizar estadísticas después de un momento
      Future.delayed(const Duration(seconds: 1), () async {
        await _updateStats();
      });

    } catch (e) {
      _logger.e('❌ Error enviando notificación de prueba: $e');
      _setError('Error enviando notificación de prueba');
    } finally {
      _setLoading(false);
    }
  }

  /// Reconfigurar todas las notificaciones
  Future<void> reconfigureNotifications() async {
    if (!_isEnabled) {
      _setError('Las notificaciones no están habilitadas');
      return;
    }

    _logger.i('🔄 Reconfigurando notificaciones');
    _setLoading(true);

    try {
      await _notificationService.reconfigureNotifications();
      await _updateStats();
      _logger.i('✅ Notificaciones reconfiguradas');

    } catch (e) {
      _logger.e('❌ Error reconfigurando notificaciones: $e');
      _setError('Error reconfigurando notificaciones');
    } finally {
      _setLoading(false);
    }
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    _logger.i('🗑️ Cancelando todas las notificaciones');
    _setLoading(true);

    try {
      await _notificationService.cancelAllNotifications();
      await _updateStats();
      _logger.i('✅ Todas las notificaciones canceladas');

    } catch (e) {
      _logger.e('❌ Error cancelando notificaciones: $e');
      _setError('Error cancelando notificaciones');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar estadísticas de notificaciones
  Future<void> _updateStats() async {
    try {
      _stats = await _notificationService.getNotificationStats();
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error actualizando estadísticas: $e');
    }
  }

  /// Actualizar estadísticas (método público)
  Future<void> updateStats() async {
    await _updateStats();
  }

  /// Verificar estado de notificaciones
  Future<void> checkNotificationStatus() async {
    try {
      _isEnabled = await _notificationService.areNotificationsEnabled();
      await _updateStats();
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error verificando estado: $e');
    }
  }

  /// Obtener información de configuración para la UI
  Map<String, dynamic> getConfigInfo() {
    if (!_isInitialized) {
      return {
        'status': 'not_initialized',
        'title': 'Configurando notificaciones...',
        'description': 'Inicializando el sistema de recordatorios zen',
        'action': null,
      };
    }

    if (!_isEnabled) {
      return {
        'status': 'disabled',
        'title': 'Notificaciones deshabilitadas',
        'description': 'Activa las notificaciones para recibir recordatorios zen durante el día',
        'action': 'enable',
      };
    }

    final dailyScheduled = _stats['daily_review_scheduled'] ?? false;
    final randomCheckins = _stats['random_checkins_scheduled'] ?? 0;

    if (!dailyScheduled || randomCheckins == 0) {
      return {
        'status': 'partially_configured',
        'title': 'Configuración incompleta',
        'description': 'Algunas notificaciones no están programadas correctamente',
        'action': 'reconfigure',
      };
    }

    return {
      'status': 'active',
      'title': 'Sistema zen activo',
      'description': 'Recibirás $randomCheckins recordatorios aleatorios y 1 notificación nocturna diaria',
      'action': null,
    };
  }

  /// Obtener mensaje de estado para la UI
  String getStatusMessage() {
    final config = getConfigInfo();
    return config['description'] as String;
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

  /// Limpiar provider
  void dispose() {
    // Limpiar recursos si es necesario
    super.dispose();
  }
}