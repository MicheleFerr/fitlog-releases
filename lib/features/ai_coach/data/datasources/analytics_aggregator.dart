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
    // TODO: Implement actual aggregation from repositories
    // This is a placeholder implementation for MVP
    // Will be implemented in post-MVP phase (Batch 12+)

    return const AIContext(
      currentStreak: 0,
      top5OneRM: {},
      recoveryStatus: RecoveryStatus.green,
      userTier: 'free',
    );
  }

  /// Get top 5 exercises by 1RM for the user
  ///
  /// Returns map of exercise name -> 1RM in kg
  Future<Map<String, int>> getTop5OneRM(String userId) async {
    // TODO: Query analytics repository for top 5 1RM
    // Placeholder for MVP
    return {};
  }

  /// Get current workout streak in days
  Future<int> getCurrentStreak(String userId) async {
    // TODO: Query streak repository
    return 0;
  }

  /// Get last completed workout summary
  Future<WorkoutSummary?> getLastWorkout(String userId) async {
    // TODO: Query history repository for last workout
    return null;
  }

  /// Get user recovery status based on recent training load
  Future<RecoveryStatus> getRecoveryStatus(String userId) async {
    // TODO: Query recovery repository
    return RecoveryStatus.green;
  }
}
