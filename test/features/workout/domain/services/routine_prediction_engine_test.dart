import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/suggestion_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/pattern_detection_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/pattern_viability_checker.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/routine_prediction_engine.dart';

void main() {
  late RoutinePredictionEngine engine;
  late PatternDetectionService patternService;
  late PatternViabilityChecker viabilityChecker;

  setUp(() {
    patternService = PatternDetectionService();
    viabilityChecker = PatternViabilityChecker();
    engine = RoutinePredictionEngine(
      patternService: patternService,
      viabilityChecker: viabilityChecker,
    );
  });

  group('RoutinePredictionEngine - Level 1: Pattern-Based', () {
    test('returns pattern-based suggestion when viable pattern detected',
        () async {
      // Arrange: Perfect pattern (Push-Pull-Legs, 4 cycles)
      final workouts = _createWorkoutSequence(
        names: List.generate(12, (i) => ['Push', 'Pull', 'Legs'][i % 3]),
        daysSpan: 25,
      );

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
      );

      // Assert
      expect(suggestion.level, equals(SuggestionLevel.pattern));
      expect(suggestion.workoutName, equals('push')); // Next after 'legs'
      expect(suggestion.confidence, greaterThanOrEqualTo(0.70));
      expect(suggestion.reason, contains('Detected pattern'));
      expect(suggestion.reason, contains('push → pull → legs'));
      expect(suggestion.isPatternBased, isTrue);
      expect(suggestion.isHighConfidence, isTrue);
    });

    test('includes pattern info with last workout', () async {
      // Arrange
      final workouts = _createWorkoutSequence(
        names: List.generate(12, (i) => ['Push', 'Pull', 'Legs'][i % 3]),
        daysSpan: 25,
      );

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
      );

      // Assert
      expect(suggestion.patternInfo, isNotNull);
      expect(suggestion.patternInfo, contains('You completed'));
      expect(suggestion.patternInfo, contains('Legs')); // Last workout
    });

    test('falls back when pattern is not viable', () async {
      // Arrange: Insufficient data (only 5 workouts)
      final workouts = _createWorkoutSequence(
        names: ['Push', 'Pull', 'Legs', 'Push', 'Pull'],
        daysSpan: 10,
      );

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
      );

      // Assert
      expect(suggestion.level, isNot(SuggestionLevel.pattern));
      // Should fallback to Level 3 (Frequency) or Level 4 (DayBased)
    });

    test('works with arbitrary workout names (franco-ciccio-paolo)', () async {
      // Arrange
      final workouts = _createWorkoutSequence(
        names:
            List.generate(12, (i) => ['franco', 'ciccio', 'paolo'][i % 3]),
        daysSpan: 25,
      );

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
      );

      // Assert
      expect(suggestion.level, equals(SuggestionLevel.pattern));
      expect(suggestion.workoutName, isIn(['franco', 'ciccio', 'paolo']));
      expect(suggestion.reason, contains('franco → ciccio → paolo'));
    });
  });

  group('RoutinePredictionEngine - Level 2: Routine-Based', () {
    test('returns null when routine-based not implemented', () async {
      // Arrange: No pattern, but routine ID provided
      final workouts = _createWorkoutSequence(
        names: ['A', 'B', 'C', 'D', 'E'], // Random, no pattern
        daysSpan: 10,
      );

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
        activeRoutineTemplateId: 'routine_123',
      );

      // Assert: Should skip routine-based (not implemented) and go to Level 3/4
      expect(suggestion.level, isNot(SuggestionLevel.routine));
    });
  });

  group('RoutinePredictionEngine - Level 3: Frequency-Based', () {
    test('returns frequency-based suggestion when clear frequency leader',
        () async {
      // Arrange: 'Push' done 6 times, others 2 times each (clear leader)
      final workouts = _createWorkoutSequence(
        names: [
          'Push',
          'Push',
          'Push',
          'Push',
          'Push',
          'Push', // 6x
          'Pull',
          'Pull', // 2x
          'Legs',
          'Legs' // 2x
        ],
        daysSpan: 25,
      );

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
        useCache: false,
      );

      // Assert
      expect(suggestion.level, equals(SuggestionLevel.frequency));
      expect(suggestion.workoutName, equals('push'));
      expect(suggestion.confidence, greaterThanOrEqualTo(0.50));
      expect(suggestion.confidence, lessThanOrEqualTo(0.70));
      expect(suggestion.reason, contains('most often'));
      expect(suggestion.frequencyData, isNotNull);
      expect(suggestion.frequencyData, contains('6 times'));
    });

    test('returns null when no clear frequency leader', () async {
      // Arrange: All workouts have similar frequency (3 each)
      final workouts = _createWorkoutSequence(
        names: [
          'Push',
          'Pull',
          'Legs',
          'Push',
          'Pull',
          'Legs',
          'Push',
          'Pull',
          'Legs'
        ],
        daysSpan: 20,
      );

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
        useCache: false,
      );

      // Assert: Should fallback to Level 4 (DayBased)
      expect(suggestion.level, equals(SuggestionLevel.dayBased));
    });

    test('requires minimum 3 workouts in last 30 days', () async {
      // Arrange: Only 2 workouts in last 30 days
      final workouts = _createWorkoutSequence(
        names: ['Push', 'Pull'],
        daysSpan: 25,
      );

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
        useCache: false,
      );

      // Assert: Should fallback to Level 4 (DayBased)
      expect(suggestion.level, equals(SuggestionLevel.dayBased));
    });

    test('confidence increases with higher frequency ratio', () async {
      // Arrange: Test with different frequency ratios
      final highFreq = _createWorkoutSequence(
        names: [
          'Push',
          'Push',
          'Push',
          'Push',
          'Push',
          'Push',
          'Push',
          'Push', // 8x
          'Pull',
          'Legs' // 1x each
        ],
        daysSpan: 25,
      );

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: highFreq,
        useCache: false,
      );

      // Assert: Higher frequency ratio → higher confidence
      expect(suggestion.confidence, greaterThanOrEqualTo(0.60));
    });
  });

  group('RoutinePredictionEngine - Level 4: Day-Based (Fallback)', () {
    test('always returns a suggestion (never fails)', () async {
      // Arrange: Empty workout history
      final workouts = <Workout>[];

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
      );

      // Assert
      expect(suggestion, isNotNull);
      expect(suggestion.level, equals(SuggestionLevel.dayBased));
      expect(suggestion.isDayBased, isTrue);
    });

    test('uses historical data for current weekday', () async {
      // Arrange: Create workouts on specific weekdays
      final today = DateTime.now().weekday;
      final workouts = <Workout>[];

      // Add 5 'Push' workouts on today's weekday
      for (int i = 0; i < 5; i++) {
        final date = DateTime.now().subtract(Duration(days: i * 7));
        if (date.weekday == today) {
          workouts.add(
            Workout(
              id: 'workout_$i',
              name: 'Push',
              startTime: date,
              status: WorkoutStatus.completed,
            ),
          );
        }
      }

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
        useCache: false,
      );

      // Assert
      expect(suggestion.level, equals(SuggestionLevel.dayBased));
      expect(suggestion.workoutName, equals('push'));
      expect(suggestion.reason, contains('usually do'));
    });

    test('has lower confidence than other levels', () async {
      // Arrange
      final workouts = _createWorkoutSequence(
        names: ['Push', 'Pull'],
        daysSpan: 10,
      );

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
        useCache: false,
      );

      // Assert: DayBased confidence should be 0.30-0.50
      expect(suggestion.confidence, greaterThanOrEqualTo(0.30));
      expect(suggestion.confidence, lessThanOrEqualTo(0.50));
    });
  });

  group('RoutinePredictionEngine - Caching', () {
    test('caches suggestion for 5 minutes', () async {
      // Arrange
      final workouts = _createWorkoutSequence(
        names: List.generate(12, (i) => ['Push', 'Pull', 'Legs'][i % 3]),
        daysSpan: 25,
      );

      // Act: First call (no cache)
      final suggestion1 = await engine.predictNextWorkout(
        workoutHistory: workouts,
      );

      // Act: Second call (should use cache)
      final suggestion2 = await engine.predictNextWorkout(
        workoutHistory: workouts,
      );

      // Assert: Same instance (cached)
      expect(identical(suggestion1, suggestion2), isTrue);
    });

    test('can bypass cache with useCache: false', () async {
      // Arrange
      final workouts = _createWorkoutSequence(
        names: List.generate(12, (i) => ['Push', 'Pull', 'Legs'][i % 3]),
        daysSpan: 25,
      );

      // Act: First call
      final suggestion1 = await engine.predictNextWorkout(
        workoutHistory: workouts,
      );

      // Act: Second call with cache bypass
      final suggestion2 = await engine.predictNextWorkout(
        workoutHistory: workouts,
        useCache: false,
      );

      // Assert: Different instances (not cached)
      expect(identical(suggestion1, suggestion2), isFalse);
    });

    test('clearCache() invalidates cached suggestion', () async {
      // Arrange
      final workouts = _createWorkoutSequence(
        names: List.generate(12, (i) => ['Push', 'Pull', 'Legs'][i % 3]),
        daysSpan: 25,
      );

      // Act: First call (creates cache)
      await engine.predictNextWorkout(workoutHistory: workouts);

      // Clear cache
      engine.clearCache();

      // Act: Second call (should recalculate)
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
      );

      // Assert: Suggestion is fresh (has recent timestamp)
      expect(suggestion.generatedAt, isNotNull);
      final age = DateTime.now().difference(suggestion.generatedAt!);
      expect(age.inSeconds, lessThan(5)); // Very recent
    });
  });

  group('RoutinePredictionEngine - Performance', () {
    test('completes prediction in <50ms for 50 workouts', () async {
      // Arrange: 50 workouts
      final workouts = _createWorkoutSequence(
        names: List.generate(
          50,
          (i) => ['Push', 'Pull', 'Legs', 'Upper', 'Lower'][i % 5],
        ),
        daysSpan: 60,
      );

      // Act: Measure time
      final stopwatch = Stopwatch()..start();
      await engine.predictNextWorkout(workoutHistory: workouts);
      stopwatch.stop();

      // Assert
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(50),
        reason: 'Prediction should complete in <50ms',
      );
    });
  });

  group('RoutinePredictionEngine - Edge Cases', () {
    test('handles empty workout history gracefully', () async {
      // Arrange
      final workouts = <Workout>[];

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
      );

      // Assert: Should fallback to Level 4 (DayBased)
      expect(suggestion.level, equals(SuggestionLevel.dayBased));
      expect(suggestion.workoutName, isNotEmpty);
    });

    test('handles workouts with empty names', () async {
      // Arrange: Workouts with empty names
      final workouts = List.generate(
        10,
        (i) => Workout(
          id: 'workout_$i',
          name: '', // Empty name
          startTime: DateTime.now().subtract(Duration(days: 10 - i)),
          status: WorkoutStatus.completed,
        ),
      );

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
      );

      // Assert: Should handle gracefully
      expect(suggestion, isNotNull);
      expect(suggestion.workoutName, isNotEmpty);
    });

    test('handles workouts without timestamps', () async {
      // Arrange: Workouts with null startTime
      final workouts = List.generate(
        10,
        (i) => Workout(
          id: 'workout_$i',
          name: 'Push',
          startTime: null, // No timestamp
          status: WorkoutStatus.completed,
        ),
      );

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
      );

      // Assert: Should handle gracefully
      expect(suggestion, isNotNull);
    });
  });
}

/// Helper function to create workout sequence from name list
List<Workout> _createWorkoutSequence({
  required List<String> names,
  required int daysSpan,
}) {
  final now = DateTime.now();
  final workouts = <Workout>[];

  for (int i = 0; i < names.length; i++) {
    // Distribute workouts evenly across daysSpan
    final daysAgo = names.length == 1
        ? 0
        : (daysSpan * (names.length - 1 - i) / (names.length - 1)).round();

    workouts.add(
      Workout(
        id: 'workout_$i',
        name: names[i],
        startTime: now.subtract(Duration(days: daysAgo)),
        status: WorkoutStatus.completed,
      ),
    );
  }

  return workouts;
}
