// ============================================================================
// data/models/analytics_v3_models.dart - ANALYTICS V3 MODELS
// NEW ANALYTICS SYSTEM - NO CONFLICTS WITH EXISTING CODE
// ============================================================================

import 'dart:math';

// ============================================================================
// CORRELATION SIGNIFICANCE MODEL
// ============================================================================
class CorrelationSignificance {
  final bool isSignificant;
  final double pValue;
  final double confidence;

  const CorrelationSignificance({
    required this.isSignificant,
    required this.pValue,
    required this.confidence,
  });

  Map<String, dynamic> toJson() => {
    'isSignificant': isSignificant,
    'pValue': pValue,
    'confidence': confidence,
  };

  factory CorrelationSignificance.fromJson(Map<String, dynamic> json) =>
      CorrelationSignificance(
        isSignificant: json['isSignificant'],
        pValue: json['pValue'].toDouble(),
        confidence: json['confidence'].toDouble(),
      );
}

// ============================================================================
// WELLNESS SCORE MODEL
// ============================================================================
class WellnessScoreModel {
  final double overallScore; // 0.0 to 10.0
  final Map<String, double> componentScores; // mood, energy, stress, sleep
  final String wellnessLevel; // 'excellent', 'good', 'average', 'poor'
  final List<String> recommendations;
  final DateTime calculatedAt;
  final Map<String, dynamic> rawMetrics;

  const WellnessScoreModel({
    required this.overallScore,
    required this.componentScores,
    required this.wellnessLevel,
    required this.recommendations,
    required this.calculatedAt,
    required this.rawMetrics,
  });

  Map<String, dynamic> toJson() => {
    'overallScore': overallScore,
    'componentScores': componentScores,
    'wellnessLevel': wellnessLevel,
    'recommendations': recommendations,
    'calculatedAt': calculatedAt.toIso8601String(),
    'rawMetrics': rawMetrics,
  };

  factory WellnessScoreModel.fromJson(Map<String, dynamic> json) =>
      WellnessScoreModel(
        overallScore: json['overallScore'].toDouble(),
        componentScores: Map<String, double>.from(json['componentScores']),
        wellnessLevel: json['wellnessLevel'],
        recommendations: List<String>.from(json['recommendations']),
        calculatedAt: DateTime.parse(json['calculatedAt']),
        rawMetrics: json['rawMetrics'],
      );
}

// ============================================================================
// ACTIVITY CORRELATION MODEL
// ============================================================================
class ActivityCorrelationModel {
  final String activityName;
  final String targetMetric; // 'mood', 'energy', 'stress'
  final double correlationStrength; // -1.0 to 1.0
  final String correlationType; // 'strong_positive', 'weak_negative', etc.
  final List<CorrelationDataPoint> dataPoints;
  final String insight;
  final String recommendation;
  final int dataPointsCount;

  const ActivityCorrelationModel({
    required this.activityName,
    required this.targetMetric,
    required this.correlationStrength,
    required this.correlationType,
    required this.dataPoints,
    required this.insight,
    required this.recommendation,
    required this.dataPointsCount,
  });

  Map<String, dynamic> toJson() => {
    'activityName': activityName,
    'targetMetric': targetMetric,
    'correlationStrength': correlationStrength,
    'correlationType': correlationType,
    'dataPoints': dataPoints.map((dp) => dp.toJson()).toList(),
    'insight': insight,
    'recommendation': recommendation,
    'dataPointsCount': dataPointsCount,
  };

  factory ActivityCorrelationModel.fromJson(Map<String, dynamic> json) =>
      ActivityCorrelationModel(
        activityName: json['activityName'],
        targetMetric: json['targetMetric'],
        correlationStrength: json['correlationStrength'].toDouble(),
        correlationType: json['correlationType'],
        dataPoints: (json['dataPoints'] as List)
            .map((dp) => CorrelationDataPoint.fromJson(dp))
            .toList(),
        insight: json['insight'],
        recommendation: json['recommendation'],
        dataPointsCount: json['dataPointsCount'],
      );
}

// ============================================================================
// CORRELATION DATA POINT
// ============================================================================
class CorrelationDataPoint {
  final DateTime date;
  final double activityValue;
  final double metricValue;

  const CorrelationDataPoint({
    required this.date,
    required this.activityValue,
    required this.metricValue,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'activityValue': activityValue,
    'metricValue': metricValue,
  };

  factory CorrelationDataPoint.fromJson(Map<String, dynamic> json) =>
      CorrelationDataPoint(
        date: DateTime.parse(json['date']),
        activityValue: json['activityValue'].toDouble(),
        metricValue: json['metricValue'].toDouble(),
      );
}

// ============================================================================
// SLEEP PATTERN ANALYSIS MODEL
// ============================================================================
class SleepPatternModel {
  final double averageSleepHours;
  final double averageSleepQuality;
  final String sleepPattern; // 'consistent', 'irregular', 'improving'
  final Map<String, double> weeklyPattern; // Monday -> average hours
  final List<SleepInsight> insights;
  final double optimalSleepHours;
  final String qualityTrend; // 'improving', 'declining', 'stable'
  final Map<String, dynamic> correlations; // sleep vs mood, energy

