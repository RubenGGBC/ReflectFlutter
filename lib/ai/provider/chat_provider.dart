// lib/ai/provider/chat_provider.dart
// ============================================================================
// CHAT PROVIDER - CONVERSACIÓN GENERAL CON IA Y MEMORIA EMOCIONAL - CORREGIDO
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;

import '../../data/models/chat_message_model.dart';
import '../../data/services/optimized_database_service.dart';
import '../../data/models/optimized_models.dart';
import 'ai_provider.dart';
import '../services/phi_model_service_genai_complete.dart';
import '../services/phi_,model_service_chat_extension.dart';
import '../services/psychology_chat_extension.dart';

class ChatProvider extends ChangeNotifier {
  final OptimizedDatabaseService _databaseService;
  final AIProvider _aiProvider;
  final Logger _logger = Logger();

  // Estado de conversaciones
  List<ChatConversation> _conversations = [];
  ChatConversation? _currentConversation;
  bool _isLoading = false;
  bool _isSendingMessage = false;
  String? _errorMessage;

  // Estado de la IA
  bool _isAIReady = false;
  String _aiStatus = 'Verificando...';

  // Cache de memoria emocional - MODIFICADO: Solo patrones generales
  Map<String, dynamic>? _conversationMemory;
  DateTime? _lastMemoryUpdate;

  ChatProvider(this._databaseService, this._aiProvider) {
    _initializeChat();
  }

  // Getters
  List<ChatConversation> get conversations => _conversations;
  ChatConversation? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  bool get isSendingMessage => _isSendingMessage;
  String? get errorMessage => _errorMessage;
  bool get isAIReady => _isAIReady;
  String get aiStatus => _aiStatus;
  bool get hasConversations => _conversations.isNotEmpty;
  List<ChatMessage> get currentMessages => _currentConversation?.messages ?? [];

