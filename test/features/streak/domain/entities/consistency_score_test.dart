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
  });
}
