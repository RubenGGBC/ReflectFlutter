// lib/data/models/goal_model.dart
// ============================================================================
// MODELO COMPLETO PARA OBJETIVOS CON ENUMS Y MÉTODOS DE UTILIDAD
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

  // ============================================================================
  // GETTERS CALCULADOS
  // ============================================================================

  /// Progreso del objetivo como porcentaje (0.0 - 1.0)
  double get progress => targetValue > 0
      ? (currentValue / targetValue).clamp(0.0, 1.0)
      : 0.0;

  /// Progreso como porcentaje entero (0-100)
  int get progressPercentage => (progress * 100).round();

  /// Si el objetivo está completado
  bool get isCompleted => status == GoalStatus.completed;

  /// Si el objetivo está activo
  bool get isActive => status == GoalStatus.active;

  /// Si el objetivo está archivado
  bool get isArchived => status == GoalStatus.archived;

  /// Días desde que se creó el objetivo
  int get daysSinceCreated => DateTime.now().difference(createdAt).inDays;

  /// Días desde que se completó (si aplica)
  int? get daysSinceCompleted => completedAt != null
      ? DateTime.now().difference(completedAt!).inDays
      : null;

  /// Valor restante para completar el objetivo
  double get remainingValue => (targetValue - currentValue).clamp(0.0, targetValue);

  /// Si el objetivo está cerca de completarse (>= 80%)
  bool get isNearCompletion => progress >= 0.8;

  /// Estado del progreso como texto descriptivo
  String get progressDescription {
    if (isCompleted) return 'Completed! 🎉';
    if (progress >= 0.8) return 'Almost there! 💪';
    if (progress >= 0.5) return 'Great progress! 📈';
    if (progress >= 0.2) return 'Getting started 🌱';
    return 'Just beginning 🚀';
  }

  /// Color recomendado basado en el tipo de objetivo
  String get typeColorHex {
    switch (type) {
      case GoalType.consistency:
        return '4ECDC4'; // Turquesa
      case GoalType.mood:
        return 'FFD700'; // Dorado
      case GoalType.positiveMoments:
        return '45B7D1'; // Azul
      case GoalType.stressReduction:
        return '96CEB4'; // Verde suave
    }
  }

  /// Icono recomendado basado en el tipo
  String get typeIcon {
    switch (type) {
      case GoalType.consistency:
        return 'timeline';
      case GoalType.mood:
        return 'sentiment_satisfied';
      case GoalType.positiveMoments:
        return 'star';
      case GoalType.stressReduction:
        return 'spa';
    }
  }

  /// Descripción amigable del tipo
  String get typeDisplayName {
    switch (type) {
      case GoalType.consistency:
        return 'Consistency';
      case GoalType.mood:
        return 'Mood Improvement';
      case GoalType.positiveMoments:
        return 'Positive Moments';
      case GoalType.stressReduction:
        return 'Stress Reduction';
    }
  }

  /// Unidad de medida sugerida según el tipo
  String get suggestedUnit {
    switch (type) {
      case GoalType.consistency:
        return 'days';
      case GoalType.mood:
        return 'score';
      case GoalType.positiveMoments:
        return 'moments';
      case GoalType.stressReduction:
        return 'points';
    }
  }

  // ============================================================================
  // MÉTODOS DE SERIALIZACIÓN
  // ============================================================================

  /// Crear desde base de datos
  factory GoalModel.fromDatabase(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      type: _parseGoalType(map['type'] as String),
      status: _parseGoalStatus(map['status'] as String),
      targetValue: (map['target_value'] as num).toDouble(),
      currentValue: (map['current_value'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }

  /// Convertir a formato de base de datos
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

  /// Crear desde JSON
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as int?,
      userId: json['userId'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      type: _parseGoalType(json['type'] as String),
      status: _parseGoalStatus(json['status'] as String),
      targetValue: (json['targetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'type': type.toString(),
      'status': status.toString(),
      'targetValue': targetValue,
      'currentValue': currentValue,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // ============================================================================
  // MÉTODOS DE UTILIDAD
  // ============================================================================

  /// Crear copia con valores modificados
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

  /// Actualizar progreso
  GoalModel updateProgress(double newValue) {
    return copyWith(currentValue: newValue);
  }

  /// Marcar como completado
  GoalModel markAsCompleted() {
    return copyWith(
      status: GoalStatus.completed,
      completedAt: DateTime.now(),
      currentValue: targetValue, // Asegurar que llegue al 100%
    );
  }

  /// Reactivar objetivo
  GoalModel reactivate() {
    return copyWith(
      status: GoalStatus.active,
      completedAt: null,
    );
  }

  /// Archivar objetivo
  GoalModel archive() {
    return copyWith(status: GoalStatus.archived);
  }

  // ============================================================================
  // MÉTODOS ESTÁTICOS DE UTILIDAD
  // ============================================================================

  /// Parsear tipo de objetivo desde string
  static GoalType _parseGoalType(String typeString) {
    // Remover prefijo del enum si existe
    final cleanType = typeString.replaceAll('GoalType.', '');

    switch (cleanType.toLowerCase()) {
      case 'consistency':
        return GoalType.consistency;
      case 'mood':
        return GoalType.mood;
      case 'positivemoments':
        return GoalType.positiveMoments;
      case 'stressreduction':
        return GoalType.stressReduction;
      default:
        return GoalType.consistency; // Default fallback
    }
  }

  /// Parsear estado de objetivo desde string
  static GoalStatus _parseGoalStatus(String statusString) {
    // Remover prefijo del enum si existe
    final cleanStatus = statusString.replaceAll('GoalStatus.', '');

    switch (cleanStatus.toLowerCase()) {
      case 'active':
        return GoalStatus.active;
      case 'completed':
        return GoalStatus.completed;
      case 'archived':
        return GoalStatus.archived;
      default:
        return GoalStatus.active; // Default fallback
    }
  }

  /// Crear objetivo de ejemplo para consistencia
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
      targetValue: targetDays.toDouble(),
      createdAt: DateTime.now(),
    );
  }

  /// Crear objetivo de ejemplo para mood
  static GoalModel createMoodGoal({
    required int userId,
    required String title,
    required String description,
    required double targetMoodScore,
  }) {
    return GoalModel(
      userId: userId,
      title: title,
      description: description,
      type: GoalType.mood,
      targetValue: targetMoodScore,
      createdAt: DateTime.now(),
    );
  }

  /// Crear objetivo de ejemplo para momentos positivos
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
      targetValue: targetMoments.toDouble(),
      createdAt: DateTime.now(),
    );
  }

  /// Crear objetivo de ejemplo para reducción de estrés
  static GoalModel createStressReductionGoal({
    required int userId,
    required String title,
    required String description,
    required double targetStressLevel,
  }) {
    return GoalModel(
      userId: userId,
      title: title,
      description: description,
      type: GoalType.stressReduction,
      targetValue: targetStressLevel,
      createdAt: DateTime.now(),
    );
  }

  // ============================================================================
  // MÉTODOS DE COMPARACIÓN Y ORDENAMIENTO
  // ============================================================================

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is GoalModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              userId == other.userId &&
              title == other.title &&
              type == other.type &&
              status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      title.hashCode ^
      type.hashCode ^
      status.hashCode;

  @override
  String toString() {
    return 'GoalModel{id: $id, title: $title, type: $type, status: $status, progress: ${progressPercentage}%}';
  }

  /// Comparar por progreso (para ordenamiento)
  static int compareByProgress(GoalModel a, GoalModel b) {
    return b.progress.compareTo(a.progress);
  }

  /// Comparar por fecha de creación (más recientes primero)
  static int compareByCreatedAt(GoalModel a, GoalModel b) {
    return b.createdAt.compareTo(a.createdAt);
  }

  /// Comparar por tipo
  static int compareByType(GoalModel a, GoalModel b) {
    return a.type.toString().compareTo(b.type.toString());
  }
}

