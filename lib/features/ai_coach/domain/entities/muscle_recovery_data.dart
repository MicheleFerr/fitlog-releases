/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/entities
/// 🎯 Feature: ai_coach
/// 🔧 Type: entity
///
/// Muscle Recovery Data - Intermediate tier AI Coach insight
///
/// **Muscle Groups Tracked**:
/// - Chest (pectorals)
/// - Back (lats, traps, rhomboids)
/// - Shoulders (deltoids)
/// - Biceps
/// - Triceps
/// - Legs (quads, hamstrings, glutes, calves)
/// - Core (abs, obliques, lower back)
///
/// **Recovery Status** (per muscle):
/// - **Fully Recovered** (72h+ rest): Ready for high volume
/// - **Recovered** (48-72h rest): Ready for normal training
/// - **Partially Recovered** (24-48h rest): Light training recommended
/// - **Fatigued** (<24h rest): Rest or alternative muscle groups
///
/// **Intermediate Tier Feature**: Available after 12 workouts over 28 days
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'muscle_recovery_data.freezed.dart';
part 'muscle_recovery_data.g.dart';

/// Muscle-specific recovery data for Intermediate tier
///
/// **Usage**:
/// ```dart
/// final recovery = MuscleRecoveryData(
///   muscleGroups: {
///     MuscleGroup.chest: MuscleRecoveryStatus(
///       group: MuscleGroup.chest,
///       status: RecoveryStatus.recovered,
///       daysSinceLastWorkout: 2,
///       volumeLoad: 2500,
///       recommendedAction: 'Ready for normal training',
///     ),
///   },
/// );
///
/// print('Chest: ${recovery.muscleGroups[MuscleGroup.chest]?.emoji}');
/// // Chest: 💪 (Recovered)
/// ```
@freezed
class MuscleRecoveryData with _$MuscleRecoveryData {
  const factory MuscleRecoveryData({
    /// Map of muscle group to recovery status
    ///
    /// **Keys**: MuscleGroup enum (chest, back, legs, etc.)
    /// **Values**: MuscleRecoveryStatus with detailed metrics
    required Map<MuscleGroup, MuscleRecoveryStatus> muscleGroups,

    /// Overall recovery score (0-100)
    ///
    /// **Calculation**: Average of all muscle group recovery scores
    /// - 90-100: All muscles fully recovered
    /// - 75-89: Most muscles recovered
    /// - 60-74: Mixed recovery status
    /// - 40-59: Multiple muscles fatigued
    /// - 0-39: Significant fatigue across muscles
    required int overallRecoveryScore,

    /// Timestamp when data was calculated
    @Default(null) DateTime? calculatedAt,
  }) = _MuscleRecoveryData;

  const MuscleRecoveryData._();

  factory MuscleRecoveryData.fromJson(Map<String, dynamic> json) =>
      _$MuscleRecoveryDataFromJson(json);

  /// Locked state (insufficient data for tier)
  static const locked = MuscleRecoveryData(
    muscleGroups: {},
    overallRecoveryScore: 0,
  );

  /// Whether any muscle group is fatigued (<24h rest)
  bool get hasFatiguedMuscles {
    return muscleGroups.values
        .any((m) => m.status == RecoveryStatus.fatigued);
  }

  /// List of muscle groups ready for training (48h+ rest)
  List<MuscleGroup> get readyForTraining {
    return muscleGroups.entries
        .where((e) =>
            e.value.status == RecoveryStatus.recovered ||
            e.value.status == RecoveryStatus.fullyRecovered)
        .map((e) => e.key)
        .toList();
  }

  /// List of muscle groups that need rest (<48h)
  List<MuscleGroup> get needsRest {
    return muscleGroups.entries
        .where((e) =>
            e.value.status == RecoveryStatus.fatigued ||
            e.value.status == RecoveryStatus.partiallyRecovered)
        .map((e) => e.key)
        .toList();
  }
}

/// Muscle group categories for tracking
enum MuscleGroup {
  /// Chest muscles (pectorals)
  @JsonValue('chest')
  chest,

  /// Back muscles (lats, traps, rhomboids)
  @JsonValue('back')
  back,

  /// Shoulder muscles (deltoids)
  @JsonValue('shoulders')
  shoulders,

  /// Biceps
  @JsonValue('biceps')
  biceps,

  /// Triceps
  @JsonValue('triceps')
  triceps,

  /// Leg muscles (quads, hamstrings, glutes, calves)
  @JsonValue('legs')
  legs,

  /// Core muscles (abs, obliques, lower back)
  @JsonValue('core')
  core,
}

