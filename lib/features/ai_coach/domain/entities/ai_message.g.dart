// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AIMessageImpl _$$AIMessageImplFromJson(Map<String, dynamic> json) =>
    _$AIMessageImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      role: $enumDecode(_$MessageRoleEnumMap, json['role']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isStreaming: json['isStreaming'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      followUpChips: (json['followUpChips'] as List<dynamic>?)
              ?.map((e) => FollowUpChip.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      conversationDepth: (json['conversationDepth'] as num?)?.toInt() ?? 0,
      parentIntent: json['parentIntent'] as String?,
    );

Map<String, dynamic> _$$AIMessageImplToJson(_$AIMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'role': _$MessageRoleEnumMap[instance.role]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'isStreaming': instance.isStreaming,
      'metadata': instance.metadata,
      'followUpChips': instance.followUpChips.map((e) => e.toJson()).toList(),
      'conversationDepth': instance.conversationDepth,
      'parentIntent': instance.parentIntent,
    };

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.assistant: 'assistant',
  MessageRole.system: 'system',
};

_$FollowUpChipImpl _$$FollowUpChipImplFromJson(Map<String, dynamic> json) =>
    _$FollowUpChipImpl(
      label: json['label'] as String,
      intent: json['intent'] as String,
      emoji: json['emoji'] as String?,
      context: json['context'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$FollowUpChipImplToJson(_$FollowUpChipImpl instance) =>
    <String, dynamic>{
      'label': instance.label,
      'intent': instance.intent,
      'emoji': instance.emoji,
      'context': instance.context,
    };
