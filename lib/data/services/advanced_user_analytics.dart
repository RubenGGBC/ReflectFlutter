// ============================================================================
// SISTEMA DE ANÁLISIS AVANZADO DEL USUARIO - IMPLEMENTACIÓN COMPLETA
// ============================================================================

import 'package:logger/logger.dart';
import 'database_service.dart';

class AdvancedUserAnalytics {
  final DatabaseService _databaseService;
  final Logger _logger = Logger();

  AdvancedUserAnalytics(this._databaseService);

  // ============================================================================
  // 📊 SCORE DE BIENESTAR MEJORADO (más de 15 factores)
  // ============================================================================

  /// 🎯 Score de bienestar ultra-preciso (0-100)
  Future<Map<String, dynamic>> getAdvancedWellbeingScore(int userId) async {
    try {
      final components = <String, double>{};
      double totalScore = 0;

      // 1. CONSISTENCIA Y HÁBITOS (25 puntos)
      final consistencyData = await _getConsistencyMetrics(userId);
      final consistencyScore = _calculateConsistencyScore(consistencyData);
      components['consistency'] = consistencyScore;
      totalScore += consistencyScore;

      // 2. EQUILIBRIO EMOCIONAL (20 puntos)
      final emotionalData = await _getEmotionalBalanceMetrics(userId);
      final emotionalScore = _calculateEmotionalScore(emotionalData);
      components['emotional_balance'] = emotionalScore;
      totalScore += emotionalScore;

      // 3. TENDENCIA DE PROGRESO (15 puntos)
      final progressData = await _getProgressTrendMetrics(userId);
      final progressScore = _calculateProgressScore(progressData);
      components['progress_trend'] = progressScore;
      totalScore += progressScore;

      // 4. DIVERSIDAD DE EXPERIENCIAS (10 puntos)
      final diversityData = await _getDiversityMetrics(userId);
      final diversityScore = _calculateDiversityScore(diversityData);
      components['diversity'] = diversityScore;
      totalScore += diversityScore;

      // 5. GESTIÓN DEL ESTRÉS (10 puntos)
      final stressData = await _getStressManagementMetrics(userId);
      final stressScore = _calculateStressScore(stressData);
      components['stress_management'] = stressScore;
      totalScore += stressScore;

      // 6. CALIDAD DE REFLEXIÓN (10 puntos)
      final reflectionData = await _getReflectionQualityMetrics(userId);
      final reflectionScore = _calculateReflectionScore(reflectionData);
      components['reflection_quality'] = reflectionScore;
      totalScore += reflectionScore;

      // 7. LOGROS Y MILESTONES (5 puntos)
      final achievementData = await _getAchievementMetrics(userId);
      final achievementScore = _calculateAchievementScore(achievementData);
      components['achievements'] = achievementScore;
      totalScore += achievementScore;

      // 8. ESTABILIDAD TEMPORAL (5 puntos)
      final stabilityData = await _getTemporalStabilityMetrics(userId);
      final stabilityScore = _calculateStabilityScore(stabilityData);
      components['temporal_stability'] = stabilityScore;
      totalScore += stabilityScore;

      final finalScore = totalScore.round().clamp(0, 100);
      final level = _getDetailedWellbeingLevel(finalScore);
      final insights = _generateAdvancedInsights(components, finalScore);

      return {
        'overall_score': finalScore,
        'level': level,
        'components': components,
        'insights': insights,
        'improvement_areas': _identifyImprovementAreas(components),
        'strengths': _identifyStrengths(components),
        'next_milestone': _getNextMilestone(finalScore, components),
      };
    } catch (e) {
      _logger.e('Error calculando score avanzado: $e');
      return _getDefaultWellbeingScore();
    }
  }

  // ============================================================================
  // 🚨 SISTEMA DE DETECCIÓN DE PROBLEMAS
  // ============================================================================

