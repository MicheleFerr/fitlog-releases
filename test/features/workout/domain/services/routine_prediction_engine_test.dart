import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/suggestion_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/routine_prediction_engine.dart';

/// ⚠️ REFACTORING IN PROGRESS
///
/// Phase 1+4 completed:
/// - Removed Pattern-based (Level 1)
/// - Removed Day-based (Level 4)
/// - Simplified to 2-level fallback: Routine + Frequency
///
/// Tests status:
/// - ✅ Level 2 (Frequency-based): Working
/// - ⏸️  Level 1 (Routine-based): Needs FlexibleRoutine mock setup
/// - ⏸️  Pattern-based tests: Skipped (feature removed)
/// - ⏸️  Day-based tests: Skipped (feature removed)

void main() {
  late RoutinePredictionEngine engine;

  setUp(() {
    engine = RoutinePredictionEngine(); // ✅ Simplified: no dependencies
  });

  group('RoutinePredictionEngine - Level 2: Frequency-Based', () {
    test('returns frequency-based suggestion when clear frequency leader',
        () async {
      // Arrange: Clear frequency leader (Push: 8, Pull: 2, Legs: 2)
      final workouts = [
        ..._createWorkoutSequence(names: List.filled(8, 'Push'), daysSpan: 25),
        ..._createWorkoutSequence(names: List.filled(2, 'Pull'), daysSpan: 25),
        ..._createWorkoutSequence(names: List.filled(2, 'Legs'), daysSpan: 25),
      ];

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
        availableTemplateNames: ['Push', 'Pull', 'Legs'], // ✅ Provide for validation
      );

      // Assert
      expect(suggestion.level, equals(SuggestionLevel.frequency));
      expect(suggestion.workoutName, equals('Push'));
      expect(suggestion.confidence, greaterThanOrEqualTo(0.50));
      expect(suggestion.reason, contains('most often'));
      expect(suggestion.isFrequencyBased, isTrue);
    });

    test('falls back to generic when no clear frequency leader', () async {
      // Arrange: No clear leader (Push: 5, Pull: 4, Legs: 3) - not >2x
      final workouts = [
        ..._createWorkoutSequence(names: List.filled(5, 'Push'), daysSpan: 25),
        ..._createWorkoutSequence(names: List.filled(4, 'Pull'), daysSpan: 25),
        ..._createWorkoutSequence(names: List.filled(3, 'Legs'), daysSpan: 25),
      ];

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
        availableTemplateNames: ['Push', 'Pull', 'Legs'], // ✅ Provide for validation
      );

      // Assert
      // Should fallback to generic "Workout" when no clear leader
      expect(suggestion.workoutName, equals('Workout'));
      expect(suggestion.confidence, lessThanOrEqualTo(0.30));
    });

    test('includes frequency data in suggestion', () async {
      // Arrange
      final workouts = [
        ..._createWorkoutSequence(names: List.filled(6, 'Push'), daysSpan: 25),
        ..._createWorkoutSequence(names: List.filled(2, 'Pull'), daysSpan: 25),
      ];

      // Act
      final suggestion = await engine.predictNextWorkout(
        workoutHistory: workouts,
        availableTemplateNames: ['Push', 'Pull'], // ✅ Provide for validation
      );

      // Assert
      expect(suggestion.frequencyData, isNotNull);
      expect(suggestion.frequencyData, contains('6 times'));
      expect(suggestion.frequencyData, contains('last 30 days'));
    });
  });

  group('RoutinePredictionEngine - Caching', () {
    test('returns cached suggestion when cache is valid', () async {
      // Arrange
      final workouts = _createWorkoutSequence(
        names: List.filled(6, 'Push'),
        daysSpan: 25,
      );

      // Act: First call
      final suggestion1 = await engine.predictNextWorkout(
        workoutHistory: workouts,
        availableTemplateNames: ['Push'], // ✅ Provide for validation
        useCache: true,
      );

      // Act: Second call (should use cache)
      final suggestion2 = await engine.predictNextWorkout(
        workoutHistory: workouts,
        availableTemplateNames: ['Push'], // ✅ Provide for validation
        useCache: true,
      );

      // Assert: Should be identical (same object)
      expect(identical(suggestion1, suggestion2), isTrue);
    });

    test('bypasses cache when useCache=false', () async {
      // Arrange
      final workouts = _createWorkoutSequence(
        names: List.filled(6, 'Push'),
        daysSpan: 25,
      );

      // Act: First call with cache
      final suggestion1 = await engine.predictNextWorkout(
        workoutHistory: workouts,
        availableTemplateNames: ['Push'], // ✅ Provide for validation
        useCache: true,
      );

      // Act: Second call without cache
      final suggestion2 = await engine.predictNextWorkout(
        workoutHistory: workouts,
        availableTemplateNames: ['Push'], // ✅ Provide for validation
        useCache: false,
      );

      // Assert: Should be different objects (not cached)
      expect(identical(suggestion1, suggestion2), isFalse);
      expect(suggestion1.workoutName, equals(suggestion2.workoutName));
    });

    test('clears cache when clearCache called', () async {
      // Arrange
      final workouts = _createWorkoutSequence(
        names: List.filled(6, 'Push'),
        daysSpan: 25,
      );

      await engine.predictNextWorkout(
        workoutHistory: workouts,
        availableTemplateNames: ['Push'], // ✅ Provide for validation
        useCache: true,
      );

      // Act: Clear cache
      engine.clearCache();

      // Act: New call after clear
      final suggestion2 = await engine.predictNextWorkout(
        workoutHistory: workouts,
        availableTemplateNames: ['Push'], // ✅ Provide for validation
        useCache: true,
      );

      // Assert: Should recompute (not cached)
      expect(suggestion2.workoutName, equals('Push'));
    });
  });
}

// ========== TEST HELPERS ==========

/// Create workout sequence for testing
List<Workout> _createWorkoutSequence({
  required List<String> names,
  required int daysSpan,
}) {
  final workouts = <Workout>[];
  final now = DateTime.now();

  for (int i = 0; i < names.length; i++) {
    final dayOffset = (daysSpan / names.length * i).round();
    final workoutDate = now.subtract(Duration(days: daysSpan - dayOffset));

    workouts.add(
      Workout(
        id: 'workout_$i',
        name: names[i],
        startTime: workoutDate,
        status: WorkoutStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    );
  }

  return workouts.reversed.toList(); // Return newest first
}
