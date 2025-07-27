// ============================================================================
// lib/presentation/providers/theme_provider.dart - VERSIÓN LIMPIA DEFINITIVA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  final Logger _logger = Logger();

  // Dark Theme Colors
  static const Color darkPrimaryBg = Color(0xFF0A0E1A);
  static const Color darkSurface = Color(0xFF141B2D);
  static const Color darkSurfaceVariant = Color(0xFF1E2A3F);
  static const Color darkAccentPrimary = Color(0xFF1E3A8A);
  static const Color darkAccentSecondary = Color(0xFF3B82F6);
  static const Color darkTextPrimary = Color(0xFFE8EAF0);
  static const Color darkTextSecondary = Color(0xFFB3B8C8);
  static const Color darkTextHint = Color(0xFF8691A8);
  static const Color darkPositiveMain = Color(0xFF10B981);
  static const Color darkNegativeMain = Color(0xFFEF4444);
  static const Color darkBorderColor = Color(0xFF1E3A8A);
  static const Color darkShadowColor = Color(0x331E3A8A);
  static const List<Color> darkGradientHeader = [Color(0xFF1E3A8A), Color(0xFF7C3AED)];

  // Light Theme Colors
  static const Color lightPrimaryBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightAccentPrimary = Color(0xFF1E3A8A);
  static const Color lightAccentSecondary = Color(0xFF3B82F6);
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextHint = Color(0xFF9CA3AF);
  static const Color lightPositiveMain = Color(0xFF059669);
  static const Color lightNegativeMain = Color(0xFFDC2626);
  static const Color lightBorderColor = Color(0xFFD1D5DB);
  static const Color lightShadowColor = Color(0x331E3A8A);
  static const List<Color> lightGradientHeader = [Color(0xFF1E3A8A), Color(0xFF7C3AED)];

  bool _isInitialized = false;
  bool _isDarkMode = true;

  // Getters para compatibilidad
  bool get isDarkMode => _isDarkMode;
  bool get isDarkTheme => _isDarkMode;
  Color get primaryBg => _isDarkMode ? darkPrimaryBg : lightPrimaryBg;
  Color get surface => _isDarkMode ? darkSurface : lightSurface;
  Color get surfaceVariant => _isDarkMode ? darkSurfaceVariant : lightSurfaceVariant;
  Color get accentPrimary => _isDarkMode ? darkAccentPrimary : lightAccentPrimary;
  Color get accentSecondary => _isDarkMode ? darkAccentSecondary : lightAccentSecondary;
  Color get textPrimary => _isDarkMode ? darkTextPrimary : lightTextPrimary;
  Color get textSecondary => _isDarkMode ? darkTextSecondary : lightTextSecondary;
  Color get textHint => _isDarkMode ? darkTextHint : lightTextHint;
  Color get positiveMain => _isDarkMode ? darkPositiveMain : lightPositiveMain;
  Color get negativeMain => _isDarkMode ? darkNegativeMain : lightNegativeMain;
  Color get borderColor => _isDarkMode ? darkBorderColor : lightBorderColor;
  Color get shadowColor => _isDarkMode ? darkShadowColor : lightShadowColor;
  List<Color> get gradientHeader => _isDarkMode ? darkGradientHeader : lightGradientHeader;
  
  // Additional getters for compatibility
  Color get secondaryBg => _isDarkMode ? darkSurface : lightSurface;
  Color get positiveLight => _isDarkMode ? darkPositiveMain.withValues(alpha: 0.3) : lightPositiveMain.withValues(alpha: 0.3);
  Color get negativeLight => _isDarkMode ? darkNegativeMain.withValues(alpha: 0.3) : lightNegativeMain.withValues(alpha: 0.3);
  List<Color> get gradientButton => gradientHeader; // Use same as header for simplicity
  bool get isDark => _isDarkMode;
  
  // Legacy getters
  Color get primaryBgColor => primaryBg;
  Color get surfaceColor => surface;
  Color get surfaceVariantColor => surfaceVariant;
  Color get accentPrimaryColor => accentPrimary;
  Color get textPrimaryColor => textPrimary;
  Color get textSecondaryColor => textSecondary;
  Color get textHintColor => textHint;
  Color get positiveMainColor => positiveMain;
  Color get negativeMainColor => negativeMain;
  Color get borderColorValue => borderColor;
  List<Color> get gradientHeaderColors => gradientHeader;

  // Objeto de colores actuales para compatibilidad
  AppColors get currentColors => AppColors(
    primaryBg: primaryBg,
    secondaryBg: _isDarkMode ? darkSurface : lightSurface, // Secondary background
    surface: surface,
    surfaceVariant: surfaceVariant,
    accentPrimary: accentPrimary,
    accentSecondary: accentSecondary,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    textHint: textHint,
    positiveMain: positiveMain,
    positiveLight: _isDarkMode ? darkPositiveMain.withValues(alpha: 0.3) : lightPositiveMain.withValues(alpha: 0.3),
    negativeMain: negativeMain,
    negativeLight: _isDarkMode ? darkNegativeMain.withValues(alpha: 0.3) : lightNegativeMain.withValues(alpha: 0.3),
    borderColor: borderColor,
    shadowColor: shadowColor,
    gradientHeader: gradientHeader,
  );

  bool get isInitialized => _isInitialized;

  /// Inicializar provider
  Future<void> initialize() async {
    if (_isInitialized) return;
    _logger.i('🎨 Inicializando ThemeProvider');
    
    // Load saved theme preference
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('is_dark_mode') ?? true;
    
    _isInitialized = true;
    notifyListeners();
  }
  
  /// Toggle between dark and light theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    
    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
    
    _logger.i('🎨 Theme toggled to ${_isDarkMode ? 'Dark' : 'Light'} mode');
    notifyListeners();
  }

  /// Set theme explicitly
  Future<void> setTheme(bool isDarkMode) async {
    if (_isDarkMode == isDarkMode) return;
    
    _isDarkMode = isDarkMode;
    
    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
    
    _logger.i('🎨 Theme set to ${_isDarkMode ? 'Dark' : 'Light'} mode');
    notifyListeners();
  }

  /// Obtener color para mood score
  Color getMoodColor(double mood) {
    if (mood <= 3) {
      return negativeMain;
    } else if (mood <= 6) {
      return Colors.orange;
    } else {
      return positiveMain;
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

  /// Tema data para Material
  ThemeData get currentThemeData => ThemeData(
    useMaterial3: true,
    brightness: _isDarkMode ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: primaryBg,
    colorScheme: _isDarkMode 
      ? ColorScheme.dark(
          primary: accentPrimary,
          secondary: accentSecondary,
          surface: surface,
          error: negativeMain,
        )
      : ColorScheme.light(
          primary: accentPrimary,
          secondary: accentSecondary,
          surface: surface,
          error: negativeMain,
        ),
  );
}

// Clase de colores para compatibilidad - SOLO AQUÍ
class AppColors {
  final Color primaryBg;
  final Color secondaryBg;
  final Color surface;
  final Color surfaceVariant;
  final Color accentPrimary;
  final Color accentSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color positiveMain;
  final Color positiveLight;
  final Color negativeMain;
  final Color negativeLight;
  final Color borderColor;
  final Color shadowColor;
  final List<Color> gradientHeader;

  const AppColors({
    required this.primaryBg,
    required this.secondaryBg,
    required this.surface,
    required this.surfaceVariant,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.positiveMain,
    required this.positiveLight,
    required this.negativeMain,
    required this.negativeLight,
    required this.borderColor,
    required this.shadowColor,
    required this.gradientHeader,
  });
}