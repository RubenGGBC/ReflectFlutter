// ============================================================================
// minimal_colors.dart - SISTEMA DE COLORES MINIMALISTA CORRECTO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class MinimalColors {
  // ============================================================================
  // COLORES DINÁMICOS (DEPENDEN DEL CONTEXTO)
  // ============================================================================
  
  // Backgrounds
  static Color backgroundPrimary(BuildContext context) => 
    Provider.of<ThemeProvider>(context, listen: false).primaryBg;
  
  static Color backgroundCard(BuildContext context) => 
    Provider.of<ThemeProvider>(context, listen: false).surface;
  
  static Color backgroundSecondary(BuildContext context) => 
    Provider.of<ThemeProvider>(context, listen: false).surfaceVariant;

  // Textos
  static Color textPrimary(BuildContext context) => 
    Provider.of<ThemeProvider>(context, listen: false).textPrimary;
  
  static Color textSecondary(BuildContext context) => 
    Provider.of<ThemeProvider>(context, listen: false).textSecondary;
  
  static Color textTertiary(BuildContext context) => 
    Provider.of<ThemeProvider>(context, listen: false).textSecondary;
  
  static Color textMuted(BuildContext context) => 
    Provider.of<ThemeProvider>(context, listen: false).textHint;

  // Sombras
  static Color shadow(BuildContext context) => 
    Provider.of<ThemeProvider>(context, listen: false).isDarkMode
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.grey.withValues(alpha: 0.2);

  // Gradientes
  static List<Color> primaryGradient(BuildContext context) => 
    Provider.of<ThemeProvider>(context, listen: false).gradientHeader;
  
  static List<Color> accentGradient(BuildContext context) => 
    Provider.of<ThemeProvider>(context, listen: false).gradientHeader;
  
  static List<Color> lightGradient(BuildContext context) => 
    Provider.of<ThemeProvider>(context, listen: false).gradientHeader;

  // Gradientes específicos para métricas
  static List<Color> positiveGradient(BuildContext context) => [
    Provider.of<ThemeProvider>(context, listen: false).positiveMain, 
    const Color(0xFF34d399)
  ];
  
  static List<Color> neutralGradient(BuildContext context) => [
    const Color(0xFFf59e0b), 
    const Color(0xFFfbbf24)
  ];
  
  static List<Color> negativeGradient(BuildContext context) => [
    Provider.of<ThemeProvider>(context, listen: false).negativeMain, 
    const Color(0xFFfca5a5)
  ];

  // ============================================================================
  // COLORES ESTÁTICOS (PARA CONSTRUCTORES CONST)
  // ============================================================================
  
  static const Color backgroundPrimaryStatic = Color(0xFF0A0E1A);
  static const Color backgroundCardStatic = Color(0xFF141B2D);
  static const Color backgroundSecondaryStatic = Color(0xFF1E2A3F);
  
  static const Color textPrimaryStatic = Color(0xFFE8EAF0);
  static const Color textSecondaryStatic = Color(0xFFB3B8C8);
  static const Color textTertiaryStatic = Color(0xFFB3B8C8);
  static const Color textMutedStatic = Color(0xFF8691A8);
  
  static const Color shadowStatic = Color(0x4D000000);
  
  static const List<Color> primaryGradientStatic = [
    Color(0xFF1E3A8A), 
    Color(0xFF7C3AED)
  ];
  
  static const List<Color> accentGradientStatic = [
    Color(0xFF1E3A8A), 
    Color(0xFF7C3AED)
  ];
  
  static const List<Color> lightGradientStatic = [
    Color(0xFF1E3A8A), 
    Color(0xFF7C3AED)
  ];
  
  static const List<Color> positiveGradientStatic = [
    Color(0xFF10B981), 
    Color(0xFF34d399)
  ];
  
  static const List<Color> neutralGradientStatic = [
    Color(0xFFf59e0b), 
    Color(0xFFfbbf24)
  ];
  
  static const List<Color> negativeGradientStatic = [
    Color(0xFFEF4444), 
    Color(0xFFfca5a5)
  ];

  // ============================================================================
  // MÉTODOS DE UTILIDAD
  // ============================================================================
  
  /// Obtiene color con opacidad usando el nuevo withValues
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
  
  /// Obtiene gradiente con opacidad
  static List<Color> gradientWithOpacity(List<Color> gradient, double opacity) {
    return gradient.map((color) => color.withValues(alpha: opacity)).toList();
  }
}