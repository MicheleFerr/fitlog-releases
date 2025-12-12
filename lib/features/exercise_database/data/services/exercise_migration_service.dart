/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/data/services
/// 🎯 Feature: exercise_database
/// 🔧 Type: service
///
/// Servizio per migrazione graduale da JSON locale a sistema ibrido
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/shared/domain/converters/exercise_converter.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart' as WorkoutExercise;
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/hybrid_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/json_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_version_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_cache_manager.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';

class ExerciseMigrationService {

  ExerciseMigrationService({
    required HybridExerciseRepository hybridRepository,
    required JsonExerciseRepository jsonRepository,
    required ExerciseVersionService versionService,
    required ExerciseCacheManager cacheManager,
    FirebaseFirestore? firestore,
  }) : _hybridRepository = hybridRepository,
       _jsonRepository = jsonRepository,
       _versionService = versionService,
       _cacheManager = cacheManager,
       _firestore = firestore ?? FirebaseFirestore.instance;
  final HybridExerciseRepository _hybridRepository;
  final JsonExerciseRepository _jsonRepository;
  final ExerciseVersionService _versionService;
  final ExerciseCacheManager _cacheManager;
  final FirebaseFirestore _firestore;

  static const String _migrationStatusKey = 'exercise_migration_status';
  static const String _exercisesCollection = 'exercises_master';
  static const String _metadataCollection = 'exercises_metadata';

