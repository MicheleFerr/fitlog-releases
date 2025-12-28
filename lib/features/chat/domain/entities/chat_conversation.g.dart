// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatConversation _$ChatConversationFromJson(Map<String, dynamic> json) =>
    _ChatConversation(
      id: json['id'] as String,
      coachId: json['coachId'] as String,
      athleteId: json['athleteId'] as String,
      coachName: json['coachName'] as String,
      athleteName: json['athleteName'] as String,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
      lastMessageSenderId: json['lastMessageSenderId'] as String?,
      coachUnreadCount: (json['coachUnreadCount'] as num?)?.toInt() ?? 0,
      athleteUnreadCount: (json['athleteUnreadCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ChatConversationToJson(_ChatConversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'coachId': instance.coachId,
      'athleteId': instance.athleteId,
      'coachName': instance.coachName,
      'athleteName': instance.athleteName,
      'lastMessage': instance.lastMessage,
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'lastMessageSenderId': instance.lastMessageSenderId,
      'coachUnreadCount': instance.coachUnreadCount,
      'athleteUnreadCount': instance.athleteUnreadCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
