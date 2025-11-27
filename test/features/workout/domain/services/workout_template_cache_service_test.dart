import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_template_cache_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

// Mocks
class MockHiveBoxManagerEnhanced extends Mock implements HiveBoxManagerEnhanced {}
class MockBox extends Mock implements Box<Map<dynamic, dynamic>> {}

void main() {
  late WorkoutTemplateCacheService cacheService;
  late MockHiveBoxManagerEnhanced mockBoxManager;
  late MockBox mockCacheBox;

  setUp(() {
    mockBoxManager = MockHiveBoxManagerEnhanced();
    mockCacheBox = MockBox();

    // Default box setup
    when(() => mockBoxManager.openBox<Map<dynamic, dynamic>>(any()))
        .thenAnswer((_) async => mockCacheBox);
    when(() => mockCacheBox.keys).thenReturn([]);
    when(() => mockCacheBox.isOpen).thenReturn(true);
    when(() => mockCacheBox.get(any())).thenReturn(null);
    when(() => mockCacheBox.put(any(), any())).thenAnswer((_) async {});
    when(() => mockCacheBox.delete(any())).thenAnswer((_) async {});
    when(() => mockCacheBox.clear()).thenAnswer((_) async => 0); // Returns int
    when(() => mockCacheBox.close()).thenAnswer((_) async {});
    when(() => mockCacheBox.flush()).thenAnswer((_) async {});

    cacheService = WorkoutTemplateCacheService(boxManager: mockBoxManager);
  });

  tearDown(() {
    cacheService.dispose();
  });

  group('WorkoutTemplateCacheService - Initialization', () {
    test('should initialize cache box successfully', () async {
      // Act
      await cacheService.initialize();

      // Assert
      verify(() => mockBoxManager.openBox<Map<dynamic, dynamic>>('template_cache')).called(1);
    });

    test('should not reinitialize if already initialized', () async {
      // Act
      await cacheService.initialize();
      await cacheService.initialize(); // Second init

      // Assert - Should only open box once
      verify(() => mockBoxManager.openBox<Map<dynamic, dynamic>>('template_cache')).called(1);
    });

    test('should cleanup old cache entries on initialization', () async {
      // Arrange - Add old cache entry (35 days old)
      final oldDate = DateTime.now().subtract(const Duration(days: 35));
      when(() => mockCacheBox.keys).thenReturn(['template_old123']);
      when(() => mockCacheBox.get('template_old123')).thenReturn({
        'lastModified': oldDate.toIso8601String(),
        'templateId': 'old123',
      });

      // Act
      await cacheService.initialize();

      // Assert - Old entry should be deleted
      verify(() => mockCacheBox.delete('template_old123')).called(1);
    });
  });

  group('WorkoutTemplateCacheService - Save with Debouncing', () {
    test('should schedule debounced save', () async {
      // Arrange
      await cacheService.initialize();
      final workout = _createTestWorkout();

      // Act
      cacheService.saveWorkoutModifications(
        templateId: 'template123',
        workout: workout,
      );

      // Assert - Should NOT save immediately (debounced)
      verifyNever(() => mockCacheBox.put(any(), any()));
    });

    test('should execute save after debounce time', () async {
      // Arrange
      await cacheService.initialize();
      final workout = _createTestWorkout();

      // Act
      cacheService.saveWorkoutModifications(
        templateId: 'template123',
        workout: workout,
      );

      // Wait for debounce time + buffer
      await Future.delayed(const Duration(seconds: 2));

      // Assert - Should save after debounce
      verify(() => mockCacheBox.put('template_template123', any())).called(1);
    });

    test('should cancel previous save and restart debounce on new modification', () async {
      // Arrange
      await cacheService.initialize();
      final workout1 = _createTestWorkout(name: 'Workout 1');
      final workout2 = _createTestWorkout(name: 'Workout 2');

      // Act - Save twice quickly
      cacheService.saveWorkoutModifications(
        templateId: 'template123',
        workout: workout1,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      cacheService.saveWorkoutModifications(
        templateId: 'template123',
        workout: workout2,
      );

      // Wait for debounce
      await Future.delayed(const Duration(seconds: 2));

      // Assert - Should only save once (last modification)
      verify(() => mockCacheBox.put('template_template123', any())).called(1);
    });

    test('should auto-initialize if not initialized when saving', () async {
      // Arrange - Don't initialize manually
      final workout = _createTestWorkout();

      // Act
      cacheService.saveWorkoutModifications(
        templateId: 'template123',
        workout: workout,
      );

      // Wait for initialization and debounce
      await Future.delayed(const Duration(seconds: 2));

      // Assert - Should auto-initialize and save
      verify(() => mockBoxManager.openBox<Map<dynamic, dynamic>>('template_cache')).called(1);
    });
  });

  group('WorkoutTemplateCacheService - Force Save', () {
    test('should save immediately without debounce', () async {
      // Arrange
      await cacheService.initialize();
      final workout = _createTestWorkout();

      cacheService.saveWorkoutModifications(
        templateId: 'template123',
        workout: workout,
      );

      // Act - Force save immediately
      await cacheService.forceSave();

      // Assert - Should save without waiting for debounce
      verify(() => mockCacheBox.put('template_template123', any())).called(1);
      verify(() => mockCacheBox.flush()).called(1);
    });

    test('should flush cache box to disk', () async {
      // Arrange
      await cacheService.initialize();
      final workout = _createTestWorkout();

      cacheService.saveWorkoutModifications(
        templateId: 'template123',
        workout: workout,
      );

      // Act
      await cacheService.forceSave();

      // Assert - Should call flush
      verify(() => mockCacheBox.flush()).called(1);
    });

    test('should handle flush errors gracefully', () async {
      // Arrange
      await cacheService.initialize();
      when(() => mockCacheBox.flush()).thenThrow(Exception('Flush error'));

      // Act & Assert - Should not throw
      await cacheService.forceSave();
      expect(true, isTrue);
    });
  });

  group('WorkoutTemplateCacheService - Get Cached Workout', () {
    test('should return cached workout when found', () async {
      // Arrange
      await cacheService.initialize();
      final cacheData = {
        'workout': _createTestWorkout().toJson(),
        'lastModified': DateTime.now().toIso8601String(),
        'templateId': 'template123',
      };

      when(() => mockCacheBox.get('template_template123')).thenReturn(cacheData);

      // Act
      final result = await cacheService.getCachedWorkout('template123');

      // Assert
      expect(result, isNotNull);
      expect(result!.name, equals('Test Workout'));
    });

    test('should return null when cache not found', () async {
      // Arrange
      await cacheService.initialize();
      when(() => mockCacheBox.get('template_template123')).thenReturn(null);

      // Act
      final result = await cacheService.getCachedWorkout('template123');

      // Assert
      expect(result, isNull);
    });

    test('should return null when cache is expired (>30 days)', () async {
      // Arrange
      await cacheService.initialize();
      final oldDate = DateTime.now().subtract(const Duration(days: 35));
      final cacheData = {
        'workout': _createTestWorkout().toJson(),
        'lastModified': oldDate.toIso8601String(),
        'templateId': 'template123',
      };

      when(() => mockCacheBox.get('template_template123')).thenReturn(cacheData);

      // Act
      final result = await cacheService.getCachedWorkout('template123');

      // Assert
      expect(result, isNull);
      verify(() => mockCacheBox.delete('template_template123')).called(1);
    });

    test('should delete expired cache entry', () async {
      // Arrange
      await cacheService.initialize();
      final oldDate = DateTime.now().subtract(const Duration(days: 31));
      final cacheData = {
        'workout': _createTestWorkout().toJson(),
        'lastModified': oldDate.toIso8601String(),
        'templateId': 'template123',
      };

      when(() => mockCacheBox.get('template_template123')).thenReturn(cacheData);

      // Act
      await cacheService.getCachedWorkout('template123');

      // Assert
      verify(() => mockCacheBox.delete('template_template123')).called(1);
    });

    test('should handle errors gracefully and return null', () async {
      // Arrange
      await cacheService.initialize();
      when(() => mockCacheBox.get('template_template123')).thenThrow(Exception('Box error'));

      // Act
      final result = await cacheService.getCachedWorkout('template123');

      // Assert
      expect(result, isNull);
    });

    test('should auto-initialize if not initialized', () async {
      // Arrange - Don't initialize manually
      when(() => mockCacheBox.get('template_template123')).thenReturn(null);

      // Act
      await cacheService.getCachedWorkout('template123');

      // Assert - Should auto-initialize
      verify(() => mockBoxManager.openBox<Map<dynamic, dynamic>>('template_cache')).called(1);
    });
  });

  group('WorkoutTemplateCacheService - Has Cache', () {
    test('should return true when cache exists', () async {
      // Arrange
      await cacheService.initialize();
      when(() => mockCacheBox.containsKey('template_template123')).thenReturn(true);

      // Act
      final result = await cacheService.hasCache('template123');

      // Assert
      expect(result, isTrue);
    });

    test('should return false when cache does not exist', () async {
      // Arrange
      await cacheService.initialize();
      when(() => mockCacheBox.containsKey('template_template123')).thenReturn(false);

      // Act
      final result = await cacheService.hasCache('template123');

      // Assert
      expect(result, isFalse);
    });
  });

  group('WorkoutTemplateCacheService - Get Cache Last Modified', () {
    test('should return last modified date when cache exists', () async {
      // Arrange
      await cacheService.initialize();
      final lastModified = DateTime(2024, 1, 15, 10, 30);
      final cacheData = {
        'workout': _createTestWorkout().toJson(),
        'lastModified': lastModified.toIso8601String(),
        'templateId': 'template123',
      };

      when(() => mockCacheBox.get('template_template123')).thenReturn(cacheData);

      // Act
      final result = await cacheService.getCacheLastModified('template123');

      // Assert
      expect(result, isNotNull);
      expect(result!.year, equals(2024));
      expect(result.month, equals(1));
      expect(result.day, equals(15));
    });

    test('should return null when cache does not exist', () async {
      // Arrange
      await cacheService.initialize();
      when(() => mockCacheBox.get('template_template123')).thenReturn(null);

      // Act
      final result = await cacheService.getCacheLastModified('template123');

      // Assert
      expect(result, isNull);
    });

    test('should return null on error', () async {
      // Arrange
      await cacheService.initialize();
      when(() => mockCacheBox.get('template_template123')).thenThrow(Exception('Error'));

      // Act
      final result = await cacheService.getCacheLastModified('template123');

      // Assert
      expect(result, isNull);
    });
  });

  group('WorkoutTemplateCacheService - Clear Cache', () {
    test('should clear cache for specific template', () async {
      // Arrange
      await cacheService.initialize();

      // Act
      await cacheService.clearCache('template123');

      // Assert
      verify(() => mockCacheBox.delete('template_template123')).called(1);
    });

    test('should handle clear cache errors gracefully', () async {
      // Arrange
      await cacheService.initialize();
      when(() => mockCacheBox.delete('template_template123')).thenThrow(Exception('Delete error'));

      // Act & Assert - Should not throw
      await cacheService.clearCache('template123');
      expect(true, isTrue);
    });
  });

  group('WorkoutTemplateCacheService - Clear All Cache', () {
    test('should clear all cached templates', () async {
      // Arrange
      await cacheService.initialize();

      // Act
      await cacheService.clearAllCache();

      // Assert
      verify(() => mockCacheBox.clear()).called(1);
    });

    test('should handle clear all errors gracefully', () async {
      // Arrange
      await cacheService.initialize();
      when(() => mockCacheBox.clear()).thenThrow(Exception('Clear error'));

      // Act & Assert - Should not throw
      await cacheService.clearAllCache();
      expect(true, isTrue);
    });
  });

  group('WorkoutTemplateCacheService - Cache Expiration', () {
    test('should keep cache that is exactly 30 days old', () async {
      // Arrange
      await cacheService.initialize();
      final exactlyThirtyDays = DateTime.now().subtract(const Duration(days: 30));
      final cacheData = {
        'workout': _createTestWorkout().toJson(),
        'lastModified': exactlyThirtyDays.toIso8601String(),
        'templateId': 'template123',
      };

      when(() => mockCacheBox.get('template_template123')).thenReturn(cacheData);

      // Act
      final result = await cacheService.getCachedWorkout('template123');

      // Assert - Should still be valid (not expired)
      expect(result, isNotNull);
      verifyNever(() => mockCacheBox.delete(any()));
    });

    test('should delete cache that is 31 days old', () async {
      // Arrange
      await cacheService.initialize();
      final thirtyOneDays = DateTime.now().subtract(const Duration(days: 31));
      final cacheData = {
        'workout': _createTestWorkout().toJson(),
        'lastModified': thirtyOneDays.toIso8601String(),
        'templateId': 'template123',
      };

      when(() => mockCacheBox.get('template_template123')).thenReturn(cacheData);

      // Act
      final result = await cacheService.getCachedWorkout('template123');

      // Assert - Should be expired
      expect(result, isNull);
      verify(() => mockCacheBox.delete('template_template123')).called(1);
    });
  });

  group('WorkoutTemplateCacheService - Disposal', () {
    test('should dispose resources properly', () async {
      // Arrange
      await cacheService.initialize();

      // Act
      cacheService.dispose();

      // Assert - Should close cache box
      verify(() => mockCacheBox.close()).called(1);
    });

    test('should save pending data on dispose via forceSave', () async {
      // Arrange
      await cacheService.initialize();
      final workout = _createTestWorkout();

      cacheService.saveWorkoutModifications(
        templateId: 'template123',
        workout: workout,
      );

      // Act - Dispose before debounce completes
      // Note: dispose() calls forceSave() which saves pending data
      cacheService.dispose();

      // Assert - Should save pending data via forceSave (not timer)
      verify(() => mockCacheBox.put('template_template123', any())).called(1);
      verify(() => mockCacheBox.close()).called(1);
    });

    test('should not dispose twice', () async {
      // Arrange
      await cacheService.initialize();

      // Act
      cacheService.dispose();
      cacheService.dispose(); // Second dispose

      // Assert - Should only close once
      verify(() => mockCacheBox.close()).called(1);
    });
  });

  group('WorkoutTemplateCacheService - Integration Scenarios', () {
    test('should save, retrieve, and verify cached workout', () async {
      // Arrange
      await cacheService.initialize();
      final workout = _createTestWorkout(name: 'Integration Test Workout');

      // Track saved data
      Map<dynamic, dynamic>? savedData;
      when(() => mockCacheBox.put(any(), any())).thenAnswer((invocation) async {
        savedData = invocation.positionalArguments[1] as Map<dynamic, dynamic>;
      });

      // Act 1: Save
      cacheService.saveWorkoutModifications(
        templateId: 'template123',
        workout: workout,
      );
      await cacheService.forceSave();

      // Setup mock to return saved data
      when(() => mockCacheBox.get('template_template123')).thenReturn(savedData);

      // Act 2: Retrieve
      final retrieved = await cacheService.getCachedWorkout('template123');

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Integration Test Workout'));
    });

    test('should handle rapid successive saves correctly', () async {
      // Arrange
      await cacheService.initialize();

      // Act - Save rapidly 5 times
      for (int i = 0; i < 5; i++) {
        cacheService.saveWorkoutModifications(
          templateId: 'template123',
          workout: _createTestWorkout(name: 'Version $i'),
        );
        await Future.delayed(const Duration(milliseconds: 200));
      }

      await Future.delayed(const Duration(seconds: 2));

      // Assert - Should only save once (last version due to debouncing)
      verify(() => mockCacheBox.put('template_template123', any())).called(1);
    });
  });
}

/// Helper to create test Workout
Workout _createTestWorkout({String name = 'Test Workout'}) {
  return Workout(
    id: 'workout-id',
    name: name,
    exercises: [],
    status: WorkoutStatus.planned,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}
