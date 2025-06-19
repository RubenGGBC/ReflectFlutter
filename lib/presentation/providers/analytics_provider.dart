// ============================================================================
// presentation/providers/analytics_provider.dart - PROVIDER PARA ANÁLISIS AVANZADO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../data/services/database_service.dart';

class AnalyticsProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  final Logger _logger = Logger();

  // Estados de carga
  bool _isLoading = false;
  String? _errorMessage;

  // Datos analíticos básicos para empezar
  Map<String, dynamic> _basicStats = {};
  List<Map<String, String>> _insights = [];
  int _wellbeingScore = 0;
  String _wellbeingLevel = 'Iniciando';

  AnalyticsProvider(this._databaseService);

  // Getters básicos
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get wellbeingScore => _wellbeingScore;
  String get wellbeingLevel => _wellbeingLevel;

  /// 🚀 Cargar análisis básicos del usuario
  Future<void> loadCompleteAnalytics(int userId) async {
    _setLoading(true);
    _clearError();

    try {
      _logger.i('🔍 Cargando análisis para usuario: $userId');

      // Por ahora, cargar estadísticas básicas
      final stats = await _databaseService.getUserComprehensiveStatistics(userId);

      setState(() {
        _basicStats = stats;
        _wellbeingScore = _calculateBasicWellbeingScore(stats);
        _wellbeingLevel = _calculateWellbeingLevel(_wellbeingScore);
        _insights = _generateBasicInsights(stats);
      });

      _logger.i('✅ Análisis cargado. Score: $_wellbeingScore ($_wellbeingLevel)');

    } catch (e) {
      _logger.e('❌ Error cargando análisis: $e');
      _setError('Error cargando análisis del usuario');
    } finally {
      _setLoading(false);
    }
  }

  /// 📊 Obtener insights destacados básicos
  List<Map<String, String>> getHighlightedInsights() {
    return _insights.take(3).toList();
  }

  /// 🏆 Obtener estado de bienestar básico
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

    return {
      'emoji': emoji,
      'level': _wellbeingLevel,
      'score': _wellbeingScore.toString(),
      'message': message,
    };
  }

  /// 📈 Obtener datos básicos para gráfico (simulados por ahora)
  List<Map<String, dynamic>> getMoodChartData() {
    // Datos básicos simulados - reemplazar con datos reales más tarde
    return List.generate(7, (index) => {
      'date': DateTime.now().subtract(Duration(days: 6 - index)).toString().split(' ')[0],
      'mood': 5.0 + (index * 0.5) + (index % 2 == 0 ? 1 : -0.5),
      'entries': 1 + (index % 3),
    });
  }

  /// 📅 Análisis del día actual básico
  Map<String, dynamic> getCurrentDayAnalysis() {
    final today = DateTime.now();
    final dayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    final todayName = dayNames[today.weekday % 7];

    return {
      'day_name': todayName,
      'avg_mood': 6.5, // Valor básico por ahora
      'entries_count': _basicStats['entries_this_month'] ?? 0,
      'is_best_day': todayName == 'Viernes', // Valor por defecto
      'motivation': '¡Hoy es un gran día para reflexionar! 💪',
    };
  }

  /// 🎯 Recomendaciones básicas
  List<Map<String, String>> getPriorityRecommendations() {
    return [
      {
        'emoji': '⏰',
        'title': 'Mantén la consistencia',
        'description': 'Intenta reflexionar a la misma hora cada día para crear un hábito fuerte.',
        'type': 'consistency',
      },
      {
        'emoji': '🎯',
        'title': 'Registra más momentos',
        'description': 'Captura 3-5 momentos al día para obtener mejores insights.',
        'type': 'moments',
      },
    ];
  }

  /// 🎨 Temas dominantes básicos (por implementar completamente)
  List<Map<String, dynamic>> getDominantThemes() {
    return [
      {'word': 'feliz', 'count': 5, 'type': 'positive', 'emoji': '😊'},
      {'word': 'trabajo', 'count': 3, 'type': 'neutral', 'emoji': '💼'},
    ];
  }

  /// 🏆 Próximo logro básico
  Map<String, String>? getNextAchievementToUnlock() {
    final streak = _basicStats['streak_days'] ?? 0;

    if (streak < 3) {
      return {
        'emoji': '🔥',
        'title': 'Primera Racha',
        'description': 'Mantén 3 días consecutivos de reflexión',
        'tier': 'bronze',
      };
    } else if (streak < 7) {
      return {
        'emoji': '💪',
        'title': 'Semana Completa',
        'description': 'Completa 7 días consecutivos',
        'tier': 'silver',
      };
    }

    return null;
  }

  // ============================================================================
  // HELPER METHODS BÁSICOS
  // ============================================================================

  int _calculateBasicWellbeingScore(Map<String, dynamic> stats) {
    double score = 0;

    // Consistencia (40 puntos)
    final streak = stats['streak_days'] ?? 0;
    score += (streak / 10 * 40).clamp(0, 40);

    // Actividad (30 puntos)
    final entriesThisMonth = stats['entries_this_month'] ?? 0;
    score += (entriesThisMonth / 20 * 30).clamp(0, 30);

    // Mood promedio (30 puntos)
    final avgMood = stats['avg_mood_score'] ?? 5.0;
    score += (avgMood / 10 * 30).clamp(0, 30);

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

    final streak = stats['streak_days'] ?? 0;
    final totalEntries = stats['total_entries'] ?? 0;
    final avgMood = stats['avg_mood_score'] ?? 5.0;

    if (streak >= 3) {
      insights.add({
        'emoji': '🔥',
        'title': 'Racha Activa',
        'description': 'Llevas $streak días consecutivos. ¡Excelente consistencia!',
        'type': 'achievement'
      });
    }

    if (totalEntries >= 5) {
      insights.add({
        'emoji': '📈',
        'title': 'Progreso Constante',
        'description': 'Has creado $totalEntries reflexiones. Tu práctica está creciendo.',
        'type': 'progress'
      });
    }

    if (avgMood >= 6) {
      insights.add({
        'emoji': '😊',
        'title': 'Actitud Positiva',
        'description': 'Tu mood promedio de ${avgMood.toStringAsFixed(1)}/10 es muy bueno.',
        'type': 'mood'
      });
    }

    // Insight por defecto si no hay otros
    if (insights.isEmpty) {
      insights.add({
        'emoji': '🌱',
        'title': 'Comenzando el Viaje',
        'description': 'Cada reflexión que escribes te ayuda a conocerte mejor.',
        'type': 'motivation'
      });
    }

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

  /// 🔄 Reset completo
  void reset() {
    _basicStats = {};
    _insights = [];
    _wellbeingScore = 0;
    _wellbeingLevel = 'Iniciando';
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}