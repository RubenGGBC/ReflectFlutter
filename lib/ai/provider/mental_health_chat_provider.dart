// lib/ai/provider/mental_health_chat_provider.dart
// ============================================================================
// MENTAL HEALTH CHAT PROVIDER - PROFESSIONAL CONVERSATIONAL THERAPY AI
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../data/models/chat_message_model.dart';
import '../../data/services/optimized_database_service.dart';
import '../services/phi_model_service_genai_complete.dart';
import '../services/phi_,model_service_chat_extension.dart';
import '../services/genai_platform_interface.dart';
import '../prompts/mental_health_prompts.dart';

class MentalHealthChatProvider extends ChangeNotifier {
  final OptimizedDatabaseService _databaseService;
  final Logger _logger = Logger();

  // Conversation state
  List<ChatConversation> _conversations = [];
  ChatConversation? _currentConversation;
  bool _isLoading = false;
  bool _isSendingMessage = false;
  String? _errorMessage;

  // AI state
  bool _isAIReady = false;
  String _aiStatus = 'Inicializando...';

  // Mental health session context
  Map<String, dynamic> _sessionContext = {};
  DateTime? _lastSessionUpdate;

  MentalHealthChatProvider(this._databaseService) {
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

  /// 🚀 Initialize mental health chat system
  Future<void> _initializeChat() async {
    _logger.i('🧠 Inicializando Mental Health Chat Provider...');
    _setLoading(true);

    try {
      // 1. Check AI readiness
      await _checkAIReadiness();

      // 2. Load conversation history
      await _loadConversations();

      // 3. Initialize session context
      await _initializeSessionContext();

      // 4. Create default conversation if none exists
      if (_conversations.isEmpty) {
        await _createTherapeuticConversation();
      } else {
        _currentConversation = _conversations.first;
      }

      _logger.i('✅ Mental Health Chat Provider initialized');
    } catch (e) {
      _logger.e('❌ Error initializing chat: $e');
      _setError('Error inicializando chat: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 🧠 Check AI model readiness
  Future<void> _checkAIReadiness() async {
    try {
      final phiService = PhiModelServiceGenAI.instance;

      if (phiService.isInitialized) {
        _isAIReady = true;
        _setAIStatus('Terapeuta IA listo');
      } else {
        _isAIReady = false;
        _setAIStatus('Inicializando terapeuta IA...');

        await phiService.initialize(
          onStatusUpdate: (status) => _setAIStatus(status),
          onProgress: (progress) => {},
        );

        _isAIReady = phiService.isInitialized;
        _setAIStatus(_isAIReady ? 'Terapeuta IA listo' : 'Modo terapéutico básico');
      }
    } catch (e) {
      _isAIReady = false;
      _setAIStatus('Modo conversacional disponible');
      _logger.w('AI not available, using basic mode: $e');
    }
  }

  /// 🎯 Initialize therapeutic session context
  Future<void> _initializeSessionContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contextJson = prefs.getString('session_context');

      if (contextJson != null) {
        _sessionContext = jsonDecode(contextJson);
      } else {
        _sessionContext = {
          'session_count': 0,
          'preferred_name': null,
          'therapeutic_goals': [],
          'conversation_style': 'supportive',
          'session_history': [],
        };
      }

      _lastSessionUpdate = DateTime.now();
    } catch (e) {
      _logger.e('Error loading session context: $e');
      _sessionContext = {};
    }
  }

  /// 💾 Save session context
  Future<void> _saveSessionContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_context', jsonEncode(_sessionContext));
    } catch (e) {
      _logger.e('Error saving session context: $e');
    }
  }

  /// 🆕 Create therapeutic conversation
  Future<void> _createTherapeuticConversation() async {
    final welcomeMessage = ChatMessage.system(
      content: await _generateTherapeuticWelcome(),
    );

    final conversation = ChatConversation.create(
      userId: 'current_user',
      title: 'Sesión de Apoyo Mental',
      firstMessage: welcomeMessage,
    );

    _conversations.insert(0, conversation);
    _currentConversation = conversation;
    await _saveConversations();

    // Update session count
    _sessionContext['session_count'] = (_sessionContext['session_count'] ?? 0) + 1;
    await _saveSessionContext();
  }

