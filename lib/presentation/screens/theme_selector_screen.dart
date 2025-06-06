// ============================================================================
// presentation/screens/theme_selector_screen.dart - VERSIÓN LIMPIA SIN DUPLICADOS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../providers/theme_provider.dart';

// Enum local SOLO para este selector
enum ThemeSelectorType {
  deepOcean,
  electricDark,
  springLight,
  sunsetWarm,
}

class ThemeSelectorScreen extends StatefulWidget {
  const ThemeSelectorScreen({Key? key}) : super(key: key);

  @override
  State<ThemeSelectorScreen> createState() => _ThemeSelectorScreenState();
}

class _ThemeSelectorScreenState extends State<ThemeSelectorScreen> {
  final Logger _logger = Logger();
  ThemeSelectorType? currentSelection;

  // Definiciones de temas LOCALES para el selector
  final Map<ThemeSelectorType, Map<String, dynamic>> _localThemes = {
    ThemeSelectorType.deepOcean: {
      'name': 'Deep Ocean',
      'displayName': '🌊 Deep Ocean',
      'description': 'Tranquilo y minimalista',
      'isDark': true,
      'primaryColor': const Color(0xFF1E3A8A),
      'positiveColor': const Color(0xFF10B981),
      'negativeColor': const Color(0xFFEF4444),
      'bgColor': const Color(0xFF0A0E1A),
      'surfaceColor': const Color(0xFF141B2D),
    },
    ThemeSelectorType.electricDark: {
      'name': 'Electric Dark',
      'displayName': '⚡ Electric Dark',
      'description': 'Futurista y moderno',
      'isDark': true,
      'primaryColor': const Color(0xFF6366F1),
      'positiveColor': const Color(0xFF06D6A0),
      'negativeColor': const Color(0xFFF72585),
      'bgColor': const Color(0xFF0C0C0F),
      'surfaceColor': const Color(0xFF1A1A23),
    },
    ThemeSelectorType.springLight: {
      'name': 'Spring Light',
      'displayName': '🌸 Spring Light',
      'description': 'Fresco y primaveral',
      'isDark': false,
      'primaryColor': const Color(0xFF059669),
      'positiveColor': const Color(0xFF059669),
      'negativeColor': const Color(0xFFDC2626),
      'bgColor': const Color(0xFFF8FAFC),
      'surfaceColor': const Color(0xFFFFFFFF),
    },
    ThemeSelectorType.sunsetWarm: {
      'name': 'Sunset Warm',
      'displayName': '🌅 Sunset Warm',
      'description': 'Cálido y acogedor',
      'isDark': false,
      'primaryColor': const Color(0xFFEA580C),
      'positiveColor': const Color(0xFF059669),
      'negativeColor': const Color(0xFFDC2626),
      'bgColor': const Color(0xFFFFF7ED),
      'surfaceColor': const Color(0xFFFFFFFF),
    },
  };

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: themeProvider.currentColors.primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(themeProvider),
            Expanded(
              child: _buildContent(themeProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: themeProvider.currentColors.gradientHeader,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Botón volver
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '← Volver',
                style: TextStyle(color: Colors.white),
              ),
            ),
            // Título
            const Expanded(
              child: Text(
                '🎨 Selector de Temas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            // Espacio para balance
            const SizedBox(width: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildIntroduction(themeProvider),
          const SizedBox(height: 30),
          _buildDarkThemesSection(themeProvider),
          const SizedBox(height: 30),
          _buildLightThemesSection(themeProvider),
          const SizedBox(height: 30),
          _buildApplyButton(themeProvider),
        ],
      ),
    );
  }

  Widget _buildIntroduction(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: themeProvider.currentColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeProvider.currentColors.borderColor),
      ),
      child: Column(
        children: [
          Text(
            'Elige tu tema favorito',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Cada tema tiene su propia personalidad y ambiente único',
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.currentColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '📱 Tema actual: Deep Ocean',
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.currentColors.accentPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDarkThemesSection(ThemeProvider themeProvider) {
    return Column(
      children: [
        Text(
          '🌙 TEMAS OSCUROS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.currentColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildThemeCard(ThemeSelectorType.deepOcean, themeProvider),
            const SizedBox(width: 16),
            _buildThemeCard(ThemeSelectorType.electricDark, themeProvider),
          ],
        ),
      ],
    );
  }

  Widget _buildLightThemesSection(ThemeProvider themeProvider) {
    return Column(
      children: [
        Text(
          '☀️ TEMAS CLAROS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.currentColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildThemeCard(ThemeSelectorType.springLight, themeProvider),
            const SizedBox(width: 16),
            _buildThemeCard(ThemeSelectorType.sunsetWarm, themeProvider),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeCard(ThemeSelectorType themeType, ThemeProvider themeProvider) {
    final themeData = _localThemes[themeType]!;
    final isSelected = currentSelection == themeType;
    final isCurrent = themeType == ThemeSelectorType.deepOcean; // Deep Ocean siempre es actual

    return GestureDetector(
      onTap: () => _selectTheme(themeType),
      child: Container(
        width: 160,
        height: 240,
        decoration: BoxDecoration(
          color: themeProvider.currentColors.surface,
          border: Border.all(
            color: isSelected
                ? themeData['primaryColor'] as Color
                : themeProvider.currentColors.borderColor,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: themeProvider.currentColors.shadowColor,
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Badge de tipo (Oscuro/Claro)
            _buildTypeBadge(themeData),
            const SizedBox(height: 12),

            // Título y descripción
            _buildThemeHeader(themeData, themeProvider),
            const SizedBox(height: 12),

            // Mini preview de colores
            _buildMiniPreview(themeData),
            const SizedBox(height: 12),

            // Badge de "ACTUAL" si corresponde
            _buildCurrentBadge(isCurrent, themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(Map<String, dynamic> themeData) {
    final isDark = themeData['isDark'] as bool;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          isDark ? 'OSCURO' : 'CLARO',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeHeader(Map<String, dynamic> themeData, ThemeProvider themeProvider) {
    return Column(
      children: [
        Text(
          themeData['displayName'] as String,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.currentColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          themeData['description'] as String,
          style: TextStyle(
            fontSize: 12,
            color: themeProvider.currentColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMiniPreview(Map<String, dynamic> themeData) {
    return Container(
      width: 130,
      height: 80,
      decoration: BoxDecoration(
        color: themeData['bgColor'] as Color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: (themeData['primaryColor'] as Color).withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          // Mini header
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: themeData['primaryColor'] as Color,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Header',
              style: TextStyle(
                fontSize: 8,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Cards de ejemplo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 55,
                height: 16,
                decoration: BoxDecoration(
                  color: themeData['positiveColor'] as Color,
                  borderRadius: BorderRadius.circular(3),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '+ Positivo',
                  style: TextStyle(
                    fontSize: 7,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 55,
                height: 16,
                decoration: BoxDecoration(
                  color: themeData['negativeColor'] as Color,
                  borderRadius: BorderRadius.circular(3),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '- Negativo',
                  style: TextStyle(
                    fontSize: 7,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Surface demo
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: themeData['surfaceColor'] as Color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: (themeData['primaryColor'] as Color).withOpacity(0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              'Surface',
              style: TextStyle(
                fontSize: 7,
                color: (themeData['isDark'] as bool) ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBadge(bool isCurrent, ThemeProvider themeProvider) {
    if (!isCurrent) {
      return const SizedBox(height: 20);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: themeProvider.currentColors.positiveMain,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'ACTUAL',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildApplyButton(ThemeProvider themeProvider) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 30),
      child: SizedBox(
        width: 280,
        height: 55,
        child: ElevatedButton(
          onPressed: currentSelection != null ? _applySelectedTheme : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: themeProvider.currentColors.positiveMain,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('✨', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text(
                'Aplicar Tema Seleccionado',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTheme(ThemeSelectorType themeType) {
    setState(() {
      currentSelection = themeType;
    });

    final themeData = _localThemes[themeType]!;
    _logger.i('🎯 Tema seleccionado: ${themeData['displayName']}');
  }

  void _applySelectedTheme() {
    if (currentSelection == null) {
      _showMessage('⚠️ Selecciona un tema primero', isError: true);
      return;
    }

    final selectedTheme = _localThemes[currentSelection!]!;

    // Por ahora solo mostrar mensaje, ya que el ThemeProvider usa colores fijos
    _showMessage('✨ ${selectedTheme['displayName']} seleccionado (funcionalidad pendiente)');

    // Limpiar selección
    setState(() {
      currentSelection = null;
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    final themeProvider = context.read<ThemeProvider>();

    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: isError
          ? themeProvider.currentColors.negativeMain
          : themeProvider.currentColors.positiveMain,
      duration: const Duration(milliseconds: 3000),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}