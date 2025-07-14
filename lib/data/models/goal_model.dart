// lib/data/models/goal_model.dart
// ============================================================================
// VERSIÓN COMPLETA Y CORREGIDA - CON TODOS LOS MÉTODOS ORIGINALES
// ============================================================================

enum GoalStatus {
  active,
  completed,
  archived
}

enum GoalType {
  consistency,      // Consistencia en hábitos diarios
  mood,            // Mejora de estado de ánimo
  positiveMoments, // Incrementar momentos positivos
  stressReduction  // Reducción de estrés
}

class GoalModel {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final GoalType type;
  final GoalStatus status;
  final int targetValue;
  final int currentValue;
  final String? progressNotes;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? lastUpdated;

  const GoalModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    this.status = GoalStatus.active,
    required this.targetValue,
    this.currentValue = 0,
    this.progressNotes,
    required this.createdAt,
    this.completedAt,
    this.lastUpdated,
  });

  // ============================================================================
  // GETTERS CALCULADOS (SIN CAMBIOS, TODOS TUS MÉTODOS CONSERVADOS)
  // ============================================================================

  double get progress => targetValue > 0
      ? (currentValue / targetValue).clamp(0.0, 1.0)
      : 0.0;
  int get progressPercentage => (progress * 100).round();
  bool get isCompleted => status == GoalStatus.completed;
  bool get isActive => status == GoalStatus.active;
  bool get isArchived => status == GoalStatus.archived;
  int get daysSinceCreated => DateTime.now().difference(createdAt).inDays;
  int? get daysSinceCompleted => completedAt != null
      ? DateTime.now().difference(completedAt!).inDays
      : null;
  int get remainingValue => (targetValue - currentValue).clamp(0, targetValue);
  bool get isNearCompletion => progress >= 0.8;
  bool get hasNotes => progressNotes != null && progressNotes!.isNotEmpty;

  String get progressDescription {
    if (isCompleted) return 'Completed! 🎉';
    if (progress >= 0.8) return 'Almost there! 💪';
    if (progress >= 0.5) return 'Great progress! 📈';
    if (progress >= 0.2) return 'Getting started 🌱';
    return 'Just beginning 🚀';
  }

  String get typeColorHex {
    switch (type) {
      case GoalType.consistency: return '4ECDC4';
      case GoalType.mood: return 'FFD700';
      case GoalType.positiveMoments: return '45B7D1';
      case GoalType.stressReduction: return '96CEB4';
    }
  }

  String get typeIcon {
    switch (type) {
      case GoalType.consistency: return 'timeline';
      case GoalType.mood: return 'sentiment_satisfied';
      case GoalType.positiveMoments: return 'star';
      case GoalType.stressReduction: return 'spa';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case GoalType.consistency: return 'Consistency';
      case GoalType.mood: return 'Mood Improvement';
      case GoalType.positiveMoments: return 'Positive Moments';
      case GoalType.stressReduction: return 'Stress Reduction';
    }
  }

  String get suggestedUnit {
    switch (type) {
      case GoalType.consistency: return 'days';
      case GoalType.mood: return 'times';
      case GoalType.positiveMoments: return 'moments';
      case GoalType.stressReduction: return 'times';
    }
  }

  // ============================================================================
  // MÉTODOS DE SERIALIZACIÓN (AQUÍ ESTÁ LA CORRECCIÓN PRINCIPAL)
  // ============================================================================

  /// ✅ **CORREGIDO: Crea un GoalModel desde un mapa de la BD, manejando cualquier tipo de dato.**
  factory GoalModel.fromDatabase(Map<String, dynamic> map) {
    // Helper para parsear GoalType de forma segura desde un valor dinámico (int o string)
    GoalType parseGoalType(dynamic value) {
      if (value is String) return GoalType.values.firstWhere((e) => e.name.toLowerCase() == value.toLowerCase(), orElse: () => GoalType.consistency);
      if (value is int && value >= 0 && value < GoalType.values.length) return GoalType.values[value];
      return GoalType.consistency;
    }

    // Helper para parsear GoalStatus de forma segura desde un valor dinámico (int o string)
    GoalStatus parseGoalStatus(dynamic value) {
      if (value is String) return GoalStatus.values.firstWhere((e) => e.name.toLowerCase() == value.toLowerCase(), orElse: () => GoalStatus.active);
      if (value is int && value >= 0 && value < GoalStatus.values.length) return GoalStatus.values[value];
      return GoalStatus.active;
    }

    // Helper para parsear DateTime de forma segura desde un valor dinámico (int o string)
    DateTime parseDateTime(dynamic value) {
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value * 1000); // Asume timestamp en segundos
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    DateTime? parseOptionalDateTime(dynamic value) {
      if (value == null) return null;
      return parseDateTime(value);
    }

    return GoalModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String? ?? 'No Title',
      description: map['description'] as String? ?? '',
      type: parseGoalType(map['type']),
      status: parseGoalStatus(map['status']),
      targetValue: (map['target_value'] as num? ?? 0).toInt(),
      currentValue: (map['current_value'] as num? ?? 0).toInt(),
      progressNotes: map['progress_notes'] as String?,
      createdAt: parseDateTime(map['created_at']),
      completedAt: parseOptionalDateTime(map['completed_at']),
      lastUpdated: parseOptionalDateTime(map['last_updated']),
    );
  }

  /// ✅ **CORREGIDO: Convierte a formato de BD con los tipos de dato correctos.**
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'target_value': targetValue,
      'current_value': currentValue,
      'progress_notes': progressNotes,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'completed_at': completedAt?.millisecondsSinceEpoch != null 
          ? completedAt!.millisecondsSinceEpoch ~/ 1000 
          : null,
      'last_updated': lastUpdated?.millisecondsSinceEpoch != null 
          ? lastUpdated!.millisecondsSinceEpoch ~/ 1000 
          : null,
    };
  }

  Map<String, dynamic> toJson() {
    return toDatabase(); // Reutiliza la lógica de toDatabase que ya es compatible con JSON
  }

  // ============================================================================
  // MÉTODOS DE UTILIDAD (SIN CAMBIOS, TODOS TUS MÉTODOS CONSERVADOS)
  // ============================================================================

  GoalModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    GoalType? type,
    GoalStatus? status,
    int? targetValue,
    int? currentValue,
    String? progressNotes,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? lastUpdated,
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
      progressNotes: progressNotes ?? this.progressNotes,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  GoalModel updateProgress(int newValue, {String? notes}) {
    return copyWith(
      currentValue: newValue,
      progressNotes: notes,
      lastUpdated: DateTime.now(),
    );
  }

  GoalModel addProgressNote(String note) {
    final existingNotes = progressNotes ?? '';
    final timestamp = DateTime.now().toString().substring(0, 16);
    final newNote = '$timestamp: $note';
    final updatedNotes = existingNotes.isEmpty 
        ? newNote 
        : '$existingNotes\n$newNote';
    
    return copyWith(
      progressNotes: updatedNotes,
      lastUpdated: DateTime.now(),
    );
  }

  GoalModel markAsCompleted({String? completionNote}) {
    return copyWith(
      status: GoalStatus.completed,
      completedAt: DateTime.now(),
      currentValue: targetValue,
      progressNotes: completionNote != null 
          ? addProgressNote('✅ Completed: $completionNote').progressNotes
          : progressNotes,
      lastUpdated: DateTime.now(),
    );
  }

  GoalModel reactivate() {
    return copyWith(status: GoalStatus.active, completedAt: null);
  }

  GoalModel archive() {
    return copyWith(status: GoalStatus.archived);
  }

  // ============================================================================
  // MÉTODOS ESTÁTICOS DE UTILIDAD (SIN CAMBIOS, TODOS TUS MÉTODOS CONSERVADOS)
  // Nota: Los métodos _parse ya no son necesarios porque la lógica está en fromDatabase.
  // ============================================================================

  static GoalModel createConsistencyGoal({
    required int userId,
    required String title,
    required String description,
    required int targetDays,
  }) {
    return GoalModel(
      userId: userId,
      title: title,
      description: description,
      type: GoalType.consistency,
      targetValue: targetDays,
      createdAt: DateTime.now(),
    );
  }

  static GoalModel createMoodGoal({
    required int userId,
    required String title,
    required String description,
    required int targetTimes,
  }) {
    return GoalModel(
      userId: userId,
      title: title,
      description: description,
      type: GoalType.mood,
      targetValue: targetTimes,
      createdAt: DateTime.now(),
    );
  }

  static GoalModel createPositiveMomentsGoal({
    required int userId,
    required String title,
    required String description,
    required int targetMoments,
  }) {
    return GoalModel(
      userId: userId,
      title: title,
      description: description,
      type: GoalType.positiveMoments,
      targetValue: targetMoments,
      createdAt: DateTime.now(),
    );
  }

  static GoalModel createStressReductionGoal({
    required int userId,
    required String title,
    required String description,
    required int targetTimes,
  }) {
    return GoalModel(
      userId: userId,
      title: title,
      description: description,
      type: GoalType.stressReduction,
      targetValue: targetTimes,
      createdAt: DateTime.now(),
    );
  }

  // ============================================================================
  // MÉTODOS DE COMPARACIÓN Y ORDENAMIENTO (SIN CAMBIOS)
  // ============================================================================

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is GoalModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'GoalModel{id: $id, title: "$title", type: ${type.name}, status: ${status.name}, progress: $progressPercentage%}';
  }

  static int compareByProgress(GoalModel a, GoalModel b) {
    return b.progress.compareTo(a.progress);
  }

  static int compareByCreatedAt(GoalModel a, GoalModel b) {
    return b.createdAt.compareTo(a.createdAt);
  }

  static int compareByType(GoalModel a, GoalModel b) {
    return a.type.toString().compareTo(b.type.toString());
  }
}

