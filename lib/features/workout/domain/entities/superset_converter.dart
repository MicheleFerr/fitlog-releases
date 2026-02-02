import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart'
    as WorkoutExercise;
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_configuration.dart';
import 'package:gymbro_flutter_new/shared/domain/converters/exercise_converter.dart';

/// Converts between SupersetConfiguration (builder) and SupersetExercise (workout)
class SupersetConverter {
  /// Convert SupersetConfiguration to SupersetExercise for adding to workout
  static WorkoutExercise.SupersetExercise configurationToSupersetExercise(
    SupersetConfiguration config,
  ) {
    // Convert database exercises to workout exercises with unique IDs
    final List<WorkoutExercise.Exercise> workoutExercises = config.exercises
        .map((dbExercise) {
          final exerciseId =
              '${DateTime.now().millisecondsSinceEpoch}_${dbExercise.id}';
          return WorkoutExercise.Exercise(
            id: exerciseId, // Generate unique ID for each exercise
            name: dbExercise.nome,
            type: WorkoutExercise
                .ExerciseType
                .single, // Individual exercises in superset
            category: _mapFocusToCategory(dbExercise.focus),
            sets: [], // Will be filled by SupersetSet
            notes: '',
            countingMode: dbExercise.countingMode, // ✅ Preserve counting mode
            tut: dbExercise.tempoEsecuzione, // ✅ Preserve TUT from database
          );
        })
        .toList();

    // Convert rounds to SupersetSet objects
    final List<WorkoutExercise.SupersetSet>
    supersetSets = config.rounds.asMap().entries.map((entry) {
      final index = entry.key;
      final round = entry.value;
      final Map<String, WorkoutExercise.SupersetExerciseData> exerciseData = {};

      // Create data for each exercise in this round using the workout exercise IDs
      for (int i = 0; i < config.exercises.length; i++) {
        final dbExercise = config.exercises[i];
        final workoutExercise = workoutExercises[i];

        // ✅ FIX: Get individual config for this specific exercise
        final exerciseConfig = round.exerciseConfigs[dbExercise.id];

        // Use the workout exercise ID as the key
        exerciseData[workoutExercise.id] = WorkoutExercise.SupersetExerciseData(
          exerciseId: workoutExercise.id,
          exerciseName: dbExercise.nome,
          // ✅ FIX: Use individual config instead of round.targetWeight/targetReps
          targetWeight: exerciseConfig?.targetWeight ?? 20.0,
          targetReps: exerciseConfig?.targetReps ?? 12,
          actualWeight: null,
          actualReps: null,
          rpe: null,
          isCompleted: false,
          notes: round.notes,
        );
      }

      // ✅ FIX: Genera ID univoco per ogni round usando index
      // Questo previene che tutti i round abbiano lo stesso ID timestamp
      return WorkoutExercise.SupersetSet(
        id: 'superset_round_${DateTime.now().millisecondsSinceEpoch}_${index}_${round.roundNumber}',
        setNumber: round.roundNumber,
        exerciseData: exerciseData,
        isCompleted: false,
      );
    }).toList();

    return WorkoutExercise.SupersetExercise(
      name: config.name,
      exercises: workoutExercises,
      supersetSets: supersetSets,
      notes: 'Rest between exercises: ${config.restBetweenExercises}s',
      restTime: config.restAfterRound,
    );
  }

  /// Map exercise focus list to workout exercise category
  static WorkoutExercise.ExerciseCategory _mapFocusToCategory(
    List<String> focusList,
  ) {
    // Use centralized converter (fixes bug where only first element was checked)
    return ExerciseConverter.mapFocusToCategory(focusList);
  }
}
