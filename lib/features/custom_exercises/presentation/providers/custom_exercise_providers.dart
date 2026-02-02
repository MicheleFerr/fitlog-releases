/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/custom_exercises/presentation/providers
/// 🎯 Feature: custom_exercises
/// 🔧 Type: providers
/// 🌍 Localization: N/A - Provider logic
/// 🎨 Theme: N/A - Provider logic
/// 📱 Platform: Universal
///
/// CUSTOM EXERCISE PROVIDERS
///
/// Riverpod providers for custom exercise feature state management.
/// Follows project patterns from workout/home providers.
///
/// **Provider Hierarchy**:
/// - Repository → Service → State → UI Helper Providers
/// - Auto-dispose providers for temporary state
/// - StreamProviders for reactive updates
/// - FutureProvider.family for individual fetches
///
/// **Usage**:
/// ```dart
/// // In a ConsumerWidget
/// final exercises = ref.watch(activeCustomExercisesProvider);
/// exercises.when(
///   data: (list) => ExerciseList(list),
///   loading: () => LoadingIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/repositories/custom_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/services/custom_exercise_limit_service.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/data/repositories/custom_exercise_repository_impl.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/data/datasources/custom_exercise_local_datasource.dart';
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:fpdart/fpdart.dart' hide State;

// ============================================================================
// INFRASTRUCTURE PROVIDERS
// ============================================================================

/// Local datasource provider (singleton)
///
/// Manages Hive storage for custom exercises.
/// - LazyBox for memory efficiency
/// - User-scoped keys for multi-user support
/// - Corruption recovery built-in
final customExerciseLocalDatasourceProvider = Provider<CustomExerciseLocalDatasource>((ref) {
  return CustomExerciseLocalDatasource();
});

/// Repository provider (singleton)
///
/// Provides access to custom exercise data layer.
/// - Local-first storage with Hive
/// - Optional Firestore sync for Premium users
/// - Conflict resolution (local wins)
///
/// **Pattern**: Same as workoutRepositoryProvider
final customExerciseRepositoryProvider = Provider<CustomExerciseRepository>((ref) {
  final localDatasource = ref.watch(customExerciseLocalDatasourceProvider);
  return CustomExerciseRepositoryImpl(localDatasource: localDatasource);
});

/// Limit service provider
///
/// Business logic for tier-based limits and ad-unlock flow.
/// ✅ FIXED: Uses consolidated tier entitlements (UserTier + AccountTier)
///
/// Limits by tier (XP-based):
/// - Starter (XP 0-99): 3 exercises
/// - Bronze (XP 100-499): 5 exercises
/// - Silver (XP 500-1499): 7 exercises
/// - Gold (XP 1500-4999): 10 exercises
/// - Platinum (XP 5000+): 999 (unlimited)
/// - Premium/Pro (subscription): 999 (unlimited) regardless of XP tier
///
/// **Dependencies**:
/// - Repository for data access
/// - tierEntitlementsProvider for consolidated limits
final customExerciseLimitServiceProvider = Provider<CustomExerciseLimitService>((ref) {
  final repository = ref.watch(customExerciseRepositoryProvider);
  final entitlements = ref.watch(tierEntitlementsProvider);

  return CustomExerciseLimitService(
    repository: repository,
    maxCustomSingleExercises: entitlements.maxCustomSingleExercises,
  );
});

// ============================================================================
// DATA PROVIDERS (Reactive Streams)
// ============================================================================

/// Stream of all active custom exercises
///
/// **Returns**: AsyncValue<List<CustomExercise>>
/// - Filters out expired temporary exercises
/// - Emits on every local/cloud change
/// - Auto-dispose when not in use
///
/// **Use Cases**:
/// - Exercise selector in workout builder
/// - Analytics filtering
/// - Template creation
///
/// **Pattern**: Similar to home_providers.dart micro-providers
final activeCustomExercisesProvider = StreamProvider.autoDispose<List<CustomExercise>>((ref) async* {
  final repository = ref.watch(customExerciseRepositoryProvider);

  await for (final result in repository.watchActive()) {
    final exercises = result.fold(
      (failure) {
        // Log failure but don't throw (keep last good state)
        throw Exception('Failed to load custom exercises: $failure');
      },
      (exercises) => exercises,
    );

    yield exercises;
  }
});

