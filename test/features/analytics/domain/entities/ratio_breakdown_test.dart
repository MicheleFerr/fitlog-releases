/// RatioBreakdown entity tests - ExerciseContribution, CategoryBreakdown,
/// RatioBreakdown computed properties and factories.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/ratio_breakdown.dart';

void main() {
  group('ExerciseContribution', () {
    test('stores all fields', () {
      const ec = ExerciseContribution(
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        volume: 5000,
        percentage: 45.0,
        isPrimary: true,
      );
      expect(ec.exerciseName, 'Bench Press');
      expect(ec.muscleGroup, 'Chest');
      expect(ec.volume, 5000);
      expect(ec.percentage, 45.0);
      expect(ec.isPrimary, isTrue);
    });

    test('isPrimary defaults to true', () {
      const ec = ExerciseContribution(
        exerciseName: 'Fly',
        muscleGroup: 'Chest',
        volume: 1000,
        percentage: 10,
      );
      expect(ec.isPrimary, isTrue);
    });
  });

  group('CategoryBreakdown', () {
    test('hasData', () {
      const empty = CategoryBreakdown(
        categoryName: 'Push',
        totalVolume: 0,
        exercisesByMuscle: {},
      );
      expect(empty.hasData, isFalse);

      const withData = CategoryBreakdown(
        categoryName: 'Push',
        totalVolume: 5000,
        exercisesByMuscle: {},
      );
      expect(withData.hasData, isTrue);
    });

    test('allExercises sorted by volume desc', () {
      const breakdown = CategoryBreakdown(
        categoryName: 'Push',
        totalVolume: 8000,
        exercisesByMuscle: {
          'Chest': [
            ExerciseContribution(
              exerciseName: 'Bench Press',
              muscleGroup: 'Chest',
              volume: 5000,
              percentage: 62.5,
            ),
          ],
          'Shoulders': [
            ExerciseContribution(
              exerciseName: 'OHP',
              muscleGroup: 'Shoulders',
              volume: 3000,
              percentage: 37.5,
            ),
          ],
        },
      );

      final all = breakdown.allExercises;
      expect(all.length, 2);
      expect(all.first.exerciseName, 'Bench Press');
      expect(all.last.exerciseName, 'OHP');
    });

    test('topExercises returns limited count', () {
      const breakdown = CategoryBreakdown(
        categoryName: 'Pull',
        totalVolume: 6000,
        exercisesByMuscle: {
          'Back': [
            ExerciseContribution(
              exerciseName: 'Row',
              muscleGroup: 'Back',
              volume: 3000,
              percentage: 50,
            ),
            ExerciseContribution(
              exerciseName: 'Pulldown',
              muscleGroup: 'Back',
              volume: 2000,
              percentage: 33,
            ),
            ExerciseContribution(
              exerciseName: 'Curl',
              muscleGroup: 'Back',
              volume: 1000,
              percentage: 17,
            ),
          ],
        },
      );

      expect(breakdown.topExercises(2).length, 2);
      expect(breakdown.topExercises(2).first.exerciseName, 'Row');
    });
  });

  group('RatioBreakdown', () {
    test('empty factory', () {
      final empty = RatioBreakdown.empty();
      expect(empty.pushBreakdown.totalVolume, 0);
      expect(empty.pullBreakdown.totalVolume, 0);
      expect(empty.upperBreakdown.totalVolume, 0);
      expect(empty.lowerBreakdown.totalVolume, 0);
      expect(empty.hasData, isFalse);
    });

    test('hasData when any category has volume', () {
      final withData = RatioBreakdown(
        pushBreakdown: const CategoryBreakdown(
          categoryName: 'Push',
          totalVolume: 5000,
          exercisesByMuscle: {},
        ),
        pullBreakdown: const CategoryBreakdown(
          categoryName: 'Pull',
          totalVolume: 0,
          exercisesByMuscle: {},
        ),
        upperBreakdown: const CategoryBreakdown(
          categoryName: 'Upper',
          totalVolume: 0,
          exercisesByMuscle: {},
        ),
        lowerBreakdown: const CategoryBreakdown(
          categoryName: 'Lower',
          totalVolume: 0,
          exercisesByMuscle: {},
        ),
      );
      expect(withData.hasData, isTrue);
    });

    test('pushPullPair and upperLowerPair', () {
      final breakdown = RatioBreakdown.empty();
      final (push, pull) = breakdown.pushPullPair;
      expect(push.categoryName, 'Push');
      expect(pull.categoryName, 'Pull');

      final (upper, lower) = breakdown.upperLowerPair;
      expect(upper.categoryName, 'Upper');
      expect(lower.categoryName, 'Lower');
    });
  });
}
