// ============================================================================
// daily_roadmap_demo.dart - DEMO SCREEN SHOWING THEME SWITCHING
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Theme imports
import '../../../core/themes/app_theme.dart';
import '../../../core/themes/theme_definitions.dart';

// Providers
import '../../providers/theme_provider.dart';

// Enhanced roadmap screen
import 'daily_roadmap_screen_v3.dart';

class DailyRoadmapDemo extends StatefulWidget {
  const DailyRoadmapDemo({super.key});

  @override
  State<DailyRoadmapDemo> createState() => _DailyRoadmapDemoState();
}

class _DailyRoadmapDemoState extends State<DailyRoadmapDemo> {
  AppThemeType _selectedTheme = AppThemeType.deepOcean;

  @override
  Widget build(BuildContext context) {
    final currentTheme = ThemeDefinitions.themes[_selectedTheme]!;
    
    return MaterialApp(
      title: 'Daily Roadmap Demo',
      theme: _buildThemeData(currentTheme),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Daily Roadmap - Theme Demo'),
          actions: [
            PopupMenuButton<AppThemeType>(
              icon: Text(
                currentTheme.icon,
                style: const TextStyle(fontSize: 24),
              ),
              onSelected: (AppThemeType theme) {
                setState(() {
                  _selectedTheme = theme;
                });
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: AppThemeType.deepOcean,
                  child: Row(
                    children: [
                      Text(ThemeDefinitions.deepOcean.icon, style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text(ThemeDefinitions.deepOcean.displayName),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: AppThemeType.electricDark,
                  child: Row(
                    children: [
                      Text(ThemeDefinitions.electricDark.icon, style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text(ThemeDefinitions.electricDark.displayName),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: AppThemeType.springLight,
                  child: Row(
                    children: [
                      Text(ThemeDefinitions.springLight.icon, style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text(ThemeDefinitions.springLight.displayName),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: AppThemeType.sunsetWarm,
                  child: Row(
                    children: [
                      Text(ThemeDefinitions.sunsetWarm.icon, style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text(ThemeDefinitions.sunsetWarm.displayName),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Theme info card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: currentTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: currentTheme.borderColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        currentTheme.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentTheme.displayName,
                              style: TextStyle(
                                color: currentTheme.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              currentTheme.description,
                              style: TextStyle(
                                color: currentTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Color palette preview
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildColorChip('Primary', currentTheme.accentPrimary),
                      _buildColorChip('Secondary', currentTheme.accentSecondary),
                      _buildColorChip('Positive', currentTheme.positiveMain),
                      _buildColorChip('Surface', currentTheme.surface),
                    ],
                  ),
                ],
              ),
            ),
            // Instructions
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: currentTheme.positiveLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: currentTheme.positiveMain.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: currentTheme.positiveMain,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Toca el ícono del tema en la barra superior para cambiar entre temas',
                      style: TextStyle(
                        color: currentTheme.positiveMain,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Daily roadmap screen preview
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: currentTheme.borderColor.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: const DailyRoadmapScreenV3(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildColorChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _getContrastColor(color),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    // Simple contrast calculation
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  ThemeData _buildThemeData(AppColors appColors) {
    return ThemeData(
      useMaterial3: true,
      brightness: appColors.isDark ? Brightness.dark : Brightness.light,
      primaryColor: appColors.accentPrimary,
      scaffoldBackgroundColor: appColors.primaryBg,
      
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
    );
  }
}