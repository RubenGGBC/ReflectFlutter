// lib/ai/provider/predictive_analysis_provider.dart
// ============================================================================
// PROVIDER PARA ANÁLISIS PREDICTIVO - INTEGRACIÓN CON LA ARQUITECTURA
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../data/services/optimized_database_service.dart';
import '../services/predictive_analysis_service.dart';

class PredictiveAnalysisProvider extends ChangeNotifier {
  final OptimizedDatabaseService _databaseService;
  final PredictiveAnalysisService _predictiveService = PredictiveAnalysisService.instance;
  final Logger _logger = Logger();

  PredictiveAnalysisProvider(this._databaseService);

  // Estados para predicción de tendencias
  MoodTrendPrediction? _lastMoodPrediction;
  bool _isLoadingMoodPrediction = false;
  String? _moodPredictionError;

  // Estados para detección de burnout
  BurnoutRiskAssessment? _lastBurnoutAssessment;
  bool _isLoadingBurnoutAssessment = false;
  String? _burnoutAssessmentError;

  // Getters para predicción de tendencias
  MoodTrendPrediction? get lastMoodPrediction => _lastMoodPrediction;
  bool get isLoadingMoodPrediction => _isLoadingMoodPrediction;
  String? get moodPredictionError => _moodPredictionError;
  bool get hasMoodPrediction => _lastMoodPrediction != null;

  // Getters para detección de burnout
  BurnoutRiskAssessment? get lastBurnoutAssessment => _lastBurnoutAssessment;
  bool get isLoadingBurnoutAssessment => _isLoadingBurnoutAssessment;
  String? get burnoutAssessmentError => _burnoutAssessmentError;
  bool get hasBurnoutAssessment => _lastBurnoutAssessment != null;

  // Getters de conveniencia
  bool get isLoading => _isLoadingMoodPrediction || _isLoadingBurnoutAssessment;
  bool get hasAnyErrors => _moodPredictionError != null || _burnoutAssessmentError != null;

  /// 🔮 Ejecutar predicción de tendencias de ánimo
  Future<void> predictMoodTrends({
    required int userId,
    required int daysAhead,
  }) async {
    _logger.i('🔮 Iniciando predicción de tendencias desde Provider');

    _isLoadingMoodPrediction = true;
    _moodPredictionError = null;
    notifyListeners();

    try {
      final prediction = await _predictiveService.predictMoodTrends(
        userId: userId,
        daysAhead: daysAhead,
        databaseService: _databaseService,
      );

      _lastMoodPrediction = prediction;
      _moodPredictionError = null;

      _logger.i('✅ Predicción completada. Confianza: ${prediction.confidenceScore}');

    } catch (e) {
      _logger.e('❌ Error en predicción: $e');
      _moodPredictionError = e.toString();
      _lastMoodPrediction = null;
    } finally {
      _isLoadingMoodPrediction = false;
      notifyListeners();
    }
  }

  /// 🚨 Ejecutar detección de riesgo de burnout
  Future<void> detectBurnoutRisk({
    required int userId,
  }) async {
    _logger.i('🚨 Iniciando detección de burnout desde Provider');

    _isLoadingBurnoutAssessment = true;
    _burnoutAssessmentError = null;
    notifyListeners();

    try {
      final assessment = await _predictiveService.detectBurnoutRisk(
        userId: userId,
        databaseService: _databaseService,
      );

      _lastBurnoutAssessment = assessment;
      _burnoutAssessmentError = null;

      _logger.i('✅ Detección completada. Riesgo: ${assessment.riskLevel} (${assessment.burnoutRiskScore}/100)');

    } catch (e) {
      _logger.e('❌ Error en detección de burnout: $e');
      _burnoutAssessmentError = e.toString();
      _lastBurnoutAssessment = null;
    } finally {
      _isLoadingBurnoutAssessment = false;
      notifyListeners();
    }
  }

  /// 🔄 Ejecutar ambos análisis en paralelo
  Future<void> runCompleteAnalysis({
    required int userId,
    int daysAhead = 7, // Por defecto predecir 7 días
  }) async {
    _logger.i('🔄 Ejecutando análisis predictivo completo');

    // Ejecutar ambos análisis en paralelo
    await Future.wait([
      predictMoodTrends(userId: userId, daysAhead: daysAhead),
      detectBurnoutRisk(userId: userId),
    ]);

    _logger.i('✅ Análisis predictivo completo finalizado');
  }

  /// 🧹 Limpiar estados
  void clearPredictions() {
    _lastMoodPrediction = null;
    _lastBurnoutAssessment = null;
    _moodPredictionError = null;
    _burnoutAssessmentError = null;
    _isLoadingMoodPrediction = false;
    _isLoadingBurnoutAssessment = false;
    notifyListeners();
  }

