// ============================================================================
// data/models/interactive_moment_model.dart - VERSIÓN CORREGIDA Y ROBUSTA
// ============================================================================

import 'tag_model.dart';

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

  factory InteractiveMomentModel.fromJson(Map<String, dynamic> json) {
    return InteractiveMomentModel(
      id: json['id'] as String,
      emoji: json['emoji'] as String,
      text: json['text'] as String,
      type: json['type'] as String,
      intensity: (json['intensity'] as int?) ?? 5, // FIX: Safe cast
      category: json['category'] as String,
      timeStr: json['timeStr'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      entryDate: DateTime.parse(json['entryDate'] as String),
    );
  }

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

  factory InteractiveMomentModel.fromDatabase(Map<String, dynamic> map) {
    return InteractiveMomentModel(
      id: map['moment_id'] as String,
      emoji: map['emoji'] as String,
      text: map['text'] as String,
      type: map['type'] as String, // Changed from moment_type
      // FIX: Safely cast 'intensity', providing a default value of 5 if it's null.
      intensity: (map['intensity'] as int?) ?? 5,
      category: map['category'] as String,
      timeStr: map['time_str'] as String,
      timestamp: DateTime.parse(map['created_at'] as String),
      entryDate: DateTime.parse(map['entry_date'] as String),
    );
  }
// ...

  Map<String, dynamic> toDatabase() {
    return {
      'moment_id': id,
      'emoji': emoji,
      'text': text,
      'type': type, // Changed from moment_type
      'intensity': intensity,
      'category': category,
      'time_str': timeStr,
      'timestamp_data': timestamp.toIso8601String(),
      'created_at': timestamp.toIso8601String(),
      'entry_date': entryDate.toIso8601String().split('T')[0],
    };
  }
// ...

  TagModel toTag() {
    final contextParts = <String>[];
    contextParts.add('Registrado a las $timeStr');
    if (intensity > 7) contextParts.add('intensidad alta ($intensity/10)');
    else if (intensity < 4) contextParts.add('intensidad baja ($intensity/10)');
    else contextParts.add('intensidad media ($intensity/10)');
    contextParts.add('categoría $category');
    final dayOfWeek = _getDayOfWeekName(entryDate.weekday);
    contextParts.add('$dayOfWeek ${entryDate.day}/${entryDate.month}');
    return TagModel(name: text, context: contextParts.join(', '), emoji: emoji, type: type);
  }

  TagModel toSimpleTag() {
    return TagModel(name: text, context: 'Momento $category a las $timeStr', emoji: emoji, type: type);
  }

  String getTimeInfo() {
    final hour = int.parse(timeStr.split(':')[0]);
    if (hour >= 5 && hour < 12) return '🌅 Mañana ($timeStr)';
    if (hour >= 12 && hour < 17) return '☀️ Tarde ($timeStr)';
    if (hour >= 17 && hour < 21) return '🌆 Atardecer ($timeStr)';
    return '🌙 Noche ($timeStr)';
  }

  String getIntensityDescription() {
    if (intensity >= 9) return 'Muy intenso';
    if (intensity >= 7) return 'Intenso';
    if (intensity >= 5) return 'Moderado';
    if (intensity >= 3) return 'Leve';
    return 'Muy leve';
  }

  String getColorHex() {
    if (type == 'positive') {
      if (intensity >= 8) return '#10B981';
      if (intensity >= 6) return '#34D399';
      return '#6EE7B7';
    } else {
      if (intensity >= 8) return '#EF4444';
      if (intensity >= 6) return '#F87171';
      return '#FCA5A5';
    }
  }

  InteractiveMomentModel copyWith({
    String? id, String? emoji, String? text, String? type, int? intensity,
    String? category, String? timeStr, DateTime? timestamp, DateTime? entryDate,
  }) {
    return InteractiveMomentModel(
      id: id ?? this.id, emoji: emoji ?? this.emoji, text: text ?? this.text,
      type: type ?? this.type, intensity: intensity ?? this.intensity, category: category ?? this.category,
      timeStr: timeStr ?? this.timeStr, timestamp: timestamp ?? this.timestamp, entryDate: entryDate ?? this.entryDate,
    );
  }

  int compareTo(InteractiveMomentModel other) => timestamp.compareTo(other.timestamp);

  bool isSameDay(DateTime date) => entryDate.year == date.year && entryDate.month == date.month && entryDate.day == date.day;

  bool isSameHour(String hourStr) => timeStr.startsWith(hourStr);

  @override
  String toString() => 'InteractiveMoment{$emoji $text at $timeStr, intensity: $intensity, type: $type}';

  String _getDayOfWeekName(int weekday) => const ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'][weekday - 1];

  static Map<String, List<InteractiveMomentModel>> groupByHour(List<InteractiveMomentModel> moments) {
    final Map<String, List<InteractiveMomentModel>> grouped = {};
    for (final moment in moments) {
      final hour = '${moment.timeStr.split(':')[0]}:00';
      grouped.putIfAbsent(hour, () => []).add(moment);
    }
    return grouped;
  }

  static Map<String, List<InteractiveMomentModel>> groupByCategory(List<InteractiveMomentModel> moments) {
    final Map<String, List<InteractiveMomentModel>> grouped = {};
    for (final moment in moments) {
      grouped.putIfAbsent(moment.category, () => []).add(moment);
    }
    return grouped;
  }

  static List<InteractiveMomentModel> filterByType(List<InteractiveMomentModel> moments, String type) {
    return moments.where((m) => m.type == type).toList();
  }

  static double calculateAverageIntensity(List<InteractiveMomentModel> moments) {
    if (moments.isEmpty) return 0.0;
    return moments.fold<int>(0, (sum, m) => sum + m.intensity) / moments.length;
  }

  static InteractiveMomentModel? getMostIntense(List<InteractiveMomentModel> moments) {
    if (moments.isEmpty) return null;
    return moments.reduce((c, n) => c.intensity > n.intensity ? c : n);
  }
}
