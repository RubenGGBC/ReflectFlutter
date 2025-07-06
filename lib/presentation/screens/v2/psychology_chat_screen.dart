// lib/presentation/screens/v2/psychology_chat_screen.dart
// ============================================================================
// SISTEMA DE CHAT PSICÓLOGO CON IA - VERSIÓN CORREGIDA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// Imports corregidos
import '../../../ai/provider/chat_provider.dart';
import '../../../ai/provider/ai_provider.dart';
import '../../../ai/services/phi_model_service_genai_complete.dart';
import '../../../ai/services/psychology_chat_extension.dart';
import '../../providers/optimized_providers.dart';
import '../../../data/models/chat_message_model.dart';
import '../components/modern_design_system.dart';

class PsychologyChatScreen extends StatefulWidget {
  const PsychologyChatScreen({super.key});

  @override
  State<PsychologyChatScreen> createState() => _PsychologyChatScreenState();
}

class _PsychologyChatScreenState extends State<PsychologyChatScreen>
    with TickerProviderStateMixin {

  // Controllers y animaciones
  late AnimationController _animationController;
  late AnimationController _statusController;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _statusColorAnimation;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocus = FocusNode();

  bool _showScrollToBottom = false;
  bool _isAIValidated = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollListener();
    _validateAIAndInitialize();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _statusController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _statusColorAnimation = ColorTween(
      begin: Colors.orange,
      end: Colors.green,
    ).animate(CurvedAnimation(
      parent: _statusController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final showButton = _scrollController.offset > 200;
      if (showButton != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = showButton;
        });
      }
    });
  }

  /// 🧠 Validar que la IA esté completamente funcional
  Future<void> _validateAIAndInitialize() async {
    final aiProvider = context.read<AIProvider>();
    final chatProvider = context.read<ChatProvider>();

    try {
      // 1. Verificar que el servicio de IA esté inicializado
      if (!aiProvider.isInitialized) {
        debugPrint('🔄 IA no inicializada, iniciando...');
        await aiProvider.initializeAI();
      }

      // 2. Validar que GenAI esté disponible (sin fallback)
      final phiService = PhiModelServiceGenAI.instance;
      if (!phiService.isInitialized || !phiService.isGenAIAvailable) {
        throw Exception('IA no disponible - GenAI requerido para chat psicológico');
      }

      // 3. Verificar capacidades de chat
      final chatCapabilities = phiService.getPsychologyCapabilities();
      if (!chatCapabilities['psychology_available']) {
        throw Exception('Capacidades de psicología no disponibles: ${chatCapabilities['error_if_unavailable']}');
      }

      // 4. Validar que ChatProvider esté listo
      if (!chatProvider.isAIReady) {
        throw Exception('ChatProvider no está listo: ${chatProvider.aiStatus}');
      }

      // 5. Crear conversación específica para psicología si no existe
      await _ensurePsychologyConversation(chatProvider);

      setState(() {
        _isAIValidated = true;
      });

      _animationController.forward();
      _statusController.forward();

      debugPrint('✅ Sistema de chat psicológico validado y listo');

    } catch (e) {
      debugPrint('❌ Error validando IA: $e');
      _showAIError(e.toString());
    }
  }

  /// 🧑‍⚕️ Asegurar que existe conversación específica para psicología
  Future<void> _ensurePsychologyConversation(ChatProvider chatProvider) async {
    // Buscar conversación existente de psicología
    final existingPsychConv = chatProvider.conversations.any(
          (conv) => conv.title.contains('Psicólogo IA') || conv.title.contains('Sesión'),
    );

    // Si no existe, crear nueva conversación
    if (!existingPsychConv) {
      await chatProvider.createNewConversation();
      // Cambiar el título de la conversación creada
      if (chatProvider.currentConversation != null) {
        // Como no puedo modificar el título directamente, creo una nueva específica
        await _createPsychologyConversation(chatProvider);
      }
    } else {
      // Usar conversación existente de psicología
      final psychConv = chatProvider.conversations.firstWhere(
            (conv) => conv.title.contains('Psicólogo IA') || conv.title.contains('Sesión'),
      );
      chatProvider.setCurrentConversation(psychConv.id);
    }
  }

  /// 🧑‍⚕️ Crear conversación específica de psicología
  Future<void> _createPsychologyConversation(ChatProvider chatProvider) async {
    // Usar el método público para crear conversación
    await chatProvider.createNewConversation();

    // La conversación ya tendrá el mensaje de bienvenida del coach
    // Podemos enviar un mensaje inicial del sistema para psicología
    if (chatProvider.currentConversation != null) {
      // El mensaje de bienvenida ya se crea automáticamente en createNewConversation
      debugPrint('✅ Conversación de psicología lista');
    }
  }

  /// ❌ Mostrar error de IA
  void _showAIError(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ModernColors.surfaceDark,
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('IA No Disponible', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El sistema de IA no está funcionando correctamente:',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                error,
                style: const TextStyle(
                  color: Colors.red,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Requisitos del sistema:',
              style: TextStyle(
                color: Colors.grey[300],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...{
              '✓ GenAI nativo disponible',
              '✓ Servicio de IA inicializado',
              '✓ Capacidades de chat habilitadas',
              '✓ Modelo Phi-3.5 descargado',
            }.map((req) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                req,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            )).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _validateAIAndInitialize();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernColors.accentBlue,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  /// 📤 Enviar mensaje del usuario
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    _messageFocus.unfocus();

    final chatProvider = context.read<ChatProvider>();

    try {
      // Usar el método público sendMessage del ChatProvider
      await chatProvider.sendMessage(message);
      _scrollToBottom();
    } catch (e) {
      _showErrorSnackBar('Error enviando mensaje: $e');
    }
  }

  /// 📜 Scroll automático al final
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// ⚠️ Mostrar error en SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _statusController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isAIValidated
                ? _buildChatInterface()
                : _buildValidationScreen(),
          ),
        ],
      ),
    );
  }

  /// 🎯 Header de la pantalla
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.accentBlue.withOpacity(0.1),
            ModernColors.accentPurple.withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Icon(
            Icons.psychology,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Psicólogo IA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isAIValidated)
                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) {
                      return Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: chatProvider.isAIReady
                                  ? Colors.green
                                  : Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            chatProvider.isAIReady
                                ? 'En línea • Sesión activa'
                                : chatProvider.aiStatus,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔄 Pantalla de validación de IA
  Widget _buildValidationScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ModernColors.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.psychology,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Iniciando Sesión de Psicología',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Consumer<AIProvider>(
                  builder: (context, aiProvider, _) {
                    return Column(
                      children: [
                        Text(
                          aiProvider.status,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (aiProvider.isInitializing)
                          Column(
                            children: [
                              CircularProgressIndicator(
                                value: aiProvider.initProgress > 0
                                    ? aiProvider.initProgress
                                    : null,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                              if (aiProvider.initProgress > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${(aiProvider.initProgress * 100).toInt()}%',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 💬 Interfaz principal de chat
  Widget _buildChatInterface() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final messages = chatProvider.currentMessages;

                if (messages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  /// 🌟 Estado vacío cuando no hay mensajes
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Inicia tu sesión de psicología',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comparte lo que sientes o piensas',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// 💬 Burbuja de mensaje individual
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.type == MessageType.user;
    final isSystem = message.type == MessageType.system;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: isSystem
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
              child: Icon(
                isSystem ? Icons.info_outline : Icons.psychology,
                color: isSystem ? Colors.blue : Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser
                    ? ModernColors.accentBlue
                    : isSystem
                    ? Colors.blue.withOpacity(0.1)
                    : ModernColors.surfaceDark,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: Border.all(
                  color: isUser
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser && !isSystem)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(
                            'Dr. IA',
                            style: TextStyle(
                              color: Colors.green[300],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.verified,
                            size: 12,
                            color: Colors.green[300],
                          ),
                        ],
                      ),
                    ),
                  Text(
                    message.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: ModernColors.accentBlue.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ⌨️ Input para escribir mensajes
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          return Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ModernColors.darkPrimary,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _messageFocus,
                    enabled: !chatProvider.isSendingMessage,
                    maxLines: null,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: chatProvider.isSendingMessage
                          ? 'Dr. IA está pensando...'
                          : '¿Qué te gustaría compartir?',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Material(
                  color: chatProvider.isSendingMessage
                      ? Colors.grey[700]
                      : ModernColors.accentBlue,
                  borderRadius: BorderRadius.circular(25),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: chatProvider.isSendingMessage ? null : _sendMessage,
                    child: Container(
                      width: 50,
                      height: 50,
                      child: chatProvider.isSendingMessage
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                          : const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}