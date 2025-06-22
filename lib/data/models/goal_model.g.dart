// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoalModel _$GoalModelFromJson(Map<String, dynamic> json) => GoalModel(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$GoalTypeEnumMap, json['type']),
      status: $enumDecodeNullable(_$GoalStatusEnumMap, json['status']) ??
          GoalStatus.active,
      targetValue: (json['targetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$GoalModelToJson(GoalModel instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'type': _$GoalTypeEnumMap[instance.type]!,
      'status': _$GoalStatusEnumMap[instance.status]!,
      'targetValue': instance.targetValue,
      'currentValue': instance.currentValue,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };

const _$GoalTypeEnumMap = {
  GoalType.consistency: 'consistency',
  GoalType.mood: 'mood',
  GoalType.positiveMoments: 'positiveMoments',
  GoalType.stressReduction: 'stressReduction',
};

const _$GoalStatusEnumMap = {
  GoalStatus.active: 'active',
  GoalStatus.completed: 'completed',
  GoalStatus.archived: 'archived',
};
