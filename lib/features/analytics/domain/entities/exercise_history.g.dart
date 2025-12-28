// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExerciseHistory _$ExerciseHistoryFromJson(Map<String, dynamic> json) =>
    _ExerciseHistory(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      muscleGroup: json['muscleGroup'] as String,
      sessions: (json['sessions'] as List<dynamic>)
          .map((e) => ExerciseSession.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExerciseHistoryToJson(_ExerciseHistory instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'muscleGroup': instance.muscleGroup,
      'sessions': instance.sessions.map((e) => e.toJson()).toList(),
    };
