import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/scientific_metrics_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';

void main() {
  group('calculateProgressiveOverload', () {
    test('should calculate positive overload correctly', () {
      // 🐛 BUG PREVENTED: Incorrect overload calculation leading to poor training decisions
      final previous = [
        _createActivity('exercise-1', 'Bench Press', [
          _createSet(weight: 100, reps: 10),
          _createSet(weight: 100, reps: 10),
          _createSet(weight: 100, reps: 10),
        ]),
      ];

      final current = [
        _createActivity('exercise-1', 'Bench Press', [
          _createSet(weight: 105, reps: 10),
          _createSet(weight: 105, reps: 10),
          _createSet(weight: 105, reps: 10),
        ]),
      ];

      final result = ScientificMetricsService.calculateProgressiveOverload(
        currentSession: current,
        previousSession: previous,
        exerciseId: 'exercise-1',
      );

      expect(result.hasData, true);
      expect(result.previousVolume, 3000.0); // 3 sets × 10 reps × 100kg
      expect(result.currentVolume, 3150.0); // 3 sets × 10 reps × 105kg
      expect(result.overloadPercent, closeTo(5.0, 0.1)); // 5% increase
      expect(result.isProgressing, true);
      expect(result.isOptimal, true); // 5% is optimal
    });

    test('should calculate negative overload (regression)', () {
      // 🐛 BUG PREVENTED: Regression not detected
      final previous = [
        _createActivity('exercise-1', 'Squat', [
          _createSet(weight: 150, reps: 8),
          _createSet(weight: 150, reps: 8),
        ]),
      ];

      final current = [
        _createActivity('exercise-1', 'Squat', [
          _createSet(weight: 140, reps: 8),
          _createSet(weight: 140, reps: 8),
        ]),
      ];

      final result = ScientificMetricsService.calculateProgressiveOverload(
        currentSession: current,
        previousSession: previous,
        exerciseId: 'exercise-1',
      );

      expect(result.overloadPercent, lessThan(0));
      expect(result.isRegressing, true);
      expect(result.isProgressing, false);
    });

    test('should return noData when current session is empty', () {
      // 🐛 BUG PREVENTED: Division by zero or null errors
      final previous = [
        _createActivity('exercise-1', 'Deadlift', [
          _createSet(weight: 200, reps: 5),
        ]),
      ];

      final result = ScientificMetricsService.calculateProgressiveOverload(
        currentSession: [],
        previousSession: previous,
        exerciseId: 'exercise-1',
      );

      expect(result.hasData, false);
    });

    test('should return noData when previous session is empty', () {
      // 🐛 BUG PREVENTED: Cannot calculate overload without baseline
      final current = [
        _createActivity('exercise-1', 'Press', [
          _createSet(weight: 60, reps: 10),
        ]),
      ];

      final result = ScientificMetricsService.calculateProgressiveOverload(
        currentSession: current,
        previousSession: [],
        exerciseId: 'exercise-1',
      );

      expect(result.hasData, false);
    });

    test('should handle zero progression correctly', () {
      // 🐛 BUG PREVENTED: Same volume not properly identified
      final session = [
        _createActivity('exercise-1', 'Row', [
          _createSet(weight: 80, reps: 10),
          _createSet(weight: 80, reps: 10),
        ]),
      ];

      final result = ScientificMetricsService.calculateProgressiveOverload(
        currentSession: session,
        previousSession: session,
        exerciseId: 'exercise-1',
      );

      expect(result.overloadPercent, 0);
      expect(result.isProgressing, false);
      expect(result.isRegressing, false);
    });

    test('should filter activities by exerciseId correctly', () {
      // 🐛 BUG PREVENTED: Mixing different exercises in calculation
      final previous = [
        _createActivity('exercise-1', 'Bench Press', [
          _createSet(weight: 100, reps: 10),
        ]),
        _createActivity('exercise-2', 'Squat', [
          _createSet(weight: 150, reps: 10),
        ]),
      ];

      final current = [
        _createActivity('exercise-1', 'Bench Press', [
          _createSet(weight: 105, reps: 10),
        ]),
        _createActivity('exercise-2', 'Squat', [
          _createSet(weight: 160, reps: 10),
        ]),
      ];

      final result = ScientificMetricsService.calculateProgressiveOverload(
        currentSession: current,
        previousSession: previous,
        exerciseId: 'exercise-1',
      );

      expect(result.previousVolume, 1000.0); // Only bench press
      expect(result.currentVolume, 1050.0);
    });

    test('should calculate isOptimal correctly (0-5% range)', () {
      // 🐛 BUG PREVENTED: Incorrect optimal range detection
      final previous = [
        _createActivity('ex-1', 'Press', [_createSet(weight: 100, reps: 10)]),
      ];

      // Test at 3% increase (optimal)
      final current3 = [
        _createActivity('ex-1', 'Press', [_createSet(weight: 103, reps: 10)]),
      ];
      final result3 = ScientificMetricsService.calculateProgressiveOverload(
        currentSession: current3,
        previousSession: previous,
        exerciseId: 'ex-1',
      );
      expect(result3.isOptimal, true);

      // Test at 6% increase (not optimal - too high)
      final current6 = [
        _createActivity('ex-1', 'Press', [_createSet(weight: 106, reps: 10)]),
      ];
      final result6 = ScientificMetricsService.calculateProgressiveOverload(
        currentSession: current6,
        previousSession: previous,
        exerciseId: 'ex-1',
      );
      expect(result6.isOptimal, false);
    });

    test('should handle multiple activities for same exercise', () {
      // 🐛 BUG PREVENTED: Not summing all volume for repeated exercises
      final previous = [
        _createActivity('ex-1', 'Curl', [_createSet(weight: 20, reps: 12)]),
        _createActivity('ex-1', 'Curl', [_createSet(weight: 20, reps: 12)]),
      ];

      final current = [
        _createActivity('ex-1', 'Curl', [_createSet(weight: 22, reps: 12)]),
        _createActivity('ex-1', 'Curl', [_createSet(weight: 22, reps: 12)]),
      ];

      final result = ScientificMetricsService.calculateProgressiveOverload(
        currentSession: current,
        previousSession: previous,
        exerciseId: 'ex-1',
      );

      expect(result.previousVolume, 480.0); // 2 activities × 12 × 20
      expect(result.currentVolume, 528.0); // 2 activities × 12 × 22
      expect(result.overloadPercent, closeTo(10.0, 0.1));
    });
  });

  group('calculateVolumeLoadIndex', () {
    test('should calculate volume per muscle group correctly', () {
      // 🐛 BUG PREVENTED: Incorrect volume tracking per muscle
      final activities = [
        _createActivity('ex-1', 'Bench Press', [
          _createSet(weight: 100, reps: 10),
          _createSet(weight: 100, reps: 10),
        ]),
        _createActivity('ex-2', 'Squat', [
          _createSet(weight: 150, reps: 8),
        ]),
      ];

      final results = ScientificMetricsService.calculateVolumeLoadIndex(activities);

      expect(results['Chest']?.totalVolume, 2000.0); // 2 sets × 10 × 100
      expect(results['Chest']?.totalSets, 2);
      expect(results['Legs']?.totalVolume, 1200.0); // 1 set × 8 × 150
      expect(results['Legs']?.totalSets, 1);
    });

    test('should skip warmup sets from count', () {
      // 🐛 BUG PREVENTED: Warmup sets inflating volume metrics
      final activities = [
        _createActivity('ex-1', 'Press', [
          _createSet(weight: 40, reps: 10, isWarmup: true),
          _createSet(weight: 60, reps: 8),
          _createSet(weight: 60, reps: 8),
        ]),
      ];

      final results = ScientificMetricsService.calculateVolumeLoadIndex(activities);

      // Should only count 2 working sets (warmup skipped)
      expect(results['Shoulders']?.totalSets, 2);
    });

    test('should skip incomplete sets from count', () {
      // 🐛 BUG PREVENTED: Incomplete sets counted in volume
      final activities = [
        _createActivity('ex-1', 'Row', [
          _createSet(weight: 80, reps: 10, done: false),
          _createSet(weight: 80, reps: 10, done: true),
          _createSet(weight: 80, reps: 10, done: true),
        ]),
      ];

      final results = ScientificMetricsService.calculateVolumeLoadIndex(activities);

      // Should only count 2 completed sets
      expect(results['Back']?.totalSets, 2);
    });

    test('should handle empty activities list', () {
      // 🐛 BUG PREVENTED: Crash on empty data
      final results = ScientificMetricsService.calculateVolumeLoadIndex([]);

      expect(results, isEmpty);
    });

    test('should categorize exercises correctly', () {
      // 🐛 BUG PREVENTED: Exercise misclassification
      final activities = [
        _createActivity('ex-1', 'Bench Press', [_createSet(weight: 100, reps: 10)]),
        _createActivity('ex-2', 'Pull Up', [_createSet(weight: 0, reps: 10)]),
        _createActivity('ex-3', 'Lateral Raise', [_createSet(weight: 15, reps: 12)]),
        _createActivity('ex-4', 'Bicep Curl', [_createSet(weight: 20, reps: 12)]),
        _createActivity('ex-5', 'Squat', [_createSet(weight: 150, reps: 8)]),
        _createActivity('ex-6', 'Plank', [_createSet(weight: 0, reps: 60)]),
      ];

      final results = ScientificMetricsService.calculateVolumeLoadIndex(activities);

      expect(results.containsKey('Chest'), true);
      expect(results.containsKey('Back'), true);
      expect(results.containsKey('Shoulders'), true);
      expect(results.containsKey('Arms'), true);
      expect(results.containsKey('Legs'), true);
      expect(results.containsKey('Core'), true);
    });

    test('should combine volume for same muscle group', () {
      // 🐛 BUG PREVENTED: Multiple exercises for same muscle not summed
      final activities = [
        _createActivity('ex-1', 'Bench Press', [_createSet(weight: 100, reps: 10)]),
        _createActivity('ex-2', 'Chest Fly', [_createSet(weight: 30, reps: 12)]),
        _createActivity('ex-3', 'Incline Press', [_createSet(weight: 80, reps: 10)]),
      ];

      final results = ScientificMetricsService.calculateVolumeLoadIndex(activities);

      // All chest exercises combined
      expect(results['Chest']?.totalVolume, 2160.0); // 1000 + 360 + 800
      expect(results['Chest']?.totalSets, 3);
    });

    test('should set volumeLoad equal to totalVolume', () {
      // 🐛 BUG PREVENTED: Mismatch between volumeLoad and totalVolume
      final activities = [
        _createActivity('ex-1', 'Press', [_createSet(weight: 60, reps: 10)]),
      ];

      final results = ScientificMetricsService.calculateVolumeLoadIndex(activities);

      expect(results['Shoulders']?.volumeLoad, results['Shoulders']?.totalVolume);
    });
  });

  group('calculateRelativeIntensity', () {
    test('should return invalid for zero weight', () {
      // 🐛 BUG PREVENTED: Division by zero or invalid calculations
      final result = ScientificMetricsService.calculateRelativeIntensity(
        weight: 0,
        reps: 10,
      );

      expect(result.isValid, false);
    });

    test('should return invalid for zero reps', () {
      // 🐛 BUG PREVENTED: Invalid rep count
      final result = ScientificMetricsService.calculateRelativeIntensity(
        weight: 100,
        reps: 0,
      );

      expect(result.isValid, false);
    });

    test('should use Brzycki formula for low reps (<=5)', () {
      // 🐛 BUG PREVENTED: Wrong formula for rep range
      final result = ScientificMetricsService.calculateRelativeIntensity(
        weight: 140,
        reps: 3,
      );

      expect(result.formula, 'Brzycki');
      expect(result.reliability, 'High (±2-3%)');
      expect(result.estimated1RM, greaterThan(140));
    });

    test('should use Epley formula for mid reps (6-10)', () {
      // 🐛 BUG PREVENTED: Suboptimal formula for mid-range reps
      final result = ScientificMetricsService.calculateRelativeIntensity(
        weight: 100,
        reps: 8,
      );

      expect(result.formula, 'Epley');
      expect(result.reliability, 'High (±5%)');
      // Epley: 100 × (1 + 8/30) = 100 × 1.266... ≈ 126.67
      expect(result.estimated1RM, closeTo(126.67, 0.1));
    });

    test('should average Epley+Brzycki for high reps (11-15)', () {
      // 🐛 BUG PREVENTED: Less accurate single formula for high reps
      final result = ScientificMetricsService.calculateRelativeIntensity(
        weight: 80,
        reps: 12,
      );

      expect(result.formula, 'Epley+Brzycki');
      expect(result.reliability, 'Medium (±10-15%)');
      expect(result.estimated1RM, greaterThan(80));
    });

    test('should return endurance zone for very high reps (>15)', () {
      // 🐛 BUG PREVENTED: Attempting 1RM calculation for endurance work
      final result = ScientificMetricsService.calculateRelativeIntensity(
        weight: 40,
        reps: 20,
      );

      expect(result.formula, 'None');
      expect(result.reliability, 'Low');
      expect(result.estimated1RM, 0);
      expect(result.percentOf1RM, 0);
      expect(result.zone, IntensityZone.endurance);
    });

    test('should classify maxStrength zone correctly (>=85%)', () {
      // 🐛 BUG PREVENTED: Incorrect intensity zone classification
      final result = ScientificMetricsService.calculateRelativeIntensity(
        weight: 150,
        reps: 2,
      );

      expect(result.zone, IntensityZone.maxStrength);
      expect(result.percentOf1RM, greaterThanOrEqualTo(85));
    });

    test('should classify strengthHypertrophy zone (75-84%)', () {
      // 🐛 BUG PREVENTED: Mixing up strength and hypertrophy zones
      final result = ScientificMetricsService.calculateRelativeIntensity(
        weight: 100,
        reps: 6,
      );

      expect(result.zone, IntensityZone.strengthHypertrophy);
      expect(result.percentOf1RM, greaterThanOrEqualTo(75));
      expect(result.percentOf1RM, lessThan(85));
    });

    test('should classify hypertrophy zone (67-74%)', () {
      // 🐛 BUG PREVENTED: Suboptimal intensity for hypertrophy
      final result = ScientificMetricsService.calculateRelativeIntensity(
        weight: 80,
        reps: 10,
      );

      expect(result.zone, IntensityZone.hypertrophy);
      expect(result.percentOf1RM, greaterThanOrEqualTo(67));
      expect(result.percentOf1RM, lessThan(75));
    });

    test('should classify endurance zone (<67%)', () {
      // 🐛 BUG PREVENTED: High rep work not properly categorized
      final result = ScientificMetricsService.calculateRelativeIntensity(
        weight: 50,
        reps: 15,
      );

      expect(result.zone, IntensityZone.endurance);
      expect(result.percentOf1RM, lessThan(67));
    });
  });

  group('getOverloadFeedback', () {
    test('should provide feedback for regression', () {
      // 🐛 BUG PREVENTED: No warning for volume loss
      final feedback = ScientificMetricsService.getOverloadFeedback(-5.0);

      expect(feedback, contains('regression'));
      expect(feedback, contains('recovery'));
    });

    test('should provide feedback for no progression', () {
      // 🐛 BUG PREVENTED: Stagnation not identified
      final feedback = ScientificMetricsService.getOverloadFeedback(0);

      expect(feedback, contains('No progression'));
    });

    test('should provide optimal feedback for beginner', () {
      // 🐛 BUG PREVENTED: Wrong thresholds for training level
      final feedback = ScientificMetricsService.getOverloadFeedback(
        3.5,
        level: 'beginner',
      );

      expect(feedback, contains('Optimal'));
      expect(feedback, contains('Sustainable'));
    });

    test('should provide optimal feedback for intermediate', () {
      // 🐛 BUG PREVENTED: Intermediate progression rate not recognized
      final feedback = ScientificMetricsService.getOverloadFeedback(
        2.0,
        level: 'intermediate',
      );

      expect(feedback, contains('Optimal'));
    });

    test('should provide optimal feedback for advanced', () {
      // 🐛 BUG PREVENTED: Advanced lifter thresholds incorrect
      final feedback = ScientificMetricsService.getOverloadFeedback(
        1.0,
        level: 'advanced',
      );

      expect(feedback, contains('Optimal'));
    });

    test('should warn for excessive overload (>10%)', () {
      // 🐛 BUG PREVENTED: Overtraining risk not flagged
      final feedback = ScientificMetricsService.getOverloadFeedback(15.0);

      expect(feedback, contains('Excessive'));
      expect(feedback, contains('HIGH risk'));
    });
  });

  group('getVolumeLoadFeedback', () {
    test('should warn for below optimal volume', () {
      // 🐛 BUG PREVENTED: Insufficient training volume not detected
      final feedback = ScientificMetricsService.getVolumeLoadFeedback(
        weeklySetCount: 6,
        goal: 'hypertrophy',
        level: 'beginner',
      );

      expect(feedback, contains('Below optimal'));
      expect(feedback, contains('Target'));
    });

    test('should confirm optimal volume', () {
      // 🐛 BUG PREVENTED: Good volume not reinforced
      final feedback = ScientificMetricsService.getVolumeLoadFeedback(
        weeklySetCount: 15,
        goal: 'hypertrophy',
        level: 'intermediate',
      );

      expect(feedback, contains('Optimal'));
    });

    test('should warn for high volume', () {
      // 🐛 BUG PREVENTED: Overreaching not detected
      final feedback = ScientificMetricsService.getVolumeLoadFeedback(
        weeklySetCount: 22,
        goal: 'hypertrophy',
        level: 'intermediate',
      );

      expect(feedback, contains('High volume'));
      expect(feedback, contains('Monitor recovery'));
    });

    test('should warn for excessive volume', () {
      // 🐛 BUG PREVENTED: Overtraining volume not flagged
      final feedback = ScientificMetricsService.getVolumeLoadFeedback(
        weeklySetCount: 35,
        goal: 'hypertrophy',
        level: 'intermediate',
      );

      expect(feedback, contains('Excessive'));
      expect(feedback, contains('overtraining'));
    });

    test('should handle different goals and levels', () {
      // 🐛 BUG PREVENTED: Goal-specific volumes not considered
      final hypertrophyFeedback = ScientificMetricsService.getVolumeLoadFeedback(
        weeklySetCount: 12,
        goal: 'hypertrophy',
        level: 'intermediate',
      );

      final strengthFeedback = ScientificMetricsService.getVolumeLoadFeedback(
        weeklySetCount: 12,
        goal: 'strength',
        level: 'intermediate',
      );

      expect(hypertrophyFeedback, contains('Optimal'));
      expect(strengthFeedback, contains('Optimal'));
    });
  });

  group('getIntensityFeedback', () {
    test('should confirm perfect intensity for strength goal', () {
      // 🐛 BUG PREVENTED: Strength training intensity not validated
      final feedback = ScientificMetricsService.getIntensityFeedback(
        percentOf1RM: 88,
        goal: 'strength',
      );

      expect(feedback, contains('Perfect'));
      expect(feedback, contains('max strength'));
    });

    test('should confirm optimal intensity for hypertrophy', () {
      // 🐛 BUG PREVENTED: Hypertrophy zone not recognized
      final feedback = ScientificMetricsService.getIntensityFeedback(
        percentOf1RM: 75,
        goal: 'hypertrophy',
      );

      expect(feedback, contains('Optimal'));
      expect(feedback, contains('hypertrophy'));
    });

    test('should warn for too low intensity on strength goal', () {
      // 🐛 BUG PREVENTED: Suboptimal strength training not flagged
      final feedback = ScientificMetricsService.getIntensityFeedback(
        percentOf1RM: 70,
        goal: 'strength',
      );

      expect(feedback, contains('too low'));
      expect(feedback, contains('85%+'));
    });

    test('should suggest reducing intensity for hypertrophy when too high', () {
      // 🐛 BUG PREVENTED: Excessive intensity for hypertrophy not addressed
      final feedback = ScientificMetricsService.getIntensityFeedback(
        percentOf1RM: 90,
        goal: 'hypertrophy',
      );

      expect(feedback, contains('very high'));
      expect(feedback, contains('67-85%'));
    });
  });

  group('Result Classes', () {
    test('ProgressiveOverloadResult should store all values correctly', () {
      // 🐛 BUG PREVENTED: Result data corruption
      final result = ProgressiveOverloadResult(
        currentVolume: 3150,
        previousVolume: 3000,
        overloadPercent: 5.0,
        exerciseName: 'Bench Press',
      );

      expect(result.currentVolume, 3150);
      expect(result.previousVolume, 3000);
      expect(result.overloadPercent, 5.0);
      expect(result.exerciseName, 'Bench Press');
      expect(result.hasData, true);
    });

    test('ProgressiveOverloadResult.noData() should create empty result', () {
      // 🐛 BUG PREVENTED: Null handling issues
      final result = ProgressiveOverloadResult.noData();

      expect(result.hasData, false);
      expect(result.currentVolume, 0);
      expect(result.previousVolume, 0);
      expect(result.overloadPercent, 0);
    });

    test('VolumeLoadResult should store all values correctly', () {
      // 🐛 BUG PREVENTED: Volume metrics data loss
      final result = VolumeLoadResult(
        muscleGroup: 'Chest',
        totalVolume: 2000,
        totalSets: 4,
        volumeLoad: 2000,
      );

      expect(result.muscleGroup, 'Chest');
      expect(result.totalVolume, 2000);
      expect(result.totalSets, 4);
      expect(result.volumeLoad, 2000);
    });

    test('RelativeIntensityResult should store all values correctly', () {
      // 🐛 BUG PREVENTED: Intensity data corruption
      final result = RelativeIntensityResult(
        weight: 100,
        reps: 8,
        estimated1RM: 126.67,
        percentOf1RM: 79,
        formula: 'Epley',
        reliability: 'High (±5%)',
        zone: IntensityZone.strengthHypertrophy,
      );

      expect(result.weight, 100);
      expect(result.reps, 8);
      expect(result.estimated1RM, 126.67);
      expect(result.percentOf1RM, 79);
      expect(result.formula, 'Epley');
      expect(result.isValid, true);
    });

    test('RelativeIntensityResult.invalid() should create invalid result', () {
      // 🐛 BUG PREVENTED: Invalid data not properly flagged
      final result = RelativeIntensityResult.invalid();

      expect(result.isValid, false);
      expect(result.weight, 0);
      expect(result.reps, 0);
      expect(result.estimated1RM, 0);
    });
  });
}

// Helper functions

ExerciseActivity _createActivity(
  String exerciseId,
  String exerciseName,
  List<ExerciseActivitySet> sets,
) {
  return ExerciseActivity(
    id: 'activity-${DateTime.now().millisecondsSinceEpoch}-${exerciseId.hashCode}',
    email: 'test@example.com',
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    schedaName: 'Test Workout',
    sets: sets,
    createdAt: DateTime.now(),
    lastModified: DateTime.now(),
  );
}

ExerciseActivitySet _createSet({
  required double weight,
  required int reps,
  bool done = true,
  bool isWarmup = false,
}) {
  return ExerciseActivitySet(
    set: 1,
    weight: weight.toString(),
    reps: reps.toString(),
    done: done,
    effort: 3,
    isWarmup: isWarmup,
  );
}
