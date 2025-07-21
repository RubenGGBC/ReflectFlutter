// lib/data/models/daily_activity_model.dart
// ============================================================================
// DAILY ACTIVITY MODEL FOR TRACKING COMPLETION STATUS
// ============================================================================

import 'package:json_annotation/json_annotation.dart';

part 'daily_activity_model.g.dart';

@JsonSerializable()
class DailyActivity {
  final String id;
  final String title;
  final String description;
  final String category;
  final String emoji;
  final int estimatedMinutes;
  final DateTime createdAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? completionNotes;
  final int? rating; // 1-5 rating after completion
  final List<String> tags;

  const DailyActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.emoji,
    required this.estimatedMinutes,
    required this.createdAt,
    this.isCompleted = false,
    this.completedAt,
    this.completionNotes,
    this.rating,
    this.tags = const [],
  });

  factory DailyActivity.fromJson(Map<String, dynamic> json) => _$DailyActivityFromJson(json);
  Map<String, dynamic> toJson() => _$DailyActivityToJson(this);

  // Database methods
  factory DailyActivity.fromDatabase(Map<String, dynamic> map) {
    return DailyActivity(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      emoji: map['emoji'] as String,
      estimatedMinutes: map['estimated_minutes'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      isCompleted: (map['is_completed'] as int) == 1,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at'] as String) : null,
      completionNotes: map['completion_notes'] as String?,
      rating: map['rating'] as int?,
      tags: (map['tags'] as String?)?.split(',') ?? [],
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'emoji': emoji,
      'estimated_minutes': estimatedMinutes,
      'created_at': createdAt.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'completion_notes': completionNotes,
      'rating': rating,
      'tags': tags.join(','),
    };
  }

  DailyActivity copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? emoji,
    int? estimatedMinutes,
    DateTime? createdAt,
    bool? isCompleted,
    DateTime? completedAt,
    String? completionNotes,
    int? rating,
    List<String>? tags,
  }) {
    return DailyActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      completionNotes: completionNotes ?? this.completionNotes,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
    );
  }

  // Helper methods
  String get durationText {
    if (estimatedMinutes < 60) {
      return '$estimatedMinutes min';
    } else {
      final hours = estimatedMinutes ~/ 60;
      final minutes = estimatedMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
  }

  String get statusText {
    if (isCompleted) {
      return 'Completada';
    }
    return 'Pendiente';
  }

  static List<DailyActivity> getDefaultActivities() {
    final now = DateTime.now();
    return [
      DailyActivity(
        id: 'exercise',
        title: 'Ejercicio físico',
        description: 'Realiza actividad física para mantenerte saludable',
        category: 'Salud',
        emoji: '🏃‍♂️',
        estimatedMinutes: 30,
        createdAt: now,
      ),
      DailyActivity(
        id: 'meditation',
        title: 'Meditación',
        description: 'Practica mindfulness y meditación',
        category: 'Bienestar',
        emoji: '🧘‍♀️',
        estimatedMinutes: 15,
        createdAt: now,
      ),
      DailyActivity(
        id: 'reading',
        title: 'Lectura',
        description: 'Lee un libro o artículo interesante',
        category: 'Desarrollo',
        emoji: '📚',
        estimatedMinutes: 45,
        createdAt: now,
      ),
      DailyActivity(
        id: 'family_time',
        title: 'Tiempo con familia',
        description: 'Disfruta tiempo de calidad con tus seres queridos',
        category: 'Social',
        emoji: '👨‍👩‍👧‍👦',
        estimatedMinutes: 60,
        createdAt: now,
      ),
      DailyActivity(
        id: 'productive_work',
        title: 'Trabajo productivo',
        description: 'Completa tareas importantes de trabajo',
        category: 'Productividad',
        emoji: '💼',
        estimatedMinutes: 120,
        createdAt: now,
      ),
      DailyActivity(
        id: 'cooking',
        title: 'Cocinar',
        description: 'Prepara una comida saludable',
        category: 'Salud',
        emoji: '🍳',
        estimatedMinutes: 30,
        createdAt: now,
      ),
      DailyActivity(
        id: 'outdoor_walk',
        title: 'Paseo al aire libre',
        description: 'Camina al aire libre y conecta con la naturaleza',
        category: 'Salud',
        emoji: '🚶‍♂️',
        estimatedMinutes: 20,
        createdAt: now,
      ),
      DailyActivity(
        id: 'music',
        title: 'Escuchar música',
        description: 'Disfruta de tu música favorita',
        category: 'Entretenimiento',
        emoji: '🎵',
        estimatedMinutes: 30,
        createdAt: now,
      ),
      DailyActivity(
        id: 'study',
        title: 'Estudiar',
        description: 'Dedica tiempo al aprendizaje o estudio',
        category: 'Desarrollo',
        emoji: '📖',
        estimatedMinutes: 60,
        createdAt: now,
      ),
      DailyActivity(
        id: 'leisure',
        title: 'Tiempo de ocio',
        description: 'Relájate y disfruta tu tiempo libre',
        category: 'Entretenimiento',
        emoji: '🎮',
        estimatedMinutes: 45,
        createdAt: now,
      ),
      DailyActivity(
        id: 'socialize',
        title: 'Socializar',
        description: 'Conecta con amigos o conocidos',
        category: 'Social',
        emoji: '👥',
        estimatedMinutes: 90,
        createdAt: now,
      ),
      DailyActivity(
        id: 'creative_hobby',
        title: 'Hobby creativo',
        description: 'Dedica tiempo a una actividad creativa',
        category: 'Creatividad',
        emoji: '🎨',
        estimatedMinutes: 60,
        createdAt: now,
      ),
    ];
  }

  @override
  String toString() {
    return 'DailyActivity(id: $id, title: $title, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyActivity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}