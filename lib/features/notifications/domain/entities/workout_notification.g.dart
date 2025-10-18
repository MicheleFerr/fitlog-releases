// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutNotificationImpl _$$WorkoutNotificationImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkoutNotificationImpl(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      body: json['body'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      priority: $enumDecode(_$NotificationPriorityEnumMap, json['priority']),
      routineId: json['routineId'] as String?,
      workoutName: json['workoutName'] as String?,
      daysToRecover: (json['daysToRecover'] as num?)?.toInt(),
      isDelivered: json['isDelivered'] as bool?,
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      payload: json['payload'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$WorkoutNotificationImplToJson(
        _$WorkoutNotificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'body': instance.body,
      'scheduledTime': instance.scheduledTime.toIso8601String(),
      'priority': _$NotificationPriorityEnumMap[instance.priority]!,
      'routineId': instance.routineId,
      'workoutName': instance.workoutName,
      'daysToRecover': instance.daysToRecover,
      'isDelivered': instance.isDelivered,
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'payload': instance.payload,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.workoutReminder: 'workoutReminder',
  NotificationType.recoveryAlert: 'recoveryAlert',
  NotificationType.streakMotivation: 'streakMotivation',
  NotificationType.restDayReminder: 'restDayReminder',
};

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.medium: 'medium',
  NotificationPriority.high: 'high',
};

_$NotificationSettingsImpl _$$NotificationSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationSettingsImpl(
      enableWorkoutReminders: json['enableWorkoutReminders'] as bool? ?? true,
      enableRecoveryAlerts: json['enableRecoveryAlerts'] as bool? ?? true,
      enableStreakMotivation: json['enableStreakMotivation'] as bool? ?? false,
      enableRestDayReminders: json['enableRestDayReminders'] as bool? ?? false,
      preferredTime: $enumDecodeNullable(
              _$NotificationTimePreferenceEnumMap, json['preferredTime']) ??
          NotificationTimePreference.morning,
      customTime: json['customTime'] == null
          ? null
          : DateTime.parse(json['customTime'] as String),
      enableSmartScheduling: json['enableSmartScheduling'] as bool? ?? true,
      doNotDisturbEnabled: json['doNotDisturbEnabled'] as bool? ?? false,
      doNotDisturbStart: json['doNotDisturbStart'] == null
          ? null
          : DateTime.parse(json['doNotDisturbStart'] as String),
      doNotDisturbEnd: json['doNotDisturbEnd'] == null
          ? null
          : DateTime.parse(json['doNotDisturbEnd'] as String),
      reminderMinutesBefore:
          (json['reminderMinutesBefore'] as num?)?.toInt() ?? 60,
    );

Map<String, dynamic> _$$NotificationSettingsImplToJson(
        _$NotificationSettingsImpl instance) =>
    <String, dynamic>{
      'enableWorkoutReminders': instance.enableWorkoutReminders,
      'enableRecoveryAlerts': instance.enableRecoveryAlerts,
      'enableStreakMotivation': instance.enableStreakMotivation,
      'enableRestDayReminders': instance.enableRestDayReminders,
      'preferredTime':
          _$NotificationTimePreferenceEnumMap[instance.preferredTime]!,
      'customTime': instance.customTime?.toIso8601String(),
      'enableSmartScheduling': instance.enableSmartScheduling,
      'doNotDisturbEnabled': instance.doNotDisturbEnabled,
      'doNotDisturbStart': instance.doNotDisturbStart?.toIso8601String(),
      'doNotDisturbEnd': instance.doNotDisturbEnd?.toIso8601String(),
      'reminderMinutesBefore': instance.reminderMinutesBefore,
    };

const _$NotificationTimePreferenceEnumMap = {
  NotificationTimePreference.morning: 'morning',
  NotificationTimePreference.midday: 'midday',
  NotificationTimePreference.afternoon: 'afternoon',
  NotificationTimePreference.evening: 'evening',
  NotificationTimePreference.custom: 'custom',
};