// ============================================================================
// EXTENSIONES ÚTILES PARA LISTAS DE OBJETIVOS
// ============================================================================

extension GoalListExtensions on List<GoalModel> {
  /// Filtrar objetivos activos
  List<GoalModel> get activeGoals =>
      where((goal) => goal.isActive).toList();

  /// Filtrar objetivos completados
  List<GoalModel> get completedGoals =>
      where((goal) => goal.isCompleted).toList();

  /// Filtrar objetivos archivados
  List<GoalModel> get archivedGoals =>
      where((goal) => goal.isArchived).toList();

  /// Obtener objetivos por tipo
  List<GoalModel> ofType(GoalType type) =>
      where((goal) => goal.type == type).toList();

  /// Calcular progreso promedio
  double get averageProgress {
    if (isEmpty) return 0.0;
    final totalProgress = fold<double>(0.0, (sum, goal) => sum + goal.progress);
    return totalProgress / length;
  }

  /// Obtener objetivo con mayor progreso
  GoalModel? get mostProgressedGoal => isEmpty
      ? null
      : reduce((a, b) => a.progress > b.progress ? a : b);

  /// Obtener objetivo más reciente
  GoalModel? get newestGoal => isEmpty
      ? null
      : reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);

  /// Contar objetivos por estado
  Map<GoalStatus, int> get countByStatus {
    final counts = <GoalStatus, int>{};
    for (final goal in this) {
      counts[goal.status] = (counts[goal.status] ?? 0) + 1;
    }
    return counts;
  }

  /// Contar objetivos por tipo
  Map<GoalType, int> get countByType {
    final counts = <GoalType, int>{};
    for (final goal in this) {
      counts[goal.type] = (counts[goal.type] ?? 0) + 1;
    }
    return counts;
  }
}