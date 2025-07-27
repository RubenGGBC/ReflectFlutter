// ============================================================================
// theme_test_validation.dart - VALIDACIÓN SIMPLE DE TEMAS
// ============================================================================

import 'package:flutter/material.dart';
import '../../../core/themes/theme_definitions.dart';
import '../../../core/themes/app_theme.dart';

class ThemeTestValidation {
  // Test to validate all themes have proper light/dark support
  static void validateThemes() {
    print('🔍 VALIDACIÓN DE TEMAS');
    print('=====================================');
    
    final themes = ThemeDefinitions.themes;
    
    for (var entry in themes.entries) {
      final themeName = entry.key.toString();
      final theme = entry.value;
      
      print('\n📋 Tema: ${theme.displayName}');
      print('   - Modo oscuro: ${theme.isDark}');
      print('   - Fondo primario: ${_colorToHex(theme.primaryBg)}');
      print('   - Superficie: ${_colorToHex(theme.surface)}');
      print('   - Texto primario: ${_colorToHex(theme.textPrimary)}');
      print('   - Texto secundario: ${_colorToHex(theme.textSecondary)}');
      print('   - Borde: ${_colorToHex(theme.borderColor)}');
      print('   - Sombra: ${_colorToHex(theme.shadowColor)}');
      
      // Validate contrast ratios for light themes
      if (!theme.isDark) {
        _validateLightTheme(theme);
      } else {
        _validateDarkTheme(theme);
      }
    }
    
    print('\n✅ VALIDACIÓN COMPLETADA');
    print('=====================================');
  }
  
  static void _validateLightTheme(AppColors theme) {
    print('   ✓ Validando tema claro...');
    
    // Check that light themes have proper contrast
    final bgLuminance = theme.primaryBg.computeLuminance();
    final textLuminance = theme.textPrimary.computeLuminance();
    
    if (bgLuminance > 0.5 && textLuminance < 0.5) {
      print('   ✅ Contraste adecuado para tema claro');
    } else {
      print('   ⚠️  Posible problema de contraste en tema claro');
    }
    
    // Validate that surface and background colors are light
    if (theme.surface.computeLuminance() > 0.7) {
      print('   ✅ Superficie apropiada para tema claro');
    } else {
      print('   ⚠️  Superficie podría ser muy oscura');
    }
  }
  
  static void _validateDarkTheme(AppColors theme) {
    print('   ✓ Validando tema oscuro...');
    
    // Check that dark themes have proper contrast
    final bgLuminance = theme.primaryBg.computeLuminance();
    final textLuminance = theme.textPrimary.computeLuminance();
    
    if (bgLuminance < 0.5 && textLuminance > 0.5) {
      print('   ✅ Contraste adecuado para tema oscuro');
    } else {
      print('   ⚠️  Posible problema de contraste en tema oscuro');
    }
    
    // Validate that surface and background colors are dark
    if (theme.surface.computeLuminance() < 0.3) {
      print('   ✅ Superficie apropiada para tema oscuro');
    } else {
      print('   ⚠️  Superficie podría ser muy clara');
    }
  }
  
  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
  
  // Test specific components with different themes
  static void testComponentWithThemes() {
    print('\n🧪 PRUEBA DE COMPONENTES CON TEMAS');
    print('=====================================');
    
    for (var entry in ThemeDefinitions.themes.entries) {
      final theme = entry.value;
      print('\n🎨 Probando con ${theme.displayName}:');
      
      // Test enhanced timeline widget colors
      _testTimelineColors(theme);
      
      // Test modal colors
      _testModalColors(theme);
    }
  }
  
  static void _testTimelineColors(AppColors theme) {
    print('   📊 Timeline Widget:');
    
    // Main container
    final containerBg = theme.isDark 
        ? theme.surface 
        : theme.surface.withValues(alpha: 0.98);
    print('     - Fondo contenedor: ${_colorToHex(containerBg)}');
    
    // Border
    final borderColor = theme.isDark 
        ? theme.borderColor.withValues(alpha: 0.3)
        : theme.borderColor.withValues(alpha: 0.5);
    print('     - Color borde: ${_colorToHex(borderColor)}');
    
    // Shadow
    final shadowAlpha = theme.isDark ? 0.1 : 0.12;
    print('     - Intensidad sombra: ${shadowAlpha}');
    
    // Empty slot background
    final emptySlotBg = theme.isDark 
        ? theme.surfaceVariant.withValues(alpha: 0.3)
        : theme.surfaceVariant.withValues(alpha: 0.9);
    print('     - Fondo slot vacío: ${_colorToHex(emptySlotBg)}');
  }
  
  static void _testModalColors(AppColors theme) {
    print('   📱 Modal Components:');
    
    // Modal background
    final modalBg = theme.isDark 
        ? theme.surface 
        : theme.surface.withValues(alpha: 0.95);
    print('     - Fondo modal: ${_colorToHex(modalBg)}');
    
    // Input field background
    final inputBg = theme.isDark 
        ? theme.surfaceVariant 
        : theme.surfaceVariant.withValues(alpha: 0.8);
    print('     - Fondo input: ${_colorToHex(inputBg)}');
    
    // Button decoration
    final buttonBorder = theme.isDark 
        ? theme.borderColor.withValues(alpha: 0.3)
        : theme.borderColor.withValues(alpha: 0.6);
    print('     - Borde botón: ${_colorToHex(buttonBorder)}');
  }
}