  /// 😰 Detector de estrés y ansiedad
  Future<Map<String, dynamic>> detectStressAndAnxiety(int userId) async {
    try {
      final db = await _databaseService.database;

      // Análisis de últimos 14 días para patrones de estrés
      final stressIndicators = await db.rawQuery('''
        SELECT 
          entry_date,
          mood_score,
          free_reflection,
          energy_level,
          sleep_quality,
          stress_level
        FROM daily_entries 
        WHERE user_id = ? AND entry_date >= date('now', '-14 days')
        ORDER BY entry_date DESC
      ''', [userId]);

      if (stressIndicators.isEmpty) {
        return _getDefaultStressAnalysis();
      }

      // Analizar indicadores de estrés
      double avgStress = 0;
      double avgMood = 0;
      double avgEnergy = 0;
      double avgSleep = 0;
      int highStressDays = 0;
      int lowMoodDays = 0;

      for (var entry in stressIndicators) {
        final stress = (entry['stress_level'] as num?)?.toDouble() ?? 5.0;
        final mood = (entry['mood_score'] as num?)?.toDouble() ?? 5.0;
        final energy = (entry['energy_level'] as num?)?.toDouble() ?? 5.0;
        final sleep = (entry['sleep_quality'] as num?)?.toDouble() ?? 5.0;

        avgStress += stress;
        avgMood += mood;
        avgEnergy += energy;
        avgSleep += sleep;

        if (stress > 7) highStressDays++;
        if (mood < 4) lowMoodDays++;
      }

      final count = stressIndicators.length;
      avgStress /= count;
      avgMood /= count;
      avgEnergy /= count;
      avgSleep /= count;

      // Determinar nivel de alerta
      String alertLevel = 'normal';
      String alertMessage = 'Niveles de estrés dentro de rangos normales';
      List<String> recommendations = [];

      if (avgStress > 7.5 || highStressDays >= 5) {
        alertLevel = 'critical';
        alertMessage = 'Se detectan niveles críticos de estrés sostenido';
        recommendations.addAll([
          'Considera contactar a un profesional de salud mental',
          'Practica técnicas de respiración profunda',
          'Reduce las actividades estresantes no esenciales',
          'Asegúrate de dormir al menos 8 horas',
        ]);
      } else if (avgStress > 6.5 || highStressDays >= 3) {
        alertLevel = 'high';
        alertMessage = 'Niveles de estrés elevados en las últimas semanas';
        recommendations.addAll([
          'Implementa rutinas de relajación diarias',
          'Practica ejercicio moderado',
          'Limita el consumo de cafeína',
          'Dedica tiempo a actividades que disfrutes',
        ]);
      } else if (avgStress > 5.5) {
        alertLevel = 'moderate';
        alertMessage = 'Estrés moderado detectado';
        recommendations.addAll([
          'Mantén horarios regulares de sueño',
          'Practica mindfulness o meditación',
          'Organiza tu tiempo de forma eficiente',
        ]);
      }

      return {
        'alert_level': alertLevel,
        'alert_message': alertMessage,
        'recommendations': recommendations,
        'metrics': {
          'avg_stress': avgStress.toStringAsFixed(1),
          'avg_mood': avgMood.toStringAsFixed(1),
          'avg_energy': avgEnergy.toStringAsFixed(1),
          'avg_sleep': avgSleep.toStringAsFixed(1),
          'high_stress_days': highStressDays,
          'low_mood_days': lowMoodDays,
        },
      };

    } catch (e) {
      _logger.e('Error detectando estrés: $e');
      return _getDefaultStressAnalysis();
    }
  }

  /// 📉 Detector de declive de ánimo
  Future<Map<String, dynamic>> detectMoodDecline(int userId) async {
    try {
      final db = await _databaseService.database;

      final moodData = await db.rawQuery('''
        SELECT 
          entry_date,
          mood_score,
          energy_level
        FROM daily_entries 
        WHERE user_id = ? AND entry_date >= date('now', '-21 days')
        ORDER BY entry_date ASC
      ''', [userId]);

      if (moodData.length < 7) {
        return _getDefaultMoodDeclineAnalysis();
      }

      // Dividir en semanas para análisis de tendencia
      final moodValues = moodData.map((e) => (e['mood_score'] as num?)?.toDouble() ?? 5.0).toList();
      final energyValues = moodData.map((e) => (e['energy_level'] as num?)?.toDouble() ?? 5.0).toList();

      // Calcular tendencia
      final moodTrend = _calculateTrendDecline(moodValues);
      final energyTrend = _calculateTrendDecline(energyValues);

      String concernLevel = 'normal';
      String message = 'Tu ánimo se mantiene estable';
      List<String> recommendations = [];

      if (moodTrend > 2.0 && energyTrend > 1.5) {
        concernLevel = 'critical';
        message = 'Se detecta una tendencia descendente preocupante en tu ánimo';
        recommendations.addAll([
          'Considera hablar con un profesional',
          'Mantén contacto regular con seres queridos',
          'Establece rutinas diarias estructuradas',
          'Realiza actividades que antes disfrutabas',
        ]);
      } else if (moodTrend > 1.5) {
        concernLevel = 'high';
        message = 'Tu ánimo ha mostrado una tendencia descendente';
        recommendations.addAll([
          'Identifica y aborda fuentes de estrés',
          'Aumenta la actividad física',
          'Practica gratitud diariamente',
          'Busca apoyo social',
        ]);
      } else if (moodTrend > 0.8) {
        concernLevel = 'moderate';
        message = 'Se observa una ligera tendencia descendente';
        recommendations.addAll([
          'Mantén horarios regulares',
          'Dedica tiempo a hobbies',
          'Practica técnicas de relajación',
        ]);
      }

      return {
        'concern_level': concernLevel,
        'message': message,
        'recommendations': recommendations,
        'trend_analysis': {
          'mood_trend': moodTrend.toStringAsFixed(2),
          'energy_trend': energyTrend.toStringAsFixed(2),
          'current_avg_mood': moodValues.take(7).reduce((a, b) => a + b) / 7,
          'previous_avg_mood': moodValues.skip(7).take(7).isNotEmpty
              ? moodValues.skip(7).take(7).reduce((a, b) => a + b) / 7
              : 0,
        },
      };

    } catch (e) {
      _logger.e('Error analizando declive de ánimo: $e');
      return _getDefaultMoodDeclineAnalysis();
    }
  }

  // ============================================================================
  // 📈 TIMELINE DE PROGRESO DETALLADO
  // ============================================================================

