import 'package:flutter/material.dart';

// Enums para los tipos de tema (equivalente a ThemeType en Python)
enum ReflectThemeType {
  deepOcean,
  electricDark,
  springLight,
  sunsetWarm,
}

// Clase para representar un tema (equivalente a ReflectTheme en Python)
class ReflectTheme {
  final String name;
  final String displayName;
  final String icon;
  final String description;
  final bool isDark;

  // Colores del tema
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

  const ReflectTheme({
    required this.name,
    required this.displayName,
    required this.icon,
    required this.description,
    required this.isDark,
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

// Pantalla principal del selector de temas
class ThemeSelectorScreen extends StatefulWidget {
  final Function(ReflectThemeType)? onThemeChanged;
  final VoidCallback? onGoBack;

  const ThemeSelectorScreen({
    Key? key,
    this.onThemeChanged,
    this.onGoBack,
  }) : super(key: key);

  @override
  State<ThemeSelectorScreen> createState() => _ThemeSelectorScreenState();
}

class _ThemeSelectorScreenState extends State<ThemeSelectorScreen> {
  ReflectThemeType? currentSelection;
  late ReflectTheme currentTheme;

  @override
  void initState() {
    super.initState();
    // Por ahora usamos Deep Ocean como tema por defecto
    currentTheme = _getTheme(ReflectThemeType.deepOcean);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentTheme.primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  // Construir el header con gradiente
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: currentTheme.gradientHeader,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Botón volver
              TextButton(
                onPressed: widget.onGoBack,
                child: const Text(
                  '← Volver',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // Título
              Expanded(
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
      ),
    );
  }

  // Construir el contenido principal
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildIntroduction(),
          const SizedBox(height: 30),
          _buildDarkThemesSection(),
          const SizedBox(height: 30),
          _buildLightThemesSection(),
          const SizedBox(height: 30),
          _buildApplyButton(),
        ],
      ),
    );
  }

