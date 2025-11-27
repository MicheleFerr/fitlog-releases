// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AIMessage _$AIMessageFromJson(Map<String, dynamic> json) => _AIMessage(
  id: json['id'] as String,
  content: json['content'] as String,
  role: $enumDecode(_$MessageRoleEnumMap, json['role']),
  timestamp: DateTime.parse(json['timestamp'] as String),
  isStreaming: json['isStreaming'] as bool? ?? false,
  metadata: json['metadata'] as Map<String, dynamic>?,
  followUpChips:
      (json['followUpChips'] as List<dynamic>?)
          ?.map((e) => FollowUpChip.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  conversationDepth: (json['conversationDepth'] as num?)?.toInt() ?? 0,
  parentIntent: json['parentIntent'] as String?,
);

Map<String, dynamic> _$AIMessageToJson(_AIMessage instance) =>
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

_FollowUpChip _$FollowUpChipFromJson(Map<String, dynamic> json) =>
    _FollowUpChip(
      label: json['label'] as String,
      intent: json['intent'] as String,
      emoji: json['emoji'] as String?,
      context: json['context'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$FollowUpChipToJson(_FollowUpChip instance) =>
    <String, dynamic>{
      'label': instance.label,
      'intent': instance.intent,
      'emoji': instance.emoji,
      'context': instance.context,
    };
