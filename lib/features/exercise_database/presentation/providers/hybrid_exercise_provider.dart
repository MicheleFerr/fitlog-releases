/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/presentation/providers
/// 🎯 Feature: exercise_database
/// 🔧 Type: provider
///
/// Provider Riverpod per gestione esercizi con sistema ibrido
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/hybrid_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_sync_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_version_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_cache_manager.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/sync_status.dart';

// ====================
// REPOSITORY PROVIDERS
// ====================

/// Provider per ExerciseCacheManager
final exerciseCacheManagerProvider = Provider<ExerciseCacheManager>((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  return ExerciseCacheManager(boxManager);
});

/// Provider per ExerciseVersionService
final exerciseVersionServiceProvider = Provider<ExerciseVersionService>((ref) {
  return ExerciseVersionService();
});

/// Provider principale per HybridExerciseRepository
final hybridExerciseRepositoryProvider = Provider<HybridExerciseRepository>((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  final cacheManager = ref.read(exerciseCacheManagerProvider);
  final versionService = ref.read(exerciseVersionServiceProvider);
  final locale = ref.watch(localeProvider);

  return HybridExerciseRepository(
    boxManager: boxManager,
    cacheManager: cacheManager,
    versionService: versionService,
    locale: locale,
  );
});

/// Provider per ExerciseSyncService
final exerciseSyncServiceProvider = Provider<ExerciseSyncService>((ref) {
  final repository = ref.read(hybridExerciseRepositoryProvider);
  final versionService = ref.read(exerciseVersionServiceProvider);

  return ExerciseSyncService(
    repository: repository,
    versionService: versionService,
  );
});

// ====================
// DATA PROVIDERS
// ====================

/// Provider per tutti gli esercizi (con gestione asincrona)
final allExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ref.read(hybridExerciseRepositoryProvider);
  return repository.getAllExercises();
});

/// Provider per ricerca esercizi
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseSearchProvider = FutureProvider.autoDispose.family<List<Exercise>, String>((ref, query) async {
  final repository = ref.read(hybridExerciseRepositoryProvider);
  return repository.searchExercises(query);
});

/// Provider per esercizi filtrati per focus
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exercisesByFocusProvider = FutureProvider.autoDispose.family<List<Exercise>, List<String>>((ref, focusGroups) async {
  final repository = ref.read(hybridExerciseRepositoryProvider);
  return repository.getExercisesByFocus(focusGroups);
});

/// Provider per un singolo esercizio
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseByIdProvider = FutureProvider.autoDispose.family<Exercise?, String>((ref, exerciseId) async {
  final repository = ref.read(hybridExerciseRepositoryProvider);
  return repository.getExerciseById(exerciseId);
});

// ====================
// SYNC STATUS PROVIDERS
// ====================

/// Provider per stato sincronizzazione repository
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final exerciseSyncStatusProvider = StreamProvider.autoDispose<SyncStatus>((ref) {
  final repository = ref.read(hybridExerciseRepositoryProvider);
  return repository.syncStatus;
});

/// Provider per eventi di sincronizzazione dal service
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final exerciseSyncEventsProvider = StreamProvider.autoDispose<SyncEvent>((ref) {
  final syncService = ref.read(exerciseSyncServiceProvider);
  return syncService.syncEvents;
});

/// Provider per controllo versione in tempo reale
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final exerciseVersionWatchProvider = StreamProvider.autoDispose<VersionCheckResult>((ref) {
  final repository = ref.read(hybridExerciseRepositoryProvider);
  return repository.watchForUpdates();
});

// ====================
// UI STATE PROVIDERS
// ====================

/// Provider per query di ricerca corrente
final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider per filtri attivi
final exerciseFiltersProvider = StateProvider<ExerciseFilters>((ref) => const ExerciseFilters());

/// Provider per esercizi filtrati e ricercati
final filteredExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final query = ref.watch(exerciseSearchQueryProvider);
  final filters = ref.watch(exerciseFiltersProvider);
  final repository = ref.read(hybridExerciseRepositoryProvider);

  // Se c'è una query di ricerca, usa quella
  if (query.isNotEmpty) {
    final searchResults = await repository.searchExercises(query);
    return _applyFilters(searchResults, filters);
  }

  // Altrimenti usa filtri per focus se specificati
  if (filters.focusGroups.isNotEmpty) {
    final focusResults = await repository.getExercisesByFocus(filters.focusGroups);
    return _applyFilters(focusResults, filters);
  }

  // Fallback: tutti gli esercizi con filtri applicati
  final allExercises = await repository.getAllExercises();
  return _applyFilters(allExercises, filters);
});

/// Applica filtri agli esercizi
List<Exercise> _applyFilters(List<Exercise> exercises, ExerciseFilters filters) {
  var filtered = exercises;

  // Filtra per attrezzatura
  if (filters.equipment.isNotEmpty) {
    filtered = filtered.where((exercise) =>
      filters.equipment.contains(exercise.attrezzatura)).toList();
  }

  // Filtra per difficoltà
  if (filters.difficulties.isNotEmpty) {
    filtered = filtered.where((exercise) =>
      filters.difficulties.contains(exercise.difficolta)).toList();
  }

  // Filtra per tipo esercizio
  if (filters.exerciseTypes.isNotEmpty) {
    filtered = filtered.where((exercise) =>
      filters.exerciseTypes.contains(exercise.tipoEsercizio)).toList();
  }

  return filtered;
}

