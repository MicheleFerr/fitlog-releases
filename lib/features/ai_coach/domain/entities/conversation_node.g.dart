// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationNodeImpl _$$ConversationNodeImplFromJson(
        Map<String, dynamic> json) =>
    _$ConversationNodeImpl(
      id: json['id'] as String,
      parentId: json['parentId'] as String?,
      childrenIds: (json['childrenIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      message: AIMessage.fromJson(json['message'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isCurrent: json['isCurrent'] as bool? ?? false,
    );

Map<String, dynamic> _$$ConversationNodeImplToJson(
        _$ConversationNodeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parentId': instance.parentId,
      'childrenIds': instance.childrenIds,
      'message': instance.message.toJson(),
      'timestamp': instance.timestamp.toIso8601String(),
      'isCurrent': instance.isCurrent,
    };
