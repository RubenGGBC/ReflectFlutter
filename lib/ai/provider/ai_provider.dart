// lib/ai/provider/ai_provider.dart
// VERSIÓN CORREGIDA SIN LA DIRECTIVA 'hide'

import 'package:flutter/foundation.dart';
import '../services/phi_model_service.dart';
import '../models/ai_response_model.dart'; // ✅ CORREGIDO: Se eliminó 'hide AIResponseModel'

class AIProvider extends ChangeNotifier {
  bool _isInitialized = false;
  bool _isInitializing = false;
  String _status = 'No inicializado';
  double _initProgress = 0.0;
  AIResponseModel? _lastSummary;
  String? _errorMessage;

  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  String get status => _status;
  double get initProgress => _initProgress;
  AIResponseModel? get lastSummary => _lastSummary;
  String? get errorMessage => _errorMessage;

  /// Inicia el proceso completo de inicialización de la IA.
  Future<void> initializeAI() async {
    if (_isInitialized || _isInitializing) return;

    _isInitializing = true;
    _initProgress = 0.0;
    _errorMessage = null;
    _status = 'Preparando para inicializar...';
    notifyListeners();

    try {
      final success = await PhiModelService.instance.initialize(
        onStatusUpdate: (status) {
          _status = status;
          notifyListeners();
        },
        onProgress: (progress) {
          _initProgress = progress;
          notifyListeners();
        },
      );

      _isInitialized = success;
      if (!success) {
        _errorMessage = "No se pudo inicializar la IA. Revisa tu conexión.";
      }
    } catch (e) {
      _errorMessage = "Error fatal durante la inicialización: $e";
    } finally {
      _isInitializing = false;
      _status = _isInitialized ? 'IA lista para usar' : 'Error en la inicialización';
      notifyListeners();
    }
  }

  /// Genera el resumen semanal.
  Future<AIResponseModel?> generateWeeklySummary({
    required List<Map<String, dynamic>> weeklyEntries,
    required List<Map<String, dynamic>> weeklyMoments,
    required String userName,
  }) async {
    if (!_isInitialized) {
      _errorMessage = 'La IA no está lista. Por favor, inicialízala primero.';
      notifyListeners();
      return null;
    }

    _status = 'Generando resumen con IA...';
    _lastSummary = null;
    notifyListeners();

    try {
      final summary = await PhiModelService.instance.generateWeeklySummary(
        weeklyEntries: weeklyEntries,
        weeklyMoments: weeklyMoments,
        userName: userName,
      );

      _lastSummary = summary;
      _status = 'Resumen generado correctamente';
      return summary;
    } catch (e) {
      _errorMessage = 'Error generando resumen: $e';
      return null;
    } finally {
      notifyListeners();
    }
  }
}
