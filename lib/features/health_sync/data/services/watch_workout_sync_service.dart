/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/health_sync/data/services
/// Feature: health_sync
/// Type: service
///
/// Apple Watch Workout Sync Service - Converts Watch workout data to app entities
///
/// **Responsibilities**:
/// - Convert Watch workout data format to Workout entity
/// - Validate incoming workout data
/// - Save workouts to repository
/// - Handle conversion errors gracefully
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';

/// Service to handle workout sync from Apple Watch
class WatchWorkoutSyncService {
  WatchWorkoutSyncService({
    required WorkoutRepository workoutRepository,
  }) : _workoutRepository = workoutRepository;

  final WorkoutRepository _workoutRepository;

  /// Convert Watch workout data to Workout entity and save
  ///
  /// Expected Watch data format:
  /// ```dart
  /// {
  ///   'workoutId': 'uuid',
  ///   'workoutName': 'Morning Workout',
  ///   'startTime': 1702345678000, // milliseconds since epoch
  ///   'endTime': 1702349278000,
  ///   'exercises': [
  ///     {
  ///       'exerciseId': 'uuid',
  ///       'exerciseName': 'Bench Press',
  ///       'category': 'chest',
  ///       'sets': [
  ///         {
  ///           'reps': 10,
  ///           'weight': 60.0,
  ///           'isCompleted': true,
  ///           'completedAt': 1702345800000,
  ///         }
  ///       ]
  ///     }
  ///   ],
  ///   'notes': 'Completed on Watch',
  /// }
  /// ```
  Future<bool> syncWorkoutFromWatch(Map<dynamic, dynamic> watchData) async {
    try {
      if (kDebugMode) {
        debugPrint('Converting workout from watch: $watchData');
      }

      // Validate required fields
      if (!_validateWatchData(watchData)) {
        if (kDebugMode) {
          debugPrint('Invalid watch workout data: missing required fields');
        }
        return false;
      }

      // Convert to Workout entity
      final workout = _convertToWorkout(watchData);

      // Save to repository
      final result = await _workoutRepository.saveWorkout(workout);

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('Failed to save workout from watch: $failure');
          }
          return false;
        },
        (workoutId) {
          if (kDebugMode) {
            debugPrint('Successfully saved workout from watch: $workoutId');
          }
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error syncing workout from watch: $e');
      }
      return false;
    }
  }

  /// Validate watch workout data has required fields
  bool _validateWatchData(Map<dynamic, dynamic> data) {
    return data['workoutId'] != null &&
        data['workoutName'] != null &&
        data['startTime'] != null &&
        data['exercises'] != null &&
        data['exercises'] is List;
  }

  /// Convert watch data to Workout entity
  Workout _convertToWorkout(Map<dynamic, dynamic> watchData) {
    final workoutId = watchData['workoutId'] as String;
    final workoutName = watchData['workoutName'] as String;
    final startTimeMs = watchData['startTime'] as int;
    final endTimeMs = watchData['endTime'] as int?;
    final notes = watchData['notes'] as String?;
    final templateId = watchData['templateId'] as String?;

    final startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMs);
    final endTime = endTimeMs != null
        ? DateTime.fromMillisecondsSinceEpoch(endTimeMs)
        : null;

    // Convert exercises
    final exercisesData = watchData['exercises'] as List;
    final exercises = exercisesData
        .map((exerciseData) => _convertToExercise(exerciseData as Map))
        .toList();

    // Create workout
    return Workout(
      id: workoutId,
      name: workoutName,
      exercises: exercises,
      status: endTime != null ? WorkoutStatus.completed : WorkoutStatus.inProgress,
      startTime: startTime,
      endTime: endTime,
      notes: notes ?? 'Completed on Apple Watch',
      createdAt: startTime,
      updatedAt: endTime ?? DateTime.now(),
      templateId: templateId,
      // Session ID for analytics tracking
      sessionId: '$workoutId-watch',
    );
  }

  /// Convert watch exercise data to Exercise entity
  Exercise _convertToExercise(Map<dynamic, dynamic> exerciseData) {
    final exerciseId = exerciseData['exerciseId'] as String;
    final exerciseName = exerciseData['exerciseName'] as String;
    final categoryStr = exerciseData['category'] as String? ?? 'other';
    final notes = exerciseData['notes'] as String?;

    // Parse category
    ExerciseCategory category;
    try {
      category = ExerciseCategory.values.firstWhere(
        (c) => c.toString().split('.').last == categoryStr,
        orElse: () => ExerciseCategory.other,
      );
    } catch (e) {
      category = ExerciseCategory.other;
    }

    // Convert sets
    final setsData = exerciseData['sets'] as List? ?? [];
    final sets = setsData
        .map((setData) => _convertToExerciseSet(setData as Map))
        .toList();

    return Exercise(
      id: exerciseId,
      name: exerciseName,
      type: ExerciseType.single, // Watch workouts are always single exercises
      sets: sets,
      category: category,
      notes: notes,
    );
  }

  /// Convert watch set data to ExerciseSet entity
  ExerciseSet _convertToExerciseSet(Map<dynamic, dynamic> setData) {
    final setNumber = setData['setNumber'] as int? ?? 1;
    final reps = setData['reps'] as int? ?? 0;
    final weight = (setData['weight'] as num?)?.toDouble() ?? 0.0;
    final isCompleted = setData['isCompleted'] as bool? ?? false;
    final completedAtMs = setData['completedAt'] as int?;
    final restTime = setData['restTime'] as int?;
    final notes = setData['notes'] as String?;

    final completedAt = completedAtMs != null
        ? DateTime.fromMillisecondsSinceEpoch(completedAtMs)
        : null;

    return ExerciseSet(
      setNumber: setNumber,
      reps: reps,
      weight: weight,
      isCompleted: isCompleted,
      completedAt: completedAt,
      restTime: restTime,
      notes: notes,
    );
  }

  /// Convert multiple workouts from watch (batch sync)
  Future<int> syncMultipleWorkoutsFromWatch(List<Map<dynamic, dynamic>> workoutsData) async {
    int successCount = 0;

    for (final workoutData in workoutsData) {
      final success = await syncWorkoutFromWatch(workoutData);
      if (success) {
        successCount++;
      }
    }

    if (kDebugMode) {
      debugPrint('Synced $successCount/${workoutsData.length} workouts from watch');
    }

    return successCount;
  }

  /// Convert Workout entity to Watch-compatible format
  ///
  /// Used when sending workout templates to Watch
  Map<String, dynamic> convertWorkoutToWatchFormat(Workout workout) {
    return {
      'workoutId': workout.id,
      'workoutName': workout.name,
      'startTime': workout.startTime?.millisecondsSinceEpoch,
      'endTime': workout.endTime?.millisecondsSinceEpoch,
      'exercises': workout.exercises.map((exercise) => {
        'exerciseId': exercise.id,
        'exerciseName': exercise.name,
        'category': exercise.category.toString().split('.').last,
        'sets': exercise.sets.map((set) => {
          'reps': set.reps,
          'weight': set.weight,
          'isCompleted': set.isCompleted,
          'completedAt': set.completedAt?.millisecondsSinceEpoch,
          'restTime': set.restTime,
          'notes': set.notes,
        }).toList(),
        'notes': exercise.notes,
      }).toList(),
      'notes': workout.notes,
      'templateId': workout.templateId,
    };
  }

  /// Get workout summary for Watch display
  Map<String, dynamic> getWorkoutSummary(Workout workout) {
    return {
      'id': workout.id,
      'name': workout.name,
      'exerciseCount': workout.exercises.length,
      'totalSets': workout.totalSets,
      'completedSets': workout.completedSets,
      'duration': workout.duration?.inMinutes ?? 0,
      'status': workout.status.toString().split('.').last,
    };
  }
}
