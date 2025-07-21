// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommended_activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendedActivity _$RecommendedActivityFromJson(Map<String, dynamic> json) =>
    RecommendedActivity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      difficultyLevel: (json['difficultyLevel'] as num).toInt(),
      benefits:
          (json['benefits'] as List<dynamic>).map((e) => e as String).toList(),
      instructions: (json['instructions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      resources: json['resources'] as Map<String, dynamic>,
      requiresTimer: json['requiresTimer'] as bool? ?? false,
      requiresEquipment: json['requiresEquipment'] as bool? ?? false,
      equipment: (json['equipment'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      motivationalQuote: json['motivationalQuote'] as String? ?? '',
      lastRecommended: json['lastRecommended'] == null
          ? null
          : DateTime.parse(json['lastRecommended'] as String),
      timesCompleted: (json['timesCompleted'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$RecommendedActivityToJson(
        RecommendedActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'durationMinutes': instance.durationMinutes,
      'difficultyLevel': instance.difficultyLevel,
      'benefits': instance.benefits,
      'instructions': instance.instructions,
      'resources': instance.resources,
      'requiresTimer': instance.requiresTimer,
      'requiresEquipment': instance.requiresEquipment,
      'equipment': instance.equipment,
      'motivationalQuote': instance.motivationalQuote,
      'lastRecommended': instance.lastRecommended?.toIso8601String(),
      'timesCompleted': instance.timesCompleted,
      'averageRating': instance.averageRating,
    };

const _$ActivityTypeEnumMap = {
  ActivityType.mindfulness: 'mindfulness',
  ActivityType.exercise: 'exercise',
  ActivityType.creativity: 'creativity',
  ActivityType.social: 'social',
  ActivityType.learning: 'learning',
  ActivityType.selfCare: 'selfCare',
  ActivityType.nutrition: 'nutrition',
  ActivityType.breathing: 'breathing',
  ActivityType.meditation: 'meditation',
  ActivityType.movement: 'movement',
  ActivityType.relaxation: 'relaxation',
  ActivityType.productivity: 'productivity',
  ActivityType.gratitude: 'gratitude',
  ActivityType.reflection: 'reflection',
  ActivityType.challenge: 'challenge',
};

ActivityCompletion _$ActivityCompletionFromJson(Map<String, dynamic> json) =>
    ActivityCompletion(
      activityId: json['activityId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      notes: json['notes'] as String?,
      metrics: json['metrics'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ActivityCompletionToJson(ActivityCompletion instance) =>
    <String, dynamic>{
      'activityId': instance.activityId,
      'completedAt': instance.completedAt.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'rating': instance.rating,
      'notes': instance.notes,
      'metrics': instance.metrics,
    };
