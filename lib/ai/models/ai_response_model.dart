class AIResponseModel {
  final String summary;
  final List<String> insights;
  final List<String> suggestions;
  final double confidenceScore;
  final DateTime generatedAt;

  const AIResponseModel({
    required this.summary,
    required this.insights,
    required this.suggestions,
    required this.confidenceScore,
    required this.generatedAt,
  });

  factory AIResponseModel.fromText(String rawResponse) {
    // Procesar la respuesta del modelo
    final lines = rawResponse.split('\n').where((line) => line.trim().isNotEmpty).toList();

    return AIResponseModel(
      summary: _extractSummary(rawResponse),
      insights: _extractInsights(rawResponse),
      suggestions: _extractSuggestions(rawResponse),
      confidenceScore: 0.8, // Placeholder por ahora
      generatedAt: DateTime.now(),
    );
  }

  static String _extractSummary(String text) {
    // Lógica para extraer el resumen
    final summaryMatch = RegExp(r'RESUMEN:(.*?)(?:INSIGHTS:|$)', dotAll: true).firstMatch(text);
    return summaryMatch?.group(1)?.trim() ?? text.split('\n').first;
  }

  static List<String> _extractInsights(String text) {
    // Extraer insights
    final insightsMatch = RegExp(r'INSIGHTS:(.*?)(?:SUGERENCIAS:|$)', dotAll: true).firstMatch(text);
    if (insightsMatch == null) return [];

    return insightsMatch.group(1)!
        .split('\n')
        .where((line) => line.trim().startsWith('-'))
        .map((line) => line.trim().substring(1).trim())
        .toList();
  }

  static List<String> _extractSuggestions(String text) {
    // Extraer sugerencias
    final suggestionsMatch = RegExp(r'SUGERENCIAS:(.*?)$', dotAll: true).firstMatch(text);
    if (suggestionsMatch == null) return [];

    return suggestionsMatch.group(1)!
        .split('\n')
        .where((line) => line.trim().startsWith('-'))
        .map((line) => line.trim().substring(1).trim())
        .toList();
  }
}