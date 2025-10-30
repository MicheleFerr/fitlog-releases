import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/apre_calculation_service.dart';

void main() {
  late ProviderContainer container;
  late APRECalculationService service;

  setUp(() {
    container = ProviderContainer();
    // Create a minimal Ref implementation for testing
    final ref = _TestRef(container);
    service = APRECalculationService(ref);
  });

  tearDown(() {
    container.dispose();
  });

  group('APRECalculationService', () {
    test('should return exercises unchanged when no APRE exercises', () async {
      // Arrange
      final exercises = [
        Exercise(
          id: 'test1',
          name: 'Regular Exercise',
          useAPRE: false,
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(setNumber: 1, weight: 50.0, reps: 10),
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
          id: 'apre1',
          name: 'APRE Exercise',
          useAPRE: true,
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(setNumber: 1, weight: 100.0, reps: 10),
          ],
        ),
        Exercise(
          id: 'regular1',
          name: 'Regular Exercise',
          useAPRE: false,
          type: ExerciseType.single,
          category: ExerciseCategory.back,
          sets: [
            ExerciseSet(setNumber: 1, weight: 50.0, reps: 10),
          ],
        ),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert - Regular exercise should remain unchanged
      expect(result.length, equals(2));
      expect(result.any((e) => e.name == 'Regular Exercise'), isTrue);
    });

    test('should handle empty exercise list', () async {
      // Arrange
      final exercises = <Exercise>[];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert
      expect(result, equals(exercises));
      expect(result.isEmpty, isTrue);
    });

    test('should handle exercises with different types', () async {
      // Arrange
      final exercises = [
        Exercise(
          id: 'apre_superset',
          name: 'APRE Superset',
          useAPRE: true,
          type: ExerciseType.superset,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(setNumber: 1, weight: 100.0, reps: 10),
          ],
        ),
        Exercise(
          id: 'apre_dropset',
          name: 'APRE Dropset',
          useAPRE: true,
          type: ExerciseType.dropset,
          category: ExerciseCategory.legs,
          sets: [
            ExerciseSet(setNumber: 1, weight: 100.0, reps: 10),
          ],
        ),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert
      expect(result.length, equals(2));
    });

    test('should handle concurrent calculation requests', () async {
      // Arrange
      final exercises = [
        Exercise(
          id: 'apre1',
          name: 'APRE Exercise',
          useAPRE: true,
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(setNumber: 1, weight: 100.0, reps: 10),
          ],
        ),
      ];

      // Act - Start two calculations concurrently
      final future1 = service.preCalculateAllAPREWeights(exercises);
      final future2 = service.preCalculateAllAPREWeights(exercises);

      final result1 = await future1;
      final result2 = await future2;

      // Assert - Second calculation should return exercises unchanged
      expect(result2, equals(exercises));
    });

    test('should preserve exercise order', () async {
      // Arrange
      final exercises = [
        Exercise(
          id: 'ex1',
          name: 'First',
          useAPRE: false,
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [],
        ),
        Exercise(
          id: 'ex2',
          name: 'Second',
          useAPRE: true,
          type: ExerciseType.single,
          category: ExerciseCategory.back,
          sets: [ExerciseSet(setNumber: 1, weight: 50.0, reps: 10)],
        ),
        Exercise(
          id: 'ex3',
          name: 'Third',
          useAPRE: false,
          type: ExerciseType.single,
          category: ExerciseCategory.legs,
          sets: [],
        ),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert - Order should be maintained
      expect(result[0].name, equals('First'));
      expect(result[1].name, equals('Second'));
      expect(result[2].name, equals('Third'));
    });

    test('should handle exercises with multiple sets', () async {
      // Arrange
      final exercises = [
        Exercise(
          id: 'apre1',
          name: 'APRE Exercise',
          useAPRE: true,
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(setNumber: 1, weight: 100.0, reps: 10),
            ExerciseSet(setNumber: 2, weight: 100.0, reps: 9),
            ExerciseSet(setNumber: 3, weight: 100.0, reps: 8),
          ],
        ),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert
      expect(result.first.sets.length, equals(3));
    });

    test('should not modify non-APRE exercises', () async {
      // Arrange
      const originalWeight = 75.0;
      final exercises = [
        Exercise(
          id: 'regular1',
          name: 'Regular Exercise',
          useAPRE: false,
          type: ExerciseType.single,
          category: ExerciseCategory.arms,
          sets: [
            ExerciseSet(setNumber: 1, weight: originalWeight, reps: 12),
          ],
        ),
      ];

      // Act
      final result = await service.preCalculateAllAPREWeights(exercises);

      // Assert - Weight should remain unchanged
      expect(result.first.sets.first.weight, equals(originalWeight));
    });
  });
}

/// Minimal Ref implementation for testing
class _TestRef implements Ref {
  _TestRef(this.container);

  final ProviderContainer container;

  @override
  T read<T>(ProviderListenable<T> provider) {
    return container.read(provider);
  }

  @override
  void Function() listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return container.listen(provider, listener, onError: onError);
  }

  @override
  T watch<T>(ProviderListenable<T> provider) {
    return container.read(provider);
  }

  @override
  void invalidate(ProviderOrFamily provider) {
    container.invalidate(provider);
  }

  @override
  void refresh<T>(Refreshable<T> provider) {
    container.refresh(provider);
  }

  @override
  bool exists(ProviderBase<Object?> provider) {
    return true;
  }

  @override
  ProviderSubscription<T> listenManual<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) {
    throw UnimplementedError();
  }

  @override
  void onDispose(void Function() cb) {}

  @override
  State get context => throw UnimplementedError();

  @override
  ProviderContainer get container => throw UnimplementedError();
}
