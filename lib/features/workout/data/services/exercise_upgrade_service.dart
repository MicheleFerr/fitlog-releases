/// Exercise Upgrade Service
///
/// Handles counting and updating exercises across workouts and templates
/// when upgrading from custom exercises to database exercises.
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/template_repository.dart';

/// Result of counting affected items
class AffectedItemsCount {
  const AffectedItemsCount({
    required this.workoutCount,
    required this.templateCount,
    required this.workoutIds,
    required this.templateIds,
  });

  /// Number of workout history items containing the exercise
  final int workoutCount;

  /// Number of templates containing the exercise
  final int templateCount;

  /// IDs of affected workouts
  final List<String> workoutIds;

  /// IDs of affected templates
  final List<String> templateIds;

  /// Total count of affected items
  int get total => workoutCount + templateCount;

  /// Whether there are any affected items
  bool get hasAffectedItems => total > 0;
}

/// Service for exercise upgrade operations
class ExerciseUpgradeService {
  ExerciseUpgradeService({
    required WorkoutHistoryRepositoryEnhanced historyRepository,
    required TemplateRepository templateRepository,
  }) : _historyRepository = historyRepository,
       _templateRepository = templateRepository;

  final WorkoutHistoryRepositoryEnhanced _historyRepository;
  final TemplateRepository _templateRepository;

  /// Count workouts and templates containing an exercise by name
  ///
  /// Returns [AffectedItemsCount] with counts and IDs of affected items.
  /// The [exerciseName] is matched case-insensitively.
  Future<AffectedItemsCount> countAffectedItems(String exerciseName) async {
    final normalizedName = exerciseName.toLowerCase().trim();

    // Count affected workouts from history
    final workoutResult = await _countAffectedWorkouts(normalizedName);

    // Count affected templates
    final templateResult = await _countAffectedTemplates(normalizedName);

    return AffectedItemsCount(
      workoutCount: workoutResult.count,
      templateCount: templateResult.count,
      workoutIds: workoutResult.ids,
      templateIds: templateResult.ids,
    );
  }

  /// Update exercise name in all affected workouts and templates
  ///
  /// [oldExerciseName] - Current name to find
  /// [newExerciseName] - New name to replace with
  /// [updateWorkouts] - Whether to update workout history
  /// [updateTemplates] - Whether to update templates
  ///
  /// Returns the number of items updated.
  Future<int> updateExerciseAcrossItems({
    required String oldExerciseName,
    required String newExerciseName,
    bool updateWorkouts = true,
    bool updateTemplates = true,
  }) async {
    int updatedCount = 0;

    if (updateWorkouts) {
      updatedCount += await _updateInWorkouts(oldExerciseName, newExerciseName);
    }

    if (updateTemplates) {
      updatedCount += await _updateInTemplates(
        oldExerciseName,
        newExerciseName,
      );
    }

    if (kDebugMode) {
      debugPrint(
        '🔄 [ExerciseUpgrade] Updated $updatedCount items: '
        '"$oldExerciseName" → "$newExerciseName"',
      );
    }

    return updatedCount;
  }

  /// Count affected workouts
  Future<_CountResult> _countAffectedWorkouts(String normalizedName) async {
    try {
      // Get all workout history
      final result = await _historyRepository.getWorkouts();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [ExerciseUpgrade] Failed to get workouts: ${failure.message}',
            );
          }
          return const _CountResult(count: 0, ids: []);
        },
        (workouts) {
          final affectedIds = <String>[];

          for (final workout in workouts) {
            final hasExercise = workout.exercises.any(
              (e) => e.name.toLowerCase().trim() == normalizedName,
            );
            if (hasExercise) {
              affectedIds.add(workout.id);
            }
          }

          return _CountResult(count: affectedIds.length, ids: affectedIds);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseUpgrade] Error counting workouts: $e');
      }
      return const _CountResult(count: 0, ids: []);
    }
  }

  /// Count affected templates
  Future<_CountResult> _countAffectedTemplates(String normalizedName) async {
    try {
      final templates = await _templateRepository.getUserTemplates();
      final affectedIds = <String>[];

      for (final template in templates) {
        final hasExercise = template.exercises.any(
          (e) => e.name.toLowerCase().trim() == normalizedName,
        );
        if (hasExercise) {
          affectedIds.add(template.id);
        }
      }

      return _CountResult(count: affectedIds.length, ids: affectedIds);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseUpgrade] Error counting templates: $e');
      }
      return const _CountResult(count: 0, ids: []);
    }
  }

  /// Update exercise name in workout history
  Future<int> _updateInWorkouts(String oldName, String newName) async {
    try {
      final result = await _historyRepository.getWorkouts();

      return await result.fold((failure) async => 0, (workouts) async {
        int updatedCount = 0;
        final normalizedOld = oldName.toLowerCase().trim();

        for (final workout in workouts) {
          bool hasMatch = false;

          // Check if workout contains the exercise
          final updatedExercises = workout.exercises.map((exercise) {
            if (exercise.name.toLowerCase().trim() == normalizedOld) {
              hasMatch = true;
              return exercise.copyWith(name: newName);
            }
            return exercise;
          }).toList();

          if (hasMatch) {
            // Update workout with new exercise names using copyWith
            final updatedWorkout = workout.copyWith(
              exercises: updatedExercises,
              updatedAt: DateTime.now(),
            );

            final updateResult = await _historyRepository.updateWorkout(
              updatedWorkout,
            );
            updateResult.fold(
              (failure) {
                if (kDebugMode) {
                  debugPrint(
                    '⚠️ [ExerciseUpgrade] Failed to update workout ${workout.id}',
                  );
                }
              },
              (_) {
                updatedCount++;
              },
            );
          }
        }

        return updatedCount;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseUpgrade] Error updating workouts: $e');
      }
      return 0;
    }
  }

  /// Update exercise name in templates
  Future<int> _updateInTemplates(String oldName, String newName) async {
    try {
      final templates = await _templateRepository.getUserTemplates();
      final affectedTemplateIds = <String>[];
      final normalizedOld = oldName.toLowerCase().trim();

      for (final template in templates) {
        final hasMatch = template.exercises.any(
          (e) => e.name.toLowerCase().trim() == normalizedOld,
        );
        if (hasMatch) {
          affectedTemplateIds.add(template.id);
        }
      }

      if (affectedTemplateIds.isEmpty) return 0;

      // Use existing replaceExerciseInTemplates method
      await _templateRepository.replaceExerciseInTemplates(
        templateIds: affectedTemplateIds,
        oldExerciseName: oldName,
        newExerciseName: newName,
        weightOption: 'keep',
      );

      return affectedTemplateIds.length;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseUpgrade] Error updating templates: $e');
      }
      return 0;
    }
  }
}

/// Internal class for count results
class _CountResult {
  const _CountResult({required this.count, required this.ids});
  final int count;
  final List<String> ids;
}