  const SleepPatternModel({
    required this.averageSleepHours,
    required this.averageSleepQuality,
    required this.sleepPattern,
    required this.weeklyPattern,
    required this.insights,
    required this.optimalSleepHours,
    required this.qualityTrend,
    required this.correlations,
  });

  Map<String, dynamic> toJson() => {
    'averageSleepHours': averageSleepHours,
    'averageSleepQuality': averageSleepQuality,
    'sleepPattern': sleepPattern,
    'weeklyPattern': weeklyPattern,
    'insights': insights.map((i) => i.toJson()).toList(),
    'optimalSleepHours': optimalSleepHours,
    'qualityTrend': qualityTrend,
    'correlations': correlations,
  };

  factory SleepPatternModel.fromJson(Map<String, dynamic> json) =>
      SleepPatternModel(
        averageSleepHours: json['averageSleepHours'].toDouble(),
        averageSleepQuality: json['averageSleepQuality'].toDouble(),
        sleepPattern: json['sleepPattern'],
        weeklyPattern: Map<String, double>.from(json['weeklyPattern']),
        insights: (json['insights'] as List)
            .map((i) => SleepInsight.fromJson(i))
            .toList(),
        optimalSleepHours: json['optimalSleepHours'].toDouble(),
        qualityTrend: json['qualityTrend'],
        correlations: json['correlations'],
      );
}

// ============================================================================
// SLEEP INSIGHT
// ============================================================================
class SleepInsight {
  final String title;
  final String description;
  final String category; // 'duration', 'quality', 'consistency'
  final String severity; // 'info', 'warning', 'critical'
  final String recommendation;

  const SleepInsight({
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'category': category,
    'severity': severity,
    'recommendation': recommendation,
  };

  factory SleepInsight.fromJson(Map<String, dynamic> json) =>
      SleepInsight(
        title: json['title'],
        description: json['description'],
        category: json['category'],
        severity: json['severity'],
        recommendation: json['recommendation'],
      );
}

// ============================================================================
// STRESS MANAGEMENT INSIGHTS MODEL
// ============================================================================
class StressManagementModel {
  final double averageStressLevel;
  final String stressTrend; // 'improving', 'worsening', 'stable'
  final List<StressTrigger> identifiedTriggers;
  final List<StressReliefMethod> effectiveMethods;
  final Map<String, double> stressByTimeOfDay;
  final Map<String, double> stressByDayOfWeek;
  final List<String> recommendations;
  final int highStressDaysCount;

  const StressManagementModel({
    required this.averageStressLevel,
    required this.stressTrend,
    required this.identifiedTriggers,
    required this.effectiveMethods,
    required this.stressByTimeOfDay,
    required this.stressByDayOfWeek,
    required this.recommendations,
    required this.highStressDaysCount,
  });

  Map<String, dynamic> toJson() => {
    'averageStressLevel': averageStressLevel,
    'stressTrend': stressTrend,
    'identifiedTriggers': identifiedTriggers.map((t) => t.toJson()).toList(),
    'effectiveMethods': effectiveMethods.map((m) => m.toJson()).toList(),
    'stressByTimeOfDay': stressByTimeOfDay,
    'stressByDayOfWeek': stressByDayOfWeek,
    'recommendations': recommendations,
    'highStressDaysCount': highStressDaysCount,
  };

  factory StressManagementModel.fromJson(Map<String, dynamic> json) =>
      StressManagementModel(
        averageStressLevel: json['averageStressLevel'].toDouble(),
        stressTrend: json['stressTrend'],
        identifiedTriggers: (json['identifiedTriggers'] as List)
            .map((t) => StressTrigger.fromJson(t))
            .toList(),
        effectiveMethods: (json['effectiveMethods'] as List)
            .map((m) => StressReliefMethod.fromJson(m))
            .toList(),
        stressByTimeOfDay: Map<String, double>.from(json['stressByTimeOfDay']),
        stressByDayOfWeek: Map<String, double>.from(json['stressByDayOfWeek']),
        recommendations: List<String>.from(json['recommendations']),
        highStressDaysCount: json['highStressDaysCount'],
      );
}

// ============================================================================
// STRESS TRIGGER
// ============================================================================
class StressTrigger {
  final String triggerName;
  final double frequency; // 0.0 to 1.0
  final double averageStressIncrease;
  final String timePattern; // 'morning', 'afternoon', 'evening', 'anytime'
  final String category; // 'work', 'social', 'personal', 'health'