  Future<Map<String, dynamic>> getDetailedProgressTimeline(int userId) async {
    try {
      final db = await _databaseService.database;

      // Obtener datos semanales de los últimos 3 meses
      final weeklyData = await db.rawQuery('''
        SELECT 
          strftime('%Y-%W', entry_date) as week,
          AVG(mood_score) as avg_mood,
          AVG(energy_level) as avg_energy,
          AVG(CASE WHEN stress_level IS NOT NULL THEN stress_level ELSE 5 END) as avg_stress,
          COUNT(*) as entries_count
        FROM daily_entries 
        WHERE user_id = ? AND entry_date >= date('now', '-90 days')
        GROUP BY strftime('%Y-%W', entry_date)
        ORDER BY week ASC
      ''', [userId]);

      List<Map<String, dynamic>> progressPoints = [];
      List<Map<String, dynamic>> milestones = [];
      List<Map<String, dynamic>> improvements = [];
      List<Map<String, dynamic>> setbacks = [];

      double previousMood = 0;
      double previousEnergy = 0;
      double previousStress = 0;

      for (var week in weeklyData) {
        final mood = (week['avg_mood'] as num?)?.toDouble() ?? 0;
        final energy = (week['avg_energy'] as num?)?.toDouble() ?? 0;
        final stress = (week['avg_stress'] as num?)?.toDouble() ?? 0;
        final weeklyScore = _calculateWeeklyScore(mood, energy, stress, (mood + energy) / 2);

        progressPoints.add({
          'week': week['week'],
          'mood': mood,
          'energy': energy,
          'stress': stress,
          'score': weeklyScore,
          'entries_count': week['entries_count'],
        });

        // Detectar mejoras y retrocesos
        if (previousMood > 0) {
          final moodChange = mood - previousMood;
          final energyChange = energy - previousEnergy;

          if (moodChange > 1.5 && energyChange > 1.0) {
            improvements.add({
              'week': week['week'],
              'type': 'improvement',
              'title': 'Mejora Significativa',
              'description': 'Tu ánimo y energía mejoraron notablemente',
              'emoji': '📈',
            });
          } else if (moodChange < -1.5 && energyChange < -1.0) {
            setbacks.add({
              'week': week['week'],
              'type': 'setback',
              'title': 'Momento Difícil',
              'description': 'Una semana más desafiante',
              'emoji': '📉',
            });
          }

          // Detectar milestones
          if (mood >= 8 && previousMood < 8) {
            milestones.add({
              'week': week['week'],
              'type': 'milestone',
              'title': 'Mood Excelente Alcanzado',
              'description': 'Tu mood promedio superó 8/10 por primera vez',
              'emoji': '🌟',
            });
          }
        }

        previousMood = mood;
        previousEnergy = energy;
        previousStress = stress;
      }

      // Calcular métricas generales de progreso
      final overallTrend = _calculateOverallTrend(progressPoints);
      final consistencyScore = _calculateProgressConsistency(progressPoints);

      return {
        'timeline': progressPoints,
        'milestones': milestones,
        'improvements': improvements,
        'setbacks': setbacks,
        'overall_trend': overallTrend,
        'consistency_score': consistencyScore,
        'progress_summary': _generateProgressSummary(overallTrend, improvements.length, setbacks.length),
      };
    } catch (e) {
      _logger.e('Error generando timeline de progreso: $e');
      return _getDefaultProgressTimeline();
    }
  }

  // ============================================================================
  // 🏆 SISTEMA DE COMPARACIONES TEMPORALES
  // ============================================================================

  Future<Map<String, dynamic>> getTemporalComparisons(int userId) async {
    try {
      final comparisons = <String, Map<String, dynamic>>{};

      // Esta semana vs semana pasada
      comparisons['week_comparison'] = await _compareTimePeriods(
          userId, 'week', 'Esta semana', 'Semana pasada'
      );

      // Este mes vs mes pasado
      comparisons['month_comparison'] = await _compareTimePeriods(
          userId, 'month', 'Este mes', 'Mes pasado'
      );

      // Últimos 30 días vs 30 días anteriores
      comparisons['thirty_day_comparison'] = await _compareTimePeriods(
          userId, '30days', 'Últimos 30 días', '30 días anteriores'
      );

      return {
        'comparisons': comparisons,
        'overall_trajectory': _analyzeOverallTrajectory(comparisons),
        'key_insights': _generateTemporalInsights(comparisons),
      };
    } catch (e) {
      _logger.e('Error en comparaciones temporales: $e');
      return {};
    }
  }

  // ============================================================================
  // 🎯 SISTEMA DE OBJETIVOS PERSONALIZADOS
  // ============================================================================

