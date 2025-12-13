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
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart'
    as WorkoutExercise;

/// Converter centralizzato per la conversione di esercizi
/// da Database Exercise a Workout Exercise
class ExerciseConverter {
  ExerciseConverter._(); // Private constructor per classe utility

  /// Converte un Database Exercise in un Workout Exercise con 3 set di default
  ///
  /// Esempio:
  /// ```dart
  /// final dbExercise = Exercise(nome: 'Squat', focus: ['QUAD', 'GLUT'], ...);
  /// final workoutExercise = ExerciseConverter.fromDatabaseExercise(dbExercise);
  /// ```
  static WorkoutExercise.Exercise fromDatabaseExercise(
    DatabaseExercise.Exercise exercise,
  ) {
    return WorkoutExercise.Exercise(
      id: exercise.id, // ✅ Preserve original database exercise ID
      name: exercise.nome,
      type: WorkoutExercise.ExerciseType.single,
      category: mapFocusToCategory(exercise.focus),
      notes: null, // Note utente separate - non mappare noteTecniche qui
      countingMode: exercise.countingMode, // ✅ Use counting mode from database
      tut: exercise.tempoEsecuzione, // ✅ Pass TUT from database
      sets: [
        WorkoutExercise.ExerciseSet(setNumber: 1, weight: 0, reps: 10),
        WorkoutExercise.ExerciseSet(setNumber: 2, weight: 0, reps: 10),
        WorkoutExercise.ExerciseSet(setNumber: 3, weight: 0, reps: 10),
      ],
    );
  }

