/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/custom_exercises/domain/repositories
/// 🎯 Feature: custom_exercises
/// 🔧 Type: repository_interface
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// CUSTOM EXERCISE REPOSITORY INTERFACE
///
/// Manages user-created exercise variants with categorization.
/// Supports both local (Hive) and cloud (Firestore) storage.
///
/// **Responsibilities**:
/// - CRUD operations for custom exercises
/// - Permanent vs temporary unlock management
/// - Free tier limit enforcement (5 exercises)
/// - Premium sync to Firestore
/// - Real-time streams for reactive UI
///
/// **Free Tier Limits**:
/// - Max 5 permanent custom exercises
/// - Unlimited temporary unlocks (7-day expiry)
/// - Can extend temporary unlocks before expiry
///
/// **Premium Benefits**:
/// - Unlimited permanent custom exercises
/// - Cloud sync across devices
/// - No expiration on any exercises
///
/// **Implementation Note**:
/// - Data layer provides concrete implementation with Hive + Firestore
/// - Uses Stream for real-time updates
/// - Returns Either<Failure, T> for error handling
///
/// **Usage**:
/// ```dart
/// class CustomExerciseRepositoryImpl implements CustomExerciseRepository {
///   @override
///   Future<Either<Failure, List<CustomExercise>>> getActive() async {
///     // Filter out expired exercises...
///   }
/// }
/// ```
library;

import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

/// Custom Exercise Repository Interface
///
/// Defines contract for managing user-created exercise variants
abstract class CustomExerciseRepository {
  // === READ OPERATIONS ===

  /// Get all custom exercises (active + expired)
  ///
  /// **Returns**: Either<Failure, List<CustomExercise>>
  /// - Left: Failure (CacheFailure, ServerFailure, etc.)
  /// - Right: Complete list including expired exercises
  ///
  /// **Use Cases**:
  /// - Admin view to see all exercises
  /// - Migration/export functionality
  /// - Analytics on expired exercises
  ///
  /// **Example**:
  /// ```dart
  /// final result = await repository.getAll();
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (exercises) => print('Total: ${exercises.length}'),
  /// );
  /// ```
  Future<Either<Failure, List<CustomExercise>>> getAll();

  /// Get only active (non-expired) exercises
  ///
  /// **Returns**: Either<Failure, List<CustomExercise>>
  /// - Left: Failure if query fails
  /// - Right: List of exercises where isActive == true
  ///
  /// **Filtering Logic**:
  /// - Permanent exercises: Always included
  /// - Temporary exercises: Only if expiresAt > DateTime.now()
  ///
  /// **Use Cases**:
  /// - Exercise selection in workout builder
  /// - Analytics filtering
  /// - Template creation
  ///
  /// **Example**:
  /// ```dart
  /// final result = await repository.getActive();
  /// result.fold(
  ///   (failure) => showError(failure),
  ///   (exercises) => displayInSelector(exercises),
  /// );
  /// ```
  Future<Either<Failure, List<CustomExercise>>> getActive();

  /// Get a specific custom exercise by ID
  ///
  /// **Parameters**:
  /// - id: Unique identifier of the custom exercise
  ///
  /// **Returns**: Either<Failure, CustomExercise?>
  /// - Left: Failure if query fails
  /// - Right: The exercise if found, null if not found
  ///
  /// **Example**:
  /// ```dart
  /// final result = await repository.getById('custom_123');
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (exercise) => exercise != null
  ///     ? print('Found: ${exercise.name}')
  ///     : print('Not found'),
  /// );
  /// ```
  Future<Either<Failure, CustomExercise?>> getById(String id);

  /// Find custom exercise by name (for analytics integration)
  ///
  /// **Parameters**:
  /// - exerciseName: Name to search for (case-insensitive)
  ///
  /// **Returns**: Either<Failure, CustomExercise?>
  /// - Left: Failure if query fails
  /// - Right: The exercise if found, null if not found
  ///
  /// **Search Logic**:
  /// - Case-insensitive exact match
  /// - Matches against CustomExercise.name field
  ///
  /// **Use Cases**:
  /// - Analytics integration (matching workout data to custom exercises)
  /// - Duplicate prevention during creation
  /// - Exercise replacement flows
  ///
  /// **Example**:
  /// ```dart
  /// final result = await repository.findByName('My Custom Bench Press');
  /// result.fold(
  ///   (failure) => null,
  ///   (exercise) => exercise, // Use for analytics
  /// );
  /// ```
  Future<Either<Failure, CustomExercise?>> findByName(String exerciseName);

