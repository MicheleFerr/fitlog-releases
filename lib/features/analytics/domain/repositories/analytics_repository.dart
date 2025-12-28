/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/repositories
/// 🎯 Feature: analytics
/// 🔧 Type: repository interface
///
/// Analytics Repository Interface - Contract for analytics data operations
///
/// **Responsibilities**:
/// - Fetch exercise history with real-time sync
/// - Filter sessions by timeframe
/// - Search exercises by name
/// - Handle offline/online states
///
/// **Implementation Note**:
/// - Data layer provides concrete implementation with Firestore + Hive
/// - Uses Stream for real-time updates
/// - Returns Either<Failure, T> for error handling
///
/// **Usage**:
/// ```dart
/// class AnalyticsRepositoryImpl implements AnalyticsRepository {
///   @override
///   Stream<Either<Failure, List<ExerciseHistory>>> getExerciseHistory(String userId) {
///     // Firestore implementation...
///   }
/// }
/// ```
library;

import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

/// Analytics repository interface
///
/// Defines contract for fetching and managing exercise analytics data
abstract class AnalyticsRepository {
  /// Get all exercise history for a user with real-time sync
  ///
  /// **Returns**: Stream of Either<Failure, List<ExerciseHistory>>
  /// - Stream emits updates whenever Firestore data changes
  /// - Left: Failure (NetworkFailure, CacheFailure, etc.)
  /// - Right: List of all exercises with their complete history
  ///
  /// **Caching Strategy**:
  /// - First emit: Cached data (if available, offline support)
  /// - Subsequent emits: Real-time Firestore updates
  ///
  /// **Example**:
  /// ```dart
  /// repository.getExerciseHistory(userId).listen((result) {
  ///   result.fold(
  ///     (failure) => print('Error: $failure'),
  ///     (exercises) => print('Loaded ${exercises.length} exercises'),
  ///   );
  /// });
  /// ```
  Stream<Either<Failure, List<ExerciseHistory>>> getExerciseHistory(
    String userId,
  );

  /// Get sessions for a specific exercise within a timeframe
  ///
  /// **Parameters**:
  /// - userId: User identifier
  /// - exerciseName: Name of the exercise (e.g., "Bench Press")
  /// - start: Start date of timeframe
  /// - end: End date of timeframe
  ///
  /// **Returns**: Future<Either<Failure, List<ExerciseSession>>>
  /// - Left: Failure if query fails
  /// - Right: List of sessions in the specified timeframe
  ///
  /// **Use Cases**:
  /// - Weekly volume comparison
  /// - Monthly progression analysis
  /// - Custom date range reports
  ///
  /// **Example**:
  /// ```dart
  /// final lastWeek = DateTime.now().subtract(Duration(days: 7));
  /// final sessions = await repository.getSessionsByTimeframe(
  ///   userId: 'user123',
  ///   exerciseName: 'Bench Press',
  ///   start: lastWeek,
  ///   end: DateTime.now(),
  /// );
  /// ```
  Future<Either<Failure, List<ExerciseSession>>> getSessionsByTimeframe({
    required String userId,
    required String exerciseName,
    required DateTime start,
    required DateTime end,
  });

  /// Search exercises by name (fuzzy search)
  ///
  /// **Parameters**:
  /// - userId: User identifier
  /// - query: Search query (case-insensitive, supports partial matches)
  ///
  /// **Returns**: Future<Either<Failure, List<ExerciseHistory>>>
  /// - Left: Failure if search fails
  /// - Right: List of exercises matching the query
  ///
  /// **Search Logic**:
  /// - Case-insensitive
  /// - Partial matches (e.g., "bench" matches "Bench Press")
  /// - Results sorted by relevance (exact matches first)
  ///
  /// **Example**:
  /// ```dart
  /// // Search for "bench"
  /// final results = await repository.searchExercises(
  ///   userId: 'user123',
  ///   query: 'bench',
  /// );
  /// // Returns: ["Bench Press", "Incline Bench Press", "Dumbbell Bench"]
  /// ```
  Future<Either<Failure, List<ExerciseHistory>>> searchExercises({
    required String userId,
    required String query,
  });

  /// Get exercise history for a specific exercise
  ///
  /// **Parameters**:
  /// - userId: User identifier
  /// - exerciseName: Exact name of the exercise
  ///
  /// **Returns**: Future<Either<Failure, ExerciseHistory>>
  /// - Left: Failure if exercise not found or query fails
  /// - Right: Complete history for the exercise
  ///
  /// **Example**:
  /// ```dart
  /// final history = await repository.getExerciseHistoryByName(
  ///   userId: 'user123',
  ///   exerciseName: 'Bench Press',
  /// );
  /// ```
  Future<Either<Failure, ExerciseHistory>> getExerciseHistoryByName({
    required String userId,
    required String exerciseName,
  });

  /// Clear local cache for analytics data
  ///
  /// **Use Cases**:
  /// - Force refresh from Firestore
  /// - Clear stale data
  /// - Reset after sync issues
  ///
  /// **Returns**: Future<Either<Failure, void>>
  /// - Left: Failure if cache clear fails
  /// - Right: void (success)
  Future<Either<Failure, void>> clearCache();

  /// Check if local cache is valid for a user
  ///
  /// **Logic**:
  /// - Cache valid if updated within last 5 minutes
  /// - Cache invalid if older or missing
  ///
  /// **Returns**: Future<bool>
  /// - true: Cache is valid, can use cached data
  /// - false: Cache is stale, should fetch from Firestore
  Future<bool> isCacheValid(String userId);

  /// Update exercise history with new session (write-through strategy)
  ///
  /// **Purpose**: Add new workout session to exercise history
  ///
  /// **Parameters**:
  /// - userId: User identifier
  /// - exerciseId: Unique database ID for the exercise
  /// - exerciseName: Name of the exercise
  /// - muscleGroup: Muscle group category (chest, back, legs, etc.)
  /// - session: New exercise session with sets
  ///
  /// **Behavior**:
  /// - If exercise exists: Append session to existing history
  /// - If exercise doesn't exist: Create new history document
  /// - Updates Firestore immediately
  /// - Invalidates local cache for the exercise
  ///
  /// **Returns**: Future<Either<Failure, void>>
  /// - Left: Failure if update fails
  /// - Right: void (success)
  ///
  /// **Example**:
  /// ```dart
  /// final session = ExerciseSession(
  ///   exerciseName: 'Bench Press',
  ///   muscleGroup: 'chest',
  ///   sets: [AnalyticsSet(weight: 100, reps: 8, date: DateTime.now())],
  ///   date: DateTime.now(),
  /// );
  /// await repository.updateExerciseHistory(
  ///   userId: 'user123',
  ///   exerciseId: 'bench_press_001',
  ///   exerciseName: 'Bench Press',
  ///   muscleGroup: 'chest',
  ///   session: session,
  /// );
  /// ```
  Future<Either<Failure, void>> updateExerciseHistory({
    required String userId,
    required String exerciseId,
    required String exerciseName,
    required String muscleGroup,
    required ExerciseSession session,
  });
}
