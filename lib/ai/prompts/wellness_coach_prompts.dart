// lib/ai/prompts/wellness_coach_prompts.dart
// PROMPTS OPTIMIZADOS PARA PHI-3.5 CON MEJOR EFECTIVIDAD
import 'dart:math' as math;
class WellnessCoachPrompts {

  /// Construye un prompt optimizado para Phi-3.5 con análisis semanal mejorado
  static String buildOptimizedWeeklySummaryPrompt({
    required List<Map<String, dynamic>> weeklyEntries,
    required List<Map<String, dynamic>> weeklyMoments,
    required String userName,
  }) {

    final userData = _formatCompactUserData(weeklyEntries, weeklyMoments);
    final analysisContext = _buildAnalysisContext(weeklyEntries, weeklyMoments);

    return '''<|system|>
Eres un coach de bienestar experto en psicología positiva. Analiza datos semanales y proporciona insights personalizados, empáticos y accionables. Usa un tono cálido pero profesional.
<|end|>

<|user|>
Analiza el bienestar semanal de $userName:

DATOS DE LA SEMANA:
$userData

CONTEXTO:
$analysisContext

Genera un análisis siguiendo esta estructura EXACTA:

**RESUMEN SEMANAL:** (2-3 oraciones sobre patrones clave)

**INSIGHTS PRINCIPALES:**
• [Patrón específico observado]
• [Correlación importante identificada] 
• [Fortaleza demostrada]

**RECOMENDACIONES:**
• [Acción específica basada en datos]
• [Optimización sugerida]
• [Enfoque para próxima semana]

**MOMENTO DESTACADO:**
[Celebra un logro específico de la semana]

Incluye datos específicos y citas cuando sea relevante. Mantén la respuesta motivadora y práctica.
<|end|>

<|assistant|>''';
  }

  /// Prompt especializado para análisis de tendencias emocionales
  static String buildEmotionalTrendsPrompt({
    required List<Map<String, dynamic>> weeklyEntries,
    required String userName,
  }) {

    final emotionalData = _extractEmotionalData(weeklyEntries);

    return '''<|system|>
Especialista en análisis emocional y patrones de bienestar. Identifica tendencias, triggers y fortalezas emocionales basándote en datos objetivos.
<|end|>

<|user|>
Analiza las tendencias emocionales de $userName:

$emotionalData

Identifica:
1. Patrón emocional dominante
2. Triggers o factores influyentes
3. Estrategias de regulación evidentes
4. Áreas de crecimiento

Respuesta concisa y específica.
<|end|>

<|assistant|>''';
  }

  /// Prompt para análisis de correlaciones entre actividades y bienestar
  static String buildCorrelationAnalysisPrompt({
    required List<Map<String, dynamic>> weeklyEntries,
    required List<Map<String, dynamic>> weeklyMoments,
    required String userName,
  }) {

    final correlationData = _buildCorrelationData(weeklyEntries, weeklyMoments);

    return '''<|system|>
Analista de datos de bienestar. Identifica correlaciones significativas entre actividades, hábitos y estados de bienestar para generar insights accionables.
<|end|>

<|user|>
Encuentra correlaciones en los datos de $userName:

$correlationData

Identifica las 3 correlaciones más importantes entre:
- Actividades y estado de ánimo
- Hábitos de sueño y energía  
- Factores de estrés y recuperación

Para cada correlación, explica:
1. La relación observada
2. La fuerza de la correlación
3. Recomendación práctica

<|end|>

<|assistant|>''';
  }

