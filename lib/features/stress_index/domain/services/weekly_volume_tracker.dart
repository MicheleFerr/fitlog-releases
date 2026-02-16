/// Weekly Volume Tracker Service
///
/// Calculates direct sets per muscle group in the last 7 days.
/// Used for volume need scoring in template suggestions.
///
/// **Key Features**:
/// - Counts only primary muscle sets (focus), not secondary
/// - Filters workouts from the last 7 days
/// - Provides volume ratio vs MRV totals
library;

import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/constants/volume_landmarks.dart';

/// Weekly Volume Tracker - Calculates weekly set counts per muscle group
class WeeklyVolumeTracker {
  /// Private constructor
  const WeeklyVolumeTracker._(this._setsThisWeek);

  /// Create from workout history and exercise database
  ///
  /// Filters workouts from last 7 days and counts direct sets per muscle.
  ///
  /// **Logic**:
  /// - Only counts PRIMARY muscles (focus) as direct sets
  /// - Secondary muscles are NOT counted (indirect volume only)
  /// - Uses exercise database lookup by ID or name
  factory WeeklyVolumeTracker.fromHistory(
    List<WorkoutHistoryDetail> history,
    Map<String, ExerciseDefinition> exerciseDB,
  ) {
    final weekStart = _startOfWeek(DateTime.now());
    final thisWeekWorkouts =
        history.where((w) => w.completedAt.isAfter(weekStart)).toList();

    final sets = <String, int>{};

    for (final workout in thisWeekWorkouts) {
      for (final exercise in workout.exercises) {
        // Look up exercise definition by ID first, then by name
        final definition =
            exerciseDB[exercise.id] ?? exerciseDB[exercise.name];

        if (definition == null) continue;

        // Count ONLY primary muscle sets (direct volume)
        // Secondary muscles are indirect volume - don't count them
        for (final primaryMuscle in definition.focus) {
          sets[primaryMuscle] = (sets[primaryMuscle] ?? 0) + exercise.sets.length;
        }
      }
    }

    return WeeklyVolumeTracker._(sets);
  }

  final Map<String, int> _setsThisWeek;

  /// Get sets done this week for a specific muscle
  ///
  /// Returns 0 if muscle hasn't been trained
  int setsThisWeek(String muscle) => _setsThisWeek[muscle] ?? 0;

  /// Get total volume ratio vs MRV sum across all muscles
  ///
  /// Returns value between 0.0 (no volume) and 1.0+ (at/above MRV)
  /// Used for CNS fatigue proxy calculation
  double get totalVolumeRatio {
    double totalCurrent = 0;
    double totalMRV = 0;

    for (final entry in volumeLandmarks.entries) {
      final muscle = entry.key;
      final landmarks = entry.value;

      totalCurrent += setsThisWeek(muscle);
      totalMRV += landmarks.mrv;
    }

    return totalMRV > 0 ? totalCurrent / totalMRV : 0.0;
  }

  /// Calculate start of current week (Monday)
  ///
  /// Returns DateTime for Monday 00:00:00 of current week
  static DateTime _startOfWeek(DateTime date) {
    final daysSinceMonday = date.weekday - 1; // 1=Mon, 7=Sun -> 0-6
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysSinceMonday));
  }

  /// Get all muscles with non-zero volume this week
  List<String> get trainedMuscles => _setsThisWeek.keys.toList();

  /// Get total sets across all muscles this week
  int get totalSetsThisWeek =>
      _setsThisWeek.values.fold(0, (sum, sets) => sum + sets);

  @override
  String toString() => 'WeeklyVolumeTracker(${_setsThisWeek.length} muscles, '
      '$totalSetsThisWeek total sets, ${(totalVolumeRatio * 100).toStringAsFixed(1)}% of MRV)';
}
