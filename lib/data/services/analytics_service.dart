// lib/data/services/analytics_service.dart
// CONSOLIDATED ANALYTICS SERVICE - ALL ANALYTICS METHODS IN ONE PLACE
// ============================================================================

import 'dart:math' as math;
import 'package:logger/logger.dart';

// Database & Models
import '../models/optimized_models.dart';
import '../models/analytics_models.dart';
import 'optimized_database_service.dart';

// AI Services
import '../../ai/services/predictive_analysis_service.dart';

/// Consolidated Analytics Service - All analytics methods in one place
/// This service combines the best analytics methods from across the project
/// for better organization and improved performance
class AnalyticsService {
  final OptimizedDatabaseService _databaseService;
  final PredictiveAnalysisService _predictiveService;
  final Logger _logger = Logger();

  AnalyticsService({
    required OptimizedDatabaseService databaseService,
    required PredictiveAnalysisService predictiveService,
  }) : _databaseService = databaseService,
       _predictiveService = predictiveService;

  // ============================================================================
  // CORE ANALYTICS METHODS
  // ============================================================================

  /// Complete analytics data load - Main entry point for analytics
  Future<Map<String, dynamic>> loadCompleteAnalytics(int userId, {int days = 30}) async {
    try {
      _logger.i('📊 Loading complete analytics for user $userId (${days}d)');

      // Load all analytics data in parallel for better performance
      final futures = await Future.wait([
        _databaseService.getUserAnalytics(userId, days: days),
        getAdvancedTimeSeriesAnalysis(userId, days: days),
        getMLPatternAnalysis(userId),
        _predictiveService.predictMoodTrends(
          userId: userId,
          daysAhead: 7,
          databaseService: _databaseService,
        ),
        _predictiveService.detectBurnoutRisk(
          userId: userId,
          databaseService: _databaseService,
        ),
      ]);

      final basicAnalytics = futures[0] as Map<String, dynamic>;
      final timeSeriesAnalysis = futures[1] as Map<String, dynamic>;
      final patternAnalysis = futures[2] as Map<String, dynamic>;
      final moodPrediction = futures[3];
      final burnoutRisk = futures[4];

      return {
        'basic_analytics': basicAnalytics,
        'time_series_analysis': timeSeriesAnalysis,
        'pattern_analysis': patternAnalysis,
        'mood_prediction': moodPrediction,
        'burnout_risk': burnoutRisk,
        'generated_at': DateTime.now().toIso8601String(),
        'days_analyzed': days,
        'user_id': userId,
      };

    } catch (e) {
      _logger.e('❌ Error loading complete analytics: $e');
      return {
        'error': e.toString(),
        'generated_at': DateTime.now().toIso8601String(),
      };
    }
  }

  // ============================================================================
  // ADVANCED TIME SERIES ANALYSIS
  // ============================================================================

