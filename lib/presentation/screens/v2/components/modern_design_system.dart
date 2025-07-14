// lib/presentation/screens/v2/components/modern_design_system.dart
// ============================================================================
// MODERN DESIGN SYSTEM COMPONENTS FOR ANALYTICS
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

/// Modern spacing constants
class ModernSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Modern typography system
class ModernTypography {
  static TextStyle title1(BuildContext context) => 
      Theme.of(context).textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ) ?? const TextStyle(fontSize: 28, fontWeight: FontWeight.bold);

  static TextStyle title2(BuildContext context) => 
      Theme.of(context).textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);

  static TextStyle title3(BuildContext context) => 
      Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ) ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

  static TextStyle body1(BuildContext context) => 
      Theme.of(context).textTheme.bodyLarge ?? 
      const TextStyle(fontSize: 16);

  static TextStyle body2(BuildContext context) => 
      Theme.of(context).textTheme.bodyMedium ?? 
      const TextStyle(fontSize: 14);

  static TextStyle caption(BuildContext context) => 
      Theme.of(context).textTheme.bodySmall ?? 
      const TextStyle(fontSize: 12);
}

/// Modern card component
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: elevation ?? 2,
      color: backgroundColor ?? theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(ModernSpacing.md),
          child: child,
        ),
      ),
    );
  }
}

/// Modern stat card for quick metrics
class ModernStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? accentColor;
  final VoidCallback? onTap;

  const ModernStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor ?? theme.primaryColor;

    return ModernCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: accent, size: 24),
            const SizedBox(height: ModernSpacing.sm),
          ],
          Text(
            title,
            style: ModernTypography.caption(context).copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: ModernSpacing.xs),
          Text(
            value,
            style: ModernTypography.title2(context).copyWith(
              color: accent,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: ModernSpacing.xs),
            Text(
              subtitle!,
              style: ModernTypography.caption(context).copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Modern section header
class ModernSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const ModernSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: ModernSpacing.md,
        vertical: ModernSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ModernTypography.title3(context),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: ModernSpacing.xs),
                  Text(
                    subtitle!,
                    style: ModernTypography.body2(context).copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Modern loading indicator
class ModernLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const ModernLoadingIndicator({
    super.key,
    this.message,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: ModernSpacing.md),
            Text(
              message!,
              style: ModernTypography.body2(context),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Modern error state
class ModernErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ModernErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: ModernSpacing.md),
            Text(
              message,
              style: ModernTypography.body1(context),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: ModernSpacing.lg),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Modern tab bar with custom styling
class ModernTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<String> tabs;

  const ModernTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        indicatorColor: theme.primaryColor,
        labelColor: theme.primaryColor,
        unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
        labelStyle: ModernTypography.body1(context).copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: ModernTypography.body1(context),
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}