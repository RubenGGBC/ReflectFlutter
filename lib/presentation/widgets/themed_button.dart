// ============================================================================
// presentation/widgets/themed_button.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

enum ThemedButtonType {
  primary,
  outlined,
  positive,
  negative,
  text,
}

class ThemedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ThemedButtonType type;
  final double? width;
  final double? height;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;

  const ThemedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.type = ThemedButtonType.primary,
    this.width,
    this.height,
    this.isLoading = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    if (isLoading) {
      return _buildLoadingButton(themeProvider);
    }

    switch (type) {
      case ThemedButtonType.primary:
        return _buildElevatedButton(
          context,
          themeProvider,
          backgroundColor: themeProvider.currentColors.accentPrimary,
          foregroundColor: Colors.white,
        );

      case ThemedButtonType.positive:
        return _buildElevatedButton(
          context,
          themeProvider,
          backgroundColor: themeProvider.currentColors.positiveMain,
          foregroundColor: Colors.white,
        );

      case ThemedButtonType.negative:
        return _buildElevatedButton(
          context,
          themeProvider,
          backgroundColor: themeProvider.currentColors.negativeMain,
          foregroundColor: Colors.white,
        );

      case ThemedButtonType.outlined:
        return _buildOutlinedButton(context, themeProvider);

      case ThemedButtonType.text:
        return _buildTextButton(context, themeProvider);
    }
  }

  Widget _buildElevatedButton(
      BuildContext context,
      ThemeProvider themeProvider, {
        required Color backgroundColor,
        required Color foregroundColor,
      }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 4,
          shadowColor: themeProvider.currentColors.shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: child,
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, ThemeProvider themeProvider) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: themeProvider.currentColors.accentPrimary,
          side: BorderSide(color: themeProvider.currentColors.accentPrimary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: child,
      ),
    );
  }

  Widget _buildTextButton(BuildContext context, ThemeProvider themeProvider) {
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: themeProvider.currentColors.accentPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: child,
      ),
    );
  }

  Widget _buildLoadingButton(ThemeProvider themeProvider) {
    Color backgroundColor;
    switch (type) {
      case ThemedButtonType.positive:
        backgroundColor = themeProvider.currentColors.positiveMain;
        break;
      case ThemedButtonType.negative:
        backgroundColor = themeProvider.currentColors.negativeMain;
        break;
      case ThemedButtonType.outlined:
      case ThemedButtonType.text:
        backgroundColor = themeProvider.currentColors.accentPrimary.withOpacity(0.1);
        break;
      default:
        backgroundColor = themeProvider.currentColors.accentPrimary;
    }

    return Container(
      width: width,
      height: height ?? 56,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
