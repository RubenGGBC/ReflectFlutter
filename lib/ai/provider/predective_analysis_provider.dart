// lib/ai/provider/predective_analysis_provider.dart
// ============================================================================
// SMART ANALYTICS PROVIDER - ANÁLISIS BASADO EN DATOS CON IA OPCIONAL
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'dart:math' as math;

import '../../data/services/optimized_database_service.dart';
import '../../data/models/optimized_models.dart';
import '../services/phi_model_service_genai_complete.dart';

// ============================================================================
// MODELOS SIMPLIFICADOS PARA ANALYTICS
// ============================================================================

/// Modelo para insights generados
class SmartInsight {
  final String id;
  final String title;
  final String description;
  final String category; // 'pattern', 'trend', 'recommendation', 'alert'
  final double confidence;
  final String actionableAdvice;
  final DateTime generatedAt;
  final Map<String, dynamic> supportingData;

  const SmartInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.confidence,
    required this.actionableAdvice,
    required this.generatedAt,
    required this.supportingData,
  });
}

/// Modelo para correlaciones encontradas
class EmotionalCorrelation {
  final String factor1;
  final String factor2;
  final double correlationStrength; // -1 to 1
  final String description;
  final List<String> examples;
  final String recommendation;

  const EmotionalCorrelation({
    required this.factor1,
    required this.factor2,
    required this.correlationStrength,
    required this.description,
    required this.examples,
    required this.recommendation,
  });
}

/// Modelo para forecasting de mood
class MoodForecast {
  final DateTime date;
  final double predictedMoodScore;
  final double predictedEnergyLevel;
  final double predictedStressLevel;
  final double confidence;
  final List<String> influences;
  final String recommendation;

  const MoodForecast({
    required this.date,
    required this.predictedMoodScore,
    required this.predictedEnergyLevel,
    required this.predictedStressLevel,
    required this.confidence,
    required this.influences,
    required this.recommendation,
  });
}

/// Modelo para personalidad emocional
class EmotionalPersonalityProfile {
  final Map<String, double> emotionalTraits;
  final String dominantEmotionalPattern;
  final List<String> strengthAreas;
  final List<String> growthAreas;
  final String personalityDescription;
  final Map<String, dynamic> detailedMetrics;

  const EmotionalPersonalityProfile({
    required this.emotionalTraits,
    required this.dominantEmotionalPattern,
    required this.strengthAreas,
    required this.growthAreas,
    required this.personalityDescription,
    required this.detailedMetrics,
  });
}

/// Modelo para reporte semanal
class WeeklyIntelligenceReport {
  final DateTime weekStart;
  final DateTime weekEnd;
  final Map<String, dynamic> weeklyMetrics;
  final List<SmartInsight> keyInsights;
  final List<EmotionalCorrelation> discoveredCorrelations;
  final String weeklyTrend;
  final double overallGrowthScore;
  final List<String> personalizedRecommendations;
  final Map<String, dynamic> comparativeAnalysis;
  final String aiSummary;

  const WeeklyIntelligenceReport({
    required this.weekStart,
    required this.weekEnd,
    required this.weeklyMetrics,
    required this.keyInsights,
    required this.discoveredCorrelations,
    required this.weeklyTrend,
    required this.overallGrowthScore,
    required this.personalizedRecommendations,
    required this.comparativeAnalysis,
    required this.aiSummary,
  });
}

// ============================================================================
// SMART ANALYTICS PROVIDER
// ============================================================================

class PredictiveAnalysisProvider extends ChangeNotifier {
  final OptimizedDatabaseService _databaseService;
  final PhiModelServiceGenAI _aiService = PhiModelServiceGenAI.instance;
  final Logger _logger = Logger();

  // Estados para insights
  List<SmartInsight> _smartInsights = [];
  bool _isGeneratingInsights = false;
  String? _insightsError;
  DateTime? _lastInsightsGeneration;

  // Estados para correlaciones
  List<EmotionalCorrelation> _emotionalCorrelations = [];
  bool _isAnalyzingCorrelations = false;
  String? _correlationsError;

  // Estados para forecasting
  List<MoodForecast> _moodForecasts = [];
  bool _isGeneratingForecasts = false;
  String? _forecastsError;

  // Estados para personalidad
  EmotionalPersonalityProfile? _personalityProfile;
  bool _isAnalyzingPersonality = false;
  String? _personalityError;

  // Estados para reporte semanal
  WeeklyIntelligenceReport? _weeklyReport;
  bool _isGeneratingWeeklyReport = false;
  String? _weeklyReportError;

  // Estado general
  bool _isAIReady = false;
  String _aiStatus = 'Verificando IA...';

  PredictiveAnalysisProvider(this._databaseService) {
    _checkAIStatus();
  }

  // ============================================================================
  // GETTERS
  // ============================================================================

  List<SmartInsight> get aiInsights => List.unmodifiable(_smartInsights);
  bool get isGeneratingInsights => _isGeneratingInsights;
  String? get insightsError => _insightsError;
  bool get hasAIInsights => _smartInsights.isNotEmpty;
  DateTime? get lastInsightsGeneration => _lastInsightsGeneration;

  List<EmotionalCorrelation> get emotionalCorrelations => List.unmodifiable(_emotionalCorrelations);
  bool get isAnalyzingCorrelations => _isAnalyzingCorrelations;
  String? get correlationsError => _correlationsError;
  bool get hasCorrelations => _emotionalCorrelations.isNotEmpty;

  List<MoodForecast> get moodForecasts => List.unmodifiable(_moodForecasts);
  bool get isGeneratingForecasts => _isGeneratingForecasts;
  String? get forecastsError => _forecastsError;
  bool get hasForecasts => _moodForecasts.isNotEmpty;

  EmotionalPersonalityProfile? get personalityProfile => _personalityProfile;
  bool get isAnalyzingPersonality => _isAnalyzingPersonality;
  String? get personalityError => _personalityError;
  bool get hasPersonalityProfile => _personalityProfile != null;

