// lib/data/models/recommended_activity_model.dart
// ============================================================================
// MODELO DE ACTIVIDAD RECOMENDADA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recommended_activity_model.g.dart';

@JsonSerializable()
class RecommendedActivity {
  final String id;
  final String title;
  final String description;
  final String category;
  final ActivityType type;
  final int durationMinutes;
  final int difficultyLevel; // 1-5 scale
  final List<String> benefits;
  final List<String> instructions;
  final Map<String, dynamic> resources;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final IconData iconData;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<Color> gradientColors;
  final bool requiresTimer;
  final bool requiresEquipment;
  final List<String> equipment;
  final String motivationalQuote;
  final DateTime? lastRecommended;
  final int timesCompleted;
  final double averageRating;

  RecommendedActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.durationMinutes,
    required this.difficultyLevel,
    required this.benefits,
    required this.instructions,
    required this.resources,
    this.requiresTimer = false,
    this.requiresEquipment = false,
    this.equipment = const [],
    this.motivationalQuote = '',
    this.lastRecommended,
    this.timesCompleted = 0,
    this.averageRating = 0.0,
  }) : iconData = type.icon,
       gradientColors = type.gradientColors;

  factory RecommendedActivity.fromJson(Map<String, dynamic> json) => _$RecommendedActivityFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendedActivityToJson(this);

  RecommendedActivity copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    ActivityType? type,
    int? durationMinutes,
    int? difficultyLevel,
    List<String>? benefits,
    List<String>? instructions,
    Map<String, dynamic>? resources,
    bool? requiresTimer,
    bool? requiresEquipment,
    List<String>? equipment,
    String? motivationalQuote,
    DateTime? lastRecommended,
    int? timesCompleted,
    double? averageRating,
  }) {
    return RecommendedActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      benefits: benefits ?? this.benefits,
      instructions: instructions ?? this.instructions,
      resources: resources ?? this.resources,
      requiresTimer: requiresTimer ?? this.requiresTimer,
      requiresEquipment: requiresEquipment ?? this.requiresEquipment,
      equipment: equipment ?? this.equipment,
      motivationalQuote: motivationalQuote ?? this.motivationalQuote,
      lastRecommended: lastRecommended ?? this.lastRecommended,
      timesCompleted: timesCompleted ?? this.timesCompleted,
      averageRating: averageRating ?? this.averageRating,
    );
  }

  // Getters
  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes min';
    } else {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
  }

  String get difficultyText {
    switch (difficultyLevel) {
      case 1:
        return 'Muy Fácil';
      case 2:
        return 'Fácil';
      case 3:
        return 'Moderado';
      case 4:
        return 'Difícil';
      case 5:
        return 'Muy Difícil';
      default:
        return 'Moderado';
    }
  }

  Color get difficultyColor {
    switch (difficultyLevel) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  bool get isRecommendedToday {
    if (lastRecommended == null) return false;
    final now = DateTime.now();
    final lastRec = lastRecommended!;
    return now.year == lastRec.year &&
           now.month == lastRec.month &&
           now.day == lastRec.day;
  }

  String get primaryBenefit {
    return benefits.isNotEmpty ? benefits.first : 'Mejora tu bienestar';
  }

  @override
  String toString() {
    return 'RecommendedActivity(id: $id, title: $title, category: $category, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecommendedActivity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum ActivityType {
  mindfulness,
  exercise,
  creativity,
  social,
  learning,
  selfCare,
  nutrition,
  breathing,
  meditation,
  movement,
  relaxation,
  productivity,
  gratitude,
  reflection,
  challenge,
}

extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.mindfulness:
        return 'Mindfulness';
      case ActivityType.exercise:
        return 'Ejercicio';
      case ActivityType.creativity:
        return 'Creatividad';
      case ActivityType.social:
        return 'Social';
      case ActivityType.learning:
        return 'Aprendizaje';
      case ActivityType.selfCare:
        return 'Autocuidado';
      case ActivityType.nutrition:
        return 'Nutrición';
      case ActivityType.breathing:
        return 'Respiración';
      case ActivityType.meditation:
        return 'Meditación';
      case ActivityType.movement:
        return 'Movimiento';
      case ActivityType.relaxation:
        return 'Relajación';
      case ActivityType.productivity:
        return 'Productividad';
      case ActivityType.gratitude:
        return 'Gratitud';
      case ActivityType.reflection:
        return 'Reflexión';
      case ActivityType.challenge:
        return 'Desafío';
    }
  }

  IconData get icon {
    switch (this) {
      case ActivityType.mindfulness:
        return Icons.self_improvement;
      case ActivityType.exercise:
        return Icons.fitness_center;
      case ActivityType.creativity:
        return Icons.palette;
      case ActivityType.social:
        return Icons.people;
      case ActivityType.learning:
        return Icons.school;
      case ActivityType.selfCare:
        return Icons.spa;
      case ActivityType.nutrition:
        return Icons.restaurant;
      case ActivityType.breathing:
        return Icons.air;
      case ActivityType.meditation:
        return Icons.self_improvement;
      case ActivityType.movement:
        return Icons.directions_run;
      case ActivityType.relaxation:
        return Icons.bathtub;
      case ActivityType.productivity:
        return Icons.check_circle;
      case ActivityType.gratitude:
        return Icons.favorite;
      case ActivityType.reflection:
        return Icons.psychology;
      case ActivityType.challenge:
        return Icons.emoji_events;
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case ActivityType.mindfulness:
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
      case ActivityType.exercise:
        return [const Color(0xFF11998e), const Color(0xFF38ef7d)];
      case ActivityType.creativity:
        return [const Color(0xFFf093fb), const Color(0xFFf5576c)];
      case ActivityType.social:
        return [const Color(0xFF4facfe), const Color(0xFF00f2fe)];
      case ActivityType.learning:
        return [const Color(0xFF43e97b), const Color(0xFF38f9d7)];
      case ActivityType.selfCare:
        return [const Color(0xFFffecd2), const Color(0xFFfcb69f)];
      case ActivityType.nutrition:
        return [const Color(0xFFa8edea), const Color(0xFFfed6e3)];
      case ActivityType.breathing:
        return [const Color(0xFFd299c2), const Color(0xFFfef9d7)];
      case ActivityType.meditation:
        return [const Color(0xFF89f7fe), const Color(0xFF66a6ff)];
      case ActivityType.movement:
        return [const Color(0xFFfdbb2d), const Color(0xFF22c1c3)];
      case ActivityType.relaxation:
        return [const Color(0xFF9890e3), const Color(0xFFb1f4cf)];
      case ActivityType.productivity:
        return [const Color(0xFFfa709a), const Color(0xFFfee140)];
      case ActivityType.gratitude:
        return [const Color(0xFFf83600), const Color(0xFFf9d423)];
      case ActivityType.reflection:
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
      case ActivityType.challenge:
        return [const Color(0xFFf12711), const Color(0xFFf5af19)];
    }
  }
}

// User completion model
@JsonSerializable()
class ActivityCompletion {
  final String activityId;
  final DateTime completedAt;
  final int durationMinutes;
  final double rating;
  final String? notes;
  final Map<String, dynamic>? metrics;

  const ActivityCompletion({
    required this.activityId,
    required this.completedAt,
    required this.durationMinutes,
    required this.rating,
    this.notes,
    this.metrics,
  });

  factory ActivityCompletion.fromJson(Map<String, dynamic> json) => _$ActivityCompletionFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityCompletionToJson(this);
}