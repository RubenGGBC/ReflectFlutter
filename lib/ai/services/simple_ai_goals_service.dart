// lib/ai/services/simple_ai_goals_service.dart
// ============================================================================
// SERVICIO SIMPLE: USA IA REAL PARA GENERAR GOALS DESPUÉS DE REFLEXIÓN
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../data/models/optimized_models.dart';
import '../../data/services/optimized_database_service.dart';
import 'phi_model_service_genai_complete.dart';

class SimpleAIGoalsService {
  static SimpleAIGoalsService? _instance;
  static SimpleAIGoalsService get instance => _instance ??= SimpleAIGoalsService._();
  SimpleAIGoalsService._();

  final Logger _logger = Logger();
  final PhiModelServiceGenAI _aiService = PhiModelServiceGenAI.instance;

  /// 🎯 MÉTODO PRINCIPAL: Usar IA REAL para generar recomendaciones
  Future<List<SimpleGoalRecommendation>> analyzeAndRecommend({
    required int userId,
    required OptimizedDailyEntryModel dailyEntry,
    required String userName,
    required OptimizedDatabaseService databaseService,
  }) async {
    try {
      _logger.i('🤖 Usando IA REAL para generar recomendaciones de goals');

      // 1. Obtener contexto adicional
      final todayMoments = await _getTodayMoments(userId, databaseService);
      final recentEntries = await _getRecentEntries(userId, databaseService);

      // 2. Convertir a formato que espera la IA
      final weeklyEntries = _convertEntriesToAIFormat([dailyEntry] + recentEntries);
      final weeklyMoments = _convertMomentsToAIFormat(todayMoments);

      // 3. ✅ USAR LA IA REAL con prompt personalizado para goals
      final aiResponse = await _aiService.generateWeeklySummary(
        weeklyEntries: weeklyEntries,
        weeklyMoments: weeklyMoments,
        userName: userName,
      );

      // 4. Parsear respuesta de la IA para extraer goals
      final recommendations = _parseAIResponseForGoals(aiResponse?.summary ?? '', dailyEntry, userName);

      _logger.i('✅ IA generó ${recommendations.length} recomendaciones');
      return recommendations;

    } catch (e) {
      _logger.e('❌ Error con IA: $e');
      // Fallback simple si falla la IA
      return _generateFallbackRecommendations(dailyEntry, userName);
    }
  }

  /// 📊 Convertir entradas al formato que espera la IA
  List<Map<String, dynamic>> _convertEntriesToAIFormat(List<OptimizedDailyEntryModel> entries) {
    return entries.map((entry) => {
      'entry_date': entry.entryDate.toIso8601String(),
      'free_reflection': entry.freeReflection,
      'mood_score': entry.moodScore ?? 5,
      'energy_level': entry.energyLevel ?? 5,
      'stress_level': entry.stressLevel ?? 5,
      'sleep_quality': entry.sleepQuality ?? 5,
      'exercise_minutes': entry.exerciseMinutes ?? 0,
      'meditation_minutes': entry.meditationMinutes ?? 0,
      'sleep_hours': entry.sleepHours ?? 8.0,
      'positive_tags': entry.positiveTags,
      'negative_tags': entry.negativeTags,
      'worth_it': entry.worthIt,
      'gratitude_items': entry.gratitudeItems ?? '',
    }).toList();
  }

  /// 📊 Convertir momentos al formato que espera la IA
  List<Map<String, dynamic>> _convertMomentsToAIFormat(List<OptimizedInteractiveMomentModel> moments) {
    return moments.map((moment) => {
      'emoji': moment.emoji,
      'text': moment.text,
      'type': moment.type,
      'intensity': moment.intensity,
      'timestamp': moment.timestamp.toIso8601String(),
      'description': '${moment.emoji} ${moment.text}',
    }).toList();
  }

