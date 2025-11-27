// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_tree.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationTreeImpl _$$ConversationTreeImplFromJson(
  Map<String, dynamic> json,
) => _$ConversationTreeImpl(
  userId: json['userId'] as String,
  rootNodeId: json['rootNodeId'] as String?,
  currentNodeId: json['currentNodeId'] as String?,
  nodes:
      (json['nodes'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, ConversationNode.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$$ConversationTreeImplToJson(
  _$ConversationTreeImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'rootNodeId': instance.rootNodeId,
  'currentNodeId': instance.currentNodeId,
  'nodes': instance.nodes.map((k, e) => MapEntry(k, e.toJson())),
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};
