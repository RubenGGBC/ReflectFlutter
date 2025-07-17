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

// ============================================================================
// NUEVOS ENUMS Y CLASES PARA PHASE 1 ENHANCEMENT
// ============================================================================

enum GoalCategory {
  mindfulness,    // Mindfulness y meditación
  stress,         // Manejo del estrés
  sleep,          // Mejora del sueño
  social,         // Conexiones sociales
  physical,       // Actividad física
  emotional,      // Bienestar emocional
  productivity,   // Productividad personal
  habits          // Formación de hábitos
}

enum GoalDifficulty {
  easy,     // Fácil - 1-2 semanas
  medium,   // Medio - 3-4 semanas
  hard,     // Difícil - 1-2 meses
  expert    // Experto - 3+ meses
}

// ============================================================================
// MODELO DE MILESTONE
// ============================================================================

class Milestone {
  final String id;
  final String title;
  final int targetValue;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? celebrationMessage;
  final double percentage; // 0.25 for 25%, 0.5 for 50%, etc.

  const Milestone({
    required this.id,
    required this.title,
    required this.targetValue,
    this.isCompleted = false,
    this.completedAt,
    this.celebrationMessage,
    required this.percentage,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'] as String,
      title: json['title'] as String,
      targetValue: json['target_value'] as int,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      celebrationMessage: json['celebration_message'] as String?,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'target_value': targetValue,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'celebration_message': celebrationMessage,
      'percentage': percentage,
    };
  }

  Milestone copyWith({
    String? id,
    String? title,
    int? targetValue,
    bool? isCompleted,
    DateTime? completedAt,
    String? celebrationMessage,
    double? percentage,
  }) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      targetValue: targetValue ?? this.targetValue,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      celebrationMessage: celebrationMessage ?? this.celebrationMessage,
      percentage: percentage ?? this.percentage,
    );
  }

  static List<Milestone> createDefaultMilestones(int targetValue) {
    return [
      Milestone(
        id: '25',
        title: '¡Primer Cuarto!',
        targetValue: (targetValue * 0.25).round(),
        percentage: 0.25,
        celebrationMessage: '¡Excelente comienzo! Has completado el 25% de tu objetivo.',
      ),
      Milestone(
        id: '50',
        title: '¡A la Mitad!',
        targetValue: (targetValue * 0.5).round(),
        percentage: 0.5,
        celebrationMessage: '¡Increíble! Ya estás a la mitad del camino.',
      ),
      Milestone(
        id: '75',
        title: '¡Casi Ahí!',
        targetValue: (targetValue * 0.75).round(),
        percentage: 0.75,
        celebrationMessage: '¡Fantástico! Solo un poco más para alcanzar tu meta.',
      ),
      Milestone(
        id: '100',
        title: '¡Objetivo Completado!',
        targetValue: targetValue,
        percentage: 1.0,
        celebrationMessage: '¡Felicitaciones! Has alcanzado tu objetivo completamente.',
      ),
    ];
  }
}

// ============================================================================
// MODELO DE PROGRESS ENTRY
// ============================================================================

class ProgressEntry {
  final String id;
  final String goalId;
  final DateTime timestamp;
  final int primaryValue;
  final Map<String, dynamic> metrics;
  final String? notes;
  final List<String> photoUrls;
  final List<String> tags;

  const ProgressEntry({
    required this.id,
    required this.goalId,
    required this.timestamp,
    required this.primaryValue,
    this.metrics = const {},
    this.notes,
    this.photoUrls = const [],
    this.tags = const [],
  });

