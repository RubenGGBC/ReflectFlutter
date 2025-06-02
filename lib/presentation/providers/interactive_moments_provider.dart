// ============================================================================
// presentation/providers/interactive_moments_provider.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../data/models/interactive_moment_model.dart';
import '../../data/models/daily_entry_model.dart';
import '../../data/services/database_service.dart';

class InteractiveMomentsProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  final Logger _logger = Logger();

  List<InteractiveMomentModel> _moments = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _autoSaveEnabled = true;

  InteractiveMomentsProvider(this._databaseService);

  // Getters
  List<InteractiveMomentModel> get moments => List.unmodifiable(_moments);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get autoSaveEnabled => _autoSaveEnabled;

  int get positiveCount => _moments.where((m) => m.type == 'positive').length;
  int get negativeCount => _moments.where((m) => m.type == 'negative').length;
  int get totalCount => _moments.length;

  /// Cargar momentos del día actual para un usuario
  Future<void> loadTodayMoments(int userId) async {
    _logger.i('📚 Cargando momentos del día para usuario $userId');
    _setLoading(true);
    _clearError();

    try {
      final moments = await _databaseService.getInteractiveMomentsToday(userId);
      _moments = moments;
      _logger.d('✅ Cargados ${moments.length} momentos');
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
    try {
      final moment = InteractiveMomentModel.create(
        emoji: emoji,
        text: text,
        type: type,
        intensity: intensity,
        category: category,
        timeStr: timeStr,
      );

      if (_autoSaveEnabled) {
        final momentId = await _databaseService.saveInteractiveMoment(userId, moment);
        if (momentId == null) {
          _setError('Error guardando momento');
          return false;
        }
      }

      _moments.add(moment);
      _clearError();

      _logger.d('✅ Momento añadido: $emoji $text');
      notifyListeners();
      return true;

    } catch (e) {
      _logger.e('❌ Error añadiendo momento: $e');
      _setError('Error añadiendo momento');
      return false;
    }
  }

  /// Eliminar momento
  Future<bool> removeMoment(String momentId, int userId) async {
    try {
      _moments.removeWhere((moment) => moment.id == momentId);

      // TODO: Implementar eliminación de BD individual si es necesario

      _logger.d('🗑️ Momento eliminado: $momentId');
      notifyListeners();
      return true;

    } catch (e) {
      _logger.e('❌ Error eliminando momento: $e');
      _setError('Error eliminando momento');
      return false;
    }
  }

  /// Limpiar todos los momentos
  Future<bool> clearAllMoments(int userId) async {
    _logger.i('🗑️ Limpiando todos los momentos para usuario $userId');
    _setLoading(true);

    try {
      await _databaseService.clearInteractiveMomentsToday(userId);
      _moments.clear();
      _clearError();

      _logger.i('✅ Momentos limpiados correctamente');
      return true;

    } catch (e) {
      _logger.e('❌ Error limpiando momentos: $e');
      _setError('Error limpiando momentos');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Guardar momentos como entrada diaria
  Future<int?> saveMomentsAsEntry(int userId, {String? reflection, bool? worthIt}) async {
    if (_moments.isEmpty) {
      _setError('No hay momentos para guardar');
      return null;
    }

    _logger.i('💾 Guardando ${_moments.length} momentos como entrada diaria');
    _setLoading(true);

    try {
      final entryId = await _databaseService.saveInteractiveMomentsAsEntry(
        userId,
        reflection: reflection,
        worthIt: worthIt,
      );

      if (entryId != null) {
        _clearError();
        _logger.i('✅ Momentos guardados como entrada ID: $entryId');
        return entryId;
      } else {
        _setError('Error guardando entrada');
        return null;
      }

    } catch (e) {
      _logger.e('❌ Error guardando momentos como entrada: $e');
      _setError('Error guardando entrada');
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

  /// Cambiar auto-guardado
  void setAutoSave(bool enabled) {
    _autoSaveEnabled = enabled;
    _logger.d('⚙️ Auto-guardado: ${enabled ? 'habilitado' : 'deshabilitado'}');
    notifyListeners();
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

  /// Limpiar estado al cambiar de usuario
  void reset() {
    _moments.clear();
    _clearError();
    _isLoading = false;
    notifyListeners();
  }
}