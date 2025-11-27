// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationRecord _$NotificationRecordFromJson(Map<String, dynamic> json) =>
    _NotificationRecord(
      id: json['id'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      sentAt: DateTime.parse(json['sentAt'] as String),
      openedAt: json['openedAt'] == null
          ? null
          : DateTime.parse(json['openedAt'] as String),
      messageKey: json['messageKey'] as String,
      context: json['context'] as String?,
      inactivityDay: (json['inactivityDay'] as num?)?.toInt(),
      wasCanceled: json['wasCanceled'] as bool? ?? false,
    );

Map<String, dynamic> _$NotificationRecordToJson(_NotificationRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'sentAt': instance.sentAt.toIso8601String(),
      'openedAt': instance.openedAt?.toIso8601String(),
      'messageKey': instance.messageKey,
      'context': instance.context,
      'inactivityDay': instance.inactivityDay,
      'wasCanceled': instance.wasCanceled,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.workoutForgotten: 'workoutForgotten',
  NotificationType.inactivity: 'inactivity',
  NotificationType.insightPr: 'insightPr',
  NotificationType.insightStreak: 'insightStreak',
  NotificationType.insightVolume: 'insightVolume',
};

_NotificationStats _$NotificationStatsFromJson(Map<String, dynamic> json) =>
    _NotificationStats(
      totalSent: (json['totalSent'] as num).toInt(),
      totalOpened: (json['totalOpened'] as num).toInt(),
      consecutiveIgnores: (json['consecutiveIgnores'] as num).toInt(),
      lastSentAt: json['lastSentAt'] == null
          ? null
          : DateTime.parse(json['lastSentAt'] as String),
      lastMessageKey: json['lastMessageKey'] as String?,
    );

Map<String, dynamic> _$NotificationStatsToJson(_NotificationStats instance) =>
    <String, dynamic>{
      'totalSent': instance.totalSent,
      'totalOpened': instance.totalOpened,
      'consecutiveIgnores': instance.consecutiveIgnores,
      'lastSentAt': instance.lastSentAt?.toIso8601String(),
      'lastMessageKey': instance.lastMessageKey,
    };
