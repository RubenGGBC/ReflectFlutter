// lib/ai/services/phi_model_service.dart
// VERSIÓN CORREGIDA PARA USAR EL MODELO DESCARGADO

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:onnxruntime/onnxruntime.dart';

import '../models/ai_response_model.dart';
import '../prompts/wellness_coach_prompts.dart';
import 'model_downloader.dart';

class PhiModelService {
  static PhiModelService? _instance;
  static PhiModelService get instance => _instance ??= PhiModelService._();

  PhiModelService._();

  OrtSession? _session;
  OrtSessionOptions? _sessionOptions;
  bool _isInitialized = false;

  /// Inicializa el servicio, descargando el modelo si es necesario.
  Future<bool> initialize({
    required Function(String) onStatusUpdate,
    required Function(double) onProgress,
  }) async {
    if (_isInitialized) return true;

    try {
      onStatusUpdate('Inicializando ONNX Runtime...');
      OrtEnv.instance.init();
      _sessionOptions = OrtSessionOptions();

      final downloader = ModelDownloader();
      onStatusUpdate('Comprobando modelo de IA...');

      // El downloader se encargará de descargar o verificar el modelo existente
      final modelPath = await downloader.downloadModel(
        onProgress: onProgress,
        onStatusUpdate: onStatusUpdate,
      );

      onStatusUpdate('Cargando modelo en memoria...');
      // Cargamos la sesión desde el fichero descargado
      _session = OrtSession.fromFile(File(modelPath), _sessionOptions!);

      _isInitialized = true;
      onStatusUpdate('IA lista para usar');
      return true;

    } catch (e) {
      onStatusUpdate('Error inicializando IA: $e');
      debugPrint('❌ Error inicializando PhiModelService: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Genera un resumen semanal usando el modelo de IA.
  Future<AIResponseModel?> generateWeeklySummary({
    required List<Map<String, dynamic>> weeklyEntries,
    required List<Map<String, dynamic>> weeklyMoments,
    required String userName,
  }) async {
    if (!_isInitialized || _session == null) {
      throw Exception('El servicio de IA no está inicializado.');
    }

    try {
      final prompt = WellnessCoachPrompts.buildDetailedWeeklySummaryPrompt(
        weeklyEntries: weeklyEntries,
        weeklyMoments: weeklyMoments,
        userName: userName,
      );

      // La inferencia real se implementaría aquí.
      // Por ahora, simulamos una respuesta para demostrar el flujo.
      final responseText = await _runInference(prompt);

      return AIResponseModel.fromText(responseText);

    } catch (e) {
      debugPrint('❌ Error generando resumen: $e');
      return null;
    }
  }

  /// Ejecuta la inferencia en el modelo (implementación de ejemplo)
  Future<String> _runInference(String prompt) async {
    // Esta es una implementación SIMULADA. La lógica real depende
    // del tokenizer y de los tensores de entrada/salida del modelo.
    await Future.delayed(const Duration(seconds: 5)); // Simula tiempo de procesamiento
    return '''
RESUMEN SEMANAL:
Hola, basándome en tus entradas, esta semana parece haber tenido altibajos. Mencionaste sentirte "productivo" al inicio, pero también "algo de estrés" hacia el final. Tu energía fluctuó, pero mantuviste una buena actitud.

INSIGHTS PROFUNDOS:
• Parece que los picos de estrés coinciden con los días de más reuniones.
• Usas la palabra "cansado" a menudo, pero tu energía registrada no siempre es baja. Podría ser fatiga mental.

SUGERENCIAS PERSONALIZADAS:
• Intenta agendar pausas de 10 minutos después de reuniones largas.
• Cuando te sientas "cansado", pregúntate si es físico o mental y actúa en consecuencia.
''';
  }

  void dispose() {
    _session?.release();
    _sessionOptions?.release();
    OrtEnv.instance.release();
    _isInitialized = false;
  }
}