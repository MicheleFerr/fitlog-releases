/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/usecases
/// 🎯 Feature: workout
/// 🔧 Type: usecase
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Domain entities
/// - Repository interface
/// - Shared failures
library;

import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';

/// Use case for completing workouts with comprehensive business logic
class CompleteWorkoutUseCase {
  const CompleteWorkoutUseCase(this._repository);
  final WorkoutRepository _repository;

  /// Complete workout with validation and post-completion processing
  Future<Either<Failure, CompleteWorkoutResult>> call(
    CompleteWorkoutParams params,
  ) async {
    // Validate workout can be completed
    final validationResult = _validateWorkoutCompletion(params.workout);
    if (validationResult != null) {
      return left(validationResult);
    }

    try {
      // Prepare workout for completion
      final completedWorkout = _prepareWorkoutForCompletion(params.workout);

      // Save completed workout
      final saveResult = await _repository.saveWorkout(completedWorkout);
      if (saveResult.isLeft) {
        return Left(saveResult.leftOrNull!);
      }

      // Save as exercise activities if required
      List<String> activityIds = [];
      if (params.saveAsActivities) {
        final activitiesResult = await _repository.saveCompletedWorkout(
          workout: completedWorkout,
          userEmail: params.userEmail,
        );

        if (activitiesResult.isLeft) {
          return Left(activitiesResult.leftOrNull!);
        }

        activityIds = activitiesResult.rightOrNull!;
      }

      // Calculate completion statistics
      final stats = _calculateWorkoutStats(completedWorkout);

      return Right(
        CompleteWorkoutResult(
          workoutId: saveResult.rightOrNull!,
          completedWorkout: completedWorkout,
          activityIds: activityIds,
          stats: stats,
        ),
      );
    } catch (e) {
      return left(UnexpectedFailure('Failed to complete workout: $e'));
    }
  }

  /// Validate workout can be completed
  ValidationFailure? _validateWorkoutCompletion(Workout workout) {
    // Workout must be in progress
    if (workout.status != WorkoutStatus.inProgress) {
      return const ValidationFailure(
        'Only workouts in progress can be completed',
        code: 'invalid_workout_status',
      );
    }

    // Workout must have been started
    if (workout.startTime == null) {
      return const ValidationFailure(
        'Workout must be started before it can be completed',
        code: 'workout_not_started',
      );
    }

    // Workout must have exercises
    if (workout.exercises.isEmpty) {
      return const ValidationFailure(
        'Cannot complete workout without exercises',
        code: 'no_exercises',
      );
    }

    // At least one set must be completed
    if (workout.completedSets == 0) {
      return const ValidationFailure(
        'Cannot complete workout without any completed sets',
        code: 'no_completed_sets',
      );
    }

    // Minimum workout duration check (prevent accidental completion)
    final duration = workout.duration;
    if (duration != null && duration.inSeconds < 30) {
      return const ValidationFailure(
        'Workout must be at least 30 seconds long',
        code: 'workout_too_short',
      );
    }

    return null;
  }

  /// Prepare workout for completion with business logic
  Workout _prepareWorkoutForCompletion(Workout workout) {
    final now = DateTime.now();

    // Mark workout as completed
    final result = workout.copyWith(
      status: WorkoutStatus.completed,
      endTime: now,
      updatedAt: now,
    );

    // ✅ Note: isCompleted, totalVolume, and completedAt are computed getters in Exercise
    // They are automatically calculated from the completed sets, so no need to explicitly set them
    // Just return the workout as-is, the getters will compute the values on-the-fly
    return result;
  }

  /// Calculate comprehensive workout statistics
  WorkoutCompletionStats _calculateWorkoutStats(Workout workout) {
    final duration = workout.duration ?? Duration.zero;
    final totalSets = workout.totalSets;
    final completedSets = workout.completedSets;
    final completionRate = totalSets > 0 ? completedSets / totalSets : 0.0;

    // Calculate total volume
    double totalVolume = 0.0;
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        if (set.isCompleted) {
          totalVolume += set.volume;
        }
      }
    }

    // Calculate average rest time
    Duration totalRestTime = Duration.zero;
    int restTimeCount = 0;
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        if (set.restTime != null) {
          totalRestTime += Duration(seconds: set.restTime!);
          restTimeCount++;
        }
      }
    }

    final averageRestTime = restTimeCount > 0
        ? Duration(seconds: totalRestTime.inSeconds ~/ restTimeCount)
        : Duration.zero;

    // Group exercises by category
    final exercisesByCategory = <ExerciseCategory, int>{};
    for (final exercise in workout.exercises) {
      exercisesByCategory[exercise.category] =
          (exercisesByCategory[exercise.category] ?? 0) + 1;
    }

    // Calculate intensity (average RPE)
    double totalRpe = 0.0;
    int rpeCount = 0;
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        if (set.isCompleted && set.rpe != null) {
          totalRpe += set.rpe!;
          rpeCount++;
        }
      }
    }

    final averageRpe = rpeCount > 0 ? totalRpe / rpeCount : null;

    return WorkoutCompletionStats(
      duration: duration,
      totalVolume: totalVolume,
      completedSets: completedSets,
      completionRate: completionRate,
      averageRestTime: averageRestTime,
      exercisesByCategory: exercisesByCategory,
      averageRpe: averageRpe,
    );
  }
}

/// Parameters for CompleteWorkoutUseCase
class CompleteWorkoutParams {
  const CompleteWorkoutParams({
    required this.workout,
    required this.userEmail,
    this.saveAsActivities = true,
  });
  final Workout workout;
  final String userEmail;
  final bool saveAsActivities;
}

/// Result of completing a workout
class CompleteWorkoutResult {
  const CompleteWorkoutResult({
    required this.workoutId,
    required this.completedWorkout,
    required this.activityIds,
    required this.stats,
  });
  final String workoutId;
  final Workout completedWorkout;
  final List<String> activityIds;
  final WorkoutCompletionStats stats;
}

/// Workout completion statistics
class WorkoutCompletionStats {
  const WorkoutCompletionStats({
    required this.duration,
    required this.totalVolume,
    required this.completedSets,
    required this.completionRate,
    required this.averageRestTime,
    required this.exercisesByCategory,
    this.averageRpe,
  });
  final Duration duration;
  final double totalVolume;
  final int completedSets;
  final double completionRate;
  final Duration averageRestTime;
  final Map<ExerciseCategory, int> exercisesByCategory;
  final double? averageRpe;
}
