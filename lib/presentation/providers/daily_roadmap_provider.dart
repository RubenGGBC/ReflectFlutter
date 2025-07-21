// ============================================================================
// daily_roadmap_provider.dart - PROVEEDOR DE ESTADO PARA ROADMAP DIARIO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../data/models/daily_roadmap_model.dart';
import '../../data/models/roadmap_activity_model.dart';
import '../../data/services/optimized_database_service.dart';

class DailyRoadmapProvider extends ChangeNotifier {
  final OptimizedDatabaseService _databaseService;
  final Logger _logger = Logger();

  // Estado interno
  DailyRoadmapModel? _currentRoadmap;
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();
  List<DailyRoadmapModel> _roadmapHistory = [];

  // Constructor
  DailyRoadmapProvider({
    required OptimizedDatabaseService databaseService,
  }) : _databaseService = databaseService;

  // Getters
  DailyRoadmapModel? get currentRoadmap => _currentRoadmap;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;
  List<DailyRoadmapModel> get roadmapHistory => _roadmapHistory;

  bool get hasActivities => _currentRoadmap?.activities.isNotEmpty ?? false;
  int get totalActivities => _currentRoadmap?.activities.length ?? 0;
  int get completedActivities => 
      _currentRoadmap?.activities.where((a) => a.isCompleted).length ?? 0;
  double get completionPercentage => 
      totalActivities > 0 ? (completedActivities / totalActivities) * 100 : 0.0;

  List<RoadmapActivityModel> get activitiesByTime => 
      _currentRoadmap?.activitiesByTime ?? [];

  List<RoadmapActivityModel> get upcomingActivities {
    final now = DateTime.now();
    return activitiesByTime.where((activity) {
      if (!_isToday(_selectedDate)) return false;
      
      final activityTime = DateTime(
        now.year,
        now.month,
        now.day,
        activity.hour,
        activity.minute,
      );
      return activityTime.isAfter(now) && !activity.isCompleted;
    }).toList();
  }

  List<RoadmapActivityModel> get overdueActivities {
    final now = DateTime.now();
    return activitiesByTime.where((activity) {
      if (!_isToday(_selectedDate)) return false;
      
      final activityTime = DateTime(
        now.year,
        now.month,
        now.day,
        activity.hour,
        activity.minute,
      ).add(Duration(minutes: activity.estimatedDuration ?? 60));
      
      return activityTime.isBefore(now) && !activity.isCompleted;
    }).toList();
  }

  // ============================================================================
  // MÉTODOS PRINCIPALES
  // ============================================================================

