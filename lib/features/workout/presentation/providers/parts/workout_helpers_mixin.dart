part of '../workout_provider.dart';

mixin WorkoutHelpersMixin on Notifier<Workout?> {
  /// Finds the next exercise with incomplete sets after the given exercise.
  /// Returns null if current exercise is the last one or all following are complete.
  Exercise? _getNextIncompleteExercise(Workout workout, Exercise current) {
    final currentIndex = workout.exercises.indexWhere(
      (e) => e.id == current.id,
    );
    if (currentIndex == -1) return null;

    for (int i = currentIndex + 1; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      if (!exercise.isCompleted) {
        return exercise;
      }
    }
    return null;
  }

  /// Resolves the rest time between exercises with priority:
  /// 1. Exercise.restAfterExercise (if set)
  /// 2. AppConfig.defaultRestBetweenExercises
  /// 3. 90 seconds (hardcoded fallback)
  int _resolveInterExerciseRest(Exercise exercise) {
    // 1. Exercise-specific override
    if (exercise.restAfterExercise != null) {
      return exercise.restAfterExercise!;
    }

    // 2. Global default from config
    final appConfig = ref.read(appConfigProvider);
    return appConfig.defaultRestBetweenExercises;
  }

  /// Gets total sets count for any exercise type (polymorphic)
  int _getExerciseTotalSets(Exercise exercise) {
    if (exercise is SupersetExercise) {
      return exercise.supersetSets.length;
    } else if (exercise is DropSetExercise) {
      return exercise.stages.length;
    } else if (exercise is RestPauseExercise) {
      return exercise.restPauseSets.length;
    }
    return exercise.sets.length;
  }

  /// Fetches the most recent completed workout for a given template.
  ///
  /// Returns null if no previous workout is found or if a query error occurs.
  ///
  Future<Workout?> _fetchPreviousTemplateWorkout({
    required String templateId,
    required String userId,
  }) async {
    final authUserId = ref.read(authServiceProvider).currentUser?.uid;
    if (authUserId == null || authUserId != userId) {
      return null;
    }

    final result = await ref
        .read(workoutRepositoryProvider)
        .getWorkouts(limit: 100);

    return result.fold((_) => null, (workouts) {
      final matchingWorkouts =
          workouts
              .where(
                (workout) =>
                    workout.templateId == templateId && workout.isCompleted,
              )
              .toList()
            ..sort((a, b) {
              final aCompletedAt = a.endTime ?? a.updatedAt;
              final bCompletedAt = b.endTime ?? b.updatedAt;
              return bCompletedAt.compareTo(aCompletedAt);
            });

      return matchingWorkouts.isEmpty ? null : matchingWorkouts.first;
    });
  }

  /// Localizes exercise name by looking up in exercise database.
  ///
  /// Replaces hardcoded English names from templates with localized names.
  /// Handles all exercise types: Exercise, SupersetExercise, DropSetExercise, RestPauseExercise.
  ///
  /// Returns the exercise with localized name(s), or the original if lookup fails.
  Future<Exercise> _localizeExerciseName(Exercise exercise) async {
    try {
      // Fetch localized name from exercise database
      final exerciseDefinition = await ref.read(
        exerciseByIdProvider(exercise.stableExerciseId).future,
      );

      if (exerciseDefinition == null) {
        // Exercise not found in database, keep original name
        if (kDebugMode) {
          debugLog(
            LogCategory.workout,
            '⚠️ [WorkoutProvider] Exercise not found in database: ${exercise.stableExerciseId}',
          );
        }
        return exercise;
      }

      final localizedName = exerciseDefinition.nome;

      // Handle different exercise types
      if (exercise is SupersetExercise) {
        // Localize main name and sub-exercise names
        final localizedSubExercises = <Exercise>[];
        for (final subExercise in exercise.exercises) {
          final localizedSub = await _localizeExerciseName(subExercise);
          localizedSubExercises.add(localizedSub);
        }

        // Update superset exercise data with localized names
        final localizedSupersetSets = exercise.supersetSets.map((supersetSet) {
          final localizedExerciseData = <String, SupersetExerciseData>{};

          for (final entry in supersetSet.exerciseData.entries) {
            final exerciseId = entry.key;
            final data = entry.value;

            // Find the localized name for this exercise
            final localizedExercise = localizedSubExercises.firstWhere(
              (e) => e.id == exerciseId,
              orElse: () =>
                  exercise.exercises.firstWhere((e) => e.id == exerciseId),
            );

            localizedExerciseData[exerciseId] = data.copyWith(
              exerciseName: localizedExercise.name,
            );
          }

          return supersetSet.copyWith(exerciseData: localizedExerciseData);
        }).toList();

        return exercise.copyWith(
          name: localizedName,
          exercises: localizedSubExercises,
          supersetSets: localizedSupersetSets,
        );
      } else if (exercise is DropSetExercise) {
        return exercise.copyWith(name: localizedName);
      } else if (exercise is RestPauseExercise) {
        return exercise.copyWith(name: localizedName);
      } else {
        // Regular Exercise
        return exercise.copyWith(name: localizedName);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error localizing exercise name: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Return original exercise if localization fails
      return exercise;
    }
  }
}
