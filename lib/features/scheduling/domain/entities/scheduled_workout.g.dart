// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduledWorkoutImpl _$$ScheduledWorkoutImplFromJson(
  Map<String, dynamic> json,
) => _$ScheduledWorkoutImpl(
  id: json['id'] as String,
  templateId: json['templateId'] as String,
  templateName: json['templateName'] as String,
  scheduledDate: DateTime.parse(json['scheduledDate'] as String),
  reminderHour: (json['reminderHour'] as num).toInt(),
  reminderMinute: (json['reminderMinute'] as num).toInt(),
  status:
      $enumDecodeNullable(_$ScheduleStatusEnumMap, json['status']) ??
      ScheduleStatus.pending,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  notificationId: json['notificationId'] as String?,
);

Map<String, dynamic> _$$ScheduledWorkoutImplToJson(
  _$ScheduledWorkoutImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'templateId': instance.templateId,
  'templateName': instance.templateName,
  'scheduledDate': instance.scheduledDate.toIso8601String(),
  'reminderHour': instance.reminderHour,
  'reminderMinute': instance.reminderMinute,
  'status': _$ScheduleStatusEnumMap[instance.status]!,
  'completedAt': instance.completedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'notificationId': instance.notificationId,
};

const _$ScheduleStatusEnumMap = {
  ScheduleStatus.pending: 'pending',
  ScheduleStatus.due: 'due',
  ScheduleStatus.completed: 'completed',
  ScheduleStatus.skipped: 'skipped',
  ScheduleStatus.missed: 'missed',
};
