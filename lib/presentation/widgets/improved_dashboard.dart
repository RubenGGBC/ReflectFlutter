// lib/presentation/widgets/improved_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';

class ImprovedDashboard extends StatelessWidget {
  final int userId;

  const ImprovedDashboard({
    Key? key,
    required this.userId,
  }) : super(key: key);

  /// Parsea de forma segura un valor dinámico a un número (num).
  /// Maneja nulos, números existentes y representaciones de números en String.
  num _parseNum(dynamic value, {num fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value;
    if (value is String) {
      return num.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  /// Parsea de forma segura un valor dinámico a un String.
  /// Maneja nulos devolviendo un valor por defecto.
  String _parseString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos 'watch' para que el widget se reconstruya si los datos cambian
    final analytics = context.watch<AnalyticsProvider>();

    // Estado de carga y error
    if (analytics.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (analytics.errorMessage != null) {
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
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                analytics.errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => analytics.loadCompleteAnalytics(userId),
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

    // Extracción de datos con métodos seguros
    final summary = analytics.getDashboardSummary();
    final stressAlerts = analytics.getStressAlerts();
    final recommendations = analytics.getTopRecommendations();

    // UI Principal del Dashboard
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWellbeingScoreCard(context, summary),
        const SizedBox(height: 16),
        if (stressAlerts['requires_attention'] == true) ...[
          _buildStressAlert(context, stressAlerts),
          const SizedBox(height: 16),
        ],
        _buildQuickStats(context, analytics),
        const SizedBox(height: 16),
        _buildScoreComponents(context, analytics),
        const SizedBox(height: 16),
        _buildMoodAnalysis(context, analytics),
        const SizedBox(height: 16),
        _buildNextLevelProgress(context, analytics),
        const SizedBox(height: 16),
        _buildRecommendations(context, recommendations),
      ],
    );
  }

  Widget _buildWellbeingScoreCard(BuildContext context, Map<String, dynamic> summary) {
    final score = _parseNum(summary['wellbeing_score']).toInt();
    final level = _parseString(summary['level'], fallback: 'Iniciando');
    final emoji = _parseString(summary['emoji'], fallback: '🌱');
    final insights = summary['insights'] as List?;

    Color gradientStart, gradientEnd;
    if (score >= 80) {
      gradientStart = Colors.green.shade400;
      gradientEnd = Colors.green.shade600;
    } else if (score >= 60) {
      gradientStart = Colors.blue.shade400;
      gradientEnd = Colors.blue.shade600;
    } else if (score >= 40) {
      gradientStart = Colors.orange.shade400;
      gradientEnd = Colors.orange.shade600;
    } else {
      gradientStart = Colors.red.shade400;
      gradientEnd = Colors.red.shade600;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tu Bienestar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                child: Text(
                  '/100',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            level,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (insights != null && insights.isNotEmpty)
            Text(
              _parseString(insights.first),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStressAlert(BuildContext context, Map<String, dynamic> stressAlerts) {
    final alertColor = stressAlerts['alert_color'] as Color? ?? Colors.orange;
    final alertIcon = _parseString(stressAlerts['alert_icon'], fallback: '⚠️');
    final alertTitle = _parseString(stressAlerts['alert_title'], fallback: 'Alerta');
    final recommendations = stressAlerts['recommendations'] as List? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alertColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(alertIcon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  alertTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: alertColor,
                  ),
                ),
              ),
            ],
          ),
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Recomendación: ${_parseString(recommendations.first)}',
              style: TextStyle(
                fontSize: 14,
                color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white).withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, AnalyticsProvider analytics) {
    final streakData = analytics.getStreakData();
    final moodInsights = analytics.getQuickStatsMoodInsights();
    final diversityInsights = analytics.getQuickStatsDiversityInsights();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '🔥',
            'Racha Actual',
            '${_parseNum(streakData['current']).toInt()} días',
            'Mejor: ${_parseNum(streakData['longest']).toInt()}',
            Colors.orange.shade400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            _parseString(moodInsights['trend_icon'], fallback: '😊'),
            'Mood Promedio',
            '${_parseNum(moodInsights['avg_mood']).toStringAsFixed(1)}/10',
            _parseString(moodInsights['trend_description'], fallback: 'Estable'),
            moodInsights['trend_color'] as Color? ?? Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '🌈',
            'Diversidad',
            '${_parseNum(diversityInsights['categories_used']).toInt()}/${_parseNum(diversityInsights['max_categories'], fallback: 5).toInt()}',
            'Categorías',
            Colors.purple.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String title, String value, String subtitle, Color color) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreComponents(BuildContext context, AnalyticsProvider analytics) {
    final components = analytics.getScoreComponents();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Componentes del Score',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 16),
          ...components.map((component) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildComponentBar(component),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildComponentBar(Map<String, dynamic> component) {
    final name = _parseString(component['name']);
    final score = _parseNum(component['score']).toInt();
    final maxScore = _parseNum(component['maxScore'], fallback: 1).toInt();
    final percentage = _parseNum(component['percentage']);
    final color = component['color'] as Color? ?? Colors.blue;
    final icon = _parseString(component['icon']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Text(
              '$score/$maxScore',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage.toDouble() / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodAnalysis(BuildContext context, AnalyticsProvider analytics) {
    final moodInsights = analytics.moodAnalysis;
    final stability = _parseNum(moodInsights['stability_score'], fallback: 0.0) * 100;
    final positiveRatio = _parseNum(moodInsights['positive_days_ratio'], fallback: 0.0) * 100;
    final daysAnalyzed = _parseNum(moodInsights['total_days_analyzed']).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '😊 Análisis de Estado de Ánimo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMoodMetric('Estabilidad', '${stability.toStringAsFixed(0)}%', Colors.blue.shade400),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMoodMetric('Días Positivos', '${positiveRatio.toStringAsFixed(0)}%', Colors.green.shade400),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Basado en los últimos $daysAnalyzed días de análisis.',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildNextLevelProgress(BuildContext context, AnalyticsProvider analytics) {
    final progress = analytics.getNextLevelProgress();
    final currentScore = _parseNum(progress['current_value']).toInt();
    final targetScore = _parseNum(progress['target_value'], fallback: 1).toInt();
    final description = _parseString(progress['description']);
    final pointsNeeded = (targetScore - currentScore).clamp(0, targetScore);
    final progressPercentage = _parseNum(progress['progress']).toDouble();

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🎯 Próximo Logro',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Text(
                '$currentScore/$targetScore',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: Colors.blue.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pointsNeeded > 0 ? 'Te faltan $pointsNeeded puntos para el siguiente nivel.' : '¡Nivel Completado!',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context, List<Map<String, String>> recommendations) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
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
          Text(
            '💡 Recomendaciones para ti',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 16),
          ...recommendations.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRecommendationCard(rec),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, String> recommendation) {
    final emoji = _parseString(recommendation['emoji'], fallback: '💡');
    final title = _parseString(recommendation['title'], fallback: 'Recomendación');
    final description = _parseString(recommendation['description']);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}