  /// 🤖 Parsear respuesta de la IA real para extraer goals
  List<SimpleGoalRecommendation> _parseAIResponseForGoals(String aiSummary, OptimizedDailyEntryModel dailyEntry, String userName) {
    final recommendations = <SimpleGoalRecommendation>[];

    // Analizar métricas para generar goals inteligentes basados en el análisis de la IA
    final moodScore = dailyEntry.moodScore ?? 5;
    final stressLevel = dailyEntry.stressLevel ?? 5;
    final exerciseMinutes = dailyEntry.exerciseMinutes ?? 0;
    final meditationMinutes = dailyEntry.meditationMinutes ?? 0;
    final sleepQuality = dailyEntry.sleepQuality ?? 5;

    // La IA ya analizó todo, ahora generar goals basados en su análisis + métricas

    // GOAL 1: Basado en el análisis de la IA sobre el humor
    if (moodScore <= 5 || aiSummary.toLowerCase().contains('ánimo') || aiSummary.toLowerCase().contains('tristeza')) {
      recommendations.add(SimpleGoalRecommendation(
        title: 'Diario de Gratitud con IA',
        description: 'Escribe 3 cosas por las que estés agradecido cada mañana durante 21 días. La IA sugiere esto basándose en tu reflexión.',
        type: 'mood',
        targetDays: 21,
        reason: 'La IA detectó en tu reflexión que podrías beneficiarte de una práctica de gratitud para mejorar tu estado de ánimo',
        aiGenerated: true,
      ));
    }

    // GOAL 2: Basado en análisis de estrés de la IA
    if (stressLevel >= 7 || aiSummary.toLowerCase().contains('estrés') || aiSummary.toLowerCase().contains('ansiedad')) {
      recommendations.add(SimpleGoalRecommendation(
        title: 'Técnica de Respiración IA',
        description: 'Practica respiración 4-7-8 por 5 minutos diarios durante 2 semanas, basado en el análisis de tu reflexión.',
        type: 'stress',
        targetDays: 14,
        reason: 'La IA identificó patrones de estrés en tu reflexión y recomienda técnicas de respiración',
        aiGenerated: true,
      ));
    }

    // GOAL 3: Basado en actividad física
    if (exerciseMinutes < 20 || aiSummary.toLowerCase().contains('ejercicio') || aiSummary.toLowerCase().contains('actividad')) {
      recommendations.add(SimpleGoalRecommendation(
        title: 'Plan de Movimiento IA',
        description: 'Camina 20 minutos diarios durante 30 días. La IA sugiere esto después de analizar tu nivel de actividad.',
        type: 'exercise',
        targetDays: 30,
        reason: 'Según el análisis de la IA de tu reflexión, incrementar la actividad física te beneficiaría',
        aiGenerated: true,
      ));
    }

    // Si no hay recomendaciones específicas, crear una general basada en la IA
    if (recommendations.isEmpty) {
      recommendations.add(SimpleGoalRecommendation(
        title: 'Reflexión Profunda Guiada por IA',
        description: 'Dedica 10 minutos diarios a reflexión consciente durante 2 semanas, personalizado según tu patrón de pensamiento.',
        type: 'mindfulness',
        targetDays: 14,
        reason: 'La IA analizó tu reflexión y sugiere profundizar en la autoobservación',
        aiGenerated: true,
      ));
    }

    return recommendations.take(2).toList(); // Máximo 2 para empezar simple
  }

  /// 🔄 Fallback si falla la IA (básico pero funcional)
  List<SimpleGoalRecommendation> _generateFallbackRecommendations(OptimizedDailyEntryModel dailyEntry, String userName) {
    final recommendations = <SimpleGoalRecommendation>[];

    final moodScore = dailyEntry.moodScore ?? 5;
    final stressLevel = dailyEntry.stressLevel ?? 5;

    if (moodScore <= 5) {
      recommendations.add(SimpleGoalRecommendation(
        title: 'Gratitud Diaria Básica',
        description: 'Escribe 2 cosas positivas cada día durante 2 semanas',
        type: 'mood',
        targetDays: 14,
        reason: 'Tu estado de ánimo podría mejorar con una práctica de gratitud',
        aiGenerated: false,
      ));
    }

    if (stressLevel >= 7) {
      recommendations.add(SimpleGoalRecommendation(
        title: 'Pausa Consciente',
        description: 'Toma 3 respiraciones profundas antes de cada comida durante 1 semana',
        type: 'stress',
        targetDays: 7,
        reason: 'Tu nivel de estrés indica que necesitas momentos de calma',
        aiGenerated: false,
      ));
    }

    return recommendations.take(1).toList(); // Solo 1 en fallback
  }

  /// 📅 Obtener momentos de hoy
  Future<List<OptimizedInteractiveMomentModel>> _getTodayMoments(
      int userId,
      OptimizedDatabaseService databaseService
      ) async {
    try {
      return await databaseService.getInteractiveMoments(
        userId: userId,
        date: DateTime.now(),
      );
    } catch (e) {
      _logger.w('❌ Error obteniendo momentos: $e');
      return [];
    }
  }

  /// 📈 Obtener entradas recientes
  Future<List<OptimizedDailyEntryModel>> _getRecentEntries(
      int userId,
      OptimizedDatabaseService databaseService,
      ) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 3)); // Solo 3 días para simplicidad

      return await databaseService.getDailyEntries(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _logger.w('❌ Error obteniendo entradas recientes: $e');
      return [];
    }
  }
}

// ============================================================================
// MODELO SIMPLE DE RECOMENDACIÓN CON FLAG DE IA
// ============================================================================

class SimpleGoalRecommendation {
  final String title;
  final String description;
  final String type;
  final int targetDays;
  final String reason;
  final bool aiGenerated; // ✅ NUEVO: Indica si fue generado por IA real

  const SimpleGoalRecommendation({
    required this.title,
    required this.description,
    required this.type,
    required this.targetDays,
    required this.reason,
    this.aiGenerated = false,
  });

  @override
  String toString() {
    return 'SimpleGoalRecommendation(title: $title, days: $targetDays, AI: $aiGenerated)';
  }
}