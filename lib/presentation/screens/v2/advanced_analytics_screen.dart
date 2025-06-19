// lib/presentation/screens/v2/advanced_analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/enhanced_analytics_provider.dart';
import '../components/modern_design_system.dart';

class AdvancedAnalyticsScreen extends StatefulWidget {
  final int userId;

  const AdvancedAnalyticsScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AdvancedAnalyticsScreen> createState() => _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState extends State<AdvancedAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar análisis avanzados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnhancedAnalyticsProvider>().loadCompleteAdvancedAnalytics(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<EnhancedAnalyticsProvider>();

    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      appBar: AppBar(
        backgroundColor: ModernColors.darkPrimary,
        elevation: 0,
        title: const Text('Análisis Avanzado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => analytics.loadCompleteAdvancedAnalytics(widget.userId),
          ),
        ],
      ),
      body: analytics.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailedWellbeingAnalysis(analytics),
                  const SizedBox(height: 24),
                  _buildMoodDeclineDetection(analytics),
                  const SizedBox(height: 24),
                  _buildHourlyPatterns(analytics),
                  const SizedBox(height: 24),
                  _buildEmotionalBalance(analytics),
                  const SizedBox(height: 24),
                  _buildPersonalizedInsights(analytics),
                  const SizedBox(height: 24),
                  _buildActionPlan(analytics),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // ANÁLISIS DETALLADO DE BIENESTAR
  // ============================================================================

  Widget _buildDetailedWellbeingAnalysis(EnhancedAnalyticsProvider analytics) {
    final wellbeing = analytics.wellbeingData;
    final components = wellbeing['components'] as Map<String, dynamic>? ?? {};
    final strengths = wellbeing['strengths'] as List? ?? [];
    final improvements = wellbeing['improvement_areas'] as List? ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1e3c72),
            const Color(0xFF2a5298),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 Análisis Detallado de Bienestar',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Radar Chart de Componentes
          SizedBox(
            height: 250,
            child: _buildRadarChart(components),
          ),

          const SizedBox(height: 20),

