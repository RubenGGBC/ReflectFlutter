// ============================================================================
// data/services/session_service.dart - Servicio de Sesiones para Flutter
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';

class SessionService {
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserAvatar = 'user_avatar';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyLastLogin = 'last_login';

  final Logger _logger = Logger();

  /// Guardar sesión de usuario
  Future<bool> saveUserSession(UserModel user, {bool rememberMe = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt(_keyUserId, user.id!);
      await prefs.setString(_keyUserEmail, user.email);
      await prefs.setString(_keyUserName, user.name);
      await prefs.setString(_keyUserAvatar, user.avatarEmoji);
      await prefs.setBool(_keyRememberMe, rememberMe);
      await prefs.setString(_keyLastLogin, DateTime.now().toIso8601String());

      _logger.i('✅ Sesión guardada para: ${user.name} (Remember: $rememberMe)');
      return true;

    } catch (e) {
      _logger.e('❌ Error guardando sesión: $e');
      return false;
    }
  }

  /// Verificar si hay una sesión activa
  Future<bool> hasActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt(_keyUserId);
      final rememberMe = prefs.getBool(_keyRememberMe) ?? false;

      if (userId != null && rememberMe) {
        // Verificar que la sesión no sea muy antigua (30 días)
        final lastLoginStr = prefs.getString(_keyLastLogin);
        if (lastLoginStr != null) {
          final lastLogin = DateTime.parse(lastLoginStr);
          final daysSinceLogin = DateTime.now().difference(lastLogin).inDays;

          if (daysSinceLogin <= 30) {
            _logger.d('🔄 Sesión activa encontrada para usuario: $userId');
            return true;
          } else {
            _logger.w('⚠️ Sesión expirada (${daysSinceLogin} días)');
            await clearSession();
          }
        }
      }

      return false;

    } catch (e) {
      _logger.e('❌ Error verificando sesión: $e');
      return false;
    }
  }

  /// Obtener datos de la sesión guardada
  Future<Map<String, dynamic>?> getSessionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt(_keyUserId);
      if (userId == null) return null;

      return {
        'id': userId,
        'email': prefs.getString(_keyUserEmail) ?? '',
        'name': prefs.getString(_keyUserName) ?? '',
        'avatar_emoji': prefs.getString(_keyUserAvatar) ?? '🧘‍♀️',
        'remember_me': prefs.getBool(_keyRememberMe) ?? false,
        'last_login': prefs.getString(_keyLastLogin),
      };

    } catch (e) {
      _logger.e('❌ Error obteniendo datos de sesión: $e');
      return null;
    }
  }

  /// Limpiar sesión
  Future<bool> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyUserAvatar);
      await prefs.remove(_keyRememberMe);
      await prefs.remove(_keyLastLogin);

      _logger.i('🗑️ Sesión limpiada correctamente');
      return true;

    } catch (e) {
      _logger.e('❌ Error limpiando sesión: $e');
      return false;
    }
  }

  /// Actualizar último login
  Future<void> updateLastLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastLogin, DateTime.now().toIso8601String());
    } catch (e) {
      _logger.e('❌ Error actualizando último login: $e');
    }
  }
}