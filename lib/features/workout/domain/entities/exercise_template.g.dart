// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseTemplateImpl _$$ExerciseTemplateImplFromJson(
  Map<String, dynamic> json,
) => _$ExerciseTemplateImpl(
  exerciseName: json['exerciseName'] as String,
  defaultWeight: (json['defaultWeight'] as num).toDouble(),
  defaultReps: (json['defaultReps'] as num).toInt(),
  defaultSets: (json['defaultSets'] as num).toInt(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$ExerciseTemplateImplToJson(
  _$ExerciseTemplateImpl instance,
) => <String, dynamic>{
  'exerciseName': instance.exerciseName,
  'defaultWeight': instance.defaultWeight,
  'defaultReps': instance.defaultReps,
  'defaultSets': instance.defaultSets,
  'notes': instance.notes,
};
