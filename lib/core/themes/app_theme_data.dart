// ============================================================================
// core/themes/app_theme_data.dart - CONSTRUCCIÓN DE TEMAS
// ============================================================================

import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppThemeData {
  static ThemeData buildTheme(AppColors appColors) {
    return ThemeData(
      useMaterial3: true,
      brightness: appColors.isDark ? Brightness.dark : Brightness.light,

      // Esquema de colores principal
      colorScheme: ColorScheme(
        brightness: appColors.isDark ? Brightness.dark : Brightness.light,
        primary: appColors.accentPrimary,
        onPrimary: Colors.white,
        secondary: appColors.accentSecondary,
        onSecondary: Colors.white,
        tertiary: appColors.positiveMain,
        onTertiary: Colors.white,
        error: appColors.negativeMain,
        onError: Colors.white,
        surface: appColors.surface,
        onSurface: appColors.textPrimary,
        surfaceContainerHighest: appColors.surfaceVariant,
        onSurfaceVariant: appColors.textSecondary,
        outline: appColors.borderColor,
        outlineVariant: appColors.borderColor.withValues(alpha: 0.5),
        shadow: appColors.shadowColor,
        scrim: Colors.black54,
        inverseSurface: appColors.textPrimary,
        onInverseSurface: appColors.primaryBg,
        inversePrimary: appColors.accentSecondary,
      ),

      // Tipografía personalizada
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: appColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: appColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: appColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: appColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: appColors.textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: appColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: appColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: appColors.textHint,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: appColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: appColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: appColors.textHint,
        ),
      ),

      // AppBar personalizada
      appBarTheme: AppBarTheme(
        backgroundColor: appColors.accentPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Botones personalizados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: appColors.accentPrimary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: appColors.shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: appColors.accentPrimary,
          side: BorderSide(color: appColors.accentPrimary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: appColors.accentPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Cards y contenedores
      cardTheme: CardThemeData(
        color: appColors.surface,
        shadowColor: appColors.shadowColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.accentPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.negativeMain),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: TextStyle(color: appColors.textHint),
        labelStyle: TextStyle(color: appColors.textSecondary),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: appColors.surface,
        selectedItemColor: appColors.accentPrimary,
        unselectedItemColor: appColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Sliders - CORREGIDO para usar withValues
      sliderTheme: SliderThemeData(
        activeTrackColor: appColors.accentPrimary,
        inactiveTrackColor: appColors.borderColor,
        thumbColor: appColors.accentPrimary,
        overlayColor: appColors.accentPrimary.withValues(alpha: 0.2),
        trackHeight: 4,
      ),

      // Checkbox y Switch
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return appColors.accentPrimary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: appColors.borderColor, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return appColors.accentPrimary;
          }
          return appColors.borderColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return appColors.accentPrimary.withValues(alpha: 0.5);
          }
          return appColors.borderColor.withValues(alpha: 0.3);
        }),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: appColors.surface,
        contentTextStyle: TextStyle(color: appColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}