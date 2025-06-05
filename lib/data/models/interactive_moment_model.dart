// ============================================================================
// data/models/interactive_moment_model.dart - VERSIÓN MEJORADA
// ============================================================================

import 'tag_model.dart';

/// Modelo para momentos interactivos mejorado
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

  /// Crear desde JSON manualmente
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

  /// Convertir a TagModel mejorado con información temporal y contextual
  TagModel toTag() {
    // Crear contexto más rico con información temporal
    final contextParts = <String>[];

    // Información temporal
    contextParts.add('Registrado a las $timeStr');

    // Información de intensidad
    if (intensity > 7) {
      contextParts.add('intensidad alta ($intensity/10)');
    } else if (intensity < 4) {
      contextParts.add('intensidad baja ($intensity/10)');
    } else {
      contextParts.add('intensidad media ($intensity/10)');
    }

    // Información de categoría
    contextParts.add('categoría $category');

    // Información del día
    final dayOfWeek = _getDayOfWeekName(entryDate.weekday);
    contextParts.add('$dayOfWeek ${entryDate.day}/${entryDate.month}');

    return TagModel(
      name: text,
      context: contextParts.join(', '),
      emoji: emoji,
      type: type,
    );
  }

  /// Convertir a TagModel simple (para compatibilidad)
  TagModel toSimpleTag() {
    return TagModel(
      name: text,
      context: 'Momento $category a las $timeStr',
      emoji: emoji,
      type: type,
    );
  }

  /// Obtener información temporal formateada
  String getTimeInfo() {
    final hour = int.parse(timeStr.split(':')[0]);

    if (hour >= 5 && hour < 12) {
      return '🌅 Mañana ($timeStr)';
    } else if (hour >= 12 && hour < 17) {
      return '☀️ Tarde ($timeStr)';
    } else if (hour >= 17 && hour < 21) {
      return '🌆 Atardecer ($timeStr)';
    } else {
      return '🌙 Noche ($timeStr)';
    }
  }

  /// Obtener descripción de intensidad
  String getIntensityDescription() {
    if (intensity >= 9) return 'Muy intenso';
    if (intensity >= 7) return 'Intenso';
    if (intensity >= 5) return 'Moderado';
    if (intensity >= 3) return 'Leve';
    return 'Muy leve';
  }

  /// Obtener color sugerido basado en tipo e intensidad
  String getColorHex() {
    if (type == 'positive') {
      if (intensity >= 8) return '#10B981'; // Verde brillante
      if (intensity >= 6) return '#34D399'; // Verde medio
      return '#6EE7B7'; // Verde suave
    } else {
      if (intensity >= 8) return '#EF4444'; // Rojo brillante
      if (intensity >= 6) return '#F87171'; // Rojo medio
      return '#FCA5A5'; // Rojo suave
    }
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

  /// Método para comparar momentos por tiempo
  int compareTo(InteractiveMomentModel other) {
    return timestamp.compareTo(other.timestamp);
  }

  /// Verificar si es del mismo día
  bool isSameDay(DateTime date) {
    return entryDate.year == date.year &&
        entryDate.month == date.month &&
        entryDate.day == date.day;
  }

  /// Verificar si es de la misma hora
  bool isSameHour(String hourStr) {
    return timeStr.startsWith(hourStr);
  }

  /// Obtener representación de depuración
  @override
  String toString() {
    return 'InteractiveMoment{$emoji $text at $timeStr, intensity: $intensity, type: $type}';
  }

  /// Helper para obtener nombre del día de la semana
  String _getDayOfWeekName(int weekday) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[weekday - 1];
  }

  /// Método estático para agrupar momentos por hora
  static Map<String, List<InteractiveMomentModel>> groupByHour(List<InteractiveMomentModel> moments) {
    final Map<String, List<InteractiveMomentModel>> grouped = {};

    for (final moment in moments) {
      final hour = moment.timeStr.split(':')[0] + ':00';
      grouped.putIfAbsent(hour, () => []).add(moment);
    }

    return grouped;
  }

  /// Método estático para agrupar momentos por categoría
  static Map<String, List<InteractiveMomentModel>> groupByCategory(List<InteractiveMomentModel> moments) {
    final Map<String, List<InteractiveMomentModel>> grouped = {};

    for (final moment in moments) {
      grouped.putIfAbsent(moment.category, () => []).add(moment);
    }

    return grouped;
  }

  /// Método estático para filtrar por tipo
  static List<InteractiveMomentModel> filterByType(List<InteractiveMomentModel> moments, String type) {
    return moments.where((moment) => moment.type == type).toList();
  }

  /// Método estático para calcular intensidad promedio
  static double calculateAverageIntensity(List<InteractiveMomentModel> moments) {
    if (moments.isEmpty) return 0.0;

    final total = moments.fold<int>(0, (sum, moment) => sum + moment.intensity);
    return total / moments.length;
  }

  /// Método estático para obtener el momento más intenso
  static InteractiveMomentModel? getMostIntense(List<InteractiveMomentModel> moments) {
    if (moments.isEmpty) return null;

    return moments.reduce((current, next) =>
    current.intensity > next.intensity ? current : next);
  }
}