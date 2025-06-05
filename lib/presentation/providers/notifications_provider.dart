// ============================================================================
// presentation/providers/notifications_provider.dart - SIMPLIFICADO ANDROID
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

  /// Inicializar provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.i('🔔 Inicializando NotificationsProvider');
    _setLoading(true);

    try {
      final initialized = await _notificationService.initialize();

      if (initialized) {
        _isEnabled = await _notificationService.areNotificationsEnabled();
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

  /// Solicitar permisos
  Future<bool> requestPermissions() async {
    _logger.i('🔔 Solicitando permisos');
    _setLoading(true);
    _clearError();

    try {
      final granted = await _notificationService.requestPermissions();

      if (granted) {
        _isEnabled = true;
        await _updateStats();
        _logger.i('✅ Permisos otorgados');
      } else {
        _setError('Permisos denegados');
        _logger.w('⚠️ Permisos denegados');
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
      _logger.e('❌ Error enviando prueba: $e');
      _setError('Error enviando prueba');
    } finally {
      _setLoading(false);
    }
  }

  /// Reconfigurar notificaciones
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
      _logger.e('❌ Error reconfigurando: $e');
      _setError('Error reconfigurando');
    } finally {
      _setLoading(false);
    }
  }

  /// Cancelar todas
  Future<void> cancelAllNotifications() async {
    _logger.i('🗑️ Cancelando todas las notificaciones');
    _setLoading(true);

    try {
      await _notificationService.cancelAllNotifications();
      await _updateStats();
      _logger.i('✅ Notificaciones canceladas');

    } catch (e) {
      _logger.e('❌ Error cancelando: $e');
      _setError('Error cancelando');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar estadísticas
  Future<void> _updateStats() async {
    try {
      _stats = await _notificationService.getNotificationStats();
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error actualizando estadísticas: $e');
    }
  }

  /// Actualizar estadísticas (público)
  Future<void> updateStats() async {
    await _updateStats();
  }

  /// Verificar estado
  Future<void> checkNotificationStatus() async {
    try {
      _isEnabled = await _notificationService.areNotificationsEnabled();
      await _updateStats();
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error verificando estado: $e');
    }
  }

  /// Obtener información para UI
  Map<String, dynamic> getConfigInfo() {
    if (!_isInitialized) {
      return {
        'status': 'not_initialized',
        'title': 'Configurando...',
        'description': 'Inicializando notificaciones',
        'action': null,
      };
    }

    if (!_isEnabled) {
      return {
        'status': 'disabled',
        'title': 'Notificaciones deshabilitadas',
        'description': 'Activa para recibir recordatorio nocturno',
        'action': 'enable',
      };
    }

    final hasNightly = _stats['daily_review_scheduled'] ?? false;

    if (!hasNightly) {
      return {
        'status': 'partially_configured',
        'title': 'Configuración incompleta',
        'description': 'Recordatorio nocturno no programado',
        'action': 'reconfigure',
      };
    }

    return {
      'status': 'active',
      'title': 'Sistema activo 🌙',
      'description': 'Recibirás recordatorio a las 22:30',
      'action': null,
    };
  }

  /// Helpers de estado
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