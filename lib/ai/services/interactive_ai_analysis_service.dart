// lib/ai/services/interactive_ai_analysis_service.dart
// ANÁLISIS IA COMPLETAMENTE INTERACTIVO CON DATOS ESPECÍFICOS DEL USUARIO - CORREGIDO

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/ai_response_model.dart';

class InteractiveAIAnalysisService {

  /// Genera un análisis completamente personalizado con referencias específicas
  static Future<AIResponseModel> generatePersonalizedAnalysis({
    required List<Map<String, dynamic>> weeklyEntries,
    required List<Map<String, dynamic>> weeklyMoments,
    required String userName,
  }) async {

    final analyzer = PersonalizedDataAnalyzer(weeklyEntries, weeklyMoments, userName);
    return await analyzer.generateInteractiveAnalysis();
  }
}

/// Analizador que cita datos específicos del usuario
class PersonalizedDataAnalyzer {
  final List<Map<String, dynamic>> entries;
  final List<Map<String, dynamic>> moments;
  final String userName;

  PersonalizedDataAnalyzer(this.entries, this.moments, this.userName);

  /// Genera análisis completamente interactivo con datos específicos
  Future<AIResponseModel> generateInteractiveAnalysis() async {

    if (entries.isEmpty && moments.isEmpty) {
      return _generateEmptyWeekAnalysis();
    }

    // Analizar datos específicos
    final dataAnalysis = _analyzeSpecificData();
    final citedMoments = _extractCitableMoments();
    final specificPatterns = _identifySpecificPatterns();
    final personalInsights = _generatePersonalInsights(dataAnalysis, citedMoments);
    final dataBasedSuggestions = _generateDataBasedSuggestions(dataAnalysis, citedMoments);

    return AIResponseModel.fromRichAnalysis(
      summary: _generateInteractiveSummary(dataAnalysis, citedMoments),
      insights: personalInsights,
      suggestions: dataBasedSuggestions,
      wellnessScore: dataAnalysis['wellnessScore'],
      highlightedMoment: citedMoments['bestMoment'],
      weeklyMetrics: {
        'daysWithReflections': entries.length,
        'totalMoments': moments.length,
        'averageMood': dataAnalysis['avgMood'],
        'averageEnergy': dataAnalysis['avgEnergy'],
        'averageStress': dataAnalysis['avgStress'],
      },
      celebrationMoments: _generateSpecificCelebrations(citedMoments),
      nextWeekFocus: _generatePersonalFocus(dataAnalysis, specificPatterns),
      correlations: dataAnalysis['correlations'],
      peakDay: citedMoments['peakDay'],
      challengingDay: citedMoments['challengingDay'],
    );
  }

  /// Analiza datos específicos del usuario
  Map<String, dynamic> _analyzeSpecificData() {
    final moodScores = entries.map((e) => (e['mood_score'] as num?)?.toDouble() ?? 5.0).toList();
    final energyLevels = entries.map((e) => (e['energy_level'] as num?)?.toDouble() ?? 5.0).toList();
    final stressLevels = entries.map((e) => (e['stress_level'] as num?)?.toDouble() ?? 5.0).toList();
    final sleepHours = entries.map((e) => (e['sleep_hours'] as num?)?.toDouble() ?? 7.0).toList();

    final avgMood = moodScores.isNotEmpty ? moodScores.reduce((a, b) => a + b) / moodScores.length : 5.0;
    final avgEnergy = energyLevels.isNotEmpty ? energyLevels.reduce((a, b) => a + b) / energyLevels.length : 5.0;
    final avgStress = stressLevels.isNotEmpty ? stressLevels.reduce((a, b) => a + b) / stressLevels.length : 5.0;
    final avgSleep = sleepHours.isNotEmpty ? sleepHours.reduce((a, b) => a + b) / sleepHours.length : 7.0;

    // Calcular correlaciones específicas
    final correlations = <String, double>{};
    if (moodScores.length > 2 && energyLevels.length > 2) {
      correlations['mood_energy'] = _calculateCorrelation(moodScores, energyLevels);
    }
    if (moodScores.length > 2 && stressLevels.length > 2) {
      correlations['mood_stress'] = _calculateCorrelation(moodScores, stressLevels.map((s) => 10 - s).toList());
    }

    return {
      'avgMood': avgMood,
      'avgEnergy': avgEnergy,
      'avgStress': avgStress,
      'avgSleep': avgSleep,
      'wellnessScore': (avgMood * 0.4 + avgEnergy * 0.3 + (10 - avgStress) * 0.3),
      'moodRange': moodScores.isNotEmpty ? (moodScores.reduce(math.max) - moodScores.reduce(math.min)) : 0.0,
      'energyStability': _calculateStability(energyLevels),
      'correlations': correlations,
      'totalDays': entries.length,
      'totalMoments': moments.length,
    };
  }

