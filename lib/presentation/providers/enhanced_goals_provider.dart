// lib/presentation/providers/enhanced_goals_provider.dart
// ============================================================================
// SIMPLIFIED ENHANCED GOALS PROVIDER
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../data/models/goal_model.dart';
import '../../data/services/enhanced_goals_service.dart';
import '../../data/services/optimized_database_service.dart';

/// Provider simplificado para gestión de objetivos
class EnhancedGoalsProvider extends ChangeNotifier {
  final EnhancedGoalsService _goalsService = EnhancedGoalsService();
  final OptimizedDatabaseService _databaseService;
  final Logger _logger = Logger();

  EnhancedGoalsProvider(this._databaseService) {
    _goalsService.initialize(_databaseService);
  }

  // ============================================================================
  // STATE MANAGEMENT
  // ============================================================================

  List<GoalModel> _goals = [];
  final Map<String, StreakData> _streakData = {};
  bool _isLoading = false;
  String? _error;
  GoalCategory? _selectedCategory;
  String _searchQuery = '';
  String _sortOption = 'createdAt';

  // ============================================================================
  // GETTERS
  // ============================================================================

  List<GoalModel> get goals => List.unmodifiable(_goals);
  Map<String, StreakData> get streakData => Map.unmodifiable(_streakData);
  bool get isLoading => _isLoading;
  String? get error => _error;
  GoalCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get sortOption => _sortOption;

