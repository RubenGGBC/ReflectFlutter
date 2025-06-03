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
    };
