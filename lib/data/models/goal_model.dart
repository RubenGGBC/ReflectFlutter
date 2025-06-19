// lib/data/models/goal_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'goal_model.g.dart';

enum GoalStatus { active, completed, archived }
enum GoalType { consistency, mood, positiveMoments, stressReduction }

@JsonSerializable()
class GoalModel {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final GoalType type;
  final GoalStatus status;
  final double targetValue;
  final double currentValue;
  final DateTime createdAt;
  final DateTime? completedAt;

  const GoalModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    this.status = GoalStatus.active,
    required this.targetValue,
    this.currentValue = 0.0,
    required this.createdAt,
    this.completedAt,
  });

  // Getters para facilitar el uso
  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);
  bool get isCompleted => status == GoalStatus.completed;

  factory GoalModel.fromJson(Map<String, dynamic> json) => _$GoalModelFromJson(json);
  Map<String, dynamic> toJson() => _$GoalModelToJson(this);

  factory GoalModel.fromDatabase(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      type: GoalType.values.firstWhere((e) => e.toString() == map['type']),
      status: GoalStatus.values.firstWhere((e) => e.toString() == map['status']),
      targetValue: map['target_value'] as double,
      currentValue: map['current_value'] as double,
      createdAt: DateTime.parse(map['created_at'] as String),
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'type': type.toString(),
      'status': status.toString(),
      'target_value': targetValue,
      'current_value': currentValue,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  GoalModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    GoalType? type,
    GoalStatus? status,
    double? targetValue,
    double? currentValue,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}