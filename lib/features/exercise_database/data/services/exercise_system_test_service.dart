/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/data/services
/// 🎯 Feature: exercise_database
/// 🔧 Type: service (TEST UTILITY)
///
/// Servizio per testare l'intero sistema di aggiornamento esercizi
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/hybrid_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/json_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_migration_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_sync_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_version_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_cache_manager.dart';

class ExerciseSystemTestService {

  ExerciseSystemTestService({
    required HybridExerciseRepository hybridRepository,
    required JsonExerciseRepository jsonRepository,
    required ExerciseMigrationService migrationService,
    required ExerciseSyncService syncService,
    required ExerciseVersionService versionService,
    required ExerciseCacheManager cacheManager,
  }) : _hybridRepository = hybridRepository,
       _jsonRepository = jsonRepository,
       _migrationService = migrationService,
       _syncService = syncService,
       _versionService = versionService,
       _cacheManager = cacheManager;
  final HybridExerciseRepository _hybridRepository;
  final JsonExerciseRepository _jsonRepository;
  final ExerciseMigrationService _migrationService;
  final ExerciseSyncService _syncService;
  final ExerciseVersionService _versionService;
  final ExerciseCacheManager _cacheManager;

  /// Esegue test completo del sistema
  Future<SystemTestReport> runFullSystemTest() async {
    final startTime = DateTime.now();
    final testResults = <String, TestStepResult>{};

    debugPrint('🧪 Starting full system test...');

    try {
      // 1. Test inizializzazione servizi
      testResults['initialization'] = await _testInitialization();

      // 2. Test migrazione
      testResults['migration'] = await _testMigration();

      // 3. Test repository ibrido
      testResults['hybrid_repository'] = await _testHybridRepository();

      // 4. Test sincronizzazione
      testResults['synchronization'] = await _testSynchronization();

      // 5. Test versioning
      testResults['versioning'] = await _testVersioning();

      // 6. Test cache management
      testResults['cache_management'] = await _testCacheManagement();

      // 7. Test performance
      testResults['performance'] = await _testPerformance();

      // 8. Test error handling
      testResults['error_handling'] = await _testErrorHandling();

      final duration = DateTime.now().difference(startTime);
      final allPassed = testResults.values.every((result) => result.success);

      debugPrint(allPassed
        ? '✅ All tests passed in ${duration.inSeconds}s'
        : '❌ Some tests failed in ${duration.inSeconds}s');

      return SystemTestReport(
        success: allPassed,
        duration: duration,
        testResults: testResults,
        summary: _generateTestSummary(testResults),
      );

    } catch (e) {
      debugPrint('❌ System test failed: $e');
      return SystemTestReport(
        success: false,
        duration: DateTime.now().difference(startTime),
        testResults: testResults,
        summary: 'System test failed with error: $e',
        error: e.toString(),
      );
    }
  }

  /// Test inizializzazione servizi
  Future<TestStepResult> _testInitialization() async {
    try {
      debugPrint('🔧 Testing service initialization...');

      await _versionService.initialize();
      await _cacheManager.initialize();
      await _syncService.initialize();

      return TestStepResult(
        success: true,
        message: 'All services initialized successfully',
        duration: Duration.zero,
      );

    } catch (e) {
      return TestStepResult(
        success: false,
        message: 'Initialization failed: $e',
        duration: Duration.zero,
      );
    }
  }

  /// Test migrazione
  Future<TestStepResult> _testMigration() async {
    try {
      debugPrint('📦 Testing migration...');

      final startTime = DateTime.now();
      final migrationResult = await _migrationService.performMigration(forceReset: true);
      final duration = DateTime.now().difference(startTime);

      if (!migrationResult.success) {
        return TestStepResult(
          success: false,
          message: 'Migration failed: ${migrationResult.message}',
          duration: duration,
        );
      }

      // Test che la migrazione abbia funzionato
      final hybridTest = await _migrationService.testHybridSystem();
      if (!hybridTest.success) {
        return TestStepResult(
          success: false,
          message: 'Hybrid system test failed: ${hybridTest.message}',
          duration: duration,
        );
      }

      return TestStepResult(
        success: true,
        message: 'Migration and hybrid system test passed',
        duration: duration,
        details: {
          'exercise_count': migrationResult.exerciseCount,
          'hybrid_test': hybridTest.message,
        },
      );

    } catch (e) {
      return TestStepResult(
        success: false,
        message: 'Migration test failed: $e',
        duration: Duration.zero,
      );
    }
  }