/// Stream of ALL custom exercises (including expired)
///
/// **Returns**: AsyncValue<List<CustomExercise>>
/// - Includes both active and expired exercises
/// - Used for admin/management screens
///
/// **Use Cases**:
/// - Admin screen showing all exercises
/// - Export functionality
/// - Migration tools
final allCustomExercisesProvider = StreamProvider.autoDispose<List<CustomExercise>>((ref) async* {
  final repository = ref.watch(customExerciseRepositoryProvider);

  await for (final result in repository.watchAll()) {
    final exercises = result.fold(
      (failure) {
        throw Exception('Failed to load all custom exercises: $failure');
      },
      (exercises) => exercises,
    );

    yield exercises;
  }
});

// ============================================================================
// INDIVIDUAL FETCH PROVIDERS (Lookup by ID/Name)
// ============================================================================

/// Get single custom exercise by ID
///
/// **Parameters**: String exerciseId
/// **Returns**: AsyncValue<CustomExercise?>
/// - null if not found
/// - auto-dispose when not in use
///
/// **Use Cases**:
/// - Exercise detail screen
/// - Edit exercise modal
/// - Workout history integration
///
/// **Example**:
/// ```dart
/// final exercise = ref.watch(customExerciseByIdProvider('custom_123'));
/// ```
final customExerciseByIdProvider = FutureProvider.autoDispose.family<CustomExercise?, String>(
  (ref, id) async {
    final repository = ref.watch(customExerciseRepositoryProvider);
    final result = await repository.getById(id);

    return result.fold(
      (failure) => null, // Return null on error (fail-safe)
      (exercise) => exercise,
    );
  },
);

/// Find custom exercise by name (for analytics integration)
///
/// **Parameters**: String exerciseName (case-insensitive)
/// **Returns**: AsyncValue<CustomExercise?>
/// - null if not found
/// - auto-dispose when not in use
///
/// **Use Cases**:
/// - Analytics integration (matching workout data)
/// - Duplicate prevention during creation
/// - Exercise replacement flows
///
/// **Example**:
/// ```dart
/// final exercise = ref.watch(customExerciseByNameProvider('My Custom Bench Press'));
/// ```
final customExerciseByNameProvider = FutureProvider.autoDispose.family<CustomExercise?, String>(
  (ref, name) async {
    final repository = ref.watch(customExerciseRepositoryProvider);
    final result = await repository.findByName(name);

    return result.fold(
      (failure) => null, // Return null on error (fail-safe)
      (exercise) => exercise,
    );
  },
);

// ============================================================================
// QUOTA & LIMIT PROVIDERS
// ============================================================================

/// Limit check result for UI display
///
/// **Returns**: AsyncValue<LimitCheckResult>
/// - Current status (available/requiresAd/unlimited)
/// - Remaining permanent slots
/// - Expired exercises count
///
/// **Use Cases**:
/// - Quota indicator in create modal
/// - Premium upsell trigger
/// - Expiry warnings
///
/// **Example**:
/// ```dart
/// final limit = ref.watch(customExerciseLimitProvider);
/// limit.when(
///   data: (result) => QuotaIndicator(result),
///   loading: () => LoadingIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
final customExerciseLimitProvider = FutureProvider.autoDispose<LimitCheckResult>((ref) async {
  final service = ref.watch(customExerciseLimitServiceProvider);
  return service.checkLimits();
});

/// Expired exercises needing renewal
///
/// **Returns**: AsyncValue<List<CustomExercise>>
/// - Exercises where unlockedUntil < now
/// - Empty list if no expired exercises
///
/// **Use Cases**:
/// - Expiry warning modal
/// - Renewal prompt in workout screen
/// - Cleanup utilities
///
/// **Example**:
/// ```dart
/// final expired = ref.watch(expiredExercisesProvider);
/// if (expired.value?.isNotEmpty ?? false) {
///   showExpiryWarning();
/// }
/// ```
final expiredExercisesProvider = FutureProvider.autoDispose<List<CustomExercise>>((ref) async {
  final service = ref.watch(customExerciseLimitServiceProvider);
  return service.getExpiredExercises();
});