  // === QUOTA CHECKING ===

  /// Get count of permanent slots used (for limit checking)
  ///
  /// **Returns**: Either<Failure, int>
  /// - Left: Failure if query fails
  /// - Right: Count of exercises where isPermanent == true
  ///
  /// **Free Tier Limit**: 5 permanent exercises
  ///
  /// **Use Cases**:
  /// - UI display of quota (e.g., "3/5 slots used")
  /// - Validation before creating new permanent exercise
  /// - Premium upsell trigger
  ///
  /// **Example**:
  /// ```dart
  /// final result = await repository.getPermanentCount();
  /// result.fold(
  ///   (failure) => 0,
  ///   (count) => count, // Display in UI
  /// );
  /// ```
  Future<Either<Failure, int>> getPermanentCount();

  /// Note: hasReachedFreeLimit() removed.
  ///
  /// **Migration**: Use CustomExerciseLimitService instead for quota checks.
  /// Service provides tier-based limits (3/5/7/10/999) with consolidated
  /// AccountTier support (Premium/Pro = unlimited).
  ///
  /// **Example**:
  /// ```dart
  /// final limitService = ref.watch(customExerciseLimitServiceProvider);
  /// final canCreate = await limitService.canCreatePermanent();
  /// final requiresAd = await limitService.requiresAdForNext();
  /// ```

  // === WRITE OPERATIONS ===

  /// Save new custom exercise
  ///
  /// **Parameters**:
  /// - exercise: The custom exercise to save
  ///
  /// **Behavior**:
  /// - Validates free tier limits before saving
  /// - Saves to Hive (local storage)
  /// - If premium user: Also saves to Firestore
  ///
  /// **Validation**:
  /// - If isPermanent && free user && count >= 5: Returns Failure
  /// - If temporary: Always allowed (no limit)
  ///
  /// **Returns**: Either<Failure, void>
  /// - Left: Failure (LimitExceededFailure, ValidationFailure, etc.)
  /// - Right: void (success)
  ///
  /// **Example**:
  /// ```dart
  /// final newExercise = CustomExercise(
  ///   id: 'custom_${uuid.v4()}',
  ///   name: 'My Bench Press Variant',
  ///   baseExerciseId: 'bench_press_barbell',
  ///   isPermanent: false, // Temporary unlock
  ///   createdAt: DateTime.now(),
  /// );
  /// final result = await repository.save(newExercise);
  /// result.fold(
  ///   (failure) => showError(failure),
  ///   (_) => showSuccess('Created successfully'),
  /// );
  /// ```
  Future<Either<Failure, void>> save(CustomExercise exercise);

  /// Update existing exercise
  ///
  /// **Parameters**:
  /// - exercise: The custom exercise with updated values
  ///
  /// **Behavior**:
  /// - Updates local Hive storage
  /// - If premium user: Syncs to Firestore
  ///
  /// **Validation**:
  /// - Exercise must exist (by ID)
  /// - Cannot change isPermanent from true to false
  /// - Cannot change isPermanent from false to true if limit reached
  ///
  /// **Returns**: Either<Failure, void>
  /// - Left: Failure (NotFoundFailure, ValidationFailure, etc.)
  /// - Right: void (success)
  ///
  /// **Example**:
  /// ```dart
  /// final updated = existingExercise.copyWith(
  ///   notes: 'Updated notes',
  /// );
  /// final result = await repository.update(updated);
  /// ```
  Future<Either<Failure, void>> update(CustomExercise exercise);

  /// Delete exercise
  ///
  /// **Parameters**:
  /// - id: ID of the custom exercise to delete
  ///
  /// **Behavior**:
  /// - Removes from local Hive storage
  /// - If premium user: Removes from Firestore
  /// - Does NOT delete associated workout data
  ///
  /// **Returns**: Either<Failure, void>
  /// - Left: Failure (NotFoundFailure, ServerFailure, etc.)
  /// - Right: void (success)
  ///
  /// **Example**:
  /// ```dart
  /// final result = await repository.delete('custom_123');
  /// result.fold(
  ///   (failure) => showError(failure),
  ///   (_) => showSuccess('Deleted successfully'),
  /// );
  /// ```
  Future<Either<Failure, void>> delete(String id);

