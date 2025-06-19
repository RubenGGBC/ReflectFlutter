// lib/presentation/widgets/enhanced_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/enhanced_analytics_provider.dart';
import '../screens/components/modern_design_system.dart';

class EnhancedDashboard extends StatefulWidget {
  final int userId;

  const EnhancedDashboard({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<EnhancedDashboard> createState() => _EnhancedDashboardState();
}

class _EnhancedDashboardState extends State<EnhancedDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Cargar datos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnhancedAnalyticsProvider>().loadCompleteAdvancedAnalytics(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<EnhancedAnalyticsProvider>();

    if (analytics.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (analytics.errorMessage != null) {
      return _buildErrorState(analytics);
    }

    return Column(
      children: [
        // Score Principal Mejorado
        _buildAdvancedWellbeingScore(analytics),

        const SizedBox(height: 24),

        // Tabs para diferentes análisis
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141B2D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.blue.shade400,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: '📊 General'),
              Tab(text: '😰 Estrés'),
              Tab(text: '📈 Progreso'),
              Tab(text: '🎯 Metas'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Contenido de las tabs
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGeneralTab(analytics),
              _buildStressTab(analytics),
              _buildProgressTab(analytics),
              _buildGoalsTab(analytics),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(EnhancedAnalyticsProvider analytics) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error al cargar los datos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              analytics.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => analytics.loadCompleteAdvancedAnalytics(widget.userId),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade400,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // SCORE DE BIENESTAR AVANZADO
  // ============================================================================

  Widget _buildAdvancedWellbeingScore(EnhancedAnalyticsProvider analytics) {
    final wellbeing = analytics.wellbeingData;
    final score = (wellbeing['overall_score'] ?? 0).toInt();
    final level = wellbeing['level'] ?? 'Iniciando';
    final components = wellbeing['components'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade900,
            Colors.blue.shade800,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score de Bienestar',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$score',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        '/100',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    level,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _getLevelColor(level),
                    ),
                  ),
                ],
              ),
              _buildScoreVisualization(score),
            ],
          ),

          const SizedBox(height: 24),

          // Componentes del score
          _buildScoreComponents(components),
        ],
      ),
    );
  }

  Widget _buildScoreVisualization(int score) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 12,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
          ),
          Text(
            _getScoreEmoji(score),
            style: const TextStyle(fontSize: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreComponents(Map<String, dynamic> components) {
    return Column(
      children: components.entries.map((entry) {
        final name = _getComponentName(entry.key);
        final value = (entry.value as num).toDouble();
        final maxValue = _getComponentMaxValue(entry.key);
        final percentage = (value / maxValue).clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${value.toStringAsFixed(1)}/${maxValue}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getComponentColor(entry.key),
                ),
                minHeight: 6,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ============================================================================
  // TAB GENERAL
  // ============================================================================

  Widget _buildGeneralTab(EnhancedAnalyticsProvider analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTemporalComparisons(analytics),
          const SizedBox(height: 16),
          _buildKeyInsights(analytics),
          const SizedBox(height: 16),
          _buildMoodPatternChart(analytics),
        ],
      ),
    );
  }

  Widget _buildTemporalComparisons(EnhancedAnalyticsProvider analytics) {
    final comparisons = analytics.temporalComparisons;
    final weekData = comparisons['week_comparison'] ?? {};
    final monthData = comparisons['month_comparison'] ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Comparaciones Temporales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildComparisonCard(
                  'Esta Semana',
                  weekData['current_mood']?.toStringAsFixed(1) ?? '0',
                  weekData['mood_change'] ?? 0,
                  Colors.blue.shade400,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildComparisonCard(
                  'Este Mes',
                  monthData['current_mood']?.toStringAsFixed(1) ?? '0',
                  monthData['mood_change'] ?? 0,
                  Colors.purple.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(String period, String value, num change, Color color) {
    final isPositive = change >= 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: isPositive ? Colors.green : Colors.red,
              ),
              Text(
                '${change.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB ESTRÉS
  // ============================================================================

  Widget _buildStressTab(EnhancedAnalyticsProvider analytics) {
    final stress = analytics.stressAnalysis;
    final stressLevel = stress['stress_level'] ?? 0;
    final anxietyLevel = stress['anxiety_level'] ?? 0;
    final triggers = stress['high_stress_triggers'] as List? ?? [];
    final patterns = stress['stress_patterns'] as Map? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStressOverview(stressLevel, anxietyLevel),
          const SizedBox(height: 16),
          _buildStressTriggers(triggers),
          const SizedBox(height: 16),
          _buildStressPatterns(patterns),
          const SizedBox(height: 16),
          _buildStressRecommendations(stress),
        ],
      ),
    );
  }

  Widget _buildStressOverview(num stressLevel, num anxietyLevel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '😰 Niveles de Estrés y Ansiedad',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildStressIndicator('Nivel de Estrés', stressLevel.toDouble(), Colors.orange),
          const SizedBox(height: 12),
          _buildStressIndicator('Nivel de Ansiedad', anxietyLevel.toDouble(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildStressIndicator(String label, double value, Color color) {
    final percentage = (value / 10).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getStressLevelDescription(value),
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // TAB PROGRESO
  // ============================================================================

  Widget _buildProgressTab(EnhancedAnalyticsProvider analytics) {
    final timeline = analytics.progressTimeline['timeline'] as List? ?? [];
    final milestones = analytics.progressTimeline['milestones'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProgressChart(timeline),
          const SizedBox(height: 16),
          _buildMilestones(milestones),
          const SizedBox(height: 16),
          _buildImprovementAreas(analytics),
        ],
      ),
    );
  }

  Widget _buildProgressChart(List timeline) {
    if (timeline.isEmpty) {
      return _buildEmptyState('No hay suficientes datos para mostrar el progreso');
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 Línea de Progreso',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getProgressSpots(timeline),
                    isCurved: true,
                    color: Colors.blue.shade400,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.blue.shade400,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.shade400.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB METAS
  // ============================================================================

  Widget _buildGoalsTab(EnhancedAnalyticsProvider analytics) {
    final goals = analytics.personalizedGoals;
    final recommendedGoals = goals['recommended_goals'] as List? ?? [];
    final progressGoals = goals['progress_goals'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRecommendedGoals(recommendedGoals),
          const SizedBox(height: 16),
          _buildActiveGoals(progressGoals),
          const SizedBox(height: 16),
          _buildNextSteps(analytics),
        ],
      ),
    );
  }

  Widget _buildRecommendedGoals(List goals) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 Metas Recomendadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...goals.take(3).map((goal) => _buildGoalCard(goal)),
        ],
      ),
    );
  }

  Widget _buildGoalCard(dynamic goal) {
    final title = goal['title'] ?? 'Meta';
    final description = goal['description'] ?? '';
    final priority = goal['priority'] ?? 'medium';
    final category = goal['category'] ?? 'general';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getPriorityColor(priority).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getPriorityColor(priority).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _getCategoryEmoji(category),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'maestro zen':
        return Colors.purple.shade400;
      case 'avanzado':
        return Colors.blue.shade400;
      case 'intermedio':
        return Colors.green.shade400;
      case 'principiante':
        return Colors.orange.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green.shade400;
    if (score >= 60) return Colors.blue.shade400;
    if (score >= 40) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  String _getScoreEmoji(int score) {
    if (score >= 80) return '🌟';
    if (score >= 60) return '💪';
    if (score >= 40) return '🌱';
    return '🔥';
  }

  String _getComponentName(String key) {
    final names = {
      'consistency': '📅 Consistencia',
      'emotional_balance': '⚖️ Balance Emocional',
      'progress_trend': '📈 Tendencia',
      'diversity': '🌈 Diversidad',
      'stress_management': '🧘 Gestión del Estrés',
      'reflection_quality': '✍️ Calidad de Reflexión',
      'achievements': '🏆 Logros',
      'temporal_stability': '⏰ Estabilidad',
    };
    return names[key] ?? key;
  }

  double _getComponentMaxValue(String key) {
    final maxValues = {
      'consistency': 25.0,
      'emotional_balance': 20.0,
      'progress_trend': 15.0,
      'diversity': 10.0,
      'stress_management': 10.0,
      'reflection_quality': 10.0,
      'achievements': 5.0,
      'temporal_stability': 5.0,
    };
    return maxValues[key] ?? 10.0;
  }

  Color _getComponentColor(String key) {
    final colors = {
      'consistency': Colors.blue.shade400,
      'emotional_balance': Colors.purple.shade400,
      'progress_trend': Colors.green.shade400,
      'diversity': Colors.orange.shade400,
      'stress_management': Colors.red.shade400,
      'reflection_quality': Colors.teal.shade400,
      'achievements': Colors.amber.shade400,
      'temporal_stability': Colors.indigo.shade400,
    };
    return colors[key] ?? Colors.grey.shade400;
  }

  String _getStressLevelDescription(double level) {
    if (level <= 3) return 'Bajo - Excelente manejo del estrés';
    if (level <= 5) return 'Moderado - Mantén las estrategias actuales';
    if (level <= 7) return 'Alto - Considera técnicas adicionales';
    return 'Muy Alto - Se recomienda atención especial';
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red.shade400;
      case 'medium':
        return Colors.orange.shade400;
      case 'low':
        return Colors.green.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  String _getCategoryEmoji(String category) {
    final emojis = {
      'consistency': '📅',
      'emotional': '💖',
      'stress': '🧘',
      'habits': '🔄',
      'wellness': '🌱',
      'growth': '📈',
      'mindfulness': '🧠',
      'general': '🎯',
    };
    return emojis[category.toLowerCase()] ?? '🎯';
  }

  List<FlSpot> _getProgressSpots(List timeline) {
    return timeline.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final data = entry.value as Map<String, dynamic>;
      final score = (data['overall_score'] ?? 0).toDouble();
      return FlSpot(index, score);
    }).toList();
  }

  Widget _buildKeyInsights(EnhancedAnalyticsProvider analytics) {
    final insights = analytics.wellbeingData['insights'] as List? ?? [];

    if (insights.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Insights Clave',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...insights.take(3).map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight.toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMoodPatternChart(EnhancedAnalyticsProvider analytics) {
    // Implementar gráfico de patrones de mood por hora
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'Gráfico de Patrones de Humor',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildStressTriggers(List triggers) {
    if (triggers.isEmpty) {
      return _buildEmptyState('No se detectaron triggers de estrés');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚠️ Triggers de Estrés',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...triggers.take(5).map((trigger) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: Colors.orange.shade400,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trigger.toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStressPatterns(Map patterns) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Patrones de Estrés',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Análisis de patrones temporales y situacionales',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStressRecommendations(Map stress) {
    final recommendations = stress['recommendations'] as List? ?? [];

    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade900,
            Colors.green.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💚 Recomendaciones para el Estrés',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...recommendations.take(3).map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rec.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMilestones(List milestones) {
    if (milestones.isEmpty) {
      return _buildEmptyState('Aún no has alcanzado milestones');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 Milestones Alcanzados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...milestones.take(5).map((milestone) => _buildMilestoneItem(milestone)),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(dynamic milestone) {
    final type = milestone['type'] ?? '';
    final description = milestone['description'] ?? '';
    final week = milestone['week'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.amber.shade400,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Semana: $week',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementAreas(EnhancedAnalyticsProvider analytics) {
    final areas = analytics.wellbeingData['improvement_areas'] as List? ?? [];

    if (areas.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 Áreas de Mejora',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...areas.map((area) => _buildImprovementAreaItem(area)),
        ],
      ),
    );
  }

  Widget _buildImprovementAreaItem(dynamic area) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.trending_up,
            size: 16,
            color: Colors.orange.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            area.toString(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveGoals(List goals) {
    if (goals.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🚀 Metas Activas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...goals.map((goal) => _buildActiveGoalItem(goal)),
        ],
      ),
    );
  }

  Widget _buildActiveGoalItem(dynamic goal) {
    final progress = (goal['progress'] ?? 0).toDouble();
    final title = goal['title'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.green.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildNextSteps(EnhancedAnalyticsProvider analytics) {
    final nextMilestone = analytics.wellbeingData['next_milestone'] as Map? ?? {};

    if (nextMilestone.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade900,
            Colors.purple.shade900,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 Próximo Objetivo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            nextMilestone['description'] ?? 'Sigue así para desbloquear nuevos logros',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navegar a detalles o acción específica
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade900,
            ),
            child: const Text('Ver Detalles'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}