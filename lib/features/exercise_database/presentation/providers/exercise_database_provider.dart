/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/presentation/providers
/// 🎯 Feature: exercise_database
/// 🔧 Type: provider (LEGACY COMPATIBILITY)
///
/// Provider aggiornato per compatibilità con sistema ibrido
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/converters/exercise_converter.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_database.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/json_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_migration_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart' as WorkoutExercise;

/// Provider legacy per ExerciseDatabase (mantiene compatibilità)
/// Ora utilizza il sistema ibrido sottostante
final exerciseDatabaseProvider = FutureProvider<List<ExerciseDatabase>>((ref) async {
  try {
    // Carica esercizi dal nuovo sistema ibrido
    final exercises = await ref.read(hybridExerciseRepositoryProvider).getAllExercises();

    // Converte Exercise -> ExerciseDatabase per compatibilità
    return exercises.map((exercise) => _convertToExerciseDatabase(exercise)).toList();
  } catch (e) {
    // Fallback ai dati mock se il sistema ibrido fallisce
    return [
      const ExerciseDatabase(
        id: '1',
        name: 'Bench Press',
        category: 'Chest',
        equipment: 'Barbell',
        primaryMuscleGroups: ['Chest'],
        secondaryMuscleGroups: ['Triceps', 'Shoulders'],
        difficulty: 'Intermediate',
      ),
      const ExerciseDatabase(
        id: '2',
        name: 'Squat',
        category: 'Legs',
        equipment: 'Barbell',
        primaryMuscleGroups: ['Quadriceps'],
        secondaryMuscleGroups: ['Glutes', 'Hamstrings'],
        difficulty: 'Intermediate',
      ),
      const ExerciseDatabase(
        id: '3',
        name: 'Deadlift',
        category: 'Back',
        equipment: 'Barbell',
        primaryMuscleGroups: ['Back'],
        secondaryMuscleGroups: ['Glutes', 'Hamstrings'],
        difficulty: 'Advanced',
      ),
    ];
  }
});

/// Provider per migrazione - espone il servizio di migrazione
final exerciseMigrationServiceProvider = Provider((ref) {
  final hybridRepository = ref.read(hybridExerciseRepositoryProvider);
  final jsonRepository = ref.read(jsonExerciseRepositoryInstanceProvider);
  final versionService = ref.read(exerciseVersionServiceProvider);
  final cacheManager = ref.read(exerciseCacheManagerProvider);

  return ExerciseMigrationService(
    hybridRepository: hybridRepository,
    jsonRepository: jsonRepository as JsonExerciseRepository,
    versionService: versionService,
    cacheManager: cacheManager,
  );
});

/// Converte Exercise a ExerciseDatabase per compatibilità
ExerciseDatabase _convertToExerciseDatabase(Exercise exercise) {
  return ExerciseDatabase(
    id: exercise.id,
    name: exercise.nome,
    category: _mapFocusToCategory(exercise.focus),
    equipment: exercise.attrezzatura,
    primaryMuscleGroups: exercise.focus,
    secondaryMuscleGroups: exercise.muscoliSecondari,
    difficulty: exercise.difficolta,
  );
}

/// Mappa focus a categoria per compatibilità
/// Usa centralized converter internamente e converte enum a String
String _mapFocusToCategory(List<String> focus) {
  final category = ExerciseConverter.mapFocusToCategory(focus);

  // Convert enum to String for legacy compatibility
  switch (category) {
    case WorkoutExercise.ExerciseCategory.chest:
      return 'Chest';
    case WorkoutExercise.ExerciseCategory.back:
      return 'Back';
    case WorkoutExercise.ExerciseCategory.shoulders:
      return 'Shoulders';
    case WorkoutExercise.ExerciseCategory.arms:
      return 'Arms';
    case WorkoutExercise.ExerciseCategory.legs:
      return 'Legs';
    case WorkoutExercise.ExerciseCategory.abs:
      return 'Core';
    case WorkoutExercise.ExerciseCategory.cardio:
      return 'Cardio';
    case WorkoutExercise.ExerciseCategory.other:
      return 'Other';
  }
}