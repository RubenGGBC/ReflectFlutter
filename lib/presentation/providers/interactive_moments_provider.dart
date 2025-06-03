// ============================================================================
// presentation/providers/interactive_moments_provider.dart - VERSIÓN CORREGIDA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../data/models/interactive_moment_model.dart';
import '../../data/services/database_service.dart';

class InteractiveMomentsProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  final Logger _logger = Logger();

  List<InteractiveMomentModel> _moments = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<InteractiveMomentModel> get moments => List.unmodifiable(_moments);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalCount => _moments.length;
  int get positiveCount => _moments.where((m) => m.type == 'positive').length;
  int get negativeCount => _moments.where((m) => m.type == 'negative').length;

  InteractiveMomentsProvider(this._databaseService);

  /// Cargar momentos del día actual
  Future<void> loadTodayMoments(int userId) async {
    _logger.d('📚 Cargando momentos del día para usuario: $userId');
    _setLoading(true);
    _clearError();

    try {
      // ✅ CORREGIR: Usar el método correcto del DatabaseService
      final momentsData = await _databaseService.getInteractiveMomentsToday(userId);

      _moments = momentsData; // Ya son InteractiveMomentModel
      _logger.i('✅ Cargados ${_moments.length} momentos del día');

    } catch (e) {
      _logger.e('❌ Error cargando momentos: $e');
      _setError('Error cargando momentos del día');
    } finally {
      _setLoading(false);
    }
  }

  /// Añadir nuevo momento
  Future<bool> addMoment({
    required int userId,
    required String emoji,
    required String text,
    required String type,
    int intensity = 5,
    String category = 'general',
    String? timeStr,
  }) async {
    _logger.d('💾 Añadiendo momento: $emoji $text');

    try {
      final moment = InteractiveMomentModel.create(
        emoji: emoji,
        text: text,
        type: type,
        intensity: intensity,
        category: category,
        timeStr: timeStr,
      );

      // ✅ CORREGIR: Usar el método correcto
      final momentId = await _databaseService.saveInteractiveMoment(userId, moment);

      if (momentId != null) {
        // Añadir al estado local
        _moments.add(moment);

        _logger.i('✅ Momento añadido correctamente');
        notifyListeners();
        return true;
      } else {
        _logger.e('❌ Error guardando momento en BD');
        _setError('Error guardando momento');
        return false;
      }

    } catch (e) {
      _logger.e('❌ Error añadiendo momento: $e');
      _setError('Error añadiendo momento');
      return false;
    }
  }

  /// Limpiar todos los momentos del día
  Future<bool> clearAllMoments(int userId) async {
    _logger.d('🗑️ Limpiando todos los momentos del día');
    _setLoading(true);

    try {
      final success = await _databaseService.clearInteractiveMomentsToday(userId);

      if (success) {
        _moments.clear();
        _logger.i('✅ Momentos eliminados correctamente');
        notifyListeners();
        return true;
      } else {
        _setError('Error eliminando momentos');
        return false;
      }

    } catch (e) {
      _logger.e('❌ Error limpiando momentos: $e');
      _setError('Error eliminando momentos');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Guardar momentos como entrada diaria
  Future<int?> saveMomentsAsEntry(
      int userId, {
        String? reflection,
        bool? worthIt,
      }) async {
    _logger.d('💾 Guardando ${_moments.length} momentos como entrada diaria');
    _setLoading(true);

    try {
      if (_moments.isEmpty) {
        _setError('No hay momentos para guardar');
        return null;
      }

      // ✅ CORREGIR: Usar el método correcto
      final entryId = await _databaseService.saveInteractiveMomentsAsEntry(
        userId,
        reflection: reflection ?? 'Entrada creada desde Momentos Interactivos',
        worthIt: worthIt ?? (positiveCount > negativeCount),
      );

      if (entryId != null) {
        _logger.i('✅ Entrada diaria creada con ID: $entryId');
        // Los momentos ya se eliminaron automáticamente en el método de BD
        _moments.clear();
        notifyListeners();
        return entryId;
      } else {
        _setError('Error creando entrada diaria');
        return null;
      }

    } catch (e) {
      _logger.e('❌ Error guardando entrada: $e');
      _setError('Error guardando entrada diaria');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener momentos por tipo
  List<InteractiveMomentModel> getMomentsByType(String type) {
    return _moments.where((moment) => moment.type == type).toList();
  }

  /// Obtener momentos por categoría
  List<InteractiveMomentModel> getMomentsByCategory(String category) {
    return _moments.where((moment) => moment.category == category).toList();
  }

  /// Obtener resumen del día
  Map<String, dynamic> getDaySummary() {
    final positive = positiveCount;
    final negative = negativeCount;
    final total = totalCount;

    String mood = 'balanced';
    if (positive > negative) {
      mood = 'positive';
    } else if (negative > positive) {
      mood = 'negative';
    }

    return {
      'total_moments': total,
      'positive_count': positive,
      'negative_count': negative,
      'overall_mood': mood,
      'balance_score': total > 0 ? (positive - negative) / total : 0.0,
      'categories': _moments.map((m) => m.category).toSet().toList(),
    };
  }

  /// Helpers para manejar estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpiar provider
  void clear() {
    _moments.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}