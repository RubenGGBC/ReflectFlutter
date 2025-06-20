// ============================================================================
// presentation/providers/auth_provider.dart - VERSIÓN CORREGIDA COMPLETA
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

    // ✅ CORREGIDO: No llamar _setLoading inmediatamente para evitar setState durante build
    _isLoading = true;

    try {
      final hasSession = await _sessionService.hasActiveSession();

      if (hasSession) {
        final sessionData = await _sessionService.getSessionData();

        if (sessionData != null) {
          final userId = sessionData['user_id'] as int?;
          if (userId != null) {
            final user = await _databaseService.getUserById(userId);

            if (user != null) {
              _currentUser = user;
              _logger.i('✅ Auto-login exitoso para: ${user.name}');
            } else {
              _logger.w('⚠️ Usuario en sesión no encontrado en BD');
              await _sessionService.clearSession();
            }
          }
        }
      } else {
        _logger.i('ℹ️ No hay sesión activa para auto-login');
      }

      _isInitialized = true;

    } catch (e) {
      _logger.e('❌ Error en auto-login: $e');
      _errorMessage = 'Error verificando sesión';
    } finally {
      _isLoading = false;
      // ✅ CORREGIDO: Solo notificar al final cuando todo esté listo
      notifyListeners();
    }
  }

  /// Login con email y password
  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    _logger.i('🔐 Iniciando login para: $email');
    _setLoading(true);
    _clearError();

    try {
      final user = await _databaseService.loginUser(email, password);

      if (user != null) {
        _currentUser = user;

        if (rememberMe) {
          await _sessionService.saveUserSession(user, rememberMe: true);
        }

        _logger.i('✅ Login exitoso para: ${user.name}');
        return true;
      } else {
        _setError('Credenciales incorrectas');
        _logger.w('⚠️ Login falló: credenciales incorrectas');
        return false;
      }

    } catch (e) {
      _logger.e('❌ Error en login: $e');
      _setError('Error iniciando sesión. Intenta de nuevo');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Registro de nuevo usuario
  Future<bool> register({
    required String email,
    required String password,
    String? name,
    bool rememberMe = false,
  }) async {
    _logger.i('📝 Registrando usuario: $email');
    _setLoading(true);
    _clearError();

    try {
      final userId = await _databaseService.createUser(
        email,
        password,
        name ?? 'Usuario',
      );

      if (userId != null) {
        // Auto-login después del registro
        final success = await login(email, password, rememberMe: rememberMe);
        if (success) {
          _logger.i('✅ Registro y login exitoso para: $email');
          return true;
        }
      }

      _setError('Error creando la cuenta');
      return false;

    } catch (e) {
      _logger.e('❌ Error en registro: $e');
      _setError('Error creando cuenta. Intenta de nuevo');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout completo
  Future<void> logout() async {
    _logger.i('🚪 Cerrando sesión para: ${_currentUser?.name}');
    try {
      await _sessionService.clearSession();
      _currentUser = null;
      _clearError();
      _logger.i('✅ Logout completado');
    } catch (e) {
      _logger.e('❌ Error en logout: $e');
    }
    notifyListeners();
  }

  /// ✅ CORREGIDO: Crear usuario de prueba para desarrollo
  Future<bool> createTestUser() async {
    _logger.i('🧪 Creando/usando usuario de prueba');

    // ✅ CREDENCIALES CORREGIDAS: Usar cuenta de desarrollador existente
    const email = 'dev@reflect.com';
    const password = 'devpassword123';

    _setLoading(true);
    _clearError();

    try {
      // Intentar crear cuenta de desarrollador (que ya maneja la creación correctamente)
      await _databaseService.createDeveloperAccount();

      // Hacer login con las credenciales correctas
      final success = await login(email, password, rememberMe: true);

      if (success) {
        _logger.i('✅ Usuario de prueba listo: $email');
        return true;
      } else {
        _logger.w('⚠️ Error en login de usuario de prueba');
        _setError('Error activando cuenta de prueba');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error con usuario de prueba: $e');
      _setError('Error creando cuenta de prueba');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Método alternativo para crear usuario zen (SIMPLIFICADO)
  Future<bool> createZenTestUser() async {
    _logger.i('🧪 Creando usuario zen de prueba');
    const email = 'zen@reflect.app';
    const password = 'reflect123';
    const name = 'Viajero Zen';

    _setLoading(true);
    _clearError();

    try {
      // ✅ CORREGIDO: Simplificado sin deleteUser
      // Intentar crear usuario - si ya existe, simplemente hacer login
      await _databaseService.createUser(email, password, name);

      // Hacer login (funcionará independientemente de si el usuario ya existía)
      final success = await login(email, password, rememberMe: true);

      if (success) {
        _logger.i('✅ Usuario zen listo: $email');
        return true;
      } else {
        _setError('Error en credenciales zen');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error creando usuario zen: $e');
      _setError('Error en creación de usuario');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar perfil de usuario
  Future<bool> updateProfile({
    String? name,
    String? avatarEmoji,
    String? bio,
    Map<String, dynamic>? preferences,
  }) async {
    if (_currentUser == null || _currentUser!.id == null) return false;

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
        final updatedUser = await _databaseService.getUserById(_currentUser!.id!);
        if (updatedUser != null) {
          _currentUser = updatedUser;
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