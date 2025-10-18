/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/data/repositories
/// 🎯 Feature: exercise_database
/// 🔧 Type: repository (HYBRID)
///
/// Repository ibrido per esercizi: Cache locale + Firebase + JSON asset fallback
library;

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/core/data/repositories/optimized_base_hybrid_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/models/exercise_model.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_cache_manager.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_version_service.dart';

class HybridExerciseRepository extends OptimizedBaseHybridRepository<Exercise> {

  HybridExerciseRepository({
    ExerciseCacheManager? cacheManager,
    ExerciseVersionService? versionService,
    super.firestore,
    super.auth,
    required this.locale,
  }) : _cacheManager = cacheManager ?? ExerciseCacheManager(),
       _versionService = versionService ?? ExerciseVersionService(),
       super(
         featureName: 'exercises',
         collectionName: _exercisesCollection,
         requiresPremiumForCloud: false,
       ) {
    _initialize();
  }
  final ExerciseCacheManager _cacheManager;
  final ExerciseVersionService _versionService;
  final Locale locale;

  static const String _exercisesCollection = 'exercises_master';
  static const Duration _syncInterval = Duration(days: 7); // Weekly sync check

  Timer? _syncTimer;
  final StreamController<SyncStatus> _syncStatusController = StreamController.broadcast();

  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  /// Inizializza il repository
  Future<void> _initialize() async {
    try {
      await _cacheManager.initialize();
      await _versionService.initialize();

      // Avvia sincronizzazione periodica
      _startPeriodicSync();

      debugPrint('✅ HybridExerciseRepository initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize HybridExerciseRepository: $e');
    }
  }

