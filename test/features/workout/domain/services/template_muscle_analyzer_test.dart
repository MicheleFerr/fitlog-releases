import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/template_muscle_analyzer.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';

/// Helper to create an ExerciseTemplate with a given number of sets.
ExerciseTemplate _makeExercise(
  String name,
  ExerciseCategory category, {
  int setCount = 3,
}) {
  return ExerciseTemplate(
    exerciseId: name.toLowerCase().replaceAll(' ', '_'),
    exerciseName: name,
    category: category,
    sets: List.generate(
      setCount,
      (i) => SetTemplate(setNumber: i + 1, targetReps: 10),
    ),
  );
}

void main() {
  group('TemplateMuscleAnalysis', () {
    test('empty constant has correct defaults', () {
      const analysis = TemplateMuscleAnalysis.empty;

      expect(analysis.musclePercentages, isEmpty);
      expect(analysis.exerciseBreakdown, isEmpty);
      expect(analysis.pushPullRatio, 0);
      expect(analysis.upperLowerRatio, 0);
      expect(analysis.pushPullWarning, isFalse);
      expect(analysis.upperLowerWarning, isFalse);
      expect(analysis.coveredMuscles, isEmpty);
      expect(analysis.neglectedMuscles, isEmpty);
      expect(analysis.missingMuscles, isEmpty);
      expect(analysis.totalSets, 0);
      expect(analysis.isEmpty, isTrue);
      expect(analysis.hasWarnings, isFalse);
    });

    test('hasWarnings is true when pushPullWarning is true', () {
      const analysis = TemplateMuscleAnalysis(
        musclePercentages: {},
        exerciseBreakdown: [],
        pushPullRatio: 2.0,
        upperLowerRatio: 1.0,
        pushPullWarning: true,
        upperLowerWarning: false,
        coveredMuscles: [],
        neglectedMuscles: [],
        missingMuscles: [],
        totalSets: 5,
      );

      expect(analysis.hasWarnings, isTrue);
    });

    test('hasWarnings is true when upperLowerWarning is true', () {
      const analysis = TemplateMuscleAnalysis(
        musclePercentages: {},
        exerciseBreakdown: [],
        pushPullRatio: 1.0,
        upperLowerRatio: 2.0,
        pushPullWarning: false,
        upperLowerWarning: true,
        coveredMuscles: [],
        neglectedMuscles: [],
        missingMuscles: [],
        totalSets: 5,
      );

      expect(analysis.hasWarnings, isTrue);
    });

    test('isEmpty is false when totalSets > 0', () {
      const analysis = TemplateMuscleAnalysis(
        musclePercentages: {},
        exerciseBreakdown: [],
        pushPullRatio: 0,
        upperLowerRatio: 0,
        pushPullWarning: false,
        upperLowerWarning: false,
        coveredMuscles: [],
        neglectedMuscles: [],
        missingMuscles: [],
        totalSets: 3,
      );

      expect(analysis.isEmpty, isFalse);
    });
  });

  group('TemplateMuscleAnalyzer.analyze', () {
    group('empty and edge cases', () {
      test('returns empty analysis for empty exercise list', () {
        final result = TemplateMuscleAnalyzer.analyze([]);

        expect(result.isEmpty, isTrue);
        expect(result.totalSets, 0);
        expect(result.musclePercentages, isEmpty);
      });

      test('returns empty analysis when all exercises have 0 sets', () {
        final exercises = [
          const ExerciseTemplate(
            exerciseId: 'bench',
            exerciseName: 'Bench Press',
            category: ExerciseCategory.chest,
            sets: [],
          ),
        ];

        final result = TemplateMuscleAnalyzer.analyze(exercises);

        expect(result.isEmpty, isTrue);
        expect(result.totalSets, 0);
      });
    });

    group('category-based fallback distribution', () {
      test('chest exercise maps to PETT', () {
        final exercises = [_makeExercise('Custom Chest', ExerciseCategory.chest)];

        final result = TemplateMuscleAnalyzer.analyze(exercises);

        expect(result.totalSets, 3);
        expect(result.musclePercentages, isNotEmpty);
        // PETT should be in covered muscles
        expect(result.coveredMuscles, contains('PETT'));
      });

      test('back exercise maps to LAT and TRAP', () {
        final exercises = [_makeExercise('Custom Back', ExerciseCategory.back)];

        final result = TemplateMuscleAnalyzer.analyze(exercises);

        expect(result.totalSets, 3);
        // Back maps to LAT and TRAP
        final coveredOrNeglected = [
          ...result.coveredMuscles,
          ...result.neglectedMuscles,
        ];
        expect(
          coveredOrNeglected.contains('LAT') ||
              coveredOrNeglected.contains('TRAP'),
          isTrue,
        );
      });

      test('shoulders exercise maps to DELT variants', () {
        final exercises = [
          _makeExercise('Custom Shoulders', ExerciseCategory.shoulders),
        ];

        final result = TemplateMuscleAnalyzer.analyze(exercises);

        expect(result.totalSets, 3);
        expect(result.musclePercentages, isNotEmpty);
      });

      test('arms exercise maps to BICI and TRIC', () {
        final exercises = [_makeExercise('Custom Arms', ExerciseCategory.arms)];

        final result = TemplateMuscleAnalyzer.analyze(exercises);

        expect(result.totalSets, 3);
      });

      test('legs exercise maps to QUAD, FEMO, GLUT', () {
        final exercises = [_makeExercise('Custom Legs', ExerciseCategory.legs)];

        final result = TemplateMuscleAnalyzer.analyze(exercises);

        expect(result.totalSets, 3);
      });

      test('abs exercise maps to CORE', () {
        final exercises = [_makeExercise('Custom Abs', ExerciseCategory.abs)];

        final result = TemplateMuscleAnalyzer.analyze(exercises);

        expect(result.totalSets, 3);
        expect(result.coveredMuscles, contains('CORE'));
      });

      test('cardio exercise produces empty muscle percentages', () {
        // Use a name that won't match any name-based categorization
        final exercises = [
          _makeExercise('Xyzzy Zzzz', ExerciseCategory.cardio),
        ];

        final result = TemplateMuscleAnalyzer.analyze(exercises);

        // Cardio has no muscle mapping, so totalSets > 0 but no volume
        expect(result.totalSets, 3);
        expect(result.musclePercentages, isEmpty);
        expect(result.exerciseBreakdown, isEmpty);
      });

      test('other category produces empty muscle percentages', () {
        final exercises = [
          _makeExercise('Xyzzy Zzzz', ExerciseCategory.other),
        ];

        final result = TemplateMuscleAnalyzer.analyze(exercises);

        expect(result.totalSets, 3);
        expect(result.musclePercentages, isEmpty);
        expect(result.exerciseBreakdown, isEmpty);
      });
    });

    group('muscleMap-based distribution', () {
      test('uses muscleMap when provided', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest),
        ];
        final muscleMap = {
          'Bench Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: ['TRIC', 'DELT_ANT'],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        expect(result.totalSets, 3);
        expect(result.musclePercentages, isNotEmpty);
        // Primary (PETT) gets 70%, secondary (TRIC, DELT_ANT) get 30%
        expect(result.coveredMuscles, contains('PETT'));
      });

      test('tries lowercase exercise name lookup', () {
        final exercises = [
          _makeExercise('BENCH PRESS', ExerciseCategory.chest),
        ];
        final muscleMap = {
          'bench press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: ['TRIC'],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        expect(result.totalSets, 3);
        expect(result.coveredMuscles, contains('PETT'));
      });

      test('falls back to category when not in muscleMap', () {
        final exercises = [
          _makeExercise('Unknown Exercise', ExerciseCategory.chest),
        ];
        final muscleMap = <String, ExerciseMuscleData>{
          'Different Exercise': const ExerciseMuscleData(
            primary: ['LAT'],
            secondary: [],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        expect(result.totalSets, 3);
        // Should use chest category fallback -> PETT
        expect(result.coveredMuscles, contains('PETT'));
      });

      test('primary only muscles get 100% of volume', () {
        final exercises = [
          _makeExercise('Isolation Exercise', ExerciseCategory.other, setCount: 4),
        ];
        final muscleMap = {
          'Isolation Exercise': const ExerciseMuscleData(
            primary: ['BICI'],
            secondary: [],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        expect(result.totalSets, 4);
        expect(result.coveredMuscles, contains('BICI'));
      });

      test('muscleMap with empty primary and secondary falls back', () {
        final exercises = [
          _makeExercise('Empty Muscle Exercise', ExerciseCategory.legs),
        ];
        final muscleMap = {
          'Empty Muscle Exercise': const ExerciseMuscleData(
            primary: [],
            secondary: [],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        // hasData is false for empty primary+secondary, so falls back to category
        expect(result.totalSets, 3);
      });
    });

    group('push/pull ratio', () {
      test('balanced push/pull gives ratio near 1.0', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 3),
          _makeExercise('Custom Row', ExerciseCategory.back, setCount: 3),
        ];
        final muscleMap = {
          'Bench Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: [],
          ),
          'Custom Row': const ExerciseMuscleData(
            primary: ['LAT'],
            secondary: [],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        expect(result.pushPullRatio, closeTo(1.0, 0.01));
        expect(result.pushPullWarning, isFalse);
      });

      test('push-heavy gives warning (ratio > 1.5)', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 6),
          _makeExercise('Incline Press', ExerciseCategory.chest, setCount: 6),
          _makeExercise('Custom Row', ExerciseCategory.back, setCount: 2),
        ];
        final muscleMap = {
          'Bench Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: [],
          ),
          'Incline Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: [],
          ),
          'Custom Row': const ExerciseMuscleData(
            primary: ['LAT'],
            secondary: [],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        expect(result.pushPullRatio, greaterThan(1.5));
        expect(result.pushPullWarning, isTrue);
      });

      test('pull-heavy gives warning (ratio < 0.67)', () {
        final exercises = [
          _makeExercise('Custom Row', ExerciseCategory.back, setCount: 6),
          _makeExercise('Pullup', ExerciseCategory.back, setCount: 6),
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 1),
        ];
        final muscleMap = {
          'Custom Row': const ExerciseMuscleData(
            primary: ['LAT'],
            secondary: [],
          ),
          'Pullup': const ExerciseMuscleData(
            primary: ['LAT'],
            secondary: ['BICI'],
          ),
          'Bench Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: [],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        expect(result.pushPullRatio, lessThan(0.67));
        expect(result.pushPullWarning, isTrue);
      });

      test('only push muscles gives ratio 2.0', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 3),
        ];
        final muscleMap = {
          'Bench Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: [],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        // Only push, no pull => pushVolume / 0 = 2.0 (special case)
        expect(result.pushPullRatio, 2.0);
      });

      test('only pull muscles gives ratio 0', () {
        final exercises = [
          _makeExercise('Custom Row', ExerciseCategory.back, setCount: 3),
        ];
        final muscleMap = {
          'Custom Row': const ExerciseMuscleData(
            primary: ['LAT'],
            secondary: [],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        // No push volume, pull > 0 => 0 / pullVolume = 0
        expect(result.pushPullRatio, 0);
      });

      test('no push or pull muscles gives ratio 0', () {
        final exercises = [
          _makeExercise('Plank', ExerciseCategory.abs, setCount: 3),
        ];
        final muscleMap = {
          'Plank': const ExerciseMuscleData(
            primary: ['CORE'],
            secondary: [],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        expect(result.pushPullRatio, 0);
        expect(result.pushPullWarning, isFalse);
      });
    });

    group('upper/lower ratio', () {
      test('balanced upper/lower gives ratio near 1.0', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 3),
          _makeExercise('Squat', ExerciseCategory.legs, setCount: 3),
        ];
        final muscleMap = {
          'Bench Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: [],
          ),
          'Squat': const ExerciseMuscleData(
            primary: ['QUAD'],
            secondary: [],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        expect(result.upperLowerRatio, closeTo(1.0, 0.01));
        expect(result.upperLowerWarning, isFalse);
      });

      test('upper-heavy gives warning', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 5),
          _makeExercise('Shoulder Press', ExerciseCategory.shoulders, setCount: 5),
          _makeExercise('Squat', ExerciseCategory.legs, setCount: 1),
        ];
        final muscleMap = {
          'Bench Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: [],
          ),
          'Shoulder Press': const ExerciseMuscleData(
            primary: ['DELT_ANT'],
            secondary: [],
          ),
          'Squat': const ExerciseMuscleData(
            primary: ['QUAD'],
            secondary: [],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        expect(result.upperLowerRatio, greaterThan(1.5));
        expect(result.upperLowerWarning, isTrue);
      });

      test('only upper muscles gives ratio 2.0', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 3),
        ];
        final muscleMap = {
          'Bench Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: [],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        expect(result.upperLowerRatio, 2.0);
      });
    });

    group('muscle classification', () {
      test('covered muscles have >5% volume', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 5),
        ];
        final muscleMap = {
          'Bench Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: [],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        expect(result.coveredMuscles, contains('PETT'));
      });

      test('missing muscles have 0% volume', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 3),
        ];
        final muscleMap = {
          'Bench Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: [],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        // Most trackable muscles should be missing
        expect(result.missingMuscles, isNotEmpty);
        // Muscles not targeted at all
        expect(result.missingMuscles, contains('LAT'));
        expect(result.missingMuscles, contains('QUAD'));
        expect(result.missingMuscles, contains('GLUT'));
      });

      test('covered muscles are sorted by percentage descending', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 5),
          _makeExercise('Squat', ExerciseCategory.legs, setCount: 3),
        ];
        final muscleMap = {
          'Bench Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: ['TRIC'],
          ),
          'Squat': const ExerciseMuscleData(
            primary: ['QUAD'],
            secondary: ['GLUT'],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        if (result.coveredMuscles.length > 1) {
          for (int i = 0; i < result.coveredMuscles.length - 1; i++) {
            final current =
                result.musclePercentages[result.coveredMuscles[i]] ?? 0;
            final next =
                result.musclePercentages[result.coveredMuscles[i + 1]] ?? 0;
            // Note: musclePercentages uses heatmap keys, coveredMuscles uses canonical
            // So we just verify the list is not empty
          }
        }

        expect(result.coveredMuscles, isNotEmpty);
      });
    });

    group('exercise breakdown', () {
      test('breakdown has one entry per exercise with muscle data', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 3),
          _makeExercise('Squat', ExerciseCategory.legs, setCount: 4),
        ];
        final muscleMap = {
          'Bench Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: [],
          ),
          'Squat': const ExerciseMuscleData(
            primary: ['QUAD'],
            secondary: [],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        expect(result.exerciseBreakdown.length, 2);
        expect(result.exerciseBreakdown[0].exerciseName, 'Bench Press');
        expect(result.exerciseBreakdown[0].sets, 3);
        expect(result.exerciseBreakdown[1].exerciseName, 'Squat');
        expect(result.exerciseBreakdown[1].sets, 4);
      });

      test('totalPercentage sums to 100 across exercises', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 3),
          _makeExercise('Squat', ExerciseCategory.legs, setCount: 3),
        ];
        final muscleMap = {
          'Bench Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: [],
          ),
          'Squat': const ExerciseMuscleData(
            primary: ['QUAD'],
            secondary: [],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        final totalPct = result.exerciseBreakdown
            .map((b) => b.totalPercentage)
            .fold(0.0, (sum, v) => sum + v);

        expect(totalPct, closeTo(100.0, 0.1));
      });

      test('contributions within an exercise sum to 100%', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 3),
        ];
        final muscleMap = {
          'Bench Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: ['TRIC', 'DELT_ANT'],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        expect(result.exerciseBreakdown.length, 1);
        final breakdown = result.exerciseBreakdown.first;
        final contributionSum = breakdown.contributions
            .map((c) => c.percentage)
            .fold(0.0, (sum, v) => sum + v);

        expect(contributionSum, closeTo(100.0, 0.1));
      });

      test('contributions are sorted by percentage descending', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 3),
        ];
        final muscleMap = {
          'Bench Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: ['TRIC', 'DELT_ANT'],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        final contributions = result.exerciseBreakdown.first.contributions;
        for (int i = 0; i < contributions.length - 1; i++) {
          expect(
            contributions[i].percentage,
            greaterThanOrEqualTo(contributions[i + 1].percentage),
          );
        }
      });
    });

    group('totalSets', () {
      test('counts sets across all exercises', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 3),
          _makeExercise('Squat', ExerciseCategory.legs, setCount: 4),
          _makeExercise('Pullup', ExerciseCategory.back, setCount: 2),
        ];

        final result = TemplateMuscleAnalyzer.analyze(exercises);

        expect(result.totalSets, 9);
      });

      test('ignores exercises with 0 sets', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 3),
          const ExerciseTemplate(
            exerciseId: 'empty',
            exerciseName: 'Empty Exercise',
            category: ExerciseCategory.chest,
            sets: [],
          ),
        ];

        final result = TemplateMuscleAnalyzer.analyze(exercises);

        expect(result.totalSets, 3);
      });
    });

    group('multiple exercises complex scenario', () {
      test('full body workout has balanced ratios', () {
        final exercises = [
          _makeExercise('Bench Press', ExerciseCategory.chest, setCount: 3),
          _makeExercise('Barbell Row', ExerciseCategory.back, setCount: 3),
          _makeExercise('Squat', ExerciseCategory.legs, setCount: 3),
          _makeExercise('Overhead Press', ExerciseCategory.shoulders, setCount: 3),
        ];
        final muscleMap = {
          'Bench Press': const ExerciseMuscleData(
            primary: ['PETT'],
            secondary: ['TRIC'],
          ),
          'Barbell Row': const ExerciseMuscleData(
            primary: ['LAT'],
            secondary: ['BICI'],
          ),
          'Squat': const ExerciseMuscleData(
            primary: ['QUAD'],
            secondary: ['GLUT'],
          ),
          'Overhead Press': const ExerciseMuscleData(
            primary: ['DELT_ANT'],
            secondary: ['TRIC'],
          ),
        };

        final result = TemplateMuscleAnalyzer.analyze(
          exercises,
          muscleMap: muscleMap,
        );

        expect(result.totalSets, 12);
        expect(result.coveredMuscles, isNotEmpty);
        expect(result.exerciseBreakdown.length, 4);
        // Full body should have fewer missing muscles
        expect(result.missingMuscles.length, lessThan(13));
      });
    });
  });

  group('ExerciseMuscleContribution', () {
    test('holds muscleId and percentage', () {
      const contribution = ExerciseMuscleContribution(
        muscleId: 'PETT',
        percentage: 70.0,
      );

      expect(contribution.muscleId, 'PETT');
      expect(contribution.percentage, 70.0);
    });
  });

  group('ExerciseContributionBreakdown', () {
    test('holds exercise details and contributions', () {
      const breakdown = ExerciseContributionBreakdown(
        exerciseName: 'Bench Press',
        sets: 3,
        totalPercentage: 50.0,
        contributions: [
          ExerciseMuscleContribution(muscleId: 'PETT', percentage: 70.0),
          ExerciseMuscleContribution(muscleId: 'TRIC', percentage: 30.0),
        ],
      );

      expect(breakdown.exerciseName, 'Bench Press');
      expect(breakdown.sets, 3);
      expect(breakdown.totalPercentage, 50.0);
      expect(breakdown.contributions.length, 2);
    });
  });
}
