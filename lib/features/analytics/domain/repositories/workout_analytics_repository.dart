/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain
/// 🎯 Feature: analytics
/// 🔧 Type: repository interface
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - workout/domain/entities: Workout
/// - analytics/domain/entities: WorkoutMetrics, PersonalRecordAchieved
library;

import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';

/// Abstract repository for workout analytics data access
abstract class WorkoutAnalyticsRepository {
  
  /// Get historical workouts for comparison
  Future<List<Workout>> getHistoricalWorkouts(
    String userId, {
    int limit = 50,
    DateTime? since,
  });

  /// Get workouts similar to the given workout
  Future<List<Workout>> getSimilarWorkouts(
    String userId,
    Workout targetWorkout, {
    int limit = 10,
    double minSimilarity = 0.3,
  });

  /// Get personal records for user
  Future<List<PersonalRecord>> getUserPRs(String userId);

  /// Get personal records for specific exercise
  Future<Map<PRType, PersonalRecord>> getExercisePRs(
    String userId,
    String exerciseId,
  );

  /// Save personal record achievement
  Future<void> savePR(PersonalRecord pr);

  /// Get workout metrics history
  Future<List<WorkoutMetrics>> getWorkoutMetricsHistory(
    String userId, {
    int limit = 30,
    DateTime? since,
  });

  /// Cache workout metrics for performance
  Future<void> cacheWorkoutMetrics(WorkoutMetrics metrics);

  /// Get cached workout metrics
  Future<WorkoutMetrics?> getCachedWorkoutMetrics(String workoutId);

  /// Get workout statistics for analytics
  Future<WorkoutAnalyticsStats> getAnalyticsStats(String userId);

  /// Stream of real-time workout updates for analytics
  Stream<WorkoutAnalyticsUpdate> watchWorkoutUpdates(String workoutId);

  /// Sync workouts from Firebase to local Hive storage
  /// Useful for first-time sync or manual refresh
  /// Optional [onProgress] callback to track sync progress
  Future<void> syncWorkoutsFromFirebase(
    String userId, {
    Function(int current, int total)? onProgress,
  });
}

/// Analytics statistics summary
class WorkoutAnalyticsStats {

  const WorkoutAnalyticsStats({
    required this.totalWorkouts,
    required this.totalPRs,
    required this.averageWorkoutVolume,
    required this.averageWorkoutDuration,
    required this.totalVolumeLifted,
    required this.exerciseFrequency,
    required this.exerciseVolumeDistribution,
    this.lastWorkoutDate,
    this.firstWorkoutDate,
  });

  /// Create from JSON
  factory WorkoutAnalyticsStats.fromJson(Map<String, dynamic> json) {
    return WorkoutAnalyticsStats(
      totalWorkouts: json['totalWorkouts'] as int,
      totalPRs: json['totalPRs'] as int,
      averageWorkoutVolume: (json['averageWorkoutVolume'] as num).toDouble(),
      averageWorkoutDuration: (json['averageWorkoutDuration'] as num).toDouble(),
      totalVolumeLifted: (json['totalVolumeLifted'] as num).toDouble(),
      exerciseFrequency: (json['exerciseFrequency'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as int),
      ),
      exerciseVolumeDistribution: (json['exerciseVolumeDistribution'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      lastWorkoutDate: json['lastWorkoutDate'] != null
        ? DateTime.parse(json['lastWorkoutDate'] as String)
        : null,
      firstWorkoutDate: json['firstWorkoutDate'] != null
        ? DateTime.parse(json['firstWorkoutDate'] as String)
        : null,
    );
  }
  final int totalWorkouts;
  final int totalPRs;
  final double averageWorkoutVolume;
  final double averageWorkoutDuration; // in minutes
  final double totalVolumeLifted;
  final Map<String, int> exerciseFrequency;
  final Map<String, double> exerciseVolumeDistribution;
  final DateTime? lastWorkoutDate;
  final DateTime? firstWorkoutDate;

  /// Get training consistency (workouts per week average)
  double get trainingConsistency {
    if (firstWorkoutDate == null || lastWorkoutDate == null) return 0;
    
    final totalDays = lastWorkoutDate!.difference(firstWorkoutDate!).inDays;
    if (totalDays <= 0) return 0;
    
    final totalWeeks = totalDays / 7;
    return totalWorkouts / totalWeeks;
  }

  /// Get most frequent exercise
  String? get mostFrequentExercise {
    if (exerciseFrequency.isEmpty) return null;
    
    return exerciseFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get exercise with highest volume
  String? get highestVolumeExercise {
    if (exerciseVolumeDistribution.isEmpty) return null;

    return exerciseVolumeDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalWorkouts': totalWorkouts,
      'totalPRs': totalPRs,
      'averageWorkoutVolume': averageWorkoutVolume,
      'averageWorkoutDuration': averageWorkoutDuration,
      'totalVolumeLifted': totalVolumeLifted,
      'exerciseFrequency': exerciseFrequency,
      'exerciseVolumeDistribution': exerciseVolumeDistribution,
      'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
      'firstWorkoutDate': firstWorkoutDate?.toIso8601String(),
    };
  }
}

/// Real-time workout analytics update
class WorkoutAnalyticsUpdate {

  const WorkoutAnalyticsUpdate({
    required this.workoutId,
    required this.metrics,
    required this.newPRs,
    required this.timestamp,
  });
  final String workoutId;
  final WorkoutMetrics metrics;
  final List<PersonalRecordAchieved> newPRs;
  final DateTime timestamp;

  bool get hasPRs => newPRs.isNotEmpty;
  int get prCount => newPRs.length;
}