  // Sección de introducción
  Widget _buildIntroduction() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: [
          Text(
            'Elige tu tema favorito',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: currentTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Cada tema tiene su propia personalidad y ambiente único',
            style: TextStyle(
              fontSize: 14,
              color: currentTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '📱 Tema actual: ${currentTheme.displayName}',
            style: TextStyle(
              fontSize: 12,
              color: currentTheme.accentPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Sección de temas oscuros
  Widget _buildDarkThemesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            '🌙 TEMAS OSCUROS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: currentTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildThemeCard(ReflectThemeType.deepOcean),
              const SizedBox(width: 16),
              _buildThemeCard(ReflectThemeType.electricDark),
            ],
          ),
        ],
      ),
    );
  }

  // Sección de temas claros
  Widget _buildLightThemesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            '☀️ TEMAS CLAROS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: currentTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildThemeCard(ReflectThemeType.springLight),
              const SizedBox(width: 16),
              _buildThemeCard(ReflectThemeType.sunsetWarm),
            ],
          ),
        ],
      ),
    );
  }

  // Botón para aplicar tema seleccionado
  Widget _buildApplyButton() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 30),
      child: SizedBox(
        width: 280,
        height: 55,
        child: ElevatedButton(
          onPressed: currentSelection != null ? _applySelectedTheme : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: currentTheme.positiveMain,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✨', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
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

  // Método para obtener tema según tipo
  ReflectTheme _getTheme(ReflectThemeType type) {
    return ThemeDefinitions.themes[type] ?? ThemeDefinitions.deepOcean;
  }

  // Seleccionar un tema
  void _selectTheme(ReflectThemeType themeType) {
    setState(() {
      currentSelection = themeType;
    });

    final themeName = ThemeDefinitions.themes[themeType]?.displayName ?? '';
    print('🎯 Tema seleccionado: $themeName');
  }

  // Aplicar tema seleccionado
  void _applySelectedTheme() {
    if (currentSelection == null) {
      _showMessage('⚠️ Selecciona un tema primero', isError: true);
      return;
    }

    final selectedTheme = _getTheme(currentSelection!);

    // Actualizar tema actual inmediatamente para preview
    setState(() {
      currentTheme = selectedTheme;
    });

    // Llamar callback si existe (conexión con tu theme_provider)
    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!(currentSelection!);
    }

    _showMessage('✨ ${selectedTheme.displayName} aplicado');

    // Limpiar selección
    setState(() {
      currentSelection = null;
    });
  }

  // Mostrar mensaje al usuario
  void _showMessage(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: isError ? currentTheme.negativeMain : currentTheme.positiveMain,
      duration: const Duration(milliseconds: 3000),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Crear tarjeta de tema individual
  Widget _buildThemeCard(ReflectThemeType themeType) {
    final theme = _getTheme(themeType);
    final isCurrentTheme = currentTheme.name == theme.name;
    final isSelected = currentSelection == themeType;

    // Determinar colores del borde
    Color borderColor = theme.accentPrimary;
    double borderWidth = 1.0;

    if (isSelected) {
      borderWidth = 3.0;
    }

    return GestureDetector(
      onTap: () => _selectTheme(themeType),
      child: Container(
        width: 160,
        height: 240, // Aumentado para acomodar más contenido
        decoration: BoxDecoration(
          color: currentTheme.surface,
          border: Border.all(
            color: isSelected ? borderColor : currentTheme.borderColor,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: currentTheme.shadowColor,
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
            _buildTypeBadge(theme),
            const SizedBox(height: 12),

            // Título y descripción
            _buildThemeHeader(theme),
            const SizedBox(height: 12),

            // Mini preview de colores
            _buildMiniPreview(theme),
            const SizedBox(height: 12),

            // Badge de "ACTUAL" si corresponde
            _buildCurrentBadge(isCurrentTheme),
          ],
        ),
      ),
    );
  }

  // Badge que indica si es tema claro u oscuro
  Widget _buildTypeBadge(ReflectTheme theme) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: theme.isDark ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          theme.isDark ? 'OSCURO' : 'CLARO',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: theme.isDark ? Colors.white : theme.textPrimary,
          ),
        ),
      ),
    );
  }

  // Header con título y descripción del tema
  Widget _buildThemeHeader(ReflectTheme theme) {
    return Column(
      children: [
        Text(
          theme.displayName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: currentTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          theme.description,
          style: TextStyle(
            fontSize: 12,
            color: currentTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Mini preview de los colores del tema
  Widget _buildMiniPreview(ReflectTheme theme) {
    return Container(
      width: 130,
      height: 80,
      decoration: BoxDecoration(
        color: theme.primaryBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.borderColor),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          // Mini header
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: theme.accentPrimary,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              'Header',
              style: TextStyle(
                fontSize: 8,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Cards de ejemplo (positivo y negativo)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 55,
                height: 16,
                decoration: BoxDecoration(
                  color: theme.positiveMain,
                  borderRadius: BorderRadius.circular(3),
                ),
                alignment: Alignment.center,
                child: Text(
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
                  color: theme.negativeMain,
                  borderRadius: BorderRadius.circular(3),
                ),
                alignment: Alignment.center,
                child: Text(
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
              color: theme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.borderColor),
            ),
            alignment: Alignment.center,
            child: Text(
              'Surface',
              style: TextStyle(
                fontSize: 7,
                color: theme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Badge que indica si es el tema actual
  Widget _buildCurrentBadge(bool isCurrentTheme) {
    if (!isCurrentTheme) {
      return const SizedBox(height: 20); // Espacio en blanco para mantener altura
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: currentTheme.positiveMain,
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
}

// Definición de todos los temas disponibles
class ThemeDefinitions {
  // 🌊 Deep Ocean Theme
  static const deepOcean = ReflectTheme(
    name: 'deep_ocean',
    displayName: '🌊 Deep Ocean',
    icon: '🌊',
    description: 'Tranquilo y minimalista',
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
    negativeMain: Color(0xFFEF4444),
    negativeLight: Color(0x33EF4444),
    borderColor: Color(0xFF1E3A8A),
    shadowColor: Color(0x331E3A8A),
    gradientHeader: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
  );

  // ⚡ Electric Dark Theme
  static const electricDark = ReflectTheme(
    name: 'electric_dark',
    displayName: '⚡ Electric Dark',
    icon: '⚡',
    description: 'Futurista y moderno',
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
    negativeMain: Color(0xFFF72585),
    negativeLight: Color(0x33F72585),
    borderColor: Color(0xFF6366F1),
    shadowColor: Color(0x336366F1),
    gradientHeader: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  // 🌸 Spring Light Theme
  static const springLight = ReflectTheme(
    name: 'spring_light',
    displayName: '🌸 Spring Light',
    icon: '🌸',
    description: 'Fresco y primaveral',
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
    negativeMain: Color(0xFFDC2626),
    negativeLight: Color(0xFFFEF2F2),
    borderColor: Color(0xFFD1D5DB),
    shadowColor: Color(0x33059669),
    gradientHeader: [Color(0xFF059669), Color(0xFF10B981)],
  );

  // 🌅 Sunset Warm Theme
  static const sunsetWarm = ReflectTheme(
    name: 'sunset_warm',
    displayName: '🌅 Sunset Warm',
    icon: '🌅',
    description: 'Cálido y acogedor',
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
    negativeMain: Color(0xFFDC2626),
    negativeLight: Color(0xFFFEF2F2),
    borderColor: Color(0xFFE5E7EB),
    shadowColor: Color(0x33EA580C),
    gradientHeader: [Color(0xFFEA580C), Color(0xFFF97316)],
  );

  // Mapa para acceso fácil
  static const Map<ReflectThemeType, ReflectTheme> themes = {
    ReflectThemeType.deepOcean: deepOcean,
    ReflectThemeType.electricDark: electricDark,
    ReflectThemeType.springLight: springLight,
    ReflectThemeType.sunsetWarm: sunsetWarm,
  };
}