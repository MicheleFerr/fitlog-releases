import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_card.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/apre_calculation_service.dart';

void main() {
  late ProviderContainer container;
  late APRECalculationService service;

  setUp(() {
    container = ProviderContainer();
    service = APRECalculationService(container);
  });

  tearDown(() {
    container.dispose();
  });

  group('APRECalculationService', () {
    test('should return exercises unchanged when no APRE exercises', () async {
      // Arrange
      final exercises = [
        Exercise(
          exerciseId: 'test1',
          name: 'Regular Exercise',
          useAPRE: false,
          type: ExerciseType.single,
          sets: [
            ExerciseCard(reps: 10, weight: '50', isCompleted: false),
          ],
        ),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert
      expect(result, equals(exercises));
      expect(result.length, equals(1));
    });

    test('should filter APRE exercises correctly', () async {
      // Arrange
      final exercises = [
        Exercise(
          exerciseId: 'apre1',
          name: 'APRE Exercise',
          useAPRE: true,
          type: ExerciseType.single,
          sets: [
            ExerciseCard(reps: 10, weight: '100', isCompleted: false),
          ],
        ),
        Exercise(
          exerciseId: 'regular1',
          name: 'Regular Exercise',
          useAPRE: false,
          type: ExerciseType.single,
          sets: [
            ExerciseCard(reps: 10, weight: '50', isCompleted: false),
          ],
        ),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert
      expect(result.length, equals(2));
      expect(result.any((ex) => ex.useAPRE), isTrue);
    });

    test('should not calculate when calculation is in progress', () async {
      // Arrange
      final exercises = [
        Exercise(
          exerciseId: 'apre1',
          name: 'APRE Exercise',
          useAPRE: true,
          type: ExerciseType.single,
          sets: [
            ExerciseCard(reps: 10, weight: '100', isCompleted: false),
          ],
        ),
      ];

      // Act - Start first calculation (don't await)
      final future1 = service.preCalculateAllAPREWeights(exercises);

      // Try to start second calculation immediately
      final future2 = service.preCalculateAllAPREWeights(exercises);

      // Wait for both
      final result1 = await future1;
      final result2 = await future2;

      // Assert - Second call should return original exercises unchanged
      expect(result2, equals(exercises));
    });

    test('should handle empty exercise list', () async {
      // Arrange
      final exercises = <Exercise>[];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert
      expect(result, isEmpty);
    });

    test('should only process single-type exercises', () async {
      // Arrange
      final exercises = [
        Exercise(
          exerciseId: 'apre_superset',
          name: 'APRE Superset',
          useAPRE: true,
          type: ExerciseType.superset,
          sets: [
            ExerciseCard(reps: 10, weight: '100', isCompleted: false),
          ],
        ),
        Exercise(
          exerciseId: 'apre_single',
          name: 'APRE Single',
          useAPRE: true,
          type: ExerciseType.single,
          sets: [
            ExerciseCard(reps: 10, weight: '100', isCompleted: false),
          ],
        ),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert
      expect(result.length, equals(2));
      // Only single-type should be processed
    });

    test('should handle exercises with multiple sets', () async {
      // Arrange
      final exercises = [
        Exercise(
          exerciseId: 'apre1',
          name: 'APRE Exercise',
          useAPRE: true,
          type: ExerciseType.single,
          sets: [
            ExerciseCard(reps: 10, weight: '100', isCompleted: false),
            ExerciseCard(reps: 8, weight: '110', isCompleted: false),
            ExerciseCard(reps: 6, weight: '120', isCompleted: false),
          ],
        ),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert
      expect(result.length, equals(1));
      expect(result.first.sets.length, equals(3));
    });

    test('should maintain exercise order', () async {
      // Arrange
      final exercises = [
        Exercise(
          exerciseId: 'ex1',
          name: 'Exercise 1',
          useAPRE: true,
          type: ExerciseType.single,
          sets: [ExerciseCard(reps: 10, weight: '100', isCompleted: false)],
        ),
        Exercise(
          exerciseId: 'ex2',
          name: 'Exercise 2',
          useAPRE: false,
          type: ExerciseType.single,
          sets: [ExerciseCard(reps: 10, weight: '50', isCompleted: false)],
        ),
        Exercise(
          exerciseId: 'ex3',
          name: 'Exercise 3',
          useAPRE: true,
          type: ExerciseType.single,
          sets: [ExerciseCard(reps: 10, weight: '80', isCompleted: false)],
        ),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert
      expect(result.length, equals(3));
      expect(result[0].exerciseId, equals('ex1'));
      expect(result[1].exerciseId, equals('ex2'));
      expect(result[2].exerciseId, equals('ex3'));
    });
  });
}
