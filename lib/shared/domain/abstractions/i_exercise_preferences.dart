/// Interface for Exercise Preferences Repository
///
/// This abstraction breaks the circular dependency between:
/// - exercise_database (needs to read preferences)
/// - analytics (owns the implementation)
///
/// By depending on this interface instead of the concrete implementation,
/// exercise_database can use preferences without importing analytics.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract interface for exercise preferences
///
/// Concrete implementation: [ExercisePreferencesRepository] in analytics feature
abstract class IExercisePreferencesRepository {
  /// Get the counting mode override for an exercise
  ///
  /// Returns null if no override exists (use default from exercise definition)
  Future<String?> getCountingModeOverride(String exerciseId);

  /// Set counting mode override for an exercise
  Future<void> setCountingModeOverride(String exerciseId, String countingMode);

  /// Remove counting mode override
  Future<void> removeCountingModeOverride(String exerciseId);

  /// Get all counting mode overrides
  Future<Map<String, String>> getAllCountingModeOverrides();

  /// Get all favorites
  Future<Set<String>> getFavorites();

  /// Set favorites (debounced write)
  Future<void> setFavorites(Set<String> favorites);

  /// Toggle favorite status
  Future<void> toggleFavorite(String exerciseName);

  /// Dispose resources
  void dispose();
}

/// Provider for the exercise preferences repository interface
///
/// This is overridden at app startup with the concrete implementation
/// from analytics feature. This allows exercise_database to depend only
/// on the interface, not the implementation.
///
/// **Setup in main.dart or app initialization:**
/// ```dart
/// ProviderScope(
///   overrides: [
///     exercisePreferencesProvider.overrideWith(
///       (ref) => ref.watch(exercisePreferencesRepositoryProvider),
///     ),
///   ],
///   child: MyApp(),
/// )
/// ```
final exercisePreferencesProvider =
    Provider.autoDispose<IExercisePreferencesRepository?>((ref) {
  // Default: null (no preferences available)
  // Overridden at runtime with concrete implementation
  return null;
});

/// Provider for counting mode override lookup
///
/// Uses the abstract interface, not concrete implementation
final countingModeOverrideLookupProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, exerciseId) async {
  final repo = ref.watch(exercisePreferencesProvider);
  if (repo == null) return null;
  return repo.getCountingModeOverride(exerciseId);
});

/// Provider for all counting mode overrides (for batch operations)
///
/// Uses the abstract interface, not concrete implementation
final allCountingModeOverridesProvider =
    FutureProvider.autoDispose<Map<String, String>>((ref) async {
  final repo = ref.watch(exercisePreferencesProvider);
  if (repo == null) return {};
  return repo.getAllCountingModeOverrides();
});
