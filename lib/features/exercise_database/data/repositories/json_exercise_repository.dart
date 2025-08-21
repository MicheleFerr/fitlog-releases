import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/exercise_model.dart';
import '../../domain/entities/exercise.dart';

class JsonExerciseRepository {
  List<Exercise>? _cachedExercises;

  Future<List<Exercise>> getAllExercises() async {
    if (_cachedExercises != null) {
      return _cachedExercises!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data/exercises.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      _cachedExercises = jsonList
          .map((json) => ExerciseModel.fromJson(json).toEntity())
          .toList();
      
      return _cachedExercises!;
    } catch (e) {
      throw Exception('Failed to load exercises: $e');
    }
  }

  Future<List<Exercise>> searchExercises(String query) async {
    final exercises = await getAllExercises();
    if (query.isEmpty) return exercises;

    final lowerQuery = query.toLowerCase();
    return exercises.where((exercise) {
      return exercise.nome.toLowerCase().contains(lowerQuery) ||
             exercise.focusDisplayName.toLowerCase().contains(lowerQuery) ||
             exercise.attrezzatura.toLowerCase().contains(lowerQuery) ||
             exercise.muscoliSecondariDisplayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<List<Exercise>> getExercisesByFocus(List<String> focusGroups) async {
    final exercises = await getAllExercises();
    return exercises.where((exercise) {
      return exercise.focus.any((focus) => focusGroups.contains(focus));
    }).toList();
  }

  Future<List<Exercise>> getExercisesByEquipment(List<String> equipment) async {
    final exercises = await getAllExercises();
    return exercises.where((exercise) {
      return equipment.contains(exercise.attrezzatura);
    }).toList();
  }

  Future<List<Exercise>> getExercisesByDifficulty(List<String> difficulties) async {
    final exercises = await getAllExercises();
    return exercises.where((exercise) {
      return difficulties.contains(exercise.difficolta);
    }).toList();
  }

  Future<Exercise?> getExerciseById(String id) async {
    final exercises = await getAllExercises();
    try {
      return exercises.firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get unique filter options
  Future<List<String>> getUniqueFocusGroups() async {
    final exercises = await getAllExercises();
    return exercises
        .expand((e) => e.focus)
        .toSet()
        .toList()..sort();
  }

  Future<List<String>> getUniqueEquipment() async {
    final exercises = await getAllExercises();
    return exercises
        .map((e) => e.attrezzatura)
        .toSet()
        .toList()..sort();
  }

  Future<List<String>> getUniqueDifficulties() async {
    final exercises = await getAllExercises();
    return exercises
        .map((e) => e.difficolta)
        .toSet()
        .toList()..sort();
  }

  // Clear cache to force reload
  void clearCache() {
    _cachedExercises = null;
  }
}

// Providers per il nuovo sistema
final jsonExerciseRepositoryProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = JsonExerciseRepository();
  return repository.getAllExercises();
});

final jsonExerciseRepositoryInstanceProvider = Provider<JsonExerciseRepository>((ref) {
  return JsonExerciseRepository();
});