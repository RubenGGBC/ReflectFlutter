// ============================================================================
// daily_roadmap_model.dart - MODELO PRINCIPAL PARA EL ROADMAP DIARIO
// ============================================================================

import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'roadmap_activity_model.dart';

part 'daily_roadmap_model.g.dart';

@JsonSerializable()
class DailyRoadmapModel {
  final int? id;
  final int userId;
  final DateTime targetDate;
  final List<RoadmapActivityModel> activities;
  final String? dailyGoal;
  final String? morningNotes;
  final String? eveningReflection;
  final RoadmapStatus status;
  final double? completionPercentage;
  final ActivityMood? overallMood;
  final int? totalActivities;
  final int? completedActivities;
  final int? totalEstimatedMinutes;
  final int? actualSpentMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyRoadmapModel({
    this.id,
    required this.userId,
    required this.targetDate,
    this.activities = const [],
    this.dailyGoal,
    this.morningNotes,
    this.eveningReflection,
    this.status = RoadmapStatus.planned,
    this.completionPercentage,
    this.overallMood,
    this.totalActivities,
    this.completedActivities,
    this.totalEstimatedMinutes,
    this.actualSpentMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyRoadmapModel.create({
    required int userId,
    required DateTime targetDate,
    String? dailyGoal,
    String? morningNotes,
  }) {
    final now = DateTime.now();
    return DailyRoadmapModel(
      userId: userId,
      targetDate: DateTime(targetDate.year, targetDate.month, targetDate.day),
      dailyGoal: dailyGoal,
      morningNotes: morningNotes,
      createdAt: now,
      updatedAt: now,
    );
  }

  // JSON serialization
  factory DailyRoadmapModel.fromJson(Map<String, dynamic> json) =>
      _$DailyRoadmapModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRoadmapModelToJson(this);

  // Database conversion
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'target_date': targetDate.toIso8601String(),
      'activities_json': jsonEncode(activities.map((a) => a.toJson()).toList()),
      'daily_goal': dailyGoal,
      'morning_notes': morningNotes,
      'evening_reflection': eveningReflection,
      'status': status.name,
      'completion_percentage': completionPercentage,
      'overall_mood': overallMood?.name,
      'total_activities': totalActivities ?? activities.length,
      'completed_activities': completedActivities ?? activities.where((a) => a.isCompleted).length,
      'total_estimated_minutes': totalEstimatedMinutes ?? _calculateTotalEstimatedMinutes(),
      'actual_spent_minutes': actualSpentMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DailyRoadmapModel.fromDatabase(Map<String, dynamic> map) {
    final activitiesJson = map['activities_json'] as String?;
    List<RoadmapActivityModel> activities = [];
    
    if (activitiesJson != null && activitiesJson.isNotEmpty) {
      final activitiesList = jsonDecode(activitiesJson) as List;
      activities = activitiesList
          .map((a) => RoadmapActivityModel.fromJson(a as Map<String, dynamic>))
          .toList();
    }

    return DailyRoadmapModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      targetDate: DateTime.parse(map['target_date'] as String),
      activities: activities,
      dailyGoal: map['daily_goal'] as String?,
      morningNotes: map['morning_notes'] as String?,
      eveningReflection: map['evening_reflection'] as String?,
      status: RoadmapStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => RoadmapStatus.planned,
      ),
      completionPercentage: map['completion_percentage'] as double?,
      overallMood: map['overall_mood'] != null
          ? ActivityMood.values.firstWhere(
              (m) => m.name == map['overall_mood'],
              orElse: () => ActivityMood.neutral,
            )
          : null,
      totalActivities: map['total_activities'] as int?,
      completedActivities: map['completed_activities'] as int?,
      totalEstimatedMinutes: map['total_estimated_minutes'] as int?,
      actualSpentMinutes: map['actual_spent_minutes'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Convenience methods
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return today == target;
  }

  bool get isFuture {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.isAfter(today);
  }

  bool get isPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.isBefore(today);
  }

  double get calculatedCompletionPercentage {
    if (activities.isEmpty) return 0.0;
    final completed = activities.where((a) => a.isCompleted).length;
    return (completed / activities.length) * 100;
  }

  int get calculatedTotalActivities => activities.length;

  int get calculatedCompletedActivities => 
      activities.where((a) => a.isCompleted).length;

  int _calculateTotalEstimatedMinutes() {
    return activities
        .map((a) => a.estimatedDuration ?? 60)
        .fold(0, (sum, duration) => sum + duration);
  }

  List<RoadmapActivityModel> get activitiesByTime {
    final sorted = List<RoadmapActivityModel>.from(activities);
    sorted.sort((a, b) {
      final timeA = a.hour * 60 + a.minute;
      final timeB = b.hour * 60 + b.minute;
      return timeA.compareTo(timeB);
    });
    return sorted;
  }

  RoadmapActivityModel? getActivityAtTime(int hour, int minute) {
    return activities
        .where((a) => a.hour == hour && a.minute == minute)
        .firstOrNull;
  }

  List<RoadmapActivityModel> getActivitiesInHour(int hour) {
    return activities.where((a) => a.hour == hour).toList();
  }

  // Statistics
  Map<ActivityPriority, int> get priorityDistribution {
    final Map<ActivityPriority, int> distribution = {};
    for (final priority in ActivityPriority.values) {
      distribution[priority] = 0;
    }
    
    for (final activity in activities) {
      distribution[activity.priority] = 
          (distribution[activity.priority] ?? 0) + 1;
    }
    
    return distribution;
  }

  Map<String, int> get categoryDistribution {
    final Map<String, int> distribution = {};
    
    for (final activity in activities) {
      final category = activity.category ?? 'Sin categoría';
      distribution[category] = (distribution[category] ?? 0) + 1;
    }
    
    return distribution;
  }

  // Copy methods
  DailyRoadmapModel copyWith({
    int? id,
    int? userId,
    DateTime? targetDate,
    List<RoadmapActivityModel>? activities,
    String? dailyGoal,
    String? morningNotes,
    String? eveningReflection,
    RoadmapStatus? status,
    double? completionPercentage,
    ActivityMood? overallMood,
    int? totalActivities,
    int? completedActivities,
    int? totalEstimatedMinutes,
    int? actualSpentMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyRoadmapModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetDate: targetDate ?? this.targetDate,
      activities: activities ?? this.activities,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      morningNotes: morningNotes ?? this.morningNotes,
      eveningReflection: eveningReflection ?? this.eveningReflection,
      status: status ?? this.status,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      overallMood: overallMood ?? this.overallMood,
      totalActivities: totalActivities ?? this.totalActivities,
      completedActivities: completedActivities ?? this.completedActivities,
      totalEstimatedMinutes: totalEstimatedMinutes ?? this.totalEstimatedMinutes,
      actualSpentMinutes: actualSpentMinutes ?? this.actualSpentMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  DailyRoadmapModel addActivity(RoadmapActivityModel activity) {
    final newActivities = List<RoadmapActivityModel>.from(activities);
    newActivities.add(activity);
    return copyWith(activities: newActivities);
  }

  DailyRoadmapModel removeActivity(String activityId) {
    final newActivities = activities
        .where((a) => a.id != activityId)
        .toList();
    return copyWith(activities: newActivities);
  }

  DailyRoadmapModel updateActivity(RoadmapActivityModel updatedActivity) {
    final newActivities = activities
        .map((a) => a.id == updatedActivity.id ? updatedActivity : a)
        .toList();
    return copyWith(activities: newActivities);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRoadmapModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          targetDate == other.targetDate;

  @override
  int get hashCode => Object.hash(id, userId, targetDate);

  @override
  String toString() => 
      'DailyRoadmapModel(id: $id, userId: $userId, targetDate: $targetDate, activities: ${activities.length})';
}

// ============================================================================
// ENUMS
// ============================================================================

@JsonEnum()
enum RoadmapStatus {
  @JsonValue('planned')
  planned,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('partially_completed')
  partiallyCompleted,
  @JsonValue('cancelled')
  cancelled,
}

// ============================================================================
// EXTENSIONS
// ============================================================================

extension RoadmapStatusExtension on RoadmapStatus {
  String get displayName {
    switch (this) {
      case RoadmapStatus.planned:
        return 'Planificado';
      case RoadmapStatus.inProgress:
        return 'En progreso';
      case RoadmapStatus.completed:
        return 'Completado';
      case RoadmapStatus.partiallyCompleted:
        return 'Parcialmente completado';
      case RoadmapStatus.cancelled:
        return 'Cancelado';
    }
  }

  String get emoji {
    switch (this) {
      case RoadmapStatus.planned:
        return '📋';
      case RoadmapStatus.inProgress:
        return '⏳';
      case RoadmapStatus.completed:
        return '✅';
      case RoadmapStatus.partiallyCompleted:
        return '⚡';
      case RoadmapStatus.cancelled:
        return '❌';
    }
  }
}

// ============================================================================
// EXTENSION PARA NULL SAFETY
// ============================================================================

extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    return isEmpty ? null : first;
  }
}