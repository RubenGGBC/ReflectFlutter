// ============================================================================
// data/services/analytics_v3_extension.dart - ANALYTICS V3 DATABASE EXTENSION
// NEW ANALYTICS SERVICE - EXTENDS EXISTING DATABASE WITHOUT MODIFICATIONS
// ============================================================================

import 'dart:math' as math;
import '../models/analytics_v3_models.dart';
import 'optimized_database_service.dart';

class AnalyticsV3Extension {
  final OptimizedDatabaseService _databaseService;

  AnalyticsV3Extension(this._databaseService);

  // ============================================================================
  // COMPREHENSIVE ANALYTICS GENERATION
  // ============================================================================
  
  Future<AnalyticsV3Model> generateComprehensiveAnalytics(int userId, int periodDays) async {
    
    // Generate all analytics components
    final wellnessScore = await calculateWellnessScore(userId, periodDays);
    final activityCorrelations = await analyzeActivityCorrelations(userId, periodDays);
    final sleepPattern = await analyzeSleepPatterns(userId, periodDays);
    final stressManagement = await analyzeStressManagement(userId, periodDays);
    final goalAnalytics = await analyzeGoalPerformance(userId, periodDays);
    final temporalPatterns = await analyzeTemporalPatterns(userId, periodDays);
    
    // Generate summary metrics
    final summaryMetrics = await _generateSummaryMetrics(userId, periodDays);
    
    // Generate key insights
    final keyInsights = _generateKeyInsights(
      wellnessScore, 
      activityCorrelations, 
      sleepPattern, 
      stressManagement,
      goalAnalytics
    );

    return AnalyticsV3Model(
      generatedAt: DateTime.now(),
      userId: userId,
      periodDays: periodDays,
      wellnessScore: wellnessScore,
      activityCorrelations: activityCorrelations,
      sleepPattern: sleepPattern,
      stressManagement: stressManagement,
      goalAnalytics: goalAnalytics,
      temporalPatterns: temporalPatterns,
      summaryMetrics: summaryMetrics,
      keyInsights: keyInsights,
    );
  }

  // ============================================================================
  // WELLNESS SCORE CALCULATION
  // ============================================================================
  
  Future<WellnessScoreModel> calculateWellnessScore(int userId, int periodDays) async {
    // Validate input parameters
    if (userId <= 0 || periodDays <= 0) {
      throw ArgumentError('Invalid parameters: userId and periodDays must be positive');
    }
    
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    final result = await db.rawQuery('''
      SELECT 
        AVG(CAST(mood_score as REAL)) as avg_mood,
        AVG(CAST(energy_level as REAL)) as avg_energy,
        AVG(CAST(stress_level as REAL)) as avg_stress,
        AVG(CAST(sleep_quality as REAL)) as avg_sleep_quality,
        AVG(CAST(anxiety_level as REAL)) as avg_anxiety,
        AVG(CAST(motivation_level as REAL)) as avg_motivation,
        AVG(CAST(emotional_stability as REAL)) as avg_emotional_stability,
        AVG(CAST(life_satisfaction as REAL)) as avg_life_satisfaction,
        COUNT(*) as total_entries,
        COUNT(CASE WHEN mood_score IS NOT NULL THEN 1 END) as mood_entries,
        COUNT(CASE WHEN stress_level IS NOT NULL THEN 1 END) as stress_entries,
        COUNT(CASE WHEN anxiety_level IS NOT NULL THEN 1 END) as anxiety_entries
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND (mood_score IS NOT NULL OR energy_level IS NOT NULL)
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty || result.first['total_entries'] == 0) {
      return _createDefaultWellnessScore();
    }

    final data = result.first;
    final totalEntries = data['total_entries'] as int;
    
    // Require minimum data for reliable analysis
    if (totalEntries < 3) {
      return _createDefaultWellnessScore();
    }
    
    // Calculate component scores with proper validation and normalization
    final moodScore = _validateAndNormalizeScore(data['avg_mood'] as double?, 'mood');
    final energyScore = _validateAndNormalizeScore(data['avg_energy'] as double?, 'energy');
    
    // Fix stress/anxiety inversion with proper scale validation
    final stressCount = data['stress_entries'] as int;
    final anxietyCount = data['anxiety_entries'] as int;
    
    final rawStress = data['avg_stress'] as double? ?? 5.0;
    final rawAnxiety = data['avg_anxiety'] as double? ?? 5.0;
    
    // Only invert if we have sufficient data and values are in expected range (1-10)
    final stressScore = (stressCount >= 2 && rawStress >= 1.0 && rawStress <= 10.0) 
        ? math.max(0.0, math.min(10.0, 11.0 - rawStress)) 
        : _validateAndNormalizeScore(rawStress, 'stress');
        
    final anxietyScore = (anxietyCount >= 2 && rawAnxiety >= 1.0 && rawAnxiety <= 10.0) 
        ? math.max(0.0, math.min(10.0, 11.0 - rawAnxiety)) 
        : _validateAndNormalizeScore(rawAnxiety, 'anxiety');
    
    final sleepScore = _validateAndNormalizeScore(data['avg_sleep_quality'] as double?, 'sleep');
    final motivationScore = _validateAndNormalizeScore(data['avg_motivation'] as double?, 'motivation');
    final emotionalScore = _validateAndNormalizeScore(data['avg_emotional_stability'] as double?, 'emotional');
    final satisfactionScore = _validateAndNormalizeScore(data['avg_life_satisfaction'] as double?, 'satisfaction');

    final componentScores = {
      'mood': moodScore,
      'energy': energyScore,
      'stress': stressScore,
      'sleep': sleepScore,
      'anxiety': anxietyScore,
      'motivation': motivationScore,
      'emotional_stability': emotionalScore,
      'life_satisfaction': satisfactionScore,
    };

    // Calculate weighted overall score
    final overallScore = (
      moodScore * 0.25 +
      energyScore * 0.20 +
      stressScore * 0.20 +
      sleepScore * 0.15 +
      anxietyScore * 0.10 +
      motivationScore * 0.05 +
      emotionalScore * 0.03 +
      satisfactionScore * 0.02
    );

    // Determine wellness level
    String wellnessLevel;
    if (overallScore >= 8.0) {
      wellnessLevel = 'excellent';
    } else if (overallScore >= 6.5) {
      wellnessLevel = 'good';
    } else if (overallScore >= 5.0) {
      wellnessLevel = 'average';
    } else {
      wellnessLevel = 'poor';
    }

    // Generate recommendations
    final recommendations = _generateWellnessRecommendations(componentScores, overallScore);

    return WellnessScoreModel(
      overallScore: overallScore,
      componentScores: componentScores,
      wellnessLevel: wellnessLevel,
      recommendations: recommendations,
      calculatedAt: DateTime.now(),
      rawMetrics: {
        'total_entries': data['total_entries'],
        'period_days': periodDays,
      },
    );
  }

  // ============================================================================
  // ACTIVITY CORRELATION ANALYSIS
  // ============================================================================
  
  Future<List<ActivityCorrelationModel>> analyzeActivityCorrelations(int userId, int periodDays) async {
    final correlations = <ActivityCorrelationModel>[];
    
    // Exercise vs Energy
    final exerciseEnergyCorr = await _calculateActivityCorrelation(
      userId, periodDays, 'physical_activity', 'energy_level', 'Ejercicio Físico', 'Energía'
    );
    if (exerciseEnergyCorr != null) {
      correlations.add(exerciseEnergyCorr);
    }

    // Sleep vs Mood
    final sleepMoodCorr = await _calculateActivityCorrelation(
      userId, periodDays, 'sleep_quality', 'mood_score', 'Calidad del Sueño', 'Estado de Ánimo'
    );
    if (sleepMoodCorr != null) {
      correlations.add(sleepMoodCorr);
    }

    // Social vs Mood
    final socialMoodCorr = await _calculateActivityCorrelation(
      userId, periodDays, 'social_interaction', 'mood_score', 'Interacción Social', 'Estado de Ánimo'
    );
    if (socialMoodCorr != null) {
      correlations.add(socialMoodCorr);
    }

    // Meditation vs Stress
    final meditationStressCorr = await _calculateActivityCorrelation(
      userId, periodDays, 'meditation_minutes', 'stress_level', 'Meditación', 'Estrés', invertTarget: true
    );
    if (meditationStressCorr != null) {
      correlations.add(meditationStressCorr);
    }

    // Water vs Energy
    final waterEnergyCorr = await _calculateActivityCorrelation(
      userId, periodDays, 'water_intake', 'energy_level', 'Hidratación', 'Energía'
    );
    if (waterEnergyCorr != null) {
      correlations.add(waterEnergyCorr);
    }

    return correlations;
  }

  Future<ActivityCorrelationModel?> _calculateActivityCorrelation(
    int userId, int periodDays, String activityColumn, String targetColumn, 
    String activityName, String targetName, {bool invertTarget = false}
  ) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    final result = await db.rawQuery('''
      SELECT 
        entry_date,
        CAST($activityColumn as REAL) as activity_value,
        CAST($targetColumn as REAL) as target_value
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND $activityColumn IS NOT NULL AND $targetColumn IS NOT NULL
      ORDER BY entry_date
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.length < 7) {
      // Return a special correlation indicating insufficient data
      return ActivityCorrelationModel(
        activityName: activityName,
        targetMetric: targetName,
        correlationStrength: 0.0,
        correlationType: 'insufficient_data',
        dataPoints: [],
        insight: 'Necesitas al menos 7 días de datos para analizar la correlación entre $activityName y $targetName',
        recommendation: 'Continúa registrando $activityName y $targetName diariamente para obtener insights confiables',
        dataPointsCount: result.length,
      );
    }

    final dataPoints = result.map((row) {
      final targetValue = invertTarget 
        ? 10.0 - (row['target_value'] as double)
        : (row['target_value'] as double);
      
      return CorrelationDataPoint(
        date: DateTime.parse(row['entry_date'] as String),
        activityValue: row['activity_value'] as double,
        metricValue: targetValue,
      );
    }).toList();

    // Calculate Pearson correlation
    final correlation = _calculatePearsonCorrelation(
      dataPoints.map((dp) => dp.activityValue).toList(),
      dataPoints.map((dp) => dp.metricValue).toList(),
    );

    // Calculate statistical significance
    final significance = _calculateCorrelationSignificance(correlation, dataPoints.length);
    
    // Determine correlation type with significance consideration
    String correlationType;
    final absCorr = correlation.abs();
    
    if (!significance.isSignificant) {
      correlationType = 'not_significant';
    } else if (absCorr >= 0.7) {
      correlationType = correlation > 0 ? 'strong_positive' : 'strong_negative';
    } else if (absCorr >= 0.5) {
      correlationType = correlation > 0 ? 'moderate_positive' : 'moderate_negative';
    } else if (absCorr >= 0.3) {
      correlationType = correlation > 0 ? 'weak_positive' : 'weak_negative';
    } else {
      correlationType = 'negligible';
    }

    // Generate insights and recommendations
    final insight = _generateCorrelationInsight(activityName, targetName, correlation, correlationType);
    final recommendation = _generateCorrelationRecommendation(activityName, targetName, correlation);

    return ActivityCorrelationModel(
      activityName: activityName,
      targetMetric: targetName,
      correlationStrength: correlation,
      correlationType: correlationType,
      dataPoints: dataPoints,
      insight: insight,
      recommendation: recommendation,
      dataPointsCount: dataPoints.length,
    );
  }