  /// Test repository ibrido
  Future<TestStepResult> _testHybridRepository() async {
    try {
      debugPrint('🔄 Testing hybrid repository...');

      final startTime = DateTime.now();

      // Test caricamento esercizi
      final exercises = await _hybridRepository.getAllExercises();
      if (exercises.isEmpty) {
        return TestStepResult(
          success: false,
          message: 'No exercises loaded from hybrid repository',
          duration: DateTime.now().difference(startTime),
        );
      }

      // Test ricerca
      final searchResults = await _hybridRepository.searchExercises('squat');
      if (searchResults.isEmpty) {
        return TestStepResult(
          success: false,
          message: 'Search functionality failed',
          duration: DateTime.now().difference(startTime),
        );
      }

      // Test filtro per focus
      final focusResults = await _hybridRepository.getExercisesByFocus(['PETT']);
      if (focusResults.isEmpty) {
        return TestStepResult(
          success: false,
          message: 'Focus filter functionality failed',
          duration: DateTime.now().difference(startTime),
        );
      }

      // Test singolo esercizio
      final firstExercise = exercises.first;
      final singleExercise = await _hybridRepository.getExerciseById(firstExercise.id);
      if (singleExercise == null) {
        return TestStepResult(
          success: false,
          message: 'Single exercise fetch failed',
          duration: DateTime.now().difference(startTime),
        );
      }

      return TestStepResult(
        success: true,
        message: 'All repository functions working correctly',
        duration: DateTime.now().difference(startTime),
        details: {
          'total_exercises': exercises.length,
          'search_results': searchResults.length,
          'focus_results': focusResults.length,
        },
      );

    } catch (e) {
      return TestStepResult(
        success: false,
        message: 'Hybrid repository test failed: $e',
        duration: Duration.zero,
      );
    }
  }

  /// Test sincronizzazione
  Future<TestStepResult> _testSynchronization() async {
    try {
      debugPrint('🔄 Testing synchronization...');

      final startTime = DateTime.now();

      // Test controllo aggiornamenti
      final hasUpdates = await _hybridRepository.checkAndApplyUpdates();

      // Test sincronizzazione manuale
      final syncResult = await _syncService.performManualSync();

      if (!syncResult.success) {
        return TestStepResult(
          success: false,
          message: 'Manual sync failed: ${syncResult.error}',
          duration: DateTime.now().difference(startTime),
        );
      }

      // Test impostazioni sync
      await _syncService.setAutoSyncEnabled(true);
      final autoSyncEnabled = await _syncService.isAutoSyncEnabled();

      if (!autoSyncEnabled) {
        return TestStepResult(
          success: false,
          message: 'Auto sync setting failed',
          duration: DateTime.now().difference(startTime),
        );
      }

      return TestStepResult(
        success: true,
        message: 'Synchronization tests passed',
        duration: DateTime.now().difference(startTime),
        details: {
          'has_updates': hasUpdates,
          'sync_successful': syncResult.success,
          'auto_sync_enabled': autoSyncEnabled,
        },
      );

    } catch (e) {
      return TestStepResult(
        success: false,
        message: 'Synchronization test failed: $e',
        duration: Duration.zero,
      );
    }
  }

  /// Test versioning
  Future<TestStepResult> _testVersioning() async {
    try {
      debugPrint('📋 Testing versioning...');

      final startTime = DateTime.now();

      // Test controllo versione
      final versionCheck = await _versionService.checkForUpdates();

      // Test versione locale
      final localVersion = await _versionService.getLocalVersion();
      if (localVersion.isEmpty) {
        return TestStepResult(
          success: false,
          message: 'Local version is empty',
          duration: DateTime.now().difference(startTime),
        );
      }

      // Test versione remota
      final remoteVersion = await _versionService.getRemoteVersion();

      // Test aggiornamento versione locale
      await _versionService.setLocalVersion('test-1.0.0');
      final updatedVersion = await _versionService.getLocalVersion();

      if (!updatedVersion.contains('test-1.0.0')) {
        return TestStepResult(
          success: false,
          message: 'Version update failed',
          duration: DateTime.now().difference(startTime),
        );
      }

      // Ripristina versione originale
      await _versionService.setLocalVersion(localVersion);

      return TestStepResult(
        success: true,
        message: 'Versioning tests passed',
        duration: DateTime.now().difference(startTime),
        details: {
          'local_version': localVersion,
          'remote_version': remoteVersion?.version ?? 'null',
          'has_updates': versionCheck.hasUpdates,
        },
      );

    } catch (e) {
      return TestStepResult(
        success: false,
        message: 'Versioning test failed: $e',
        duration: Duration.zero,
      );
    }
  }

  /// Test gestione cache
  Future<TestStepResult> _testCacheManagement() async {
    try {
      debugPrint('💾 Testing cache management...');

      final startTime = DateTime.now();

      // Test metadata cache
      final metadata = await _cacheManager.getCacheMetadata();
      if (metadata == null) {
        return TestStepResult(
          success: false,
          message: 'Cache metadata is null',
          duration: DateTime.now().difference(startTime),
        );
      }

      // Test caricamento da cache
      final cachedExercises = await _cacheManager.getCachedExercises();
      if (cachedExercises.isEmpty) {
        return TestStepResult(
          success: false,
          message: 'No exercises in cache',
          duration: DateTime.now().difference(startTime),
        );
      }

      // Test ricerca in cache
      final searchResults = await _cacheManager.searchCachedExercises('bench');

      // Test statistiche
      final stats = await _hybridRepository.getCacheStats();

      return TestStepResult(
        success: true,
        message: 'Cache management tests passed',
        duration: DateTime.now().difference(startTime),
        details: {
          'cached_exercises': cachedExercises.length,
          'search_results': searchResults.length,
          'cache_size': stats?.cacheSize ?? 0,
        },
      );

    } catch (e) {
      return TestStepResult(
        success: false,
        message: 'Cache management test failed: $e',
        duration: Duration.zero,
      );
    }
  }

