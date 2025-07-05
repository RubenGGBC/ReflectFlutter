// lib/presentation/screens/v2/ai_chat_screen.dart
// ============================================================================
// AI CHAT SCREEN - CHAT CON MEMORIA E IA
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
  late Animation<double> _fadeAnimation;
  late Animation<double> _fabAnimation;

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

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    _animationController.dispose();
    _fabController.dispose();
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
              // Avatar del Coach IA
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  chat.isAIReady ? Icons.psychology : Icons.psychology_outlined,
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
                      '🤖 Coach IA Personal',
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
                      chat.isAIReady ? Icons.check_circle : Icons.error,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      chat.isAIReady ? 'Listo' : 'Error',
                      style: ModernTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Menú de acciones
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () => _showChatMenu(context, chat),
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
              color: ModernColors.accentBlue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(ModernColors.accentBlue),
                  strokeWidth: 3,
                ),
                const Icon(
                  Icons.chat,
                  color: ModernColors.accentBlue,
                  size: 32,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '🚀 Preparando Chat IA',
            style: ModernTypography.heading3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Inicializando conversación...',
            style: ModernTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.7),
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
            '💬 Inicia una conversación',
            style: ModernTypography.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Pregúntame sobre tu bienestar, patrones\no cualquier tema relacionado con tu desarrollo personal',
            style: ModernTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildSuggestedQuestions(),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    final suggestions = [
      '¿Cómo puedo mejorar mi bienestar?',
      'Analiza mis patrones recientes',
      '¿Qué me recomiendas para hoy?',
      'Ayúdame con mi estado de ánimo',
    ];

    return Column(
      children: suggestions.map((suggestion) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: TextButton(
            onPressed: () {
              _messageController.text = suggestion;
              _sendMessage();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              suggestion,
              style: ModernTypography.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            _buildAvatar(message),
            const SizedBox(width: 8),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildMessageHeader(message),
                const SizedBox(height: 4),
                _buildMessageContent(message),
                if (message.isAssistant && message.confidence != null)
                  _buildConfidenceIndicator(message.confidence!),
              ],
            ),
          ),

          if (message.isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(message),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(ChatMessage message) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: message.isUser
            ? LinearGradient(colors: [Colors.blue, Colors.purple])
            : LinearGradient(colors: ModernColors.primaryGradient),
        shape: BoxShape.circle,
      ),
      child: Icon(
        message.isUser ? Icons.person : Icons.psychology,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildMessageHeader(ChatMessage message) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.roleDisplay,
          style: ModernTypography.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          message.displayTime,
          style: ModernTypography.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        if (message.isUser) ...[
          const SizedBox(width: 8),
          _buildMessageStatus(message),
        ],
      ],
    );
  }

  Widget _buildMessageContent(ChatMessage message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getMessageBackgroundColor(message),
        borderRadius: BorderRadius.circular(16),
        border: message.isError
            ? Border.all(color: Colors.red.withOpacity(0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isThinking)
            _buildThinkingIndicator()
          else
            Text(
              message.content,
              style: ModernTypography.bodyMedium.copyWith(
                color: Colors.white,
                height: 1.4,
              ),
            ),

          if (message.sources?.isNotEmpty == true)
            _buildSourcesIndicator(message.sources!),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.7)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Pensando...',
          style: ModernTypography.bodyMedium.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageStatus(ChatMessage message) {
    IconData icon;
    Color color;

    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.blue;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.green;
        break;
      case MessageStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
      default:
        icon = Icons.check;
        color = Colors.grey;
    }

    return Icon(icon, size: 16, color: color);
  }

  Widget _buildConfidenceIndicator(double confidence) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 12,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(width: 4),
          Text(
            'Confianza: ${(confidence * 100).round()}%',
            style: ModernTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
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
            child: Row(
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
                            : 'IA no disponible...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: ModernColors.primaryGradient),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: chat.isAIReady && !chat.isSendingMessage
                        ? _sendMessage
                        : null,
                    icon: chat.isSendingMessage
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getMessageBackgroundColor(ChatMessage message) {
    if (message.isUser) {
      return ModernColors.accentBlue.withOpacity(0.3);
    } else if (message.isError) {
      return Colors.red.withOpacity(0.2);
    } else if (message.isSystem) {
      return Colors.green.withOpacity(0.2);
    } else if (message.isThinking) {
      return Colors.orange.withOpacity(0.2);
    } else {
      return Colors.white.withOpacity(0.1);
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chat = context.read<ChatProvider>();
    _messageController.clear();
    chat.sendMessage(text);

    // Scroll to bottom después de enviar
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
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

  void _showChatMenu(BuildContext context, ChatProvider chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ModernColors.darkSecondary,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add, color: Colors.white),
              title: const Text('Nueva Conversación', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                chat.createNewConversation();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.white),
              title: const Text('Reiniciar IA', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                chat.reinitializeAI();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text('Limpiar Chat', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showClearConfirmation(context, chat);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, ChatProvider chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernColors.darkSecondary,
        title: const Text('Confirmar', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todas las conversaciones?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              chat.clearAllConversations();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}