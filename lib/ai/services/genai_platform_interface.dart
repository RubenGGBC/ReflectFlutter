// lib/ai/services/genai_platform_interface.dart
// INTERFAZ PARA COMUNICACIÓN CON CÓDIGO NATIVO

import 'package:flutter/services.dart';

class GenAIPlatformInterface {
  static const MethodChannel _channel = MethodChannel('com.yourapp.genai');

  /// Inicializa el modelo GenAI nativo
  static Future<bool> initializeModel(String modelPath) async {
    try {
      final result = await _channel.invokeMethod('initializeModel', {
        'modelPath': modelPath,
      });
      return result as bool;
    } catch (e) {
      print('Error initializing GenAI model: $e');
      return false;
    }
  }

  /// Genera texto usando GenAI
  static Future<String?> generateText(String prompt, {
    int maxTokens = 512,
    double temperature = 0.7,
    double topP = 0.9,
  }) async {
    try {
      final result = await _channel.invokeMethod('generateText', {
        'prompt': prompt,
        'maxTokens': maxTokens,
        'temperature': temperature,
        'topP': topP,
      });
      return result as String?;
    } catch (e) {
      print('Error generating text: $e');
      return null;
    }
  }

  /// Libera recursos del modelo
  static Future<void> disposeModel() async {
    try {
      await _channel.invokeMethod('disposeModel');
    } catch (e) {
      print('Error disposing model: $e');
    }
  }

  /// Verifica si GenAI está disponible en la plataforma
  static Future<bool> isGenAIAvailable() async {
    try {
      final result = await _channel.invokeMethod('isGenAIAvailable');
      return result as bool;
    } catch (e) {
      print('Error checking GenAI availability: $e');
      return false;
    }
  }
}