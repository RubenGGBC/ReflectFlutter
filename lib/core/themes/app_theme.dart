// ============================================================================
// core/themes/app_theme.dart
// ============================================================================

import 'package:flutter/material.dart';

enum AppThemeType {
  deepOcean,
  electricDark,
  springLight,
  sunsetWarm,
}

class AppColors {
  // Colores base
  final Color primaryBg;
  final Color secondaryBg;
  final Color surface;
  final Color surfaceVariant;

  // Acentos
  final Color accentPrimary;
  final Color accentSecondary;

  // Textos
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  // Estados
  final Color positiveMain;
  final Color positiveLight;
  final Color positiveGlow;
  final Color negativeMain;
  final Color negativeLight;
  final Color negativeGlow;

  // Efectos
  final Color shadowColor;
  final Color borderColor;
  final Color glassBg;

  // Gradientes
  final List<Color> gradientHeader;
  final List<Color> gradientButton;

  // Metadatos
  final String name;
  final String displayName;
  final String icon;
  final String description;
  final bool isDark;

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
    required this.positiveGlow,
    required this.negativeMain,
    required this.negativeLight,
    required this.negativeGlow,
    required this.shadowColor,
    required this.borderColor,
    required this.glassBg,
    required this.gradientHeader,
    required this.gradientButton,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.description,
    required this.isDark,
  });
}

// ============================================================================
// core/themes/theme_definitions.dart
// ============================================================================

class ThemeDefinitions {
  static const AppColors deepOcean = AppColors(
    // Metadatos
    name: "deep_ocean",
    displayName: "🌊 Deep Ocean",
    icon: "🌊",
    description: "Tranquilo y minimalista",
    isDark: true,

    // Fondos
    primaryBg: Color(0xFF0A0E1A),
    secondaryBg: Color(0xFF141B2D),
    surface: Color(0xFF141B2D),
    surfaceVariant: Color(0xFF1E2A3F),

    // Acentos azules
    accentPrimary: Color(0xFF1E3A8A),
    accentSecondary: Color(0xFF3B82F6),

    // Textos
    textPrimary: Color(0xFFE8EAF0),
    textSecondary: Color(0xFFB3B8C8),
    textHint: Color(0xFF8691A8),

    // Estados
    positiveMain: Color(0xFF10B981),
    positiveLight: Color(0x3310B981),
    positiveGlow: Color(0x6610B981),
    negativeMain: Color(0xFFEF4444),
    negativeLight: Color(0x33EF4444),
    negativeGlow: Color(0x66EF4444),

    // Efectos
    shadowColor: Color(0x4D1E3A8A),
    borderColor: Color(0xFF1E3A8A),
    glassBg: Color(0x331E3A8A),

    // Gradientes
    gradientHeader: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    gradientButton: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
  );

  static const AppColors electricDark = AppColors(
    // Metadatos
    name: "electric_dark",
    displayName: "⚡ Electric Dark",
    icon: "⚡",
    description: "Futurista y moderno",
    isDark: true,

    // Fondos eléctricos
    primaryBg: Color(0xFF0C0C0F),
    secondaryBg: Color(0xFF1A1A23),
    surface: Color(0xFF1A1A23),
    surfaceVariant: Color(0xFF24243A),

    // Acentos eléctricos
    accentPrimary: Color(0xFF6366F1),
    accentSecondary: Color(0xFF8B5CF6),

    // Textos brillantes
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFCBD5E1),
    textHint: Color(0xFF94A3B8),

    // Estados eléctricos
    positiveMain: Color(0xFF06D6A0),
    positiveLight: Color(0x3306D6A0),
    positiveGlow: Color(0x6606D6A0),
    negativeMain: Color(0xFFF72585),
    negativeLight: Color(0x33F72585),
    negativeGlow: Color(0x66F72585),

    // Efectos neón
    shadowColor: Color(0x4D6366F1),
    borderColor: Color(0xFF6366F1),
    glassBg: Color(0x336366F1),

    // Gradientes vibrantes
    gradientHeader: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    gradientButton: [Color(0xFF06D6A0), Color(0xFF00E5C7)],
  );

  static const AppColors springLight = AppColors(
    // Metadatos
    name: "spring_light",
    displayName: "🌸 Spring Light",
    icon: "🌸",
    description: "Fresco y primaveral",
    isDark: false,

    // Fondos claros
    primaryBg: Color(0xFFF8FAFC),
    secondaryBg: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF1F5F9),

    // Acentos verdes primaveral
    accentPrimary: Color(0xFF059669),
    accentSecondary: Color(0xFF10B981),

    // Textos oscuros para contraste
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF4B5563),
    textHint: Color(0xFF9CA3AF),

    // Estados vibrantes
    positiveMain: Color(0xFF059669),
    positiveLight: Color(0xFFECFDF5),
    positiveGlow: Color(0xFFA7F3D0),
    negativeMain: Color(0xFFDC2626),
    negativeLight: Color(0xFFFEF2F2),
    negativeGlow: Color(0xFFFECACA),

    // Efectos suaves
    shadowColor: Color(0x33059669),
    borderColor: Color(0xFFD1D5DB),
    glassBg: Color(0x1A059669),

    // Gradientes suaves
    gradientHeader: [Color(0xFF059669), Color(0xFF10B981)],
    gradientButton: [Color(0xFF059669), Color(0xFF047857)],
  );

  static const AppColors sunsetWarm = AppColors(
    // Metadatos
    name: "sunset_warm",
    displayName: "🌅 Sunset Warm",
    icon: "🌅",
    description: "Cálido y acogedor",
    isDark: false,

    // Fondos cálidos claros
    primaryBg: Color(0xFFFFF7ED),
    secondaryBg: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF8F9FA),

    // Acentos naranjas cálidos
    accentPrimary: Color(0xFFEA580C),
    accentSecondary: Color(0xFFF97316),

    // Textos oscuros para contraste
    textPrimary: Color(0xFF292524),
    textSecondary: Color(0xFF57534E),
    textHint: Color(0xFFA8A29E),

    // Estados cálidos
    positiveMain: Color(0xFF059669),
    positiveLight: Color(0xFFF0FDF4),
    positiveGlow: Color(0xFFBBF7D0),
    negativeMain: Color(0xFFDC2626),
    negativeLight: Color(0xFFFEF2F2),
    negativeGlow: Color(0xFFFECACA),

    // Efectos cálidos
    shadowColor: Color(0x33EA580C),
    borderColor: Color(0xFFE5E7EB),
    glassBg: Color(0x1AEA580C),

    // Gradientes cálidos
    gradientHeader: [Color(0xFFEA580C), Color(0xFFF97316)],
    gradientButton: [Color(0xFFEA580C), Color(0xFFC2410C)],
  );

  static Map<AppThemeType, AppColors> get themes => {
    AppThemeType.deepOcean: deepOcean,
    AppThemeType.electricDark: electricDark,
    AppThemeType.springLight: springLight,
    AppThemeType.sunsetWarm: sunsetWarm,
  };
}

// ============================================================================
// core/themes/app_theme_data.dart
// ============================================================================

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
        outlineVariant: appColors.borderColor.withOpacity(0.5),
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

      // Sliders
      sliderTheme: SliderThemeData(
        activeTrackColor: appColors.accentPrimary,
        inactiveTrackColor: appColors.borderColor,
        thumbColor: appColors.accentPrimary,
        overlayColor: appColors.accentPrimary.withOpacity(0.2),
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
            return appColors.accentPrimary.withOpacity(0.5);
          }
          return appColors.borderColor.withOpacity(0.3);
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