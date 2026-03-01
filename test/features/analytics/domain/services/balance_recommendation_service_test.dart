/// BalanceRecommendationService tests - recommendation generation, priorities, focus.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/balance_recommendation_service.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/muscle_balance_calculator.dart';

void main() {
  group('RecommendationType', () {
    test('has 8 values', () {
      expect(RecommendationType.values.length, 8);
    });
  });

  group('RecommendationPriority', () {
    test('has 5 values', () {
      expect(RecommendationPriority.values.length, 5);
    });
  });

  group('BalanceRecommendation', () {
    test('isActionable true for non-balanced types', () {
      const rec = BalanceRecommendation(
        type: RecommendationType.increasePull,
        priority: RecommendationPriority.high,
        title: 'Test',
        description: 'Test desc',
      );
      expect(rec.isActionable, isTrue);
    });

    test('isActionable false for balanced type', () {
      const rec = BalanceRecommendation(
        type: RecommendationType.balanced,
        priority: RecommendationPriority.info,
        title: 'Balanced',
        description: 'All good',
      );
      expect(rec.isActionable, isFalse);
    });

    test('default empty lists for targetMuscles and suggestedExercises', () {
      const rec = BalanceRecommendation(
        type: RecommendationType.increasePush,
        priority: RecommendationPriority.medium,
        title: 'Test',
        description: 'Test',
      );
      expect(rec.targetMuscles, isEmpty);
      expect(rec.suggestedExercises, isEmpty);
      expect(rec.volumeAdjustment, isNull);
      expect(rec.currentRatio, isNull);
      expect(rec.targetRatio, isNull);
    });
  });

  group('BalanceRecommendationResult', () {
    test('criticalRecommendations filters correctly', () {
      const result = BalanceRecommendationResult(
        recommendations: [
          BalanceRecommendation(
            type: RecommendationType.increasePull,
            priority: RecommendationPriority.critical,
            title: 'Critical',
            description: 'Desc',
          ),
          BalanceRecommendation(
            type: RecommendationType.increaseLower,
            priority: RecommendationPriority.high,
            title: 'High',
            description: 'Desc',
          ),
        ],
        overallStatus: 'Test',
        overallScore: 5.0,
      );
      expect(result.criticalRecommendations.length, 1);
      expect(result.highPriorityRecommendations.length, 1);
    });

    test('hasCriticalIssues', () {
      const noCritical = BalanceRecommendationResult(
        recommendations: [
          BalanceRecommendation(
            type: RecommendationType.balanced,
            priority: RecommendationPriority.info,
            title: 'OK',
            description: 'OK',
          ),
        ],
        overallStatus: 'Good',
        overallScore: 9.0,
      );
      expect(noCritical.hasCriticalIssues, isFalse);

      const withCritical = BalanceRecommendationResult(
        recommendations: [
          BalanceRecommendation(
            type: RecommendationType.increasePull,
            priority: RecommendationPriority.critical,
            title: 'Bad',
            description: 'Bad',
          ),
        ],
        overallStatus: 'Bad',
        overallScore: 3.0,
      );
      expect(withCritical.hasCriticalIssues, isTrue);
    });

    test('actionableCount excludes balanced', () {
      const result = BalanceRecommendationResult(
        recommendations: [
          BalanceRecommendation(
            type: RecommendationType.increasePull,
            priority: RecommendationPriority.high,
            title: 'A',
            description: 'A',
          ),
          BalanceRecommendation(
            type: RecommendationType.balanced,
            priority: RecommendationPriority.info,
            title: 'B',
            description: 'B',
          ),
        ],
        overallStatus: 'Test',
        overallScore: 7.0,
      );
      expect(result.actionableCount, 1);
    });
  });

  group('BalanceRecommendationService.generateRecommendations', () {
    test('balanced metrics returns balanced recommendation', () {
      final metrics = MuscleBalanceMetrics.empty();
      final result =
          BalanceRecommendationService.generateRecommendations(metrics);
      expect(result.recommendations.length, 1);
      expect(
        result.recommendations.first.type,
        RecommendationType.balanced,
      );
      expect(result.hasCriticalIssues, isFalse);
      expect(result.overallScore, 10.0);
    });

    test('upper push/pull warning generates pull recommendation', () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 1.0,
        pushPullWarning: false,
        upperLowerWarning: false,
        neglectedMuscles: [],
        topMuscles: [],
        balanceScore: 7.0,
        muscleVolumePercentages: {},
        upperPushPullRatio: 2.5,
        upperPushPullWarning: true,
      );
      final result =
          BalanceRecommendationService.generateRecommendations(metrics);
      expect(result.recommendations.any(
        (r) => r.type == RecommendationType.increasePull,
      ), isTrue);
    });

    test('upper pull-dominant generates push recommendation', () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 1.0,
        pushPullWarning: false,
        upperLowerWarning: false,
        neglectedMuscles: [],
        topMuscles: [],
        balanceScore: 7.0,
        muscleVolumePercentages: {},
        upperPushPullRatio: 0.4,
        upperPushPullWarning: true,
      );
      final result =
          BalanceRecommendationService.generateRecommendations(metrics);
      expect(result.recommendations.any(
        (r) => r.type == RecommendationType.increasePush,
      ), isTrue);
    });

    test('lower push/pull warning generates posterior chain recommendation',
        () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 1.0,
        pushPullWarning: false,
        upperLowerWarning: false,
        neglectedMuscles: [],
        topMuscles: [],
        balanceScore: 7.0,
        muscleVolumePercentages: {},
        lowerPushPullRatio: 2.5,
        lowerPushPullWarning: true,
      );
      final result =
          BalanceRecommendationService.generateRecommendations(metrics);
      final pullRec = result.recommendations.firstWhere(
        (r) => r.type == RecommendationType.increasePull,
      );
      expect(pullRec.title, contains('Posterior'));
    });

    test('lower posterior-dominant generates quad recommendation', () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 1.0,
        pushPullWarning: false,
        upperLowerWarning: false,
        neglectedMuscles: [],
        topMuscles: [],
        balanceScore: 7.0,
        muscleVolumePercentages: {},
        lowerPushPullRatio: 0.4,
        lowerPushPullWarning: true,
      );
      final result =
          BalanceRecommendationService.generateRecommendations(metrics);
      final pushRec = result.recommendations.firstWhere(
        (r) => r.type == RecommendationType.increasePush,
      );
      expect(pushRec.title, contains('Quad'));
    });

    test('upper/lower warning generates leg recommendation', () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 2.5,
        pushPullWarning: false,
        upperLowerWarning: true,
        neglectedMuscles: [],
        topMuscles: [],
        balanceScore: 6.0,
        muscleVolumePercentages: {},
      );
      final result =
          BalanceRecommendationService.generateRecommendations(metrics);
      expect(result.recommendations.any(
        (r) => r.type == RecommendationType.increaseLower,
      ), isTrue);
    });

    test('lower-dominant generates upper body recommendation', () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 0.4,
        pushPullWarning: false,
        upperLowerWarning: true,
        neglectedMuscles: [],
        topMuscles: [],
        balanceScore: 6.0,
        muscleVolumePercentages: {},
      );
      final result =
          BalanceRecommendationService.generateRecommendations(metrics);
      expect(result.recommendations.any(
        (r) => r.type == RecommendationType.increaseUpper,
      ), isTrue);
    });

    test('neglected muscles generate trainNeglected recommendations', () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 1.0,
        pushPullWarning: false,
        upperLowerWarning: false,
        neglectedMuscles: ['calves', 'biceps'],
        topMuscles: [],
        balanceScore: 8.0,
        muscleVolumePercentages: {'calves': 1.0, 'biceps': 3.0},
      );
      final result =
          BalanceRecommendationService.generateRecommendations(metrics);
      final neglectedRecs = result.recommendations
          .where((r) => r.type == RecommendationType.trainNeglected)
          .toList();
      expect(neglectedRecs.length, 2);
    });

    test('recommendations sorted by priority', () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 2.5,
        pushPullWarning: false,
        upperLowerWarning: true,
        neglectedMuscles: ['calves'],
        topMuscles: [],
        balanceScore: 5.0,
        muscleVolumePercentages: {'calves': 1.0},
        upperPushPullRatio: 2.5,
        upperPushPullWarning: true,
      );
      final result =
          BalanceRecommendationService.generateRecommendations(metrics);
      // Should be sorted by priority index (critical < high < medium < low < info)
      for (int i = 0; i < result.recommendations.length - 1; i++) {
        expect(
          result.recommendations[i].priority.index,
          lessThanOrEqualTo(result.recommendations[i + 1].priority.index),
        );
      }
    });

    test('critical ratio (>2.0) gets critical priority', () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 1.0,
        pushPullWarning: false,
        upperLowerWarning: false,
        neglectedMuscles: [],
        topMuscles: [],
        balanceScore: 5.0,
        muscleVolumePercentages: {},
        upperPushPullRatio: 2.5,
        upperPushPullWarning: true,
      );
      final result =
          BalanceRecommendationService.generateRecommendations(metrics);
      expect(result.recommendations.first.priority,
          RecommendationPriority.critical);
    });

    test('nextWorkoutFocus set from top recommendation', () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 2.5,
        pushPullWarning: false,
        upperLowerWarning: true,
        neglectedMuscles: [],
        topMuscles: [],
        balanceScore: 6.0,
        muscleVolumePercentages: {},
      );
      final result =
          BalanceRecommendationService.generateRecommendations(metrics);
      expect(result.nextWorkoutFocus, isNotNull);
      expect(result.nextWorkoutFocus, contains('Leg'));
    });

    test('nextWorkoutFocus null when balanced', () {
      final metrics = MuscleBalanceMetrics.empty();
      final result =
          BalanceRecommendationService.generateRecommendations(metrics);
      expect(result.nextWorkoutFocus, isNull);
    });

    test('overallStatus reflects critical issues', () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 1.0,
        pushPullWarning: false,
        upperLowerWarning: false,
        neglectedMuscles: [],
        topMuscles: [],
        balanceScore: 5.0,
        muscleVolumePercentages: {},
        upperPushPullRatio: 2.5,
        upperPushPullWarning: true,
      );
      final result =
          BalanceRecommendationService.generateRecommendations(metrics);
      expect(result.overallStatus, contains('Critical'));
    });

    test('overallStatus excellent for high score no issues', () {
      final metrics = MuscleBalanceMetrics.empty();
      final result =
          BalanceRecommendationService.generateRecommendations(metrics);
      expect(result.overallStatus, contains('Excellent'));
    });
  });
}