  /// Objetivos filtrados según criterios actuales
  List<GoalModel> get filteredGoals {
    return _goals.where((goal) {
      // Filtro por categoría
      if (_selectedCategory != null && goal.category != _selectedCategory) {
        return false;
      }
      
      // Filtro por búsqueda
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return goal.title.toLowerCase().contains(query) ||
               goal.description.toLowerCase().contains(query);
      }
      
      return true;
    }).toList()..sort(_getSortComparator());
  }

  /// Comparador para ordenamiento
  int Function(GoalModel, GoalModel) _getSortComparator() {
    switch (_sortOption) {
      case 'title':
        return (a, b) => a.title.compareTo(b.title);
      case 'progress':
        return (a, b) => (b.currentValue / b.targetValue).compareTo(a.currentValue / a.targetValue);
      case 'createdAt':
        return (a, b) => b.createdAt.compareTo(a.createdAt);
      case 'category':
        return (a, b) => a.category.toString().compareTo(b.category.toString());
      default:
        return (a, b) => b.createdAt.compareTo(a.createdAt);
    }
  }

  /// Objetivos activos
  List<GoalModel> get activeGoals => 
      _goals.where((goal) => goal.status == GoalStatus.active).toList();

  /// Objetivos completados
  List<GoalModel> get completedGoals => 
      _goals.where((goal) => goal.status == GoalStatus.completed).toList();

  // ============================================================================
  // METHODS
  // ============================================================================

  /// Cargar objetivos
  Future<void> loadGoals(int userId) async {
    
    _setLoading(true);
    _clearError();
    
    try {
      _goals = await _databaseService.getUserGoals(userId);
      
      // Cargar datos de racha para cada objetivo
      for (final goal in _goals) {
        if (goal.id != null) {
          _streakData[goal.id.toString()] = const StreakData(
            currentStreak: 0,
            bestStreak: 0,
            daysSinceLastActivity: 0,
            momentumScore: 0.0,
            isStreakActive: false,
          );
        }
      }
      
      _logger.i('✅ Objetivos cargados: ${_goals.length}');
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error cargando objetivos: $e');
      _setError('Error cargando objetivos');
    } finally {
      _setLoading(false);
    }
  }

  /// Filtrar por categoría
  void filterByCategory(GoalCategory? category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  void setSortOption(String option) {
    if (_sortOption != option) {
      _sortOption = option;
      notifyListeners();
    }
  }

  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    _sortOption = 'createdAt';
    notifyListeners();
  }

  /// Crear objetivo
  Future<void> createGoal(GoalModel goal) async {
    _setLoading(true);
    _clearError();
    
    try {
      _logger.i('📝 Creando objetivo: ${goal.title}');
      
      final createdGoal = await _databaseService.addGoal(goal.userId, goal);
      final goalWithId = goal.copyWith(id: createdGoal);
      
      _goals.add(goalWithId);
      
      // Inicializar datos de racha
      _streakData[createdGoal.toString()] = const StreakData(
        currentStreak: 0,
        bestStreak: 0,
        daysSinceLastActivity: 0,
        momentumScore: 0.0,
        isStreakActive: false,
      );
      
      _logger.i('✅ Objetivo creado con ID: $createdGoal');
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error creando objetivo: $e');
      _setError('Error creando objetivo');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualiza el progreso de un objetivo
  Future<void> updateGoalProgress(int goalId, int newValue, {
    String? notes,
    Map<String, dynamic>? metrics,
  }) async {
    try {
      _logger.i('📊 Actualizando progreso del objetivo $goalId: $newValue');
      
      await _databaseService.updateGoalProgress(goalId, newValue.toDouble());
      
      // Actualizar en memoria
      final index = _goals.indexWhere((goal) => goal.id == goalId);
      if (index != -1) {
        _goals[index] = _goals[index].copyWith(
          currentValue: newValue,
          lastUpdated: DateTime.now(),
        );
        
        // Actualizar datos de racha
        _streakData[goalId.toString()] = const StreakData(
          currentStreak: 0,
          bestStreak: 0,
          daysSinceLastActivity: 0,
          momentumScore: 0.0,
          isStreakActive: false,
        );
      }
      
      _logger.i('✅ Progreso actualizado: $goalId');
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error actualizando progreso: $e');
      _setError('Error actualizando progreso');
    }
  }

  /// Obtiene datos de racha para un objetivo
  StreakData getStreakDataForGoal(int goalId) {
    return _streakData[goalId.toString()] ?? const StreakData(
      currentStreak: 0,
      bestStreak: 0,
      daysSinceLastActivity: 0,
      momentumScore: 0.0,
      isStreakActive: false,
    );
  }

  /// Get goal statistics
  Map<String, dynamic> get goalStatistics {
    final total = _goals.length;
    final completed = _goals.where((g) => g.status == GoalStatus.completed).length;
    final active = _goals.where((g) => g.status == GoalStatus.active).length;
    
    return {
      'total': total,
      'completed': completed,
      'active': active,
      'completionRate': total > 0 ? completed / total : 0.0,
    };
  }

  /// Set category filter
  void setCategory(GoalCategory? category) {
    filterByCategory(category);
  }

  /// Add progress entry
  Future<void> addProgressEntry(dynamic entry) async {
    try {
      _logger.i('📝 Añadiendo entrada de progreso para objetivo: ${entry.goalId}');
      
      await _goalsService.addProgressEntry(entry);
      
      // Actualizar datos de racha
      _streakData[entry.goalId] = const StreakData(
        currentStreak: 0,
        bestStreak: 0,
        daysSinceLastActivity: 0,
        momentumScore: 0.0,
        isStreakActive: false,
      );
      
      _logger.i('✅ Entrada de progreso añadida: ${entry.goalId}');
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error añadiendo entrada de progreso: $e');
      _setError('Error añadiendo entrada de progreso');
    }
  }

  /// Update goal
  Future<void> updateGoal(GoalModel updatedGoal) async {
    try {
      _logger.i('📊 Actualizando objetivo: ${updatedGoal.title}');
      
      final index = _goals.indexWhere((goal) => goal.id == updatedGoal.id);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
        _logger.i('✅ Objetivo actualizado: ${updatedGoal.id}');
      }
    } catch (e) {
      _logger.e('❌ Error actualizando objetivo: $e');
      _setError('Error actualizando objetivo');
    }
  }

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

// ============================================================================
// SORT OPTIONS
// ============================================================================

class GoalSortOptions {
  static const String title = 'title';
  static const String progress = 'progress';
  static const String createdAt = 'createdAt';
  static const String category = 'category';
  static const String priority = 'priority';
  static const String difficulty = 'difficulty';
  
  static String getDisplayName(String option) {
    switch (option) {
      case title: return 'Título';
      case progress: return 'Progreso';
      case createdAt: return 'Fecha de creación';
      case category: return 'Categoría';
      case priority: return 'Reciente';
      case difficulty: return 'Duración';
      default: return 'Desconocido';
    }
  }
}