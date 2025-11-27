// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_workout_set_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LastWorkoutSetData _$LastWorkoutSetDataFromJson(Map<String, dynamic> json) =>
    _LastWorkoutSetData(
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      rpe: (json['rpe'] as num?)?.toInt(),
      date: DateTime.parse(json['date'] as String),
      workoutName: json['workoutName'] as String?,
      setNumber: (json['setNumber'] as num).toInt(),
      exerciseName: json['exerciseName'] as String,
    );

Map<String, dynamic> _$LastWorkoutSetDataToJson(_LastWorkoutSetData instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'reps': instance.reps,
      'rpe': instance.rpe,
      'date': instance.date.toIso8601String(),
      'workoutName': instance.workoutName,
      'setNumber': instance.setNumber,
      'exerciseName': instance.exerciseName,
    };

_LastWorkoutSetParams _$LastWorkoutSetParamsFromJson(
  Map<String, dynamic> json,
) => _LastWorkoutSetParams(
  exerciseName: json['exerciseName'] as String,
  setNumber: (json['setNumber'] as num).toInt(),
);

Map<String, dynamic> _$LastWorkoutSetParamsToJson(
  _LastWorkoutSetParams instance,
) => <String, dynamic>{
  'exerciseName': instance.exerciseName,
  'setNumber': instance.setNumber,
};
