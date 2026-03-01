/// MuscleBalanceAnalyzer tests - push/pull, quad/ham, distribution, feedback.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/muscle_balance_analyzer.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

void main() {
  ExerciseActivity _makeActivity({
    required String name,
    required DateTime date,
    List<ExerciseActivitySet>? sets,
  }) {
    return ExerciseActivity(
      id: 'a_${date.millisecondsSinceEpoch}_${name.hashCode}',
      email: 'test@test.com',
      exerciseId: name.toLowerCase().replaceAll(' ', '_'),
      exerciseName: name,
      schedaName: 'Test',
      sets: sets ??
          [
            ExerciseActivitySet(
              set: 1,
              weight: '80',
              reps: '10',
              done: true,
              effort: 3,
            ),
            ExerciseActivitySet(
              set: 2,
              weight: '80',
              reps: '10',
              done: true,
              effort: 3,
            ),
            ExerciseActivitySet(
              set: 3,
              weight: '80',
              reps: '10',
              done: true,
              effort: 3,
            ),
          ],
      createdAt: date,
      lastModified: date,
      category: ExerciseCategory.chest,
    );
  }

  group('PushPullBalance', () {
    test('isBalanced for ratio 0.67 to 1.0', () {
      final balanced = PushPullBalance(
        pushSets: 9,
        pullSets: 10,
        pushVolume: 9000,
        pullVolume: 10000,
        ratio: 0.9,
      );
      expect(balanced.isBalanced, isTrue);
    });

    test('isBalanced false for high ratio', () {
      final unbalanced = PushPullBalance(
        pushSets: 15,
        pullSets: 5,
        pushVolume: 15000,
        pullVolume: 5000,
        ratio: 3.0,
      );
      expect(unbalanced.isBalanced, isFalse);
    });

    test('status: Too much Pull for ratio < 0.5', () {
      final data = PushPullBalance(
        pushSets: 3,
        pullSets: 10,
        pushVolume: 3000,
        pullVolume: 10000,
        ratio: 0.3,
      );
      expect(data.status, 'Too much Pull');
    });

    test('status: Too much Push for ratio > 1.2', () {
      final data = PushPullBalance(
        pushSets: 15,
        pullSets: 5,
        pushVolume: 15000,
        pullVolume: 5000,
        ratio: 3.0,
      );
      expect(data.status, 'Too much Push');
    });

    test('status: Optimal for ratio 0.8-1.0', () {
      final data = PushPullBalance(
        pushSets: 9,
        pullSets: 10,
        pushVolume: 9000,
        pullVolume: 10000,
        ratio: 0.9,
      );
      expect(data.status, 'Optimal');
    });

    test('status: Acceptable for other ranges', () {
      final data = PushPullBalance(
        pushSets: 12,
        pullSets: 10,
        pushVolume: 12000,
        pullVolume: 10000,
        ratio: 1.1,
      );
      expect(data.status, 'Acceptable');
    });
  });

  group('QuadHamstringBalance', () {
    test('isBalanced for ratio 0.6-1.0', () {
      final balanced = QuadHamstringBalance(
        quadSets: 10,
        hamstringSets: 8,
        quadVolume: 10000,
        hamstringVolume: 8000,
        ratio: 0.8,
      );
      expect(balanced.isBalanced, isTrue);
    });

    test('isHighRisk for ratio < 0.5', () {
      final risky = QuadHamstringBalance(
        quadSets: 10,
        hamstringSets: 3,
        quadVolume: 10000,
        hamstringVolume: 3000,
        ratio: 0.3,
      );
      expect(risky.isHighRisk, isTrue);
    });

    test('status: High Injury Risk for ratio < 0.5', () {
      final data = QuadHamstringBalance(
        quadSets: 10,
        hamstringSets: 3,
        quadVolume: 10000,
        hamstringVolume: 3000,
        ratio: 0.3,
      );
      expect(data.status, 'High Injury Risk');
    });

    test('status: Under-trained for ratio 0.5-0.6', () {
      final data = QuadHamstringBalance(
        quadSets: 10,
        hamstringSets: 5,
        quadVolume: 10000,
        hamstringVolume: 5000,
        ratio: 0.55,
      );
      expect(data.status, 'Under-trained');
    });

    test('status: Optimal for ratio 0.6-1.0', () {
      final data = QuadHamstringBalance(
        quadSets: 10,
        hamstringSets: 8,
        quadVolume: 10000,
        hamstringVolume: 8000,
        ratio: 0.8,
      );
      expect(data.status, 'Optimal');
    });

    test('status: Over-emphasized for ratio > 1.0', () {
      final data = QuadHamstringBalance(
        quadSets: 5,
        hamstringSets: 8,
        quadVolume: 5000,
        hamstringVolume: 8000,
        ratio: 1.6,
      );
      expect(data.status, 'Over-emphasized');
    });
  });

  group('MuscleDistribution', () {
    test('empty factory', () {
      final empty = MuscleDistribution.empty();
      expect(empty.totalVolume, 0);
      expect(empty.volumeByGroup, isEmpty);
      expect(empty.percentageDistribution, isEmpty);
      expect(empty.topMuscleGroup, isNull);
      expect(empty.topPercentage, isNull);
    });

    test('topMuscleGroup returns highest percentage', () {
      final dist = MuscleDistribution(
        volumeByGroup: {'Chest': 5000.0, 'Back': 3000.0, 'Legs': 2000.0},
        percentageDistribution: {'Chest': 50.0, 'Back': 30.0, 'Legs': 20.0},
        totalVolume: 10000,
      );
      expect(dist.topMuscleGroup, 'Chest');
      expect(dist.topPercentage, 50.0);
    });
  });

  group('MuscleBalanceAnalyzer.analyzePushPullBalance', () {
    test('empty activities returns zero ratio', () {
      final result = MuscleBalanceAnalyzer.analyzePushPullBalance([]);
      expect(result.pushSets, 0);
      expect(result.pullSets, 0);
      expect(result.ratio, 0.0);
    });

    test('push-only activities', () {
      final activities = [
        _makeActivity(name: 'Bench Press', date: DateTime(2025, 1, 1)),
      ];
      final result = MuscleBalanceAnalyzer.analyzePushPullBalance(activities);
      expect(result.pushSets, greaterThan(0));
    });
  });

  group('MuscleBalanceAnalyzer.analyzeQuadHamstringBalance', () {
    test('empty activities returns zero ratio', () {
      final result = MuscleBalanceAnalyzer.analyzeQuadHamstringBalance([]);
      expect(result.quadSets, 0);
      expect(result.hamstringSets, 0);
      expect(result.ratio, 0.0);
    });

    test('squat detected as quad exercise', () {
      final activities = [
        _makeActivity(name: 'Back Squat', date: DateTime(2025, 1, 1)),
      ];
      final result =
          MuscleBalanceAnalyzer.analyzeQuadHamstringBalance(activities);
      expect(result.quadSets, greaterThan(0));
    });

    test('rdl detected as hamstring exercise', () {
      final activities = [
        _makeActivity(name: 'Romanian Deadlift', date: DateTime(2025, 1, 1)),
      ];
      final result =
          MuscleBalanceAnalyzer.analyzeQuadHamstringBalance(activities);
      expect(result.hamstringSets, greaterThan(0));
    });

    test('leg curl detected as hamstring exercise', () {
      final activities = [
        _makeActivity(name: 'Leg Curl', date: DateTime(2025, 1, 1)),
      ];
      final result =
          MuscleBalanceAnalyzer.analyzeQuadHamstringBalance(activities);
      expect(result.hamstringSets, greaterThan(0));
    });

    test('leg press detected as quad exercise', () {
      final activities = [
        _makeActivity(name: 'Leg Press', date: DateTime(2025, 1, 1)),
      ];
      final result =
          MuscleBalanceAnalyzer.analyzeQuadHamstringBalance(activities);
      expect(result.quadSets, greaterThan(0));
    });

    test('leg extension detected as quad exercise', () {
      final activities = [
        _makeActivity(name: 'Leg Extension', date: DateTime(2025, 1, 1)),
      ];
      final result =
          MuscleBalanceAnalyzer.analyzeQuadHamstringBalance(activities);
      expect(result.quadSets, greaterThan(0));
    });
  });

  group('MuscleBalanceAnalyzer.analyzeDistribution', () {
    test('empty activities returns empty distribution', () {
      final result = MuscleBalanceAnalyzer.analyzeDistribution([]);
      expect(result.totalVolume, 0);
      expect(result.topMuscleGroup, isNull);
    });
  });

  group('MuscleBalanceAnalyzer.getPushPullFeedback', () {
    test('feedbackTooMuchPull for ratio < 0.5', () {
      expect(
        MuscleBalanceAnalyzer.getPushPullFeedback(0.3),
        'feedbackTooMuchPull',
      );
    });

    test('feedbackTooMuchPush for ratio > 1.2', () {
      expect(
        MuscleBalanceAnalyzer.getPushPullFeedback(1.5),
        'feedbackTooMuchPush',
      );
    });

    test('feedbackSlightPushExcess for ratio 1.0-1.2', () {
      expect(
        MuscleBalanceAnalyzer.getPushPullFeedback(1.1),
        'feedbackSlightPushExcess',
      );
    });

    test('feedbackOptimalPushPull for ratio 0.8-1.0', () {
      expect(
        MuscleBalanceAnalyzer.getPushPullFeedback(0.9),
        'feedbackOptimalPushPull',
      );
    });

    test('feedbackGoodPullEmphasis for ratio 0.5-0.8', () {
      expect(
        MuscleBalanceAnalyzer.getPushPullFeedback(0.6),
        'feedbackGoodPullEmphasis',
      );
    });
  });

  group('MuscleBalanceAnalyzer.getQuadHamFeedback', () {
    test('severely undertrained for ratio < 0.5', () {
      expect(
        MuscleBalanceAnalyzer.getQuadHamFeedback(0.3),
        'feedbackHamstringSeverelyUndertrained',
      );
    });

    test('undertrained for ratio 0.5-0.6', () {
      expect(
        MuscleBalanceAnalyzer.getQuadHamFeedback(0.55),
        'feedbackHamstringUndertrained',
      );
    });

    test('optimal for ratio 0.6-1.0', () {
      expect(
        MuscleBalanceAnalyzer.getQuadHamFeedback(0.8),
        'feedbackOptimalQuadHam',
      );
    });

    test('over-emphasized for ratio > 1.0', () {
      expect(
        MuscleBalanceAnalyzer.getQuadHamFeedback(1.5),
        'feedbackHamstringOveremphasized',
      );
    });
  });
}
