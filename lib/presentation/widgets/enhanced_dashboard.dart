// lib/presentation/widgets/enhanced_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/optimized_providers.dart'; // ✅ IMPORT ARREGLADO
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
      // ✅ PROVIDER ARREGLADO
      context.read<OptimizedAnalyticsProvider>().loadCompleteAnalytics(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ PROVIDER ARREGLADO
    final analytics = context.watch<OptimizedAnalyticsProvider>();

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
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF141B2D),
            borderRadius: BorderRadius.circular(25),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.blue.shade400,
              borderRadius: BorderRadius.circular(25),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: '📊 Resumen'),
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
              _buildSummaryTab(analytics),
              _buildStressTab(analytics),
              _buildProgressTab(analytics),
              _buildGoalsTab(analytics),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(OptimizedAnalyticsProvider analytics) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar los datos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              analytics.errorMessage!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
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

  Widget _buildAdvancedWellbeingScore(OptimizedAnalyticsProvider analytics) {
    final wellbeingStatus = analytics.getWellbeingStatus();
    final score = wellbeingStatus['score'] as int? ?? 0;
    final level = wellbeingStatus['level'] as String? ?? 'Sin datos';
    final emoji = wellbeingStatus['emoji'] as String? ?? '📊';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getScoreColor(score),
            _getScoreColor(score).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor(score).withOpacity(0.3),
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
                    emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nivel $level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    wellbeingStatus['message'] ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    score.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '/10',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: score / 10,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab(OptimizedAnalyticsProvider analytics) {
    final summary = analytics.getDashboardSummary();
    final insights = analytics.getHighlightedInsights();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Métricas principales
          _buildQuickStatsGrid(summary),
          const SizedBox(height: 20),

          // Insights destacados
          if (insights.isNotEmpty) ...[
            const Text(
              '💡 Insights Destacados',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...insights.take(3).map((insight) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF141B2D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(insight['emoji'] ?? '💡', style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight['title'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          insight['description'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(Map<String, dynamic> summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          '🎯',
          'Bienestar',
          '${summary['wellbeing_score']}/10',
          Colors.blue.shade400,
        ),
        _buildStatCard(
          '🔥',
          'Racha Actual',
          '${summary['current_streak']} días',
          Colors.orange.shade400,
        ),
        _buildStatCard(
          '📊',
          'Entradas',
          '${summary['total_entries']}',
          Colors.green.shade400,
        ),
        _buildStatCard(
          '😊',
          'Mood Promedio',
          '${(summary['avg_mood'] as double? ?? 0.0).toStringAsFixed(1)}',
          Colors.purple.shade400,
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStressTab(OptimizedAnalyticsProvider analytics) {
    final stressAlerts = analytics.getStressAlerts();
    final recommendations = analytics.getPriorityRecommendations();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alerta de estrés
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (stressAlerts['alert_color'] as Color? ?? Colors.green).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: stressAlerts['alert_color'] as Color? ?? Colors.green,
              ),
            ),
            child: Row(
              children: [
                Text(
                  stressAlerts['alert_icon'] ?? '✅',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stressAlerts['alert_title'] ?? 'Estado del Estrés',
                        style: TextStyle(
                          color: stressAlerts['alert_color'] as Color? ?? Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nivel: ${stressAlerts['level'] ?? 'normal'}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Recomendaciones
          const Text(
            '💡 Recomendaciones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...((stressAlerts['recommendations'] as List?) ?? []).map((rec) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF141B2D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.yellow, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rec.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProgressTab(OptimizedAnalyticsProvider analytics) {
    final chartData = analytics.getMoodChartData();
    final nextAchievement = analytics.getNextAchievementToUnlock();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Gráfico de progreso
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141B2D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: chartData.isNotEmpty
                ? _buildProgressChart(chartData)
                : const Center(
              child: Text(
                'No hay suficientes datos para mostrar el progreso',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Próximo logro
          if (nextAchievement != null)
            _buildNextAchievement(nextAchievement),
        ],
      ),
    );
  }

  Widget _buildProgressChart(List<Map<String, dynamic>> chartData) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: chartData.asMap().entries.map((entry) {
              final index = entry.key.toDouble();
              final mood = (entry.value['mood'] as double? ?? 5.0);
              return FlSpot(index, mood);
            }).toList(),
            isCurved: true,
            color: Colors.blue.shade400,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.shade400.withOpacity(0.2),
            ),
          ),
        ],
        minY: 0,
        maxY: 10,
      ),
    );
  }

  Widget _buildNextAchievement(Map<String, dynamic> achievement) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                achievement['emoji'] ?? '🏆',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Próximo Logro',
                      style: TextStyle(
                        color: Colors.yellow.shade400,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      achievement['title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      achievement['description'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '${achievement['current']}/${achievement['target']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (achievement['progress'] as double?) ?? 0.0,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow.shade400),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTab(OptimizedAnalyticsProvider analytics) {
    final recommendations = analytics.getTopRecommendations();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 Objetivos Recomendados',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          ...recommendations.map((goal) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141B2D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(goal['emoji'] ?? '🎯', style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal['description'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(goal['priority'] ?? 'low'),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPriorityLabel(goal['priority'] ?? 'low'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green.shade400;
    if (score >= 6) return Colors.blue.shade400;
    if (score >= 4) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high': return Colors.red.shade400;
      case 'medium': return Colors.orange.shade400;
      case 'low': return Colors.blue.shade400;
      default: return Colors.grey.shade400;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'high': return 'ALTA';
      case 'medium': return 'MEDIA';
      case 'low': return 'BAJA';
      default: return 'INFO';
    }
  }
}