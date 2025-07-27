// ============================================================================
// minimal_colors.dart - SISTEMA DE COLORES MINIMALISTA CORRECTO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class MinimalColors {
  // ============================================================================
  // COLORES DINÁMICOS CORREGIDOS (DEPENDEN DEL CONTEXTO)
  // ============================================================================
  
  // Backgrounds - CORREGIDO para modo claro
  static Color backgroundPrimary(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode 
        ? themeProvider.primaryBg
        : const Color(0xFFFFFFFF); // Blanco puro para modo claro
  }
  
  static Color backgroundCard(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode 
        ? themeProvider.surface
        : const Color(0xFFFFFFFF); // Blanco puro para modo claro
  }
  
  static Color backgroundSecondary(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode 
        ? themeProvider.surfaceVariant
        : const Color(0xFFF8F9FA); // Gris muy claro para modo claro
  }

  // Textos - CORREGIDO para contraste apropiado
  static Color textPrimary(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode 
        ? themeProvider.textPrimary
        : const Color(0xFF1F2937); // Negro para modo claro
  }
  
  static Color textSecondary(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode 
        ? themeProvider.textSecondary
        : const Color(0xFF4B5563); // Gris oscuro para modo claro
  }
  
  static Color textTertiary(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode 
        ? themeProvider.textSecondary
        : const Color(0xFF6B7280); // Gris medio para modo claro
  }
  
  static Color textMuted(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode 
        ? themeProvider.textHint
        : const Color(0xFF9CA3AF); // Gris claro para modo claro
  }

  // Sombras - CORREGIDO para ambos modos
  static Color shadow(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode
        ? Colors.black.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.05); // Sombra MUY sutil para modo claro
  }

  // Sombras de gradiente - theme-aware para efectos visuales
  static Color gradientShadow(BuildContext context, {double alpha = 0.2}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (themeProvider.isDarkMode) {
      return themeProvider.gradientHeader[1].withValues(alpha: alpha);
    } else {
      // En modo claro, usar sombras MUCHO más sutiles
      return Colors.black.withValues(alpha: alpha * 0.1);
    }
  }

  // Sombras de color específico - theme-aware
  static Color coloredShadow(BuildContext context, Color baseColor, {double alpha = 0.2}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (themeProvider.isDarkMode) {
      return baseColor.withValues(alpha: alpha);
    } else {
      // En modo claro, usar versiones MUCHO más sutiles de las sombras de color
      return Colors.black.withValues(alpha: alpha * 0.1);
    }
  }

  // Gradientes - MANTIENEN LOS COLORES DE LA APP
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
  
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF141B2D);
  static const Color surfaceVariant = Color(0xFF1E2A3F);
  static const Color border = Color(0xFF2A3441);
  
  static const Color primary = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF8B5CF6);
  static const Color secondary = Color(0xFF10B981);
  
  static const Color textPrimaryStatic = Color(0xFFE8EAF0);
  static const Color textSecondaryStatic = Color(0xFFB3B8C8);
  static const Color textTertiaryStatic = Color(0xFFB3B8C8);
  static const Color textMutedStatic = Color(0xFF8691A8);
  
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  static const Color shadowStatic = Color(0x4D000000);
  
  // Legacy static versions for compatibility
  static const Color backgroundPrimaryStatic = background;
  static const Color backgroundCardStatic = surface;
  static const Color backgroundSecondaryStatic = surfaceVariant;
  
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