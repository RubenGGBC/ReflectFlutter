// lib/presentation/screens/components/modern_design_system.dart

import 'package:flutter/material.dart';

// ============================================================================
// 🎨 COLORES MODERNOS - VERSIÓN CORREGIDA Y AMPLIADA
// ============================================================================

class ModernColors {
  // Gradientes principales
  static const Color accentPurple = Color(0xFF764ba2); // ✅ AGREGADO: Color faltante

  // Agregar estas líneas dentro de la clase ModernColors:
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color surfaceDark = Color(0xFF141B2D);
  static const List<Color> primaryGradient = [Color(0xFF667eea), Color(0xFF764ba2)];
  static const List<Color> positiveGradient = [Color(0xFF11998e), Color(0xFF38ef7d)];
  static const List<Color> negativeGradient = [Color(0xFFff6b6b), Color(0xFFfeca57)];
  static const List<Color> neutralGradient = [Color(0xFF2c3e50), Color(0xFF3498db)];

  // ✅ NUEVO: Gradientes añadidos para warning y error
  static const List<Color> warningGradient = [Color(0xFFfeca57), Color(0xFFff9f43)];
  static const List<Color> errorGradient = [Color(0xFFff6b6b), Color(0xFFee5253)];


  // Surfaces con glassmorphism
  static const Color glassSurface = Color(0x1AFFFFFF);
  static const Color glassSecondary = Color(0x0DFFFFFF);

  // Backgrounds
  static const Color darkPrimary = Color(0xFF0a0e27);
  static const Color darkSecondary = Color(0xFF2d1b69);
  static const Color darkAccent = Color(0xFF11998e);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textHint = Color(0x66FFFFFF);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Category colors
  static const Map<String, Color> categories = {
    'emocional': Color(0xFF667eea),
    'fisico': Color(0xFF11998e),
    'social': Color(0xFFff6b6b),
    'mental': Color(0xFF4ecdc4),
    'espiritual': Color(0xFF764ba2),
  };

}

// ... (El resto del archivo ModernSpacing, ModernTypography, etc., permanece igual)

class ModernSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusRound = 25.0;
}

class ModernTypography {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: ModernColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: ModernColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: ModernColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ModernColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: ModernColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: ModernColors.textHint,
    height: 1.3,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ModernColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ModernColors.textSecondary,
  );
}


// ============================================================================
// 🎭 COMPONENTES MODERNOS REUTILIZABLES
// ============================================================================

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final List<Color>? gradient;
  final bool blur;
  final VoidCallback? onTap;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.gradient,
    this.blur = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(ModernSpacing.md),
      decoration: BoxDecoration(
        gradient: gradient != null
            ? LinearGradient(colors: gradient!)
            : null,
        color: backgroundColor ?? (gradient == null ? ModernColors.glassSurface : null),
        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}