  /// Esegue migrazione completa da JSON a sistema ibrido
  Future<MigrationResult> performMigration({bool forceReset = false}) async {
    final startTime = DateTime.now();

    try {
      if (kDebugMode) {
        debugPrint('🚀 Starting exercise migration...');
      }

      // 1. Verifica se migrazione è già stata fatta
      if (!forceReset && await _isMigrationCompleted()) {
        if (kDebugMode) {
          debugPrint('✅ Migration already completed, skipping');
        }
        return MigrationResult(
          success: true,
          message: 'Migration already completed',
          duration: DateTime.now().difference(startTime),
        );
      }

      // 2. Inizializza servizi
      await _initializeServices();

      // 3. Carica esercizi da JSON
      final jsonExercises = await _loadExercisesFromJson();
      if (kDebugMode) {
        debugPrint('📄 Loaded ${jsonExercises.length} exercises from JSON');
      }

      // 4. Setup Firebase collections (se necessario)
      await _setupFirebaseCollections(jsonExercises);

      // 5. Popola cache locale
      await _populateLocalCache(jsonExercises);

      // 6. Verifica migrazione
      await _verifyMigration(jsonExercises.length);

      // 7. Marca migrazione come completata
      await _markMigrationCompleted();

      final duration = DateTime.now().difference(startTime);
      if (kDebugMode) {
        debugPrint('✅ Migration completed successfully in ${duration.inSeconds}s');
      }

      return MigrationResult(
        success: true,
        message: 'Migration completed successfully',
        exerciseCount: jsonExercises.length,
        duration: duration,
      );

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Migration failed: $e');
      }
      return MigrationResult(
        success: false,
        message: 'Migration failed: $e',
        duration: DateTime.now().difference(startTime),
      );
    }
  }

  /// Testa il sistema ibrido confrontando con JSON
  Future<TestResult> testHybridSystem() async {
    try {
      if (kDebugMode) {
        debugPrint('🧪 Testing hybrid system...');
      }

      // 1. Carica esercizi da entrambi i sistemi
      final jsonExercises = await _jsonRepository.getAllExercises();
      final hybridExercises = await _hybridRepository.getAllExercises();

      // 2. Confronta quantità
      if (jsonExercises.length != hybridExercises.length) {
        return TestResult(
          success: false,
          message: 'Count mismatch: JSON=${jsonExercises.length}, Hybrid=${hybridExercises.length}',
        );
      }

      // 3. Confronta contenuto
      final missingInHybrid = <String>[];
      final missingInJson = <String>[];

      final jsonIds = jsonExercises.map((e) => e.id).toSet();
      final hybridIds = hybridExercises.map((e) => e.id).toSet();

      for (final id in jsonIds) {
        if (!hybridIds.contains(id)) {
          missingInHybrid.add(id);
        }
      }

      for (final id in hybridIds) {
        if (!jsonIds.contains(id)) {
          missingInJson.add(id);
        }
      }

      if (missingInHybrid.isNotEmpty || missingInJson.isNotEmpty) {
        return TestResult(
          success: false,
          message: 'Content mismatch - Missing in hybrid: ${missingInHybrid.length}, Missing in JSON: ${missingInJson.length}',
          missingInHybrid: missingInHybrid,
          missingInJson: missingInJson,
        );
      }

      // 4. Test funzionalità specifiche
      final searchTest = await _testSearchFunctionality();
      if (!searchTest.success) return searchTest;

      final filterTest = await _testFilterFunctionality();
      if (!filterTest.success) return filterTest;

      if (kDebugMode) {
        debugPrint('✅ Hybrid system test passed');
      }
      return TestResult(
        success: true,
        message: 'All tests passed successfully',
        exerciseCount: hybridExercises.length,
      );

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Hybrid system test failed: $e');
      }
      return TestResult(
        success: false,
        message: 'Test failed: $e',
      );
    }
  }

  /// Test di performance tra JSON e sistema ibrido
  Future<PerformanceTestResult> performanceTest() async {
    try {
      if (kDebugMode) {
        debugPrint('⚡ Running performance tests...');
      }

      // Test caricamento JSON
      final jsonStartTime = DateTime.now();
      final jsonExercises = await _jsonRepository.getAllExercises();
      final jsonLoadTime = DateTime.now().difference(jsonStartTime);

      // Test caricamento ibrido (cache)
      final hybridStartTime = DateTime.now();
      final hybridExercises = await _hybridRepository.getAllExercises();
      final hybridLoadTime = DateTime.now().difference(hybridStartTime);

      // Test ricerca JSON
      final jsonSearchStart = DateTime.now();
      final jsonSearchResults = await _jsonRepository.searchExercises('squat');
      final jsonSearchTime = DateTime.now().difference(jsonSearchStart);

      // Test ricerca ibrida
      final hybridSearchStart = DateTime.now();
      final hybridSearchResults = await _hybridRepository.searchExercises('squat');
      final hybridSearchTime = DateTime.now().difference(hybridSearchStart);

      if (kDebugMode) {
        debugPrint('📊 Performance Results:');
      }
      debugPrint('   JSON Load: ${jsonLoadTime.inMilliseconds}ms');
      if (kDebugMode) {
        debugPrint('   Hybrid Load: ${hybridLoadTime.inMilliseconds}ms');
      }
      debugPrint('   JSON Search: ${jsonSearchTime.inMilliseconds}ms');
      if (kDebugMode) {
        debugPrint('   Hybrid Search: ${hybridSearchTime.inMilliseconds}ms');
      }

      return PerformanceTestResult(
        jsonLoadTime: jsonLoadTime,
        hybridLoadTime: hybridLoadTime,
        jsonSearchTime: jsonSearchTime,
        hybridSearchTime: hybridSearchTime,
        jsonExerciseCount: jsonExercises.length,
        hybridExerciseCount: hybridExercises.length,
        jsonSearchResultCount: jsonSearchResults.length,
        hybridSearchResultCount: hybridSearchResults.length,
      );

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Performance test failed: $e');
      }
      rethrow;
    }
  }

  /// Inizializza tutti i servizi necessari
  Future<void> _initializeServices() async {
    await _versionService.initialize();
    await _cacheManager.initialize();
  }

  /// Carica esercizi dal JSON asset
  Future<List<Exercise>> _loadExercisesFromJson() async {
    return await _jsonRepository.getAllExercises();
  }

  /// Setup collezioni Firebase se necessario
  Future<void> _setupFirebaseCollections(List<Exercise> exercises) async {
    try {
      // 1. Verifica se metadata esiste già
      final metadataDoc = await _firestore
          .collection(_metadataCollection)
          .doc('version_info')
          .get();

      if (!metadataDoc.exists) {
        if (kDebugMode) {
          debugPrint('📝 Creating Firebase metadata...');
        }

        final versionInfo = ExerciseVersionInfo(
          version: '1.0.0',
          lastUpdated: DateTime.now(),
          totalExercises: exercises.length,
          changelog: ['Initial migration from JSON asset'],
        );

        await _firestore
            .collection(_metadataCollection)
            .doc('version_info')
            .set(versionInfo.toFirestore());
      }

      // 2. Verifica se esercizi esistono già
      final exercisesQuery = await _firestore
          .collection(_exercisesCollection)
          .limit(1)
          .get();

      if (exercisesQuery.docs.isEmpty) {
        if (kDebugMode) {
          debugPrint('📤 Uploading exercises to Firebase...');
        }
        await _uploadExercisesToFirebase(exercises);
      } else {
        if (kDebugMode) {
          debugPrint('✅ Exercises already exist in Firebase');
        }
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Firebase setup skipped (may be offline): $e');
      }
    }
  }

  /// Upload esercizi su Firebase
  Future<void> _uploadExercisesToFirebase(List<Exercise> exercises) async {
    const batchSize = 100;
    int uploaded = 0;

    for (int i = 0; i < exercises.length; i += batchSize) {
      final batch = _firestore.batch();
      final end = (i + batchSize < exercises.length) ? i + batchSize : exercises.length;

      for (int j = i; j < end; j++) {
        final exercise = exercises[j];
        final firebaseData = _convertToFirebaseFormat(exercise);
        final docRef = _firestore.collection(_exercisesCollection).doc(exercise.id);
        batch.set(docRef, firebaseData);
      }

      await batch.commit();
      uploaded += (end - i);
      if (kDebugMode) {
        debugPrint('📤 Uploaded $uploaded/${exercises.length} exercises');
      }

      // Pausa tra batch per evitare rate limiting
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Converte esercizio a formato Firebase
  Map<String, dynamic> _convertToFirebaseFormat(Exercise exercise) {
    return {
      'name': exercise.nome,
      'description': exercise.noteTecniche,
      'category': _mapFocusToCategory(exercise.focus.join(', ')),
      'type': 'single',
      'muscleGroups': exercise.focus,
      'secondaryMuscles': exercise.muscoliSecondari,
      'equipment': [exercise.attrezzatura],
      'instructions': [exercise.noteTecniche],
      'imageUrl': exercise.imageUrl,
      'difficulty': exercise.difficolta,
      'exerciseType': exercise.tipoEsercizio,
      'movementPattern': exercise.patternMovimento,
      'repRange': exercise.rangeRipetizioni,
      'warmupSets': exercise.warmupSets,
      'warmupTime': exercise.tempoWarmup,
      'preMobility': exercise.mobilitaPre,
      'preActivation': exercise.attivazionePre,
      'technicalDrill': exercise.drillTecnico,
      'injuryPrevention': exercise.prevenzioneInfortuni,
      'cooldownRecommended': exercise.cooldownConsigliato,
      'termExplanation': exercise.spiegazioneTermini,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Mappa focus a categoria Firebase
  /// Usa centralized converter internamente e converte enum a lowercase string
  String _mapFocusToCategory(String focus) {
    // Split focus string by comma to create a list
    final focusList = focus.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final category = ExerciseConverter.mapFocusToCategory(focusList);

    // Convert enum to lowercase string for Firebase
    switch (category) {
      case WorkoutExercise.ExerciseCategory.chest:
        return 'chest';
      case WorkoutExercise.ExerciseCategory.back:
        return 'back';
      case WorkoutExercise.ExerciseCategory.shoulders:
        return 'shoulders';
      case WorkoutExercise.ExerciseCategory.arms:
        return 'arms';
      case WorkoutExercise.ExerciseCategory.legs:
        return 'legs';
      case WorkoutExercise.ExerciseCategory.abs:
        return 'core';
      case WorkoutExercise.ExerciseCategory.cardio:
        return 'cardio';
      case WorkoutExercise.ExerciseCategory.other:
        return 'other';
    }
  }

  /// Popola cache locale
  Future<void> _populateLocalCache(List<Exercise> exercises) async {
    if (kDebugMode) {
      debugPrint('💾 Populating local cache...');
    }
    // Use hybrid repository's locale for cache consistency
    final locale = _hybridRepository.locale.languageCode;
    await _cacheManager.cacheExercises(exercises, '1.0.0', locale: locale);
    await _versionService.setLocalVersion('1.0.0');
  }

  /// Verifica che la migrazione sia riuscita
  Future<void> _verifyMigration(int expectedCount) async {
    final cachedExercises = await _cacheManager.getCachedExercises();

    if (cachedExercises.length != expectedCount) {
      throw Exception('Cache verification failed: expected $expectedCount, found ${cachedExercises.length}');
    }

    if (kDebugMode) {
      debugPrint('✅ Migration verification passed');
    }
  }

  /// Test funzionalità di ricerca
  Future<TestResult> _testSearchFunctionality() async {
    try {
      final searchResults = await _hybridRepository.searchExercises('squat');
      if (searchResults.isEmpty) {
        return TestResult(
          success: false,
          message: 'Search test failed: no results for "squat"',
        );
      }
      return TestResult(success: true, message: 'Search test passed');
    } catch (e) {
      return TestResult(success: false, message: 'Search test failed: $e');
    }
  }

  /// Test funzionalità di filtro
  Future<TestResult> _testFilterFunctionality() async {
    try {
      final filterResults = await _hybridRepository.getExercisesByFocus(['PETT']);
      if (filterResults.isEmpty) {
        return TestResult(
          success: false,
          message: 'Filter test failed: no results for PETT focus',
        );
      }
      return TestResult(success: true, message: 'Filter test passed');
    } catch (e) {
      return TestResult(success: false, message: 'Filter test failed: $e');
    }
  }

  /// Controlla se migrazione è già completata
  Future<bool> _isMigrationCompleted() async {
    try {
      final metadata = await _cacheManager.getCacheMetadata();
      return metadata != null && metadata.exerciseCount > 0;
    } catch (e) {
      return false;
    }
  }

  /// Marca migrazione come completata
  Future<void> _markMigrationCompleted() async {
    await _versionService.markUpdateCompleted('1.0.0', (await _cacheManager.getCachedExercises()).length);
  }
}

/// Risultato della migrazione
class MigrationResult {

  MigrationResult({
    required this.success,
    required this.message,
    this.exerciseCount,
    required this.duration,
  });
  final bool success;
  final String message;
  final int? exerciseCount;
  final Duration duration;
}

/// Risultato dei test
class TestResult {

  TestResult({
    required this.success,
    required this.message,
    this.exerciseCount,
    this.missingInHybrid,
    this.missingInJson,
  });
  final bool success;
  final String message;
  final int? exerciseCount;
  final List<String>? missingInHybrid;
  final List<String>? missingInJson;
}

/// Risultato test di performance
class PerformanceTestResult {

  PerformanceTestResult({
    required this.jsonLoadTime,
    required this.hybridLoadTime,
    required this.jsonSearchTime,
    required this.hybridSearchTime,
    required this.jsonExerciseCount,
    required this.hybridExerciseCount,
    required this.jsonSearchResultCount,
    required this.hybridSearchResultCount,
  });
  final Duration jsonLoadTime;
  final Duration hybridLoadTime;
  final Duration jsonSearchTime;
  final Duration hybridSearchTime;
  final int jsonExerciseCount;
  final int hybridExerciseCount;
  final int jsonSearchResultCount;
  final int hybridSearchResultCount;

  double get loadSpeedupFactor =>
    jsonLoadTime.inMicroseconds / hybridLoadTime.inMicroseconds;

  double get searchSpeedupFactor =>
    jsonSearchTime.inMicroseconds / hybridSearchTime.inMicroseconds;
}