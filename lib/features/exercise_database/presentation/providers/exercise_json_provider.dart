import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Provider che carica gli esercizi dal file JSON
final exerciseJsonProvider = FutureProvider<List<Exercise>>((ref) async {
  try {
    // Carica il file JSON
    final String jsonString = await rootBundle.loadString('assets/data/exercises.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    
    // Converte in Exercise entities
    final exercises = jsonData.map((item) {
      return Exercise(
        id: item['id'] ?? '',
        name: item['nome'] ?? item['name'] ?? '',
        type: _getExerciseType(item['tipoEsercizio']),
        category: _getExerciseCategory(item['focus']),
        notes: item['noteTecniche'],
      );
    }).toList();
    
    return exercises;
  } catch (e) {
    print('Error loading exercises: $e');
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
  
  final focusLower = focus.toLowerCase();
  
  if (focusLower.contains('pett') || focusLower.contains('chest')) {
    return ExerciseCategory.chest;
  } else if (focusLower.contains('dors') || focusLower.contains('back') || focusLower.contains('lat')) {
    return ExerciseCategory.back;
  } else if (focusLower.contains('spall') || focusLower.contains('delt') || focusLower.contains('shoulder')) {
    return ExerciseCategory.shoulders;
  } else if (focusLower.contains('bicipit') || focusLower.contains('bicep')) {
    return ExerciseCategory.arms;
  } else if (focusLower.contains('tricipit') || focusLower.contains('tricep')) {
    return ExerciseCategory.arms;
  } else if (focusLower.contains('quad') || focusLower.contains('femor') || focusLower.contains('leg') || focusLower.contains('gamb')) {
    return ExerciseCategory.legs;
  } else if (focusLower.contains('glut')) {
    return ExerciseCategory.legs;
  } else if (focusLower.contains('core') || focusLower.contains('add') || focusLower.contains('abs')) {
    return ExerciseCategory.abs;
  } else if (focusLower.contains('cardio')) {
    return ExerciseCategory.cardio;
  } else if (focusLower.contains('polp') || focusLower.contains('calf')) {
    return ExerciseCategory.legs;
  } else {
    return ExerciseCategory.other;
  }
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