/// Recovery status for a specific muscle group
@freezed
class MuscleRecoveryStatus with _$MuscleRecoveryStatus {
  const factory MuscleRecoveryStatus({
    /// Muscle group this status applies to
    required MuscleGroup group,

    /// Current recovery status
    required RecoveryStatus status,

    /// Days since last workout for this muscle
    required int daysSinceLastWorkout,

    /// Total volume load in last 7 days (sets × reps × weight)
    ///
    /// Used to assess training intensity per muscle
    required int volumeLoad,

    /// Human-readable recommendation
    ///
    /// **Examples**:
    /// - "Ready for high volume training" (Fully Recovered)
    /// - "Ready for normal training" (Recovered)
    /// - "Light training recommended" (Partially Recovered)
    /// - "Rest or alternative muscle groups" (Fatigued)
    required String recommendedAction,

    /// Optional: Estimated hours until fully recovered
    ///
    /// **Calculation**: Based on 48-72h recovery window
    /// - <24h: 24-48h remaining
    /// - 24-48h: 0-24h remaining
    /// - 48h+: 0h (fully recovered)
    int? hoursUntilFullyRecovered,
  }) = _MuscleRecoveryStatus;

  const MuscleRecoveryStatus._();

  factory MuscleRecoveryStatus.fromJson(Map<String, dynamic> json) =>
      _$MuscleRecoveryStatusFromJson(json);

  /// Emoji representation of recovery status
  String get emoji {
    switch (status) {
      case RecoveryStatus.fullyRecovered:
        return '🔥'; // Peak readiness
      case RecoveryStatus.recovered:
        return '💪'; // Good to train
      case RecoveryStatus.partiallyRecovered:
        return '😐'; // Light training
      case RecoveryStatus.fatigued:
        return '😴'; // Needs rest
    }
  }

  /// Color for UI (semantic)
  ///
  /// Returns color name for theming:
  /// - fullyRecovered: success (green)
  /// - recovered: primary (blue)
  /// - partiallyRecovered: warning (yellow)
  /// - fatigued: error (red)
  String get colorName {
    switch (status) {
      case RecoveryStatus.fullyRecovered:
        return 'success';
      case RecoveryStatus.recovered:
        return 'primary';
      case RecoveryStatus.partiallyRecovered:
        return 'warning';
      case RecoveryStatus.fatigued:
        return 'error';
    }
  }
}

/// Recovery status levels for muscle groups
enum RecoveryStatus {
  /// Fully recovered (72h+ rest) - Ready for high volume
  @JsonValue('fully_recovered')
  fullyRecovered,

  /// Recovered (48-72h rest) - Ready for normal training
  @JsonValue('recovered')
  recovered,

  /// Partially recovered (24-48h rest) - Light training recommended
  @JsonValue('partially_recovered')
  partiallyRecovered,

  /// Fatigued (<24h rest) - Rest or alternative muscle groups
  @JsonValue('fatigued')
  fatigued,
}

/// Extension on MuscleGroup for convenience methods
extension MuscleGroupExtension on MuscleGroup {
  /// Display name for UI
  String get displayName {
    switch (this) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.legs:
        return 'Legs';
      case MuscleGroup.core:
        return 'Core';
    }
  }

  /// Icon name for UI (Material Icons)
  String get iconName {
    switch (this) {
      case MuscleGroup.chest:
        return 'fitness_center'; // Bench press icon
      case MuscleGroup.back:
        return 'straighten'; // Back muscles
      case MuscleGroup.shoulders:
        return 'accessibility_new'; // Shoulders
      case MuscleGroup.biceps:
        return 'fitness_center'; // Arm curl
      case MuscleGroup.triceps:
        return 'fitness_center'; // Tricep extension
      case MuscleGroup.legs:
        return 'directions_run'; // Leg day
      case MuscleGroup.core:
        return 'accessibility'; // Core work
    }
  }

  /// Typical recovery time in hours (general guideline)
  ///
  /// **Recovery Windows**:
  /// - Small muscles (biceps, triceps): 24-48h
  /// - Large muscles (chest, back, legs): 48-72h
  /// - Core: 24-48h (can train more frequently)
  int get typicalRecoveryHours {
    switch (this) {
      case MuscleGroup.chest:
      case MuscleGroup.back:
      case MuscleGroup.legs:
        return 72; // Large muscle groups need more recovery
      case MuscleGroup.shoulders:
        return 60; // Medium recovery time
      case MuscleGroup.biceps:
      case MuscleGroup.triceps:
      case MuscleGroup.core:
        return 48; // Smaller muscles recover faster
    }
  }
}

/// Extension on RecoveryStatus for convenience methods
extension RecoveryStatusExtension on RecoveryStatus {
  /// Display name for UI
  String get displayName {
    switch (this) {
      case RecoveryStatus.fullyRecovered:
        return 'Fully Recovered';
      case RecoveryStatus.recovered:
        return 'Recovered';
      case RecoveryStatus.partiallyRecovered:
        return 'Partially Recovered';
      case RecoveryStatus.fatigued:
        return 'Fatigued';
    }
  }

  /// Recovery score (0-100) for this status
  int get score {
    switch (this) {
      case RecoveryStatus.fullyRecovered:
        return 100;
      case RecoveryStatus.recovered:
        return 80;
      case RecoveryStatus.partiallyRecovered:
        return 50;
      case RecoveryStatus.fatigued:
        return 20;
    }
  }
}
