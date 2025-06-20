// lib/presentation/widgets/enhanced_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/analytics_provider.dart'; // UPDATED
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

class _EnhancedDashboardState extends State<EnhancedDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Cargar datos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // UPDATED: Call the correct provider
      context.read<AnalyticsProvider>().loadCompleteAnalytics(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UPDATED: Watch AnalyticsProvider
    final analytics = context.watch<AnalyticsProvider>();

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

  Widget _buildErrorState(AnalyticsProvider analytics) {
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
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              analytics.errorMessage!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => analytics.loadCompleteAnalytics(widget.userId),
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

  Widget _buildAdvancedWellbeingScore(AnalyticsProvider analytics) {
    final summary = analytics.getDashboardSummary(); // UPDATED
    final score = (summary['wellbeing_score'] as num? ?? 0).toInt();
    final level = summary['level']?.toString() ?? 'Iniciando';
    final components = analytics.getScoreComponents(); // UPDATED

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
          _buildScoreComponents(components), // UPDATED
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

  Widget _buildScoreComponents(List<Map<String, dynamic>> components) { // UPDATED
    return Column(
      children: components.map((component) {
        final name = component['name']?.toString() ?? 'Componente';
        final value = (component['score'] as num? ?? 0).toDouble();
        final maxValue = (component['maxScore'] as num? ?? 10).toDouble();
        final percentage = (value / (maxValue > 0 ? maxValue : 1)).clamp(0.0, 1.0);
        final color = component['color'] as Color? ?? Colors.grey;

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
                    '${value.toStringAsFixed(1)}/${maxValue.toStringAsFixed(0)}',
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
                valueColor: AlwaysStoppedAnimation<Color>(color),
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

  Widget _buildGeneralTab(AnalyticsProvider analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildKeyInsights(analytics),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB ESTRÉS
  // ============================================================================

  Widget _buildStressTab(AnalyticsProvider analytics) {
    final stress = analytics.getStressAlerts(); // UPDATED
    final stressLevel = (stress['frequency'] as num? ?? 0).toDouble();
    final recommendations = stress['recommendations'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStressOverview(stressLevel, 0), // Ansiedad no está en el provider normal
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
            '😰 Niveles de Estrés',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildStressIndicator('Frecuencia de Estrés', stressLevel.toDouble(), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStressIndicator(String label, double value, Color color) {
    final percentage = (value / 100).clamp(0.0, 1.0);

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
              '${value.toStringAsFixed(0)}%',
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

  Widget _buildProgressTab(AnalyticsProvider analytics) {
    final timeline = analytics.getMoodChartData(); // UPDATED
    final nextAchievement = analytics.getNextAchievementToUnlock();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProgressChart(timeline),
          const SizedBox(height: 16),
          if(nextAchievement != null) _buildMilestones([nextAchievement]), // Adaptado
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
            '📈 Línea de Progreso (Mood)', // UPDATED
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
                      reservedSize: 28,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < timeline.length) {
                            return Text(
                              timeline[value.toInt()]['date']?.toString() ?? '',
                              style: const TextStyle(color: Colors.white54, fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 22,
                      )
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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

  Widget _buildGoalsTab(AnalyticsProvider analytics) {
    final recommendedGoals = analytics.getTopRecommendations(); // UPDATED
    final progressGoals = [analytics.getNextLevelProgress()]; // UPDATED

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRecommendedGoals(recommendedGoals),
          const SizedBox(height: 16),
          _buildActiveGoals(progressGoals),
        ],
      ),
    );
  }

  Widget _buildRecommendedGoals(List<Map<String, String>> goals) {
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

  Widget _buildGoalCard(Map<String, String> goal) { // UPDATED
    final title = goal['title'] ?? 'Meta';
    final description = goal['description'] ?? '';
    final type = goal['type'] ?? 'general';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getPriorityColor(type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getPriorityColor(type).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getPriorityColor(type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _getCategoryEmoji(type),
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
  // MÉTODOS AUXILIARES (Algunos actualizados)
  // ============================================================================

  Color _getLevelColor(String level) {
    if(level.toLowerCase().contains('maestro') || level.toLowerCase().contains('excelente')) return Colors.purple.shade400;
    if(level.toLowerCase().contains('avanzado')) return Colors.blue.shade400;
    if(level.toLowerCase().contains('progreso') || level.toLowerCase().contains('intermedio')) return Colors.green.shade400;
    return Colors.orange.shade400;
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

  String _getStressLevelDescription(double level) {
    if (level <= 30) return 'Bajo';
    if (level <= 60) return 'Moderado';
    return 'Alto';
  }

  Color _getPriorityColor(String type) { // UPDATED
    switch (type.toLowerCase()) {
      case 'stress': return Colors.red.shade400;
      case 'consistency': return Colors.orange.shade400;
      case 'diversity': return Colors.purple.shade400;
      default: return Colors.blue.shade400;
    }
  }

  String _getCategoryEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'stress': return '🧘';
      case 'consistency': return '📅';
      case 'diversity': return '🌈';
      case 'mood': return '😊';
      default: return '🎯';
    }
  }

  List<FlSpot> _getProgressSpots(List timeline) {
    return timeline.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final data = entry.value as Map<String, dynamic>;
      final score = (data['mood'] as num? ?? 5.0).toDouble(); // UPDATED
      return FlSpot(index, score);
    }).toList();
  }

  Widget _buildKeyInsights(AnalyticsProvider analytics) {
    final insights = analytics.getHighlightedInsights(); // UPDATED

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
                Text(insight['emoji'] ?? '💡', style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight['description'] ?? 'No hay insights disponibles.',
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

  Widget _buildStressRecommendations(Map<String, dynamic> stress) {
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
      return _buildEmptyState('Aún no has alcanzado logros importantes');
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
            '🏆 Próximo Logro', // UPDATED
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...milestones.take(1).map((milestone) => _buildMilestoneItem(milestone)),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(dynamic milestone) {
    final description = milestone['description'] ?? '';
    final title = milestone['title'] ?? 'Logro';
    final emoji = milestone['emoji'] ?? '🏆';

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
          Text(emoji, style: const TextStyle(fontSize: 24)),
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

  Widget _buildImprovementAreas(AnalyticsProvider analytics) {
    final areas = analytics.getTopRecommendations();

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
            '🎯 Áreas de Mejora Sugeridas',
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

  Widget _buildImprovementAreaItem(Map<String, String> area) {
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
            area['title'] ?? 'Mejora sugerida',
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
    final progress = (goal['progress'] as num? ?? 0.0).toDouble();
    final title = goal['description'] ?? '';
    final currentValue = (goal['current_value'] as num? ?? 0).toInt();
    final targetValue = (goal['target_value'] as num? ?? 1).toInt();

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
                '$currentValue/$targetValue',
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