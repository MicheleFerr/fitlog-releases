import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/converters/exercise_converter.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/utils/exercise_json_loader.dart';

/// Provider che carica gli esercizi dal file JSON
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseJsonProvider = FutureProvider.autoDispose<List<Exercise>>((ref) async {
  try {
    // Get current locale
    final locale = ref.watch(localeProvider);

    // Carica da nuova struttura a cartelle
    final jsonData = await ExerciseJsonLoader.loadExercises(locale.languageCode);
    
    // Converte in Exercise entities
    final exercises = jsonData.map((item) {
      return Exercise(
        id: item['id'] ?? '',
        name: item['nome'] ?? item['name'] ?? '',
        type: _getExerciseType(item['tipoEsercizio']),
        category: _getExerciseCategory(item['focus']),
        notes: null, // Note utente separate - non mappare noteTecniche qui
      );
    }).toList();
    
    return exercises;
  } catch (e) {
    // Ritorna una lista di fallback
    return _getFallbackExercises();
  }
});

ExerciseType _getExerciseType(String? tipo) {
  if (tipo == null) return ExerciseType.single;
  
  switch (tipo.toLowerCase()) {
    case 'superset':
      return ExerciseType.superset;
    case 'dropset':
      return ExerciseType.dropset;
    case 'restpause':
      return ExerciseType.restPause;
    default:
      return ExerciseType.single;
  }
}

ExerciseCategory _getExerciseCategory(String? focus) {
  if (focus == null) return ExerciseCategory.other;

  // Split focus string by comma to create a list (handles both single and multi-muscle)
  final focusList = focus.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  // Use centralized converter for consistent category mapping
  return ExerciseConverter.mapFocusToCategory(focusList);
}

List<Exercise> _getFallbackExercises() {
  return [
    // Chest
    Exercise(name: 'Panca Piana Bilanciere', type: ExerciseType.single, category: ExerciseCategory.chest),
    Exercise(name: 'Panca Piana Manubri', type: ExerciseType.single, category: ExerciseCategory.chest),
    Exercise(name: 'Panca Inclinata Bilanciere', type: ExerciseType.single, category: ExerciseCategory.chest),
    Exercise(name: 'Panca Inclinata Manubri', type: ExerciseType.single, category: ExerciseCategory.chest),
    Exercise(name: 'Croci Manubri', type: ExerciseType.single, category: ExerciseCategory.chest),
    Exercise(name: 'Dips', type: ExerciseType.single, category: ExerciseCategory.chest),
    Exercise(name: 'Cable Fly', type: ExerciseType.single, category: ExerciseCategory.chest),
    Exercise(name: 'Push-up', type: ExerciseType.single, category: ExerciseCategory.chest),
    
    // Back
    Exercise(name: 'Stacco da Terra', type: ExerciseType.single, category: ExerciseCategory.back),
    Exercise(name: 'Trazioni', type: ExerciseType.single, category: ExerciseCategory.back),
    Exercise(name: 'Lat Machine', type: ExerciseType.single, category: ExerciseCategory.back),
    Exercise(name: 'Rematore Bilanciere', type: ExerciseType.single, category: ExerciseCategory.back),
    Exercise(name: 'Rematore Manubrio', type: ExerciseType.single, category: ExerciseCategory.back),
    Exercise(name: 'Pulley Basso', type: ExerciseType.single, category: ExerciseCategory.back),
    Exercise(name: 'T-Bar Row', type: ExerciseType.single, category: ExerciseCategory.back),
    
    // Shoulders
    Exercise(name: 'Military Press', type: ExerciseType.single, category: ExerciseCategory.shoulders),
    Exercise(name: 'Shoulder Press Manubri', type: ExerciseType.single, category: ExerciseCategory.shoulders),
    Exercise(name: 'Alzate Laterali', type: ExerciseType.single, category: ExerciseCategory.shoulders),
    Exercise(name: 'Alzate Frontali', type: ExerciseType.single, category: ExerciseCategory.shoulders),
    Exercise(name: 'Alzate Posteriori', type: ExerciseType.single, category: ExerciseCategory.shoulders),
    Exercise(name: 'Arnold Press', type: ExerciseType.single, category: ExerciseCategory.shoulders),
    
    // Arms
    Exercise(name: 'Curl Bilanciere', type: ExerciseType.single, category: ExerciseCategory.arms),
    Exercise(name: 'Curl Manubri', type: ExerciseType.single, category: ExerciseCategory.arms),
    Exercise(name: 'Hammer Curl', type: ExerciseType.single, category: ExerciseCategory.arms),
    Exercise(name: 'Cable Curl', type: ExerciseType.single, category: ExerciseCategory.arms),
    Exercise(name: 'French Press', type: ExerciseType.single, category: ExerciseCategory.arms),
    Exercise(name: 'Tricep Pushdown', type: ExerciseType.single, category: ExerciseCategory.arms),
    Exercise(name: 'Overhead Extension', type: ExerciseType.single, category: ExerciseCategory.arms),
    
    // Legs
    Exercise(name: 'Squat', type: ExerciseType.single, category: ExerciseCategory.legs),
    Exercise(name: 'Front Squat', type: ExerciseType.single, category: ExerciseCategory.legs),
    Exercise(name: 'Leg Press', type: ExerciseType.single, category: ExerciseCategory.legs),
    Exercise(name: 'Affondi', type: ExerciseType.single, category: ExerciseCategory.legs),
    Exercise(name: 'Leg Extension', type: ExerciseType.single, category: ExerciseCategory.legs),
    Exercise(name: 'Leg Curl', type: ExerciseType.single, category: ExerciseCategory.legs),
    Exercise(name: 'Stacco Rumeno', type: ExerciseType.single, category: ExerciseCategory.legs),
    Exercise(name: 'Hip Thrust', type: ExerciseType.single, category: ExerciseCategory.legs),
    Exercise(name: 'Calf Raise', type: ExerciseType.single, category: ExerciseCategory.legs),
    
    // Abs
    Exercise(name: 'Crunch', type: ExerciseType.single, category: ExerciseCategory.abs),
    Exercise(name: 'Plank', type: ExerciseType.single, category: ExerciseCategory.abs),
    Exercise(name: 'Russian Twist', type: ExerciseType.single, category: ExerciseCategory.abs),
    Exercise(name: 'Leg Raise', type: ExerciseType.single, category: ExerciseCategory.abs),
    Exercise(name: 'Cable Crunch', type: ExerciseType.single, category: ExerciseCategory.abs),
  ];
}