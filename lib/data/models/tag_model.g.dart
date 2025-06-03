// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagModel _$TagModelFromJson(Map<String, dynamic> json) => TagModel(
      name: json['name'] as String,
      context: json['context'] as String,
      emoji: json['emoji'] as String,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$TagModelToJson(TagModel instance) => <String, dynamic>{
      'name': instance.name,
      'context': instance.context,
      'emoji': instance.emoji,
      'type': instance.type,
    };
