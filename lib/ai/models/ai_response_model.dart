// lib/ai/models/ai_response_model.dart
// MODELO EXPANDIDO PARA ANÁLISIS RICO

class AIResponseModel {
  // Campos básicos (existentes)
  final String summary;
  final List<String> insights;
  final List<String> suggestions;
  final double confidenceScore;
  final DateTime generatedAt;

  // ✅ NUEVOS CAMPOS PARA ANÁLISIS RICO
  final double? wellnessScore;           // Puntuación de bienestar 0-10
  final String? highlightedMoment;       // Momento para celebrar específico
  final Map<String, double>? correlations; // Correlaciones clave
  final Map<String, dynamic>? peakDay;   // Mejor día con detalles
  final Map<String, dynamic>? challengingDay; // Día más desafiante
  final List<String>? celebrationMoments; // Momentos específicos para celebrar
  final Map<String, dynamic>? weeklyMetrics; // Métricas avanzadas
  final String? nextWeekFocus;           // Enfoque para próxima semana
  final List<String>? behavioralPatterns; // Patrones identificados
  final Map<String, String>? trendAnalysis; // Análisis de tendencias

  const AIResponseModel({
    required this.summary,
    required this.insights,
    required this.suggestions,
    required this.confidenceScore,
    required this.generatedAt,
    // Nuevos campos opcionales
    this.wellnessScore,
    this.highlightedMoment,
    this.correlations,
    this.peakDay,
    this.challengingDay,
    this.celebrationMoments,
    this.weeklyMetrics,
    this.nextWeekFocus,
    this.behavioralPatterns,
    this.trendAnalysis,
  });

  factory AIResponseModel.fromText(String rawResponse) {
    // Procesar la respuesta del modelo (versión mejorada)
    return AIResponseModel(
      summary: _extractSummary(rawResponse),
      insights: _extractInsights(rawResponse),
      suggestions: _extractSuggestions(rawResponse),
      confidenceScore: 0.8,
      generatedAt: DateTime.now(),
      // ✅ EXTRAER NUEVOS CAMPOS
      wellnessScore: _extractWellnessScore(rawResponse),
      highlightedMoment: _extractHighlightedMoment(rawResponse),
      correlations: _extractCorrelations(rawResponse),
      peakDay: _extractPeakDay(rawResponse),
      challengingDay: _extractChallengingDay(rawResponse),
      celebrationMoments: _extractCelebrationMoments(rawResponse),
      weeklyMetrics: _extractWeeklyMetrics(rawResponse),
      nextWeekFocus: _extractNextWeekFocus(rawResponse),
      behavioralPatterns: _extractBehavioralPatterns(rawResponse),
      trendAnalysis: _extractTrendAnalysis(rawResponse),
    );
  }

  /// Constructor mejorado para análisis rico
  factory AIResponseModel.fromRichAnalysis({
    required String summary,
    required List<String> insights,
    required List<String> suggestions,
    required double wellnessScore,
    String? highlightedMoment,
    Map<String, double>? correlations,
    Map<String, dynamic>? peakDay,
    Map<String, dynamic>? challengingDay,
    List<String>? celebrationMoments,
    Map<String, dynamic>? weeklyMetrics,
    String? nextWeekFocus,
    List<String>? behavioralPatterns,
    Map<String, String>? trendAnalysis,
  }) {
    return AIResponseModel(
      summary: summary,
      insights: insights,
      suggestions: suggestions,
      confidenceScore: 0.9, // Mayor confianza para análisis rico
      generatedAt: DateTime.now(),
      wellnessScore: wellnessScore,
      highlightedMoment: highlightedMoment,
      correlations: correlations,
      peakDay: peakDay,
      challengingDay: challengingDay,
      celebrationMoments: celebrationMoments,
      weeklyMetrics: weeklyMetrics,
      nextWeekFocus: nextWeekFocus,
      behavioralPatterns: behavioralPatterns,
      trendAnalysis: trendAnalysis,
    );
  }

  // =============================================================================
  // MÉTODOS DE EXTRACCIÓN MEJORADOS
  // =============================================================================

