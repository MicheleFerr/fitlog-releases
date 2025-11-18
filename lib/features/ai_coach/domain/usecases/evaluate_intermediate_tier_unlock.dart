/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/usecases
/// 🎯 Feature: ai_coach
/// 🔧 Type: use_case
///
/// Evaluate Intermediate Tier Unlock - Calculate muscle-specific recovery data
///
/// **Requirements**:
/// - Minimum 12 workouts logged
/// - Minimum 28 days of data
///
/// **Muscle Recovery Calculation**:
/// - Track 7 muscle groups (chest, back, shoulders, biceps, triceps, legs, core)
/// - Analyze volume load per muscle (sets × reps × weight)
/// - Calculate days since last workout per muscle
/// - Determine recovery status (Fully Recovered, Recovered, Partially Recovered, Fatigued)
///
/// **Recovery Thresholds**:
/// - Fatigued: <24h rest
/// - Partially Recovered: 24-48h rest
/// - Recovered: 48-72h rest
/// - Fully Recovered: 72h+ rest
///
/// **Returns**:
/// - `MuscleRecoveryData.locked` if requirements not met
/// - `MuscleRecoveryData` with per-muscle recovery status if unlocked
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/muscle_recovery_data.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/recovery_tier.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Evaluate Intermediate Tier unlock and calculate muscle-specific recovery
///
/// **Usage**:
/// ```dart
/// final useCase = EvaluateIntermediateTierUnlock();
/// final data = await useCase.call(
///   workouts: userWorkouts,
///   accountCreatedAt: userCreatedDate,
/// );
///
/// if (data.overallRecoveryScore == 0) {
///   // Show lock screen
/// } else {
///   // Show muscle recovery: Chest ${data.muscleGroups[MuscleGroup.chest]?.emoji}
/// }
/// ```
class EvaluateIntermediateTierUnlock {
  /// Evaluate if user meets Intermediate tier requirements and calculate muscle recovery
  ///
  /// **Parameters**:
  /// - `workouts`: List of completed workouts
  /// - `accountCreatedAt`: Date when user account was created
  ///
  /// **Returns**: MuscleRecoveryData with per-muscle recovery status or locked state
  Future<MuscleRecoveryData> call({
    required List<Workout> workouts,
    required DateTime accountCreatedAt,
  }) async {
    // Check if user meets Intermediate tier unlock criteria
    const config = RecoveryTierConfig.intermediate;
    final daysSinceCreation =
        DateTime.now().difference(accountCreatedAt).inDays;

    if (workouts.length < config.minWorkouts ||
        daysSinceCreation < config.minDays) {
      // Return locked state
      return MuscleRecoveryData.locked;
    }

    // User has unlocked Intermediate tier - calculate muscle recovery
    return _calculateMuscleRecovery(workouts);
  }

  /// Calculate muscle-specific recovery data from workout history
  MuscleRecoveryData _calculateMuscleRecovery(List<Workout> workouts) {
    // Initialize recovery status map for all muscle groups
    final muscleGroups = <MuscleGroup, MuscleRecoveryStatus>{};

    // Calculate recovery for each muscle group
    for (final group in MuscleGroup.values) {
      muscleGroups[group] = _calculateMuscleGroupRecovery(group, workouts);
    }

    // Calculate overall recovery score (average of all muscles)
    final overallScore = _calculateOverallRecoveryScore(muscleGroups);

    return MuscleRecoveryData(
      muscleGroups: muscleGroups,
      overallRecoveryScore: overallScore,
      calculatedAt: DateTime.now(),
    );
  }

  /// Calculate recovery status for a specific muscle group
  MuscleRecoveryStatus _calculateMuscleGroupRecovery(
    MuscleGroup group,
    List<Workout> workouts,
  ) {
    // Get workouts that trained this muscle group (last 30 days)
    final relevantWorkouts = _getWorkoutsForMuscleGroup(group, workouts);

    // Calculate days since last workout for this muscle
    final daysSinceLastWorkout =
        _getDaysSinceLastWorkout(relevantWorkouts);

    // Calculate volume load (last 7 days only)
    final volumeLoad = _calculateVolumeLoad(relevantWorkouts, daysWindow: 7);

    // Determine recovery status based on days since last workout
    final status = _determineRecoveryStatus(daysSinceLastWorkout, group);

    // Generate recommendation
    final recommendation = _generateRecommendation(status);

    // Calculate hours until fully recovered
    final hoursUntilFullyRecovered =
        _calculateHoursUntilFullyRecovered(daysSinceLastWorkout, group);

    return MuscleRecoveryStatus(
      group: group,
      status: status,
      daysSinceLastWorkout: daysSinceLastWorkout,
      volumeLoad: volumeLoad,
      recommendedAction: recommendation,
      hoursUntilFullyRecovered: hoursUntilFullyRecovered,
    );
  }

  /// Get workouts that trained a specific muscle group
  List<Workout> _getWorkoutsForMuscleGroup(
    MuscleGroup group,
    List<Workout> workouts,
  ) {
    final last30Days = DateTime.now().subtract(const Duration(days: 30));

    return workouts.where((workout) {
      // Filter out workouts with null startTime or older than 30 days
      if (workout.startTime == null ||
          workout.startTime!.isBefore(last30Days)) {
        return false;
      }

      // Check if workout contains exercises targeting this muscle group
      return workout.exercises.any((exercise) {
        final categories = _mapMuscleGroupToExerciseCategories(group);
        return categories.contains(exercise.category);
      });
    }).toList();
  }