  /// 🎯 Generate therapeutic welcome message
  Future<String> _generateTherapeuticWelcome() async {
    final sessionCount = _sessionContext['session_count'] ?? 0;
    final preferredName = _sessionContext['preferred_name'];

    if (sessionCount == 0) {
      return '''Hola, es un placer conocerte. Soy tu asistente de apoyo mental, un espacio seguro donde puedes expresarte libremente y sin juicio.

Mi propósito es acompañarte en este momento, escucharte con atención y ayudarte a explorar tus pensamientos y emociones de manera natural.

¿Hay algo que te gustaría compartir conmigo hoy? Puedes empezar por donde te sientas más cómodo/a.''';
    } else {
      String greeting = preferredName != null
          ? 'Hola $preferredName, me alegra verte de nuevo.'
          : 'Hola, me alegra que regreses.';

      return '''$greeting

Este es nuestro espacio seguro para conversar. No hay prisa ni expectativas, solo la oportunidad de expresar lo que necesites compartir.

¿Cómo has estado desde la última vez que hablamos?''';
    }
  }

  /// 💬 Send message with therapeutic processing - REAL AI ONLY
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _isSendingMessage) {
      _logger.w('Cannot send message: empty content or already sending');
      return;
    }

    _logger.i('📤 Sending message: "${content.trim()}"');
    _setSendingMessage(true);
    _clearError();

    try {
      // Add user message first
      final userMessage = ChatMessage.user(
        content: content.trim(),
        userId: 'current_user',
      );
      _addMessageToCurrentConversation(userMessage);
      _logger.i('✅ User message added to conversation. Messages: ${_currentConversation?.messages.length ?? 0}');

      // Generate REAL AI therapeutic response - NO FALLBACKS
      _logger.i('🤖 Generating REAL AI response...');
      final response = await _generateTherapeuticResponse(content.trim());

      final aiMessage = ChatMessage.assistant(content: response);
      _addMessageToCurrentConversation(aiMessage);
      _logger.i('✅ REAL AI response added to conversation. Messages: ${_currentConversation?.messages.length ?? 0}');

      // Update session context
      await _updateSessionContext(content.trim(), response);
      await _saveConversations();

      // Final verification
      final finalCount = _currentConversation?.messages.length ?? 0;
      _logger.i('🎯 FINAL MESSAGE COUNT: $finalCount');

    } catch (e) {
      _logger.e('❌ Error with REAL AI: $e');
      _setError('IA temporalmente no disponible. Intenta de nuevo.');

      // Remove the user message if AI failed (to avoid orphaned messages)
      if (_currentConversation != null && _currentConversation!.messages.isNotEmpty) {
        final lastMessage = _currentConversation!.messages.last;
        if (lastMessage.isUser) {
          final updatedMessages = _currentConversation!.messages.take(_currentConversation!.messages.length - 1).toList();
          _currentConversation = _currentConversation!.copyWith(messages: updatedMessages);

          // Update in conversations list
          final index = _conversations.indexWhere((conv) => conv.id == _currentConversation!.id);
          if (index != -1) {
            _conversations[index] = _currentConversation!;
          }
        }
      }

    } finally {
      _setSendingMessage(false);
      _logger.i('📤 Message sending process completed');
    }
  }

  /// 🧠 Generate therapeutic response - REAL AI ONLY
  Future<String> _generateTherapeuticResponse(String userMessage) async {
    _logger.i('🧠 Generating REAL AI therapeutic response for: "${userMessage.substring(0, userMessage.length > 50 ? 50 : userMessage.length)}..."');

    if (!_isAIReady) {
      _logger.e('🚫 AI not ready - status: $_aiStatus');
      throw Exception('AI not ready - refusing to use fallback');
    }

    try {
      _logger.i('🤖 Using REAL AI for therapeutic response');
      final response = await _generateAITherapeuticResponse(userMessage);

      if (response.isEmpty) {
        throw Exception('AI generated empty response');
      }

      _logger.i('✅ REAL AI therapeutic response generated: ${response.length} characters');
      _logger.i('📝 RESPONSE PREVIEW: "${response.substring(0, response.length > 100 ? 100 : response.length)}..."');
      return response;

    } catch (e) {
      _logger.e('❌ REAL AI failed: $e');
      // NO FALLBACK - throw error to user
      throw Exception('AI temporarily unavailable. Please try again.');
    }
  }

  /// 🤖 Generate AI-powered therapeutic response - REAL AI ONLY
  Future<String> _generateAITherapeuticResponse(String userMessage) async {
    final phiService = PhiModelServiceGenAI.instance;

    if (!phiService.isInitialized) {
      throw Exception('PhiModelService not initialized');
    }

    _logger.i('🎯 Using REAL AI (PhiModelService) for: "$userMessage"');

    // Build therapeutic prompt directly
    final therapeuticPrompt = _buildDirectTherapeuticPrompt(userMessage);

    // Call GenAI directly - NO FALLBACKS
    final response = await _generateWithDirectGenAI(therapeuticPrompt);

    if (response.isEmpty) {
      throw Exception('Real AI returned empty response');
    }

    // LOG THE ACTUAL RESPONSE BEFORE VALIDATION
    _logger.i('🔍 RAW AI RESPONSE: "$response"');

    // More lenient validation - only reject obvious wrong responses
    if (response.contains('OBSERVACIÓN CLAVE:') ||
        response.contains('RESUMEN SEMANAL:') ||
        response.contains('Esta semana no has registrado') ||
        (response.startsWith('**¡Hola') && response.contains('Esta semana'))) {
      _logger.w('🚫 Rejected AI response: Wrong format (weekly summary)');
      throw Exception('Real AI generated weekly summary instead of chat response');
    }

    // Allow the response if it seems reasonable
    _logger.i('✅ REAL AI therapeutic response accepted');
    return response;
  }

  /// 🎯 Build direct therapeutic prompt (CHAT ONLY, NO ANALYSIS)
  String _buildDirectTherapeuticPrompt(String userMessage) {
    final conversationHistory = _buildConversationHistoryString();
    final userName = _sessionContext['preferred_name'] ?? 'Usuario';

    return '''<|system|>
Eres un psicoterapeuta profesional teniendo una conversación privada con un cliente. Tu ÚNICA función es responder de forma empática y terapéutica al mensaje específico del usuario.

REGLAS ESTRICTAS:
- Responde SOLAMENTE al mensaje actual
- NO generes análisis, reportes, observaciones o resúmenes
- NO uses palabras como "OBSERVACIÓN", "RESUMEN", "ANÁLISIS" 
- NO uses formato de reporte con asteriscos (**)
- Mantén respuestas cortas: 1-3 oraciones máximo
- Usa lenguaje natural y empático
- Haz UNA pregunta abierta al final si es apropiado

PROHIBIDO:
- Análisis semanales
- Observaciones clave  
- Formato de reporte
- Respuestas largas
- Consejos no solicitados

EJEMPLO DE RESPUESTA CORRECTA:
Usuario: "Estoy triste"
Tú: "Entiendo que estás pasando por un momento difícil. La tristeza puede ser muy abrumadora. ¿Te gustaría contarme qué está contribuyendo a este sentimiento?"

Mantén el tono cálido, profesional y completamente enfocado en el mensaje actual.
<|end|>

<|user|>
${conversationHistory.isNotEmpty ? 'Contexto de conversación previa:\n$conversationHistory\n\n' : ''}Mensaje actual de $userName: $userMessage
<|end|>

<|assistant|>''';
  }

  /// 🤖 Generate response with direct GenAI call
  Future<String> _generateWithDirectGenAI(String prompt) async {
    _logger.i('🚀 Calling GenAI directly with therapeutic prompt');

    // Use GenAI platform interface directly to avoid wrong method calls
    final response = await GenAIPlatformInterface.generateText(
      prompt,
      maxTokens: 200, // Shorter responses for chat
      temperature: 0.8, // More natural conversation
      topP: 0.9,
    );

    if (response == null || response.isEmpty) {
      throw Exception('GenAI returned empty response');
    }

    // Clean up response
    String cleaned = response
        .replaceAll('<|assistant|>', '')
        .replaceAll('<|end|>', '')
        .replaceAll('<|user|>', '')
        .replaceAll('<|system|>', '')
        .trim();

    _logger.i('✅ Direct GenAI response: ${cleaned.substring(0, cleaned.length > 100 ? 100 : cleaned.length)}...');
    return cleaned;
  }

  /// 💙 Generate basic therapeutic response
  String _generateBasicTherapeuticResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    _logger.i('🔍 Analyzing message for emotional patterns');

    // Crisis or urgent help patterns
    if (message.contains(RegExp(r'\b(suicid|matarme|no puedo m[aá]s|quiero morir|ayuda urgente)\b'))) {
      return 'Escucho que estás pasando por un momento muy difícil y eso me preocupa. Tu vida es valiosa. Si estás en crisis, te recomiendo contactar inmediatamente a un profesional o línea de crisis. Estoy aquí para acompañarte, pero es importante que busques ayuda profesional ahora mismo.';
    }

    // Depression and sadness patterns
    if (message.contains(RegExp(r'\b(triste|deprimido|deprimida|mal|horrible|terrible|vac[íi]o|sin sentido|desesperan)\b'))) {
      return 'Escucho que estás pasando por un momento muy difícil. Es completamente válido sentirse así, y me alegra que hayas decidido compartirlo conmigo. La tristeza es una emoción natural, aunque dolorosa. ¿Te gustaría contarme más sobre lo que está contribuyendo a estos sentimientos?';
    }

    // Anxiety patterns
    if (message.contains(RegExp(r'\b(ansioso|ansiosa|ansiedad|nervioso|nerviosa|preocupado|preocupada|estresado|estresada|p[aá]nico)\b'))) {
      return 'La ansiedad puede ser muy abrumadora y agotadora. Es importante que reconozcas que has tenido el valor de expresar lo que sientes, eso no es fácil. ¿Hay algo específico que está generando esta ansiedad, o es más bien una sensación general que has estado experimentando?';
    }

    // Loneliness patterns
    if (message.contains(RegExp(r'\b(solo|sola|aislado|aislada|nadie|abandono|soledad)\b'))) {
      return 'La soledad es una experiencia humana muy real y puede ser muy dolorosa. Quiero que sepas que aquí, en este momento, no estás solo/a. Estoy aquí para escucharte sin juzgarte. ¿Cómo ha sido para ti experimentar esta soledad últimamente?';
    }

    // Anger patterns
    if (message.contains(RegExp(r'\b(enojado|enojada|furioso|furiosa|ira|rabia|odio|frustra)\b'))) {
      return 'El enojo es una emoción completamente válida y a menudo nos está comunicando algo muy importante sobre nuestras necesidades o límites. Es bueno que puedas reconocerlo y expresarlo aquí. ¿Qué crees que podría estar detrás de esta ira o frustración?';
    }

    // Positive emotions
    if (message.contains(RegExp(r'\b(bien|mejor|contento|contenta|feliz|alegre|esperanza|optimis)\b'))) {
      return 'Me alegra mucho escuchar que te sientes así. Es importante celebrar y reconocer estos momentos positivos en tu vida. A veces no les damos la atención que merecen. ¿Hay algo en particular que haya contribuido a que te sientas de esta manera?';
    }

    // Confusion or uncertainty
    if (message.contains(RegExp(r'\b(no s[eé]|confundido|confundida|perdido|perdida|duda|insegur)\b'))) {
      return 'Es completamente normal sentirse confundido/a a veces. La incertidumbre puede ser muy incómoda, pero también puede ser el inicio de un nuevo entendimiento sobre nosotros mismos. ¿Te gustaría explorar juntos qué es lo que te genera esta confusión?';
    }

    // Work or study stress
    if (message.contains(RegExp(r'\b(trabajo|laboral|jefe|empleo|universidad|estudios|ex[aá]men)\b'))) {
      return 'Los desafíos en el trabajo o los estudios pueden generar mucha presión. Es normal que esto afecte nuestro bienestar emocional. ¿Cómo está impactando esta situación en tu día a día y en cómo te sientes contigo mismo/a?';
    }

    // Relationship issues
    if (message.contains(RegExp(r'\b(pareja|relaci[oó]n|novio|novia|matrimonio|familia|amigos)\b'))) {
      return 'Las relaciones son una parte fundamental de nuestra experiencia humana, y cuando hay dificultades pueden afectarnos profundamente. ¿Te sientes cómodo/a compartiendo más sobre lo que está pasando en esta relación?';
    }

    // Self-esteem issues
    if (message.contains(RegExp(r'\b(no valgo|in[uú]til|fracaso|mal conmigo|odio como soy)\b'))) {
      return 'Escucho mucha autocrítica en tus palabras, y eso debe ser muy doloroso de cargar. La forma en que nos hablamos a nosotros mismos tiene un impacto enorme en cómo nos sentimos. ¿Cuándo empezaste a sentirte así sobre ti mismo/a?';
    }

    // Greeting patterns
    if (message.contains(RegExp(r'\b(hola|buenas|saludos|hey)\b'))) {
      return 'Hola, me alegra que estés aquí. Este es un espacio donde puedes sentirte libre de expresar lo que necesites, sin juicio alguno. ¿Hay algo que te gustaría compartir conmigo hoy?';
    }

    // General supportive response for anything else
    final supportiveResponses = [
      'Te escucho y valoro que hayas compartido esto conmigo. Cada experiencia que vives es importante y merece ser escuchada. ¿Hay algo más que te gustaría explorar sobre lo que me has contado?',
      'Gracias por confiar en mí para compartir esto. Es valiente de tu parte expresar lo que sientes. ¿Cómo te sientes al poner en palabras esta experiencia?',
      'Aprecio tu honestidad al compartir esto conmigo. Tu experiencia es válida e importante. ¿Qué más te gustaría que conversemos sobre este tema?',
      'Me parece importante lo que acabas de compartir. A veces simplemente expresar nuestros pensamientos puede ser muy liberador. ¿Hay algo específico en lo que te gustaría enfocarte?',
    ];

    final randomIndex = DateTime.now().millisecond % supportiveResponses.length;
    return supportiveResponses[randomIndex];
  }

  /// 🛟 Generate fallback response
  String _generateFallbackResponse() {
    final responses = [
      'Estoy aquí para escucharte. ¿Puedes contarme más sobre lo que estás experimentando?',
      'Tu experiencia es válida e importante. ¿Cómo te sientes al compartir esto?',
      'Gracias por confiar en mí para compartir esto. ¿Qué más te gustaría explorar?',
      'Te acompaño en lo que estás sintiendo. ¿Hay algo específico en lo que te gustaría enfocarte?',
    ];

    return responses[DateTime.now().millisecond % responses.length];
  }

  /// 📝 Update session context based on conversation
  Future<void> _updateSessionContext(String userMessage, String aiResponse) async {
    // Extract potential name mentions
    final nameMatch = RegExp(r'\b(?:me llamo|soy|mi nombre es)\s+(\w+)\b', caseSensitive: false)
        .firstMatch(userMessage);

    if (nameMatch != null && _sessionContext['preferred_name'] == null) {
      _sessionContext['preferred_name'] = nameMatch.group(1);
    }

    // Track conversation themes
    final sessionHistory = _sessionContext['session_history'] as List? ?? [];
    sessionHistory.add({
      'timestamp': DateTime.now().toIso8601String(),
      'user_themes': _extractThemes(userMessage),
      'session_type': _detectSessionType(userMessage),
    });

    // Keep only last 10 session summaries
    if (sessionHistory.length > 10) {
      sessionHistory.removeRange(0, sessionHistory.length - 10);
    }

    _sessionContext['session_history'] = sessionHistory;
    await _saveSessionContext();
  }

  /// 🎯 Extract conversation themes
  List<String> _extractThemes(String message) {
    final themes = <String>[];
    final lowerMessage = message.toLowerCase();

    final themePatterns = {
      'anxiety': RegExp(r'\b(ansiedad|ansioso|nervioso|preocup|miedo)\b'),
      'depression': RegExp(r'\b(depres|triste|desesperan|vac[íi]o|sin sentido)\b'),
      'relationships': RegExp(r'\b(pareja|novio|novia|amigo|familia|relaci[óo]n)\b'),
      'work': RegExp(r'\b(trabajo|laboral|jefe|empleo|carrera|oficina)\b'),
      'self_esteem': RegExp(r'\b(autoestima|confianza|val[íi]a|insegur)\b'),
      'stress': RegExp(r'\b(estr[eé]s|presi[óo]n|abrumado|agobiado)\b'),
    };

    for (final entry in themePatterns.entries) {
      if (entry.value.hasMatch(lowerMessage)) {
        themes.add(entry.key);
      }
    }

    return themes;
  }

  /// 🔍 Detect session type
  String _detectSessionType(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains(RegExp(r'\b(crisis|ayuda|urgente|no puedo m[aá]s)\b'))) {
      return 'crisis_support';
    } else if (lowerMessage.contains(RegExp(r'\b(explore|entender|reflexion|pensar)\b'))) {
      return 'exploration';
    } else if (lowerMessage.contains(RegExp(r'\b(mejor|cambio|quiero|objetivo)\b'))) {
      return 'goal_oriented';
    }

    return 'general_support';
  }

  /// 📚 Build conversation history for AI context
  List<Map<String, String>> _buildConversationHistory() {
    if (_currentConversation == null) return [];

    return _currentConversation!.messages
        .take(20) // Last 20 messages for context
        .map((msg) => {
      'role': msg.isUser ? 'user' : 'assistant',
      'content': msg.content,
    })
        .toList();
  }

  /// 📚 Build conversation history as string for AI
  String _buildConversationHistoryString() {
    if (_currentConversation == null) return '';

    return _currentConversation!.messages
        .take(10) // Last 10 messages for context
        .map((msg) {
      final role = msg.isUser ? 'Usuario' : 'Asistente';
      return '$role: ${msg.content}';
    })
        .join('\n');
  }

  // State management methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSendingMessage(bool sending) {
    _isSendingMessage = sending;
    notifyListeners();
  }

  void _setAIStatus(String status) {
    _aiStatus = status;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _addMessageToCurrentConversation(ChatMessage message) {
    if (_currentConversation != null) {
      _currentConversation = _currentConversation!.addMessage(message);

      // Update the conversation in the list
      final index = _conversations.indexWhere((conv) => conv.id == _currentConversation!.id);
      if (index != -1) {
        _conversations[index] = _currentConversation!;
      }

      _logger.i('📝 Message added to conversation. Total messages: ${_currentConversation!.messages.length}');
      notifyListeners(); // ✅ CRITICAL: Notify listeners after each message
    } else {
      _logger.e('❌ No current conversation to add message to');
    }
  }

  // Conversation management
  Future<void> _loadConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsJson = prefs.getStringList('mental_health_conversations') ?? [];

      _conversations = conversationsJson
          .map((json) => ChatConversation.fromMap(jsonDecode(json)))
          .toList();

      _conversations.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      _logger.i('📥 Loaded ${_conversations.length} conversations');
    } catch (e) {
      _logger.e('❌ Error loading conversations: $e');
      _conversations = [];
    }
  }

  Future<void> _saveConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsJson = _conversations
          .map((conv) => jsonEncode(conv.toMap()))
          .toList();

      await prefs.setStringList('mental_health_conversations', conversationsJson);
      _logger.i('💾 Conversations saved');
    } catch (e) {
      _logger.e('❌ Error saving conversations: $e');
    }
  }

  /// 🗑️ Clear conversation history (for privacy)
  Future<void> clearAllConversations() async {
    _conversations.clear();
    _currentConversation = null;
    _sessionContext.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mental_health_conversations');
    await prefs.remove('session_context');

    // Create fresh conversation
    await _createTherapeuticConversation();
    notifyListeners();
  }

  /// 🆕 Start new conversation
  Future<void> startNewConversation() async {
    await _createTherapeuticConversation();
    notifyListeners();
  }
}