// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AIToolCall _$AIToolCallFromJson(Map<String, dynamic> json) => _AIToolCall(
  name: json['name'] as String,
  arguments: json['arguments'] as Map<String, dynamic>,
  result: json['result'] as String?,
);

Map<String, dynamic> _$AIToolCallToJson(_AIToolCall instance) =>
    <String, dynamic>{
      'name': instance.name,
      'arguments': instance.arguments,
      'result': instance.result,
    };

_AIMessage _$AIMessageFromJson(Map<String, dynamic> json) => _AIMessage(
  id: json['id'] as String,
  role: $enumDecode(_$MessageRoleEnumMap, json['role']),
  content: json['content'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  toolCall: json['toolCall'] == null
      ? null
      : AIToolCall.fromJson(json['toolCall'] as Map<String, dynamic>),
  isTyping: json['isTyping'] as bool? ?? false,
  error: json['error'] as String?,
  suggestions:
      (json['suggestions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$AIMessageToJson(_AIMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$MessageRoleEnumMap[instance.role]!,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'toolCall': instance.toolCall?.toJson(),
      'isTyping': instance.isTyping,
      'error': instance.error,
      'suggestions': instance.suggestions,
    };

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.assistant: 'assistant',
  MessageRole.system: 'system',
  MessageRole.tool: 'tool',
};
