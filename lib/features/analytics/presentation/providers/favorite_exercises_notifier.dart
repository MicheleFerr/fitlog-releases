/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/providers
/// 🎯 Feature: analytics
/// 🔧 Type: provider
///
/// FavoriteExercisesNotifier - Manages user's favorite exercises
///
/// **Responsibilities**:
/// - Track which exercises are marked as favorites
/// - Toggle favorite status for exercises
/// - Provide quick lookup for favorite status
/// - Sync with Firestore (optimized for minimal reads/writes)
///
/// **State**: `Set<String>` of exercise names marked as favorite
///
/// **Firestore Cost Optimization**:
/// - Lazy loading: Only loads from Firestore when Analytics screen is visible
/// - Optimistic updates: UI updates immediately, Firestore async
/// - Debounced writes: 500ms batch window to reduce write operations
///
/// **Methods**:
/// - toggleFavorite(exerciseName): Add/remove from favorites
/// - isFavorite(exerciseName): Check if exercise is favorite
///
/// **Usage**:
/// ```dart
/// // Watch favorite status
/// final isFavorite = ref.watch(favoriteExercisesNotifierProvider
///     .select((state) => state.contains('Bench Press')));
///
/// // Toggle favorite
/// ref.read(favoriteExercisesNotifierProvider.notifier)
///     .toggleFavorite('Bench Press');
/// ```
///
/// **Integration**:
/// - Data persistence: ExercisePreferencesRepository (debounced writes)
/// - Real-time sync: StreamProvider listens to Firestore updates
/// - UI integration: Task 5.2 (star icon on exercise cards)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/exercise_preferences_repository.dart';

/// StateNotifier for managing favorite exercises
///
/// State is a `Set<String>` containing exercise names that are marked as favorite.
/// This provides O(1) lookup time for checking favorite status.
///
/// **Firestore Integration**:
/// - Reads from Firestore on initialization (1 read)
/// - Writes to Firestore on toggle (debounced, 1 write per 500ms batch)
/// - Listens to Firestore stream for real-time sync
class FavoriteExercisesNotifier extends StateNotifier<Set<String>> {
  FavoriteExercisesNotifier(this._ref) : super({}) {
    _loadInitialState();
  }

  final Ref _ref;

  /// Load initial favorites from Firestore
  ///
  /// **Firestore Cost**: 1 read (only on first load)
  ///
  /// Called automatically on notifier initialization.
  /// Silently fails if user not authenticated or Firestore error.
  Future<void> _loadInitialState() async {
    final repo = _ref.read(exercisePreferencesRepositoryProvider);
    if (repo == null) return; // User not authenticated

    try {
      final prefs = await repo.getPreferences();
      if (prefs != null) {
        state = prefs.favoritesSet;
      }
    } catch (e) {
      // Silently fail - start with empty set
      // User can still add favorites, they'll sync when connection restored
    }
  }

  /// Toggle favorite status for an exercise
  ///
  /// **Optimistic Update**: UI updates immediately, Firestore write happens async
  ///
  /// **Parameters**:
  /// - exerciseName: Name of the exercise (e.g., "Bench Press")
  ///
  /// **Firestore Cost**: 1 write (debounced 500ms)
  ///
  /// **Side effects**:
  /// - Updates local state immediately (optimistic update)
  /// - Triggers debounced Firestore write (500ms delay)
  void toggleFavorite(String exerciseName) {
    final newState = Set<String>.from(state);

    if (newState.contains(exerciseName)) {
      // Remove from favorites
      newState.remove(exerciseName);
    } else {
      // Add to favorites
      newState.add(exerciseName);
    }

    // Optimistic update - UI updates immediately
    state = newState;

    // Persist to Firestore (debounced)
    final repo = _ref.read(exercisePreferencesRepositoryProvider);
    if (repo != null) {
      // Fire-and-forget - don't await
      // Repository handles debouncing (500ms) to batch rapid toggles
      repo.setFavorites(newState);
    }
  }