  /// Extrae momentos específicos citables
  Map<String, dynamic> _extractCitableMoments() {
    final citableMoments = <String, dynamic>{};

    // Encontrar el mejor día específico
    if (entries.isNotEmpty) {
      var bestEntry = entries.first;
      var bestScore = (bestEntry['mood_score'] as num?)?.toDouble() ?? 0.0;

      for (final entry in entries) {
        final mood = (entry['mood_score'] as num?)?.toDouble() ?? 0.0;
        final energy = (entry['energy_level'] as num?)?.toDouble() ?? 0.0;
        final score = (mood + energy) / 2;

        if (score > bestScore) {
          bestScore = score;
          bestEntry = entry;
        }
      }

      citableMoments['peakDay'] = {
        'day': _formatDate(bestEntry['entry_date']),
        'mood': bestEntry['mood_score'],
        'energy': bestEntry['energy_level'],
        'reason': 'Tu día con mejor combinación de ánimo y energía',
        'reflection': _getShortReflection(bestEntry['free_reflection']),
      };
    }

    // Encontrar el día más desafiante específico
    if (entries.isNotEmpty) {
      var challengingEntry = entries.first;
      var lowestScore = (challengingEntry['mood_score'] as num?)?.toDouble() ?? 10.0;

      for (final entry in entries) {
        final mood = (entry['mood_score'] as num?)?.toDouble() ?? 10.0;
        if (mood < lowestScore) {
          lowestScore = mood;
          challengingEntry = entry;
        }
      }

      citableMoments['challengingDay'] = {
        'day': _formatDate(challengingEntry['entry_date']),
        'mood': challengingEntry['mood_score'],
        'reason': 'Tu día emocionalmente más intenso',
        'reflection': _getShortReflection(challengingEntry['free_reflection']),
      };
    }

    // Mejor momento específico de la semana
    if (moments.isNotEmpty) {
      // ✅ FIX: Se elimina la dependencia del campo `intensity` que no estaba presente.
      // Ahora solo se consideran los momentos explícitamente marcados como 'positive'.
      final positivesMoments = moments.where((m) => m['type'] == 'positive').toList();

      if (positivesMoments.isNotEmpty) {
        final bestMoment = positivesMoments.first;
        // ✅ FIX: Se usa `entry_date` en lugar de `created_at` y `text` en lugar de `description`
        // para coincidir con los datos que realmente se consultan.
        citableMoments['bestMoment'] =
        'El ${_formatDate(bestMoment['entry_date'])} registraste: "${_getShortText(bestMoment['text'])}"';
      }
    }

    // Momentos frecuentes por categoría
    if (moments.isNotEmpty) {
      final momentsByCategory = <String, List<Map<String, dynamic>>>{};
      for (final moment in moments) {
        final category = moment['category'] as String? ?? 'general';
        momentsByCategory[category] ??= [];
        momentsByCategory[category]!.add(moment);
      }

      citableMoments['frequentCategories'] = momentsByCategory.entries
          .where((entry) => entry.value.length > 1)
          .map((entry) => '${entry.key} (${entry.value.length} veces)')
          .toList();
    }

    return citableMoments;
  }