  Future<Map<String, dynamic>> generatePersonalizedGoals(int userId) async {
    try {
      final currentStats = await getAdvancedWellbeingScore(userId);
      final progressData = await getDetailedProgressTimeline(userId);
      final stressAnalysis = await detectStressAndAnxiety(userId);

      List<Map<String, dynamic>> recommendedGoals = [];

      // Objetivo basado en consistencia
      final currentStreak = await _databaseService.calculateCurrentStreak(userId);
      if (currentStreak < 7) {
        recommendedGoals.add(_createGoal(
            'consistency_goal',
            'Construir Hábito Diario',
            'Mantener 7 días consecutivos de reflexión',
            'Crear una rutina sostenible de autocuidado',
            currentStreak.toDouble(),
            7,
            'días',
            '🔥',
            'high'
        ));
      } else if (currentStreak < 30) {
        recommendedGoals.add(_createGoal(
            'consistency_advanced',
            'Maestría en Consistencia',
            'Alcanzar 30 días consecutivos',
            'Establecer un hábito inquebrantable',
            currentStreak.toDouble(),
            30,
            'días',
            '💎',
            'medium'
        ));
      }

      // Objetivo basado en mood promedio
      final components = currentStats['components'] as Map<String, dynamic>? ?? {};
      final emotionalBalance = components['emotional_balance'] ?? 10.0;
      final currentMoodAvg = emotionalBalance / 2; // Convertir a escala 1-10

      if (currentMoodAvg < 7) {
        final targetMood = (currentMoodAvg + 1.5).clamp(1, 10);
        recommendedGoals.add(_createGoal(
            'mood_improvement',
            'Elevar Estado de Ánimo',
            'Alcanzar mood promedio de ${targetMood.toStringAsFixed(1)}/10',
            'Mejorar tu bienestar emocional general',
            currentMoodAvg,
            targetMood,
            'puntos',
            '😊',
            'high'
        ));
      }

      // Objetivo basado en estrés
      final stressLevel = stressAnalysis['alert_level'] ?? 'normal';
      if (stressLevel == 'high' || stressLevel == 'critical') {
        recommendedGoals.add(_createGoal(
            'stress_reduction',
            'Reducir Niveles de Estrés',
            'Mantener estrés promedio por debajo de 5/10',
            'Mejorar tu manejo del estrés diario',
            7.0, // Estimado actual alto
            5.0,
            'puntos',
            '🧘',
            'high'
        ));
      }

      return {
        'recommended_goals': recommendedGoals.take(3).toList(),
        'all_available_goals': recommendedGoals,
        'goal_categories': _categorizeGoals(recommendedGoals),
        'estimated_timeline': _estimateGoalTimeline(recommendedGoals.take(3).toList()),
      };
    } catch (e) {
      _logger.e('Error generando objetivos: $e');
      return _getDefaultGoals();
    }
  }

  // ============================================================================
  // MÉTODOS AUXILIARES PARA MÉTRICAS
  // ============================================================================

  Future<Map<String, dynamic>> _getConsistencyMetrics(int userId) async {
    try {
      final streak = await _databaseService.calculateCurrentStreak(userId);
      final db = await _databaseService.database;

      final last30Days = await db.rawQuery('''
        SELECT COUNT(*) as total_entries
        FROM daily_entries 
        WHERE user_id = ? AND entry_date >= date('now', '-30 days')
      ''', [userId]);

      final totalEntries = (last30Days.first['total_entries'] as num?)?.toInt() ?? 0;
      final consistencyRate = totalEntries / 30.0;

      return {
        'current_streak': streak,
        'total_entries_30d': totalEntries,
        'consistency_rate': consistencyRate,
      };
    } catch (e) {
      return {'current_streak': 0, 'total_entries_30d': 0, 'consistency_rate': 0.0};
    }
  }

  Future<Map<String, dynamic>> _getEmotionalBalanceMetrics(int userId) async {
    try {
      final db = await _databaseService.database;

      final emotionalData = await db.rawQuery('''
        SELECT 
          AVG(mood_score) as avg_mood,
          MIN(mood_score) as min_mood,
          MAX(mood_score) as max_mood,
          AVG(energy_level) as avg_energy
        FROM daily_entries 
        WHERE user_id = ? AND entry_date >= date('now', '-30 days')
      ''', [userId]);

      final data = emotionalData.first;
      return {
        'avg_mood': (data['avg_mood'] as num?)?.toDouble() ?? 5.0,
        'min_mood': (data['min_mood'] as num?)?.toDouble() ?? 5.0,
        'max_mood': (data['max_mood'] as num?)?.toDouble() ?? 5.0,
        'avg_energy': (data['avg_energy'] as num?)?.toDouble() ?? 5.0,
        'mood_variance': ((data['max_mood'] as num?)?.toDouble() ?? 5.0) - ((data['min_mood'] as num?)?.toDouble() ?? 5.0),
      };
    } catch (e) {
      return {'avg_mood': 5.0, 'avg_energy': 5.0, 'mood_variance': 0.0};
    }
  }

  Future<Map<String, dynamic>> _getProgressTrendMetrics(int userId) async {
    try {
      final db = await _databaseService.database;

      final trendData = await db.rawQuery('''
        SELECT 
          entry_date,
          mood_score,
          energy_level
        FROM daily_entries 
        WHERE user_id = ? AND entry_date >= date('now', '-14 days')
        ORDER BY entry_date ASC
      ''', [userId]);

      final moodValues = trendData.map((e) => (e['mood_score'] as num?)?.toDouble() ?? 5.0).toList();
      final trend = _calculateTrendSlope(moodValues);

      return {
        'mood_trend': trend,
        'data_points': moodValues.length,
        'trend_direction': trend > 0.1 ? 'improving' : trend < -0.1 ? 'declining' : 'stable',
      };
    } catch (e) {
      return {'mood_trend': 0.0, 'trend_direction': 'stable'};
    }
  }

