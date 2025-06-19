// lib/presentation/widgets/home/key_metrics_grid.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';
import '../../presentation/screens/components/modern_design_system.dart';

class KeyMetricsGrid extends StatelessWidget {
  const KeyMetricsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    final streakData = analytics.getStreakData();
    final moodInsights = analytics.getQuickStatsMoodInsights();
    final diversityInsights = analytics.getQuickStatsDiversityInsights();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Métricas Clave', style: ModernTypography.heading3),
        const SizedBox(height: ModernSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: ModernSpacing.md,
          mainAxisSpacing: ModernSpacing.md,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              icon: Icons.local_fire_department_outlined,
              label: 'Racha Actual',
              value: '${(streakData['current'] as num? ?? 0).toInt()} días',
              color: ModernColors.warning,
            ),
            _buildMetricCard(
              icon: Icons.sentiment_satisfied_alt_outlined,
              label: 'Mood Promedio',
              value: '${(moodInsights['avg_mood'] as num? ?? 0.0).toStringAsFixed(1)}/10',
              color: ModernColors.info,
            ),
            _buildMetricCard(
              icon: Icons.apps_outlined,
              label: 'Diversidad',
              value: '${(diversityInsights['categories_used'] as num? ?? 0).toInt()}/${(diversityInsights['max_categories'] as num? ?? 5).toInt()}',
              color: Colors.purple.shade400,
            ),
            _buildMetricCard(
              icon: Icons.shield_outlined,
              label: 'Estrés',
              value: analytics.getStressAlerts()['level']?.toString().toUpperCase() ?? 'BAJO',
              color: ModernColors.success,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({required IconData icon, required String label, required String value, required Color color}) {
    return ModernCard(
      padding: const EdgeInsets.all(ModernSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: ModernTypography.heading3.copyWith(color: color, fontSize: 20)),
              Text(label, style: ModernTypography.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}