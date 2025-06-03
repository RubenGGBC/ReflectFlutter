// ============================================================================
// data/models/interactive_moment_model.dart - VERSIÓN CORREGIDA
// ============================================================================

import 'tag_model.dart';

/// Modelo para momentos interactivos sin JSON serialization automática
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

  /// Factory constructor para crear un momento nuevo
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

  /// Crear desde JSON manualmente (sin code generation)
  factory InteractiveMomentModel.fromJson(Map<String, dynamic> json) {
    return InteractiveMomentModel(
      id: json['id'] as String,
      emoji: json['emoji'] as String,
      text: json['text'] as String,
      type: json['type'] as String,
      intensity: json['intensity'] as int,
      category: json['category'] as String,
      timeStr: json['timeStr'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      entryDate: DateTime.parse(json['entryDate'] as String),
    );
  }

  /// Convertir a JSON manualmente
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emoji': emoji,
      'text': text,
      'type': type,
      'intensity': intensity,
      'category': category,
      'timeStr': timeStr,
      'timestamp': timestamp.toIso8601String(),
      'entryDate': entryDate.toIso8601String(),
    };
  }

  /// Crear desde base de datos
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

  /// Convertir para base de datos
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

  /// Convertir a TagModel para compatibilidad
  TagModel toTag() {
    return TagModel(
      name: text,
      context: 'Momento $category de intensidad $intensity a las $timeStr',
      emoji: emoji,
      type: type,
    );
  }

  /// Crear copia con modificaciones
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