  Future<Map<String, dynamic>> _getDiversityMetrics(int userId) async {
    try {
      final db = await _databaseService.database;

      final diversityData = await db.rawQuery('''
        SELECT COUNT(DISTINCT CASE WHEN mood_score <= 3 THEN 'low' 
                                   WHEN mood_score <= 7 THEN 'medium' 
                                   ELSE 'high' END) as mood_diversity
        FROM daily_entries 
        WHERE user_id = ? AND entry_date >= date('now', '-30 days')
      ''', [userId]);

      final diversity = (diversityData.first['mood_diversity'] as num?)?.toInt() ?? 1;
      return {'mood_diversity': diversity, 'diversity_score': diversity / 3.0};
    } catch (e) {
      return {'mood_diversity': 1, 'diversity_score': 0.33};
    }
  }

  Future<Map<String, dynamic>> _getStressManagementMetrics(int userId) async {
    try {
      final db = await _databaseService.database;

      final stressData = await db.rawQuery('''
        SELECT 
          AVG(CASE WHEN stress_level IS NOT NULL THEN stress_level ELSE 5 END) as avg_stress,
          COUNT(CASE WHEN stress_level > 7 THEN 1 END) as high_stress_days
        FROM daily_entries 
        WHERE user_id = ? AND entry_date >= date('now', '-30 days')
      ''', [userId]);

      final data = stressData.first;
      return {
        'avg_stress': (data['avg_stress'] as num?)?.toDouble() ?? 5.0,
        'high_stress_days': (data['high_stress_days'] as num?)?.toInt() ?? 0,
      };
    } catch (e) {
      return {'avg_stress': 5.0, 'high_stress_days': 0};
    }
  }

  Future<Map<String, dynamic>> _getReflectionQualityMetrics(int userId) async {
    try {
      final db = await _databaseService.database;

      final reflectionData = await db.rawQuery('''
        SELECT 
          AVG(LENGTH(free_reflection)) as avg_reflection_length,
          COUNT(CASE WHEN LENGTH(free_reflection) > 100 THEN 1 END) as detailed_reflections
        FROM daily_entries 
        WHERE user_id = ? AND entry_date >= date('now', '-30 days')
        AND free_reflection IS NOT NULL
      ''', [userId]);

      final data = reflectionData.first;
      return {
        'avg_length': (data['avg_reflection_length'] as num?)?.toDouble() ?? 50.0,
        'detailed_count': (data['detailed_reflections'] as num?)?.toInt() ?? 0,
      };
    } catch (e) {
      return {'avg_length': 50.0, 'detailed_count': 0};
    }
  }

  Future<Map<String, dynamic>> _getAchievementMetrics(int userId) async {
    try {
      final streak = await _databaseService.calculateCurrentStreak(userId);
      return {
        'current_streak': streak,
        'milestone_reached': streak >= 7,
      };
    } catch (e) {
      return {'current_streak': 0, 'milestone_reached': false};
    }
  }

