// lib/presentation/widgets/home/alerts_section.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';
import '../../presentation/screens/components/modern_design_system.dart';

class AlertsSection extends StatelessWidget {
  const AlertsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    final stressAlerts = analytics.getStressAlerts();

    if (stressAlerts['requires_attention'] != true) {
      return const SizedBox.shrink();
    }

    final alertColor = stressAlerts['alert_color'] as Color? ?? Colors.orange;
    final alertIcon = stressAlerts['alert_icon']?.toString() ?? '⚠️';
    final alertTitle = stressAlerts['alert_title']?.toString() ?? 'Atención';
    final recommendations = stressAlerts['recommendations'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: ModernSpacing.lg),
      padding: const EdgeInsets.all(ModernSpacing.md),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        border: Border.all(color: alertColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(alertIcon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: ModernSpacing.md),
              Expanded(
                child: Text(
                  alertTitle,
                  style: ModernTypography.heading3.copyWith(color: alertColor, fontSize: 18),
                ),
              ),
            ],
          ),
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: ModernSpacing.md),
            Text(
              "Recomendación: ${recommendations.first}",
              style: ModernTypography.bodyMedium.copyWith(color: alertColor.withOpacity(0.8)),
            ),
          ],
        ],
      ),
    );
  }
}