  /// Advanced time series analysis with seasonal decomposition
  Future<Map<String, dynamic>> getAdvancedTimeSeriesAnalysis(int userId, {int days = 90}) async {
    try {
      _logger.i('📈 Performing advanced time series analysis');

      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      
      // Get daily entries for time series
      final dailyEntries = await _databaseService.getDailyEntries(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (dailyEntries.length < 7) {
        return {
          'error': 'Insufficient data for time series analysis',
          'minimum_required': 7,
          'current_data_points': dailyEntries.length,
        };
      }

      // Convert to time series data
      final timeSeriesData = dailyEntries.map((entry) => {
        'date': entry.entryDate.toIso8601String().split('T')[0],
        'mood_score': entry.moodScore ?? 5,
        'energy_level': entry.energyLevel ?? 5,
        'stress_level': entry.stressLevel ?? 5,
        'sleep_quality': entry.sleepQuality ?? 5,
        'timestamp': entry.entryDate.millisecondsSinceEpoch,
      }).toList();

      // Perform advanced analysis
      final seasonalDecomposition = _performSeasonalDecomposition(timeSeriesData);
      final trendAnalysis = _calculateAdvancedTrends(timeSeriesData);
      final correlationMatrix = _calculateCorrelationMatrix(timeSeriesData);
      final anomalies = _detectAnomalies(timeSeriesData);
      final patterns = _detectWeeklyPatterns(timeSeriesData);

      return {
        'seasonal_decomposition': seasonalDecomposition,
        'trend_analysis': trendAnalysis,
        'correlation_matrix': correlationMatrix,
        'anomalies': anomalies,
        'weekly_patterns': patterns,
        'data_quality': _assessDataQuality(timeSeriesData),
        'forecast': _generateShortTermForecast(timeSeriesData),
        'analysis_confidence': _calculateAnalysisConfidence(timeSeriesData),
      };

    } catch (e) {
      _logger.e('❌ Error in time series analysis: $e');
      return {'error': e.toString()};
    }
  }

  // ============================================================================
  // MACHINE LEARNING PATTERN ANALYSIS
  // ============================================================================

  /// ML-inspired pattern analysis with clustering and feature importance
  Future<Map<String, dynamic>> getMLPatternAnalysis(int userId) async {
    try {
      _logger.i('🤖 Performing ML pattern analysis');

      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 60));
      
      // Get comprehensive data
      final dailyEntries = await _databaseService.getDailyEntries(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final interactiveMoments = await _databaseService.getInteractiveMoments(
        userId: userId,
        limit: 500,
      );

      if (dailyEntries.length < 10) {
        return {'error': 'Insufficient data for ML analysis'};
      }

      // Feature engineering
      final features = _extractAdvancedFeatures(dailyEntries, interactiveMoments);
      
      // ML-inspired analysis
      final clustering = _performEmotionalClustering(features);
      final featureImportance = _calculateFeatureImportance(features);
      final behaviorPatterns = _identifyBehaviorPatterns(features);
      final emotionalProfiles = _generateEmotionalProfiles(features);
      
      return {
        'emotional_clusters': clustering,
        'feature_importance': featureImportance,
        'behavior_patterns': behaviorPatterns,
        'emotional_profiles': emotionalProfiles,
        'pattern_stability': _assessPatternStability(features),
        'recommendations': _generateMLRecommendations(clustering, featureImportance),
      };

    } catch (e) {
      _logger.e('❌ Error in ML pattern analysis: $e');
      return {'error': e.toString()};
    }
  }

  // ============================================================================
  // PREDICTIVE ANALYTICS - ENHANCED
  // ============================================================================

