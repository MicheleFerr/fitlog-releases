/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: domain/repositories
 * 🎯 Feature: workout
 * 🔧 Type: repository_interface
 * 🌍 Localization: N/A
 * 🎨 Theme: N/A
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Domain entities only
 * - Shared failures
 * - Either type
 */

import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import '../entities/workout.dart';
import '../entities/exercise.dart';

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
}

/// Value objects for repository operations
class WorkoutStats {
  final int totalWorkouts;
  final int totalExercises;
  final int totalSets;
  final Duration totalDuration;
  final double averageWorkoutDuration;
  final Map<ExerciseCategory, int> exercisesByCategory;
  final DateTime? lastWorkoutDate;
  
  const WorkoutStats({
    required this.totalWorkouts,
    required this.totalExercises,
    required this.totalSets,
    required this.totalDuration,
    required this.averageWorkoutDuration,
    required this.exercisesByCategory,
    this.lastWorkoutDate,
  });
}

class WorkoutHistory {
  final List<Workout> workouts;
  final int totalCount;
  final bool hasMore;
  final int currentPage;
  
  const WorkoutHistory({
    required this.workouts,
    required this.totalCount,
    required this.hasMore,
    required this.currentPage,
  });
}