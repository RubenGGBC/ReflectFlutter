// lib/data/models/conversation_memory_model.dart
// ============================================================================
// LOCAL CONVERSATION MEMORY MODELS - 100% OFFLINE AI MEMORY
// ============================================================================

import 'package:json_annotation/json_annotation.dart';

part 'conversation_memory_model.g.dart';

/// Individual conversation message with memory metadata
@JsonSerializable()
class ConversationMessage {
  final int? id;
  final int conversationId;
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final double? importance; // 0.0-1.0 for memory prioritization
  final bool isMemoryCompressed; // True if this message was compressed

  const ConversationMessage({
    this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.metadata,
    this.importance,
    this.isMemoryCompressed = false,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) => 
      _$ConversationMessageFromJson(json);
  
  Map<String, dynamic> toJson() => _$ConversationMessageToJson(this);

  ConversationMessage copyWith({
    int? id,
    int? conversationId,
    String? role,
    String? content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    double? importance,
    bool? isMemoryCompressed,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      importance: importance ?? this.importance,
      isMemoryCompressed: isMemoryCompressed ?? this.isMemoryCompressed,
    );
  }
}

/// Conversation session with metadata
@JsonSerializable()
class ConversationSession {
  final int? id;
  final int userId;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final int messageCount;
  final Map<String, dynamic>? metadata;
  final String? summary; // AI-generated conversation summary
  final List<String>? keyTopics; // Important topics discussed
  final double? emotionalTone; // Overall emotional tone (-1.0 to 1.0)

  const ConversationSession({
    this.id,
    required this.userId,
    required this.title,
    required this.startTime,
    this.endTime,
    this.messageCount = 0,
    this.metadata,
    this.summary,
    this.keyTopics,
    this.emotionalTone,
  });

  factory ConversationSession.fromJson(Map<String, dynamic> json) => 
      _$ConversationSessionFromJson(json);
  
  Map<String, dynamic> toJson() => _$ConversationSessionToJson(this);

  ConversationSession copyWith({
    int? id,
    int? userId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    int? messageCount,
    Map<String, dynamic>? metadata,
    String? summary,
    List<String>? keyTopics,
    double? emotionalTone,
  }) {
    return ConversationSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      messageCount: messageCount ?? this.messageCount,
      metadata: metadata ?? this.metadata,
      summary: summary ?? this.summary,
      keyTopics: keyTopics ?? this.keyTopics,
      emotionalTone: emotionalTone ?? this.emotionalTone,
    );
  }
}

/// User memory profile for personalized responses
@JsonSerializable()
class UserMemoryProfile {
  final int? id;
  final int userId;
  final String name;
  final Map<String, dynamic> preferences; // User preferences learned over time
  final Map<String, dynamic> characteristics; // Personality traits, communication style
  final List<String> interests; // Topics user is interested in
  final List<String> triggers; // Topics to be careful about
  final Map<String, int> topicFrequency; // How often user talks about topics
  final DateTime lastUpdated;
  final int conversationCount;

  const UserMemoryProfile({
    this.id,
    required this.userId,
    required this.name,
    required this.preferences,
    required this.characteristics,
    required this.interests,
    required this.triggers,
    required this.topicFrequency,
    required this.lastUpdated,
    this.conversationCount = 0,
  });

  factory UserMemoryProfile.fromJson(Map<String, dynamic> json) => 
      _$UserMemoryProfileFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserMemoryProfileToJson(this);

  UserMemoryProfile copyWith({
    int? id,
    int? userId,
    String? name,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? characteristics,
    List<String>? interests,
    List<String>? triggers,
    Map<String, int>? topicFrequency,
    DateTime? lastUpdated,
    int? conversationCount,
  }) {
    return UserMemoryProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      preferences: preferences ?? this.preferences,
      characteristics: characteristics ?? this.characteristics,
      interests: interests ?? this.interests,
      triggers: triggers ?? this.triggers,
      topicFrequency: topicFrequency ?? this.topicFrequency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      conversationCount: conversationCount ?? this.conversationCount,
    );
  }
}

/// Memory summary for efficient context retrieval
@JsonSerializable()
class MemorySummary {
  final int? id;
  final int userId;
  final int? conversationId;
  final String summary;
  final List<String> keyPoints;
  final Map<String, dynamic> extractedInfo; // Important facts, preferences, etc.
  final DateTime createdAt;
  final DateTime? lastAccessed;
  final double relevanceScore; // 0.0-1.0 for retrieval ranking
  final String summaryType; // 'conversation', 'session', 'topic', 'user'

  const MemorySummary({
    this.id,
    required this.userId,
    this.conversationId,
    required this.summary,
    required this.keyPoints,
    required this.extractedInfo,
    required this.createdAt,
    this.lastAccessed,
    this.relevanceScore = 0.5,
    this.summaryType = 'conversation',
  });

  factory MemorySummary.fromJson(Map<String, dynamic> json) => 
      _$MemorySummaryFromJson(json);
  
  Map<String, dynamic> toJson() => _$MemorySummaryToJson(this);

  MemorySummary copyWith({
    int? id,
    int? userId,
    int? conversationId,
    String? summary,
    List<String>? keyPoints,
    Map<String, dynamic>? extractedInfo,
    DateTime? createdAt,
    DateTime? lastAccessed,
    double? relevanceScore,
    String? summaryType,
  }) {
    return MemorySummary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      conversationId: conversationId ?? this.conversationId,
      summary: summary ?? this.summary,
      keyPoints: keyPoints ?? this.keyPoints,
      extractedInfo: extractedInfo ?? this.extractedInfo,
      createdAt: createdAt ?? this.createdAt,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      summaryType: summaryType ?? this.summaryType,
    );
  }
}

/// Context window for current conversation
class ContextWindow {
  final List<ConversationMessage> recentMessages;
  final List<MemorySummary> relevantMemories;
  final UserMemoryProfile? userProfile;
  final int maxTokens;
  final int currentTokenCount;

  const ContextWindow({
    required this.recentMessages,
    required this.relevantMemories,
    this.userProfile,
    this.maxTokens = 2048,
    this.currentTokenCount = 0,
  });

  /// Build context string for AI prompt
  String buildContextString() {
    final buffer = StringBuffer();

    // Add user profile if available
    if (userProfile != null) {
      buffer.writeln('USER PROFILE:');
      buffer.writeln('Name: ${userProfile!.name}');
      if (userProfile!.preferences.isNotEmpty) {
        buffer.writeln('Preferences: ${userProfile!.preferences}');
      }
      if (userProfile!.interests.isNotEmpty) {
        buffer.writeln('Interests: ${userProfile!.interests.join(', ')}');
      }
      buffer.writeln();
    }

    // Add relevant memories
    if (relevantMemories.isNotEmpty) {
      buffer.writeln('RELEVANT MEMORIES:');
      for (final memory in relevantMemories.take(3)) {
        buffer.writeln('- ${memory.summary}');
      }
      buffer.writeln();
    }

    // Add recent conversation
    buffer.writeln('RECENT CONVERSATION:');
    for (final message in recentMessages) {
      buffer.writeln('${message.role}: ${message.content}');
    }

    return buffer.toString();
  }

  /// Estimate token count (rough approximation)
  int estimateTokenCount() {
    final contextString = buildContextString();
    return (contextString.length / 4).round(); // Rough 4 chars per token
  }
}