  Future<Map<String, dynamic>> _getTemporalStabilityMetrics(int userId) async {
    try {
      final db = await _databaseService.database;

      final stabilityData = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_days,
          COUNT(CASE WHEN abs(mood_score - LAG(mood_score) OVER (ORDER BY entry_date)) < 2 THEN 1 END) as stable_days
        FROM daily_entries 
        WHERE user_id = ? AND entry_date >= date('now', '-30 days')
      ''', [userId]);

      final data = stabilityData.first;
      final totalDays = (data['total_days'] as num?)?.toInt() ?? 1;
      final stableDays = (data['stable_days'] as num?)?.toInt() ?? 0;

      return {
        'stability_rate': stableDays / totalDays,
        'stable_days': stableDays,
        'total_days': totalDays,
      };
    } catch (e) {
      return {'stability_rate': 0.5, 'stable_days': 0, 'total_days': 1};
    }
  }

  // ============================================================================
  // MÉTODOS DE CÁLCULO DE SCORES
  // ============================================================================

  double _calculateConsistencyScore(Map<String, dynamic> data) {
    final streak = data['current_streak'] as int;
    final consistencyRate = data['consistency_rate'] as double;

    // Score basado en racha y consistencia (max 25 puntos)
    final streakScore = (streak * 2).clamp(0, 15).toDouble();
    final rateScore = (consistencyRate * 10).clamp(0, 10);

    return streakScore + rateScore;
  }

  double _calculateEmotionalScore(Map<String, dynamic> data) {
    final avgMood = data['avg_mood'] as double;
    final avgEnergy = data['avg_energy'] as double;
    final variance = data['mood_variance'] as double;

    // Score basado en mood promedio, energía y estabilidad (max 20 puntos)
    final moodScore = (avgMood / 10 * 10).clamp(0, 10);
    final energyScore = (avgEnergy / 10 * 5).clamp(0, 5);
    final stabilityScore = (5 - (variance / 2)).clamp(0, 5);

    return (moodScore + energyScore + stabilityScore).toDouble();
  }

  double _calculateProgressScore(Map<String, dynamic> data) {
    final trend = data['mood_trend'] as double;
    final direction = data['trend_direction'] as String;

    // Score basado en tendencia de progreso (max 15 puntos)
    double score = 7.5; // Base neutral

    if (direction == 'improving') {
      score += (trend * 10).clamp(0, 7.5);
    } else if (direction == 'declining') {
      score -= (trend.abs() * 5).clamp(0, 5);
    }

    return score.clamp(0, 15);
  }

  double _calculateDiversityScore(Map<String, dynamic> data) {
    final diversityScore = data['diversity_score'] as double;
    return (diversityScore * 10).clamp(0, 10);
  }

  double _calculateStressScore(Map<String, dynamic> data) {
    final avgStress = data['avg_stress'] as double;
    final highStressDays = data['high_stress_days'] as int;

    // Score inverso al estrés (max 10 puntos)
    final stressScore = ((10 - avgStress) / 10 * 7).clamp(0, 7);
    final daysScore = (3 - (highStressDays * 0.2)).clamp(0, 3);

    return (stressScore + daysScore).toDouble();
  }

  double _calculateReflectionScore(Map<String, dynamic> data) {
    final avgLength = data['avg_length'] as double;
    final detailedCount = data['detailed_count'] as int;

    // Score basado en calidad de reflexión (max 10 puntos)
    final lengthScore = (avgLength / 200 * 5).clamp(0, 5);
    final qualityScore = (detailedCount * 0.5).clamp(0, 5);

    return (lengthScore + qualityScore).toDouble();
  }

  double _calculateAchievementScore(Map<String, dynamic> data) {
    final streak = data['current_streak'] as int;
    final milestoneReached = data['milestone_reached'] as bool;

    // Score basado en logros (max 5 puntos)
    double score = (streak * 0.1).clamp(0, 3);
    if (milestoneReached) score += 2;

    return score.clamp(0, 5);
  }

  double _calculateStabilityScore(Map<String, dynamic> data) {
    final stabilityRate = data['stability_rate'] as double;
    return (stabilityRate * 5).clamp(0, 5);
  }

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  double _calculateTrendDecline(List<double> values) {
    if (values.length < 2) return 0.0;

    double totalChange = 0;
    for (int i = 1; i < values.length; i++) {
      totalChange += values[i-1] - values[i]; // Cambio positivo = declive
    }
    return totalChange / (values.length - 1);
  }

  double _calculateTrendSlope(List<double> values) {
    if (values.length < 2) return 0.0;

    // Calcular pendiente usando regresión lineal simple
    final n = values.length;
    final sumX = n * (n - 1) / 2; // 0 + 1 + 2 + ... + (n-1)
    final sumY = values.reduce((a, b) => a + b);
    final sumXY = values.asMap().entries.map((e) => e.key * e.value).reduce((a, b) => a + b);
    final sumXSquared = (n - 1) * n * (2 * n - 1) / 6; // 0² + 1² + 2² + ... + (n-1)²

    final slope = (n * sumXY - sumX * sumY) / (n * sumXSquared - sumX * sumX);
    return slope;
  }

  double _calculateWeeklyScore(double mood, double energy, double stress, double motivation) {
    return ((mood * 0.3 + energy * 0.25 + (10 - stress) * 0.25 + motivation * 0.2) / 10 * 100)
        .clamp(0, 100);
  }

  String _calculateOverallTrend(List<Map<String, dynamic>> progressPoints) {
    if (progressPoints.length < 2) return 'stable';

    final scores = progressPoints.map((p) => p['score'] as double).toList();
    final trend = _calculateTrendSlope(scores);

    if (trend > 2) return 'improving';
    if (trend < -2) return 'declining';
    return 'stable';
  }

  double _calculateProgressConsistency(List<Map<String, dynamic>> progressPoints) {
    if (progressPoints.isEmpty) return 0.0;

    final entryCounts = progressPoints.map((p) => p['entries_count'] as int).toList();
    final avgEntries = entryCounts.reduce((a, b) => a + b) / entryCounts.length;

    return (avgEntries / 7).clamp(0, 1); // Asumiendo 7 días por semana ideal
  }

  String _generateProgressSummary(String trend, int improvements, int setbacks) {
    if (trend == 'improving') {
      return 'Tu progreso muestra una tendencia positiva con $improvements mejoras significativas.';
    } else if (trend == 'declining') {
      return 'Has enfrentado algunos desafíos con $setbacks momentos difíciles, pero cada experiencia es valiosa.';
    } else {
      return 'Tu progreso se mantiene estable. Considera establecer nuevos objetivos para impulsar tu crecimiento.';
    }
  }

  Map<String, dynamic> _createGoal(
      String id, String title, String description, String purpose,
      double currentValue, double targetValue, String unit, String emoji, String priority
      ) {
    final progress = currentValue / targetValue;
    final remaining = targetValue - currentValue;

    return {
      'id': id,
      'title': title,
      'description': description,
      'purpose': purpose,
      'current_value': currentValue,
      'target_value': targetValue,
      'unit': unit,
      'emoji': emoji,
      'priority': priority,
      'progress_percentage': (progress * 100).clamp(0, 100).round(),
      'remaining': remaining > 0 ? remaining : 0,
      'estimated_days': _estimateDaysToComplete(remaining, unit),
      'difficulty': _assessGoalDifficulty(currentValue, targetValue, unit),
    };
  }

  int _estimateDaysToComplete(double remaining, String unit) {
    switch (unit) {
      case 'días': return remaining.round();
      case 'puntos': return (remaining * 7).round(); // Asumiendo 1 punto por semana
      default: return 30; // Default
    }
  }

  String _assessGoalDifficulty(double current, double target, String unit) {
    final ratio = target / (current + 1); // +1 para evitar división por cero
    if (ratio <= 1.5) return 'Fácil';
    if (ratio <= 3) return 'Moderado';
    return 'Desafiante';
  }

  // ============================================================================
  // MÉTODOS DE COMPARACIÓN TEMPORAL
  // ============================================================================

  Future<Map<String, dynamic>> _compareTimePeriods(
      int userId, String period, String currentLabel, String previousLabel) async {
    try {
      final db = await _databaseService.database;

      String dateFilter;
      switch (period) {
        case 'week':
          dateFilter = "strftime('%Y-%W', entry_date) = strftime('%Y-%W', 'now')";
          break;
        case 'month':
          dateFilter = "strftime('%Y-%m', entry_date) = strftime('%Y-%m', 'now')";
          break;
        case '30days':
          dateFilter = "entry_date >= date('now', '-30 days')";
          break;
        default:
          dateFilter = "entry_date >= date('now', '-7 days')";
      }

      final currentData = await db.rawQuery('''
        SELECT 
          AVG(mood_score) as avg_mood,
          AVG(energy_level) as avg_energy,
          COUNT(*) as entry_count
        FROM daily_entries 
        WHERE user_id = ? AND $dateFilter
      ''', [userId]);

      // Para datos anteriores, ajustar el filtro
      String previousDateFilter;
      switch (period) {
        case 'week':
          previousDateFilter = "strftime('%Y-%W', entry_date) = strftime('%Y-%W', date('now', '-7 days'))";
          break;
        case 'month':
          previousDateFilter = "strftime('%Y-%m', entry_date) = strftime('%Y-%m', date('now', '-1 month'))";
          break;
        case '30days':
          previousDateFilter = "entry_date >= date('now', '-60 days') AND entry_date < date('now', '-30 days')";
          break;
        default:
          previousDateFilter = "entry_date >= date('now', '-14 days') AND entry_date < date('now', '-7 days')";
      }

      final previousData = await db.rawQuery('''
        SELECT 
          AVG(mood_score) as avg_mood,
          AVG(energy_level) as avg_energy,
          COUNT(*) as entry_count
        FROM daily_entries 
        WHERE user_id = ? AND $previousDateFilter
      ''', [userId]);

      final current = currentData.first;
      final previous = previousData.first;

      final currentMood = (current['avg_mood'] as num?)?.toDouble() ?? 0;
      final previousMood = (previous['avg_mood'] as num?)?.toDouble() ?? 0;
      final moodChange = currentMood - previousMood;

      return {
        'current_period': currentLabel,
        'previous_period': previousLabel,
        'current_mood': currentMood,
        'previous_mood': previousMood,
        'mood_change': moodChange,
        'mood_change_percentage': previousMood > 0 ? (moodChange / previousMood * 100) : 0,
        'improvement': moodChange > 0,
      };
    } catch (e) {
      return {};
    }
  }

  String _analyzeOverallTrajectory(Map<String, Map<String, dynamic>> comparisons) {
    int improvements = 0;
    int total = 0;

    for (var comparison in comparisons.values) {
      if (comparison['improvement'] == true) improvements++;
      total++;
    }

    if (improvements >= total * 0.7) return 'positive';
    if (improvements <= total * 0.3) return 'negative';
    return 'mixed';
  }

  List<String> _generateTemporalInsights(Map<String, Map<String, dynamic>> comparisons) {
    List<String> insights = [];

    for (var entry in comparisons.entries) {
      final key = entry.key;
      final data = entry.value;
      final improvement = data['improvement'] as bool? ?? false;
      final change = data['mood_change'] as double? ?? 0;

      if (improvement && change > 0.5) {
        insights.add('Mejora significativa en ${data['current_period']}');
      } else if (!improvement && change < -0.5) {
        insights.add('Desafío temporal en ${data['current_period']}');
      }
    }

    return insights;
  }

  List<String> _categorizeGoals(List<Map<String, dynamic>> goals) {
    Set<String> categories = {};
    for (var goal in goals) {
      if (goal['id'].toString().contains('consistency')) categories.add('Hábitos');
      if (goal['id'].toString().contains('mood')) categories.add('Bienestar Emocional');
      if (goal['id'].toString().contains('stress')) categories.add('Gestión del Estrés');
    }
    return categories.toList();
  }

  Map<String, int> _estimateGoalTimeline(List<Map<String, dynamic>> goals) {
    int totalDays = 0;
    for (var goal in goals) {
      totalDays += goal['estimated_days'] as int? ?? 30;
    }

    return {
      'total_estimated_days': totalDays,
      'weeks': (totalDays / 7).ceil(),
      'months': (totalDays / 30).ceil(),
    };
  }

  // ============================================================================
  // MÉTODOS DE GENERACIÓN DE INSIGHTS
  // ============================================================================

  String _getDetailedWellbeingLevel(int score) {
    if (score >= 90) return 'Excelente';
    if (score >= 80) return 'Muy Bueno';
    if (score >= 70) return 'Bueno';
    if (score >= 60) return 'Regular';
    if (score >= 50) return 'En Desarrollo';
    if (score >= 40) return 'Necesita Atención';
    return 'Requiere Apoyo';
  }

  List<String> _generateAdvancedInsights(Map<String, double> components, int score) {
    List<String> insights = [];

    // Insight sobre componente más fuerte
    final strongestComponent = components.entries.reduce((a, b) => a.value > b.value ? a : b);
    insights.add('Tu fortaleza principal es ${_getComponentName(strongestComponent.key)}');

    // Insight sobre área de mejora
    final weakestComponent = components.entries.reduce((a, b) => a.value < b.value ? a : b);
    insights.add('Puedes mejorar en ${_getComponentName(weakestComponent.key)}');

    // Insight sobre progreso general
    if (score >= 80) {
      insights.add('Estás en una excelente fase de bienestar personal');
    } else if (score >= 60) {
      insights.add('Tu progreso es sólido, sigue construyendo sobre estas bases');
    } else {
      insights.add('Cada paso cuenta en tu camino hacia el bienestar');
    }

    return insights;
  }

  String _getComponentName(String key) {
    switch (key) {
      case 'consistency': return 'la consistencia';
      case 'emotional_balance': return 'el equilibrio emocional';
      case 'progress_trend': return 'la tendencia de progreso';
      case 'diversity': return 'la diversidad de experiencias';
      case 'stress_management': return 'la gestión del estrés';
      case 'reflection_quality': return 'la calidad de reflexión';
      case 'achievements': return 'los logros';
      case 'temporal_stability': return 'la estabilidad temporal';
      default: return key;
    }
  }

  List<String> _identifyImprovementAreas(Map<String, double> components) {
    return components.entries
        .where((e) => e.value < 15) // Componentes con score bajo
        .map((e) => _getComponentName(e.key))
        .toList();
  }

  List<String> _identifyStrengths(Map<String, double> components) {
    return components.entries
        .where((e) => e.value >= 20) // Componentes con score alto
        .map((e) => _getComponentName(e.key))
        .toList();
  }

  Map<String, dynamic> _getNextMilestone(int score, Map<String, double> components) {
    if (score < 50) {
      return {'title': 'Equilibrio Básico', 'target': 50, 'description': 'Alcanzar un nivel básico de bienestar'};
    } else if (score < 70) {
      return {'title': 'Progreso Sólido', 'target': 70, 'description': 'Establecer bases sólidas'};
    } else if (score < 85) {
      return {'title': 'Alto Bienestar', 'target': 85, 'description': 'Alcanzar un alto nivel de bienestar'};
    } else {
      return {'title': 'Excelencia Personal', 'target': 95, 'description': 'Lograr la excelencia en bienestar'};
    }
  }

  // ============================================================================
  // MÉTODOS DE FALLBACK
  // ============================================================================

  Map<String, dynamic> _getDefaultWellbeingScore() {
    return {
      'overall_score': 50,
      'level': 'En Progreso',
      'components': {},
      'insights': ['Continúa registrando tus reflexiones para obtener insights más precisos'],
      'improvement_areas': ['Consistencia'],
      'strengths': ['Autoconocimiento'],
      'next_milestone': {'title': 'Equilibrio Básico', 'target': 50, 'description': 'Alcanzar un nivel básico de bienestar'},
    };
  }

  Map<String, dynamic> _getDefaultStressAnalysis() {
    return {
      'alert_level': 'normal',
      'alert_message': 'No hay suficientes datos para análisis de estrés',
      'recommendations': ['Continúa registrando tus estados para obtener análisis más precisos'],
      'metrics': {},
    };
  }

  Map<String, dynamic> _getDefaultMoodDeclineAnalysis() {
    return {
      'concern_level': 'normal',
      'message': 'No hay suficientes datos para análisis de tendencias',
      'recommendations': ['Registra tus estados de ánimo regularmente para mejor seguimiento'],
      'trend_analysis': {},
    };
  }

  Map<String, dynamic> _getDefaultProgressTimeline() {
    return {
      'timeline': [],
      'milestones': [],
      'improvements': [],
      'setbacks': [],
      'progress_summary': 'Continúa usando la app para ver tu progreso',
    };
  }

  Map<String, dynamic> _getDefaultGoals() {
    return {
      'recommended_goals': [
        _createGoal(
            'first_week',
            'Primera Semana',
            'Completar 7 días de reflexión',
            'Establecer el hábito básico',
            0, 7, 'días', '🌱', 'high'
        )
      ],
      'all_available_goals': [],
      'goal_categories': ['Hábitos'],
      'estimated_timeline': {'total_estimated_days': 7, 'weeks': 1, 'months': 1},
    };
  }
}