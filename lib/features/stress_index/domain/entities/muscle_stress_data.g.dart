// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muscle_stress_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MuscleStressData _$MuscleStressDataFromJson(Map<String, dynamic> json) =>
    _MuscleStressData(
      muscleId: json['muscleId'] as String,
      displayName: json['displayName'] as String,
      stressScore: (json['stressScore'] as num).toDouble(),
      setsCount: (json['setsCount'] as num).toInt(),
      totalVolume: (json['totalVolume'] as num).toDouble(),
      avgRpe: (json['avgRpe'] as num).toDouble(),
      recoveryHours: (json['recoveryHours'] as num).toInt(),
      estimatedRecovery: json['estimatedRecovery'] == null
          ? null
          : DateTime.parse(json['estimatedRecovery'] as String),
    );

Map<String, dynamic> _$MuscleStressDataToJson(_MuscleStressData instance) =>
    <String, dynamic>{
      'muscleId': instance.muscleId,
      'displayName': instance.displayName,
      'stressScore': instance.stressScore,
      'setsCount': instance.setsCount,
      'totalVolume': instance.totalVolume,
      'avgRpe': instance.avgRpe,
      'recoveryHours': instance.recoveryHours,
      'estimatedRecovery': instance.estimatedRecovery?.toIso8601String(),
    };
