// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flexible_routine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduledDayImpl _$$ScheduledDayImplFromJson(Map<String, dynamic> json) =>
    _$ScheduledDayImpl(
      date: DateTime.parse(json['date'] as String),
      status: $enumDecode(_$DayStatusEnumMap, json['status']),
      templateId: json['templateId'] as String?,
      workoutId: json['workoutId'] as String?,
      skipReason: json['skipReason'] as String?,
      originalDate: json['originalDate'] == null
          ? null
          : DateTime.parse(json['originalDate'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ScheduledDayImplToJson(_$ScheduledDayImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'status': _$DayStatusEnumMap[instance.status]!,
      'templateId': instance.templateId,
      'workoutId': instance.workoutId,
      'skipReason': instance.skipReason,
      'originalDate': instance.originalDate?.toIso8601String(),
      'notes': instance.notes,
    };

const _$DayStatusEnumMap = {
  DayStatus.scheduled: 'scheduled',
  DayStatus.completed: 'completed',
  DayStatus.skipped: 'skipped',
  DayStatus.recovered: 'recovered',
  DayStatus.rest: 'rest',
};

_$RecoverySettingsImpl _$$RecoverySettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$RecoverySettingsImpl(
      suggestRecovery: json['suggestRecovery'] as bool? ?? true,
      allowRecoveryOnRestDays: json['allowRecoveryOnRestDays'] as bool? ?? true,
      maxRecoveryDays: (json['maxRecoveryDays'] as num?)?.toInt() ?? 7,
      notifyOnSkip: json['notifyOnSkip'] as bool? ?? true,
    );

Map<String, dynamic> _$$RecoverySettingsImplToJson(
        _$RecoverySettingsImpl instance) =>
    <String, dynamic>{
      'suggestRecovery': instance.suggestRecovery,
      'allowRecoveryOnRestDays': instance.allowRecoveryOnRestDays,
      'maxRecoveryDays': instance.maxRecoveryDays,
      'notifyOnSkip': instance.notifyOnSkip,
    };

_$FlexibleRoutineImpl _$$FlexibleRoutineImplFromJson(
        Map<String, dynamic> json) =>
    _$FlexibleRoutineImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String? ?? 'My Routine',
      description: json['description'] as String? ?? '',
      type: $enumDecode(_$RoutineTypeEnumMap, json['type']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      pattern: RoutinePattern.fromJson(json['pattern'] as Map<String, dynamic>),
      schedule: (json['schedule'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, ScheduledDay.fromJson(e as Map<String, dynamic>)),
      ),
      skipTracker:
          SkipTracker.fromJson(json['skipTracker'] as Map<String, dynamic>),
      recoverySettings: RecoverySettings.fromJson(
          json['recoverySettings'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool? ?? true,
      isArchived: json['isArchived'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      totalWorkoutDays: (json['totalWorkoutDays'] as num?)?.toInt() ?? 0,
      completedDays: (json['completedDays'] as num?)?.toInt() ?? 0,
      lastWorkoutDate: json['lastWorkoutDate'] == null
          ? null
          : DateTime.parse(json['lastWorkoutDate'] as String),
      isSyncPending: json['isSyncPending'] as bool? ?? false,
    );

Map<String, dynamic> _$$FlexibleRoutineImplToJson(
        _$FlexibleRoutineImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'type': _$RoutineTypeEnumMap[instance.type]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'pattern': instance.pattern.toJson(),
      'schedule': instance.schedule.map((k, e) => MapEntry(k, e.toJson())),
      'skipTracker': instance.skipTracker.toJson(),
      'recoverySettings': instance.recoverySettings.toJson(),
      'isActive': instance.isActive,
      'isArchived': instance.isArchived,
      'isCompleted': instance.isCompleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'totalWorkoutDays': instance.totalWorkoutDays,
      'completedDays': instance.completedDays,
      'lastWorkoutDate': instance.lastWorkoutDate?.toIso8601String(),
      'isSyncPending': instance.isSyncPending,
    };

const _$RoutineTypeEnumMap = {
  RoutineType.weekly: 'weekly',
  RoutineType.monthly: 'monthly',
  RoutineType.bimonthly: 'bimonthly',
  RoutineType.semester: 'semester',
  RoutineType.custom: 'custom',
};