  /// Enhanced mood prediction with multiple algorithms
  Future<PrediccionEstadoAnimo> predecirEstadoAnimoProximaSemana(int userId) async {
    try {
      _logger.i('🔮 Predicting mood for next week');

      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      
      final dailyEntries = await _databaseService.getDailyEntries(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (dailyEntries.length < 7) {
        return PrediccionEstadoAnimo(
          fecha: DateTime.now().add(const Duration(days: 7)),
          estadoAnimoPredicto: 5.0,
          confianza: 0.0,
          factoresInfluencia: [
            FactorInfluencia(
              nombre: 'Datos insuficientes',
              impacto: 0.0,
              importancia: 0.0,
              categoria: 'warning',
              detalles: {'message': 'Se necesitan más datos para predicción precisa'},
            )
          ],
          tendencia: 'estable',
          probabilidadDepresion: 0.0,
          probabilidadAnsiedad: 0.0,
        );
      }

      // Advanced prediction using multiple methods
      final linearTrend = _calcularTendenciaLineal(dailyEntries);
      final exponentialSmoothing = _calcularSuavizadoExponencial(dailyEntries);
      final seasonalComponent = _calcularComponenteEstacional(dailyEntries);
      final confidenceScore = _calcularConfianzaPrediccion(dailyEntries);

      // Weighted ensemble prediction
      final ensemblePrediction = (linearTrend * 0.4) + 
                                (exponentialSmoothing * 0.4) + 
                                (seasonalComponent * 0.2);

      // Clamp to valid range
      final finalPrediction = math.max(1.0, math.min(10.0, ensemblePrediction));

      // Generate influence factors
      final influenceFactors = _identificarFactoresInfluencia(dailyEntries);

      return PrediccionEstadoAnimo(
        fecha: DateTime.now().add(const Duration(days: 7)),
        estadoAnimoPredicto: finalPrediction,
        confianza: confidenceScore,
        factoresInfluencia: _convertToFactorInfluencia(influenceFactors),
        tendencia: _determineTrend(dailyEntries),
        probabilidadDepresion: _calculateDepressionRisk(dailyEntries),
        probabilidadAnsiedad: _calculateAnxietyRisk(dailyEntries),
      );

    } catch (e) {
      _logger.e('❌ Error in mood prediction: $e');
      return PrediccionEstadoAnimo(
        fecha: DateTime.now().add(const Duration(days: 7)),
        estadoAnimoPredicto: 5.0,
        confianza: 0.0,
        factoresInfluencia: [
          FactorInfluencia(
            nombre: 'Error en el análisis',
            impacto: 0.0,
            importancia: 0.0,
            categoria: 'error',
            detalles: {'error': e.toString()},
          )
        ],
        tendencia: 'estable',
        probabilidadDepresion: 0.0,
        probabilidadAnsiedad: 0.0,
      );
    }
  }

  // ============================================================================
  // ANXIETY TRIGGERS ANALYSIS
  // ============================================================================

  /// Advanced anxiety triggers detection and analysis
  Future<AnalisisTriggersAnsiedad> analizarTriggersAnsiedad(int userId) async {
    try {
      _logger.i('😰 Analyzing anxiety triggers');

      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 60));
      
      final dailyEntries = await _databaseService.getDailyEntries(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final interactiveMoments = await _databaseService.getInteractiveMoments(
        userId: userId,
        limit: 200,
      );

      // Identify high stress/anxiety periods
      final highAnxietyDays = dailyEntries
          .where((entry) => (entry.stressLevel ?? 0) >= 7 || (entry.anxietyLevel ?? 0) >= 7)
          .toList();

      if (highAnxietyDays.isEmpty) {
        return AnalisisTriggersAnsiedad(
          triggersDetectados: [],
          patronesTemporales: {},
          nivelAnsiedadPromedio: 0.0,
          estrategiasRecomendadas: [],
          frecuenciaTriggers: {},
        );
      }

      // Analyze patterns
      final triggers = _identificarTriggersEspecificos(highAnxietyDays, interactiveMoments);
      final patterns = _analizarPatronesTriggers(highAnxietyDays);
      final severity = _calcularSeveridadPromedio(highAnxietyDays);
      final recommendations = _generarRecomendacionesManejo(triggers, patterns);

      return AnalisisTriggersAnsiedad(
        triggersDetectados: _convertToTriggerAnsiedad(triggers),
        patronesTemporales: _convertPatternsToMap(patterns),
        nivelAnsiedadPromedio: severity,
        estrategiasRecomendadas: _convertToEstrategiaManejo(recommendations),
        frecuenciaTriggers: _calculateTriggerFrequency(triggers),
      );

    } catch (e) {
      _logger.e('❌ Error analyzing anxiety triggers: $e');
      return AnalisisTriggersAnsiedad(
        triggersDetectados: [],
        patronesTemporales: {},
        nivelAnsiedadPromedio: 0.0,
        estrategiasRecomendadas: [],
        frecuenciaTriggers: {},
      );
    }
  }

  // ============================================================================
  // VISUALIZATION DATA METHODS
  // ============================================================================

  /// Get comprehensive dashboard data for visualization
  Future<Map<String, dynamic>> getDashboardData(int userId, {int days = 30}) async {
    try {
      _logger.i('📊 Generating dashboard data');

      final basicAnalytics = await _databaseService.getUserAnalytics(userId, days: days);
      
      return {
        'quick_stats': _generateQuickStats(basicAnalytics),
        'mood_chart_data': _generateMoodChartData(basicAnalytics),
        'trend_indicators': _generateTrendIndicators(basicAnalytics),
        'wellness_score': _calculateWellnessScore(basicAnalytics),
        'achievement_progress': _calculateAchievementProgress(basicAnalytics),
        'insights': _generateSmartInsights(basicAnalytics),
        'recommendations': _generatePriorityRecommendations(basicAnalytics),
        'streaks': _calculateStreakData(basicAnalytics),
      };

    } catch (e) {
      _logger.e('❌ Error generating dashboard data: $e');
      return {'error': e.toString()};
    }
  }