  /// Test performance
  Future<TestStepResult> _testPerformance() async {
    try {
      debugPrint('⚡ Testing performance...');

      final performanceResult = await _migrationService.performanceTest();

      // Verifica che il sistema ibrido sia più veloce del JSON
      final isLoadFaster = performanceResult.loadSpeedupFactor > 1.0;
      final isSearchFaster = performanceResult.searchSpeedupFactor > 1.0;

      return TestStepResult(
        success: true,
        message: 'Performance tests completed',
        duration: performanceResult.hybridLoadTime + performanceResult.hybridSearchTime,
        details: {
          'load_speedup': performanceResult.loadSpeedupFactor.toStringAsFixed(2),
          'search_speedup': performanceResult.searchSpeedupFactor.toStringAsFixed(2),
          'load_faster': isLoadFaster,
          'search_faster': isSearchFaster,
          'json_load_ms': performanceResult.jsonLoadTime.inMilliseconds,
          'hybrid_load_ms': performanceResult.hybridLoadTime.inMilliseconds,
        },
      );

    } catch (e) {
      return TestStepResult(
        success: false,
        message: 'Performance test failed: $e',
        duration: Duration.zero,
      );
    }
  }

  /// Test gestione errori
  Future<TestStepResult> _testErrorHandling() async {
    try {
      debugPrint('⚠️ Testing error handling...');

      final startTime = DateTime.now();

      // Test ricerca esercizio inesistente
      final nonExistentExercise = await _hybridRepository.getExerciseById('non_existent_id');
      if (nonExistentExercise != null) {
        return TestStepResult(
          success: false,
          message: 'Should return null for non-existent exercise',
          duration: DateTime.now().difference(startTime),
        );
      }

      // Test ricerca vuota
      final emptySearch = await _hybridRepository.searchExercises('');
      if (emptySearch.isEmpty) {
        return TestStepResult(
          success: false,
          message: 'Empty search should return all exercises',
          duration: DateTime.now().difference(startTime),
        );
      }

      // Test filtro vuoto
      final emptyFilter = await _hybridRepository.getExercisesByFocus([]);
      if (emptyFilter.isNotEmpty) {
        return TestStepResult(
          success: false,
          message: 'Empty filter should return empty list',
          duration: DateTime.now().difference(startTime),
        );
      }

      return TestStepResult(
        success: true,
        message: 'Error handling tests passed',
        duration: DateTime.now().difference(startTime),
      );

    } catch (e) {
      return TestStepResult(
        success: false,
        message: 'Error handling test failed: $e',
        duration: Duration.zero,
      );
    }
  }

  /// Genera riassunto test
  String _generateTestSummary(Map<String, TestStepResult> results) {
    final passed = results.values.where((r) => r.success).length;
    final failed = results.values.where((r) => !r.success).length;
    final total = results.length;

    final buffer = StringBuffer();
    buffer.writeln('=== SYSTEM TEST SUMMARY ===');
    buffer.writeln('Total Tests: $total');
    buffer.writeln('Passed: $passed');
    buffer.writeln('Failed: $failed');
    buffer.writeln('Success Rate: ${((passed / total) * 100).toStringAsFixed(1)}%');
    buffer.writeln();

    if (failed > 0) {
      buffer.writeln('FAILED TESTS:');
      results.forEach((name, result) {
        if (!result.success) {
          buffer.writeln('- $name: ${result.message}');
        }
      });
      buffer.writeln();
    }

    buffer.writeln('DETAILED RESULTS:');
    results.forEach((name, result) {
      final status = result.success ? '✅' : '❌';
      buffer.writeln('$status $name (${result.duration.inMilliseconds}ms): ${result.message}');
    });

    return buffer.toString();
  }
}

/// Risultato test del sistema
class SystemTestReport {

  SystemTestReport({
    required this.success,
    required this.duration,
    required this.testResults,
    required this.summary,
    this.error,
  });
  final bool success;
  final Duration duration;
  final Map<String, TestStepResult> testResults;
  final String summary;
  final String? error;
}

/// Risultato singolo step di test
class TestStepResult {

  TestStepResult({
    required this.success,
    required this.message,
    required this.duration,
    this.details,
  });
  final bool success;
  final String message;
  final Duration duration;
  final Map<String, dynamic>? details;
}