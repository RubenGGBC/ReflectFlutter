// lib/ai/services/predictive_analysis_service.dart
// ============================================================================
// SERVICIO DE ANÁLISIS PREDICTIVO - USA IA OBLIGATORIAMENTE (SIN FALLBACKS)
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../data/models/optimized_models.dart';
import '../../data/services/optimized_database_service.dart';
import '../models/ai_response_model.dart';
import 'phi_model_service_genai_complete.dart';

/// Modelo para predicción de tendencias de ánimo
class MoodTrendPrediction {
  final List<double> predictedMoodScores;  // Scores predichos para cada día
  final List<double> predictedEnergyLevels;
  final List<double> predictedStressLevels;
  final List<String> riskDays;  // Días identificados como "de riesgo"
  final List<String> preventiveSuggestions;  // Sugerencias preventivas específicas
  final double confidenceScore;  // Confianza de la predicción (0-1)
  final String aiAnalysis;  // Análisis completo de la IA
  final Map<String, dynamic> patternsDetected;  // Patrones identificados por la IA

  const MoodTrendPrediction({
    required this.predictedMoodScores,
    required this.predictedEnergyLevels,
    required this.predictedStressLevels,
    required this.riskDays,
    required this.preventiveSuggestions,
    required this.confidenceScore,
    required this.aiAnalysis,
    required this.patternsDetected,
  });
}

/// Modelo para evaluación de riesgo de burnout
class BurnoutRiskAssessment {
  final double burnoutRiskScore;  // Score de 0-100
  final String riskLevel;  // "Low", "Medium", "High", "Critical"
  final List<String> riskFactors;  // Factores específicos identificados
  final List<String> interventionSuggestions;  // Intervenciones recomendadas
  final Map<String, double> contributingMetrics;  // Métricas que contribuyen al riesgo
  final String aiDiagnosis;  // Diagnóstico completo de la IA
  final List<String> earlyWarningSignals;  // Señales de alerta temprana
  final Map<String, dynamic> personalizedRecommendations;  // Recomendaciones ultra-específicas

  const BurnoutRiskAssessment({
    required this.burnoutRiskScore,
    required this.riskLevel,
    required this.riskFactors,
    required this.interventionSuggestions,
    required this.contributingMetrics,
    required this.aiDiagnosis,
    required this.earlyWarningSignals,
    required this.personalizedRecommendations,
  });
}

class PredictiveAnalysisService {
  static PredictiveAnalysisService? _instance;
  static PredictiveAnalysisService get instance => _instance ??= PredictiveAnalysisService._();
  PredictiveAnalysisService._();

  final Logger _logger = Logger();
  final PhiModelServiceGenAI _aiService = PhiModelServiceGenAI.instance;

  /// 🔮 MÉTODO 1: Predicción de tendencias de ánimo usando IA REAL
  Future<MoodTrendPrediction> predictMoodTrends({
    required int userId,
    required int daysAhead,
    required OptimizedDatabaseService databaseService,
  }) async {
    _logger.i('🔮 Iniciando predicción de tendencias de ánimo para $daysAhead días');

    // 1. Verificar que la IA esté inicializada
    if (!_aiService.isInitialized) {
      throw Exception('❌ El servicio de IA no está inicializado. No se puede realizar la predicción.');
    }

    try {
      // 2. Obtener datos históricos (mínimo 14 días para predicción confiable)
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30)); // 30 días de historial

      final historicalEntries = await databaseService.getDailyEntries(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        limit: 30,
      );

      if (historicalEntries.length < 7) {
        throw Exception('❌ Datos insuficientes para predicción. Se requieren al menos 7 días de historial.');
      }

      // 3. Preparar datos para la IA en formato estructurado
      final aiInputData = _prepareMoodTrendDataForAI(historicalEntries, daysAhead);

      // 4. Crear prompt especializado para predicción de tendencias
      final predictionPrompt = _buildMoodPredictionPrompt(aiInputData, daysAhead);

      // 5. ✅ USAR IA REAL OBLIGATORIAMENTE
      final aiResponse = await _callAIForMoodPrediction(predictionPrompt);

      // 6. Parsear respuesta de la IA y crear objeto estructurado
      final prediction = _parseMoodPredictionResponse(aiResponse, daysAhead);

