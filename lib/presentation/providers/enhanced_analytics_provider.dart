// ============================================================================
// PROVIDER DE ANALYTICS MEJORADO
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../data/services/advanced_user_analytics.dart';
import '../../data/services/database_service.dart';

class EnhancedAnalyticsProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  final AdvancedUserAnalytics _advancedAnalytics;
  final Logger _logger = Logger();

  // Estados de carga
  bool _isLoading = false;
  String? _errorMessage;

  // Datos analíticos avanzados
  Map<String, dynamic> _wellbeingData = {};
  Map<String, dynamic> _stressAnalysis = {};
  Map<String, dynamic> _moodDeclineAnalysis = {};
  Map<String, dynamic> _progressTimeline = {};
  Map<String, dynamic> _personalizedGoals = {};
  Map<String, dynamic> _temporalComparisons = {};

  EnhancedAnalyticsProvider(this._databaseService)
      : _advancedAnalytics = AdvancedUserAnalytics(_databaseService);

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get wellbeingData => _wellbeingData;
  Map<String, dynamic> get stressAnalysis => _stressAnalysis;
  Map<String, dynamic> get moodDeclineAnalysis => _moodDeclineAnalysis;
  Map<String, dynamic> get progressTimeline => _progressTimeline;
  Map<String, dynamic> get personalizedGoals => _personalizedGoals;
  Map<String, dynamic> get temporalComparisons => _temporalComparisons;

  /// 🚀 Cargar análisis completo del usuario
  Future<void> loadCompleteAdvancedAnalytics(int userId) async {
    _setLoading(true);
    _clearError();

    try {
      _logger.i('🔍 Cargando análisis avanzado para usuario: $userId');

      // Cargar todos los análisis de forma paralela para mejor rendimiento
      final results = await Future.wait([
        _advancedAnalytics.getAdvancedWellbeingScore(userId),
        _advancedAnalytics.detectStressAndAnxiety(userId),
        _advancedAnalytics.detectMoodDecline(userId),
        _advancedAnalytics.getDetailedProgressTimeline(userId),
        _advancedAnalytics.generatePersonalizedGoals(userId),
        _advancedAnalytics.getTemporalComparisons(userId),
      ]);

      _wellbeingData = results[0];
      _stressAnalysis = results[1];
      _moodDeclineAnalysis = results[2];
      _progressTimeline = results[3];
      _personalizedGoals = results[4];
      _temporalComparisons = results[5];


      _logger.i('✅ Análisis completo cargado. Score: ${_wellbeingData['overall_score']}');

      // Generar notificaciones inteligentes si es necesario
      await _generateIntelligentNotifications(userId);

    } catch (e) {
      _logger.e('❌ Error cargando análisis avanzado: $e');
      _setError('Error cargando análisis del usuario');
    } finally {
      _setLoading(false);
    }
  }

  /// 🚨 Obtener alertas críticas del usuario
  List<Map<String, dynamic>> getCriticalAlerts() {
    final alerts = <Map<String, dynamic>>[];

    // Alerta de estrés alto
    if (_stressAnalysis['alert_level'] == 'high') {
      alerts.add({
        'type': 'stress_critical',
        'priority': 'high',
        'emoji': '🚨',
        'title': 'Nivel de Estrés Crítico',
        'message': _stressAnalysis['alert_message'],
        'action': 'Ver recomendaciones de manejo del estrés',
        'color': 'red',
      });
    }

    // Alerta de declive del mood
    if (_moodDeclineAnalysis['concern_level'] == 'high') {
      alerts.add({
        'type': 'mood_decline',
        'priority': 'high',
        'emoji': '😔',
        'title': 'Declive del Estado de Ánimo',
        'message': _moodDeclineAnalysis['message'],
        'action': 'Buscar apoyo profesional',
        'color': 'orange',
      });
    }

    // Alerta de bajo score de bienestar
    if ((_wellbeingData['overall_score'] ?? 50) < 30) {
      alerts.add({
        'type': 'low_wellbeing',
        'priority': 'medium',
        'emoji': '💔',
        'title': 'Bienestar Bajo',
        'message': 'Tu score de bienestar ha bajado significativamente',
        'action': 'Revisar plan de autocuidado',
        'color': 'yellow',
      });
    }

    return alerts;
  }

  /// 📊 Obtener resumen de progreso para dashboard
  Map<String, dynamic> getProgressSummary() {
    final wellbeingScore = _wellbeingData['overall_score'] ?? 0;
    final level = _wellbeingData['level'] ?? 'Iniciando';
    final improvements = _progressTimeline['improvements'] ?? [];
    final milestones = _progressTimeline['milestones'] ?? [];

    return {
      'wellbeing_score': wellbeingScore,
      'level': level,
      'recent_improvements': improvements.take(3).toList(),
      'unlocked_milestones': milestones.length,
      'stress_status': _getStressStatus(),
      'mood_trend': _getMoodTrend(),
      'next_goal': _getNextPriorityGoal(),
      'motivational_message': _getMotivationalMessage(wellbeingScore),
    };
  }

  /// 🎯 Obtener recomendaciones inteligentes
  List<Map<String, dynamic>> getIntelligentRecommendations() {
    final recommendations = <Map<String, dynamic>>[];

    // Recomendaciones basadas en análisis de estrés
    if (_stressAnalysis['recommendations'] != null) {
      for (final rec in _stressAnalysis['recommendations']) {
        recommendations.add({
          'type': 'stress_management',
          'title': 'Gestión del Estrés',
          'description': rec,
          'priority': _stressAnalysis['alert_level'] == 'high' ? 'high' : 'medium',
          'emoji': '🧘',
          'category': 'Bienestar Mental',
        });
      }
    }

    // Recomendaciones de mejora basadas en componentes débiles
    final improvementAreas = _wellbeingData['improvement_areas'] ?? [];
    for (final area in improvementAreas) {
      recommendations.add(_getRecommendationForArea(area));
    }

    // Recomendaciones de objetivos personalizados
    final goals = _personalizedGoals['recommended_goals'] ?? [];
    for (final goal in goals.take(2)) {
      recommendations.add({
        'type': 'goal_pursuit',
        'title': goal['title'],
        'description': goal['description'],
        'priority': goal['priority'],
        'emoji': goal['emoji'],
        'category': 'Objetivos Personales',
        'progress': goal['progress_percentage'],
        'action': 'Ver plan detallado',
      });
    }

    return recommendations.take(5).toList(); // Top 5 recomendaciones
  }

  /// 📈 Obtener datos para gráficos avanzados
  Map<String, dynamic> getAdvancedChartData() {
    return {
      'wellbeing_components': _getWellbeingComponentsChart(),
      'progress_timeline': _getProgressTimelineChart(),
      'stress_patterns': _getStressPatternsChart(),
      'mood_evolution': _getMoodEvolutionChart(),
      'goal_progress': _getGoalProgressChart(),
    };
  }

  /// 🏆 Obtener logros y milestones recientes
  Map<String, dynamic> getRecentAchievements() {
    final milestones = _progressTimeline['milestones'] ?? [];
    final improvements = _progressTimeline['improvements'] ?? [];
    final goals = _personalizedGoals['recommended_goals'] ?? [];

    return {
      'recent_milestones': milestones.take(3).toList(),
      'notable_improvements': improvements.where((imp) =>
      (imp['magnitude'] ?? 0) > 1.0).take(3).toList(),
      'goal_completions': goals.where((goal) =>
      (goal['progress_percentage'] ?? 0) >= 100).toList(),
      'streak_achievements': _getStreakAchievements(),
    };
  }

  /// Métricas rápidas para vistas compactas
  Map<String, dynamic> getQuickMetrics() {
    final stressLevel = _stressAnalysis['alert_level'] ?? 'normal';
    final moodLevel = _moodDeclineAnalysis['concern_level'] ?? 'normal';
    final goals = _personalizedGoals['recommended_goals'] as List? ?? [];

    return {
      'wellbeing_score': _wellbeingData['overall_score'] ?? 0,
      'stress_level': _mapStressLevel(stressLevel),
      'mood_trend': _mapMoodLevel(moodLevel),
      'active_goals': goals.length,
      'completed_today': 0, // Debes implementar esta lógica si es necesaria
    };
  }

  /// Datos para el gráfico de componentes de bienestar
  List<Map<String, dynamic>> getWellbeingComponentsChartData() {
    final components = _wellbeingData['components'] as Map<String, dynamic>? ?? {};

    return components.entries.map((entry) {
      return {
        'name': _getComponentDisplayName(entry.key),
        'value': (entry.value ?? 0).toDouble(),
        'score': entry.value,
        'maxScore': _getMaxScoreForComponent(entry.key),
        'percentage': (entry.value / _getMaxScoreForComponent(entry.key) * 100).round(),
        // Puedes añadir más propiedades como color o emoji si los necesitas
      };
    }).toList();
  }


  // ============================================================================
  // MÉTODOS AUXILIARES PRIVADOS
  // ============================================================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Map<String, String> _getStressStatus() {
    final level = _stressAnalysis['alert_level'] ?? 'normal';
    final frequency = _stressAnalysis['stress_frequency'] ?? 0;

    switch (level) {
      case 'high':
        return {'status': 'Alto', 'emoji': '🔴', 'color': 'red'};
      case 'moderate':
        return {'status': 'Moderado', 'emoji': '🟡', 'color': 'orange'};
      case 'mild':
        return {'status': 'Leve', 'emoji': '🟢', 'color': 'green'};
      default:
        return {'status': 'Normal', 'emoji': '✅', 'color': 'green'};
    }
  }

  Map<String, String> _getMoodTrend() {
    final trend = _progressTimeline['overall_trend'] ?? 'stable';

    switch (trend) {
      case 'improving':
        return {'trend': 'Mejorando', 'emoji': '📈', 'color': 'green'};
      case 'declining':
        return {'trend': 'Descendiendo', 'emoji': '📉', 'color': 'red'};
      case 'stable':
        return {'trend': 'Estable', 'emoji': '➡️', 'color': 'blue'};
      default:
        return {'trend': 'Sin datos', 'emoji': '❓', 'color': 'gray'};
    }
  }

  Map<String, dynamic>? _getNextPriorityGoal() {
    final goals = _personalizedGoals['recommended_goals'] ?? [];
    return goals.isNotEmpty ? goals.first : null;
  }

  String _getMotivationalMessage(int score) {
    if (score >= 80) {
      return '¡Increíble! Eres un ejemplo de bienestar 🌟';
    } else if (score >= 60) {
      return '¡Excelente progreso! Sigue así 💪';
    } else if (score >= 40) {
      return 'Vas por buen camino. Cada día cuenta 🌱';
    } else {
      return 'Tu viaje de crecimiento ha comenzado 🚀';
    }
  }

  Map<String, dynamic> _getRecommendationForArea(String area) {
    switch (area) {
      case 'Consistencia':
        return {
          'type': 'consistency_improvement',
          'title': 'Mejora tu Consistencia',
          'description': 'Establece un horario fijo para tus reflexiones diarias',
          'priority': 'high',
          'emoji': '⏰',
          'category': 'Hábitos',
          'action': 'Configurar recordatorios',
        };
      case 'Equilibrio Emocional':
        return {
          'type': 'emotional_balance',
          'title': 'Equilibrio Emocional',
          'description': 'Practica técnicas de regulación emocional',
          'priority': 'medium',
          'emoji': '⚖️',
          'category': 'Bienestar Emocional',
          'action': 'Ver ejercicios de mindfulness',
        };
      case 'Gestión del Estrés':
        return {
          'type': 'stress_improvement',
          'title': 'Mejor Gestión del Estrés',
          'description': 'Desarrolla estrategias efectivas de manejo del estrés',
          'priority': 'high',
          'emoji': '🧘',
          'category': 'Manejo del Estrés',
          'action': 'Aprender técnicas de relajación',
        };
      default:
        return {
          'type': 'general_improvement',
          'title': 'Área de Mejora',
          'description': 'Continúa trabajando en $area',
          'priority': 'medium',
          'emoji': '🎯',
          'category': 'Desarrollo Personal',
        };
    }
  }

  List<Map<String, dynamic>> _getWellbeingComponentsChart() {
    final components = _wellbeingData['components'] ?? {};
    return components.entries.map((entry) => {
      'component': entry.key,
      'name': _getComponentDisplayName(entry.key),
      'score': entry.value,
      'maxScore': _getMaxScoreForComponent(entry.key),
      'percentage': (entry.value / _getMaxScoreForComponent(entry.key) * 100).round(),
    }).toList();
  }

  List<Map<String, dynamic>> _getProgressTimelineChart() {
    final timeline = _progressTimeline['timeline'] ?? [];
    return timeline.map<Map<String, dynamic>>((point) => {
      'date': point['week_start'],
      'mood': point['mood'],
      'energy': point['energy'],
      'stress': point['stress'],
      'overall_score': point['overall_score'],
    }).toList();
  }

  String _getComponentDisplayName(String key) {
    switch (key) {
      case 'consistency': return 'Consistencia';
      case 'emotional_balance': return 'Equilibrio Emocional';
      case 'progress_trend': return 'Progreso';
      case 'diversity': return 'Diversidad';
      case 'stress_management': return 'Gestión Estrés';
      case 'reflection_quality': return 'Calidad Reflexión';
      case 'achievements': return 'Logros';
      case 'temporal_stability': return 'Estabilidad';
      default: return key;
    }
  }

  double _getMaxScoreForComponent(String key) {
    switch (key) {
      case 'consistency': return 25;
      case 'emotional_balance': return 20;
      case 'progress_trend': return 15;
      case 'diversity': return 10;
      case 'stress_management': return 10;
      case 'reflection_quality': return 10;
      case 'achievements': return 5;
      case 'temporal_stability': return 5;
      default: return 10;
    }
  }

  String _mapStressLevel(String level) {
    switch (level) {
      case 'low': return 'Bajo';
      case 'normal': return 'Normal';
      case 'moderate': return 'Moderado';
      case 'high': return 'Alto';
      case 'critical': return 'Crítico';
      default: return 'Normal';
    }
  }

  String _mapMoodLevel(String level) {
    switch (level) {
      case 'improving': return 'Mejorando';
      case 'stable': return 'Estable';
      case 'normal': return 'Normal';
      case 'declining': return 'Descendiendo';
      case 'concerning': return 'Preocupante';
      default: return 'Normal';
    }
  }

  String _getStressLevelText() {
    final level = _stressAnalysis['alert_level'] ?? 'normal';
    return _mapStressLevel(level);
  }

  String _getMoodTrendText() {
    final level = _moodDeclineAnalysis['concern_level'] ?? 'normal';
    return _mapMoodLevel(level);
  }

  Future<void> _generateIntelligentNotifications(int userId) async {
    // Generar notificaciones basadas en el análisis
    final alerts = getCriticalAlerts();

    for (final alert in alerts) {
      if (alert['priority'] == 'high') {
        _logger.w('🚨 Alerta crítica para usuario $userId: ${alert['title']}');
        // Aquí se podría integrar con un sistema de notificaciones
      }
    }
  }

  List<Map<String, dynamic>> _getStreakAchievements() {
    // Implementar lógica para obtener logros de racha
    return [];
  }

  List<Map<String, dynamic>> _getStressPatternsChart() {
    // Implementar datos para gráfico de patrones de estrés
    return [];
  }

  List<Map<String, dynamic>> _getMoodEvolutionChart() {
    // Implementar datos para gráfico de evolución del mood
    return [];
  }

  List<Map<String, dynamic>> _getGoalProgressChart() {
    // Implementar datos para gráfico de progreso de objetivos
    return [];
  }
} // <-- FIN DE LA CLASE EnhancedAnalyticsProvider


