import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart' as db_exercise;
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_fuzzy_matcher.dart';

class ExerciseSearchService {
  factory ExerciseSearchService() => _instance;
  ExerciseSearchService._internal();
  static final ExerciseSearchService _instance = ExerciseSearchService._internal();

  List<Map<String, dynamic>> _exercisesData = [];
  String? _cachedLocaleCode;

  // Mapping categorie generiche a muscoli specifici
  static const Map<String, List<String>> categoryMappings = {
    // Categorie generali
    'upper body': ['PET', 'LAT', 'SCH', 'DORS', 'DORSO', 'DELT', 'DEL', 'SPALLA', 'BIC', 'TRIC', 'TRAP', 'ROMBOIDI', 'AVAMB'],
    'lower body': ['QUAD', 'GLUT', 'GLUTEI', 'FEMOR', 'POLP', 'LOM', 'ADDU'],
    'core': ['CORE', 'ADDOM', 'ABD', 'OBLIQ'],
    'full body': ['PET', 'LAT', 'SCH', 'DORS', 'DELT', 'DEL', 'BIC', 'TRIC', 'QUAD', 'GLUT', 'GLUTEI', 'FEMOR'],

    // Pattern di movimento
    'push': ['PET', 'TRIC', 'DELT', 'DEL', 'SPALLA'],
    'pull': ['LAT', 'SCH', 'DORS', 'DORSO', 'BIC', 'TRAP', 'ROMBOIDI', 'AVAMB'],
    'legs': ['QUAD', 'GLUT', 'GLUTEI', 'FEMOR', 'POLP', 'LOM', 'ADDU'],
    'hinge': ['FEMOR', 'GLUT', 'GLUTEI', 'LOM', 'TRAP'],
    'squat': ['QUAD', 'GLUT', 'GLUTEI'],

    // Sinonimi italiano -> codici muscoli
    'petto': ['PET'],
    'pettorali': ['PET'],
    'chest': ['PET'],

    'schiena': ['LAT', 'SCH', 'DORS', 'DORSO', 'TRAP', 'ROMBOIDI'],
    'dorsali': ['LAT', 'SCH', 'DORS', 'DORSO'],
    'back': ['LAT', 'SCH', 'DORS', 'DORSO', 'TRAP', 'ROMBOIDI'],
    'lats': ['LAT', 'SCH', 'DORS', 'DORSO'],

    'spalle': ['DELT', 'DEL', 'SPALLA'],
    'deltoidi': ['DELT', 'DEL'],
    'shoulders': ['DELT', 'DEL', 'SPALLA'],

    'braccia': ['BIC', 'TRIC', 'AVAMB'],
    'bicipiti': ['BIC'],
    'tricipiti': ['TRIC'],
    'arms': ['BIC', 'TRIC', 'AVAMB'],
    'biceps': ['BIC'],
    'triceps': ['TRIC'],

    'gambe': ['QUAD', 'GLUT', 'GLUTEI', 'FEMOR', 'POLP', 'LOM', 'ADDU'],
    'quadricipiti': ['QUAD'],
    'quads': ['QUAD'],
    'glutei': ['GLUT', 'GLUTEI'],
    'glutes': ['GLUT', 'GLUTEI'],
    'femorali': ['FEMOR'],
    'hamstrings': ['FEMOR'],
    'polpacci': ['POLP'],
    'calves': ['POLP'],
    'lombari': ['LOM'],
    'lower back': ['LOM'],
    'adduttori': ['ADDU'],
    'adductors': ['ADDU'],

    'addominali': ['ADDOM', 'ABD'],
    'abs': ['ADDOM', 'ABD'],
    'addome': ['ADDOM', 'ABD'],

    'trapezi': ['TRAP'],
    'traps': ['TRAP'],

    'avambracci': ['AVAMB'],
    'forearms': ['AVAMB'],
  };

  // Mapping completo dei nomi dei muscoli
  static const Map<String, String> muscleNameMappings = {
    'PET': 'Pettorali',
    'LAT': 'Dorsali',
    'SCH': 'Dorsali',
    'DORS': 'Dorsali',
    'DORSO': 'Dorsali',
    'DELT': 'Deltoidi',
    'DEL': 'Deltoidi',
    'SPALLA': 'Spalle',
    'BIC': 'Bicipiti',
    'TRIC': 'Tricipiti',
    'TRAP': 'Trapezi',
    'ROMBOIDI': 'Romboidi',
    'QUAD': 'Quadricipiti',
    'GLUT': 'Glutei',
    'GLUTEI': 'Glutei',
    'FEMOR': 'Femorali',
    'POLP': 'Polpacci',
    'LOM': 'Lombari',
    'ADDOM': 'Addominali',
    'ABD': 'Addominali',
    'OBLIQ': 'Obliqui',
    'AVAMB': 'Avambracci',
    'ADDU': 'Adduttori',
    'CORE': 'Core',
    'COLLO': 'Collo',
  };