  /// Extend temporary unlock by N days (default 7)
  ///
  /// **Parameters**:
  /// - id: ID of the custom exercise to extend
  /// - days: Number of days to extend (default: 7)
  ///
  /// **Behavior**:
  /// - Can only extend temporary exercises (isPermanent == false)
  /// - Adds N days to current expiresAt date
  /// - If already expired: Sets expiresAt to now + N days
  ///
  /// **Use Cases**:
  /// - "Extend for 7 more days" button in expiry warning
  /// - Auto-extend when user completes workout with exercise
  /// - Premium users can extend indefinitely
  ///
  /// **Returns**: Either<Failure, void>
  /// - Left: Failure (NotFoundFailure, ValidationFailure if permanent)
  /// - Right: void (success)
  ///
  /// **Example**:
  /// ```dart
  /// // Extend by default 7 days
  /// await repository.extendUnlock('custom_123');
  ///
  /// // Extend by custom duration
  /// await repository.extendUnlock('custom_123', days: 14);
  /// ```
  Future<Either<Failure, void>> extendUnlock(String id, {int days = 7});

  // === REACTIVE STREAMS ===

  /// Watch all custom exercises (reactive stream)
  ///
  /// **Returns**: Stream<Either<Failure, List<CustomExercise>>>
  /// - Stream emits updates whenever data changes
  /// - Left: Failure if stream encounters error
  /// - Right: Updated list of all exercises
  ///
  /// **Behavior**:
  /// - Emits immediately with current data
  /// - Emits on every local change (add/update/delete)
  /// - If premium: Also emits on Firestore changes
  ///
  /// **Use Cases**:
  /// - Admin screen showing all exercises
  /// - Export functionality
  /// - Migration tools
  ///
  /// **Example**:
  /// ```dart
  /// repository.watchAll().listen((result) {
  ///   result.fold(
  ///     (failure) => showError(failure),
  ///     (exercises) => updateUI(exercises),
  ///   );
  /// });
  /// ```
  Stream<Either<Failure, List<CustomExercise>>> watchAll();

  /// Watch active exercises only
  ///
  /// **Returns**: Stream<Either<Failure, List<CustomExercise>>>
  /// - Stream emits updates when active exercises change
  /// - Left: Failure if stream encounters error
  /// - Right: Updated list of active exercises only
  ///
  /// **Filtering**:
  /// - Same logic as getActive()
  /// - Re-filters on every emission
  /// - Expired exercises automatically removed from stream
  ///
  /// **Use Cases**:
  /// - Exercise selector in workout builder
  /// - Template creation UI
  /// - Analytics filtering
  ///
  /// **Example**:
  /// ```dart
  /// repository.watchActive().listen((result) {
  ///   result.fold(
  ///     (failure) => showError(failure),
  ///     (activeExercises) => displayInSelector(activeExercises),
  ///   );
  /// });
  /// ```
  Stream<Either<Failure, List<CustomExercise>>> watchActive();

  // === CLOUD SYNC (Premium Only) ===

  /// Sync with cloud (Premium only)
  ///
  /// **Behavior**:
  /// - Pushes local Hive data to Firestore
  /// - Resolves conflicts (server wins)
  /// - No-op if not premium user
  ///
  /// **Use Cases**:
  /// - Manual sync button
  /// - After upgrading to premium
  /// - Recovery after offline period
  ///
  /// **Returns**: Either<Failure, void>
  /// - Left: Failure (NetworkFailure, ServerFailure, NotPremiumFailure)
  /// - Right: void (success)
  ///
  /// **Example**:
  /// ```dart
  /// final result = await repository.syncToCloud();
  /// result.fold(
  ///   (failure) => showError('Sync failed: $failure'),
  ///   (_) => showSuccess('Synced to cloud'),
  /// );
  /// ```
  Future<Either<Failure, void>> syncToCloud();

  /// Force refresh from cloud
  ///
  /// **Behavior**:
  /// - Pulls latest data from Firestore
  /// - Overwrites local Hive data (server wins)
  /// - No-op if not premium user
  ///
  /// **Use Cases**:
  /// - Manual refresh button
  /// - After logging in on new device
  /// - Resolving sync conflicts
  ///
  /// **Returns**: Either<Failure, void>
  /// - Left: Failure (NetworkFailure, ServerFailure, NotPremiumFailure)
  /// - Right: void (success)
  ///
  /// **Example**:
  /// ```dart
  /// final result = await repository.refreshFromCloud();
  /// result.fold(
  ///   (failure) => showError('Refresh failed: $failure'),
  ///   (_) => showSuccess('Refreshed from cloud'),
  /// );
  /// ```
  Future<Either<Failure, void>> refreshFromCloud();
}