// ============================================================================
// EJEMPLO DE USO EN UI - WIDGET DE DASHBOARD AVANZADO
// ============================================================================

class AdvancedDashboardWidget extends StatelessWidget {
  final int userId;

  const AdvancedDashboardWidget({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedAnalyticsProvider>(
      builder: (context, analytics, child) {
        if (analytics.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final progressSummary = analytics.getProgressSummary();
        final criticalAlerts = analytics.getCriticalAlerts();
        final recommendations = analytics.getIntelligentRecommendations();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score de Bienestar Principal
              _buildWellbeingScoreCard(progressSummary),

              const SizedBox(height: 16),

              // Alertas Críticas (si las hay)
              if (criticalAlerts.isNotEmpty) ...[
                _buildCriticalAlertsSection(criticalAlerts),
                const SizedBox(height: 16),
              ],

              // Resumen de Estado
              _buildStatusSummary(progressSummary),

              const SizedBox(height: 16),

              // Gráfico de Componentes de Bienestar
              _buildWellbeingComponentsChart(analytics),

              const SizedBox(height: 16),

              // Recomendaciones Inteligentes
              _buildRecommendationsSection(recommendations),

              const SizedBox(height: 16),

              // Progreso de Objetivos
              _buildGoalsProgressSection(analytics),

              const SizedBox(height: 16),

              // Timeline de Progreso
              _buildProgressTimelineSection(analytics),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWellbeingScoreCard(Map<String, dynamic> summary) {
    final score = summary['wellbeing_score'] ?? 0;
    final level = summary['level'] ?? 'Iniciando';
    final message = summary['motivational_message'] ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: _getScoreGradientColors(score),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score de Bienestar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '/100',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalAlertsSection(List<Map<String, dynamic>> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⚠️ Alertas Importantes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 12),
        ...alerts.map((alert) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getAlertColor(alert['color']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getAlertColor(alert['color']),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                alert['emoji'],
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert['message'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildStatusSummary(Map<String, dynamic> summary) {
    final stressStatus = summary['stress_status'] ?? {};
    final moodTrend = summary['mood_trend'] ?? {};

    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'Estado del Estrés',
            stressStatus['status'] ?? 'Normal',
            stressStatus['emoji'] ?? '✅',
            _getAlertColor(stressStatus['color'] ?? 'green'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatusCard(
            'Tendencia del Mood',
            moodTrend['trend'] ?? 'Estable',
            moodTrend['emoji'] ?? '➡️',
            _getAlertColor(moodTrend['color'] ?? 'blue'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String status, String emoji, Color color) {
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                status,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares para colores y styling
  List<Color> _getScoreGradientColors(int score) {
    if (score >= 80) return [Colors.green.shade400, Colors.green.shade600];
    if (score >= 60) return [Colors.blue.shade400, Colors.blue.shade600];
    if (score >= 40) return [Colors.orange.shade400, Colors.orange.shade600];
    return [Colors.red.shade400, Colors.red.shade600];
  }

  Color _getAlertColor(String colorName) {
    switch (colorName) {
      case 'red': return Colors.red;
      case 'orange': return Colors.orange;
      case 'yellow': return Colors.amber;
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      default: return Colors.grey;
    }
  }

  // Métodos adicionales para otras secciones del dashboard
  Widget _buildWellbeingComponentsChart(EnhancedAnalyticsProvider analytics) {
    // Implementar gráfico de componentes de bienestar
    return Container(
      height: 200,
      child: Center(child: Text('Gráfico de Componentes de Bienestar')),
    );
  }

  Widget _buildRecommendationsSection(List<Map<String, dynamic>> recommendations) {
    // Implementar sección de recomendaciones
    return Container(
      child: Center(child: Text('Recomendaciones Inteligentes')),
    );
  }

  Widget _buildGoalsProgressSection(EnhancedAnalyticsProvider analytics) {
    // Implementar sección de progreso de objetivos
    return Container(
      child: Center(child: Text('Progreso de Objetivos')),
    );
  }

  Widget _buildProgressTimelineSection(EnhancedAnalyticsProvider analytics) {
    // Implementar timeline de progreso
    return Container(
      child: Center(child: Text('Timeline de Progreso')),
    );
  }
}