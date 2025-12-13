import 'package:gymbro_flutter_new/features/exercise_database/data/utils/exercise_json_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_selection_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

/// Provider ottimizzato per il caricamento lazy degli esercizi
final optimizedExerciseProviderProvider = AsyncNotifierProvider<OptimizedExerciseNotifier, List<ExerciseData>>(OptimizedExerciseNotifier.new);

/// Provider per la ricerca degli esercizi
final exerciseSearchProvider = StateProvider<String>((ref) => '');

/// Provider per i risultati filtrati della ricerca
final filteredExercisesProvider = Provider<List<ExerciseData>>((ref) {
  final exercisesAsync = ref.watch(optimizedExerciseProviderProvider);
  final exercises = exercisesAsync.valueOrNull ?? [];
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
  final exercisesAsync = ref.watch(optimizedExerciseProviderProvider);
  final exercises = exercisesAsync.valueOrNull ?? [];
  
  final Map<String, List<ExerciseData>> grouped = {};
  
  for (final exercise in exercises) {
    final category = exercise.category;
    grouped.putIfAbsent(category, () => []).add(exercise);
  }
  
  return grouped;
});

class OptimizedExerciseNotifier extends AsyncNotifier<List<ExerciseData>> {
  // Cache statica per evitare ricaricamenti multipli
  static List<ExerciseData>? _cachedExercises;
  static DateTime? _lastLoadTime;
  static String? _cachedLanguageCode;
  static const Duration _cacheExpiry = Duration(hours: 1);

  @override
  Future<List<ExerciseData>> build() async {
    // Get language code from app config
    final config = ref.watch(appConfigProvider);
    final languageCode = config.languageCode;

    return await _loadExercises(languageCode);
  }

  Future<List<ExerciseData>> _loadExercises(String languageCode) async {
    try {
      // Controlla cache (invalida se lingua cambiata)
      if (_cachedExercises != null &&
          _lastLoadTime != null &&
          _cachedLanguageCode == languageCode &&
          DateTime.now().difference(_lastLoadTime!) < _cacheExpiry) {
        return _cachedExercises!;
      }

      // Carica JSON dalla nuova struttura a cartelle
      final jsonList = await ExerciseJsonLoader.loadExercises(languageCode);
      
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
      
      // Aggiorna cache con lingua
      _cachedExercises = exercises;
      _lastLoadTime = DateTime.now();
      _cachedLanguageCode = languageCode;

      return exercises;
    } catch (error) {
      // AsyncNotifier automatically handles errors when thrown
      rethrow;
    }
  }
  
  /// Ricarica forzato degli esercizi
  Future<void> refresh() async {
    _cachedExercises = null;
    _lastLoadTime = null;

    // Invalidate and rebuild the provider
    ref.invalidateSelf();
    await future; // Wait for the new build to complete
  }
  
  /// Cerca esercizi per nome
  List<ExerciseData> searchByName(String query) {
    final exercisesAsync = state;
    final exercises = exercisesAsync.valueOrNull ?? [];
    if (query.isEmpty) return exercises;
    
    final lowerQuery = query.toLowerCase();
    return exercises.where((e) => 
      e.name.toLowerCase().contains(lowerQuery)
    ).toList();
  }
  
  /// Filtra per categoria
  List<ExerciseData> filterByCategory(String category) {
    final exercisesAsync = state;
    final exercises = exercisesAsync.valueOrNull ?? [];
    return exercises.where((e) => e.category == category).toList();
  }

  /// Filtra per gruppo muscolare
  List<ExerciseData> filterByMuscleGroup(String muscleGroup) {
    final exercisesAsync = state;
    final exercises = exercisesAsync.valueOrNull ?? [];
    return exercises.where((e) =>
      e.muscleGroups.contains(muscleGroup)
    ).toList();
  }

  /// Ottieni esercizi popolari (più usati)
  List<ExerciseData> getPopularExercises({int limit = 10}) {
    final exercisesAsync = state;
    final exercises = exercisesAsync.valueOrNull ?? [];
    if (exercises.isEmpty) return [];
    
    // Per ora ritorna i primi N esercizi
    // In futuro potrebbe usare statistiche d'uso reali
    return exercises.take(limit).toList();
  }
  
  /// Ottieni suggerimenti basati su query parziale
  List<ExerciseData> getSuggestions(String partial, {int limit = 5}) {
    if (partial.length < 2) return [];

    final exercisesAsync = state;
    final exercises = exercisesAsync.valueOrNull ?? [];
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
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exercisePreloadProvider = FutureProvider.autoDispose<void>((ref) async {
  // Forza il caricamento degli esercizi all'avvio
  // Simply watching the provider will trigger the build/load
  await ref.watch(optimizedExerciseProviderProvider.future);
});