// ============================================================================
// data/models/daily_entry_model.dart - NUEVO ARCHIVO SEPARADO
// ============================================================================

import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'tag_model.dart';

part 'daily_entry_model.g.dart';

@JsonSerializable()
class DailyEntryModel {
  final int? id;
  final int userId;
  final String freeReflection;
  final List<TagModel> positiveTags;
  final List<TagModel> negativeTags;
  final bool? worthIt;
  final String? overallSentiment;
  final int? moodScore;
  final String? aiSummary;
  final int wordCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime entryDate;

  const DailyEntryModel({
    this.id,
    required this.userId,
    required this.freeReflection,
    this.positiveTags = const [],
    this.negativeTags = const [],
    this.worthIt,
    this.overallSentiment,
    this.moodScore,
    this.aiSummary,
    this.wordCount = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.entryDate,
  });

  factory DailyEntryModel.create({
    required int userId,
    required String freeReflection,
    List<TagModel> positiveTags = const [],
    List<TagModel> negativeTags = const [],
    bool? worthIt,
  }) {
    final now = DateTime.now();
    final wordCount = freeReflection.split(' ').length;

    // Calcular mood score simple basado en balance
    final positiveCount = positiveTags.length;
    final negativeCount = negativeTags.length;

    int moodScore = 5; // neutral
    if (positiveCount > negativeCount) {
      moodScore = 7 + (positiveCount - negativeCount).clamp(0, 3);
    } else if (negativeCount > positiveCount) {
      moodScore = 5 - (negativeCount - positiveCount).clamp(0, 3);
    }
    moodScore = moodScore.clamp(1, 10);

    // Sentimiento general
    String sentiment = "balanced";
    if (moodScore >= 7) {
      sentiment = "positive";
    } else if (moodScore <= 4) {
      sentiment = "negative";
    }

    return DailyEntryModel(
      userId: userId,
      freeReflection: freeReflection,
      positiveTags: positiveTags,
      negativeTags: negativeTags,
      worthIt: worthIt,
      overallSentiment: sentiment,
      moodScore: moodScore,
      wordCount: wordCount,
      createdAt: now,
      updatedAt: now,
      entryDate: DateTime(now.year, now.month, now.day),
    );
  }

  factory DailyEntryModel.fromJson(Map<String, dynamic> json) => _$DailyEntryModelFromJson(json);
  Map<String, dynamic> toJson() => _$DailyEntryModelToJson(this);

  // Para base de datos
  factory DailyEntryModel.fromDatabase(Map<String, dynamic> map) {
    // Parsear tags JSON de manera segura
    List<TagModel> parseTagsJson(String? jsonStr) {
      if (jsonStr == null || jsonStr.isEmpty) return [];
      try {
        final List<dynamic> tagsList = json.decode(jsonStr);
        return tagsList.map((tagJson) => TagModel.fromJson(tagJson as Map<String, dynamic>)).toList();
      } catch (e) {
        return [];
      }
    }

    return DailyEntryModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      freeReflection: map['free_reflection'] as String,
      positiveTags: parseTagsJson(map['positive_tags'] as String?),
      negativeTags: parseTagsJson(map['negative_tags'] as String?),
      worthIt: map['worth_it'] != null ? (map['worth_it'] as int) == 1 : null,
      overallSentiment: map['overall_sentiment'] as String?,
      moodScore: map['mood_score'] as int?,
      aiSummary: map['ai_summary'] as String?,
      wordCount: map['word_count'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      entryDate: DateTime.parse(map['entry_date'] as String),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'free_reflection': freeReflection,
      'positive_tags': json.encode(positiveTags.map((tag) => tag.toJson()).toList()),
      'negative_tags': json.encode(negativeTags.map((tag) => tag.toJson()).toList()),
      'worth_it': worthIt != null ? (worthIt! ? 1 : 0) : null,
      'overall_sentiment': overallSentiment,
      'mood_score': moodScore,
      'ai_summary': aiSummary,
      'word_count': wordCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'entry_date': entryDate.toIso8601String().split('T')[0],
    };
  }

  DailyEntryModel copyWith({
    int? id,
    int? userId,
    String? freeReflection,
    List<TagModel>? positiveTags,
    List<TagModel>? negativeTags,
    bool? worthIt,
    String? overallSentiment,
    int? moodScore,
    String? aiSummary,
    int? wordCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? entryDate,
  }) {
    return DailyEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      freeReflection: freeReflection ?? this.freeReflection,
      positiveTags: positiveTags ?? this.positiveTags,
      negativeTags: negativeTags ?? this.negativeTags,
      worthIt: worthIt ?? this.worthIt,
      overallSentiment: overallSentiment ?? this.overallSentiment,
      moodScore: moodScore ?? this.moodScore,
      aiSummary: aiSummary ?? this.aiSummary,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      entryDate: entryDate ?? this.entryDate,
    );
  }
}