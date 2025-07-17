// lib/presentation/screens/v2/ai_chat_screen.dart
// ============================================================================
// AI CHAT SCREEN - CONVERSACIÓN GENERAL CON IA Y MEMORIA EMOCIONAL
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../../ai/provider/chat_provider.dart';
import '../../../ai/provider/ai_provider.dart';
import '../../providers/optimized_providers.dart';
import '../../../data/models/chat_message_model.dart';
import '../components/modern_design_system.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fabController;
  late AnimationController _typingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _fabAnimation;
  late Animation<double> _typingAnimation;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocus = FocusNode();

  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupChatListener();
  }

  void _setupChatListener() {
    // Solo configurar una vez
    if (!mounted) return;

    final chat = Provider.of<ChatProvider>(context, listen: false);
    // Remover listener anterior si existe
    chat.removeListener(_onChatStateChanged);
    // Agregar nuevo listener
    chat.addListener(_onChatStateChanged);
  }

  void _onChatStateChanged() {
    final chat = Provider.of<ChatProvider>(context, listen: false);

    // Manejar animación de typing
    if (chat.isSendingMessage) {
      _typingController.repeat();
    } else {
      _typingController.stop();
      _typingController.reset();
    }

    // Auto-scroll cuando llega un nuevo mensaje
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final showButton = _scrollController.offset > 200;
      if (showButton != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = showButton;
        });
        if (showButton) {
          _fabController.forward();
        } else {
          _fabController.reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    // Remover listener de forma segura
    try {
      final chat = Provider.of<ChatProvider>(context, listen: false);
      chat.removeListener(_onChatStateChanged);
    } catch (e) {
      // Ignorar errores si el context ya no está disponible
    }

    _animationController.dispose();
    _fabController.dispose();
    _typingController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chat, _) {
                  if (chat.isLoading) {
                    return _buildLoadingState();
                  }

                  return Stack(
                    children: [
                      _buildMessagesList(chat),
                      _buildScrollToBottomFab(),
                      if (chat.isSendingMessage) _buildTypingIndicator(),
                    ],
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(
        top: 50,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: ModernColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Consumer2<ChatProvider, AIProvider>(
        builder: (context, chat, ai, _) {
          return Row(
            children: [
              // Avatar del Asistente IA
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  chat.isAIReady ? Icons.smart_toy : Icons.smart_toy_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Info del Chat
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🤖 Asistente IA',
                      style: ModernTypography.heading3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      chat.aiStatus,
                      style: ModernTypography.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Menú de opciones
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: ModernColors.darkSecondary,
                onSelected: (value) => _handleMenuAction(value, chat),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'new_chat',
                    child: Row(
                      children: [
                        Icon(Icons.add_comment, color: ModernColors.accentBlue),
                        const SizedBox(width: 8),
                        Text('Nueva conversación', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'clear_chat',
                    child: Row(
                      children: [
                        Icon(Icons.cleaning_services, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text('Limpiar chat', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'reload_ai',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.green),
                        const SizedBox(width: 8),
                        Text('Reiniciar IA', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),

              // Estado de la IA
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: chat.isAIReady
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      chat.isAIReady ? Icons.circle : Icons.circle_outlined,
                      color: chat.isAIReady ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      chat.isAIReady ? 'Online' : 'Offline',
                      style: ModernTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: ModernColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '🚀 Preparando Asistente IA',
            style: ModernTypography.heading3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Consumer<ChatProvider>(
            builder: (context, chat, _) => Text(
              chat.aiStatus,
              style: ModernTypography.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ChatProvider chat) {
    if (chat.currentMessages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chat.currentMessages.length,
      itemBuilder: (context, index) {
        final message = chat.currentMessages[index];
        return _buildMessageBubble(message, index);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ModernColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '💬 ¡Hola! Soy tu asistente IA',
              style: ModernTypography.heading2.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Puedo conversar sobre cualquier tema, ayudarte a resolver problemas, analizar tus emociones y proponerte soluciones personalizadas.',
              style: ModernTypography.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildSuggestedQuestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    final suggestions = [
      '¿Cómo puedes ayudarme?',
      'Necesito consejos para organizarme mejor',
      'Me siento estresado por el trabajo',
      '¿Qué opinas sobre este problema?',
      'Ayúdame a tomar una decisión',
      'Quiero mejorar mis hábitos',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💡 Preguntas sugeridas:',
          style: ModernTypography.bodyMedium.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((suggestion) {
            return GestureDetector(
              onTap: () => _sendSuggestedMessage(suggestion),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  suggestion,
                  style: ModernTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isUser = message.isUser;
    final isSystem = message.isSystem;
    final isError = message.isError;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _buildAvatar(isSystem, isError),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                  colors: ModernColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isUser
                    ? null
                    : isError
                    ? Colors.red.withOpacity(0.2)
                    : isSystem
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser && !isSystem) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.smart_toy,
                          size: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Asistente IA',
                          style: ModernTypography.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    message.content,
                    style: ModernTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.displayTime,
                        style: ModernTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10,
                        ),
                      ),
                      if (message.confidence != null) ...[
                        const SizedBox(width: 8),
                        _buildConfidenceIndicator(message.confidence!),
                      ],
                      if (isUser && message.isSending) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (message.sources?.isNotEmpty == true)
                    _buildSourcesIndicator(message.sources!),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(false, false, isUser: true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isSystem, bool isError, {bool isUser = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: isUser
            ? LinearGradient(
          colors: ModernColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isUser
            ? null
            : isError
            ? Colors.red.withOpacity(0.3)
            : isSystem
            ? Colors.blue.withOpacity(0.3)
            : Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser
            ? Icons.person
            : isError
            ? Icons.error_outline
            : isSystem
            ? Icons.info_outline
            : Icons.smart_toy,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _buildConfidenceIndicator(double confidence) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 10,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(width: 2),
          Text(
            '${(confidence * 100).round()}%',
            style: ModernTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourcesIndicator(List<String> sources) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 4,
        children: sources.take(3).map((source) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              source,
              style: ModernTypography.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Positioned(
      bottom: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.smart_toy,
              size: 16,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              'escribiendo',
              style: ModernTypography.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 20,
              height: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _typingController,
                    builder: (context, child) {
                      final delay = index * 0.2;
                      final progress = (_typingController.value + delay) % 1.0;
                      final opacity = (math.sin(progress * math.pi * 2) + 1) / 2;

                      return Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(opacity * 0.8),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollToBottomFab() {
    return Positioned(
      bottom: 80,
      right: 16,
      child: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.small(
          onPressed: _scrollToBottom,
          backgroundColor: ModernColors.accentBlue,
          child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ModernColors.darkSecondary,
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                if (chat.errorMessage != null) _buildErrorBanner(chat),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          focusNode: _messageFocus,
                          maxLines: null,
                          enabled: chat.isAIReady && !chat.isSendingMessage,
                          decoration: InputDecoration(
                            hintText: chat.isAIReady
                                ? 'Escribe tu mensaje...'
                                : 'Esperando que se inicie la IA...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          onSubmitted: (_) => _sendMessage(chat),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: ModernColors.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: chat.isAIReady && !chat.isSendingMessage
                            ? () => _sendMessage(chat)
                            : null,
                        icon: chat.isSendingMessage
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorBanner(ChatProvider chat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              chat.errorMessage!,
              style: ModernTypography.bodySmall.copyWith(
                color: Colors.red.shade300,
              ),
            ),
          ),
          IconButton(
            onPressed: () => chat.clearError(),
            icon: Icon(Icons.close, color: Colors.red, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _sendMessage(ChatProvider chat) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      chat.sendMessage(message);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _sendSuggestedMessage(String message) {
    _messageController.text = message;
    final chat = Provider.of<ChatProvider>(context, listen: false);
    _sendMessage(chat);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleMenuAction(String action, ChatProvider chat) {
    switch (action) {
      case 'new_chat':
        chat.createNewConversation();
        break;
      case 'clear_chat':
        _showClearChatDialog(chat);
        break;
      case 'reload_ai':
        chat.reloadAI();
        break;
    }
  }

  void _showClearChatDialog(ChatProvider chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernColors.darkSecondary,
        title: Text(
          'Limpiar conversación',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro que quieres limpiar esta conversación? Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              chat.clearCurrentConversation();
            },
            child: Text('Limpiar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}