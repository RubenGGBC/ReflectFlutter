// lib/presentation/widgets/key_metrics_grid.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/optimized_providers.dart'; // ✅ IMPORT ARREGLADO
import '../../presentation/screens/components/modern_design_system.dart';

class KeyMetricsGrid extends StatelessWidget {
  const KeyMetricsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<OptimizedAnalyticsProvider>(); // ✅ PROVIDER ARREGLADO
    final streakData = analytics.getStreakData();
    final moodInsights = analytics.getQuickStatsMoodInsights();
    final diversityInsights = analytics.getQuickStatsDiversityInsights();
    final stressAlerts = analytics.getStressAlerts();

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
              value: stressAlerts['level']?.toString().toUpperCase() ?? 'NORMAL',
              color: _getStressColor(stressAlerts['level']?.toString() ?? 'bajo'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(ModernSpacing.md),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: ModernSpacing.sm),
          Text(
            value,
            style: ModernTypography.heading3.copyWith(
              color: color,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ModernSpacing.xs),
          Text(
            label,
            style: ModernTypography.bodySmall.copyWith(
              color: ModernColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getStressColor(String level) {
    switch (level.toLowerCase()) {
      case 'alto':
        return Colors.red.shade400;
      case 'moderado':
        return Colors.orange.shade400;
      case 'bajo':
        return Colors.green.shade400;
      default:
        return Colors.blue.shade400;
    }
  }
}