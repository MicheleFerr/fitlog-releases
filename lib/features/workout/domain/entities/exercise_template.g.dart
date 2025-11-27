// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExerciseTemplate _$ExerciseTemplateFromJson(Map<String, dynamic> json) =>
    _ExerciseTemplate(
      exerciseName: json['exerciseName'] as String,
      defaultWeight: (json['defaultWeight'] as num).toDouble(),
      defaultReps: (json['defaultReps'] as num).toInt(),
      defaultSets: (json['defaultSets'] as num).toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ExerciseTemplateToJson(_ExerciseTemplate instance) =>
    <String, dynamic>{
      'exerciseName': instance.exerciseName,
      'defaultWeight': instance.defaultWeight,
      'defaultReps': instance.defaultReps,
      'defaultSets': instance.defaultSets,
      'notes': instance.notes,
    };
