/// Analytics Aggregator DataSource
///
/// Aggregates user analytics data into AI context.
/// Fetches from analytics, history, recovery, and streak repositories.
///
/// **Layer**: Data - DataSource
/// **Feature**: AI Coach
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_context.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/streak/data/repositories/streak_repository.dart';

/// Aggregates analytics data for AI Coach context
class AnalyticsAggregator {
  AnalyticsAggregator({
    required this.analyticsRepo,
    required this.historyRepo,
    required this.streakRepo,
  });

  final AnalyticsRepository analyticsRepo;
  final WorkoutHistoryRepositoryEnhanced historyRepo;
  final StreakRepository streakRepo;

  /// Aggregate full user context for AI
  ///
  /// Returns [AIContext] with streak, last workout, top 5 1RM, recovery status
  Future<AIContext> aggregateContext({required String userId}) async {
    debugPrint('[AI_COACH] 🔍 Starting context aggregation for user: $userId');

    try {
      // Fetch real data from repositories
      debugPrint('[AI_COACH] 📊 Fetching streak...');
      final streak = await getCurrentStreak(userId);
      debugPrint('[AI_COACH] ✅ Streak: $streak days');

      debugPrint('[AI_COACH] 📝 Fetching last workout...');
      final lastWorkout = await getLastWorkout(userId);
      debugPrint('[AI_COACH] ✅ Last workout: ${lastWorkout?.name ?? "none"}');

      debugPrint('[AI_COACH] 💪 Fetching top 5 1RM...');
      final top5 = await getTop5OneRM(userId);
      debugPrint('[AI_COACH] ✅ Top 5 1RM: ${top5.length} exercises');

      debugPrint('[AI_COACH] 🏃 Fetching recovery status...');
      final recovery = await getRecoveryStatus(userId);
      debugPrint('[AI_COACH] ✅ Recovery: ${recovery.name}');

      final context = AIContext(
        currentStreak: streak,
        lastWorkout: lastWorkout,
        top5OneRM: top5,
        recoveryStatus: recovery,
        userTier: 'free', // TODO: Get from user profile when tier system active
      );

      debugPrint('[AI_COACH] 🎯 Context aggregation complete:\n${context.toPromptString()}');
      return context;
    } catch (e, stackTrace) {
      // Fallback to empty context on error
      debugPrint('[AI_COACH] ❌ Error aggregating context: $e');
      debugPrint('[AI_COACH] Stack: $stackTrace');

      return const AIContext(
        currentStreak: 0,
        top5OneRM: {},
        recoveryStatus: RecoveryStatus.green,
        userTier: 'free',
      );
    }
  }

  /// Get top 5 exercises by 1RM for the user
  ///
  /// Returns map of exercise name -> 1RM in kg
  Future<Map<String, int>> getTop5OneRM(String userId) async {
    try {
      debugPrint('[AI_COACH] 💪 getTop5OneRM - userId: $userId');

      // Analytics repo returns Stream<Either<Failure, List<ExerciseHistory>>>
      // We need to get the first value from the stream
      final exerciseHistoryStream = analyticsRepo.getExerciseHistory(userId);

      // Get first emit (cached or real-time)
      final firstResult = await exerciseHistoryStream.first;

      // Handle Either result
      return firstResult.fold(
        (failure) {
          debugPrint('[AI_COACH] ❌ Failed to get exercise history: ${failure.message}');
          return <String, int>{};
        },
        (exercises) {
          debugPrint('[AI_COACH] ✅ Got ${exercises.length} exercises from analytics');

          // Extract top 5 by highest estimated 1RM
          final recordsMap = <String, int>{};

          for (final exercise in exercises) {
            if (exercise.sessions.isNotEmpty) {
              // Get highest 1RM from all sessions
              final highestRM = exercise.sessions
                  .map((s) => s.highestEstimated1RM)
                  .reduce((a, b) => a > b ? a : b);

              recordsMap[exercise.exerciseName] = highestRM.round();
            }
          }

          // Sort by 1RM descending
          final sorted = recordsMap.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final top5 = Map.fromEntries(sorted.take(5));
          debugPrint('[AI_COACH] 💪 Top 5 1RM: $top5');

          return top5;
        },
      );
    } catch (e, stackTrace) {
      debugPrint('[AI_COACH] ❌ Error in getTop5OneRM: $e');
      debugPrint('[AI_COACH] Stack: $stackTrace');
      return {};
    }
  }

