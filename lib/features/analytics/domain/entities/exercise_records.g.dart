// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_records.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseRecordsImpl _$$ExerciseRecordsImplFromJson(
  Map<String, dynamic> json,
) => _$ExerciseRecordsImpl(
  exerciseName: json['exerciseName'] as String,
  maxWeightRecord: (json['maxWeightRecord'] as num).toDouble(),
  estimated1RM: (json['estimated1RM'] as num).toDouble(),
  totalVolumeRecord: (json['totalVolumeRecord'] as num).toDouble(),
  totalSetsRecord: (json['totalSetsRecord'] as num).toInt(),
  lastWorkoutDate: DateTime.parse(json['lastWorkoutDate'] as String),
  weeklyFrequency: (json['weeklyFrequency'] as num).toDouble(),
  firstWorkoutDate: DateTime.parse(json['firstWorkoutDate'] as String),
  totalWorkouts: (json['totalWorkouts'] as num).toInt(),
);

Map<String, dynamic> _$$ExerciseRecordsImplToJson(
  _$ExerciseRecordsImpl instance,
) => <String, dynamic>{
  'exerciseName': instance.exerciseName,
  'maxWeightRecord': instance.maxWeightRecord,
  'estimated1RM': instance.estimated1RM,
  'totalVolumeRecord': instance.totalVolumeRecord,
  'totalSetsRecord': instance.totalSetsRecord,
  'lastWorkoutDate': instance.lastWorkoutDate.toIso8601String(),
  'weeklyFrequency': instance.weeklyFrequency,
  'firstWorkoutDate': instance.firstWorkoutDate.toIso8601String(),
  'totalWorkouts': instance.totalWorkouts,
};
