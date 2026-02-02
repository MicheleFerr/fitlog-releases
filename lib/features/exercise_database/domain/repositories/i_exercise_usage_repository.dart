/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/domain/repositories
/// 🎯 Feature: exercise_database
/// 🔧 Type: repository interface
///
/// Repository interface for exercise usage tracking
///
/// This abstraction allows swapping data sources (Hive, Firebase, InMemory)
/// without changing business logic or presentation layer.
///
/// Benefits:
/// - ✅ Testability: Easy to mock in unit tests
/// - ✅ Flexibility: Swap implementations without breaking changes
/// - ✅ Separation: Clear boundary between domain and data layers
library;

import 'package:gymbro_flutter_new/features/exercise_database/data/models/exercise_usage_model.dart';

/// Repository interface for exercise usage tracking
///
/// Provides abstraction over data source (Hive, Firebase, in-memory)
///
/// Example implementations:
/// - `HiveExerciseUsageRepository` - Local storage with Hive
/// - `FirebaseExerciseUsageRepository` - Cloud sync with Firebase
/// - `InMemoryExerciseUsageRepository` - Mock for testing
abstract class IExerciseUsageRepository {
  /// Initialize repository (e.g., open database connection)
  ///
  /// Call this once at app startup
  Future<void> initialize();

  /// Increment usage count for an exercise
  ///
  /// Creates new entry if exercise not tracked before
  ///
  /// [exerciseId] - Unique ID of the exercise
  /// [exerciseName] - Display name (for logging/debugging)
  /// [userId] - Current user ID (for personalization)
  Future<void> incrementUsage({
    required String exerciseId,
    required String exerciseName,
    required String userId,
  });

  /// Decrement usage count for an exercise (negative feedback)
  ///
  /// Useful when user removes exercise from workout or marks as "not useful"
  ///
  /// [exerciseId] - Unique ID of the exercise
  Future<void> decrementUsage({required String exerciseId});

  /// Remove exercise completely from usage tracking
  ///
  /// This deletes all history for this exercise
  ///
  /// [exerciseId] - Unique ID of the exercise to remove
  Future<void> removeExercise({required String exerciseId});

  /// Get ML boost score for a single exercise (0.0 - 1.0)
  ///
  /// Returns normalized boost based on usage frequency
  /// - 1.0 = Most used exercise
  /// - 0.5 = Half as used as most used
  /// - 0.0 = Never used
  ///
  /// [exerciseId] - Unique ID of the exercise
  /// Returns: Boost score (0.0-1.0)
  Future<double> getBoost(String exerciseId);

  /// OPTIMIZED: Get ML boost scores for multiple exercises in batch
  ///
  /// Much more efficient than calling `getBoost()` in a loop
  /// Performs single max calculation for normalization
  ///
  /// [exerciseIds] - List of exercise IDs to get boosts for
  /// Returns: Map of exerciseId → boost (0.0-1.0)
  ///
  /// Example:
  /// ```dart
  /// final boosts = await repository.getBatchBoosts(['ex1', 'ex2', 'ex3']);
  /// final boost1 = boosts['ex1'] ?? 0.0;
  /// ```
  Future<Map<String, double>> getBatchBoosts(List<String> exerciseIds);

  /// Get all exercise usage counts (for analytics/debug)
  ///
  /// Returns: Map of exerciseId → usageCount
  ///
  /// Example:
  /// ```dart
  /// final counts = await repository.getUserUsageCounts();
  /// final squatCount = counts['squat_123'] ?? 0;
  /// ```
  Future<Map<String, int>> getUserUsageCounts();

  /// Get top N most used exercises
  ///
  /// Sorted by usage count descending (most used first)
  ///
  /// [limit] - Maximum number of results (default 10)
  /// Returns: List of ExerciseUsageModel sorted by usage count
  Future<List<ExerciseUsageModel>> getTopUsedExercises({int limit = 10});

  /// Get recently used exercises
  ///
  /// Sorted by last used timestamp descending (most recent first)
  ///
  /// [limit] - Maximum number of results (default 10)
  /// Returns: List of ExerciseUsageModel sorted by last used date
  Future<List<ExerciseUsageModel>> getRecentlyUsedExercises({int limit = 10});

  /// Reset all usage data (for testing/debug)
  ///
  /// ⚠️ DANGER: This deletes all tracked exercise usage
  ///
  /// Use cases:
  /// - Testing: Clear data between test runs
  /// - User request: "Reset my personalized suggestions"
  /// - Debug: Reproduce fresh user experience
  Future<void> resetAllUsage();

  /// Dispose repository resources (close database connections, etc.)
  ///
  /// Call this when shutting down the app or disposing the provider
  Future<void> dispose();
}
