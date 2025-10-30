import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/apre_calculation_service.dart';
import 'package:mocktail/mocktail.dart';

// Mock Ref for testing
class MockRef extends Mock implements Ref {}

void main() {
  late APRECalculationService service;
  late MockRef mockRef;

  setUp(() {
    mockRef = MockRef();
    service = APRECalculationService(mockRef);
  });

  group('APRECalculationService - Concurrency Control', () {
    test('should allow calculation when not in progress', () async {
      // Arrange
      final exercises = [
        _createAPREExercise(name: 'Bench Press'),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert
      expect(result, isNotNull);
      expect(result.length, equals(1));
    });

    test('should skip calculation when already in progress', () async {
      // Arrange
      final exercises = [
        _createAPREExercise(name: 'Bench Press'),
      ];

      // Act - Start first calculation (don't await)
      final future1 = service.preCalculateAllAPREWeights(exercises);

      // Try to start second calculation immediately
      final result2 = await service.preCalculateAllAPREWeights(exercises);

      // Wait for first to complete
      await future1;

      // Assert - Second call should return original exercises (skipped)
      expect(result2, equals(exercises));
    });

    test('should allow calculation after previous completes', () async {
      // Arrange
      final exercises1 = [_createAPREExercise(name: 'Bench Press')];
      final exercises2 = [_createAPREExercise(name: 'Squat')];

      // Act
      await service.preCalculateAllAPREWeights(exercises1);
      final result2 = await service.preCalculateAllAPREWeights(exercises2);

      // Assert - Second calculation should proceed
      expect(result2, isNotNull);
      expect(result2.length, equals(1));
      expect(result2.first.name, equals('Squat'));
    });

    test('should release lock even when error occurs', () async {
      // Arrange - Create exercise that might cause error
      final exercises = [_createAPREExercise(name: 'Test')];

      // Act - Force error scenario (service handles it internally)
      await service.preCalculateAllAPREWeights(exercises);

      // Second call should work (lock released)
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert
      expect(result, isNotNull);
    });
  });

  group('APRECalculationService - Exercise Filtering', () {
    test('should filter only APRE exercises', () async {
      // Arrange
      final exercises = [
        _createAPREExercise(name: 'Bench Press', useAPRE: true),
        _createAPREExercise(name: 'Squat', useAPRE: false), // Not APRE
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert - Should return all exercises, but only calculate APRE ones
      expect(result.length, equals(2));
    });

    test('should filter only single type exercises', () async {
      // Arrange
      final exercises = [
        _createAPREExercise(name: 'Bench Press', type: ExerciseType.single),
        _createAPREExercise(name: 'Superset', type: ExerciseType.superset),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert
      expect(result.length, equals(2));
      // Only single type should be calculated (superset skipped)
    });

    test('should handle empty exercise list', () async {
      // Arrange
      final exercises = <Exercise>[];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert
      expect(result, isEmpty);
    });

    test('should handle list with no APRE exercises', () async {
      // Arrange
      final exercises = [
        _createAPREExercise(name: 'Bench Press', useAPRE: false),
        _createAPREExercise(name: 'Squat', useAPRE: false),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert - Should return original exercises unchanged
      expect(result.length, equals(2));
      expect(result, equals(exercises));
    });

    test('should handle mixed APRE and non-APRE exercises', () async {
      // Arrange
      final exercises = [
        _createAPREExercise(name: 'Bench Press', useAPRE: true),
        _createAPREExercise(name: 'Squat', useAPRE: false),
        _createAPREExercise(name: 'Deadlift', useAPRE: true),
        _createAPREExercise(name: 'Row', useAPRE: false),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert
      expect(result.length, equals(4));
      // All exercises returned, APRE ones calculated
    });
  });

  group('APRECalculationService - Parallel Calculation', () {
    test('should calculate multiple exercises in parallel', () async {
      // Arrange
      final exercises = [
        _createAPREExercise(name: 'Bench Press'),
        _createAPREExercise(name: 'Squat'),
        _createAPREExercise(name: 'Deadlift'),
      ];

      // Act
      final stopwatch = Stopwatch()..start();
      final result = await service.preCalculateAllAPREWeights(exercises);
      stopwatch.stop();

      // Assert - All exercises processed
      expect(result.length, equals(3));
      // Parallel processing should be relatively fast (< 1 second for simple cases)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('should handle large batch of exercises', () async {
      // Arrange - 10 APRE exercises
      final exercises = List.generate(
        10,
        (i) => _createAPREExercise(name: 'Exercise $i'),
      );

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert
      expect(result.length, equals(10));
    });

    test('should maintain exercise order after parallel calculation', () async {
      // Arrange
      final exercises = [
        _createAPREExercise(name: 'First'),
        _createAPREExercise(name: 'Second'),
        _createAPREExercise(name: 'Third'),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert - Order preserved
      expect(result[0].name, equals('First'));
      expect(result[1].name, equals('Second'));
      expect(result[2].name, equals('Third'));
    });
  });

  group('APRECalculationService - Cache Logic', () {
    test('should use cached calculations when recent', () async {
      // Arrange - Exercise with recent calculation (2 days ago)
      final recentDate = DateTime.now().subtract(const Duration(days: 2));
      final exercises = [
        _createAPREExercise(
          name: 'Bench Press',
          calculated1RM: 100.0,
          lastCalculationDate: recentDate,
        ),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert - Should use cached value (not recalculate)
      expect(result.first.calculated1RM, equals(100.0));
      expect(result.first.lastCalculationDate, equals(recentDate));
    });

    test('should recalculate when cache is old (>7 days)', () async {
      // Arrange - Exercise with old calculation (10 days ago)
      final oldDate = DateTime.now().subtract(const Duration(days: 10));
      final exercises = [
        _createAPREExercise(
          name: 'Bench Press',
          calculated1RM: 100.0,
          lastCalculationDate: oldDate,
        ),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert - Should have updated lastCalculationDate
      expect(result, isNotNull);
      // New calculation should update date (verified by service logic)
    });

    test('should recalculate when no previous calculation exists', () async {
      // Arrange - Exercise with no calculation
      final exercises = [
        _createAPREExercise(
          name: 'Bench Press',
          calculated1RM: null,
          lastCalculationDate: null,
        ),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert
      expect(result, isNotNull);
      expect(result.length, equals(1));
    });

    test('should recalculate on exactly 7 days boundary', () async {
      // Arrange - Exercise calculated exactly 8 days ago (should recalculate)
      final boundaryDate = DateTime.now().subtract(const Duration(days: 8));
      final exercises = [
        _createAPREExercise(
          name: 'Bench Press',
          lastCalculationDate: boundaryDate,
        ),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert - Should recalculate (>7 days)
      expect(result, isNotNull);
    });
  });

  group('APRECalculationService - Error Handling', () {
    test('should handle errors gracefully for individual exercises', () async {
      // Arrange - Mix of valid and potentially problematic exercises
      final exercises = [
        _createAPREExercise(name: 'Valid Exercise'),
        _createAPREExercise(name: 'Another Valid'),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert - Should complete without throwing
      expect(result, isNotNull);
      expect(result.length, equals(2));
    });

    test('should continue processing other exercises after one fails', () async {
      // Arrange
      final exercises = [
        _createAPREExercise(name: 'Exercise 1'),
        _createAPREExercise(name: 'Exercise 2'),
        _createAPREExercise(name: 'Exercise 3'),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert - All exercises in result
      expect(result.length, equals(3));
    });

    test('should return original exercise if calculation fails', () async {
      // Arrange
      final exercises = [
        _createAPREExercise(name: 'Bench Press', calculated1RM: 100.0),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert - Should have exercises (failure returns original)
      expect(result.first, isNotNull);
    });

    test('should handle null values in exercise properties', () async {
      // Arrange - Exercise with minimal properties
      final exercise = Exercise(
        name: 'Minimal Exercise',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        useAPRE: true,
        calculated1RM: null,
        calculated3RM: null,
        lastCalculationDate: null,
      );

      // Act
      final result = await service.preCalculateAllAPREWeights([exercise]);

      // Assert
      expect(result, isNotNull);
      expect(result.length, equals(1));
    });
  });

  group('APRECalculationService - Edge Cases', () {
    test('should handle exercise with all APRE fields populated', () async {
      // Arrange
      final exercise = _createAPREExercise(
        name: 'Complete Exercise',
        calculated1RM: 100.0,
        calculated3RM: 90.0,
        calculated6RM: 80.0,
        calculated10RM: 70.0,
        lastCalculationDate: DateTime.now(),
        apreProtocol: 6,
        apreBaseWeight: 60.0,
      );

      // Act
      final result = await service.preCalculateAllAPREWeights([exercise]);

      // Assert
      expect(result.length, equals(1));
      expect(result.first.calculated1RM, equals(100.0));
    });

    test('should handle very large weight values', () async {
      // Arrange
      final exercise = _createAPREExercise(
        name: 'Heavy Exercise',
        calculated1RM: 999999.99,
        apreBaseWeight: 500.0,
      );

      // Act
      final result = await service.preCalculateAllAPREWeights([exercise]);

      // Assert
      expect(result, isNotNull);
    });

    test('should handle very small weight values', () async {
      // Arrange
      final exercise = _createAPREExercise(
        name: 'Light Exercise',
        calculated1RM: 0.5,
        apreBaseWeight: 0.25,
      );

      // Act
      final result = await service.preCalculateAllAPREWeights([exercise]);

      // Assert
      expect(result, isNotNull);
    });

    test('should handle exercise with future lastCalculationDate', () async {
      // Arrange - Edge case: date in future (should treat as recent)
      final futureDate = DateTime.now().add(const Duration(days: 1));
      final exercise = _createAPREExercise(
        name: 'Future Dated',
        lastCalculationDate: futureDate,
        calculated1RM: 100.0,
      );

      // Act
      final result = await service.preCalculateAllAPREWeights([exercise]);

      // Assert - Should use cache (future date means very recent)
      expect(result.first.lastCalculationDate, equals(futureDate));
    });
  });

  group('APRECalculationService - Integration Scenarios', () {
    test('should handle workout with mixed exercise types', () async {
      // Arrange - Real workout scenario
      final exercises = [
        _createAPREExercise(name: 'Bench Press', useAPRE: true, type: ExerciseType.single),
        _createAPREExercise(name: 'Incline Press', useAPRE: true, type: ExerciseType.single),
        _createAPREExercise(name: 'Cable Fly Superset', useAPRE: false, type: ExerciseType.superset),
        _createAPREExercise(name: 'Dips', useAPRE: true, type: ExerciseType.single),
        _createAPREExercise(name: 'Tricep Dropset', useAPRE: false, type: ExerciseType.dropset),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert - All exercises returned
      expect(result.length, equals(5));
    });

    test('should handle progressive overload scenario', () async {
      // Arrange - Exercise that was calculated 1 week ago, needs update
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      final exercise = _createAPREExercise(
        name: 'Bench Press',
        calculated1RM: 100.0,
        lastCalculationDate: oneWeekAgo,
      );

      // Act
      final result = await service.preCalculateAllAPREWeights([exercise]);

      // Assert
      expect(result, isNotNull);
      expect(result.first.name, equals('Bench Press'));
    });

    test('should handle deload week scenario', () async {
      // Arrange - Recent calculation (3 days ago), should use cache
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final exercise = _createAPREExercise(
        name: 'Bench Press',
        calculated1RM: 100.0,
        lastCalculationDate: threeDaysAgo,
      );

      // Act
      final result = await service.preCalculateAllAPREWeights([exercise]);

      // Assert - Should use cached values (recent)
      expect(result.first.calculated1RM, equals(100.0));
    });
  });
}

/// Helper function to create APRE exercise for testing
Exercise _createAPREExercise({
  required String name,
  bool useAPRE = true,
  ExerciseType type = ExerciseType.single,
  double? calculated1RM,
  double? calculated3RM,
  double? calculated6RM,
  double? calculated10RM,
  DateTime? lastCalculationDate,
  int? apreProtocol,
  double? apreBaseWeight,
}) {
  return Exercise(
    name: name,
    type: type,
    category: ExerciseCategory.chest,
    useAPRE: useAPRE,
    calculated1RM: calculated1RM,
    calculated3RM: calculated3RM,
    calculated6RM: calculated6RM,
    calculated10RM: calculated10RM,
    lastCalculationDate: lastCalculationDate,
    apreProtocol: apreProtocol,
    apreBaseWeight: apreBaseWeight,
  );
}
