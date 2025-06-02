// ============================================================================
// presentation/widgets/gradient_header.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class GradientHeader extends StatelessWidget {
  final String title;
  final Widget? leftButton;
  final Widget? rightButton;
  final double? height;

  const GradientHeader({
    Key? key,
    required this.title,
    this.leftButton,
    this.rightButton,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      height: height ?? 120,
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
        boxShadow: [
          BoxShadow(
            color: themeProvider.currentColors.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              leftButton ?? const SizedBox(width: 80),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              rightButton ?? const SizedBox(width: 80),
            ],
          ),
        ),
      ),
    );
  }
}