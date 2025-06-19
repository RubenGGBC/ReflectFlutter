// ============================================================================
// SISTEMA DE ANÁLISIS AVANZADO DEL USUARIO - VERSIÓN MEJORADA
// ============================================================================

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
          stress_level,
          anxiety_tags,
          negative_tags
        FROM daily_entries 
        WHERE user_id = ? AND entry_date >= date('now', '-14 days')
        ORDER BY entry_date DESC
      ''', [userId]);

      final stressKeywords = [
        'estresado', 'agobiado', 'presión', 'ansiedad', 'nervioso', 'preocupado',
        'abrumado', 'tensión', 'pánico', 'inquieto', 'agitado', 'overwhelmed'
      ];

      final physicalSymptoms = [
        'cansado', 'agotado', 'dolor de cabeza', 'insomnio', 'fatiga',
        'tensión muscular', 'palpitaciones', 'sudoración'
      ];

      int stressCount = 0;
      int anxietyCount = 0;
      int physicalSymptomsCount = 0;
      double avgMoodDuringStress = 0;
      double avgEnergyLevel = 0;
      List<String> stressPatterns = [];
      List<String> recommendations = [];

      for (final row in stressIndicators) {
        final reflection = (row['free_reflection'] as String).toLowerCase();
        final mood = (row['mood_score'] as num).toDouble();
        final energy = (row['energy_level'] as num?)?.toDouble() ?? 5.0;
        final stressLevel = (row['stress_level'] as num?)?.toDouble() ?? 1.0;

        avgMoodDuringStress += mood;
        avgEnergyLevel += energy;

        // Detectar palabras de estrés
        for (final keyword in stressKeywords) {
          if (reflection.contains(keyword)) {
            stressCount++;
            break;
          }
        }

        // Detectar síntomas físicos
        for (final symptom in physicalSymptoms) {
          if (reflection.contains(symptom)) {
            physicalSymptomsCount++;
            break;
          }
        }

        // Detectar ansiedad específica
        if (reflection.contains('ansiedad') || reflection.contains('ansioso') ||
            reflection.contains('nervioso') || stressLevel > 7) {
          anxietyCount++;
        }
      }

      final totalEntries = stressIndicators.length;
      final stressFrequency = totalEntries > 0 ? stressCount / totalEntries : 0.0;
      final anxietyFrequency = totalEntries > 0 ? anxietyCount / totalEntries : 0.0;
      avgMoodDuringStress = totalEntries > 0 ? avgMoodDuringStress / totalEntries : 5.0;
      avgEnergyLevel = totalEntries > 0 ? avgEnergyLevel / totalEntries : 5.0;

      // Determinar nivel de alerta
      String alertLevel = 'normal';
      String alertMessage = 'Tu nivel de estrés parece estar bajo control.';

      if (stressFrequency > 0.6 || anxietyFrequency > 0.5) {
        alertLevel = 'high';
        alertMessage = '⚠️ ALERTA: Detectamos niveles altos de estrés. Es importante que busques apoyo.';
        recommendations.addAll([
          'Considera hablar con un profesional de la salud mental',
          'Practica técnicas de respiración profunda',
          'Establece límites más claros en tu día a día',
          'Reserva tiempo para actividades que te relajen'
        ]);
      } else if (stressFrequency > 0.4 || anxietyFrequency > 0.3) {
        alertLevel = 'moderate';
        alertMessage = '⚡ Tu nivel de estrés está elevado. Te recomendamos algunas estrategias.';
        recommendations.addAll([
          'Implementa rutinas de relajación diarias',
          'Considera meditation o mindfulness',
          'Evalúa tu carga de trabajo actual',
          'Asegúrate de dormir las horas suficientes'
        ]);
      } else if (stressFrequency > 0.2) {
        alertLevel = 'mild';
        alertMessage = '🌱 Hay algunos indicadores de estrés. Mantente atento a tu bienestar.';
        recommendations.addAll([
          'Mantén tus rutinas de autocuidado',
          'Practica ejercicio regular',
          'Conecta con personas que te apoyen'
        ]);
      }

      return {
        'alert_level': alertLevel,
        'alert_message': alertMessage,
        'stress_frequency': (stressFrequency * 100).round(),
        'anxiety_frequency': (anxietyFrequency * 100).round(),
        'physical_symptoms_frequency': (physicalSymptomsCount / totalEntries * 100).round(),
        'avg_mood_during_stress': avgMoodDuringStress.toStringAsFixed(1),
        'avg_energy_level': avgEnergyLevel.toStringAsFixed(1),
        'stress_patterns': stressPatterns,
        'recommendations': recommendations,
        'needs_professional_help': alertLevel == 'high',
        'last_analysis': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _logger.e('Error detectando estrés: $e');
      return _getDefaultStressAnalysis();
    }
  }

  /// 😔 Detector de decaimiento y depresión
  Future<Map<String, dynamic>> detectMoodDecline(int userId) async {
    try {
      final db = await _databaseService.database;

      // Análisis de últimas 3 semanas para detectar patrones
      final moodData = await db.rawQuery('''
        SELECT 
          entry_date,
          mood_score,
          energy_level,
          motivation_level,
          social_interaction,
          free_reflection,
          negative_tags
        FROM daily_entries 
        WHERE user_id = ? AND entry_date >= date('now', '-21 days')
        ORDER BY entry_date ASC
      ''', [userId]);

      final depressionKeywords = [
        'triste', 'deprimido', 'vacío', 'solo', 'desesperanzado', 'melancólico',
        'sin energía', 'sin motivación', 'no vale la pena', 'inútil', 'culpable'
      ];

      List<double> moodTrend = [];
      List<double> energyTrend = [];
      List<double> motivationTrend = [];
      int negativeKeywordCount = 0;
      int lowMoodDays = 0;
      int isolationDays = 0;

      for (final row in moodData) {
        final mood = (row['mood_score'] as num).toDouble();
        final energy = (row['energy_level'] as num?)?.toDouble() ?? 5.0;
        final motivation = (row['motivation_level'] as num?)?.toDouble() ?? 5.0;
        final social = (row['social_interaction'] as num?)?.toDouble() ?? 5.0;
        final reflection = (row['free_reflection'] as String).toLowerCase();

        moodTrend.add(mood);
        energyTrend.add(energy);
        motivationTrend.add(motivation);

        if (mood <= 3) lowMoodDays++;
        if (social <= 2) isolationDays++;

        for (final keyword in depressionKeywords) {
          if (reflection.contains(keyword)) {
            negativeKeywordCount++;
            break;
          }
        }
      }

      // Calcular tendencias
      final moodDecline = _calculateTrendDecline(moodTrend);
      final energyDecline = _calculateTrendDecline(energyTrend);
      final motivationDecline = _calculateTrendDecline(motivationTrend);

      final totalDays = moodData.length;
      final lowMoodFrequency = totalDays > 0 ? lowMoodDays / totalDays : 0.0;
      final isolationFrequency = totalDays > 0 ? isolationDays / totalDays : 0.0;
      final negativeLanguageFrequency = totalDays > 0 ? negativeKeywordCount / totalDays : 0.0;

      // Determinar nivel de preocupación
      String concernLevel = 'normal';
      String message = 'Tu estado de ánimo parece estable.';
      List<String> warningSignsDetected = [];
      List<String> recommendations = [];

      if (moodDecline > 2.0 && lowMoodFrequency > 0.5) {
        concernLevel = 'high';
        message = '🚨 IMPORTANTE: Detectamos un declive significativo en tu estado de ánimo.';
        warningSignsDetected.addAll(['Declive sostenido del mood', 'Frecuentes días de bajo ánimo']);
        recommendations.addAll([
          'Es recomendable buscar apoyo profesional',
          'Habla con personas cercanas a ti',
          'No te aísles, mantén conexiones sociales',
          'Considera actividades que antes disfrutabas'
        ]);
      } else if (moodDecline > 1.0 || lowMoodFrequency > 0.3) {
        concernLevel = 'moderate';
        message = '⚠️ Notamos algunos cambios en tu estado de ánimo que vale la pena atender.';
        recommendations.addAll([
          'Mantén rutinas que te den estructura',
          'Asegúrate de estar durmiendo bien',
          'Incorpora actividades físicas ligeras',
          'Conecta con tu red de apoyo'
        ]);
      }

      if (isolationFrequency > 0.4) {
        warningSignsDetected.add('Tendencia al aislamiento social');
      }
      if (energyDecline > 1.5) {
        warningSignsDetected.add('Declive en los niveles de energía');
      }
      if (motivationDecline > 1.5) {
        warningSignsDetected.add('Pérdida de motivación');
      }

      return {
        'concern_level': concernLevel,
        'message': message,
        'mood_decline_rate': moodDecline.toStringAsFixed(1),
        'energy_decline_rate': energyDecline.toStringAsFixed(1),
        'motivation_decline_rate': motivationDecline.toStringAsFixed(1),
        'low_mood_frequency': (lowMoodFrequency * 100).round(),
        'isolation_frequency': (isolationFrequency * 100).round(),
        'negative_language_frequency': (negativeLanguageFrequency * 100).round(),
        'warning_signs': warningSignsDetected,
        'recommendations': recommendations,
        'requires_attention': concernLevel != 'normal',
        'last_analysis': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _logger.e('Error detectando decaimiento: $e');
      return _getDefaultMoodDeclineAnalysis();
    }
  }

  // ============================================================================
  // 📈 SISTEMA AVANZADO DE PROGRESIÓN
  // ============================================================================

  /// 🎯 Timeline de progreso detallado
  Future<Map<String, dynamic>> getDetailedProgressTimeline(int userId) async {
    try {
      final db = await _databaseService.database;

      // Obtener datos de los últimos 90 días agrupados por semana
      final weeklyData = await db.rawQuery('''
        SELECT 
          strftime('%Y-%W', entry_date) as week,
          AVG(mood_score) as avg_mood,
          AVG(energy_level) as avg_energy,
          AVG(stress_level) as avg_stress,
          AVG(motivation_level) as avg_motivation,
          COUNT(*) as entries_count,
          MIN(entry_date) as week_start,
          MAX(entry_date) as week_end
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
      double previousStress = 10;

      for (int i = 0; i < weeklyData.length; i++) {
        final week = weeklyData[i];
        final mood = (week['avg_mood'] as num).toDouble();
        final energy = (week['avg_energy'] as num).toDouble();
        final stress = (week['avg_stress'] as num).toDouble();
        final motivation = (week['avg_motivation'] as num).toDouble();

        progressPoints.add({
          'week': week['week'],
          'week_start': week['week_start'],
          'week_end': week['week_end'],
          'mood': mood,
          'energy': energy,
          'stress': stress,
          'motivation': motivation,
          'entries_count': week['entries_count'],
          'overall_score': _calculateWeeklyScore(mood, energy, stress, motivation),
        });

        // Detectar mejoras significativas
        if (i > 0) {
          final moodImprovement = mood - previousMood;
          final energyImprovement = energy - previousEnergy;
          final stressReduction = previousStress - stress;

          if (moodImprovement > 1.5 || energyImprovement > 1.5 || stressReduction > 1.5) {
            improvements.add({
              'week': week['week'],
              'type': 'improvement',
              'description': _getImprovementDescription(moodImprovement, energyImprovement, stressReduction),
              'magnitude': (moodImprovement + energyImprovement + stressReduction) / 3,
            });
          }

          // Detectar retrocesos
          if (moodImprovement < -1.5 || energyImprovement < -1.5 || stressReduction < -1.5) {
            setbacks.add({
              'week': week['week'],
              'type': 'setback',
              'description': _getSetbackDescription(moodImprovement, energyImprovement, stressReduction),
              'magnitude': abs((moodImprovement + energyImprovement + stressReduction) / 3),
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
      final accelerationRate = _calculateProgressAcceleration(progressPoints);

      return {
        'timeline': progressPoints,
        'milestones': milestones,
        'improvements': improvements,
        'setbacks': setbacks,
        'overall_trend': overallTrend,
        'consistency_score': consistencyScore,
        'acceleration_rate': accelerationRate,
        'progress_summary': _generateProgressSummary(overallTrend, improvements.length, setbacks.length),
        'next_targets': _generateNextTargets(progressPoints.isNotEmpty ? progressPoints.last : null),
      };
    } catch (e) {
      _logger.e('Error generando timeline de progreso: $e');
      return _getDefaultProgressTimeline();
    }
  }

  /// 🏆 Sistema de comparaciones temporales
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

      // Comparación con mejor período histórico
      comparisons['best_period_comparison'] = await _compareToBestPeriod(userId);

      // Evolución por trimestres
      comparisons['quarterly_evolution'] = await _getQuarterlyEvolution(userId);

      return {
        'comparisons': comparisons,
        'overall_trajectory': _analyzeOverallTrajectory(comparisons),
        'key_insights': _generateTemporalInsights(comparisons),
        'improvement_rate': _calculateImprovementRate(comparisons),
      };
    } catch (e) {
      _logger.e('Error en comparaciones temporales: $e');
      return {};
    }
  }

  // ============================================================================
  // 🎯 SISTEMA DE OBJETIVOS PERSONALIZADOS
  // ============================================================================

  /// 📊 Generador de objetivos inteligentes
  Future<Map<String, dynamic>> generatePersonalizedGoals(int userId) async {
    try {
      final currentStats = await getAdvancedWellbeingScore(userId);
      final progressData = await getDetailedProgressTimeline(userId);
      final stressAnalysis = await detectStressAndAnxiety(userId);
      final moodAnalysis = await detectMoodDecline(userId);

      List<Map<String, dynamic>> recommendedGoals = [];

      // Objetivo basado en consistencia
      final currentStreak = await _databaseService.calculateCurrentStreak(userId);
      if (currentStreak < 7) {
        recommendedGoals.add(_createGoal(
            'consistency_goal',
            'Construir Hábito Diario',
            'Mantener 7 días consecutivos de reflexión',
            'Crear una rutina sostenible de autocuidado',
            currentStreak,
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
            currentStreak,
            30,
            'días',
            '💎',
            'medium'
        ));
      }

      // Objetivo basado en mood promedio
      final currentMoodAvg = currentStats['components']['emotional_balance'] * 10 / 20; // Convertir a escala 1-10
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
      if (stressAnalysis['alert_level'] != 'normal') {
        final currentStressFreq = stressAnalysis['stress_frequency'];
        final targetStressFreq = (currentStressFreq * 0.6).clamp(0, 100); // Reducir 40%
        recommendedGoals.add(_createGoal(
            'stress_reduction',
            'Gestión del Estrés',
            'Reducir días estresantes a ${targetStressFreq.round()}%',
            'Desarrollar mejores estrategias de manejo del estrés',
            currentStressFreq.toDouble(),
            targetStressFreq,
            '% días',
            '🧘',
            'high'
        ));
      }

      // Objetivo de diversidad de experiencias
      final diversityScore = currentStats['components']['diversity'];
      if (diversityScore < 8) {
        recommendedGoals.add(_createGoal(
            'experience_diversity',
            'Ampliar Horizontes',
            'Explorar 5 categorías diferentes de momentos',
            'Enriquecer tu experiencia de vida',
            diversityScore,
            10.0,
            'categorías',
            '🌈',
            'medium'
        ));
      }

      // Objetivo de calidad de reflexión
      final reflectionQuality = currentStats['components']['reflection_quality'];
      if (reflectionQuality < 8) {
        recommendedGoals.add(_createGoal(
            'reflection_depth',
            'Reflexiones Más Profundas',
            'Mejorar la calidad de tus reflexiones',
            'Desarrollar mayor autoconocimiento',
            reflectionQuality,
            10.0,
            'calidad',
            '🤔',
            'medium'
        ));
      }

      // Establecer prioridades
      recommendedGoals.sort((a, b) =>
          _getPriorityWeight(b['priority']).compareTo(_getPriorityWeight(a['priority']))
      );

      return {
        'recommended_goals': recommendedGoals.take(3).toList(), // Top 3 más importantes
        'all_available_goals': recommendedGoals,
        'goal_categories': _categorizeGoals(recommendedGoals),
        'estimated_timeline': _estimateGoalTimeline(recommendedGoals.take(3).toList()),
        'success_probability': _calculateSuccessProbability(userId, recommendedGoals.take(3).toList()),
      };
    } catch (e) {
      _logger.e('Error generando objetivos: $e');
      return _getDefaultGoals();
    }
  }

  // ============================================================================
  // MÉTODOS AUXILIARES PARA CÁLCULOS AVANZADOS
  // ============================================================================

  double _calculateTrendDecline(List<double> values) {
    if (values.length < 2) return 0.0;

    double totalChange = 0;
    for (int i = 1; i < values.length; i++) {
      totalChange += values[i-1] - values[i]; // Cambio positivo = declive
    }
    return totalChange / (values.length - 1);
  }

  double _calculateWeeklyScore(double mood, double energy, double stress, double motivation) {
    return ((mood * 0.3 + energy * 0.25 + (10 - stress) * 0.25 + motivation * 0.2) / 10 * 100)
        .clamp(0, 100);
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

  int _getPriorityWeight(String priority) {
    switch (priority) {
      case 'high': return 3;
      case 'medium': return 2;
      case 'low': return 1;
      default: return 1;
    }
  }

  // Métodos por defecto en caso de error
  Map<String, dynamic> _getDefaultWellbeingScore() {
    return {
      'overall_score': 50,
      'level': 'En Progreso',
      'components': {},
      'insights': ['Continúa registrando tus reflexiones para obtener insights más precisos'],
      'improvement_areas': ['Consistencia'],
      'strengths': ['Autoconocimiento'],
    };
  }

  Map<String, dynamic> _getDefaultStressAnalysis() {
    return {
      'alert_level': 'normal',
      'alert_message': 'No hay suficientes datos para análisis de estrés',
      'recommendations': ['Continúa registrando tus estados para obtener análisis más precisos'],
    };
  }

  Map<String, dynamic> _getDefaultMoodDeclineAnalysis() {
    return {
      'concern_level': 'normal',
      'message': 'No hay suficientes datos para análisis de tendencias',
      'recommendations': ['Registra tus estados de ánimo regularmente para mejor seguimiento'],
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
    };
  }
}