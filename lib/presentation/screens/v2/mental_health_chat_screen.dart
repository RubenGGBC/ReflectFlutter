// lib/presentation/screens/v2/mental_health_chat_screen.dart
// ============================================================================
// MENTAL HEALTH CHAT SCREEN - AI COACH CONVERSATION
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// Models and Services
import '../../../data/models/chat_message_model.dart';
// AI provider removed - screen disabled

// Components
import 'components/minimal_colors.dart';

class MentalHealthChatScreen extends StatefulWidget {
  const MentalHealthChatScreen({super.key});

  @override
  State<MentalHealthChatScreen> createState() => _MentalHealthChatScreenState();
}

class _MentalHealthChatScreenState extends State<MentalHealthChatScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _messageFadeController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _messageFadeAnimation;
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  
  bool _isComposing = false;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _messageController.addListener(_onMessageChanged);
  }
  
  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _messageFadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    
    _messageFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _messageFadeController, curve: Curves.easeInOut));
    
    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }
  
  void _onMessageChanged() {
    final isComposing = _messageController.text.trim().isNotEmpty;
    if (isComposing != _isComposing) {
      setState(() {
        _isComposing = isComposing;
      });
    }
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }
  
  void _sendMessage() {
    // AI removed - show disabled message
    HapticFeedback.lightImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('IA deshabilitada - Funcionalidad no disponible'),
        backgroundColor: MinimalColors.negativeGradient(context)[0],
      ),
    );
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _messageFadeController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: MinimalColors.primaryGradient(context),
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Header
                      _buildHeader(),
                      
                      // Messages
                      Expanded(
                        child: _buildMessagesArea(),
                      ),
                      
                      // Input Area
                      _buildInputArea(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context).withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.shadow(context).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row with back button and title
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MinimalColors.backgroundSecondary(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: MinimalColors.textSecondary(context),
                    size: 16,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coach de Bienestar',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tu compañero de apoyo mental',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // AI removed - no download button needed
              
              // New Chat Button
              GestureDetector(
                onTap: () => _showNewChatDialog(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MinimalColors.backgroundSecondary(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: MinimalColors.textSecondary(context),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // AI Status Indicator (AI removed)
          _buildAIStatusIndicator(),
        ],
      ),
    );
  }
  
  Widget _buildAIStatusIndicator() {
    // AI removed - show disabled status
    final statusColor = MinimalColors.negativeGradient(context)[0];
    final backgroundColor = MinimalColors.negativeGradient(context)[0].withValues(alpha: 0.1);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.block,
            color: statusColor,
            size: 12,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'IA deshabilitada',
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessagesArea() {
    // AI removed - show disabled state
    return _buildDisabledState();
  }
  
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final isThinking = message.isThinking;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser 
          ? MainAxisAlignment.end 
          : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            // AI Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: MinimalColors.accentGradient(context),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser 
                  ? MinimalColors.backgroundSecondary(context)
                  : MinimalColors.backgroundCard(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: MinimalColors.shadow(context).withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content
                  if (isThinking) ...[
                    _buildThinkingIndicator(),
                  ] else ...[
                    Text(
                      message.content,
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 8),
                  
                  // Timestamp
                  Text(
                    message.displayTime,
                    style: TextStyle(
                      color: MinimalColors.textMuted(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            // User avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: MinimalColors.backgroundSecondary(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person_rounded,
                color: MinimalColors.textSecondary(context),
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildThinkingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated thinking dots
        for (int i = 0; i < 3; i++) ...[
          AnimatedOpacity(
            opacity: 0.5,
            duration: Duration(milliseconds: 600 + (i * 200)),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: MinimalColors.textSecondary(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          if (i < 2) const SizedBox(width: 4),
        ],
      ],
    );
  }
  
  Widget _buildInputArea() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context).withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.shadow(context).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: MinimalColors.backgroundSecondary(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  hintStyle: TextStyle(
                    color: MinimalColors.textMuted(context),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 16,
                ),
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Send button (disabled)
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundSecondary(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.block,
                color: MinimalColors.textMuted(context),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              MinimalColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Preparando tu espacio de bienestar...',
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: MinimalColors.neutralGradient(context)[0],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'La IA no está disponible',
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // AI removed - no retry available
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MinimalColors.backgroundSecondary(context),
              foregroundColor: MinimalColors.textPrimary(context),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundSecondary(context),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              Icons.block,
              color: MinimalColors.negativeGradient(context)[0],
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chat IA Deshabilitado',
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'La funcionalidad de chat con IA ha sido deshabilitada.\nUtiliza otras funciones de la app para el seguimiento de tu bienestar.',
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver al inicio'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MinimalColors.backgroundSecondary(context),
              foregroundColor: MinimalColors.textPrimary(context),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: MinimalColors.accentGradient(context),
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Hola! Soy tu Coach de Bienestar',
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Estoy aquí para escucharte y acompañarte.\nPuedes compartir lo que sientes con total confianza.',
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Escribe un mensaje para comenzar',
            style: TextStyle(
              color: MinimalColors.textMuted(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MinimalColors.backgroundCard(context),
        title: Text(
          'Nueva Conversación',
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
          ),
        ),
        content: Text(
          'Quieres comenzar una nueva conversación? La conversación actual se guardará.',
          style: TextStyle(
            color: MinimalColors.textSecondary(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // AI removed - no new conversation available
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('IA deshabilitada - Funcionalidad no disponible'),
                  backgroundColor: MinimalColors.negativeGradient(context)[0],
                ),
              );
            },
            child: Text(
              'Nueva Conversación',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}