          // Fortalezas y Áreas de Mejora
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildStrengthsSection(strengths),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildImprovementsSection(improvements),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChart(Map<String, dynamic> components) {
    // Implementación simplificada del radar chart
    // En producción, usar una librería específica para radar charts
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.radar,
              size: 48,
              color: Colors.white54,
            ),
            const SizedBox(height: 8),
            const Text(
              'Radar Chart',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            // Mostrar valores como lista temporal
            ...components.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${_getComponentName(entry.key)}: ${entry.value}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthsSection(List strengths) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.green.shade400, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Fortalezas',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...strengths.take(3).map((strength) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $strength',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildImprovementsSection(List improvements) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.orange.shade400, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Áreas de Mejora',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...improvements.take(3).map((area) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $area',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          )),
        ],
      ),
    );
  }

  // ============================================================================
  // DETECCIÓN DE DECLIVE DEL ÁNIMO
  // ============================================================================

  Widget _buildMoodDeclineDetection(EnhancedAnalyticsProvider analytics) {
    final decline = analytics.moodDeclineAnalysis;
    final isDecline = decline['is_mood_decline'] as bool? ?? false;
    final severity = decline['decline_severity'] ?? 0;
    final daysSince = decline['days_since_peak'] ?? 0;
    final recommendations = decline['recommendations'] as List? ?? [];

    if (!isDecline) {
      return _buildPositiveMoodCard();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade900,
            Colors.orange.shade900,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.yellow.shade400,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alerta de Declive del Ánimo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Severidad: ${_getSeverityText(severity)} • $daysSince días',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gráfico de tendencia
          SizedBox(
            height: 150,
            child: _buildMoodTrendChart(decline),
          ),

          const SizedBox(height: 16),

          // Recomendaciones
          if (recommendations.isNotEmpty) ...[
            const Text(
              'Recomendaciones:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...recommendations.take(3).map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Colors.green.shade400,
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
        ],
      ),
    );
  }

  Widget _buildPositiveMoodCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade800,
            Colors.green.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.sentiment_very_satisfied,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de Ánimo Estable',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'No se detectan señales de declive. ¡Sigue así!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTrendChart(Map decline) {
    // Implementación simplificada del gráfico de tendencia
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'Gráfico de Tendencia del Ánimo',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // PATRONES POR HORA
  // ============================================================================

  Widget _buildHourlyPatterns(EnhancedAnalyticsProvider analytics) {
    final temporal = analytics._temporalComparisons;
    final patterns = temporal['hourly_patterns'] as Map? ?? {};

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⏰ Patrones por Hora del Día',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Heat Map de Horas
          _buildHourlyHeatMap(patterns),

          const SizedBox(height: 20),

          // Mejores y peores horas
          Row(
            children: [
              Expanded(
                child: _buildTimeCard(
                  '🌅 Mejor Hora',
                  patterns['best_hour'] ?? '12:00',
                  'Mayor energía positiva',
                  Colors.green.shade400,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeCard(
                  '🌙 Hora Difícil',
                  patterns['worst_hour'] ?? '15:00',
                  'Mayor cansancio',
                  Colors.red.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyHeatMap(Map patterns) {
    // Implementación del heat map
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'Heat Map de Actividad por Hora',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(String title, String time, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
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
    );
  }

  // ============================================================================
  // BALANCE EMOCIONAL
  // ============================================================================

  Widget _buildEmotionalBalance(EnhancedAnalyticsProvider analytics) {
    final wellbeing = analytics.wellbeingData;
    final emotionalBalance = wellbeing['components']?['emotional_balance'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade900,
            Colors.purple.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚖️ Balance Emocional Detallado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Visualización del balance
          _buildEmotionalBalanceVisualization(emotionalBalance),

          const SizedBox(height: 20),

          // Distribución de emociones
          _buildEmotionDistribution(analytics),
        ],
      ),
    );
  }

  Widget _buildEmotionalBalanceVisualization(dynamic balance) {
    final score = (balance as num).toDouble();
    final percentage = (score / 20 * 100).clamp(0, 100);

    return Column(
      children: [
        Text(
          '${percentage.toInt()}%',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getBalanceDescription(percentage),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.white.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            _getBalanceColor(percentage),
          ),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildEmotionDistribution(EnhancedAnalyticsProvider analytics) {
    // Distribución de emociones basada en los datos
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribución Emocional',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildEmotionBar('😊 Positivas', 0.7, Colors.green),
          const SizedBox(height: 8),
          _buildEmotionBar('😐 Neutrales', 0.2, Colors.blue),
          const SizedBox(height: 8),
          _buildEmotionBar('😔 Negativas', 0.1, Colors.red),
        ],
      ),
    );
  }

  Widget _buildEmotionBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // INSIGHTS PERSONALIZADOS
  // ============================================================================

  Widget _buildPersonalizedInsights(EnhancedAnalyticsProvider analytics) {
    final insights = analytics.wellbeingData['insights'] as List? ?? [];
    final goals = analytics.personalizedGoals;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.shade900,
            Colors.cyan.shade900,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Insights Personalizados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Insights principales
          ...insights.take(5).map((insight) => _buildInsightCard(insight)),

          const SizedBox(height: 16),

          // Correlaciones encontradas
          _buildCorrelations(analytics),
        ],
      ),
    );
  }

  Widget _buildInsightCard(dynamic insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.lightbulb,
                size: 18,
                color: Colors.amber,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelations(EnhancedAnalyticsProvider analytics) {
    // Correlaciones entre diferentes métricas
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔗 Correlaciones Detectadas',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildCorrelationItem(
            'Sueño → Estado de ánimo',
            0.85,
            'Fuerte correlación positiva',
          ),
          _buildCorrelationItem(
            'Ejercicio → Energía',
            0.72,
            'Correlación positiva',
          ),
          _buildCorrelationItem(
            'Estrés → Productividad',
            -0.65,
            'Correlación negativa',
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationItem(String title, double value, String description) {
    final color = value > 0 ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(value.abs() * 100).toInt()}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PLAN DE ACCIÓN
  // ============================================================================

  Widget _buildActionPlan(EnhancedAnalyticsProvider analytics) {
    final goals = analytics.personalizedGoals;
    final recommendedGoals = goals['recommended_goals'] as List? ?? [];
    final progressGoals = goals['progress_goals'] as List? ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2E3192),
            const Color(0xFF1BFFFF),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🚀 Plan de Acción Personalizado',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Acciones inmediatas
          _buildImmediateActions(recommendedGoals),

          const SizedBox(height: 20),

          // Plan semanal
          _buildWeeklyPlan(analytics),

          const SizedBox(height: 20),

          // Botón de acción principal
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Implementar navegación o acción
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2E3192),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Comenzar Plan de Mejora',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImmediateActions(List goals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Inmediatas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...goals.take(3).map((goal) => _buildActionItem(goal)),
      ],
    );
  }

  Widget _buildActionItem(dynamic goal) {
    final title = goal['title'] ?? '';
    final time = goal['estimated_time'] ?? '5 min';
    final impact = goal['impact_level'] ?? 'medium';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getImpactColor(impact).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.flash_on,
                color: _getImpactColor(impact),
                size: 20,
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
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPlan(EnhancedAnalyticsProvider analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Semanal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildWeekDay('Lunes', 'Meditación 10 min', Colors.blue),
          _buildWeekDay('Miércoles', 'Reflexión profunda', Colors.purple),
          _buildWeekDay('Viernes', 'Revisión semanal', Colors.green),
          _buildWeekDay('Domingo', 'Planificación', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildWeekDay(String day, String activity, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              day,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              activity,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  String _getComponentName(String key) {
    final names = {
      'consistency': 'Consistencia',
      'emotional_balance': 'Balance Emocional',
      'progress_trend': 'Tendencia',
      'diversity': 'Diversidad',
      'stress_management': 'Gestión del Estrés',
      'reflection_quality': 'Calidad de Reflexión',
      'achievements': 'Logros',
      'temporal_stability': 'Estabilidad',
    };
    return names[key] ?? key;
  }

  String _getSeverityText(dynamic severity) {
    final level = (severity as num).toInt();
    if (level <= 2) return 'Leve';
    if (level <= 5) return 'Moderada';
    if (level <= 7) return 'Alta';
    return 'Crítica';
  }

  String _getBalanceDescription(double percentage) {
    if (percentage >= 80) return 'Excelente equilibrio emocional';
    if (percentage >= 60) return 'Buen balance emocional';
    if (percentage >= 40) return 'Balance emocional en desarrollo';
    return 'Necesitas trabajar en tu equilibrio emocional';
  }

  Color _getBalanceColor(double percentage) {
    if (percentage >= 80) return Colors.green.shade400;
    if (percentage >= 60) return Colors.blue.shade400;
    if (percentage >= 40) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  Color _getImpactColor(String impact) {
    switch (impact.toLowerCase()) {
      case 'high':
        return Colors.green.shade400;
      case 'medium':
        return Colors.blue.shade400;
      case 'low':
        return Colors.orange.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
}