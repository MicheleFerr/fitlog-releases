// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PhotoReminderSettings _$PhotoReminderSettingsFromJson(
  Map<String, dynamic> json,
) => _PhotoReminderSettings(
  isEnabled: json['isEnabled'] as bool? ?? false,
  frequency:
      $enumDecodeNullable(_$PhotoReminderFrequencyEnumMap, json['frequency']) ??
      PhotoReminderFrequency.monthly,
  customIntervalDays: (json['customIntervalDays'] as num?)?.toInt() ?? 28,
  reminderHour: (json['reminderHour'] as num?)?.toInt() ?? 9,
  reminderMinute: (json['reminderMinute'] as num?)?.toInt() ?? 0,
  suggestPose: json['suggestPose'] as bool? ?? true,
  lastReminderSent: json['lastReminderSent'] == null
      ? null
      : DateTime.parse(json['lastReminderSent'] as String),
  nextReminderScheduled: json['nextReminderScheduled'] == null
      ? null
      : DateTime.parse(json['nextReminderScheduled'] as String),
  notificationId: (json['notificationId'] as num?)?.toInt(),
  consecutiveIgnores: (json['consecutiveIgnores'] as num?)?.toInt() ?? 0,
  maxIgnoresBeforeDisable:
      (json['maxIgnoresBeforeDisable'] as num?)?.toInt() ?? 3,
  disabledByAntiSpam: json['disabledByAntiSpam'] as bool? ?? false,
);

Map<String, dynamic> _$PhotoReminderSettingsToJson(
  _PhotoReminderSettings instance,
) => <String, dynamic>{
  'isEnabled': instance.isEnabled,
  'frequency': _$PhotoReminderFrequencyEnumMap[instance.frequency]!,
  'customIntervalDays': instance.customIntervalDays,
  'reminderHour': instance.reminderHour,
  'reminderMinute': instance.reminderMinute,
  'suggestPose': instance.suggestPose,
  'lastReminderSent': instance.lastReminderSent?.toIso8601String(),
  'nextReminderScheduled': instance.nextReminderScheduled?.toIso8601String(),
  'notificationId': instance.notificationId,
  'consecutiveIgnores': instance.consecutiveIgnores,
  'maxIgnoresBeforeDisable': instance.maxIgnoresBeforeDisable,
  'disabledByAntiSpam': instance.disabledByAntiSpam,
};

const _$PhotoReminderFrequencyEnumMap = {
  PhotoReminderFrequency.biweekly: 'biweekly',
  PhotoReminderFrequency.monthly: 'monthly',
  PhotoReminderFrequency.sixWeeks: 'sixWeeks',
  PhotoReminderFrequency.custom: 'custom',
};

_PhotoReminderRecord _$PhotoReminderRecordFromJson(Map<String, dynamic> json) =>
    _PhotoReminderRecord(
      id: json['id'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      openedAt: json['openedAt'] == null
          ? null
          : DateTime.parse(json['openedAt'] as String),
      photoTakenAt: json['photoTakenAt'] == null
          ? null
          : DateTime.parse(json['photoTakenAt'] as String),
      messageVariation: (json['messageVariation'] as num).toInt(),
      wasCanceled: json['wasCanceled'] as bool? ?? false,
    );

Map<String, dynamic> _$PhotoReminderRecordToJson(
  _PhotoReminderRecord instance,
) => <String, dynamic>{
  'id': instance.id,
  'sentAt': instance.sentAt.toIso8601String(),
  'openedAt': instance.openedAt?.toIso8601String(),
  'photoTakenAt': instance.photoTakenAt?.toIso8601String(),
  'messageVariation': instance.messageVariation,
  'wasCanceled': instance.wasCanceled,
};
