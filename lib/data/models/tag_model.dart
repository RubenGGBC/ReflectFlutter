// ============================================================================
// data/models/tag_model.dart - NUEVO ARCHIVO SEPARADO
// ============================================================================

import 'package:json_annotation/json_annotation.dart';

part 'tag_model.g.dart';

@JsonSerializable()
class TagModel {
  final String name;
  final String context;
  final String emoji;
  final String? type;

  const TagModel({
    required this.name,
    required this.context,
    required this.emoji,
    this.type,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) => _$TagModelFromJson(json);
  Map<String, dynamic> toJson() => _$TagModelToJson(this);

  TagModel copyWith({
    String? name,
    String? context,
    String? emoji,
    String? type,
  }) {
    return TagModel(
      name: name ?? this.name,
      context: context ?? this.context,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
    );
  }
}