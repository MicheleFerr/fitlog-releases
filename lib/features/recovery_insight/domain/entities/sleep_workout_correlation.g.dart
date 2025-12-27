// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_workout_correlation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SleepWorkoutCorrelation _$SleepWorkoutCorrelationFromJson(
  Map<String, dynamic> json,
) => _SleepWorkoutCorrelation(
  volumeChangeAbove7h: (json['volumeChangeAbove7h'] as num).toDouble(),
  volumeChangeBelow6h: (json['volumeChangeBelow6h'] as num).toDouble(),
  workoutSampleSize: (json['workoutSampleSize'] as num).toInt(),
  sleepSampleSize: (json['sleepSampleSize'] as num).toInt(),
  isSignificant: json['isSignificant'] as bool,
  periodDays: (json['periodDays'] as num?)?.toInt() ?? 30,
  workoutsWithGoodSleep: (json['workoutsWithGoodSleep'] as num?)?.toInt() ?? 0,
  workoutsWithPoorSleep: (json['workoutsWithPoorSleep'] as num?)?.toInt() ?? 0,
  sleepPattern:
      $enumDecodeNullable(_$SleepPatternEnumMap, json['sleepPattern']) ??
      SleepPattern.unknown,
  averageSleepHours: (json['averageSleepHours'] as num?)?.toDouble() ?? 0.0,
  averageVolume: (json['averageVolume'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$SleepWorkoutCorrelationToJson(
  _SleepWorkoutCorrelation instance,
) => <String, dynamic>{
  'volumeChangeAbove7h': instance.volumeChangeAbove7h,
  'volumeChangeBelow6h': instance.volumeChangeBelow6h,
  'workoutSampleSize': instance.workoutSampleSize,
  'sleepSampleSize': instance.sleepSampleSize,
  'isSignificant': instance.isSignificant,
  'periodDays': instance.periodDays,
  'workoutsWithGoodSleep': instance.workoutsWithGoodSleep,
  'workoutsWithPoorSleep': instance.workoutsWithPoorSleep,
  'sleepPattern': _$SleepPatternEnumMap[instance.sleepPattern]!,
  'averageSleepHours': instance.averageSleepHours,
  'averageVolume': instance.averageVolume,
};

const _$SleepPatternEnumMap = {
  SleepPattern.variable: 'variable',
  SleepPattern.consistentlyGood: 'consistentlyGood',
  SleepPattern.consistentlyPoor: 'consistentlyPoor',
  SleepPattern.unknown: 'unknown',
};

_SleepWorkoutDataPoint _$SleepWorkoutDataPointFromJson(
  Map<String, dynamic> json,
) => _SleepWorkoutDataPoint(
  workoutDate: DateTime.parse(json['workoutDate'] as String),
  sleepHours: (json['sleepHours'] as num).toDouble(),
  workoutVolume: (json['workoutVolume'] as num).toDouble(),
  workoutDurationMinutes: (json['workoutDurationMinutes'] as num).toInt(),
  exerciseCount: (json['exerciseCount'] as num).toInt(),
  averageRpe: (json['averageRpe'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SleepWorkoutDataPointToJson(
  _SleepWorkoutDataPoint instance,
) => <String, dynamic>{
  'workoutDate': instance.workoutDate.toIso8601String(),
  'sleepHours': instance.sleepHours,
  'workoutVolume': instance.workoutVolume,
  'workoutDurationMinutes': instance.workoutDurationMinutes,
  'exerciseCount': instance.exerciseCount,
  'averageRpe': instance.averageRpe,
};