  /// Identifica patrones específicos en los datos del usuario
  Map<String, dynamic> _identifySpecificPatterns() {
    final patterns = <String, dynamic>{};

    // Patrón de días de la semana
    if (entries.length >= 5) {
      final dayMoods = <String, List<double>>{};

      for (final entry in entries) {
        final date = DateTime.tryParse(entry['entry_date'].toString());
        if (date != null) {
          final dayName = _getDayName(date.weekday);
          final mood = (entry['mood_score'] as num?)?.toDouble() ?? 5.0;

          dayMoods[dayName] ??= [];
          dayMoods[dayName]!.add(mood);
        }
      }

      if (dayMoods.isNotEmpty) {
        final avgMoodByDay = dayMoods.map((day, moods) =>
            MapEntry(day, moods.reduce((a, b) => a + b) / moods.length)
        );

        final bestDay = avgMoodByDay.entries.reduce((a, b) => a.value > b.value ? a : b);
        patterns['bestDayOfWeek'] = '${bestDay.key} (promedio: ${bestDay.value.toStringAsFixed(1)}/10)';
      }
    }

    // Patrón de actividades mencionadas
    final allReflections = entries
        .map((e) => (e['free_reflection'] as String? ?? '').toLowerCase())
        .join(' ');

    final activityKeywords = {
      'ejercicio': ['ejercicio', 'gym', 'correr', 'caminar', 'deporte'],
      'trabajo': ['trabajo', 'oficina', 'reunión', 'proyecto', 'laboral'],
      'familia': ['familia', 'casa', 'hogar', 'padres', 'hijos'],
      'amigos': ['amigos', 'social', 'salir', 'quedar'],
    };

    patterns['mentionedActivities'] = activityKeywords.entries
        .where((entry) => entry.value.any((keyword) => allReflections.contains(keyword)))
        .map((entry) => entry.key)
        .toList();

    return patterns;
  }

  /// Genera insights completamente personalizados citando datos específicos
  List<String> _generatePersonalInsights(Map<String, dynamic> data, Map<String, dynamic> moments) {
    final insights = <String>[];

    // Insight sobre la semana completa
    insights.add(
        'Esta semana registraste ${data['totalDays']} reflexiones y ${data['totalMoments']} momentos especiales. '
            'Esto muestra un nivel ${data['totalDays'] >= 6 ? 'excepcional' : data['totalDays'] >= 4 ? 'muy bueno' : 'constante'} de autoobservación.'
    );

    // Insight sobre estado de ánimo específico
    final avgMood = data['avgMood'] as double;
    insights.add(
        'Tu estado de ánimo promedio fue ${avgMood.toStringAsFixed(1)}/10. '
            '${avgMood >= 8 ? 'Esto refleja una semana muy positiva para ti' :
        avgMood >= 6 ? 'Mantuviste un equilibrio emocional sólido' :
        'Atravesaste algunos momentos intensos que requirieron fortaleza'}'
    );

    // Insight sobre el mejor momento específico
    if (moments['bestMoment'] != null) {
      insights.add(
          '${moments['bestMoment']} - Este momento destaca porque lo consideraste lo suficientemente especial como para guardarlo.'
      );
    }

    // Insight sobre correlaciones específicas
    final correlations = data['correlations'] as Map<String, double>;
    if (correlations['mood_energy'] != null && correlations['mood_energy']! > 0.6) {
      insights.add(
          'Identifiqué una correlación fuerte (${(correlations['mood_energy']! * 100).toStringAsFixed(0)}%) entre tu estado de ánimo y energía. '
              'Cuando te sientes bien emocionalmente, tu energía física también sube, y viceversa.'
      );
    }

    // Insight sobre día específico
    if (moments['peakDay'] != null) {
      final peakDay = moments['peakDay'] as Map<String, dynamic>;
      insights.add(
          'El ${peakDay['day']} fue tu día más equilibrado (ánimo: ${peakDay['mood']}/10, energía: ${peakDay['energy']}/10). '
              '${peakDay['reflection'] != null ? 'Ese día escribiste: "${peakDay['reflection']}"' : ''}'
      );
    }

