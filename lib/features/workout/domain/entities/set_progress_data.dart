import 'package:freezed_annotation/freezed_annotation.dart';

part 'set_progress_data.freezed.dart';
part 'set_progress_data.g.dart';

/// Represents the progress comparison between current set and last workout.
/// Used to display progress arrows (green/red) in set rows.
@freezed
abstract class SetProgressData with _$SetProgressData {

  const factory SetProgressData({
    /// Current weight being lifted
    required double currentWeight,

    /// Weight from last workout for same exercise/set
    required double lastWeight,

    /// Current reps being performed
    required int currentReps,

    /// Reps from last workout for same exercise/set
    required int lastReps,

    /// Date of the last workout for reference
    required DateTime lastWorkoutDate,

    /// Set number this comparison is for
    required int setNumber,

    /// Exercise name for reference
    required String exerciseName,
  }) = _SetProgressData;
  const SetProgressData._();

  factory SetProgressData.fromJson(Map<String, dynamic> json) =>
      _$SetProgressDataFromJson(json);

  /// Weight difference (positive = improvement)
  double get weightDelta => currentWeight - lastWeight;

  /// Reps difference (positive = improvement)
  int get repsDelta => currentReps - lastReps;

  /// Whether weight has improved
  bool get hasWeightImproved => currentWeight > lastWeight;

  /// Whether weight has decreased
  bool get hasWeightDecreased => currentWeight < lastWeight;

  /// Whether reps have improved
  bool get hasRepsImproved => currentReps > lastReps;

  /// Whether reps have decreased
  bool get hasRepsDecreased => currentReps < lastReps;

  /// Overall progress status considering both weight and reps
  ProgressStatus get overallStatus {
    final weightUp = hasWeightImproved;
    final weightDown = hasWeightDecreased;
    final repsUp = hasRepsImproved;
    final repsDown = hasRepsDecreased;

    // Both improved = big win
    if (weightUp && repsUp) return ProgressStatus.majorImprovement;

    // Weight improved, reps same or slightly down = improvement
    if (weightUp && !repsDown) return ProgressStatus.improvement;
    if (weightUp && repsDown) return ProgressStatus.mixed;

    // Reps improved, weight same = improvement
    if (repsUp && !weightDown) return ProgressStatus.improvement;
    if (repsUp && weightDown) return ProgressStatus.mixed;

    // Both decreased = regression
    if (weightDown && repsDown) return ProgressStatus.majorRegression;

    // Either decreased alone = regression
    if (weightDown || repsDown) return ProgressStatus.regression;

    // Same = no change
    return ProgressStatus.unchanged;
  }

  /// Get percentage change for weight
  double get weightPercentageChange {
    if (lastWeight == 0) return currentWeight > 0 ? 100.0 : 0.0;
    return ((currentWeight - lastWeight) / lastWeight) * 100;
  }

  /// Get percentage change for reps
  double get repsPercentageChange {
    if (lastReps == 0) return currentReps > 0 ? 100.0 : 0.0;
    return ((currentReps - lastReps) / lastReps) * 100;
  }
}

/// Status enum for progress comparison
enum ProgressStatus {
  /// Both weight and reps improved
  majorImprovement,

  /// Either weight or reps improved (other unchanged)
  improvement,

  /// Mixed results (one up, one down)
  mixed,

  /// No change in weight or reps
  unchanged,

  /// Either weight or reps decreased (other unchanged)
  regression,

  /// Both weight and reps decreased
  majorRegression,
}

/// Parameters for querying set progress data
@freezed
abstract class SetProgressParams with _$SetProgressParams {
  const factory SetProgressParams({
    required String exerciseName,
    required int setNumber,
    required double currentWeight,
    required int currentReps,
  }) = _SetProgressParams;

  factory SetProgressParams.fromJson(Map<String, dynamic> json) =>
      _$SetProgressParamsFromJson(json);
}