  Future<void> initialize(int userId) async {
    // Defer initialization to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAsync(userId);
    });
  }

  Future<void> _initializeAsync(int userId) async {
    try {
      _setLoading(true);
      _clearError();

      await loadRoadmapForDate(userId, _selectedDate);
      await loadRoadmapHistory(userId);

      _logger.d('🗓️ DailyRoadmapProvider inicializado para usuario $userId');
    } catch (e) {
      _setError('Error inicializando roadmap: $e');
      _logger.e('❌ Error inicializando DailyRoadmapProvider: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRoadmapForDate(int userId, DateTime date) async {
    try {
      _setLoading(true);
      _clearError();

      final roadmap = await _databaseService.getDailyRoadmap(
        userId: userId,
        targetDate: date,
      );

      if (roadmap != null) {
        _currentRoadmap = roadmap;
        _logger.d('🗓️ Roadmap cargado para fecha: ${date.toIso8601String().split('T')[0]}');
      } else {
        // Crear roadmap vacío para la fecha seleccionada
        _currentRoadmap = DailyRoadmapModel.create(
          userId: userId,
          targetDate: date,
        );
        _logger.d('🗓️ Creado nuevo roadmap para fecha: ${date.toIso8601String().split('T')[0]}');
      }

      _selectedDate = date;
      notifyListeners();
    } catch (e) {
      _setError('Error cargando roadmap: $e');
      _logger.e('❌ Error cargando roadmap: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRoadmapHistory(int userId, {int limit = 30}) async {
    try {
      final history = await _databaseService.getDailyRoadmaps(
        userId: userId,
        limit: limit,
      );

      _roadmapHistory = history;
      _logger.d('📋 Cargado historial de roadmaps: ${history.length} elementos');
      
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error cargando historial de roadmaps: $e');
    }
  }

  Future<bool> saveCurrentRoadmap() async {
    if (_currentRoadmap == null) return false;

    try {
      _setLoading(true);
      _clearError();

      // Actualizar estadísticas antes de guardar
      final updatedRoadmap = _currentRoadmap!.copyWith(
        completionPercentage: completionPercentage,
        totalActivities: totalActivities,
        completedActivities: completedActivities,
        status: _determineRoadmapStatus(),
      );

      final savedId = await _databaseService.saveDailyRoadmap(updatedRoadmap);
      
      if (savedId != null) {
        _currentRoadmap = updatedRoadmap.copyWith(id: savedId);
        _logger.d('💾 Roadmap guardado exitosamente con ID: $savedId');
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('Error guardando roadmap: $e');
      _logger.e('❌ Error guardando roadmap: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================================
  // MÉTODOS DE ACTIVIDADES
  // ============================================================================

  Future<bool> addActivity({
    required String title,
    required int hour,
    required int minute,
    String? description,
    ActivityPriority priority = ActivityPriority.medium,
    String? category,
    List<String> tags = const [],
    int? estimatedDuration,
  }) async {
    if (_currentRoadmap == null) return false;

    try {
      final activity = RoadmapActivityModel.create(
        hour: hour,
        minute: minute,
        title: title,
        description: description,
        priority: priority,
        category: category,
        tags: tags,
        estimatedDuration: estimatedDuration,
      );

      _currentRoadmap = _currentRoadmap!.addActivity(activity);
      
      _logger.d('➕ Actividad agregada: $title a las ${activity.timeString}');
      notifyListeners();
      
      return await saveCurrentRoadmap();
    } catch (e) {
      _setError('Error agregando actividad: $e');
      _logger.e('❌ Error agregando actividad: $e');
      return false;
    }
  }

  Future<bool> updateActivity(RoadmapActivityModel updatedActivity) async {
    if (_currentRoadmap == null) return false;

    try {
      _currentRoadmap = _currentRoadmap!.updateActivity(updatedActivity);
      
      _logger.d('✏️ Actividad actualizada: ${updatedActivity.title}');
      notifyListeners();
      
      return await saveCurrentRoadmap();
    } catch (e) {
      _setError('Error actualizando actividad: $e');
      _logger.e('❌ Error actualizando actividad: $e');
      return false;
    }
  }

  Future<bool> removeActivity(String activityId) async {
    if (_currentRoadmap == null) return false;

    try {
      _currentRoadmap = _currentRoadmap!.removeActivity(activityId);
      
      _logger.d('🗑️ Actividad eliminada: $activityId');
      notifyListeners();
      
      return await saveCurrentRoadmap();
    } catch (e) {
      _setError('Error eliminando actividad: $e');
      _logger.e('❌ Error eliminando actividad: $e');
      return false;
    }
  }

  Future<bool> toggleActivityCompletion(String activityId) async {
    if (_currentRoadmap == null) return false;

    try {
      final activity = _currentRoadmap!.activities
          .where((a) => a.id == activityId)
          .firstOrNull;

      if (activity == null) return false;

      final updatedActivity = activity.copyWith(
        isCompleted: !activity.isCompleted,
        completedAt: !activity.isCompleted ? DateTime.now() : null,
      );

      return await updateActivity(updatedActivity);
    } catch (e) {
      _setError('Error cambiando estado de actividad: $e');
      _logger.e('❌ Error cambiando estado de actividad: $e');
      return false;
    }
  }

  Future<bool> updateActivityMood(String activityId, ActivityMood mood, {bool isPlanned = false}) async {
    if (_currentRoadmap == null) return false;

    try {
      final activity = _currentRoadmap!.activities
          .where((a) => a.id == activityId)
          .firstOrNull;

      if (activity == null) return false;

      final updatedActivity = activity.copyWith(
        plannedMood: isPlanned ? mood : activity.plannedMood,
        actualMood: !isPlanned ? mood : activity.actualMood,
      );

      return await updateActivity(updatedActivity);
    } catch (e) {
      _setError('Error actualizando mood de actividad: $e');
      _logger.e('❌ Error actualizando mood de actividad: $e');
      return false;
    }
  }

  Future<bool> updateActivityNotes(String activityId, String notes, {bool isFeelings = false}) async {
    if (_currentRoadmap == null) return false;

    try {
      final activity = _currentRoadmap!.activities
          .where((a) => a.id == activityId)
          .firstOrNull;

      if (activity == null) return false;

      final updatedActivity = activity.copyWith(
        notes: !isFeelings ? notes : activity.notes,
        feelingsNotes: isFeelings ? notes : activity.feelingsNotes,
      );

      return await updateActivity(updatedActivity);
    } catch (e) {
      _setError('Error actualizando notas de actividad: $e');
      _logger.e('❌ Error actualizando notas de actividad: $e');
      return false;
    }
  }

  // ============================================================================
  // MÉTODOS DE ROADMAP
  // ============================================================================

  Future<bool> updateDailyGoal(String goal) async {
    if (_currentRoadmap == null) return false;

    try {
      _currentRoadmap = _currentRoadmap!.copyWith(dailyGoal: goal);
      notifyListeners();
      return await saveCurrentRoadmap();
    } catch (e) {
      _setError('Error actualizando meta diaria: $e');
      return false;
    }
  }

  Future<bool> updateMorningNotes(String notes) async {
    if (_currentRoadmap == null) return false;

    try {
      _currentRoadmap = _currentRoadmap!.copyWith(morningNotes: notes);
      notifyListeners();
      return await saveCurrentRoadmap();
    } catch (e) {
      _setError('Error actualizando notas matutinas: $e');
      return false;
    }
  }

  Future<bool> updateEveningReflection(String reflection) async {
    if (_currentRoadmap == null) return false;

    try {
      _currentRoadmap = _currentRoadmap!.copyWith(eveningReflection: reflection);
      notifyListeners();
      return await saveCurrentRoadmap();
    } catch (e) {
      _setError('Error actualizando reflexión vespertina: $e');
      return false;
    }
  }

  Future<bool> updateOverallMood(ActivityMood mood) async {
    if (_currentRoadmap == null) return false;

    try {
      _currentRoadmap = _currentRoadmap!.copyWith(overallMood: mood);
      notifyListeners();
      return await saveCurrentRoadmap();
    } catch (e) {
      _setError('Error actualizando mood general: $e');
      return false;
    }
  }

  // ============================================================================
  // UTILIDADES
  // ============================================================================

  void changeSelectedDate(DateTime newDate) {
    if (_selectedDate != newDate) {
      _selectedDate = newDate;
      notifyListeners();
      
      // Cargar roadmap para la nueva fecha si hay un usuario disponible
      if (_currentRoadmap != null) {
        loadRoadmapForDate(_currentRoadmap!.userId, newDate);
      }
    }
  }

  RoadmapStatus _determineRoadmapStatus() {
    if (totalActivities == 0) return RoadmapStatus.planned;
    
    final completionRate = completionPercentage / 100;
    
    if (completionRate >= 1.0) return RoadmapStatus.completed;
    if (completionRate >= 0.5) return RoadmapStatus.partiallyCompleted;
    if (completionRate > 0.0) return RoadmapStatus.inProgress;
    
    return RoadmapStatus.planned;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  void _clearError() {
    _setError(null);
  }

  // ============================================================================
  // LIMPIEZA
  // ============================================================================

  void reset() {
    _currentRoadmap = null;
    _isLoading = false;
    _error = null;
    _selectedDate = DateTime.now();
    _roadmapHistory.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _logger.d('🗓️ DailyRoadmapProvider dispose');
    super.dispose();
  }
}