// ============================================================================
// EXTENSIONES ÚTILES PARA LISTAS DE OBJETIVOS (SIN CAMBIOS)
// ============================================================================

extension GoalListExtensions on List<GoalModel> {
  List<GoalModel> get activeGoals => where((goal) => goal.isActive).toList();
  List<GoalModel> get completedGoals => where((goal) => goal.isCompleted).toList();
  List<GoalModel> get archivedGoals => where((goal) => goal.isArchived).toList();
  List<GoalModel> ofType(GoalType type) => where((goal) => goal.type == type).toList();

  double get averageProgress {
    if (isEmpty) return 0.0;
    final totalProgress = fold<double>(0.0, (sum, goal) => sum + goal.progress);
    return totalProgress / length;
  }

  GoalModel? get mostProgressedGoal => isEmpty
      ? null
      : reduce((a, b) => a.progress > b.progress ? a : b);
  GoalModel? get newestGoal => isEmpty
      ? null
      : reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);

  Map<GoalStatus, int> get countByStatus {
    final counts = <GoalStatus, int>{};
    for (final goal in this) {
      counts[goal.status] = (counts[goal.status] ?? 0) + 1;
    }
    return counts;
  }

  Map<GoalType, int> get countByType {
    final counts = <GoalType, int>{};
    for (final goal in this) {
      counts[goal.type] = (counts[goal.type] ?? 0) + 1;
    }
    return counts;
  }
}