/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/repositories
/// 🎯 Feature: workout
/// 🔧 Type: repository_interface
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Domain entities only
/// - Shared failures
/// - Either type
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/paginated_result.dart';

/// Abstract repository interface for workout data operations
/// This defines the contract that data layer must implement
abstract class WorkoutRepository {
  /// Save a workout to persistent storage
  Future<Either<Failure, String>> saveWorkout(Workout workout);

  /// Update an existing workout
  Future<Either<Failure, void>> updateWorkout(Workout workout);

  /// Get a workout by ID
  Future<Either<Failure, Workout>> getWorkout(String workoutId);

  /// Get all workouts for current user
  Future<Either<Failure, List<Workout>>> getWorkouts({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Delete a workout
  Future<Either<Failure, void>> deleteWorkout(String workoutId);

  /// Save completed workout as exercise activities
  Future<Either<Failure, List<String>>> saveCompletedWorkout({
    required Workout workout,
    required String userEmail,
  });

  /// Update a specific exercise set within a workout
  Future<Either<Failure, void>> updateExerciseSet({
    required String workoutId,
    required String exerciseId,
    required ExerciseSet exerciseSet,
  });

  /// Add exercise to existing workout
  Future<Either<Failure, void>> addExerciseToWorkout({
    required String workoutId,
    required Exercise exercise,
  });

  /// Remove exercise from workout
  Future<Either<Failure, void>> removeExerciseFromWorkout({
    required String workoutId,
    required String exerciseId,
  });

  /// Get workout statistics for analytics
  Future<Either<Failure, WorkoutStats>> getWorkoutStats({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Stream of active workout changes (for real-time updates)
  Stream<Either<Failure, Workout?>> watchActiveWorkout();

  /// Get user's workout history with pagination
  Future<Either<Failure, WorkoutHistory>> getWorkoutHistory({
    int page = 1,
    int limit = 10,
  });

  /// Get last completed workout for user
  ///
  /// Returns the most recent workout with endTime != null (completed).
  /// Returns null if no completed workouts found.
  Future<Workout?> getLastCompletedWorkout(String userId);

  /// Get workouts with cursor-based pagination (infinite scroll optimized)
  ///
  /// Uses Firestore's startAfterDocument for efficient cursor-based pagination.
  /// This is the recommended method for infinite scroll UI patterns.
  ///
  /// [pageSize] - Number of items per page (default: 20)
  /// [startAfter] - Document snapshot cursor from previous page (null for first page)
  /// [dateFrom] - Optional filter for workouts after this date
  /// [dateTo] - Optional filter for workouts before this date
  /// [status] - Optional filter by workout status (e.g., 'completed', 'inProgress')
  ///
  /// Returns [PaginatedResult<Workout>] containing:
  /// - items: List of workouts for this page
  /// - hasMore: Whether more pages are available
  /// - lastDocument: Cursor for the next page
  ///
  /// Example usage:
  /// ```dart
  /// // First page
  /// final firstPage = await repo.getWorkoutsPaginated(pageSize: 20);
  ///
  /// // Next page (use cursor from previous result)
  /// final nextPage = await repo.getWorkoutsPaginated(
  ///   pageSize: 20,
  ///   startAfter: firstPage.lastDocument,
  /// );
  /// ```
  Future<Either<Failure, PaginatedResult<Workout>>> getWorkoutsPaginated({
    int pageSize = 20,
    DocumentSnapshot? startAfter,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
  });
}

/// Value objects for repository operations
class WorkoutStats {
  const WorkoutStats({
    required this.totalWorkouts,
    required this.totalExercises,
    required this.totalSets,
    required this.totalDuration,
    required this.averageWorkoutDuration,
    required this.exercisesByCategory,
    this.lastWorkoutDate,
  });
  final int totalWorkouts;
  final int totalExercises;
  final int totalSets;
  final Duration totalDuration;
  final double averageWorkoutDuration;
  final Map<ExerciseCategory, int> exercisesByCategory;
  final DateTime? lastWorkoutDate;
}

class WorkoutHistory {
  const WorkoutHistory({
    required this.workouts,
    required this.totalCount,
    required this.hasMore,
    required this.currentPage,
  });
  final List<Workout> workouts;
  final int totalCount;
  final bool hasMore;
  final int currentPage;
}