  const StressTrigger({
    required this.triggerName,
    required this.frequency,
    required this.averageStressIncrease,
    required this.timePattern,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'triggerName': triggerName,
    'frequency': frequency,
    'averageStressIncrease': averageStressIncrease,
    'timePattern': timePattern,
    'category': category,
  };

  factory StressTrigger.fromJson(Map<String, dynamic> json) =>
      StressTrigger(
        triggerName: json['triggerName'],
        frequency: json['frequency'].toDouble(),
        averageStressIncrease: json['averageStressIncrease'].toDouble(),
        timePattern: json['timePattern'],
        category: json['category'],
      );
}

// ============================================================================
// STRESS RELIEF METHOD
// ============================================================================
class StressReliefMethod {
  final String methodName;
  final double effectiveness; // 0.0 to 1.0
  final int usageCount;
  final double averageStressReduction;
  final String category; // 'exercise', 'meditation', 'social', 'creative'

  const StressReliefMethod({
    required this.methodName,
    required this.effectiveness,
    required this.usageCount,
    required this.averageStressReduction,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'methodName': methodName,
    'effectiveness': effectiveness,
    'usageCount': usageCount,
    'averageStressReduction': averageStressReduction,
    'category': category,
  };

  factory StressReliefMethod.fromJson(Map<String, dynamic> json) =>
      StressReliefMethod(
        methodName: json['methodName'],
        effectiveness: json['effectiveness'].toDouble(),
        usageCount: json['usageCount'],
        averageStressReduction: json['averageStressReduction'].toDouble(),
        category: json['category'],
      );
}

// ============================================================================
// GOAL ACHIEVEMENT ANALYTICS MODEL
// ============================================================================
class GoalAnalyticsModel {
  final int totalGoals;
  final int completedGoals;
  final int inProgressGoals;
  final double completionRate; // 0.0 to 1.0
  final Map<String, double> completionByCategory;
  final List<GoalPerformanceInsight> insights;
  final String performanceTrend; // 'improving', 'declining', 'stable'
  final double averageCompletionTime; // days
  final List<String> successFactors;

  const GoalAnalyticsModel({
    required this.totalGoals,
    required this.completedGoals,
    required this.inProgressGoals,
    required this.completionRate,
    required this.completionByCategory,
    required this.insights,
    required this.performanceTrend,
    required this.averageCompletionTime,
    required this.successFactors,
  });

  Map<String, dynamic> toJson() => {
    'totalGoals': totalGoals,
    'completedGoals': completedGoals,
    'inProgressGoals': inProgressGoals,
    'completionRate': completionRate,
    'completionByCategory': completionByCategory,
    'insights': insights.map((i) => i.toJson()).toList(),
    'performanceTrend': performanceTrend,
    'averageCompletionTime': averageCompletionTime,
    'successFactors': successFactors,
  };

  factory GoalAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      GoalAnalyticsModel(
        totalGoals: json['totalGoals'],
        completedGoals: json['completedGoals'],
        inProgressGoals: json['inProgressGoals'],
        completionRate: json['completionRate'].toDouble(),
        completionByCategory: Map<String, double>.from(json['completionByCategory']),
        insights: (json['insights'] as List)
            .map((i) => GoalPerformanceInsight.fromJson(i))
            .toList(),
        performanceTrend: json['performanceTrend'],
        averageCompletionTime: json['averageCompletionTime'].toDouble(),
        successFactors: List<String>.from(json['successFactors']),
      );
}

// ============================================================================
// GOAL PERFORMANCE INSIGHT
// ============================================================================
class GoalPerformanceInsight {
  final String title;
  final String description;
  final String category;
  final String impact; // 'high', 'medium', 'low'
  final String recommendation;

  const GoalPerformanceInsight({
    required this.title,
    required this.description,
    required this.category,
    required this.impact,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'category': category,
    'impact': impact,
    'recommendation': recommendation,
  };

  factory GoalPerformanceInsight.fromJson(Map<String, dynamic> json) =>
      GoalPerformanceInsight(
        title: json['title'],
        description: json['description'],
        category: json['category'],
        impact: json['impact'],
        recommendation: json['recommendation'],
      );
}

// ============================================================================
// TEMPORAL PATTERN MODEL
// ============================================================================
class TemporalPatternModel {
  final Map<String, double> hourlyPatterns; // 0-23 hour averages
  final Map<String, double> dailyPatterns; // Monday-Sunday averages
  final Map<String, double> monthlyTrends; // Month-over-month changes
  final String optimalTimeOfDay; // 'morning', 'afternoon', 'evening'
  final String weeklyPattern; // 'weekday_focused', 'weekend_warrior', 'consistent'
  final List<TemporalInsight> insights;

