// ignore_for_file: sort_unnamed_constructors_first

/// Parsed Workout Entities
///
/// Freezed entities representing the result of AI parsing
/// of workout text or photos.
///
/// **Layer**: Domain - Entities
/// **Feature**: Workout Import
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

part 'parsed_workout.freezed.dart';
part 'parsed_workout.g.dart';

/// Complete parsed workout result from AI
@freezed
abstract class ParsedWorkout with _$ParsedWorkout {
  const factory ParsedWorkout({
    required List<ParsedDay> days,
    String? rawText,
    @Default(false) bool hasMultipleDays,
  }) = _ParsedWorkout;

  factory ParsedWorkout.fromJson(Map<String, dynamic> json) =>
      _$ParsedWorkoutFromJson(json);
}

/// Single training day parsed from text
@freezed
abstract class ParsedDay with _$ParsedDay {
  const factory ParsedDay({
    required String name,
    required List<ParsedExerciseLine> exercises,
  }) = _ParsedDay;

  factory ParsedDay.fromJson(Map<String, dynamic> json) =>
      _$ParsedDayFromJson(json);
}

/// Single exercise line parsed from text with match result
@freezed
abstract class ParsedExerciseLine with _$ParsedExerciseLine {
  const ParsedExerciseLine._();

  const factory ParsedExerciseLine({
    required String rawName,
    required List<ParsedSet> sets,
    int? restSeconds,
    String? muscleGroup,
    String? notes,
    String? supersetGroup,
    // Fuzzy match results (populated after matching)
    String? matchedExerciseId,
    String? matchedExerciseName,
    double? matchConfidence,
    ExerciseCategory? matchedCategory,
  }) = _ParsedExerciseLine;

  factory ParsedExerciseLine.fromJson(Map<String, dynamic> json) =>
      _$ParsedExerciseLineFromJson(json);

  /// Match confidence level for UI badge display
  MatchLevel get matchLevel {
    if (matchedExerciseId == null || matchConfidence == null) {
      return MatchLevel.none;
    }
    if (matchConfidence! >= 0.80) return MatchLevel.confident;
    if (matchConfidence! >= 0.50) return MatchLevel.suggested;
    return MatchLevel.none;
  }
}

/// Confidence level for exercise match - drives badge UI
enum MatchLevel { confident, suggested, none }

/// Single set parsed from text
@freezed
abstract class ParsedSet with _$ParsedSet {
  const factory ParsedSet({
    int? reps,
    @Default(false) bool isMaxReps,
    double? weight,
    int? durationSeconds,
    int? minReps,
    int? maxReps,
  }) = _ParsedSet;

  factory ParsedSet.fromJson(Map<String, dynamic> json) =>
      _$ParsedSetFromJson(json);
}
