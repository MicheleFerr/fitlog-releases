// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muscle_recovery_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MuscleRecoveryData _$MuscleRecoveryDataFromJson(Map<String, dynamic> json) =>
    _MuscleRecoveryData(
      muscleGroups: (json['muscleGroups'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          $enumDecode(_$MuscleGroupEnumMap, k),
          MuscleRecoveryStatus.fromJson(e as Map<String, dynamic>),
        ),
      ),
      overallRecoveryScore: (json['overallRecoveryScore'] as num).toInt(),
      calculatedAt: json['calculatedAt'] == null
          ? null
          : DateTime.parse(json['calculatedAt'] as String),
    );

Map<String, dynamic> _$MuscleRecoveryDataToJson(_MuscleRecoveryData instance) =>
    <String, dynamic>{
      'muscleGroups': instance.muscleGroups.map(
        (k, e) => MapEntry(_$MuscleGroupEnumMap[k]!, e.toJson()),
      ),
      'overallRecoveryScore': instance.overallRecoveryScore,
      'calculatedAt': instance.calculatedAt?.toIso8601String(),
    };

const _$MuscleGroupEnumMap = {
  MuscleGroup.chest: 'chest',
  MuscleGroup.back: 'back',
  MuscleGroup.shoulders: 'shoulders',
  MuscleGroup.biceps: 'biceps',
  MuscleGroup.triceps: 'triceps',
  MuscleGroup.legs: 'legs',
  MuscleGroup.core: 'core',
};

_MuscleRecoveryStatus _$MuscleRecoveryStatusFromJson(
  Map<String, dynamic> json,
) => _MuscleRecoveryStatus(
  group: $enumDecode(_$MuscleGroupEnumMap, json['group']),
  status: $enumDecode(_$RecoveryStatusEnumMap, json['status']),
  daysSinceLastWorkout: (json['daysSinceLastWorkout'] as num).toInt(),
  volumeLoad: (json['volumeLoad'] as num).toInt(),
  recommendedAction: json['recommendedAction'] as String,
  hoursUntilFullyRecovered: (json['hoursUntilFullyRecovered'] as num?)?.toInt(),
);

Map<String, dynamic> _$MuscleRecoveryStatusToJson(
  _MuscleRecoveryStatus instance,
) => <String, dynamic>{
  'group': _$MuscleGroupEnumMap[instance.group]!,
  'status': _$RecoveryStatusEnumMap[instance.status]!,
  'daysSinceLastWorkout': instance.daysSinceLastWorkout,
  'volumeLoad': instance.volumeLoad,
  'recommendedAction': instance.recommendedAction,
  'hoursUntilFullyRecovered': instance.hoursUntilFullyRecovered,
};

const _$RecoveryStatusEnumMap = {
  RecoveryStatus.fullyRecovered: 'fully_recovered',
  RecoveryStatus.recovered: 'recovered',
  RecoveryStatus.partiallyRecovered: 'partially_recovered',
  RecoveryStatus.fatigued: 'fatigued',
};