  /// 📊 Obtener resumen del estado actual
  Map<String, dynamic> getAnalysisSummary() {
    return {
      'mood_prediction': {
        'available': _lastMoodPrediction != null,
        'confidence': _lastMoodPrediction?.confidenceScore,
        'risk_days_count': _lastMoodPrediction?.riskDays.length ?? 0,
        'error': _moodPredictionError,
      },
      'burnout_assessment': {
        'available': _lastBurnoutAssessment != null,
        'risk_score': _lastBurnoutAssessment?.burnoutRiskScore,
        'risk_level': _lastBurnoutAssessment?.riskLevel,
        'risk_factors_count': _lastBurnoutAssessment?.riskFactors.length ?? 0,
        'error': _burnoutAssessmentError,
      },
      'overall_status': {
        'is_loading': isLoading,
        'has_errors': hasAnyErrors,
        'last_analysis': _getLastAnalysisTime(),
      }
    };
  }

  /// ⏰ Obtener tiempo del último análisis
  String? _getLastAnalysisTime() {
    // En implementación real, guardar timestamps
    return null;
  }

  /// 🎯 Verificar si necesita actualización
  bool needsUpdate() {
    // Verificar si han pasado más de X horas desde último análisis
    // O si hay nuevos datos disponibles
    return _lastMoodPrediction == null || _lastBurnoutAssessment == null;
  }

  /// 📈 Obtener recomendaciones prioritarias
  List<String> getPriorityRecommendations() {
    final recommendations = <String>[];

    // Recomendaciones de burnout (más críticas)
    if (_lastBurnoutAssessment != null) {
      if (_lastBurnoutAssessment!.burnoutRiskScore >= 75) {
        recommendations.addAll(_lastBurnoutAssessment!.interventionSuggestions.take(2));
      }
    }

    // Recomendaciones de predicción de ánimo
    if (_lastMoodPrediction != null) {
      if (_lastMoodPrediction!.riskDays.isNotEmpty) {
        recommendations.addAll(_lastMoodPrediction!.preventiveSuggestions.take(2));
      }
    }

    return recommendations.take(3).toList(); // Máximo 3 recomendaciones prioritarias
  }

  /// 🔥 Verificar si hay alertas críticas
  bool hasCriticalAlerts() {
    // Burnout crítico
    if (_lastBurnoutAssessment?.burnoutRiskScore != null &&
        _lastBurnoutAssessment!.burnoutRiskScore >= 75) {
      return true;
    }

    // Múltiples días de riesgo predichos
    if (_lastMoodPrediction?.riskDays != null &&
        _lastMoodPrediction!.riskDays.length >= 3) {
      return true;
    }

    return false;
  }

  /// 📱 Preparar datos para mostrar en UI
  Map<String, dynamic> getUIDisplayData() {
    return {
      'mood_trend': {
        'has_data': _lastMoodPrediction != null,
        'confidence_percentage': _lastMoodPrediction != null
            ? (_lastMoodPrediction!.confidenceScore * 100).round()
            : 0,
        'predicted_scores': _lastMoodPrediction?.predictedMoodScores ?? [],
        'risk_days_summary': _lastMoodPrediction?.riskDays.take(3).toList() ?? [],
        'top_suggestions': _lastMoodPrediction?.preventiveSuggestions.take(3).toList() ?? [],
      },
      'burnout_risk': {
        'has_data': _lastBurnoutAssessment != null,
        'risk_score': _lastBurnoutAssessment?.burnoutRiskScore?.round() ?? 0,
        'risk_level': _lastBurnoutAssessment?.riskLevel ?? 'Unknown',
        'risk_color': _getBurnoutRiskColor(),
        'top_factors': _lastBurnoutAssessment?.riskFactors.take(3).toList() ?? [],
        'immediate_actions': _lastBurnoutAssessment?.personalizedRecommendations['immediate'] ?? [],
      },
      'loading_states': {
        'mood_prediction': _isLoadingMoodPrediction,
        'burnout_assessment': _isLoadingBurnoutAssessment,
      },
      'errors': {
        'mood_prediction': _moodPredictionError,
        'burnout_assessment': _burnoutAssessmentError,
      }
    };
  }

  /// 🎨 Obtener color para el riesgo de burnout
  String _getBurnoutRiskColor() {
    if (_lastBurnoutAssessment == null) return 'gray';

    final score = _lastBurnoutAssessment!.burnoutRiskScore;
    if (score >= 75) return 'red';
    if (score >= 50) return 'orange';
    if (score >= 25) return 'yellow';
    return 'green';
  }
}