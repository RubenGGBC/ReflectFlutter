// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roadmap_activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoadmapActivityModel _$RoadmapActivityModelFromJson(
        Map<String, dynamic> json) =>
    RoadmapActivityModel(
      id: json['id'] as String,
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      feelingsNotes: json['feelingsNotes'] as String?,
      priority:
          $enumDecodeNullable(_$ActivityPriorityEnumMap, json['priority']) ??
              ActivityPriority.medium,
      plannedMood:
          $enumDecodeNullable(_$ActivityMoodEnumMap, json['plannedMood']),
      actualMood:
          $enumDecodeNullable(_$ActivityMoodEnumMap, json['actualMood']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      category: json['category'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      estimatedDuration: (json['estimatedDuration'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RoadmapActivityModelToJson(
        RoadmapActivityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hour': instance.hour,
      'minute': instance.minute,
      'title': instance.title,
      'description': instance.description,
      'notes': instance.notes,
      'feelingsNotes': instance.feelingsNotes,
      'priority': _$ActivityPriorityEnumMap[instance.priority]!,
      'plannedMood': _$ActivityMoodEnumMap[instance.plannedMood],
      'actualMood': _$ActivityMoodEnumMap[instance.actualMood],
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
      'category': instance.category,
      'tags': instance.tags,
      'estimatedDuration': instance.estimatedDuration,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ActivityPriorityEnumMap = {
  ActivityPriority.low: 'low',
  ActivityPriority.medium: 'medium',
  ActivityPriority.high: 'high',
  ActivityPriority.urgent: 'urgent',
};

const _$ActivityMoodEnumMap = {
  ActivityMood.veryBad: 'very_bad',
  ActivityMood.bad: 'bad',
  ActivityMood.neutral: 'neutral',
  ActivityMood.good: 'good',
  ActivityMood.veryGood: 'very_good',
  ActivityMood.excited: 'excited',
};
