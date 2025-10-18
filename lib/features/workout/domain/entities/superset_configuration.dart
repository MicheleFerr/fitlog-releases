import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart' as ExerciseDB;

/// Configuration model for creating supersets with tier-1 UX
class SupersetConfiguration {

  const SupersetConfiguration({
    required this.exercises,
    required this.rounds,
    this.restBetweenExercises = 0, // True superset has no rest between exercises
    this.restAfterRound = 90,      // Standard rest after completing full round
    this.name = 'Superset',
  });
  final List<ExerciseDB.Exercise> exercises;
  final List<SupersetRound> rounds;
  final int restBetweenExercises; // Seconds between exercises in a round (usually 0)
  final int restAfterRound;       // Seconds between rounds (typically 60-120s)
  final String name;

  SupersetConfiguration copyWith({
    List<ExerciseDB.Exercise>? exercises,
    List<SupersetRound>? rounds,
    int? restBetweenExercises,
    int? restAfterRound,
    String? name,
  }) {
    return SupersetConfiguration(
      exercises: exercises ?? this.exercises,
      rounds: rounds ?? this.rounds,
      restBetweenExercises: restBetweenExercises ?? this.restBetweenExercises,
      restAfterRound: restAfterRound ?? this.restAfterRound,
      name: name ?? this.name,
    );
  }

  bool get isValid => exercises.length >= 2 && rounds.isNotEmpty;
  
  int get totalSets => rounds.length;
}

/// Exercise-specific configuration within a superset round
class SupersetExerciseConfig {

  const SupersetExerciseConfig({
    required this.exerciseId,
    required this.targetReps,
    this.targetWeight,
  });
  final String exerciseId;
  final int targetReps;
  final double? targetWeight;

  SupersetExerciseConfig copyWith({
    String? exerciseId,
    int? targetReps,
    double? targetWeight,
  }) {
    return SupersetExerciseConfig(
      exerciseId: exerciseId ?? this.exerciseId,
      targetReps: targetReps ?? this.targetReps,
      targetWeight: targetWeight ?? this.targetWeight,
    );
  }
}

/// Represents a single round/set in a superset where all exercises are performed
class SupersetRound {

  const SupersetRound({
    required this.roundNumber,
    required this.exerciseConfigs,
    this.notes,
  });

  // Legacy constructor for backward compatibility
  SupersetRound.legacy({
    required this.roundNumber,
    required int targetReps,
    double? targetWeight,
    this.notes,
    required List<ExerciseDB.Exercise> exercises,
  }) : exerciseConfigs = { for (var e in exercises) e.id : SupersetExerciseConfig(
            exerciseId: e.id,
            targetReps: targetReps,
            targetWeight: targetWeight,
          ) };

  // Simple constructor that creates same config for all exercises
  SupersetRound.uniform({
    required this.roundNumber,
    required int targetReps,
    double? targetWeight,
    this.notes,
    required List<String> exerciseIds,
  }) : exerciseConfigs = { for (var id in exerciseIds) id : SupersetExerciseConfig(
            exerciseId: id,
            targetReps: targetReps,
            targetWeight: targetWeight,
          ) };
  final int roundNumber;
  final Map<String, SupersetExerciseConfig> exerciseConfigs; // Per-exercise configuration
  final String? notes;

  SupersetRound copyWith({
    int? roundNumber,
    Map<String, SupersetExerciseConfig>? exerciseConfigs,
    String? notes,
  }) {
    return SupersetRound(
      roundNumber: roundNumber ?? this.roundNumber,
      exerciseConfigs: exerciseConfigs ?? this.exerciseConfigs,
      notes: notes ?? this.notes,
    );
  }

  // Legacy getters for backward compatibility
  int get targetReps => exerciseConfigs.values.first.targetReps;
  double? get targetWeight => exerciseConfigs.values.first.targetWeight;
}