  /// Prompt para generar recomendaciones personalizadas
  static String buildPersonalizedRecommendationsPrompt({
    required Map<String, dynamic> userProfile,
    required Map<String, dynamic> weeklyMetrics,
    required String userName,
  }) {

    final profileData = _formatUserProfile(userProfile);
    final metricsData = _formatWeeklyMetrics(weeklyMetrics);

    return '''<|system|>
Coach de bienestar personalizado. Genera recomendaciones específicas basadas en el perfil único del usuario y sus métricas actuales. Prioriza acciones de alto impacto y factibles.
<|end|>

<|user|>
Genera recomendaciones para $userName:

PERFIL DEL USUARIO:
$profileData

MÉTRICAS ACTUALES:
$metricsData

Proporciona 3 recomendaciones priorizadas:

1. **ALTA PRIORIDAD:** [Área más crítica para mejorar]
   - Acción específica
   - Por qué es importante
   - Cómo medir progreso

2. **DESARROLLO:** [Optimización de fortaleza existente]
   - Estrategia de mejora
   - Beneficio esperado
   - Indicadores de éxito

3. **EXPERIMENTAL:** [Nueva área de exploración]
   - Práctica sugerida
   - Duración de prueba
   - Métricas a observar

<|end|>

<|assistant|>''';
  }

  /// Prompt para análisis de resiliencia y afrontamiento
  static String buildResilienceAnalysisPrompt({
    required List<Map<String, dynamic>> challengingMoments,
    required List<Map<String, dynamic>> recoveryPatterns,
    required String userName,
  }) {

    final resilienceData = _buildResilienceData(challengingMoments, recoveryPatterns);

    return '''<|system|>
Experto en resiliencia psicológica. Analiza cómo las personas manejan desafíos y se recuperan, identificando fortalezas y áreas de desarrollo en sus estrategias de afrontamiento.
<|end|>

<|user|>
Evalúa la resiliencia de $userName:

$resilienceData

Analiza:
1. **Estrategias de afrontamiento** más efectivas
2. **Patrones de recuperación** observados
3. **Fortalezas resilientes** demostradas
4. **Oportunidades de desarrollo** de la resiliencia

Proporciona un análisis específico y constructivo.
<|end|>

<|assistant|>''';
  }

  // =============================================================================
  // MÉTODOS AUXILIARES PARA FORMATEO DE DATOS
  // =============================================================================

  static String _formatCompactUserData(
      List<Map<String, dynamic>> entries,
      List<Map<String, dynamic>> moments,
      ) {
    final buffer = StringBuffer();

    if (entries.isEmpty && moments.isEmpty) {
      return 'Sin datos registrados esta semana.';
    }

    // Métricas principales
    if (entries.isNotEmpty) {
      final avgMood = _calculateAverage(entries, 'mood_score');
      final avgEnergy = _calculateAverage(entries, 'energy_level');
      final avgStress = _calculateAverage(entries, 'stress_level');
      final avgSleep = _calculateAverage(entries, 'sleep_hours');

      buffer.writeln('MÉTRICAS: ${entries.length} días registrados');
      buffer.writeln('- Ánimo promedio: ${avgMood.toStringAsFixed(1)}/10');
      if (avgEnergy > 0) buffer.writeln('- Energía promedio: ${avgEnergy.toStringAsFixed(1)}/10');
      if (avgStress > 0) buffer.writeln('- Estrés promedio: ${avgStress.toStringAsFixed(1)}/10');
      if (avgSleep > 0) buffer.writeln('- Sueño promedio: ${avgSleep.toStringAsFixed(1)}h');
    }

    // Reflexiones destacadas (máximo 2 más significativas)
    final significantReflections = entries
        .where((e) => (e['free_reflection'] as String? ?? '').length > 30)
        .take(2)
        .map((e) => '"${(e['free_reflection'] as String).substring(0, math.min(100, (e['free_reflection'] as String).length))}..."')
        .toList();

    if (significantReflections.isNotEmpty) {
      buffer.writeln('\nREFLEXIONES CLAVE:');
      for (int i = 0; i < significantReflections.length; i++) {
        buffer.writeln('${i + 1}. ${significantReflections[i]}');
      }
    }

    // Momentos especiales
    if (moments.isNotEmpty) {
      final positiveCount = moments.where((m) => m['type'] == 'positive').length;
      final challengingCount = moments.where((m) => m['type'] == 'challenging').length;
      buffer.writeln('\nMOMENTOS: $positiveCount positivos, $challengingCount desafiantes');
    }

    return buffer.toString();
  }