  /// Converte un Database Exercise in un Workout Exercise con set custom
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
    List<WorkoutExercise.ExerciseSet> sets,
  ) {
    return WorkoutExercise.Exercise(
      id: exercise.id, // ✅ Preserve original database exercise ID
      name: exercise.nome,
      type: WorkoutExercise.ExerciseType.single,
      category: mapFocusToCategory(exercise.focus),
      notes: null, // Note utente separate - non mappare noteTecniche qui
      countingMode: exercise.countingMode, // ✅ Use counting mode from database
      tut: exercise.tempoEsecuzione, // ✅ Pass TUT from database
      sets: sets,
    );
  }

  /// Mappa i codici muscoli focus a category di workout
  ///
  /// **IMPORTANTE**: Usa `.any()` per controllare TUTTI gli elementi del focus,
  /// non solo il primo. Questo risolve il bug dove ['QUAD', 'PETTO'] veniva
  /// mappato a legs invece di chest quando si usava `.first`.
  ///
  /// Esempio:
  /// ```dart
  /// mapFocusToCategory(['PETTO', 'DELT']) // → ExerciseCategory.chest
  /// mapFocusToCategory(['QUAD', 'GLUT'])  // → ExerciseCategory.legs
  /// mapFocusToCategory(['BICIPITI'])      // → ExerciseCategory.arms
  /// ```
  static WorkoutExercise.ExerciseCategory mapFocusToCategory(
    List<String> focus,
  ) {
    if (focus.isEmpty) {
      return WorkoutExercise.ExerciseCategory.other;
    }

    // Converti tutto in uppercase per confronto case-insensitive
    final upperFocus = focus.map((f) => f.toUpperCase()).toList();

    // Chest - Pettorali
    if (upperFocus.any((f) => ['PETTO', 'CHEST', 'PECT'].contains(f))) {
      return WorkoutExercise.ExerciseCategory.chest;
    }

    // Back - Dorso/Schiena
    if (upperFocus.any((f) => ['DORSO', 'BACK', 'LAT', 'LATS', 'TRAP', 'TRAPS', 'SCHIENA'].contains(f))) {
      return WorkoutExercise.ExerciseCategory.back;
    }

    // Shoulders - Spalle
    if (upperFocus.any((f) => ['SPALLE', 'DELT', 'SHOULDERS', 'SHOULDER'].contains(f))) {
      return WorkoutExercise.ExerciseCategory.shoulders;
    }

    // Arms - Braccia
    if (upperFocus.any((f) => ['BICIPITI', 'TRICIPITI', 'ARMS', 'BRACCI', 'BIC', 'TRIC', 'BICEPS', 'TRICEPS', 'AVAMB', 'FOREARMS'].contains(f))) {
      return WorkoutExercise.ExerciseCategory.arms;
    }

    // Legs - Gambe
    if (upperFocus.any((f) => ['QUAD', 'GLUT', 'FEMOR', 'POLP', 'LEGS', 'GAMBE', 'HAM', 'HAMSTRINGS', 'CALVES'].contains(f))) {
      return WorkoutExercise.ExerciseCategory.legs;
    }

    // Core/Abs - Addome
    if (upperFocus.any((f) => ['CORE', 'ADDOME', 'ABS', 'ADDOM'].contains(f))) {
      return WorkoutExercise.ExerciseCategory.abs;
    }

    // Cardio
    if (upperFocus.any((f) => f == 'CARDIO')) {
      return WorkoutExercise.ExerciseCategory.cardio;
    }

    return WorkoutExercise.ExerciseCategory.other;
  }

  /// Mappa nomi di muscoli (IT/EN) ai codici standardizzati
  ///
  /// Usato per reverse mapping quando si crea un esercizio custom
  /// e si vuole convertire "Pettorali" → "PET"
  ///
  /// Esempio:
  /// ```dart
  /// mapMuscleNameToCode('Pettorali')    // → 'PET'
  /// mapMuscleNameToCode('Quadricipiti') // → 'QUAD'
  /// mapMuscleNameToCode('Chest')        // → 'PET'
  /// mapMuscleNameToCode('Unknown')      // → 'OTHER'
  /// ```
  static String mapMuscleNameToCode(String muscleName) {
    final mappings = {
      'pettorali': 'PET',
      'chest': 'PET',
      'petto': 'PET',
      'dorsali': 'LAT',
      'back': 'LAT',
      'dorso': 'LAT',
      'lats': 'LAT',
      'deltoidi': 'DELT',
      'shoulders': 'DELT',
      'spalle': 'DELT',
      'bicipiti': 'BIC',
      'biceps': 'BIC',
      'tricipiti': 'TRIC',
      'triceps': 'TRIC',
      'trapezi': 'TRAP',
      'traps': 'TRAP',
      'quadricipiti': 'QUAD',
      'quads': 'QUAD',
      'glutei': 'GLUT',
      'glutes': 'GLUT',
      'femorali': 'FEMOR',
      'hamstrings': 'FEMOR',
      'polpacci': 'POLP',
      'calves': 'POLP',
      'addominali': 'ADDOM',
      'abs': 'ADDOM',
      'core': 'CORE',
      'avambracci': 'AVAMB',
      'forearms': 'AVAMB',
    };

    // Cerca il mapping usando contains per match parziale
    final lowerMuscleName = muscleName.toLowerCase();
    for (final entry in mappings.entries) {
      if (lowerMuscleName.contains(entry.key)) {
        return entry.value;
      }
    }

    return 'OTHER';
  }

  /// Converte un codice muscolo al nome IT display-friendly
  ///
  /// Esempio:
  /// ```dart
  /// mapMuscleCodeToName('PET')  // → 'Pettorali'
  /// mapMuscleCodeToName('QUAD') // → 'Quadricipiti'
  /// ```
  static String mapMuscleCodeToName(String code) {
    final mappings = {
      'PET': 'Pettorali',
      'PETTO': 'Pettorali',
      'LAT': 'Dorsali',
      'DORSO': 'Dorsali',
      'DELT': 'Deltoidi',
      'SPALLE': 'Deltoidi',
      'BIC': 'Bicipiti',
      'TRIC': 'Tricipiti',
      'TRAP': 'Trapezi',
      'QUAD': 'Quadricipiti',
      'GLUT': 'Glutei',
      'FEMOR': 'Femorali',
      'POLP': 'Polpacci',
      'ADDOM': 'Addominali',
      'CORE': 'Core',
      'AVAMB': 'Avambracci',
    };

    return mappings[code.toUpperCase()] ?? code;
  }
}
