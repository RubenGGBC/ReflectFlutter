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
  int get wellbeingScore => (_analytics['basic_stats']?['avg_wellbeing'] as double?)?.round() ?? 0;
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
  // MÉTODOS ESPECÍFICOS PARA WIDGETS
  // ============================================================================

  /// Obtener insights destacados
  List<Map<String, String>> getHighlightedInsights() {
    final insights = <Map<String, String>>[];

    if (_analytics.isEmpty) return insights;

    final basicStats = _analytics['basic_stats'] as Map<String, dynamic>?;
    final streakData = _analytics['streak_data'] as Map<String, dynamic>?;

    if (basicStats != null) {
      final avgWellbeing = basicStats['avg_wellbeing'] as double? ?? 0.0;
      final consistencyRate = basicStats['consistency_rate'] as double? ?? 0.0;

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
    final avgWellbeing = basicStats['avg_wellbeing'] as double? ?? 0.0;

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
      'mood': trend['mood_score'] ?? 5.0,
      'energy': trend['energy_level'] ?? 5.0,
      'stress': trend['stress_level'] ?? 5.0,
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

    final avgWellbeing = basicStats['avg_wellbeing'] as double? ?? 0.0;
    final consistencyRate = basicStats['consistency_rate'] as double? ?? 0.0;

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
    final mood = entry['mood_score'] as double? ?? 5.0;
    final energy = entry['energy_level'] as double? ?? 5.0;
    final stress = entry['stress_level'] as double? ?? 5.0;

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
          ? '¡Vas ${current} días seguidos!'
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

    final avgMood = basicStats['avg_wellbeing'] as double? ?? 0.0;

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
      return sum + (trend['stress_level'] as double? ?? 5.0);
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

    final wellbeingScore = (basicStats['avg_wellbeing'] as double? ?? 0.0).round();
    final currentStreak = streakData?['current_streak'] as int? ?? 0;
    final totalEntries = basicStats['total_entries'] as int? ?? 0;
    final consistencyRate = basicStats['consistency_rate'] as double? ?? 0.0;

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
}