  // ============================================================================
  // HELPER METHODS - SEASONAL DECOMPOSITION
  // ============================================================================

  Map<String, dynamic> _performSeasonalDecomposition(List<Map<String, dynamic>> data) {
    if (data.length < 14) return {'error': 'Insufficient data for seasonal decomposition'};

    final moodValues = data.map((d) => (d['mood_score'] as num).toDouble()).toList();
    
    // Simple moving average for trend
    final trendWindow = 7;
    final trend = <double>[];
    
    for (int i = 0; i < moodValues.length; i++) {
      if (i < trendWindow ~/ 2 || i >= moodValues.length - trendWindow ~/ 2) {
        trend.add(moodValues[i]);
      } else {
        final windowStart = i - trendWindow ~/ 2;
        final windowEnd = i + trendWindow ~/ 2 + 1;
        final windowValues = moodValues.sublist(windowStart, windowEnd);
        trend.add(windowValues.reduce((a, b) => a + b) / windowValues.length);
      }
    }

    // Detrended data
    final detrended = List.generate(moodValues.length, (i) => moodValues[i] - trend[i]);

    // Weekly seasonal pattern
    final seasonal = <double>[];
    for (int i = 0; i < moodValues.length; i++) {
      final dayOfWeek = i % 7;
      final sameDayValues = <double>[];
      for (int j = dayOfWeek; j < detrended.length; j += 7) {
        sameDayValues.add(detrended[j]);
      }
      seasonal.add(sameDayValues.reduce((a, b) => a + b) / sameDayValues.length);
    }

    // Residual
    final residual = List.generate(moodValues.length, (i) => 
        moodValues[i] - trend[i] - seasonal[i]);

    return {
      'trend': trend,
      'seasonal': seasonal,
      'residual': residual,
      'original': moodValues,
      'trend_strength': _calculateTrendStrength(trend),
      'seasonal_strength': _calculateSeasonalStrength(seasonal),
      'noise_level': _calculateNoiseLevel(residual),
    };
  }

  // ============================================================================
  // HELPER METHODS - ADVANCED CALCULATIONS
  // ============================================================================

  Map<String, dynamic> _calculateAdvancedTrends(List<Map<String, dynamic>> data) {
    final moodTrend = _calculateLinearTrend(data.map((d) => (d['mood_score'] as num).toDouble()).toList());
    final energyTrend = _calculateLinearTrend(data.map((d) => (d['energy_level'] as num).toDouble()).toList());
    final stressTrend = _calculateLinearTrend(data.map((d) => (d['stress_level'] as num).toDouble()).toList());

    return {
      'mood_trend': moodTrend,
      'energy_trend': energyTrend,
      'stress_trend': stressTrend,
      'overall_direction': _categorizeOverallTrend(moodTrend, energyTrend, stressTrend),
      'trend_acceleration': _calculateTrendAcceleration(data),
    };
  }

  double _calculateLinearTrend(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final n = values.length;
    final x = List.generate(n, (i) => i.toDouble());
    final xMean = x.reduce((a, b) => a + b) / n;
    final yMean = values.reduce((a, b) => a + b) / n;
    
    double numerator = 0;
    double denominator = 0;
    
    for (int i = 0; i < n; i++) {
      numerator += (x[i] - xMean) * (values[i] - yMean);
      denominator += (x[i] - xMean) * (x[i] - xMean);
    }
    
    return denominator != 0 ? numerator / denominator : 0.0;
  }

