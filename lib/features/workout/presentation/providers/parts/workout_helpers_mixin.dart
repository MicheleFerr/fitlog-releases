part of '../workout_provider.dart';

mixin WorkoutHelpersMixin on Notifier<Workout?> {
  /// Finds the next exercise with incomplete sets after the given exercise.
  /// Returns null if current exercise is the last one or all following are complete.
  Exercise? _getNextIncompleteExercise(Workout workout, Exercise current) {
    final currentIndex = workout.exercises.indexWhere((e) => e.id == current.id);
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
  /// NOTE: Currently returns null because WorkoutModel does not persist
  /// templateId to Firestore yet. Once WorkoutModel.toJson() includes
  /// templateId, this method can query Firestore with:
  ///   .where('templateId', isEqualTo: templateId)
  ///   .where('status', isEqualTo: 'completed')
  ///   .orderBy('endTime', descending: true)
  ///   .limit(1)
  Future<Workout?> _fetchPreviousTemplateWorkout({
    required String templateId,
    required String userId,
  }) async {
    // templateId is not yet persisted in Firestore by WorkoutModel.toJson(),
    // so the query would return no results. Return null until that is fixed.
    return null;
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
        exerciseByIdProvider(exercise.id).future,
      );

      if (exerciseDefinition == null) {
        // Exercise not found in database, keep original name
        if (kDebugMode) {
          debugLog(
            LogCategory.workout,
            '⚠️ [WorkoutProvider] Exercise not found in database: ${exercise.id}',
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
              orElse: () => exercise.exercises.firstWhere((e) => e.id == exerciseId),
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
