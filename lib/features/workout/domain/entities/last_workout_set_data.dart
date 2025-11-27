import 'package:freezed_annotation/freezed_annotation.dart';

part 'last_workout_set_data.freezed.dart';
part 'last_workout_set_data.g.dart';

/// Data from the last completed workout for a specific exercise and set number.
/// Used for pre-fill functionality in QuickEditOverlay.
@freezed
abstract class LastWorkoutSetData with _$LastWorkoutSetData {
  const factory LastWorkoutSetData({
    /// Weight used in the last workout (in kg)
    required double weight,

    /// Number of reps completed
    required int reps,

    /// RPE rating (1-10) if recorded
    int? rpe,

    /// Date when this workout was completed
    required DateTime date,

    /// Name of the workout (e.g., "Push Day")
    String? workoutName,

    /// Set number this data corresponds to
    required int setNumber,

    /// Exercise name for reference
    required String exerciseName,
  }) = _LastWorkoutSetData;

  factory LastWorkoutSetData.fromJson(Map<String, dynamic> json) =>
      _$LastWorkoutSetDataFromJson(json);
}

/// Parameters for querying last workout set data
@freezed
abstract class LastWorkoutSetParams with _$LastWorkoutSetParams {
  const factory LastWorkoutSetParams({
    required String exerciseName,
    required int setNumber,
  }) = _LastWorkoutSetParams;

  factory LastWorkoutSetParams.fromJson(Map<String, dynamic> json) =>
      _$LastWorkoutSetParamsFromJson(json);
}