  static String _buildAnalysisContext(
      List<Map<String, dynamic>> entries,
      List<Map<String, dynamic>> moments,
      ) {
    final buffer = StringBuffer();

    if (entries.isEmpty) {
      return 'Semana sin reflexiones registradas.';
    }

    // Tendencias
    final moodScores = entries.map((e) => (e['mood_score'] as num?)?.toDouble() ?? 5.0).toList();
    if (moodScores.length > 1) {
      final trend = _calculateTrend(moodScores);
      buffer.writeln('Tendencia del ánimo: ${trend > 0.5 ? 'ascendente' : trend < -0.5 ? 'descendente' : 'estable'}');
    }

    // Días más significativos
    if (entries.isNotEmpty) {
      final bestDay = _findBestDay(entries);
      final challengingDay = _findMostChallengingDay(entries);

      if (bestDay.isNotEmpty) {
        buffer.writeln('Mejor día: ${bestDay['date']} (ánimo: ${bestDay['mood']}/10)');
      }
      if (challengingDay.isNotEmpty) {
        buffer.writeln('Día desafiante: ${challengingDay['date']} (ánimo: ${challengingDay['mood']}/10)');
      }
    }

    // Patrones de consistencia
    final consistencyScore = entries.length / 7.0;
    buffer.writeln('Consistencia reflexiva: ${(consistencyScore * 100).toStringAsFixed(0)}%');

    return buffer.toString();
  }

  static String _extractEmotionalData(List<Map<String, dynamic>> entries) {
    final buffer = StringBuffer();

    if (entries.isEmpty) return 'Sin datos emocionales.';

    final moodScores = entries.map((e) => (e['mood_score'] as num?)?.toDouble() ?? 5.0).toList();
    final energyLevels = entries.map((e) => (e['energy_level'] as num?)?.toDouble() ?? 5.0).toList();
    final stressLevels = entries.map((e) => (e['stress_level'] as num?)?.toDouble() ?? 5.0).toList();

    buffer.writeln('DATOS EMOCIONALES (${entries.length} días):');
    buffer.writeln('Ánimo: [${moodScores.map((s) => s.toStringAsFixed(1)).join(', ')}]');
    buffer.writeln('Energía: [${energyLevels.map((e) => e.toStringAsFixed(1)).join(', ')}]');
    buffer.writeln('Estrés: [${stressLevels.map((s) => s.toStringAsFixed(1)).join(', ')}]');

    // Variabilidad emocional
    final moodRange = moodScores.isNotEmpty ?
    (moodScores.reduce(math.max) - moodScores.reduce(math.min)) : 0.0;
    buffer.writeln('Amplitud emocional: ${moodRange.toStringAsFixed(1)} puntos');

    return buffer.toString();
  }

  static String _buildCorrelationData(
      List<Map<String, dynamic>> entries,
      List<Map<String, dynamic>> moments,
      ) {
    final buffer = StringBuffer();

    if (entries.isEmpty) return 'Sin datos para correlaciones.';

    buffer.writeln('DATOS PARA ANÁLISIS DE CORRELACIONES:');

    // Datos por día
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final date = entry['entry_date']?.toString().split(' ')[0] ?? 'Día ${i+1}';
      final mood = entry['mood_score'] ?? 'N/A';
      final energy = entry['energy_level'] ?? 'N/A';
      final stress = entry['stress_level'] ?? 'N/A';
      final sleep = entry['sleep_hours'] ?? 'N/A';

      buffer.writeln('$date: Ánimo=$mood, Energía=$energy, Estrés=$stress, Sueño=${sleep}h');
    }

    // Actividades y tags
    final allTags = entries.expand((e) =>
        (e['positive_tags'] as List<dynamic>? ?? []).cast<String>()
    ).toList();

    if (allTags.isNotEmpty) {
      final tagFrequency = <String, int>{};
      for (final tag in allTags) {
        tagFrequency[tag] = (tagFrequency[tag] ?? 0) + 1;
      }

      buffer.writeln('\nACTIVIDADES FRECUENTES:');
      tagFrequency.entries
          .where((entry) => entry.value > 1)
          .forEach((entry) => buffer.writeln('- ${entry.key}: ${entry.value} veces'));
    }

