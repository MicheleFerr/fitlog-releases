import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/template_coverage.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/template_aware_balance_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';

void main() {
  late TemplateAwareBalanceService service;

  setUp(() {
    service = TemplateAwareBalanceService();
  });

  // Helper: Create ExerciseTemplate
  ExerciseTemplate createExerciseTemplate({
    required String name,
    ExerciseCategory category = ExerciseCategory.chest,
    int setsCount = 3,
  }) {
    return ExerciseTemplate(
      exerciseId: 'ex-id-${name.hashCode}',
      exerciseName: name,
      category: category,
      sets: List.generate(
        setsCount,
        (i) => SetTemplate(setNumber: i + 1),
      ),
    );
  }

  // Helper: Create WorkoutTemplate
  WorkoutTemplate createWorkoutTemplate({
    required String name,
    required List<ExerciseTemplate> exercises,
  }) {
    return WorkoutTemplate(
      id: 'template-${name.hashCode}',
      name: name,
      description: 'Test template',
      exercises: exercises,
    );
  }

  // Helper: Create ExerciseMuscleData
  Map<String, ExerciseMuscleData> createMuscleMap(
      Map<String, List<String>> primaryMap,
      [Map<String, List<String>>? secondaryMap]) {
    return primaryMap.map((name, primary) => MapEntry(
          name.toLowerCase(),
          ExerciseMuscleData(
            primary: primary,
            secondary: secondaryMap?[name] ?? [],
          ),
        ));
  }

  // Helper: Create NeglectedMuscle
  NeglectedMuscle createNeglectedMuscle({
    required String name,
    required NeglectSeverity severity,
    double volumePercentage = 3.0,
    double priority = 7.0,
  }) {
    return NeglectedMuscle(
      muscleName: name,
      volumePercentage: volumePercentage,
      severity: severity,
      priority: priority,
    );
  }

  // Helper: Create ExerciseSuggestion
  ExerciseSuggestion createSuggestion({
    required String name,
    required String targetMuscle,
    ExerciseDifficulty difficulty = ExerciseDifficulty.intermediate,
  }) {
    return ExerciseSuggestion(
      exerciseId: 'ex-${name.hashCode}',
      exerciseName: name,
      targetMuscle: targetMuscle,
      priority: 7.0,
      difficulty: difficulty,
      equipment: 'Barbell',
      description: 'Test exercise',
      countingMode: ExerciseCountingMode.weighted,
      exerciseType: 'Compound',
    );
  }

  group('analyzeTemplateCoverage', () {
    test('should return empty result for no templates', () {
      final result = service.analyzeTemplateCoverage(
        templates: [],
        exerciseMuscleMap: {},
      );

      expect(result.hasData, isFalse);
      expect(result.muscleScores, isEmpty);
      expect(result.exerciseToTemplates, isEmpty);
    });

    test('should track muscle coverage from primary muscles', () {
      final templates = [
        createWorkoutTemplate(
          name: 'Push Day',
          exercises: [
            createExerciseTemplate(name: 'Bench Press', setsCount: 4),
            createExerciseTemplate(name: 'Shoulder Press', setsCount: 3),
          ],
        ),
      ];

      final muscleMap = createMuscleMap({
        'bench press': ['chest', 'triceps'],
        'shoulder press': ['shoulders', 'triceps'],
      });

      final result = service.analyzeTemplateCoverage(
        templates: templates,
        exerciseMuscleMap: muscleMap,
      );

      expect(result.hasCoverage('chest'), isTrue);
      expect(result.hasCoverage('shoulders'), isTrue);
      expect(result.hasCoverage('triceps'), isTrue);
      expect(result.hasCoverage('back'), isFalse);
    });

    test('should track exercises across multiple templates', () {
      final templates = [
        createWorkoutTemplate(
          name: 'Push Day',
          exercises: [
            createExerciseTemplate(name: 'Bench Press'),
          ],
        ),
        createWorkoutTemplate(
          name: 'Full Body',
          exercises: [
            createExerciseTemplate(name: 'Bench Press'),
            createExerciseTemplate(name: 'Squat'),
          ],
        ),
      ];

      final muscleMap = createMuscleMap({
        'bench press': ['chest'],
        'squat': ['legs'],
      });

      final result = service.analyzeTemplateCoverage(
        templates: templates,
        exerciseMuscleMap: muscleMap,
      );

      // Bench Press is in 2 templates
      final templatesForBench =
          result.getTemplatesForExercise('Bench Press');
      expect(templatesForBench.length, 2);
      expect(templatesForBench, contains('Push Day'));
      expect(templatesForBench, contains('Full Body'));

      // Chest is covered by 2 templates
      final chestCoverage = result.getCoverage('chest');
      expect(chestCoverage?.templateCount, 2);
    });

    test('should use category fallback when muscle map unavailable', () {
      final templates = [
        createWorkoutTemplate(
          name: 'Leg Day',
          exercises: [
            createExerciseTemplate(
              name: 'Unknown Leg Exercise',
              category: ExerciseCategory.legs,
            ),
          ],
        ),
      ];

      final result = service.analyzeTemplateCoverage(
        templates: templates,
        exerciseMuscleMap: {}, // Empty map
      );

      expect(result.hasCoverage('legs'), isTrue);
    });

    test('should be case-insensitive for exercise lookup', () {
      final templates = [
        createWorkoutTemplate(
          name: 'Workout',
          exercises: [
            createExerciseTemplate(name: 'BENCH PRESS'),
          ],
        ),
      ];

      final muscleMap = createMuscleMap({
        'bench press': ['chest'],
      });

      final result = service.analyzeTemplateCoverage(
        templates: templates,
        exerciseMuscleMap: muscleMap,
      );

      expect(result.hasCoverage('chest'), isTrue);
    });

    test('should calculate estimated weekly sets', () {
      final templates = [
        createWorkoutTemplate(
          name: 'Push Day',
          exercises: [
            createExerciseTemplate(name: 'Bench Press', setsCount: 4),
            createExerciseTemplate(name: 'Incline Press', setsCount: 3),
          ],
        ),
      ];

      final muscleMap = createMuscleMap({
        'bench press': ['chest'],
        'incline press': ['chest'],
      });

      final result = service.analyzeTemplateCoverage(
        templates: templates,
        exerciseMuscleMap: muscleMap,
      );

      final chestCoverage = result.getCoverage('chest');
      expect(chestCoverage?.estimatedWeeklySets, 7); // 4 + 3
    });

    test('should count secondary muscles at half weight', () {
      final templates = [
        createWorkoutTemplate(
          name: 'Push Day',
          exercises: [
            createExerciseTemplate(name: 'Bench Press', setsCount: 4),
          ],
        ),
      ];

      final muscleMap = {
        'bench press': const ExerciseMuscleData(
          primary: ['chest'],
          secondary: ['triceps'],
        ),
      };

      final result = service.analyzeTemplateCoverage(
        templates: templates,
        exerciseMuscleMap: muscleMap,
      );

      final chestCoverage = result.getCoverage('chest');
      final tricepsCoverage = result.getCoverage('triceps');

      expect(chestCoverage?.estimatedWeeklySets, 4); // Full credit
      expect(tricepsCoverage?.estimatedWeeklySets, 2); // Half credit (4/2)
    });
  });

  group('adjustNeglectedMuscles', () {
    test('should not adjust severity when not covered by templates', () {
      final neglected = <NeglectedMuscle>[
        createNeglectedMuscle(
          name: 'back',
          severity: NeglectSeverity.critical,
        ),
      ];

      final coverage = TemplateCoverageResult.empty();

      final adjusted = service.adjustNeglectedMuscles(
        neglected: neglected,
        coverage: coverage,
      );

      expect(adjusted.length, 1);
      expect(adjusted.first.adjustedSeverity, NeglectSeverity.critical);
      expect(adjusted.first.wasSeverityReduced, isFalse);
    });

    test('should reduce severity by 1 level for 2+ templates', () {
      final neglected = <NeglectedMuscle>[
        createNeglectedMuscle(
          name: 'chest',
          severity: NeglectSeverity.critical,
        ),
      ];

      const coverage = TemplateCoverageResult(
        muscleScores: {
          'chest': TemplateMuscleScore(
            muscleName: 'chest',
            templateCount: 2,
            totalExercises: 3,
            estimatedWeeklySets: 10,
            templateNames: ['Push Day', 'Full Body'],
          ),
        },
        exerciseToTemplates: {},
      );

      final adjusted = service.adjustNeglectedMuscles(
        neglected: neglected,
        coverage: coverage,
      );

      expect(adjusted.first.adjustedSeverity, NeglectSeverity.high);
      expect(adjusted.first.wasSeverityReduced, isTrue);
    });

    test('should reduce severity by 2 levels for 3+ templates', () {
      final neglected = <NeglectedMuscle>[
        createNeglectedMuscle(
          name: 'chest',
          severity: NeglectSeverity.critical,
        ),
      ];

      const coverage = TemplateCoverageResult(
        muscleScores: {
          'chest': TemplateMuscleScore(
            muscleName: 'chest',
            templateCount: 3,
            totalExercises: 5,
            estimatedWeeklySets: 15,
            templateNames: ['Push Day', 'Full Body A', 'Full Body B'],
          ),
        },
        exerciseToTemplates: {},
      );

      final adjusted = service.adjustNeglectedMuscles(
        neglected: neglected,
        coverage: coverage,
      );

      expect(adjusted.first.adjustedSeverity, NeglectSeverity.medium);
      expect(adjusted.first.wasSeverityReduced, isTrue);
    });

    test('should never reduce critical below medium', () {
      final neglected = <NeglectedMuscle>[
        createNeglectedMuscle(
          name: 'chest',
          severity: NeglectSeverity.critical,
        ),
      ];

      const coverage = TemplateCoverageResult(
        muscleScores: {
          'chest': TemplateMuscleScore(
            muscleName: 'chest',
            templateCount: 5, // Many templates
            totalExercises: 10,
            estimatedWeeklySets: 30,
            templateNames: ['A', 'B', 'C', 'D', 'E'],
          ),
        },
        exerciseToTemplates: {},
      );

      final adjusted = service.adjustNeglectedMuscles(
        neglected: neglected,
        coverage: coverage,
      );

      // Should stop at MEDIUM, not go to LOW
      expect(adjusted.first.adjustedSeverity, NeglectSeverity.medium);
    });

    test('should sort by adjusted priority (highest first)', () {
      final neglected = <NeglectedMuscle>[
        createNeglectedMuscle(
          name: 'back',
          severity: NeglectSeverity.medium,
          priority: 5.0,
        ),
        createNeglectedMuscle(
          name: 'chest',
          severity: NeglectSeverity.critical,
          priority: 9.0,
        ),
      ];

      final coverage = TemplateCoverageResult.empty();

      final adjusted = service.adjustNeglectedMuscles(
        neglected: neglected,
        coverage: coverage,
      );

      // Critical (chest) should be first
      expect(adjusted.first.original.muscleName, 'chest');
      expect(adjusted.last.original.muscleName, 'back');
    });
  });

  group('filterAlreadyPlanned', () {
    test('should remove suggestions already in templates', () {
      final suggestions = <ExerciseSuggestion>[
        createSuggestion(name: 'Bench Press', targetMuscle: 'chest'),
        createSuggestion(name: 'Lat Pulldown', targetMuscle: 'back'),
      ];

      const coverage = TemplateCoverageResult(
        muscleScores: {},
        exerciseToTemplates: {
          'bench press': ['Push Day'],
        },
      );

      final filtered = service.filterAlreadyPlanned(
        suggestions: suggestions,
        coverage: coverage,
        includeWithBadge: false,
      );

      expect(filtered.length, 1);
      expect(filtered.first.exerciseName, 'Lat Pulldown');
    });

    test('should keep planned exercises with badge when includeWithBadge is true', () {
      final suggestions = <ExerciseSuggestion>[
        createSuggestion(name: 'Bench Press', targetMuscle: 'chest'),
        createSuggestion(name: 'Lat Pulldown', targetMuscle: 'back'),
      ];

      const coverage = TemplateCoverageResult(
        muscleScores: {},
        exerciseToTemplates: {
          'bench press': ['Push Day'],
        },
      );

      final filtered = service.filterAlreadyPlanned(
        suggestions: suggestions,
        coverage: coverage,
        includeWithBadge: true,
      );

      expect(filtered.length, 2);

      final benchFiltered =
          filtered.firstWhere((f) => f.exerciseName == 'Bench Press');
      expect(benchFiltered.isInTemplate, isTrue);
      expect(benchFiltered.templateNames, contains('Push Day'));

      final latFiltered =
          filtered.firstWhere((f) => f.exerciseName == 'Lat Pulldown');
      expect(latFiltered.isInTemplate, isFalse);
    });
  });

  group('getCoverageSummary', () {
    test('should return balanced message when no neglected muscles', () {
      final summary = service.getCoverageSummary(
        neglected: [],
        coverage: TemplateCoverageResult.empty(),
      );

      expect(summary, 'All muscles are well balanced');
    });

    test('should return needs attention when no coverage', () {
      final neglected = <NeglectedMuscle>[
        createNeglectedMuscle(
          name: 'back',
          severity: NeglectSeverity.high,
        ),
      ];

      final summary = service.getCoverageSummary(
        neglected: neglected,
        coverage: TemplateCoverageResult.empty(),
      );

      expect(summary, contains('need attention'));
    });

    test('should return all covered message when fully covered', () {
      final neglected = <NeglectedMuscle>[
        createNeglectedMuscle(
          name: 'chest',
          severity: NeglectSeverity.medium,
        ),
      ];

      const coverage = TemplateCoverageResult(
        muscleScores: {
          'chest': TemplateMuscleScore(
            muscleName: 'chest',
            templateCount: 2,
            totalExercises: 3,
            estimatedWeeklySets: 10,
            templateNames: ['Push Day', 'Full Body'],
          ),
        },
        exerciseToTemplates: {},
      );

      final summary = service.getCoverageSummary(
        neglected: neglected,
        coverage: coverage,
      );

      expect(summary, contains('covered by your templates'));
    });

    test('should return partial coverage message', () {
      final neglected = <NeglectedMuscle>[
        createNeglectedMuscle(
          name: 'chest',
          severity: NeglectSeverity.medium,
        ),
        createNeglectedMuscle(
          name: 'back',
          severity: NeglectSeverity.high,
        ),
      ];

      const coverage = TemplateCoverageResult(
        muscleScores: {
          'chest': TemplateMuscleScore(
            muscleName: 'chest',
            templateCount: 1,
            totalExercises: 2,
            estimatedWeeklySets: 6,
            templateNames: ['Push Day'],
          ),
        },
        exerciseToTemplates: {},
      );

      final summary = service.getCoverageSummary(
        neglected: neglected,
        coverage: coverage,
      );

      expect(summary, contains('not in templates'));
    });
  });

  group('TemplateCoverageResult', () {
    test('isExercisePlanned should be case-insensitive', () {
      const coverage = TemplateCoverageResult(
        muscleScores: {},
        exerciseToTemplates: {
          'bench press': ['Push Day'],
        },
      );

      expect(coverage.isExercisePlanned('bench press'), isTrue);
      expect(coverage.isExercisePlanned('Bench Press'), isTrue);
      expect(coverage.isExercisePlanned('BENCH PRESS'), isTrue);
      expect(coverage.isExercisePlanned('lat pulldown'), isFalse);
    });
  });

  group('TemplateMuscleScore', () {
    test('should calculate coverage score correctly', () {
      // High coverage: 3 templates, 5 exercises
      const highScore = TemplateMuscleScore(
        muscleName: 'chest',
        templateCount: 3,
        totalExercises: 5,
        estimatedWeeklySets: 15,
        templateNames: ['A', 'B', 'C'],
      );

      // Coverage should be high (capped at 1.0)
      expect(highScore.coverageScore, closeTo(1.0, 0.1));
      expect(highScore.isWellCovered, isTrue);

      // Low coverage: 1 template, 1 exercise
      const lowScore = TemplateMuscleScore(
        muscleName: 'back',
        templateCount: 1,
        totalExercises: 1,
        estimatedWeeklySets: 3,
        templateNames: ['A'],
      );

      // Coverage should be lower
      expect(lowScore.coverageScore, lessThan(0.5));
      expect(lowScore.isWellCovered, isFalse);
    });
  });

  group('AdjustedNeglectedMuscle', () {
    test('should provide covering templates info', () {
      final neglected = createNeglectedMuscle(
        name: 'chest',
        severity: NeglectSeverity.high,
      );

      const coverage = TemplateMuscleScore(
        muscleName: 'chest',
        templateCount: 2,
        totalExercises: 4,
        estimatedWeeklySets: 12,
        templateNames: ['Push Day', 'Full Body'],
      );

      final adjusted = AdjustedNeglectedMuscle(
        original: neglected,
        coverage: coverage,
      );

      expect(adjusted.coveringTemplates, ['Push Day', 'Full Body']);
      expect(adjusted.plannedExerciseCount, 4);
      expect(adjusted.hasPlannedExercises, isTrue);
    });
  });
}
