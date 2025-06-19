import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../data/services/database_service.dart';

class AnalyticsProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  final Logger _logger = Logger();

  // Estados de carga
  bool _isLoading = false;
  String? _errorMessage;

  // Datos básicos (compatibilidad con widgets existentes)
  Map<String, dynamic> _basicStats = {};
  List<Map<String, String>> _insights = [];
  int _wellbeingScore = 0;
  String _wellbeingLevel = 'Iniciando';

  // Datos analíticos mejorados NUEVOS
  Map<String, dynamic> _enhancedWellbeingScore = {};
  Map<String, dynamic> _streakAnalysis = {};
  Map<String, dynamic> _moodAnalysis = {};
  Map<String, dynamic> _consistencyAnalysis = {};
  Map<String, dynamic> _diversityAnalysis = {};
  Map<String, dynamic> _stressPattern = {};

  AnalyticsProvider(this._databaseService);

  // Getters básicos
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get wellbeingScore => _wellbeingScore;
  String get wellbeingLevel => _wellbeingLevel;

  // Getters nuevos mejorados
  Map<String, dynamic> get enhancedWellbeingScore => _enhancedWellbeingScore;
  Map<String, dynamic> get streakAnalysis => _streakAnalysis;
  Map<String, dynamic> get moodAnalysis => _moodAnalysis;
  Map<String, dynamic> get stressPattern => _stressPattern;
  // NUEVO: Getter para diversidad, requerido por el dashboard
  Map<String, dynamic> get diversityAnalysis => _diversityAnalysis;


  /// 🚀 Cargar análisis completo MEJORADO
  Future<void> loadCompleteAnalytics(int userId) async {
    _setLoading(true);
    _clearError();

    try {
      _logger.i('🔍 Cargando análisis mejorado para usuario: $userId');

      // Cargar datos básicos (compatibilidad)
      final basicStats = await _databaseService.getUserComprehensiveStatistics(userId);

      // Cargar análisis mejorados NUEVOS
      final results = await Future.wait([
        _databaseService.getEnhancedWellbeingScore(userId),
        _databaseService.getAdvancedStreakAnalysis(userId),
        _databaseService.getDetailedMoodAnalysis(userId),
        _databaseService.getConsistencyAnalysis(userId),
        _databaseService.getDiversityAnalysis(userId),
        _databaseService.detectStressPattern(userId),
      ]);

      _basicStats = basicStats;
      _enhancedWellbeingScore = results[0];
      _streakAnalysis = results[1];
      _moodAnalysis = results[2];
      _consistencyAnalysis = results[3];
      _diversityAnalysis = results[4];
      _stressPattern = results[5];

      // Actualizar datos básicos con los mejorados
      _wellbeingScore = (_enhancedWellbeingScore['total_score'] as num? ?? 0).toInt();
      _wellbeingLevel = _enhancedWellbeingScore['level']?.toString() ?? 'Iniciando';
      _insights = _generateBasicInsights(basicStats);

      _logger.i('✅ Análisis cargado. Score: $_wellbeingScore ($_wellbeingLevel)');

    } catch (e) {
      _logger.e('❌ Error cargando análisis: $e');
      _setError('Error cargando análisis del usuario');

      // Fallback con datos básicos
      try {
        final basicStats = await _databaseService.getUserComprehensiveStatistics(userId);
        _basicStats = basicStats;
        _wellbeingScore = _calculateBasicWellbeingScore(basicStats);
        _wellbeingLevel = _calculateWellbeingLevel(_wellbeingScore);
        _insights = _generateBasicInsights(basicStats);
      } catch (fallbackError) {
        _logger.e('❌ Error en fallback: $fallbackError');
      }
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================================
  // MÉTODOS PARA EL NUEVO DASHBOARD (SECCIÓN NUEVA)
  // ============================================================================

  /// **NUEVO**: Obtiene los datos de mood con el formato que espera el Quick Stat.
  Map<String, dynamic> getQuickStatsMoodInsights() {
    final avgMood = (_moodAnalysis['avg_mood'] as num?)?.toDouble() ?? 0.0;
    final trend = _moodAnalysis['mood_trend']?.toString() ?? 'estable';
    String trendIcon;
    String trendDescription;
    Color trendColor;

    switch (trend) {
      case 'mejorando':
        trendIcon = '🔼';
        trendDescription = 'Mejorando';
        trendColor = Colors.green.shade400;
        break;
      case 'empeorando':
        trendIcon = '🔽';
        trendDescription = 'Empeorando';
        trendColor = Colors.red.shade400;
        break;
      default:
        trendIcon = '▶️';
        trendDescription = 'Estable';
        trendColor = Colors.blue.shade400;
    }

    return {
      'trend_icon': trendIcon,
      'avg_mood': avgMood,
      'trend_description': trendDescription,
      'trend_color': trendColor,
    };
  }

  /// **NUEVO**: Obtiene los datos de diversidad para el Quick Stat.
  Map<String, dynamic> getQuickStatsDiversityInsights() {
    return {
      'categories_used': (_diversityAnalysis['categories_used'] as num?)?.toInt() ?? 0,
      'max_categories': (_diversityAnalysis['total_available_categories'] as num?)?.toInt() ?? 5,
    };
  }


  // ============================================================================
  // MÉTODOS COMPATIBLES CON WIDGETS ANTIGUOS (SECCIÓN MODIFICADA)
  // ============================================================================

  List<Map<String, String>> getTopRecommendations() {
    final recommendations = <Map<String, String>>[];

    if (_stressPattern.isNotEmpty && _stressPattern['requires_attention'] == true) {
      final stressRecs = _stressPattern['recommendations'] as List<dynamic>? ?? [];
      if (stressRecs.isNotEmpty) {
        recommendations.add({
          'emoji': '🧘',
          'title': 'Manejo del Estrés',
          'description': stressRecs.first.toString(),
          'type': 'stress',
        });
      }
    }

    final streak = (_basicStats['streak_days'] as num?)?.toInt() ?? 0;
    if (streak < 7) {
      recommendations.add({
        'emoji': '⏰',
        'title': 'Mejora tu Consistencia',
        'description': 'Intenta reflexionar al menos 5 días por semana',
        'type': 'consistency',
      });
    }

    if (_diversityAnalysis.isNotEmpty) {
      final categoriesUsed = (_diversityAnalysis['categories_used'] as num?)?.toInt() ?? 0;
      if (categoriesUsed < 3) {
        recommendations.add({
          'emoji': '🌈',
          'title': 'Explora Nuevas Experiencias',
          'description': 'Prueba registrar momentos de diferentes categorías',
          'type': 'diversity',
        });
      }
    }

    if (recommendations.isEmpty) {
      recommendations.add({
        'emoji': '🎯',
        'title': 'Continúa Creciendo',
        'description': 'Mantén tu práctica diaria de reflexión',
        'type': 'general',
      });
    }

    return recommendations.take(3).toList();
  }

  List<Map<String, String>> getPriorityRecommendations() => getTopRecommendations();

  List<Map<String, String>> getMoodInsights() {
    if (_moodAnalysis.isNotEmpty && _moodAnalysis['avg_mood'] != null) {
      final avgMood = (_moodAnalysis['avg_mood'] as num).toDouble();
      final trend = _moodAnalysis['mood_trend']?.toString() ?? 'estable';
      String description;

      if (trend == 'mejorando') {
        description = 'Tu ánimo promedio es de ${avgMood.toStringAsFixed(1)}/10 y va mejorando. ¡Sigue así!';
      } else {
        description = 'Tu ánimo promedio es de ${avgMood.toStringAsFixed(1)}/10. Cada reflexión es un paso adelante.';
      }

      return [{
        'emoji': '😊',
        'title': 'Análisis de Ánimo',
        'description': description,
        'type': 'mood'
      }];
    }
    return [{
      'emoji': '🤔',
      'title': 'Análisis de Ánimo',
      'description': 'Registra tu estado de ánimo varios días para ver tus tendencias.',
      'type': 'mood'
    }];
  }

  List<Map<String, String>> getDiversityInsights() {
    if (_diversityAnalysis.isNotEmpty && _diversityAnalysis['categories_used'] != null) {
      final categoriesUsed = (_diversityAnalysis['categories_used'] as num).toInt();
      final totalCategories = (_diversityAnalysis['total_available_categories'] as num?)?.toInt() ?? 5;
      String description;

      if (categoriesUsed < 3) {
        description = 'Has explorado $categoriesUsed de $totalCategories categorías. ¡Anímate a registrar nuevas experiencias!';
      } else {
        description = '¡Excelente diversidad! Has usado $categoriesUsed de $totalCategories categorías en tus reflexiones.';
      }

      return [{
        'emoji': '🌈',
        'title': 'Diversidad de Momentos',
        'description': description,
        'type': 'diversity'
      }];
    }
    return [{
      'emoji': '🗺️',
      'title': 'Explora y Crece',
      'description': 'Registrar diferentes tipos de momentos enriquece tu análisis.',
      'type': 'diversity'
    }];
  }

  Map<String, dynamic> getNextLevelProgress() {
    final streak = (_basicStats['streak_days'] as num?)?.toInt() ?? 0;
    double progress;
    String description;
    int currentGoal;

    if (streak < 3) {
      progress = streak / 3.0;
      currentGoal = 3;
      description = 'Alcanza una racha de 3 días';
    } else if (streak < 7) {
      progress = streak / 7.0;
      currentGoal = 7;
      description = 'Alcanza una racha de 7 días';
    } else if (streak < 30) {
      progress = streak / 30.0;
      currentGoal = 30;
      description = 'Alcanza una racha de 30 días';
    } else {
      progress = 1.0;
      currentGoal = streak;
      description = '¡Has alcanzado la maestría en rachas!';
    }

    return {
      'progress': progress.clamp(0.0, 1.0),
      'description': description,
      'current_value': streak,
      'target_value': currentGoal,
    };
  }

  List<Map<String, String>> getHighlightedInsights() {
    final highlights = <Map<String, String>>[];
    if (_enhancedWellbeingScore.isNotEmpty) {
      final enhancedInsights = _enhancedWellbeingScore['insights'] as List<dynamic>? ?? [];
      for (final insight in enhancedInsights.take(3)) {
        highlights.add({
          'emoji': '✨',
          'title': 'Insight de Bienestar',
          'description': insight.toString(),
          'type': 'achievement',
        });
      }
    }
    if (_streakAnalysis.isNotEmpty) {
      final currentStreak = (_streakAnalysis['current_streak'] as num?)?.toInt() ?? 0;
      if (currentStreak > 0) {
        highlights.add({
          'emoji': '🔥',
          'title': 'Racha Activa',
          'description': 'Llevas $currentStreak días consecutivos. ¡Excelente consistencia!',
          'type': 'achievement',
        });
      }
    }
    if (_stressPattern.isNotEmpty) {
      final stressLevel = _stressPattern['stress_level']?.toString() ?? 'unknown';
      if (stressLevel == 'low') {
        highlights.add({
          'emoji': '😌',
          'title': 'Estrés Bajo',
          'description': 'Tu nivel de estrés está bien controlado. ¡Sigue así!',
          'type': 'mood',
        });
      }
    }
    if (highlights.isEmpty) return _insights;
    return highlights.take(3).toList();
  }

  Map<String, String>? getNextAchievementToUnlock() {
    final streak = (_basicStats['streak_days'] as num?)?.toInt() ?? 0;
    if (streak < 3) return {'emoji': '🔥', 'title': 'Primera Racha', 'description': 'Mantén 3 días consecutivos de reflexión', 'tier': 'bronze'};
    if (streak < 7) return {'emoji': '💪', 'title': 'Semana Completa', 'description': 'Completa 7 días consecutivos', 'tier': 'silver'};
    if (streak < 30) return {'emoji': '💎', 'title': 'Maestría', 'description': 'Alcanza 30 días consecutivos', 'tier': 'gold'};
    return null;
  }

  Map<String, String> getWellbeingStatus() {
    String message;
    String emoji;
    if (_wellbeingScore >= 80) {
      emoji = '🌟';
      message = '¡Excelente! Tu bienestar está en un nivel fantástico';
    } else if (_wellbeingScore >= 60) {
      emoji = '😊';
      message = 'Buen trabajo! Vas por el camino correcto';
    } else if (_wellbeingScore >= 40) {
      emoji = '🌱';
      message = 'En crecimiento. Cada paso cuenta';
    } else {
      emoji = '💪';
      message = 'Comenzando el viaje. ¡Tú puedes!';
    }
    return {'emoji': emoji, 'level': _wellbeingLevel, 'score': _wellbeingScore.toString(), 'message': message};
  }

  List<Map<String, dynamic>> getMoodChartData() {
    if (_moodAnalysis.isNotEmpty) {
      final avgMood = (_moodAnalysis['avg_mood'] as num?)?.toDouble() ?? 5.0;
      return List.generate(7, (index) {
        final date = DateTime.now().subtract(Duration(days: 6 - index));
        final moodVariation = (index % 2 == 0 ? 0.5 : -0.3);
        final mood = (avgMood + moodVariation).clamp(1.0, 10.0);
        return {'date': '${date.day}/${date.month}', 'mood': mood, 'entries': 1};
      });
    }
    return List.generate(7, (index) => {
      'date': DateTime.now().subtract(Duration(days: 6 - index)).toString().split(' ')[0],
      'mood': 5.0 + (index * 0.5) + (index % 2 == 0 ? 1 : -0.5),
      'entries': 1 + (index % 3),
    });
  }

  // Métodos mejorados para el nuevo dashboard
  Map<String, dynamic> getDashboardSummary() {
    final score = (_enhancedWellbeingScore['total_score'] as num?)?.toInt() ?? _wellbeingScore;
    final level = _enhancedWellbeingScore['level']?.toString() ?? _wellbeingLevel;
    final emoji = _enhancedWellbeingScore['emoji']?.toString() ?? '🌱';
    final currentStreak = (_streakAnalysis['current_streak'] as num?)?.toInt() ?? (_basicStats['streak_days'] as num?)?.toInt() ?? 0;
    final longestStreak = (_streakAnalysis['longest_streak'] as num?)?.toInt() ?? 0;
    return {
      'wellbeing_score': score,
      'level': level,
      'emoji': emoji,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'stress_level': _stressPattern['stress_level']?.toString() ?? 'unknown',
      'requires_attention': _stressPattern['requires_attention'] as bool? ?? false,
      'insights': _enhancedWellbeingScore['insights'] ?? _insights.map((i) => i['description']).toList(),
    };
  }

  List<Map<String, dynamic>> getScoreComponents() {
    if (_enhancedWellbeingScore.isNotEmpty) {
      final components = _enhancedWellbeingScore['component_scores'] as Map? ?? {};
      final maxScores = {'consistency': 30, 'emotional': 25, 'progress': 20, 'activity': 15, 'diversity': 10};
      return components.entries.map((entry) {
        final key = entry.key.toString();
        final score = (entry.value as num).toDouble();
        final maxScore = (maxScores[key] ?? 10).toDouble();
        final percentage = (score / maxScore * 100).round();
        return {
          'name': _getComponentDisplayName(key),
          'score': score.round(),
          'maxScore': maxScore.round(),
          'percentage': percentage,
          'color': _getComponentColor(key),
          'icon': _getComponentIcon(key),
        };
      }).toList();
    }
    return [
      {'name': 'Consistencia', 'score': (((_basicStats['streak_days'] as num?)?.toInt() ?? 0) / 30 * 30).round(), 'maxScore': 30, 'percentage': (((_basicStats['streak_days'] as num?)?.toInt() ?? 0) / 30 * 100).round().clamp(0, 100), 'color': Colors.red.shade400, 'icon': '🔥'},
      {'name': 'Bienestar', 'score': (((_basicStats['avg_mood_score'] as num?)?.toDouble() ?? 5.0) / 10 * 25).round(), 'maxScore': 25, 'percentage': (((_basicStats['avg_mood_score'] as num?)?.toDouble() ?? 5.0) / 10 * 100).round(), 'color': Colors.blue.shade400, 'icon': '😊'},
    ];
  }

  Map<String, dynamic> getStressAlerts() {
    if (_stressPattern.isEmpty) return {'level': 'unknown', 'requires_attention': false, 'recommendations': <String>[], 'alert_color': Colors.grey, 'alert_icon': '❓', 'alert_title': 'Datos Insuficientes'};
    final stressLevel = _stressPattern['stress_level']?.toString() ?? 'unknown';
    final requiresAttention = _stressPattern['requires_attention'] as bool? ?? false;
    final recommendations = _stressPattern['recommendations'] ?? <String>[];
    Color alertColor;
    String alertIcon;
    String alertTitle;
    switch (stressLevel) {
      case 'high': alertColor = Colors.red; alertIcon = '🚨'; alertTitle = 'Estrés Alto Detectado'; break;
      case 'moderate': alertColor = Colors.orange; alertIcon = '⚠️'; alertTitle = 'Estrés Moderado'; break;
      case 'low': alertColor = Colors.green; alertIcon = '✅'; alertTitle = 'Estrés Bajo'; break;
      default: alertColor = Colors.grey; alertIcon = '❓'; alertTitle = 'Evaluando...';
    }
    return {'level': stressLevel, 'requires_attention': requiresAttention, 'recommendations': recommendations, 'frequency': (_stressPattern['stress_frequency'] as num?)?.toInt() ?? 0, 'alert_color': alertColor, 'alert_icon': alertIcon, 'alert_title': alertTitle, 'days_analyzed': (_stressPattern['days_analyzed'] as num?)?.toInt() ?? 0};
  }

  Map<String, dynamic> getStreakData() {
    if (_streakAnalysis.isNotEmpty) return {
      'current': (_streakAnalysis['current_streak'] as num?)?.toInt() ?? 0,
      'longest': (_streakAnalysis['longest_streak'] as num?)?.toInt() ?? 0,
      'total_streaks': (_streakAnalysis['total_streaks'] as num?)?.toInt() ?? 0,
      'avg_length': ((_streakAnalysis['avg_streak_length'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1),
      'weekly_consistency': ((_streakAnalysis['weekly_consistency'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1),
      'stability': (((_streakAnalysis['streak_stability'] as num?)?.toDouble() ?? 0.0) * 100).round(),
    };
    final currentStreak = (_basicStats['streak_days'] as num?)?.toInt() ?? 0;
    return {'current': currentStreak, 'longest': currentStreak, 'total_streaks': 1, 'avg_length': currentStreak.toString(), 'weekly_consistency': '5.0', 'stability': 80};
  }

  // Métodos auxiliares
  String _getComponentDisplayName(String key) {
    switch (key) {
      case 'consistency': return 'Consistencia';
      case 'emotional': return 'Bienestar Emocional';
      case 'progress': return 'Progreso';
      case 'activity': return 'Actividad';
      case 'diversity': return 'Diversidad';
      default: return key;
    }
  }

  Color _getComponentColor(String key) {
    switch (key) {
      case 'consistency': return Colors.red.shade400;
      case 'emotional': return Colors.blue.shade400;
      case 'progress': return Colors.green.shade400;
      case 'activity': return Colors.orange.shade400;
      case 'diversity': return Colors.purple.shade400;
      default: return Colors.grey.shade400;
    }
  }

  String _getComponentIcon(String key) {
    switch (key) {
      case 'consistency': return '🔥';
      case 'emotional': return '😊';
      case 'progress': return '📈';
      case 'activity': return '⚡';
      case 'diversity': return '🌈';
      default: return '📊';
    }
  }

  int _calculateBasicWellbeingScore(Map<String, dynamic> stats) {
    double score = 0;
    score += (((stats['streak_days'] as num?)?.toInt() ?? 0) / 10 * 40).clamp(0, 40);
    score += (((stats['entries_this_month'] as num?)?.toInt() ?? 0) / 20 * 30).clamp(0, 30);
    score += (((stats['avg_mood_score'] as num?)?.toDouble() ?? 5.0) / 10 * 30).clamp(0, 30);
    return score.round().clamp(0, 100);
  }

  String _calculateWellbeingLevel(int score) {
    if (score >= 85) return 'Maestro Zen';
    if (score >= 70) return 'Avanzado';
    if (score >= 55) return 'Intermedio';
    if (score >= 40) return 'En Progreso';
    if (score >= 25) return 'Aprendiz';
    return 'Iniciando';
  }

  List<Map<String, String>> _generateBasicInsights(Map<String, dynamic> stats) {
    final insights = <Map<String, String>>[];
    final streak = (stats['streak_days'] as num?)?.toInt() ?? 0;
    if (streak >= 3) insights.add({'emoji': '🔥', 'title': 'Racha Activa', 'description': 'Llevas $streak días consecutivos. ¡Excelente consistencia!', 'type': 'achievement'});
    final totalEntries = (stats['total_entries'] as num?)?.toInt() ?? 0;
    if (totalEntries >= 5) insights.add({'emoji': '📈', 'title': 'Progreso Constante', 'description': 'Has creado $totalEntries reflexiones. Tu práctica está creciendo.', 'type': 'progress'});
    final avgMood = (stats['avg_mood_score'] as num?)?.toDouble() ?? 5.0;
    if (avgMood >= 6) insights.add({'emoji': '😊', 'title': 'Actitud Positiva', 'description': 'Tu mood promedio de ${avgMood.toStringAsFixed(1)}/10 es muy bueno.', 'type': 'mood'});
    if (insights.isEmpty) insights.add({'emoji': '🌱', 'title': 'Comenzando el Viaje', 'description': 'Cada reflexión que escribes te ayuda a conocerte mejor.', 'type': 'motivation'});
    return insights;
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
  }

  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  void reset() {
    _basicStats = {};
    _insights = [];
    _wellbeingScore = 0;
    _wellbeingLevel = 'Iniciando';
    _enhancedWellbeingScore = {};
    _streakAnalysis = {};
    _moodAnalysis = {};
    _consistencyAnalysis = {};
    _diversityAnalysis = {};
    _stressPattern = {};
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> getDominantThemes() {
    final themes = [{'word': 'feliz', 'count': 5, 'type': 'positive', 'emoji': '😊'}, {'word': 'trabajo', 'count': 3, 'type': 'neutral', 'emoji': '💼'}, {'word': 'familia', 'count': 4, 'type': 'positive', 'emoji': '👨‍👩‍👧‍👦'}, {'word': 'cansado', 'count': 2, 'type': 'negative', 'emoji': '😴'}, {'word': 'logro', 'count': 3, 'type': 'positive', 'emoji': '🏆'}];
    themes.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return themes.take(5).toList();
  }

  Map<String, dynamic> getCurrentDayAnalysis() {
    final today = DateTime.now();
    final dayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    final todayName = dayNames[today.weekday % 7];
    return {'day_name': todayName, 'avg_mood': 6.5, 'entries_count': (_basicStats['entries_this_month'] as num?)?.toInt() ?? 0, 'is_best_day': todayName == 'Viernes', 'motivation': _getDayMotivation(todayName), 'current_hour': today.hour, 'recommended_activity': _getRecommendedActivity(today.hour)};
  }

  String _getDayMotivation(String dayName) {
    switch (dayName) {
      case 'Lunes': return '¡Nuevo comienzo! Hoy es perfecto para establecer intenciones 💪';
      case 'Martes': return '¡A por el impulso! Mantén la energía de ayer 🚀';
      case 'Miércoles': return '¡Mitad de semana! Eres más fuerte de lo que crees 🌟';
      case 'Jueves': return '¡Casi en la meta! Tu constancia está dando frutos 🎯';
      case 'Viernes': return '¡El viernes perfecto! Celebra todo lo que has logrado 🎉';
      case 'Sábado': return '¡Fin de semana! Tiempo para cuidarte y reflexionar 🌱';
      case 'Domingo': return '¡Día de renovación! Prepárate para una nueva semana ✨';
      default: return '¡Hoy es un gran día para reflexionar! 💫';
    }
  }

  String _getRecommendedActivity(int hour) {
    if (hour >= 6 && hour < 9) return 'Reflexión matutina: Define tus intenciones para el día';
    if (hour >= 9 && hour < 12) return 'Momento productivo: Captura tus logros y avances';
    if (hour >= 12 && hour < 15) return 'Pausa consciente: ¿Cómo te sientes a mitad del día?';
    if (hour >= 15 && hour < 18) return 'Impulso vespertino: Registra momentos destacados';
    if (hour >= 18 && hour < 22) return 'Reflexión del día: ¿Qué aprendiste hoy?';
    return 'Momento de calma: Agradece y prepárate para descansar';
  }
}
