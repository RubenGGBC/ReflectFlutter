// ============================================================================
// data/models/daily_entry_model.dart - VERSIÓN EXTENDIDA CON TODOS LOS PARÁMETROS
// REEMPLAZAR TODO EL ARCHIVO
// ============================================================================

import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'daily_entry_model.g.dart';

@JsonSerializable()
class DailyEntryModel {
  final int? id;
  final int userId;
  final String freeReflection;
  final String? innerReflection;
  final String? gratitudeItems;
  final List<String> positiveTags;
  final List<String> negativeTags;
  final List<String> completedActivitiesToday;
  final List<String> goalsSummary;
  final bool? worthIt;
  final String? overallSentiment;
  final int? moodScore;
  final String? aiSummary;
  final int wordCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime entryDate;

  // ✅ NUEVOS CAMPOS DE ANALYTICS
  final int? energyLevel;
  final int? stressLevel;
  final int? sleepQuality;
  final int? anxietyLevel;
  final int? motivationLevel;
  final int? socialInteraction;
  final int? physicalActivity;
  final int? workProductivity;
  final double? sleepHours;
  final int? waterIntake;
  final int? meditationMinutes;
  final int? exerciseMinutes;
  final double? screenTimeHours;
  final int? weatherMoodImpact;
  final int? socialBattery;
  final int? creativeEnergy;
  final int? emotionalStability;
  final int? focusLevel;
  final int? lifeSatisfaction;
  final String? voiceRecordingPath;
  final List<String> imagePaths;

  const DailyEntryModel({
    this.id,
    required this.userId,
    required this.freeReflection,
    this.innerReflection,
    this.gratitudeItems,
    this.positiveTags = const [],
    this.negativeTags = const [],
    this.completedActivitiesToday = const [],
    this.goalsSummary = const [],
    this.worthIt,
    this.overallSentiment,
    this.moodScore,
    this.aiSummary,
    this.wordCount = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.entryDate,
    // ✅ NUEVOS PARÁMETROS
    this.energyLevel,
    this.stressLevel,
    this.sleepQuality,
    this.anxietyLevel,
    this.motivationLevel,
    this.socialInteraction,
    this.physicalActivity,
    this.workProductivity,
    this.sleepHours,
    this.waterIntake,
    this.meditationMinutes,
    this.exerciseMinutes,
    this.screenTimeHours,
    this.weatherMoodImpact,
    this.socialBattery,
    this.creativeEnergy,
    this.emotionalStability,
    this.focusLevel,
    this.lifeSatisfaction,
    this.voiceRecordingPath,
    this.imagePaths = const [],
  });

  factory DailyEntryModel.create({
    required int userId,
    required String freeReflection,
    String? innerReflection,
    String? gratitudeItems,
    List<String> positiveTags = const [],
    List<String> negativeTags = const [],
    List<String> completedActivitiesToday = const [],
    List<String> goalsSummary = const [],
    bool? worthIt,
    // ✅ PARÁMETROS OPCIONALES DE ANALYTICS
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
    int? weatherMoodImpact,
    int? socialBattery,
    int? creativeEnergy,
    int? emotionalStability,
    int? focusLevel,
    int? lifeSatisfaction,
    String? voiceRecordingPath,
    List<String> imagePaths = const [],
    DateTime? entryDate,
  }) {
    final now = DateTime.now();
    final wordCount = freeReflection.split(' ').where((s) => s.isNotEmpty).length;

    final positiveCount = positiveTags.length;
    final negativeCount = negativeTags.length;

    int moodScore = 5; // neutral
    if (positiveCount > negativeCount) {
      moodScore = 7 + (positiveCount - negativeCount).clamp(0, 3);
    } else if (negativeCount > positiveCount) {
      moodScore = 5 - (negativeCount - positiveCount).clamp(0, 3);
    }
    moodScore = moodScore.clamp(1, 10);

    String sentiment = "balanced";
    if (moodScore >= 7) sentiment = "positive";
    else if (moodScore <= 4) sentiment = "negative";

    return DailyEntryModel(
      userId: userId,
      freeReflection: freeReflection,
      innerReflection: innerReflection,
      gratitudeItems: gratitudeItems,
      positiveTags: positiveTags,
      negativeTags: negativeTags,
      completedActivitiesToday: completedActivitiesToday,
      goalsSummary: goalsSummary,
      worthIt: worthIt,
      overallSentiment: sentiment,
      moodScore: moodScore,
      wordCount: wordCount,
      createdAt: now,
      updatedAt: now,
      entryDate: DateTime(now.year, now.month, now.day),
      // ✅ ASIGNAR VALORES DE ANALYTICS
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
      weatherMoodImpact: weatherMoodImpact,
      socialBattery: socialBattery,
      creativeEnergy: creativeEnergy,
      emotionalStability: emotionalStability,
      focusLevel: focusLevel,
      lifeSatisfaction: lifeSatisfaction,
      voiceRecordingPath: voiceRecordingPath,
      imagePaths: imagePaths,
    );
  }

