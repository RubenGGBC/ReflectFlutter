// lib/ai/services/psychology_chat_extension.dart
// ============================================================================
// EXTENSIÓN DE CHAT ESPECÍFICA PARA PSICOLOGÍA - VERSIÓN CORREGIDA
// ============================================================================

import 'package:flutter/foundation.dart';
import 'phi_model_service_genai_complete.dart';
import 'genai_platform_interface.dart';

/// Extensión específica para chat de psicología
extension PsychologyChatExtension on PhiModelServiceGenAI {

  /// Genera respuesta de psicólogo usando la IA real
  Future<String> generatePsychologyResponse({
    required String userMessage,
    required String conversationHistory,
    required String userName,
    String? userEmotionalState,
    List<String>? recentTopics,
  }) async {
    if (!isInitialized) {
      throw Exception('El servicio de IA no está inicializado');
    }

    if (!isGenAIAvailable) {
      throw Exception('GenAI requerido para sesiones de psicología');
    }

    debugPrint('🧠 Generando respuesta de psicólogo IA...');
    debugPrint('👤 Paciente: $userName');
    debugPrint('💭 Mensaje: ${userMessage.substring(0, userMessage.length > 50 ? 50 : userMessage.length)}...');
    debugPrint('📊 Estado emocional: $userEmotionalState');
    debugPrint('📜 Historial: ${conversationHistory.length} caracteres');

    try {
      // Crear prompt específico para psicología
      final psychologyPrompt = _buildPsychologyPrompt(
        userMessage: userMessage,
        conversationHistory: conversationHistory,
        userName: userName,
        userEmotionalState: userEmotionalState,
        recentTopics: recentTopics,
      );

      // Usar GenAI nativo (sin fallback para psicología)
      final response = await _generatePsychologyWithNativeGenAI(psychologyPrompt);

      debugPrint('✅ Respuesta psicológica generada: ${response.length} caracteres');
      return response;

    } catch (e) {
      debugPrint('❌ Error generando respuesta psicológica: $e');
      rethrow; // Re-lanzar error sin fallback
    }
  }

  /// Construye el prompt específico para psicología profesional
  String _buildPsychologyPrompt({
    required String userMessage,
    required String conversationHistory,
    required String userName,
    String? userEmotionalState,
    List<String>? recentTopics,
  }) {
    final recentTopicsText = recentTopics?.isNotEmpty == true
        ? '\nTemas recurrentes: ${recentTopics!.join(", ")}'
        : '';

    final emotionalContext = userEmotionalState != null
        ? '\nEstado emocional percibido: $userEmotionalState'
        : '';

    return '''
Eres el Dr. IA, un psicólogo profesional especializado en terapia cognitivo-conductual y técnicas de mindfulness. Tu objetivo es proporcionar apoyo psicológico genuino y profesional.

IDENTIDAD PROFESIONAL:
- Nombre: Dr. IA
- Especialidad: Psicología Clínica y Terapia Cognitivo-Conductual
- Enfoque: Humanista, empático, basado en evidencia
- Experiencia: Tratamiento de ansiedad, depresión, estrés, autoestima

PRINCIPIOS TERAPÉUTICOS:
1. ESCUCHA ACTIVA: Valida las emociones del paciente sin juzgar
2. PREGUNTAS REFLEXIVAS: Ayuda al auto-descubrimiento mediante preguntas abiertas
3. TÉCNICAS ESPECÍFICAS: Aplica CBT, mindfulness, reestructuración cognitiva
4. SEGURIDAD: Mantén un espacio seguro y confidencial
5. PROFESIONALISMO: Equilibra calidez humana con competencia profesional

ESTRUCTURA DE RESPUESTA:
- Validación emocional inicial
- Reflexión o reformulación de lo expresado
- Pregunta reflexiva o técnica terapéutica
- Sugerencia práctica cuando sea apropiado

TÉCNICAS DISPONIBLES:
• Reestructuración cognitiva (identificar pensamientos negativos)
• Técnicas de grounding (5-4-3-2-1, respiración)
• Registro de pensamientos y emociones
• Técnicas de exposure gradual
• Mindfulness y meditación guiada
• Análisis de patrones de comportamiento

ESPECIALIDADES CLÍNICAS:
- Trastornos de ansiedad y pánico
- Episodios depresivos y distimia
- Estrés laboral y burnout
- Problemas de autoestima y autoconcepto
- Gestión de emociones y regulación emocional
- Relaciones interpersonales y comunicación

${conversationHistory.isNotEmpty ? '''
CONTEXTO DE LA SESIÓN:
$conversationHistory$emotionalContext$recentTopicsText
''' : ''}

MENSAJE ACTUAL DEL PACIENTE ($userName):
$userMessage

INSTRUCCIONES ESPECÍFICAS:
1. Responde como Dr. IA manteniendo coherencia con la sesión anterior
2. Si es una primera sesión, establece rapport y explora la motivación de consulta
3. Si detectas crisis o riesgo, aborda con seriedad y profesionalismo
4. Usa técnicas específicas apropiadas para la situación presentada
5. Haz preguntas reflexivas que promuevan insight
6. Ofrece técnicas concretas y aplicables
7. Mantén límites profesionales apropiados
8. Si hay patrones repetitivos, señálalos constructivamente

NOTA IMPORTANTE: No diagnostiques ni prescribas medicamentos. Si detectas necesidad de intervención médica, sugiere consulta presencial.

Responde ahora como Dr. IA:
''';
  }

