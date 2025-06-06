// ============================================================================
// lib/presentation/providers/theme_provider.dart - VERSIÓN LIMPIA DEFINITIVA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ThemeProvider with ChangeNotifier {
  final Logger _logger = Logger();

  // Solo usar colores hardcodeados - Dark Blue Theme
  static const Color primaryBg = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF141B2D);
  static const Color surfaceVariant = Color(0xFF1E2A3F);
  static const Color accentPrimary = Color(0xFF1E3A8A);
  static const Color accentSecondary = Color(0xFF3B82F6);
  static const Color textPrimary = Color(0xFFE8EAF0);
  static const Color textSecondary = Color(0xFFB3B8C8);
  static const Color textHint = Color(0xFF8691A8);
  static const Color positiveMain = Color(0xFF10B981);
  static const Color negativeMain = Color(0xFFEF4444);
  static const Color borderColor = Color(0xFF1E3A8A);
  static const Color shadowColor = Color(0x331E3A8A);
  static const List<Color> gradientHeader = [Color(0xFF1E3A8A), Color(0xFF3B82F6)];

  bool _isInitialized = false;

  // Getters para compatibilidad
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
    surface: surface,
    surfaceVariant: surfaceVariant,
    accentPrimary: accentPrimary,
    accentSecondary: accentSecondary,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    textHint: textHint,
    positiveMain: positiveMain,
    negativeMain: negativeMain,
    borderColor: borderColor,
    shadowColor: shadowColor,
    gradientHeader: gradientHeader,
  );

  bool get isInitialized => _isInitialized;

  /// Inicializar provider
  Future<void> initialize() async {
    if (_isInitialized) return;
    _logger.i('🎨 Inicializando ThemeProvider (Dark Blue)');
    _isInitialized = true;
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
    brightness: Brightness.dark,
    scaffoldBackgroundColor: primaryBg,
    colorScheme: const ColorScheme.dark(
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
  final Color surface;
  final Color surfaceVariant;
  final Color accentPrimary;
  final Color accentSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color positiveMain;
  final Color negativeMain;
  final Color borderColor;
  final Color shadowColor;
  final List<Color> gradientHeader;

  const AppColors({
    required this.primaryBg,
    required this.surface,
    required this.surfaceVariant,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.positiveMain,
    required this.negativeMain,
    required this.borderColor,
    required this.shadowColor,
    required this.gradientHeader,
  });
}