  /// Get current workout streak in days
  Future<int> getCurrentStreak(String userId) async {
    try {
      debugPrint('[AI_COACH] 📊 getCurrentStreak - userId: $userId');

      final streak = await streakRepo.getCurrentStreak();
      final days = streak.currentStreak;

      debugPrint('[AI_COACH] ✅ Current streak: $days days');
      return days;
    } catch (e, stackTrace) {
      debugPrint('[AI_COACH] ❌ Error in getCurrentStreak: $e');
      debugPrint('[AI_COACH] Stack: $stackTrace');
      return 0;
    }
  }

  /// Get last completed workout summary
  Future<WorkoutSummary?> getLastWorkout(String userId) async {
    try {
      debugPrint('[AI_COACH] 📝 getLastWorkout - userId: $userId');

      // Call getWorkouts() which returns Either<Failure, List<WorkoutHistoryDetail>>
      final workoutsEither = await historyRepo.getWorkouts();

      return workoutsEither.fold(
        (failure) {
          debugPrint('[AI_COACH] ❌ Failed to get workouts: ${failure.message}');
          return null;
        },
        (workouts) {
          debugPrint('[AI_COACH] ✅ Got ${workouts.length} workouts from history');

          if (workouts.isEmpty) {
            debugPrint('[AI_COACH] ℹ️ No workouts found');
            return null;
          }

          // Get most recent workout (already sorted by date)
          final last = workouts.first;

          final summary = WorkoutSummary(
            id: last.id,
            name: last.name,
            completedAt: last.completedAt,
            exerciseCount: last.exercises.length,
            durationMinutes: last.duration.inMinutes,
          );

          debugPrint('[AI_COACH] 📝 Last workout: ${summary.name} (${summary.completedAt})');
          return summary;
        },
      );
    } catch (e, stackTrace) {
      debugPrint('[AI_COACH] ❌ Error in getLastWorkout: $e');
      debugPrint('[AI_COACH] Stack: $stackTrace');
      return null;
    }
  }

  /// Get user recovery status based on recent training load
  Future<RecoveryStatus> getRecoveryStatus(String userId) async {
    // Simple heuristic: check workout frequency in last 7 days
    try {
      debugPrint('[AI_COACH] 🏃 getRecoveryStatus - userId: $userId');

      final workoutsEither = await historyRepo.getWorkouts();

      return workoutsEither.fold(
        (failure) {
          debugPrint('[AI_COACH] ❌ Failed to get workouts for recovery: ${failure.message}');
          return RecoveryStatus.green;
        },
        (allWorkouts) {
          // Filter last 7 days
          final lastWeek = allWorkouts.where((WorkoutHistoryDetail w) {
            return w.completedAt.isAfter(DateTime.now().subtract(const Duration(days: 7)));
          }).length;

          debugPrint('[AI_COACH] 🏃 Workouts in last 7 days: $lastWeek');

          // Unified thresholds: >=6 red, >=4 amber, <4 green
          if (lastWeek >= 6) {
            debugPrint('[AI_COACH] 🔴 Very high frequency - recovery red');
            return RecoveryStatus.red; // Overtraining risk
          }
          if (lastWeek >= 4) {
            debugPrint('[AI_COACH] ⚠️ High frequency - recovery amber');
            return RecoveryStatus.amber; // High frequency
          }

          debugPrint('[AI_COACH] ✅ Low frequency - well recovered');
          return RecoveryStatus.green; // Low frequency, well recovered
        },
      );
    } catch (e, stackTrace) {
      debugPrint('[AI_COACH] ❌ Error in getRecoveryStatus: $e');
      debugPrint('[AI_COACH] Stack: $stackTrace');
      return RecoveryStatus.green;
    }
  }
}