class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;
  final List<Color>? gradient;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
    this.gradient,
    this.width,
    this.padding,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.isLoading ? null : widget.onPressed,
        child: Container(
          width: widget.width,
          padding: widget.padding ?? const EdgeInsets.symmetric(
            horizontal: ModernSpacing.lg,
            vertical: ModernSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
              colors: widget.gradient ?? ModernColors.primaryGradient,
            )
                : null,
            color: widget.isPrimary ? null : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
            border: Border.all(
              color: widget.isPrimary
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.2),
            ),
            boxShadow: widget.isPrimary ? [
              BoxShadow(
                color: (widget.gradient ?? ModernColors.primaryGradient).first.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ] else ...[
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: ModernSpacing.sm),
                ],
                Text(
                  widget.text,
                  style: ModernTypography.button,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ModernTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted; // FIX: Added this parameter
  final int maxLines;
  final int? maxLength;
  final TextInputType keyboardType;

  const ModernTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.onFieldSubmitted, // FIX: Added this to constructor
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: ModernTypography.bodyMedium,
          ),
          const SizedBox(height: ModernSpacing.sm),
        ],
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            validator: widget.validator,
            onFieldSubmitted: widget.onFieldSubmitted, // FIX: Passed parameter to TextFormField
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            style: ModernTypography.bodyLarge,
            decoration: InputDecoration(
              counterText: "",
              hintText: widget.hintText,
              hintStyle: ModernTypography.bodyMedium.copyWith(
                color: ModernColors.textHint,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                widget.prefixIcon,
                color: _isFocused ? ModernColors.primaryGradient.first : ModernColors.textHint,
              )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? GestureDetector(
                onTap: widget.onSuffixTap,
                child: Icon(
                  widget.suffixIcon,
                  color: ModernColors.textHint,
                ),
              )
                  : null,
              filled: true,
              fillColor: ModernColors.glassSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                borderSide: BorderSide(
                  color: ModernColors.primaryGradient.first,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                borderSide: const BorderSide(
                  color: ModernColors.error,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: ModernSpacing.md,
                vertical: ModernSpacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ... Rest of the file remains the same ...

class ModernMoodSelector extends StatefulWidget {
  final int selectedMood;
  final ValueChanged<int> onMoodChanged;
  final bool animated;

  const ModernMoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodChanged,
    this.animated = true,
  });

  @override
  State<ModernMoodSelector> createState() => _ModernMoodSelectorState();
}

class _ModernMoodSelectorState extends State<ModernMoodSelector>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, dynamic>> moods = [
    {'emoji': '😢', 'label': 'Muy mal', 'color': const Color(0xFFEF4444)},
    {'emoji': '😔', 'label': 'Mal', 'color': const Color(0xFFF97316)},
    {'emoji': '😐', 'label': 'Regular', 'color': const Color(0xFFF59E0B)},
    {'emoji': '🙂', 'label': 'Bien', 'color': const Color(0xFF10B981)},
    {'emoji': '😊', 'label': 'Muy bien', 'color': const Color(0xFF059669)},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cómo te sientes hoy?',
            style: ModernTypography.heading3,
          ),
          const SizedBox(height: ModernSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final mood = moods[index];
              final isSelected = widget.selectedMood == index + 1;

              return GestureDetector(
                onTap: () {
                  if (widget.animated) {
                    _controller.forward().then((_) {
                      _controller.reverse();
                    });
                  }
                  widget.onMoodChanged(index + 1);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(ModernSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? mood['color'].withOpacity(0.2)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? mood['color']
                          : Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: isSelected ? 32 : 24,
                        ),
                        child: Text(mood['emoji']),
                      ),
                      const SizedBox(height: ModernSpacing.xs),
                      Text(
                        mood['label'],
                        style: ModernTypography.bodySmall.copyWith(
                          color: isSelected ? mood['color'] : ModernColors.textHint,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ModernProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final Color color;
  final IconData icon;
  final String? trailing;

  const ModernProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.color,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ModernSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: ModernSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ModernTypography.bodyLarge),
                    Text(subtitle, style: ModernTypography.bodySmall),
                  ],
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: ModernTypography.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: ModernSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 🎬 ANIMACIONES PREDEFINIDAS
// ============================================================================

class ModernAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve easeInOut = Curves.easeInOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve bounceOut = Curves.bounceOut;
}

// ============================================================================
// 🌈 TEMA GLOBAL
// ============================================================================

class ModernTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'System',
      scaffoldBackgroundColor: ModernColors.darkPrimary,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF667eea),
        secondary: Color(0xFF11998e),
        surface: Color(0xFF2d1b69),
        error: ModernColors.error,
      ),
      textTheme: const TextTheme(
        displayLarge: ModernTypography.heading1,
        displayMedium: ModernTypography.heading2,
        displaySmall: ModernTypography.heading3,
        bodyLarge: ModernTypography.bodyLarge,
        bodyMedium: ModernTypography.bodyMedium,
        bodySmall: ModernTypography.bodySmall,
        labelLarge: ModernTypography.button,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: ModernSpacing.lg,
            vertical: ModernSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ModernColors.glassSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ModernSpacing.md,
          vertical: ModernSpacing.md,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: ModernColors.glassSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        ),
      ),
    );
  }
}
