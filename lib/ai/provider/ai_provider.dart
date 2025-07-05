// lib/ai/provider/ai_provider.dart
// VERSIÓN ACTUALIZADA PARA GENAI IMPLEMENTATION

import 'package:flutter/foundation.dart';
import '../services/phi_model_service_genai_complete.dart'; // ✅ UPDATED: New GenAI service
import '../models/ai_response_model.dart';

class AIProvider extends ChangeNotifier {
  bool _isInitialized = false;
  bool _isInitializing = false;
  String _status = 'No inicializado';
  double _initProgress = 0.0;
  AIResponseModel? _lastSummary;
  String? _errorMessage;

  // ✅ NEW: GenAI availability status
  bool _isGenAIAvailable = false;

  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  String get status => _status;
  double get initProgress => _initProgress;
  AIResponseModel? get lastSummary => _lastSummary;
  String? get errorMessage => _errorMessage;
  bool get isGenAIAvailable => _isGenAIAvailable; // ✅ NEW: Expose GenAI status

  /// Inicia el proceso completo de inicia l ización de la IA.
  Future<void> initializeAI() async {
    if (_isInitialized || _isInitializing) return;

    _isInitializing = true;
    _initProgress = 0.0;
    _errorMessage = null;
    _status = 'Preparando para inicializar...';
    notifyListeners();

    try {
      // ✅ UPDATED: Use new GenAI service
      final success = await PhiModelServiceGenAI.instance.initialize(
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

      // ✅ NEW: Get GenAI availability status
      if (success) {
        _isGenAIAvailable = PhiModelServiceGenAI.instance.isGenAIAvailable;
        debugPrint('🤖 GenAI Mode: ${_isGenAIAvailable ? "Native" : "Compatible"}');
      }

      if (!success) {
        _errorMessage = "No se pudo inicializar la IA. Revisa tu conexión.";
      }
    } catch (e) {
      _errorMessage = "Error fatal durante la inicialización: $e";
      debugPrint('❌ Error en AIProvider.initializeAI: $e');
    } finally {
      _isInitializing = false;

      // ✅ UPDATED: More informative status message
      if (_isInitialized) {
        _status = _isGenAIAvailable ?
        'IA lista (modo nativo)' :
        'IA lista (modo compatible)';
      } else {
        _status = 'Error en la inicialización';
      }

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
    _errorMessage = null; // ✅ NEW: Clear previous errors
    notifyListeners();

    try {
      debugPrint('🤖 Iniciando generación de resumen semanal...');
      debugPrint('📊 Datos: ${weeklyEntries.length} entradas, ${weeklyMoments.length} momentos');

      // ✅ UPDATED: Use new GenAI service
      final summary = await PhiModelServiceGenAI.instance.generateWeeklySummary(
        weeklyEntries: weeklyEntries,
        weeklyMoments: weeklyMoments,
        userName: userName,
      );

      _lastSummary = summary;

      if (summary != null) {
        _status = 'Resumen generado correctamente';
        debugPrint('✅ Resumen generado exitosamente: ${summary.summary.length} caracteres');
      } else {
        _status = 'Error generando resumen';
        _errorMessage = 'No se pudo generar el resumen. Inténtalo de nuevo.';
        debugPrint('❌ Resumen generado fue null');
      }

      return summary;
    } catch (e) {
      _errorMessage = 'Error generando resumen: $e';
      _status = 'Error en la generación';
      debugPrint('❌ Error en generateWeeklySummary: $e');
      return null;
    } finally {
      notifyListeners();
    }
  }

  /// ✅ NEW: Method to get detailed AI status
  Map<String, dynamic> getAIStatus() {
    return {
      'isInitialized': _isInitialized,
      'isInitializing': _isInitializing,
      'isGenAIAvailable': _isGenAIAvailable,
      'status': _status,
      'hasError': _errorMessage != null,
      'errorMessage': _errorMessage,
      'progress': _initProgress,
      'lastSummaryGenerated': _lastSummary != null,
    };
  }

  /// ✅ NEW: Method to reset AI state (useful for debugging)
  Future<void> resetAI() async {
    if (_isInitializing) {
      debugPrint('⚠️ Cannot reset AI while initializing');
      return;
    }

    try {
      // Dispose current service if needed
      if (_isInitialized) {
        PhiModelServiceGenAI.instance.dispose();
      }

      // Reset state
      _isInitialized = false;
      _isInitializing = false;
      _isGenAIAvailable = false;
      _status = 'No inicializado';
      _initProgress = 0.0;
      _lastSummary = null;
      _errorMessage = null;

      notifyListeners();
      debugPrint('🔄 AI state reset successfully');
    } catch (e) {
      debugPrint('❌ Error resetting AI: $e');
      _errorMessage = 'Error reiniciando IA: $e';
      notifyListeners();
    }
  }

  /// ✅ NEW: Method to check if AI can generate summaries
  bool canGenerateSummary() {
    return _isInitialized && !_isInitializing && _errorMessage == null;
  }

  /// ✅ NEW: Method to clear errors
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// ✅ UPDATED: Enhanced dispose method
  @override
  void dispose() {
    try {
      if (_isInitialized) {
        PhiModelServiceGenAI.instance.dispose();
      }
    } catch (e) {
      debugPrint('❌ Error disposing AI service: $e');
    }
    super.dispose();
  }
}