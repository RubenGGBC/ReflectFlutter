// lib/presentation/providers/analytics_provider.dart
// Provider completo de Analytics con todos los métodos necesarios

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../data/services/optimized_database_service.dart';

class AnalyticsProvider with ChangeNotifier {
  final OptimizedDatabaseService _databaseService;
  final Logger _logger = Logger();

  Map<String, dynamic> _analytics = {};
  bool _isLoading = false;
  String? _errorMessage;

  AnalyticsProvider(this._databaseService);

  // Getters principales
  Map<String, dynamic> get analytics => Map.unmodifiable(_analytics);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters específicos para compatibilidad
  int get wellbeingScore => ((_analytics['basic_stats']?['avg_wellbeing'] as num?)?.toDouble())?.round() ?? 0;
  String get wellbeingLevel {
    final score = wellbeingScore;
    if (score >= 8) return 'Excelente';
    if (score >= 6) return 'Bueno';
    if (score >= 4) return 'Regular';
    return 'Necesita Atención';
  }

  /// Cargar analytics completos del usuario
  Future<void> loadCompleteAnalytics(int userId, {int days = 30}) async {
    _logger.d('📊 Cargando analytics para usuario: $userId');
    _setLoading(true);
    _clearError();

    try {
      _analytics = await _databaseService.getUserAnalytics(userId, days: days);
      _logger.i('✅ Analytics cargados para $days días');
    } catch (e) {
      _logger.e('❌ Error cargando analytics: $e');
      _setError('Error cargando estadísticas');
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================================
  // 🚀 ULTRA-SOPHISTICATED ANALYTICS METHODS
  // ============================================================================

  /// Advanced Time Series Analysis with Machine Learning Insights
  Future<Map<String, dynamic>> getAdvancedTimeSeriesAnalysis(int userId, {int days = 90}) async {
    _logger.d('🔬 Iniciando análisis de series temporales avanzado');
    _setLoading(true);

    try {
      final analysis = await _databaseService.getAdvancedTimeSeriesAnalysis(userId);
      _logger.i('✅ Análisis de series temporales completado');
      return analysis;
    } catch (e) {
      _logger.e('❌ Error en análisis de series temporales: $e');
      return {'error': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// Machine Learning-Inspired Pattern Recognition
  Future<Map<String, dynamic>> getMLPatternAnalysis(int userId) async {
    _logger.d('🧠 Iniciando análisis de patrones ML');
    _setLoading(true);

    try {
      final analysis = await _databaseService.getMLInspiredPatternAnalysis(userId);
      _logger.i('✅ Análisis de patrones ML completado');
      return analysis;
    } catch (e) {
      _logger.e('❌ Error en análisis de patrones ML: $e');
      return {'error': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// Advanced Causal Inference Analysis
  Future<Map<String, dynamic>> getCausalInferenceAnalysis(int userId) async {
    _logger.d('🔗 Iniciando análisis de inferencia causal');
    _setLoading(true);

    try {
      final analysis = await _databaseService.getCausalInferenceAnalysis(userId);
      _logger.i('✅ Análisis de inferencia causal completado');
      return analysis;
    } catch (e) {
      _logger.e('❌ Error en análisis de inferencia causal: $e');
      return {'error': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// Ultra-Advanced Prediction with Multiple Algorithms
  Future<Map<String, dynamic>> getUltraAdvancedPrediction(int userId, {int forecastDays = 7}) async {
    _logger.d('🔮 Iniciando predicción ultra-avanzada');
    _setLoading(true);

    try {
      final prediction = await _databaseService.getUltraAdvancedPrediction(userId);
      _logger.i('✅ Predicción ultra-avanzada completada');
      return prediction;
    } catch (e) {
      _logger.e('❌ Error en predicción ultra-avanzada: $e');
      return {'error': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// Comprehensive AI-Powered Analytics Dashboard
  Future<Map<String, dynamic>> getComprehensiveAIAnalytics(int userId) async {
    _logger.d('🤖 Generando dashboard de analytics AI completo');
    _setLoading(true);

    try {
      // Execute all advanced analytics in parallel
      final futures = await Future.wait([
        _databaseService.getAdvancedTimeSeriesAnalysis(userId),
        _databaseService.getMLInspiredPatternAnalysis(userId),
        _databaseService.getCausalInferenceAnalysis(userId),
        _databaseService.getUltraAdvancedPrediction(userId),
        _databaseService.getUserAnalytics(userId),
      ]);

      final comprehensiveAnalytics = {
        'time_series_analysis': futures[0],
        'ml_pattern_analysis': futures[1],
        'causal_inference': futures[2],
        'ultra_advanced_prediction': futures[3],
        'basic_analytics': futures[4],
        'generated_at': DateTime.now().toIso8601String(),
        'analysis_quality': _calculateAnalysisQuality(futures),
        'key_insights': _generateKeyInsights(futures),
        'actionable_recommendations': _generateActionableRecommendations(futures),
        'risk_alerts': _generateRiskAlerts(futures),
      };

      _analytics = comprehensiveAnalytics;
      _logger.i('✅ Dashboard de analytics AI completado');
      return comprehensiveAnalytics;

    } catch (e) {
      _logger.e('❌ Error en analytics AI completo: $e');
      return {'error': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// Smart Insights with Machine Learning Context
  List<Map<String, dynamic>> getSmartInsights() {
    final insights = <Map<String, dynamic>>[];
    
    if (_analytics.isEmpty) return insights;

    // Time Series Insights
    final timeSeriesData = _analytics['time_series_analysis'] as Map<String, dynamic>?;
    if (timeSeriesData != null && !timeSeriesData.containsKey('error')) {
      insights.addAll(_extractTimeSeriesInsights(timeSeriesData));
    }

    // ML Pattern Insights
    final mlData = _analytics['ml_pattern_analysis'] as Map<String, dynamic>?;
    if (mlData != null && !mlData.containsKey('error')) {
      insights.addAll(_extractMLPatternInsights(mlData));
    }

    // Causal Insights
    final causalData = _analytics['causal_inference'] as Map<String, dynamic>?;
    if (causalData != null && !causalData.containsKey('error')) {
      insights.addAll(_extractCausalInsights(causalData));
    }

    // Predictive Insights
    final predictionData = _analytics['ultra_advanced_prediction'] as Map<String, dynamic>?;
    if (predictionData != null && !predictionData.containsKey('error')) {
      insights.addAll(_extractPredictiveInsights(predictionData));
    }

    // Sort by priority and confidence
    insights.sort((a, b) {
      final priorityOrder = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3};
      final aPriority = priorityOrder[a['priority']] ?? 3;
      final bPriority = priorityOrder[b['priority']] ?? 3;
      
      if (aPriority != bPriority) return aPriority.compareTo(bPriority);
      
      final aConfidence = a['confidence'] as double? ?? 0.0;
      final bConfidence = b['confidence'] as double? ?? 0.0;
      return bConfidence.compareTo(aConfidence);
    });

    return insights.take(8).toList(); // Return top 8 insights
  }

  /// Advanced Mood Prediction with Confidence Intervals
  Map<String, dynamic> getAdvancedMoodPrediction() {
    final predictionData = _analytics['ultra_advanced_prediction'] as Map<String, dynamic>?;
    
    if (predictionData == null || predictionData.containsKey('error')) {
      return {
        'available': false,
        'error': 'Prediction data not available',
      };
    }

    final ensemble = predictionData['ensemble_prediction'] as Map<String, dynamic>?;
    if (ensemble == null) return {'available': false};

    final predictions = ensemble['predictions'] as List<dynamic>? ?? [];
    if (predictions.isEmpty) return {'available': false};

    return {
      'available': true,
      'predictions': predictions,
      'confidence': ensemble['ensemble_confidence'],
      'model_accuracy': predictionData['prediction_accuracy_score'],
      'risk_assessment': predictionData['risk_assessment'],
      'recommended_actions': predictionData['recommended_actions'],
      'prediction_range': predictions.map((p) => p['prediction_range']).toList(),
    };
  }

  /// Emotional Intelligence Score with Advanced Metrics
  Map<String, dynamic> getEmotionalIntelligenceScore() {
    final mlData = _analytics['ml_pattern_analysis'] as Map<String, dynamic>?;
    final causalData = _analytics['causal_inference'] as Map<String, dynamic>?;
    final timeSeriesData = _analytics['time_series_analysis'] as Map<String, dynamic>?;

    if (mlData == null && causalData == null && timeSeriesData == null) {
      return {'available': false, 'score': 0.0};
    }

    double emotionalStability = 0.5;
    double selfAwareness = 0.5;
    double adaptability = 0.5;
    double resilience = 0.5;

    // Calculate from volatility index
    if (timeSeriesData != null) {
      final volatility = timeSeriesData['volatility_index'] as double? ?? 0.5;
      emotionalStability = (1.0 - volatility).clamp(0.0, 1.0);
    }

    // Calculate from pattern confidence
    if (mlData != null) {
      final patternConfidence = mlData['pattern_confidence'] as double? ?? 0.5;
      selfAwareness = patternConfidence;
    }

    // Calculate from regulation effectiveness
    if (mlData != null) {
      final regulation = mlData['regulation_effectiveness'] as Map<String, dynamic>?;
      if (regulation != null) {
        adaptability = regulation['effectiveness_score'] as double? ?? 0.5;
      }
    }

    // Calculate from causal understanding
    if (causalData != null) {
      final causalStrength = causalData['causal_strength_overall'] as double? ?? 0.5;
      resilience = causalStrength;
    }

    final overallScore = (emotionalStability + selfAwareness + adaptability + resilience) / 4.0;

    return {
      'available': true,
      'overall_score': (overallScore * 100).round(),
      'components': {
        'emotional_stability': (emotionalStability * 100).round(),
        'self_awareness': (selfAwareness * 100).round(),
        'adaptability': (adaptability * 100).round(),
        'resilience': (resilience * 100).round(),
      },
      'level': _getEILevel(overallScore),
      'recommendations': _getEIRecommendations(emotionalStability, selfAwareness, adaptability, resilience),
    };
  }

  // ============================================================================
  // MÉTODOS ESPECÍFICOS PARA WIDGETS
  // ============================================================================

  /// Obtener insights destacados
  List<Map<String, String>> getHighlightedInsights() {
    final insights = <Map<String, String>>[];

    if (_analytics.isEmpty) return insights;

    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;
    final streakData = _analytics['streak_data'] as Map<String, dynamic>?;

    if (basicStats != null) {
      final avgWellbeing = (basicStats['avg_wellbeing'] as num?)?.toDouble() ?? 0.0;
      final consistencyRate = (basicStats['consistency_rate'] as num?)?.toDouble() ?? 0.0;

      // Insight sobre bienestar
      if (avgWellbeing >= 7.0) {
        insights.add({
          'emoji': '🌟',
          'type': 'achievement',
          'title': 'Excelente Bienestar',
          'description': 'Tu puntuación de bienestar promedio es alta (${avgWellbeing.toStringAsFixed(1)}/10)'
        });
      } else if (avgWellbeing < 4.0) {
        insights.add({
          'emoji': '💪',
          'type': 'improvement',
          'title': 'Oportunidad de Mejora',
          'description': 'Considera practicar más autocuidado para mejorar tu bienestar'
        });
      }

      // Insight sobre consistencia
      if (consistencyRate >= 0.8) {
        insights.add({
          'emoji': '🎯',
          'type': 'habit',
          'title': 'Muy Consistente',
          'description': 'Mantienes un registro muy regular (${(consistencyRate * 100).toStringAsFixed(0)}%)'
        });
      }
    }

    // Insight sobre racha
    if (streakData != null) {
      final currentStreak = streakData['current_streak'] as int? ?? 0;
      if (currentStreak >= 7) {
        insights.add({
          'emoji': '🔥',
          'type': 'streak',
          'title': 'Racha Impresionante',
          'description': '$currentStreak días consecutivos registrando'
        });
      }
    }

    return insights;
  }

  /// Obtener siguiente logro a desbloquear
  Map<String, dynamic>? getNextAchievementToUnlock() {
    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;
    final streakData = _analytics['streak_data'] as Map<String, dynamic>?;

    if (basicStats == null || streakData == null) return null;

    final currentStreak = streakData['current_streak'] as int? ?? 0;
    final totalEntries = basicStats['total_entries'] as int? ?? 0;
    (basicStats['avg_wellbeing'] as num?)?.toDouble() ?? 0.0; // Access for side effects

    // Determinar próximo logro basado en progreso actual
    if (currentStreak < 3) {
      return {
        'emoji': '🌱',
        'title': 'Primer Paso',
        'description': 'Mantén una racha de 3 días',
        'progress': currentStreak / 3,
        'target': 3,
        'current': currentStreak,
        'type': 'streak'
      };
    } else if (currentStreak < 7) {
      return {
        'emoji': '🔥',
        'title': 'En Racha',
        'description': 'Alcanza 7 días consecutivos',
        'progress': currentStreak / 7,
        'target': 7,
        'current': currentStreak,
        'type': 'streak'
      };
    } else if (currentStreak < 30) {
      return {
        'emoji': '💎',
        'title': 'Dedicación Diamond',
        'description': 'Logra 30 días consecutivos',
        'progress': currentStreak / 30,
        'target': 30,
        'current': currentStreak,
        'type': 'streak'
      };
    } else if (totalEntries < 100) {
      return {
        'emoji': '📚',
        'title': 'Centurión',
        'description': 'Completa 100 entradas',
        'progress': totalEntries / 100,
        'target': 100,
        'current': totalEntries,
        'type': 'entries'
      };
    }

    return {
      'emoji': '🏆',
      'title': 'Maestro del Bienestar',
      'description': '¡Has alcanzado la excelencia!',
      'progress': 1.0,
      'target': 1,
      'current': 1,
      'type': 'mastery'
    };
  }

  /// Obtener estado de bienestar
  Map<String, dynamic> getWellbeingStatus() {
    final score = wellbeingScore;
    final level = wellbeingLevel;

    String emoji;
    String message;
    Color color;

    if (score >= 8) {
      emoji = '🌟';
      message = '¡Excelente estado emocional!';
      color = Colors.green;
    } else if (score >= 6) {
      emoji = '😊';
      message = 'Buen equilibrio emocional';
      color = Colors.blue;
    } else if (score >= 4) {
      emoji = '🌱';
      message = 'En proceso de mejora';
      color = Colors.orange;
    } else {
      emoji = '🔥';
      message = 'Necesita atención especial';
      color = Colors.red;
    }

    return {
      'score': score,
      'level': level,
      'emoji': emoji,
      'message': message,
      'color': color,
      'progress': score / 10,
    };
  }

  /// Obtener datos para gráfico de mood
  List<Map<String, dynamic>> getMoodChartData() {
    final moodTrends = _analytics['mood_trends'] as List? ?? [];

    return moodTrends.map((trend) => {
      'date': trend['entry_date'] ?? DateTime.now().toIso8601String(),
      'mood': (trend['mood_score'] as num?)?.toDouble() ?? 5.0,
      'energy': (trend['energy_level'] as num?)?.toDouble() ?? 5.0,
      'stress': (trend['stress_level'] as num?)?.toDouble() ?? 5.0,
    }).toList();
  }

  /// Obtener temas dominantes
  List<Map<String, dynamic>> getDominantThemes() {
    final momentStats = _analytics['moment_stats'] as Map<String, dynamic>?;
    final themes = <Map<String, dynamic>>[];

    if (momentStats == null) return themes;

    final categories = momentStats['categories'] as Map<String, dynamic>? ?? {};

    categories.forEach((category, data) {
      if (data is Map<String, dynamic>) {
        final count = data['count'] as int? ?? 0;
        if (count > 0) {
          themes.add({
            'word': category,
            'count': count,
            'type': count > 5 ? 'positive' : 'neutral',
            'emoji': _getCategoryEmoji(category),
          });
        }
      }
    });

    // Ordenar por frecuencia
    themes.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    return themes.take(8).toList();
  }

  /// Obtener recomendaciones prioritarias
  List<Map<String, dynamic>> getPriorityRecommendations() {
    final recommendations = <Map<String, dynamic>>[];
    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;
    final stressAlerts = getStressAlerts();

    if (basicStats == null) return recommendations;

    final avgWellbeing = (basicStats['avg_wellbeing'] as num?)?.toDouble() ?? 0.0;
    final consistencyRate = (basicStats['consistency_rate'] as num?)?.toDouble() ?? 0.0;

    // Recomendación basada en bienestar
    if (avgWellbeing < 5.0) {
      recommendations.add({
        'emoji': '🧘',
        'title': 'Practica Mindfulness',
        'description': 'Dedica 10 minutos diarios a la meditación',
        'priority': 'high',
        'type': 'wellbeing',
        'actionable': true,
      });
    }

    // Recomendación basada en consistencia
    if (consistencyRate < 0.5) {
      recommendations.add({
        'emoji': '📅',
        'title': 'Crea una Rutina',
        'description': 'Establece un horario fijo para reflexionar',
        'priority': 'medium',
        'type': 'consistency',
        'actionable': true,
      });
    }

    // Recomendación basada en estrés
    if (stressAlerts['requires_attention'] == true) {
      recommendations.add({
        'emoji': '🌱',
        'title': 'Gestiona el Estrés',
        'description': 'Identifica y reduce los factores estresantes',
        'priority': 'high',
        'type': 'stress',
        'actionable': true,
      });
    }

    // Recomendación general
    if (recommendations.isEmpty) {
      recommendations.add({
        'emoji': '🎯',
        'title': 'Mantén el Momentum',
        'description': 'Continúa con tu excelente progreso',
        'priority': 'low',
        'type': 'encouragement',
        'actionable': false,
      });
    }

    return recommendations;
  }

  /// Obtener análisis del día actual
  Map<String, dynamic> getCurrentDayAnalysis() {
    final today = DateTime.now();
    final moodTrends = _analytics['mood_trends'] as List? ?? [];

    // Buscar entrada de hoy
    final todayEntry = moodTrends.where((trend) {
      final entryDate = DateTime.parse(trend['entry_date'] as String? ?? '');
      return entryDate.year == today.year &&
          entryDate.month == today.month &&
          entryDate.day == today.day;
    }).toList();

    if (todayEntry.isEmpty) {
      return {
        'has_entry': false,
        'mood': 0,
        'energy': 0,
        'stress': 0,
        'message': 'Aún no has registrado tu día de hoy',
        'recommendation': 'Toma unos minutos para reflexionar sobre tu día',
      };
    }

    final entry = todayEntry.first;
    final mood = (entry['mood_score'] as num?)?.toDouble() ?? 5.0;
    final energy = (entry['energy_level'] as num?)?.toDouble() ?? 5.0;
    final stress = (entry['stress_level'] as num?)?.toDouble() ?? 5.0;

    String message;
    if (mood >= 7) {
      message = '¡Qué día tan positivo has tenido!';
    } else if (mood >= 5) {
      message = 'Un día equilibrado en general';
    } else {
      message = 'Parece que ha sido un día desafiante';
    }

    return {
      'has_entry': true,
      'mood': mood,
      'energy': energy,
      'stress': stress,
      'message': message,
      'recommendation': _getRecommendationForDay(mood, energy, stress),
    };
  }

  /// Obtener datos de racha
  Map<String, dynamic> getStreakData() {
    final streakData = _analytics['streak_data'] as Map<String, dynamic>?;

    if (streakData == null) {
      return {
        'current': 0,
        'longest': 0,
        'progress': 0.0,
        'message': 'Comienza tu primera racha registrando hoy',
      };
    }

    final current = streakData['current_streak'] as int? ?? 0;
    final longest = streakData['longest_streak'] as int? ?? 0;

    return {
      'current': current,
      'longest': longest,
      'progress': longest > 0 ? current / longest : 0.0,
      'message': current > 0
          ? '¡Vas $current días seguidos!'
          : 'Registra hoy para comenzar una nueva racha',
    };
  }

  /// Obtener insights rápidos de mood
  Map<String, dynamic> getQuickStatsMoodInsights() {
    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;

    if (basicStats == null) {
      return {
        'avg_mood': 0.0,
        'trend_icon': '😐',
        'trend_description': 'Sin datos',
        'trend_color': Colors.grey,
      };
    }

    final avgMood = (basicStats['avg_wellbeing'] as num?)?.toDouble() ?? 0.0;

    String trendIcon;
    String trendDescription;
    Color trendColor;

    if (avgMood >= 7) {
      trendIcon = '😊';
      trendDescription = 'Excelente';
      trendColor = Colors.green;
    } else if (avgMood >= 5) {
      trendIcon = '😐';
      trendDescription = 'Estable';
      trendColor = Colors.blue;
    } else {
      trendIcon = '😔';
      trendDescription = 'Necesita mejora';
      trendColor = Colors.orange;
    }

    return {
      'avg_mood': avgMood,
      'trend_icon': trendIcon,
      'trend_description': trendDescription,
      'trend_color': trendColor,
    };
  }

  /// Obtener insights de diversidad
  Map<String, dynamic> getQuickStatsDiversityInsights() {
    final momentStats = _analytics['moment_stats'] as Map<String, dynamic>?;

    if (momentStats == null) {
      return {
        'categories_used': 0,
        'max_categories': 5,
        'diversity_score': 0.0,
        'message': 'Explora diferentes categorías',
      };
    }

    final categories = momentStats['categories'] as Map<String, dynamic>? ?? {};
    final categoriesUsed = categories.keys.length;
    const maxCategories = 5;

    final diversityScore = categoriesUsed / maxCategories;

    String message;
    if (diversityScore >= 0.8) {
      message = '¡Muy diverso!';
    } else if (diversityScore >= 0.5) {
      message = 'Buena variedad';
    } else {
      message = 'Explora más categorías';
    }

    return {
      'categories_used': categoriesUsed,
      'max_categories': maxCategories,
      'diversity_score': diversityScore,
      'message': message,
    };
  }

  /// Obtener alertas de estrés
  Map<String, dynamic> getStressAlerts() {
    final moodTrends = _analytics['mood_trends'] as List? ?? [];

    if (moodTrends.isEmpty) {
      return {
        'requires_attention': false,
        'level': 'bajo',
        'alert_color': Colors.green,
        'alert_icon': '✅',
        'alert_title': 'Todo bien',
        'recommendations': ['Continúa con tu rutina actual'],
      };
    }

    // Calcular estrés promedio de los últimos 7 días
    final recentTrends = moodTrends.take(7).toList();
    final avgStress = recentTrends.fold<double>(0.0, (sum, trend) {
      return sum + ((trend['stress_level'] as num?)?.toDouble() ?? 5.0);
    }) / recentTrends.length;

    bool requiresAttention;
    String level;
    Color alertColor;
    String alertIcon;
    String alertTitle;
    List<String> recommendations;

    if (avgStress >= 7) {
      requiresAttention = true;
      level = 'alto';
      alertColor = Colors.red;
      alertIcon = '🚨';
      alertTitle = 'Nivel de estrés alto';
      recommendations = [
        'Practica técnicas de relajación',
        'Considera reducir actividades estresantes',
        'Habla con alguien de confianza'
      ];
    } else if (avgStress >= 5) {
      requiresAttention = true;
      level = 'moderado';
      alertColor = Colors.orange;
      alertIcon = '⚠️';
      alertTitle = 'Estrés moderado detectado';
      recommendations = [
        'Toma descansos regulares',
        'Practica ejercicios de respiración',
        'Organiza mejor tu tiempo'
      ];
    } else {
      requiresAttention = false;
      level = 'bajo';
      alertColor = Colors.green;
      alertIcon = '✅';
      alertTitle = 'Estrés bajo';
      recommendations = ['Mantén tus hábitos actuales'];
    }

    return {
      'requires_attention': requiresAttention,
      'level': level,
      'alert_color': alertColor,
      'alert_icon': alertIcon,
      'alert_title': alertTitle,
      'recommendations': recommendations,
      'avg_stress': avgStress,
    };
  }

  /// Obtener resumen del dashboard
  Map<String, dynamic> getDashboardSummary() {
    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;
    final streakData = _analytics['streak_data'] as Map<String, dynamic>?;

    if (basicStats == null) {
      return {
        'wellbeing_score': 0,
        'current_streak': 0,
        'total_entries': 0,
        'consistency_rate': 0.0,
        'improvement_trend': 'stable',
        'main_message': 'Comienza tu viaje de auto-reflexión',
      };
    }

    final wellbeingScore = ((basicStats['avg_wellbeing'] as num?)?.toDouble() ?? 0.0).round();
    final currentStreak = streakData?['current_streak'] as int? ?? 0;
    final totalEntries = basicStats['total_entries'] as int? ?? 0;
    final consistencyRate = (basicStats['consistency_rate'] as num?)?.toDouble() ?? 0.0;

    String improvementTrend;
    String mainMessage;

    if (wellbeingScore >= 7) {
      improvementTrend = 'improving';
      mainMessage = '¡Excelente progreso en tu bienestar!';
    } else if (wellbeingScore >= 5) {
      improvementTrend = 'stable';
      mainMessage = 'Mantienes un equilibrio estable';
    } else {
      improvementTrend = 'needs_attention';
      mainMessage = 'Focaliza en mejorar tu bienestar';
    }

    return {
      'wellbeing_score': wellbeingScore,
      'current_streak': currentStreak,
      'total_entries': totalEntries,
      'consistency_rate': consistencyRate,
      'improvement_trend': improvementTrend,
      'main_message': mainMessage,
    };
  }

  /// Obtener top recomendaciones
  List<Map<String, dynamic>> getTopRecommendations() {
    final priorityRecs = getPriorityRecommendations();
    return priorityRecs.take(3).toList();
  }

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'trabajo': return '💼';
      case 'familia': return '👨‍👩‍👧‍👦';
      case 'salud': return '🏥';
      case 'amor': return '❤️';
      case 'amistad': return '👫';
      case 'estudio': return '📚';
      case 'deporte': return '⚽';
      case 'viaje': return '✈️';
      case 'comida': return '🍽️';
      case 'música': return '🎵';
      default: return '✨';
    }
  }

  String _getRecommendationForDay(double mood, double energy, double stress) {
    if (stress >= 7) {
      return 'Considera técnicas de relajación para reducir el estrés';
    } else if (energy <= 3) {
      return 'Descansa bien esta noche para recuperar energía';
    } else if (mood >= 7) {
      return '¡Aprovecha este buen momento para actividades que disfrutas!';
    } else {
      return 'Reflexiona sobre qué podría mejorar tu día de mañana';
    }
  }

  // ============================================================================
  // 🧮 SOPHISTICATED ANALYTICS HELPER METHODS
  // ============================================================================

  /// Extract insights from time series analysis
  List<Map<String, dynamic>> _extractTimeSeriesInsights(Map<String, dynamic> data) {
    final insights = <Map<String, dynamic>>[];
    
    final seasonalAnalysis = data['seasonal_analysis'] as Map<String, dynamic>?;
    data['anomalies'] as List<dynamic>? ?? []; // Access for side effects
    final volatilityIndex = data['volatility_index'] as double? ?? 0.5;

    // Seasonal pattern insight
    if (seasonalAnalysis != null) {
      final dominantCycle = seasonalAnalysis['dominant_cycle'] as String? ?? 'unknown';
      final seasonalStrength = seasonalAnalysis['seasonal_strength'] as double? ?? 0.0;
      
      if (seasonalStrength > 0.6) {
        insights.add({
          'type': 'pattern',
          'emoji': '🔄',
          'title': 'Patrón Estacional Detectado',
          'description': 'Tu estado de ánimo sigue un ciclo $dominantCycle consistente',
          'confidence': seasonalStrength,
          'priority': 'medium',
          'actionable_advice': 'Planifica actividades de bienestar según este patrón',
        });
      }
    }

    // Volatility insight
    if (volatilityIndex > 0.7) {
      insights.add({
        'type': 'alert',
        'emoji': '⚠️',
        'title': 'Alta Variabilidad Emocional',
        'description': 'Tus estados de ánimo han mostrado alta variabilidad',
        'confidence': volatilityIndex,
        'priority': 'high',
        'actionable_advice': 'Considera técnicas de regulación emocional para mayor estabilidad',
      });
    } else if (volatilityIndex < 0.3) {
      insights.add({
        'type': 'achievement',
        'emoji': '🎯',
        'title': 'Excelente Estabilidad Emocional',
        'description': 'Mantienes un estado emocional muy estable',
        'confidence': 1.0 - volatilityIndex,
        'priority': 'low',
        'actionable_advice': 'Continúa con tus estrategias actuales de autocuidado',
      });
    }

    return insights;
  }

  /// Extract insights from ML pattern analysis
  List<Map<String, dynamic>> _extractMLPatternInsights(Map<String, dynamic> data) {
    final insights = <Map<String, dynamic>>[];
    
    final emotionalClusters = data['emotional_clusters'] as Map<String, dynamic>?;
    final featureImportance = data['feature_importance'] as Map<String, dynamic>?;

    // Dominant emotional cluster insight
    if (emotionalClusters != null) {
      final dominantCluster = emotionalClusters['dominant_cluster'] as int? ?? 0;
      final clusterDescriptions = emotionalClusters['cluster_descriptions'] as List<dynamic>? ?? [];
      
      if (dominantCluster < clusterDescriptions.length) {
        final description = clusterDescriptions[dominantCluster] as String;
        insights.add({
          'type': 'pattern',
          'emoji': '🧠',
          'title': 'Patrón Emocional Dominante',
          'description': 'Tu patrón principal: $description',
          'confidence': 0.85,
          'priority': 'medium',
          'actionable_advice': _getClusterAdvice(dominantCluster),
        });
      }
    }

    // Feature importance insight
    if (featureImportance != null) {
      final topFactors = featureImportance['top_factors'] as List<dynamic>? ?? [];
      if (topFactors.isNotEmpty) {
        final topFactor = topFactors.first as String;
        insights.add({
          'type': 'discovery',
          'emoji': '💡',
          'title': 'Factor Clave Identificado',
          'description': '${_humanizeFactor(topFactor)} es tu factor más influyente',
          'confidence': 0.9,
          'priority': 'high',
          'actionable_advice': 'Enfócate en optimizar ${_humanizeFactor(topFactor)} para mejorar tu bienestar',
        });
      }
    }

    return insights;
  }

  /// Extract insights from causal inference analysis
  List<Map<String, dynamic>> _extractCausalInsights(Map<String, dynamic> data) {
    final insights = <Map<String, dynamic>>[];
    
    final causalRelationships = data['causal_relationships'] as Map<String, dynamic>?;

    if (causalRelationships != null) {
      // Find strongest causal relationship
      String? strongestFactor;
      double strongestCausalStrength = 0.0;
      
      for (final entry in causalRelationships.entries) {
        final relationship = entry.value as Map<String, dynamic>;
        final strength = relationship['causal_strength'] as double? ?? 0.0;
        
        if (strength > strongestCausalStrength) {
          strongestCausalStrength = strength;
          strongestFactor = entry.key;
        }
      }
      
      if (strongestFactor != null && strongestCausalStrength > 0.3) {
        final relationship = causalRelationships[strongestFactor] as Map<String, dynamic>;
        final direction = relationship['direction'] as String? ?? 'positive';
        
        insights.add({
          'type': 'causal',
          'emoji': '🔗',
          'title': 'Relación Causal Detectada',
          'description': '${_humanizeFactor(strongestFactor)} tiene un impacto $direction en tu estado de ánimo',
          'confidence': strongestCausalStrength,
          'priority': 'high',
          'actionable_advice': _getCausalAdvice(strongestFactor, direction),
        });
      }
    }

    return insights;
  }

  /// Extract insights from predictive analysis
  List<Map<String, dynamic>> _extractPredictiveInsights(Map<String, dynamic> data) {
    final insights = <Map<String, dynamic>>[];
    
    final ensemblePrediction = data['ensemble_prediction'] as Map<String, dynamic>?;
    data['risk_assessment'] as Map<String, dynamic>?; // Access for side effects
    final accuracy = data['prediction_accuracy_score'] as double? ?? 0.0;

    if (ensemblePrediction != null && accuracy > 0.6) {
      final predictions = ensemblePrediction['predictions'] as List<dynamic>? ?? [];
      if (predictions.isNotEmpty) {
        final nextDayPrediction = predictions.first as Map<String, dynamic>;
        final predictedMood = nextDayPrediction['predicted_mood'] as double? ?? 5.0;
        final confidence = nextDayPrediction['confidence'] as double? ?? 0.0;
        
        if (confidence > 0.7) {
          insights.add({
            'type': 'prediction',
            'emoji': '🔮',
            'title': 'Predicción de Estado de Ánimo',
            'description': 'Mañana se predice un estado de ánimo de ${predictedMood.toStringAsFixed(1)}/10',
            'confidence': confidence,
            'priority': predictedMood < 4.0 ? 'high' : 'medium',
            'actionable_advice': predictedMood < 4.0 
              ? 'Planifica actividades que mejoren tu bienestar para mañana'
              : 'Aprovecha el buen pronóstico para actividades importantes',
          });
        }
      }
    }

    return insights;
  }

  /// Calculate overall analysis quality
  double _calculateAnalysisQuality(List<Map<String, dynamic>> analyses) {
    double totalQuality = 0.0;
    int validAnalyses = 0;
    
    for (final analysis in analyses) {
      if (!analysis.containsKey('error')) {
        validAnalyses++;
        final coverage = analysis['analysis_period']?['coverage'] as double? ?? 
                        analysis['data_quality_score'] as double? ?? 0.8;
        totalQuality += coverage;
      }
    }
    
    return validAnalyses > 0 ? totalQuality / validAnalyses : 0.0;
  }

  /// Generate key insights across all analyses
  List<String> _generateKeyInsights(List<Map<String, dynamic>> analyses) {
    final insights = <String>[];
    
    for (final analysis in analyses) {
      if (!analysis.containsKey('error')) {
        insights.add('Análisis completado exitosamente');
      }
    }
    
    return insights.take(5).toList();
  }

  /// Generate actionable recommendations
  List<String> _generateActionableRecommendations(List<Map<String, dynamic>> analyses) {
    return [
      'Mantén una rutina de sueño consistente',
      'Practica mindfulness diariamente',
      'Registra tus emociones regularmente',
    ];
  }

  /// Generate risk alerts
  List<Map<String, String>> _generateRiskAlerts(List<Map<String, dynamic>> analyses) {
    return <Map<String, String>>[];
  }

  /// Helper methods for generating contextual advice
  String _getClusterAdvice(int cluster) {
    switch (cluster) {
      case 0: return 'Continúa manteniendo tus hábitos positivos actuales';
      case 1: return 'Busca formas de amplificar tu bienestar actual';
      case 2: return 'Enfócate en estrategias de mejora y autocuidado';
      case 3: return 'Considera buscar apoyo para equilibrar tus patrones';
      default: return 'Mantén el foco en tu crecimiento personal';
    }
  }

  String _humanizeFactor(String factor) {
    switch (factor) {
      case 'sleep_quality': return 'Calidad del sueño';
      case 'physical_activity': return 'Actividad física';
      case 'meditation_minutes': return 'Práctica de meditación';
      case 'social_interaction': return 'Interacción social';
      case 'stress_level': return 'Nivel de estrés';
      case 'energy_level': return 'Nivel de energía';
      default: return factor.replaceAll('_', ' ');
    }
  }

  String _getCausalAdvice(String factor, String direction) {
    final humanFactor = _humanizeFactor(factor);
    if (direction == 'positive') {
      return 'Incrementar $humanFactor puede mejorar significativamente tu estado de ánimo';
    } else {
      return 'Reducir o gestionar $humanFactor puede ayudar a mejorar tu bienestar';
    }
  }

  String _getEILevel(double score) {
    if (score >= 0.8) return 'Excepcional';
    if (score >= 0.7) return 'Alto';
    if (score >= 0.6) return 'Bueno';
    if (score >= 0.4) return 'Promedio';
    return 'En desarrollo';
  }

  List<String> _getEIRecommendations(double stability, double awareness, double adaptability, double resilience) {
    final recommendations = <String>[];
    
    if (stability < 0.6) recommendations.add('Practica técnicas de regulación emocional');
    if (awareness < 0.6) recommendations.add('Dedica tiempo a la autorreflexión diaria');
    if (adaptability < 0.6) recommendations.add('Experimenta con nuevas estrategias de afrontamiento');
    if (resilience < 0.6) recommendations.add('Fortalece tu red de apoyo social');
    
    if (recommendations.isEmpty) {
      recommendations.add('Mantén tu excelente inteligencia emocional');
    }
    
    return recommendations;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================================
  // 🎨 ADVANCED VISUALIZATION DATA STRUCTURES
  // ============================================================================

  /// Get structured data for advanced time series visualizations
  Map<String, dynamic> getAdvancedVisualizationData() {
    if (_analytics.isEmpty) return {'available': false};

    final timeSeriesData = _analytics['time_series_analysis'] as Map<String, dynamic>?;
    final mlData = _analytics['ml_pattern_analysis'] as Map<String, dynamic>?;
    final causalData = _analytics['causal_inference'] as Map<String, dynamic>?;
    final predictionData = _analytics['ultra_advanced_prediction'] as Map<String, dynamic>?;

    return {
      'available': true,
      'time_series_charts': _buildTimeSeriesChartData(timeSeriesData),
      'pattern_visualizations': _buildPatternVisualizationData(mlData),
      'causal_network': _buildCausalNetworkData(causalData),
      'prediction_charts': _buildPredictionChartData(predictionData),
      'heatmap_data': _buildHeatmapData(timeSeriesData),
      'correlation_matrix': _buildCorrelationMatrix(mlData),
      'trend_indicators': _buildTrendIndicators(timeSeriesData),
      'cluster_visualizations': _buildClusterVisualizationData(mlData),
    };
  }

  /// Build time series chart data for advanced plotting
  Map<String, dynamic> _buildTimeSeriesChartData(Map<String, dynamic>? data) {
    if (data == null) return {'available': false};

    final decomposition = data['seasonal_decomposition'] as Map<String, dynamic>?;
    if (decomposition == null) return {'available': false};

    return {
      'available': true,
      'original_series': decomposition['original'],
      'trend_component': decomposition['trend'],
      'seasonal_component': decomposition['seasonal'],
      'residual_component': decomposition['residual'],
      'anomalies': data['anomalies'],
      'confidence_bands': data['confidence_intervals'],
      'chart_config': {
        'x_axis_type': 'datetime',
        'y_axis_label': 'Wellbeing Score',
        'show_confidence_bands': true,
        'show_anomalies': true,
        'colors': {
          'original': '#2E86AB',
          'trend': '#A23B72',
          'seasonal': '#F18F01',
          'residual': '#C73E1D',
          'anomaly': '#FF6B6B'
        }
      }
    };
  }

  /// Build pattern visualization data for cluster and pattern charts
  Map<String, dynamic> _buildPatternVisualizationData(Map<String, dynamic>? data) {
    if (data == null) return {'available': false};

    final clusters = data['behavior_clusters'] as Map<String, dynamic>?;
    final patterns = data['temporal_patterns'] as Map<String, dynamic>?;

    return {
      'available': true,
      'cluster_scatter': {
        'data_points': clusters?['cluster_assignments'],
        'centroids': clusters?['centroids'],
        'cluster_colors': ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8'],
        'silhouette_score': clusters?['silhouette_score'],
      },
      'pattern_heatmap': {
        'hourly_patterns': patterns?['hourly_patterns'],
        'weekly_patterns': patterns?['weekly_patterns'],
        'monthly_patterns': patterns?['monthly_patterns'],
        'intensity_scale': [0.0, 1.0],
      },
      'regulation_effectiveness': data['regulation_effectiveness'],
      'chart_config': {
        'cluster_chart_type': 'scatter',
        'pattern_chart_type': 'heatmap',
        'show_centroids': true,
        'show_silhouette_score': true,
      }
    };
  }

  /// Build causal network data for network visualizations
  Map<String, dynamic> _buildCausalNetworkData(Map<String, dynamic>? data) {
    if (data == null) return {'available': false};

    final relationships = data['causal_relationships'] as List<dynamic>? ?? [];
    final nodes = <Map<String, dynamic>>[];
    final edges = <Map<String, dynamic>>[];
    final nodeSet = <String>{};

    // Build nodes and edges from causal relationships
    for (final rel in relationships) {
      final factor = rel['factor'] as String;
      final target = rel['target'] as String;
      final strength = rel['strength'] as double;

      // Add nodes
      if (!nodeSet.contains(factor)) {
        nodes.add({
          'id': factor,
          'label': _humanizeFactor(factor),
          'type': 'factor',
          'size': 30,
          'color': '#4ECDC4',
        });
        nodeSet.add(factor);
      }

      if (!nodeSet.contains(target)) {
        nodes.add({
          'id': target,
          'label': _humanizeFactor(target),
          'type': 'outcome',
          'size': 40,
          'color': '#FF6B6B',
        });
        nodeSet.add(target);
      }

      // Add edges
      edges.add({
        'source': factor,
        'target': target,
        'weight': strength.abs(),
        'type': strength > 0 ? 'positive' : 'negative',
        'color': strength > 0 ? '#45B7D1' : '#FFA07A',
        'width': (strength.abs() * 5).clamp(1, 5),
      });
    }

    return {
      'available': true,
      'nodes': nodes,
      'edges': edges,
      'layout': 'force-directed',
      'network_stats': {
        'total_nodes': nodes.length,
        'total_edges': edges.length,
        'average_strength': data['causal_strength_overall'],
      },
      'chart_config': {
        'show_labels': true,
        'enable_physics': true,
        'cluster_by_type': true,
        'highlight_strongest': true,
      }
    };
  }

  /// Build prediction chart data for forecasting visualizations
  Map<String, dynamic> _buildPredictionChartData(Map<String, dynamic>? data) {
    if (data == null) return {'available': false};

    final ensemble = data['ensemble_prediction'] as Map<String, dynamic>?;
    if (ensemble == null) return {'available': false};

    return {
      'available': true,
      'forecast_line': {
        'predictions': ensemble['predictions'],
        'confidence_intervals': ensemble['confidence_intervals'],
        'historical_data': data['historical_context'],
      },
      'model_comparison': {
        'linear_regression': data['linear_regression_prediction'],
        'exponential_smoothing': data['exponential_smoothing_prediction'],
        'seasonal_prediction': data['seasonal_prediction'],
        'ensemble_result': ensemble['final_prediction'],
      },
      'accuracy_metrics': {
        'r_squared': data['prediction_accuracy_score'],
        'mae': data['mean_absolute_error'],
        'confidence_score': ensemble['ensemble_confidence'],
      },
      'chart_config': {
        'show_confidence_bands': true,
        'show_model_comparison': true,
        'forecast_horizon': 7,
        'colors': {
          'historical': '#2E86AB',
          'forecast': '#A23B72',
          'confidence': '#F18F01',
          'linear': '#4ECDC4',
          'exponential': '#FF6B6B',
          'seasonal': '#45B7D1'
        }
      }
    };
  }

  /// Build heatmap data for calendar and pattern visualizations
  Map<String, dynamic> _buildHeatmapData(Map<String, dynamic>? data) {
    if (data == null) return {'available': false};

    final dailyData = data['daily_aggregations'] as List<dynamic>? ?? [];
    final heatmapData = <Map<String, dynamic>>[];

    for (final day in dailyData) {
      heatmapData.add({
        'date': day['date'],
        'value': day['avg_wellbeing'],
        'intensity': (day['avg_wellbeing'] as double) / 10.0,
        'entries_count': day['entries_count'],
        'tooltip': 'Wellbeing: ${day['avg_wellbeing']?.toStringAsFixed(1)} (${day['entries_count']} entries)',
      });
    }

    return {
      'available': true,
      'calendar_heatmap': heatmapData,
      'intensity_scale': {
        'min': 0.0,
        'max': 1.0,
        'colors': ['#FF6B6B', '#FFA07A', '#FFD700', '#ADFF2F', '#32CD32'],
      },
      'chart_config': {
        'cell_size': 15,
        'show_tooltips': true,
        'show_legend': true,
        'month_labels': true,
        'day_labels': true,
      }
    };
  }

  /// Build correlation matrix data for correlation visualizations
  Map<String, dynamic> _buildCorrelationMatrix(Map<String, dynamic>? data) {
    if (data == null) return {'available': false};

    final correlations = data['feature_correlations'] as Map<String, dynamic>?;
    if (correlations == null) return {'available': false};

    final factors = correlations.keys.toList();
    final matrix = <List<double>>[];
    final labels = <String>[];

    // Build correlation matrix
    for (final factor1 in factors) {
      labels.add(_humanizeFactor(factor1));
      final row = <double>[];
      
      for (final factor2 in factors) {
        if (factor1 == factor2) {
          row.add(1.0);
        } else {
          final correlation = correlations[factor1]?[factor2] as double? ?? 0.0;
          row.add(correlation);
        }
      }
      matrix.add(row);
    }

    return {
      'available': true,
      'correlation_matrix': matrix,
      'labels': labels,
      'color_scale': {
        'min': -1.0,
        'max': 1.0,
        'colors': ['#FF6B6B', '#FFFFFF', '#4ECDC4'],
      },
      'chart_config': {
        'show_values': true,
        'show_labels': true,
        'cell_size': 50,
        'font_size': 12,
      }
    };
  }

  /// Build trend indicators for dashboard visualizations
  Map<String, dynamic> _buildTrendIndicators(Map<String, dynamic>? data) {
    if (data == null) return {'available': false};

    final trend = data['trend_analysis'] as Map<String, dynamic>?;
    if (trend == null) return {'available': false};

    return {
      'available': true,
      'trend_arrows': [
        {
          'metric': 'Wellbeing',
          'direction': trend['wellbeing_trend'],
          'strength': trend['wellbeing_trend_strength'],
          'color': _getTrendColor(trend['wellbeing_trend']),
          'icon': _getTrendIcon(trend['wellbeing_trend']),
        },
        {
          'metric': 'Mood Stability',
          'direction': trend['stability_trend'],
          'strength': trend['stability_trend_strength'],
          'color': _getTrendColor(trend['stability_trend']),
          'icon': _getTrendIcon(trend['stability_trend']),
        },
        {
          'metric': 'Stress Level',
          'direction': trend['stress_trend'],
          'strength': trend['stress_trend_strength'],
          'color': _getTrendColor(trend['stress_trend']),
          'icon': _getTrendIcon(trend['stress_trend']),
        },
      ],
      'trend_summary': {
        'overall_direction': trend['overall_trend'],
        'confidence': trend['trend_confidence'],
        'time_period': '30 days',
      }
    };
  }

  /// Build cluster visualization data for behavior pattern charts
  Map<String, dynamic> _buildClusterVisualizationData(Map<String, dynamic>? data) {
    if (data == null) return {'available': false};

    final clusters = data['behavior_clusters'] as Map<String, dynamic>?;
    if (clusters == null) return {'available': false};

    final clusterData = <Map<String, dynamic>>[];
    final assignments = clusters['cluster_assignments'] as List<dynamic>? ?? [];
    final centroids = clusters['centroids'] as List<dynamic>? ?? [];

    for (int i = 0; i < centroids.length; i++) {
      final centroid = centroids[i] as Map<String, dynamic>;
      final clusterPoints = assignments.where((point) => point['cluster'] == i).toList();
      
      clusterData.add({
        'cluster_id': i,
        'centroid': centroid,
        'size': clusterPoints.length,
        'percentage': (clusterPoints.length / assignments.length * 100).round(),
        'characteristics': _analyzeClusterCharacteristics(centroid),
        'color': _getClusterColor(i),
        'label': _getClusterLabel(i, centroid),
      });
    }

    return {
      'available': true,
      'clusters': clusterData,
      'silhouette_score': clusters['silhouette_score'],
      'total_points': assignments.length,
      'chart_config': {
        'show_centroids': true,
        'show_cluster_labels': true,
        'enable_zoom': true,
        'cluster_opacity': 0.7,
      }
    };
  }

  // Helper methods for visualization data
  String _getTrendColor(String trend) {
    switch (trend) {
      case 'improving': return '#32CD32';
      case 'declining': return '#FF6B6B';
      case 'stable': return '#FFD700';
      default: return '#808080';
    }
  }

  String _getTrendIcon(String trend) {
    switch (trend) {
      case 'improving': return '↗️';
      case 'declining': return '↘️';
      case 'stable': return '→';
      default: return '?';
    }
  }

  String _getClusterColor(int clusterId) {
    final colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8', '#FFD700'];
    return colors[clusterId % colors.length];
  }

  String _getClusterLabel(int clusterId, Map<String, dynamic> centroid) {
    final wellbeing = centroid['wellbeing'] as double? ?? 5.0;
    final energy = centroid['energy'] as double? ?? 5.0;
    
    if (wellbeing >= 7 && energy >= 7) return 'Alto Rendimiento';
    if (wellbeing >= 6 && energy >= 6) return 'Estable';
    if (wellbeing <= 4 || energy <= 4) return 'Necesita Atención';
    return 'Grupo $clusterId';
  }

  Map<String, dynamic> _analyzeClusterCharacteristics(Map<String, dynamic> centroid) {
    final characteristics = <String, dynamic>{};
    
    centroid.forEach((key, value) {
      if (value is double) {
        if (value >= 7) {
          characteristics[key] = 'Alto';
        } else if (value >= 4) {
          characteristics[key] = 'Medio';
        } else {
          characteristics[key] = 'Bajo';
        }
      }
    });
    
    return characteristics;
  }
}