// lib/ai/services/phi_model_service_genai_complete.dart
// IMPLEMENTACIÓN COMPLETA CON ONNX RUNTIME GENAI

import 'dart:io';
import 'package:flutter/foundation.dart';

import '../models/ai_response_model.dart';
import '../prompts/wellness_coach_prompts.dart';
import 'model_downloader.dart';
import 'genai_platform_interface.dart';

class PhiModelServiceGenAI {
  static PhiModelServiceGenAI? _instance;
  static PhiModelServiceGenAI get instance => _instance ??= PhiModelServiceGenAI._();

  PhiModelServiceGenAI._();

  bool _isInitialized = false;
  bool _isGenAIAvailable = false;
  String _modelDirectory = '';

  bool get isInitialized => _isInitialized;
  bool get isGenAIAvailable => _isGenAIAvailable;

  /// Inicializa el servicio GenAI completo
  Future<bool> initialize({
    required Function(String) onStatusUpdate,
    required Function(double) onProgress,
  }) async {
    if (_isInitialized) return true;

    try {
      onStatusUpdate('Verificando capacidades de IA...');

      // Verificar si GenAI está disponible en la plataforma
      _isGenAIAvailable = await GenAIPlatformInterface.isGenAIAvailable();
      debugPrint('🔍 GenAI disponible: $_isGenAIAvailable');

      // Descargar/verificar archivos del modelo
      final downloader = ModelDownloader();
      onStatusUpdate('Verificando archivos del modelo...');

      if (!await downloader.isModelDownloaded()) {
        onStatusUpdate('Descargando modelo Phi-3.5 (esto puede tomar unos minutos)...');
        await downloader.downloadModel(
          onProgress: onProgress,
          onStatusUpdate: onStatusUpdate,
        );
      }

      // Obtener directorio del modelo
      _modelDirectory = await downloader.getModelDirectory();
      onStatusUpdate('Archivos del modelo verificados');

      if (_isGenAIAvailable) {
        // Inicializar GenAI nativo
        onStatusUpdate('Inicializando motor de IA nativo...');
        final initSuccess = await GenAIPlatformInterface.initializeModel(_modelDirectory);

        if (!initSuccess) {
          onStatusUpdate('Error inicializando GenAI, usando modo compatible...');
          _isGenAIAvailable = false;
        } else {
          onStatusUpdate('Motor de IA nativo inicializado correctamente');
        }
      } else {
        onStatusUpdate('Usando modo compatible de IA...');
      }

      // Verificar funcionamiento con una prueba
      onStatusUpdate('Verificando funcionamiento de la IA...');
      await _testAIFunctionality();

      _isInitialized = true;
      onStatusUpdate(_isGenAIAvailable ?
      'IA Phi-3.5 lista (modo nativo)' :
      'IA lista (modo compatible)');

      return true;

    } catch (e) {
      onStatusUpdate('Error inicializando IA: $e');
      debugPrint('❌ Error inicializando PhiModelServiceGenAI: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Genera resumen semanal usando GenAI
  Future<AIResponseModel?> generateWeeklySummary({
    required List<Map<String, dynamic>> weeklyEntries,
    required List<Map<String, dynamic>> weeklyMoments,
    required String userName,
  }) async {
    if (!_isInitialized) {
      throw Exception('El servicio GenAI no está inicializado.');
    }

    try {
      debugPrint('🤖 Generando resumen semanal con GenAI...');
      debugPrint('📊 Datos: ${weeklyEntries.length} entradas, ${weeklyMoments.length} momentos');

      // Construir prompt optimizado para Phi-3.5
      final prompt = _buildOptimizedPrompt(weeklyEntries, weeklyMoments, userName);

      String responseText;

      if (_isGenAIAvailable) {
        // Usar GenAI nativo
        responseText = await _generateWithNativeGenAI(prompt);
      } else {
        // Usar análisis inteligente como fallback
        responseText = await _generateWithIntelligentAnalysis(prompt, weeklyEntries, weeklyMoments, userName);
      }

      debugPrint('✅ Resumen generado: ${responseText.length} caracteres');
      return AIResponseModel.fromText(responseText);

    } catch (e) {
      debugPrint('❌ Error generando resumen: $e');

      // Fallback en caso de error
      try {
        final fallbackResponse = await _generateWithIntelligentAnalysis(
            '', weeklyEntries, weeklyMoments, userName
        );
        return AIResponseModel.fromText(fallbackResponse);
      } catch (fallbackError) {
        debugPrint('❌ Error en fallback: $fallbackError');
        return null;
      }
    }
  }

  /// Construye prompt optimizado para Phi-3.5
  String _buildOptimizedPrompt(
      List<Map<String, dynamic>> weeklyEntries,
      List<Map<String, dynamic>> weeklyMoments,
      String userName,
      ) {
    final systemPrompt = '''Eres un coach de bienestar empático y perspicaz. Tu trabajo es analizar los datos de bienestar de una persona y proporcionar insights valiosos y recomendaciones personalizadas. Mantén un tono cálido, profesional y alentador.''';

    final userData = _formatUserDataForAI(weeklyEntries, weeklyMoments, userName);

    final userPrompt = '''Analiza los datos de bienestar de $userName de esta semana y genera un resumen que incluya:

1. **RESUMEN SEMANAL**: Observaciones clave sobre patrones y tendencias
2. **INSIGHTS PROFUNDOS**: Conexiones entre diferentes aspectos del bienestar
3. **RECOMENDACIONES PERSONALIZADAS**: Sugerencias específicas y accionables

Datos de la semana:
$userData

Formato la respuesta de manera clara y estructurada, usando un lenguaje cercano y motivador.''';

    // Formato para Phi-3.5
    return '''<|system|>$systemPrompt<|end|>
<|user|>$userPrompt<|end|>
<|assistant|>''';
  }

  /// Formatea datos del usuario para el prompt de IA
  String _formatUserDataForAI(
      List<Map<String, dynamic>> weeklyEntries,
      List<Map<String, dynamic>> weeklyMoments,
      String userName,
      ) {
    final buffer = StringBuffer();

    if (weeklyEntries.isEmpty && weeklyMoments.isEmpty) {
      buffer.writeln('No hay datos registrados esta semana.');
      return buffer.toString();
    }

    // Resumen de entradas diarias
    if (weeklyEntries.isNotEmpty) {
      buffer.writeln('REFLEXIONES DIARIAS:');

      final moodScores = weeklyEntries.map((e) => e['mood_score'] as num? ?? 5).toList();
      final avgMood = moodScores.reduce((a, b) => a + b) / moodScores.length;

      buffer.writeln('- Total de días con reflexiones: ${weeklyEntries.length}');
      buffer.writeln('- Estado de ánimo promedio: ${avgMood.toStringAsFixed(1)}/10');

      if (weeklyEntries.any((e) => e['energy_level'] != null)) {
        final energyLevels = weeklyEntries.map((e) => e['energy_level'] as num? ?? 5).toList();
        final avgEnergy = energyLevels.reduce((a, b) => a + b) / energyLevels.length;
        buffer.writeln('- Nivel de energía promedio: ${avgEnergy.toStringAsFixed(1)}/10');
      }

      if (weeklyEntries.any((e) => e['stress_level'] != null)) {
        final stressLevels = weeklyEntries.map((e) => e['stress_level'] as num? ?? 5).toList();
        final avgStress = stressLevels.reduce((a, b) => a + b) / stressLevels.length;
        buffer.writeln('- Nivel de estrés promedio: ${avgStress.toStringAsFixed(1)}/10');
      }

      // Seleccionar reflexiones más significativas
      final significantReflections = weeklyEntries
          .where((e) => (e['free_reflection'] as String? ?? '').length > 20)
          .take(3)
          .map((e) => e['free_reflection'] as String)
          .toList();

      if (significantReflections.isNotEmpty) {
        buffer.writeln('\nREFLEXIONES DESTACADAS:');
        for (int i = 0; i < significantReflections.length; i++) {
          buffer.writeln('${i + 1}. "${significantReflections[i]}"');
        }
      }
    }

    // Momentos especiales
    if (weeklyMoments.isNotEmpty) {
      buffer.writeln('\nMOMENTOS ESPECIALES:');
      buffer.writeln('- Total de momentos registrados: ${weeklyMoments.length}');

      final momentDescriptions = weeklyMoments
          .map((m) => m['description'] as String? ?? '')
          .where((d) => d.isNotEmpty)
          .take(3)
          .toList();

      if (momentDescriptions.isNotEmpty) {
        buffer.writeln('MOMENTOS DESTACADOS:');
        for (int i = 0; i < momentDescriptions.length; i++) {
          buffer.writeln('${i + 1}. "${momentDescriptions[i]}"');
        }
      }
    }

    return buffer.toString();
  }

  /// Genera respuesta usando GenAI nativo
  Future<String> _generateWithNativeGenAI(String prompt) async {
    debugPrint('🚀 Usando GenAI nativo para generación...');

    final response = await GenAIPlatformInterface.generateText(
      prompt,
      maxTokens: 512,
      temperature: 0.7,
      topP: 0.9,
    );

    if (response == null || response.isEmpty) {
      throw Exception('GenAI no devolvió respuesta válida');
    }

    return _cleanupGenAIResponse(response);
  }

  /// Genera respuesta usando análisis inteligente (fallback)
  Future<String> _generateWithIntelligentAnalysis(
      String prompt,
      List<Map<String, dynamic>> weeklyEntries,
      List<Map<String, dynamic>> weeklyMoments,
      String userName,
      ) async {
    debugPrint('🧠 Usando análisis inteligente como fallback...');

    // Simular tiempo de procesamiento de IA
    await Future.delayed(const Duration(seconds: 3));

    return _generateIntelligentResponse(weeklyEntries, weeklyMoments, userName);
  }

  /// Limpia y formatea la respuesta de GenAI
  String _cleanupGenAIResponse(String response) {
    // Remover tokens especiales que puedan aparecer
    String cleaned = response
        .replaceAll('<|assistant|>', '')
        .replaceAll('<|end|>', '')
        .replaceAll('<|user|>', '')
        .replaceAll('<|system|>', '');

    // Limpiar espacios extra y líneas vacías
    cleaned = cleaned
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n');

    return cleaned.trim();
  }

  /// Genera respuesta inteligente basada en análisis de datos
  String _generateIntelligentResponse(
      List<Map<String, dynamic>> weeklyEntries,
      List<Map<String, dynamic>> weeklyMoments,
      String userName,
      ) {
    if (weeklyEntries.isEmpty && weeklyMoments.isEmpty) {
      return '''**¡Hola $userName!**

Esta semana no registraste reflexiones en tu diario, y eso también nos dice algo valioso.

**OBSERVACIÓN CLAVE:**
Los períodos sin registro suelen coincidir con semanas muy ocupadas o momentos de transición. Esto es completamente normal y parte del ritmo natural de la vida.

**INSIGHT PROFUNDO:**
La ausencia de datos es en sí misma un dato. Puede indicar que estuviste tan inmerso en el presente que no hubo tiempo para la reflexión, o que necesitas simplificar tu proceso de autoobservación.

**RECOMENDACIÓN PERSONALIZADA:**
Prueba la "reflexión de 30 segundos": antes de dormir, pregúntate simplemente "¿Cómo me sentí hoy?" No necesitas escribir un párrafo; incluso una palabra o emoji cuenta.

Recuerda: la constancia importa más que la perfección. ¡Nos vemos la próxima semana! 🌟''';
    }

    // Análisis detallado con datos reales
    final analyzer = WeeklyDataAnalyzer(weeklyEntries, weeklyMoments, userName);
    return analyzer.generateComprehensiveAnalysis();
  }

  /// Prueba la funcionalidad de la IA
  Future<void> _testAIFunctionality() async {
    try {
      if (_isGenAIAvailable) {
        final testPrompt = '<|system|>Responde brevemente<|end|><|user|>Test<|end|><|assistant|>';
        final testResponse = await GenAIPlatformInterface.generateText(
          testPrompt,
          maxTokens: 50,
          temperature: 0.1,
        );

        if (testResponse == null || testResponse.isEmpty) {
          debugPrint('⚠️ Test de GenAI falló, switching to fallback');
          _isGenAIAvailable = false;
        } else {
          debugPrint('✅ Test de GenAI exitoso: $testResponse');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error en test de IA: $e');
      _isGenAIAvailable = false;
    }
  }

  void dispose() {
    if (_isGenAIAvailable) {
      GenAIPlatformInterface.disposeModel();
    }
    _isInitialized = false;
  }
}

/// Analizador inteligente de datos semanales
class WeeklyDataAnalyzer {
  final List<Map<String, dynamic>> entries;
  final List<Map<String, dynamic>> moments;
  final String userName;

  WeeklyDataAnalyzer(this.entries, this.moments, this.userName);

  String generateComprehensiveAnalysis() {
    final stats = _calculateDetailedStats();
    final patterns = _identifyBehavioralPatterns();
    final insights = _generateDeepInsights(stats, patterns);
    final recommendations = _generatePersonalizedRecommendations(stats, patterns);

    return '''**¡Hola $userName!**

**RESUMEN SEMANAL:**
${_generateWeeklySummary(stats)}

**INSIGHTS PROFUNDOS:**
${insights.map((insight) => '• $insight').join('\n')}

**RECOMENDACIONES PERSONALIZADAS:**
${recommendations.map((rec) => '• $rec').join('\n')}

**REFLEXIÓN FINAL:**
${_generatePersonalReflection(stats)}

¡Tu dedicación al autoconocimiento es inspiradora! Cada reflexión te acerca más a la mejor versión de ti mismo. 🌟''';
  }

  Map<String, dynamic> _calculateDetailedStats() {
    if (entries.isEmpty) return {'hasData': false};

    final moodScores = entries.map((e) => (e['mood_score'] as num?)?.toDouble() ?? 5.0).toList();
    final energyLevels = entries.map((e) => (e['energy_level'] as num?)?.toDouble() ?? 5.0).toList();
    final stressLevels = entries.map((e) => (e['stress_level'] as num?)?.toDouble() ?? 5.0).toList();

    return {
      'hasData': true,
      'totalEntries': entries.length,
      'totalMoments': moments.length,
      'avgMood': moodScores.reduce((a, b) => a + b) / moodScores.length,
      'avgEnergy': energyLevels.reduce((a, b) => a + b) / energyLevels.length,
      'avgStress': stressLevels.reduce((a, b) => a + b) / stressLevels.length,
      'moodTrend': _calculateTrend(moodScores),
      'energyTrend': _calculateTrend(energyLevels),
      'stressTrend': _calculateTrend(stressLevels),
      'consistency': entries.length >= 5 ? 'alta' : entries.length >= 3 ? 'media' : 'baja',
    };
  }

  String _calculateTrend(List<double> values) {
    if (values.length < 3) return 'estable';

    final firstHalf = values.take(values.length ~/ 2).toList();
    final secondHalf = values.skip(values.length ~/ 2).toList();

    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

    final difference = secondAvg - firstAvg;

    if (difference > 0.8) return 'mejorando significativamente';
    if (difference > 0.3) return 'mejorando';
    if (difference < -0.8) return 'declinando significativamente';
    if (difference < -0.3) return 'declinando';
    return 'estable';
  }

  List<String> _identifyBehavioralPatterns() {
    final patterns = <String>[];

    // Análisis de contenido textual
    final allText = entries
        .map((e) => (e['free_reflection'] as String? ?? '').toLowerCase())
        .join(' ');

    final workKeywords = ['trabajo', 'laboral', 'oficina', 'reunión', 'proyecto'];
    final familyKeywords = ['familia', 'casa', 'hogar', 'padres', 'hijos'];
    final healthKeywords = ['ejercicio', 'deporte', 'gym', 'caminar', 'correr'];
    final stressKeywords = ['estrés', 'estresado', 'ansiedad', 'presión', 'agobiado'];

    if (_containsKeywords(allText, workKeywords)) {
      patterns.add('El ámbito laboral tiene un impacto significativo en tu bienestar');
    }

    if (_containsKeywords(allText, familyKeywords)) {
      patterns.add('La vida familiar es una fuente importante de reflexión para ti');
    }

    if (_containsKeywords(allText, healthKeywords)) {
      patterns.add('La actividad física aparece como un tema relevante en tu semana');
    }

    if (_containsKeywords(allText, stressKeywords)) {
      patterns.add('Has experimentado momentos de estrés que vale la pena atender');
    }

    return patterns.isNotEmpty ? patterns : ['Tus reflexiones muestran una perspectiva equilibrada y madura'];
  }

  bool _containsKeywords(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  List<String> _generateDeepInsights(Map<String, dynamic> stats, List<String> patterns) {
    final insights = <String>[];

    if (!stats['hasData']) {
      insights.add('La pausa en el registro puede ser una oportunidad para reflexionar sobre tus hábitos actuales');
      return insights;
    }

    final avgMood = stats['avgMood'] as double;
    final avgEnergy = stats['avgEnergy'] as double;
    final avgStress = stats['avgStress'] as double;
    final moodTrend = stats['moodTrend'] as String;

    // Insight sobre correlación mood-energy
    if ((avgMood - avgEnergy).abs() < 1.0) {
      insights.add('Tu estado de ánimo y nivel de energía están bien sincronizados, indicando un buen equilibrio interno');
    } else if (avgMood > avgEnergy + 1.5) {
      insights.add('Mantienes una actitud positiva incluso cuando tu energía está baja - esto demuestra una gran resiliencia emocional');
    }

    // Insight sobre manejo del estrés
    if (avgStress > 7 && avgMood > 6) {
      insights.add('Tu capacidad para mantener buen ánimo bajo presión es notable y sugiere habilidades sólidas de afrontamiento');
    } else if (avgStress > 6 && avgMood < 5) {
      insights.add('El estrés parece estar afectando tu bienestar general - es importante abordar las fuentes de presión');
    }

    // Insight sobre tendencias
    if (moodTrend.contains('mejorando')) {
      insights.add('La tendencia ascendente en tu estado de ánimo sugiere que las estrategias que estás usando están funcionando');
    }

    // Insight sobre consistencia
    if (stats['consistency'] == 'alta') {
      insights.add('Tu constancia en la autorreflexión es excepcional y seguramente está contribuyendo a tu autoconocimiento');
    }

    return insights.isNotEmpty ? insights : ['Tus datos revelan un patrón de crecimiento personal continuo'];
  }

  List<String> _generatePersonalizedRecommendations(Map<String, dynamic> stats, List<String> patterns) {
    final recommendations = <String>[];

    if (!stats['hasData']) {
      recommendations.add('Considera establecer un recordatorio suave para retomar la práctica de reflexión diaria');
      recommendations.add('Prueba con reflexiones muy breves (una sola frase) para facilitar la constancia');
      return recommendations;
    }

    final avgStress = stats['avgStress'] as double;
    final avgEnergy = stats['avgEnergy'] as double;
    final avgMood = stats['avgMood'] as double;
    final consistency = stats['consistency'] as String;

    if (avgStress > 7) {
      recommendations.add('Incorpora técnicas de respiración profunda o meditación breve en tu rutina diaria');
    }

    if (avgEnergy < 5) {
      recommendations.add('Evalúa tus patrones de sueño y considera aumentar gradualmente tu actividad física');
    }

    if (avgMood < 6) {
      recommendations.add('Dedica tiempo diario a actividades que genuinamente disfrutes, aunque sean pequeñas');
    }

    if (consistency == 'baja') {
      recommendations.add('Establece un momento específico del día para la reflexión - la consistencia amplifica los beneficios');
    }

    // Recomendaciones basadas en patrones
    if (patterns.any((p) => p.contains('laboral'))) {
      recommendations.add('Considera establecer límites más claros entre tu tiempo de trabajo y personal');
    }

    if (patterns.any((p) => p.contains('estrés'))) {
      recommendations.add('Identifica los principales triggers de estrés y desarrolla estrategias específicas para cada uno');
    }

    return recommendations.isNotEmpty ? recommendations : ['Continúa con tus prácticas actuales - están dando buenos resultados'];
  }

  String _generateWeeklySummary(Map<String, dynamic> stats) {
    if (!stats['hasData']) {
      return 'Esta semana tomaste un descanso de las reflexiones escritas.';
    }

    final totalEntries = stats['totalEntries'] as int;
    final totalMoments = stats['totalMoments'] as int;
    final avgMood = stats['avgMood'] as double;
    final moodTrend = stats['moodTrend'] as String;

    return 'Registraste $totalEntries reflexiones y $totalMoments momentos especiales. '
        'Tu estado de ánimo promedio fue ${avgMood.toStringAsFixed(1)}/10, '
        'con una tendencia $moodTrend a lo largo de la semana.';
  }

  String _generatePersonalReflection(Map<String, dynamic> stats) {
    if (!stats['hasData']) {
      return 'Recuerda que tanto los momentos de pausa como los de actividad tienen su lugar en el crecimiento personal.';
    }

    final avgMood = stats['avgMood'] as double;
    final consistency = stats['consistency'] as String;

    if (avgMood >= 7 && consistency == 'alta') {
      return 'Tu dedicación a la autorreflexión combinada con tu actitud positiva crean una base sólida para el bienestar continuo.';
    } else if (avgMood < 5) {
      return 'Has navegado algunos desafíos esta semana, y tu voluntad de reflexionar sobre ellos demuestra una fortaleza admirable.';
    } else {
      return 'Tu enfoque equilibrado hacia la autorreflexión muestra una madurez emocional que te servirá bien en el futuro.';
    }
  }
}