// ====================
// ACTION PROVIDERS
// ====================

/// Provider per azioni di sincronizzazione
final exerciseSyncActionsProvider = Provider<ExerciseSyncActions>((ref) {
  final syncService = ref.read(exerciseSyncServiceProvider);
  final repository = ref.read(hybridExerciseRepositoryProvider);

  return ExerciseSyncActions(
    syncService: syncService,
    repository: repository,
  );
});

// ====================
// STATISTICS PROVIDERS
// ====================

/// Provider per statistiche cache
final exerciseCacheStatsProvider = FutureProvider<CacheMetadata?>((ref) async {
  final repository = ref.read(hybridExerciseRepositoryProvider);
  return repository.getCacheStats();
});

/// Provider per informazioni versione locale
final exerciseVersionInfoProvider = FutureProvider<String>((ref) async {
  final versionService = ref.read(exerciseVersionServiceProvider);
  return versionService.getLocalVersion();
});

/// Provider per ultimo aggiornamento
final lastExerciseUpdateProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final versionService = ref.read(exerciseVersionServiceProvider);
  return versionService.getLastUpdateInfo();
});

// ====================
// FILTER CLASSES
// ====================

/// Classe per gestire filtri degli esercizi
class ExerciseFilters {

  const ExerciseFilters({
    this.focusGroups = const [],
    this.equipment = const [],
    this.difficulties = const [],
    this.exerciseTypes = const [],
  });
  final List<String> focusGroups;
  final List<String> equipment;
  final List<String> difficulties;
  final List<String> exerciseTypes;

  ExerciseFilters copyWith({
    List<String>? focusGroups,
    List<String>? equipment,
    List<String>? difficulties,
    List<String>? exerciseTypes,
  }) {
    return ExerciseFilters(
      focusGroups: focusGroups ?? this.focusGroups,
      equipment: equipment ?? this.equipment,
      difficulties: difficulties ?? this.difficulties,
      exerciseTypes: exerciseTypes ?? this.exerciseTypes,
    );
  }

  bool get isEmpty =>
    focusGroups.isEmpty &&
    equipment.isEmpty &&
    difficulties.isEmpty &&
    exerciseTypes.isEmpty;
}

/// Classe per azioni di sincronizzazione
class ExerciseSyncActions {

  ExerciseSyncActions({
    required this.syncService,
    required this.repository,
  });
  final ExerciseSyncService syncService;
  final HybridExerciseRepository repository;

  /// Forza sincronizzazione manuale
  Future<SyncResult> forceSync() async {
    return await syncService.performManualSync();
  }

  /// Abilita/disabilita auto-sync
  Future<void> setAutoSync(bool enabled) async {
    await syncService.setAutoSyncEnabled(enabled);
  }

  /// Controlla se auto-sync è abilitato
  Future<bool> isAutoSyncEnabled() async {
    return await syncService.isAutoSyncEnabled();
  }

  /// Pulisce cache locale
  Future<void> clearCache() async {
    await repository.clearCache();
  }

  /// Imposta frequenza di sincronizzazione
  Future<void> setSyncFrequency(Duration frequency) async {
    await syncService.setSyncFrequency(frequency);
  }

  /// Ottiene ultima sincronizzazione
  Future<DateTime?> getLastSyncTime() async {
    return await syncService.getLastSyncTime();
  }

  /// Controlla se serve sincronizzazione
  Future<bool> needsSync() async {
    return await syncService.needsSync();
  }
}

// ====================
// LEGACY COMPATIBILITY
// ====================

/// Provider per compatibilità con il vecchio sistema
/// Questo permette una migrazione graduale
final exerciseDatabaseProvider = allExercisesProvider;

/// Provider per repository JSON (fallback per compatibilità)
final jsonExerciseRepositoryProvider = FutureProvider<List<Exercise>>((ref) async {
  // Reindirizza al nuovo sistema ibrido
  final repository = ref.read(hybridExerciseRepositoryProvider);
  return repository.getAllExercises();
});

/// Provider istanza repository (per compatibilità)
final jsonExerciseRepositoryInstanceProvider = Provider((ref) {
  // Restituisce wrapper del nuovo repository
  return ExerciseRepositoryWrapper(ref.read(hybridExerciseRepositoryProvider));
});

/// Wrapper per mantenere compatibilità con l'API esistente
class ExerciseRepositoryWrapper {

  ExerciseRepositoryWrapper(this._hybridRepository);
  final HybridExerciseRepository _hybridRepository;

  Future<List<Exercise>> getAllExercises() => _hybridRepository.getAllExercises();
  Future<List<Exercise>> searchExercises(String query) => _hybridRepository.searchExercises(query);
  Future<List<Exercise>> getExercisesByFocus(List<String> focusGroups) => _hybridRepository.getExercisesByFocus(focusGroups);
  Future<Exercise?> getExerciseById(String id) => _hybridRepository.getExerciseById(id);

  void clearCache() => _hybridRepository.clearCache();
}