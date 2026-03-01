import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/consistency_score.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/weekly_stats.dart';

void main() {
  group('ConsistencyScore', () {
    test('creates instance with binary indicators', () {
      final score = ConsistencyScore(
        frequencyOptimal: true,
        restOptimal: false,
        progressionPositive: true,
        frequencyScore: 85,
        restScore: 60,
        progressionScore: 90,
        weeklyStats: WeeklyStats.empty(),
        calculatedAt: DateTime.now(),
      );

      expect(score.frequencyOptimal, true);
      expect(score.restOptimal, false);
      expect(score.progressionPositive, true);
    });

    test('empty() factory creates all indicators false', () {
      final empty = ConsistencyScore.empty();

      expect(empty.frequencyOptimal, false);
      expect(empty.restOptimal, false);
      expect(empty.progressionPositive, false);
    });

    test('empty() factory sets all numeric scores to 0', () {
      final empty = ConsistencyScore.empty();

      expect(empty.frequencyScore, 0);
      expect(empty.restScore, 0);
      expect(empty.progressionScore, 0);
      expect(empty.workoutsCompleted, 0);
      expect(empty.workoutsSkipped, 0);
      expect(empty.longestStreak, 0);
      expect(empty.currentStreak, 0);
      expect(empty.avgFrequency, 0.0);
    });

    test('empty() factory sets calculatedAt', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final empty = ConsistencyScore.empty();
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(empty.calculatedAt, isNotNull);
      expect(empty.calculatedAt!.isAfter(before), isTrue);
      expect(empty.calculatedAt!.isBefore(after), isTrue);
    });

    group('fromJson / toJson', () {
      Map<String, dynamic> _weeklyStatsJson() => {
            'avgWorkoutsPerWeek': 3.5,
            'avgRestDaysPerWeek': 2.5,
            'totalWorkouts': 7,
            'totalRestDays': 5,
            'totalActiveDays': 7,
            'weekStartDate': null,
            'weekEndDate': null,
          };

      test('fromJson parses binary indicators correctly', () {
        final json = {
          'frequencyOptimal': true,
          'restOptimal': false,
          'progressionPositive': true,
          'frequencyScore': 95,
          'restScore': 80,
          'progressionScore': 85,
          'weeklyStats': _weeklyStatsJson(),
          'workoutsCompleted': 10,
          'workoutsSkipped': 2,
          'avgFrequency': 3.5,
          'longestStreak': 14,
          'currentStreak': 5,
          'calculatedAt': null,
          'overallScore': null,
          'scoreRating': null,
          'rating': null,
          'riskLevel': null,
          'overtrainingRisk': null,
          'volumeScore': null,
        };

        final score = ConsistencyScore.fromJson(json);

        expect(score.frequencyOptimal, true);
        expect(score.restOptimal, false);
        expect(score.progressionPositive, true);
        expect(score.frequencyScore, 95);
        expect(score.restScore, 80);
        expect(score.progressionScore, 85);
        expect(score.workoutsCompleted, 10);
        expect(score.workoutsSkipped, 2);
        expect(score.avgFrequency, 3.5);
        expect(score.longestStreak, 14);
        expect(score.currentStreak, 5);
      });

      test('fromJson with all false indicators', () {
        final json = {
          'frequencyOptimal': false,
          'restOptimal': false,
          'progressionPositive': false,
          'frequencyScore': 0,
          'restScore': 0,
          'progressionScore': 0,
          'weeklyStats': _weeklyStatsJson(),
          'workoutsCompleted': 0,
          'workoutsSkipped': 0,
          'avgFrequency': 0.0,
          'longestStreak': 0,
          'currentStreak': 0,
          'calculatedAt': null,
          'overallScore': null,
          'scoreRating': null,
          'rating': null,
          'riskLevel': null,
          'overtrainingRisk': null,
          'volumeScore': null,
        };

        final score = ConsistencyScore.fromJson(json);

        expect(score.frequencyOptimal, false);
        expect(score.restOptimal, false);
        expect(score.progressionPositive, false);
      });

      test('fromJson applies defaults for missing optional fields', () {
        final json = {
          'weeklyStats': _weeklyStatsJson(),
          // Everything else will use defaults
        };

        final score = ConsistencyScore.fromJson(json);

        expect(score.frequencyOptimal, false);
        expect(score.restOptimal, false);
        expect(score.progressionPositive, false);
        expect(score.frequencyScore, 0);
      });

      test('toJson serializes binary indicators', () {
        final score = ConsistencyScore(
          frequencyOptimal: true,
          restOptimal: true,
          progressionPositive: false,
          frequencyScore: 100,
          restScore: 90,
          progressionScore: 70,
          weeklyStats: WeeklyStats.empty(),
        );

        final json = score.toJson();

        expect(json['frequencyOptimal'], true);
        expect(json['restOptimal'], true);
        expect(json['progressionPositive'], false);
        expect(json['frequencyScore'], 100);
        expect(json['restScore'], 90);
        expect(json['progressionScore'], 70);
        expect(json['weeklyStats'], isA<Map<String, dynamic>>());
      });

      test('round-trip fromJson(toJson()) preserves binary indicators', () {
        final original = ConsistencyScore(
          frequencyOptimal: true,
          restOptimal: false,
          progressionPositive: true,
          frequencyScore: 85,
          restScore: 60,
          progressionScore: 90,
          weeklyStats: WeeklyStats(totalWorkouts: 5),
          workoutsCompleted: 10,
          currentStreak: 7,
          longestStreak: 14,
        );

        final json = original.toJson();
        final restored = ConsistencyScore.fromJson(json);

        expect(restored.frequencyOptimal, original.frequencyOptimal);
        expect(restored.restOptimal, original.restOptimal);
        expect(restored.progressionPositive, original.progressionPositive);
        expect(restored.frequencyScore, original.frequencyScore);
        expect(restored.restScore, original.restScore);
        expect(restored.progressionScore, original.progressionScore);
        expect(restored.workoutsCompleted, original.workoutsCompleted);
        expect(restored.currentStreak, original.currentStreak);
        expect(restored.longestStreak, original.longestStreak);
      });

      test('fromJson handles overtrainingRisk enum values', () {
        final json = {
          'weeklyStats': _weeklyStatsJson(),
          'overtrainingRisk': 'medium',
        };

        // ignore: deprecated_member_use
        final score = ConsistencyScore.fromJson(json);
        // ignore: deprecated_member_use
        expect(score.overtrainingRisk, OvertrainingRisk.medium);
      });
    });
  });
}