  factory DailyEntryModel.fromJson(Map<String, dynamic> json) => _$DailyEntryModelFromJson(json);
  Map<String, dynamic> toJson() => _$DailyEntryModelToJson(this);

  // Para base de datos
  factory DailyEntryModel.fromDatabase(Map<String, dynamic> map) {
    List<String> parseTagsJson(String? jsonStr) {
      if (jsonStr == null || jsonStr.isEmpty) return [];
      try {
        final List<dynamic> tagsList = json.decode(jsonStr);
        return tagsList.map((tag) => tag.toString()).toList();
      } catch (e) {
        return [];
      }
    }

    return DailyEntryModel(
      id: map['id'] as int?,
      userId: (map['user_id'] as int?) ?? 0,
      freeReflection: (map['free_reflection'] as String?) ?? '',
      innerReflection: (map['inner_reflection'] as String?),
      gratitudeItems: (map['gratitude_items'] as String?),
      positiveTags: parseTagsJson(map['positive_tags'] as String?),
      negativeTags: parseTagsJson(map['negative_tags'] as String?),
      completedActivitiesToday: (json.decode(map['completed_activities_today'] as String) as List<dynamic>).map((e) => e as String).toList(),
      goalsSummary: (json.decode(map['goals_summary'] as String) as List<dynamic>).map((e) => e as String).toList(),
      worthIt: map['worth_it'] != null ? (map['worth_it'] as int) == 1 : null,
      overallSentiment: map['overall_sentiment'] as String?,
      moodScore: map['mood_score'] as int?,
      aiSummary: map['ai_summary'] as String?,
      wordCount: (map['word_count'] as int?) ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      entryDate: DateTime.parse(map['entry_date'] as String),
      // ✅ LEER CAMPOS DE ANALYTICS
      energyLevel: map['energy_level'] as int?,
      stressLevel: map['stress_level'] as int?,
      sleepQuality: map['sleep_quality'] as int?,
      anxietyLevel: map['anxiety_level'] as int?,
      motivationLevel: map['motivation_level'] as int?,
      socialInteraction: map['social_interaction'] as int?,
      physicalActivity: map['physical_activity'] as int?,
      workProductivity: map['work_productivity'] as int?,
      sleepHours: (map['sleep_hours'] as num?)?.toDouble(),
      waterIntake: map['water_intake'] as int?,
      meditationMinutes: map['meditation_minutes'] as int?,
      exerciseMinutes: map['exercise_minutes'] as int?,
      screenTimeHours: (map['screen_time_hours'] as num?)?.toDouble(),
      weatherMoodImpact: map['weather_mood_impact'] as int?,
      socialBattery: map['social_battery'] as int?,
      creativeEnergy: map['creative_energy'] as int?,
      emotionalStability: map['emotional_stability'] as int?,
      focusLevel: map['focus_level'] as int?,
      lifeSatisfaction: map['life_satisfaction'] as int?,
      voiceRecordingPath: map['voice_recording_path'] as String?,
      imagePaths: parseTagsJson(map['image_paths'] as String?),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'free_reflection': freeReflection,
      'inner_reflection': innerReflection,
      'gratitude_items': gratitudeItems,
      'positive_tags': json.encode(positiveTags),
      'negative_tags': json.encode(negativeTags),
      'completed_activities_today': json.encode(completedActivitiesToday),
      'goals_summary': json.encode(goalsSummary),
      'worth_it': worthIt == null ? null : (worthIt! ? 1 : 0),
      'overall_sentiment': overallSentiment,
      'mood_score': moodScore,
      'ai_summary': aiSummary,
      'word_count': wordCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'entry_date': entryDate.toIso8601String().split('T')[0],
      // ✅ INCLUIR CAMPOS DE ANALYTICS
      'energy_level': energyLevel,
      'stress_level': stressLevel,
      'sleep_quality': sleepQuality,
      'anxiety_level': anxietyLevel,
      'motivation_level': motivationLevel,
      'social_interaction': socialInteraction,
      'physical_activity': physicalActivity,
      'work_productivity': workProductivity,
      'sleep_hours': sleepHours,
      'water_intake': waterIntake,
      'meditation_minutes': meditationMinutes,
      'exercise_minutes': exerciseMinutes,
      'screen_time_hours': screenTimeHours,
      'weather_mood_impact': weatherMoodImpact,
      'social_battery': socialBattery,
      'creative_energy': creativeEnergy,
      'emotional_stability': emotionalStability,
      'focus_level': focusLevel,
      'life_satisfaction': lifeSatisfaction,
      'voice_recording_path': voiceRecordingPath,
      'image_paths': json.encode(imagePaths),
    };
  }

