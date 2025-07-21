// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_memory_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationMessage _$ConversationMessageFromJson(Map<String, dynamic> json) =>
    ConversationMessage(
      id: (json['id'] as num?)?.toInt(),
      conversationId: (json['conversationId'] as num).toInt(),
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      importance: (json['importance'] as num?)?.toDouble(),
      isMemoryCompressed: json['isMemoryCompressed'] as bool? ?? false,
    );

Map<String, dynamic> _$ConversationMessageToJson(
        ConversationMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'role': instance.role,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'metadata': instance.metadata,
      'importance': instance.importance,
      'isMemoryCompressed': instance.isMemoryCompressed,
    };

ConversationSession _$ConversationSessionFromJson(Map<String, dynamic> json) =>
    ConversationSession(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      title: json['title'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
      summary: json['summary'] as String?,
      keyTopics: (json['keyTopics'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      emotionalTone: (json['emotionalTone'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ConversationSessionToJson(
        ConversationSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'messageCount': instance.messageCount,
      'metadata': instance.metadata,
      'summary': instance.summary,
      'keyTopics': instance.keyTopics,
      'emotionalTone': instance.emotionalTone,
    };

UserMemoryProfile _$UserMemoryProfileFromJson(Map<String, dynamic> json) =>
    UserMemoryProfile(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String,
      preferences: json['preferences'] as Map<String, dynamic>,
      characteristics: json['characteristics'] as Map<String, dynamic>,
      interests:
          (json['interests'] as List<dynamic>).map((e) => e as String).toList(),
      triggers:
          (json['triggers'] as List<dynamic>).map((e) => e as String).toList(),
      topicFrequency: Map<String, int>.from(json['topicFrequency'] as Map),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      conversationCount: (json['conversationCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UserMemoryProfileToJson(UserMemoryProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'preferences': instance.preferences,
      'characteristics': instance.characteristics,
      'interests': instance.interests,
      'triggers': instance.triggers,
      'topicFrequency': instance.topicFrequency,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'conversationCount': instance.conversationCount,
    };

MemorySummary _$MemorySummaryFromJson(Map<String, dynamic> json) =>
    MemorySummary(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      conversationId: (json['conversationId'] as num?)?.toInt(),
      summary: json['summary'] as String,
      keyPoints:
          (json['keyPoints'] as List<dynamic>).map((e) => e as String).toList(),
      extractedInfo: json['extractedInfo'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAccessed: json['lastAccessed'] == null
          ? null
          : DateTime.parse(json['lastAccessed'] as String),
      relevanceScore: (json['relevanceScore'] as num?)?.toDouble() ?? 0.5,
      summaryType: json['summaryType'] as String? ?? 'conversation',
    );

Map<String, dynamic> _$MemorySummaryToJson(MemorySummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'conversationId': instance.conversationId,
      'summary': instance.summary,
      'keyPoints': instance.keyPoints,
      'extractedInfo': instance.extractedInfo,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastAccessed': instance.lastAccessed?.toIso8601String(),
      'relevanceScore': instance.relevanceScore,
      'summaryType': instance.summaryType,
    };