  // ============================================================================
  // SLEEP PATTERN ANALYSIS
  // ============================================================================
  
  Future<SleepPatternModel> analyzeSleepPatterns(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    // Get sleep data
    final result = await db.rawQuery('''
      SELECT 
        entry_date,
        CAST(sleep_hours as REAL) as hours,
        CAST(sleep_quality as REAL) as quality,
        strftime('%w', entry_date) as day_of_week
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND (sleep_hours IS NOT NULL OR sleep_quality IS NOT NULL)
      ORDER BY entry_date
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) {
      return _createDefaultSleepPattern();
    }

    // Calculate averages
    final validHours = result.where((r) => r['hours'] != null).map((r) => r['hours'] as double).toList();
    final validQuality = result.where((r) => r['quality'] != null).map((r) => r['quality'] as double).toList();
    
    final avgHours = validHours.isNotEmpty ? validHours.reduce((a, b) => a + b) / validHours.length : 7.0;
    final avgQuality = validQuality.isNotEmpty ? validQuality.reduce((a, b) => a + b) / validQuality.length : 5.0;

    // Weekly pattern analysis
    final weeklyPattern = <String, double>{};
    final dayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    
    for (int i = 0; i < 7; i++) {
      final dayData = result.where((r) => r['day_of_week'] == i.toString()).toList();
      if (dayData.isNotEmpty) {
        final dayHours = dayData.where((r) => r['hours'] != null).map((r) => r['hours'] as double).toList();
        final dayAvg = dayHours.isNotEmpty ? dayHours.reduce((a, b) => a + b) / dayHours.length : avgHours;
        weeklyPattern[dayNames[i]] = dayAvg;
      }
    }

    // Determine sleep pattern with improved variance analysis
    final hoursVariance = validHours.length >= 3 ? _calculateVariance(validHours) : 0.0;
    
    // Calculate coefficient of variation for better pattern assessment
    final coefficientOfVariation = avgHours > 0 ? (math.sqrt(hoursVariance) / avgHours) : 0.0;
    
    String sleepPattern;
    if (validHours.length < 3) {
      sleepPattern = 'needs_data';
    } else if (coefficientOfVariation < 0.1) { // Less than 10% variation
      sleepPattern = 'consistent';
    } else if (coefficientOfVariation > 0.25) { // More than 25% variation
      sleepPattern = 'irregular';
    } else {
      sleepPattern = avgHours >= 7.0 ? 'improving' : 'needs_attention';
    }

    // Enhanced quality trend analysis with chronological ordering
    String qualityTrend = 'stable';
    if (validQuality.length >= 7) {
      // Ensure we have chronological data by using result entries with dates
      final chronologicalQuality = result
          .where((r) => r['quality'] != null)
          .map((r) => r['quality'] as double)
          .toList();
      
      if (chronologicalQuality.length >= 7) {
        final splitPoint = chronologicalQuality.length ~/ 2;
        final firstHalf = chronologicalQuality.take(splitPoint).toList();
        final secondHalf = chronologicalQuality.skip(splitPoint).toList();
        
        if (firstHalf.isNotEmpty && secondHalf.isNotEmpty) {
          final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
          final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
          final difference = secondAvg - firstAvg;
          
          // Use statistical significance threshold based on data variance
          final qualityVariance = _calculateVariance(chronologicalQuality);
          final threshold = math.max(0.3, math.sqrt(qualityVariance) * 0.5);
          
          if (difference > threshold) {
            qualityTrend = 'improving';
          } else if (difference < -threshold) {
            qualityTrend = 'declining';
          }
        }
      }
    }

    // Generate insights
    final insights = _generateSleepInsights(avgHours, avgQuality, sleepPattern, hoursVariance);

    // Calculate correlations
    final correlations = await _calculateSleepCorrelations(userId, periodDays);

    return SleepPatternModel(
      averageSleepHours: avgHours,
      averageSleepQuality: avgQuality,
      sleepPattern: sleepPattern,
      weeklyPattern: weeklyPattern,
      insights: insights,
      optimalSleepHours: _calculateOptimalSleepHours(avgHours, avgQuality),
      qualityTrend: qualityTrend,
      correlations: correlations,
    );
  }

  // ============================================================================
  // STRESS MANAGEMENT ANALYSIS
  // ============================================================================
  
  Future<StressManagementModel> analyzeStressManagement(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    // Get stress data
    final result = await db.rawQuery('''
      SELECT 
        entry_date,
        CAST(stress_level as REAL) as stress,
        strftime('%H', created_at, 'unixepoch') as hour,
        strftime('%w', entry_date) as day_of_week
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND stress_level IS NOT NULL
      ORDER BY entry_date
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) {
      return _createDefaultStressManagement();
    }

    final stressLevels = result.map((r) => r['stress'] as double).toList();
    final avgStress = stressLevels.reduce((a, b) => a + b) / stressLevels.length;
    
    // Calculate trend
    String stressTrend = 'stable';
    if (stressLevels.length >= 7) {
      final firstHalf = stressLevels.take(stressLevels.length ~/ 2).toList();
      final secondHalf = stressLevels.skip(stressLevels.length ~/ 2).toList();
      final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
      
      if (secondAvg - firstAvg > 0.5) {
        stressTrend = 'worsening';
      } else if (firstAvg - secondAvg > 0.5) {
        stressTrend = 'improving';
      }
    }

    // Time patterns
    final stressByHour = <String, double>{};
    final stressByDay = <String, double>{};
    final dayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];

    // Group by time of day
    for (int hour = 0; hour < 24; hour++) {
      final hourData = result.where((r) => r['hour'] == hour.toString()).toList();
      if (hourData.isNotEmpty) {
        final hourStress = hourData.map((r) => r['stress'] as double).toList();
        stressByHour[hour.toString()] = hourStress.reduce((a, b) => a + b) / hourStress.length;
      }
    }

    // Group by day of week
    for (int i = 0; i < 7; i++) {
      final dayData = result.where((r) => r['day_of_week'] == i.toString()).toList();
      if (dayData.isNotEmpty) {
        final dayStress = dayData.map((r) => r['stress'] as double).toList();
        stressByDay[dayNames[i]] = dayStress.reduce((a, b) => a + b) / dayStress.length;
      }
    }

    // Identify triggers (simplified)
    final triggers = _identifyStressTriggers(result, avgStress);
    
    // Identify effective methods (simplified)
    final effectiveMethods = await _identifyStressReliefMethods(userId, periodDays);

    // Generate recommendations
    final recommendations = _generateStressRecommendations(avgStress, stressTrend, triggers);

    final highStressDays = stressLevels.where((s) => s >= 7.0).length;