  WeeklyIntelligenceReport? get weeklyReport => _weeklyReport;
  bool get isGeneratingWeeklyReport => _isGeneratingWeeklyReport;
  String? get weeklyReportError => _weeklyReportError;
  bool get hasWeeklyReport => _weeklyReport != null;

  bool get isAIReady => _isAIReady;
  String get aiStatus => _aiStatus;

  bool get isLoading => _isGeneratingInsights ||
      _isAnalyzingCorrelations ||
      _isGeneratingForecasts ||
      _isAnalyzingPersonality ||
      _isGeneratingWeeklyReport;

  bool get hasAnyErrors => _insightsError != null ||
      _correlationsError != null ||
      _forecastsError != null ||
      _personalityError != null ||
      _weeklyReportError != null;

  // ============================================================================
  // VERIFICACIÓN DE IA
  // ============================================================================

  Future<void> _checkAIStatus() async {
    try {
      _isAIReady = _aiService.isInitialized;
      _aiStatus = _isAIReady ? 'IA operativa' : 'Modo análisis básico';
    } catch (e) {
      _isAIReady = false;
      _aiStatus = 'Análisis básico disponible';
    }
    notifyListeners();
  }

  // ============================================================================
  // ANÁLISIS DE INSIGHTS
  // ============================================================================

