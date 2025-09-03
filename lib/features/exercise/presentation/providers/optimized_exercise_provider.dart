import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise/domain/entities/exercise_data.dart';

/// Provider ottimizzato per il caricamento lazy degli esercizi
final optimizedExerciseProviderProvider = StateNotifierProvider<OptimizedExerciseNotifier, AsyncValue<List<ExerciseData>>>((ref) {
  return OptimizedExerciseNotifier();
});

/// Provider per la ricerca degli esercizi
final exerciseSearchProvider = StateProvider<String>((ref) => '');

/// Provider per i risultati filtrati della ricerca
final filteredExercisesProvider = Provider<List<ExerciseData>>((ref) {
  final exercises = ref.watch(optimizedExerciseProviderProvider).valueOrNull ?? [];
  final searchQuery = ref.watch(exerciseSearchProvider).toLowerCase();
  
  if (searchQuery.isEmpty) {
    return exercises;
  }
  
  return exercises.where((exercise) {
    return exercise.name.toLowerCase().contains(searchQuery) ||
           exercise.category.toString().toLowerCase().contains(searchQuery) ||
           exercise.muscleGroups.any((muscle) => muscle.toLowerCase().contains(searchQuery));
  }).toList();
});

/// Provider per esercizi raggruppati per categoria
final exercisesByCategoryProvider = Provider<Map<String, List<ExerciseData>>>((ref) {
  final exercises = ref.watch(optimizedExerciseProviderProvider).valueOrNull ?? [];
  
  final Map<String, List<ExerciseData>> grouped = {};
  
  for (final exercise in exercises) {
    final category = exercise.category;
    grouped.putIfAbsent(category, () => []).add(exercise);
  }
  
  return grouped;
});

class OptimizedExerciseNotifier extends StateNotifier<AsyncValue<List<ExerciseData>>> {
  OptimizedExerciseNotifier() : super(const AsyncValue.loading()) {
    _loadExercises();
  }
  
  // Cache statica per evitare ricaricamenti multipli
  static List<ExerciseData>? _cachedExercises;
  static DateTime? _lastLoadTime;
  static const Duration _cacheExpiry = Duration(hours: 1);
  
  Future<void> _loadExercises() async {
    try {
      // Controlla cache
      if (_cachedExercises != null && 
          _lastLoadTime != null &&
          DateTime.now().difference(_lastLoadTime!) < _cacheExpiry) {
        state = AsyncValue.data(_cachedExercises!);
        return;
      }
      
      // Carica JSON in modo ottimizzato
      final jsonString = await rootBundle.loadString('assets/data/exercises.json');
      
      // Parse JSON in background usando compute se disponibile
      final List<dynamic> jsonList = json.decode(jsonString);
      
      // Converti in batch per non bloccare UI
      final exercises = <ExerciseData>[];
      const batchSize = 50;
      
      for (int i = 0; i < jsonList.length; i += batchSize) {
        final end = (i + batchSize < jsonList.length) ? i + batchSize : jsonList.length;
        final batch = jsonList.sublist(i, end);
        
        // Processa batch
        for (final json in batch) {
          exercises.add(ExerciseData.fromJson(json));
        }
        
        // Yield per non bloccare UI
        if (i % 100 == 0) {
          await Future.delayed(const Duration(microseconds: 1));
        }
      }
      
      // Aggiorna cache
      _cachedExercises = exercises;
      _lastLoadTime = DateTime.now();
      
      state = AsyncValue.data(exercises);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  /// Ricarica forzato degli esercizi
  Future<void> refresh() async {
    _cachedExercises = null;
    _lastLoadTime = null;
    state = const AsyncValue.loading();
    await _loadExercises();
  }
  
  /// Cerca esercizi per nome
  List<ExerciseData> searchByName(String query) {
    final exercises = state.valueOrNull ?? [];
    if (query.isEmpty) return exercises;
    
    final lowerQuery = query.toLowerCase();
    return exercises.where((e) => 
      e.name.toLowerCase().contains(lowerQuery)
    ).toList();
  }
  
  /// Filtra per categoria
  List<ExerciseData> filterByCategory(String category) {
    final exercises = state.valueOrNull ?? [];
    return exercises.where((e) => e.category == category).toList();
  }
  
  /// Filtra per gruppo muscolare
  List<ExerciseData> filterByMuscleGroup(String muscleGroup) {
    final exercises = state.valueOrNull ?? [];
    return exercises.where((e) => 
      e.muscleGroups.contains(muscleGroup)
    ).toList();
  }
  
  /// Ottieni esercizi popolari (più usati)
  List<ExerciseData> getPopularExercises({int limit = 10}) {
    final exercises = state.valueOrNull ?? [];
    if (exercises.isEmpty) return [];
    
    // Per ora ritorna i primi N esercizi
    // In futuro potrebbe usare statistiche d'uso reali
    return exercises.take(limit).toList();
  }
  
  /// Ottieni suggerimenti basati su query parziale
  List<ExerciseData> getSuggestions(String partial, {int limit = 5}) {
    if (partial.length < 2) return [];
    
    final exercises = state.valueOrNull ?? [];
    final lowerPartial = partial.toLowerCase();
    
    // Prima cerca match esatti all'inizio del nome
    final exactMatches = exercises.where((e) => 
      e.name.toLowerCase().startsWith(lowerPartial)
    ).take(limit).toList();
    
    if (exactMatches.length >= limit) {
      return exactMatches;
    }
    
    // Poi cerca match parziali
    final partialMatches = exercises.where((e) => 
      e.name.toLowerCase().contains(lowerPartial) &&
      !exactMatches.contains(e)
    ).take(limit - exactMatches.length).toList();
    
    return [...exactMatches, ...partialMatches];
  }
}

/// Provider per il preload degli esercizi all'avvio app
final exercisePreloadProvider = FutureProvider<void>((ref) async {
  // Forza il caricamento degli esercizi all'avvio
  await ref.read(optimizedExerciseProviderProvider.notifier)._loadExercises();
});