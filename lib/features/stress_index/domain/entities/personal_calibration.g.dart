// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_calibration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PersonalCalibration _$PersonalCalibrationFromJson(Map<String, dynamic> json) =>
    _PersonalCalibration(
      userId: json['userId'] as String,
      ageFactor: (json['ageFactor'] as num?)?.toDouble() ?? 1.0,
      trainingAgeFactor: (json['trainingAgeFactor'] as num?)?.toDouble() ?? 1.0,
      sexFactor: (json['sexFactor'] as num?)?.toDouble() ?? 1.0,
      hrvFactor: (json['hrvFactor'] as num?)?.toDouble() ?? 1.0,
      sleepFactor: (json['sleepFactor'] as num?)?.toDouble() ?? 1.0,
      injuryFactor: (json['injuryFactor'] as num?)?.toDouble() ?? 1.0,
      baselineHrv: (json['baselineHrv'] as num?)?.toDouble(),
      baselineSleepHours: (json['baselineSleepHours'] as num?)?.toDouble(),
      baselineRestingHr: (json['baselineRestingHr'] as num?)?.toDouble(),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      dataPointsUsed: (json['dataPointsUsed'] as num?)?.toInt() ?? 0,
      confidenceLevel: (json['confidenceLevel'] as num?)?.toDouble() ?? 0.5,
    );

Map<String, dynamic> _$PersonalCalibrationToJson(
  _PersonalCalibration instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'ageFactor': instance.ageFactor,
  'trainingAgeFactor': instance.trainingAgeFactor,
  'sexFactor': instance.sexFactor,
  'hrvFactor': instance.hrvFactor,
  'sleepFactor': instance.sleepFactor,
  'injuryFactor': instance.injuryFactor,
  'baselineHrv': instance.baselineHrv,
  'baselineSleepHours': instance.baselineSleepHours,
  'baselineRestingHr': instance.baselineRestingHr,
  'lastUpdated': instance.lastUpdated?.toIso8601String(),
  'dataPointsUsed': instance.dataPointsUsed,
  'confidenceLevel': instance.confidenceLevel,
};
