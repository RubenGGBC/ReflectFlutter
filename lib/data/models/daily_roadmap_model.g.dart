// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_roadmap_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRoadmapModel _$DailyRoadmapModelFromJson(Map<String, dynamic> json) =>
    DailyRoadmapModel(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      targetDate: DateTime.parse(json['targetDate'] as String),
      activities: (json['activities'] as List<dynamic>?)
              ?.map((e) =>
                  RoadmapActivityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      dailyGoal: json['dailyGoal'] as String?,
      morningNotes: json['morningNotes'] as String?,
      eveningReflection: json['eveningReflection'] as String?,
      status: $enumDecodeNullable(_$RoadmapStatusEnumMap, json['status']) ??
          RoadmapStatus.planned,
      completionPercentage: (json['completionPercentage'] as num?)?.toDouble(),
      overallMood:
          $enumDecodeNullable(_$ActivityMoodEnumMap, json['overallMood']),
      totalActivities: (json['totalActivities'] as num?)?.toInt(),
      completedActivities: (json['completedActivities'] as num?)?.toInt(),
      totalEstimatedMinutes: (json['totalEstimatedMinutes'] as num?)?.toInt(),
      actualSpentMinutes: (json['actualSpentMinutes'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DailyRoadmapModelToJson(DailyRoadmapModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'targetDate': instance.targetDate.toIso8601String(),
      'activities': instance.activities,
      'dailyGoal': instance.dailyGoal,
      'morningNotes': instance.morningNotes,
      'eveningReflection': instance.eveningReflection,
      'status': _$RoadmapStatusEnumMap[instance.status]!,
      'completionPercentage': instance.completionPercentage,
      'overallMood': _$ActivityMoodEnumMap[instance.overallMood],
      'totalActivities': instance.totalActivities,
      'completedActivities': instance.completedActivities,
      'totalEstimatedMinutes': instance.totalEstimatedMinutes,
      'actualSpentMinutes': instance.actualSpentMinutes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$RoadmapStatusEnumMap = {
  RoadmapStatus.planned: 'planned',
  RoadmapStatus.inProgress: 'in_progress',
  RoadmapStatus.completed: 'completed',
  RoadmapStatus.partiallyCompleted: 'partially_completed',
  RoadmapStatus.cancelled: 'cancelled',
};

const _$ActivityMoodEnumMap = {
  ActivityMood.veryBad: 'very_bad',
  ActivityMood.bad: 'bad',
  ActivityMood.neutral: 'neutral',
  ActivityMood.good: 'good',
  ActivityMood.veryGood: 'very_good',
  ActivityMood.excited: 'excited',
};
