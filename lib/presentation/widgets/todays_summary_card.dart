// lib/presentation/widgets/home/todays_summary_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';
import '../screens/components/modern_design_system.dart';

class TodaysSummaryCard extends StatelessWidget {
  const TodaysSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    final summary = analytics.getDashboardSummary();
    final score = (summary['wellbeing_score'] as num? ?? 0).toInt();
    final level = summary['level']?.toString() ?? 'Iniciando';

    final gradient = _getGradientForScore(score);

    return Container(
      padding: const EdgeInsets.all(ModernSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ModernSpacing.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu Bienestar Hoy',
            style: ModernTypography.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: ModernSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: ModernTypography.heading1.copyWith(fontSize: 64, color: Colors.white, height: 1.0),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: ModernSpacing.sm),
                child: Text('/100', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: ModernSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ModernSpacing.radiusRound),
            ),
            child: Text(
              level,
              style: ModernTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientForScore(int score) {
    if (score >= 80) return ModernColors.positiveGradient;
    if (score >= 60) return ModernColors.primaryGradient;
    if (score >= 40) return ModernColors.warningGradient;
    return ModernColors.errorGradient;
  }
}