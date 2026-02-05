// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutSummary _$WorkoutSummaryFromJson(Map<String, dynamic> json) =>
    _WorkoutSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      exerciseCount: (json['exerciseCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WorkoutSummaryToJson(_WorkoutSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'completedAt': instance.completedAt.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'exerciseCount': instance.exerciseCount,
    };

_AIContext _$AIContextFromJson(Map<String, dynamic> json) => _AIContext(
  currentStreak: (json['currentStreak'] as num).toInt(),
  lastWorkout: json['lastWorkout'] == null
      ? null
      : WorkoutSummary.fromJson(json['lastWorkout'] as Map<String, dynamic>),
  top5OneRM: Map<String, int>.from(json['top5OneRM'] as Map),
  recoveryStatus: $enumDecode(_$RecoveryStatusEnumMap, json['recoveryStatus']),
  userTier: json['userTier'] as String,
  experienceLevel: json['experienceLevel'] as String?,
  fitnessGoal: json['fitnessGoal'] as String?,
);

Map<String, dynamic> _$AIContextToJson(_AIContext instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'lastWorkout': instance.lastWorkout?.toJson(),
      'top5OneRM': instance.top5OneRM,
      'recoveryStatus': _$RecoveryStatusEnumMap[instance.recoveryStatus]!,
      'userTier': instance.userTier,
      'experienceLevel': instance.experienceLevel,
      'fitnessGoal': instance.fitnessGoal,
    };

const _$RecoveryStatusEnumMap = {
  RecoveryStatus.green: 'green',
  RecoveryStatus.amber: 'amber',
  RecoveryStatus.red: 'red',
};
