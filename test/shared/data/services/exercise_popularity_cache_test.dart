import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:gymbro_flutter_new/shared/data/services/exercise_popularity_cache.dart';
import 'package:gymbro_flutter_new/shared/data/models/exercise_popularity_hive_model.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise_popularity_data.dart';

void main() {
  late ExercisePopularityCache cache;
  late Directory testDir;

  setUp(() async {
    // Create temporary directory for Hive
    testDir = await Directory.systemTemp.createTemp('hive_test_');

    // Initialize Hive with test directory
    Hive.init(testDir.path);

    // Register adapter
    if (!Hive.isAdapterRegistered(111)) {
      Hive.registerAdapter(ExercisePopularityHiveModelAdapter());
    }

    cache = ExercisePopularityCache();
    await cache.init();
  });

  tearDown(() async {
    await cache.clear();
    await cache.close();
    await Hive.deleteFromDisk();

    // Clean up temp directory
    if (testDir.existsSync()) {
      await testDir.delete(recursive: true);
    }
  });

  group('ExercisePopularityCache', () {
    test('getPopularity returns 0 for missing exercise', () {
      final popularity = cache.getPopularity('non_existent');
      expect(popularity, 0);
    });

    test('getPopularity returns cached count for existing exercise', () async {
      // Arrange: Add test data
      final testData = [
        ExercisePopularityData(
          exerciseId: 'squat',
          count: 100,
          lastUpdated: DateTime.now(),
        ),
      ];
      await cache.updateBatch(testData);

      // Act
      final popularity = cache.getPopularity('squat');

      // Assert
      expect(popularity, 100);
    });

    test('getPopularity returns 0 for expired cache entry', () async {
      // Arrange: Add expired data (>24h old)
      final oldDate = DateTime.now().subtract(const Duration(days: 2));
      final testData = [
        ExercisePopularityData(
          exerciseId: 'old_exercise',
          count: 50,
          lastUpdated: oldDate,
        ),
      ];
      await cache.updateBatch(testData);

      // Act
      final popularity = cache.getPopularity('old_exercise');

      // Assert: Should return 0 for expired data
      expect(popularity, 0);
    });

    test('updateBatch populates cache correctly', () async {
      // Arrange
      final testData = [
        ExercisePopularityData(
          exerciseId: 'exercise1',
          count: 10,
          lastUpdated: DateTime.now(),
        ),
        ExercisePopularityData(
          exerciseId: 'exercise2',
          count: 20,
          lastUpdated: DateTime.now(),
        ),
      ];

      // Act
      await cache.updateBatch(testData);

      // Assert
      expect(cache.getPopularity('exercise1'), 10);
      expect(cache.getPopularity('exercise2'), 20);
    });

    test('needsSync returns true for empty cache', () {
      final needsSync = cache.needsSync();
      expect(needsSync, true);
    });

    test('needsSync returns false for fresh cache', () async {
      // Arrange: Add fresh data
      final testData = [
        ExercisePopularityData(
          exerciseId: 'fresh',
          count: 1,
          lastUpdated: DateTime.now(),
        ),
      ];
      await cache.updateBatch(testData);

      // Act
      final needsSync = cache.needsSync();

      // Assert
      expect(needsSync, false);
    });

    test('needsSync returns true for expired cache', () async {
      // Arrange: Add old data
      final oldDate = DateTime.now().subtract(const Duration(days: 2));
      final testData = [
        ExercisePopularityData(
          exerciseId: 'old',
          count: 1,
          lastUpdated: oldDate,
        ),
      ];
      await cache.updateBatch(testData);

      // Act
      final needsSync = cache.needsSync();

      // Assert
      expect(needsSync, true);
    });

    test('clear removes all cache entries', () async {
      // Arrange: Add data
      final testData = [
        ExercisePopularityData(
          exerciseId: 'test',
          count: 100,
          lastUpdated: DateTime.now(),
        ),
      ];
      await cache.updateBatch(testData);

      // Act
      await cache.clear();

      // Assert
      expect(cache.getPopularity('test'), 0);
      expect(cache.needsSync(), true); // Empty cache needs sync
    });

    test('getStats returns correct statistics', () async {
      // Arrange: Add mixed data (fresh + expired)
      final now = DateTime.now();
      final oldDate = now.subtract(const Duration(days: 2));

      final testData = [
        ExercisePopularityData(
          exerciseId: 'fresh1',
          count: 10,
          lastUpdated: now,
        ),
        ExercisePopularityData(
          exerciseId: 'fresh2',
          count: 20,
          lastUpdated: now,
        ),
        ExercisePopularityData(
          exerciseId: 'expired',
          count: 30,
          lastUpdated: oldDate,
        ),
      ];
      await cache.updateBatch(testData);

      // Act
      final stats = cache.getStats();

      // Assert
      expect(stats['initialized'], true);
      expect(stats['entries'], 3);
      expect(stats['expired'], 1);
      expect(stats['fresh'], 2);
      expect(stats['needsSync'], true); // Has expired entries
    });
  });
}
