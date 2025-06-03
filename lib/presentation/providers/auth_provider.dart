// ============================================================================
// presentation/providers/auth_provider.dart - ACTUALIZADO CON AUTO-LOGIN
// ============================================================================

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../data/models/user_model.dart';
import '../../data/services/database_service.dart';
import '../../data/services/session_service.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  final SessionService _sessionService = SessionService();
  final Logger _logger = Logger();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialized => _isInitialized;

  AuthProvider(this._databaseService);

  /// Inicializar provider - verificar auto-login
  Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.i('🔑 Inicializando AuthProvider con auto-login');
    _setLoading(true);

    try {
      // Verificar si hay sesión activa
      final hasSession = await _sessionService.hasActiveSession();

      if (hasSession) {
        final sessionData = await _sessionService.getSessionData();

        if (sessionData != null) {
          final userId = sessionData['id'] as int;

          // Obtener datos actualizados del usuario desde BD
          final user = await _databaseService.getUserById(userId);

          if (user != null) {
            _currentUser = user;
            await _sessionService.updateLastLogin();
            _logger.i('🌺 Auto-login exitoso para: ${user.name}');
          } else {
            _logger.w('⚠️ Usuario de sesión no encontrado en BD');
            await _sessionService.clearSession();
          }
        }
      } else {
        _logger.d('ℹ️ No hay sesión activa para auto-login');
      }

      _isInitialized = true;

    } catch (e) {
      _logger.e('❌ Error en inicialización: $e');
      _setError('Error inicializando sesión');
    } finally {
      _setLoading(false);
    }
  }

  /// Login de usuario con opción "recordarme"
  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    _logger.i('🔑 Intentando login para: $email (Remember: $rememberMe)');
    _setLoading(true);
    _clearError();

    try {
      final user = await _databaseService.loginUser(email, password);

      if (user != null) {
        _currentUser = user;

        // Guardar sesión si el usuario lo solicitó
        await _sessionService.saveUserSession(user, rememberMe: rememberMe);

        _logger.i('✅ Login exitoso para: ${user.name}');
        return true;
      } else {
        _setError('Credenciales incorrectas');
        _logger.w('❌ Login fallido para: $email');
        return false;
      }

    } catch (e) {
      _logger.e('❌ Error en login: $e');
      _setError('Error del sistema. Intenta de nuevo');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Registro de usuario
  Future<bool> register(String email, String password, String name, {String avatarEmoji = '🧘‍♀️'}) async {
    _logger.i('📝 Intentando registro para: $email');
    _setLoading(true);
    _clearError();

    try {
      final userId = await _databaseService.createUser(email, password, name, avatarEmoji: avatarEmoji);

      if (userId != null) {
        // Login automático después del registro
        final user = await _databaseService.getUserById(userId);
        if (user != null) {
          _currentUser = user;

          // Guardar sesión automáticamente tras registro
          await _sessionService.saveUserSession(user, rememberMe: true);

          _logger.i('✅ Registro y login exitoso para: $name');
          return true;
        }
      } else {
        _setError('Este email ya está registrado');
        _logger.w('❌ Registro fallido - email duplicado: $email');
        return false;
      }

      return false;

    } catch (e) {
      _logger.e('❌ Error en registro: $e');
      _setError('Error del sistema. Intenta de nuevo');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout completo
  Future<void> logout() async {
    _logger.i('🚪 Cerrando sesión para: ${_currentUser?.name}');

    try {
      // Limpiar sesión guardada
      await _sessionService.clearSession();

      // Limpiar estado actual
      _currentUser = null;
      _clearError();

      _logger.i('✅ Logout completado');
    } catch (e) {
      _logger.e('❌ Error en logout: $e');
    }

    notifyListeners();
  }

  /// Crear usuario de prueba para desarrollo
  Future<bool> createTestUser() async {
    _logger.i('🧪 Creando usuario de prueba');

    const email = 'zen@reflect.app';
    const password = 'reflect123';
    const name = 'Viajero Zen';

    try {
      // Intentar crear usuario (fallará si ya existe, pero está bien)
      await _databaseService.createUser(email, password, name);
    } catch (e) {
      // Ignorar error si el usuario ya existe
    }

    // Intentar login (funcionará incluso si el usuario ya existía)
    return await login(email, password, rememberMe: true);
  }

  /// Actualizar perfil de usuario
  Future<bool> updateProfile({
    String? name,
    String? avatarEmoji,
    String? bio,
    Map<String, dynamic>? preferences,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);

    try {
      final success = await _databaseService.updateUserProfile(
        _currentUser!.id!,
        name: name,
        avatarEmoji: avatarEmoji,
        bio: bio,
        preferences: preferences,
      );

      if (success) {
        // Recargar datos del usuario
        final updatedUser = await _databaseService.getUserById(_currentUser!.id!);
        if (updatedUser != null) {
          _currentUser = updatedUser;

          // Actualizar sesión guardada
          await _sessionService.saveUserSession(_currentUser!, rememberMe: true);

          _logger.i('✅ Perfil actualizado correctamente');
          return true;
        }
      }

      _setError('Error actualizando perfil');
      return false;

    } catch (e) {
      _logger.e('❌ Error actualizando perfil: $e');
      _setError('Error actualizando perfil');
      return false;
    } finally {
      _setLoading(false);
    }
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