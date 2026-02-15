// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parsed_workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParsedWorkout _$ParsedWorkoutFromJson(Map<String, dynamic> json) =>
    _ParsedWorkout(
      days: (json['days'] as List<dynamic>)
          .map((e) => ParsedDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      rawText: json['rawText'] as String?,
      hasMultipleDays: json['hasMultipleDays'] as bool? ?? false,
    );

Map<String, dynamic> _$ParsedWorkoutToJson(_ParsedWorkout instance) =>
    <String, dynamic>{
      'days': instance.days.map((e) => e.toJson()).toList(),
      'rawText': instance.rawText,
      'hasMultipleDays': instance.hasMultipleDays,
    };

_ParsedDay _$ParsedDayFromJson(Map<String, dynamic> json) => _ParsedDay(
  name: json['name'] as String,
  exercises: (json['exercises'] as List<dynamic>)
      .map((e) => ParsedExerciseLine.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ParsedDayToJson(_ParsedDay instance) =>
    <String, dynamic>{
      'name': instance.name,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
    };

_ParsedExerciseLine _$ParsedExerciseLineFromJson(Map<String, dynamic> json) =>
    _ParsedExerciseLine(
      rawName: json['rawName'] as String,
      sets: (json['sets'] as List<dynamic>)
          .map((e) => ParsedSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      restSeconds: (json['restSeconds'] as num?)?.toInt(),
      muscleGroup: json['muscleGroup'] as String?,
      notes: json['notes'] as String?,
      supersetGroup: json['supersetGroup'] as String?,
      matchedExerciseId: json['matchedExerciseId'] as String?,
      matchedExerciseName: json['matchedExerciseName'] as String?,
      matchConfidence: (json['matchConfidence'] as num?)?.toDouble(),
      matchedCategory: $enumDecodeNullable(
        _$ExerciseCategoryEnumMap,
        json['matchedCategory'],
      ),
    );

Map<String, dynamic> _$ParsedExerciseLineToJson(_ParsedExerciseLine instance) =>
    <String, dynamic>{
      'rawName': instance.rawName,
      'sets': instance.sets.map((e) => e.toJson()).toList(),
      'restSeconds': instance.restSeconds,
      'muscleGroup': instance.muscleGroup,
      'notes': instance.notes,
      'supersetGroup': instance.supersetGroup,
      'matchedExerciseId': instance.matchedExerciseId,
      'matchedExerciseName': instance.matchedExerciseName,
      'matchConfidence': instance.matchConfidence,
      'matchedCategory': _$ExerciseCategoryEnumMap[instance.matchedCategory],
    };

const _$ExerciseCategoryEnumMap = {
  ExerciseCategory.chest: 'chest',
  ExerciseCategory.back: 'back',
  ExerciseCategory.shoulders: 'shoulders',
  ExerciseCategory.arms: 'arms',
  ExerciseCategory.legs: 'legs',
  ExerciseCategory.abs: 'abs',
  ExerciseCategory.cardio: 'cardio',
  ExerciseCategory.other: 'other',
};

_ParsedSet _$ParsedSetFromJson(Map<String, dynamic> json) => _ParsedSet(
  reps: (json['reps'] as num?)?.toInt(),
  isMaxReps: json['isMaxReps'] as bool? ?? false,
  weight: (json['weight'] as num?)?.toDouble(),
  durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
  minReps: (json['minReps'] as num?)?.toInt(),
  maxReps: (json['maxReps'] as num?)?.toInt(),
);

Map<String, dynamic> _$ParsedSetToJson(_ParsedSet instance) =>
    <String, dynamic>{
      'reps': instance.reps,
      'isMaxReps': instance.isMaxReps,
      'weight': instance.weight,
      'durationSeconds': instance.durationSeconds,
      'minReps': instance.minReps,
      'maxReps': instance.maxReps,
    };
