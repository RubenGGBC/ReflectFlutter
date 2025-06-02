// ============================================================================
// presentation/providers/theme_provider.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../../core/themes/app_theme.dart';
import '../../core/themes/theme_definitions.dart';
import '../../core/themes/app_theme_data.dart';

class ThemeProvider with ChangeNotifier {
  final Logger _logger = Logger();

  AppThemeType _currentThemeType = AppThemeType.deepOcean;
  AppColors _currentColors = ThemeDefinitions.deepOcean;
  ThemeData _currentThemeData = AppThemeData.buildTheme(ThemeDefinitions.deepOcean);
  bool _isInitialized = false;

  // Getters
  AppThemeType get currentThemeType => _currentThemeType;
  AppColors get currentColors => _currentColors;
  ThemeData get currentThemeData => _currentThemeData;
  bool get isInitialized => _isInitialized;

  /// Inicializar provider - cargar tema guardado
  Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.i('🎨 Inicializando ThemeProvider');

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeName = prefs.getString('current_theme') ?? 'deep_ocean';

      // Buscar tema por nombre
      AppThemeType? foundThemeType;
      for (final entry in ThemeDefinitions.themes.entries) {
        if (entry.value.name == savedThemeName) {
          foundThemeType = entry.key;
          break;
        }
      }

      if (foundThemeType != null) {
        await _applyTheme(foundThemeType, save: false);
        _logger.i('📖 Tema cargado: ${_currentColors.displayName}');
      } else {
        _logger.w('⚠️ Tema guardado no encontrado, usando Deep Ocean por defecto');
      }

      _isInitialized = true;

    } catch (e) {
      _logger.e('❌ Error cargando tema: $e');
      _isInitialized = true; // Continuar con tema por defecto
    }

    notifyListeners();
  }

  /// Cambiar tema
  Future<bool> setTheme(AppThemeType themeType) async {
    if (themeType == _currentThemeType) return true;

    _logger.i('🎨 Cambiando tema a: ${ThemeDefinitions.themes[themeType]?.displayName}');

    try {
      await _applyTheme(themeType, save: true);
      _logger.i('✅ Tema aplicado correctamente');
      return true;
    } catch (e) {
      _logger.e('❌ Error aplicando tema: $e');
      return false;
    }
  }

  /// Aplicar tema
  Future<void> _applyTheme(AppThemeType themeType, {bool save = true}) async {
    final themeColors = ThemeDefinitions.themes[themeType];
    if (themeColors == null) {
      throw Exception('Tema no encontrado: $themeType');
    }

    _currentThemeType = themeType;
    _currentColors = themeColors;
    _currentThemeData = AppThemeData.buildTheme(themeColors);

    if (save) {
      await _saveTheme(themeColors.name);
    }

    notifyListeners();
  }

  /// Guardar tema actual
  Future<void> _saveTheme(String themeName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_theme', themeName);
      await prefs.setString('last_updated', DateTime.now().toIso8601String());
      _logger.d('💾 Tema guardado: $themeName');
    } catch (e) {
      _logger.e('❌ Error guardando tema: $e');
    }
  }

  /// Obtener todos los temas disponibles
  Map<AppThemeType, AppColors> get availableThemes => ThemeDefinitions.themes;

  /// Verificar si un tema es oscuro
  bool get isDarkTheme => _currentColors.isDark;

  /// Obtener color para mood score
  Color getMoodColor(double mood) {
    if (mood <= 3) {
      return _currentColors.negativeMain;
    } else if (mood <= 6) {
      return Colors.orange; // Amarillo/naranja
    } else {
      return _currentColors.positiveMain;
    }
  }

  /// Obtener etiqueta para mood score
  String getMoodLabel(double mood) {
    if (mood <= 2) {
      return "Muy difícil";
    } else if (mood <= 4) {
      return "Difícil";
    } else if (mood <= 6) {
      return "Regular";
    } else if (mood <= 8) {
      return "Bueno";
    } else {
      return "Excelente";
    }
  }
}