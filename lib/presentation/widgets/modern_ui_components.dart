// ============================================================================
// MODERN UI COMPONENTS - Sistema de componentes reutilizables
// ============================================================================
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

// ============================================================================
// 1. MODERN CARD - Glassmorphism effect
// ============================================================================

class ModernCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isClickable;
  final double borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;

  const ModernCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.all(8),
    this.onTap,
    this.isClickable = false,
    this.borderRadius = 20,
    this.backgroundColor,
    this.shadows,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: widget.isClickable || widget.onTap != null
              ? (_) => _animationController.forward()
              : null,
          onTapUp: widget.isClickable || widget.onTap != null
              ? (_) => _animationController.reverse()
              : null,
          onTapCancel: widget.isClickable || widget.onTap != null
              ? () => _animationController.reverse()
              : null,
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.backgroundColor ??
                  Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: widget.shadows ??
                  [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. ANIMATED BUTTON - Múltiples variantes con animaciones
// ============================================================================

enum ModernButtonType { primary, secondary, ghost, icon }

class ModernButton extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ModernButtonType type;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;
  final List<Color>? gradientColors;

  const ModernButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.type = ModernButtonType.primary,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
    this.gradientColors,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(_animationController);
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTapDown: widget.onPressed != null
                  ? (_) => _animationController.forward()
                  : null,
              onTapUp: widget.onPressed != null
                  ? (_) => _animationController.reverse()
                  : null,
              onTapCancel: widget.onPressed != null
                  ? () => _animationController.reverse()
                  : null,
              onTap: widget.onPressed,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: _getButtonDecoration(),
                child: _buildButtonContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _getButtonDecoration() {
    switch (widget.type) {
      case ModernButtonType.primary:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradientColors ??
                [const Color(0xFF667eea), const Color(0xFF764ba2)],
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: (widget.gradientColors?.first ?? const Color(0xFF667eea))
                  .withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case ModernButtonType.secondary:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: const Color(0xFF667eea),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case ModernButtonType.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );
      case ModernButtonType.icon:
        return BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        );
    }
  }

  Widget _buildButtonContent() {
    Color textColor;
    switch (widget.type) {
      case ModernButtonType.primary:
        textColor = Colors.white;
        break;
      case ModernButtonType.secondary:
        textColor = const Color(0xFF667eea);
        break;
      case ModernButtonType.ghost:
        textColor = Colors.white;
        break;
      case ModernButtonType.icon:
        textColor = Colors.white;
        break;
    }

    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: textColor,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (widget.icon != null && widget.text != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            widget.text!,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (widget.icon != null) {
      return Center(
        child: Icon(widget.icon, color: textColor, size: 24),
      );
    }

    return Center(
      child: Text(
        widget.text ?? '',
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================================
// 3. MODERN PROGRESS INDICATOR - Circular con animaciones
// ============================================================================

class ModernProgressIndicator extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final List<Color> progressColors;
  final Widget? centerWidget;
  final bool showPercentage;

  const ModernProgressIndicator({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 6,
    this.backgroundColor = const Color(0xFFE5E7EB),
    this.progressColors = const [Color(0xFF10B981), Color(0xFF059669)],
    this.centerWidget,
    this.showPercentage = true,
  });

  @override
  State<ModernProgressIndicator> createState() =>
      _ModernProgressIndicatorState();
}

class _ModernProgressIndicatorState extends State<ModernProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ModernProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: widget.strokeWidth,
              backgroundColor: widget.backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(widget.backgroundColor),
            ),
          ),
          // Progress circle
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return SizedBox(
                width: widget.size,
                height: widget.size,
                child: CustomPaint(
                  painter: _GradientCircularProgressPainter(
                    progress: _progressAnimation.value,
                    strokeWidth: widget.strokeWidth,
                    gradientColors: widget.progressColors,
                  ),
                ),
              );
            },
          ),
          // Center content
          if (widget.centerWidget != null)
            widget.centerWidget!
          else if (widget.showPercentage)
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Text(
                  '${(_progressAnimation.value * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;

  _GradientCircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final gradient = SweepGradient(
      colors: gradientColors,
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
    );

    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============================================================================
// 4. FLOATING PANEL - Modal con backdrop blur
// ============================================================================

class FloatingPanel extends StatefulWidget {
  final Widget child;
  final double? height;
  final bool isDismissible;
  final VoidCallback? onDismiss;

  const FloatingPanel({
    super.key,
    required this.child,
    this.height,
    this.isDismissible = true,
    this.onDismiss,
  });

  @override
  State<FloatingPanel> createState() => _FloatingPanelState();
}

class _FloatingPanelState extends State<FloatingPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isDismissible
          ? () {
        _dismiss();
      }
          : null,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Backdrop blur
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
            ),
            // Panel content
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _slideAnimation,
                child: GestureDetector(
                  onTap: () {}, // Prevent dismissal when tapping on panel
                  child: Container(
                    width: double.infinity,
                    height: widget.height ?? MediaQuery.of(context).size.height * 0.6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Handle
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Content
                        Expanded(child: widget.child),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _dismiss() {
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    }
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }
}

// Helper para mostrar el panel
void showFloatingPanel(
    BuildContext context, {
      required Widget child,
      double? height,
      bool isDismissible = true,
      VoidCallback? onDismiss,
    }) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    pageBuilder: (context, animation, secondaryAnimation) {
      return FloatingPanel(
        height: height,
        isDismissible: isDismissible,
        onDismiss: onDismiss,
        child: child,
      );
    },
  );
}

// ============================================================================
// 5. CONSTANTS & HELPERS
// ============================================================================



class ModernColors {
  static const primaryGradient = [Color(0xFF667eea), Color(0xFF764ba2)];
  static const positiveGradient = [Color(0xFF10B981), Color(0xFF059669)];
  static const warningGradient = [Color(0xFFF59E0B), Color(0xFFD97706)];
  static const errorGradient = [Color(0xFFEF4444), Color(0xFFDC2626)];

  static const glassSurface = Color(0x1AFFFFFF);
  static const cardSurface = Color(0xFFF9FAFB);
  static const borderColor = Color(0xFFE5E7EB);

  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);
}

class ModernSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class ModernTypography {
  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: ModernColors.textPrimary,
  );

  static const headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: ModernColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    color: ModernColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: ModernColors.textSecondary,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: ModernColors.textHint,
  );
}