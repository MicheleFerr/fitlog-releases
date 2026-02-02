/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/data/repositories
/// 🎯 Feature: exercise_database
/// 🔧 Type: repository (HYBRID)
///
/// Repository ibrido per esercizi: Cache locale + Firebase + JSON asset fallback
library;

import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/data/repositories/optimized_base_hybrid_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/models/exercise_model.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/utils/exercise_json_loader.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_cache_manager.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_version_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/sync_status.dart';

class HybridExerciseRepository extends OptimizedBaseHybridRepository<Exercise> {
  HybridExerciseRepository({
    required super.boxManager,
    ExerciseCacheManager? cacheManager,
    ExerciseVersionService? versionService,
    super.firestore,
    super.auth,
    required this.locale,
  }) : _cacheManager = cacheManager ?? ExerciseCacheManager(),
       _versionService = versionService ?? ExerciseVersionService(),
       super(
         featureName: 'exercises',
         collectionName:
             _baseCollectionName, // Base name for super(), actual queries use _firestoreCollection
         requiresPremiumForCloud: false,
       ) {
    _initialize();
  }
  final ExerciseCacheManager _cacheManager;
  final ExerciseVersionService _versionService;
  final Locale locale;

  // FIX: Collection name is now dynamic based on locale
  // The static const is kept for super() constructor compatibility
  static const String _baseCollectionName = 'exercises';
  static const Duration _syncInterval = Duration(days: 7); // Weekly sync check

  /// Dynamic Firestore collection based on user locale
  /// Returns: exercises_it, exercises_en, etc.
  String get _firestoreCollection => 'exercises_${locale.languageCode}';

  Timer? _syncTimer;
  final StreamController<SyncStatus> _syncStatusController =
      StreamController.broadcast();

  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  /// Inizializza il repository
  Future<void> _initialize() async {
    try {
      await _cacheManager.initialize();
      await _versionService.initialize();

      // Avvia sincronizzazione periodica
      _startPeriodicSync();

      if (kDebugMode) {
        debugPrint('✅ HybridExerciseRepository initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to initialize HybridExerciseRepository: $e');
      }
    }
  }

  /// Ottiene tutti gli esercizi (priorità: Cache → Firebase → JSON asset)
  Future<List<Exercise>> getAllExercises() async {
    final currentLocale = locale.languageCode;

    try {
      _syncStatusController.add(SyncStatus.loading);

      // 1. Prova cache locale prima (con controllo locale)
      final cachedExercises = await _cacheManager.getCachedExercises(
        forLocale: currentLocale,
      );
      if (cachedExercises.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
            '📱 Loaded ${cachedExercises.length} exercises from cache (locale: $currentLocale)',
          );
        }
        _syncStatusController.add(SyncStatus.success);

        // Avvia sync in background se necessario
        _syncInBackground();

        return cachedExercises;
      }