  static String _extractSummary(String text) {
    // Buscar patrones más específicos del nuevo formato
    final patterns = [
      RegExp(r'\*\*RESUMEN SEMANAL:\*\*(.*?)(?:\*\*[A-Z]|$)', dotAll: true),
      RegExp(r'Esta semana(.*?)(?:\*\*|$)', dotAll: true),
      RegExp(r'RESUMEN:(.*?)(?:INSIGHTS:|$)', dotAll: true),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1)!.trim().replaceAll('*', '');
      }
    }

    // Fallback: primeras 3 líneas
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    return lines.take(3).join(' ').trim();
  }

  static List<String> _extractInsights(String text) {
    final patterns = [
      RegExp(r'\*\*💡 INSIGHTS CLAVE[^:]*:\*\*(.*?)(?:\*\*🎯|$)', dotAll: true),
      RegExp(r'\*\*INSIGHTS[^:]*:\*\*(.*?)(?:\*\*[A-Z]|$)', dotAll: true),
      RegExp(r'INSIGHTS:(.*?)(?:SUGERENCIAS:|$)', dotAll: true),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1)!
            .split('\n')
            .where((line) => line.trim().startsWith('•') || line.trim().startsWith('-'))
            .map((line) => line.trim().replaceFirst(RegExp(r'^[•\-]\s*'), ''))
            .where((insight) => insight.isNotEmpty)
            .toList();
      }
    }

    return [];
  }

  static List<String> _extractSuggestions(String text) {
    final patterns = [
      RegExp(r'\*\*🎯 RECOMENDACIONES[^:]*:\*\*(.*?)(?:\*\*🎉|$)', dotAll: true),
      RegExp(r'\*\*RECOMENDACIONES[^:]*:\*\*(.*?)(?:\*\*[A-Z]|$)', dotAll: true),
      RegExp(r'SUGERENCIAS:(.*?)$', dotAll: true),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1)!
            .split('\n')
            .where((line) => line.trim().startsWith('•') || line.trim().startsWith('-'))
            .map((line) => line.trim().replaceFirst(RegExp(r'^[•\-]\s*'), ''))
            .where((suggestion) => suggestion.isNotEmpty)
            .toList();
      }
    }

    return [];
  }

  // ✅ NUEVOS EXTRACTORS PARA CAMPOS RICOS

  static double? _extractWellnessScore(String text) {
    final scorePattern = RegExp(r'puntuación de bienestar[:\s]*(\d+\.?\d*)/10', caseSensitive: true);
    final match = scorePattern.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  static String? _extractHighlightedMoment(String text) {
    final patterns = [
      RegExp(r'\*\*🎉 MOMENTOS PARA CELEBRAR:\*\*(.*?)(?:\*\*🔮|$)', dotAll: true),
      RegExp(r'MOMENTO DESTACADO:(.*?)(?:\n|$)', dotAll: true),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final moment = match.group(1)!.trim();
        // Extraer el primer momento específico
        final lines = moment.split('\n').where((line) => line.trim().isNotEmpty).toList();
        if (lines.isNotEmpty) {
          return lines.first.trim().replaceFirst(RegExp(r'^[•\-]\s*'), '');
        }
      }
    }

    return null;
  }

  static Map<String, double>? _extractCorrelations(String text) {
    final correlations = <String, double>{};

    // Buscar patrones como "correlación ejercicio-energía (0.85)"
    final correlationPattern = RegExp(r'correlación ([^(]+)\((\d+\.?\d*)\)', caseSensitive: true);
    final matches = correlationPattern.allMatches(text);

    for (final match in matches) {
      final key = match.group(1)!.trim();
      final value = double.tryParse(match.group(2)!);
      if (value != null) {
        correlations[key] = value;
      }
    }

    return correlations.isNotEmpty ? correlations : null;
  }

  static Map<String, dynamic>? _extractPeakDay(String text) {
    final peakPattern = RegExp(r'(\w+) fue tu día más brillante[^✨]*✨', caseSensitive: true);
    final match = peakPattern.firstMatch(text);

    if (match != null) {
      return {
        'day': match.group(1)!,
        'reason': 'Día más brillante de la semana',
        'type': 'peak'
      };
    }

    return null;
  }

  static Map<String, dynamic>? _extractChallengingDay(String text) {
    final challengingPattern = RegExp(r'(\w+) fue tu día más desafiante', caseSensitive: true);
    final match = challengingPattern.firstMatch(text);

    if (match != null) {
      return {
        'day': match.group(1)!,
        'reason': 'Día más desafiante',
        'type': 'challenging'
      };
    }

    return null;
  }

  static List<String>? _extractCelebrationMoments(String text) {
    final celebrationPattern = RegExp(r'\*\*🎉 MOMENTOS PARA CELEBRAR:\*\*(.*?)(?:\*\*|$)', dotAll: true);
    final match = celebrationPattern.firstMatch(text);

    if (match != null) {
      return match.group(1)!
          .split('\n')
          .where((line) => line.trim().startsWith('•') || line.trim().startsWith('-'))
          .map((line) => line.trim().replaceFirst(RegExp(r'^[•\-]\s*'), ''))
          .where((moment) => moment.isNotEmpty)
          .toList();
    }

    return null;
  }

  static Map<String, dynamic>? _extractWeeklyMetrics(String text) {
    final metrics = <String, dynamic>{};

    // Extraer días registrados
    final daysPattern = RegExp(r'(\d+) días con reflexiones', caseSensitive: true);
    final daysMatch = daysPattern.firstMatch(text);
    if (daysMatch != null) {
      metrics['daysWithReflections'] = int.tryParse(daysMatch.group(1)!);
    }

    // Extraer estado de ánimo promedio
    final moodPattern = RegExp(r'estado de ánimo promedio de (\d+\.?\d*)/10', caseSensitive: true);
    final moodMatch = moodPattern.firstMatch(text);
    if (moodMatch != null) {
      metrics['averageMood'] = double.tryParse(moodMatch.group(1)!);
    }

    return metrics.isNotEmpty ? metrics : null;
  }

  static String? _extractNextWeekFocus(String text) {
    final focusPattern = RegExp(r'\*\*🔮 ENFOQUE PARA LA PRÓXIMA SEMANA:\*\*(.*?)(?:\*\*|$)', dotAll: true);
    final match = focusPattern.firstMatch(text);

    if (match != null) {
      return match.group(1)!.trim();
    }

    return null;
  }

  static List<String>? _extractBehavioralPatterns(String text) {
    // Extraer patrones mencionados en el texto
    final patterns = <String>[];

    if (text.toLowerCase().contains('correlación') && text.toLowerCase().contains('fuerte')) {
      patterns.add('Correlaciones fuertes identificadas');
    }

    if (text.toLowerCase().contains('consistencia') && text.toLowerCase().contains('reflexiv')) {
      patterns.add('Patrón de reflexión consistente');
    }

    if (text.toLowerCase().contains('resilencia') || text.toLowerCase().contains('recuperación')) {
      patterns.add('Capacidad de recuperación demostrada');
    }

    return patterns.isNotEmpty ? patterns : null;
  }

  static Map<String, String>? _extractTrendAnalysis(String text) {
    final trends = <String, String>{};

    if (text.toLowerCase().contains('tendencia ascendente')) {
      trends['mood'] = 'ascendente';
    } else if (text.toLowerCase().contains('tendencia descendente')) {
      trends['mood'] = 'descendente';
    } else {
      trends['mood'] = 'estable';
    }

    return trends.isNotEmpty ? trends : null;
  }

  // =============================================================================
  // MÉTODOS DE UTILIDAD
  // =============================================================================

  /// Indica si este análisis contiene datos ricos
  bool get hasRichData => wellnessScore != null ||
      correlations != null ||
      celebrationMoments != null;

  /// Obtiene un resumen rápido de las métricas principales
  String get quickMetricsSummary {
    final parts = <String>[];

    if (wellnessScore != null) {
      parts.add('Bienestar: ${wellnessScore!.toStringAsFixed(1)}/10');
    }

    if (weeklyMetrics?['daysWithReflections'] != null) {
      parts.add('${weeklyMetrics!['daysWithReflections']} días registrados');
    }

    if (weeklyMetrics?['averageMood'] != null) {
      parts.add('Ánimo: ${weeklyMetrics!['averageMood'].toStringAsFixed(1)}/10');
    }

    return parts.join(' • ');
  }

  /// Obtiene la correlación más fuerte
  MapEntry<String, double>? get strongestCorrelation {
    if (correlations == null || correlations!.isEmpty) return null;

    return correlations!.entries.reduce(
            (a, b) => a.value.abs() > b.value.abs() ? a : b
    );
  }
}