  Future<void> loadExercises([Locale? locale]) async {
    final localeCode = locale?.languageCode ?? 'en';

    // Clear cache if locale changed
    if (_cachedLocaleCode != localeCode) {
      _exercisesData = [];
      _cachedLocaleCode = localeCode;
    }

    if (_exercisesData.isNotEmpty) return;

    try {
      // Load the correct JSON file based on locale
      final String fileName = localeCode == 'it'
          ? 'assets/data/exercises_it.json'
          : 'assets/data/exercises.json';

      final String jsonString = await rootBundle.loadString(fileName);
      final List<dynamic> jsonData = json.decode(jsonString);
      _exercisesData = jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading exercises: $e');
      }
      _exercisesData = [];
    }
  }

  Future<List<ExerciseTemplate>> searchExercises(String query, [Locale? locale]) async {
    // Ensure exercises are loaded with correct locale
    await loadExercises(locale);

    final queryLower = query.toLowerCase().trim();

    if (queryLower.isEmpty) {
      return _getAllExercises();
    }

    // Check if query matches a category mapping
    final mappedMuscles = _getMappedMuscles(queryLower);

    if (mappedMuscles.isNotEmpty) {
      return _searchByMuscles(mappedMuscles);
    }

    // Standard fuzzy search in name, muscles, and aliases
    return await _standardSearch(queryLower);
  }

  List<String> _getMappedMuscles(String query) {
    final muscles = <String>{};

    // Check exact matches first
    if (categoryMappings.containsKey(query)) {
      muscles.addAll(categoryMappings[query]!);
    }

    // Check partial matches
    for (final entry in categoryMappings.entries) {
      if (entry.key.contains(query) || query.contains(entry.key)) {
        muscles.addAll(entry.value);
      }
    }

    // Check if query is a muscle code directly
    final upperQuery = query.toUpperCase();
    if (muscleNameMappings.containsKey(upperQuery)) {
      muscles.add(upperQuery);
    }

    return muscles.toList();
  }

  List<ExerciseTemplate> _searchByMuscles(List<String> muscles) {
    final results = <ExerciseTemplate>[];

    for (final exerciseData in _exercisesData) {
      final focus = exerciseData['focus'] as String?;
      if (focus == null) continue;

      // Check if any of the target muscles are in the exercise focus
      bool matches = false;
      for (final muscle in muscles) {
        if (focus.contains(muscle)) {
          matches = true;
          break;
        }
      }

      if (matches) {
        results.add(_mapToExerciseTemplate(exerciseData));
      }
    }

    return results;
  }

  Future<List<ExerciseTemplate>> _standardSearch(String query) async {
    // Convert JSON data to Exercise entities for fuzzy matching
    final exercises = _exercisesData
        .map((data) => db_exercise.Exercise.fromJson(data))
        .toList();

    // Perform fuzzy search
    final fuzzyResults = await ExerciseFuzzyMatcher.searchExercises(
      exercises: exercises,
      query: query,
      strictThreshold: 0.85, // Match quasi esatti
      typeThreshold: 0.65,   // Tolleranza typos
      maxResults: 50,        // Limita risultati per performance
    );

    // Convert fuzzy results to ExerciseTemplate
    final results = <ExerciseTemplate>[];
    for (final fuzzyResult in fuzzyResults) {
      // Find original JSON data for the matched exercise
      final exerciseData = _exercisesData.firstWhere(
        (data) => data['id'] == fuzzyResult.exercise.id,
        orElse: () => <String, dynamic>{},
      );

      if (exerciseData.isNotEmpty) {
        results.add(_mapToExerciseTemplate(exerciseData));
      }
    }

    return results;
  }

  List<ExerciseTemplate> _getAllExercises() {
    return _exercisesData.map(_mapToExerciseTemplate).toList();
  }

  ExerciseTemplate _mapToExerciseTemplate(Map<String, dynamic> data) {
    // Map muscle codes to readable names
    final focus = data['focus'] as String? ?? '';
    final muscleGroups = _parseMuscleGroups(focus);

    // Determine category based on primary muscle
    final category = _determineCategory(focus);

    return ExerciseTemplate(
      id: data['id'] ?? '',
      name: data['nome'] ?? '',
      description: '${data['focus'] ?? ''} - ${data['tipoEsercizio'] ?? ''}',
      category: category,
      type: ExerciseType.single,
      muscleGroups: muscleGroups,
      equipment: [data['attrezzatura'] ?? 'Nessuna'],
      instructions: [
        if (data['noteTecniche'] != null) data['noteTecniche'],
        if (data['tempoNote'] != null) 'Tempo: ${data['tempoNote']}',
      ],
      imageUrl: data['imageUrl'],
      difficulty: data['difficolta'] ?? 'Intermedio',
      isActive: true,
    );
  }

  List<String> _parseMuscleGroups(String focus) {
    final groups = <String>[];
    final parts = focus.split(',').map((s) => s.trim()).toList();

    for (final part in parts) {
      final muscleName = muscleNameMappings[part];
      if (muscleName != null) {
        groups.add(muscleName);
      } else {
        groups.add(part);
      }
    }

    return groups;
  }

  ExerciseCategory _determineCategory(String focus) {
    final primaryMuscle = focus.split(',').first.trim();

    switch (primaryMuscle) {
      case 'PET':
        return ExerciseCategory.chest;
      case 'LAT':
      case 'TRAP':
      case 'ROMBOIDI':
        return ExerciseCategory.back;
      case 'DELT':
      case 'DEL':
        return ExerciseCategory.shoulders;
      case 'BIC':
      case 'TRIC':
      case 'AVAMB':
        return ExerciseCategory.arms;
      case 'QUAD':
      case 'GLUT':
      case 'FEMOR':
      case 'POLP':
      case 'ADDU':
        return ExerciseCategory.legs;
      case 'ADDOM':
      case 'OBLIQ':
      case 'CORE':
        return ExerciseCategory.abs;
      default:
        return ExerciseCategory.other;
    }
  }

  // Quick filter buttons data
  static const List<Map<String, dynamic>> quickFilters = [
    {'label': 'Upper Body', 'icon': '💪', 'query': 'upper body'},
    {'label': 'Lower Body', 'icon': '🦵', 'query': 'lower body'},
    {'label': 'Core', 'icon': '🎯', 'query': 'core'},
    {'label': 'Push', 'icon': '🫸', 'query': 'push'},
    {'label': 'Pull', 'icon': '🫷', 'query': 'pull'},
    {'label': 'Full Body', 'icon': '🏋️', 'query': 'full body'},
  ];
}