/// Count of permanent custom exercises (for UI display)
///
/// **Returns**: AsyncValue<int>
/// - Number of exercises where isPermanent == true
/// - Used for quota display (e.g., "3/5 slots used")
///
/// **Example**:
/// ```dart
/// final count = ref.watch(permanentCountProvider);
/// Text('${count.value ?? 0}/5 permanent slots');
/// ```
final permanentCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.watch(customExerciseRepositoryProvider);
  final result = await repository.getPermanentCount();

  return result.fold(
    (failure) => 0, // Return 0 on error (fail-safe)
    (count) => count,
  );
});

/// Remaining permanent slots for free tier
///
/// **Returns**: AsyncValue<int>
/// - 0-5 for free users
/// - 999 for premium users (unlimited)
///
/// **Example**:
/// ```dart
/// final remaining = ref.watch(remainingSlotsProvider);
/// if (remaining.value == 0) {
///   showPremiumUpsell();
/// }
/// ```
final remainingSlotsProvider = FutureProvider.autoDispose<int>((ref) async {
  final service = ref.watch(customExerciseLimitServiceProvider);
  return service.getRemainingPermanentSlots();
});

// ============================================================================
// HELPER PROVIDERS (Convenience)
// ============================================================================

/// Can user create a permanent exercise?
///
/// **Returns**: AsyncValue<bool>
/// - true if user has free slots OR is premium
/// - false if limit reached
///
/// **Use Cases**:
/// - Disable "Make Permanent" button
/// - Show premium upsell
/// - Validation before save
///
/// **Example**:
/// ```dart
/// final canCreate = ref.watch(canCreatePermanentProvider);
/// if (!canCreate.value ?? false) {
///   showLimitReachedDialog();
/// }
/// ```
final canCreatePermanentProvider = FutureProvider.autoDispose<bool>((ref) async {
  final service = ref.watch(customExerciseLimitServiceProvider);
  return service.canCreatePermanent();
});

/// Does user need to watch ad for next exercise?
///
/// **Returns**: AsyncValue<bool>
/// - true if free user with limit reached
/// - false if premium OR has free slots
///
/// **Use Cases**:
/// - Show ad before creation
/// - Premium upsell trigger
/// - Flow routing in create modal
///
/// **Example**:
/// ```dart
/// final requiresAd = ref.watch(requiresAdProvider);
/// if (requiresAd.value ?? false) {
///   showAdBeforeCreation();
/// }
/// ```
final requiresAdProvider = FutureProvider.autoDispose<bool>((ref) async {
  final service = ref.watch(customExerciseLimitServiceProvider);
  return service.requiresAdForNext();
});

// ============================================================================
// MUTATION METHODS (Use in Widgets/Controllers)
// ============================================================================

/// Custom Exercise Actions
///
/// These are helper methods to be called from widgets/controllers.
/// They use ref.read() instead of ref.watch() to avoid rebuilds.
///
/// **Pattern**: Similar to workout_provider.dart actions
class CustomExerciseActions {
  const CustomExerciseActions._();

  /// Save new custom exercise
  ///
  /// **Parameters**:
  /// - ref: WidgetRef or ProviderRef
  /// - exercise: The custom exercise to save
  ///
  /// **Returns**: Future<Either<Failure, void>>
  /// - Left: Failure (LimitExceededFailure, ValidationFailure, etc.)
  /// - Right: void (success)
  ///
  /// **Example**:
  /// ```dart
  /// final result = await CustomExerciseActions.save(ref, newExercise);
  /// result.fold(
  ///   (failure) => showError(failure),
  ///   (_) => showSuccess('Created successfully'),
  /// );
  /// ```
  static Future<Either<Failure, void>> save(
    Ref ref,
    CustomExercise exercise,
  ) async {
    final repository = ref.read(customExerciseRepositoryProvider);
    return repository.save(exercise);
  }

  /// Update existing exercise
  ///
  /// **Parameters**:
  /// - ref: WidgetRef or ProviderRef
  /// - exercise: The custom exercise with updated values
  ///
  /// **Returns**: Future<Either<Failure, void>>
  ///
  /// **Example**:
  /// ```dart
  /// final updated = existingExercise.copyWith(notes: 'New notes');
  /// await CustomExerciseActions.update(ref, updated);
  /// ```
  static Future<Either<Failure, void>> update(
    Ref ref,
    CustomExercise exercise,
  ) async {
    final repository = ref.read(customExerciseRepositoryProvider);
    return repository.update(exercise);
  }

