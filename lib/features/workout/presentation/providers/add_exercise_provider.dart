import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';

// Exercise sets management for the modal
class ExerciseSetNotifier extends StateNotifier<List<ExerciseSet>> {
  ExerciseSetNotifier() : super([
    ExerciseSet(setNumber: 1, weight: 0, reps: 10),
    ExerciseSet(setNumber: 2, weight: 0, reps: 10),
    ExerciseSet(setNumber: 3, weight: 0, reps: 10),
  ]);

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
final exerciseSetsProvider = StateNotifierProvider<ExerciseSetNotifier, List<ExerciseSet>>((ref) {
  return ExerciseSetNotifier();
});