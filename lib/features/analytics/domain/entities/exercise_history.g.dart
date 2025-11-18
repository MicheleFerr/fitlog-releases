// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseHistoryImpl _$$ExerciseHistoryImplFromJson(
        Map<String, dynamic> json) =>
    _$ExerciseHistoryImpl(
      exerciseName: json['exerciseName'] as String,
      muscleGroup: json['muscleGroup'] as String,
      sessions: (json['sessions'] as List<dynamic>)
          .map((e) => ExerciseSession.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ExerciseHistoryImplToJson(
        _$ExerciseHistoryImpl instance) =>
    <String, dynamic>{
      'exerciseName': instance.exerciseName,
      'muscleGroup': instance.muscleGroup,
      'sessions': instance.sessions.map((e) => e.toJson()).toList(),
    };