  /// Delete exercise
  ///
  /// **Parameters**:
  /// - ref: WidgetRef or ProviderRef
  /// - id: ID of the custom exercise to delete
  ///
  /// **Returns**: Future<Either<Failure, void>>
  ///
  /// **Example**:
  /// ```dart
  /// await CustomExerciseActions.delete(ref, 'custom_123');
  /// ```
  static Future<Either<Failure, void>> delete(
    Ref ref,
    String id,
  ) async {
    final repository = ref.read(customExerciseRepositoryProvider);
    return repository.delete(id);
  }

  /// Extend temporary unlock by N days (default 7)
  ///
  /// **Parameters**:
  /// - ref: WidgetRef or ProviderRef
  /// - id: ID of the custom exercise to extend
  /// - days: Number of days to extend (default: 7)
  ///
  /// **Returns**: Future<Either<Failure, void>>
  ///
  /// **Example**:
  /// ```dart
  /// // Extend by default 7 days
  /// await CustomExerciseActions.extendUnlock(ref, 'custom_123');
  ///
  /// // Extend by custom duration
  /// await CustomExerciseActions.extendUnlock(ref, 'custom_123', days: 14);
  /// ```
  static Future<Either<Failure, void>> extendUnlock(
    Ref ref,
    String id, {
    int days = 7,
  }) async {
    final repository = ref.read(customExerciseRepositoryProvider);
    return repository.extendUnlock(id, days: days);
  }

  /// Prepare exercise for save with appropriate unlock status
  ///
  /// Business logic:
  /// - Premium users: always permanent (unlockedUntil = null)
  /// - Free users with slots: permanent (unlockedUntil = null)
  /// - Free users without slots: temporary 7-day unlock
  ///
  /// **Parameters**:
  /// - ref: WidgetRef or ProviderRef
  /// - exercise: The custom exercise to prepare
  ///
  /// **Returns**: Future<CustomExercise>
  /// - Exercise with correct unlockedUntil field
  ///
  /// **Example**:
  /// ```dart
  /// final prepared = await CustomExerciseActions.prepareForSave(ref, newExercise);
  /// await CustomExerciseActions.save(ref, prepared);
  /// ```
  static Future<CustomExercise> prepareForSave(
    Ref ref,
    CustomExercise exercise,
  ) async {
    final service = ref.read(customExerciseLimitServiceProvider);
    return service.prepareExerciseForSave(exercise);
  }

  /// Handle ad completion - extend or convert to permanent
  ///
  /// **Parameters**:
  /// - ref: WidgetRef or ProviderRef
  /// - exerciseId: ID of the exercise that was unlocked
  ///
  /// **Behavior**:
  /// - If user now has free slots: converts to permanent
  /// - Otherwise: extends temporary unlock by 7 days
  ///
  /// **Example**:
  /// ```dart
  /// // After user watches ad
  /// await CustomExerciseActions.onAdWatched(ref, 'custom_123');
  /// ```
  static Future<void> onAdWatched(
    Ref ref,
    String exerciseId,
  ) async {
    final service = ref.read(customExerciseLimitServiceProvider);
    return service.onAdWatched(exerciseId);
  }

  /// Sync with cloud (Premium only)
  ///
  /// **Returns**: Future<Either<Failure, void>>
  /// - Left: Failure (NetworkFailure, ServerFailure, NotPremiumFailure)
  /// - Right: void (success)
  ///
  /// **Example**:
  /// ```dart
  /// final result = await CustomExerciseActions.syncToCloud(ref);
  /// result.fold(
  ///   (failure) => showError('Sync failed'),
  ///   (_) => showSuccess('Synced successfully'),
  /// );
  /// ```
  static Future<Either<Failure, void>> syncToCloud(Ref ref) async {
    final repository = ref.read(customExerciseRepositoryProvider);
    return repository.syncToCloud();
  }

  /// Force refresh from cloud
  ///
  /// **Returns**: Future<Either<Failure, void>>
  /// - Left: Failure (NetworkFailure, ServerFailure, NotPremiumFailure)
  /// - Right: void (success)
  ///
  /// **Example**:
  /// ```dart
  /// await CustomExerciseActions.refreshFromCloud(ref);
  /// ```
  static Future<Either<Failure, void>> refreshFromCloud(Ref ref) async {
    final repository = ref.read(customExerciseRepositoryProvider);
    return repository.refreshFromCloud();
  }
}