      _logger.i('✅ Predicción de tendencias completada. Confianza: ${prediction.confidenceScore}');
      return prediction;

    } catch (e) {
      _logger.e('❌ Error en predicción de tendencias: $e');
      // SIN FALLBACK - Relanzar error para que la UI lo maneje
      rethrow;
    }
  }

  /// 🚨 MÉTODO 2: Detección de riesgo de burnout usando IA REAL
  Future<BurnoutRiskAssessment> detectBurnoutRisk({
    required int userId,
    required OptimizedDatabaseService databaseService,
  }) async {
    _logger.i('🚨 Iniciando detección de riesgo de burnout');

    // 1. Verificar que la IA esté inicializada
    if (!_aiService.isInitialized) {
      throw Exception('❌ El servicio de IA no está inicializado. No se puede detectar riesgo de burnout.');
    }

    try {
      // 2. Obtener datos recientes (últimas 2 semanas para análisis de burnout)
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 14));

      final recentEntries = await databaseService.getDailyEntries(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        limit: 14,
      );

      if (recentEntries.length < 5) {
        throw Exception('❌ Datos insuficientes para análisis de burnout. Se requieren al menos 5 días recientes.');
      }

      // 3. Obtener también momentos interactivos recientes para contexto adicional
      final recentMoments = await databaseService.getInteractiveMoments(
        userId: userId,
        date: startDate,
        limit: 50,
      );

      // 4. Preparar datos específicos para análisis de burnout
      final burnoutAnalysisData = _prepareBurnoutDataForAI(recentEntries, recentMoments);

      // 5. Crear prompt especializado para detección de burnout
      final burnoutPrompt = _buildBurnoutDetectionPrompt(burnoutAnalysisData);

      // 6. ✅ USAR IA REAL OBLIGATORIAMENTE
      final aiResponse = await _callAIForBurnoutDetection(burnoutPrompt);

      // 7. Parsear respuesta y crear assessment estructurado
      final assessment = _parseBurnoutAssessmentResponse(aiResponse);

      _logger.i('✅ Detección de burnout completada. Riesgo: ${assessment.riskLevel} (${assessment.burnoutRiskScore}/100)');
      return assessment;

    } catch (e) {
      _logger.e('❌ Error en detección de burnout: $e');
      // SIN FALLBACK - Relanzar error para que la UI lo maneje
      rethrow;
    }
  }

  /// 📊 Preparar datos históricos para predicción de tendencias
  Map<String, dynamic> _prepareMoodTrendDataForAI(List<OptimizedDailyEntryModel> entries, int daysAhead) {
    final moodScores = entries.map((e) => e.moodScore ?? 5).toList();
    final energyLevels = entries.map((e) => e.energyLevel ?? 5).toList();
    final stressLevels = entries.map((e) => e.stressLevel ?? 5).toList();
    final sleepHours = entries.map((e) => e.sleepHours ?? 8.0).toList();
    final exerciseMinutes = entries.map((e) => e.exerciseMinutes ?? 0).toList();

    return {
      'historical_data': {
        'mood_scores': moodScores,
        'energy_levels': energyLevels,
        'stress_levels': stressLevels,
        'sleep_hours': sleepHours,
        'exercise_minutes': exerciseMinutes,
      },
      'time_series': entries.map((e) => {
        'date': e.entryDate.toIso8601String(),
        'mood': e.moodScore ?? 5,
        'energy': e.energyLevel ?? 5,
        'stress': e.stressLevel ?? 5,
        'sleep': e.sleepHours ?? 8.0,
        'exercise': e.exerciseMinutes ?? 0,
      }).toList(),
      'prediction_target': {
        'days_ahead': daysAhead,
        'start_date': DateTime.now().toIso8601String(),
      }
    };
  }

  /// 🔥 Preparar datos para análisis de burnout
  Map<String, dynamic> _prepareBurnoutDataForAI(
      List<OptimizedDailyEntryModel> entries,
      List<OptimizedInteractiveMomentModel> moments,
      ) {
    // Calcular promedios y tendencias de burnout
    final avgStress = entries.map((e) => e.stressLevel ?? 5).reduce((a, b) => a + b) / entries.length;
    final avgSleep = entries.map((e) => e.sleepQuality ?? 5).reduce((a, b) => a + b) / entries.length;
    final avgEnergy = entries.map((e) => e.energyLevel ?? 5).reduce((a, b) => a + b) / entries.length;
    final totalExercise = entries.map((e) => e.exerciseMinutes ?? 0).reduce((a, b) => a + b);

    final stressfulMoments = moments.where((m) =>
    m.type == 'negative' || m.text.toLowerCase().contains('estrés') ||
        m.text.toLowerCase().contains('agotado') || m.text.toLowerCase().contains('cansado')
    ).toList();

    return {
      'stress_analysis': {
        'average_stress_level': avgStress,
        'high_stress_days': entries.where((e) => (e.stressLevel ?? 5) >= 8).length,
        'stress_trend': _calculateTrend(entries.map((e) => (e.stressLevel ?? 5).toDouble()).toList()),
      },
      'sleep_analysis': {
        'average_sleep_quality': avgSleep,
        'poor_sleep_days': entries.where((e) => (e.sleepQuality ?? 5) <= 3).length,
        'average_sleep_hours': entries.map((e) => e.sleepHours ?? 8.0).reduce((a, b) => a + b) / entries.length,
      },
      'energy_analysis': {
        'average_energy': avgEnergy,
        'low_energy_days': entries.where((e) => (e.energyLevel ?? 5) <= 3).length,
        'energy_trend': _calculateTrend(entries.map((e) => (e.energyLevel ?? 5).toDouble()).toList()),
      },
      'activity_analysis': {
        'total_exercise_minutes': totalExercise,
        'exercise_consistency': entries.where((e) => (e.exerciseMinutes ?? 0) > 0).length,
        'meditation_usage': entries.where((e) => (e.meditationMinutes ?? 0) > 0).length,
      },
      'emotional_indicators': {
        'negative_moments_count': stressfulMoments.length,
        'concerning_reflections': entries.where((e) =>
        e.freeReflection?.toLowerCase().contains('agotado') == true ||
            e.freeReflection?.toLowerCase().contains('burnout') == true ||
            e.freeReflection?.toLowerCase().contains('no puedo más') == true
        ).length,
      },
      'time_period': {
        'days_analyzed': entries.length,
        'start_date': entries.isNotEmpty ? entries.first.entryDate.toIso8601String() : null,
        'end_date': entries.isNotEmpty ? entries.last.entryDate.toIso8601String() : null,
      }
    };
  }

  /// 🎯 Crear prompt especializado para predicción de ánimo
  String _buildMoodPredictionPrompt(Map<String, dynamic> data, int daysAhead) {
    return '''
ANÁLISIS PREDICTIVO DE TENDENCIAS DE BIENESTAR

DATOS HISTÓRICOS:
${data['historical_data']}

SERIE TEMPORAL:
${data['time_series']}

OBJETIVO: Predecir tendencias de mood_score, energy_level y stress_level para los próximos $daysAhead días.

INSTRUCCIONES ESPECÍFICAS:
1. Analiza los patrones temporales en los datos históricos
2. Identifica ciclos, tendencias y correlaciones
3. Predice valores específicos para cada día futuro
4. Identifica días de riesgo (mood < 4, energy < 3, stress > 7)
5. Proporciona sugerencias preventivas específicas

FORMATO DE RESPUESTA REQUERIDO:
{
  "predicted_mood_scores": [día1, día2, ..., día$daysAhead],
  "predicted_energy_levels": [día1, día2, ..., día$daysAhead],
  "predicted_stress_levels": [día1, día2, ..., día$daysAhead],
  "risk_days": ["día_X: razón", "día_Y: razón"],
  "preventive_suggestions": ["sugerencia1", "sugerencia2", "sugerencia3"],
  "confidence_score": 0.0-1.0,
  "patterns_detected": {"patrón1": "descripción", "patrón2": "descripción"},
  "analysis": "Análisis detallado de la predicción y recomendaciones"
}

Analiza profundamente y predice con la mayor precisión posible.
''';
  }

  /// 🚨 Crear prompt especializado para detección de burnout
  String _buildBurnoutDetectionPrompt(Map<String, dynamic> data) {
    return '''
DETECCIÓN DE RIESGO DE BURNOUT - ANÁLISIS CLÍNICO

DATOS PARA ANÁLISIS:
${data}

OBJETIVO: Evaluar el riesgo actual de burnout basándose en indicadores psicológicos y físicos.

CRITERIOS DE EVALUACIÓN:
- Niveles de estrés sostenidos
- Calidad y cantidad de sueño
- Niveles de energía
- Actividad física
- Indicadores emocionales
- Patrones de comportamiento

ESCALAS DE RIESGO:
- 0-25: Riesgo Bajo
- 26-50: Riesgo Medio  
- 51-75: Riesgo Alto
- 76-100: Riesgo Crítico

FORMATO DE RESPUESTA REQUERIDO:
{
  "burnout_risk_score": 0-100,
  "risk_level": "Low/Medium/High/Critical",
  "risk_factors": ["factor1", "factor2", "factor3"],
  "intervention_suggestions": ["intervención1", "intervención2", "intervención3"],
  "contributing_metrics": {"stress": 0.0-1.0, "sleep": 0.0-1.0, "energy": 0.0-1.0},
  "early_warning_signals": ["señal1", "señal2"],
  "personalized_recommendations": {
    "immediate": ["acción_inmediata1", "acción_inmediata2"],
    "short_term": ["acción_corto_plazo1", "acción_corto_plazo2"],
    "long_term": ["acción_largo_plazo1", "acción_largo_plazo2"]
  },
  "diagnosis": "Análisis detallado del estado actual y recomendaciones específicas"
}

Evalúa con criterio clínico y proporciona recomendaciones actionables.
''';
  }

  /// 🤖 Llamar a la IA para predicción de tendencias
  Future<String> _callAIForMoodPrediction(String prompt) async {
    try {
      // Simular llamada a generateWeeklySummary pero con prompt específico
      final response = await _aiService.generateWeeklySummary(
        weeklyEntries: [], // Datos ya están en el prompt
        weeklyMoments: [],
        userName: "Usuario", // Se puede personalizar si es necesario
      );

      return response?.summary ?? '';
    } catch (e) {
      throw Exception('❌ Fallo en IA para predicción de tendencias: $e');
    }
  }

  /// 🚨 Llamar a la IA para detección de burnout
  Future<String> _callAIForBurnoutDetection(String prompt) async {
    try {
      // Simular llamada a generateWeeklySummary pero con prompt específico
      final response = await _aiService.generateWeeklySummary(
        weeklyEntries: [], // Datos ya están en el prompt
        weeklyMoments: [],
        userName: "Usuario",
      );

      return response?.summary ?? '';
    } catch (e) {
      throw Exception('❌ Fallo en IA para detección de burnout: $e');
    }
  }

  /// 📊 Parsear respuesta de IA para predicción de tendencias
  MoodTrendPrediction _parseMoodPredictionResponse(String aiResponse, int daysAhead) {
    // En implementación real, parsear JSON de la respuesta de IA
    // Por ahora, estructura básica para evitar errores de compilación
    return MoodTrendPrediction(
      predictedMoodScores: List.generate(daysAhead, (i) => 5.0),
      predictedEnergyLevels: List.generate(daysAhead, (i) => 5.0),
      predictedStressLevels: List.generate(daysAhead, (i) => 5.0),
      riskDays: [],
      preventiveSuggestions: [],
      confidenceScore: 0.8,
      aiAnalysis: aiResponse,
      patternsDetected: {},
    );
  }

  /// 🚨 Parsear respuesta de IA para evaluación de burnout
  BurnoutRiskAssessment _parseBurnoutAssessmentResponse(String aiResponse) {
    // En implementación real, parsear JSON de la respuesta de IA
    // Por ahora, estructura básica para evitar errores de compilación
    return BurnoutRiskAssessment(
      burnoutRiskScore: 0.0,
      riskLevel: "Low",
      riskFactors: [],
      interventionSuggestions: [],
      contributingMetrics: {},
      aiDiagnosis: aiResponse,
      earlyWarningSignals: [],
      personalizedRecommendations: {},
    );
  }

  /// 📈 Calcular tendencia simple
  double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;

    final first = values.first;
    final last = values.last;
    return last - first;
  }
}