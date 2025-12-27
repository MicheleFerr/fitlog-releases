// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muscle_readiness_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MuscleReadinessData _$MuscleReadinessDataFromJson(Map<String, dynamic> json) =>
    _MuscleReadinessData(
      muscleId: json['muscleId'] as String,
      displayName: json['displayName'] as String,
      recoveryPercent: (json['recoveryPercent'] as num).toDouble(),
      lastWorkedAt: json['lastWorkedAt'] == null
          ? null
          : DateTime.parse(json['lastWorkedAt'] as String),
      hoursSinceWorkout: (json['hoursSinceWorkout'] as num).toInt(),
      lastWorkoutStress: (json['lastWorkoutStress'] as num?)?.toDouble() ?? 0,
      expectedStressFromWorkout:
          (json['expectedStressFromWorkout'] as num?)?.toDouble() ?? 0,
      isPrimaryMuscle: json['isPrimaryMuscle'] as bool? ?? false,
      sleepModifier: (json['sleepModifier'] as num?)?.toDouble() ?? 0,
      hrvModifier: (json['hrvModifier'] as num?)?.toDouble() ?? 0,
      ageModifier: (json['ageModifier'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$MuscleReadinessDataToJson(
  _MuscleReadinessData instance,
) => <String, dynamic>{
  'muscleId': instance.muscleId,
  'displayName': instance.displayName,
  'recoveryPercent': instance.recoveryPercent,
  'lastWorkedAt': instance.lastWorkedAt?.toIso8601String(),
  'hoursSinceWorkout': instance.hoursSinceWorkout,
  'lastWorkoutStress': instance.lastWorkoutStress,
  'expectedStressFromWorkout': instance.expectedStressFromWorkout,
  'isPrimaryMuscle': instance.isPrimaryMuscle,
  'sleepModifier': instance.sleepModifier,
  'hrvModifier': instance.hrvModifier,
  'ageModifier': instance.ageModifier,
};
