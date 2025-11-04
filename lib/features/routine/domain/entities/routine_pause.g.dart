// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_pause.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoutinePauseImpl _$$RoutinePauseImplFromJson(Map<String, dynamic> json) =>
    _$RoutinePauseImpl(
      id: json['id'] as String,
      routineId: json['routineId'] as String,
      userId: json['userId'] as String,
      reason: $enumDecode(_$PauseReasonEnumMap, json['reason']),
      startDate: const TimestampSerializer().fromJson(json['startDate']),
      endDate: const TimestampSerializer().fromJson(json['endDate']),
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: const TimestampSerializer().fromJson(json['createdAt']),
      resumedAt: const TimestampSerializer().fromJson(json['resumedAt']),
      userInitiatedResume: json['userInitiatedResume'] as bool? ?? false,
      workoutsSkipped: (json['workoutsSkipped'] as num?)?.toInt() ?? 0,
      skippedWorkoutIds: (json['skippedWorkoutIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$RoutinePauseImplToJson(_$RoutinePauseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'routineId': instance.routineId,
      'userId': instance.userId,
      'reason': _$PauseReasonEnumMap[instance.reason]!,
      'startDate': const TimestampSerializer().toJson(instance.startDate),
      'endDate': const TimestampSerializer().toJson(instance.endDate),
      'notes': instance.notes,
      'isActive': instance.isActive,
      'createdAt': const TimestampSerializer().toJson(instance.createdAt),
      'resumedAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.resumedAt, const TimestampSerializer().toJson),
      'userInitiatedResume': instance.userInitiatedResume,
      'workoutsSkipped': instance.workoutsSkipped,
      'skippedWorkoutIds': instance.skippedWorkoutIds,
    };

const _$PauseReasonEnumMap = {
  PauseReason.injury: 'injury',
  PauseReason.sick: 'sick',
  PauseReason.vacation: 'vacation',
  PauseReason.busy: 'busy',
  PauseReason.burnout: 'burnout',
  PauseReason.other: 'other',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
