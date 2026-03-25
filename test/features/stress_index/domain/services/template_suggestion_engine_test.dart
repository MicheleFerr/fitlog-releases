/// Template Suggestion Engine - Comprehensive Unit Tests
///
/// Covers all 6 scoring factors, edge cases, and integration paths.
/// Uses manual fakes only (no mockito/mocktail).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_readiness_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/template_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/weekly_volume_tracker.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart'
    as workout;

// =============================================================================
// TEST HELPERS / FAKES
// =============================================================================

/// Minimal ExerciseDefinition factory
ExerciseDefinition makeExerciseDef({
  required String id,
  required List<String> focus,
  List<String> secondary = const [],
}) {
  return ExerciseDefinition(
    id: id,
    nome: id,
    focus: focus,
    muscoliSecondari: secondary,
    difficolta: 'Intermedio',
    tipoEsercizio: 'Compound',
    attrezzatura: 'Bilanciere',
    patternMovimento: 'Push',
    rangeRipetizioni: '8-12',
  );
}

/// Minimal CommunityWorkoutTemplate factory
CommunityWorkoutTemplate makeTemplate({
  required String id,
  required List<workout.Exercise> exercises,
  String name = 'Test Template',
}) {
  return CommunityWorkoutTemplate(
    id: id,
    userId: 'user-1',
    name: name,
    exercises: exercises,
    createdAt: DateTime(2024, 1, 1),
  );
}

/// Minimal Exercise instance factory
workout.Exercise makeExercise({
  required String id,
  String? name,
  int setCount = 3,
}) {
  final sets = List.generate(
    setCount,
    (i) => workout.ExerciseSet(setNumber: i + 1, weight: 80.0, reps: 10),
  );
  return workout.Exercise(
    id: id,
    name: name ?? id,
    type: workout.ExerciseType.single,
    category: workout.ExerciseCategory.chest,
    sets: sets,
  );
}

/// MuscleReadinessData factory
MuscleReadinessData makeReadiness({
  required String muscleId,
  required double recoveryPercent,
}) {
  return MuscleReadinessData(
    muscleId: muscleId,
    displayName: muscleId,
    recoveryPercent: recoveryPercent,
    hoursSinceWorkout: 48,
  );
}

/// WorkoutHistoryDetail factory
WorkoutHistoryDetail makeHistory({
  required String id,
  required DateTime completedAt,
  String? templateId,
  List<ExerciseHistoryDetail> exercises = const [],
}) {
  return WorkoutHistoryDetail(
    id: id,
    userId: 'user-1',
    name: 'Workout $id',
    description: '',
    createdAt: completedAt,
    startedAt: completedAt,
    completedAt: completedAt,
    updatedAt: completedAt,
    duration: const Duration(hours: 1),
    exercises: exercises,
    metadata: {},
    templateId: templateId,
  );
}

/// ExerciseHistoryDetail factory (minimal)
ExerciseHistoryDetail makeExerciseHistory({
  required String id,
  required String name,
  int setCount = 3,
}) {
  final sets = List.generate(
    setCount,
    (i) => SetHistoryDetail(setNumber: i + 1, weight: 80.0, reps: 10, rpe: 7),
  );
  return ExerciseHistoryDetail(
    id: id,
    name: name,
    category: 'chest',
    sets: sets,
    exerciseData: {},
  );
}

/// Minimal WeeklyVolumeTracker with custom sets
///
/// Uses the internal factory by constructing from empty history but
/// we need to override. Since WeeklyVolumeTracker._ is private,
/// we build a tracker from real history data for non-zero volumes.
/// For zero volumes, just use WeeklyVolumeTracker.fromHistory([], {}).
WeeklyVolumeTracker emptyTracker() => WeeklyVolumeTracker.fromHistory([], {});

// =============================================================================
// MAIN TEST SUITE
// =============================================================================