  /// Ottiene tutti gli esercizi (priorità: Cache → Firebase → JSON asset)
  Future<List<Exercise>> getAllExercises() async {
    try {
      _syncStatusController.add(SyncStatus.loading);

      // 1. Prova cache locale prima
      final cachedExercises = await _cacheManager.getCachedExercises();
      if (cachedExercises.isNotEmpty) {
        debugPrint('📱 Loaded ${cachedExercises.length} exercises from cache');
        _syncStatusController.add(SyncStatus.success);

        // Avvia sync in background se necessario
        _syncInBackground();

        return cachedExercises;
      }

      // 2. Se cache vuota, prova Firebase
      final firebaseExercises = await _getExercisesFromFirebase();
      if (firebaseExercises.isNotEmpty) {
        debugPrint('☁️ Loaded ${firebaseExercises.length} exercises from Firebase');

        // Cache per usi futuri
        final versionInfo = await _versionService.getRemoteVersion();
        if (versionInfo != null) {
          await _cacheManager.cacheExercises(firebaseExercises, versionInfo.version);
          await _versionService.setLocalVersion(versionInfo.version);
        }

        _syncStatusController.add(SyncStatus.success);
        return firebaseExercises;
      }

      // 3. Fallback: carica da JSON asset
      debugPrint('📄 Falling back to JSON asset...');
      final assetExercises = await _getExercisesFromAsset();

      if (assetExercises.isNotEmpty) {
        // Cache anche il JSON asset per performance future
        await _cacheManager.cacheExercises(assetExercises, '1.0.0-asset');
        await _versionService.setLocalVersion('1.0.0-asset');
      }

      _syncStatusController.add(SyncStatus.success);
      return assetExercises;

    } catch (e) {
      debugPrint('❌ Failed to get exercises: $e');
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
               exercise.muscoliSecondariDisplayName.toLowerCase().contains(lowerQuery);
      }).toList();

    } catch (e) {
      debugPrint('❌ Failed to search exercises: $e');
      return [];
    }
  }

  /// Ottiene esercizi per focus
  Future<List<Exercise>> getExercisesByFocus(List<String> focusGroups) async {
    try {
      // Prova cache prima
      final cachedResults = await _cacheManager.getCachedExercisesByFocus(focusGroups);
      if (cachedResults.isNotEmpty) {
        return cachedResults;
      }

      // Fallback a tutti gli esercizi
      final allExercises = await getAllExercises();
      return allExercises.where((exercise) {
        return exercise.focus.any((focus) => focusGroups.contains(focus));
      }).toList();

    } catch (e) {
      debugPrint('❌ Failed to get exercises by focus: $e');
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
      debugPrint('❌ Failed to get exercise by ID: $e');
      return null;
    }
  }

  /// Forza sincronizzazione manuale
  Future<bool> forceSyncFromFirebase() async {
    try {
      _syncStatusController.add(SyncStatus.syncing);
      debugPrint('🔄 Forcing sync from Firebase...');

      final firebaseExercises = await _getExercisesFromFirebase();
      if (firebaseExercises.isEmpty) {
        _syncStatusController.add(SyncStatus.error);
        return false;
      }

      // Aggiorna cache
      final versionInfo = await _versionService.getRemoteVersion();
      if (versionInfo != null) {
        await _cacheManager.cacheExercises(firebaseExercises, versionInfo.version);
        await _versionService.markUpdateCompleted(versionInfo.version, firebaseExercises.length);
      }

      _syncStatusController.add(SyncStatus.success);
      debugPrint('✅ Force sync completed: ${firebaseExercises.length} exercises');
      return true;

    } catch (e) {
      debugPrint('❌ Force sync failed: $e');
      _syncStatusController.add(SyncStatus.error);
      return false;
    }
  }

  /// Controlla e applica aggiornamenti se disponibili
  Future<bool> checkAndApplyUpdates() async {
    try {
      final versionCheck = await _versionService.checkForUpdates();

      if (!versionCheck.hasUpdates) {
        debugPrint('✅ No updates available');
        return false;
      }

      debugPrint('🆕 Updates available: ${versionCheck.localVersion} → ${versionCheck.remoteVersion?.version}');

      return await forceSyncFromFirebase();

    } catch (e) {
      debugPrint('❌ Failed to check/apply updates: $e');
      return false;
    }
  }

  /// Stream per monitorare aggiornamenti disponibili
  Stream<VersionCheckResult> watchForUpdates() {
    return _versionService.watchVersionChanges();
  }

  /// Ottiene esercizi da Firebase
  Future<List<Exercise>> _getExercisesFromFirebase() async {
    try {
      final snapshot = await firestore
          .collection(_exercisesCollection)
          .orderBy('name')
          .get();

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
          debugPrint('⚠️ Failed to parse exercise ${doc.id}: $e');
        }
      }

      return exercises;

    } catch (e) {
      debugPrint('❌ Failed to get exercises from Firebase: $e');
      return [];
    }
  }

  /// Ottiene esercizi da JSON asset (fallback)
  Future<List<Exercise>> _getExercisesFromAsset() async {
    try {
      // Load the correct JSON file based on locale
      final String fileName = locale.languageCode == 'it'
          ? 'assets/data/exercises_it.json'
          : 'assets/data/exercises.json';

      final String jsonString = await rootBundle.loadString(fileName);
      final List<dynamic> jsonList = json.decode(jsonString);

      return jsonList
          .map((json) => ExerciseModel.fromJson(json).toEntity())
          .toList();

    } catch (e) {
      debugPrint('❌ Failed to load exercises from asset: $e');
      return [];
    }
  }

  /// Converte formato Firebase a formato JSON locale
  Map<String, dynamic> _convertFirebaseToLocalFormat(Map<String, dynamic> firebaseData) {
    // Converte da formato Firebase (ExerciseTemplate) a formato JSON locale
    return {
      'id': firebaseData['id'] ?? '',
      'nome': firebaseData['name'] ?? '',
      'focus': _convertMuscleGroupsToFocus(firebaseData['muscleGroups'] ?? []),
      'imageUrl': firebaseData['imageUrl'] ?? '',
      'muscoliSecondari': _convertSecondaryMuscles(firebaseData['secondaryMuscles'] ?? []),
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
  String _convertMuscleGroupsToFocus(List<dynamic> muscleGroups) {
    if (muscleGroups.isEmpty) return 'VARIO';

    final focusMap = {
      'chest': 'PETT',
      'back': 'DORS',
      'shoulders': 'DELT',
      'biceps': 'BRAC',
      'triceps': 'TRIC',
      'quadriceps': 'QUAD',
      'hamstrings': 'FEMOR',
      'glutes': 'GLUT',
      'calves': 'POLP',
      'core': 'CORE',
    };

    final convertedFocus = muscleGroups
        .map((muscle) => focusMap[muscle.toString().toLowerCase()] ?? muscle.toString().toUpperCase())
        .toList();

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
        debugPrint('🔄 Background sync completed with updates');
      }
    } catch (e) {
      debugPrint('❌ Background sync failed: $e');
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
    debugPrint('🧹 Exercise cache cleared');
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

/// Stato della sincronizzazione
enum SyncStatus {
  idle,
  loading,
  syncing,
  success,
  error,
}