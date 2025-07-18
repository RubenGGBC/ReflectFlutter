// lib/data/services/enhanced_goals_service.dart
// ============================================================================
// ENHANCED GOALS SERVICE - PHASE 1 IMPLEMENTATION
// ============================================================================

import 'dart:convert';
import 'dart:math' as math;
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';

import '../models/goal_model.dart';
import 'optimized_database_service.dart';

class EnhancedGoalsService {
  static final EnhancedGoalsService _instance = EnhancedGoalsService._internal();
  factory EnhancedGoalsService() => _instance;
  EnhancedGoalsService._internal();

  final Logger _logger = Logger();
  final OptimizedDatabaseService _dbService = OptimizedDatabaseService();

  // ============================================================================
  // DATABASE SCHEMA UPDATES FOR PHASE 1
  // ============================================================================

  /// Actualiza la esquema de base de datos para Phase 1
  Future<void> migrateToPhase1Schema() async {
    final db = await _dbService.database;
    
    await db.transaction((txn) async {
      try {
        // Agregar nuevas columnas a user_goals si no existen
        await _addColumnIfNotExists(txn, 'user_goals', 'category', 'TEXT DEFAULT "habits"');
        await _addColumnIfNotExists(txn, 'user_goals', 'difficulty', 'TEXT DEFAULT "medium"');
        await _addColumnIfNotExists(txn, 'user_goals', 'estimated_days', 'INTEGER DEFAULT 30');
        await _addColumnIfNotExists(txn, 'user_goals', 'milestones', 'TEXT DEFAULT "[]"');
        await _addColumnIfNotExists(txn, 'user_goals', 'metrics', 'TEXT DEFAULT "{}"');
        
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS progress_entries (
            id TEXT PRIMARY KEY,
            goal_id TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            primary_value INTEGER NOT NULL,
            metrics TEXT DEFAULT '{}',
            notes TEXT,
            photo_urls TEXT DEFAULT '[]',
            tags TEXT DEFAULT '[]',
            created_at INTEGER NOT NULL,
            FOREIGN KEY (goal_id) REFERENCES user_goals (id)
          )
        ''');
        
        // Crear índices para optimizar consultas
        await txn.execute('CREATE INDEX IF NOT EXISTS idx_progress_entries_goal_id ON progress_entries (goal_id)');
        await txn.execute('CREATE INDEX IF NOT EXISTS idx_progress_entries_timestamp ON progress_entries (timestamp DESC)');
        await txn.execute('CREATE INDEX IF NOT EXISTS idx_progress_entries_goal_timestamp ON progress_entries (goal_id, timestamp DESC)');
        
        _logger.i('✅ Schema migrado a Phase 1 exitosamente');
      } catch (e) {
        _logger.e('❌ Error migrando schema: $e');
        rethrow;
      }
    });
  }

  /// Helper para agregar columnas si no existen
  Future<void> _addColumnIfNotExists(Transaction txn, String table, String column, String definition) async {
    try {
      await txn.execute('ALTER TABLE $table ADD COLUMN $column $definition');
      _logger.i('✅ Columna $column agregada a $table');
    } catch (e) {
      // Columna ya existe, ignorar error
      _logger.d('Columna $column ya existe en $table');
    }
  }

  // ============================================================================
  // ENHANCED
  // ============================================================================

  /// Crea un objetivo con configuración completa de Phase 1
  Future<GoalModel> createEnhancedGoal({
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
  }) async {
    final db = await _dbService.database;
    
    try {
      final goal = GoalModel.createEnhanced(
        userId: userId,
        title: title,
        description: description,
        type: type,
        targetValue: targetValue,
        category: category,
        difficulty: difficulty,
        estimatedDays: estimatedDays,
        customMilestones: customMilestones,
        initialMetrics: initialMetrics,
      );
      
      final goalData = goal.toDatabase();
      
      // ✅ FIX: Convertir integers a doubles para compatibilidad con esquema REAL
      goalData['target_value'] = (goalData['target_value'] as int).toDouble();
      goalData['current_value'] = (goalData['current_value'] as int).toDouble();
      
      goalData['milestones'] = jsonEncode(goal.milestones.map((m) => m.toJson()).toList());
      goalData['metrics'] = jsonEncode(goal.metrics);
      
      _logger.i('📊 Creating enhanced goal: $goalData');
      
      final goalId = await db.insert('user_goals', goalData);
      
      _logger.i('✅ Enhanced goal created with ID: $goalId');
      return goal.copyWith(id: goalId);
    } catch (e) {
      _logger.e('❌ Error creating enhanced goal: $e');
      rethrow;
    }
  }

  /// Crea un objetivo mejorado desde un modelo GoalModel
  Future<GoalModel> createEnhancedGoalFromModel(GoalModel goal) async {
    final db = await _dbService.database;
    
    try {
      // Generar milestones automáticamente si no los tiene
      final enhancedGoal = goal.milestones.isEmpty 
          ? goal.copyWith(milestones: goal.generateDefaultMilestones())
          : goal;
      
      final goalData = enhancedGoal.toDatabase();
      
      // ✅ FIX: Convertir integers a doubles para compatibilidad con esquema REAL
      goalData['target_value'] = (goalData['target_value'] as int).toDouble();
      goalData['current_value'] = (goalData['current_value'] as int).toDouble();
      
      goalData['milestones'] = jsonEncode(enhancedGoal.milestones.map((m) => m.toJson()).toList());
      goalData['metrics'] = jsonEncode(enhancedGoal.metrics);
      
      _logger.i('📊 Inserting goal data: $goalData');
      
      final goalId = await db.insert('user_goals', goalData);
      
      _logger.i('✅ Enhanced goal created from model with ID: $goalId');
      return enhancedGoal.copyWith(id: goalId);
    } catch (e) {
      _logger.e('❌ Error creating enhanced goal from model: $e');
      rethrow;
    }
  }

  /// Obtiene objetivos con configuración completa
  Future<List<GoalModel>> getUserGoalsEnhanced(int userId) async {
    final db = await _dbService.database;
    
    final results = await db.query(
      'user_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    
    return results.map((row) {
      // Parsear JSON fields
      final rowCopy = Map<String, dynamic>.from(row);
      
      if (rowCopy['milestones'] is String) {
        try {
          final milestonesJson = jsonDecode(rowCopy['milestones'] as String) as List;
          rowCopy['milestones'] = milestonesJson;
        } catch (e) {
          rowCopy['milestones'] = [];
        }
      }
      
      if (rowCopy['metrics'] is String) {
        try {
          rowCopy['metrics'] = jsonDecode(rowCopy['metrics'] as String);
        } catch (e) {
          rowCopy['metrics'] = {};
        }
      }
      
      return GoalModel.fromDatabase(rowCopy);
    }).toList();
  }

  /// Actualiza progreso con verificación automática de milestones
  Future<GoalModel> updateGoalProgressWithMilestones(
    int goalId,
    int newValue, {
    String? notes,
    Map<String, dynamic>? metrics,
  }) async {
    final db = await _dbService.database;
    
    // Obtener objetivo actual
    final goalResults = await db.query(
      'user_goals',
      where: 'id = ?',
      whereArgs: [goalId],
      limit: 1,
    );
    
    if (goalResults.isEmpty) {
      throw Exception('Goal not found with ID: $goalId');
    }
    
    final currentGoalData = Map<String, dynamic>.from(goalResults.first);
    
    // Parsear datos JSON
    if (currentGoalData['milestones'] is String) {
      try {
        final milestonesJson = jsonDecode(currentGoalData['milestones'] as String) as List;
        currentGoalData['milestones'] = milestonesJson.map((json) => 
          Milestone.fromJson(json as Map<String, dynamic>)).toList();
      } catch (e) {
        currentGoalData['milestones'] = <Milestone>[];
      }
    }
    
    if (currentGoalData['metrics'] is String) {
      try {
        currentGoalData['metrics'] = jsonDecode(currentGoalData['metrics'] as String);
      } catch (e) {
        currentGoalData['metrics'] = <String, dynamic>{};
      }
    }
    
    final currentGoal = GoalModel.fromDatabase(currentGoalData);
    
    // Actualizar progreso y verificar milestones
    final updatedGoal = currentGoal.updateProgressWithMilestones(newValue, notes: notes);
    
    // Actualizar métricas si se proporcionan
    final finalGoal = metrics != null 
        ? updatedGoal.updateMetrics(metrics)
        : updatedGoal;
    
    // Guardar en base de datos
    final goalData = finalGoal.toDatabase();
    goalData['milestones'] = jsonEncode(finalGoal.milestones.map((m) => m.toJson()).toList());
    goalData['metrics'] = jsonEncode(finalGoal.metrics);
    
    await db.update(
      'user_goals',
      goalData,
      where: 'id = ?',
      whereArgs: [goalId],
    );
    
    _logger.i('✅ Goal progress updated with milestones check');
    return finalGoal;
  }

  // ============================================================================
  // PROGRESS ENTRIES MANAGEMENT
  // ============================================================================

  /// Agrega una entrada de progreso rica
  Future<ProgressEntry> addProgressEntry(ProgressEntry entry) async {
    final db = await _dbService.database;
    
    final entryData = {
      'id': entry.id,
      'goal_id': entry.goalId,
      'timestamp': entry.timestamp.toIso8601String(),
      'primary_value': entry.primaryValue,
      'metrics': jsonEncode(entry.metrics),
      'notes': entry.notes,
      'photo_urls': jsonEncode(entry.photoUrls),
      'tags': jsonEncode(entry.tags),
      'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
    
    await db.insert('progress_entries', entryData);
    
    _logger.i('✅ Progress entry added for goal ${entry.goalId}');
    return entry;
  }

  /// Obtiene entradas de progreso para un objetivo
  Future<List<ProgressEntry>> getProgressEntries(String goalId, {int? limit}) async {
    final db = await _dbService.database;
    
    final results = await db.query(
      'progress_entries',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    
    return results.map((row) {
      return ProgressEntry(
        id: row['id'] as String,
        goalId: row['goal_id'] as String,
        timestamp: DateTime.parse(row['timestamp'] as String),
        primaryValue: row['primary_value'] as int,
        metrics: jsonDecode(row['metrics'] as String? ?? '{}') as Map<String, dynamic>,
        notes: row['notes'] as String?,
        photoUrls: List<String>.from(jsonDecode(row['photo_urls'] as String? ?? '[]') as List),
        tags: List<String>.from(jsonDecode(row['tags'] as String? ?? '[]') as List),
      );
    }).toList();
  }

  // ============================================================================
  // STREAK CALCULATION
  // ============================================================================

  /// Calcula datos de racha para un objetivo
  Future<StreakData> calculateStreakData(String goalId) async {
    final entries = await getProgressEntries(goalId);
    
    if (entries.isEmpty) {
      return StreakData(
        currentStreak: 0,
        bestStreak: 0,
        daysSinceLastActivity: 0,
        momentumScore: 0.0,
        lastActivityDate: null,
        isStreakActive: false,
      );
    }
    
    // Agrupar entradas por día
    final entriesByDay = <String, List<ProgressEntry>>{};
    for (final entry in entries) {
      final dayKey = _getDayKey(entry.timestamp);
      entriesByDay.putIfAbsent(dayKey, () => []).add(entry);
    }
    
    final activeDays = entriesByDay.keys.toList()..sort();
    activeDays.sort((a, b) => b.compareTo(a)); // Más reciente primero
    
    // Calcular racha actual
    int currentStreak = 0;
    final today = _getDayKey(DateTime.now());
    final yesterday = _getDayKey(DateTime.now().subtract(Duration(days: 1)));
    
    // Verificar si hay actividad hoy o ayer
    bool streakActive = activeDays.isNotEmpty && 
        (activeDays.first == today || activeDays.first == yesterday);
    
    if (streakActive) {
      final startDate = activeDays.first == today ? today : yesterday;
      DateTime currentDate = DateTime.parse('${startDate}T00:00:00');
      
      while (activeDays.contains(_getDayKey(currentDate))) {
        currentStreak++;
        currentDate = currentDate.subtract(Duration(days: 1));
      }
    }
    
    // Calcular mejor racha
    int bestStreak = currentStreak;
    int tempStreak = 0;
    DateTime? lastDate;
    
    for (final day in activeDays.reversed) {
      final currentDate = DateTime.parse('${day}T00:00:00');
      
      if (lastDate == null || currentDate.difference(lastDate).inDays == 1) {
        tempStreak++;
        bestStreak = math.max(bestStreak, tempStreak);
      } else {
        tempStreak = 1;
      }
      
      lastDate = currentDate;
    }
    
    // Calcular días desde última actividad
    final lastActivityDate = entries.isNotEmpty ? entries.first.timestamp : null;
    final daysSinceLastActivity = lastActivityDate != null
        ? DateTime.now().difference(lastActivityDate).inDays
        : 0;
    
    // Calcular momentum score (basado en actividad reciente)
    final recentEntries = entries.take(7).length; // Últimos 7 días
    final momentumScore = (recentEntries / 7.0).clamp(0.0, 1.0);
    
    return StreakData(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      daysSinceLastActivity: daysSinceLastActivity,
      momentumScore: momentumScore,
      lastActivityDate: lastActivityDate,
      isStreakActive: streakActive,
    );
  }

  String _getDayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================================
  // ANALYTICS AND INSIGHTS
  // ============================================================================

  /// Obtiene estadísticas de progreso para un objetivo
  Future<Map<String, dynamic>> getGoalAnalytics(String goalId) async {
    final entries = await getProgressEntries(goalId);
    final streakData = await calculateStreakData(goalId);
    
    if (entries.isEmpty) {
      return {
        'total_entries': 0,
        'average_quality': 0.0,
        'mood_improvement_rate': 0.0,
        'consistency_score': 0.0,
        'streak_data': streakData,
      };
    }
    
    // Calcular estadísticas
    final totalEntries = entries.length;
    
    final qualityRatings = entries
        .map((e) => e.qualityRating)
        .where((q) => q != null)
        .cast<int>()
        .toList();
    
    final averageQuality = qualityRatings.isNotEmpty
        ? qualityRatings.reduce((a, b) => a + b) / qualityRatings.length
        : 0.0;
    
    // Calcular tasa de mejora de humor
    final moodImprovements = entries.where((e) => e.hasMoodImprovement).length;
    final moodImprovementRate = totalEntries > 0 ? moodImprovements / totalEntries : 0.0;
    
    // Calcular score de consistencia (basado en días únicos con entradas)
    final uniqueDays = entries.map((e) => _getDayKey(e.timestamp)).toSet().length;
    final daysSinceStart = entries.isNotEmpty 
        ? DateTime.now().difference(entries.last.timestamp).inDays + 1
        : 1;
    final consistencyScore = uniqueDays / daysSinceStart;
    
    return {
      'total_entries': totalEntries,
      'average_quality': averageQuality,
      'mood_improvement_rate': moodImprovementRate,
      'consistency_score': consistencyScore.clamp(0.0, 1.0),
      'unique_days': uniqueDays,
      'streak_data': streakData,
    };
  }

  /// Obtiene objetivos por categoría
  Future<List<GoalModel>> getGoalsByCategory(int userId, GoalCategory category) async {
    final db = await _dbService.database;
    
    final results = await db.query(
      'user_goals',
      where: 'user_id = ? AND category = ?',
      whereArgs: [userId, category.name],
      orderBy: 'created_at DESC',
    );
    
    return results.map((row) => GoalModel.fromDatabase(row)).toList();
  }

  /// Obtiene objetivos que necesitan atención (sin actividad reciente)
  Future<List<Map<String, dynamic>>> getGoalsNeedingAttention(int userId) async {
    final goals = await getUserGoalsEnhanced(userId);
    final goalsNeedingAttention = <Map<String, dynamic>>[];
    
    for (final goal in goals.where((g) => g.isActive)) {
      final streakData = await calculateStreakData(goal.id.toString());
      
      if (streakData.daysSinceLastActivity > 2 || streakData.momentumScore < 0.3) {
        goalsNeedingAttention.add({
          'goal': goal,
          'streak_data': streakData,
          'priority': _calculateAttentionPriority(goal, streakData),
        });
      }
    }
    
    // Ordenar por prioridad
    goalsNeedingAttention.sort((a, b) => (b['priority'] as double).compareTo(a['priority'] as double));
    
    return goalsNeedingAttention;
  }

  double _calculateAttentionPriority(GoalModel goal, StreakData streakData) {
    double priority = 0.0;
    
    // Más días sin actividad = mayor prioridad
    priority += streakData.daysSinceLastActivity * 0.3;
    
    // Menor momentum = mayor prioridad
    priority += (1.0 - streakData.momentumScore) * 0.4;
    
    // Progreso cercano a milestone = mayor prioridad
    if (goal.nextMilestone != null) {
      priority += goal.progressToNextMilestone * 0.3;
    }
    
    return priority.clamp(0.0, 1.0);
  }
}