// lib/ai/models/ai_response_model.dart

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
    return AIResponseModel(
      summary: _extractSummary(rawResponse),
      insights: _extractInsights(rawResponse),
      suggestions: _extractSuggestions(rawResponse),
      confidenceScore: 0.85, // Placeholder
      generatedAt: DateTime.now(),
    );
  }

  // ✅ FIXED: Updated regex to find "**RESUMEN SEMANAL:**"
  static String _extractSummary(String text) {
    final summaryMatch = RegExp(r'\*\*RESUMEN SEMANAL:\*\*(.*?)(?=\*\*)', dotAll: true).firstMatch(text);
    return summaryMatch?.group(1)?.trim() ?? 'No se pudo extraer el resumen.';
  }

  // ✅ FIXED: Updated regex to find "**INSIGHTS PROFUNDOS:**" and filter correctly
  static List<String> _extractInsights(String text) {
    final insightsMatch = RegExp(r'\*\*INSIGHTS PROFUNDOS:\*\*(.*?)(?=\*\*)', dotAll: true).firstMatch(text);
    if (insightsMatch == null) return [];

    return insightsMatch.group(1)!
        .split('\n')
        .where((line) => line.trim().startsWith('•'))
        .map((line) => line.trim().substring(1).trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  // ✅ FIXED: Updated regex to find "**RECOMENDACIONES PERSONALIZADAS:**"
  static List<String> _extractSuggestions(String text) {
    final suggestionsMatch = RegExp(r'\*\*RECOMENDACIONES PERSONALIZADAS:\*\*(.*?)(?=\*\*)', dotAll: true).firstMatch(text);
    if (suggestionsMatch == null) return [];

    return suggestionsMatch.group(1)!
        .split('\n')
        .where((line) => line.trim().startsWith('•'))
        .map((line) => line.trim().substring(1).trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }
}