  const TemporalPatternModel({
    required this.hourlyPatterns,
    required this.dailyPatterns,
    required this.monthlyTrends,
    required this.optimalTimeOfDay,
    required this.weeklyPattern,
    required this.insights,
  });

  Map<String, dynamic> toJson() => {
    'hourlyPatterns': hourlyPatterns,
    'dailyPatterns': dailyPatterns,
    'monthlyTrends': monthlyTrends,
    'optimalTimeOfDay': optimalTimeOfDay,
    'weeklyPattern': weeklyPattern,
    'insights': insights.map((i) => i.toJson()).toList(),
  };

  factory TemporalPatternModel.fromJson(Map<String, dynamic> json) =>
      TemporalPatternModel(
        hourlyPatterns: Map<String, double>.from(json['hourlyPatterns']),
        dailyPatterns: Map<String, double>.from(json['dailyPatterns']),
        monthlyTrends: Map<String, double>.from(json['monthlyTrends']),
        optimalTimeOfDay: json['optimalTimeOfDay'],
        weeklyPattern: json['weeklyPattern'],
        insights: (json['insights'] as List)
            .map((i) => TemporalInsight.fromJson(i))
            .toList(),
      );
}

// ============================================================================
// TEMPORAL INSIGHT
// ============================================================================
class TemporalInsight {
  final String pattern;
  final String description;
  final String recommendation;
  final double confidence; // 0.0 to 1.0

  const TemporalInsight({
    required this.pattern,
    required this.description,
    required this.recommendation,
    required this.confidence,
  });

  Map<String, dynamic> toJson() => {
    'pattern': pattern,
    'description': description,
    'recommendation': recommendation,
    'confidence': confidence,
  };

  factory TemporalInsight.fromJson(Map<String, dynamic> json) =>
      TemporalInsight(
        pattern: json['pattern'],
        description: json['description'],
        recommendation: json['recommendation'],
        confidence: json['confidence'].toDouble(),
      );
}

// ============================================================================
// COMPREHENSIVE ANALYTICS V3 MODEL
// ============================================================================
class AnalyticsV3Model {
  final DateTime generatedAt;
  final int userId;
  final int periodDays;
  final WellnessScoreModel wellnessScore;
  final List<ActivityCorrelationModel> activityCorrelations;
  final SleepPatternModel sleepPattern;
  final StressManagementModel stressManagement;
  final GoalAnalyticsModel goalAnalytics;
  final TemporalPatternModel temporalPatterns;
  final Map<String, dynamic> summaryMetrics;
  final List<String> keyInsights;

  const AnalyticsV3Model({
    required this.generatedAt,
    required this.userId,
    required this.periodDays,
    required this.wellnessScore,
    required this.activityCorrelations,
    required this.sleepPattern,
    required this.stressManagement,
    required this.goalAnalytics,
    required this.temporalPatterns,
    required this.summaryMetrics,
    required this.keyInsights,
  });

  Map<String, dynamic> toJson() => {
    'generatedAt': generatedAt.toIso8601String(),
    'userId': userId,
    'periodDays': periodDays,
    'wellnessScore': wellnessScore.toJson(),
    'activityCorrelations': activityCorrelations.map((ac) => ac.toJson()).toList(),
    'sleepPattern': sleepPattern.toJson(),
    'stressManagement': stressManagement.toJson(),
    'goalAnalytics': goalAnalytics.toJson(),
    'temporalPatterns': temporalPatterns.toJson(),
    'summaryMetrics': summaryMetrics,
    'keyInsights': keyInsights,
  };

  factory AnalyticsV3Model.fromJson(Map<String, dynamic> json) =>
      AnalyticsV3Model(
        generatedAt: DateTime.parse(json['generatedAt']),
        userId: json['userId'],
        periodDays: json['periodDays'],
        wellnessScore: WellnessScoreModel.fromJson(json['wellnessScore']),
        activityCorrelations: (json['activityCorrelations'] as List)
            .map((ac) => ActivityCorrelationModel.fromJson(ac))
            .toList(),
        sleepPattern: SleepPatternModel.fromJson(json['sleepPattern']),
        stressManagement: StressManagementModel.fromJson(json['stressManagement']),
        goalAnalytics: GoalAnalyticsModel.fromJson(json['goalAnalytics']),
        temporalPatterns: TemporalPatternModel.fromJson(json['temporalPatterns']),
        summaryMetrics: json['summaryMetrics'],
        keyInsights: List<String>.from(json['keyInsights']),
      );
}