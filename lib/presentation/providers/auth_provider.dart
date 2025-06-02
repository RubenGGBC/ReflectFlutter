// ============================================================================
// presentation/providers/auth_provider.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../../data/models/user_model.dart';
import '../../data/services/database_service.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  final Logger _logger = Logger();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  AuthProvider(this._databaseService);

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialized => _isInitialized;

  /// Inicializar provider - verificar si hay sesión guardada
  Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.i('🔑 Inicializando AuthProvider');
    _setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getInt('user_id');

      if (savedUserId != null) {
        _logger.d('👤 Usuario guardado encontrado: $savedUserId');
        final user = await _databaseService.getUserById(savedUserId);

        if (user != null) {
          _currentUser = user;
          _logger.i('🌺 Sesión restaurada para: ${user.name}');
        } else {
          _logger.w('⚠️ Usuario guardado no encontrado en BD, limpiando sesión');
          await _clearSavedSession();
        }
      }

      _isInitialized = true;

    } catch (e) {
      _logger.e('❌ Error inicializando AuthProvider: $e');
      _setError('Error inicializando sesión');
    } finally {
      _setLoading(false);
    }
  }

  /// Login de usuario
  Future<bool> login(String email, String password) async {
    _logger.i('🔑 Intentando login para: $email');
    _setLoading(true);
    _clearError();

    try {
      final user = await _databaseService.loginUser(email, password);

      if (user != null) {
        _currentUser = user;
        await _saveSession(user.id!);
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
          await _saveSession(userId);
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

  /// Logout
  Future<void> logout() async {
    _logger.i('🚪 Cerrando sesión para: ${_currentUser?.name}');

    try {
      await _clearSavedSession();
      _currentUser = null;
      _clearError();
      _logger.i('✅ Sesión cerrada correctamente');
    } catch (e) {
      _logger.e('❌ Error cerrando sesión: $e');
    }

    notifyListeners();
  }

  /// Crear usuario de prueba
  Future<bool> createTestUser() async {
    _logger.i('🧪 Creando usuario de prueba');

    const email = 'zen@reflect.app';
    const password = 'reflect123';
    const name = 'Viajero Zen';

    // Intentar crear usuario
    await _databaseService.createUser(email, password, name);

    // Intentar login (funcionará incluso si el usuario ya existía)
    return await login(email, password);
  }

  /// Guardar sesión en SharedPreferences
  Future<void> _saveSession(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', userId);
      _logger.d('💾 Sesión guardada para usuario: $userId');
    } catch (e) {
      _logger.e('❌ Error guardando sesión: $e');
    }
  }

  /// Limpiar sesión guardada
  Future<void> _clearSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      _logger.d('🗑️ Sesión guardada eliminada');
    } catch (e) {
      _logger.e('❌ Error limpiando sesión: $e');
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

