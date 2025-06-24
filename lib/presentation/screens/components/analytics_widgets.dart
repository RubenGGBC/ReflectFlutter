// ============================================================================
// analytics_widgets.dart - WIDGETS PARA MOSTRAR ANÁLISIS Y REFUERZO POSITIVO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/optimized_providers.dart'; // ✅ IMPORT ARREGLADO
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
    return Consumer<OptimizedAnalyticsProvider>( // ✅ PROVIDER ARREGLADO
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
    return Consumer<OptimizedAnalyticsProvider>( // ✅ PROVIDER ARREGLADO
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ModernSpacing.sm,
                      vertical: ModernSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: ModernColors.accentBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
                    ),
                    child: Text(
                      '${wellbeingStatus['score']}/10',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.bold,
                        color: ModernColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),

              if (nextAchievement != null) ...[
                const SizedBox(height: ModernSpacing.md),
                Divider(color: ModernColors.glassPrimary),
                const SizedBox(height: ModernSpacing.md),

                // Próximo logro
                Row(
                  children: [
                    Text(
                      nextAchievement['emoji'] ?? '🏆',
                      style: TextStyle(fontSize: isTablet ? 24 : 20),
                    ),
                    const SizedBox(width: ModernSpacing.sm),
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

                const SizedBox(height: ModernSpacing.sm),

                // Progreso del logro
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progreso',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 10,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${nextAchievement['current']}/${nextAchievement['target']}',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 10,
                            fontWeight: FontWeight.bold,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ModernSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
                      child: LinearProgressIndicator(
                        value: (nextAchievement['progress'] as double?) ?? 0.0,
                        backgroundColor: ModernColors.glassPrimary,
                        valueColor: AlwaysStoppedAnimation<Color>(ModernColors.accentBlue),
                        minHeight: isTablet ? 8 : 6,
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
}

/// 📊 Widget de gráfico de mood
class MoodChartWidget extends StatelessWidget {
  final bool isTablet;

  const MoodChartWidget({
    super.key,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OptimizedAnalyticsProvider>( // ✅ PROVIDER ARREGLADO
      builder: (context, analytics, child) {
        final chartData = analytics.getMoodChartData();

        if (chartData.isEmpty) {
          return ModernCard(
            child: Column(
              children: [
                Icon(
                  Icons.insert_chart_outlined,
                  size: isTablet ? 64 : 48,
                  color: ModernColors.textSecondary,
                ),
                const SizedBox(height: ModernSpacing.md),
                Text(
                  'Gráfico de Mood',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(height: ModernSpacing.sm),
                Text(
                  'Registra algunos días para ver tu progreso',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: ModernColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Evolución del Mood',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: ModernColors.textPrimary,
                ),
              ),
              const SizedBox(height: ModernSpacing.md),

              // Aquí iría el gráfico real con fl_chart
              Container(
                height: isTablet ? 200 : 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ModernColors.surfaceDark.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
                ),
                child: Center(
                  child: Text(
                    'Gráfico de ${chartData.length} días',
                    style: TextStyle(
                      color: ModernColors.textSecondary,
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: ModernSpacing.md),

              // Leyenda simple
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem('😊', 'Mood', Colors.blue, isTablet),
                  _buildLegendItem('⚡', 'Energía', Colors.yellow, isTablet),
                  _buildLegendItem('😰', 'Estrés', Colors.red, isTablet),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String emoji, String label, Color color, bool isTablet) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
          '$emoji $label',
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
    return Consumer<OptimizedAnalyticsProvider>( // ✅ PROVIDER ARREGLADO
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
            ? ModernColors.success.withOpacity(0.2)
            : ModernColors.warning.withOpacity(0.2),
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
              color: (isPositive ? ModernColors.success : ModernColors.warning).withOpacity(0.3),
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
    return Consumer<OptimizedAnalyticsProvider>( // ✅ PROVIDER ARREGLADO
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
                        color: _getPriorityColor(rec['priority'] ?? 'low').withOpacity(0.2),
                        borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
                      ),
                      child: Center(
                        child: Text(
                          rec['emoji'] ?? '💡',
                          style: TextStyle(fontSize: isTablet ? 24 : 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: ModernSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec['title'] ?? '',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.bold,
                              color: ModernColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: ModernSpacing.xs),
                          Text(
                            rec['description'] ?? '',
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: ModernColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ModernSpacing.sm,
                        vertical: ModernSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(rec['priority'] ?? 'low'),
                        borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
                      ),
                      child: Text(
                        _getPriorityLabel(rec['priority'] ?? 'low'),
                        style: TextStyle(
                          fontSize: isTablet ? 10 : 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red.shade400;
      case 'medium':
        return Colors.orange.shade400;
      case 'low':
        return Colors.blue.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return 'ALTA';
      case 'medium':
        return 'MEDIA';
      case 'low':
        return 'BAJA';
      default:
        return 'INFO';
    }
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
    return Consumer<OptimizedAnalyticsProvider>( // ✅ PROVIDER ARREGLADO
      builder: (context, analytics, child) {
        final dayAnalysis = analytics.getCurrentDayAnalysis();

        return ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.today_outlined,
                    color: ModernColors.accentBlue,
                    size: isTablet ? 28 : 24,
                  ),
                  const SizedBox(width: ModernSpacing.sm),
                  Text(
                    'Análisis de Hoy',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ModernSpacing.md),

              Text(
                dayAnalysis['message'] ?? 'No hay datos para hoy',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: ModernColors.textSecondary,
                ),
              ),

              if (dayAnalysis['recommendation'] != null) ...[
                const SizedBox(height: ModernSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(ModernSpacing.sm),
                  decoration: BoxDecoration(
                    color: ModernColors.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: ModernColors.accentBlue,
                        size: 16,
                      ),
                      const SizedBox(width: ModernSpacing.sm),
                      Expanded(
                        child: Text(
                          dayAnalysis['recommendation'],
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 10,
                            color: ModernColors.accentBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}