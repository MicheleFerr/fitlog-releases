// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buddy_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BuddyMessageImpl _$$BuddyMessageImplFromJson(Map<String, dynamic> json) =>
    _$BuddyMessageImpl(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      content: json['content'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      isDelivered: json['isDelivered'] as bool? ?? false,
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      isEdited: json['isEdited'] as bool? ?? false,
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      replyToMessageId: json['replyToMessageId'] as String?,
      replyToContent: json['replyToContent'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BuddyMessageImplToJson(_$BuddyMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'matchId': instance.matchId,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'content': instance.content,
      'metadata': instance.metadata,
      'isRead': instance.isRead,
      'readAt': instance.readAt?.toIso8601String(),
      'isDelivered': instance.isDelivered,
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'isEdited': instance.isEdited,
      'editedAt': instance.editedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'replyToMessageId': instance.replyToMessageId,
      'replyToContent': instance.replyToContent,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.workoutInvite: 'workoutInvite',
  MessageType.workoutPlan: 'workoutPlan',
  MessageType.exerciseShare: 'exerciseShare',
  MessageType.systemNotification: 'systemNotification',
};
