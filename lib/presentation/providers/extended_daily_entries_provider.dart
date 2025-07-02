// lib/presentation/providers/extended_daily_entries_provider.dart
// ============================================================================
// PROVIDER EXTENDIDO QUE USA IA REAL PARA GENERAR GOALS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../data/models/optimized_models.dart';
import '../../data/services/optimized_database_service.dart';
import '../../ai/services/simple_ai_goals_service.dart';
import 'optimized_providers.dart';

class ExtendedDailyEntriesProvider extends OptimizedDailyEntriesProvider {
  final SimpleAIGoalsService _aiService = SimpleAIGoalsService.instance;
  final Logger _logger = Logger();

  // ✅ SOLUCIÓN: Almacenar referencia local al database service
  final OptimizedDatabaseService _databaseService;

  // Lista de recomendaciones generadas por IA REAL
  List<SimpleGoalRecommendation> _recommendations = [];
  bool _hasNewRecommendations = false;
  bool _isGeneratingRecommendations = false;

  // ✅ CONSTRUCTOR CORREGIDO: Almacenar la referencia
  ExtendedDailyEntriesProvider(OptimizedDatabaseService databaseService)
      : _databaseService = databaseService,
        super(databaseService);

  // Getters para las recomendaciones
  List<SimpleGoalRecommendation> get recommendations => List.unmodifiable(_recommendations);
  bool get hasNewRecommendations => _hasNewRecommendations;
  bool get isGeneratingRecommendations => _isGeneratingRecommendations;

  /// ✅ MÉTODO EXTENDIDO: Guardar entrada Y usar IA REAL para generar goals
  @override
  Future<bool> saveDailyEntry({
    required int userId,
    required String freeReflection,
    List<String> positiveTags = const [],
    List<String> negativeTags = const [],
    bool? worthIt,
    int? moodScore,
    int? energyLevel,
    int? stressLevel,
    int? sleepQuality,
    int? anxietyLevel,
    int? motivationLevel,
    int? socialInteraction,
    int? physicalActivity,
    int? workProductivity,
    double? sleepHours,
    int? waterIntake,
    int? meditationMinutes,
    int? exerciseMinutes,
    double? screenTimeHours,
    String? gratitudeItems,
    int? weatherMoodImpact,
    int? socialBattery,
    int? creativeEnergy,
    int? emotionalStability,
    int? focusLevel,
    int? lifeSatisfaction,

    // ✅ NUEVOS PARÁMETROS
    String userName = 'Usuario',
    bool useAI = true,
  }) async {

    // 1. Primero guardar la entrada normalmente
    final success = await super.saveDailyEntry(
      userId: userId,
      freeReflection: freeReflection,
      positiveTags: positiveTags,
      negativeTags: negativeTags,
      worthIt: worthIt,
      moodScore: moodScore,
      energyLevel: energyLevel,
      stressLevel: stressLevel,
      sleepQuality: sleepQuality,
      anxietyLevel: anxietyLevel,
      motivationLevel: motivationLevel,
      socialInteraction: socialInteraction,
      physicalActivity: physicalActivity,
      workProductivity: workProductivity,
      sleepHours: sleepHours,
      waterIntake: waterIntake,
      meditationMinutes: meditationMinutes,
      exerciseMinutes: exerciseMinutes,
      screenTimeHours: screenTimeHours,
      gratitudeItems: gratitudeItems,
      weatherMoodImpact: weatherMoodImpact,
      socialBattery: socialBattery,
      creativeEnergy: creativeEnergy,
      emotionalStability: emotionalStability,
      focusLevel: focusLevel,
      lifeSatisfaction: lifeSatisfaction,
    );

    // 2. Si se guardó exitosamente Y se solicita IA, generar recomendaciones
    if (success && useAI && todayEntry != null) {
      _generateAIRecommendations(userId, todayEntry!, userName);
    }

    return success;
  }

  /// 🤖 Generar recomendaciones usando IA REAL (en segundo plano)
  Future<void> _generateAIRecommendations(int userId, OptimizedDailyEntryModel dailyEntry, String userName) async {
    if (_isGeneratingRecommendations) return; // Evitar llamadas múltiples

    _isGeneratingRecommendations = true;
    notifyListeners();

    try {
      _logger.i('🤖 Usando IA REAL para generar recomendaciones...');

      // ✅ USAR LA IA REAL - Ahora _databaseService está disponible
      final recommendations = await _aiService.analyzeAndRecommend(
        userId: userId,
        dailyEntry: dailyEntry,
        userName: userName,
        databaseService: _databaseService,
      );

      _recommendations = recommendations;
      _hasNewRecommendations = recommendations.isNotEmpty;

      final aiCount = recommendations.where((r) => r.aiGenerated).length;
      _logger.i('✅ IA generó ${recommendations.length} recomendaciones (${aiCount} con IA real)');

    } catch (e) {
      _logger.e('❌ Error con IA: $e');
      _recommendations = [];
      _hasNewRecommendations = false;
    } finally {
      _isGeneratingRecommendations = false;
      notifyListeners();
    }
  }

  /// 📋 Marcar recomendaciones como vistas
  void markRecommendationsAsSeen() {
    _hasNewRecommendations = false;
    notifyListeners();
  }

  /// 🗑️ Limpiar recomendaciones
  void clearRecommendations() {
    _recommendations = [];
    _hasNewRecommendations = false;
    notifyListeners();
  }

  /// 🔄 Regenerar recomendaciones manualmente
  Future<void> regenerateRecommendations(int userId, String userName) async {
    if (todayEntry == null) {
      _logger.w('❌ No hay entrada de hoy para analizar');
      return;
    }

    await _generateAIRecommendations(userId, todayEntry!, userName);
  }
}