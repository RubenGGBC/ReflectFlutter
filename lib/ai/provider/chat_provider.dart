// lib/ai/provider/chat_provider.dart
// ============================================================================
// CHAT PROVIDER - COACH EMOCIONAL CON IA Y MEMORIA
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
import '../prompts/wellness_coach_prompts.dart';

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

  // Cache de datos del usuario para coaching
  Map<String, dynamic>? _userWellnessData;
  DateTime? _lastWellnessDataUpdate;

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

      // 2. Cargar datos de bienestar del usuario
      await _loadUserWellnessData();

      // 3. Cargar conversaciones guardadas
      await _loadConversations();

      // 4. Crear conversación por defecto si no hay ninguna
      if (_conversations.isEmpty) {
        await _createDefaultConversation();
      } else {
        // Usar la conversación más reciente
        _currentConversation = _conversations.first;
      }

      _logger.i('✅ ChatProvider inicializado correctamente');
    } catch (e) {
      _logger.e('❌ Error inicializando ChatProvider: $e');
      _setError('Error inicializando chat: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 🧠 Verificar estado del motor de IA
  Future<void> _checkAIReadiness() async {
    try {
      final phiService = PhiModelServiceGenAI.instance;

      if (phiService.isInitialized) {
        _isAIReady = true;
        _setAIStatus(phiService.isGenAIAvailable
            ? 'Coach IA listo (motor nativo)'
            : 'Coach IA listo (modo compatible)');
      } else {
        _isAIReady = false;
        _setAIStatus('Coach IA inicializando...');

        // Intentar inicializar
        await phiService.initialize(
          onStatusUpdate: (status) => _setAIStatus(status),
          onProgress: (progress) => {/* progress handled elsewhere */},
        );

        _isAIReady = phiService.isInitialized;
        _setAIStatus(_isAIReady
            ? 'Coach IA listo'
            : 'Coach IA temporalmente no disponible');
      }
    } catch (e) {
      _isAIReady = false;
      _setAIStatus('Coach IA en modo básico');
      _logger.w('IA no disponible, usando modo básico: $e');
    }
  }

  /// 📊 Cargar datos de bienestar del usuario
  Future<void> _loadUserWellnessData() async {
    try {
      // Cargar entradas recientes (últimos 7 días)
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final recentEntries = await _databaseService.getDailyEntries(
        userId: 1, // TODO: Obtener userId real del auth provider
        startDate: weekAgo,
        endDate: now,
        limit: 30,
      );

      // Cargar momentos recientes (últimos 7 días)
      final recentMoments = await _databaseService.getInteractiveMoments(
        userId: 1, // TODO: Obtener userId real del auth provider
        limit: 50,
      );

      _userWellnessData = {
        'recent_entries': recentEntries.map((e) => e.toOptimizedDatabase()).toList(),
        'recent_moments': recentMoments.map((m) => m.toOptimizedDatabase()).toList(),
        'user_name': 'Usuario', // Obtener del perfil si está disponible
      };

      _lastWellnessDataUpdate = now;
      _logger.i('📊 Datos de bienestar cargados: ${recentEntries.length} entradas, ${recentMoments.length} momentos');
    } catch (e) {
      _logger.e('❌ Error cargando datos de bienestar: $e');
      _userWellnessData = null;
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

  /// 🆕 Crear conversación por defecto
  Future<void> _createDefaultConversation() async {
    final personalizedWelcome = await _generatePersonalizedWelcome();

    final welcomeMessage = ChatMessage.system(
      content: personalizedWelcome,
    );

    final conversation = ChatConversation.create(
      userId: 'current_user',
      title: 'Chat con Coach IA',
      firstMessage: welcomeMessage,
    );

    _conversations.insert(0, conversation);
    _currentConversation = conversation;
    await _saveConversations();

    _logger.i('🆕 Conversación por defecto creada');
  }

  /// 🎯 Generar mensaje de bienvenida personalizado
  Future<String> _generatePersonalizedWelcome() async {
    if (_userWellnessData == null) {
      return '¡Hola! Soy tu Coach de IA personal. Estoy aquí para acompañarte en tu desarrollo emocional y bienestar. ¿En qué puedo ayudarte hoy?';
    }

    final recentEntries = _userWellnessData!['recent_entries'] as List? ?? [];
    final recentMoments = _userWellnessData!['recent_moments'] as List? ?? [];

    if (recentEntries.isEmpty && recentMoments.isEmpty) {
      return '¡Hola! Es genial verte por aquí. Soy tu Coach de IA personal y estoy aquí para acompañarte en tu bienestar emocional. Comenzamos juntos este viaje de autoconocimiento. ¿Cómo te sientes hoy?';
    }

    // Analizar datos recientes para personalizar el saludo
    var welcomeMessage = '¡Hola! Me alegra verte de nuevo. ';

    if (recentEntries.isNotEmpty) {
      final lastEntry = recentEntries.last;
      final moodScore = lastEntry['mood_score'] ?? 5;

      if (moodScore >= 7) {
        welcomeMessage += 'He notado que has tenido días positivos recientemente, ¡eso es maravilloso! ';
      } else if (moodScore <= 4) {
        welcomeMessage += 'Veo que has estado navegando algunos desafíos. Estoy aquí para apoyarte. ';
      } else {
        welcomeMessage += 'He visto tus reflexiones recientes y admiro tu dedicación al autoconocimiento. ';
      }
    }

    welcomeMessage += '¿En qué puedo acompañarte hoy?';

    return welcomeMessage;
  }

  /// 💬 Enviar mensaje del usuario
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _isSendingMessage) return;

    _logger.i('📤 Enviando mensaje: ${content.substring(0, content.length > 50 ? 50 : content.length)}...');

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

      // 4. Generar respuesta del coach IA
      final aiResponse = await _generateCoachResponse(content);

      // 5. Remover indicador de "pensando"
      _removeMessageFromCurrentConversation(thinkingMessage.id);

      // 6. Añadir respuesta de la IA
      final assistantMessage = ChatMessage.assistant(
        content: aiResponse.response,
        conversationId: _currentConversation?.id,
        confidence: aiResponse.confidence,
        sources: aiResponse.sources,
      );
      _addMessageToCurrentConversation(assistantMessage);

      // 7. Guardar conversación
      await _saveConversations();

      _logger.i('✅ Mensaje enviado y respuesta generada');

    } catch (e) {
      _logger.e('❌ Error enviando mensaje: $e');

      // Remover mensaje de "pensando" si existe
      _removeThinkingMessages();

      // Añadir mensaje de error
      final errorMessage = ChatMessage.error(
        content: 'Lo siento, hubo un problema procesando tu mensaje. ¿Podrías intentarlo de nuevo?',
        conversationId: _currentConversation?.id,
      );
      _addMessageToCurrentConversation(errorMessage);

      _setError('Error procesando mensaje: $e');
    } finally {
      _setSendingMessage(false);
    }
  }

  /// 🤖 Generar respuesta del coach IA
  Future<CoachResponse> _generateCoachResponse(String userMessage) async {
    try {
      // Actualizar datos de bienestar si es necesario
      await _updateWellnessDataIfNeeded();

      // Construir contexto de la conversación
      final conversationContext = _buildConversationContext();

      // Analizar el tipo de consulta del usuario
      final queryType = _analyzeUserQuery(userMessage);

      // Generar respuesta basada en el tipo de consulta
      switch (queryType) {
        case QueryType.wellnessAnalysis:
          return await _generateWellnessAnalysisResponse(userMessage, conversationContext);
        case QueryType.emotionalSupport:
          return await _generateEmotionalSupportResponse(userMessage, conversationContext);
        case QueryType.recommendations:
          return await _generateRecommendationsResponse(userMessage, conversationContext);
        case QueryType.dataExploration:
          return await _generateDataExplorationResponse(userMessage, conversationContext);
        case QueryType.generalChat:
        default:
          return await _generateGeneralChatResponse(userMessage, conversationContext);
      }
    } catch (e) {
      _logger.e('❌ Error generando respuesta IA: $e');
      return CoachResponse(
        response: 'Lo siento, encontré dificultades procesando tu mensaje. Como tu coach, te sugiero que lo intentemos de nuevo con una pregunta más específica.',
        confidence: 0.3,
        sources: ['sistema'],
      );
    }
  }

  /// 🔍 Analizar tipo de consulta del usuario
  QueryType _analyzeUserQuery(String message) {
    final lowercaseMessage = message.toLowerCase();

    // Palabras clave para análisis de bienestar
    if (lowercaseMessage.contains(RegExp(r'\b(anali[sz]a|resumen|datos|patr[oó]n|tendencia|estad[íi]stica)\b'))) {
      return QueryType.wellnessAnalysis;
    }

    // Palabras clave para soporte emocional
    if (lowercaseMessage.contains(RegExp(r'\b(me siento|estoy|ansiedad|tristeza|estr[eé]s|depresi[oó]n|preocup|mied|dolor|sufr)\b'))) {
      return QueryType.emotionalSupport;
    }

    // Palabras clave para recomendaciones
    if (lowercaseMessage.contains(RegExp(r'\b(qu[eé] puedo|c[oó]mo|ayuda|consejo|recomend|sugier|deber[íi]a)\b'))) {
      return QueryType.recommendations;
    }

    // Palabras clave para exploración de datos
    if (lowercaseMessage.contains(RegExp(r'\b(cu[aá]ndo|d[oó]nde|por qu[eé]|qu[eé] d[íi]a|cu[aá]nto)\b'))) {
      return QueryType.dataExploration;
    }

    return QueryType.generalChat;
  }

  /// 📊 Generar respuesta de análisis de bienestar
  Future<CoachResponse> _generateWellnessAnalysisResponse(String message, String context) async {
    if (_userWellnessData == null) {
      return CoachResponse(
        response: 'Me encantaría analizar tu bienestar, pero aún no tengo suficientes datos tuyos. Te sugiero que comiences registrando algunas reflexiones diarias para que pueda ofrecerte insights personalizados.',
        confidence: 0.8,
        sources: ['análisis básico'],
      );
    }

    final recentEntries = _userWellnessData!['recent_entries'] as List<Map<String, dynamic>>;

    if (recentEntries.isEmpty) {
      return CoachResponse(
        response: 'Para poder hacer un análisis significativo de tu bienestar, necesitaría que registres algunas reflexiones diarias. Una vez que tengas algunos días de datos, podré identificar patrones y ofrecerte insights valiosos sobre tu estado emocional.',
        confidence: 0.7,
        sources: ['guía de registro'],
      );
    }

    // Calcular métricas
    final analysis = _analyzeWellnessMetrics(recentEntries);

    return CoachResponse(
      response: '''Basándome en tus últimas ${analysis['days']} reflexiones, puedo compartir algunos insights importantes:

**Análisis del estado de ánimo:**
Tu puntuación promedio es ${analysis['avgMood']}/10, lo que indica ${analysis['moodInterpretation']}. He notado que ${analysis['moodPattern']}.

**Niveles de energía:**
Tu energía promedio es ${analysis['avgEnergy']}/10. ${analysis['energyInsight']}.

**Gestión del estrés:**
Tus niveles de estrés promedian ${analysis['avgStress']}/10. ${analysis['stressInsight']}.

**Patrón destacado:**
${analysis['keyPattern']}

¿Te gustaría que profundice en algún aspecto específico de este análisis?''',
      confidence: 0.9,
      sources: ['análisis de ${analysis['days']} días', 'métricas de bienestar'],
    );
  }

  /// 💙 Generar respuesta de soporte emocional
  Future<CoachResponse> _generateEmotionalSupportResponse(String message, String context) async {
    // Detectar emociones en el mensaje
    final emotion = _detectEmotion(message);
    final supportResponse = _generateEmotionalSupport(emotion, message);

    // Incluir contexto de datos si está disponible
    String contextualSupport = '';
    if (_userWellnessData != null) {
      final recentEntries = _userWellnessData!['recent_entries'] as List;
      if (recentEntries.isNotEmpty) {
        final recentMood = recentEntries.last['mood_score'] ?? 5;
        if (recentMood <= 4) {
          contextualSupport = '\n\nHe notado en tus reflexiones recientes que has estado navegando algunos desafíos. Quiero que sepas que estos momentos difíciles son parte natural de la experiencia humana y que tu disposición a reflexionar sobre ellos muestra una gran fortaleza.';
        }
      }
    }

    return CoachResponse(
      response: supportResponse + contextualSupport,
      confidence: 0.85,
      sources: ['soporte emocional', 'coaching empático'],
    );
  }

  /// 💡 Generar respuesta de recomendaciones
  Future<CoachResponse> _generateRecommendationsResponse(String message, String context) async {
    if (_userWellnessData == null) {
      return CoachResponse(
        response: '''Te puedo ofrecer algunas recomendaciones generales para el bienestar:

• **Práctica de mindfulness**: Dedica 5-10 minutos diarios a la meditación o respiración consciente
• **Registro emocional**: Mantén un diario de emociones para aumentar tu autoconocimiento
• **Actividad física**: Incorpora al menos 30 minutos de movimiento en tu día
• **Conexiones sociales**: Cultiva relaciones significativas con familiares y amigos
• **Rutina de sueño**: Mantén horarios regulares de descanso

¿Te gustaría que personalice estas recomendaciones una vez que comiences a registrar tus reflexiones diarias?''',
        confidence: 0.7,
        sources: ['recomendaciones generales'],
      );
    }

    final recommendations = _generatePersonalizedRecommendations();

    return CoachResponse(
      response: '''Basándome en tu historial de bienestar, aquí tienes mis recomendaciones personalizadas:

${recommendations.map((rec) => '• **${rec['title']}**: ${rec['description']}').join('\n')}

${recommendations.isNotEmpty ? '\n¿Te gustaría que profundice en alguna de estas recomendaciones?' : ''}''',
      confidence: 0.9,
      sources: ['análisis personalizado', 'patrones de bienestar'],
    );
  }

  /// 🔍 Generar respuesta de exploración de datos
  Future<CoachResponse> _generateDataExplorationResponse(String message, String context) async {
    if (_userWellnessData == null) {
      return CoachResponse(
        response: 'Aún no tengo datos suficientes para responder esa pregunta específica. Una vez que registres algunas reflexiones, podré ayudarte a explorar patrones específicos en tus datos.',
        confidence: 0.6,
        sources: ['sin datos'],
      );
    }

    final recentEntries = _userWellnessData!['recent_entries'] as List<Map<String, dynamic>>;
    final exploration = _exploreSpecificData(message, recentEntries);

    return CoachResponse(
      response: exploration,
      confidence: 0.8,
      sources: ['exploración de datos', 'análisis específico'],
    );
  }

  /// 💬 Generar respuesta de chat general
  Future<CoachResponse> _generateGeneralChatResponse(String message, String context) async {
    // Respuestas empáticas y coaching para chat general
    final responses = [
      'Esa es una reflexión muy valiosa. Como tu coach, me interesa conocer más sobre lo que estás experimentando. ¿Podrías contarme un poco más sobre lo que hay detrás de esa idea?',
      'Me alegra que compartas eso conmigo. En mi experiencia como coach de bienestar, he visto que este tipo de reflexiones son el punto de partida para un crecimiento muy significativo.',
      'Gracias por confiar en mí con esa reflexión. ¿Hay algo específico sobre tu bienestar emocional en lo que te gustaría que profundicemos juntos?',
      'Es interesante lo que mencionas. Como tu coach, me gustaría ayudarte a explorar esa idea desde diferentes perspectivas. ¿Qué te parece si comenzamos por entender cómo te hace sentir?',
    ];

    final randomResponse = responses[math.Random().nextInt(responses.length)];

    return CoachResponse(
      response: randomResponse,
      confidence: 0.75,
      sources: ['coaching conversacional'],
    );
  }

  /// 📊 Analizar métricas de bienestar
  Map<String, dynamic> _analyzeWellnessMetrics(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return {};

    final moodScores = entries.map((e) =>
        ((e['mood_score'] ?? 5) as num).toDouble()).toList();
    final energyLevels = entries.map((e) =>
        ((e['energy_level'] ?? 5) as num).toDouble()).toList();
    final stressLevels = entries.map((e) =>
        ((e['stress_level'] ?? 5) as num).toDouble()).toList();

    final avgMood = moodScores.reduce((a, b) => a + b) / moodScores.length;
    final avgEnergy = energyLevels.reduce((a, b) => a + b) / energyLevels.length;
    final avgStress = stressLevels.reduce((a, b) => a + b) / stressLevels.length;

    return {
      'days': entries.length,
      'avgMood': avgMood.toStringAsFixed(1),
      'avgEnergy': avgEnergy.toStringAsFixed(1),
      'avgStress': avgStress.toStringAsFixed(1),
      'moodInterpretation': avgMood >= 7 ? 'un estado emocional positivo' :
      avgMood >= 5 ? 'un equilibrio emocional saludable' :
      'algunos desafíos emocionales que estás navegando con valentía',
      'moodPattern': _analyzeMoodTrend(moodScores),
      'energyInsight': avgEnergy >= 7 ? 'Mantienes buenos niveles de vitalidad' :
      avgEnergy >= 5 ? 'Tu energía está en niveles moderados' :
      'Podríamos trabajar en estrategias para optimizar tu energía',
      'stressInsight': avgStress <= 4 ? 'Gestionas el estrés de manera efectiva' :
      avgStress <= 7 ? 'Tus niveles de estrés están en rango normal' :
      'Es importante que prestemos atención a tu gestión del estrés',
      'keyPattern': _identifyKeyPattern(moodScores, energyLevels, stressLevels),
    };
  }

  /// 📈 Analizar tendencia del estado de ánimo
  String _analyzeMoodTrend(List<double> moodScores) {
    if (moodScores.length < 2) return 'necesito más datos para identificar tendencias';

    final firstHalf = moodScores.take(moodScores.length ~/ 2).toList();
    final secondHalf = moodScores.skip(moodScores.length ~/ 2).toList();

    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

    if (secondAvg > firstAvg + 0.5) {
      return 'una tendencia positiva en tu estado de ánimo últimamente';
    } else if (firstAvg > secondAvg + 0.5) {
      return 'algunos desafíos recientes, pero esto es información valiosa para trabajar juntos';
    } else {
      return 'una estabilidad emocional, lo cual habla de tu capacidad de autorregulación';
    }
  }

  /// 🔍 Identificar patrón clave
  String _identifyKeyPattern(List<double> mood, List<double> energy, List<double> stress) {
    // Calcular correlaciones simples
    final moodEnergyCorr = _calculateSimpleCorrelation(mood, energy);
    final moodStressCorr = _calculateSimpleCorrelation(mood, stress.map((s) => 10 - s).toList());

    if (moodEnergyCorr > 0.6) {
      return 'Existe una conexión positiva entre tu estado de ánimo y niveles de energía, lo cual es una fortaleza importante.';
    } else if (moodStressCorr > 0.6) {
      return 'Muestras una buena capacidad para mantener un estado de ánimo positivo incluso cuando gestionas estrés.';
    } else {
      return 'Tus patrones emocionales muestran una complejidad natural que habla de tu profundidad emocional.';
    }
  }

  /// 📊 Calcular correlación simple
  double _calculateSimpleCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 2) return 0.0;

    final meanX = x.reduce((a, b) => a + b) / x.length;
    final meanY = y.reduce((a, b) => a + b) / y.length;

    double numerator = 0.0;
    double sumSqX = 0.0;
    double sumSqY = 0.0;

    for (int i = 0; i < x.length; i++) {
      final diffX = x[i] - meanX;
      final diffY = y[i] - meanY;
      numerator += diffX * diffY;
      sumSqX += diffX * diffX;
      sumSqY += diffY * diffY;
    }

    final denominator = math.sqrt(sumSqX * sumSqY);
    return denominator == 0 ? 0.0 : numerator / denominator;
  }

  /// 😊 Detectar emoción en mensaje
  String _detectEmotion(String message) {
    final lowercaseMessage = message.toLowerCase();

    if (lowercaseMessage.contains(RegExp(r'\b(triste|tristeza|deprimi|llor|dolor|sufr)\b'))) {
      return 'sadness';
    } else if (lowercaseMessage.contains(RegExp(r'\b(ansio|nervio|preocup|mied|p[aá]nic)\b'))) {
      return 'anxiety';
    } else if (lowercaseMessage.contains(RegExp(r'\b(enoja|ira|rabia|molest|frustrat)\b'))) {
      return 'anger';
    } else if (lowercaseMessage.contains(RegExp(r'\b(fel[íi]z|alegr|content|emociona)\b'))) {
      return 'happiness';
    } else if (lowercaseMessage.contains(RegExp(r'\b(estresa|agobia|presiona|tens)\b'))) {
      return 'stress';
    } else {
      return 'neutral';
    }
  }

  /// 💙 Generar soporte emocional específico
  String _generateEmotionalSupport(String emotion, String message) {
    switch (emotion) {
      case 'sadness':
        return '''Veo que estás pasando por un momento difícil y quiero que sepas que es completamente válido sentirse así. La tristeza es una emoción natural que nos permite procesar experiencias difíciles.

Algunas estrategias que pueden ayudarte:
• Permítete sentir la emoción sin juzgarte
• Busca actividades que nutran tu alma (música, naturaleza, arte)
• Conecta con personas que te brinden apoyo
• Recuerda que este sentimiento es temporal

¿Te gustaría que exploremos juntos qué está detrás de esta tristeza?''';

      case 'anxiety':
        return '''Reconozco la ansiedad que estás experimentando. Es una respuesta natural de nuestro cuerpo ante situaciones que percibimos como desafiantes.

Técnicas que pueden ayudarte ahora mismo:
• Respiración 4-7-8: inhala 4 segundos, mantén 7, exhala 8
• Técnica de grounding: nombra 5 cosas que ves, 4 que puedes tocar, 3 que escuchas
• Recuérdate que estás seguro/a en este momento
• Enfócate en lo que sí puedes controlar

¿Quieres que practiquemos juntos alguna de estas técnicas?''';

      case 'anger':
        return '''La ira que sientes es una emoción válida que nos indica que algo importante para nosotros se ha visto afectado. Es saludable reconocerla.

Para gestionar esta energía de manera constructiva:
• Toma respiraciones profundas antes de actuar
• Identifica qué necesidad o valor se sintió amenazado
• Busca formas de expresar tu perspectiva de manera asertiva
• Considera el ejercicio físico para canalizar la energía

¿Te gustaría explorar qué hay detrás de esta ira para transformarla en acción constructiva?''';

      case 'stress':
        return '''El estrés que sientes es una señal de que tu sistema está respondiendo a demandas elevadas. Es importante que cuidemos tu bienestar.

Estrategias inmediatas para el estrés:
• Prioriza las tareas más importantes y delega lo que puedas
• Toma descansos regulares, aunque sean de 5 minutos
• Practica mindfulness o meditación breve
• Asegúrate de mantener hábitos básicos: sueño, alimentación, hidratación

¿Qué aspectos específicos del estrés te gustaría que abordemos juntos?''';

      case 'happiness':
        return '''¡Qué maravilloso poder acompañarte en este momento de alegría! Es importante celebrar y saborear estos momentos positivos.

Para potenciar este bienestar:
• Tómate un momento para apreciar conscientemente esta sensación
• Comparte tu alegría con personas importantes para ti
• Reflexiona sobre qué contribuyó a este estado positivo
• Considera cómo puedes incorporar más de estos elementos en tu vida

¿Te gustaría explorar qué factores han contribuido a este estado positivo?''';

      default:
        return '''Gracias por compartir lo que estás sintiendo conmigo. Crear un espacio para expresar nuestras emociones es fundamental para el bienestar.

Como tu coach, estoy aquí para:
• Escucharte sin juicio
• Ayudarte a explorar tus emociones con curiosidad
• Acompañarte en el desarrollo de estrategias de bienestar
• Celebrar tus fortalezas y crecimiento

¿Hay algo específico sobre tu estado emocional actual que te gustaría explorar más profundamente?''';
    }
  }

  /// 💡 Generar recomendaciones personalizadas
  List<Map<String, String>> _generatePersonalizedRecommendations() {
    if (_userWellnessData == null) return [];

    final recentEntries = _userWellnessData!['recent_entries'] as List<Map<String, dynamic>>;
    if (recentEntries.isEmpty) return [];

    final recommendations = <Map<String, String>>[];

    // Analizar patrones para recomendaciones específicas
    final avgMood = recentEntries
        .map((e) => ((e['mood_score'] ?? 5) as num).toDouble())
        .reduce((a, b) => a + b) / recentEntries.length;

    final avgEnergy = recentEntries
        .map((e) => ((e['energy_level'] ?? 5) as num).toDouble())
        .reduce((a, b) => a + b) / recentEntries.length;

    final avgStress = recentEntries
        .map((e) => ((e['stress_level'] ?? 5) as num).toDouble())
        .reduce((a, b) => a + b) / recentEntries.length;

    if (avgMood < 6) {
      recommendations.add({
        'title': 'Práctica de Gratitud Personalizada',
        'description': 'Basándome en tus patrones, te sugiero una práctica diaria de 3 gratitudes específicas cada mañana durante 2 semanas para elevar tu estado de ánimo naturalmente.',
      });
    }

    if (avgEnergy < 6) {
      recommendations.add({
        'title': 'Optimización de Energía',
        'description': 'Tus datos sugieren que podrías beneficiarte de revisar tu rutina de sueño y considerar incorporar 10 minutos de movimiento energizante cada mañana.',
      });
    }

    if (avgStress > 7) {
      recommendations.add({
        'title': 'Técnica de Relajación Progresiva',
        'description': 'Dado tus niveles de estrés, te recomiendo practicar 5 minutos de relajación muscular progresiva antes de dormir para mejorar tu descanso y reducir tensión.',
      });
    }

    if (recommendations.isEmpty) {
      recommendations.add({
        'title': 'Mantenimiento del Bienestar',
        'description': 'Tus métricas muestran un buen equilibrio. Te sugiero mantener tus prácticas actuales y considerar añadir una nueva actividad que te genere curiosidad o crecimiento.',
      });
    }

    return recommendations;
  }

  /// 🔍 Explorar datos específicos
  String _exploreSpecificData(String message, List<Map<String, dynamic>> entries) {
    final lowercaseMessage = message.toLowerCase();

    if (lowercaseMessage.contains('mejor') || lowercaseMessage.contains('máximo')) {
      final bestDay = _findBestDay(entries);
      return bestDay.isNotEmpty
          ? 'Tu mejor día registrado fue el ${bestDay['date']} con un estado de ánimo de ${bestDay['mood']}/10. ¿Recuerdas qué hiciste especial ese día?'
          : 'Aún necesito más datos para identificar tu mejor día.';
    }

    if (lowercaseMessage.contains('peor') || lowercaseMessage.contains('difícil')) {
      final worstDay = _findMostChallengingDay(entries);
      return worstDay.isNotEmpty
          ? 'El día más desafiante fue el ${worstDay['date']} con un estado de ánimo de ${worstDay['mood']}/10. Es valioso reflexionar sobre cómo lograste superar ese momento.'
          : 'No he identificado días particularmente difíciles en tus registros recientes.';
    }

    return 'Basándome en tus datos, puedo ver que has registrado ${entries.length} reflexiones. ¿Hay algún patrón específico que te gustaría que exploremos juntos?';
  }

  /// 📅 Encontrar mejor día
  Map<String, dynamic> _findBestDay(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return {};

    var bestEntry = entries.first;
    for (final entry in entries) {
      final currentMood = (entry['mood_score'] ?? 0) as num;
      final bestMood = (bestEntry['mood_score'] ?? 0) as num;
      if (currentMood > bestMood) {
        bestEntry = entry;
      }
    }

    return {
      'date': bestEntry['entry_date']?.toString().split(' ')[0] ?? 'fecha desconocida',
      'mood': bestEntry['mood_score'] ?? 0,
    };
  }

  /// 📅 Encontrar día más desafiante
  Map<String, dynamic> _findMostChallengingDay(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return {};

    var worstEntry = entries.first;
    for (final entry in entries) {
      final currentMood = (entry['mood_score'] ?? 10) as num;
      final worstMood = (worstEntry['mood_score'] ?? 10) as num;
      if (currentMood < worstMood) {
        worstEntry = entry;
      }
    }

    return {
      'date': worstEntry['entry_date']?.toString().split(' ')[0] ?? 'fecha desconocida',
      'mood': worstEntry['mood_score'] ?? 0,
    };
  }

  /// 🔄 Actualizar datos de bienestar si es necesario
  Future<void> _updateWellnessDataIfNeeded() async {
    if (_lastWellnessDataUpdate == null ||
        DateTime.now().difference(_lastWellnessDataUpdate!).inMinutes > 30) {
      await _loadUserWellnessData();
    }
  }

  /// 📝 Construir contexto de la conversación
  String _buildConversationContext() {
    if (_currentConversation == null || _currentConversation!.messages.isEmpty) {
      return '';
    }

    final recentMessages = _currentConversation!.messages
        .where((msg) => !msg.isThinking && !msg.isError)
        .take(6)
        .toList();

    final contextString = recentMessages
        .map((msg) => '${msg.roleDisplay}: ${msg.content.length > 100 ? msg.content.substring(0, 100) + '...' : msg.content}')
        .join('\n');

    return contextString;
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

  /// ➖ Remover mensaje de conversación actual
  void _removeMessageFromCurrentConversation(String messageId) {
    if (_currentConversation != null) {
      _currentConversation = _currentConversation!.removeMessage(messageId);

      // Actualizar en la lista de conversaciones
      final index = _conversations.indexWhere((conv) => conv.id == _currentConversation!.id);
      if (index != -1) {
        _conversations[index] = _currentConversation!;
      }

      notifyListeners();
    }
  }

  /// 🧹 Remover mensajes de "pensando"
  void _removeThinkingMessages() {
    if (_currentConversation != null) {
      final filteredMessages = _currentConversation!.messages
          .where((msg) => !msg.isThinking)
          .toList();

      _currentConversation = _currentConversation!.copyWith(messages: filteredMessages);

      // Actualizar en la lista
      final index = _conversations.indexWhere((conv) => conv.id == _currentConversation!.id);
      if (index != -1) {
        _conversations[index] = _currentConversation!;
      }

      notifyListeners();
    }
  }

  /// 🆕 Crear nueva conversación
  Future<void> createNewConversation() async {
    final conversation = ChatConversation.create(
      userId: 'current_user',
      title: 'Nueva conversación ${_conversations.length + 1}',
    );

    _conversations.insert(0, conversation);
    _currentConversation = conversation;
    await _saveConversations();

    notifyListeners();
    _logger.i('🆕 Nueva conversación creada');
  }

  /// 🔄 Cambiar conversación activa
  void setCurrentConversation(String conversationId) {
    final conversation = _conversations.firstWhere(
          (conv) => conv.id == conversationId,
      orElse: () => _conversations.first,
    );

    _currentConversation = conversation;
    notifyListeners();
    _logger.i('🔄 Conversación cambiada: $conversationId');
  }

  /// 🗑️ Eliminar conversación
  Future<void> deleteConversation(String conversationId) async {
    _conversations.removeWhere((conv) => conv.id == conversationId);

    // Si se eliminó la conversación actual, seleccionar otra
    if (_currentConversation?.id == conversationId) {
      if (_conversations.isNotEmpty) {
        _currentConversation = _conversations.first;
      } else {
        await _createDefaultConversation();
      }
    }

    await _saveConversations();
    notifyListeners();
    _logger.i('🗑️ Conversación eliminada: $conversationId');
  }

  /// 🔄 Reiniciar IA
  Future<void> reinitializeAI() async {
    _logger.i('🔄 Reiniciando chat...');
    await _checkAIReadiness();
    await _loadUserWellnessData();
    _clearError();
    notifyListeners();
  }

  /// 🧹 Limpiar todas las conversaciones
  Future<void> clearAllConversations() async {
    _conversations.clear();
    _currentConversation = null;
    await _createDefaultConversation();
    await _saveConversations();
    notifyListeners();
    _logger.i('🧹 Todas las conversaciones eliminadas');
  }

  // Métodos de estado privados
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

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setAIStatus(String status) {
    _aiStatus = status;
    notifyListeners();
  }

  /// 📊 Obtener estadísticas del chat
  Map<String, dynamic> getChatStats() {
    final totalMessages = _conversations
        .expand((conv) => conv.messages)
        .where((msg) => !msg.isThinking && !msg.isError)
        .length;

    final userMessages = _conversations
        .expand((conv) => conv.messages)
        .where((msg) => msg.isUser)
        .length;

    final assistantMessages = _conversations
        .expand((conv) => conv.messages)
        .where((msg) => msg.isAssistant)
        .length;

    return {
      'total_conversations': _conversations.length,
      'total_messages': totalMessages,
      'user_messages': userMessages,
      'assistant_messages': assistantMessages,
      'ai_ready': _isAIReady,
      'ai_status': _aiStatus,
      'wellness_data_loaded': _userWellnessData != null,
    };
  }

  /// 📈 Obtener recomendaciones prioritarias
  List<String> getPriorityRecommendations() {
    if (_userWellnessData == null) return [];

    final personalizedRecs = _generatePersonalizedRecommendations();
    return personalizedRecs.take(3).map((rec) => rec['title']!).toList();
  }

  /// 🔥 Verificar si hay alertas críticas
  bool hasCriticalAlerts() {
    if (_userWellnessData == null) return false;

    final recentEntries = _userWellnessData!['recent_entries'] as List<Map<String, dynamic>>;
    if (recentEntries.isEmpty) return false;

    // Alertas basadas en patrones preocupantes
    final recentMoods = recentEntries.take(3).map((e) =>
        ((e['mood_score'] ?? 5) as num).toDouble()).toList();
    final avgRecentMood = recentMoods.reduce((a, b) => a + b) / recentMoods.length;

    return avgRecentMood <= 3; // Estado de ánimo muy bajo en días recientes
  }
}

// Enums y clases auxiliares
enum QueryType {
  wellnessAnalysis,
  emotionalSupport,
  recommendations,
  dataExploration,
  generalChat,
}

class CoachResponse {
  final String response;
  final double confidence;
  final List<String> sources;

  CoachResponse({
    required this.response,
    required this.confidence,
    required this.sources,
  });
}