  Future<void> generateAIInsights({
    required int userId,
    int daysBack = 30,
    bool forceRegenerate = false,
  }) async {
    if (!forceRegenerate && _smartInsights.isNotEmpty && _lastInsightsGeneration != null) {
      final timeSince = DateTime.now().difference(_lastInsightsGeneration!);
      if (timeSince.inHours < 6) {
        _logger.i('💡 Insights recientes disponibles');
        return;
      }
    }

    _logger.i('🧠 Generando insights automáticos...');

    _isGeneratingInsights = true;
    _insightsError = null;
    notifyListeners();

    try {
      // Obtener datos del usuario
      final userData = await _gatherUserData(userId, daysBack);

      // Generar insights basados en datos
      final insights = await _analyzeDataForInsights(userData);

      _smartInsights = insights;
      _lastInsightsGeneration = DateTime.now();
      _insightsError = null;

      _logger.i('✅ Generados ${insights.length} insights');

    } catch (e) {
      _logger.e('❌ Error generando insights: $e');
      _insightsError = e.toString();
    } finally {
      _isGeneratingInsights = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // ANÁLISIS DE CORRELACIONES
  // ============================================================================

  Future<void> analyzeEmotionalCorrelations({
    required int userId,
    int daysBack = 60,
  }) async {
    _logger.i('🔍 Analizando correlaciones emocionales...');

    _isAnalyzingCorrelations = true;
    _correlationsError = null;
    notifyListeners();

    try {
      final userData = await _gatherUserData(userId, daysBack);
      final correlations = await _findCorrelations(userData);

      _emotionalCorrelations = correlations;
      _correlationsError = null;

      _logger.i('✅ Encontradas ${correlations.length} correlaciones');

    } catch (e) {
      _logger.e('❌ Error analizando correlaciones: $e');
      _correlationsError = e.toString();
    } finally {
      _isAnalyzingCorrelations = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // FORECASTING DE MOOD
  // ============================================================================

  Future<void> generateAdvancedMoodForecasts({
    required int userId,
    int daysAhead = 7,
  }) async {
    _logger.i('🔮 Generando forecasts de mood...');

    _isGeneratingForecasts = true;
    _forecastsError = null;
    notifyListeners();

    try {
      final userData = await _gatherUserData(userId, 60);
      final forecasts = await _generateForecasts(userData, daysAhead);

      _moodForecasts = forecasts;
      _forecastsError = null;

      _logger.i('✅ Generados forecasts para ${forecasts.length} días');

    } catch (e) {
      _logger.e('❌ Error generando forecasts: $e');
      _forecastsError = e.toString();
    } finally {
      _isGeneratingForecasts = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // ANÁLISIS DE PERSONALIDAD
  // ============================================================================

  Future<void> analyzeEmotionalPersonality({
    required int userId,
    int daysBack = 90,
  }) async {
    _logger.i('🎭 Analizando personalidad emocional...');

    _isAnalyzingPersonality = true;
    _personalityError = null;
    notifyListeners();

    try {
      final userData = await _gatherUserData(userId, daysBack);
      final profile = await _analyzePersonality(userData);

      _personalityProfile = profile;
      _personalityError = null;

      _logger.i('✅ Perfil de personalidad generado');

    } catch (e) {
      _logger.e('❌ Error analizando personalidad: $e');
      _personalityError = e.toString();
    } finally {
      _isAnalyzingPersonality = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // REPORTE SEMANAL
  // ============================================================================

  Future<void> generateWeeklyIntelligenceReport({
    required int userId,
    DateTime? weekStart,
  }) async {
    final actualWeekStart = weekStart ?? _getStartOfWeek(DateTime.now());
    final weekEnd = actualWeekStart.add(const Duration(days: 6));

    _logger.i('📋 Generando reporte semanal...');

    _isGeneratingWeeklyReport = true;
    _weeklyReportError = null;
    notifyListeners();

    try {
      final weeklyData = await _gatherWeeklyData(userId, actualWeekStart, weekEnd);
      final report = await _generateWeeklyReport(weeklyData, actualWeekStart, weekEnd);

      _weeklyReport = report;
      _weeklyReportError = null;

      _logger.i('✅ Reporte semanal generado');

    } catch (e) {
      _logger.e('❌ Error generando reporte: $e');
      _weeklyReportError = e.toString();
    } finally {
      _isGeneratingWeeklyReport = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // MÉTODOS DE ANÁLISIS DE DATOS
  // ============================================================================

  Future<Map<String, dynamic>> _gatherUserData(int userId, int daysBack) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: daysBack));

    final dailyEntries = await _databaseService.getDailyEntries(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    final moments = await _databaseService.getInteractiveMoments(
      userId: userId,
      limit: 500,
    );

    final analytics = await _databaseService.getUserAnalytics(userId, days: daysBack);

    return {
      'daily_entries': dailyEntries,
      'moments': moments,
      'analytics': analytics,
      'period': {
        'start_date': startDate,
        'end_date': endDate,
        'days_back': daysBack,
      },
    };
  }

  Future<List<SmartInsight>> _analyzeDataForInsights(Map<String, dynamic> userData) async {
    final insights = <SmartInsight>[];
    final entries = userData['daily_entries'] as List<OptimizedDailyEntryModel>;
    final moments = userData['moments'] as List<OptimizedInteractiveMomentModel>;

    if (entries.isEmpty) {
      return insights;
    }

    // Análisis 1: Tendencia general de mood
    final moodTrend = _analyzeMoodTrend(entries);
    if (moodTrend != null) {
      insights.add(moodTrend);
    }

    // Análisis 2: Patrones de energía
    final energyPattern = _analyzeEnergyPatterns(entries);
    if (energyPattern != null) {
      insights.add(energyPattern);
    }

    // Análisis 3: Análisis de estrés
    final stressAnalysis = _analyzeStressLevels(entries);
    if (stressAnalysis != null) {
      insights.add(stressAnalysis);
    }

    // Análisis 4: Patrones de sueño
    final sleepInsight = _analyzeSleepPatterns(entries);
    if (sleepInsight != null) {
      insights.add(sleepInsight);
    }

    // Análisis 5: Consistencia en reflexiones
    final consistencyInsight = _analyzeConsistency(entries, moments);
    if (consistencyInsight != null) {
      insights.add(consistencyInsight);
    }

    return insights;
  }

  SmartInsight? _analyzeMoodTrend(List<OptimizedDailyEntryModel> entries) {
    if (entries.length < 7) return null;

    final recentMoods = entries.take(7).map((e) => e.moodScore ?? 5).toList();
    final olderMoods = entries.skip(7).take(7).map((e) => e.moodScore ?? 5).toList();

    if (olderMoods.isEmpty) return null;

    final recentAvg = recentMoods.reduce((a, b) => a + b) / recentMoods.length;
    final olderAvg = olderMoods.reduce((a, b) => a + b) / olderMoods.length;

    final difference = recentAvg - olderAvg;

    if (difference > 0.5) {
      return SmartInsight(
        id: 'mood_improving_${DateTime.now().millisecondsSinceEpoch}',
        title: '📈 Tu estado de ánimo está mejorando',
        description: 'En los últimos 7 días tu mood promedio ha subido ${difference.toStringAsFixed(1)} puntos. ¡Vas por buen camino!',
        category: 'trend',
        confidence: 0.8,
        actionableAdvice: 'Identifica qué cambios has hecho recientemente y manténlos. Esta tendencia positiva es alentadora.',
        generatedAt: DateTime.now(),
        supportingData: {
          'recent_avg': recentAvg,
          'older_avg': olderAvg,
          'improvement': difference,
        },
      );
    } else if (difference < -0.5) {
      return SmartInsight(
        id: 'mood_declining_${DateTime.now().millisecondsSinceEpoch}',
        title: '📉 Ligera bajada en tu estado de ánimo',
        description: 'Tu mood promedio ha bajado ${difference.abs().toStringAsFixed(1)} puntos. Es normal tener fluctuaciones.',
        category: 'alert',
        confidence: 0.75,
        actionableAdvice: 'Considera revisar tus hábitos de sueño, ejercicio y alimentación. Un pequeño ajuste puede marcar la diferencia.',
        generatedAt: DateTime.now(),
        supportingData: {
          'recent_avg': recentAvg,
          'older_avg': olderAvg,
          'decline': difference,
        },
      );
    }

    return null;
  }

  SmartInsight? _analyzeEnergyPatterns(List<OptimizedDailyEntryModel> entries) {
    if (entries.length < 14) return null;

    // Analizar por día de la semana
    final energyByWeekday = <int, List<int>>{};

    for (final entry in entries) {
      final weekday = entry.entryDate.weekday;
      final energy = entry.energyLevel ?? 5;
      energyByWeekday.putIfAbsent(weekday, () => []).add(energy);
    }

    // Encontrar el día con menor energía
    double lowestAvg = 10.0;
    int lowestDay = 1;

    energyByWeekday.forEach((weekday, energies) {
      final avg = energies.reduce((a, b) => a + b) / energies.length;
      if (avg < lowestAvg) {
        lowestAvg = avg;
        lowestDay = weekday;
      }
    });

    final dayNames = ['', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

    if (lowestAvg < 4.5) {
      return SmartInsight(
        id: 'energy_pattern_${DateTime.now().millisecondsSinceEpoch}',
        title: '⚡ Patrón de energía detectado',
        description: 'Los ${dayNames[lowestDay]} tienes consistentemente menos energía (${lowestAvg.toStringAsFixed(1)}/10).',
        category: 'pattern',
        confidence: 0.85,
        actionableAdvice: 'Planifica tareas menos demandantes para los ${dayNames[lowestDay]} y asegúrate de descansar bien el día anterior.',
        generatedAt: DateTime.now(),
        supportingData: {
          'lowest_day': lowestDay,
          'average_energy': lowestAvg,
        },
      );
    }

    return null;
  }

  SmartInsight? _analyzeStressLevels(List<OptimizedDailyEntryModel> entries) {
    if (entries.length < 10) return null;

    final recentStress = entries.take(7).map((e) => e.stressLevel ?? 5).toList();
    final avgStress = recentStress.reduce((a, b) => a + b) / recentStress.length;

    if (avgStress > 7) {
      return SmartInsight(
        id: 'stress_alert_${DateTime.now().millisecondsSinceEpoch}',
        title: '⚠️ Niveles de estrés elevados',
        description: 'Tu estrés promedio esta semana es ${avgStress.toStringAsFixed(1)}/10. Es importante que cuides tu bienestar.',
        category: 'alert',
        confidence: 0.9,
        actionableAdvice: 'Considera técnicas de relajación como respiración profunda, meditación o ejercicio ligero. Si persiste, habla con un profesional.',
        generatedAt: DateTime.now(),
        supportingData: {
          'average_stress': avgStress,
          'high_stress_days': recentStress.where((s) => s > 7).length,
        },
      );
    } else if (avgStress < 3) {
      return SmartInsight(
        id: 'stress_low_${DateTime.now().millisecondsSinceEpoch}',
        title: '😌 Excelente manejo del estrés',
        description: 'Tu estrés promedio es solo ${avgStress.toStringAsFixed(1)}/10. ¡Fantástico manejo emocional!',
        category: 'trend',
        confidence: 0.85,
        actionableAdvice: 'Mantén las estrategias que estás usando. Podrías compartir tus técnicas con otros o profundizar en mindfulness.',
        generatedAt: DateTime.now(),
        supportingData: {
          'average_stress': avgStress,
        },
      );
    }

    return null;
  }

  SmartInsight? _analyzeSleepPatterns(List<OptimizedDailyEntryModel> entries) {
    final entriesWithSleep = entries.where((e) => e.sleepHours != null && e.sleepHours! > 0).toList();

    if (entriesWithSleep.length < 7) return null;

    final avgSleep = entriesWithSleep.map((e) => e.sleepHours!).reduce((a, b) => a + b) / entriesWithSleep.length;

    if (avgSleep < 6.5) {
      return SmartInsight(
        id: 'sleep_insufficient_${DateTime.now().millisecondsSinceEpoch}',
        title: '😴 Sueño insuficiente detectado',
        description: 'Promedio de ${avgSleep.toStringAsFixed(1)} horas de sueño. La mayoría de adultos necesitan 7-9 horas.',
        category: 'alert',
        confidence: 0.9,
        actionableAdvice: 'Intenta acostarte 30 minutos más temprano y crear una rutina relajante antes de dormir.',
        generatedAt: DateTime.now(),
        supportingData: {
          'average_sleep': avgSleep,
          'recommended_min': 7.0,
        },
      );
    } else if (avgSleep > 8.5) {
      return SmartInsight(
        id: 'sleep_optimal_${DateTime.now().millisecondsSinceEpoch}',
        title: '🌙 Excelentes hábitos de sueño',
        description: 'Promedio de ${avgSleep.toStringAsFixed(1)} horas de sueño. ¡Mantienes una rutina saludable!',
        category: 'trend',
        confidence: 0.8,
        actionableAdvice: 'Tu sueño es excelente. Mantén la consistencia en tus horarios para optimizar la calidad.',
        generatedAt: DateTime.now(),
        supportingData: {
          'average_sleep': avgSleep,
        },
      );
    }

    return null;
  }

  SmartInsight? _analyzeConsistency(List<OptimizedDailyEntryModel> entries, List<OptimizedInteractiveMomentModel> moments) {
    final daysWithData = entries.length;
    final totalPossibleDays = DateTime.now().difference(entries.isNotEmpty ? entries.last.entryDate : DateTime.now()).inDays + 1;

    final consistencyRate = daysWithData / math.max(totalPossibleDays, 1);

    if (consistencyRate > 0.8) {
      return SmartInsight(
        id: 'consistency_excellent_${DateTime.now().millisecondsSinceEpoch}',
        title: '🎯 Excelente consistencia',
        description: 'Has registrado datos en ${(consistencyRate * 100).toInt()}% de los días. ¡Increíble dedicación!',
        category: 'trend',
        confidence: 0.95,
        actionableAdvice: 'Tu consistencia es ejemplar. Esto te permite tener análisis más precisos y útiles.',
        generatedAt: DateTime.now(),
        supportingData: {
          'consistency_rate': consistencyRate,
          'days_with_data': daysWithData,
        },
      );
    } else if (consistencyRate < 0.4) {
      return SmartInsight(
        id: 'consistency_low_${DateTime.now().millisecondsSinceEpoch}',
        title: '📝 Oportunidad de mejora',
        description: 'Has registrado datos en ${(consistencyRate * 100).toInt()}% de los días. Más datos = mejores insights.',
        category: 'recommendation',
        confidence: 0.8,
        actionableAdvice: 'Intenta crear un recordatorio diario para registrar tus reflexiones. La consistencia es clave.',
        generatedAt: DateTime.now(),
        supportingData: {
          'consistency_rate': consistencyRate,
          'days_with_data': daysWithData,
        },
      );
    }

    return null;
  }

  Future<List<EmotionalCorrelation>> _findCorrelations(Map<String, dynamic> userData) async {
    final correlations = <EmotionalCorrelation>[];
    final entries = userData['daily_entries'] as List<OptimizedDailyEntryModel>;

    if (entries.length < 14) return correlations;

    // Correlación: Sueño vs Mood
    final sleepMoodCorr = _calculateCorrelation(
      entries.where((e) => e.sleepHours != null).map((e) => e.sleepHours!.toDouble()).toList(),
      entries.where((e) => e.sleepHours != null).map((e) => (e.moodScore ?? 5).toDouble()).toList(),
    );

    if (sleepMoodCorr.abs() > 0.4) {
      correlations.add(EmotionalCorrelation(
        factor1: 'Horas de sueño',
        factor2: 'Estado de ánimo',
        correlationStrength: sleepMoodCorr,
        description: sleepMoodCorr > 0
            ? 'Cuando duermes más, tu estado de ánimo tiende a mejorar.'
            : 'Existe una relación inesperada entre tu sueño y mood.',
        examples: [
          'Noches de ${sleepMoodCorr > 0 ? "buen" : "poco"} sueño correlacionan con ${sleepMoodCorr > 0 ? "mejor" : "diferente"} humor',
        ],
        recommendation: sleepMoodCorr > 0
            ? 'Prioriza dormir 7-8 horas para mantener un buen estado de ánimo.'
            : 'Revisa la calidad de tu sueño, no solo la cantidad.',
      ));
    }

    // Correlación: Ejercicio vs Energía
    final exerciseEnergyCorr = _calculateCorrelation(
      entries.where((e) => e.exerciseMinutes != null).map((e) => (e.exerciseMinutes ?? 0).toDouble()).toList(),
      entries.where((e) => e.exerciseMinutes != null).map((e) => (e.energyLevel ?? 5).toDouble()).toList(),
    );

    if (exerciseEnergyCorr.abs() > 0.3) {
      correlations.add(EmotionalCorrelation(
        factor1: 'Ejercicio',
        factor2: 'Nivel de energía',
        correlationStrength: exerciseEnergyCorr,
        description: exerciseEnergyCorr > 0
            ? 'Los días que haces ejercicio tienes más energía.'
            : 'Tu ejercicio y energía muestran una relación compleja.',
        examples: [
          'Días con ${exerciseEnergyCorr > 0 ? "más" : "diferente"} actividad física = ${exerciseEnergyCorr > 0 ? "mayor" : "variada"} energía',
        ],
        recommendation: exerciseEnergyCorr > 0
            ? 'Incluye actividad física regular para mantener buenos niveles de energía.'
            : 'Encuentra el balance óptimo entre ejercicio y descanso.',
      ));
    }

    return correlations;
  }

  double _calculateCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 3) return 0.0;

    final n = x.length;
    final meanX = x.reduce((a, b) => a + b) / n;
    final meanY = y.reduce((a, b) => a + b) / n;

    double numerator = 0.0;
    double sumXX = 0.0;
    double sumYY = 0.0;

    for (int i = 0; i < n; i++) {
      final dx = x[i] - meanX;
      final dy = y[i] - meanY;
      numerator += dx * dy;
      sumXX += dx * dx;
      sumYY += dy * dy;
    }

    final denominator = math.sqrt(sumXX * sumYY);
    return denominator != 0 ? numerator / denominator : 0.0;
  }

  Future<List<MoodForecast>> _generateForecasts(Map<String, dynamic> userData, int daysAhead) async {
    final forecasts = <MoodForecast>[];
    final entries = userData['daily_entries'] as List<OptimizedDailyEntryModel>;

    if (entries.length < 21) return forecasts;

    // Análisis por día de la semana
    final weekdayPatterns = <int, List<int>>{};
    for (final entry in entries) {
      final weekday = entry.entryDate.weekday;
      weekdayPatterns.putIfAbsent(weekday, () => []).add(entry.moodScore ?? 5);
    }

    // Calcular promedios por día
    final weekdayAverages = <int, double>{};
    weekdayPatterns.forEach((weekday, moods) {
      weekdayAverages[weekday] = moods.reduce((a, b) => a + b) / moods.length;
    });

    // Generar forecasts
    for (int i = 1; i <= daysAhead; i++) {
      final futureDate = DateTime.now().add(Duration(days: i));
      final weekday = futureDate.weekday;

      final baselineMood = weekdayAverages[weekday] ?? 5.0;
      final recentTrend = _calculateRecentTrend(entries);

      final predictedMood = (baselineMood + recentTrend * 0.3).clamp(1.0, 10.0);

      forecasts.add(MoodForecast(
        date: futureDate,
        predictedMoodScore: predictedMood,
        predictedEnergyLevel: (predictedMood * 0.8 + 2).clamp(1.0, 10.0),
        predictedStressLevel: (10 - predictedMood * 0.6).clamp(1.0, 10.0),
        confidence: math.max(0.4, 0.9 - (i * 0.1)),
        influences: _getWeekdayInfluences(weekday),
        recommendation: _getForecastRecommendation(predictedMood, weekday),
      ));
    }

    return forecasts;
  }

  double _calculateRecentTrend(List<OptimizedDailyEntryModel> entries) {
    if (entries.length < 7) return 0.0;

    final recent = entries.take(3).map((e) => e.moodScore ?? 5).toList();
    final older = entries.skip(3).take(3).map((e) => e.moodScore ?? 5).toList();

    if (older.isEmpty) return 0.0;

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;

    return recentAvg - olderAvg;
  }

  List<String> _getWeekdayInfluences(int weekday) {
    final influences = <String>[];

    switch (weekday) {
      case 1: // Lunes
        influences.addAll(['Inicio de semana', 'Transición del fin de semana']);
        break;
      case 2: // Martes
        influences.addAll(['Productividad laboral', 'Rutina establecida']);
        break;
      case 3: // Miércoles
        influences.addAll(['Mitad de semana', 'Momentum laboral']);
        break;
      case 4: // Jueves
        influences.addAll(['Pre-fin de semana', 'Acumulación semanal']);
        break;
      case 5: // Viernes
        influences.addAll(['Fin de semana cercano', 'Relajación anticipada']);
        break;
      case 6: // Sábado
        influences.addAll(['Tiempo libre', 'Actividades sociales']);
        break;
      case 7: // Domingo
        influences.addAll(['Descanso', 'Preparación para la semana']);
        break;
    }

    return influences;
  }

  String _getForecastRecommendation(double predictedMood, int weekday) {
    final weekdays = ['', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];

    if (predictedMood > 7) {
      return 'Buen día esperado para el ${weekdays[weekday]}. Aprovecha esta energía positiva para tareas importantes.';
    } else if (predictedMood < 4) {
      return 'El ${weekdays[weekday]} podría ser más desafiante. Planifica actividades relajantes y sé gentil contigo mismo.';
    } else {
      return 'Día balanceado esperado para el ${weekdays[weekday]}. Mantén tus rutinas habituales.';
    }
  }

  Future<EmotionalPersonalityProfile> _analyzePersonality(Map<String, dynamic> userData) async {
    final entries = userData['daily_entries'] as List<OptimizedDailyEntryModel>;
    final moments = userData['moments'] as List<OptimizedInteractiveMomentModel>;

    // Calcular rasgos emocionales
    final traits = <String, double>{};

    // Resilencia (basada en recuperación de días difíciles)
    traits['resilience'] = _calculateResilience(entries);

    // Estabilidad emocional
    traits['emotional_stability'] = _calculateStability(entries);

    // Optimismo (tendencia hacia mood positivo)
    traits['optimism'] = _calculateOptimism(entries);

    // Autoregulación (manejo del estrés)
    traits['self_regulation'] = _calculateSelfRegulation(entries);

    // Consciencia emocional (diversidad en momentos)
    traits['emotional_awareness'] = _calculateAwareness(moments);

    // Determinar patrón dominante
    final dominantPattern = _determineDominantPattern(traits);

    // Identificar fortalezas y áreas de crecimiento
    final strengths = _identifyStrengths(traits);
    final growthAreas = _identifyGrowthAreas(traits);

    return EmotionalPersonalityProfile(
      emotionalTraits: traits,
      dominantEmotionalPattern: dominantPattern,
      strengthAreas: strengths,
      growthAreas: growthAreas,
      personalityDescription: _generatePersonalityDescription(traits, dominantPattern),
      detailedMetrics: {
        'data_points': entries.length + moments.length,
        'analysis_depth': entries.length > 60 ? 'high' : 'medium',
      },
    );
  }

  double _calculateResilience(List<OptimizedDailyEntryModel> entries) {
    if (entries.length < 14) return 0.5;

    int recoveryCount = 0;
    int difficultDays = 0;

    for (int i = 0; i < entries.length - 1; i++) {
      final today = entries[i].moodScore ?? 5;
      final tomorrow = entries[i + 1].moodScore ?? 5;

      if (today < 4) {
        difficultDays++;
        if (tomorrow > today + 1) {
          recoveryCount++;
        }
      }
    }

    return difficultDays > 0 ? (recoveryCount / difficultDays).clamp(0.0, 1.0) : 0.7;
  }

  double _calculateStability(List<OptimizedDailyEntryModel> entries) {
    if (entries.length < 7) return 0.5;

    final moods = entries.map((e) => e.moodScore ?? 5).toList();
    final mean = moods.reduce((a, b) => a + b) / moods.length;
    final variance = moods.map((m) => math.pow(m - mean, 2)).reduce((a, b) => a + b) / moods.length;

    // Inversamente proporcional a la varianza (más estable = menor varianza)
    return (1.0 / (1.0 + variance / 4.0)).clamp(0.0, 1.0);
  }

  double _calculateOptimism(List<OptimizedDailyEntryModel> entries) {
    if (entries.isEmpty) return 0.5;

    final avgMood = entries.map((e) => e.moodScore ?? 5).reduce((a, b) => a + b) / entries.length;
    return ((avgMood - 1) / 9).clamp(0.0, 1.0);
  }

  double _calculateSelfRegulation(List<OptimizedDailyEntryModel> entries) {
    if (entries.isEmpty) return 0.5;

    final avgStress = entries.map((e) => e.stressLevel ?? 5).reduce((a, b) => a + b) / entries.length;
    return (1.0 - (avgStress - 1) / 9).clamp(0.0, 1.0);
  }

  double _calculateAwareness(List<OptimizedInteractiveMomentModel> moments) {
    if (moments.isEmpty) return 0.3;

    final uniqueEmojis = moments.map((m) => m.emoji).toSet().length;
    final uniqueTypes = moments.map((m) => m.type).toSet().length;

    return (math.min(uniqueEmojis / 10.0, 1.0) + math.min(uniqueTypes / 3.0, 1.0)) / 2.0;
  }

  String _determineDominantPattern(Map<String, double> traits) {
    final resilience = traits['resilience'] ?? 0.5;
    final stability = traits['emotional_stability'] ?? 0.5;
    final optimism = traits['optimism'] ?? 0.5;

    if (resilience > 0.7 && optimism > 0.7) {
      return 'Resiliente Optimista';
    } else if (stability > 0.8) {
      return 'Emocionalmente Estable';
    } else if (optimism > 0.7) {
      return 'Naturalmente Positivo';
    } else if (resilience > 0.7) {
      return 'Adaptativo Fuerte';
    } else {
      return 'En Desarrollo Emocional';
    }
  }

  List<String> _identifyStrengths(Map<String, double> traits) {
    final strengths = <String>[];

    traits.forEach((trait, value) {
      if (value > 0.7) {
        switch (trait) {
          case 'resilience':
            strengths.add('Excelente capacidad de recuperación');
            break;
          case 'emotional_stability':
            strengths.add('Gran estabilidad emocional');
            break;
          case 'optimism':
            strengths.add('Perspectiva naturalmente positiva');
            break;
          case 'self_regulation':
            strengths.add('Buen manejo del estrés');
            break;
          case 'emotional_awareness':
            strengths.add('Alta consciencia emocional');
            break;
        }
      }
    });

    if (strengths.isEmpty) {
      strengths.add('Compromiso con el crecimiento personal');
      strengths.add('Apertura a la autoreflexión');
    }

    return strengths;
  }

  List<String> _identifyGrowthAreas(Map<String, double> traits) {
    final growthAreas = <String>[];

    traits.forEach((trait, value) {
      if (value < 0.4) {
        switch (trait) {
          case 'resilience':
            growthAreas.add('Desarrollo de estrategias de recuperación emocional');
            break;
          case 'emotional_stability':
            growthAreas.add('Práctica de técnicas de regulación emocional');
            break;
          case 'optimism':
            growthAreas.add('Cultivo de una perspectiva más positiva');
            break;
          case 'self_regulation':
            growthAreas.add('Mejora en el manejo del estrés y ansiedad');
            break;
          case 'emotional_awareness':
            growthAreas.add('Expansión del vocabulario emocional');
            break;
        }
      }
    });

    if (growthAreas.isEmpty) {
      growthAreas.add('Continuar con la práctica de mindfulness');
      growthAreas.add('Explorar nuevas técnicas de bienestar');
    }

    return growthAreas;
  }

  String _generatePersonalityDescription(Map<String, double> traits, String dominantPattern) {
    final resilience = traits['resilience'] ?? 0.5;
    final stability = traits['emotional_stability'] ?? 0.5;
    final optimism = traits['optimism'] ?? 0.5;

    return 'Tu perfil emocional muestra el patrón "$dominantPattern". '
        'Destacas por tu ${resilience > 0.6 ? "buena capacidad de recuperación" : "potencial de crecimiento en resiliencia"} '
        'y ${stability > 0.6 ? "estabilidad emocional" : "oportunidades para desarrollar mayor estabilidad"}. '
        '${optimism > 0.6 ? "Tu tendencia hacia el optimismo es una gran fortaleza." : "Trabajar en una perspectiva más positiva puede ser muy beneficioso."}';
  }

  Future<Map<String, dynamic>> _gatherWeeklyData(int userId, DateTime weekStart, DateTime weekEnd) async {
    final weeklyEntries = await _databaseService.getDailyEntries(
      userId: userId,
      startDate: weekStart,
      endDate: weekEnd,
    );

    final weeklyMoments = await _databaseService.getInteractiveMoments(
      userId: userId,
      limit: 100,
    ).then((moments) => moments.where((m) =>
    m.timestamp.isAfter(weekStart) && m.timestamp.isBefore(weekEnd.add(const Duration(days: 1)))
    ).toList());

    // Calcular métricas semanales
    final weeklyMetrics = <String, dynamic>{};

    if (weeklyEntries.isNotEmpty) {
      final moodScores = weeklyEntries.map((e) => e.moodScore ?? 5).toList();
      final energyLevels = weeklyEntries.map((e) => e.energyLevel ?? 5).toList();
      final stressLevels = weeklyEntries.map((e) => e.stressLevel ?? 5).toList();

      weeklyMetrics['avg_mood'] = moodScores.isNotEmpty
          ? moodScores.reduce((a, b) => a + b) / moodScores.length
          : 5.0;
      weeklyMetrics['avg_energy'] = energyLevels.isNotEmpty
          ? energyLevels.reduce((a, b) => a + b) / energyLevels.length
          : 5.0;
      weeklyMetrics['avg_stress'] = stressLevels.isNotEmpty
          ? stressLevels.reduce((a, b) => a + b) / stressLevels.length
          : 5.0;
      weeklyMetrics['total_entries'] = weeklyEntries.length;
      weeklyMetrics['total_moments'] = weeklyMoments.length;
    }

    return {
      'weekly_entries': weeklyEntries,
      'weekly_moments': weeklyMoments,
      'weekly_metrics': weeklyMetrics,
      'week_start': weekStart,
      'week_end': weekEnd,
    };
  }

  Future<WeeklyIntelligenceReport> _generateWeeklyReport(
      Map<String, dynamic> weeklyData,
      DateTime weekStart,
      DateTime weekEnd
      ) async {
    final entries = weeklyData['weekly_entries'] as List<OptimizedDailyEntryModel>;
    final moments = weeklyData['weekly_moments'] as List<OptimizedInteractiveMomentModel>;
    final metrics = weeklyData['weekly_metrics'] as Map<String, dynamic>;

    // Generar insights de la semana
    final weeklyInsights = await _generateWeeklyInsights(entries, moments);

    // Calcular score de crecimiento
    final growthScore = _calculateWeeklyGrowthScore(entries, moments);

    // Determinar tendencia
    final trend = _determineWeeklyTrend(entries);

    // Generar recomendaciones
    final recommendations = _generateWeeklyRecommendations(entries, moments, metrics);

    // Análisis comparativo (placeholder)
    final comparativeAnalysis = <String, dynamic>{
      'vs_previous_week': 'Datos insuficientes para comparación',
      'vs_monthly_average': 'Análisis en desarrollo',
    };

    return WeeklyIntelligenceReport(
      weekStart: weekStart,
      weekEnd: weekEnd,
      weeklyMetrics: metrics,
      keyInsights: weeklyInsights,
      discoveredCorrelations: [], // Se podrían agregar correlaciones específicas de la semana
      weeklyTrend: trend,
      overallGrowthScore: growthScore,
      personalizedRecommendations: recommendations,
      comparativeAnalysis: comparativeAnalysis,
      aiSummary: _generateWeeklySummary(entries, moments, growthScore, trend),
    );
  }

  List<SmartInsight> _generateWeeklyInsights(List<OptimizedDailyEntryModel> entries, List<OptimizedInteractiveMomentModel> moments) {
    final insights = <SmartInsight>[];

    if (entries.isNotEmpty) {
      final avgMood = entries.map((e) => e.moodScore ?? 5).reduce((a, b) => a + b) / entries.length;

      if (avgMood > 7) {
        insights.add(SmartInsight(
          id: 'weekly_mood_excellent_${DateTime.now().millisecondsSinceEpoch}',
          title: '🌟 Semana emocionalmente excelente',
          description: 'Tu mood promedio esta semana fue ${avgMood.toStringAsFixed(1)}/10. ¡Fantástico!',
          category: 'trend',
          confidence: 0.9,
          actionableAdvice: 'Identifica qué hizo especial a esta semana para replicarlo.',
          generatedAt: DateTime.now(),
          supportingData: {'avg_mood': avgMood},
        ));
      }
    }

    if (moments.isNotEmpty) {
      final positiveCount = moments.where((m) => m.type == 'positive').length;
      final ratio = positiveCount / moments.length;

      if (ratio > 0.7) {
        insights.add(SmartInsight(
          id: 'weekly_positive_moments_${DateTime.now().millisecondsSinceEpoch}',
          title: '😊 Semana llena de momentos positivos',
          description: '${(ratio * 100).toInt()}% de tus momentos fueron positivos esta semana.',
          category: 'pattern',
          confidence: 0.85,
          actionableAdvice: 'Reflexiona sobre qué generó tantos momentos positivos.',
          generatedAt: DateTime.now(),
          supportingData: {'positive_ratio': ratio},
        ));
      }
    }

    return insights;
  }

  double _calculateWeeklyGrowthScore(List<OptimizedDailyEntryModel> entries, List<OptimizedInteractiveMomentModel> moments) {
    if (entries.isEmpty) return 0.5;

    double score = 0.0;

    // Factor 1: Consistencia (30%)
    final consistencyScore = entries.length / 7.0;
    score += consistencyScore * 0.3;

    // Factor 2: Mood promedio (40%)
    final avgMood = entries.map((e) => e.moodScore ?? 5).reduce((a, b) => a + b) / entries.length;
    final moodScore = (avgMood - 1) / 9.0;
    score += moodScore * 0.4;

    // Factor 3: Momentos registrados (20%)
    final momentsScore = math.min(moments.length / 10.0, 1.0);
    score += momentsScore * 0.2;

    // Factor 4: Variedad emocional (10%)
    final uniqueEmojis = moments.map((m) => m.emoji).toSet().length;
    final varietyScore = math.min(uniqueEmojis / 5.0, 1.0);
    score += varietyScore * 0.1;

    return score.clamp(0.0, 1.0);
  }

  String _determineWeeklyTrend(List<OptimizedDailyEntryModel> entries) {
    if (entries.length < 3) return 'stable';

    final firstHalf = entries.take(entries.length ~/ 2);
    final secondHalf = entries.skip(entries.length ~/ 2);

    final firstAvg = firstHalf.map((e) => e.moodScore ?? 5).reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.map((e) => e.moodScore ?? 5).reduce((a, b) => a + b) / secondHalf.length;

    final difference = secondAvg - firstAvg;

    if (difference > 0.5) return 'improving';
    if (difference < -0.5) return 'declining';
    return 'stable';
  }

  List<String> _generateWeeklyRecommendations(
      List<OptimizedDailyEntryModel> entries,
      List<OptimizedInteractiveMomentModel> moments,
      Map<String, dynamic> metrics
      ) {
    final recommendations = <String>[];

    if (entries.length < 5) {
      recommendations.add('Intenta registrar reflexiones al menos 5 días por semana para mejores insights.');
    }

    final avgStress = metrics['avg_stress'] as double? ?? 5.0;
    if (avgStress > 6) {
      recommendations.add('Tus niveles de estrés están elevados. Considera técnicas de relajación.');
    }

    final avgSleep = entries.where((e) => e.sleepHours != null).isNotEmpty
        ? entries.where((e) => e.sleepHours != null).map((e) => e.sleepHours!).reduce((a, b) => a + b) / entries.where((e) => e.sleepHours != null).length
        : 7.0;

    if (avgSleep < 7) {
      recommendations.add('Prioriza dormir al menos 7 horas por noche para mejor bienestar.');
    }

    if (moments.length < 3) {
      recommendations.add('Registra más momentos especiales durante la semana para mayor consciencia emocional.');
    }

    if (recommendations.isEmpty) {
      recommendations.add('¡Continúa con tus excelentes hábitos de bienestar!');
      recommendations.add('Considera explorar nuevas técnicas de mindfulness.');
    }

    return recommendations;
  }

  String _generateWeeklySummary(List<OptimizedDailyEntryModel> entries, List<OptimizedInteractiveMomentModel> moments, double growthScore, String trend) {
    final scorePercent = (growthScore * 100).toInt();

    String summary = 'Esta semana has logrado un score de crecimiento del $scorePercent%. ';

    switch (trend) {
      case 'improving':
        summary += 'Tu tendencia es positiva, mostrando una mejora gradual a lo largo de la semana. ';
        break;
      case 'declining':
        summary += 'Hubo algunos desafíos esta semana, pero cada día es una nueva oportunidad. ';
        break;
      default:
        summary += 'Has mantenido una estabilidad emocional consistente. ';
    }

    if (entries.isNotEmpty) {
      summary += 'Registraste ${entries.length} reflexiones ';
    }

    if (moments.isNotEmpty) {
      summary += 'y ${moments.length} momentos especiales. ';
    }

    summary += 'Continúa con tu práctica de autoconocimiento, cada insight te acerca más a tu mejor versión.';

    return summary;
  }

  // ============================================================================
  // MÉTODOS DE UTILIDAD
  // ============================================================================

  DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }

  // ============================================================================
  // MÉTODOS DE LIMPIEZA Y RESUMEN
  // ============================================================================

  void clearPredictions() {
    _smartInsights.clear();
    _emotionalCorrelations.clear();
    _moodForecasts.clear();
    _personalityProfile = null;
    _weeklyReport = null;

    _insightsError = null;
    _correlationsError = null;
    _forecastsError = null;
    _personalityError = null;
    _weeklyReportError = null;

    _isGeneratingInsights = false;
    _isAnalyzingCorrelations = false;
    _isGeneratingForecasts = false;
    _isAnalyzingPersonality = false;
    _isGeneratingWeeklyReport = false;

    _lastInsightsGeneration = null;

    notifyListeners();
  }

  Map<String, dynamic> getAnalysisSummary() {
    return {
      'ai_insights': {
        'available': _smartInsights.isNotEmpty,
        'count': _smartInsights.length,
        'last_generation': _lastInsightsGeneration?.toIso8601String(),
        'error': _insightsError,
      },
      'correlations': {
        'available': _emotionalCorrelations.isNotEmpty,
        'count': _emotionalCorrelations.length,
        'error': _correlationsError,
      },
      'forecasts': {
        'available': _moodForecasts.isNotEmpty,
        'count': _moodForecasts.length,
        'error': _forecastsError,
      },
      'personality': {
        'available': _personalityProfile != null,
        'error': _personalityError,
      },
      'weekly_report': {
        'available': _weeklyReport != null,
        'growth_score': _weeklyReport?.overallGrowthScore,
        'error': _weeklyReportError,
      },
      'overall_status': {
        'is_loading': isLoading,
        'has_errors': hasAnyErrors,
        'ai_ready': _isAIReady,
        'ai_status': _aiStatus,
      }
    };
  }
}