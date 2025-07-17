// lib/ai/services/phi_model_service_genai_complete.dart
// VERSIÓN ACTUALIZADA PARA GENERAR ANÁLISIS RICO

import 'dart:io';
import 'package:flutter/foundation.dart';

import '../models/ai_response_model.dart';
import '../prompts/wellness_coach_prompts.dart';
import 'model_downloader.dart';
import 'genai_platform_interface.dart';

// ✅ IMPORTAR EL NUEVO SERVICIO DE ANÁLISIS INTERACTIVO
import 'interactive_ai_analysis_service.dart';

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

  /// ✅ MÉTODO ACTUALIZADO: Genera resumen semanal RICO usando el nuevo sistema INTERACTIVO
  Future<AIResponseModel?> generateWeeklySummary({
    required List<Map<String, dynamic>> weeklyEntries,
    required List<Map<String, dynamic>> weeklyMoments,
    required String userName,
  }) async {
    if (!_isInitialized) {
      throw Exception('El servicio GenAI no está inicializado.');
    }

    try {
      debugPrint('🤖 Generando análisis semanal INTERACTIVO...');
      debugPrint('📊 Datos: ${weeklyEntries.length} entradas, ${weeklyMoments.length} momentos');

      // ✅ NUEVO: Usar el servicio de análisis interactivo que cita datos específicos
      final interactiveAnalysis = await InteractiveAIAnalysisService.generatePersonalizedAnalysis(
        weeklyEntries: weeklyEntries,
        weeklyMoments: weeklyMoments,
        userName: userName,
      );

      debugPrint('✅ Análisis INTERACTIVO generado: ${interactiveAnalysis.summary.length} caracteres');
      debugPrint('📈 Datos específicos citados: wellnessScore=${interactiveAnalysis.wellnessScore}');

      return interactiveAnalysis;

    } catch (e) {
      debugPrint('❌ Error generando análisis interactivo: $e');

      // ✅ FALLBACK: Si falla el análisis interactivo, usar versión básica mejorada
      try {
        debugPrint('🔄 Usando fallback básico mejorado...');
        return await _generateBasicEnhancedFallback(weeklyEntries, weeklyMoments, userName);
      } catch (fallbackError) {
        debugPrint('❌ Error en fallback básico: $fallbackError');
        return null;
      }
    }
  }

  /// ✅ NUEVO: Fallback básico pero que usa el modelo expandido
  Future<AIResponseModel> _generateBasicEnhancedFallback(
      List<Map<String, dynamic>> weeklyEntries,
      List<Map<String, dynamic>> weeklyMoments,
      String userName,
      ) async {

    if (weeklyEntries.isEmpty) {
      return AIResponseModel.fromRichAnalysis(
        summary: '''Esta semana tomaste un descanso de las reflexiones, y eso también es valioso. A veces necesitamos espacio para simplemente vivir el momento.

Los períodos sin registro pueden indicar inmersión completa en el presente. El descanso de la autoobservación también es una forma de autocuidado.''',
        insights: [
          'Los períodos sin registro pueden indicar inmersión completa en el presente',
          'El descanso de la autoobservación también es una forma de autocuidado',
          'La pausa consciente puede ofrecer perspectiva renovada'
        ],
        suggestions: [
          'Considera una reflexión breve de 30 segundos antes de dormir',
          'Una sola palabra o emoji puede ser suficiente para mantener la conexión',
          'La constancia importa más que la perfección'
        ],
        wellnessScore: 5.0,
        nextWeekFocus: 'Retoma gradualmente tu práctica reflexiva sin presión',
        celebrationMoments: [
          'Tu capacidad de autocuidado al tomar descansos conscientes'
        ],
      );
    }

    // Calcular métricas básicas
    final moodScores = weeklyEntries.map((e) => (e['mood_score'] as num?)?.toDouble() ?? 5.0).toList();
    final energyLevels = weeklyEntries.map((e) => (e['energy_level'] as num?)?.toDouble() ?? 5.0).toList();
    final stressLevels = weeklyEntries.map((e) => (e['stress_level'] as num?)?.toDouble() ?? 5.0).toList();

    final avgMood = moodScores.reduce((a, b) => a + b) / moodScores.length;
    final avgEnergy = energyLevels.reduce((a, b) => a + b) / energyLevels.length;
    final avgStress = stressLevels.reduce((a, b) => a + b) / stressLevels.length;

    // Calcular puntuación de bienestar
    final wellnessScore = (avgMood * 0.4 + avgEnergy * 0.3 + (10 - avgStress) * 0.3);

    return AIResponseModel.fromRichAnalysis(
      summary: '''Esta semana registraste ${weeklyEntries.length} reflexiones con un estado de ánimo promedio de ${avgMood.toStringAsFixed(1)}/10.

Tu compromiso con la reflexión muestra madurez emocional. El patrón semanal indica ${avgMood >= 7 ? 'un período positivo' : avgMood >= 5 ? 'equilibrio emocional' : 'algunos desafíos que muestran fortaleza'}. La consistencia en tu práctica refleja dedicación al crecimiento.''',
      insights: [
        'Tu compromiso con la reflexión muestra madurez emocional',
        'El patrón semanal indica ${avgMood >= 7 ? 'un período positivo' : avgMood >= 5 ? 'equilibrio emocional' : 'algunos desafíos que muestran fortaleza'}',
        'La consistencia en tu práctica refleja dedicación al crecimiento',
        'Tu nivel de energía promedio (${avgEnergy.toStringAsFixed(1)}/10) ${avgEnergy >= 7 ? 'muestra vitalidad' : 'indica oportunidades de mejora'}',
      ],
      suggestions: [
        'Continúa con tu práctica reflexiva actual',
        avgMood < 6 ? 'Considera actividades que históricamente mejoran tu ánimo' : 'Mantén las estrategias que están funcionando bien',
        'Celebra tu compromiso con el autoconocimiento',
        avgEnergy < 6 ? 'Evalúa tus patrones de sueño y actividad física' : 'Tu energía está en buen nivel',
      ],
      wellnessScore: wellnessScore,
      weeklyMetrics: {
        'daysWithReflections': weeklyEntries.length,
        'averageMood': avgMood,
        'averageEnergy': avgEnergy,
        'averageStress': avgStress,
      },
      highlightedMoment: 'Tu dedicación a la reflexión personal es admirable - cada entrada es un acto de amor propio',
      celebrationMoments: [
        'Tu compromiso constante con el autoconocimiento',
        'La valentía de mantener la práctica reflexiva',
        weeklyEntries.length >= 5 ? 'Excelente consistencia esta semana' : 'Cada reflexión cuenta y es valiosa',
      ],
      nextWeekFocus: 'Continúa cultivando tu práctica de autoconocimiento con la misma dedicación',
      correlations: avgMood > 6 && avgEnergy > 6 ? {'mood_energy': 0.75} : null,
    );
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

**OBSERVACIÓN CLAVE:**
Esta semana no registraste reflexiones en tu diario, y eso también nos dice algo valioso.

**INSIGHT PROFUNDO:**
Los períodos sin registro suelen coincidir con semanas muy ocupadas o momentos de transición. Esto es completamente normal y parte del ritmo natural de la vida.

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

/// ✅ MANTENER: Analizador inteligente de datos semanales (versión básica)
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

    return insights.isNotEmpty ? insights : ['Tus reflexiones muestran un compromiso genuino con el crecimiento personal'];
  }

  List<String> _generatePersonalizedRecommendations(Map<String, dynamic> stats, List<String> patterns) {
    final recommendations = <String>[];

    if (!stats['hasData']) {
      recommendations.add('Considera retomar gradualmente tu práctica de reflexión con sesiones breves de 1-2 minutos');
      return recommendations;
    }

    final avgMood = stats['avgMood'] as double;
    final avgEnergy = stats['avgEnergy'] as double;
    final avgStress = stats['avgStress'] as double;

    if (avgMood < 6) {
      recommendations.add('Identifica y programa más actividades que históricamente han mejorado tu estado de ánimo');
    }

    if (avgEnergy < 6) {
      recommendations.add('Evalúa tus patrones de sueño, alimentación y actividad física para optimizar tus niveles de energía');
    }

    if (avgStress > 7) {
      recommendations.add('Considera implementar técnicas de manejo del estrés como respiración profunda o meditación breve');
    }

    if (stats['consistency'] == 'baja') {
      recommendations.add('Intenta establecer un horario fijo para la reflexión, aunque sea solo 30 segundos al día');
    }

    return recommendations.isNotEmpty ? recommendations : ['Continúa con tu excelente práctica de autorreflexión'];
  }

  String _generateWeeklySummary(Map<String, dynamic> stats) {
    if (!stats['hasData']) {
      return 'Esta semana tomaste un descanso de las reflexiones. Los períodos sin registro son también parte natural del proceso de autoconocimiento.';
    }

    final totalEntries = stats['totalEntries'] as int;
    final avgMood = stats['avgMood'] as double;
    final consistency = stats['consistency'] as String;

    return 'Registraste $totalEntries reflexiones esta semana con un estado de ánimo promedio de ${avgMood.toStringAsFixed(1)}/10. Tu nivel de consistencia fue $consistency, lo que ${consistency == 'alta' ? 'demuestra un excelente compromiso' : 'muestra tu dedicación al crecimiento'} con el autoconocimiento.';
  }

  String _generatePersonalReflection(Map<String, dynamic> stats) {
    if (!stats['hasData']) {
      return 'Recuerda que tanto los períodos de reflexión activa como los de pausa consciente son valiosos para tu desarrollo personal.';
    }

    final moodTrend = stats['moodTrend'] as String;
    if (moodTrend.contains('mejorando')) {
      return 'La tendencia positiva en tu bienestar es una señal esperanzadora. Continúa cultivando las prácticas que están funcionando para ti.';
    } else {
      return 'Cada reflexión que compartes es un paso valioso hacia un mayor autoconocimiento y crecimiento personal.';
    }
  }
}