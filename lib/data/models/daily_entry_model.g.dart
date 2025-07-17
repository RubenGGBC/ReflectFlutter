// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyEntryModel _$DailyEntryModelFromJson(Map<String, dynamic> json) =>
    DailyEntryModel(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      freeReflection: json['freeReflection'] as String,
      positiveTags: (json['positiveTags'] as List<dynamic>?)
              ?.map((e) => TagModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      negativeTags: (json['negativeTags'] as List<dynamic>?)
              ?.map((e) => TagModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      worthIt: json['worthIt'] as bool?,
      overallSentiment: json['overallSentiment'] as String?,
      moodScore: (json['moodScore'] as num?)?.toInt(),
      aiSummary: json['aiSummary'] as String?,
      wordCount: (json['wordCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      entryDate: DateTime.parse(json['entryDate'] as String),
      energyLevel: (json['energyLevel'] as num?)?.toInt(),
      stressLevel: (json['stressLevel'] as num?)?.toInt(),
      sleepQuality: (json['sleepQuality'] as num?)?.toInt(),
      anxietyLevel: (json['anxietyLevel'] as num?)?.toInt(),
      motivationLevel: (json['motivationLevel'] as num?)?.toInt(),
      socialInteraction: (json['socialInteraction'] as num?)?.toInt(),
      physicalActivity: (json['physicalActivity'] as num?)?.toInt(),
      workProductivity: (json['workProductivity'] as num?)?.toInt(),
      sleepHours: (json['sleepHours'] as num?)?.toDouble(),
      waterIntake: (json['waterIntake'] as num?)?.toInt(),
      meditationMinutes: (json['meditationMinutes'] as num?)?.toInt(),
      exerciseMinutes: (json['exerciseMinutes'] as num?)?.toInt(),
      screenTimeHours: (json['screenTimeHours'] as num?)?.toDouble(),
      gratitudeItems: json['gratitudeItems'] as String?,
      weatherMoodImpact: (json['weatherMoodImpact'] as num?)?.toInt(),
      socialBattery: (json['socialBattery'] as num?)?.toInt(),
      creativeEnergy: (json['creativeEnergy'] as num?)?.toInt(),
      emotionalStability: (json['emotionalStability'] as num?)?.toInt(),
      focusLevel: (json['focusLevel'] as num?)?.toInt(),
      lifeSatisfaction: (json['lifeSatisfaction'] as num?)?.toInt(),
      voiceRecordingPath: json['voiceRecordingPath'] as String?,
    );

Map<String, dynamic> _$DailyEntryModelToJson(DailyEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'freeReflection': instance.freeReflection,
      'positiveTags': instance.positiveTags,
      'negativeTags': instance.negativeTags,
      'worthIt': instance.worthIt,
      'overallSentiment': instance.overallSentiment,
      'moodScore': instance.moodScore,
      'aiSummary': instance.aiSummary,
      'wordCount': instance.wordCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'entryDate': instance.entryDate.toIso8601String(),
      'energyLevel': instance.energyLevel,
      'stressLevel': instance.stressLevel,
      'sleepQuality': instance.sleepQuality,
      'anxietyLevel': instance.anxietyLevel,
      'motivationLevel': instance.motivationLevel,
      'socialInteraction': instance.socialInteraction,
      'physicalActivity': instance.physicalActivity,
      'workProductivity': instance.workProductivity,
      'sleepHours': instance.sleepHours,
      'waterIntake': instance.waterIntake,
      'meditationMinutes': instance.meditationMinutes,
      'exerciseMinutes': instance.exerciseMinutes,
      'screenTimeHours': instance.screenTimeHours,
      'gratitudeItems': instance.gratitudeItems,
      'weatherMoodImpact': instance.weatherMoodImpact,
      'socialBattery': instance.socialBattery,
      'creativeEnergy': instance.creativeEnergy,
      'emotionalStability': instance.emotionalStability,
      'focusLevel': instance.focusLevel,
      'lifeSatisfaction': instance.lifeSatisfaction,
      'voiceRecordingPath': instance.voiceRecordingPath,
    };