      // 2. Se cache vuota, prova Firebase
      final firebaseExercises = await _getExercisesFromFirebase();
      if (firebaseExercises.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
            '☁️ Loaded ${firebaseExercises.length} exercises from Firebase',
          );
        }

        // Cache per usi futuri con locale
        final versionInfo = await _versionService.getRemoteVersion();
        if (versionInfo != null) {
          await _cacheManager.cacheExercises(
            firebaseExercises,
            versionInfo.version,
            locale: currentLocale,
          );
          await _versionService.setLocalVersion(versionInfo.version);
        }

        _syncStatusController.add(SyncStatus.success);
        return firebaseExercises;
      }

      // 3. Fallback: carica da JSON asset (già localizzato)
      if (kDebugMode) {
        debugPrint('📄 Falling back to JSON asset (locale: $currentLocale)...');
      }
      final assetExercises = await _getExercisesFromAsset();

      if (assetExercises.isNotEmpty) {
        // Cache il JSON asset con la locale corretta
        await _cacheManager.cacheExercises(
          assetExercises,
          '1.0.0-asset',
          locale: currentLocale,
        );
        await _versionService.setLocalVersion('1.0.0-asset');
      }

      _syncStatusController.add(SyncStatus.success);
      return assetExercises;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get exercises: $e');
      }
      _syncStatusController.add(SyncStatus.error);
      rethrow;
    }
  }

  /// Cerca esercizi
  Future<List<Exercise>> searchExercises(String query) async {
    try {
      // Cerca prima nella cache per performance
      final cachedResults = await _cacheManager.searchCachedExercises(query);
      if (cachedResults.isNotEmpty || query.isEmpty) {
        return cachedResults;
      }

      // Se cache vuota, usa getAllExercises che gestisce fallback
      final allExercises = await getAllExercises();

      if (query.isEmpty) return allExercises;

      final lowerQuery = query.toLowerCase();
      return allExercises.where((exercise) {
        return exercise.nome.toLowerCase().contains(lowerQuery) ||
            exercise.focusDisplayName.toLowerCase().contains(lowerQuery) ||
            exercise.attrezzatura.toLowerCase().contains(lowerQuery) ||
            exercise.muscoliSecondariDisplayName.toLowerCase().contains(
              lowerQuery,
            );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to search exercises: $e');
      }
      return [];
    }
  }

  /// Ottiene esercizi per focus
  Future<List<Exercise>> getExercisesByFocus(List<String> focusGroups) async {
    try {
      // Prova cache prima
      final cachedResults = await _cacheManager.getCachedExercisesByFocus(
        focusGroups,
      );
      if (cachedResults.isNotEmpty) {
        return cachedResults;
      }

      // Fallback a tutti gli esercizi
      final allExercises = await getAllExercises();
      return allExercises.where((exercise) {
        return exercise.focus.any((focus) => focusGroups.contains(focus));
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get exercises by focus: $e');
      }
      return [];
    }
  }

  /// Ottiene un singolo esercizio per ID
  Future<Exercise?> getExerciseById(String id) async {
    try {
      // Prova cache prima
      final cachedExercise = await _cacheManager.getCachedExercise(id);
      if (cachedExercise != null) {
        return cachedExercise;
      }

      // Se non in cache, carica tutti e cerca
      final allExercises = await getAllExercises();
      try {
        return allExercises.firstWhere((exercise) => exercise.id == id);
      } catch (e) {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get exercise by ID: $e');
      }
      return null;
    }
  }

  /// Forza sincronizzazione manuale
  Future<bool> forceSyncFromFirebase() async {
    final currentLocale = locale.languageCode;

    try {
      _syncStatusController.add(SyncStatus.syncing);
      if (kDebugMode) {
        debugPrint('🔄 Forcing sync from Firebase (locale: $currentLocale)...');
      }

      final firebaseExercises = await _getExercisesFromFirebase();

      if (firebaseExercises.isEmpty) {
        _syncStatusController.add(SyncStatus.error);
        return false;
      }

      // Aggiorna cache con locale
      final versionInfo = await _versionService.getRemoteVersion();

      if (versionInfo != null) {
        await _cacheManager.cacheExercises(
          firebaseExercises,
          versionInfo.version,
          locale: currentLocale,
        );
        await _versionService.markUpdateCompleted(
          versionInfo.version,
          firebaseExercises.length,
        );
      }

      _syncStatusController.add(SyncStatus.success);
      if (kDebugMode) {
        debugPrint(
          '✅ Force sync completed: ${firebaseExercises.length} exercises (locale: $currentLocale)',
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Force sync failed: $e');
      }
      _syncStatusController.add(SyncStatus.error);
      return false;
    }
  }

  /// Controlla e applica aggiornamenti se disponibili
  Future<bool> checkAndApplyUpdates() async {
    try {
      final versionCheck = await _versionService.checkForUpdates();

      if (!versionCheck.hasUpdates) {
        if (kDebugMode) {
          debugPrint('✅ No updates available');
        }
        return false;
      }

      if (kDebugMode) {
        debugPrint(
          '🆕 Updates available: ${versionCheck.localVersion} → ${versionCheck.remoteVersion?.version}',
        );
      }

      return await forceSyncFromFirebase();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to check/apply updates: $e');
      }
      return false;
    }
  }

  /// Stream per monitorare aggiornamenti disponibili
  Stream<VersionCheckResult> watchForUpdates() {
    return _versionService.watchVersionChanges();
  }

  /// Ottiene esercizi da Firebase
  /// Uses locale-aware collection: exercises_it, exercises_en, etc.
  /// Falls back to exercises_it if locale collection is empty
  Future<List<Exercise>> _getExercisesFromFirebase() async {
    // Try locale-specific collection first
    var exercises = await _fetchFromCollection(_firestoreCollection);

    // Fallback to Italian if locale collection is empty and we're not already using Italian
    if (exercises.isEmpty && _firestoreCollection != 'exercises_it') {
      if (kDebugMode) {
        debugPrint(
          '⚠️ $_firestoreCollection is empty, falling back to exercises_it',
        );
      }
      exercises = await _fetchFromCollection('exercises_it');
    }

    return exercises;
  }

  /// Fetches exercises from a specific Firestore collection
  Future<List<Exercise>> _fetchFromCollection(String collectionName) async {
    try {
      // NOTE: Removed orderBy('nome') - Firestore requires index for ordered queries
      // Exercises will be sorted client-side if needed
      final snapshot = await firestore.collection(collectionName).get();

      final exercises = <Exercise>[];

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;

          // Converte da formato Firebase a formato JSON locale
          final localFormat = _convertFirebaseToLocalFormat(data);
          final exercise = ExerciseModel.fromJson(localFormat).toEntity();
          exercises.add(exercise);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Failed to parse exercise ${doc.id}: $e');
          }
        }
      }

      return exercises;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get exercises from Firebase: $e');
      }
      return [];
    }
  }

  /// Ottiene esercizi da JSON asset (fallback)
  Future<List<Exercise>> _getExercisesFromAsset() async {
    try {
      final jsonList = await ExerciseJsonLoader.loadExercises(
        locale.languageCode,
      );

      return jsonList
          .map((json) => ExerciseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load exercises from asset: $e');
      }
      return [];
    }
  }

  /// Converte formato Firebase a formato JSON locale
  /// Supports both:
  /// - Direct JSON format (from publish script): nome, focus, difficolta, etc.
  /// - Legacy ExerciseTemplate format: name, muscleGroups, difficulty, etc.
  Map<String, dynamic> _convertFirebaseToLocalFormat(
    Map<String, dynamic> firebaseData,
  ) {
    // Check if data is already in local JSON format (has 'nome' field)
    if (firebaseData.containsKey('nome')) {
      // Data is already in correct format, return as-is with id
      return {
        'id': firebaseData['id'] ?? '',
        'nome': firebaseData['nome'] ?? '',
        'focus': firebaseData['focus'] ?? 'VARIO',
        'imageUrl': firebaseData['imageUrl'] ?? '',
        'muscoliSecondari': firebaseData['muscoliSecondari'] ?? '',
        'difficolta': firebaseData['difficolta'] ?? 'Intermedio',
        'tipoEsercizio': firebaseData['tipoEsercizio'] ?? 'Isolamento',
        'attrezzatura': firebaseData['attrezzatura'] ?? 'Vario',
        'patternMovimento': firebaseData['patternMovimento'] ?? '',
        'rangeRipetizioni': firebaseData['rangeRipetizioni'] ?? '8-12',
        'noteTecniche': firebaseData['noteTecniche'] ?? '',
        'mobilitaPre': firebaseData['mobilitaPre'] ?? '',
        'attivazionePre': firebaseData['attivazionePre'] ?? '',
        'warmupSets': firebaseData['warmupSets'] ?? '',
        'tempoWarmup': firebaseData['tempoWarmup'] ?? '',
        'drillTecnico': firebaseData['drillTecnico'] ?? '',
        'prevenzioneInfortuni': firebaseData['prevenzioneInfortuni'] ?? '',
        'cooldownConsigliato': firebaseData['cooldownConsigliato'] ?? '',
        'spiegazioneTermini': firebaseData['spiegazioneTermini'] ?? '',
      };
    }

    // Legacy format: convert from ExerciseTemplate format to local JSON format
    return {
      'id': firebaseData['id'] ?? '',
      'nome': firebaseData['name'] ?? '',
      'focus': _convertMuscleGroupsToFocus(firebaseData['muscleGroups'] ?? []),
      'imageUrl': firebaseData['imageUrl'] ?? '',
      'muscoliSecondari': _convertSecondaryMuscles(
        firebaseData['secondaryMuscles'] ?? [],
      ),
      'difficolta': firebaseData['difficulty'] ?? 'Intermedio',
      'tipoEsercizio': firebaseData['exerciseType'] ?? 'Isolamento',
      'attrezzatura': (firebaseData['equipment'] as List?)?.first ?? 'Vario',
      'patternMovimento': firebaseData['movementPattern'] ?? '',
      'rangeRipetizioni': firebaseData['repRange'] ?? '8-12',
      'noteTecniche': firebaseData['description'] ?? '',
      'mobilitaPre': firebaseData['preMobility'] ?? '',
      'attivazionePre': firebaseData['preActivation'] ?? '',
      'warmupSets': firebaseData['warmupSets'] ?? '',
      'tempoWarmup': firebaseData['warmupTime'] ?? '',
      'drillTecnico': firebaseData['technicalDrill'] ?? '',
      'prevenzioneInfortuni': firebaseData['injuryPrevention'] ?? '',
      'cooldownConsigliato': firebaseData['cooldownRecommended'] ?? '',
      'spiegazioneTermini': firebaseData['termExplanation'] ?? '',
    };
  }

  /// Converte muscle groups a formato focus
  ///
  /// **SINGLE SOURCE OF TRUTH**: Uses MuscleAbbreviationMapper for name → abbreviation.
  String _convertMuscleGroupsToFocus(List<dynamic> muscleGroups) {
    if (muscleGroups.isEmpty) return 'VARIO';

    final convertedFocus = muscleGroups.map((muscle) {
      final muscleName = muscle.toString().toLowerCase();
      final abbreviation = MuscleAbbreviationMapper.nameToAbbreviation(
        muscleName,
      );
      return abbreviation ?? muscle.toString().toUpperCase();
    }).toList();

    return convertedFocus.join(', ');
  }

  /// Converte secondary muscles
  String _convertSecondaryMuscles(List<dynamic> secondaryMuscles) {
    if (secondaryMuscles.isEmpty) return '';
    return _convertMuscleGroupsToFocus(secondaryMuscles);
  }

  /// Sincronizzazione in background
  Future<void> _syncInBackground() async {
    try {
      final hasUpdates = await checkAndApplyUpdates();
      if (hasUpdates) {
        if (kDebugMode) {
          debugPrint('🔄 Background sync completed with updates');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Background sync failed: $e');
      }
    }
  }

  /// Avvia sincronizzazione periodica
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(_syncInterval, (timer) {
      _syncInBackground();
    });
  }

  /// Pulisce cache locale
  Future<void> clearCache() async {
    await _cacheManager.clearCache();
    if (kDebugMode) {
      debugPrint('🧹 Exercise cache cleared');
    }
  }

  /// Reset completo per testing - cancella cache E resetta versione
  /// Dopo questo metodo, il prossimo sync scaricherà tutto da Firebase
  Future<void> resetForTesting() async {
    // 1. Clear exercise cache
    await _cacheManager.clearCache();

    // 2. Reset local version to force re-download
    await _versionService.setLocalVersion('1.0.0-reset');
  }

  /// Ottiene statistiche cache
  Future<CacheMetadata?> getCacheStats() async {
    return _cacheManager.getCacheMetadata();
  }

  // ============================================================
  // Abstract methods implementation
  // ============================================================

  @override
  Map<String, dynamic> toJson(Exercise entity) {
    return entity.toJson();
  }

  @override
  Exercise fromJson(Map<String, dynamic> json) {
    return Exercise.fromJson(json);
  }

  @override
  String getId(Exercise entity) {
    return entity.id;
  }

  @override
  bool validate(Exercise entity) {
    return entity.id.isNotEmpty &&
        entity.nome.isNotEmpty &&
        entity.focus.isNotEmpty &&
        entity.difficolta.isNotEmpty &&
        entity.tipoEsercizio.isNotEmpty &&
        entity.attrezzatura.isNotEmpty &&
        entity.patternMovimento.isNotEmpty &&
        entity.rangeRipetizioni.isNotEmpty;
  }

  @override
  Future<void> dispose() async {
    _syncTimer?.cancel();
    await _syncStatusController.close();
    await _cacheManager.dispose();
    await _versionService.dispose();
    super.dispose();
  }
}

// ✅ SyncStatus removed - now using shared/domain/entities/sync_status.dart
