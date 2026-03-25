/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/domain/converters
/// 🎯 Feature: shared
/// 🔧 Type: converter
///
/// Converter centralizzato per trasformare Exercise Database → Workout Exercise
/// Elimina duplicazione di logica di conversione presente in 9 file diversi
library;

import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    as DatabaseExercise;
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart'
    as WorkoutExercise;
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';

/// Converter centralizzato per la conversione di esercizi
/// da Database Exercise a Workout Exercise
class ExerciseConverter {
  ExerciseConverter._(); // Private constructor per classe utility

  /// Converte un Database Exercise in un Workout Exercise con 3 set di default
  ///
  /// [countingModeOverride] - Optional override for the counting mode.
  /// If provided, it will be used instead of the database exercise's counting mode.
  /// This is used when the user has saved a preferred counting mode for this exercise.
  ///
  /// Esempio:
  /// ```dart
  /// final dbExercise = Exercise(nome: 'Squat', focus: ['QUAD', 'GLUT'], ...);
  /// final workoutExercise = ExerciseConverter.fromDatabaseExercise(dbExercise);
  ///
  /// // With override:
  /// final workoutExercise = ExerciseConverter.fromDatabaseExercise(
  ///   dbExercise,
  ///   countingModeOverride: ExerciseCountingMode.reps,
  /// );
  /// ```
  static WorkoutExercise.Exercise fromDatabaseExercise(
    DatabaseExercise.Exercise exercise, {
    ExerciseCountingMode? countingModeOverride,
    int initialSetCount = 3,
  }) {
    final safeInitialSetCount = initialSetCount < 1 ? 1 : initialSetCount;

    return WorkoutExercise.Exercise(
      databaseExerciseId: exercise.id,
      name: exercise.nome,
      type: WorkoutExercise.ExerciseType.single,
      category: mapFocusToCategory(exercise.focus),
      notes: null, // Note utente separate - non mappare noteTecniche qui
      countingMode:
          countingModeOverride ??
          exercise
              .countingMode, // ✅ Use override if provided, otherwise database
      tut: exercise.tempoEsecuzione, // ✅ Pass TUT from database
      sets: List.generate(
        safeInitialSetCount,
        (index) => WorkoutExercise.ExerciseSet(
          setNumber: index + 1,
          weight: 0,
          reps: 10,
        ),
      ),
    );
  }

  /// Converte un Database Exercise in un Workout Exercise con set custom
  ///
  /// [countingModeOverride] - Optional override for the counting mode.
  ///
  /// Esempio:
  /// ```dart
  /// final customSets = [
  ///   ExerciseSet(setNumber: 1, weight: 100, reps: 5),
  ///   ExerciseSet(setNumber: 2, weight: 110, reps: 3),
  /// ];
  /// final workoutExercise = ExerciseConverter.fromDatabaseExerciseWithSets(
  ///   dbExercise,
  ///   customSets,
  /// );
  /// ```
  static WorkoutExercise.Exercise fromDatabaseExerciseWithSets(
    DatabaseExercise.Exercise exercise,
    List<WorkoutExercise.ExerciseSet> sets, {
    ExerciseCountingMode? countingModeOverride,
  }) {
    return WorkoutExercise.Exercise(
      databaseExerciseId: exercise.id,
      name: exercise.nome,
      type: WorkoutExercise.ExerciseType.single,
      category: mapFocusToCategory(exercise.focus),
      notes: null, // Note utente separate - non mappare noteTecniche qui
      countingMode:
          countingModeOverride ??
          exercise.countingMode, // ✅ Use override if provided
      tut: exercise.tempoEsecuzione, // ✅ Pass TUT from database
      sets: sets,
    );
  }

  /// Mappa i codici muscoli focus a category di workout
  ///
  /// **SINGLE SOURCE OF TRUTH**: Delega a MuscleAbbreviationMapper
  /// che è la fonte centralizzata per il mapping abbreviazione → categoria.
  ///
  /// Esempio:
  /// ```dart
  /// mapFocusToCategory(['PETT', 'DELT']) // → ExerciseCategory.chest
  /// mapFocusToCategory(['QUAD', 'GLUT'])  // → ExerciseCategory.legs
  /// mapFocusToCategory(['LAT'])           // → ExerciseCategory.back
  /// ```
  static WorkoutExercise.ExerciseCategory mapFocusToCategory(
    List<String> focus,
  ) {
    // Usa il mapper centralizzato come single source of truth
    return MuscleAbbreviationMapper.focusListToExerciseCategory(focus);
  }

  /// Mappa nomi di muscoli (IT/EN) ai codici standardizzati
  ///
  /// **SINGLE SOURCE OF TRUTH**: Delega a MuscleAbbreviationMapper.
  ///
  /// Esempio:
  /// ```dart
  /// mapMuscleNameToCode('Pettorali')    // → 'PETT'
  /// mapMuscleNameToCode('Quadricipiti') // → 'QUAD'
  /// mapMuscleNameToCode('Chest')        // → 'PETT'
  /// mapMuscleNameToCode('Unknown')      // → 'OTHER'
  /// ```
  static String mapMuscleNameToCode(String muscleName) {
    return MuscleAbbreviationMapper.nameToAbbreviation(muscleName) ?? 'OTHER';
  }

  /// Converte un codice muscolo al nome IT display-friendly
  ///
  /// **SINGLE SOURCE OF TRUTH**: Delega a MuscleAbbreviationMapper.
  ///
  /// Esempio:
  /// ```dart
  /// mapMuscleCodeToName('PETT') // → 'Pettorali'
  /// mapMuscleCodeToName('QUAD') // → 'Quadricipiti'
  /// ```
  static String mapMuscleCodeToName(String code) {
    return MuscleAbbreviationMapper.codeToDisplayName(code);
  }
}
