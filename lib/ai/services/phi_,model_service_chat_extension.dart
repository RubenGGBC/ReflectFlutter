// lib/ai/services/phi_model_service_chat_extension.dart
// ============================================================================
// EXTENSIÓN DEL SERVICIO DE IA PARA CHAT CONVERSACIONAL GENERAL
// ============================================================================

import 'package:flutter/foundation.dart';
import 'phi_model_service_genai_complete.dart';
import 'genai_platform_interface.dart';

/// Extensión del servicio de IA para manejar chat conversacional general
extension ChatExtension on PhiModelServiceGenAI {

  /// Genera respuesta de chat usando la IA real - MODIFICADO: Conversación general
  Future<String> generateChatResponse({
    required String userMessage,
    required String conversationHistory,
    required String userName,
    String? emotionalContext,
  }) async {
    if (!isInitialized) {
      throw Exception('El servicio de IA no está inicializado');
    }

    debugPrint('🗣️ Generando respuesta de chat conversacional...');
    debugPrint('👤 Usuario: $userName');
    debugPrint('💬 Mensaje: ${userMessage.substring(0, userMessage.length > 50 ? 50 : userMessage.length)}...');
    debugPrint('📜 Historial: ${conversationHistory.length} caracteres');
    debugPrint('💭 Contexto emocional: ${emotionalContext?.length ?? 0} caracteres');

    try {
      // Crear prompt específico para chat general
      final chatPrompt = _buildGeneralChatPrompt(
        userMessage: userMessage,
        conversationHistory: conversationHistory,
        userName: userName,
        emotionalContext: emotionalContext,
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

  /// Construye el prompt específico para chat conversacional general - MODIFICADO
  String _buildGeneralChatPrompt({
    required String userMessage,
    required String conversationHistory,
    required String userName,
    String? emotionalContext,
  }) {
    return '''
Eres un asistente de IA conversacional inteligente y empático. Tu personalidad y características son:

PERSONALIDAD PRINCIPAL:
- Empático, comprensivo y genuinamente interesado en ayudar
- Conversacional y natural, como un buen amigo que escucha
- Inteligente pero accesible, sin ser condescendiente
- Propositivo y orientado a soluciones prácticas
- Adaptable al estilo de comunicación del usuario

CAPACIDADES PRINCIPALES:
- Conversar sobre cualquier tema de manera natural e informativa
- Analizar y validar emociones del usuario con sensibilidad
- Proponer soluciones prácticas y realistas a problemas
- Ofrecer perspectivas diferentes y útiles
- Hacer preguntas reflexivas que ayuden al usuario a pensar
- Proporcionar apoyo emocional cuando sea necesario

ESTILO DE COMUNICACIÓN:
- Respuestas naturales y conversacionales (no robóticas)
- Longitud apropiada: ni muy corto ni excesivamente largo
- Uso de emojis ocasionales para expresar calidez (pero sin exceso)
- Preguntas de seguimiento cuando sea apropiado
- Validación emocional antes de dar consejos
- Lenguaje claro y directo, evitando jerga técnica innecesaria

ESPECIALIDADES EN SOLUCIONES:
- Problemas interpersonales y de comunicación
- Gestión del tiempo y productividad
- Toma de decisiones y análisis de opciones
- Manejo del estrés y emociones
- Desarrollo personal y autoconocimiento
- Resolución creativa de problemas
- Apoyo en situaciones difíciles

${emotionalContext?.isNotEmpty == true ? '''
CONTEXTO EMOCIONAL Y PREFERENCIAS DEL USUARIO:
$emotionalContext

Usa esta información para personalizar tu respuesta y demostrar que recuerdas aspectos importantes de conversaciones anteriores.
''' : ''}

${conversationHistory.isNotEmpty ? '''
HISTORIAL DE LA CONVERSACIÓN ACTUAL:
$conversationHistory

Mantén coherencia con el flujo de la conversación y haz referencia a puntos anteriores cuando sea relevante.
''' : ''}

MENSAJE ACTUAL DEL USUARIO ($userName):
$userMessage

INSTRUCCIONES ESPECÍFICAS PARA TU RESPUESTA:

1. ANÁLISIS EMOCIONAL:
   - Identifica las emociones presentes en el mensaje del usuario
   - Valida esas emociones como naturales y comprensibles
   - Si detectas malestar emocional, abórdalo con sensibilidad antes de dar soluciones

2. RESPUESTA PRINCIPAL:
   - Responde directamente a lo que el usuario está preguntando o expresando
   - Si es una pregunta, proporciona información útil y completa
   - Si es un problema, ofrece 2-3 soluciones prácticas y específicas
   - Si es una expresión emocional, valida y explora con preguntas reflexivas

3. PROPUESTA DE SOLUCIONES (cuando aplique):
   - Soluciones prácticas y realizables
   - Pasos concretos que el usuario puede seguir
   - Alternativas si la primera opción no funciona
   - Consideración de las limitaciones y recursos del usuario

4. SEGUIMIENTO:
   - Hacer una pregunta de seguimiento cuando sea apropiado
   - Ofrecer profundizar en temas que parezcan importantes
   - Sugerir próximos pasos si es relevante

5. TONO Y ESTILO:
   - Mantén un equilibrio entre profesional y amigable
   - Sé auténtico y evita respuestas que suenen a plantilla
   - Adapta tu nivel de formalidad al estilo del usuario
   - Demuestra interés genuino en ayudar

TEMAS QUE PUEDES ABORDAR:
- Relaciones interpersonales y familiares
- Trabajo, estudios y carrera profesional
- Salud mental y bienestar emocional
- Productividad y organización personal
- Hobbies, intereses y desarrollo personal
- Tecnología y herramientas útiles
- Creatividad y resolución de problemas
- Cualquier otro tema que el usuario traiga

Recuerda: Tu objetivo es ser un compañero de conversación útil, empático y que realmente ayude al usuario a sentirse mejor y encontrar soluciones a lo que necesita.

GENERA UNA RESPUESTA NATURAL Y ÚTIL:''';
  }

  /// Genera respuesta usando GenAI nativo - MODIFICADO: Mejor manejo de errores
  Future<String> _generateChatWithNativeGenAI(String prompt) async {
    try {
      debugPrint('🤖 Usando GenAI nativo para generar respuesta...');

      final response = await GenAIPlatformInterface.generateText(
        prompt,
        maxTokens: 300, // Respuestas de chat más concisas
        temperature: 0.8, // Más creatividad para conversación natural
        topP: 0.9,
      );

      if (response == null || response.isEmpty) {
        throw Exception('GenAI devolvió una respuesta vacía');
      }

      // Limpiar y validar la respuesta
      final cleanedResponse = _cleanResponse(response);

      debugPrint('✅ Respuesta GenAI generada exitosamente');
      return cleanedResponse;

    } catch (e) {
      debugPrint('❌ Error en GenAI nativo: $e');
      throw Exception('Error generando respuesta con GenAI: $e');
    }
  }

  /// Limpia y valida la respuesta de la IA - NUEVO
  String _cleanResponse(String response) {
    // Eliminar posibles prefijos innecesarios y tokens especiales
    String cleaned = response
        .replaceAll('<|assistant|>', '')
        .replaceAll('<|end|>', '')
        .replaceAll('<|user|>', '')
        .replaceAll('<|system|>', '')
        .replaceFirst(RegExp(r'^(Respuesta:|Respuesta del asistente:|IA:|Asistente:)\s*'), '')
        .trim();

    // Limpiar espacios extra y líneas vacías
    cleaned = cleaned
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n')
        .trim();

    // Asegurar que la respuesta no esté vacía
    if (cleaned.isEmpty) {
      return 'Lo siento, tuve un problema generando mi respuesta. ¿Podrías reformular tu pregunta?';
    }

    // Limitar longitud máxima para evitar respuestas excesivamente largas
    if (cleaned.length > 2000) {
      cleaned = cleaned.substring(0, 1950) + '...';
    }

    return cleaned;
  }

  /// Generar respuesta de emergencia cuando falla todo - NUEVO
  String generateEmergencyResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    // Respuestas específicas según el contenido del mensaje
    if (lowerMessage.contains(RegExp(r'\b(triste|deprimido|mal|horrible)\b'))) {
      return "Siento mucho que te sientas así. Aunque mi sistema está teniendo dificultades técnicas en este momento, quiero que sepas que es completamente normal tener días difíciles. ¿Te ayudaría si hablamos sobre lo que te está pasando?";
    }

    if (lowerMessage.contains(RegExp(r'\b(ayuda|help|socorro)\b'))) {
      return "Entiendo que necesitas ayuda. Aunque mi sistema de IA está experimentando problemas, estoy aquí para escucharte. ¿Puedes contarme más específicamente con qué necesitas apoyo?";
    }

    if (lowerMessage.contains(RegExp(r'\b(gracias|thank you)\b'))) {
      return "¡De nada! Me alegra poder ayudarte, aunque sea de forma limitada en este momento. ¿Hay algo más en lo que pueda apoyarte?";
    }

    if (lowerMessage.contains('?')) {
      return "Esa es una buena pregunta. Lamentablemente, mi sistema de IA está teniendo problemas técnicos y no puedo darte la respuesta completa que mereces. ¿Podrías darme más contexto para intentar ayudarte de otra manera?";
    }

    // Respuesta general empática
    return "Gracias por compartir eso conmigo. Mi sistema de IA está experimentando dificultades técnicas, pero quiero que sepas que estoy aquí para escucharte. ¿Puedes contarme un poco más sobre lo que tienes en mente?";
  }
}