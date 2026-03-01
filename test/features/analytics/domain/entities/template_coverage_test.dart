/// TemplateCoverage entity tests - TemplateMuscleScore, TemplateCoverageResult,
/// computed properties.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/template_coverage.dart';

void main() {
  group('TemplateMuscleScore', () {
    test('coverageScore with full coverage', () {
      final score = TemplateMuscleScore(
        muscleName: 'chest',
        templateCount: 3,
        totalExercises: 6,
        templateNames: ['Push', 'Full A', 'Full B'],
      );
      expect(score.coverageScore, 1.0);
      expect(score.isWellCovered, isTrue);
      expect(score.hasAnyCoverage, isTrue);
    });

    test('coverageScore with partial coverage', () {
      final score = TemplateMuscleScore(
        muscleName: 'biceps',
        templateCount: 1,
        totalExercises: 2,
        templateNames: ['Pull'],
      );
      expect(score.coverageScore, greaterThan(0));
      expect(score.coverageScore, lessThan(1.0));
    });

    test('coverageScore zero for no coverage', () {
      final score = TemplateMuscleScore(
        muscleName: 'calves',
        templateCount: 0,
        totalExercises: 0,
        templateNames: [],
      );
      expect(score.coverageScore, 0.0);
      expect(score.isWellCovered, isFalse);
      expect(score.hasAnyCoverage, isFalse);
    });
  });

  group('TemplateCoverageResult', () {
    test('empty factory', () {
      final result = TemplateCoverageResult.empty();
      expect(result.muscleScores, isEmpty);
      expect(result.exerciseToTemplates, isEmpty);
      expect(result.hasData, isFalse);
      expect(result.totalPlannedExercises, 0);
    });

    test('isExercisePlanned case-insensitive', () {
      final result = TemplateCoverageResult(
        muscleScores: {},
        exerciseToTemplates: {
          'bench press': ['Push Day'],
        },
      );
      expect(result.isExercisePlanned('Bench Press'), isTrue);
      expect(result.isExercisePlanned('squat'), isFalse);
    });

    test('getTemplatesForExercise', () {
      final result = TemplateCoverageResult(
        muscleScores: {},
        exerciseToTemplates: {
          'lat pulldown': ['Pull A', 'Pull B'],
        },
      );
      expect(result.getTemplatesForExercise('Lat Pulldown'), ['Pull A', 'Pull B']);
      expect(result.getTemplatesForExercise('Unknown'), isEmpty);
    });

    test('getCoverage and hasCoverage', () {
      final chestScore = TemplateMuscleScore(
        muscleName: 'chest',
        templateCount: 2,
        totalExercises: 4,
        templateNames: ['Push', 'Full'],
      );
      final result = TemplateCoverageResult(
        muscleScores: {'chest': chestScore},
        exerciseToTemplates: {},
      );
      expect(result.getCoverage('chest'), isNotNull);
      expect(result.getCoverage('Chest'), isNotNull);
      expect(result.hasCoverage('chest'), isTrue);
      expect(result.hasCoverage('back'), isFalse);
    });

    test('wellCoveredMuscles and coveredMuscles', () {
      final well = TemplateMuscleScore(
        muscleName: 'chest',
        templateCount: 3,
        totalExercises: 6,
        templateNames: ['A', 'B', 'C'],
      );
      final partial = TemplateMuscleScore(
        muscleName: 'biceps',
        templateCount: 1,
        totalExercises: 1,
        templateNames: ['Pull'],
      );
      final result = TemplateCoverageResult(
        muscleScores: {'chest': well, 'biceps': partial},
        exerciseToTemplates: {},
      );
      expect(result.coveredMuscles, containsAll(['chest', 'biceps']));
      expect(result.wellCoveredMuscles, contains('chest'));
    });

    test('totalPlannedExercises', () {
      final result = TemplateCoverageResult(
        muscleScores: {},
        exerciseToTemplates: {
          'bench press': ['A'],
          'squat': ['B'],
        },
      );
      expect(result.totalPlannedExercises, 2);
    });

    test('hasData', () {
      expect(
        TemplateCoverageResult(
          muscleScores: {
            'chest': TemplateMuscleScore(
              muscleName: 'chest',
              templateCount: 1,
              totalExercises: 1,
              templateNames: ['A'],
            ),
          },
          exerciseToTemplates: {},
        ).hasData,
        isTrue,
      );
    });
  });
}
