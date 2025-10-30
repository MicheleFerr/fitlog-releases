import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/pattern_detection_service.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';

class MockHiveWorkoutDataSource extends Mock implements HiveWorkoutDataSource {}

void main() {
  late PatternDetectionService service;
  late MockHiveWorkoutDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockHiveWorkoutDataSource();
    service = PatternDetectionService(hiveDataSource: mockDataSource);
  });

  group('PatternDetectionService', () {
    group('normalizeWorkoutType', () {
      test('should normalize push-related keywords correctly', () {
        expect(PatternDetectionService.normalizeWorkoutType('Push Day'), 'PUSH');
        expect(PatternDetectionService.normalizeWorkoutType('Chest & Triceps'), 'PUSH');
        expect(PatternDetectionService.normalizeWorkoutType('Petto e Tricipiti'), 'PUSH');
        expect(PatternDetectionService.normalizeWorkoutType('Spinta'), 'PUSH');
        expect(PatternDetectionService.normalizeWorkoutType('Bench Press Day'), 'PUSH');
        expect(PatternDetectionService.normalizeWorkoutType('Shoulder Session'), 'PUSH');

        // Variazioni creative/giocose
        expect(PatternDetectionService.normalizeWorkoutType('Pushiamo'), 'PUSH');
        expect(PatternDetectionService.normalizeWorkoutType('Spingiamo Forte'), 'PUSH');
        expect(PatternDetectionService.normalizeWorkoutType('Premi e Basta'), 'PUSH');
      });

      test('should normalize pull-related keywords correctly', () {
        expect(PatternDetectionService.normalizeWorkoutType('Pull Day'), 'PULL');
        expect(PatternDetectionService.normalizeWorkoutType('Back & Biceps'), 'PULL');
        expect(PatternDetectionService.normalizeWorkoutType('Schiena'), 'PULL');
        expect(PatternDetectionService.normalizeWorkoutType('Tirata'), 'PULL');
        expect(PatternDetectionService.normalizeWorkoutType('Deadlift Day'), 'PULL');
        expect(PatternDetectionService.normalizeWorkoutType('Lat Pulldown Focus'), 'PULL');

        // Variazioni creative/giocose
        expect(PatternDetectionService.normalizeWorkoutType('Pulliamo'), 'PULL');
        expect(PatternDetectionService.normalizeWorkoutType('Tiriamo Tutto'), 'PULL');
      });

      test('should normalize leg-related keywords correctly', () {
        expect(PatternDetectionService.normalizeWorkoutType('Leg Day'), 'LEGS');
        expect(PatternDetectionService.normalizeWorkoutType('Gambe'), 'LEGS');
        expect(PatternDetectionService.normalizeWorkoutType('Squat Session'), 'LEGS');
        expect(PatternDetectionService.normalizeWorkoutType('Quad & Hamstring'), 'LEGS');
        expect(PatternDetectionService.normalizeWorkoutType('Glutes Focus'), 'LEGS');

        // Variazioni creative/giocose
        expect(PatternDetectionService.normalizeWorkoutType('Legghiamo'), 'LEGS');
        expect(PatternDetectionService.normalizeWorkoutType('Gambizziamo'), 'LEGS');
        expect(PatternDetectionService.normalizeWorkoutType('Gambettoni Power'), 'LEGS');
      });

      test('should normalize upper/lower body keywords correctly', () {
        expect(PatternDetectionService.normalizeWorkoutType('Upper Body'), 'UPPER');
        expect(PatternDetectionService.normalizeWorkoutType('Parte Superiore'), 'UPPER');
        // Note: 'Lower Body' maps to 'LEGS' because 'legs' keyword is checked before 'lower'
        expect(PatternDetectionService.normalizeWorkoutType('Lower Body'), 'LEGS');
        expect(PatternDetectionService.normalizeWorkoutType('Parte Inferiore'), 'LOWER');
      });

      test('should normalize full body keywords correctly', () {
        expect(PatternDetectionService.normalizeWorkoutType('Full Body'), 'FULL_BODY');
        expect(PatternDetectionService.normalizeWorkoutType('Total Body'), 'FULL_BODY');
        expect(PatternDetectionService.normalizeWorkoutType('HIIT Circuit'), 'FULL_BODY');
        expect(PatternDetectionService.normalizeWorkoutType('CrossFit WOD'), 'FULL_BODY');
        expect(PatternDetectionService.normalizeWorkoutType('Functional Training'), 'FULL_BODY');
      });

      test('should create custom normalized name for unmatched workouts', () {
        expect(PatternDetectionService.normalizeWorkoutType('Custom Workout 123'),
               'CUSTOM_WORKOUT_123');
        expect(PatternDetectionService.normalizeWorkoutType('My Special Routine'),
               'MY_SPECIAL_ROUTINE');
      });

      test('should handle null and empty strings', () {
        expect(PatternDetectionService.normalizeWorkoutType(null), null);
        expect(PatternDetectionService.normalizeWorkoutType(''), null);
      });
    });

    group('extractSequences', () {
      test('should handle creative Italian names like Pushiamo/Pulliamo/Legghiamo', () async {
        final now = DateTime.now();
        final workouts = [
          WorkoutModel(
            id: '1',
            name: 'Pushiamo',
            startTime: now.subtract(const Duration(days: 6)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(days: 6)),
            updatedAt: now.subtract(const Duration(days: 6)),
          ),
          WorkoutModel(
            id: '2',
            name: 'Pulliamo',
            startTime: now.subtract(const Duration(days: 5)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(days: 5)),
            updatedAt: now.subtract(const Duration(days: 5)),
          ),
          WorkoutModel(
            id: '3',
            name: 'Legghiamo',
            startTime: now.subtract(const Duration(days: 4)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(days: 4)),
            updatedAt: now.subtract(const Duration(days: 4)),
          ),
          WorkoutModel(
            id: '4',
            name: 'Pushiamo Forte',
            startTime: now.subtract(const Duration(days: 3)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(days: 3)),
            updatedAt: now.subtract(const Duration(days: 3)),
          ),
          WorkoutModel(
            id: '5',
            name: 'Pulliamo Tutto',
            startTime: now.subtract(const Duration(days: 2)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(days: 2)),
            updatedAt: now.subtract(const Duration(days: 2)),
          ),
          WorkoutModel(
            id: '6',
            name: 'Legghiamo Power',
            startTime: now.subtract(const Duration(days: 1)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(days: 1)),
            updatedAt: now.subtract(const Duration(days: 1)),
          ),
        ];

        when(() => mockDataSource.getWorkouts(
          'user123',
          startDate: any(named: 'startDate'),
          limit: 100,
        )).thenAnswer((_) async => workouts);

        final sequences = await service.extractSequences(
          userId: 'user123',
          lookbackDays: 21,
        );

        // Should detect the pattern as PUSH → PULL → LEGS
        expect(sequences, equals(['PUSH', 'PULL', 'LEGS', 'PUSH', 'PULL', 'LEGS']));

        // Verify pattern detection works
        final detector = SimplePatternDetector();
        final pattern = detector.detectRepeatingPattern(sequences);

        expect(pattern, isNotNull);
        expect(pattern!.pattern, equals(['PUSH', 'PULL', 'LEGS']));
        expect(pattern.confidence, equals(1.0)); // Perfect match
      });

      test('should extract and normalize workout sequences', () async {
        final now = DateTime.now();
        final workouts = [
          WorkoutModel(
            id: '1',
            name: 'Push Day',
            startTime: now.subtract(const Duration(days: 6)),
            endTime: now.subtract(const Duration(days: 6, hours: -1)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(days: 6)),
            updatedAt: now.subtract(const Duration(days: 6)),
          ),
          WorkoutModel(
            id: '2',
            name: 'Pull Day',
            startTime: now.subtract(const Duration(days: 5)),
            endTime: now.subtract(const Duration(days: 5, hours: -1)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(days: 5)),
            updatedAt: now.subtract(const Duration(days: 5)),
          ),
          WorkoutModel(
            id: '3',
            name: 'Leg Day',
            startTime: now.subtract(const Duration(days: 4)),
            endTime: now.subtract(const Duration(days: 4, hours: -1)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(days: 4)),
            updatedAt: now.subtract(const Duration(days: 4)),
          ),
          WorkoutModel(
            id: '4',
            name: 'Push Day',
            startTime: now.subtract(const Duration(days: 3)),
            endTime: now.subtract(const Duration(days: 3, hours: -1)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(days: 3)),
            updatedAt: now.subtract(const Duration(days: 3)),
          ),
          WorkoutModel(
            id: '5',
            name: 'Pull Day',
            startTime: now.subtract(const Duration(days: 2)),
            endTime: now.subtract(const Duration(days: 2, hours: -1)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(days: 2)),
            updatedAt: now.subtract(const Duration(days: 2)),
          ),
          WorkoutModel(
            id: '6',
            name: 'Leg Day',
            startTime: now.subtract(const Duration(days: 1)),
            endTime: now.subtract(const Duration(days: 1, hours: -1)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(days: 1)),
            updatedAt: now.subtract(const Duration(days: 1)),
          ),
        ];

        when(() => mockDataSource.getWorkouts(
          'user123',
          startDate: any(named: 'startDate'),
          limit: 100,
        )).thenAnswer((_) async => workouts);

        final sequences = await service.extractSequences(
          userId: 'user123',
          lookbackDays: 21,
        );

        expect(sequences, equals(['PUSH', 'PULL', 'LEGS', 'PUSH', 'PULL', 'LEGS']));
      });

      test('should return empty list when no workouts found', () async {
        when(() => mockDataSource.getWorkouts(
          'user123',
          startDate: any(named: 'startDate'),
          limit: 100,
        )).thenAnswer((_) async => []);

        final sequences = await service.extractSequences(
          userId: 'user123',
          lookbackDays: 21,
        );

        expect(sequences, isEmpty);
      });

      test('should filter out empty workout names', () async {
        final now = DateTime.now();
        final workouts = [
          WorkoutModel(
            id: '1',
            name: 'Push Day',
            startTime: now.subtract(const Duration(days: 2)),
            endTime: now.subtract(const Duration(days: 2, hours: -1)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(days: 2)),
            updatedAt: now.subtract(const Duration(days: 2)),
          ),
          WorkoutModel(
            id: '2',
            name: '', // Empty name should be filtered
            startTime: now.subtract(const Duration(days: 1)),
            endTime: now.subtract(const Duration(days: 1, hours: -1)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(days: 1)),
            updatedAt: now.subtract(const Duration(days: 1)),
          ),
        ];

        when(() => mockDataSource.getWorkouts(
          'user123',
          startDate: any(named: 'startDate'),
          limit: 100,
        )).thenAnswer((_) async => workouts);

        final sequences = await service.extractSequences(
          userId: 'user123',
          lookbackDays: 21,
        );

        expect(sequences, equals(['PUSH']));
      });
    });
  });

  group('SimplePatternDetector', () {
    late SimplePatternDetector detector;

    setUp(() {
      detector = SimplePatternDetector();
    });

    group('detectRepeatingPattern', () {
      test('should detect simple PPL pattern with high confidence', () {
        final sequence = ['PUSH', 'PULL', 'LEGS', 'PUSH', 'PULL', 'LEGS', 'PUSH', 'PULL', 'LEGS'];

        final result = detector.detectRepeatingPattern(sequence);

        expect(result, isNotNull);
        expect(result!.pattern, equals(['PUSH', 'PULL', 'LEGS']));
        expect(result.confidence, greaterThanOrEqualTo(0.95));
        expect(result.occurrences, equals(3));
      });

      test('should detect Upper/Lower pattern', () {
        final sequence = ['UPPER', 'LOWER', 'UPPER', 'LOWER', 'UPPER', 'LOWER'];

        final result = detector.detectRepeatingPattern(sequence);

        expect(result, isNotNull);
        expect(result!.pattern, equals(['UPPER', 'LOWER']));
        expect(result.confidence, equals(1.0));
        expect(result.occurrences, equals(3));
      });

      test('should detect pattern with minor variations', () {
        final sequence = ['PUSH', 'PULL', 'LEGS', 'PUSH', 'PULL', 'LEGS', 'PUSH', 'FULL_BODY', 'LEGS'];

        final result = detector.detectRepeatingPattern(sequence);

        expect(result, isNotNull);
        expect(result!.pattern, equals(['PUSH', 'PULL', 'LEGS']));
        expect(result.confidence, greaterThanOrEqualTo(0.75));
        expect(result.confidence, lessThan(1.0)); // Not perfect due to variation
      });

      test('should return null for sequences too short', () {
        final sequence = ['PUSH', 'PULL', 'LEGS'];

        final result = detector.detectRepeatingPattern(sequence);

        expect(result, isNull);
      });

      test('should return null for empty sequences', () {
        final result = detector.detectRepeatingPattern([]);

        expect(result, isNull);
      });

      test('should return null for random sequences without pattern', () {
        final sequence = ['PUSH', 'LEGS', 'PULL', 'UPPER', 'LOWER', 'FULL_BODY', 'CHEST'];

        final result = detector.detectRepeatingPattern(sequence);

        expect(result, isNull);
      });

      test('should detect longer patterns (4-day split)', () {
        final sequence = [
          'PUSH', 'PULL', 'LEGS', 'UPPER',
          'PUSH', 'PULL', 'LEGS', 'UPPER',
          'PUSH', 'PULL', 'LEGS', 'UPPER',
        ];

        final result = detector.detectRepeatingPattern(sequence);

        expect(result, isNotNull);
        expect(result!.pattern, equals(['PUSH', 'PULL', 'LEGS', 'UPPER']));
        expect(result.confidence, equals(1.0));
        expect(result.occurrences, equals(3));
      });

      test('should prefer shorter patterns when both are valid', () {
        final sequence = ['A', 'B', 'A', 'B', 'A', 'B', 'A', 'B'];

        final result = detector.detectRepeatingPattern(sequence);

        expect(result, isNotNull);
        expect(result!.pattern, equals(['A', 'B']));
        expect(result.confidence, equals(1.0));
      });
    });

    group('detectPatternWithRest', () {
      test('should detect pattern including rest days', () {
        final workoutSequence = ['PUSH', 'PULL', 'LEGS', 'PUSH', 'PULL', 'LEGS'];
        final workoutDates = [
          DateTime.now().subtract(const Duration(days: 13)),
          DateTime.now().subtract(const Duration(days: 12)),
          DateTime.now().subtract(const Duration(days: 10)), // 2 days rest
          DateTime.now().subtract(const Duration(days: 9)),
          DateTime.now().subtract(const Duration(days: 8)),
          DateTime.now().subtract(const Duration(days: 6)), // 2 days rest
        ];

        final result = detector.detectPatternWithRest(workoutSequence, workoutDates);

        expect(result, isNotNull);
        // Should detect pattern with rest days included
        expect(result!.pattern.contains('REST'), isTrue);
      });

      test('should limit rest days to max 3', () {
        final workoutSequence = ['PUSH', 'PULL'];
        final workoutDates = [
          DateTime.now().subtract(const Duration(days: 10)),
          DateTime.now().subtract(const Duration(days: 1)), // 9 days gap
        ];

        final result = detector.detectPatternWithRest(workoutSequence, workoutDates);

        // Even with 9 days gap, should only add max 3 REST days
        final restCount = result?.pattern.where((p) => p == 'REST').length ?? 0;
        expect(restCount, lessThanOrEqualTo(3));
      });

      test('should return null for mismatched sequences and dates', () {
        final workoutSequence = ['PUSH', 'PULL', 'LEGS'];
        final workoutDates = [
          DateTime.now().subtract(const Duration(days: 2)),
          DateTime.now().subtract(const Duration(days: 1)),
          // Missing third date
        ];

        final result = detector.detectPatternWithRest(workoutSequence, workoutDates);

        expect(result, isNull);
      });
    });
  });
}