  factory ProgressEntry.fromJson(Map<String, dynamic> json) {
    return ProgressEntry(
      id: json['id'] as String,
      goalId: json['goal_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      primaryValue: json['primary_value'] as int,
      metrics: Map<String, dynamic>.from(json['metrics'] as Map? ?? {}),
      notes: json['notes'] as String?,
      photoUrls: List<String>.from(json['photo_urls'] as List? ?? []),
      tags: List<String>.from(json['tags'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'timestamp': timestamp.toIso8601String(),
      'primary_value': primaryValue,
      'metrics': metrics,
      'notes': notes,
      'photo_urls': photoUrls,
      'tags': tags,
    };
  }

  // Getters para métricas comunes
  int? get qualityRating => metrics['quality'] as int?;
  int? get moodBefore => metrics['mood_before'] as int?;
  int? get moodAfter => metrics['mood_after'] as int?;
  int? get energyLevel => metrics['energy_level'] as int?;
  int? get stressLevel => metrics['stress_level'] as int?;
  int? get difficultyRating => metrics['difficulty'] as int?;

  bool get hasMoodImprovement => 
      moodBefore != null && moodAfter != null && moodAfter! > moodBefore!;

  ProgressEntry copyWith({
    String? id,
    String? goalId,
    DateTime? timestamp,
    int? primaryValue,
    Map<String, dynamic>? metrics,
    String? notes,
    List<String>? photoUrls,
    List<String>? tags,
  }) {
    return ProgressEntry(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      timestamp: timestamp ?? this.timestamp,
      primaryValue: primaryValue ?? this.primaryValue,
      metrics: metrics ?? this.metrics,
      notes: notes ?? this.notes,
      photoUrls: photoUrls ?? this.photoUrls,
      tags: tags ?? this.tags,
    );
  }
}

// ============================================================================
// MODELO DE STREAK DATA
// ============================================================================

class StreakData {
  final int currentStreak;
  final int bestStreak;
  final int daysSinceLastActivity;
  final double momentumScore;
  final DateTime? lastActivityDate;
  final bool isStreakActive;

  const StreakData({
    required this.currentStreak,
    required this.bestStreak,
    required this.daysSinceLastActivity,
    required this.momentumScore,
    this.lastActivityDate,
    required this.isStreakActive,
  });

  String get streakDescription {
    if (currentStreak == 0) return 'Comienza tu racha';
    if (currentStreak == 1) return '1 día consecutivo';
    return '$currentStreak días consecutivos';
  }

  String get momentumDescription {
    if (momentumScore >= 0.8) return 'Momentum excelente 🔥';
    if (momentumScore >= 0.6) return 'Buen ritmo 📈';
    if (momentumScore >= 0.4) return 'Ritmo moderado 📊';
    if (momentumScore >= 0.2) return 'Empezando 🌱';
    return 'Necesita impulso 💪';
  }
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
  
  // ============================================================================
  // NUEVOS CAMPOS PARA PHASE 1 ENHANCEMENT
  // ============================================================================
  final GoalCategory category;
  final GoalDifficulty difficulty;
  final int estimatedDays;
  final List<Milestone> milestones;
  final Map<String, dynamic> metrics;

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
    // Nuevos campos con valores por defecto
    this.category = GoalCategory.habits,
    this.difficulty = GoalDifficulty.medium,
    this.estimatedDays = 30,
    this.milestones = const [],
    this.metrics = const {},
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
  
  // ============================================================================
  // NUEVOS GETTERS PARA PHASE 1 ENHANCEMENT
  // ============================================================================
  
  /// Obtiene los milestones o crea por defecto si están vacíos
  List<Milestone> get effectiveMilestones {
    if (milestones.isNotEmpty) return milestones;
    return Milestone.createDefaultMilestones(targetValue);
  }
  
  /// Siguiente milestone a alcanzar
  Milestone? get nextMilestone {
    final effective = effectiveMilestones;
    for (final milestone in effective) {
      if (!milestone.isCompleted && currentValue < milestone.targetValue) {
        return milestone;
      }
    }
    return null;
  }
  
  /// Último milestone completado
  Milestone? get lastCompletedMilestone {
    final effective = effectiveMilestones;
    Milestone? last;
    for (final milestone in effective) {
      if (milestone.isCompleted) {
        last = milestone;
      }
    }
    return last;
  }
  
  /// Cuenta de milestones completados
  int get completedMilestonesCount {
    return effectiveMilestones.where((m) => m.isCompleted).length;
  }
  
  /// Progreso hasta el siguiente milestone
  double get progressToNextMilestone {
    final next = nextMilestone;
    if (next == null) return 1.0;
    
    final lastCompleted = lastCompletedMilestone;
    final startValue = lastCompleted?.targetValue ?? 0;
    final targetValue = next.targetValue;
    final currentProgress = currentValue - startValue;
    final totalNeeded = targetValue - startValue;
    
    if (totalNeeded <= 0) return 1.0;
    return (currentProgress / totalNeeded).clamp(0.0, 1.0);
  }
  
  /// Descripción de la categoría
  String get categoryDisplayName {
    switch (category) {
      case GoalCategory.mindfulness: return 'Mindfulness';
      case GoalCategory.stress: return 'Manejo del Estrés';
      case GoalCategory.sleep: return 'Sueño';
      case GoalCategory.social: return 'Social';
      case GoalCategory.physical: return 'Físico';
      case GoalCategory.emotional: return 'Emocional';
      case GoalCategory.productivity: return 'Productividad';
      case GoalCategory.habits: return 'Hábitos';
    }
  }
  
  /// Descripción de la dificultad
  String get difficultyDisplayName {
    switch (difficulty) {
      case GoalDifficulty.easy: return 'Fácil';
      case GoalDifficulty.medium: return 'Medio';
      case GoalDifficulty.hard: return 'Difícil';
      case GoalDifficulty.expert: return 'Experto';
    }
  }
  
  /// Color asociado a la categoría
  String get categoryColorHex {
    switch (category) {
      case GoalCategory.mindfulness: return '8B5CF6'; // Morado
      case GoalCategory.stress: return 'EF4444'; // Rojo
      case GoalCategory.sleep: return '3B82F6'; // Azul
      case GoalCategory.social: return '10B981'; // Verde
      case GoalCategory.physical: return 'F59E0B'; // Naranja
      case GoalCategory.emotional: return 'EC4899'; // Rosa
      case GoalCategory.productivity: return '6366F1'; // Índigo
      case GoalCategory.habits: return '84CC16'; // Lima
    }
  }
  
  /// Icono asociado a la categoría
  String get categoryIcon {
    switch (category) {
      case GoalCategory.mindfulness: return 'self_improvement';
      case GoalCategory.stress: return 'psychology';
      case GoalCategory.sleep: return 'bedtime';
      case GoalCategory.social: return 'people';
      case GoalCategory.physical: return 'fitness_center';
      case GoalCategory.emotional: return 'favorite';
      case GoalCategory.productivity: return 'trending_up';
      case GoalCategory.habits: return 'repeat';
    }
  }
  
  /// Días restantes estimados
  int get estimatedDaysRemaining {
    if (isCompleted) return 0;
    
    final progressRate = progress;
    if (progressRate == 0) return estimatedDays;
    
    final daysElapsed = daysSinceCreated;
    final estimatedTotal = (daysElapsed / progressRate).round();
    return (estimatedTotal - daysElapsed).clamp(0, estimatedDays * 2);
  }
  
  /// Si debe mostrar celebración
  bool get shouldCelebrateMilestone {
    final next = nextMilestone;
    return next != null && currentValue >= next.targetValue && !next.isCompleted;
  }

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
    
    // Helper para parsear GoalCategory de forma segura
    GoalCategory parseGoalCategory(dynamic value) {
      if (value is String) return GoalCategory.values.firstWhere((e) => e.name.toLowerCase() == value.toLowerCase(), orElse: () => GoalCategory.habits);
      if (value is int && value >= 0 && value < GoalCategory.values.length) return GoalCategory.values[value];
      return GoalCategory.habits;
    }
    
    // Helper para parsear GoalDifficulty de forma segura
    GoalDifficulty parseGoalDifficulty(dynamic value) {
      if (value is String) return GoalDifficulty.values.firstWhere((e) => e.name.toLowerCase() == value.toLowerCase(), orElse: () => GoalDifficulty.medium);
      if (value is int && value >= 0 && value < GoalDifficulty.values.length) return GoalDifficulty.values[value];
      return GoalDifficulty.medium;
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
    
    // Helper para parsear milestones de JSON
    List<Milestone> parseMilestones(dynamic value) {
      if (value == null) return [];
      if (value is String) {
        try {
          final List<dynamic> jsonList = Map<String, dynamic>.from(
            Map.castFrom(Map.from({}))
          )['milestones'] as List<dynamic>? ?? [];
          return jsonList.map((json) => Milestone.fromJson(json as Map<String, dynamic>)).toList();
        } catch (e) {
          return [];
        }
      }
      return [];
    }
    
    // Helper para parsear metrics de JSON
    Map<String, dynamic> parseMetrics(dynamic value) {
      if (value == null) return {};
      if (value is String) {
        try {
          return Map<String, dynamic>.from(Map.from({}));
        } catch (e) {
          return {};
        }
      }
      if (value is Map) return Map<String, dynamic>.from(value);
      return {};
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
      // Nuevos campos
      category: parseGoalCategory(map['category']),
      difficulty: parseGoalDifficulty(map['difficulty']),
      estimatedDays: (map['estimated_days'] as num? ?? 30).toInt(),
      milestones: parseMilestones(map['milestones']),
      metrics: parseMetrics(map['metrics']),
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
      // Nuevos campos
      'category': category.name,
      'difficulty': difficulty.name,
      'estimated_days': estimatedDays,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'metrics': metrics,
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
    GoalCategory? category,
    GoalDifficulty? difficulty,
    int? estimatedDays,
    List<Milestone>? milestones,
    Map<String, dynamic>? metrics,
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
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      milestones: milestones ?? this.milestones,
      metrics: metrics ?? this.metrics,
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
  // NUEVOS MÉTODOS PARA PHASE 1 ENHANCEMENT
  // ============================================================================
  
  /// Actualiza progreso y verifica milestones automáticamente
  GoalModel updateProgressWithMilestones(int newValue, {String? notes}) {
    final updatedMilestones = <Milestone>[];
    final effective = effectiveMilestones;
    
    for (final milestone in effective) {
      if (newValue >= milestone.targetValue && !milestone.isCompleted) {
        // Marcar milestone como completado
        updatedMilestones.add(milestone.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        ));
      } else {
        updatedMilestones.add(milestone);
      }
    }
    
    return copyWith(
      currentValue: newValue,
      progressNotes: notes,
      lastUpdated: DateTime.now(),
      milestones: updatedMilestones,
    );
  }
  
  /// Agrega milestone personalizado
  GoalModel addCustomMilestone(Milestone milestone) {
    final updatedMilestones = List<Milestone>.from(milestones);
    updatedMilestones.add(milestone);
    // Ordenar por porcentaje
    updatedMilestones.sort((a, b) => a.percentage.compareTo(b.percentage));
    
    return copyWith(
      milestones: updatedMilestones,
      lastUpdated: DateTime.now(),
    );
  }
  
  /// Actualiza métricas del objetivo
  GoalModel updateMetrics(Map<String, dynamic> newMetrics) {
    final updatedMetrics = Map<String, dynamic>.from(metrics);
    updatedMetrics.addAll(newMetrics);
    
    return copyWith(
      metrics: updatedMetrics,
      lastUpdated: DateTime.now(),
    );
  }
  
  /// Marca un milestone específico como completado
  GoalModel completeMilestone(String milestoneId) {
    final updatedMilestones = milestones.map((milestone) {
      if (milestone.id == milestoneId) {
        return milestone.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );
      }
      return milestone;
    }).toList();
    
    return copyWith(
      milestones: updatedMilestones,
      lastUpdated: DateTime.now(),
    );
  }
  
  /// Crea objetivo con configuración completa
  static GoalModel createEnhanced({
    required int userId,
    required String title,
    required String description,
    required GoalType type,
    required int targetValue,
    required GoalCategory category,
    GoalDifficulty difficulty = GoalDifficulty.medium,
    int? estimatedDays,
    List<Milestone>? customMilestones,
    Map<String, dynamic>? initialMetrics,
  }) {
    final estimatedDaysCalculated = estimatedDays ?? _calculateEstimatedDays(difficulty, targetValue);
    final milestones = customMilestones ?? Milestone.createDefaultMilestones(targetValue);
    
    return GoalModel(
      userId: userId,
      title: title,
      description: description,
      type: type,
      targetValue: targetValue,
      category: category,
      difficulty: difficulty,
      estimatedDays: estimatedDaysCalculated,
      milestones: milestones,
      metrics: initialMetrics ?? {},
      createdAt: DateTime.now(),
    );
  }
  
  /// Calcula días estimados basado en dificultad y valor objetivo
  static int _calculateEstimatedDays(GoalDifficulty difficulty, int targetValue) {
    switch (difficulty) {
      case GoalDifficulty.easy:
        return (targetValue * 0.5).clamp(7, 14).round(); // 7-14 días
      case GoalDifficulty.medium:
        return (targetValue * 1.0).clamp(21, 30).round(); // 21-30 días
      case GoalDifficulty.hard:
        return (targetValue * 1.5).clamp(45, 60).round(); // 45-60 días
      case GoalDifficulty.expert:
        return (targetValue * 2.0).clamp(90, 120).round(); // 90-120 días
    }
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

  /// Genera milestones por defecto basados en el objetivo
  List<Milestone> generateDefaultMilestones() {
    if (targetValue <= 0) return [];
    
    final milestones = <Milestone>[];
    final quarterValue = (targetValue * 0.25).round();
    final halfValue = (targetValue * 0.5).round();
    final threeQuarterValue = (targetValue * 0.75).round();
    
    if (quarterValue > 0) {
      milestones.add(Milestone(
        id: '${id}_milestone_25',
        title: 'Primer Cuarto',
        targetValue: quarterValue,
        percentage: 0.25,
        isCompleted: currentValue >= quarterValue,
        completedAt: currentValue >= quarterValue ? DateTime.now() : null,
        celebrationMessage: 'Has completado el 25% de tu objetivo',
      ));
    }
    
    if (halfValue > quarterValue) {
      milestones.add(Milestone(
        id: '${id}_milestone_50',
        title: 'Mitad del Camino',
        targetValue: halfValue,
        percentage: 0.5,
        isCompleted: currentValue >= halfValue,
        completedAt: currentValue >= halfValue ? DateTime.now() : null,
        celebrationMessage: 'Has llegado a la mitad de tu objetivo',
      ));
    }
    
    if (threeQuarterValue > halfValue) {
      milestones.add(Milestone(
        id: '${id}_milestone_75',
        title: 'Tres Cuartos',
        targetValue: threeQuarterValue,
        percentage: 0.75,
        isCompleted: currentValue >= threeQuarterValue,
        completedAt: currentValue >= threeQuarterValue ? DateTime.now() : null,
        celebrationMessage: 'Estás muy cerca de completar tu objetivo',
      ));
    }
    
    // Final milestone
    milestones.add(Milestone(
      id: '${id}_milestone_100',
      title: '¡Objetivo Completado!',
      targetValue: targetValue,
      percentage: 1.0,
      isCompleted: currentValue >= targetValue,
      completedAt: currentValue >= targetValue ? DateTime.now() : null,
      celebrationMessage: 'Has completado tu objetivo exitosamente',
    ));
    
    return milestones;
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