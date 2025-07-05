// lib/ai/services/phi_model_service_chat_extension.dart
// ============================================================================
// EXTENSIÓN DEL SERVICIO DE IA PARA CHAT CONVERSACIONAL
// ============================================================================

import 'package:flutter/foundation.dart';
import 'phi_model_service_genai_complete.dart';
import 'genai_platform_interface.dart';

/// Extensión del servicio de IA para manejar chat conversacional
extension ChatExtension on PhiModelServiceGenAI {

  /// Genera respuesta de chat usando la IA real
  Future<String> generateChatResponse({
    required String userMessage,
    required String conversationHistory,
    required String userName,
  }) async {
    if (!isInitialized) {
      throw Exception('El servicio de IA no está inicializado');
    }

    debugPrint('🗣️ Generando respuesta de chat...');
    debugPrint('👤 Usuario: $userName');
    debugPrint('💬 Mensaje: ${userMessage.substring(0, userMessage.length > 50 ? 50 : userMessage.length)}...');
    debugPrint('📜 Historial: ${conversationHistory.length} caracteres');

    try {
      // Crear prompt específico para chat
      final chatPrompt = _buildChatPrompt(
        userMessage: userMessage,
        conversationHistory: conversationHistory,
        userName: userName,
      );

      String response;

      if (isGenAIAvailable) {
        // Usar GenAI nativo
        response = await _generateChatWithNativeGenAI(chatPrompt);
      } else {
        // Si GenAI no está disponible, fallar completamente
        throw Exception('GenAI no está disponible para generar respuestas de chat');
      }

      debugPrint('✅ Respuesta generada: ${response.length} caracteres');
      return response;

    } catch (e) {
      debugPrint('❌ Error generando respuesta de chat: $e');
      rethrow; // Re-lanzar error sin fallback
    }
  }

  /// Construye el prompt específico para chat conversacional
  String _buildChatPrompt({
    required String userMessage,
    required String conversationHistory,
    required String userName,
  }) {
    return '''
Eres un Coach de IA especializado en bienestar y desarrollo personal. Tu nombre es "Coach IA" y tu rol es:

PERSONALIDAD:
- Empático, comprensivo y motivador
- Profesional pero cálido y accesible
- Enfocado en el bienestar integral de la persona
- Propositivo y orientado a soluciones

ESPECIALIDADES:
- Bienestar emocional y mental
- Gestión del estrés y ansiedad
- Mejora de hábitos saludables
- Desarrollo personal y autocuidado
- Análisis de patrones de comportamiento

ESTILO DE COMUNICACIÓN:
- Respuestas naturales y conversacionales
- Preguntas reflexivas cuando sea apropiado
- Consejos prácticos y aplicables
- Validación emocional
- Longitud apropiada (ni muy corto ni muy largo)

${conversationHistory.isNotEmpty ? '''
CONTEXTO DE LA CONVERSACIÓN:
$conversationHistory
''' : ''}

MENSAJE ACTUAL DEL USUARIO ($userName):
$userMessage

INSTRUCCIONES:
1. Responde como Coach IA manteniendo coherencia con la conversación anterior
2. Si es un saludo inicial, preséntate brevemente y pregunta cómo puedes ayudar
3. Si el usuario menciona problemas específicos, ofrece apoyo y estrategias concretas
4. Si pide análisis de patrones, sugiere que revises sus reflexiones y datos
5. Mantén un tono profesional pero cálido
6. No inventes información sobre el usuario que no tengas
7. Si necesitas más información para ayudar mejor, pregunta específicamente

Responde ahora como Coach IA:
''';
  }

  /// Genera respuesta usando GenAI nativo para chat
  Future<String> _generateChatWithNativeGenAI(String prompt) async {
    debugPrint('🚀 Generando respuesta de chat con GenAI nativo...');

    final response = await GenAIPlatformInterface.generateText(
      prompt,
      maxTokens: 300, // Respuestas de chat más concisas
      temperature: 0.8, // Más creatividad para conversación natural
      topP: 0.9,
    );

    if (response == null || response.isEmpty) {
      throw Exception('GenAI no devolvió respuesta válida para el chat');
    }

    return _cleanupChatResponse(response);
  }

  /// Limpia la respuesta de chat
  String _cleanupChatResponse(String response) {
    // Remover tokens especiales del modelo
    String cleaned = response
        .replaceAll('<|assistant|>', '')
        .replaceAll('<|end|>', '')
        .replaceAll('<|user|>', '')
        .replaceAll('<|system|>', '')
        .replaceAll('Coach IA:', '') // Remover prefijo si aparece
        .replaceAll('Respuesta:', ''); // Remover otros prefijos comunes

    // Limpiar espacios extra y líneas vacías
    cleaned = cleaned
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n')
        .trim();

    // Si la respuesta está vacía después de la limpieza, generar error
    if (cleaned.isEmpty) {
      throw Exception('La IA generó una respuesta vacía');
    }

    // Si la respuesta es muy corta (menos de 10 caracteres), probablemente es un error
    if (cleaned.length < 10) {
      throw Exception('La IA generó una respuesta demasiado corta: "$cleaned"');
    }

    // Si la respuesta es muy larga (más de 1000 caracteres), truncar
    if (cleaned.length > 1000) {
      cleaned = cleaned.substring(0, 1000) + '...';
      debugPrint('⚠️ Respuesta truncada por ser muy larga');
    }

    return cleaned;
  }

  /// Verifica si el servicio puede manejar chat
  bool get canHandleChat => isInitialized && isGenAIAvailable;

  /// Obtiene información del estado del chat
  Map<String, dynamic> getChatCapabilities() {
    return {
      'chat_available': canHandleChat,
      'ai_initialized': isInitialized,
      'genai_available': isGenAIAvailable,
      'can_generate_responses': canHandleChat,
      'error_if_unavailable': !canHandleChat ? 'IA no disponible para chat' : null,
    };
  }
}