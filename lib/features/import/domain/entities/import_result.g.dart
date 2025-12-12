// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImportParseResult _$ImportParseResultFromJson(Map<String, dynamic> json) =>
    _ImportParseResult(
      sourceApp: json['sourceApp'] as String,
      workouts: (json['workouts'] as List<dynamic>)
          .map((e) => ParsedWorkout.fromJson(e as Map<String, dynamic>))
          .toList(),
      unmappedExercises: (json['unmappedExercises'] as List<dynamic>)
          .map((e) => UnmappedExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      autoMappedExercises: Map<String, String>.from(
        json['autoMappedExercises'] as Map,
      ),
      warnings:
          (json['warnings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      totalRows: (json['totalRows'] as num).toInt(),
      parsedRows: (json['parsedRows'] as num).toInt(),
    );

Map<String, dynamic> _$ImportParseResultToJson(_ImportParseResult instance) =>
    <String, dynamic>{
      'sourceApp': instance.sourceApp,
      'workouts': instance.workouts.map((e) => e.toJson()).toList(),
      'unmappedExercises': instance.unmappedExercises
          .map((e) => e.toJson())
          .toList(),
      'autoMappedExercises': instance.autoMappedExercises,
      'warnings': instance.warnings,
      'totalRows': instance.totalRows,
      'parsedRows': instance.parsedRows,
    };

_ParsedWorkout _$ParsedWorkoutFromJson(Map<String, dynamic> json) =>
    _ParsedWorkout(
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ParsedExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ParsedWorkoutToJson(_ParsedWorkout instance) =>
    <String, dynamic>{
      'name': instance.name,
      'date': instance.date.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'notes': instance.notes,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
    };

_ParsedExercise _$ParsedExerciseFromJson(Map<String, dynamic> json) =>
    _ParsedExercise(
      originalName: json['originalName'] as String,
      mappedExerciseId: json['mappedExerciseId'] as String?,
      mappedExerciseName: json['mappedExerciseName'] as String?,
      sets: (json['sets'] as List<dynamic>)
          .map((e) => ParsedSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ParsedExerciseToJson(_ParsedExercise instance) =>
    <String, dynamic>{
      'originalName': instance.originalName,
      'mappedExerciseId': instance.mappedExerciseId,
      'mappedExerciseName': instance.mappedExerciseName,
      'sets': instance.sets.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
    };

_ParsedSet _$ParsedSetFromJson(Map<String, dynamic> json) => _ParsedSet(
  setNumber: (json['setNumber'] as num).toInt(),
  weight: (json['weight'] as num?)?.toDouble(),
  reps: (json['reps'] as num?)?.toInt(),
  seconds: (json['seconds'] as num?)?.toInt(),
  distance: (json['distance'] as num?)?.toDouble(),
  rpe: (json['rpe'] as num?)?.toInt(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ParsedSetToJson(_ParsedSet instance) =>
    <String, dynamic>{
      'setNumber': instance.setNumber,
      'weight': instance.weight,
      'reps': instance.reps,
      'seconds': instance.seconds,
      'distance': instance.distance,
      'rpe': instance.rpe,
      'notes': instance.notes,
    };

_UnmappedExercise _$UnmappedExerciseFromJson(Map<String, dynamic> json) =>
    _UnmappedExercise(
      originalName: json['originalName'] as String,
      occurrences: (json['occurrences'] as num).toInt(),
      suggestions:
          (json['suggestions'] as List<dynamic>?)
              ?.map((e) => ExerciseMatch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UnmappedExerciseToJson(_UnmappedExercise instance) =>
    <String, dynamic>{
      'originalName': instance.originalName,
      'occurrences': instance.occurrences,
      'suggestions': instance.suggestions.map((e) => e.toJson()).toList(),
    };

_ExerciseMatch _$ExerciseMatchFromJson(Map<String, dynamic> json) =>
    _ExerciseMatch(
      exerciseId: json['exerciseId'] as String,
      name: json['name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$ExerciseMatchToJson(_ExerciseMatch instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'name': instance.name,
      'confidence': instance.confidence,
    };

_ImportFinalResult _$ImportFinalResultFromJson(Map<String, dynamic> json) =>
    _ImportFinalResult(
      workoutsImported: (json['workoutsImported'] as num).toInt(),
      workoutsSkipped: (json['workoutsSkipped'] as num).toInt(),
      exercisesImported: (json['exercisesImported'] as num).toInt(),
      setsImported: (json['setsImported'] as num).toInt(),
      errors:
          (json['errors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      importedAt: DateTime.parse(json['importedAt'] as String),
      sourceApp: json['sourceApp'] as String,
    );

Map<String, dynamic> _$ImportFinalResultToJson(_ImportFinalResult instance) =>
    <String, dynamic>{
      'workoutsImported': instance.workoutsImported,
      'workoutsSkipped': instance.workoutsSkipped,
      'exercisesImported': instance.exercisesImported,
      'setsImported': instance.setsImported,
      'errors': instance.errors,
      'importedAt': instance.importedAt.toIso8601String(),
      'sourceApp': instance.sourceApp,
    };
