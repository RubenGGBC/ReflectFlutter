import 'package:flutter/foundation.dart';
import '/ai/services/phi_model_service.dart';
import '/ai/models/ai_response_model.dart' hide AIResponseModel;

class AIProvider extends ChangeNotifier {
  bool _isInitialized = false;
  bool _isInitializing = false;
  String _status = 'No inicializado';
  double _initProgress = 0.0;
  AIResponseModel? _lastSummary;

  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  String get status => _status;
  double get initProgress => _initProgress;
  AIResponseModel? get lastSummary => _lastSummary;

  Future<void> initializeAI() async {
    if (_isInitialized || _isInitializing) return;

    _isInitializing = true;
    notifyListeners();

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
    _isInitializing = false;
    _status = success ? 'IA lista para usar' : 'Error inicializando IA';
    notifyListeners();
  }

  Future<AIResponseModel?> generateWeeklySummary({
    required List<Map<String, dynamic>> weeklyEntries,
    required List<Map<String, dynamic>> weeklyMoments,
    required String userName,
  }) async {
    if (!_isInitialized) {
      await initializeAI();
    }

    _status = 'Generando resumen semanal...';
    notifyListeners();

    try {
      final summary = await PhiModelService.instance.generateWeeklySummary(
        weeklyEntries: weeklyEntries,
        weeklyMoments: weeklyMoments,
        userName: userName,
      );

      _lastSummary = summary;
      _status = 'Resumen generado correctamente';
      notifyListeners();

      return summary;
    } catch (e) {
      _status = 'Error generando resumen: $e';
      notifyListeners();
      return null;
    }
  }
}