  /// 🚀 Inicializar chat y verificar estado de IA
  Future<void> _initializeChat() async {
    _logger.i('🤖 Inicializando ChatProvider...');
    _setLoading(true);

    try {
      // 1. Verificar estado del motor de IA
      await _checkAIReadiness();

      // 2. Cargar memoria conversacional (MODIFICADO: Sin datos específicos del usuario)
      await _loadConversationMemory();

      // 3. Cargar conversaciones guardadas
      await _loadConversations();

      // 4. Crear conversación por defecto si no hay ninguna
      if (_conversations.isEmpty) {
        await _createDefaultConversation();
      } else {
        _currentConversation = _conversations.first;
      }

      _logger.i('✅ ChatProvider inicializado correctamente');
    } catch (e) {
      _logger.e('❌ Error inicializando ChatProvider: $e');
      _setError('Error iniciando el chat: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 🔧 Setters de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSendingMessage(bool sending) {
    _isSendingMessage = sending;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// ✅ MÉTODO FALTANTE: Limpiar error
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setAIStatus(String status) {
    _aiStatus = status;
    notifyListeners();
  }

  /// 🧠 Verificar disponibilidad de IA
  Future<void> _checkAIReadiness() async {
    try {
      final phiService = PhiModelServiceGenAI.instance;

      if (phiService.isInitialized) {
        _isAIReady = true;
        _setAIStatus(phiService.isGenAIAvailable
            ? 'IA lista (motor nativo)'
            : 'IA lista (modo compatible)');
      } else {
        _isAIReady = false;
        _setAIStatus('IA inicializando...');

        await phiService.initialize(
          onStatusUpdate: (status) => _setAIStatus(status),
          onProgress: (progress) => {/* progress handled elsewhere */},
        );

        _isAIReady = phiService.isInitialized;
        _setAIStatus(_isAIReady
            ? 'IA lista'
            : 'IA temporalmente no disponible');
      }
    } catch (e) {
      _isAIReady = false;
      _setAIStatus('IA en modo básico');
      _logger.w('IA no disponible, usando modo básico: $e');
    }
  }

  /// 💭 Cargar memoria conversacional - MODIFICADO: Solo patrones generales
  Future<void> _loadConversationMemory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memoryJson = prefs.getString('conversation_memory');

      if (memoryJson != null) {
        _conversationMemory = jsonDecode(memoryJson);
        _lastMemoryUpdate = DateTime.parse(_conversationMemory!['last_update'] ?? DateTime.now().toIso8601String());
      } else {
        // Inicializar memoria por primera vez
        _conversationMemory = {
          'emotional_patterns': {},
          'conversation_preferences': {},
          'topics_discussed': [],
          'user_interests': [],
          'communication_style': 'friendly',
          'last_update': DateTime.now().toIso8601String(),
        };
        await _saveConversationMemory();
      }

      _logger.i('💭 Memoria conversacional cargada');
    } catch (e) {
      _logger.e('❌ Error cargando memoria: $e');
      _conversationMemory = {
        'emotional_patterns': {},
        'conversation_preferences': {},
        'topics_discussed': [],
        'user_interests': [],
        'communication_style': 'friendly',
        'last_update': DateTime.now().toIso8601String(),
      };
    }
  }

  /// 💾 Guardar memoria conversacional
  Future<void> _saveConversationMemory() async {
    try {
      if (_conversationMemory == null) return;

      _conversationMemory!['last_update'] = DateTime.now().toIso8601String();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('conversation_memory', jsonEncode(_conversationMemory));

      _logger.i('💾 Memoria conversacional guardada');
    } catch (e) {
      _logger.e('❌ Error guardando memoria: $e');
    }
  }

  /// 💾 Cargar conversaciones desde almacenamiento
  Future<void> _loadConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsJson = prefs.getStringList('chat_conversations') ?? [];

      _conversations = conversationsJson
          .map((json) => ChatConversation.fromMap(jsonDecode(json)))
          .toList();

      // Ordenar por fecha más reciente
      _conversations.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

      _logger.i('📥 Cargadas ${_conversations.length} conversaciones');
    } catch (e) {
      _logger.e('❌ Error cargando conversaciones: $e');
      _conversations = [];
    }
  }

  /// 💾 Guardar conversaciones en almacenamiento
  Future<void> _saveConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsJson = _conversations
          .map((conv) => jsonEncode(conv.toMap()))
          .toList();

      await prefs.setStringList('chat_conversations', conversationsJson);
      _logger.i('💾 Conversaciones guardadas');
    } catch (e) {
      _logger.e('❌ Error guardando conversaciones: $e');
    }
  }

  /// 🆕 Crear conversación por defecto - MODIFICADO: Saludo general
  Future<void> _createDefaultConversation() async {
    final personalizedWelcome = _generatePersonalizedWelcome();

    final welcomeMessage = ChatMessage.system(
      content: personalizedWelcome,
    );

    final conversation = ChatConversation.create(
      userId: 'current_user',
      title: 'Conversación con IA',
      firstMessage: welcomeMessage,
    );

    _conversations.insert(0, conversation);
    _currentConversation = conversation;
    await _saveConversations();

    _logger.i('🆕 Conversación por defecto creada');
  }

  /// 🎯 Generar mensaje de bienvenida personalizado - MODIFICADO: Sin datos específicos
  String _generatePersonalizedWelcome() {
    if (_conversationMemory == null) {
      return '¡Hola! Soy tu asistente de IA personal. Estoy aquí para conversar contigo, ayudarte con cualquier duda, analizar tus emociones y proponerte soluciones a lo que necesites. ¿En qué puedo ayudarte hoy?';
    }

    final communicationStyle = _conversationMemory!['communication_style'] ?? 'friendly';
    final userInterests = _conversationMemory!['user_interests'] as List? ?? [];
    final topicsDiscussed = _conversationMemory!['topics_discussed'] as List? ?? [];

    String welcomeMessage = '¡Hola de nuevo! ';

    if (communicationStyle == 'formal') {
      welcomeMessage = 'Saludos. Es un gusto volver a conversar contigo. ';
    } else if (communicationStyle == 'casual') {
      welcomeMessage = '¡Hey! ¿Qué tal? ';
    }

    if (userInterests.isNotEmpty) {
      final randomInterest = userInterests[math.Random().nextInt(userInterests.length)];
      welcomeMessage += 'Recuerdo que te gusta hablar de $randomInterest. ';
    }

    if (topicsDiscussed.isNotEmpty && topicsDiscussed.length > 3) {
      welcomeMessage += 'Hemos tenido conversaciones muy interesantes. ';
    }

    welcomeMessage += '¿En qué puedo ayudarte hoy? Puedo conversar sobre cualquier tema, analizar cómo te sientes o ayudarte a encontrar soluciones.';

    return welcomeMessage;
  }

  /// 💬 Enviar mensaje y obtener respuesta de IA - MODIFICADO: Análisis emocional general
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty || _isSendingMessage) return;
    if (_currentConversation == null) {
      await _createDefaultConversation();
    }

    _setSendingMessage(true);
    _setError(null);

    try {
      // Agregar mensaje del usuario
      final userMessage = ChatMessage.user(
        content: message.trim(),
        userId: 'current_user',
        conversationId: _currentConversation!.id,
      );
      _addMessageToCurrentConversation(userMessage);

      // Analizar y actualizar memoria emocional
      await _analyzeAndUpdateMemory(message);

      // Generar respuesta de IA
      if (_isAIReady) {
        final response = await _generateAIResponse(message);
        final aiMessage = ChatMessage.assistant(
          content: response,
          conversationId: _currentConversation!.id,
        );
        _addMessageToCurrentConversation(aiMessage);
      } else {
        final fallbackResponse = _generateFallbackResponse(message);
        final aiMessage = ChatMessage.assistant(
          content: fallbackResponse,
          conversationId: _currentConversation!.id,
        );
        _addMessageToCurrentConversation(aiMessage);
      }

      // Guardar conversación
      await _saveConversations();
      await _saveConversationMemory();

    } catch (e) {
      _logger.e('❌ Error enviando mensaje: $e');
      _setError('Error enviando mensaje: ${e.toString()}');

      // Agregar mensaje de error
      final errorMessage = ChatMessage.error(
        content: 'Lo siento, hubo un problema procesando tu mensaje. Por favor intenta de nuevo.',
        conversationId: _currentConversation!.id,
      );
      _addMessageToCurrentConversation(errorMessage);

    } finally {
      _setSendingMessage(false);
    }
  }

  /// 🧠 Analizar mensaje y actualizar memoria emocional - NUEVO: Análisis general
  Future<void> _analyzeAndUpdateMemory(String message) async {
    if (_conversationMemory == null) return;

    try {
      // Detectar emociones básicas en el mensaje
      final emotions = _detectEmotions(message);
      final topics = _extractTopics(message);
      final communicationStyle = _detectCommunicationStyle(message);

      // Actualizar patrones emocionales
      final emotionalPatterns = _conversationMemory!['emotional_patterns'] as Map<String, dynamic>? ?? {};
      for (final emotion in emotions) {
        emotionalPatterns[emotion] = (emotionalPatterns[emotion] ?? 0) + 1;
      }
      _conversationMemory!['emotional_patterns'] = emotionalPatterns;

      // Actualizar temas de interés
      final userInterests = List<String>.from(_conversationMemory!['user_interests'] ?? []);
      for (final topic in topics) {
        if (!userInterests.contains(topic)) {
          userInterests.add(topic);
          if (userInterests.length > 10) {
            userInterests.removeAt(0); // Mantener solo los 10 más recientes
          }
        }
      }
      _conversationMemory!['user_interests'] = userInterests;

      // Actualizar temas discutidos
      final topicsDiscussed = List<String>.from(_conversationMemory!['topics_discussed'] ?? []);
      for (final topic in topics) {
        topicsDiscussed.add(topic);
        if (topicsDiscussed.length > 20) {
          topicsDiscussed.removeAt(0);
        }
      }
      _conversationMemory!['topics_discussed'] = topicsDiscussed;

      // Actualizar estilo de comunicación preferido
      if (communicationStyle.isNotEmpty) {
        _conversationMemory!['communication_style'] = communicationStyle;
      }

    } catch (e) {
      _logger.e('❌ Error analizando memoria: $e');
    }
  }

  /// 😊 Detectar emociones en el mensaje - NUEVO
  List<String> _detectEmotions(String message) {
    final emotions = <String>[];
    final lowerMessage = message.toLowerCase();

    // Emociones positivas
    if (lowerMessage.contains(RegExp(r'\b(feliz|contento|alegre|genial|excelente|perfecto|increíble|maravilloso)\b'))) {
      emotions.add('alegría');
    }
    if (lowerMessage.contains(RegExp(r'\b(emocionado|entusiasmado|motivado|inspirado)\b'))) {
      emotions.add('entusiasmo');
    }
    if (lowerMessage.contains(RegExp(r'\b(gracias|agradecido|agradezco)\b'))) {
      emotions.add('gratitud');
    }

    // Emociones negativas
    if (lowerMessage.contains(RegExp(r'\b(triste|deprimido|melancólico|desanimado)\b'))) {
      emotions.add('tristeza');
    }
    if (lowerMessage.contains(RegExp(r'\b(nervioso|ansioso|preocupado|estresado|agobiado)\b'))) {
      emotions.add('ansiedad');
    }
    if (lowerMessage.contains(RegExp(r'\b(enojado|molesto|frustrado|irritado)\b'))) {
      emotions.add('enojo');
    }
    if (lowerMessage.contains(RegExp(r'\b(confundido|perdido|no entiendo)\b'))) {
      emotions.add('confusión');
    }

    return emotions;
  }

  /// 🏷️ Extraer temas del mensaje - NUEVO
  List<String> _extractTopics(String message) {
    final topics = <String>[];
    final lowerMessage = message.toLowerCase();

    // Temas comunes
    final topicPatterns = {
      'trabajo': RegExp(r'\b(trabajo|empleo|oficina|jefe|empresa|carrera|proyecto)\b'),
      'estudios': RegExp(r'\b(estudios|universidad|colegio|examen|tarea|curso)\b'),
      'familia': RegExp(r'\b(familia|padres|hijos|hermanos|pareja|relación)\b'),
      'salud': RegExp(r'\b(salud|médico|ejercicio|dormir|comer|dieta)\b'),
      'dinero': RegExp(r'\b(dinero|economía|comprar|ahorro|gasto|presupuesto)\b'),
      'tecnología': RegExp(r'\b(tecnología|computadora|celular|internet|app|programa)\b'),
      'hobbies': RegExp(r'\b(música|películas|libros|videojuegos|deporte|arte)\b'),
      'viajes': RegExp(r'\b(viaje|vacaciones|viajar|turismo|destino)\b'),
    };

    for (final entry in topicPatterns.entries) {
      if (entry.value.hasMatch(lowerMessage)) {
        topics.add(entry.key);
      }
    }

    return topics;
  }

  /// 🗣️ Detectar estilo de comunicación - NUEVO
  String _detectCommunicationStyle(String message) {
    final lowerMessage = message.toLowerCase();

    // Formal
    if (lowerMessage.contains(RegExp(r'\b(usted|por favor|disculpe|podría|sería tan amable)\b'))) {
      return 'formal';
    }

    // Casual
    if (lowerMessage.contains(RegExp(r'\b(hey|qué tal|cómo andas|genial|chevere|jaja|jeje)\b'))) {
      return 'casual';
    }

    return 'friendly'; // Por defecto
  }

  /// 🤖 Generar respuesta de IA
  Future<String> _generateAIResponse(String message) async {
    try {
      final phiService = PhiModelServiceGenAI.instance;
      final conversationHistory = _buildConversationHistory();

      return await phiService.generateChatResponse(
        userMessage: message,
        conversationHistory: conversationHistory,
        userName: 'Usuario',
      );
    } catch (e) {
      _logger.e('❌ Error generando respuesta IA: $e');
      return _generateFallbackResponse(message);
    }
  }

  /// 📜 Construir historial de conversación
  String _buildConversationHistory() {
    if (_currentConversation == null || _currentConversation!.messages.isEmpty) {
      return '';
    }

    final recentMessages = _currentConversation!.messages.take(10).toList();
    return recentMessages
        .map((msg) => '${msg.roleDisplay}: ${msg.content}')
        .join('\n');
  }

  /// ✅ MÉTODO FALTANTE: Construir contexto de conversación para psicología
  String _buildConversationContext() {
    if (_currentConversation == null || _currentConversation!.messages.isEmpty) {
      return '';
    }

    // Tomar los últimos 15 mensajes para contexto más amplio en psicología
    final recentMessages = _currentConversation!.messages.take(15).toList();
    return recentMessages
        .where((msg) => msg.type != MessageType.thinking) // Excluir mensajes de "pensando"
        .map((msg) => '${msg.roleDisplay}: ${msg.content}')
        .join('\n');
  }

  /// 🔧 Generar respuesta de respaldo - MODIFICADO: Más empática y propositiva
  String _generateFallbackResponse(String message) {
    final emotions = _detectEmotions(message);
    final lowerMessage = message.toLowerCase();

    // Respuestas según emociones detectadas
    if (emotions.contains('tristeza')) {
      return "Entiendo que te sientes triste. Es completamente normal tener estos momentos. ¿Te gustaría hablar sobre lo que te está pasando? A veces ayuda expresar nuestros sentimientos. También puedo sugerirte algunas actividades que podrían ayudarte a sentirte mejor.";
    }

    if (emotions.contains('ansiedad')) {
      return "Noto que te sientes ansioso o preocupado. Estas emociones pueden ser muy intensas. ¿Quieres que hablemos sobre lo que te está generando esta ansiedad? Puedo ayudarte con técnicas de relajación o estrategias para manejar estos sentimientos.";
    }

    if (emotions.contains('enojo')) {
      return "Veo que estás molesto. Es válido sentirse así a veces. ¿Te ayudaría hablar sobre lo que te está frustrando? Puedo escucharte y ayudarte a encontrar formas constructivas de manejar esta situación.";
    }

    if (emotions.contains('alegría')) {
      return "¡Me alegra mucho saber que te sientes bien! Es genial cuando tenemos estos momentos positivos. ¿Qué te está haciendo sentir tan feliz? Me encanta compartir la alegría contigo.";
    }

    if (emotions.contains('confusión')) {
      return "Entiendo que te sientes confundido. Todos pasamos por momentos donde las cosas no están claras. ¿Puedes contarme más sobre lo que te tiene confundido? Trabajemos juntos para aclarar tus dudas.";
    }

    // Respuestas según preguntas comunes
    if (lowerMessage.contains('ayuda') || lowerMessage.contains('ayudar')) {
      return "Por supuesto, estoy aquí para ayudarte. Puedo conversar sobre cualquier tema que necesites, analizar cómo te sientes, darte consejos prácticos o simplemente escucharte. ¿En qué específicamente te gustaría que te ayude?";
    }

    if (lowerMessage.contains('solución') || lowerMessage.contains('resolver')) {
      return "Me parece genial que busques soluciones. Esa es una actitud muy positiva. Cuéntame más detalles sobre la situación que quieres resolver y trabajemos juntos para encontrar las mejores opciones.";
    }

    if (lowerMessage.contains('consejo') || lowerMessage.contains('qué hacer')) {
      return "Estaré encantado de darte mi perspectiva. Para poder aconsejarte mejor, ¿podrías contarme un poco más sobre tu situación? Mientras más detalles tengas, mejor podremos encontrar el camino correcto.";
    }

    // Respuesta general empática
    return "Gracias por compartir eso conmigo. Aunque mi sistema de IA está temporalmente limitado, estoy aquí para escucharte y ayudarte en lo que pueda. ¿Hay algo específico en lo que te gustaría que te apoye? Puedo ofrecerte mi perspectiva, sugerencias prácticas o simplemente ser un buen compañero de conversación.";
  }

  /// ➕ Añadir mensaje a conversación actual
  void _addMessageToCurrentConversation(ChatMessage message) {
    if (_currentConversation != null) {
      _currentConversation = _currentConversation!.addMessage(message);

      // Actualizar en la lista de conversaciones
      final index = _conversations.indexWhere((conv) => conv.id == _currentConversation!.id);
      if (index != -1) {
        _conversations[index] = _currentConversation!;
      }

      notifyListeners();
    }
  }

  /// ✅ MÉTODO FALTANTE: Remover mensaje específico de la conversación actual
  void _removeMessageFromCurrentConversation(String messageId) {
    if (_currentConversation != null) {
      final updatedMessages = _currentConversation!.messages
          .where((msg) => msg.id != messageId)
          .toList();

      _currentConversation = _currentConversation!.copyWith(
        messages: updatedMessages,
      );

      // Actualizar en la lista de conversaciones
      final index = _conversations.indexWhere((conv) => conv.id == _currentConversation!.id);
      if (index != -1) {
        _conversations[index] = _currentConversation!;
      }

      notifyListeners();
    }
  }

  /// ✅ MÉTODO FALTANTE: Remover todos los mensajes de "pensando"
  void _removeThinkingMessages() {
    if (_currentConversation != null) {
      final updatedMessages = _currentConversation!.messages
          .where((msg) => msg.type != MessageType.thinking)
          .toList();

      _currentConversation = _currentConversation!.copyWith(
        messages: updatedMessages,
      );

      // Actualizar en la lista de conversaciones
      final index = _conversations.indexWhere((conv) => conv.id == _currentConversation!.id);
      if (index != -1) {
        _conversations[index] = _currentConversation!;
      }

      notifyListeners();
    }
  }

  /// 🆕 Crear nueva conversación
  Future<void> createNewConversation() async {
    await _createDefaultConversation();
    notifyListeners();
  }

  /// 🔄 Seleccionar conversación
  void selectConversation(ChatConversation conversation) {
    _currentConversation = conversation;
    notifyListeners();
  }

  /// 🗑️ Eliminar conversación
  Future<void> deleteConversation(ChatConversation conversation) async {
    _conversations.removeWhere((conv) => conv.id == conversation.id);

    if (_currentConversation?.id == conversation.id) {
      _currentConversation = _conversations.isNotEmpty ? _conversations.first : null;
    }

    await _saveConversations();
    notifyListeners();
  }

  /// 🧹 Limpiar conversación actual
  Future<void> clearCurrentConversation() async {
    if (_currentConversation != null) {
      // Crear nueva conversación con solo el mensaje de bienvenida
      final welcomeMessage = ChatMessage.system(
        content: _generatePersonalizedWelcome(),
        conversationId: _currentConversation!.id,
      );

      _currentConversation = _currentConversation!.copyWith(
        messages: [welcomeMessage],
        lastMessageAt: DateTime.now(),
      );

      // Actualizar en la lista
      final index = _conversations.indexWhere((conv) => conv.id == _currentConversation!.id);
      if (index != -1) {
        _conversations[index] = _currentConversation!;
      }

      await _saveConversations();
      notifyListeners();
    }
  }

  /// 🔄 Recargar IA
  Future<void> reloadAI() async {
    await _checkAIReadiness();
  }

  /// 🧹 Limpiar error
  void clearError() {
    _setError(null);
  }

  /// 🧠 Enviar mensaje específico de psicología
  Future<void> sendPsychologyMessage(String content) async {
    if (content.trim().isEmpty || _isSendingMessage) return;

    _logger.i('🧠 Enviando mensaje psicológico: ${content.substring(0, content.length > 50 ? 50 : content.length)}...');

    _setSendingMessage(true);
    _clearError();

    try {
      // 1. Crear mensaje del usuario
      final userMessage = ChatMessage.user(
        content: content,
        userId: 'current_user',
        conversationId: _currentConversation?.id,
      );

      // 2. Añadir mensaje del usuario a la conversación
      _addMessageToCurrentConversation(userMessage);

      // 3. Mostrar indicador de "pensando"
      final thinkingMessage = ChatMessage.thinking(
        conversationId: _currentConversation?.id,
      );
      _addMessageToCurrentConversation(thinkingMessage);

      // 4. Usar el servicio de psicología
      final phiService = PhiModelServiceGenAI.instance;

      // Construir historial de conversación
      final conversationHistory = _buildConversationContext();

      // Generar respuesta psicológica específica
      final psychologyResponse = await phiService.generatePsychologyResponse(
        userMessage: content,
        conversationHistory: conversationHistory,
        userName: 'Paciente',
      );

      // 5. Remover indicador de "pensando"
      _removeMessageFromCurrentConversation(thinkingMessage.id);

      // 6. Añadir respuesta del psicólogo
      final assistantMessage = ChatMessage.assistant(
        content: psychologyResponse,
        conversationId: _currentConversation?.id,
      );
      _addMessageToCurrentConversation(assistantMessage);

      // 7. Guardar conversación
      await _saveConversations();

      _logger.i('✅ Mensaje psicológico enviado y respuesta generada');

    } catch (e) {
      _logger.e('❌ Error enviando mensaje psicológico: $e');

      // Remover mensaje de "pensando" si existe
      _removeThinkingMessages();

      // Añadir mensaje de error específico para psicología
      final errorMessage = ChatMessage.error(
        content: 'Lo siento, hubo un problema en la sesión de psicología. El Dr. IA no está disponible en este momento. ¿Podrías intentarlo de nuevo?',
        conversationId: _currentConversation?.id,
      );
      _addMessageToCurrentConversation(errorMessage);

      _setError('Error en sesión de psicología: $e');
      rethrow;
    } finally {
      _setSendingMessage(false);
    }
  }

  /// 🧑‍⚕️ Crear conversación específica para psicología
  Future<void> createPsychologySession() async {
    final welcomeMessage = ChatMessage.system(
      content: '''¡Hola! Soy el Dr. IA, tu psicólogo personal especializado en terapia cognitivo-conductual.

🌟 **Bienvenido/a a tu espacio seguro**

En esta sesión podremos trabajar juntos en:
• **Gestión de emociones** y regulación emocional
• **Técnicas de relajación** y mindfulness  
• **Reestructuración de pensamientos** negativos
• **Estrategias de afrontamiento** para el estrés
• **Fortalecimiento de la autoestima** y confianza

💭 **¿Cómo te sientes hoy?** 
Puedes compartir conmigo cualquier pensamiento, preocupación o emoción que tengas. Este es un espacio libre de juicios donde tu bienestar es la prioridad.

¿Hay algo específico en lo que te gustaría que te acompañe hoy?''',
    );

    final session = ChatConversation.create(
      userId: 'current_user',
      title: 'Sesión de Psicología ${DateTime.now().day}/${DateTime.now().month}',
      firstMessage: welcomeMessage,
    );

    _conversations.insert(0, session);
    _currentConversation = session;
    await _saveConversations();

    _logger.i('🧠 Nueva sesión de psicología creada');
    notifyListeners();
  }
}