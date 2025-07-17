// ============================================================================
// core/themes/theme_definitions.dart - DEFINICIONES DE TEMAS SEPARADAS
// ============================================================================

import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeDefinitions {
  // 🌊 Deep Ocean Theme
  static const AppColors deepOcean = AppColors(
    name: "deep_ocean",
    displayName: "🌊 Deep Ocean",
    icon: "🌊",
    description: "Tranquilo y minimalista",
    isDark: true,
    primaryBg: Color(0xFF0A0E1A),
    secondaryBg: Color(0xFF141B2D),
    surface: Color(0xFF141B2D),
    surfaceVariant: Color(0xFF1E2A3F),
    accentPrimary: Color(0xFF1E3A8A),
    accentSecondary: Color(0xFF3B82F6),
    textPrimary: Color(0xFFE8EAF0),
    textSecondary: Color(0xFFB3B8C8),
    textHint: Color(0xFF8691A8),
    positiveMain: Color(0xFF10B981),
    positiveLight: Color(0x3310B981),
    positiveGlow: Color(0x6610B981),
    negativeMain: Color(0xFFEF4444),
    negativeLight: Color(0x33EF4444),
    negativeGlow: Color(0x66EF4444),
    shadowColor: Color(0x4D1E3A8A),
    borderColor: Color(0xFF1E3A8A),
    glassBg: Color(0x331E3A8A),
    gradientHeader: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    gradientButton: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
  );

  // ⚡ Electric Dark Theme
  static const AppColors electricDark = AppColors(
    name: "electric_dark",
    displayName: "⚡ Electric Dark",
    icon: "⚡",
    description: "Futurista y moderno",
    isDark: true,
    primaryBg: Color(0xFF0C0C0F),
    secondaryBg: Color(0xFF1A1A23),
    surface: Color(0xFF1A1A23),
    surfaceVariant: Color(0xFF24243A),
    accentPrimary: Color(0xFF6366F1),
    accentSecondary: Color(0xFF8B5CF6),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFCBD5E1),
    textHint: Color(0xFF94A3B8),
    positiveMain: Color(0xFF06D6A0),
    positiveLight: Color(0x3306D6A0),
    positiveGlow: Color(0x6606D6A0),
    negativeMain: Color(0xFFF72585),
    negativeLight: Color(0x33F72585),
    negativeGlow: Color(0x66F72585),
    shadowColor: Color(0x4D6366F1),
    borderColor: Color(0xFF6366F1),
    glassBg: Color(0x336366F1),
    gradientHeader: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    gradientButton: [Color(0xFF06D6A0), Color(0xFF00E5C7)],
  );

  // 🌸 Spring Light Theme
  static const AppColors springLight = AppColors(
    name: "spring_light",
    displayName: "🌸 Spring Light",
    icon: "🌸",
    description: "Fresco y primaveral",
    isDark: false,
    primaryBg: Color(0xFFF8FAFC),
    secondaryBg: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF1F5F9),
    accentPrimary: Color(0xFF059669),
    accentSecondary: Color(0xFF10B981),
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF4B5563),
    textHint: Color(0xFF9CA3AF),
    positiveMain: Color(0xFF059669),
    positiveLight: Color(0xFFECFDF5),
    positiveGlow: Color(0xFFA7F3D0),
    negativeMain: Color(0xFFDC2626),
    negativeLight: Color(0xFFFEF2F2),
    negativeGlow: Color(0xFFFECACA),
    shadowColor: Color(0x33059669),
    borderColor: Color(0xFFD1D5DB),
    glassBg: Color(0x1A059669),
    gradientHeader: [Color(0xFF059669), Color(0xFF10B981)],
    gradientButton: [Color(0xFF059669), Color(0xFF047857)],
  );

  // 🌅 Sunset Warm Theme
  static const AppColors sunsetWarm = AppColors(
    name: "sunset_warm",
    displayName: "🌅 Sunset Warm",
    icon: "🌅",
    description: "Cálido y acogedor",
    isDark: false,
    primaryBg: Color(0xFFFFF7ED),
    secondaryBg: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF8F9FA),
    accentPrimary: Color(0xFFEA580C),
    accentSecondary: Color(0xFFF97316),
    textPrimary: Color(0xFF292524),
    textSecondary: Color(0xFF57534E),
    textHint: Color(0xFFA8A29E),
    positiveMain: Color(0xFF059669),
    positiveLight: Color(0xFFF0FDF4),
    positiveGlow: Color(0xFFBBF7D0),
    negativeMain: Color(0xFFDC2626),
    negativeLight: Color(0xFFFEF2F2),
    negativeGlow: Color(0xFFFECACA),
    shadowColor: Color(0x33EA580C),
    borderColor: Color(0xFFE5E7EB),
    glassBg: Color(0x1AEA580C),
    gradientHeader: [Color(0xFFEA580C), Color(0xFFF97316)],
    gradientButton: [Color(0xFFEA580C), Color(0xFFC2410C)],
  );

  // Mapa para acceso fácil
  static Map<AppThemeType, AppColors> get themes => {
    AppThemeType.deepOcean: deepOcean,
    AppThemeType.electricDark: electricDark,
    AppThemeType.springLight: springLight,
    AppThemeType.sunsetWarm: sunsetWarm,
  };
}