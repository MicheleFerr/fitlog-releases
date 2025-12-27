/// Muscle Readiness Data Entity
///
/// Contains detailed readiness information for a specific muscle group.
/// Used for template stress analysis and recovery tracking.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'muscle_readiness_data.freezed.dart';
part 'muscle_readiness_data.g.dart';

@freezed
abstract class MuscleReadinessData with _$MuscleReadinessData {
  const factory MuscleReadinessData({
    /// Muscle identifier (e.g., "PETT", "LAT", "QUAD")
    required String muscleId,

    /// Display name for UI (e.g., "Chest", "Lats", "Quadriceps")
    required String displayName,

    /// Recovery percentage (0-150%)
    /// Can exceed 100% if supercompensated
    required double recoveryPercent,

    /// When this muscle was last worked
    DateTime? lastWorkedAt,

    /// Hours since last workout
    required int hoursSinceWorkout,

    /// Stress from last workout (0-100)
    @Default(0) double lastWorkoutStress,

    /// How this workout would stress this muscle (0-100)
    @Default(0) double expectedStressFromWorkout,

    /// Whether this muscle is primary or secondary in the template
    @Default(false) bool isPrimaryMuscle,

    // === CONTRIBUTING FACTORS ===

    /// Sleep modifier applied (-30% to 0%)
    @Default(0) double sleepModifier,

    /// HRV modifier applied (-25% to +10%)
    @Default(0) double hrvModifier,

    /// Age modifier applied (-20% to 0%)
    @Default(0) double ageModifier,
  }) = _MuscleReadinessData;

  const MuscleReadinessData._();

  factory MuscleReadinessData.fromJson(Map<String, dynamic> json) =>
      _$MuscleReadinessDataFromJson(json);

  /// Readiness state based on recovery percentage
  MuscleReadinessState get state {
    if (recoveryPercent >= 100) return MuscleReadinessState.fullyReady;
    if (recoveryPercent >= 90) return MuscleReadinessState.ready;
    if (recoveryPercent >= 70) return MuscleReadinessState.acceptable;
    if (recoveryPercent >= 50) return MuscleReadinessState.underRecovered;
    return MuscleReadinessState.fatigued;
  }

  /// Whether this muscle is ready for training
  bool get isReady =>
      state == MuscleReadinessState.fullyReady ||
      state == MuscleReadinessState.ready;

  /// Whether training this muscle would be suboptimal
  bool get isSuboptimal =>
      state == MuscleReadinessState.acceptable ||
      state == MuscleReadinessState.underRecovered;

  /// Whether this muscle should be avoided
  bool get shouldAvoid => state == MuscleReadinessState.fatigued;

  /// Total modifier from all factors (for display)
  double get totalModifier => sleepModifier + hrvModifier + ageModifier;

  /// Whether modifiers significantly impacted recovery
  bool get hasSignificantModifiers => totalModifier.abs() > 10;
}

/// Muscle readiness states for template analysis
enum MuscleReadinessState {
  /// 100%+ recovered - Optimal for training
  fullyReady,

  /// 90-99% recovered - Good to go
  ready,

  /// 70-89% recovered - Doable but not ideal
  acceptable,

  /// 50-69% recovered - Risk of accumulated fatigue
  underRecovered,

  /// <50% recovered - Should rest
  fatigued,
}