  /// Map MuscleGroup to corresponding ExerciseCategory values
  ///
  /// **Mappings**:
  /// - chest → [ExerciseCategory.chest]
  /// - back → [ExerciseCategory.back]
  /// - shoulders → [ExerciseCategory.shoulders]
  /// - biceps → [ExerciseCategory.arms] (partial match)
  /// - triceps → [ExerciseCategory.arms] (partial match)
  /// - legs → [ExerciseCategory.legs]
  /// - core → [ExerciseCategory.abs]
  List<ExerciseCategory> _mapMuscleGroupToExerciseCategories(
      MuscleGroup group) {
    switch (group) {
      case MuscleGroup.chest:
        return [ExerciseCategory.chest];
      case MuscleGroup.back:
        return [ExerciseCategory.back];
      case MuscleGroup.shoulders:
        return [ExerciseCategory.shoulders];
      case MuscleGroup.biceps:
      case MuscleGroup.triceps:
        // Arms exercises cover both biceps and triceps
        return [ExerciseCategory.arms];
      case MuscleGroup.legs:
        return [ExerciseCategory.legs];
      case MuscleGroup.core:
        return [ExerciseCategory.abs];
    }
  }

  /// Calculate days since last workout for muscle group
  int _getDaysSinceLastWorkout(List<Workout> relevantWorkouts) {
    if (relevantWorkouts.isEmpty) return 999; // Never trained

    final validWorkouts =
        relevantWorkouts.where((w) => w.startTime != null).toList();
    if (validWorkouts.isEmpty) return 999;

    final lastWorkout = validWorkouts.reduce(
        (a, b) => a.startTime!.isAfter(b.startTime!) ? a : b);
    return DateTime.now().difference(lastWorkout.startTime!).inDays;
  }

  /// Calculate total volume load (sets × reps × weight) for muscle group
  ///
  /// **Formula**: Σ(sets × reps × weight) for all exercises targeting muscle
  int _calculateVolumeLoad(List<Workout> relevantWorkouts,
      {int daysWindow = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysWindow));

    int totalVolume = 0;

    for (final workout in relevantWorkouts) {
      // Skip workouts outside the time window
      if (workout.startTime == null ||
          workout.startTime!.isBefore(cutoffDate)) {
        continue;
      }

      // Sum volume for all exercises in workout
      for (final exercise in workout.exercises) {
        for (final set in exercise.sets) {
          final weight = set.weight ?? 0.0;
          final reps = set.actualReps ?? set.reps ?? 0;
          totalVolume += (weight * reps).toInt();
        }
      }
    }

    return totalVolume;
  }

  /// Determine recovery status based on days since last workout
  ///
  /// **Thresholds** (adjusted per muscle group size):
  /// - Large muscles (chest, back, legs): 72h+ = Fully Recovered
  /// - Medium muscles (shoulders): 60h+ = Fully Recovered
  /// - Small muscles (biceps, triceps, core): 48h+ = Fully Recovered
  RecoveryStatus _determineRecoveryStatus(
    int daysSinceLastWorkout,
    MuscleGroup group,
  ) {
    if (daysSinceLastWorkout >= 999) {
      // Never trained = fully recovered
      return RecoveryStatus.fullyRecovered;
    }

    final typicalRecoveryDays = group.typicalRecoveryHours / 24;

    // Fully recovered threshold (e.g., 3 days for large muscles)
    if (daysSinceLastWorkout >= typicalRecoveryDays) {
      return RecoveryStatus.fullyRecovered;
    }

    // Recovered threshold (2-3 days for large muscles, 2 days for small)
    if (daysSinceLastWorkout >= (typicalRecoveryDays * 0.67)) {
      return RecoveryStatus.recovered;
    }

    // Partially recovered threshold (1-2 days)
    if (daysSinceLastWorkout >= 1) {
      return RecoveryStatus.partiallyRecovered;
    }

    // Fatigued (<24h rest)
    return RecoveryStatus.fatigued;
  }

  /// Generate human-readable recommendation based on recovery status
  String _generateRecommendation(RecoveryStatus status) {
    switch (status) {
      case RecoveryStatus.fullyRecovered:
        return 'Ready for high volume training';
      case RecoveryStatus.recovered:
        return 'Ready for normal training';
      case RecoveryStatus.partiallyRecovered:
        return 'Light training recommended';
      case RecoveryStatus.fatigued:
        return 'Rest or alternative muscle groups';
    }
  }

  /// Calculate hours until fully recovered
  int? _calculateHoursUntilFullyRecovered(
    int daysSinceLastWorkout,
    MuscleGroup group,
  ) {
    if (daysSinceLastWorkout >= 999) {
      return 0; // Never trained or fully recovered
    }

    final typicalRecoveryHours = group.typicalRecoveryHours;
    final hoursSinceLastWorkout = daysSinceLastWorkout * 24;

    final hoursRemaining = typicalRecoveryHours - hoursSinceLastWorkout;

    return hoursRemaining > 0 ? hoursRemaining : 0;
  }

  /// Calculate overall recovery score (0-100)
  ///
  /// **Formula**: Average of all muscle group recovery scores
  int _calculateOverallRecoveryScore(
      Map<MuscleGroup, MuscleRecoveryStatus> muscleGroups) {
    if (muscleGroups.isEmpty) return 0;

    final totalScore = muscleGroups.values
        .fold(0, (sum, muscle) => sum + muscle.status.score);

    return (totalScore / muscleGroups.length).round();
  }
}
