// ============================================================================
// roadmap_activity_model.dart - MODELO PARA ACTIVIDADES DEL ROADMAP DIARIO
// ============================================================================

import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'roadmap_activity_model.g.dart';

@JsonSerializable()
class RoadmapActivityModel {
  final String id;
  final int hour; // 0-23
  final int minute; // 0-59
  final String title;
  final String? description;
  final String? notes;
  final String? feelingsNotes;
  final ActivityPriority priority;
  final ActivityMood? plannedMood;
  final ActivityMood? actualMood;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? category;
  final List<String> tags;
  final int? estimatedDuration; // minutes
  final DateTime createdAt;
  final DateTime updatedAt;

  const RoadmapActivityModel({
    required this.id,
    required this.hour,
    required this.minute,
    required this.title,
    this.description,
    this.notes,
    this.feelingsNotes,
    this.priority = ActivityPriority.medium,
    this.plannedMood,
    this.actualMood,
    this.isCompleted = false,
    this.completedAt,
    this.category,
    this.tags = const [],
    this.estimatedDuration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoadmapActivityModel.create({
    required int hour,
    required int minute,
    required String title,
    String? description,
    ActivityPriority priority = ActivityPriority.medium,
    String? category,
    List<String> tags = const [],
    int? estimatedDuration,
  }) {
    final now = DateTime.now();
    return RoadmapActivityModel(
      id: '${now.millisecondsSinceEpoch}_${hour}_${minute}',
      hour: hour,
      minute: minute,
      title: title,
      description: description,
      priority: priority,
      category: category,
      tags: tags,
      estimatedDuration: estimatedDuration,
      createdAt: now,
      updatedAt: now,
    );
  }

  // JSON serialization
  factory RoadmapActivityModel.fromJson(Map<String, dynamic> json) =>
      _$RoadmapActivityModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapActivityModelToJson(this);

  // Convenience methods
  String get timeString {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  bool get isInProgress {
    final now = DateTime.now();
    final activityTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    final endTime = activityTime.add(Duration(minutes: estimatedDuration ?? 60));
    return now.isAfter(activityTime) && now.isBefore(endTime) && !isCompleted;
  }

  bool get isPast {
    final now = DateTime.now();
    final activityTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    final endTime = activityTime.add(Duration(minutes: estimatedDuration ?? 60));
    return now.isAfter(endTime);
  }

  // Copy methods
  RoadmapActivityModel copyWith({
    String? id,
    int? hour,
    int? minute,
    String? title,
    String? description,
    String? notes,
    String? feelingsNotes,
    ActivityPriority? priority,
    ActivityMood? plannedMood,
    ActivityMood? actualMood,
    bool? isCompleted,
    DateTime? completedAt,
    String? category,
    List<String>? tags,
    int? estimatedDuration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoadmapActivityModel(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      title: title ?? this.title,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      feelingsNotes: feelingsNotes ?? this.feelingsNotes,
      priority: priority ?? this.priority,
      plannedMood: plannedMood ?? this.plannedMood,
      actualMood: actualMood ?? this.actualMood,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoadmapActivityModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RoadmapActivityModel(id: $id, time: $timeString, title: $title)';
}

// ============================================================================
// ENUMS
// ============================================================================

@JsonEnum()
enum ActivityPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

@JsonEnum()
enum ActivityMood {
  @JsonValue('very_bad')
  veryBad,
  @JsonValue('bad')
  bad,
  @JsonValue('neutral')
  neutral,
  @JsonValue('good')
  good,
  @JsonValue('very_good')
  veryGood,
  @JsonValue('excited')
  excited,
}

// ============================================================================
// EXTENSIONS
// ============================================================================

extension ActivityPriorityExtension on ActivityPriority {
  String get displayName {
    switch (this) {
      case ActivityPriority.low:
        return 'Baja';
      case ActivityPriority.medium:
        return 'Media';
      case ActivityPriority.high:
        return 'Alta';
      case ActivityPriority.urgent:
        return 'Urgente';
    }
  }

  String get emoji {
    switch (this) {
      case ActivityPriority.low:
        return '🟢';
      case ActivityPriority.medium:
        return '🟡';
      case ActivityPriority.high:
        return '🟠';
      case ActivityPriority.urgent:
        return '🔴';
    }
  }
}

extension ActivityMoodExtension on ActivityMood {
  String get displayName {
    switch (this) {
      case ActivityMood.veryBad:
        return 'Muy mal';
      case ActivityMood.bad:
        return 'Mal';
      case ActivityMood.neutral:
        return 'Neutral';
      case ActivityMood.good:
        return 'Bien';
      case ActivityMood.veryGood:
        return 'Muy bien';
      case ActivityMood.excited:
        return 'Emocionado';
    }
  }

  String get emoji {
    switch (this) {
      case ActivityMood.veryBad:
        return '😞';
      case ActivityMood.bad:
        return '😔';
      case ActivityMood.neutral:
        return '😐';
      case ActivityMood.good:
        return '😊';
      case ActivityMood.veryGood:
        return '😄';
      case ActivityMood.excited:
        return '🤩';
    }
  }

  int get numericValue {
    switch (this) {
      case ActivityMood.veryBad:
        return 1;
      case ActivityMood.bad:
        return 2;
      case ActivityMood.neutral:
        return 3;
      case ActivityMood.good:
        return 4;
      case ActivityMood.veryGood:
        return 5;
      case ActivityMood.excited:
        return 6;
    }
  }
}