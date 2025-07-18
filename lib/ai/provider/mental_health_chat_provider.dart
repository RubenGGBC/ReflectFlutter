// lib/ai/provider/mental_health_chat_provider.dart
// ============================================================================
// MENTAL HEALTH CHAT PROVIDER - PROFESSIONAL CONVERSATIONAL THERAPY AI
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

import '../../data/models/chat_message_model.dart';
import '../../data/services/optimized_database_service.dart';
import '../services/phi_model_service_genai_complete.dart';
import '../services/phi_,model_service_chat_extension.dart';
import '../services/genai_platform_interface.dart';
import '../services/model_downloader.dart';
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

  /// 🧠 Check AI model readiness - ENSURE MODEL IS DOWNLOADED
  Future<void> _checkAIReadiness() async {
    try {
      final phiService = PhiModelServiceGenAI.instance;

      if (phiService.isInitialized) {
        _isAIReady = true;
        _setAIStatus('Terapeuta IA listo');
        return;
      }

      _isAIReady = false;
      _setAIStatus('Verificando modelo IA...');
      
      // First check if model is downloaded
      final downloader = ModelDownloader();
      final isDownloaded = await downloader.isModelDownloaded();
      
      _logger.i('📋 Model download status: $isDownloaded');
      
      if (!isDownloaded) {
        _setAIStatus('Modelo no encontrado, descargando...');
        _logger.i('⬇️ Starting model download...');
        
        try {
          await downloader.downloadModel(
            onProgress: (progress) {
              final progressPercent = (progress * 100).toInt();
              _setAIStatus('Descargando modelo: $progressPercent%');
              _logger.i('📈 Download Progress: $progressPercent%');
            },
            onStatusUpdate: (status) {
              _setAIStatus(status);
              _logger.i('📊 Download Status: $status');
            },
          );
          _logger.i('✅ Model download completed');
        } catch (downloadError) {
          _logger.e('❌ Model download failed: $downloadError');
          _setAIStatus('Error descargando modelo');
          throw Exception('Failed to download model: $downloadError');
        }
      } else {
        _setAIStatus('Modelo encontrado, inicializando...');
        _logger.i('✅ Model already downloaded');
      }

      // Now initialize with proper progress tracking
      _setAIStatus('Inicializando IA...');
      
      // Get model directory for initialization
      final modelDirectory = await downloader.getModelDirectory();
      _logger.i('📁 Model directory: $modelDirectory');
      
      final initSuccess = await phiService.initialize(
        onStatusUpdate: (status) {
          _setAIStatus(status);
          _logger.i('📊 AI Status: $status');
        },
        onProgress: (progress) {
          final progressPercent = (progress * 100).toInt();
          _setAIStatus('Configurando IA: $progressPercent%');
          _logger.i('📈 Init Progress: $progressPercent%');
        },
      );

      if (initSuccess && phiService.isInitialized) {
        _isAIReady = true;
        _setAIStatus('Terapeuta IA listo');
        _logger.i('✅ AI Model successfully initialized');
      } else {
        _isAIReady = false;
        _setAIStatus('Error inicializando IA');
        _logger.e('❌ AI Model initialization failed');
        throw Exception('Failed to initialize AI model');
      }
    } catch (e) {
      _isAIReady = false;
      _setAIStatus('IA no disponible');
      _logger.e('❌ AI initialization error: $e');
      // Don't throw here - let the UI handle the error state
    }
  }

  /// 🎯 Initialize therapeutic session context - PER CONVERSATION
  Future<void> _initializeSessionContext() async {
    try {
      // Session context is now per conversation, not global
      if (_currentConversation != null) {
        _sessionContext = _currentConversation!.metadata ?? {};
      }
      
      // Initialize default context if empty
      if (_sessionContext.isEmpty) {
        _sessionContext = {
          'session_count': 0,
          'preferred_name': null,
          'therapeutic_goals': [],
          'conversation_style': 'supportive',
          'session_history': [],
          'conversation_id': _currentConversation?.id ?? '',
          'created_at': DateTime.now().toIso8601String(),
        };
      }

      _lastSessionUpdate = DateTime.now();
    } catch (e) {
      _logger.e('Error loading session context: $e');
      _sessionContext = {};
    }
  }

  /// 💾 Save session context - PER CONVERSATION
  Future<void> _saveSessionContext() async {
    try {
      if (_currentConversation != null) {
        // Save context to current conversation metadata
        _currentConversation = _currentConversation!.copyWith(
          metadata: _sessionContext,
        );
        
        // Update conversation in list
        final index = _conversations.indexWhere((conv) => conv.id == _currentConversation!.id);
        if (index != -1) {
          _conversations[index] = _currentConversation!;
        }
        
        // Save all conversations
        await _saveConversations();
      }
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

  /// 🧠 Generate therapeutic response - REAL AI ONLY, NO FALLBACKS
  Future<String> _generateTherapeuticResponse(String userMessage) async {
    _logger.i('🧠 Generating REAL AI therapeutic response for: "${userMessage.substring(0, userMessage.length > 50 ? 50 : userMessage.length)}..."');

    if (!_isAIReady) {
      _logger.e('🚫 AI not ready - status: $_aiStatus');
      throw Exception('La IA no está disponible. Por favor, espera a que se inicialice.');
    }

    try {
      _logger.i('🤖 Using REAL AI for therapeutic response');
      final response = await _generateAITherapeuticResponse(userMessage);

      if (response.isEmpty) {
        throw Exception('La IA generó una respuesta vacía');
      }

      _logger.i('✅ REAL AI therapeutic response generated: ${response.length} characters');
      _logger.i('📝 RESPONSE PREVIEW: "${response.substring(0, response.length > 100 ? 100 : response.length)}..."');
      return response;

    } catch (e) {
      _logger.e('❌ REAL AI failed: $e');
      // NO FALLBACK - throw error to user
      throw Exception('La IA no está disponible temporalmente. Intenta de nuevo en un momento.');
    }
  }

  /// 🤖 Generate AI-powered therapeutic response - REAL AI ONLY
  Future<String> _generateAITherapeuticResponse(String userMessage) async {
    final phiService = PhiModelServiceGenAI.instance;

    if (!phiService.isInitialized) {
      throw Exception('PhiModelService not initialized');
    }

    _logger.i('🎯 Using REAL AI (PhiModelService) for: "$userMessage"');

    // Try up to 3 times with different approaches
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        _logger.i('🔄 Attempt $attempt/3 for AI response');
        
        // Build therapeutic prompt with attempt-specific modifications
        final therapeuticPrompt = _buildDirectTherapeuticPrompt(userMessage, attempt);

        // Call GenAI directly
        final response = await _generateWithDirectGenAI(therapeuticPrompt);

        if (response.isEmpty) {
          throw Exception('Real AI returned empty response');
        }

        // LOG THE ACTUAL RESPONSE BEFORE VALIDATION
        _logger.i('🔍 RAW AI RESPONSE (attempt $attempt): "$response"');

        // Validate response format
        if (_isValidChatResponse(response)) {
          _logger.i('✅ REAL AI therapeutic response accepted on attempt $attempt');
          return response;
        } else {
          _logger.w('🚫 Rejected AI response on attempt $attempt: Wrong format');
          if (attempt == 3) {
            throw Exception('Real AI consistently generated wrong format after 3 attempts');
          }
          continue; // Try next attempt
        }
      } catch (e) {
        _logger.w('⚠️ Attempt $attempt failed: $e');
        if (attempt == 3) {
          throw Exception('Real AI failed after 3 attempts: $e');
        }
        // Wait a bit before retry
        await Future.delayed(Duration(milliseconds: 500));
      }
    }

    throw Exception('Real AI failed to generate valid response');
  }

  /// 🔍 Validate if response is a proper chat response
  bool _isValidChatResponse(String response) {
    final responseUpper = response.toUpperCase();
    final invalidPatterns = [
      'OBSERVACIÓN CLAVE:',
      'RESUMEN SEMANAL:',
      'ESTA SEMANA NO HAS REGISTRADO',
      'ESTA SEMANA',
      'INSIGHTS PROFUNDOS:',
      'RECOMENDACIONES PERSONALIZADAS:',
      'REFLEXIÓN FINAL:',
      'ANÁLISIS SEMANAL:',
      'WEEKLY SUMMARY',
      'OBSERVACIONES CLAVE',
      'RESUMEN DE LA SEMANA',
      'ANÁLISIS DE',
      'REPORTES',
      'MÉTRICAS',
      'DATOS DE LA SEMANA',
      'PROMEDIO DE',
      'NIVEL DE ENERGÍA',
      'ESTADO DE ÁNIMO PROMEDIO',
    ];
    
    final containsInvalidPattern = invalidPatterns.any((pattern) => 
      responseUpper.contains(pattern));
    
    final hasReportFormat = response.contains('**') && 
      (response.contains('RESUMEN') || response.contains('ANÁLISIS'));
    
    return !containsInvalidPattern && !hasReportFormat;
  }

  /// 🎯 Build direct therapeutic prompt (CHAT ONLY, NO ANALYSIS)
  String _buildDirectTherapeuticPrompt(String userMessage, [int attempt = 1]) {
    final conversationHistory = _buildConversationHistoryString();
    final userName = _sessionContext['preferred_name'] ?? 'Usuario';

    // More specific instructions for different attempts
    final String specificInstructions = attempt == 1
        ? "Responde ÚNICAMENTE al mensaje del usuario como un terapeuta empático en conversación natural."
        : attempt == 2
            ? "IMPORTANTE: NO generes análisis ni reportes. Solo responde al mensaje como si fueras un amigo terapeuta hablando cara a cara."
            : "CRÍTICO: Responde SOLO con una conversación natural. NO uses formato de reporte. Solo habla directamente al usuario.";

    return '''<|system|>
Eres un terapeuta conversacional. Solo responde al mensaje del usuario con empatía y naturalidad.

FORMATO REQUERIDO:
- Respuesta directa al mensaje (2-3 oraciones)
- Sin análisis, reportes, o resúmenes
- Sin formato con asteriscos (**)
- Sin títulos o secciones
- Sin palabras como "OBSERVACIÓN", "RESUMEN", "ANÁLISIS", "SEMANAL"

EJEMPLOS CORRECTOS:
Usuario: "Hola"
Respuesta: "Hola, me alegra que estés aquí. ¿Cómo te sientes hoy?"

Usuario: "Estoy triste"
Respuesta: "Entiendo que estás pasando por un momento difícil. La tristeza puede ser muy abrumadora. ¿Qué te ha llevado a sentirte así?"

Usuario: "Tengo ansiedad"
Respuesta: "La ansiedad puede ser muy intensa. Es valiente de tu parte compartir esto conmigo. ¿Hay algo específico que la esté provocando?"

$specificInstructions
<|end|>

<|user|>
${conversationHistory.isNotEmpty ? 'Conversación previa:\n$conversationHistory\n\n' : ''}$userName dice: "$userMessage"

Responde como terapeuta empático en conversación natural:
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

  // REMOVED: Basic therapeutic response - NO FALLBACKS ALLOWED

  // REMOVED: Fallback response - NO FALLBACKS ALLOWED

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

  /// 📚 Build conversation history for AI context - CURRENT CONVERSATION ONLY
  List<Map<String, String>> _buildConversationHistory() {
    if (_currentConversation == null) return [];

    // Only use messages from current conversation - NO cross-conversation memory
    return _currentConversation!.messages
        .where((msg) => !msg.isThinking && !msg.isSystem) // Filter out thinking/system messages
        .take(20) // Last 20 messages for context
        .map((msg) => {
      'role': msg.isUser ? 'user' : 'assistant',
      'content': msg.content,
    })
        .toList();
  }

  /// 📚 Build conversation history as string for AI - CURRENT CONVERSATION ONLY
  String _buildConversationHistoryString() {
    if (_currentConversation == null) return '';

    // Only use messages from current conversation - NO cross-conversation memory
    return _currentConversation!.messages
        .where((msg) => !msg.isThinking && !msg.isSystem) // Filter out thinking/system messages
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
  
  /// 🔄 Public method to clear error and retry initialization
  void clearError() {
    _clearError();
  }
  
  /// 🔄 Public method to trigger re-initialization
  Future<void> initializeChat() async {
    await _initializeChat();
  }
  
  /// 🔄 Force model download (for testing/debugging)
  Future<void> forceDownloadModel() async {
    try {
      _setAIStatus('Forzando descarga del modelo...');
      final downloader = ModelDownloader();
      
      // Delete existing model files first
      final modelPath = await downloader.getModelPath();
      final dataPath = await downloader.getDataPath();
      
      final modelFile = File(modelPath);
      final dataFile = File(dataPath);
      
      if (await modelFile.exists()) {
        await modelFile.delete();
        _logger.i('🗑️ Deleted existing model file');
      }
      
      if (await dataFile.exists()) {
        await dataFile.delete();
        _logger.i('🗑️ Deleted existing data file');
      }
      
      // Force download
      await downloader.downloadModel(
        onProgress: (progress) {
          final progressPercent = (progress * 100).toInt();
          _setAIStatus('Descargando modelo: $progressPercent%');
          _logger.i('📈 Force Download Progress: $progressPercent%');
        },
        onStatusUpdate: (status) {
          _setAIStatus(status);
          _logger.i('📊 Force Download Status: $status');
        },
      );
      
      _logger.i('✅ Force model download completed');
      
      // Re-initialize after download
      await _initializeChat();
      
    } catch (e) {
      _logger.e('❌ Force download failed: $e');
      _setError('Error forzando descarga: $e');
    }
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
    // Note: No need to remove 'session_context' as it's now per-conversation

    // Create fresh conversation
    await _createTherapeuticConversation();
    notifyListeners();
  }

  /// 🆕 Start new conversation - ISOLATED MEMORY
  Future<void> startNewConversation() async {
    // Reset session context for new conversation
    _sessionContext = {};
    
    // Create new conversation
    await _createTherapeuticConversation();
    
    // Initialize fresh context for this conversation
    await _initializeSessionContext();
    
    notifyListeners();
  }
  
  /// 🔄 Switch to existing conversation - LOAD ITS MEMORY
  Future<void> switchToConversation(String conversationId) async {
    try {
      final conversation = _conversations.firstWhere(
        (conv) => conv.id == conversationId,
        orElse: () => throw Exception('Conversation not found'),
      );
      
      _currentConversation = conversation;
      
      // Load the specific memory for this conversation
      _sessionContext = conversation.metadata ?? {};
      
      // If no context exists, initialize it
      if (_sessionContext.isEmpty) {
        await _initializeSessionContext();
      }
      
      notifyListeners();
    } catch (e) {
      _logger.e('Error switching conversation: $e');
      _setError('Error cambiando conversación');
    }
  }
}