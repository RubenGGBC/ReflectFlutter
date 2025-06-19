// ============================================================================
// analytics_widgets.dart - WIDGETS PARA MOSTRAR ANÁLISIS Y REFUERZO POSITIVO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/analytics_provider.dart';
import 'modern_design_system.dart';

/// 🎯 Widget principal de insights destacados
class HighlightedInsightsWidget extends StatelessWidget {
  final bool isTablet;

  const HighlightedInsightsWidget({
    super.key,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analytics, child) {
        if (analytics.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final highlights = analytics.getHighlightedInsights();
        if (highlights.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights Destacados',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: ModernColors.textPrimary,
              ),
            ),
            SizedBox(height: isTablet ? ModernSpacing.lg : ModernSpacing.md),
            SizedBox(
              height: isTablet ? 140 : 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: highlights.length,
                itemBuilder: (context, index) {
                  final insight = highlights[index];
                  return Container(
                    width: isTablet ? 280 : 250,
                    margin: EdgeInsets.only(
                      right: isTablet ? ModernSpacing.lg : ModernSpacing.md,
                    ),
                    child: _buildInsightCard(insight, isTablet),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInsightCard(Map<String, String> insight, bool isTablet) {
    final gradient = _getGradientForType(insight['type'] ?? 'general');

    return ModernCard(
      gradient: gradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                insight['emoji'] ?? '💡',
                style: TextStyle(fontSize: isTablet ? 28 : 24),
              ),
              const SizedBox(width: ModernSpacing.sm),
              Expanded(
                child: Text(
                  insight['title'] ?? 'Insight',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernSpacing.sm),
          Text(
            insight['description'] ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isTablet ? 14 : 12,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientForType(String type) {
    switch (type) {
      case 'achievement':
        return [const Color(0xFFffd89b), const Color(0xFF19547b)];
      case 'mood':
        return ModernColors.positiveGradient;
      case 'pattern':
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
      default:
        return ModernColors.neutralGradient;
    }
  }
}

/// 🏆 Widget de progreso de logros
class AchievementProgressWidget extends StatelessWidget {
  final bool isTablet;

  const AchievementProgressWidget({
    super.key,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analytics, child) {
        final nextAchievement = analytics.getNextAchievementToUnlock();
        final wellbeingStatus = analytics.getWellbeingStatus();

        return ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con score de bienestar
              Row(
                children: [
                  Text(
                    wellbeingStatus['emoji'] ?? '💎',
                    style: TextStyle(fontSize: isTablet ? 28 : 24),
                  ),
                  const SizedBox(width: ModernSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nivel: ${wellbeingStatus['level']}',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.bold,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                        Text(
                          wellbeingStatus['message'] ?? '',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 10,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? ModernSpacing.md : ModernSpacing.sm,
                      vertical: isTablet ? ModernSpacing.sm : ModernSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getScoreColor(analytics.wellbeingScore).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                    ),
                    child: Text(
                      '${analytics.wellbeingScore}/100',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(analytics.wellbeingScore),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isTablet ? ModernSpacing.lg : ModernSpacing.md),

              // Barra de progreso
              LinearProgressIndicator(
                value: analytics.wellbeingScore / 100,
                backgroundColor: ModernColors.glassSecondary,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getScoreColor(analytics.wellbeingScore),
                ),
                minHeight: isTablet ? 8 : 6,
              ),

              if (nextAchievement != null) ...[
                SizedBox(height: isTablet ? ModernSpacing.lg : ModernSpacing.md),
                Divider(color: ModernColors.glassSecondary),
                SizedBox(height: isTablet ? ModernSpacing.md : ModernSpacing.sm),

                // Próximo logro
                Row(
                  children: [
                    Container(
                      width: isTablet ? 40 : 35,
                      height: isTablet ? 40 : 35,
                      decoration: BoxDecoration(
                        color: ModernColors.glassSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getTierColor(nextAchievement['tier'] ?? 'bronze'),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          nextAchievement['emoji'] ?? '🎯',
                          style: TextStyle(fontSize: isTablet ? 20 : 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: ModernSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Próximo: ${nextAchievement['title']}',
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.bold,
                              color: ModernColors.textPrimary,
                            ),
                          ),
                          Text(
                            nextAchievement['description'] ?? '',
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 10,
                              color: ModernColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return ModernColors.success;
    if (score >= 60) return ModernColors.categories['emocional']!;
    if (score >= 40) return ModernColors.warning;
    return ModernColors.error;
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      default:
        return const Color(0xFFCD7F32);
    }
  }
}

/// 📈 Widget de gráfico de evolución del mood
class MoodEvolutionWidget extends StatelessWidget {
  final bool isTablet;

  const MoodEvolutionWidget({
    super.key,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analytics, child) {
        final chartData = analytics.getMoodChartData();
        if (chartData.isEmpty) {
          return const SizedBox.shrink();
        }

        return ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Evolución del Mood (7 días)',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: ModernColors.textPrimary,
                ),
              ),
              SizedBox(height: isTablet ? ModernSpacing.lg : ModernSpacing.md),

              SizedBox(
                height: isTablet ? 120 : 100,
                child: _buildMoodChart(chartData, isTablet),
              ),

              SizedBox(height: isTablet ? ModernSpacing.md : ModernSpacing.sm),
              _buildChartLegend(isTablet),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoodChart(List<Map<String, dynamic>> data, bool isTablet) {
    // Crear un gráfico simple usando Container y Animation
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final barWidth = (width - (data.length - 1) * 8) / data.length;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.asMap().entries.map((entry) {
            final index = entry.key;
            final dayData = entry.value;
            final mood = (dayData['mood'] as num).toDouble();
            final barHeight = (mood / 10 * height).clamp(10.0, height);

            return Container(
              width: barWidth,
              height: barHeight,
              margin: EdgeInsets.only(right: index < data.length - 1 ? 8 : 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: mood >= 6
                      ? ModernColors.positiveGradient
                      : mood >= 4
                      ? [ModernColors.warning, ModernColors.warning.withValues(alpha: 0.7)]
                      : [ModernColors.error, ModernColors.error.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildChartLegend(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Excelente', ModernColors.success, isTablet),
        _buildLegendItem('Bueno', ModernColors.categories['emocional']!, isTablet),
        _buildLegendItem('Regular', ModernColors.warning, isTablet),
        _buildLegendItem('Bajo', ModernColors.error, isTablet),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isTablet) {
    return Row(
      children: [
        Container(
          width: isTablet ? 12 : 10,
          height: isTablet ? 12 : 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 12 : 10,
            color: ModernColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 🎨 Widget de temas dominantes
class DominantThemesWidget extends StatelessWidget {
  final bool isTablet;

  const DominantThemesWidget({
    super.key,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analytics, child) {
        final themes = analytics.getDominantThemes();
        if (themes.isEmpty) {
          return const SizedBox.shrink();
        }

        return ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Temas Dominantes',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: ModernColors.textPrimary,
                ),
              ),
              SizedBox(height: isTablet ? ModernSpacing.lg : ModernSpacing.md),

              Wrap(
                spacing: ModernSpacing.sm,
                runSpacing: ModernSpacing.sm,
                children: themes.map((theme) => _buildThemeChip(theme, isTablet)).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeChip(Map<String, dynamic> theme, bool isTablet) {
    final isPositive = theme['type'] == 'positive';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? ModernSpacing.md : ModernSpacing.sm,
        vertical: isTablet ? ModernSpacing.sm : ModernSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isPositive
            ? ModernColors.success.withValues(alpha: 0.2)
            : ModernColors.warning.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        border: Border.all(
          color: isPositive ? ModernColors.success : ModernColors.warning,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            theme['emoji']?.toString() ?? (isPositive ? '✨' : '🤔'),
            style: TextStyle(fontSize: isTablet ? 16 : 14),
          ),
          const SizedBox(width: ModernSpacing.xs),
          Text(
            theme['word']?.toString() ?? '',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: isPositive ? ModernColors.success : ModernColors.warning,
            ),
          ),
          const SizedBox(width: ModernSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (isPositive ? ModernColors.success : ModernColors.warning).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${theme['count']}',
              style: TextStyle(
                fontSize: isTablet ? 10 : 8,
                fontWeight: FontWeight.bold,
                color: isPositive ? ModernColors.success : ModernColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 💡 Widget de recomendaciones prioritarias
class PriorityRecommendationsWidget extends StatelessWidget {
  final bool isTablet;

  const PriorityRecommendationsWidget({
    super.key,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analytics, child) {
        final recommendations = analytics.getPriorityRecommendations();
        if (recommendations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recomendaciones para Ti',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: ModernColors.textPrimary,
              ),
            ),
            SizedBox(height: isTablet ? ModernSpacing.lg : ModernSpacing.md),

            ...recommendations.map((rec) => Container(
              margin: const EdgeInsets.only(bottom: ModernSpacing.md),
              child: ModernCard(
                gradient: ModernColors.neutralGradient,
                child: Row(
                  children: [
                    Container(
                      width: isTablet ? 50 : 40,
                      height: isTablet ? 50 : 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          rec['emoji'] ?? '💡',
                          style: TextStyle(fontSize: isTablet ? 20 : 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: ModernSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec['title'] ?? 'Recomendación',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rec['description'] ?? '',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: isTablet ? 14 : 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ],
        );
      },
    );
  }
}

/// 📅 Widget de análisis del día actual
class CurrentDayAnalysisWidget extends StatelessWidget {
  final bool isTablet;

  const CurrentDayAnalysisWidget({
    super.key,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analytics, child) {
        final dayAnalysis = analytics.getCurrentDayAnalysis();

        return ModernCard(
          gradient: dayAnalysis['is_best_day'] == true
              ? ModernColors.positiveGradient
              : ModernColors.neutralGradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    dayAnalysis['is_best_day'] == true ? '🌟' : '📅',
                    style: TextStyle(fontSize: isTablet ? 28 : 24),
                  ),
                  const SizedBox(width: ModernSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayAnalysis['day_name'] ?? 'Hoy',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Mood promedio: ${(dayAnalysis['avg_mood'] as num).toDouble().toStringAsFixed(1)}/10',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: isTablet ? 14 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? ModernSpacing.md : ModernSpacing.sm),
              Text(
                dayAnalysis['motivation'] ?? 'Cada día es una oportunidad',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: isTablet ? 14 : 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}