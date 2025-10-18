/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/entities
/// 🎯 Feature: routine
/// 🔧 Type: entity
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// DAY STATS - Statistics and data for a single routine day
library;

import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';

/// Parameters for day stats calculation
class DayStatsParams {

  const DayStatsParams({
    required this.date,
    this.templateId,
    this.workoutId,
  });
  final DateTime date;
  final String? templateId;
  final String? workoutId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayStatsParams &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          templateId == other.templateId &&
          workoutId == other.workoutId;

  @override
  int get hashCode => date.hashCode ^ templateId.hashCode ^ workoutId.hashCode;
}

/// Complete statistics for a routine day
class DayStats {

  const DayStats({
    required this.date,
    this.templateId,
    this.templateName,
    this.completedWorkout,
    required this.totalVolume,
    required this.duration,
    required this.totalExercises,
    required this.completedExercises,
    required this.averageRPE,
    required this.previousWorkouts,
    this.volumeChangePercent,
    this.durationChange,
    required this.isPersonalRecord,
    required this.currentStreak,
    required this.isAfterRestDay,
    required this.totalWorkoutsWithTemplate,
  });

  /// Create empty stats
  factory DayStats.empty(DateTime date) {
    return DayStats(
      date: date,
      totalVolume: 0,
      duration: Duration.zero,
      totalExercises: 0,
      completedExercises: 0,
      averageRPE: 0,
      previousWorkouts: [],
      isPersonalRecord: false,
      currentStreak: 0,
      isAfterRestDay: false,
      totalWorkoutsWithTemplate: 0,
    );
  }
  // Current day data
  final DateTime date;
  final String? templateId;
  final String? templateName;
  final WorkoutHistoryDetail? completedWorkout;

  // Performance metrics
  final double totalVolume;
  final Duration duration;
  final int totalExercises;
  final int completedExercises;
  final double averageRPE;

  // Historical comparison
  final List<WorkoutHistoryDetail> previousWorkouts;
  final double? volumeChangePercent; // vs last workout
  final Duration? durationChange; // vs last workout
  final bool isPersonalRecord;

  // Streak & consistency
  final int currentStreak;
  final bool isAfterRestDay;
  final int totalWorkoutsWithTemplate;

  /// Check if day has completed workout
  bool get hasCompletedWorkout => completedWorkout != null;

  /// Calculate completion percentage
  double get completionPercentage {
    if (totalExercises == 0) return 0;
    return (completedExercises / totalExercises) * 100;
  }

  /// Get performance trend
  PerformanceTrend get performanceTrend {
    if (volumeChangePercent == null) return PerformanceTrend.neutral;
    if (volumeChangePercent! > 5) return PerformanceTrend.improving;
    if (volumeChangePercent! < -5) return PerformanceTrend.declining;
    return PerformanceTrend.stable;
  }

  /// Get last workout
  WorkoutHistoryDetail? get lastWorkout {
    if (previousWorkouts.isEmpty) return null;
    return previousWorkouts.first;
  }

  /// Calculate average volume from history
  double get averageVolume {
    if (previousWorkouts.isEmpty) return 0;
    final total = previousWorkouts.fold<double>(
      0,
      (sum, workout) => sum + workout.totalVolume,
    );
    return total / previousWorkouts.length;
  }

  /// Calculate average duration from history
  Duration get averageDuration {
    if (previousWorkouts.isEmpty) return Duration.zero;
    final totalMinutes = previousWorkouts.fold<int>(
      0,
      (sum, workout) => sum + workout.duration.inMinutes,
    );
    return Duration(minutes: totalMinutes ~/ previousWorkouts.length);
  }
}

/// Performance trend enum
enum PerformanceTrend {
  improving,
  stable,
  declining,
  neutral,
}
