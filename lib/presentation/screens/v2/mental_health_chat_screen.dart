// lib/presentation/screens/mental_health_chat_screen.dart
// ============================================================================
// MENTAL HEALTH CHAT SCREEN - THERAPEUTIC CONVERSATION INTERFACE
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../../ai/provider/mental_health_chat_provider.dart';
import '../../../data/models/chat_message_model.dart';
import '../components/modern_design_system.dart';

class MentalHealthChatScreen extends StatefulWidget {
  const MentalHealthChatScreen({super.key});

  @override
  State<MentalHealthChatScreen> createState() => _MentalHealthChatScreenState();
}

class _MentalHealthChatScreenState extends State<MentalHealthChatScreen>
    with TickerProviderStateMixin {

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocus = FocusNode();

  late AnimationController _fadeController;
  late AnimationController _typingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // Auto-scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _typingController, curve: Curves.easeInOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _typingController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocus.dispose();
    super.dispose();
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

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    print('🔍 DEBUG: Sending message from UI: "$message"'); // Debug log
    _messageController.clear();

    final chatProvider = context.read<MentalHealthChatProvider>();
    print('🔍 DEBUG: Current messages before send: ${chatProvider.currentMessages.length}'); // Debug log

    // Start typing animation
    _typingController.repeat();

    await chatProvider.sendMessage(message);

    print('🔍 DEBUG: Current messages after send: ${chatProvider.currentMessages.length}'); // Debug log

    // Stop typing animation
    _typingController.stop();
    _typingController.reset();

    // Force rebuild and scroll to bottom
    if (mounted) {
      setState(() {}); // Force rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }

    // Give focus back to input
    _messageFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(child: _buildMessagesList()),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0A0A0A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white70),
        onPressed: () => Navigator.pop(context),
      ),
      title: Consumer<MentalHealthChatProvider>(
        builder: (context, chatProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Espacio Seguro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                chatProvider.aiStatus,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white70),
          color: const Color(0xFF1A1A1A),
          onSelected: (value) => _handleMenuAction(value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'new_conversation',
              child: Row(
                children: [
                  Icon(Icons.add_comment, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Text('Nueva conversación', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'privacy',
              child: Row(
                children: [
                  Icon(Icons.privacy_tip, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Text('Privacidad', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear_all',
              child: Row(
                children: [
                  Icon(Icons.delete_sweep, color: Colors.redAccent, size: 20),
                  SizedBox(width: 12),
                  Text('Limpiar historial', style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return Consumer<MentalHealthChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white54),
                SizedBox(height: 16),
                Text(
                  'Preparando tu espacio seguro...',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          );
        }

        final messages = chatProvider.currentMessages;
        print('🔍 DEBUG: Building messages list with ${messages.length} messages'); // Debug log

        if (messages.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology, size: 64, color: Colors.white24),
                SizedBox(height: 16),
                Text(
                  'Tu espacio seguro está listo',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Comparte lo que necesites, sin juicio',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length + (chatProvider.isSendingMessage ? 1 : 0),
          itemBuilder: (context, index) {
            print('🔍 DEBUG: Building item $index of ${messages.length + (chatProvider.isSendingMessage ? 1 : 0)}'); // Debug log

            if (index == messages.length && chatProvider.isSendingMessage) {
              return _buildTypingIndicator();
            }

            final message = messages[index];
            print('🔍 DEBUG: Message $index - ${message.isUser ? "USER" : "AI"}: "${message.content.substring(0, message.content.length > 50 ? 50 : message.content.length)}..."'); // Debug log
            return _buildMessageBubble(message);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white70,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF2A5BDA).withOpacity(0.8)
                        : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20),
                    border: !isUser ? Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ) : null,
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(message.timestamp),
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2A5BDA).withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white70,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white70,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTypingDot(0),
                    const SizedBox(width: 4),
                    _buildTypingDot(1),
                    const SizedBox(width: 4),
                    _buildTypingDot(2),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    final delay = index * 0.2;
    final progress = (_typingAnimation.value + delay) % 1.0;
    final opacity = (progress * 2).clamp(0.3, 1.0);

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white54.withOpacity(opacity),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Consumer<MentalHealthChatProvider>(
        builder: (context, chatProvider, child) {
          return Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _messageFocus,
                    enabled: !chatProvider.isSendingMessage,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Comparte lo que sientes...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: chatProvider.isSendingMessage ? null : _sendMessage,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: chatProvider.isSendingMessage
                        ? Colors.white24
                        : const Color(0xFF2A5BDA),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: chatProvider.isSendingMessage
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white54,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                      : const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  void _handleMenuAction(String action) async {
    final chatProvider = context.read<MentalHealthChatProvider>();

    switch (action) {
      case 'new_conversation':
        final confirmed = await _showConfirmDialog(
          'Nueva conversación',
          '¿Quieres iniciar una nueva conversación? La actual se guardará de forma privada.',
        );
        if (confirmed) {
          await chatProvider.startNewConversation();
          _scrollToBottom();
        }
        break;

      case 'privacy':
        _showPrivacyInfo();
        break;

      case 'clear_all':
        final confirmed = await _showConfirmDialog(
          'Limpiar historial',
          '¿Estás seguro? Esto eliminará todas las conversaciones de forma permanente.',
          isDestructive: true,
        );
        if (confirmed) {
          await chatProvider.clearAllConversations();
          _scrollToBottom();
        }
        break;
    }
  }

  Future<bool> _showConfirmDialog(String title, String message, {bool isDestructive = false}) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isDestructive ? 'Eliminar' : 'Confirmar',
              style: TextStyle(
                color: isDestructive ? Colors.redAccent : const Color(0xFF2A5BDA),
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showPrivacyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Row(
          children: [
            Icon(Icons.privacy_tip, color: Colors.green, size: 24),
            SizedBox(width: 12),
            Text('Tu Privacidad', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔒 Procesamiento local',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              'Toda la IA funciona en tu dispositivo',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            SizedBox(height: 12),
            Text(
              '💾 Almacenamiento privado',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              'Las conversaciones se guardan solo en tu teléfono',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            SizedBox(height: 12),
            Text(
              '🚫 Sin transmisión de datos',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              'Nada se envía a servidores externos',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido', style: TextStyle(color: Color(0xFF2A5BDA))),
          ),
        ],
      ),
    );
  }
}