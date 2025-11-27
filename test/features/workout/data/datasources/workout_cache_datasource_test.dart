/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 🧪 Test Suite: WorkoutCacheDataSource
/// ✅ PREVIOUS_DATA: Tests for 3-tier caching strategy (Tier 2: Hive cache)
///
/// Test Scenarios:
/// 1. Cache hit within 24h TTL
/// 2. Cache miss (expired TTL >24h)
/// 3. Cache miss (no cached data)
/// 4. Hive corruption graceful fallback
/// 5. Cache invalidation
/// 6. Cache statistics calculation
/// 7. Successful workout caching
/// 8. Clear all cache

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/workout_cache_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'workout_cache_datasource_test.mocks.dart';

@GenerateMocks([HiveBoxManagerEnhanced, Box])
void main() {
  late WorkoutCacheDataSource dataSource;
  late MockHiveBoxManagerEnhanced mockBoxManager;
  late MockBox<dynamic> mockBox;

  setUp(() {
    mockBoxManager = MockHiveBoxManagerEnhanced();
    mockBox = MockBox<dynamic>();
    dataSource = WorkoutCacheDataSource(mockBoxManager);

    // Default: openBox returns mockBox
    when(mockBoxManager.openBox<dynamic>(HiveBoxNames.workoutPreviousDataCache))
        .thenAnswer((_) async => mockBox);

    // Default: box.keys returns empty list (can be overridden in specific tests)
    when(mockBox.keys).thenReturn([]);
  });

  group('WorkoutCacheDataSource - Cache Validity', () {
    test('✅ Scenario 1: Cache HIT within 24h TTL', () async {
      // Arrange
      const templateId = 'template_123';
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheTimestamp = now - (const Duration(hours: 12).inMilliseconds); // 12h ago

      when(mockBox.get('template_${templateId}_timestamp'))
          .thenReturn(cacheTimestamp);

      // Act
      final isValid = await dataSource.isCacheValid(templateId);

      // Assert
      expect(isValid, true);
      verify(mockBox.get('template_${templateId}_timestamp')).called(1);
    });

    test('❌ Scenario 2: Cache MISS - Expired TTL (>24h)', () async {
      // Arrange
      const templateId = 'template_123';
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheTimestamp = now - (const Duration(hours: 25).inMilliseconds); // 25h ago

      when(mockBox.get('template_${templateId}_timestamp'))
          .thenReturn(cacheTimestamp);

      // Act
      final isValid = await dataSource.isCacheValid(templateId);

      // Assert
      expect(isValid, false);
      verify(mockBox.get('template_${templateId}_timestamp')).called(1);
    });

    test('❌ Scenario 3: Cache MISS - No cached data', () async {
      // Arrange
      const templateId = 'template_123';

      when(mockBox.get('template_${templateId}_timestamp'))
          .thenReturn(null); // No timestamp

      // Act
      final isValid = await dataSource.isCacheValid(templateId);

      // Assert
      expect(isValid, false);
      verify(mockBox.get('template_${templateId}_timestamp')).called(1);
    });

    test('❌ Cache validity check throws exception - returns false', () async {
      // Arrange
      const templateId = 'template_123';

      when(mockBox.get('template_${templateId}_timestamp'))
          .thenThrow(Exception('Hive error'));

      // Act
      final isValid = await dataSource.isCacheValid(templateId);

      // Assert
      expect(isValid, false);
      verify(mockBox.get('template_${templateId}_timestamp')).called(1);
    });
  });

  group('WorkoutCacheDataSource - Get Cached Workout', () {
    test('✅ Returns cached workout when data exists', () async {
      // Arrange
      const templateId = 'template_123';
      final now = DateTime.now();
      final workoutJson = {
        'id': 'workout_456',
        'name': 'Test Workout',
        'templateId': templateId,
        'exercises': [],
        'startTime': now.toIso8601String(),
        'status': 'completed',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      when(mockBox.get('template_$templateId'))
          .thenReturn(workoutJson);

      // Act
      final workout = await dataSource.getCachedWorkout(templateId);

      // Assert
      expect(workout, isNotNull);
      expect(workout!.id, 'workout_456');
      expect(workout.name, 'Test Workout');
      expect(workout.templateId, templateId);
      verify(mockBox.get('template_$templateId')).called(1);
    });

    test('❌ Returns null when no cached workout exists', () async {
      // Arrange
      const templateId = 'template_123';

      when(mockBox.get('template_$templateId'))
          .thenReturn(null);

      // Act
      final workout = await dataSource.getCachedWorkout(templateId);

      // Assert
      expect(workout, isNull);
      verify(mockBox.get('template_$templateId')).called(1);
    });

    test('⚠️ Scenario 4: Hive corruption - Graceful fallback returns null', () async {
      // Arrange
      const templateId = 'template_123';

      when(mockBox.get('template_$templateId'))
          .thenThrow(HiveError('Corrupted data'));

      // Act
      final workout = await dataSource.getCachedWorkout(templateId);

      // Assert
      expect(workout, isNull); // ✅ Graceful fallback
      verify(mockBox.get('template_$templateId')).called(1);
    });

    test('✅ Handles Map<dynamic, dynamic> to Map<String, dynamic> conversion', () async {
      // Arrange
      const templateId = 'template_123';
      // Simulate Hive returning Map<dynamic, dynamic>
      final now = DateTime.now();
      final dynamicMap = <dynamic, dynamic>{
        'id': 'workout_456',
        'name': 'Test Workout',
        'templateId': templateId,
        'exercises': [],
        'startTime': now.toIso8601String(),
        'status': 'completed',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      when(mockBox.get('template_$templateId'))
          .thenReturn(dynamicMap);

      // Act
      final workout = await dataSource.getCachedWorkout(templateId);

      // Assert
      expect(workout, isNotNull);
      expect(workout!.name, 'Test Workout');
    });
  });

  group('WorkoutCacheDataSource - Cache Workout', () {
    test('✅ Scenario 7: Successfully caches workout with timestamp', () async {
      // Arrange
      const templateId = 'template_123';
      final now = DateTime.now();
      final workout = Workout(
        id: 'workout_456',
        name: 'Test Workout',
        templateId: templateId,
        exercises: [],
        startTime: now,
        status: WorkoutStatus.completed,
        createdAt: now,
        updatedAt: now,
      );

      when(mockBox.put(any, any))
          .thenAnswer((_) async => Future<void>.value());

      // Act
      await dataSource.cacheWorkout(templateId, workout);

      // Assert
      verify(mockBox.put('template_$templateId', workout.toJson())).called(1);
      verify(mockBox.put(
        'template_${templateId}_timestamp',
        any, // Timestamp (int)
      )).called(1);
    });

    test('⚠️ Handles cache failure gracefully (non-critical)', () async {
      // Arrange
      const templateId = 'template_123';
      final now = DateTime.now();
      final workout = Workout(
        id: 'workout_456',
        name: 'Test Workout',
        templateId: templateId,
        exercises: [],
        startTime: now,
        status: WorkoutStatus.completed,
        createdAt: now,
        updatedAt: now,
      );

      when(mockBox.put(any, any))
          .thenThrow(HiveError('Write failed'));

      // Act & Assert
      // Should not throw - caching is non-critical
      await expectLater(
        dataSource.cacheWorkout(templateId, workout),
        completes,
      );
    });
  });

  group('WorkoutCacheDataSource - Invalidate Cache', () {
    test('✅ Scenario 5: Successfully invalidates cache (deletes workout + timestamp)', () async {
      // Arrange
      const templateId = 'template_123';

      when(mockBox.delete(any))
          .thenAnswer((_) async => Future<void>.value());

      // Act
      await dataSource.invalidateCache(templateId);

      // Assert
      verify(mockBox.delete('template_$templateId')).called(1);
      verify(mockBox.delete('template_${templateId}_timestamp')).called(1);
    });

    test('⚠️ Handles invalidation failure gracefully', () async {
      // Arrange
      const templateId = 'template_123';

      when(mockBox.delete(any))
          .thenThrow(HiveError('Delete failed'));

      // Act & Assert
      await expectLater(
        dataSource.invalidateCache(templateId),
        completes,
      );
    });
  });

  group('WorkoutCacheDataSource - Clear All Cache', () {
    test('✅ Scenario 8: Successfully clears all cached workouts', () async {
      // Arrange
      when(mockBox.clear())
          .thenAnswer((_) async => 10); // Returns number of deleted entries

      // Act
      await dataSource.clearAllCache();

      // Assert
      verify(mockBox.clear()).called(1);
    });

    test('⚠️ Handles clear failure gracefully', () async {
      // Arrange
      when(mockBox.clear())
          .thenThrow(HiveError('Clear failed'));

      // Act & Assert
      await expectLater(
        dataSource.clearAllCache(),
        completes,
      );
    });
  });

  group('WorkoutCacheDataSource - Cache Statistics', () {
    test('✅ Scenario 6: Calculates cache stats correctly', () async {
      // Arrange
      final now = DateTime.now().millisecondsSinceEpoch;

      // Mock box keys (3 templates, each with workout + timestamp)
      when(mockBox.keys).thenReturn([
        'template_1',
        'template_1_timestamp',
        'template_2',
        'template_2_timestamp',
        'template_3',
        'template_3_timestamp',
      ]);

      // Mock timestamps: 2 valid, 1 stale
      when(mockBox.get('template_1_timestamp'))
          .thenReturn(now - const Duration(hours: 12).inMilliseconds); // Valid
      when(mockBox.get('template_2_timestamp'))
          .thenReturn(now - const Duration(hours: 20).inMilliseconds); // Valid
      when(mockBox.get('template_3_timestamp'))
          .thenReturn(now - const Duration(hours: 30).inMilliseconds); // Stale

      // Act
      final stats = await dataSource.getCacheStats();

      // Assert
      expect(stats['totalEntries'], 3);
      expect(stats['validEntries'], 2);
      expect(stats['staleEntries'], 1);
      expect(stats['cacheHitRate'], '66.7'); // 2/3 = 66.7%
    });

    test('✅ Returns 0.0% hit rate when no cache entries', () async {
      // Arrange
      when(mockBox.keys).thenReturn([]);

      // Act
      final stats = await dataSource.getCacheStats();

      // Assert
      expect(stats['totalEntries'], 0);
      expect(stats['validEntries'], 0);
      expect(stats['staleEntries'], 0);
      expect(stats['cacheHitRate'], '0.0');
    });

    test('⚠️ Returns error stats when exception occurs', () async {
      // Arrange
      when(mockBox.keys).thenThrow(HiveError('Failed to read keys'));

      // Act
      final stats = await dataSource.getCacheStats();

      // Assert
      expect(stats['totalEntries'], 0);
      expect(stats['validEntries'], 0);
      expect(stats['staleEntries'], 0);
      expect(stats['cacheHitRate'], '0.0');
      expect(stats['error'], isNotNull);
    });
  });
}
