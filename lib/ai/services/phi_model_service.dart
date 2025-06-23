// lib/ai/services/phi_model_service.dart
// ✅ VERSIÓN CORREGIDA CON MANEJO DE NULL SAFETY

import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:flutter/services.dart';
// Asumiendo que estos ficheros existen en tu estructura de proyecto
// import '../models/ai_response_model.dart';
// import '../prompts/wellness_coach_prompts.dart';
// import 'model_downloader.dart';

// Modelos de datos simulados para que el fichero sea autocontenido y analizable
class AIResponseModel {
  final String summary;
  final List<String> insights;
  final List<String> suggestions;
  final double confidenceScore;
  final DateTime generatedAt;

  AIResponseModel({
    required this.summary,
    required this.insights,
    required this.suggestions,
    required this.confidenceScore,
    required this.generatedAt,
  });

  factory AIResponseModel.fromText(String text) {
    // Lógica de parsing simulada
    return AIResponseModel(
      summary: text,
      insights: ['Insight 1 basado en el texto.', 'Insight 2 basado en el texto.'],
      suggestions: ['Sugerencia 1.', 'Sugerencia 2.'],
      confidenceScore: 0.85,
      generatedAt: DateTime.now(),
    );
  }
}

class WellnessCoachPrompts {
  static String buildWeeklySummaryPrompt({
    required List<Map<String, dynamic>> weeklyEntries,
    required List<Map<String, dynamic>> weeklyMoments,
    required String userName,
  }) {
    // Lógica de construcción de prompt simulada
    return "Resume las siguientes entradas para $userName: $weeklyEntries y $weeklyMoments";
  }
}

class ModelDownloader {
  Future<bool> isModelDownloaded() async => true;
  Future<void> downloadModel({required Function(double) onProgress, required Function(String) onStatusUpdate}) async {}
  Future<String> getModelPath() async => 'assets/ai/phi-3-mini-4k-instruct-int8.tflite';
}


class PhiModelService {
  static PhiModelService? _instance;
  static PhiModelService get instance => _instance ??= PhiModelService._();

  PhiModelService._();

  OrtSession? _session;
  OrtSessionOptions? _sessionOptions;
  bool _isInitialized = false;
  bool _isInitializing = false;

  Future<bool> initialize({
    required Function(String) onStatusUpdate,
    required Function(double) onProgress,
  }) async {
    if (_isInitialized) return true;
    if (_isInitializing) return false;

    _isInitializing = true;

    try {
      onStatusUpdate('Inicializando ONNX Runtime...');

      // ✅ Inicializar ONNX Runtime Environment
      OrtEnv.instance.init();

      onStatusUpdate('Verificando modelo...');

      final downloader = ModelDownloader();
      final isDownloaded = await downloader.isModelDownloaded();

      Uint8List modelBytes;
      if (!isDownloaded) {
        onStatusUpdate('Descargando modelo...');
        await downloader.downloadModel(
          onProgress: onProgress,
          onStatusUpdate: onStatusUpdate,
        );
      }

      onStatusUpdate('Cargando modelo en memoria...');
      final modelPath = await downloader.getModelPath();

      // ✅ Leer archivo como bytes
      final file = await rootBundle.load(modelPath);
      modelBytes = file.buffer.asUint8List();

      onStatusUpdate('Configurando sesión ONNX...');

      // ✅ Configurar opciones de sesión correctamente
      _sessionOptions = OrtSessionOptions();

      // ✅ Crear sesión desde bytes (no desde archivo)
      _session = OrtSession.fromBuffer(modelBytes, _sessionOptions!);

      _isInitialized = true;
      _isInitializing = false;

      onStatusUpdate('IA inicializada correctamente');
      return true;

    } catch (e) {
      _isInitializing = false;
      onStatusUpdate('Error inicializando IA: $e');
      debugPrint('❌ Error inicializando PhiModelService: $e');
      return false;
    }
  }

  Future<AIResponseModel?> generateWeeklySummary({
    required List<Map<String, dynamic>> weeklyEntries,
    required List<Map<String, dynamic>> weeklyMoments,
    required String userName,
  }) async {
    if (!_isInitialized || _session == null) {
      throw Exception('El modelo no está inicializado');
    }

    try {
      final prompt = WellnessCoachPrompts.buildWeeklySummaryPrompt(
        weeklyEntries: weeklyEntries,
        weeklyMoments: weeklyMoments,
        userName: userName,
      );

      // ✅ Ejecutar inferencia con API correcta
      final response = await _runInference(prompt);

      return AIResponseModel.fromText(response);

    } catch (e) {
      debugPrint('❌ Error generando resumen: $e');
      // ✅ Fallback a respuesta simulada si la IA falla
      return _generateFallbackResponse(userName, weeklyEntries, weeklyMoments);
    }
  }

