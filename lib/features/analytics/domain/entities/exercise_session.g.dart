// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseSessionImpl _$$ExerciseSessionImplFromJson(
  Map<String, dynamic> json,
) => _$ExerciseSessionImpl(
  exerciseName: json['exerciseName'] as String,
  muscleGroup: json['muscleGroup'] as String,
  sets: (json['sets'] as List<dynamic>)
      .map((e) => AnalyticsSet.fromJson(e as Map<String, dynamic>))
      .toList(),
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$$ExerciseSessionImplToJson(
  _$ExerciseSessionImpl instance,
) => <String, dynamic>{
  'exerciseName': instance.exerciseName,
  'muscleGroup': instance.muscleGroup,
  'sets': instance.sets.map((e) => e.toJson()).toList(),
  'date': instance.date.toIso8601String(),
};
