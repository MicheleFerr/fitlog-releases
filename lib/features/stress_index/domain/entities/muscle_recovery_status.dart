/// Muscle Recovery Status Entity
///
/// Represents the current recovery state of a specific muscle group.
/// Used for proactive recovery guidance before the next workout.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'muscle_recovery_status.freezed.dart';
part 'muscle_recovery_status.g.dart';

@freezed
abstract class MuscleRecoveryStatus with _$MuscleRecoveryStatus {
  const factory MuscleRecoveryStatus({
    /// Muscle identifier (e.g., "PETT", "LAT", "QUAD")
    required String muscleId,

    /// Display name for UI (e.g., "Chest", "Lats", "Quadriceps")
    required String displayName,

    /// Recovery percentage (0-100+)
    /// Can exceed 100% if fully recovered and supercompensated
    required double recoveryPercentage,

    /// When this muscle was last worked
    required DateTime lastWorked,

    /// Stress score from last workout
    required double lastStressScore,

    /// Current recovery state
    required RecoveryState state,
  }) = _MuscleRecoveryStatus;

  const MuscleRecoveryStatus._();

  factory MuscleRecoveryStatus.fromJson(Map<String, dynamic> json) =>
      _$MuscleRecoveryStatusFromJson(json);

  /// Hours since last workout
  int get hoursSinceLastWorkout =>
      DateTime.now().difference(lastWorked).inHours;

  /// Check if muscle is ready for training
  bool get isReadyForTraining =>
      state == RecoveryState.fullyRecovered ||
      state == RecoveryState.almostReady;

  /// Check if muscle should be avoided
  bool get shouldAvoid =>
      state == RecoveryState.exhausted ||
      state == RecoveryState.fatigued;
}

/// Recovery state categories based on percentage
enum RecoveryState {
  /// 100%+ - Fully recovered and ready
  fullyRecovered,

  /// 75-99% - Almost ready, light work OK
  almostReady,

  /// 50-74% - Still recovering, avoid heavy work
  recovering,

  /// 25-49% - Significantly fatigued
  fatigued,

  /// 0-24% - Needs rest, avoid training
  exhausted,
}