  DailyEntryModel copyWith({
    int? id,
    int? userId,
    String? freeReflection,
    String? innerReflection,
    String? gratitudeItems,
    List<String>? positiveTags,
    List<String>? negativeTags,
    List<String>? completedActivitiesToday,
    List<String>? goalsSummary,
    bool? worthIt,
    String? overallSentiment,
    int? moodScore,
    String? aiSummary,
    int? wordCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? entryDate,
    // ✅ PARÁMETROS DE ANALYTICS EN COPYWITH
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
    int? weatherMoodImpact,
    int? socialBattery,
    int? creativeEnergy,
    int? emotionalStability,
    int? focusLevel,
    int? lifeSatisfaction,
    String? voiceRecordingPath,
    List<String>? imagePaths,
  }) {
    return DailyEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      freeReflection: freeReflection ?? this.freeReflection,
      innerReflection: innerReflection ?? this.innerReflection,
      gratitudeItems: gratitudeItems ?? this.gratitudeItems,
      positiveTags: positiveTags ?? this.positiveTags,
      negativeTags: negativeTags ?? this.negativeTags,
      completedActivitiesToday: completedActivitiesToday ?? this.completedActivitiesToday,
      goalsSummary: goalsSummary ?? this.goalsSummary,
      worthIt: worthIt ?? this.worthIt,
      overallSentiment: overallSentiment ?? this.overallSentiment,
      moodScore: moodScore ?? this.moodScore,
      aiSummary: aiSummary ?? this.aiSummary,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      entryDate: entryDate ?? this.entryDate,
      // ✅ COPYWITH DE ANALYTICS
      energyLevel: energyLevel ?? this.energyLevel,
      stressLevel: stressLevel ?? this.stressLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      anxietyLevel: anxietyLevel ?? this.anxietyLevel,
      motivationLevel: motivationLevel ?? this.motivationLevel,
      socialInteraction: socialInteraction ?? this.socialInteraction,
      physicalActivity: physicalActivity ?? this.physicalActivity,
      workProductivity: workProductivity ?? this.workProductivity,
      sleepHours: sleepHours ?? this.sleepHours,
      waterIntake: waterIntake ?? this.waterIntake,
      meditationMinutes: meditationMinutes ?? this.meditationMinutes,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      screenTimeHours: screenTimeHours ?? this.screenTimeHours,
      weatherMoodImpact: weatherMoodImpact ?? this.weatherMoodImpact,
      socialBattery: socialBattery ?? this.socialBattery,
      creativeEnergy: creativeEnergy ?? this.creativeEnergy,
      emotionalStability: emotionalStability ?? this.emotionalStability,
      focusLevel: focusLevel ?? this.focusLevel,
      lifeSatisfaction: lifeSatisfaction ?? this.lifeSatisfaction,
      voiceRecordingPath: voiceRecordingPath ?? this.voiceRecordingPath,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }
}