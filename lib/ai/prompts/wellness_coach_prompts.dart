class WellnessCoachPrompts {
  static String buildWeeklySummaryPrompt({
    required List<Map<String, dynamic>> weeklyEntries,
    required List<Map<String, dynamic>> weeklyMoments,
    required String userName,
  }) {
    final entriesText = _formatEntries(weeklyEntries);
    final momentsText = _formatMoments(weeklyMoments);

    return '''
Eres un coach de bienestar empático y perspicaz. Analiza la semana de $userName y crea un resumen personalizado.

DATOS DE LA SEMANA:
$entriesText

MOMENTOS DESTACADOS:
$momentsText

INSTRUCCIONES:
- Crea un análisis empático y constructivo
- Identifica patrones en emociones, energía y bienestar
- Destaca logros y momentos positivos
- Sugiere áreas de mejora sin ser crítico
- Usa un tono cálido y motivador
- Limítate a 200 palabras máximo

FORMATO DE RESPUESTA:
RESUMEN:
[Párrafo narrativo sobre la semana]

INSIGHTS:
- [Patrón o observación importante]
- [Otro insight relevante]
- [Tercer insight si es necesario]

SUGERENCIAS:
- [Sugerencia constructiva]
- [Otra recomendación]
- [Tercera sugerencia opcional]
''';
  }

  static String _formatEntries(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return 'No hay reflexiones registradas esta semana.';

    return entries.map((entry) {
      final date = entry['entry_date'] ?? 'Fecha desconocida';
      final reflection = entry['free_reflection'] ?? '';
      final mood = entry['mood_score'] ?? 'N/A';
      final energy = entry['energy_level'] ?? 'N/A';
      final stress = entry['stress_level'] ?? 'N/A';
      final worthIt = entry['worth_it'] == 1 ? 'Sí' : (entry['worth_it'] == 0 ? 'No' : 'N/A');

      return '''
Día $date:
- Reflexión: "$reflection"
- Estado de ánimo: $mood/10
- Energía: $energy/10  
- Estrés: $stress/10
- ¿Día que valió la pena?: $worthIt
''';
    }).join('\n');
  }

  static String _formatMoments(List<Map<String, dynamic>> moments) {
    if (moments.isEmpty) return 'No hay momentos registrados esta semana.';

    final groupedMoments = <String, List<Map<String, dynamic>>>{};
    for (final moment in moments) {
      final type = moment['type'] ?? 'neutral';
      groupedMoments.putIfAbsent(type, () => []).add(moment);
    }

    String result = '';
    groupedMoments.forEach((type, momentsList) {
      final typeLabel = type == 'positive' ? 'Momentos Positivos' :
      type == 'negative' ? 'Momentos Desafiantes' : 'Momentos Neutros';
      result += '$typeLabel:\n';
      for (final moment in momentsList) {
        result += '- ${moment['emoji']} ${moment['text']}\n';
      }
      result += '\n';
    });

    return result;
  }
}