  Map<String, double> _calculateCorrelationMatrix(List<Map<String, dynamic>> data) {
    final mood = data.map((d) => (d['mood_score'] as num).toDouble()).toList();
    final energy = data.map((d) => (d['energy_level'] as num).toDouble()).toList();
    final stress = data.map((d) => (d['stress_level'] as num).toDouble()).toList();
    final sleep = data.map((d) => (d['sleep_quality'] as num).toDouble()).toList();

    return {
      'mood_energy': _calculateCorrelation(mood, energy),
      'mood_stress': _calculateCorrelation(mood, stress),
      'mood_sleep': _calculateCorrelation(mood, sleep),
      'energy_stress': _calculateCorrelation(energy, stress),
      'energy_sleep': _calculateCorrelation(energy, sleep),
      'stress_sleep': _calculateCorrelation(stress, sleep),
    };
  }

  double _calculateCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 2) return 0.0;
    
    final n = x.length;
    final xMean = x.reduce((a, b) => a + b) / n;
    final yMean = y.reduce((a, b) => a + b) / n;
    
    double numerator = 0;
    double xSquaredSum = 0;
    double ySquaredSum = 0;
    
    for (int i = 0; i < n; i++) {
      final xDiff = x[i] - xMean;
      final yDiff = y[i] - yMean;
      numerator += xDiff * yDiff;
      xSquaredSum += xDiff * xDiff;
      ySquaredSum += yDiff * yDiff;
    }
    
    final denominator = math.sqrt(xSquaredSum * ySquaredSum);
    return denominator != 0 ? numerator / denominator : 0.0;
  }

  // ============================================================================
  // PLACEHOLDER HELPER METHODS (TO BE IMPLEMENTED)
  // ============================================================================

  List<Map<String, dynamic>> _detectAnomalies(List<Map<String, dynamic>> data) {
    if (data.length < 7) return [];
    
    final moodValues = data.map((d) => (d['mood_score'] as num).toDouble()).toList();
    final mean = moodValues.reduce((a, b) => a + b) / moodValues.length;
    final variance = moodValues.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / moodValues.length;
    final stdDev = math.sqrt(variance);
    final threshold = 2.0; // Z-score threshold
    
    final anomalies = <Map<String, dynamic>>[];
    for (int i = 0; i < data.length; i++) {
      final value = moodValues[i];
      final zScore = (value - mean) / stdDev;
      if (zScore.abs() > threshold) {
        anomalies.add({
          'date': data[i]['date'],
          'mood_score': value,
          'z_score': zScore,
          'type': zScore > 0 ? 'unusually_high' : 'unusually_low',
          'severity': zScore.abs() > 3 ? 'extreme' : 'moderate',
        });
      }
    }
    return anomalies;
  }

  Map<String, dynamic> _detectWeeklyPatterns(List<Map<String, dynamic>> data) {
    if (data.length < 14) return {};
    
    final weekdayMoods = <int, List<double>>{};
    
    for (int i = 0; i < data.length; i++) {
      final timestamp = data[i]['timestamp'] as int;
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final weekday = date.weekday; // 1=Monday, 7=Sunday
      final moodScore = (data[i]['mood_score'] as num).toDouble();
      
      weekdayMoods.putIfAbsent(weekday, () => <double>[]).add(moodScore);
    }
    
    final weekdayAverages = <String, double>{};
    final weekdayNames = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    for (final entry in weekdayMoods.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      weekdayAverages[weekdayNames[entry.key]] = avg;
    }
    
    // Find best and worst days
    final sortedDays = weekdayAverages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return {
      'weekday_averages': weekdayAverages,
      'best_day': sortedDays.first.key,
      'worst_day': sortedDays.last.key,
      'weekly_variance': _calculateWeeklyVariance(weekdayAverages.values.toList()),
      'pattern_strength': _calculatePatternStrength(weekdayAverages.values.toList()),
    };
  }

  Map<String, dynamic> _assessDataQuality(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return {'quality_score': 0.0, 'completeness': 0.0};
    
    // Check completeness
    final totalFields = data.length * 4; // mood, energy, stress, sleep
    int completedFields = 0;
    int consecutiveDays = 0;
    int maxConsecutive = 0;
    DateTime? lastDate;
    
    for (final entry in data) {
      if (entry['mood_score'] != null) completedFields++;
      if (entry['energy_level'] != null) completedFields++;
      if (entry['stress_level'] != null) completedFields++;
      if (entry['sleep_quality'] != null) completedFields++;
      
      // Check consecutive days
      final currentDate = DateTime.parse(entry['date']);
      if (lastDate != null && currentDate.difference(lastDate).inDays == 1) {
        consecutiveDays++;
        maxConsecutive = math.max(maxConsecutive, consecutiveDays);
      } else {
        consecutiveDays = 1;
      }
      lastDate = currentDate;
    }
    
    final completeness = completedFields / totalFields;
    final consistency = maxConsecutive / data.length;
    final qualityScore = (completeness * 0.7) + (consistency * 0.3);
    
    return {
      'quality_score': qualityScore,
      'completeness': completeness,
      'consistency': consistency,
      'max_consecutive_days': maxConsecutive,
      'total_entries': data.length,
    };
  }

  List<Map<String, dynamic>> _generateShortTermForecast(List<Map<String, dynamic>> data) {
    // TODO: Implement short-term forecasting
    return [];
  }

  double _calculateAnalysisConfidence(List<Map<String, dynamic>> data) {
    // TODO: Implement confidence calculation
    return 0.75;
  }

  Map<String, dynamic> _extractAdvancedFeatures(List<OptimizedDailyEntryModel> dailyEntries, List<OptimizedInteractiveMomentModel> moments) {
    // TODO: Implement advanced feature extraction
    return {};
  }

  Map<String, dynamic> _performEmotionalClustering(Map<String, dynamic> features) {
    // TODO: Implement emotional clustering
    return {};
  }

  Map<String, dynamic> _calculateFeatureImportance(Map<String, dynamic> features) {
    // TODO: Implement feature importance calculation
    return {};
  }

  Map<String, dynamic> _identifyBehaviorPatterns(Map<String, dynamic> features) {
    // TODO: Implement behavior pattern identification
    return {};
  }

  Map<String, dynamic> _generateEmotionalProfiles(Map<String, dynamic> features) {
    // TODO: Implement emotional profile generation
    return {};
  }

  double _assessPatternStability(Map<String, dynamic> features) {
    // TODO: Implement pattern stability assessment
    return 0.7;
  }

  List<String> _generateMLRecommendations(Map<String, dynamic> clustering, Map<String, dynamic> importance) {
    // TODO: Implement ML-based recommendations
    return ['Continue tracking your mood', 'Focus on sleep quality'];
  }

  // Additional helper methods for mood prediction
  double _calcularTendenciaLineal(List<OptimizedDailyEntryModel> entries) {
    final values = entries.map((e) => (e.moodScore ?? 5).toDouble()).toList();
    return _calculateLinearTrend(values);
  }

  double _calcularSuavizadoExponencial(List<OptimizedDailyEntryModel> entries) {
    // TODO: Implement exponential smoothing
    return 5.0;
  }

  double _calcularComponenteEstacional(List<OptimizedDailyEntryModel> entries) {
    // TODO: Implement seasonal component calculation
    return 0.0;
  }

  double _calcularConfianzaPrediccion(List<OptimizedDailyEntryModel> entries) {
    // TODO: Implement prediction confidence calculation
    return math.min(1.0, entries.length / 30.0);
  }

  List<String> _identificarFactoresInfluencia(List<OptimizedDailyEntryModel> entries) {
    // TODO: Implement influence factors identification
    return ['Sleep quality', 'Stress levels', 'Social interactions'];
  }

  List<String> _generarRecomendacionesPersonalizadas(List<OptimizedDailyEntryModel> entries, double prediction) {
    // TODO: Implement personalized recommendations
    if (prediction < 5.0) {
      return ['Focus on self-care activities', 'Consider reaching out to friends'];
    } else {
      return ['Maintain current positive habits', 'Continue tracking progress'];
    }
  }

  // Anxiety analysis helper methods
  List<String> _identificarTriggersEspecificos(List<OptimizedDailyEntryModel> entries, List<OptimizedInteractiveMomentModel> moments) {
    // TODO: Implement specific trigger identification
    return ['Work stress', 'Social situations', 'Sleep deprivation'];
  }

  Map<String, dynamic> _analizarPatronesTriggers(List<OptimizedDailyEntryModel> entries) {
    // TODO: Implement trigger pattern analysis
    return {'weekly_pattern': 'Mondays and Fridays', 'time_pattern': 'Evening hours'};
  }

  double _calcularSeveridadPromedio(List<OptimizedDailyEntryModel> entries) {
    if (entries.isEmpty) return 0.0;
    final stressLevels = entries.map((e) => (e.stressLevel ?? 0).toDouble()).toList();
    return stressLevels.reduce((a, b) => a + b) / stressLevels.length;
  }

  double _calcularFrecuenciaSemanal(List<OptimizedDailyEntryModel> entries) {
    if (entries.isEmpty) return 0.0;
    final weeks = entries.length / 7.0;
    return entries.length / weeks;
  }

  List<String> _generarRecomendacionesManejo(List<String> triggers, Map<String, dynamic> patterns) {
    // TODO: Implement management recommendations
    return ['Practice deep breathing exercises', 'Identify early warning signs', 'Maintain regular sleep schedule'];
  }

  // Dashboard data generation methods
  Map<String, dynamic> _generateQuickStats(Map<String, dynamic> analytics) {
    // TODO: Implement quick stats generation
    return {};
  }

  List<Map<String, dynamic>> _generateMoodChartData(Map<String, dynamic> analytics) {
    // TODO: Implement mood chart data generation
    return [];
  }

  Map<String, dynamic> _generateTrendIndicators(Map<String, dynamic> analytics) {
    // TODO: Implement trend indicators
    return {};
  }

  double _calculateWellnessScore(Map<String, dynamic> analytics) {
    // TODO: Implement wellness score calculation
    return 7.5;
  }

  Map<String, dynamic> _calculateAchievementProgress(Map<String, dynamic> analytics) {
    // TODO: Implement achievement progress calculation
    return {};
  }

  List<Map<String, dynamic>> _generateSmartInsights(Map<String, dynamic> analytics) {
    // TODO: Implement smart insights generation
    return [];
  }

  List<Map<String, dynamic>> _generatePriorityRecommendations(Map<String, dynamic> analytics) {
    // TODO: Implement priority recommendations
    return [];
  }

  Map<String, dynamic> _calculateStreakData(Map<String, dynamic> analytics) {
    // TODO: Implement streak calculation
    return {};
  }

  // Additional helper methods for seasonal decomposition
  double _calculateTrendStrength(List<double> trend) {
    // TODO: Implement trend strength calculation
    return 0.6;
  }

  double _calculateSeasonalStrength(List<double> seasonal) {
    // TODO: Implement seasonal strength calculation
    return 0.4;
  }

  double _calculateNoiseLevel(List<double> residual) {
    // TODO: Implement noise level calculation
    return 0.2;
  }

  String _categorizeOverallTrend(double mood, double energy, double stress) {
    // TODO: Implement overall trend categorization
    if (mood > 0.1 && energy > 0.1 && stress < -0.1) {
      return 'improving';
    } else if (mood < -0.1 && energy < -0.1 && stress > 0.1) {
      return 'declining';
    } else {
      return 'stable';
    }
  }

  Map<String, dynamic> _calculateTrendAcceleration(List<Map<String, dynamic>> data) {
    if (data.length < 3) return {'acceleration': 0.0, 'direction': 'stable'};
    
    final moodValues = data.map((d) => (d['mood_score'] as num).toDouble()).toList();
    final firstHalf = moodValues.sublist(0, moodValues.length ~/ 2);
    final secondHalf = moodValues.sublist(moodValues.length ~/ 2);
    
    final firstTrend = _calculateLinearTrend(firstHalf);
    final secondTrend = _calculateLinearTrend(secondHalf);
    final acceleration = secondTrend - firstTrend;
    
    String direction;
    if (acceleration > 0.1) {
      direction = 'accelerating_positive';
    } else if (acceleration < -0.1) {
      direction = 'accelerating_negative';
    } else {
      direction = 'stable';
    }
    
    return {'acceleration': acceleration, 'direction': direction};
  }

  double _calculateWeeklyVariance(List<double> weekdayAverages) {
    if (weekdayAverages.isEmpty) return 0.0;
    final mean = weekdayAverages.reduce((a, b) => a + b) / weekdayAverages.length;
    final variance = weekdayAverages.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / weekdayAverages.length;
    return variance;
  }

  double _calculatePatternStrength(List<double> weekdayAverages) {
    if (weekdayAverages.length < 2) return 0.0;
    final sortedValues = List<double>.from(weekdayAverages)..sort();
    final range = sortedValues.last - sortedValues.first;
    return math.min(1.0, range / 5.0); // Normalize to 0-1 scale
  }

  // ============================================================================
  // MISSING HELPER METHODS FOR PREDICCION ESTADO ANIMO
  // ============================================================================
  
  List<FactorInfluencia> _convertToFactorInfluencia(List<String> factors) {
    return factors.map((factor) => FactorInfluencia(
      nombre: factor,
      impacto: 0.5,
      importancia: 0.7,
      categoria: 'general',
      detalles: {'source': 'analytics'},
    )).toList();
  }

  String _determineTrend(List<OptimizedDailyEntryModel> entries) {
    if (entries.length < 2) return 'estable';
    final trend = _calcularTendenciaLineal(entries);
    if (trend > 0.1) return 'ascendente';
    if (trend < -0.1) return 'descendente';
    return 'estable';
  }

  double _calculateDepressionRisk(List<OptimizedDailyEntryModel> entries) {
    if (entries.isEmpty) return 0.0;
    final avgMood = entries.map((e) => e.moodScore ?? 5).reduce((a, b) => a + b) / entries.length;
    final avgEnergy = entries.map((e) => e.energyLevel ?? 5).reduce((a, b) => a + b) / entries.length;
    return math.max(0.0, math.min(1.0, (5.0 - avgMood) / 5.0 + (5.0 - avgEnergy) / 10.0));
  }

  double _calculateAnxietyRisk(List<OptimizedDailyEntryModel> entries) {
    if (entries.isEmpty) return 0.0;
    final avgStress = entries.map((e) => e.stressLevel ?? 5).reduce((a, b) => a + b) / entries.length;
    final avgAnxiety = entries.map((e) => e.anxietyLevel ?? 5).reduce((a, b) => a + b) / entries.length;
    return math.max(0.0, math.min(1.0, (avgStress + avgAnxiety - 10.0) / 10.0));
  }

  // ============================================================================
  // MISSING HELPER METHODS FOR ANXIETY ANALYSIS
  // ============================================================================
  
  List<TriggerAnsiedad> _convertToTriggerAnsiedad(List<String> triggers) {
    return triggers.map((trigger) => TriggerAnsiedad(
      nombre: trigger,
      categoria: 'general',
      intensidadPromedio: 7.0,
      ocurrencias: [DateTime.now()],
      contexto: {'source': 'analytics'},
      correlacionEstadoAnimo: 0.6,
    )).toList();
  }

  Map<String, double> _convertPatternsToMap(Map<String, dynamic> patterns) {
    return patterns.map((key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0));
  }

  List<EstrategiaManejo> _convertToEstrategiaManejo(List<String> recommendations) {
    return recommendations.map((rec) => EstrategiaManejo(
      nombre: rec,
      descripcion: 'Estrategia recomendada: $rec',
      tipo: 'general',
      efectividadEstimada: 0.7,
      pasos: [rec],
      duracionEstimada: '5-10 minutos',
    )).toList();
  }

  Map<String, int> _calculateTriggerFrequency(List<String> triggers) {
    final frequency = <String, int>{};
    for (final trigger in triggers) {
      frequency[trigger] = (frequency[trigger] ?? 0) + 1;
    }
    return frequency;
  }
}