// lib/data/models/chat_message_model.dart
// ============================================================================
// MODELO PARA MENSAJES DEL CHAT CON IA
// ============================================================================

enum MessageType {
  user,
  assistant,
  system,
  error,
  thinking,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  failed,
  typing,
}

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? userId;
  final Map<String, dynamic>? metadata;
  final String? conversationId;
  final bool isStreaming;
  final double? confidence;
  final List<String>? sources;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.userId,
    this.metadata,
    this.conversationId,
    this.isStreaming = false,
    this.confidence,
    this.sources,
  });

  // Factory constructors para diferentes tipos de mensajes
  factory ChatMessage.user({
    required String content,
    required String userId,
    String? conversationId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
      userId: userId,
      conversationId: conversationId,
      metadata: metadata,
      status: MessageStatus.sending,
    );
  }

  factory ChatMessage.assistant({
    required String content,
    String? conversationId,
    double? confidence,
    List<String>? sources,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      conversationId: conversationId,
      confidence: confidence,
      sources: sources,
      metadata: metadata,
      status: MessageStatus.delivered,
    );
  }

  factory ChatMessage.system({
    required String content,
    String? conversationId,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.system,
      timestamp: DateTime.now(),
      conversationId: conversationId,
      status: MessageStatus.delivered,
    );
  }

  factory ChatMessage.error({
    required String content,
    String? conversationId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.error,
      timestamp: DateTime.now(),
      conversationId: conversationId,
      metadata: metadata,
      status: MessageStatus.failed,
    );
  }

  factory ChatMessage.thinking({
    String? conversationId,
  }) {
    return ChatMessage(
      id: 'thinking_${DateTime.now().millisecondsSinceEpoch}',
      content: 'La IA está pensando...',
      type: MessageType.thinking,
      timestamp: DateTime.now(),
      conversationId: conversationId,
      status: MessageStatus.typing,
      isStreaming: true,
    );
  }

  // Métodos de copia
  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? userId,
    Map<String, dynamic>? metadata,
    String? conversationId,
    bool? isStreaming,
    double? confidence,
    List<String>? sources,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
      conversationId: conversationId ?? this.conversationId,
      isStreaming: isStreaming ?? this.isStreaming,
      confidence: confidence ?? this.confidence,
      sources: sources ?? this.sources,
    );
  }

  // Conversión a/desde Map para persistencia
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'metadata': metadata,
      'conversationId': conversationId,
      'isStreaming': isStreaming,
      'confidence': confidence,
      'sources': sources,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => MessageType.user,
      ),
      status: MessageStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      userId: map['userId'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      conversationId: map['conversationId'],
      isStreaming: map['isStreaming'] ?? false,
      confidence: map['confidence']?.toDouble(),
      sources: map['sources'] != null
          ? List<String>.from(map['sources'])
          : null,
    );
  }

  // Getters de conveniencia
  bool get isUser => type == MessageType.user;
  bool get isAssistant => type == MessageType.assistant;
  bool get isSystem => type == MessageType.system;
  bool get isError => type == MessageType.error;
  bool get isThinking => type == MessageType.thinking;
  bool get isFailed => status == MessageStatus.failed;
  bool get isSending => status == MessageStatus.sending;
  bool get isTyping => status == MessageStatus.typing;

  String get displayTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'ahora';
    }
  }

  String get roleDisplay {
    switch (type) {
      case MessageType.user:
        return 'Tú';
      case MessageType.assistant:
        return 'Coach IA';
      case MessageType.system:
        return 'Sistema';
      case MessageType.error:
        return 'Error';
      case MessageType.thinking:
        return 'Coach IA';
    }
  }
}

// Clase para representar una conversación completa
class ChatConversation {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String? userId;
  final Map<String, dynamic>? metadata;
  final bool isActive;

  const ChatConversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.lastMessageAt,
    this.userId,
    this.metadata,
    this.isActive = true,
  });

  factory ChatConversation.create({
    required String userId,
    String? title,
    ChatMessage? firstMessage,
  }) {
    final now = DateTime.now();
    final conversationId = 'conv_${now.millisecondsSinceEpoch}';

    return ChatConversation(
      id: conversationId,
      title: title ?? 'Nueva conversación',
      messages: firstMessage != null ? [firstMessage] : [],
      createdAt: now,
      lastMessageAt: now,
      userId: userId,
      isActive: true,
    );
  }

  ChatConversation copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? userId,
    Map<String, dynamic>? metadata,
    bool? isActive,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
      isActive: isActive ?? this.isActive,
    );
  }

  ChatConversation addMessage(ChatMessage message) {
    return copyWith(
      messages: [...messages, message],
      lastMessageAt: message.timestamp,
    );
  }

  ChatConversation updateMessage(String messageId, ChatMessage updatedMessage) {
    final updatedMessages = messages.map((msg) {
      return msg.id == messageId ? updatedMessage : msg;
    }).toList();

    return copyWith(
      messages: updatedMessages,
      lastMessageAt: updatedMessage.timestamp,
    );
  }

  ChatConversation removeMessage(String messageId) {
    final filteredMessages = messages.where((msg) => msg.id != messageId).toList();
    return copyWith(messages: filteredMessages);
  }

  // Getters de conveniencia
  ChatMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;
  int get messageCount => messages.length;
  bool get hasMessages => messages.isNotEmpty;

  String get lastMessagePreview {
    if (lastMessage == null) return 'Sin mensajes';
    final content = lastMessage!.content;
    return content.length > 50 ? '${content.substring(0, 50)}...' : content;
  }

  List<ChatMessage> get userMessages => messages.where((msg) => msg.isUser).toList();
  List<ChatMessage> get assistantMessages => messages.where((msg) => msg.isAssistant).toList();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((msg) => msg.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'userId': userId,
      'metadata': metadata,
      'isActive': isActive,
    };
  }

  factory ChatConversation.fromMap(Map<String, dynamic> map) {
    return ChatConversation(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      messages: (map['messages'] as List<dynamic>?)
          ?.map((msgMap) => ChatMessage.fromMap(msgMap))
          .toList() ?? [],
      createdAt: DateTime.parse(map['createdAt']),
      lastMessageAt: DateTime.parse(map['lastMessageAt']),
      userId: map['userId'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      isActive: map['isActive'] ?? true,
    );
  }
}