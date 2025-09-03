/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: domain/usecases
 * 🎯 Feature: workout
 * 🔧 Type: usecase
 * 🌍 Localization: N/A
 * 🎨 Theme: N/A
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Domain entities
 * - Repository interface
 * - Shared failures
 */

import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';

/// Use case for completing workouts with comprehensive business logic
class CompleteWorkoutUseCase {
  final WorkoutRepository _repository;
  
  const CompleteWorkoutUseCase(this._repository);
  
  /// Complete workout with validation and post-completion processing
  Future<Either<Failure, CompleteWorkoutResult>> call(CompleteWorkoutParams params) async {
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
      
      return Right(CompleteWorkoutResult(
        workoutId: saveResult.rightOrNull!,
        completedWorkout: completedWorkout,
        activityIds: activityIds,
        stats: stats,
        achievements: _checkAchievements(completedWorkout, stats),
      ));
      
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
    var result = workout.copyWith(
      status: WorkoutStatus.completed,
      endTime: now,
      updatedAt: now,
    );
    
    // Clean up exercise data and calculate final metrics
    final processedExercises = result.exercises.map((exercise) {
      // Calculate exercise-level metrics
      final completedSets = exercise.sets.where((set) => set.isCompleted).toList();
      final totalVolume = completedSets.fold<double>(
        0.0, 
        (sum, set) => sum + set.volume,
      );
      
      // Mark exercise as completed if all sets are done
      final isExerciseComplete = exercise.sets.isNotEmpty && 
        exercise.sets.every((set) => set.isCompleted);
      
      return exercise.copyWith(
        isCompleted: isExerciseComplete,
        totalVolume: totalVolume,
        completedAt: isExerciseComplete ? now : null,
      );
    }).toList();
    
    return result.copyWith(exercises: processedExercises);
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
  
  /// Check for achievements unlocked
  List<Achievement> _checkAchievements(Workout workout, WorkoutCompletionStats stats) {
    final achievements = <Achievement>[];
    
    // Duration-based achievements
    if (stats.duration.inMinutes >= 60) {
      achievements.add(const Achievement(
        id: 'marathon_workout',
        name: 'Marathon Warrior',
        description: 'Complete a workout longer than 60 minutes',
        iconPath: '🏃‍♂️',
      ));
    }
    
    // Volume-based achievements
    if (stats.totalVolume >= 1000) {
      achievements.add(const Achievement(
        id: 'volume_beast',
        name: 'Volume Beast',
        description: 'Move over 1000kg in a single workout',
        iconPath: '💪',
      ));
    }
    
    // Set count achievements
    if (stats.completedSets >= 50) {
      achievements.add(const Achievement(
        id: 'set_master',
        name: 'Set Master',
        description: 'Complete 50+ sets in one workout',
        iconPath: '🎯',
      ));
    }
    
    // Perfect completion
    if (stats.completionRate == 1.0) {
      achievements.add(const Achievement(
        id: 'perfectionist',
        name: 'Perfectionist',
        description: 'Complete every planned set',
        iconPath: '⭐',
      ));
    }
    
    // Variety achievement
    if (stats.exercisesByCategory.length >= 4) {
      achievements.add(const Achievement(
        id: 'well_rounded',
        name: 'Well Rounded',
        description: 'Train 4+ muscle groups in one workout',
        iconPath: '🎯',
      ));
    }
    
    return achievements;
  }
}

/// Parameters for CompleteWorkoutUseCase
class CompleteWorkoutParams {
  final Workout workout;
  final String userEmail;
  final bool saveAsActivities;
  
  const CompleteWorkoutParams({
    required this.workout,
    required this.userEmail,
    this.saveAsActivities = true,
  });
}

/// Result of completing a workout
class CompleteWorkoutResult {
  final String workoutId;
  final Workout completedWorkout;
  final List<String> activityIds;
  final WorkoutCompletionStats stats;
  final List<Achievement> achievements;
  
  const CompleteWorkoutResult({
    required this.workoutId,
    required this.completedWorkout,
    required this.activityIds,
    required this.stats,
    required this.achievements,
  });
}

/// Workout completion statistics
class WorkoutCompletionStats {
  final Duration duration;
  final double totalVolume;
  final int completedSets;
  final double completionRate;
  final Duration averageRestTime;
  final Map<ExerciseCategory, int> exercisesByCategory;
  final double? averageRpe;
  
  const WorkoutCompletionStats({
    required this.duration,
    required this.totalVolume,
    required this.completedSets,
    required this.completionRate,
    required this.averageRestTime,
    required this.exercisesByCategory,
    this.averageRpe,
  });
}

/// Achievement unlocked during workout
class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
  });
}