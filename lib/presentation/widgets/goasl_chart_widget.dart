// lib/presentation/widgets/goals_chart_widget.dart
// ============================================================================
// WIDGET ESPECIALIZADO PARA VISUALIZACIÓN DE CHARTS DE GOALS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// Providers
import '../providers/optimized_providers.dart';

// Modelos
import '../../data/models/goal_model.dart';

// Componentes
import '../screens/components/modern_design_system.dart';

// ============================================================================
// WIDGET PRINCIPAL DE CHART DE GOALS
// ============================================================================

class GoalsChartWidget extends StatefulWidget {
  final GoalsChartType chartType;
  final bool showTitle;
  final double? height;
  final EdgeInsets? padding;
  final bool animated;

  const GoalsChartWidget({
    super.key,
    this.chartType = GoalsChartType.overview,
    this.showTitle = true,
    this.height,
    this.padding,
    this.animated = true,
  });

  @override
  State<GoalsChartWidget> createState() => _GoalsChartWidgetState();
}

class _GoalsChartWidgetState extends State<GoalsChartWidget>
    with TickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _setupAnimations();
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _animationController.dispose();
    }
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalsProvider>(
      builder: (context, goalsProvider, child) {
        if (goalsProvider.isLoading) {
          return _buildLoadingState();
        }

        if (goalsProvider.goals.isEmpty) {
          return _buildEmptyState();
        }

        Widget chart = _buildChart(goalsProvider);

        if (!widget.animated) {
          return chart;
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: chart,
          ),
        );
      },
    );
  }

  Widget _buildChart(GoalsProvider goalsProvider) {
    switch (widget.chartType) {
      case GoalsChartType.overview:
        return _buildOverviewChart(goalsProvider);
      case GoalsChartType.progress:
        return _buildProgressChart(goalsProvider);
      case GoalsChartType.typeDistribution:
        return _buildTypeDistributionChart(goalsProvider);
      case GoalsChartType.timeline:
        return _buildTimelineChart(goalsProvider);
    }
  }

  // ============================================================================
  // CHART DE OVERVIEW GENERAL
  // ============================================================================

  Widget _buildOverviewChart(GoalsProvider goalsProvider) {
    final activeGoals = goalsProvider.activeGoals;
    final completedGoals = goalsProvider.completedGoals;
    final averageProgress = goalsProvider.averageProgress;

    return Container(
      height: widget.height ?? 200,
      padding: widget.padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.glassPrimary,
        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        border: Border.all(color: ModernColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle) ...[
            const Text(
              '🎯 Goals Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: Row(
              children: [
                // Círculo de progreso principal
                Expanded(
                  flex: 2,
                  child: _buildMainProgressCircle(averageProgress),
                ),
                const SizedBox(width: 20),
                // Métricas laterales
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildMetricRow(
                        'Active Goals',
                        activeGoals.length.toString(),
                        Icons.trending_up,
                        const Color(0xFF4ECDC4),
                      ),
                      const SizedBox(height: 12),
                      _buildMetricRow(
                        'Completed',
                        completedGoals.length.toString(),
                        Icons.check_circle,
                        const Color(0xFFFFD700),
                      ),
                      const SizedBox(height: 12),
                      _buildMetricRow(
                        'Progress',
                        '${(averageProgress * 100).round()}%',
                        Icons.track_changes,
                        const Color(0xFF45B7D1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainProgressCircle(double progress) {
    return Center(
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          children: [
            // Círculo de fondo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            // Círculo de progreso
            if (widget.animated)
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return CircularProgressIndicator(
                    value: progress * _progressAnimation.value,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
                  );
                },
              )
            else
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
              ),
            // Texto central
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Average',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // CHART DE PROGRESO DETALLADO
  // ============================================================================

  Widget _buildProgressChart(GoalsProvider goalsProvider) {
    final activeGoals = goalsProvider.activeGoals;

    return Container(
      height: widget.height ?? 250,
      padding: widget.padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.glassPrimary,
        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        border: Border.all(color: ModernColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle) ...[
            const Text(
              '📈 Progress Breakdown',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: ListView.builder(
              itemCount: activeGoals.length,
              itemBuilder: (context, index) {
                final goal = activeGoals[index];
                return _buildProgressBar(goal, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(GoalModel goal, int index) {
    final color = _getGoalTypeColor(goal.type);
    final progress = goal.progress;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.animated)
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress * _progressAnimation.value,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                );
              },
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================================
  // CHART DE DISTRIBUCIÓN POR TIPO
  // ============================================================================

  Widget _buildTypeDistributionChart(GoalsProvider goalsProvider) {
    final goalsByType = goalsProvider.goalsByType;

    return Container(
      height: widget.height ?? 200,
      padding: widget.padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.glassPrimary,
        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        border: Border.all(color: ModernColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle) ...[
            const Text(
              '📊 Goals by Type',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: Row(
              children: [
                // Gráfico circular simple
                Expanded(
                  flex: 2,
                  child: _buildSimplePieChart(goalsByType),
                ),
                const SizedBox(width: 20),
                // Leyenda
                Expanded(
                  flex: 3,
                  child: _buildTypeLegend(goalsByType),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplePieChart(Map<GoalType, int> goalsByType) {
    if (goalsByType.isEmpty) {
      return const Center(
        child: Text(
          'No data',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white12,
        ),
        child: const Center(
          child: Icon(
            Icons.pie_chart,
            color: Colors.white54,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeLegend(Map<GoalType, int> goalsByType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: goalsByType.entries.map((entry) {
        final type = entry.key;
        final count = entry.value;
        final color = _getGoalTypeColor(type);
        final icon = _getGoalTypeIcon(type);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getGoalTypeDisplayName(type),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ============================================================================
  // CHART DE TIMELINE
  // ============================================================================

  Widget _buildTimelineChart(GoalsProvider goalsProvider) {
    final goals = goalsProvider.goals;
    final recentGoals = goals.take(5).toList();

    return Container(
      height: widget.height ?? 300,
      padding: widget.padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.glassPrimary,
        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        border: Border.all(color: ModernColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle) ...[
            const Text(
              '⏱️ Recent Goals Timeline',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: ListView.builder(
              itemCount: recentGoals.length,
              itemBuilder: (context, index) {
                final goal = recentGoals[index];
                return _buildTimelineItem(goal, index == recentGoals.length - 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(GoalModel goal, bool isLast) {
    final color = _getGoalTypeColor(goal.type);
    final icon = _getGoalTypeIcon(goal.type);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        goal.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(goal.createdAt),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                if (goal.isCompleted && goal.completedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Completed ${_formatDate(goal.completedAt!)}',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // ESTADOS ESPECIALES
  // ============================================================================

  Widget _buildLoadingState() {
    return Container(
      height: widget.height ?? 200,
      padding: widget.padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.glassPrimary,
        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        border: Border.all(color: ModernColors.borderPrimary),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: widget.height ?? 200,
      padding: widget.padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.glassPrimary,
        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        border: Border.all(color: ModernColors.borderPrimary),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              color: Colors.white54,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'No goals yet',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // MÉTODOS DE UTILIDAD
  // ============================================================================

  Color _getGoalTypeColor(GoalType type) {
    switch (type) {
      case GoalType.consistency:
        return const Color(0xFF4ECDC4);
      case GoalType.mood:
        return const Color(0xFFFFD700);
      case GoalType.positiveMoments:
        return const Color(0xFF45B7D1);
      case GoalType.stressReduction:
        return const Color(0xFF96CEB4);
    }
  }

  IconData _getGoalTypeIcon(GoalType type) {
    switch (type) {
      case GoalType.consistency:
        return Icons.timeline;
      case GoalType.mood:
        return Icons.sentiment_satisfied;
      case GoalType.positiveMoments:
        return Icons.star;
      case GoalType.stressReduction:
        return Icons.spa;
    }
  }

  String _getGoalTypeDisplayName(GoalType type) {
    switch (type) {
      case GoalType.consistency:
        return 'Consistency';
      case GoalType.mood:
        return 'Mood';
      case GoalType.positiveMoments:
        return 'Positive Moments';
      case GoalType.stressReduction:
        return 'Stress Reduction';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).round()} weeks ago';
    return '${(difference / 30).round()} months ago';
  }
}

// ============================================================================
// ENUMS Y CONFIGURACIONES
// ============================================================================

enum GoalsChartType {
  overview,
  progress,
  typeDistribution,
  timeline,
}

// ============================================================================
// WIDGET COMPACTO PARA HOME SCREEN
// ============================================================================

class CompactGoalsWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const CompactGoalsWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const GoalsChartWidget(
        chartType: GoalsChartType.overview,
        height: 160,
        padding: EdgeInsets.all(16),
        showTitle: false,
      ),
    );
  }
}

// ============================================================================
// WIDGET DE MÉTRICAS RÁPIDAS
// ============================================================================

class QuickGoalsMetrics extends StatelessWidget {
  const QuickGoalsMetrics({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalsProvider>(
      builder: (context, goalsProvider, child) {
        if (goalsProvider.isLoading) {
          return const SizedBox(
            height: 60,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildQuickMetric(
                'Active',
                goalsProvider.activeGoals.length.toString(),
                Icons.trending_up,
                const Color(0xFF4ECDC4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickMetric(
                'Progress',
                '${(goalsProvider.averageProgress * 100).round()}%',
                Icons.track_changes,
                const Color(0xFFFFD700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickMetric(
                'Done',
                goalsProvider.completedGoals.length.toString(),
                Icons.check_circle,
                const Color(0xFF45B7D1),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}