// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muscle_recovery_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MuscleRecoveryStatus _$MuscleRecoveryStatusFromJson(
  Map<String, dynamic> json,
) => _MuscleRecoveryStatus(
  muscleId: json['muscleId'] as String,
  displayName: json['displayName'] as String,
  recoveryPercentage: (json['recoveryPercentage'] as num).toDouble(),
  lastWorked: DateTime.parse(json['lastWorked'] as String),
  lastStressScore: (json['lastStressScore'] as num).toDouble(),
  state: $enumDecode(_$RecoveryStateEnumMap, json['state']),
);

Map<String, dynamic> _$MuscleRecoveryStatusToJson(
  _MuscleRecoveryStatus instance,
) => <String, dynamic>{
  'muscleId': instance.muscleId,
  'displayName': instance.displayName,
  'recoveryPercentage': instance.recoveryPercentage,
  'lastWorked': instance.lastWorked.toIso8601String(),
  'lastStressScore': instance.lastStressScore,
  'state': _$RecoveryStateEnumMap[instance.state]!,
};

const _$RecoveryStateEnumMap = {
  RecoveryState.fullyRecovered: 'fullyRecovered',
  RecoveryState.almostReady: 'almostReady',
  RecoveryState.recovering: 'recovering',
  RecoveryState.fatigued: 'fatigued',
  RecoveryState.exhausted: 'exhausted',
};
