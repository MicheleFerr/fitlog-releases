/// Analytics Aggregator DataSource
///
/// Aggregates user analytics data into AI context.
/// Fetches from analytics, history, recovery, and streak repositories.
///
/// **Layer**: Data - DataSource
/// **Feature**: AI Coach
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_context.dart';

/// Aggregates analytics data for AI Coach context
class AnalyticsAggregator {
  AnalyticsAggregator({
    required this.analyticsRepo,
    required this.historyRepo,
    required this.recoveryRepo,
    required this.streakRepo,
  });

  final dynamic analyticsRepo;
  final dynamic historyRepo;
  final dynamic recoveryRepo;
  final dynamic streakRepo;

  /// Aggregate full user context for AI
  ///
  /// Returns [AIContext] with streak, last workout, top 5 1RM, recovery status
  Future<AIContext> aggregateContext({required String userId}) async {
    try {
      // Fetch real data from repositories
      final streak = await getCurrentStreak(userId);
      final lastWorkout = await getLastWorkout(userId);
      final top5 = await getTop5OneRM(userId);
      final recovery = await getRecoveryStatus(userId);

      return AIContext(
        currentStreak: streak,
        lastWorkout: lastWorkout,
        top5OneRM: top5,
        recoveryStatus: recovery,
        userTier: 'free', // TODO: Get from user profile when tier system active
      );
    } catch (e) {
      // Fallback to empty context on error
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
      // Query analytics repository for exercise records
      final records = await analyticsRepo.getExerciseRecords();

      // Get top 5 by estimated 1RM
      final sorted = records.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return Map.fromEntries(
        sorted.take(5).map((e) => MapEntry(e.key, e.value)),
      );
    } catch (e) {
      return {};
    }
  }

  /// Get current workout streak in days
  Future<int> getCurrentStreak(String userId) async {
    try {
      final streak = await streakRepo.getCurrentStreak();
      return streak?.currentStreak ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get last completed workout summary
  Future<WorkoutSummary?> getLastWorkout(String userId) async {
    try {
      final workouts = await historyRepo.getRecentWorkouts(limit: 1);
      if (workouts.isEmpty) return null;

      final last = workouts.first;
      return WorkoutSummary(
        id: last.id,
        name: last.name ?? 'Allenamento',
        completedAt: last.completedAt ?? last.createdAt,
        exerciseCount: last.exercises.length,
        durationMinutes: last.duration?.inMinutes,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get user recovery status based on recent training load
  Future<RecoveryStatus> getRecoveryStatus(String userId) async {
    // Simple heuristic: check workout frequency in last 7 days
    try {
      final recent = await historyRepo.getRecentWorkouts(limit: 10);
      final lastWeek = recent.where((w) {
        final completed = w.completedAt ?? w.createdAt;
        return completed.isAfter(DateTime.now().subtract(const Duration(days: 7)));
      }).length;

      if (lastWeek >= 5) return RecoveryStatus.amber; // High frequency
      if (lastWeek >= 3) return RecoveryStatus.green;  // Optimal
      return RecoveryStatus.green; // Low frequency, well recovered
    } catch (e) {
      return RecoveryStatus.green;
    }
  }
}