    return StressManagementModel(
      averageStressLevel: avgStress,
      stressTrend: stressTrend,
      identifiedTriggers: triggers,
      effectiveMethods: effectiveMethods,
      stressByTimeOfDay: stressByHour,
      stressByDayOfWeek: stressByDay,
      recommendations: recommendations,
      highStressDaysCount: highStressDays,
    );
  }

  // ============================================================================
  // GOAL ANALYTICS
  // ============================================================================
  
  Future<GoalAnalyticsModel> analyzeGoalPerformance(int userId, int periodDays) async {
    final goals = await _databaseService.getUserGoals(userId);
    
    if (goals.isEmpty) {
      return _createDefaultGoalAnalytics();
    }

    final totalGoals = goals.length;
    final completedGoals = goals.where((g) => g.isCompleted).length;
    final inProgressGoals = totalGoals - completedGoals;
    final completionRate = totalGoals > 0 ? completedGoals / totalGoals : 0.0;

    // Completion by category
    final completionByCategory = <String, double>{};
    final categories = goals.map((g) => g.category.toString().split('.').last).toSet();
    
    for (final category in categories) {
      final categoryGoals = goals.where((g) => g.category.toString().split('.').last == category).toList();
      final categoryCompleted = categoryGoals.where((g) => g.isCompleted).length;
      completionByCategory[category] = categoryGoals.isNotEmpty ? categoryCompleted / categoryGoals.length : 0.0;
    }

    // Calculate average completion time for completed goals
    final completedGoalsWithDates = goals.where((g) => g.isCompleted && g.lastUpdated != null).toList();
    double averageCompletionTime = 0.0;
    
    if (completedGoalsWithDates.isNotEmpty) {
      final completionTimes = completedGoalsWithDates.map((g) {
        return g.lastUpdated!.difference(g.createdAt).inDays.toDouble();
      }).toList();
      averageCompletionTime = completionTimes.reduce((a, b) => a + b) / completionTimes.length;
    }

    // Performance trend (simplified)
    String performanceTrend = 'stable';
    if (completionRate > 0.7) {
      performanceTrend = 'improving';
    } else if (completionRate < 0.3) {
      performanceTrend = 'declining';
    }

    // Generate insights
    final insights = _generateGoalInsights(completionRate, completionByCategory, averageCompletionTime);

    // Success factors
    final successFactors = _identifySuccessFactors(goals, completionRate);

    return GoalAnalyticsModel(
      totalGoals: totalGoals,
      completedGoals: completedGoals,
      inProgressGoals: inProgressGoals,
      completionRate: completionRate,
      completionByCategory: completionByCategory,
      insights: insights,
      performanceTrend: performanceTrend,
      averageCompletionTime: averageCompletionTime,
      successFactors: successFactors,
    );
  }

  // ============================================================================
  // TEMPORAL PATTERN ANALYSIS
  // ============================================================================
  
  Future<TemporalPatternModel> analyzeTemporalPatterns(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    // Get mood data with timestamps
    final result = await db.rawQuery('''
      SELECT 
        CAST(mood_score as REAL) as mood,
        strftime('%H', created_at, 'unixepoch') as hour,
        strftime('%w', entry_date) as day_of_week,
        strftime('%m', entry_date) as month
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND mood_score IS NOT NULL
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) {
      return _createDefaultTemporalPattern();
    }

    // Hourly patterns
    final hourlyPatterns = <String, double>{};
    for (int hour = 0; hour < 24; hour++) {
      final hourData = result.where((r) => r['hour'] == hour.toString()).toList();
      if (hourData.isNotEmpty) {
        final hourMoods = hourData.map((r) => r['mood'] as double).toList();
        hourlyPatterns[hour.toString()] = hourMoods.reduce((a, b) => a + b) / hourMoods.length;
      }
    }

    // Daily patterns
    final dailyPatterns = <String, double>{};
    final dayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    
    for (int i = 0; i < 7; i++) {
      final dayData = result.where((r) => r['day_of_week'] == i.toString()).toList();
      if (dayData.isNotEmpty) {
        final dayMoods = dayData.map((r) => r['mood'] as double).toList();
        dailyPatterns[dayNames[i]] = dayMoods.reduce((a, b) => a + b) / dayMoods.length;
      }
    }

    // Monthly trends (simplified)
    final monthlyTrends = <String, double>{};
    final currentMonth = DateTime.now().month;
    for (int month = math.max(1, currentMonth - 2); month <= currentMonth; month++) {
      final monthData = result.where((r) => int.parse(r['month'] as String) == month).toList();
      if (monthData.isNotEmpty) {
        final monthMoods = monthData.map((r) => r['mood'] as double).toList();
        monthlyTrends[month.toString()] = monthMoods.reduce((a, b) => a + b) / monthMoods.length;
      }
    }

    // Determine optimal time and patterns
    final optimalTimeOfDay = _determineOptimalTimeOfDay(hourlyPatterns);
    final weeklyPattern = _determineWeeklyPattern(dailyPatterns);

    // Generate insights
    final insights = _generateTemporalInsights(hourlyPatterns, dailyPatterns, optimalTimeOfDay);

    return TemporalPatternModel(
      hourlyPatterns: hourlyPatterns,
      dailyPatterns: dailyPatterns,
      monthlyTrends: monthlyTrends,
      optimalTimeOfDay: optimalTimeOfDay,
      weeklyPattern: weeklyPattern,
      insights: insights,
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  double _calculatePearsonCorrelation(List<double> x, List<double> y) {
    // Enhanced validation for reliable correlation analysis
    if (x.isEmpty || y.isEmpty || x.length != y.length) return 0.0;
    
    // Require minimum 7 data points for reliable correlation
    if (x.length < 7) return 0.0;
    
    // Check for valid numeric values
    if (x.any((v) => !v.isFinite) || y.any((v) => !v.isFinite)) return 0.0;
    
    final n = x.length;
    
    // Calculate means for validation
    final meanX = x.reduce((a, b) => a + b) / n;
    final meanY = y.reduce((a, b) => a + b) / n;
    
    // Check for zero variance (constant values)
    final varianceX = x.map((v) => math.pow(v - meanX, 2)).reduce((a, b) => a + b) / n;
    final varianceY = y.map((v) => math.pow(v - meanY, 2)).reduce((a, b) => a + b) / n;
    
    if (varianceX < 0.001 || varianceY < 0.001) return 0.0; // Insufficient variance
    
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumX2 = x.map((v) => v * v).reduce((a, b) => a + b);
    final sumY2 = y.map((v) => v * v).reduce((a, b) => a + b);
    
    final numerator = n * sumXY - sumX * sumY;
    final denominatorPart1 = n * sumX2 - sumX * sumX;
    final denominatorPart2 = n * sumY2 - sumY * sumY;
    
    // Enhanced denominator validation
    if (denominatorPart1 <= 0 || denominatorPart2 <= 0) return 0.0;
    
    final denominator = math.sqrt(denominatorPart1 * denominatorPart2);
    
    if (denominator == 0 || !denominator.isFinite) return 0.0;
    
    final correlation = numerator / denominator;
    
    // Clamp result to valid range [-1, 1]
    return math.max(-1.0, math.min(1.0, correlation));
  }

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => math.pow(v - mean, 2));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  /// Validates and normalizes a score to the 0-10 range with proper error handling
  double _validateAndNormalizeScore(double? value, String scoreType) {
    if (value == null || !value.isFinite) {
      return 5.0; // Default neutral value
    }
    
    // Clamp to valid range based on expected scale
    final clampedValue = math.max(0.0, math.min(10.0, value));
    
    // Additional validation for specific score types
    switch (scoreType) {
      case 'stress':
      case 'anxiety':
        // For stress/anxiety, ensure we're working with valid inverted scores
        return clampedValue;
      default:
        return clampedValue;
    }
  }

  /// Calculate statistical significance of a correlation coefficient
  CorrelationSignificance _calculateCorrelationSignificance(double correlation, int sampleSize) {
    if (sampleSize < 3) {
      return CorrelationSignificance(isSignificant: false, pValue: 1.0, confidence: 0.0);
    }
    
    // Calculate t-statistic for Pearson correlation
    final absR = correlation.abs();
    final degreesOfFreedom = sampleSize - 2;
    
    if (absR >= 1.0 || degreesOfFreedom <= 0) {
      return CorrelationSignificance(isSignificant: false, pValue: 1.0, confidence: 0.0);
    }
    
    final tStatistic = absR * math.sqrt(degreesOfFreedom / (1 - absR * absR));
    
    // Simplified significance thresholds based on degrees of freedom
    // For p < 0.05 (95% confidence)
    double criticalValue;
    if (degreesOfFreedom >= 30) {
      criticalValue = 2.042; // Approximately for large samples
    } else if (degreesOfFreedom >= 20) {
      criticalValue = 2.086;
    } else if (degreesOfFreedom >= 10) {
      criticalValue = 2.228;
    } else if (degreesOfFreedom >= 5) {
      criticalValue = 2.571;
    } else {
      criticalValue = 3.182; // Very small samples
    }
    
    final isSignificant = tStatistic > criticalValue;
    final confidence = isSignificant ? 0.95 : 0.0;
    
    // Rough p-value estimation (simplified)
    final pValue = isSignificant ? 0.04 : 0.10; // Simplified estimation
    
    return CorrelationSignificance(
      isSignificant: isSignificant,
      pValue: pValue,
      confidence: confidence,
    );
  }

  // Default models for when there's insufficient data
  WellnessScoreModel _createDefaultWellnessScore() {
    return WellnessScoreModel(
      overallScore: 5.0,
      componentScores: {
        'mood': 5.0,
        'energy': 5.0,
        'stress': 5.0,
        'sleep': 5.0,
      },
      wellnessLevel: 'insufficient_data',
      recommendations: [
        'Necesitas registrar al menos 3 días de datos para obtener un análisis confiable de bienestar',
        'Continúa usando la app diariamente para generar insights personalizados',
        'Registra tu estado de ánimo, nivel de energía y calidad de sueño regularmente'
      ],
      calculatedAt: DateTime.now(),
      rawMetrics: {'total_entries': 0, 'minimum_required': 3},
    );
  }

  SleepPatternModel _createDefaultSleepPattern() {
    return SleepPatternModel(
      averageSleepHours: 7.0,
      averageSleepQuality: 5.0,
      sleepPattern: 'insufficient_data',
      weeklyPattern: {},
      insights: [], // Empty list for insufficient data
      optimalSleepHours: 8.0,
      qualityTrend: 'needs_more_data',
      correlations: {},
    );
  }

  StressManagementModel _createDefaultStressManagement() {
    return StressManagementModel(
      averageStressLevel: 5.0,
      stressTrend: 'insufficient_data',
      identifiedTriggers: [],
      effectiveMethods: [],
      stressByTimeOfDay: {},
      stressByDayOfWeek: {},
      recommendations: [
        'Registra tus niveles de estrés diariamente para identificar patrones',
        'Necesitas al menos 7 días de datos para análisis de tendencias confiables',
        'Incluye información sobre actividades y situaciones que afectan tu estrés'
      ],
      highStressDaysCount: 0,
    );
  }

  GoalAnalyticsModel _createDefaultGoalAnalytics() {
    return GoalAnalyticsModel(
      totalGoals: 0,
      completedGoals: 0,
      inProgressGoals: 0,
      completionRate: 0.0,
      completionByCategory: {},
      insights: [], // Empty list for insufficient data
      performanceTrend: 'insufficient_data',
      averageCompletionTime: 0.0,
      successFactors: [
        'Define metas claras y alcanzables',
        'Revisa y actualiza el progreso de tus metas regularmente',
        'Establece fechas límite realistas para tus objetivos'
      ],
    );
  }

  TemporalPatternModel _createDefaultTemporalPattern() {
    return TemporalPatternModel(
      hourlyPatterns: {},
      dailyPatterns: {},
      monthlyTrends: {},
      optimalTimeOfDay: 'insufficient_data',
      weeklyPattern: 'needs_more_data',
      insights: [], // Empty list for insufficient data
    );
  }

  // Insight generation methods (simplified implementations)
  List<String> _generateWellnessRecommendations(Map<String, double> scores, double overall) {
    final recommendations = <String>[];
    
    if (scores['mood']! < 6.0) {
      recommendations.add('Considera actividades que mejoren tu estado de ánimo como ejercicio o tiempo en naturaleza');
    }
    if (scores['energy']! < 6.0) {
      recommendations.add('Optimiza tu sueño y nutrición para aumentar tus niveles de energía');
    }
    if (scores['stress']! < 6.0) {
      recommendations.add('Practica técnicas de manejo del estrés como respiración profunda o meditación');
    }
    if (scores['sleep']! < 6.0) {
      recommendations.add('Establece una rutina de sueño consistente para mejorar tu descanso');
    }
    
    if (overall >= 8.0) {
      recommendations.add('¡Excelente! Mantén tus hábitos saludables actuales');
    }
    
    return recommendations.isNotEmpty ? recommendations : ['Continúa registrando tus datos para obtener recomendaciones personalizadas'];
  }

  String _generateCorrelationInsight(String activity, String target, double correlation, String type) {
    final strength = correlation.abs() >= 0.7 ? 'fuerte' : correlation.abs() >= 0.3 ? 'moderada' : 'débil';
    final direction = correlation > 0 ? 'positiva' : 'negativa';
    
    return 'Se detectó una correlación $strength $direction entre $activity y $target (${(correlation * 100).toStringAsFixed(0)}%)';
  }

  String _generateCorrelationRecommendation(String activity, String target, double correlation) {
    if (correlation > 0.5) {
      return 'Incrementa $activity para mejorar tu $target';
    } else if (correlation < -0.5) {
      return 'Reduce $activity para mejorar tu $target';
    } else {
      return 'El impacto de $activity en $target es limitado, considera otros factores';
    }
  }

  // Additional helper methods would go here...
  // (Due to length constraints, showing key structure)

  Future<Map<String, dynamic>> _generateSummaryMetrics(int userId, int periodDays) async {
    return {
      'period_days': periodDays,
      'analysis_date': DateTime.now().toIso8601String(),
      'user_id': userId,
    };
  }

  List<String> _generateKeyInsights(
    WellnessScoreModel wellness,
    List<ActivityCorrelationModel> correlations,
    SleepPatternModel sleep,
    StressManagementModel stress,
    GoalAnalyticsModel goals,
  ) {
    final insights = <String>[];
    
    if (wellness.overallScore >= 8.0) {
      insights.add('Tu bienestar general está en excelente estado');
    } else if (wellness.overallScore < 5.0) {
      insights.add('Hay oportunidades importantes para mejorar tu bienestar');
    }
    
    final strongCorrelations = correlations.where((c) => c.correlationStrength.abs() > 0.6);
    if (strongCorrelations.isNotEmpty) {
      insights.add('Se encontraron ${strongCorrelations.length} correlaciones fuertes en tus actividades');
    }
    
    if (sleep.averageSleepHours < 7.0) {
      insights.add('Podrías beneficiarte de más horas de sueño');
    }
    
    if (stress.averageStressLevel > 6.0) {
      insights.add('Tus niveles de estrés están por encima del promedio');
    }
    
    if (goals.completionRate > 0.7) {
      insights.add('¡Excelente progreso en tus metas!');
    }
    
    return insights.isNotEmpty ? insights : ['Continúa registrando datos para generar insights personalizados'];
  }

  // ============================================================================
  // COMPREHENSIVE PRODUCTIVITY ANALYTICS
  // ============================================================================
  
  Future<Map<String, dynamic>> analyzeProductivityPatterns(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    final result = await db.rawQuery('''
      SELECT 
        work_productivity,
        focus_level,
        creative_energy,
        energy_level,
        stress_level,
        meditation_minutes,
        exercise_minutes,
        sleep_hours,
        sleep_quality,
        screen_time_hours,
        strftime('%w', entry_date) as day_of_week,
        strftime('%H', created_at, 'unixepoch') as hour
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND work_productivity IS NOT NULL
      ORDER BY entry_date DESC
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) {
      return {
        'insights': [
          'No hay datos de productividad disponibles',
          'Registra tu nivel de productividad y concentración diariamente'
        ],
        'peak_hours': [],
        'recommendations': [
          'Necesitas al menos 7 días de datos para identificar patrones de productividad',
          'Incluye información sobre tu trabajo y nivel de concentración',
          'Registra la hora en que te sientes más productivo'
        ],
        'productivity_score': 0.0,
        'status': 'insufficient_data'
      };
    }

    // Analyze productivity by hour
    final productivityByHour = <int, List<double>>{};
    final focusByHour = <int, List<double>>{};
    
    for (final row in result) {
      final hourStr = row['hour']?.toString();
      final productivity = (row['work_productivity'] as num?)?.toDouble();
      final focus = (row['focus_level'] as num?)?.toDouble();
      
      // Validate data quality
      if (productivity == null || focus == null || 
          !productivity.isFinite || !focus.isFinite ||
          productivity < 0 || productivity > 10 ||
          focus < 0 || focus > 10) {
        continue; // Skip invalid data
      }
      
      int hour;
      if (hourStr != null) {
        hour = int.tryParse(hourStr) ?? -1;
        if (hour < 0 || hour > 23) {
          continue; // Skip invalid hours
        }
      } else {
        continue; // Skip entries without time data
      }
      
      productivityByHour.putIfAbsent(hour, () => []).add(productivity);
      focusByHour.putIfAbsent(hour, () => []).add(focus);
    }

    // Find peak productivity hours
    final peakHours = <Map<String, dynamic>>[];
    productivityByHour.forEach((hour, values) {
      final avg = values.reduce((a, b) => a + b) / values.length;
      if (avg >= 7.0) {
        peakHours.add({
          'hour': hour,
          'productivity': avg,
          'sessions': values.length,
        });
      }
    });
    peakHours.sort((a, b) => (b['productivity'] as double).compareTo(a['productivity'] as double));

    // Analyze productivity factors
    final insights = <String>[];
    final recommendations = <String>[];

    // Sleep impact analysis
    final sleepProductivityCorr = _analyzeFactorCorrelation(result, 'sleep_hours', 'work_productivity');
    if (sleepProductivityCorr > 0.3) {
      insights.add('Dormir más horas mejora tu productividad (${(sleepProductivityCorr * 100).toStringAsFixed(0)}% correlación)');
      if (_getAverageValue(result, 'sleep_hours') < 7.0) {
        recommendations.add('Intenta dormir al menos 7-8 horas para maximizar tu productividad');
      }
    }

    // Exercise impact
    final exerciseProductivityCorr = _analyzeFactorCorrelation(result, 'exercise_minutes', 'work_productivity');
    if (exerciseProductivityCorr > 0.2) {
      insights.add('El ejercicio aumenta tu productividad (${(exerciseProductivityCorr * 100).toStringAsFixed(0)}% correlación)');
      recommendations.add('Incluye 20-30 minutos de ejercicio antes del trabajo');
    }

    // Meditation impact
    final meditationFocusCorr = _analyzeFactorCorrelation(result, 'meditation_minutes', 'focus_level');
    if (meditationFocusCorr > 0.25) {
      insights.add('La meditación mejora tu capacidad de concentración');
      recommendations.add('Dedica 10-15 minutos a meditar antes de tareas importantes');
    }

    // Screen time analysis
    final screenProductivityCorr = _analyzeFactorCorrelation(result, 'screen_time_hours', 'work_productivity');
    if (screenProductivityCorr < -0.2) {
      insights.add('Demasiado tiempo de pantalla reduce tu productividad');
      recommendations.add('Limita el tiempo de pantalla no relacionado con trabajo');
    }

    return {
      'peak_hours': peakHours.take(3).toList(),
      'insights': insights,
      'recommendations': recommendations,
      'productivity_factors': {
        'sleep_correlation': sleepProductivityCorr,
        'exercise_correlation': exerciseProductivityCorr,
        'meditation_correlation': meditationFocusCorr,
        'screen_correlation': screenProductivityCorr,
      }
    };
  }

  // ============================================================================
  // ADVANCED MOOD STABILITY ANALYSIS
  // ============================================================================
  
  Future<Map<String, dynamic>> analyzeMoodStability(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    final result = await db.rawQuery('''
      SELECT 
        mood_score,
        emotional_stability,
        stress_level,
        anxiety_level,
        social_interaction,
        physical_activity,
        meditation_minutes,
        weather_mood_impact,
        entry_date
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND mood_score IS NOT NULL
      ORDER BY entry_date ASC
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.length < 5) {
      return {
        'stability_score': 5.0,
        'insights': [
          'Necesitas al menos 5 días de datos para analizar la estabilidad del ánimo',
          'Registra tu estado de ánimo diariamente para detectar patrones emocionales'
        ],
        'triggers': [],
        'recommendations': [
          'Continúa registrando tu estado de ánimo diariamente',
          'Incluye notas sobre eventos o situaciones que afectan tu ánimo',
          'Mantén consistencia en tus registros para mejores insights'
        ],
        'mood_variance': 0.0,
        'status': 'insufficient_data'
      };
    }

    // Calculate mood variance (stability indicator)
    final moodScores = result.map((r) => (r['mood_score'] as num).toDouble()).toList();
    final moodVariance = _calculateVariance(moodScores);
    final stabilityScore = math.max(0.0, 10.0 - (moodVariance * 2));

    // Detect mood drops and their triggers
    final moodTriggers = <Map<String, dynamic>>[];
    for (int i = 1; i < result.length; i++) {
      final prevMood = (result[i-1]['mood_score'] as num).toDouble();
      final currMood = (result[i]['mood_score'] as num).toDouble();
      
      if (prevMood - currMood >= 2.0) { // Significant mood drop
        final triggers = <String>[];
        
        // Check potential triggers
        final stress = (result[i]['stress_level'] as num?)?.toDouble() ?? 5.0;
        final anxiety = (result[i]['anxiety_level'] as num?)?.toDouble() ?? 5.0;
        final social = (result[i]['social_interaction'] as num?)?.toDouble() ?? 5.0;
        final exercise = (result[i]['physical_activity'] as num?)?.toDouble() ?? 5.0;
        
        if (stress >= 7.0) triggers.add('Alto estrés');
        if (anxiety >= 7.0) triggers.add('Alta ansiedad');
        if (social <= 3.0) triggers.add('Baja interacción social');
        if (exercise <= 3.0) triggers.add('Poca actividad física');
        
        if (triggers.isNotEmpty) {
          moodTriggers.add({
            'date': result[i]['entry_date'],
            'mood_drop': prevMood - currMood,
            'triggers': triggers,
          });
        }
      }
    }

    // Analyze protective factors
    final protectiveFactors = <String>[];
    final highMoodDays = result.where((r) => (r['mood_score'] as num) >= 7).toList();
    
    if (highMoodDays.isNotEmpty) {
      final avgSocial = _getAverageFromSubset(highMoodDays, 'social_interaction');
      final avgExercise = _getAverageFromSubset(highMoodDays, 'physical_activity');
      final avgMeditation = _getAverageFromSubset(highMoodDays, 'meditation_minutes');
      
      if (avgSocial >= 6.0) protectiveFactors.add('Interacción social regular');
      if (avgExercise >= 6.0) protectiveFactors.add('Actividad física constante');
      if (avgMeditation >= 10.0) protectiveFactors.add('Práctica de meditación');
    }

    return {
      'stability_score': stabilityScore,
      'mood_variance': moodVariance,
      'mood_triggers': moodTriggers.take(5).toList(),
      'protective_factors': protectiveFactors,
      'insights': _generateMoodStabilityInsights(stabilityScore, moodVariance, protectiveFactors),
      'recommendations': _generateMoodStabilityRecommendations(stabilityScore, moodTriggers, protectiveFactors),
    };
  }

  // ============================================================================
  // LIFESTYLE BALANCE ANALYSIS
  // ============================================================================
  
  Future<Map<String, dynamic>> analyzeLifestyleBalance(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    final result = await db.rawQuery('''
      SELECT 
        work_productivity,
        social_interaction,
        physical_activity,
        creative_energy,
        meditation_minutes,
        exercise_minutes,
        sleep_hours,
        screen_time_hours,
        water_intake,
        life_satisfaction,
        emotional_stability
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
      ORDER BY entry_date DESC
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) {
      return {
        'balance_score': 5.0,
        'areas': {},
        'recommendations': [
          'Registra datos en diferentes áreas de tu vida para analizar el equilibrio',
          'Incluye información sobre trabajo, actividad física, vida social y bienestar',
          'Necesitas al menos 10 días de datos para un análisis de balance confiable'
        ],
        'insights': [
          'No hay suficientes datos para evaluar tu equilibrio de vida',
          'Registra actividades en diferentes categorías para obtener insights'
        ],
        'status': 'insufficient_data'
      };
    }

    // Calculate balance scores for different life areas
    final workScore = _getAverageValue(result, 'work_productivity');
    final socialScore = _getAverageValue(result, 'social_interaction');
    final physicalScore = _getAverageValue(result, 'physical_activity');
    final creativityScore = _getAverageValue(result, 'creative_energy');
    final wellnessScore = _getAverageValue(result, 'life_satisfaction');
    
    // Calculate quantitative wellness metrics
    final avgSleep = _getAverageValue(result, 'sleep_hours');
    final avgExercise = _getAverageValue(result, 'exercise_minutes');
    final avgMeditation = _getAverageValue(result, 'meditation_minutes');
    final avgWater = _getAverageValue(result, 'water_intake');
    final avgScreen = _getAverageValue(result, 'screen_time_hours');

    // Normalize quantitative metrics to 1-10 scale
    final sleepNormalized = _normalizeSleepScore(avgSleep);
    final exerciseNormalized = _normalizeExerciseScore(avgExercise);
    final meditationNormalized = _normalizeMeditationScore(avgMeditation);
    final hydrationNormalized = _normalizeHydrationScore(avgWater);
    final screenNormalized = _normalizeScreenScore(avgScreen);

    final areas = {
      'trabajo': workScore,
      'social': socialScore,
      'fisico': physicalScore,
      'creatividad': creativityScore,
      'bienestar': wellnessScore,
      'sueño': sleepNormalized,
      'ejercicio': exerciseNormalized,
      'meditacion': meditationNormalized,
      'hidratacion': hydrationNormalized,
      'pantallas': screenNormalized,
    };

    // Calculate overall balance score (penalize extreme imbalances)
    final scores = areas.values.where((s) => s > 0).toList();
    final balanceVariance = _calculateVariance(scores);
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;
    final balanceScore = math.max(1.0, avgScore - (balanceVariance * 0.5));

    // Identify imbalanced areas
    final recommendations = <String>[];
    areas.forEach((area, score) {
      if (score < 4.0) {
        recommendations.add(_getAreaImprovementRecommendation(area, score));
      } else if (score > 8.0 && _shouldModerateArea(area)) {
        recommendations.add(_getAreaModerationRecommendation(area));
      }
    });

    return {
      'balance_score': balanceScore,
      'areas': areas,
      'balance_variance': balanceVariance,
      'recommendations': recommendations,
      'insights': _generateBalanceInsights(areas, balanceScore),
    };
  }

  // ============================================================================
  // ENERGY PATTERNS ANALYSIS
  // ============================================================================
  
  Future<Map<String, dynamic>> analyzeEnergyPatterns(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    final result = await db.rawQuery('''
      SELECT 
        energy_level,
        sleep_hours,
        sleep_quality,
        physical_activity,
        exercise_minutes,
        water_intake,
        stress_level,
        meditation_minutes,
        strftime('%H', created_at, 'unixepoch') as hour,
        strftime('%w', entry_date) as day_of_week
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND energy_level IS NOT NULL
      ORDER BY entry_date ASC
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) {
      return {
        'energy_pattern': 'insufficient_data',
        'peak_times': [],
        'energy_boosters': [],
        'recommendations': [
          'Registra tu nivel de energía a diferentes horas del día',
          'Necesitas al menos 10 días de datos para identificar patrones de energía',
          'Incluye factores como sueño, ejercicio e hidratación en tus registros'
        ],
        'insights': [
          'No hay datos suficientes para analizar tus patrones de energía',
          'Registra tu nivel de energía junto con actividades y horarios'
        ],
        'status': 'insufficient_data'
      };
    }

    // Analyze energy by time of day with improved error handling
    final energyByHour = <int, List<double>>{};
    int invalidTimeEntries = 0;
    
    for (final row in result) {
      final hourStr = row['hour']?.toString();
      final energy = (row['energy_level'] as num?)?.toDouble();
      
      if (energy == null || !energy.isFinite || energy < 0 || energy > 10) {
        continue; // Skip invalid energy values
      }
      
      int hour;
      if (hourStr != null) {
        hour = int.tryParse(hourStr) ?? -1;
        if (hour < 0 || hour > 23) {
          invalidTimeEntries++;
          continue; // Skip invalid hours
        }
      } else {
        invalidTimeEntries++;
        continue; // Skip entries without time data
      }
      
      energyByHour.putIfAbsent(hour, () => []).add(energy);
    }
    
    // Check if we have enough valid data
    if (energyByHour.isEmpty || invalidTimeEntries > result.length * 0.5) {
      return {
        'energy_pattern': 'insufficient_data',
        'peak_times': [],
        'energy_boosters': [],
        'recommendations': [
          'Muchos registros tienen datos de hora inválidos o faltan',
          'Asegúrate de registrar tu energía con la hora correcta',
          'Necesitas datos válidos durante al menos 7 días diferentes'
        ],
        'insights': [
          'Datos de tiempo insuficientes o inválidos para analizar patrones de energía',
          'Verifica que tus registros incluyan información de hora precisa'
        ],
        'status': 'invalid_data'
      };
    }

    // Calculate average energy per hour
    final hourlyAverages = <int, double>{};
    energyByHour.forEach((hour, values) {
      hourlyAverages[hour] = values.reduce((a, b) => a + b) / values.length;
    });

    // Identify peak energy times
    final peakTimes = <Map<String, dynamic>>[];
    hourlyAverages.forEach((hour, avgEnergy) {
      if (avgEnergy >= 7.0) {
        peakTimes.add({
          'hour': hour,
          'energy': avgEnergy,
          'time_label': _getTimeLabel(hour),
        });
      }
    });
    peakTimes.sort((a, b) => (b['energy'] as double).compareTo(a['energy'] as double));

    // Analyze energy boosters (factors that correlate with high energy)
    final energyBoosters = <Map<String, dynamic>>[];
    
    // Sleep correlation
    final sleepEnergyCorr = _analyzeFactorCorrelation(result, 'sleep_hours', 'energy_level');
    if (sleepEnergyCorr > 0.2) {
      energyBoosters.add({
        'factor': 'Horas de sueño',
        'correlation': sleepEnergyCorr,
        'recommendation': 'Mantén 7-8 horas de sueño para mejor energía',
      });
    }

    // Exercise correlation
    final exerciseEnergyCorr = _analyzeFactorCorrelation(result, 'physical_activity', 'energy_level');
    if (exerciseEnergyCorr > 0.15) {
      energyBoosters.add({
        'factor': 'Actividad física',
        'correlation': exerciseEnergyCorr,
        'recommendation': 'El ejercicio regular aumenta tus niveles de energía',
      });
    }

    // Hydration correlation
    final waterEnergyCorr = _analyzeFactorCorrelation(result, 'water_intake', 'energy_level');
    if (waterEnergyCorr > 0.1) {
      energyBoosters.add({
        'factor': 'Hidratación',
        'correlation': waterEnergyCorr,
        'recommendation': 'Mantente bien hidratado durante el día',
      });
    }

    // Stress correlation (negative)
    final stressEnergyCorr = _analyzeFactorCorrelation(result, 'stress_level', 'energy_level');
    if (stressEnergyCorr < -0.2) {
      energyBoosters.add({
        'factor': 'Manejo del estrés',
        'correlation': stressEnergyCorr.abs(),
        'recommendation': 'Reducir el estrés mejora significativamente tu energía',
      });
    }

    // Determine energy pattern with statistical significance
    final morningEnergy = _getAverageEnergyForTimeRange(hourlyAverages, 6, 12);
    final afternoonEnergy = _getAverageEnergyForTimeRange(hourlyAverages, 12, 18);
    final eveningEnergy = _getAverageEnergyForTimeRange(hourlyAverages, 18, 22);
    
    // Calculate overall variance to determine if differences are significant
    final allPeriodValues = [morningEnergy, afternoonEnergy, eveningEnergy]
        .where((v) => v > 0)
        .toList();
    
    String energyPattern;
    if (allPeriodValues.length < 2) {
      energyPattern = 'insufficient_data';
    } else {
      final periodVariance = _calculateVariance(allPeriodValues);
      final significanceThreshold = math.sqrt(periodVariance) * 0.5; // 0.5 standard deviations
      
      if (significanceThreshold < 0.3) {
        energyPattern = 'consistent'; // Very little variation
      } else if (morningEnergy > afternoonEnergy + significanceThreshold && 
                 morningEnergy > eveningEnergy + significanceThreshold) {
        energyPattern = 'morning_person';
      } else if (afternoonEnergy > morningEnergy + significanceThreshold && 
                 afternoonEnergy > eveningEnergy + significanceThreshold) {
        energyPattern = 'afternoon_peak';
      } else if (eveningEnergy > morningEnergy + significanceThreshold && 
                 eveningEnergy > afternoonEnergy + significanceThreshold) {
        energyPattern = 'evening_person';
      } else {
        energyPattern = 'balanced';
      }
    }

    return {
      'energy_pattern': energyPattern,
      'peak_times': peakTimes.take(3).toList(),
      'energy_boosters': energyBoosters,
      'hourly_averages': hourlyAverages,
      'pattern_analysis': {
        'morning': morningEnergy,
        'afternoon': afternoonEnergy,
        'evening': eveningEnergy,
      },
      'recommendations': _generateEnergyRecommendations(energyPattern, energyBoosters),
    };
  }

  // ============================================================================
  // SOCIAL WELLNESS ANALYSIS
  // ============================================================================
  
  Future<Map<String, dynamic>> analyzeSocialWellness(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    final result = await db.rawQuery('''
      SELECT 
        social_interaction,
        social_battery,
        mood_score,
        emotional_stability,
        stress_level,
        anxiety_level,
        strftime('%w', entry_date) as day_of_week
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND social_interaction IS NOT NULL
      ORDER BY entry_date ASC
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) {
      return {
        'social_wellness_score': 5.0,
        'patterns': {},
        'recommendations': [
          'Registra tu nivel de interacción social diariamente',
          'Incluye información sobre cómo te sientes después de actividades sociales',
          'Necesitas al menos 7 días de datos para analizar tu bienestar social'
        ],
        'insights': [
          'No hay suficientes datos para evaluar tu bienestar social',
          'Registra tanto actividades sociales como momentos de soledad'
        ],
        'social_battery_pattern': 'unknown',
        'status': 'insufficient_data'
      };
    }

    // Calculate social wellness metrics
    final avgSocial = _getAverageValue(result, 'social_interaction');
    final avgSocialBattery = _getAverageValue(result, 'social_battery');
    final socialWellnessScore = (avgSocial + avgSocialBattery) / 2.0;

    // Analyze social impact on mood
    final socialMoodCorrelation = _analyzeFactorCorrelation(result, 'social_interaction', 'mood_score');
    final socialStressCorrelation = _analyzeFactorCorrelation(result, 'social_interaction', 'stress_level');

    // Weekly social patterns
    final weeklyPatterns = <String, double>{};
    final dayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    
    for (int i = 0; i < 7; i++) {
      final dayData = result.where((r) => r['day_of_week'] == i.toString()).toList();
      if (dayData.isNotEmpty) {
        final dayAvgSocial = _getAverageFromSubset(dayData, 'social_interaction');
        weeklyPatterns[dayNames[i]] = dayAvgSocial;
      }
    }

    // Social preferences analysis
    final socialPreferences = <String>[];
    final highSocialDays = result.where((r) => (r['social_interaction'] as num) >= 7).toList();
    final lowSocialDays = result.where((r) => (r['social_interaction'] as num) <= 3).toList();

    if (highSocialDays.isNotEmpty && lowSocialDays.isNotEmpty) {
      final highSocialMood = _getAverageFromSubset(highSocialDays, 'mood_score');
      final lowSocialMood = _getAverageFromSubset(lowSocialDays, 'mood_score');
      
      if (highSocialMood > lowSocialMood + 1.0) {
        socialPreferences.add('Extrovertido: La interacción social mejora tu estado de ánimo');
      } else if (lowSocialMood > highSocialMood + 1.0) {
        socialPreferences.add('Introvertido: Valoras el tiempo a solas para recargar energías');
      } else {
        socialPreferences.add('Ambivertido: Disfrutas tanto del tiempo social como del tiempo a solas');
      }
    }

    // Generate insights and recommendations
    final insights = <String>[];
    final recommendations = <String>[];

    if (socialMoodCorrelation > 0.3) {
      insights.add('La interacción social tiene un fuerte impacto positivo en tu estado de ánimo');
      recommendations.add('Programa actividades sociales regulares para mantener tu bienestar');
    } else if (socialMoodCorrelation < -0.2) {
      insights.add('Demasiada interacción social podría estar agotándote');
      recommendations.add('Equilibra tu tiempo social con momentos de soledad para recargar');
    }

    if (avgSocialBattery < 5.0) {
      recommendations.add('Tu batería social está baja - considera tomar descansos sociales');
    }

    return {
      'social_wellness_score': socialWellnessScore,
      'weekly_patterns': weeklyPatterns,
      'social_preferences': socialPreferences,
      'correlations': {
        'mood': socialMoodCorrelation,
        'stress': socialStressCorrelation,
      },
      'insights': insights,
      'recommendations': recommendations,
    };
  }

  // ============================================================================
  // COMPREHENSIVE HABIT TRACKING
  // ============================================================================
  
  Future<Map<String, dynamic>> analyzeHabitConsistency(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    final result = await db.rawQuery('''
      SELECT 
        meditation_minutes,
        exercise_minutes,
        water_intake,
        sleep_hours,
        physical_activity,
        entry_date
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
      ORDER BY entry_date ASC
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) {
      return {
        'habits': {},
        'overall_consistency': 0.0,
        'streaks': {},
        'recommendations': [
          'Registra hábitos como meditación, ejercicio e hidratación diariamente',
          'Necesitas al menos 14 días de datos para analizar la consistencia de hábitos',
          'Establece metas realistas para cada hábito que quieras desarrollar'
        ],
        'insights': [
          'No hay datos suficientes para evaluar la consistencia de tus hábitos',
          'Comienza registrando hábitos simples como beber agua o hacer ejercicio'
        ],
        'consistency_score': 0.0,
        'status': 'insufficient_data'
      };
    }

    final habits = <String, Map<String, dynamic>>{};

    // Calculate dynamic targets based on user's historical data
    final dynamicTargets = _calculateDynamicTargets(result);
    
    // Analyze meditation habit
    habits['meditation'] = _analyzeHabitPattern(
      result, 
      'meditation_minutes', 
      'Meditación',
      targetValue: dynamicTargets['meditation'] ?? 10.0,
      isMinutes: true
    );

    // Analyze exercise habit
    habits['exercise'] = _analyzeHabitPattern(
      result, 
      'exercise_minutes', 
      'Ejercicio',
      targetValue: dynamicTargets['exercise'] ?? 30.0,
      isMinutes: true
    );

    // Analyze hydration habit
    habits['hydration'] = _analyzeHabitPattern(
      result, 
      'water_intake', 
      'Hidratación',
      targetValue: dynamicTargets['hydration'] ?? 8.0,
      isGlasses: true
    );

    // Analyze sleep habit
    habits['sleep'] = _analyzeHabitPattern(
      result, 
      'sleep_hours', 
      'Sueño',
      targetValue: dynamicTargets['sleep'] ?? 7.5,
      isHours: true
    );

    // Analyze physical activity habit
    habits['physical_activity'] = _analyzeHabitPattern(
      result, 
      'physical_activity', 
      'Actividad Física',
      targetValue: dynamicTargets['physical_activity'] ?? 6.0,
      isRating: true
    );

    // Calculate overall consistency
    final consistencyScores = habits.values.map((h) => h['consistency'] as double).toList();
    final overallConsistency = consistencyScores.reduce((a, b) => a + b) / consistencyScores.length;

    // Generate habit insights
    final insights = <String>[];
    final recommendations = <String>[];

    habits.forEach((key, habit) {
      final consistency = habit['consistency'] as double;
      final name = habit['name'] as String;
      
      if (consistency >= 0.8) {
        insights.add('Excelente consistencia en $name (${(consistency * 100).toStringAsFixed(0)}%)');
      } else if (consistency >= 0.6) {
        insights.add('Buena consistencia en $name, pero hay espacio para mejorar');
        recommendations.add('Intenta ser más consistente con $name');
      } else {
        insights.add('$name necesita más atención y consistencia');
        recommendations.add('Establece recordatorios para $name y comienza con metas pequeñas');
      }
    });

    return {
      'habits': habits,
      'overall_consistency': overallConsistency,
      'insights': insights,
      'recommendations': recommendations,
      'best_habit': _findBestHabit(habits),
      'needs_improvement': _findHabitsNeedingImprovement(habits),
    };
  }

  // ============================================================================
  // HELPER METHODS FOR NEW ANALYTICS
  // ============================================================================

  double _analyzeFactorCorrelation(List<Map<String, Object?>> data, String factor, String target) {
    final factorValues = <double>[];
    final targetValues = <double>[];
    
    for (final row in data) {
      final factorVal = (row[factor] as num?)?.toDouble();
      final targetVal = (row[target] as num?)?.toDouble();
      
      if (factorVal != null && targetVal != null) {
        factorValues.add(factorVal);
        targetValues.add(targetVal);
      }
    }
    
    if (factorValues.length < 3) return 0.0;
    return _calculatePearsonCorrelation(factorValues, targetValues);
  }

  double _getAverageValue(List<Map<String, Object?>> data, String column) {
    final values = data
        .map((r) => (r[column] as num?)?.toDouble())
        .where((v) => v != null)
        .cast<double>()
        .toList();
    
    return values.isEmpty ? 5.0 : values.reduce((a, b) => a + b) / values.length;
  }

  double _getAverageFromSubset(List<Map<String, Object?>> data, String column) {
    return _getAverageValue(data, column);
  }

  double _normalizeSleepScore(double hours) {
    if (hours >= 7.5 && hours <= 9.0) return 10.0;
    if (hours >= 7.0 && hours < 7.5) return 8.0;
    if (hours >= 6.5 && hours < 7.0) return 6.0;
    if (hours >= 6.0 && hours < 6.5) return 4.0;
    return 2.0;
  }

  double _normalizeExerciseScore(double minutes) {
    if (minutes >= 30) return 10.0;
    if (minutes >= 20) return 8.0;
    if (minutes >= 10) return 6.0;
    if (minutes > 0) return 4.0;
    return 1.0;
  }

  double _normalizeMeditationScore(double minutes) {
    if (minutes >= 20) return 10.0;
    if (minutes >= 15) return 8.0;
    if (minutes >= 10) return 7.0;
    if (minutes >= 5) return 5.0;
    if (minutes > 0) return 3.0;
    return 1.0;
  }

  double _normalizeHydrationScore(double glasses) {
    if (glasses >= 8) return 10.0;
    if (glasses >= 6) return 8.0;
    if (glasses >= 4) return 6.0;
    if (glasses >= 2) return 4.0;
    return 2.0;
  }

  double _normalizeScreenScore(double hours) {
    // Less screen time is better (inverted)
    if (hours <= 2) return 10.0;
    if (hours <= 4) return 8.0;
    if (hours <= 6) return 6.0;
    if (hours <= 8) return 4.0;
    return 2.0;
  }

  String _getTimeLabel(int hour) {
    if (hour >= 6 && hour < 12) return 'Mañana';
    if (hour >= 12 && hour < 18) return 'Tarde';
    if (hour >= 18 && hour < 22) return 'Noche';
    return 'Madrugada';
  }

  double _getAverageEnergyForTimeRange(Map<int, double> hourlyData, int startHour, int endHour) {
    final values = <double>[];
    for (int hour = startHour; hour < endHour; hour++) {
      if (hourlyData.containsKey(hour)) {
        values.add(hourlyData[hour]!);
      }
    }
    return values.isEmpty ? 5.0 : values.reduce((a, b) => a + b) / values.length;
  }

  Map<String, dynamic> _analyzeHabitPattern(
    List<Map<String, Object?>> data, 
    String column, 
    String name, {
    required double targetValue,
    bool isMinutes = false,
    bool isHours = false,
    bool isGlasses = false,
    bool isRating = false,
  }) {
    final values = data
        .map((r) => (r[column] as num?)?.toDouble())
        .where((v) => v != null)
        .cast<double>()
        .toList();

    if (values.isEmpty) {
      return {
        'name': name,
        'consistency': 0.0,
        'average': 0.0,
        'target_met_days': 0,
        'streak': 0,
      };
    }

    final average = values.reduce((a, b) => a + b) / values.length;
    final targetMetDays = values.where((v) => v >= targetValue).length;
    final consistency = targetMetDays / values.length;

    // Calculate current streak with proper chronological handling
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    
    // Process data chronologically (assuming data is ordered by entry_date)
    for (int i = 0; i < values.length; i++) {
      if (values[i] >= targetValue) {
        tempStreak++;
        longestStreak = math.max(longestStreak, tempStreak);
      } else {
        tempStreak = 0;
      }
    }
    
    // Calculate current streak from the end
    for (int i = values.length - 1; i >= 0; i--) {
      if (values[i] >= targetValue) {
        currentStreak++;
      } else {
        break;
      }
    }

    return {
      'name': name,
      'consistency': consistency,
      'average': average,
      'target_met_days': targetMetDays,
      'total_days': values.length,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'target': targetValue,
    };
  }

  /// Calculate dynamic targets based on user's historical performance
  Map<String, double> _calculateDynamicTargets(List<Map<String, Object?>> data) {
    final targets = <String, double>{};
    
    if (data.isEmpty) {
      return {
        'meditation': 10.0,
        'exercise': 30.0,
        'hydration': 8.0,
        'sleep': 7.5,
        'physical_activity': 6.0,
      };
    }
    
    // Calculate percentile-based targets (75th percentile as achievable goals)
    final habits = {
      'meditation': 'meditation_minutes',
      'exercise': 'exercise_minutes',
      'hydration': 'water_intake',
      'sleep': 'sleep_hours',
      'physical_activity': 'physical_activity',
    };
    
    habits.forEach((habitName, columnName) {
      final values = data
          .map((r) => (r[columnName] as num?)?.toDouble())
          .where((v) => v != null && v > 0)
          .cast<double>()
          .toList();
      
      if (values.length >= 5) {
        values.sort();
        final percentile75Index = (values.length * 0.75).floor();
        final target = values[math.min(percentile75Index, values.length - 1)];
        
        // Apply reasonable bounds
        switch (habitName) {
          case 'meditation':
            targets[habitName] = math.max(5.0, math.min(60.0, target));
            break;
          case 'exercise':
            targets[habitName] = math.max(15.0, math.min(120.0, target));
            break;
          case 'hydration':
            targets[habitName] = math.max(4.0, math.min(12.0, target));
            break;
          case 'sleep':
            targets[habitName] = math.max(6.0, math.min(9.0, target));
            break;
          case 'physical_activity':
            targets[habitName] = math.max(3.0, math.min(10.0, target));
            break;
        }
      } else {
        // Fallback to defaults for insufficient data
        targets[habitName] = {
          'meditation': 10.0,
          'exercise': 30.0,
          'hydration': 8.0,
          'sleep': 7.5,
          'physical_activity': 6.0,
        }[habitName] ?? 5.0;
      }
    });
    
    return targets;
  }

  Map<String, dynamic> _findBestHabit(Map<String, Map<String, dynamic>> habits) {
    Map<String, dynamic>? best;
    double bestScore = 0.0;
    
    habits.forEach((key, habit) {
      final consistency = habit['consistency'] as double;
      if (consistency > bestScore) {
        bestScore = consistency;
        best = habit;
      }
    });
    
    return best ?? {'name': 'Ninguno', 'consistency': 0.0};
  }

  List<String> _findHabitsNeedingImprovement(Map<String, Map<String, dynamic>> habits) {
    final needsImprovement = <String>[];
    
    habits.forEach((key, habit) {
      final consistency = habit['consistency'] as double;
      if (consistency < 0.6) {
        needsImprovement.add(habit['name'] as String);
      }
    });
    
    return needsImprovement;
  }

  // Additional helper methods
  List<String> _generateMoodStabilityInsights(double stability, double variance, List<String> protectiveFactors) {
    final insights = <String>[];
    
    if (stability >= 8.0) {
      insights.add('Tu estado de ánimo es muy estable');
    } else if (stability >= 6.0) {
      insights.add('Tu estado de ánimo es moderadamente estable');
    } else {
      insights.add('Tu estado de ánimo presenta variaciones significativas');
    }
    
    if (protectiveFactors.isNotEmpty) {
      insights.add('Factores protectores identificados: ${protectiveFactors.join(", ")}');
    }
    
    return insights;
  }

  List<String> _generateMoodStabilityRecommendations(double stability, List<Map<String, dynamic>> triggers, List<String> protectiveFactors) {
    final recommendations = <String>[];
    
    if (stability < 6.0) {
      recommendations.add('Practica técnicas de regulación emocional como respiración profunda');
      recommendations.add('Mantén una rutina diaria estable');
    }
    
    if (triggers.isNotEmpty) {
      recommendations.add('Identifica y maneja tus principales desencadenantes de estrés');
    }
    
    if (protectiveFactors.isNotEmpty) {
      recommendations.add('Mantén y fortalece tus factores protectores actuales');
    }
    
    return recommendations;
  }

  List<String> _generateBalanceInsights(Map<String, double> areas, double balanceScore) {
    final insights = <String>[];
    
    if (balanceScore >= 7.0) {
      insights.add('Tienes un buen equilibrio general en tu estilo de vida');
    } else if (balanceScore >= 5.0) {
      insights.add('Tu equilibrio de vida es moderado, con oportunidades de mejora');
    } else {
      insights.add('Hay desequilibrios significativos que requieren atención');
    }
    
    final strongAreas = areas.entries.where((e) => e.value >= 7.0).map((e) => e.key).toList();
    final weakAreas = areas.entries.where((e) => e.value < 4.0).map((e) => e.key).toList();
    
    if (strongAreas.isNotEmpty) {
      insights.add('Fortalezas: ${strongAreas.join(", ")}');
    }
    
    if (weakAreas.isNotEmpty) {
      insights.add('Áreas que necesitan atención: ${weakAreas.join(", ")}');
    }
    
    return insights;
  }

  String _getAreaImprovementRecommendation(String area, double score) {
    final recommendations = {
      'trabajo': 'Mejora tu productividad con técnicas de gestión del tiempo',
      'social': 'Dedica más tiempo a actividades sociales que disfrutes',
      'fisico': 'Incrementa tu actividad física gradualmente',
      'creatividad': 'Busca tiempo para actividades creativas que te inspiren',
      'bienestar': 'Practica autocuidado y mindfulness',
      'sueño': 'Establece una rutina de sueño más consistente',
      'ejercicio': 'Comienza con 15-20 minutos de ejercicio diario',
      'meditacion': 'Prueba con 5-10 minutos de meditación diaria',
      'hidratacion': 'Aumenta tu consumo de agua gradualmente',
      'pantallas': 'Reduce el tiempo de pantalla no productivo',
    };
    
    return recommendations[area] ?? 'Dedica más atención a esta área de tu vida';
  }

  String _getAreaModerationRecommendation(String area) {
    final recommendations = {
      'trabajo': 'Considera equilibrar trabajo con descanso',
      'pantallas': 'Excelente control del tiempo de pantalla, manténlo así',
    };
    
    return recommendations[area] ?? 'Mantén este buen nivel';
  }

  bool _shouldModerateArea(String area) {
    return ['trabajo', 'pantallas'].contains(area);
  }

  List<String> _generateEnergyRecommendations(String pattern, List<Map<String, dynamic>> boosters) {
    final recommendations = <String>[];
    
    switch (pattern) {
      case 'morning_person':
        recommendations.add('Programa tareas importantes en las mañanas cuando tienes más energía');
        break;
      case 'afternoon_peak':
        recommendations.add('Aprovecha las tardes para tu trabajo más exigente');
        break;
      case 'evening_person':
        recommendations.add('Las noches son tu momento de mayor productividad');
        break;
      default:
        recommendations.add('Mantén una energía consistente durante el día');
    }
    
    for (final booster in boosters) {
      recommendations.add(booster['recommendation'] as String);
    }
    
    return recommendations;
  }

  // Placeholder implementations for additional methods
  List<SleepInsight> _generateSleepInsights(double avgHours, double avgQuality, String pattern, double variance) => [];
  Future<Map<String, dynamic>> _calculateSleepCorrelations(int userId, int periodDays) async => {};
  double _calculateOptimalSleepHours(double avgHours, double avgQuality) => math.max(7.0, avgHours);
  List<StressTrigger> _identifyStressTriggers(List<Map<String, Object?>> data, double avgStress) => [];
  Future<List<StressReliefMethod>> _identifyStressReliefMethods(int userId, int periodDays) async => [];
  List<String> _generateStressRecommendations(double avgStress, String trend, List<StressTrigger> triggers) => [];
  List<GoalPerformanceInsight> _generateGoalInsights(double completionRate, Map<String, double> byCategory, double avgTime) => [];
  List<String> _identifySuccessFactors(List<dynamic> goals, double completionRate) => [];
  String _determineOptimalTimeOfDay(Map<String, double> hourlyPatterns) => 'morning';
  String _determineWeeklyPattern(Map<String, double> dailyPatterns) => 'consistent';
  List<TemporalInsight> _generateTemporalInsights(Map<String, double> hourly, Map<String, double> daily, String optimal) => [];
}