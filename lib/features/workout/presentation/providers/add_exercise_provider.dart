import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

// Exercise sets management for the modal
class ExerciseSetNotifier extends Notifier<List<ExerciseSet>> {
  @override
  List<ExerciseSet> build() => [
    ExerciseSet(setNumber: 1, weight: 0, reps: 10),
    ExerciseSet(setNumber: 2, weight: 0, reps: 10),
    ExerciseSet(setNumber: 3, weight: 0, reps: 10),
  ];

  void addSet() {
    final newSetNumber = state.length + 1;
    final lastSet = state.isNotEmpty ? state.last : null;

    final newSet = ExerciseSet(
      setNumber: newSetNumber,
      weight: lastSet?.weight ?? 0,
      reps: lastSet?.reps ?? 10,
    );

    state = [...state, newSet];
  }

  void removeSet(String setId) {
    if (state.length <= 1) return; // Keep at least one set

    final updatedSets = state.where((set) => set.id != setId).toList();

    // Renumber sets
    for (int i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }

    state = updatedSets;
  }

  void updateSet(String setId, ExerciseSet updatedSet) {
    state = state.map((set) {
      if (set.id == setId) {
        return updatedSet;
      }
      return set;
    }).toList();
  }

  void reset() {
    state = [
      ExerciseSet(setNumber: 1, weight: 0, reps: 10),
      ExerciseSet(setNumber: 2, weight: 0, reps: 10),
      ExerciseSet(setNumber: 3, weight: 0, reps: 10),
    ];
  }
}

// Provider for exercise sets in the modal
final exerciseSetsProvider =
    NotifierProvider<ExerciseSetNotifier, List<ExerciseSet>>(
      ExerciseSetNotifier.new,
    );

// Superset exercises management
class SupersetExercisesNotifier extends Notifier<List<Exercise>> {
  @override
  List<Exercise> build() => [];

  void addExercise(Exercise exercise) {
    state = [...state, exercise];
  }

  void removeExercise(Exercise exercise) {
    state = state.where((e) => e.id != exercise.id).toList();
  }

  void clear() {
    state = [];
  }
}

// Provider for superset exercises
final supersetExercisesProvider =
    NotifierProvider<SupersetExercisesNotifier, List<Exercise>>(
      SupersetExercisesNotifier.new,
    );
