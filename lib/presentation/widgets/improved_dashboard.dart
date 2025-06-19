import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';

class ImprovedDashboard extends StatelessWidget {
  final int userId;

  const ImprovedDashboard({
    Key? key,
    required this.userId,
  }) : super(key: key);

  /// Safely parses a dynamic value into a number (num).
  /// Handles nulls, existing numbers, and string representations of numbers.
  num _parseNum(dynamic value, {num fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value;
    if (value is String) {
      return num.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  /// Safely parses a dynamic value into a String.
  /// Handles nulls by returning a fallback value.
  String _parseString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analytics, child) {
        if (analytics.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (analytics.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Error cargando datos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  analytics.errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => analytics.loadCompleteAnalytics(userId),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final summary = analytics.getDashboardSummary();
        final stressAlerts = analytics.getStressAlerts();
        final recommendations = analytics.getTopRecommendations();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWellbeingScoreCard(context, summary),
              const SizedBox(height: 16),
              if (stressAlerts['requires_attention'] == true) ...[
                _buildStressAlert(stressAlerts),
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
          ),
        );
      },
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
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '/100',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
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

  Widget _buildStressAlert(Map<String, dynamic> stressAlerts) {
    final alertColor = stressAlerts['alert_color'] as Color? ?? Colors.orange;
    final alertIcon = _parseString(stressAlerts['alert_icon'], fallback: '⚠️');
    final alertTitle = _parseString(stressAlerts['alert_title'], fallback: 'Alerta');
    final recommendations = stressAlerts['recommendations'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alertColor, width: 1),
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
                    color: alertColor.withOpacity(0.8),
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
                color: alertColor.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, AnalyticsProvider analytics) {
    final streakData = analytics.getStreakData();
    // CORREGIDO: Llamar a los nuevos métodos del provider
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
            '${_parseNum(diversityInsights['categories_used']).toInt()}/${_parseNum(diversityInsights['max_categories']).toInt()}',
            'Categorías',
            Colors.purple.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String title, String value, String subtitle, Color color) {
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
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Componentes del Score',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodAnalysis(BuildContext context, AnalyticsProvider analytics) {
    // CORREGIDO: Usar el mapa de análisis de mood directamente
    final moodInsights = analytics.moodAnalysis;
    final stability = _parseNum(moodInsights['stability'], fallback: 0).toInt();
    final positiveRatio = _parseNum(moodInsights['positive_ratio'], fallback: 0).toInt();
    final daysAnalyzed = _parseNum(moodInsights['days_analyzed'] ?? moodInsights['total_days_analyzed']).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '😊 Análisis de Estado de Ánimo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMoodMetric('Estabilidad', '$stability%', Colors.blue.shade400),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMoodMetric('Días Positivos', '$positiveRatio%', Colors.green.shade400),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Basado en $daysAnalyzed días de análisis',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildNextLevelProgress(BuildContext context, AnalyticsProvider analytics) {
    // CORREGIDO: Adaptado a la nueva estructura de datos del provider
    final progress = analytics.getNextLevelProgress();
    final currentScore = _parseNum(progress['current_value']).toInt();
    final targetScore = _parseNum(progress['target_value'], fallback: 1).toInt();
    final targetLevel = _parseString(progress['description']);
    final pointsNeeded = (targetScore - currentScore).clamp(0, targetScore);
    final progressPercentage = _parseNum(progress['progress']).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        // CORREGIDO: Typo de 'boxShow' a 'boxShadow'
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🎯 Progreso al Siguiente Nivel',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
            targetLevel,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
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
            pointsNeeded > 0 ? 'Te faltan $pointsNeeded puntos' : '¡Nivel Completado!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 Recomendaciones',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
    final priority = _parseString(recommendation['priority'], fallback: 'medium');

    Color priorityColor;
    switch (priority) {
      case 'high':
        priorityColor = Colors.red.shade400;
        break;
      case 'medium':
        priorityColor = Colors.orange.shade400;
        break;
      default:
        priorityColor = Colors.blue.shade400;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: priorityColor.withOpacity(0.3)),
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
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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