  Future<String> _runInference(String prompt) async {
    if (_session == null) throw Exception('Sesión no inicializada');

    // Declarar variables de recursos fuera del try para que estén disponibles en el finally
    OrtValue? inputTensor;
    OrtRunOptions? runOptions;
    List<OrtValue?>? outputs;

    try {
      // ✅ Tokenizar entrada (simplificado por ahora)
      final inputTokens = _tokenizeSimple(prompt);

      // ✅ Crear tensor con API correcta
      final inputShape = [1, inputTokens.length];
      inputTensor = OrtValueTensor.createTensorWithDataList(
        // Los modelos de lenguaje suelen usar enteros largos (int64)
        inputTokens.map((e) => BigInt.from(e)).toList(),
        inputShape,
      );

      // ✅ Crear mapa de entradas
      final inputs = {'input_ids': inputTensor};

      // ✅ Configurar opciones de ejecución
      runOptions = OrtRunOptions();

      // ✅ Ejecutar inferencia de forma asíncrona
      outputs = await _session!.runAsync(runOptions, inputs);

      // ✅ Procesar salida
      String result = 'Respuesta generada por IA';
      // ✅ FIX: Comprobar que 'outputs' no es nulo antes de usarlo
      if (outputs != null && outputs.isNotEmpty) {
        final outputValue = outputs.first;
        if (outputValue != null && outputValue is OrtValueTensor) {
          // Procesar tensor de salida
          result = _processOutput(outputValue);
        }
      }

      return result;

    } catch (e) {
      debugPrint('❌ Error en inferencia: $e');
      // Fallback a respuesta simulada
      return 'Error en IA, generando respuesta simulada...';
    } finally {
      // ✅ Limpiar todos los recursos de forma segura
      inputTensor?.release();
      runOptions?.release();
      // ✅ FIX: Comprobar que 'outputs' no es nulo antes de iterar
      if (outputs != null) {
        for (var element in outputs) {
          element?.release();
        }
      }
    }
  }

  List<int> _tokenizeSimple(String text) {
    // ✅ Tokenización simplificada - En producción usarías un tokenizer real
    // Por ahora, limitamos a 128 tokens máximo
    final words = text.split(' ');
    final tokens = <int>[];

    for (final word in words.take(120)) {
      // Convertir palabra a token simple (hash básico)
      final hash = word.hashCode.abs() % 30000 + 1000;
      tokens.add(hash);
    }

    // Padding hasta 128 tokens
    while (tokens.length < 128) {
      tokens.add(0); // padding token
    }

    return tokens.take(128).toList();
  }

  String _processOutput(OrtValueTensor outputTensor) {
    try {
      // ✅ Procesar tensor de salida (simplificado)
      // En un modelo real, aquí decodificarías los tokens a texto
      debugPrint("Tipo de salida: ${outputTensor.runtimeType}");
      debugPrint("Valor de salida: ${outputTensor.value}");
      return 'Análisis generado por el modelo de IA.';
    } catch (e) {
      debugPrint('❌ Error procesando salida: $e');
      return 'Error procesando respuesta de IA.';
    }
  }

  // ✅ Respuesta de fallback cuando la IA falla
  AIResponseModel _generateFallbackResponse(
      String userName,
      List<Map<String, dynamic>> entries,
      List<Map<String, dynamic>> moments,
      ) {
    return AIResponseModel(
      summary: 'Hola $userName, aunque la IA no está disponible ahora, puedo ver que has registrado ${entries.length} reflexiones y ${moments.length} momentos esta semana. Sigue así con tu práctica de autoconocimiento.',
      insights: [
        'Tu constancia en el registro muestra compromiso con tu bienestar',
        'Cada reflexión es un paso hacia mayor autoconocimiento',
      ],
      suggestions: [
        'Continúa registrando tus experiencias diarias',
        'Revisa tus entradas anteriores para identificar patrones',
      ],
      confidenceScore: 0.5,
      generatedAt: DateTime.now(),
    );
  }

  void dispose() {
    try {
      _session?.release();
      _sessionOptions?.release();
      OrtEnv.instance.release();
    } catch (e) {
      debugPrint('⚠️ Error limpiando recursos ONNX: $e');
    }
    _session = null;
    _sessionOptions = null;
    _isInitialized = false;
  }
}
