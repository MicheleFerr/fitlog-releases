/// Import Result Entity
///
/// Represents the result of a workout data import operation.
/// Tracks success, failures, and exercise mappings.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_result.freezed.dart';
part 'import_result.g.dart';

/// Result of parsing a CSV file
@freezed
abstract class ImportParseResult with _$ImportParseResult {
  const factory ImportParseResult({
    /// Source app (strong, hevy, generic)
    required String sourceApp,

    /// Parsed workouts ready for import
    required List<ParsedWorkout> workouts,

    /// Exercises that need manual mapping
    required List<UnmappedExercise> unmappedExercises,

    /// Exercises successfully auto-mapped
    required Map<String, String> autoMappedExercises,

    /// Parse errors/warnings
    @Default([]) List<String> warnings,

    /// Total rows in CSV
    required int totalRows,

    /// Successfully parsed rows
    required int parsedRows,
  }) = _ImportParseResult;

  factory ImportParseResult.fromJson(Map<String, dynamic> json) =>
      _$ImportParseResultFromJson(json);
}

/// A parsed workout from CSV
@freezed
abstract class ParsedWorkout with _$ParsedWorkout {
  const factory ParsedWorkout({
    /// Original workout name from CSV
    required String name,

    /// Workout date
    required DateTime date,

    /// Duration in minutes (if available)
    int? durationMinutes,

    /// Workout notes
    String? notes,

    /// Exercises in this workout
    required List<ParsedExercise> exercises,
  }) = _ParsedWorkout;

  factory ParsedWorkout.fromJson(Map<String, dynamic> json) =>
      _$ParsedWorkoutFromJson(json);
}

/// A parsed exercise from CSV
@freezed
abstract class ParsedExercise with _$ParsedExercise {
  const factory ParsedExercise({
    /// Original exercise name from CSV
    required String originalName,

    /// Mapped exercise ID in our database (null if unmapped)
    String? mappedExerciseId,

    /// Mapped exercise name (null if unmapped)
    String? mappedExerciseName,

    /// Sets for this exercise
    required List<ParsedSet> sets,

    /// Exercise notes
    String? notes,
  }) = _ParsedExercise;

  factory ParsedExercise.fromJson(Map<String, dynamic> json) =>
      _$ParsedExerciseFromJson(json);
}

/// A parsed set from CSV
@freezed
abstract class ParsedSet with _$ParsedSet {
  const factory ParsedSet({
    /// Set number (1-based)
    required int setNumber,

    /// Weight (in user's unit preference)
    double? weight,

    /// Reps performed
    int? reps,

    /// Duration in seconds (for timed exercises)
    int? seconds,

    /// Distance (for cardio)
    double? distance,

    /// RPE if available
    int? rpe,

    /// Set notes
    String? notes,
  }) = _ParsedSet;

  factory ParsedSet.fromJson(Map<String, dynamic> json) =>
      _$ParsedSetFromJson(json);
}

/// An exercise that couldn't be auto-mapped
@freezed
abstract class UnmappedExercise with _$UnmappedExercise {
  const factory UnmappedExercise({
    /// Original name from CSV
    required String originalName,

    /// How many times this exercise appears
    required int occurrences,

    /// Best fuzzy match suggestions
    @Default([]) List<ExerciseMatch> suggestions,
  }) = _UnmappedExercise;

  factory UnmappedExercise.fromJson(Map<String, dynamic> json) =>
      _$UnmappedExerciseFromJson(json);
}

/// A suggested exercise match
@freezed
abstract class ExerciseMatch with _$ExerciseMatch {
  const factory ExerciseMatch({
    /// Exercise ID in our database
    required String exerciseId,

    /// Exercise name
    required String name,

    /// Match confidence (0.0 - 1.0)
    required double confidence,
  }) = _ExerciseMatch;

  factory ExerciseMatch.fromJson(Map<String, dynamic> json) =>
      _$ExerciseMatchFromJson(json);
}

/// Final import result after user confirms
@freezed
abstract class ImportFinalResult with _$ImportFinalResult {
  const factory ImportFinalResult({
    /// Number of workouts imported
    required int workoutsImported,

    /// Number of workouts skipped (duplicates, errors)
    required int workoutsSkipped,

    /// Total exercises imported
    required int exercisesImported,

    /// Total sets imported
    required int setsImported,

    /// Import errors
    @Default([]) List<String> errors,

    /// Import timestamp
    required DateTime importedAt,

    /// Source app
    required String sourceApp,
  }) = _ImportFinalResult;

  factory ImportFinalResult.fromJson(Map<String, dynamic> json) =>
      _$ImportFinalResultFromJson(json);
}