void main() {
  const engine = TemplateSuggestionEngine();

  // ---------------------------------------------------------------------------
  // FACTOR 1: RECOVERY SCORE
  // ---------------------------------------------------------------------------

  group('recoveryScore', () {
    test('returns 50.0 neutral when template has no exercises (empty DB)', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'unknown-exercise')],
      );

      final score = engine.recoveryScore(template, {}, {});

      expect(score, equals(50.0));
    });

    test('returns 50.0 when primary muscles list is empty (no DB match)', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'ex-no-db-match')],
      );
      final score = engine.recoveryScore(template, {}, {});
      expect(score, equals(50.0));
    });

    test(
      'optimal window 70-90%: primary fully at 80% returns 100.0 * 0.7 + secondary portion',
      () {
        // Primary muscle PETT at 80% recovery -> supercompensation curve -> 100
        // No secondary muscles in DB -> secondary defaults to 50
        final template = makeTemplate(
          id: 'tmpl1',
          exercises: [makeExercise(id: 'bench', name: 'bench')],
        );
        final exerciseDB = {
          'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
        };
        final recovery = {
          'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 80.0),
        };

        final score = engine.recoveryScore(template, recovery, exerciseDB);

        // primaryAvg = 100.0, secondaryAvg = 50.0 (default)
        // result = 100 * 0.7 + 50 * 0.3 = 70 + 15 = 85.0
        expect(score, closeTo(85.0, 0.01));
      },
    );

    test(
      'recovery at 90%: primary PETT at 90% -> supercompensationCurve returns 95',
      () {
        final template = makeTemplate(
          id: 'tmpl1',
          exercises: [makeExercise(id: 'bench', name: 'bench')],
        );
        final exerciseDB = {
          'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
        };
        final recovery = {
          'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 90.0),
        };

        final score = engine.recoveryScore(template, recovery, exerciseDB);

        // curve(90) = 95, secondaryAvg = 50
        // 95 * 0.7 + 50 * 0.3 = 66.5 + 15 = 81.5
        expect(score, closeTo(81.5, 0.01));
      },
    );

    test('recovery above 90% returns 95.0 from curve', () {
      // 100% recovery -> curve returns 95
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      final recovery = {
        'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 100.0),
      };

      final score = engine.recoveryScore(template, recovery, exerciseDB);

      // curve(100) = 95, secondary = 50
      // 95 * 0.7 + 50 * 0.3 = 81.5
      expect(score, closeTo(81.5, 0.01));
    });

    test('recovery at 60%: partial recovery returns 70 from curve', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      final recovery = {
        'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 60.0),
      };

      final score = engine.recoveryScore(template, recovery, exerciseDB);

      // curve(60) = 70, secondary = 50
      // 70 * 0.7 + 50 * 0.3 = 49 + 15 = 64.0
      expect(score, closeTo(64.0, 0.01));
    });

    test('recovery at 40%: fatigued returns 40 from curve', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      final recovery = {
        'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 40.0),
      };

      final score = engine.recoveryScore(template, recovery, exerciseDB);

      // curve(40) = 40, secondary = 50
      // 40 * 0.7 + 50 * 0.3 = 28 + 15 = 43.0
      expect(score, closeTo(43.0, 0.01));
    });

    test('acute fatigue (<30%) returns 10 from curve', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      final recovery = {
        'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 10.0),
      };

      final score = engine.recoveryScore(template, recovery, exerciseDB);

      // curve(10) = 10, secondary = 50
      // 10 * 0.7 + 50 * 0.3 = 7 + 15 = 22.0
      expect(score, closeTo(22.0, 0.01));
    });

    test('missing recovery data defaults to 100% (supercompensated)', () {
      // No recovery data for PETT -> defaults to 100.0 -> curve = 95
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };

      final score = engine.recoveryScore(template, {}, exerciseDB);

      // curve(100) = 95, secondary empty -> 50
      // 95 * 0.7 + 50 * 0.3 = 81.5
      expect(score, closeTo(81.5, 0.01));
    });

    test('secondary muscles are weighted at 30%', () {
      // primary PETT at 70% -> 100, secondary LAT at 40% -> 40
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(
          id: 'bench',
          focus: ['PETT'],
          secondary: ['LAT'],
        ),
      };
      final recovery = {
        'PETT': makeReadiness(
          muscleId: 'PETT',
          recoveryPercent: 75.0,
        ), // curve -> 100
        'LAT': makeReadiness(
          muscleId: 'LAT',
          recoveryPercent: 40.0,
        ), // curve -> 40
      };

      final score = engine.recoveryScore(template, recovery, exerciseDB);

      // 100 * 0.7 + 40 * 0.3 = 70 + 12 = 82.0
      expect(score, closeTo(82.0, 0.01));
    });

    test('exercise looked up by name when not found by id', () {
      // Exercise id does not match DB, but name does
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'UNKNOWN_ID', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      final recovery = {
        'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 75.0),
      };

      final score = engine.recoveryScore(template, recovery, exerciseDB);

      // Should still find by name; curve(75) = 100
      expect(score, closeTo(85.0, 0.01));
    });
  });

  // ---------------------------------------------------------------------------
  // FACTOR 2: VOLUME NEED SCORE
  // ---------------------------------------------------------------------------

  group('volumeNeedScore', () {
    test('returns 0.0 when no primary muscles in template', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'no-db-match')],
      );

      final score = engine.volumeNeedScore(template, emptyTracker(), {});

      expect(score, equals(0.0));
    });

    test('under MEV: returns near 100 (urgent)', () {
      // PETT: MEV=10, currently 0 sets -> deficit = 1 - (0/10) = 1.0 -> 100 points
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };

      final score = engine.volumeNeedScore(
        template,
        emptyTracker(),
        exerciseDB,
      );

      expect(score, closeTo(100.0, 0.01));
    });

    test('above MAV: returns 0.0 (risk overtraining)', () {
      // PETT: MAV=20, we simulate 25 sets (above MAV)
      // We need a tracker with actual data; build from real history
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };

      // Build tracker with 25 sets for PETT using real history
      // Each history exercise set = 1 set; we need 25 sets
      final historyExercises = [
        makeExerciseHistory(id: 'bench', name: 'bench', setCount: 25),
      ];
      final historyEntry = makeHistory(
        id: 'w1',
        completedAt: DateTime.now(),
        exercises: historyExercises,
      );
      final tracker = WeeklyVolumeTracker.fromHistory([
        historyEntry,
      ], exerciseDB);

      final score = engine.volumeNeedScore(template, tracker, exerciseDB);

      expect(score, equals(0.0));
    });

    test('between MEV and MAV: returns 50 * (1 - position/range)', () {
      // PETT: MEV=10, MAV=20. At 15 sets: position=5, range=10 -> 50*(1-0.5)=25
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };

      final historyExercises = [
        makeExerciseHistory(id: 'bench', name: 'bench', setCount: 15),
      ];
      final historyEntry = makeHistory(
        id: 'w1',
        completedAt: DateTime.now(),
        exercises: historyExercises,
      );
      final tracker = WeeklyVolumeTracker.fromHistory([
        historyEntry,
      ], exerciseDB);

      final score = engine.volumeNeedScore(template, tracker, exerciseDB);

      expect(score, closeTo(25.0, 0.5));
    });

    test('at MEV exactly: returns 50.0 * 1 = 50.0', () {
      // PETT: MEV=10, at exactly MEV -> position=0 -> 50*(1-0/10)=50
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };

      final historyExercises = [
        makeExerciseHistory(id: 'bench', name: 'bench', setCount: 10),
      ];
      final historyEntry = makeHistory(
        id: 'w1',
        completedAt: DateTime.now(),
        exercises: historyExercises,
      );
      final tracker = WeeklyVolumeTracker.fromHistory([
        historyEntry,
      ], exerciseDB);

      final score = engine.volumeNeedScore(template, tracker, exerciseDB);

      expect(score, closeTo(50.0, 0.5));
    });

    test('uses defaultVolumeLandmarks for unknown muscle', () {
      // Use a muscle not in volumeLandmarks
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'weird', name: 'weird')],
      );
      final exerciseDB = {
        'weird': makeExerciseDef(id: 'weird', focus: ['UNKNOWN_MUSCLE_XYZ']),
      };

      // Default MEV=8, 0 sets -> score = 100
      final score = engine.volumeNeedScore(
        template,
        emptyTracker(),
        exerciseDB,
      );

      expect(score, closeTo(100.0, 0.01));
    });

    test('result is clamped between 0 and 100', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };

      final score = engine.volumeNeedScore(
        template,
        emptyTracker(),
        exerciseDB,
      );

      expect(score, inInclusiveRange(0.0, 100.0));
    });
  });

  // ---------------------------------------------------------------------------
  // FACTOR 3: NEGLECTED SCORE
  // ---------------------------------------------------------------------------

  group('neglectedScore', () {
    test('returns 50.0 neutral when neglected list is empty', () {
      final template = makeTemplate(id: 'tmpl1', exercises: []);

      final score = engine.neglectedScore(template, [], {});

      expect(score, equals(50.0));
    });

    test('returns 0.0 when template does not cover any neglected muscle', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      // Neglected muscle is 'hamstrings', but template only has 'PETT'
      final neglected = [
        NeglectedMuscle(
          muscleName: 'hamstrings',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 8.0,
        ),
      ];

      final score = engine.neglectedScore(template, neglected, exerciseDB);

      expect(score, equals(0.0));
    });

    test('covers neglected chest muscle -> returns priority * 10', () {
      // Template covers PETT, neglected 'chest' maps to PETT
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      final neglected = [
        NeglectedMuscle(
          muscleName: 'chest',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 7.0,
        ),
      ];

      final score = engine.neglectedScore(template, neglected, exerciseDB);

      // priority 7 * 10 = 70 / 1 = 70
      expect(score, closeTo(70.0, 0.01));
    });

    test('covers neglected back muscle (maps LAT) -> correct score', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'row', name: 'row')],
      );
      final exerciseDB = {
        'row': makeExerciseDef(id: 'row', focus: ['LAT']),
      };
      final neglected = [
        NeglectedMuscle(
          muscleName: 'back',
          volumePercentage: 2.0,
          severity: NeglectSeverity.high,
          priority: 5.0,
        ),
      ];

      final score = engine.neglectedScore(template, neglected, exerciseDB);

      // priority 5 * 10 = 50 / 1 = 50
      expect(score, closeTo(50.0, 0.01));
    });

    test(
      'multiple neglected muscles, only some covered -> averages covered only',
      () {
        // Template covers PETT (chest) and BICI (biceps)
        // Neglected: chest (priority=8), hamstrings (priority=9) - hamstrings not covered
        final template = makeTemplate(
          id: 'tmpl1',
          exercises: [
            makeExercise(id: 'bench', name: 'bench'),
            makeExercise(id: 'curl', name: 'curl'),
          ],
        );
        final exerciseDB = {
          'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
          'curl': makeExerciseDef(id: 'curl', focus: ['BICI']),
        };
        final neglected = [
          NeglectedMuscle(
            muscleName: 'chest',
            volumePercentage: 1.0,
            severity: NeglectSeverity.critical,
            priority: 8.0,
          ),
          NeglectedMuscle(
            muscleName: 'biceps',
            volumePercentage: 1.0,
            severity: NeglectSeverity.high,
            priority: 6.0,
          ),
          NeglectedMuscle(
            muscleName: 'hamstrings',
            volumePercentage: 1.0,
            severity: NeglectSeverity.critical,
            priority: 9.0, // Not covered
          ),
        ];

        final score = engine.neglectedScore(template, neglected, exerciseDB);

        // Covered: chest (80) + biceps (60) = 140, coveredCount=2 -> 70
        expect(score, closeTo(70.0, 0.01));
      },
    );

    test('score is clamped to 100.0 max', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      // Priority=10 -> 100 points, still clamped
      final neglected = [
        NeglectedMuscle(
          muscleName: 'chest',
          volumePercentage: 0.5,
          severity: NeglectSeverity.critical,
          priority: 10.0,
        ),
      ];

      final score = engine.neglectedScore(template, neglected, exerciseDB);

      expect(score, equals(100.0));
    });

    test('covers neglected muscle via secondary muscles', () {
      // Template has bench where TRIC is secondary, biceps is neglected
      // 'triceps' maps to TRIC
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(
          id: 'bench',
          focus: ['PETT'],
          secondary: ['TRIC'],
        ),
      };
      final neglected = [
        NeglectedMuscle(
          muscleName: 'triceps',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 5.0,
        ),
      ];

      final score = engine.neglectedScore(template, neglected, exerciseDB);

      // TRIC covered via secondary: 5 * 10 = 50
      expect(score, closeTo(50.0, 0.01));
    });

    test('muscleName lookup is case insensitive (lowercased)', () {
      // Neglected muscleName 'Chest' (capitalized) should still match 'chest'
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      final neglected = [
        NeglectedMuscle(
          muscleName: 'Chest', // capitalized
          volumePercentage: 1.0,
          severity: NeglectSeverity.medium,
          priority: 4.0,
        ),
      ];

      final score = engine.neglectedScore(template, neglected, exerciseDB);

      // muscleName is lowercased in lookup: 'Chest'.toLowerCase() = 'chest' -> PETT -> covered
      expect(score, closeTo(40.0, 0.01));
    });

    test('all known muscle name mappings produce correct abbreviations', () {
      // Test a subset of the muscle name map
      final muscleToAbbr = {
        'chest': 'PETT',
        'back': 'LAT',
        'shoulders': 'DELT',
        'biceps': 'BICI',
        'triceps': 'TRIC',
        'quads': 'QUAD',
        'hamstrings': 'FEMO',
        'glutes': 'GLUT',
        'calves': 'POLP',
        'abs': 'CORE',
        'lower_back': 'LOMB',
        'forearms': 'AVA',
        'rear_delts': 'DELT_POST',
      };

      for (final entry in muscleToAbbr.entries) {
        final template = makeTemplate(
          id: 'tmpl-${entry.key}',
          exercises: [makeExercise(id: entry.value, name: entry.value)],
        );
        final exerciseDB = {
          entry.value: makeExerciseDef(id: entry.value, focus: [entry.value]),
        };
        final neglected = [
          NeglectedMuscle(
            muscleName: entry.key,
            volumePercentage: 1.0,
            severity: NeglectSeverity.critical,
            priority: 5.0,
          ),
        ];

        final score = engine.neglectedScore(template, neglected, exerciseDB);

        expect(
          score,
          closeTo(50.0, 0.01),
          reason: '${entry.key} -> ${entry.value} mapping failed',
        );
      }
    });
  });

  // ---------------------------------------------------------------------------
  // FACTOR 4: PATTERN SCORE
  // ---------------------------------------------------------------------------

  group('patternScore', () {
    test('returns 50.0 neutral with empty history', () {
      final template = makeTemplate(id: 'tmpl1', exercises: []);

      final score = engine.patternScore(template, []);

      expect(score, equals(50.0));
    });

    test('returns 50.0 when no workouts on this weekday', () {
      // History has entries but none on today's weekday within 60 days
      // Use a date 70 days ago so it's outside the 60-day window
      final template = makeTemplate(id: 'tmpl1', exercises: []);
      final oldDate = DateTime.now().subtract(const Duration(days: 70));
      final history = [
        makeHistory(id: 'w1', completedAt: oldDate, templateId: 'tmpl1'),
      ];

      final score = engine.patternScore(template, history);

      expect(score, equals(50.0));
    });

    test(
      'returns 100.0 when all recent same-weekday workouts used this template',
      () {
        // Create history entries on today's weekday within 60 days
        final today = DateTime.now();
        // Go back to find last week same weekday
        final lastWeekSameDay = today.subtract(const Duration(days: 7));
        final twoWeeksAgoSameDay = today.subtract(const Duration(days: 14));

        final template = makeTemplate(id: 'tmpl1', exercises: []);
        final history = [
          makeHistory(
            id: 'w1',
            completedAt: lastWeekSameDay,
            templateId: 'tmpl1',
          ),
          makeHistory(
            id: 'w2',
            completedAt: twoWeeksAgoSameDay,
            templateId: 'tmpl1',
          ),
        ];

        final score = engine.patternScore(template, history);

        expect(score, closeTo(100.0, 0.01));
      },
    );

    test('returns 0.0 when no workouts on this weekday used this template', () {
      final today = DateTime.now();
      final lastWeekSameDay = today.subtract(const Duration(days: 7));

      final template = makeTemplate(id: 'target-template', exercises: []);
      final history = [
        makeHistory(
          id: 'w1',
          completedAt: lastWeekSameDay,
          templateId: 'other-template',
        ),
      ];

      final score = engine.patternScore(template, history);

      expect(score, closeTo(0.0, 0.01));
    });

    test('returns fractional score when partial match', () {
      // 1 out of 2 same-weekday workouts used this template
      final today = DateTime.now();
      final lastWeek = today.subtract(const Duration(days: 7));
      final twoWeeksAgo = today.subtract(const Duration(days: 14));

      final template = makeTemplate(id: 'tmpl1', exercises: []);
      final history = [
        makeHistory(id: 'w1', completedAt: lastWeek, templateId: 'tmpl1'),
        makeHistory(id: 'w2', completedAt: twoWeeksAgo, templateId: 'other'),
      ];

      final score = engine.patternScore(template, history);

      // 1/2 = 50%
      expect(score, closeTo(50.0, 0.01));
    });

    test('ignores workouts outside the 60-day window', () {
      final today = DateTime.now();
      final within60Days = today.subtract(const Duration(days: 7));
      final outside60Days = today.subtract(const Duration(days: 65));

      final template = makeTemplate(id: 'tmpl1', exercises: []);
      final history = [
        makeHistory(id: 'w1', completedAt: within60Days, templateId: 'tmpl1'),
        makeHistory(id: 'w2', completedAt: outside60Days, templateId: 'other'),
      ];

      final score = engine.patternScore(template, history);

      // Only 1 workout within window (w1), and it uses tmpl1 -> 100%
      expect(score, closeTo(100.0, 0.01));
    });

    test('score is clamped between 0 and 100', () {
      final template = makeTemplate(id: 'tmpl1', exercises: []);

      final score = engine.patternScore(template, []);

      expect(score, inInclusiveRange(0.0, 100.0));
    });
  });

  // ---------------------------------------------------------------------------
  // FACTOR 5: VARIETY SCORE
  // ---------------------------------------------------------------------------

  group('varietyScore', () {
    test('returns 100.0 when history is empty', () {
      final template = makeTemplate(id: 'tmpl1', exercises: []);

      final score = engine.varietyScore(template, [], {});

      expect(score, equals(100.0));
    });

    test('returns 10.0 when last workout used exact same template', () {
      final template = makeTemplate(id: 'same-template', exercises: []);
      final history = [
        makeHistory(
          id: 'w1',
          completedAt: DateTime.now(),
          templateId: 'same-template',
        ),
      ];

      final score = engine.varietyScore(template, history, {});

      expect(score, equals(10.0));
    });

    test(
      'returns 100.0 when last workout used different template and no muscle overlap',
      () {
        final template = makeTemplate(
          id: 'leg-day',
          exercises: [makeExercise(id: 'squat', name: 'squat')],
        );
        final exerciseDB = {
          'squat': makeExerciseDef(id: 'squat', focus: ['QUAD']),
          'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
        };
        final history = [
          makeHistory(
            id: 'w1',
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
            templateId: 'push-day',
            exercises: [makeExerciseHistory(id: 'bench', name: 'bench')],
          ),
        ];

        final score = engine.varietyScore(template, history, exerciseDB);

        // No overlap between QUAD and PETT -> 100.0
        expect(score, closeTo(100.0, 0.01));
      },
    );

    test('returns scaled score based on muscle overlap', () {
      // Template: PETT + LAT
      // Last workout: PETT only
      // Overlap = 1/2 = 0.5 -> (1-0.5)*100 = 50
      final template = makeTemplate(
        id: 'push-pull',
        exercises: [
          makeExercise(id: 'bench', name: 'bench'),
          makeExercise(id: 'row', name: 'row'),
        ],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
        'row': makeExerciseDef(id: 'row', focus: ['LAT']),
      };
      final history = [
        makeHistory(
          id: 'w1',
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
          templateId: 'other-template',
          exercises: [makeExerciseHistory(id: 'bench', name: 'bench')],
        ),
      ];

      final score = engine.varietyScore(template, history, exerciseDB);

      // PETT overlaps, LAT does not. Overlap = 1, thisMuscles.length = 2
      // overlapRatio = 0.5 -> (1 - 0.5) * 100 = 50
      expect(score, closeTo(50.0, 0.01));
    });

    test('returns 100.0 when last workout has no muscles in DB', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      final history = [
        makeHistory(
          id: 'w1',
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
          templateId: 'other',
          // exercises have no DB match
          exercises: [makeExerciseHistory(id: 'unknown', name: 'unknown')],
        ),
      ];

      final score = engine.varietyScore(template, history, exerciseDB);

      // lastMuscles is empty -> 100.0
      expect(score, closeTo(100.0, 0.01));
    });

    test('returns 100.0 when template has no muscles in DB', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'no-db', name: 'no-db')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      final history = [
        makeHistory(
          id: 'w1',
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
          templateId: 'other',
          exercises: [makeExerciseHistory(id: 'bench', name: 'bench')],
        ),
      ];

      final score = engine.varietyScore(template, history, exerciseDB);

      // thisMuscles is empty -> 100.0
      expect(score, closeTo(100.0, 0.01));
    });

    test('uses most recent workout (sorted by completedAt)', () {
      // Older workout: PETT (same as template)
      // Newer workout: LAT (different from template)
      // Should use newer, giving no overlap -> 100
      final template = makeTemplate(
        id: 'chest-day',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
        'row': makeExerciseDef(id: 'row', focus: ['LAT']),
      };
      final older = makeHistory(
        id: 'w1',
        completedAt: DateTime.now().subtract(const Duration(days: 3)),
        templateId: 'other',
        exercises: [makeExerciseHistory(id: 'bench', name: 'bench')],
      );
      final newer = makeHistory(
        id: 'w2',
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        templateId: 'other',
        exercises: [makeExerciseHistory(id: 'row', name: 'row')],
      );
      final history = [older, newer]; // Not sorted - should sort internally

      final score = engine.varietyScore(template, history, exerciseDB);

      // Most recent is 'row' (LAT), no overlap with PETT -> 100
      expect(score, closeTo(100.0, 0.01));
    });

    test('score is clamped between 0 and 100', () {
      final template = makeTemplate(id: 'same', exercises: []);
      final history = [
        makeHistory(id: 'w1', completedAt: DateTime.now(), templateId: 'same'),
      ];

      final score = engine.varietyScore(template, history, {});

      expect(score, inInclusiveRange(0.0, 100.0));
    });
  });

  // ---------------------------------------------------------------------------
  // FACTOR 6: BALANCE SCORE
  // ---------------------------------------------------------------------------

  group('balanceScore', () {
    test('returns 50.0 neutral when no antagonist pairs have been trained', () {
      final template = makeTemplate(id: 'tmpl1', exercises: []);

      final score = engine.balanceScore(template, emptyTracker(), {});

      expect(score, equals(50.0));
    });

    test('perfect balance (equal volumes) returns 100.0', () {
      // PETT and LAT both at equal sets (10 each)
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
        'row': makeExerciseDef(id: 'row', focus: ['LAT']),
      };
      final exercises = [
        makeExerciseHistory(id: 'bench', name: 'bench', setCount: 10),
        makeExerciseHistory(id: 'row', name: 'row', setCount: 10),
      ];
      final history = [
        makeHistory(
          id: 'w1',
          completedAt: DateTime.now(),
          exercises: exercises,
        ),
      ];
      final tracker = WeeklyVolumeTracker.fromHistory(history, exerciseDB);
      final template = makeTemplate(id: 'tmpl1', exercises: []);

      final score = engine.balanceScore(template, tracker, exerciseDB);

      // PETT:LAT = 10:10 -> ratio=1.0, deviation=0 -> avg=0/3... wait, only checked pairs
      // with both muscles trained. PETT/LAT trained, QUAD/FEMO=0 skipped, BICI/TRIC=0 skipped
      // pairsChecked=1, avgImbalance=0 -> (1 - 0/2)*100 = 100
      expect(score, closeTo(100.0, 0.01));
    });

    test('severe imbalance (3:1 ratio) returns low score', () {
      // PETT=30, LAT=10 -> ratio=3.0, deviation=2.0
      // avgImbalance=2.0, score = (1 - 2/2)*100 = 0
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
        'row': makeExerciseDef(id: 'row', focus: ['LAT']),
      };
      final exercises = [
        makeExerciseHistory(id: 'bench', name: 'bench', setCount: 30),
        makeExerciseHistory(id: 'row', name: 'row', setCount: 10),
      ];
      final history = [
        makeHistory(
          id: 'w1',
          completedAt: DateTime.now(),
          exercises: exercises,
        ),
      ];
      final tracker = WeeklyVolumeTracker.fromHistory(history, exerciseDB);
      final template = makeTemplate(id: 'tmpl1', exercises: []);

      final score = engine.balanceScore(template, tracker, exerciseDB);

      expect(score, closeTo(0.0, 0.1));
    });

    test('2:1 ratio imbalance returns 50.0', () {
      // PETT=20, LAT=10 -> ratio=2.0, deviation=1.0
      // avgImbalance=1.0, score = (1 - 1/2)*100 = 50
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
        'row': makeExerciseDef(id: 'row', focus: ['LAT']),
      };
      final exercises = [
        makeExerciseHistory(id: 'bench', name: 'bench', setCount: 20),
        makeExerciseHistory(id: 'row', name: 'row', setCount: 10),
      ];
      final history = [
        makeHistory(
          id: 'w1',
          completedAt: DateTime.now(),
          exercises: exercises,
        ),
      ];
      final tracker = WeeklyVolumeTracker.fromHistory(history, exerciseDB);
      final template = makeTemplate(id: 'tmpl1', exercises: []);

      final score = engine.balanceScore(template, tracker, exerciseDB);

      expect(score, closeTo(50.0, 0.5));
    });

    test('only one side of a pair trained: pair is still counted', () {
      // PETT=10, LAT=0 -> volA=10, volB=0 -> skip? No: volA+volB=10 != 0, so not skipped
      // ratio = 10 / max(0,1) = 10/1 = 10, deviation = |10-1| = 9
      // score = (1 - 9/2)*100 = (1-4.5)*100 = -350 -> clamped to 0
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      final exercises = [
        makeExerciseHistory(id: 'bench', name: 'bench', setCount: 10),
      ];
      final history = [
        makeHistory(
          id: 'w1',
          completedAt: DateTime.now(),
          exercises: exercises,
        ),
      ];
      final tracker = WeeklyVolumeTracker.fromHistory(history, exerciseDB);
      final template = makeTemplate(id: 'tmpl1', exercises: []);

      final score = engine.balanceScore(template, tracker, exerciseDB);

      expect(score, equals(0.0)); // clamped
    });

    test('score is clamped between 0 and 100', () {
      final template = makeTemplate(id: 'tmpl1', exercises: []);

      final score = engine.balanceScore(template, emptyTracker(), {});

      expect(score, inInclusiveRange(0.0, 100.0));
    });
  });

  // ---------------------------------------------------------------------------
  // COMPOSITE SCORE: computeScore
  // ---------------------------------------------------------------------------

  group('computeScore', () {
    test('returns value between 0 and 100', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      final ctx = SuggestionContext(
        muscleRecovery: {},
        weeklyVolumes: emptyTracker(),
        neglectedMuscles: [],
        history: [],
      );

      final score = engine.computeScore(template, ctx, exerciseDB);

      expect(score, inInclusiveRange(0.0, 100.0));
    });

    test('returns weighted sum of all 6 factors', () {
      // Empty context -> all factors return neutral/default values
      // Recovery: 50 (no muscles), Volume: 100 (under MEV), Neglected: 50 (empty list),
      // Pattern: 50 (empty history), Variety: 100 (empty history), Balance: 50 (no pairs)
      // Weighted: 0.25*50 + 0.25*100 + 0.20*50 + 0.15*50 + 0.10*100 + 0.05*50
      //         = 12.5 + 25.0 + 10.0 + 7.5 + 10.0 + 2.5 = 67.5
      // Note: with PETT at under MEV, volumeNeedScore = 100
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      final ctx = SuggestionContext(
        muscleRecovery: {},
        weeklyVolumes: emptyTracker(),
        neglectedMuscles: [],
        history: [],
      );

      final score = engine.computeScore(template, ctx, exerciseDB);

      // Recovery: no primary muscles? Actually bench is in DB, so primary = [PETT]
      // Recovery: no recovery data -> defaults to 100% -> curve=95 -> 95*0.7 + 50*0.3 = 81.5
      // Volume: PETT at 0 sets, MEV=10 -> score=100
      // Neglected: empty list -> 50
      // Pattern: empty history -> 50
      // Variety: empty history -> 100
      // Balance: no pairs trained -> 50
      // Total: 0.25*81.5 + 0.25*100 + 0.20*50 + 0.15*50 + 0.10*100 + 0.05*50
      //      = 20.375 + 25 + 10 + 7.5 + 10 + 2.5 = 75.375
      expect(score, closeTo(75.375, 0.5));
    });

    test('higher recovery score increases total score', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };

      final ctxGoodRecovery = SuggestionContext(
        muscleRecovery: {
          'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 80.0),
        },
        weeklyVolumes: emptyTracker(),
        neglectedMuscles: [],
        history: [],
      );
      final ctxPoorRecovery = SuggestionContext(
        muscleRecovery: {
          'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 20.0),
        },
        weeklyVolumes: emptyTracker(),
        neglectedMuscles: [],
        history: [],
      );

      final goodScore = engine.computeScore(
        template,
        ctxGoodRecovery,
        exerciseDB,
      );
      final poorScore = engine.computeScore(
        template,
        ctxPoorRecovery,
        exerciseDB,
      );

      expect(goodScore, greaterThan(poorScore));
    });

    test('template with no exercises still returns valid score', () {
      final template = makeTemplate(id: 'empty-template', exercises: []);
      final ctx = SuggestionContext(
        muscleRecovery: {},
        weeklyVolumes: emptyTracker(),
        neglectedMuscles: [],
        history: [],
      );

      final score = engine.computeScore(template, ctx, {});

      expect(score, inInclusiveRange(0.0, 100.0));
    });
  });

  // ---------------------------------------------------------------------------
  // SCORE BREAKDOWN: computeScoreBreakdown
  // ---------------------------------------------------------------------------

  group('computeScoreBreakdown', () {
    test('returns map with all 6 factors', () {
      final template = makeTemplate(id: 'tmpl1', exercises: []);
      final ctx = SuggestionContext(
        muscleRecovery: {},
        weeklyVolumes: emptyTracker(),
        neglectedMuscles: [],
        history: [],
      );

      final breakdown = engine.computeScoreBreakdown(template, ctx, {});

      expect(
        breakdown.keys,
        containsAll([
          'recovery',
          'volume',
          'neglected',
          'pattern',
          'variety',
          'balance',
        ]),
      );
      expect(breakdown.length, equals(6));
    });

    test('all breakdown values are between 0 and 100', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      final ctx = SuggestionContext(
        muscleRecovery: {
          'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 75.0),
        },
        weeklyVolumes: emptyTracker(),
        neglectedMuscles: [],
        history: [],
      );

      final breakdown = engine.computeScoreBreakdown(template, ctx, exerciseDB);

      for (final entry in breakdown.entries) {
        expect(
          entry.value,
          inInclusiveRange(0.0, 100.0),
          reason: '${entry.key} score out of bounds',
        );
      }
    });

    test('breakdown values are consistent with individual factor calls', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      final tracker = emptyTracker();
      final recovery = {
        'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 80.0),
      };
      final ctx = SuggestionContext(
        muscleRecovery: recovery,
        weeklyVolumes: tracker,
        neglectedMuscles: [],
        history: [],
      );

      final breakdown = engine.computeScoreBreakdown(template, ctx, exerciseDB);

      expect(
        breakdown['recovery'],
        closeTo(engine.recoveryScore(template, recovery, exerciseDB), 0.001),
      );
      expect(
        breakdown['volume'],
        closeTo(engine.volumeNeedScore(template, tracker, exerciseDB), 0.001),
      );
      expect(
        breakdown['neglected'],
        closeTo(engine.neglectedScore(template, [], exerciseDB), 0.001),
      );
      expect(
        breakdown['pattern'],
        closeTo(engine.patternScore(template, []), 0.001),
      );
      expect(
        breakdown['variety'],
        closeTo(engine.varietyScore(template, [], exerciseDB), 0.001),
      );
      expect(
        breakdown['balance'],
        closeTo(engine.balanceScore(template, tracker, exerciseDB), 0.001),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // SUPERCOMPENSATION CURVE (tested indirectly via recoveryScore)
  // ---------------------------------------------------------------------------

  group('supercompensationCurve - all branches', () {
    // Test each branch of _supercompensationCurve via recoveryScore
    // (with a single primary muscle and no secondary)

    ExerciseDefinition benchDef = makeExerciseDef(id: 'bench', focus: ['PETT']);
    late CommunityWorkoutTemplate benchTemplate;
    late Map<String, ExerciseDefinition> benchDB;

    setUp(() {
      benchTemplate = makeTemplate(
        id: 'tmpl',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      benchDB = {'bench': benchDef};
    });

    test('recovery >= 90 returns 95 from curve', () {
      final recovery = {
        'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 95.0),
      };
      final score = engine.recoveryScore(benchTemplate, recovery, benchDB);
      // curve(95) = 95 -> 95*0.7 + 50*0.3 = 81.5
      expect(score, closeTo(81.5, 0.01));
    });

    test('recovery in 70-90 returns 100 from curve (OPTIMAL)', () {
      final recovery = {
        'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 75.0),
      };
      final score = engine.recoveryScore(benchTemplate, recovery, benchDB);
      // curve(75) = 100 -> 100*0.7 + 50*0.3 = 85.0
      expect(score, closeTo(85.0, 0.01));
    });

    test('recovery in 50-70 returns 70 from curve', () {
      final recovery = {
        'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 60.0),
      };
      final score = engine.recoveryScore(benchTemplate, recovery, benchDB);
      // curve(60) = 70 -> 70*0.7 + 50*0.3 = 64.0
      expect(score, closeTo(64.0, 0.01));
    });

    test('recovery in 30-50 returns 40 from curve', () {
      final recovery = {
        'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 40.0),
      };
      final score = engine.recoveryScore(benchTemplate, recovery, benchDB);
      // curve(40) = 40 -> 40*0.7 + 50*0.3 = 43.0
      expect(score, closeTo(43.0, 0.01));
    });

    test('recovery < 30 returns 10 from curve', () {
      final recovery = {
        'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 20.0),
      };
      final score = engine.recoveryScore(benchTemplate, recovery, benchDB);
      // curve(20) = 10 -> 10*0.7 + 50*0.3 = 22.0
      expect(score, closeTo(22.0, 0.01));
    });

    test('boundary: recovery exactly 70 -> optimal window (100)', () {
      final recovery = {
        'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 70.0),
      };
      final score = engine.recoveryScore(benchTemplate, recovery, benchDB);
      // curve(70) = 100 -> 100*0.7 + 50*0.3 = 85.0
      expect(score, closeTo(85.0, 0.01));
    });

    test('boundary: recovery exactly 50 -> partial (70)', () {
      final recovery = {
        'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 50.0),
      };
      final score = engine.recoveryScore(benchTemplate, recovery, benchDB);
      // curve(50) = 70 -> 70*0.7 + 50*0.3 = 64.0
      expect(score, closeTo(64.0, 0.01));
    });

    test('boundary: recovery exactly 30 -> fatigued (40)', () {
      final recovery = {
        'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 30.0),
      };
      final score = engine.recoveryScore(benchTemplate, recovery, benchDB);
      // curve(30) = 40 -> 40*0.7 + 50*0.3 = 43.0
      expect(score, closeTo(43.0, 0.01));
    });
  });

  // ---------------------------------------------------------------------------
  // SUPERSET EXERCISE SUPPORT
  // ---------------------------------------------------------------------------

  group('superset exercise handling', () {
    test('recoveryScore extracts muscles from superset sub-exercises', () {
      // Create a superset: bench (PETT) + row (LAT)
      final benchEx = workout.Exercise(
        id: 'bench',
        name: 'bench',
        type: workout.ExerciseType.single,
        category: workout.ExerciseCategory.chest,
        sets: [],
      );
      final rowEx = workout.Exercise(
        id: 'row',
        name: 'row',
        type: workout.ExerciseType.single,
        category: workout.ExerciseCategory.back,
        sets: [],
      );
      final superset = workout.SupersetExercise(
        id: 'ss1',
        name: 'Push-Pull Superset',
        exercises: [benchEx, rowEx],
      );

      final template = makeTemplate(id: 'tmpl1', exercises: [superset]);
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
        'row': makeExerciseDef(id: 'row', focus: ['LAT']),
      };
      final recovery = {
        'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 75.0),
        'LAT': makeReadiness(muscleId: 'LAT', recoveryPercent: 75.0),
      };

      final score = engine.recoveryScore(template, recovery, exerciseDB);

      // Both at 75% -> curve=100, no secondary
      // primaryAvg = 100, secondaryAvg = 50 (no secondary)
      // 100*0.7 + 50*0.3 = 85.0
      expect(score, closeTo(85.0, 0.01));
    });

    test('volumeNeedScore extracts muscles from superset sub-exercises', () {
      final benchEx = workout.Exercise(
        id: 'bench',
        name: 'bench',
        type: workout.ExerciseType.single,
        category: workout.ExerciseCategory.chest,
        sets: [],
      );
      final superset = workout.SupersetExercise(
        id: 'ss1',
        name: 'Superset',
        exercises: [benchEx],
      );

      final template = makeTemplate(id: 'tmpl1', exercises: [superset]);
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };

      final score = engine.volumeNeedScore(
        template,
        emptyTracker(),
        exerciseDB,
      );

      // PETT at 0 sets, MEV=10 -> 100
      expect(score, closeTo(100.0, 0.01));
    });
  });

  // ---------------------------------------------------------------------------
  // RANKEDTEMPLATE
  // ---------------------------------------------------------------------------

  group('RankedTemplate', () {
    test('constructs with correct fields', () {
      final template = makeTemplate(id: 'tmpl1', exercises: []);
      const score = 75.5;
      const breakdown = {'recovery': 80.0, 'volume': 70.0};

      final ranked = RankedTemplate(
        template: template,
        score: score,
        breakdown: breakdown,
      );

      expect(ranked.template.id, equals('tmpl1'));
      expect(ranked.score, equals(75.5));
      expect(ranked.breakdown['recovery'], equals(80.0));
    });

    test('toString includes template name and score', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [],
        name: 'Chest Day',
      );
      final ranked = RankedTemplate(
        template: template,
        score: 88.5,
        breakdown: {},
      );

      final str = ranked.toString();

      expect(str, contains('Chest Day'));
      expect(str, contains('88.5'));
    });
  });

  // ---------------------------------------------------------------------------
  // SUGGESTIONCONTEXT
  // ---------------------------------------------------------------------------

  group('SuggestionContext', () {
    test('stores all fields correctly', () {
      final tracker = emptyTracker();
      final recovery = {
        'PETT': makeReadiness(muscleId: 'PETT', recoveryPercent: 80.0),
      };
      final neglected = [
        NeglectedMuscle(
          muscleName: 'chest',
          volumePercentage: 2.0,
          severity: NeglectSeverity.high,
          priority: 7.0,
        ),
      ];
      final history = [makeHistory(id: 'w1', completedAt: DateTime.now())];

      final ctx = SuggestionContext(
        muscleRecovery: recovery,
        weeklyVolumes: tracker,
        neglectedMuscles: neglected,
        history: history,
      );

      expect(ctx.muscleRecovery, equals(recovery));
      expect(ctx.weeklyVolumes, equals(tracker));
      expect(ctx.neglectedMuscles, equals(neglected));
      expect(ctx.history, equals(history));
    });

    test('constructed with empty fields has correct defaults', () {
      final tracker = emptyTracker();
      final ctx = SuggestionContext(
        muscleRecovery: {},
        weeklyVolumes: tracker,
        neglectedMuscles: [],
        history: [],
      );

      expect(ctx.muscleRecovery, isEmpty);
      expect(ctx.neglectedMuscles, isEmpty);
      expect(ctx.history, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // INTEGRATION: computeScore with full context
  // ---------------------------------------------------------------------------

  group('computeScore - integration', () {
    test('variety penalty reduces score when same template repeated', () {
      final template = makeTemplate(
        id: 'chest-day',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };

      final ctxNoHistory = SuggestionContext(
        muscleRecovery: {},
        weeklyVolumes: emptyTracker(),
        neglectedMuscles: [],
        history: [],
      );
      final ctxSameTemplate = SuggestionContext(
        muscleRecovery: {},
        weeklyVolumes: emptyTracker(),
        neglectedMuscles: [],
        history: [
          makeHistory(
            id: 'w1',
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
            templateId: 'chest-day',
          ),
        ],
      );

      final noHistoryScore = engine.computeScore(
        template,
        ctxNoHistory,
        exerciseDB,
      );
      final repeatedScore = engine.computeScore(
        template,
        ctxSameTemplate,
        exerciseDB,
      );

      expect(noHistoryScore, greaterThan(repeatedScore));
    });

    test('neglected muscle coverage increases score', () {
      final template = makeTemplate(
        id: 'chest-day',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };

      final ctxNoNeglect = SuggestionContext(
        muscleRecovery: {},
        weeklyVolumes: emptyTracker(),
        neglectedMuscles: [],
        history: [],
      );
      final ctxWithNeglect = SuggestionContext(
        muscleRecovery: {},
        weeklyVolumes: emptyTracker(),
        neglectedMuscles: [
          NeglectedMuscle(
            muscleName: 'chest',
            volumePercentage: 1.0,
            severity: NeglectSeverity.critical,
            priority: 10.0,
          ),
        ],
        history: [],
      );

      final noNeglectScore = engine.computeScore(
        template,
        ctxNoNeglect,
        exerciseDB,
      );
      final withNeglectScore = engine.computeScore(
        template,
        ctxWithNeglect,
        exerciseDB,
      );

      // With neglected coverage (100 vs 50 neutral), score should be higher
      expect(withNeglectScore, greaterThan(noNeglectScore));
    });

    test('all factors contribute proportionally to total', () {
      final template = makeTemplate(
        id: 'tmpl1',
        exercises: [makeExercise(id: 'bench', name: 'bench')],
      );
      final exerciseDB = {
        'bench': makeExerciseDef(id: 'bench', focus: ['PETT']),
      };
      final ctx = SuggestionContext(
        muscleRecovery: {},
        weeklyVolumes: emptyTracker(),
        neglectedMuscles: [],
        history: [],
      );

      final total = engine.computeScore(template, ctx, exerciseDB);
      final breakdown = engine.computeScoreBreakdown(template, ctx, exerciseDB);

      // Manually compute weighted sum
      const weights = {
        'recovery': 0.25,
        'volume': 0.25,
        'neglected': 0.20,
        'pattern': 0.15,
        'variety': 0.10,
        'balance': 0.05,
      };
      double expected = 0;
      for (final entry in breakdown.entries) {
        expected += weights[entry.key]! * entry.value;
      }

      expect(total, closeTo(expected.clamp(0, 100), 0.001));
    });
  });
}