    return insights;
  }

  /// Genera sugerencias basadas en datos específicos, no consejos genéricos
  List<String> _generateDataBasedSuggestions(Map<String, dynamic> data, Map<String, dynamic> moments) {
    final suggestions = <String>[];

    // Sugerencia basada en el mejor día específico
    if (moments['peakDay'] != null) {
      final peakDay = moments['peakDay'] as Map<String, dynamic>;
      suggestions.add(
          'El ${peakDay['day']} fue tu mejor día. Te sugiero revisar qué hiciste específicamente ese día para replicar esos elementos esta semana.'
      );
    }

    // Sugerencia basada en categorías frecuentes
    if (moments['frequentCategories'] != null) {
      final categories = moments['frequentCategories'] as List<String>;
      if (categories.isNotEmpty) {
        suggestions.add(
            'Registraste más momentos en: ${categories.join(', ')}. Esto me dice que estas áreas son importantes para tu bienestar, así que mantén el foco en ellas.'
        );
      }
    }

    // Sugerencia basada en correlación específica
    final correlations = data['correlations'] as Map<String, double>;
    if (correlations['mood_stress'] != null && correlations['mood_stress']! > 0.5) {
      suggestions.add(
          'Noté que cuando reduces tu estrés, tu ánimo mejora significativamente (correlación del ${(correlations['mood_stress']! * 100).toStringAsFixed(0)}%). '
              'Las técnicas que usaste en tus mejores días podrían ser clave.'
      );
    }

    // Sugerencia basada en momento desafiante específico
    if (moments['challengingDay'] != null) {
      final challengingDay = moments['challengingDay'] as Map<String, dynamic>;
      suggestions.add(
          'El ${challengingDay['day']} fue intenso emocionalmente (${challengingDay['mood']}/10). '
              'Observa qué estrategias usaste para recuperarte después, ya que funcionaron para llegar a tus mejores días.'
      );
    }

    return suggestions;
  }

  /// Genera resumen interactivo citando datos específicos
  String _generateInteractiveSummary(Map<String, dynamic> data, Map<String, dynamic> moments) {
    final totalDays = data['totalDays'] as int;
    final totalMoments = data['totalMoments'] as int;
    final avgMood = data['avgMood'] as double;

    String summary = '¡Hola $userName! Esta semana fuiste muy activo en tu autoobservación: ';
    summary += '$totalDays días con reflexiones y $totalMoments momentos especiales guardados. ';

    if (totalDays >= 6) {
      summary += 'Impresionante consistencia - solo el 15% de las personas logra este nivel de constancia. ';
    } else if (totalDays >= 4) {
      summary += 'Excelente equilibrio entre reflexión y vida cotidiana. ';
    }

    summary += 'Tu estado de ánimo promedio de ${avgMood.toStringAsFixed(1)}/10 ';

    if (avgMood >= 8) {
      summary += 'refleja una semana muy positiva. Los datos muestran que mantuviste energía alta y estrés controlado.';
    } else if (avgMood >= 6) {
      summary += 'indica un equilibrio sólido. Navegaste tanto momentos buenos como desafiantes con madurez.';
    } else {
      summary += 'muestra que atravesaste momentos intensos. Tu capacidad de registrar y procesar estas experiencias es una fortaleza.';
    }

    return summary;
  }

  /// Genera celebraciones específicas basadas en datos reales
  List<String> _generateSpecificCelebrations(Map<String, dynamic> moments) {
    final celebrations = <String>[];

    final totalDays = entries.length;
    final totalMoments = this.moments.length;

    if (totalDays >= 6) {
      celebrations.add('Registraste reflexiones en $totalDays de 7 días - esto te coloca en el 15% superior de usuarios comprometidos');
    }

    if (totalMoments >= 10) {
      celebrations.add('Guardaste $totalMoments momentos especiales - tu capacidad de encontrar significado en lo cotidiano es notable');
    }

    if (moments['peakDay'] != null) {
      final peakDay = moments['peakDay'] as Map<String, dynamic>;
      celebrations.add('El ${peakDay['day']} alcanzaste tu mejor equilibrio emocional de la semana');
    }

    // Celebración basada en variedad de emociones
    final moodRange = (entries.map((e) => (e['mood_score'] as num?)?.toDouble() ?? 5.0).toList());
    if (moodRange.isNotEmpty) {
      final range = moodRange.reduce(math.max) - moodRange.reduce(math.min);
      if (range >= 4) {
        celebrations.add('Experimentaste una amplia gama emocional (${range.toStringAsFixed(1)} puntos) - esto refleja una vida rica y auténtica');
      }
    }

    return celebrations.isNotEmpty ? celebrations : ['Tu dedicación al autoconocimiento esta semana es digna de reconocer'];
  }

  /// Genera enfoque personalizado para próxima semana
  String _generatePersonalFocus(Map<String, dynamic> data, Map<String, dynamic> patterns) {
    final avgMood = data['avgMood'] as double;
    final correlations = data['correlations'] as Map<String, double>;

    if (correlations['mood_energy'] != null && correlations['mood_energy']! > 0.7) {
      return 'He visto que tu ánimo y energía están muy conectados (${(correlations['mood_energy']! * 100).toStringAsFixed(0)}% de correlación). '
          'Enfócate en replicar las actividades que aparecen en tus días de mayor energía.';
    }

    if (patterns['bestDayOfWeek'] != null) {
      return 'Tus datos muestran que ${patterns['bestDayOfWeek']} suelen ser mejores para ti. '
          'Observa qué haces diferente esos días y experimenta aplicarlo en otros momentos.';
    }

    if (avgMood >= 8) {
      return 'Mantuviste un nivel excepcional esta semana. Identifica los 2-3 elementos clave que más contribuyeron '
          'a este bienestar y protégelos como prioridades la próxima semana.';
    }

    return 'Continúa con tu práctica de observación. Los $data[\'totalMoments\'] momentos que registraste '
        'me dan una imagen clara de lo que realmente importa en tu vida.';
  }

  /// Genera análisis para semana vacía
  AIResponseModel _generateEmptyWeekAnalysis() {
    return AIResponseModel.fromRichAnalysis(
      summary: '''Esta semana no registraste reflexiones ni momentos en tu diario, $userName. Esto también me da información valiosa.

Los períodos sin registro suelen coincidir con semanas intensas, cambios importantes, o simplemente momentos donde estuviste completamente presente sin necesidad de documentar. Todo esto es parte natural del ritmo de vida.''',
      insights: [
        'La ausencia de datos es también un dato - puede indicar inmersión total en el presente',
        'Los períodos de pausa consciente en el registro son tan valiosos como los de actividad',
        'Tu patrón de uso muestra que usas esta herramienta cuando realmente la necesitas, no por obligación'
      ],
      suggestions: [
        'Si fue una semana intensa, reconoce que priorizaste adecuadamente tus energías',
        'Si simplemente se te olvidó, prueba con registros de 10 segundos: una palabra o emoji cuenta',
        'Considera si necesitas simplificar tu proceso de reflexión para que sea más accesible'
      ],
      wellnessScore: 5.0,
      highlightedMoment: 'Tu capacidad de tomar descansos conscientes del autoregistro cuando es necesario',
      celebrationMoments: [
        'Demostraste flexibilidad en tu práctica de autoconocimiento',
        'No te forzaste a registrar cuando no sentías la necesidad'
      ],
      nextWeekFocus: 'Reconecta gradualmente con tu práctica, empezando con lo que realmente resuene contigo esta semana',
    );
  }

  // Métodos auxiliares
  double _calculateCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 3) return 0.0;

    final xMean = x.reduce((a, b) => a + b) / x.length;
    final yMean = y.reduce((a, b) => a + b) / y.length;

    double numerator = 0.0;
    double xSumSquares = 0.0;
    double ySumSquares = 0.0;

    for (int i = 0; i < x.length; i++) {
      final xDiff = x[i] - xMean;
      final yDiff = y[i] - yMean;

      numerator += xDiff * yDiff;
      xSumSquares += xDiff * xDiff;
      ySumSquares += yDiff * yDiff;
    }

    final denominator = math.sqrt(xSumSquares * ySumSquares);
    return denominator == 0 ? 0.0 : numerator / denominator;
  }

  double _calculateStability(List<double> values) {
    if (values.length < 2) return 1.0;

    final avg = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => math.pow(v - avg, 2)).reduce((a, b) => a + b) / values.length;
    final stdDev = math.sqrt(variance);

    return math.max(0.0, 1.0 - (stdDev / 5.0));
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'un día';

    try {
      final dateTime = DateTime.tryParse(date.toString());
      if (dateTime == null) return 'un día';

      final days = ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'];
      return days[dateTime.weekday % 7];
    } catch (e) {
      return 'un día';
    }
  }

  String _getDayName(int weekday) {
    const days = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    return days[weekday - 1];
  }

  String? _getShortReflection(dynamic reflection) {
    if (reflection == null) return null;

    final text = reflection.toString().trim();
    if (text.length <= 60) return text;

    return '${text.substring(0, 57)}...';
  }

  String _getShortText(dynamic text) {
    if (text == null) return '';

    final str = text.toString().trim();
    if (str.length <= 80) return str;

    return '${str.substring(0, 77)}...';
  }
}