    return buffer.toString();
  }

  static String _formatUserProfile(Map<String, dynamic> profile) {
    final buffer = StringBuffer();

    buffer.writeln('PERFIL DEL USUARIO:');
    buffer.writeln('- Edad: ${profile['age'] ?? 'No especificada'}');
    buffer.writeln('- Objetivos: ${profile['goals'] ?? 'Bienestar general'}');
    buffer.writeln('- Preferencias: ${profile['preferences'] ?? 'No especificadas'}');
    buffer.writeln('- Historial: ${profile['history'] ?? 'Usuario nuevo'}');

    return buffer.toString();
  }

  static String _formatWeeklyMetrics(Map<String, dynamic> metrics) {
    final buffer = StringBuffer();

    buffer.writeln('MÉTRICAS DE LA SEMANA:');
    buffer.writeln('- Puntuación de bienestar: ${((metrics['wellnessScore'] ?? 0.5) * 10).toStringAsFixed(1)}/10');
    buffer.writeln('- Consistencia reflexiva: ${((metrics['reflectionConsistency'] ?? 0) * 100).toStringAsFixed(0)}%');
    buffer.writeln('- Estabilidad emocional: ${((metrics['emotionalStability'] ?? 0.5) * 10).toStringAsFixed(1)}/10');
    buffer.writeln('- Gestión del estrés: ${metrics['stressManagement'] ?? 'Regular'}');

    return buffer.toString();
  }

  static String _buildResilienceData(
      List<Map<String, dynamic>> challenges,
      List<Map<String, dynamic>> recoveries,
      ) {
    final buffer = StringBuffer();

    buffer.writeln('ANÁLISIS DE RESILIENCIA:');

    if (challenges.isNotEmpty) {
      buffer.writeln('\nMOMENTOS DESAFIANTES:');
      for (final challenge in challenges.take(3)) {
        buffer.writeln('- ${challenge['description'] ?? 'Desafío registrado'}');
        buffer.writeln('  Impacto: ${challenge['impact'] ?? 'Moderado'}');
      }
    }

    if (recoveries.isNotEmpty) {
      buffer.writeln('\nPATRONES DE RECUPERACIÓN:');
      for (final recovery in recoveries.take(3)) {
        buffer.writeln('- ${recovery['strategy'] ?? 'Estrategia aplicada'}');
        buffer.writeln('  Efectividad: ${recovery['effectiveness'] ?? 'Moderada'}');
      }
    }

    return buffer.toString();
  }

  // Métodos auxiliares para cálculos
  static double _calculateAverage(List<Map<String, dynamic>> entries, String field) {
    final values = entries
        .map((e) => (e[field] as num?)?.toDouble())
        .where((v) => v != null && v > 0)
        .cast<double>()
        .toList();

    return values.isEmpty ? 0.0 : values.reduce((a, b) => a + b) / values.length;
  }

  static double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;

    double totalChange = 0.0;
    for (int i = 1; i < values.length; i++) {
      totalChange += values[i] - values[i-1];
    }
    return totalChange / (values.length - 1);
  }

  static Map<String, dynamic> _findBestDay(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return {};

    Map<String, dynamic> best = {};
    double bestScore = -1;

    for (final entry in entries) {
      final mood = (entry['mood_score'] as num?)?.toDouble() ?? 5.0;
      if (mood > bestScore) {
        bestScore = mood;
        best = {
          'date': entry['entry_date']?.toString().split(' ')[0] ?? 'Desconocido',
          'mood': mood,
        };
      }
    }

    return best;
  }

  static Map<String, dynamic> _findMostChallengingDay(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return {};

    Map<String, dynamic> challenging = {};
    double lowestScore = 11;

    for (final entry in entries) {
      final mood = (entry['mood_score'] as num?)?.toDouble() ?? 5.0;
      if (mood < lowestScore) {
        lowestScore = mood;
        challenging = {
          'date': entry['entry_date']?.toString().split(' ')[0] ?? 'Desconocido',
          'mood': mood,
        };
      }
    }

    return challenging;
  }
}

// Importar math para usar en los cálculos