  /// Check if an exercise is marked as favorite
  ///
  /// **Parameters**:
  /// - exerciseName: Name of the exercise to check
  ///
  /// **Returns**: true if exercise is in favorites, false otherwise
  ///
  /// **Complexity**: O(1) lookup time
  bool isFavorite(String exerciseName) {
    return state.contains(exerciseName);
  }

  /// Add multiple exercises to favorites at once
  ///
  /// Useful for bulk operations or initial sync from Firestore.
  ///
  /// **Parameters**:
  /// - exerciseNames: Set of exercise names to mark as favorite
  void addFavorites(Set<String> exerciseNames) {
    state = {...state, ...exerciseNames};
  }

  /// Remove multiple exercises from favorites at once
  ///
  /// **Parameters**:
  /// - exerciseNames: Set of exercise names to remove from favorites
  void removeFavorites(Set<String> exerciseNames) {
    final newState = Set<String>.from(state);
    newState.removeAll(exerciseNames);
    state = newState;
  }

  /// Clear all favorites
  ///
  /// Useful for testing or reset scenarios.
  void clearAll() {
    state = {};
  }

  /// Update favorites from Firestore stream
  ///
  /// **Internal use**: Called by favoriteExercisesNotifierProvider
  /// when Firestore stream emits new data.
  ///
  /// **Parameters**:
  /// - favorites: New set of favorites from Firestore
  ///
  /// Only updates if state is different to avoid unnecessary rebuilds.
  void updateFromFirestore(Set<String> favorites) {
    if (state != favorites) {
      state = favorites;
    }
  }
}

/// Provider for favorite exercises state
///
/// **Type**: `StateNotifierProvider<FavoriteExercisesNotifier, Set<String>>`
/// **Default**: Empty set (loads from Firestore on init)
/// **Persistence**: Firestore with debounced writes (500ms)
///
/// **Firestore Cost**:
/// - Initial load: 1 read
/// - Per toggle: 1 write (debounced 500ms batch)
/// - Real-time sync: 1 read per external update
///
/// **State Management**:
/// - Read state: `ref.watch(favoriteExercisesNotifierProvider)`
/// - Check favorite: `ref.watch(favoriteExercisesNotifierProvider.select((s) => s.contains('exercise')))`
/// - Toggle: `ref.read(favoriteExercisesNotifierProvider.notifier).toggleFavorite('exercise')`
///
/// **Integration**:
/// - Uses favoriteExercisesStreamProvider for real-time sync
/// - Automatically syncs with other devices/sessions
final favoriteExercisesNotifierProvider =
    StateNotifierProvider<FavoriteExercisesNotifier, Set<String>>(
  (ref) {
    final notifier = FavoriteExercisesNotifier(ref);

    // Listen to Firestore stream for real-time sync
    // This keeps local state in sync with Firestore changes from other devices
    ref.listen(favoriteExercisesStreamProvider, (previous, next) {
      next.whenData((prefs) {
        if (prefs != null) {
          // Update state from Firestore
          // Only if different to avoid unnecessary rebuilds
          notifier.updateFromFirestore(prefs.favoritesSet);
        }
      });
    });

    return notifier;
  },
);

/// StreamProvider for real-time Firestore sync
///
/// **Purpose**: Listens to Firestore changes and updates FavoriteExercisesNotifier
///
/// **Firestore Cost**:
/// - Initial: 1 read (when provider created)
/// - Per update: 1 read (when favorites change in Firestore)
///
/// **Optimization**: Only active when Analytics screen is visible
/// (provider is autoDispose, disposes when screen closes)
///
/// **Usage**: Not meant to be watched directly - used by favoriteExercisesNotifierProvider
final favoriteExercisesStreamProvider = StreamProvider.autoDispose((ref) {
  final repo = ref.watch(exercisePreferencesRepositoryProvider);

  if (repo == null) {
    // User not authenticated - return empty stream
    return Stream.value(null);
  }

  // Stream Firestore updates
  // Cost: 1 read on subscribe + 1 read per update
  return repo.watchPreferences();
});