  /// Genera respuesta usando GenAI nativo para psicología
  Future<String> _generatePsychologyWithNativeGenAI(String prompt) async {
    debugPrint('🧠 Generando respuesta psicológica con GenAI nativo...');

    final response = await GenAIPlatformInterface.generateText(
      prompt,
      maxTokens: 400, // Respuestas más elaboradas para psicología
      temperature: 0.7, // Balance entre coherencia y naturalidad
      topP: 0.9,
    );

    if (response == null || response.isEmpty) {
      throw Exception('GenAI no devolvió respuesta válida para la consulta psicológica');
    }

    return _cleanupPsychologyResponse(response);
  }

  /// Limpia la respuesta psicológica
  String _cleanupPsychologyResponse(String response) {
    // Remover tokens especiales del modelo
    String cleaned = response
        .replaceAll('<|assistant|>', '')
        .replaceAll('<|end|>', '')
        .replaceAll('<|user|>', '')
        .replaceAll('<|system|>', '')
        .replaceAll('Dr. IA:', '') // Remover prefijo si aparece
        .replaceAll('Psicólogo:', '')
        .replaceAll('Respuesta:', '');

    // Limpiar espacios extra y líneas vacías
    cleaned = cleaned
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n')
        .trim();

    // Validaciones específicas para psicología
    if (cleaned.isEmpty) {
      throw Exception('La IA generó una respuesta vacía para la consulta psicológica');
    }

    if (cleaned.length < 20) {
      throw Exception('La IA generó una respuesta demasiado corta para psicología: "$cleaned"');
    }

    // Para psicología, permitir respuestas más largas pero con límite
    if (cleaned.length > 1500) {
      cleaned = cleaned.substring(0, 1500) + '...\n\n¿Te gustaría que profundicemos en algún aspecto específico?';
      debugPrint('⚠️ Respuesta psicológica truncada por longitud');
    }

    // Verificar que no contenga contenido inapropiado para psicología
    if (_containsInappropriateContent(cleaned)) {
      throw Exception('La IA generó contenido inapropiado para una sesión psicológica');
    }

    return cleaned;
  }

  /// Verifica contenido inapropiado para sesiones de psicología
  bool _containsInappropriateContent(String content) {
    final inappropriate = [
      'prescribe',
      'medication',
      'diagnose',
      'diagnosis',
      'medical advice',
      'take pills',
      'medication recommendation',
    ];

    final lowerContent = content.toLowerCase();
    return inappropriate.any((term) => lowerContent.contains(term));
  }

  /// Analiza el estado emocional del mensaje
  Future<String?> analyzeEmotionalState(String message) async {
    if (!isInitialized || !isGenAIAvailable) return null;

    try {
      final analysisPrompt = '''
Analiza el estado emocional del siguiente mensaje y responde SOLO con una palabra que describa la emoción principal:

Mensaje: $message

Opciones: ansioso, triste, enojado, confundido, esperanzado, frustrado, calmado, preocupado, alegre, neutral

Responde solo con UNA palabra:
''';

      final response = await GenAIPlatformInterface.generateText(
        analysisPrompt,
        maxTokens: 10,
        temperature: 0.1,
      );

      return response?.trim().toLowerCase();
    } catch (e) {
      debugPrint('Error analizando estado emocional: $e');
      return null;
    }
  }

  /// Extrae temas principales de la conversación
  Future<List<String>> extractConversationTopics(String conversationHistory) async {
    if (!isInitialized || !isGenAIAvailable || conversationHistory.isEmpty) {
      return [];
    }

    try {
      final topicsPrompt = '''
Extrae los 3 temas principales de esta conversación psicológica. Responde SOLO con los temas separados por comas:

Conversación: $conversationHistory

Ejemplo de respuesta: ansiedad laboral, relaciones familiares, autoestima

Respuesta:
''';

      final response = await GenAIPlatformInterface.generateText(
        topicsPrompt,
        maxTokens: 50,
        temperature: 0.3,
      );

      if (response == null || response.isEmpty) return [];

      return response
          .split(',')
          .map((topic) => topic.trim())
          .where((topic) => topic.isNotEmpty)
          .take(3)
          .toList();
    } catch (e) {
      debugPrint('Error extrayendo temas: $e');
      return [];
    }
  }

  /// Verifica si el servicio puede manejar psicología
  bool get canHandlePsychology => isInitialized && isGenAIAvailable;

  /// Obtiene información del estado de psicología
  Map<String, dynamic> getPsychologyCapabilities() {
    return {
      'psychology_available': canHandlePsychology,
      'ai_initialized': isInitialized,
      'genai_available': isGenAIAvailable,
      'can_generate_responses': canHandlePsychology,
      'specialties': [
        'Terapia Cognitivo-Conductual',
        'Técnicas de Mindfulness',
        'Gestión de Ansiedad',
        'Manejo del Estrés',
        'Autoestima y Autoconcepto',
      ],
      'error_if_unavailable': !canHandlePsychology
          ? 'GenAI requerido para sesiones de psicología'
          : null,
    };
  }
}