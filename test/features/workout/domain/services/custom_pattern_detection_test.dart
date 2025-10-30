import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/pattern_detection_service.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';

class MockHiveWorkoutDataSource extends Mock implements HiveWorkoutDataSource {}

void main() {
  late PatternDetectionService service;
  late MockHiveWorkoutDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockHiveWorkoutDataSource();
    service = PatternDetectionService(hiveDataSource: mockDataSource);
  });

  group('Custom Name Pattern Detection', () {
    test('should detect pattern with custom names like Pippo, Giovanni, Mario', () async {
      // Arrange: workout history con nomi custom
      final now = DateTime.now();
      final workouts = [
        WorkoutModel(
          id: '1',
          name: 'Pippo',
          startTime: now.subtract(const Duration(days: 18)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 18)),
          updatedAt: now.subtract(const Duration(days: 18)),
        ),
        WorkoutModel(
          id: '2',
          name: 'Giovanni',
          startTime: now.subtract(const Duration(days: 16)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 16)),
          updatedAt: now.subtract(const Duration(days: 16)),
        ),
        WorkoutModel(
          id: '3',
          name: 'Mario',
          startTime: now.subtract(const Duration(days: 14)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 14)),
          updatedAt: now.subtract(const Duration(days: 14)),
        ),
        WorkoutModel(
          id: '4',
          name: 'Pippo',
          startTime: now.subtract(const Duration(days: 12)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 12)),
          updatedAt: now.subtract(const Duration(days: 12)),
        ),
        WorkoutModel(
          id: '5',
          name: 'Giovanni',
          startTime: now.subtract(const Duration(days: 10)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 10)),
          updatedAt: now.subtract(const Duration(days: 10)),
        ),
        WorkoutModel(
          id: '6',
          name: 'Mario',
          startTime: now.subtract(const Duration(days: 8)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 8)),
          updatedAt: now.subtract(const Duration(days: 8)),
        ),
      ];

      when(() => mockDataSource.getWorkouts(
        any(),
        startDate: any(named: 'startDate'),
        limit: any(named: 'limit'),
      )).thenAnswer((_) async => workouts);

      // Act: Extract custom names (normalizeNames = false)
      final sequence = await service.extractSequences(
        userId: 'user123',
        lookbackDays: 21,
        normalizeNames: false, // IMPORTANTE: nomi custom
      );

      // Assert: Sequenza deve essere Pippo → Giovanni → Mario (ripetuto)
      expect(sequence, ['Pippo', 'Giovanni', 'Mario', 'Pippo', 'Giovanni', 'Mario']);
    });

    test('should detect pattern with mixed custom and standard names', () async {
      // Arrange: mix di nomi custom e standard
      final now = DateTime.now();
      final workouts = [
        WorkoutModel(
          id: '1',
          name: 'Super Push Workout',
          startTime: now.subtract(const Duration(days: 18)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 18)),
          updatedAt: now.subtract(const Duration(days: 18)),
        ),
        WorkoutModel(
          id: '2',
          name: 'Pull Strong',
          startTime: now.subtract(const Duration(days: 16)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 16)),
          updatedAt: now.subtract(const Duration(days: 16)),
        ),
        WorkoutModel(
          id: '3',
          name: 'Gambe',
          startTime: now.subtract(const Duration(days: 14)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 14)),
          updatedAt: now.subtract(const Duration(days: 14)),
        ),
        WorkoutModel(
          id: '4',
          name: 'Super Push Workout',
          startTime: now.subtract(const Duration(days: 12)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 12)),
          updatedAt: now.subtract(const Duration(days: 12)),
        ),
        WorkoutModel(
          id: '5',
          name: 'Pull Strong',
          startTime: now.subtract(const Duration(days: 10)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 10)),
          updatedAt: now.subtract(const Duration(days: 10)),
        ),
        WorkoutModel(
          id: '6',
          name: 'Gambe',
          startTime: now.subtract(const Duration(days: 8)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 8)),
          updatedAt: now.subtract(const Duration(days: 8)),
        ),
      ];

      when(() => mockDataSource.getWorkouts(
        any(),
        startDate: any(named: 'startDate'),
        limit: any(named: 'limit'),
      )).thenAnswer((_) async => workouts);

      // Act: Con normalizeNames = false, mantiene nomi originali
      final customSequence = await service.extractSequences(
        userId: 'user123',
        lookbackDays: 21,
        normalizeNames: false,
      );

      // Act: Con normalizeNames = true, normalizza
      final normalizedSequence = await service.extractSequences(
        userId: 'user123',
        lookbackDays: 21,
        normalizeNames: true,
      );

      // Assert: Custom preserva nomi originali
      expect(customSequence, [
        'Super Push Workout',
        'Pull Strong',
        'Gambe',
        'Super Push Workout',
        'Pull Strong',
        'Gambe',
      ]);

      // Assert: Normalized usa categorie
      expect(normalizedSequence, [
        'PUSH',
        'PULL',
        'LEGS',
        'PUSH',
        'PULL',
        'LEGS',
      ]);
    });

    test('should handle spaces and case sensitivity correctly for custom names', () async {
      // Arrange: Workout con spazi e case variabile
      final now = DateTime.now();
      final workouts = [
        WorkoutModel(
          id: '1',
          name: '  Pippo  ', // Spazi extra
          startTime: now.subtract(const Duration(days: 12)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 12)),
          updatedAt: now.subtract(const Duration(days: 12)),
        ),
        WorkoutModel(
          id: '2',
          name: 'GIOVANNI', // Tutto maiuscolo
          startTime: now.subtract(const Duration(days: 10)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 10)),
          updatedAt: now.subtract(const Duration(days: 10)),
        ),
        WorkoutModel(
          id: '3',
          name: 'mario', // Tutto minuscolo
          startTime: now.subtract(const Duration(days: 8)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 8)),
          updatedAt: now.subtract(const Duration(days: 8)),
        ),
      ];

      when(() => mockDataSource.getWorkouts(
        any(),
        startDate: any(named: 'startDate'),
        limit: any(named: 'limit'),
      )).thenAnswer((_) async => workouts);

      // Act
      final sequence = await service.extractSequences(
        userId: 'user123',
        lookbackDays: 21,
        normalizeNames: false,
      );

      // Assert: Dovrebbe trimmare gli spazi
      expect(sequence, ['Pippo', 'GIOVANNI', 'mario']);
    });

    test('should handle empty workout names gracefully', () async {
      // Arrange
      final now = DateTime.now();
      final workouts = [
        WorkoutModel(
          id: '1',
          name: 'Pippo',
          startTime: now.subtract(const Duration(days: 12)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 12)),
          updatedAt: now.subtract(const Duration(days: 12)),
        ),
        WorkoutModel(
          id: '3',
          name: '', // Nome vuoto
          startTime: now.subtract(const Duration(days: 8)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 8)),
          updatedAt: now.subtract(const Duration(days: 8)),
        ),
        WorkoutModel(
          id: '4',
          name: 'Giovanni',
          startTime: now.subtract(const Duration(days: 6)),
          exercises: const [],
          status: 'completed',
          createdAt: now.subtract(const Duration(days: 6)),
          updatedAt: now.subtract(const Duration(days: 6)),
        ),
      ];

      when(() => mockDataSource.getWorkouts(
        any(),
        startDate: any(named: 'startDate'),
        limit: any(named: 'limit'),
      )).thenAnswer((_) async => workouts);

      // Act
      final sequence = await service.extractSequences(
        userId: 'user123',
        lookbackDays: 21,
        normalizeNames: false,
      );

      // Assert: Dovrebbe skipare i workout senza nome
      expect(sequence, ['Pippo', 'Giovanni']);
    });
  });

  group('SimplePatternDetector with Custom Names', () {
    test('should detect repeating custom name pattern', () {
      // Arrange
      final detector = SimplePatternDetector();
      final sequence = ['Pippo', 'Giovanni', 'Mario', 'Pippo', 'Giovanni', 'Mario'];

      // Act
      final result = detector.detectRepeatingPattern(sequence);

      // Assert
      expect(result, isNotNull);
      expect(result!.pattern, ['Pippo', 'Giovanni', 'Mario']);
      expect(result.confidence, greaterThanOrEqualTo(0.75));
      expect(result.occurrences, 2);
    });

    test('should predict next workout in custom pattern', () {
      // Arrange
      final detector = SimplePatternDetector();
      final sequence = ['Pippo', 'Giovanni', 'Mario', 'Pippo', 'Giovanni', 'Mario'];

      // Act
      final result = detector.detectRepeatingPattern(sequence);
      final nextWorkout = result!.predictNext(sequence);

      // Assert: Dopo Mario dovrebbe essere Pippo
      expect(nextWorkout, 'Pippo');
    });

    test('should work with pattern of 2 custom names', () {
      // Arrange
      final detector = SimplePatternDetector();
      final sequence = ['Alfa', 'Beta', 'Alfa', 'Beta', 'Alfa', 'Beta'];

      // Act
      final result = detector.detectRepeatingPattern(sequence);

      // Assert
      expect(result, isNotNull);
      expect(result!.pattern, ['Alfa', 'Beta']);
      expect(result.confidence, greaterThanOrEqualTo(0.75));
    });
  });
}
