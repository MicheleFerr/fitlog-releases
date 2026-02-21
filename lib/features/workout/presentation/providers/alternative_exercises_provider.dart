import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/converters/exercise_converter.dart';

/// Difficulty sort order supporting both Italian and English values.
const _difficultyOrder = <String, int>{
  'principiante': 0,
  'beginner': 0,
  'intermedio': 1,
  'intermediate': 1,
  'avanzato': 2,
  'advanced': 2,
};

/// Provider per filtrare esercizi alternativi basati sulla categoria
final alternativeExercisesProvider = FutureProvider.autoDispose
    .family<List<Exercise>, String>((ref, currentExerciseName) async {
  // Get all exercises from hybrid repository
  final allExercises = await ref.read(allExercisesProvider.future);

  // Find the current exercise to get its category
  final currentExercise = allExercises
      .where((ex) => ex.nome == currentExerciseName)
      .firstOrNull;

  if (currentExercise == null || currentExercise.focus.isEmpty) {
    // If current exercise not found or no focus, return empty list
    return [];
  }

  // Get category from focus using the converter
  final category = ExerciseConverter.mapFocusToCategory(
    currentExercise.focus,
  );

  // Filter exercises by same category, excluding current exercise
  final alternatives = allExercises.where((ex) {
    if (ex.nome == currentExerciseName) {
      return false; // Exclude current exercise
    }
    if (ex.focus.isEmpty) return false; // Skip exercises without focus

    final exCategory = ExerciseConverter.mapFocusToCategory(ex.focus);
    return exCategory == category;
  }).toList();

  // Sort by difficulty (supports both IT and EN values) and limit to top 8
  alternatives.sort((a, b) {
    final aIndex = _difficultyOrder[a.difficolta.toLowerCase()] ?? 99;
    final bIndex = _difficultyOrder[b.difficolta.toLowerCase()] ?? 99;
    if (aIndex != bIndex) return aIndex.compareTo(bIndex);
    return a.nome.compareTo(b.nome);
  });

  return alternatives.take(8).toList();
});
