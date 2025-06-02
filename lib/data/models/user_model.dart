// ============================================================================
// data/models/user_model.dart
// ============================================================================

import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int? id;
  final String email;
  final String name;
  final String avatarEmoji;
  final Map<String, dynamic> preferences;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  const UserModel({
    this.id,
    required this.email,
    required this.name,
    this.avatarEmoji = '🧘‍♀️',
    this.preferences = const {},
    this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Método para crear usuario desde base de datos
  factory UserModel.fromDatabase(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      email: map['email'] as String,
      name: map['name'] as String,
      avatarEmoji: map['avatar_emoji'] as String? ?? '🧘‍♀️',
      preferences: map['preferences'] != null
          ? Map<String, dynamic>.from(json.decode(map['preferences']))
          : {},
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      lastLogin: map['last_login'] != null
          ? DateTime.parse(map['last_login'] as String)
          : null,
    );
  }

  // Método para convertir a base de datos
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'name': name,
      'avatar_emoji': avatarEmoji,
      'preferences': json.encode(preferences),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (lastLogin != null) 'last_login': lastLogin!.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? email,
    String? name,
    String? avatarEmoji,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

// ============================================================================
// data/models/tag_model.dart
// ============================================================================

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

// ============================================================================
// data/models/interactive_moment_model.dart
// ============================================================================

@JsonSerializable()
class InteractiveMomentModel {
  final String id;
  final String emoji;
  final String text;
  final String type; // "positive" o "negative"
  final int intensity; // 1-10
  final String category;
  final String timeStr;
  final DateTime timestamp;
  final DateTime entryDate;

  const InteractiveMomentModel({
    required this.id,
    required this.emoji,
    required this.text,
    required this.type,
    required this.intensity,
    required this.category,
    required this.timeStr,
    required this.timestamp,
    required this.entryDate,
  });

  factory InteractiveMomentModel.create({
    required String emoji,
    required String text,
    required String type,
    int intensity = 5,
    String category = "general",
    String? timeStr,
  }) {
    final now = DateTime.now();
    return InteractiveMomentModel(
      id: '${now.millisecondsSinceEpoch}',
      emoji: emoji,
      text: text,
      type: type,
      intensity: intensity,
      category: category,
      timeStr: timeStr ?? '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      timestamp: now,
      entryDate: DateTime(now.year, now.month, now.day),
    );
  }

  factory InteractiveMomentModel.fromJson(Map<String, dynamic> json) => _$InteractiveMomentModelFromJson(json);
  Map<String, dynamic> toJson() => _$InteractiveMomentModelToJson(this);

  // Para base de datos
  factory InteractiveMomentModel.fromDatabase(Map<String, dynamic> map) {
    return InteractiveMomentModel(
      id: map['moment_id'] as String,
      emoji: map['emoji'] as String,
      text: map['text'] as String,
      type: map['moment_type'] as String,
      intensity: map['intensity'] as int,
      category: map['category'] as String,
      timeStr: map['time_str'] as String,
      timestamp: DateTime.parse(map['created_at'] as String),
      entryDate: DateTime.parse(map['entry_date'] as String),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'moment_id': id,
      'emoji': emoji,
      'text': text,
      'moment_type': type,
      'intensity': intensity,
      'category': category,
      'time_str': timeStr,
      'timestamp_data': timestamp.toIso8601String(),
      'created_at': timestamp.toIso8601String(),
      'entry_date': entryDate.toIso8601String().split('T')[0],
    };
  }

  // Convertir a TagModel para compatibilidad
  TagModel toTag() {
    return TagModel(
      name: text,
      context: 'Momento $category de intensidad $intensity a las $timeStr',
      emoji: emoji,
      type: type,
    );
  }

  InteractiveMomentModel copyWith({
    String? id,
    String? emoji,
    String? text,
    String? type,
    int? intensity,
    String? category,
    String? timeStr,
    DateTime? timestamp,
    DateTime? entryDate,
  }) {
    return InteractiveMomentModel(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      text: text ?? this.text,
      type: type ?? this.type,
      intensity: intensity ?? this.intensity,
      category: category ?? this.category,
      timeStr: timeStr ?? this.timeStr,
      timestamp: timestamp ?? this.timestamp,
      entryDate: entryDate ?? this.entryDate,
    );
  }
}

// ============================================================================
// data/models/daily_entry_model.dart
// ============================================================================

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