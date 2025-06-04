// ============================================================================
// presentation/widgets/themed_container.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class ThemedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final bool addShadow;
  final bool addBorder;
  final bool isSurface;

  const ThemedContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.addShadow = true,
    this.addBorder = true,
    this.isSurface = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin,
      decoration: BoxDecoration(
        color: isSurface
            ? themeProvider.currentColors.surface
            : themeProvider.currentColors.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        border: addBorder
            ? Border.all(color: themeProvider.currentColors.borderColor)
            : null,
        boxShadow: addShadow ? [
          BoxShadow(
            color: themeProvider.currentColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: child,
    );
  }
}
