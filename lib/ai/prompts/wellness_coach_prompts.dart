class WellnessCoachPrompts {
  static String buildDetailedWeeklySummaryPrompt({
    required List<Map<String, dynamic>> weeklyEntries,
    required List<Map<String, dynamic>> weeklyMoments,
    required String userName,
  }) {
    final entriesText = _formatDetailedEntries(weeklyEntries);
    final momentsText = _formatDetailedMoments(weeklyMoments);
    final emotionalJourney = _analyzeEmotionalJourney(weeklyEntries);
    final reflectionThemes = _extractReflectionThemes(weeklyEntries);

    return '''
Eres un coach de bienestar altamente empático y perspicaz con formación en psicología positiva. Tu misión es crear un análisis profundo y personalizado de la semana de $userName, citando frases específicas, momentos concretos y patrones sutiles.

DATOS COMPLETOS DE LA SEMANA:
$entriesText

MOMENTOS ESPECÍFICOS REGISTRADOS:
$momentsText

EVOLUCIÓN EMOCIONAL DETECTADA:
$emotionalJourney

TEMAS RECURRENTES EN LAS REFLEXIONES:
$reflectionThemes

INSTRUCCIONES PARA UN ANÁLISIS PROFUNDO:

1. ANÁLISIS NARRATIVO DETALLADO (150-200 palabras):
   - Cita frases específicas de las reflexiones entre comillas
   - Haz referencia a momentos concretos por fecha/día
   - Identifica la evolución emocional día a día
   - Conecta los estados de ánimo con eventos específicos mencionados
   - Usa un tono cálido, empático y genuinamente interesado

2. INSIGHTS ESPECÍFICOS Y PROFUNDOS (4-6 insights):
   - Analiza patrones sutiles en el lenguaje usado
   - Identifica correlaciones entre reflexiones y estados emocionales
   - Destaca fortalezas psicológicas mostradas en momentos difíciles
   - Señala inconsistencias o contrastes interesantes
   - Reconoce estrategias de afrontamiento que la persona ya usa
   - Identifica valores personales reflejados en las decisiones tomadas

3. SUGERENCIAS HIPERSPECÍFICAS (3-5 sugerencias):
   - Basadas en las palabras exactas y situaciones mencionadas
   - Que aprovechen las fortalezas ya demostradas
   - Que aborden los desafíos específicos identificados
   - Con acciones concretas y personalizadas
   - Que respeten el estilo personal de afrontamiento mostrado

4. MOMENTOS DESTACADOS PARA CELEBRAR:
   - Cita momentos específicos donde mostró crecimiento
   - Reconoce pequeñas victorias que podrían haber pasado desapercibidas
   - Valida emociones difíciles cuando fueron manejadas con sabiduría

5. PATRONES A OBSERVAR:
   - Identifica tendencias en horarios, actividades o pensamientos
   - Señala correlaciones entre actividades y bienestar
   - Menciona palabras o frases que se repiten en las reflexiones

IMPORTANTE:
- Cita frases literales de las reflexiones para dar especificidad
- Haz referencia a días específicos y momentos registrados
- Evita generalidades y ve directo a lo personal y específico
- Muestra que realmente has "escuchado" y procesado cada palabra
- Balancear validación empática con insights constructivos
- No inventes información que no esté en los datos

FORMATO DE RESPUESTA:
RESUMEN SEMANAL:
[Análisis narrativo profundo de 150-200 palabras citando frases específicas y momentos concretos]

INSIGHTS PROFUNDOS:
• [Insight específico basado en patrones de lenguaje o comportamiento]
• [Correlación identificada entre eventos y estados emocionales]
• [Fortaleza psicológica demostrada en situación específica]
• [Patrón sutil en la forma de procesar experiencias]
• [Valor personal evidente en las decisiones tomadas]

SUGERENCIAS PERSONALIZADAS:
• [Sugerencia específica basada en situación mencionada]
• [Recomendación que aprovecha fortaleza ya demostrada]
• [Estrategia para desafío específico identificado]
• [Acción concreta adaptada al estilo personal]

MOMENTOS PARA CELEBRAR:
• [Momento específico de crecimiento o sabiduría]
• [Pequeña victoria que merece reconocimiento]

PATRONES OBSERVADOS:
• [Tendencia específica en horarios/actividades/pensamientos]
• [Correlación entre actividad específica y bienestar]
''';
  }

  static String _formatDetailedEntries(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return 'No hay reflexiones registradas esta semana.';

    return entries.map((entry) {
      final date = entry['entry_date'] ?? 'Fecha desconocida';
      final reflection = entry['free_reflection'] ?? '';
      final mood = entry['mood_score'] ?? 'N/A';
      final energy = entry['energy_level'] ?? 'N/A';
      final stress = entry['stress_level'] ?? 'N/A';
      final sleep = entry['sleep_hours'] ?? 'N/A';
      final meditation = entry['meditation_minutes'] ?? 'N/A';
      final worthIt = entry['worth_it'] == 1 ? 'Sí' : (entry['worth_it'] == 0 ? 'No' : 'N/A');

      return '''
=== $date ===
REFLEXIÓN COMPLETA: "$reflection"
Estados registrados:
- Estado de ánimo: $mood/10
- Nivel de energía: $energy/10  
- Nivel de estrés: $stress/10
- Horas de sueño: $sleep
- Minutos de meditación: $meditation
- ¿Día que valió la pena?: $worthIt
''';
    }).join('\n\n');
  }

  static String _formatDetailedMoments(List<Map<String, dynamic>> moments) {
    if (moments.isEmpty) return 'No hay momentos específicos registrados esta semana.';

    final sortedMoments = [...moments]..sort((a, b) =>
        (a['entry_date'] ?? '').compareTo(b['entry_date'] ?? ''));

    return sortedMoments.map((moment) {
      final date = moment['entry_date'] ?? 'Fecha desconocida';
      final emoji = moment['emoji'] ?? '';
      final text = moment['text'] ?? '';
      final type = moment['type'] ?? 'neutral';
      final category = moment['category'] ?? 'general';

      final typeLabel = type == 'positive' ? '✨ POSITIVO' :
      type == 'negative' ? '💙 DESAFIANTE' : '⚪ NEUTRAL';

      return '''$date - $typeLabel ($category):
$emoji "$text"''';
    }).join('\n');
  }

  static String _analyzeEmotionalJourney(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return 'Sin datos suficientes para analizar evolución emocional.';

    final sortedEntries = [...entries]..sort((a, b) =>
        (a['entry_date'] ?? '').compareTo(b['entry_date'] ?? ''));

    String journey = 'EVOLUCIÓN EMOCIONAL DÍA A DÍA:\n';

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final date = entry['entry_date'] ?? 'Fecha desconocida';
      final mood = entry['mood_score'] ?? 0;
      final energy = entry['energy_level'] ?? 0;
      final stress = entry['stress_level'] ?? 0;

      String moodTrend = '';
      if (i > 0) {
        final prevMood = sortedEntries[i-1]['mood_score'] ?? 0;
        if (mood > prevMood + 1) moodTrend = ' ↗️ (mejora significativa)';
        else if (mood < prevMood - 1) moodTrend = ' ↘️ (bajada notable)';
        else if (mood > prevMood) moodTrend = ' ↗️ (ligera mejora)';
        else if (mood < prevMood) moodTrend = ' ↘️ (ligero descenso)';
        else moodTrend = ' ➡️ (estable)';
      }

      journey += '$date: Ánimo $mood/10, Energía $energy/10, Estrés $stress/10$moodTrend\n';
    }

    return journey;
  }

  static String _extractReflectionThemes(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return 'Sin reflexiones para analizar temas.';

    final allReflections = entries
        .map((e) => e['free_reflection'] as String? ?? '')
        .where((r) => r.isNotEmpty)
        .join(' ');

    if (allReflections.isEmpty) return 'No hay contenido en las reflexiones para analizar.';

    // Palabras/frases que indican temas importantes
    final themes = <String, List<String>>{};

    // Trabajo/Productividad
    final workWords = ['trabajo', 'proyecto', 'reunión', 'cliente', 'tarea', 'productivo',
      'oficina', 'equipo', 'jefe', 'deadline', 'programar', 'código'];
    final workMatches = workWords.where((word) =>
        allReflections.toLowerCase().contains(word)).toList();
    if (workMatches.isNotEmpty) {
      themes['Trabajo/Carrera'] = workMatches;
    }

    // Relaciones
    final relationWords = ['familia', 'amigo', 'pareja', 'conversación', 'conflicto',
      'apoyo', 'social', 'gente', 'solo', 'acompañado'];
    final relationMatches = relationWords.where((word) =>
        allReflections.toLowerCase().contains(word)).toList();
    if (relationMatches.isNotEmpty) {
      themes['Relaciones Sociales'] = relationMatches;
    }

    // Salud/Bienestar
    final healthWords = ['ejercicio', 'dormir', 'cansado', 'energía', 'salud',
      'médico', 'dolor', 'bienestar', 'meditación', 'relajar'];
    final healthMatches = healthWords.where((word) =>
        allReflections.toLowerCase().contains(word)).toList();
    if (healthMatches.isNotEmpty) {
      themes['Salud y Bienestar'] = healthMatches;
    }

    // Crecimiento Personal
    final growthWords = ['aprender', 'crecer', 'cambio', 'meta', 'objetivo',
      'mejorar', 'reflexionar', 'pensar', 'decidir'];
    final growthMatches = growthWords.where((word) =>
        allReflections.toLowerCase().contains(word)).toList();
    if (growthMatches.isNotEmpty) {
      themes['Crecimiento Personal'] = growthMatches;
    }

    if (themes.isEmpty) {
      return 'Temas variados en las reflexiones - requiere análisis más específico del contenido.';
    }

    String result = 'TEMAS IDENTIFICADOS EN LAS REFLEXIONES:\n';
    themes.forEach((theme, words) {
      result += '• $theme: menciones de [${words.join(', ')}]\n';
    });

    return result;
  }
}