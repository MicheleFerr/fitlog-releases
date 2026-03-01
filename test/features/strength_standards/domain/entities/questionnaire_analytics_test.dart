/// QuestionnaireAnalytics unit tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/questionnaire_analytics.dart';

void main() {
  final now = DateTime(2024, 6, 15, 10, 0);

  group('QuestionnaireAnalytics - completionRate', () {
    test('completed returns 1.0', () {
      final q = QuestionnaireAnalytics(
        userId: 'u1',
        startedAt: now,
        completedAt: now.add(const Duration(minutes: 5)),
      );
      expect(q.completionRate, 1.0);
    });

    test('abandoned at step 3/7 returns ~0.43', () {
      final q = QuestionnaireAnalytics(
        userId: 'u1',
        startedAt: now,
        lastStepReached: 3,
        totalSteps: 7,
      );
      expect(q.completionRate, closeTo(0.4286, 0.001));
    });

    test('abandoned at step 0 returns 0', () {
      final q = QuestionnaireAnalytics(
        userId: 'u1',
        startedAt: now,
        lastStepReached: 0,
      );
      expect(q.completionRate, 0.0);
    });
  });

  group('QuestionnaireAnalytics - averageStepDuration', () {
    test('returns 0 when no step durations', () {
      final q = QuestionnaireAnalytics(userId: 'u1', startedAt: now);
      expect(q.averageStepDuration, 0.0);
    });

    test('returns average of step durations', () {
      final q = QuestionnaireAnalytics(
        userId: 'u1',
        startedAt: now,
        stepDurations: {0: 10, 1: 20, 2: 30},
      );
      expect(q.averageStepDuration, 20.0);
    });
  });

  group('QuestionnaireAnalytics - dropOffStep', () {
    test('returns null when completed', () {
      final q = QuestionnaireAnalytics(
        userId: 'u1',
        startedAt: now,
        completedAt: now.add(const Duration(minutes: 5)),
        lastStepReached: 6,
      );
      expect(q.dropOffStep, isNull);
    });

    test('returns last step when not completed', () {
      final q = QuestionnaireAnalytics(
        userId: 'u1',
        startedAt: now,
        lastStepReached: 4,
      );
      expect(q.dropOffStep, 4);
    });
  });

  group('QuestionnaireAnalytics - isCompleted', () {
    test('true when completedAt is set', () {
      final q = QuestionnaireAnalytics(
        userId: 'u1',
        startedAt: now,
        completedAt: now,
      );
      expect(q.isCompleted, true);
    });

    test('false when completedAt is null', () {
      final q = QuestionnaireAnalytics(userId: 'u1', startedAt: now);
      expect(q.isCompleted, false);
    });
  });

  group('QuestionnaireAnalytics - totalDurationMinutes', () {
    test('returns 0 when totalDurationSeconds is null', () {
      final q = QuestionnaireAnalytics(userId: 'u1', startedAt: now);
      expect(q.totalDurationMinutes, 0.0);
    });

    test('converts seconds to minutes', () {
      final q = QuestionnaireAnalytics(
        userId: 'u1',
        startedAt: now,
        totalDurationSeconds: 300,
      );
      expect(q.totalDurationMinutes, 5.0);
    });
  });

  group('QuestionnaireAnalytics - averageFeedbackRating', () {
    test('returns null when no feedback', () {
      final q = QuestionnaireAnalytics(userId: 'u1', startedAt: now);
      expect(q.averageFeedbackRating, isNull);
    });

    test('returns null when all feedback is null', () {
      final q = QuestionnaireAnalytics(
        userId: 'u1',
        startedAt: now,
        stepFeedback: {0: null, 1: null},
      );
      expect(q.averageFeedbackRating, isNull);
    });

    test('returns average of non-null feedback', () {
      final q = QuestionnaireAnalytics(
        userId: 'u1',
        startedAt: now,
        stepFeedback: {0: 4, 1: null, 2: 5},
      );
      expect(q.averageFeedbackRating, 4.5);
    });
  });

  group('QuestionnaireAnalytics - hasFeedback', () {
    test('false when no feedback', () {
      final q = QuestionnaireAnalytics(userId: 'u1', startedAt: now);
      expect(q.hasFeedback, false);
    });

    test('true when has non-null feedback', () {
      final q = QuestionnaireAnalytics(
        userId: 'u1',
        startedAt: now,
        stepFeedback: {0: 4},
      );
      expect(q.hasFeedback, true);
    });
  });

  group('QuestionnaireAnalyticsAggregated', () {
    test('completionRate', () {
      const agg = QuestionnaireAnalyticsAggregated(
        totalAttempts: 100,
        totalCompletions: 75,
        averageCompletionTime: Duration(minutes: 5),
        dropOffByStep: {2: 10, 4: 15},
        averageFeedbackByStep: {0: 4.0, 1: 3.5},
      );
      expect(agg.completionRate, 0.75);
    });

    test('mostProblematicStep returns highest drop-off', () {
      const agg = QuestionnaireAnalyticsAggregated(
        totalAttempts: 100,
        totalCompletions: 75,
        averageCompletionTime: Duration(minutes: 5),
        dropOffByStep: {2: 10, 4: 25, 5: 5},
        averageFeedbackByStep: {},
      );
      expect(agg.mostProblematicStep, 4);
    });

    test('mostProblematicStep returns 0 when empty', () {
      const agg = QuestionnaireAnalyticsAggregated(
        totalAttempts: 100,
        totalCompletions: 75,
        averageCompletionTime: Duration(minutes: 5),
        dropOffByStep: {},
        averageFeedbackByStep: {},
      );
      expect(agg.mostProblematicStep, 0);
    });
  });
}
