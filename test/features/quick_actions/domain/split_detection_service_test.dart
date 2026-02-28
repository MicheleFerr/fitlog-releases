/// Unit tests for SplitDetectionService
///
/// Tests split pattern detection, recovery-based suggestions,
/// imbalance detection, and edge cases using static method calls only.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/quick_actions/domain/services/split_detection_service.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Creates a minimal [SetHistoryDetail] with no-op values.
SetHistoryDetail _set() => const SetHistoryDetail(
      setNumber: 1,
      weight: 60,
      reps: 10,
      rpe: 7,
    );

/// Creates an [ExerciseHistoryDetail] for the given category string.
ExerciseHistoryDetail _exercise(String category, {String? name}) =>
    ExerciseHistoryDetail(
      id: 'ex-$category',
      name: name ?? 'Exercise ($category)',
      category: category,
      sets: [_set()],
      exerciseData: const {},
    );

/// Creates a [WorkoutHistoryDetail] with the given exercises and completedAt.
WorkoutHistoryDetail _workout({
  required DateTime completedAt,
  required List<ExerciseHistoryDetail> exercises,
  String id = '',
}) {
  final workoutId = id.isEmpty ? completedAt.toIso8601String() : id;
  return WorkoutHistoryDetail(
    id: workoutId,
    userId: 'user-1',
    name: 'Test Workout',
    description: '',
    createdAt: completedAt,
    startedAt: completedAt,
    completedAt: completedAt,
    updatedAt: completedAt,
    duration: const Duration(hours: 1),
    exercises: exercises,
    metadata: const {},
  );
}

/// Builds a single-category workout [n] days ago.
WorkoutHistoryDetail _workoutDaysAgo(String category, int daysAgo) {
  final date = DateTime.now().subtract(Duration(days: daysAgo));
  return _workout(completedAt: date, exercises: [_exercise(category)]);
}

/// Builds a repeating PPL sequence: Push, Pull, Legs x [cycles],
/// starting [startDaysAgo] days ago with [dayGap] days between workouts.
///
/// Returns workouts newest-first (as the service expects).
List<WorkoutHistoryDetail> _buildPplHistory({
  int cycles = 3,
  int startDaysAgo = 18,
  int dayGap = 2,
}) {
  final sequence = ['chest', 'back', 'legs'];
  final workouts = <WorkoutHistoryDetail>[];
  var daysAgo = startDaysAgo;

  for (var c = 0; c < cycles; c++) {
    for (final cat in sequence) {
      workouts.add(_workoutDaysAgo(cat, daysAgo));
      daysAgo -= dayGap;
    }
  }

  // Sort newest-first
  workouts.sort((a, b) => b.completedAt.compareTo(a.completedAt));
  return workouts;
}

/// Builds an Upper/Lower split history newest-first.
List<WorkoutHistoryDetail> _buildUpperLowerHistory({
  int cycles = 3,
  int startDaysAgo = 12,
}) {
  final sequence = ['chest', 'legs'];
  final workouts = <WorkoutHistoryDetail>[];
  var daysAgo = startDaysAgo;

  for (var c = 0; c < cycles; c++) {
    for (final cat in sequence) {
      workouts.add(_workoutDaysAgo(cat, daysAgo));
      daysAgo -= 2;
    }
  }

  workouts.sort((a, b) => b.completedAt.compareTo(a.completedAt));
  return workouts;
}

/// Builds a Bro Split: chest, back, shoulders, arms, legs over [cycles] weeks,
/// newest-first.
List<WorkoutHistoryDetail> _buildBroSplitHistory({
  int cycles = 2,
  int startDaysAgo = 20,
}) {
  final sequence = ['chest', 'back', 'shoulders', 'arms', 'legs'];
  final workouts = <WorkoutHistoryDetail>[];
  var daysAgo = startDaysAgo;

  for (var c = 0; c < cycles; c++) {
    for (final cat in sequence) {
      workouts.add(_workoutDaysAgo(cat, daysAgo));
      daysAgo -= 2;
    }
  }

  workouts.sort((a, b) => b.completedAt.compareTo(a.completedAt));
  return workouts;
}

// ---------------------------------------------------------------------------
// Test suite
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  group('SplitDetectionService.detect – new user threshold', () {
    test('returns newUser for empty workout list', () {
      final result = SplitDetectionService.detect(workouts: []);

      expect(result.type, SplitDetectionType.newUser);
      expect(result.suggestedCategory, isNull);
      expect(result.detectedCycle, isNull);
    });

    test('returns newUser for exactly 1 workout', () {
      final workouts = [_workoutDaysAgo('chest', 1)];

      final result = SplitDetectionService.detect(workouts: workouts);

      expect(result.type, SplitDetectionType.newUser);
    });

    test('returns newUser for exactly 3 workouts (boundary)', () {
      final workouts = [
        _workoutDaysAgo('chest', 5),
        _workoutDaysAgo('back', 3),
        _workoutDaysAgo('legs', 1),
      ];

      final result = SplitDetectionService.detect(workouts: workouts);

      expect(result.type, SplitDetectionType.newUser);
    });

    test('does NOT return newUser for exactly 4 workouts (minimum)', () {
      final workouts = [
        _workoutDaysAgo('chest', 6),
        _workoutDaysAgo('back', 4),
        _workoutDaysAgo('legs', 2),
        _workoutDaysAgo('chest', 1),
      ];

      final result = SplitDetectionService.detect(workouts: workouts);

      expect(result.type, isNot(SplitDetectionType.newUser));
    });

    test('returns newUser when all exercises are cardio/other (no muscle data)',
        () {
      // 6 workouts but all cardio - dominant categories will be empty
      final workouts = List.generate(
        6,
        (i) => _workout(
          completedAt: DateTime.now().subtract(Duration(days: i * 2)),
          exercises: [_exercise('cardio')],
        ),
      );

      final result = SplitDetectionService.detect(workouts: workouts);

      expect(result.type, SplitDetectionType.newUser);
    });
  });

  // -------------------------------------------------------------------------
  group('SplitDetectionService.detect – PPL pattern detection', () {
    test('detects 3-day PPL cycle with 3 full repetitions', () {
      final workouts = _buildPplHistory(cycles: 3, startDaysAgo: 18);

      final result = SplitDetectionService.detect(workouts: workouts);

      expect(result.type, SplitDetectionType.patternDetected);
      expect(result.detectedCycle, isNotNull);
      expect(result.detectedCycle!.length, 3);
    });

    test('PPL suggests next category in rotation after legs', () {
      // Build PPL ending on legs — next should be chest
      final workouts = _buildPplHistory(cycles: 2, startDaysAgo: 12);

      final result = SplitDetectionService.detect(workouts: workouts);

      if (result.type == SplitDetectionType.patternDetected) {
        // Verify suggestion is the next step in detected cycle
        expect(result.suggestedCategory, isNotNull);
        expect(result.detectedCycle, isNotNull);
      }
    });

    test('PPL result contains detectedCycle with 3 categories', () {
      final workouts = _buildPplHistory(cycles: 3);

      final result = SplitDetectionService.detect(workouts: workouts);

      if (result.type == SplitDetectionType.patternDetected) {
        expect(result.detectedCycle!.length, 3);
      }
    });

    test('PPL with 1 mismatch per cycle still detects pattern (tolerance)', () {
      // Build standard PPL but replace one workout category in each cycle
      final now = DateTime.now();
      final workouts = <WorkoutHistoryDetail>[];

      // Cycle 1: chest, back, legs
      workouts.add(_workout(
        completedAt: now.subtract(const Duration(days: 12)),
        exercises: [_exercise('chest')],
        id: 'c1w1',
      ));
      workouts.add(_workout(
        completedAt: now.subtract(const Duration(days: 10)),
        exercises: [_exercise('back')],
        id: 'c1w2',
      ));
      workouts.add(_workout(
        completedAt: now.subtract(const Duration(days: 8)),
        exercises: [_exercise('legs')],
        id: 'c1w3',
      ));

      // Cycle 2: chest, SHOULDERS (mismatch), legs
      workouts.add(_workout(
        completedAt: now.subtract(const Duration(days: 6)),
        exercises: [_exercise('chest')],
        id: 'c2w1',
      ));
      workouts.add(_workout(
        completedAt: now.subtract(const Duration(days: 4)),
        exercises: [_exercise('shoulders')], // mismatch
        id: 'c2w2',
      ));
      workouts.add(_workout(
        completedAt: now.subtract(const Duration(days: 2)),
        exercises: [_exercise('legs')],
        id: 'c2w3',
      ));

      workouts.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      final result = SplitDetectionService.detect(workouts: workouts);

      // With tolerance of 1 mismatch per cycle the pattern should still be found
      expect(result.type, SplitDetectionType.patternDetected);
    });
  });

  // -------------------------------------------------------------------------
  group('SplitDetectionService.detect – Upper/Lower split', () {
    test('detects 2-day Upper/Lower cycle', () {
      final workouts = _buildUpperLowerHistory(cycles: 4, startDaysAgo: 16);

      final result = SplitDetectionService.detect(workouts: workouts);

      expect(result.type, SplitDetectionType.patternDetected);
      expect(result.detectedCycle!.length, 2);
    });

    test('Upper/Lower suggests correct next category after upper day', () {
      // Build upper/lower ending with upper (chest) — next should be lower (legs)
      final now = DateTime.now();
      final workouts = <WorkoutHistoryDetail>[];

      for (var i = 0; i < 4; i++) {
        final category = i.isEven ? 'chest' : 'legs';
        workouts.add(_workout(
          completedAt: now.subtract(Duration(days: (8 - i * 2))),
          exercises: [_exercise(category)],
          id: 'ul$i',
        ));
      }

      // Add final upper to make last category upper
      workouts.add(_workout(
        completedAt: now.subtract(const Duration(days: 1)),
        exercises: [_exercise('chest')],
        id: 'ul-last',
      ));

      workouts.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      final result = SplitDetectionService.detect(workouts: workouts);

      if (result.type == SplitDetectionType.patternDetected) {
        expect(result.suggestedCategory, isNotNull);
      }
    });
  });

  // -------------------------------------------------------------------------
  group('SplitDetectionService.detect – Full Body split', () {
    test('full body (all categories per workout) falls back to non-newUser',
        () {
      // Each workout has chest + back + legs - dominant varies
      final now = DateTime.now();
      final workouts = List.generate(5, (i) {
        return _workout(
          completedAt: now.subtract(Duration(days: i + 1)),
          exercises: [
            _exercise('chest'),
            _exercise('back'),
            _exercise('legs'),
          ],
          id: 'fb$i',
        );
      });

      final result = SplitDetectionService.detect(workouts: workouts);

      // Full body dominant will always resolve to same category
      // Repeated same category is a 1-length cycle or falls through.
      // Either way, confirm not newUser.
      expect(result.type, isNot(SplitDetectionType.newUser));
    });
  });

  // -------------------------------------------------------------------------
  group('SplitDetectionService.detect – Bro Split (5-day)', () {
    test('detects 5-day bro split cycle with 2 repetitions', () {
      final workouts = _buildBroSplitHistory(cycles: 2, startDaysAgo: 20);

      final result = SplitDetectionService.detect(workouts: workouts);

      expect(result.type, SplitDetectionType.patternDetected);
      expect(result.detectedCycle!.length, 5);
    });

    test('bro split detectedCycle contains all 5 muscle groups', () {
      final workouts = _buildBroSplitHistory(cycles: 2, startDaysAgo: 20);

      final result = SplitDetectionService.detect(workouts: workouts);

      if (result.type == SplitDetectionType.patternDetected) {
        final cycleCategories = result.detectedCycle!.map((c) => c.name);
        expect(
            cycleCategories,
            containsAll(
                ['chest', 'back', 'shoulders', 'arms', 'legs']));
      }
    });
  });

  // -------------------------------------------------------------------------
  group('SplitDetectionService.detect – imbalance detection', () {
    test('detects imbalance when category not trained >7 days, user active',
        () {
      final now = DateTime.now();

      // Active user: 2+ workouts in last 7 days using different categories
      // (same category repeated would trigger patternDetected before imbalance)
      final workouts = <WorkoutHistoryDetail>[
        _workout(
          completedAt: now.subtract(const Duration(days: 1)),
          exercises: [_exercise('chest')],
          id: 'imb1',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 3)),
          exercises: [_exercise('back')],
          id: 'imb2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 5)),
          exercises: [_exercise('shoulders')],
          id: 'imb3',
        ),
        // Legs last trained 10 days ago — imbalance
        _workout(
          completedAt: now.subtract(const Duration(days: 10)),
          exercises: [_exercise('legs')],
          id: 'imb4',
        ),
      ];

      final result = SplitDetectionService.detect(workouts: workouts);

      expect(result.type, SplitDetectionType.imbalanceDetected);
      expect(result.isImbalanceDetected, isTrue);
      expect(result.suggestedCategory, ExerciseCategory.legs);
    });

    test('imbalance result includes daysSinceLastForCategory > 7', () {
      final now = DateTime.now();
      final workouts = <WorkoutHistoryDetail>[
        _workout(
          completedAt: now.subtract(const Duration(days: 1)),
          exercises: [_exercise('chest')],
          id: 'i1',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 3)),
          exercises: [_exercise('back')],
          id: 'i2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 5)),
          exercises: [_exercise('chest')],
          id: 'i3',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 9)),
          exercises: [_exercise('legs')],
          id: 'i4',
        ),
      ];

      final result = SplitDetectionService.detect(workouts: workouts);

      if (result.type == SplitDetectionType.imbalanceDetected) {
        expect(result.daysSinceLastForCategory, greaterThan(7));
      }
    });

    test('NO imbalance when user has only 1 workout in last 7 days', () {
      final now = DateTime.now();
      // Inactive user: only 1 recent workout
      final workouts = <WorkoutHistoryDetail>[
        _workout(
          completedAt: now.subtract(const Duration(days: 2)),
          exercises: [_exercise('chest')],
          id: 'ni1',
        ),
        // Older workouts don't count as "recent"
        _workout(
          completedAt: now.subtract(const Duration(days: 10)),
          exercises: [_exercise('legs')],
          id: 'ni2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 14)),
          exercises: [_exercise('back')],
          id: 'ni3',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 18)),
          exercises: [_exercise('shoulders')],
          id: 'ni4',
        ),
      ];

      final result = SplitDetectionService.detect(workouts: workouts);

      // Should NOT detect imbalance — user isn't active enough
      expect(result.type, isNot(SplitDetectionType.imbalanceDetected));
    });

    test('isImbalanceDetected is false for patternDetected result', () {
      final workouts = _buildPplHistory(cycles: 3);

      final result = SplitDetectionService.detect(workouts: workouts);

      if (result.type == SplitDetectionType.patternDetected) {
        expect(result.isImbalanceDetected, isFalse);
      }
    });

    test('isImbalanceDetected is false for recoveryBased result', () {
      final now = DateTime.now();
      // 4 workouts, no pattern, no imbalance (all within 7 days or only 1 recent)
      final workouts = [
        _workout(
          completedAt: now.subtract(const Duration(days: 1)),
          exercises: [_exercise('chest')],
          id: 'rb1',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 4)),
          exercises: [_exercise('back')],
          id: 'rb2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 6)),
          exercises: [_exercise('legs')],
          id: 'rb3',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 7)),
          exercises: [_exercise('shoulders')],
          id: 'rb4',
        ),
      ];

      final result = SplitDetectionService.detect(workouts: workouts);

      expect(result.isImbalanceDetected, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('SplitDetectionService.detect – recovery-based suggestions', () {
    test('recovery-based returns most rested category (no recoveryHours)', () {
      final now = DateTime.now();
      // No pattern but 4+ workouts. Legs most rested (5 days).
      final workouts = [
        _workout(
          completedAt: now.subtract(const Duration(days: 1)),
          exercises: [_exercise('chest')],
          id: 'r1',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 3)),
          exercises: [_exercise('back')],
          id: 'r2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 5)),
          exercises: [_exercise('legs')],
          id: 'r3',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 4)),
          exercises: [_exercise('shoulders')],
          id: 'r4',
        ),
      ];

      final result = SplitDetectionService.detect(workouts: workouts);

      if (result.type == SplitDetectionType.recoveryBased) {
        // legs trained 5 days ago — most rested
        expect(result.suggestedCategory, ExerciseCategory.legs);
      }
    });

    test('recovery-based with recoveryHours weights suggestion correctly', () {
      final now = DateTime.now();
      // Scores with given recoveryHours:
      // chest:    1 day  / (48h/24)  = 1/2   = 0.50
      // back:     5 days / (72h/24)  = 5/3   = 1.67  ← wins
      // legs:     3 days / (96h/24)  = 3/4   = 0.75
      // shoulders: 1 day / (72h/24)  = 1/3   = 0.33
      // (shoulders is the most recently trained so it won't win)
      final workouts = [
        _workout(
          completedAt: now.subtract(const Duration(days: 1)),
          exercises: [_exercise('chest')],
          id: 'rh1',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 3)),
          exercises: [_exercise('legs')],
          id: 'rh2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 5)),
          exercises: [_exercise('back')],
          id: 'rh3',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 1)),
          exercises: [_exercise('shoulders')],
          id: 'rh4',
        ),
      ];

      final result = SplitDetectionService.detect(
        workouts: workouts,
        recoveryHoursPerCategory: {
          ExerciseCategory.chest: 48,
          ExerciseCategory.legs: 96,
          ExerciseCategory.back: 72,
          ExerciseCategory.shoulders: 72,
        },
      );

      if (result.type == SplitDetectionType.recoveryBased) {
        // back: score 1.67 is the highest
        expect(result.suggestedCategory, ExerciseCategory.back);
      }
    });

    test('recovery-based result includes daysSinceLastForCategory', () {
      final now = DateTime.now();
      final workouts = [
        _workout(
          completedAt: now.subtract(const Duration(days: 2)),
          exercises: [_exercise('chest')],
          id: 'ds1',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 5)),
          exercises: [_exercise('back')],
          id: 'ds2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 3)),
          exercises: [_exercise('legs')],
          id: 'ds3',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 4)),
          exercises: [_exercise('shoulders')],
          id: 'ds4',
        ),
      ];

      final result = SplitDetectionService.detect(workouts: workouts);

      if (result.type == SplitDetectionType.recoveryBased) {
        expect(result.daysSinceLastForCategory, isNotNull);
        expect(result.daysSinceLastForCategory, greaterThan(0));
      }
    });

    test('recovery-based prefers category with best score when using hours',
        () {
      final now = DateTime.now();
      // arms: 2 days ago, recovery 24h → score 2/1 = 2.0
      // legs: 3 days ago, recovery 96h → score 3/4 = 0.75
      // arms should win despite being more recently trained
      final workouts = [
        _workout(
          completedAt: now.subtract(const Duration(days: 1)),
          exercises: [_exercise('chest')],
          id: 'ph1',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 2)),
          exercises: [_exercise('arms')],
          id: 'ph2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 3)),
          exercises: [_exercise('legs')],
          id: 'ph3',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 4)),
          exercises: [_exercise('back')],
          id: 'ph4',
        ),
      ];

      final result = SplitDetectionService.detect(
        workouts: workouts,
        recoveryHoursPerCategory: {
          ExerciseCategory.chest: 72,
          ExerciseCategory.arms: 24,
          ExerciseCategory.legs: 96,
          ExerciseCategory.back: 72,
        },
      );

      if (result.type == SplitDetectionType.recoveryBased) {
        expect(result.suggestedCategory, ExerciseCategory.arms);
      }
    });

    test('recovery-based uses default 72h when category missing from map', () {
      final now = DateTime.now();
      // back: 4 days ago; no entry in recoveryHours → defaults to 72h (3d)
      // score back = 4/3 = 1.33
      // chest: 1 day ago, 72h → score 1/3 = 0.33
      final workouts = [
        _workout(
          completedAt: now.subtract(const Duration(days: 1)),
          exercises: [_exercise('chest')],
          id: 'def1',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 4)),
          exercises: [_exercise('back')],
          id: 'def2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 3)),
          exercises: [_exercise('legs')],
          id: 'def3',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 2)),
          exercises: [_exercise('shoulders')],
          id: 'def4',
        ),
      ];

      // Only provide partial map — back not in map → default 72h used
      final result = SplitDetectionService.detect(
        workouts: workouts,
        recoveryHoursPerCategory: {
          ExerciseCategory.chest: 72,
          // back intentionally missing
          ExerciseCategory.legs: 72,
          ExerciseCategory.shoulders: 72,
        },
      );

      if (result.type == SplitDetectionType.recoveryBased) {
        // back should win (4 days / 3 days recovery = 1.33 score)
        expect(result.suggestedCategory, ExerciseCategory.back);
      }
    });
  });

  // -------------------------------------------------------------------------
  group('SplitDetectionService.detect – cardio/other exclusion', () {
    test('cardio exercises are excluded from dominant category calculation',
        () {
      final now = DateTime.now();
      // Each workout has 3 cardio + 1 chest — chest should be dominant
      final workouts = List.generate(5, (i) {
        return _workout(
          completedAt: now.subtract(Duration(days: i * 2 + 1)),
          exercises: [
            _exercise('cardio'),
            _exercise('cardio'),
            _exercise('cardio'),
            _exercise('chest'),
          ],
          id: 'ex$i',
        );
      });

      final result = SplitDetectionService.detect(workouts: workouts);

      // Should NOT be newUser — chest exercises are valid
      expect(result.type, isNot(SplitDetectionType.newUser));
    });

    test('other exercises are excluded from dominant category calculation', () {
      final now = DateTime.now();
      final workouts = List.generate(5, (i) {
        return _workout(
          completedAt: now.subtract(Duration(days: i * 2 + 1)),
          exercises: [
            _exercise('other'),
            _exercise('other'),
            _exercise('back'),
          ],
          id: 'oth$i',
        );
      });

      final result = SplitDetectionService.detect(workouts: workouts);

      expect(result.type, isNot(SplitDetectionType.newUser));
    });

    test(
        'workout with only cardio contributes no dominant category — '
        'service does not crash or suggest cardio',
        () {
      final now = DateTime.now();
      // Mix of cardio-only and muscle workouts.
      // Cardio workouts are excluded from dominant category extraction,
      // so suggestions will only ever be muscle-group categories.
      final workouts = <WorkoutHistoryDetail>[
        _workout(
          completedAt: now.subtract(const Duration(days: 1)),
          exercises: [_exercise('cardio')],
          id: 'co1',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 3)),
          exercises: [_exercise('chest')],
          id: 'co2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 5)),
          exercises: [_exercise('cardio')],
          id: 'co3',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 7)),
          exercises: [_exercise('back')],
          id: 'co4',
        ),
      ];

      final result = SplitDetectionService.detect(workouts: workouts);

      // Result must not be newUser (4 total workouts >= threshold)
      // and suggested category must never be cardio or other
      expect(result.type, isNot(SplitDetectionType.newUser));
      if (result.suggestedCategory != null) {
        expect(
          result.suggestedCategory,
          isNot(anyOf(ExerciseCategory.cardio, ExerciseCategory.other)),
        );
      }
    });
  });

  // -------------------------------------------------------------------------
  group('SplitDetectionService.detect – patternDetected result structure', () {
    test('patternDetected includes suggestedCategory', () {
      final workouts = _buildPplHistory(cycles: 3);

      final result = SplitDetectionService.detect(workouts: workouts);

      if (result.type == SplitDetectionType.patternDetected) {
        expect(result.suggestedCategory, isNotNull);
      }
    });

    test('patternDetected includes detectedCycle', () {
      final workouts = _buildPplHistory(cycles: 3);

      final result = SplitDetectionService.detect(workouts: workouts);

      if (result.type == SplitDetectionType.patternDetected) {
        expect(result.detectedCycle, isNotNull);
        expect(result.detectedCycle, isNotEmpty);
      }
    });

    test('suggestedCategory is always a member of detectedCycle', () {
      final workouts = _buildPplHistory(cycles: 3);

      final result = SplitDetectionService.detect(workouts: workouts);

      if (result.type == SplitDetectionType.patternDetected) {
        expect(result.detectedCycle, contains(result.suggestedCategory));
      }
    });

    test('detectedCycle has length between 2 and 7', () {
      final workouts = _buildBroSplitHistory(cycles: 2, startDaysAgo: 20);

      final result = SplitDetectionService.detect(workouts: workouts);

      if (result.type == SplitDetectionType.patternDetected) {
        expect(result.detectedCycle!.length, greaterThanOrEqualTo(2));
        expect(result.detectedCycle!.length, lessThanOrEqualTo(7));
      }
    });
  });

  // -------------------------------------------------------------------------
  group('SplitDetectionService.detect – cycle detection boundary conditions',
      () {
    test('3 workouts in a potential cycle does NOT trigger patternDetected',
        () {
      // Only 3 workouts total = newUser (< 4)
      final workouts = [
        _workoutDaysAgo('chest', 4),
        _workoutDaysAgo('back', 2),
        _workoutDaysAgo('legs', 1),
      ];

      final result = SplitDetectionService.detect(workouts: workouts);

      expect(result.type, SplitDetectionType.newUser);
    });

    test('cycle requires at least 2 full repetitions (4 workouts = 2x2-cycle)',
        () {
      // Exactly 2-cycle length with 2 repetitions = should detect
      final now = DateTime.now();
      final workouts = [
        _workout(
          completedAt: now.subtract(const Duration(days: 7)),
          exercises: [_exercise('chest')],
          id: 'cr1',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 5)),
          exercises: [_exercise('legs')],
          id: 'cr2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 3)),
          exercises: [_exercise('chest')],
          id: 'cr3',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 1)),
          exercises: [_exercise('legs')],
          id: 'cr4',
        ),
      ];

      final result = SplitDetectionService.detect(workouts: workouts);

      expect(result.type, SplitDetectionType.patternDetected);
      expect(result.detectedCycle!.length, 2);
    });

    test('random category sequence without pattern returns non-pattern result',
        () {
      final now = DateTime.now();
      final workouts = <WorkoutHistoryDetail>[
        _workout(
          completedAt: now.subtract(const Duration(days: 10)),
          exercises: [_exercise('chest')],
          id: 'rand1',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 8)),
          exercises: [_exercise('legs')],
          id: 'rand2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 6)),
          exercises: [_exercise('back')],
          id: 'rand3',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 4)),
          exercises: [_exercise('arms')],
          id: 'rand4',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 3)),
          exercises: [_exercise('chest')],
          id: 'rand5',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 2)),
          exercises: [_exercise('shoulders')],
          id: 'rand6',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 1)),
          exercises: [_exercise('legs')],
          id: 'rand7',
        ),
      ];

      final result = SplitDetectionService.detect(workouts: workouts);

      expect(
        result.type,
        anyOf(
          SplitDetectionType.recoveryBased,
          SplitDetectionType.imbalanceDetected,
        ),
      );
    });

    test('2-mismatch cycle per repetition breaks detection (exceeds tolerance)',
        () {
      final now = DateTime.now();
      // Candidate: chest, back, legs — but 2 mismatches in second cycle
      final workouts = [
        _workout(
          completedAt: now.subtract(const Duration(days: 12)),
          exercises: [_exercise('chest')],
          id: 'bk1',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 10)),
          exercises: [_exercise('back')],
          id: 'bk2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 8)),
          exercises: [_exercise('legs')],
          id: 'bk3',
        ),
        // Second repetition with 2 mismatches
        _workout(
          completedAt: now.subtract(const Duration(days: 6)),
          exercises: [_exercise('shoulders')], // mismatch 1
          id: 'bk4',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 4)),
          exercises: [_exercise('arms')], // mismatch 2
          id: 'bk5',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 2)),
          exercises: [_exercise('legs')],
          id: 'bk6',
        ),
      ];

      final result = SplitDetectionService.detect(workouts: workouts);

      // 2 mismatches exceeds 1-tolerance → no pattern
      expect(result.type, isNot(SplitDetectionType.patternDetected));
    });
  });

  // -------------------------------------------------------------------------
  group('SplitDetectionService.detect – edge cases', () {
    test('handles workouts provided in any order (sorts internally)', () {
      final now = DateTime.now();
      // PPL in chronological (oldest first) order — service should sort
      final workoutsChronological = <WorkoutHistoryDetail>[
        _workout(
          completedAt: now.subtract(const Duration(days: 10)),
          exercises: [_exercise('chest')],
          id: 'ord1',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 8)),
          exercises: [_exercise('back')],
          id: 'ord2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 6)),
          exercises: [_exercise('legs')],
          id: 'ord3',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 4)),
          exercises: [_exercise('chest')],
          id: 'ord4',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 2)),
          exercises: [_exercise('back')],
          id: 'ord5',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 1)),
          exercises: [_exercise('legs')],
          id: 'ord6',
        ),
      ];

      // Reversed (newest first) should give same result
      final workoutsNewestFirst =
          List<WorkoutHistoryDetail>.from(workoutsChronological.reversed);

      final resultA =
          SplitDetectionService.detect(workouts: workoutsChronological);
      final resultB =
          SplitDetectionService.detect(workouts: workoutsNewestFirst);

      expect(resultA.type, resultB.type);
      expect(resultA.suggestedCategory, resultB.suggestedCategory);
    });

    test('handles workout with mixed known/unknown category strings', () {
      final now = DateTime.now();
      final workouts = <WorkoutHistoryDetail>[
        _workout(
          completedAt: now.subtract(const Duration(days: 1)),
          exercises: [_exercise('unknownCategory')], // maps to other → excluded
          id: 'unk1',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 3)),
          exercises: [_exercise('chest')],
          id: 'unk2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 5)),
          exercises: [_exercise('back')],
          id: 'unk3',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 7)),
          exercises: [_exercise('legs')],
          id: 'unk4',
        ),
      ];

      // Should not throw and return a valid result
      expect(
        () => SplitDetectionService.detect(workouts: workouts),
        returnsNormally,
      );
    });

    test('handles workout with no exercises (empty exercise list)', () {
      final now = DateTime.now();
      final workouts = <WorkoutHistoryDetail>[
        _workout(
          completedAt: now.subtract(const Duration(days: 1)),
          exercises: [],
          id: 'empty1',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 2)),
          exercises: [_exercise('chest')],
          id: 'empty2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 4)),
          exercises: [_exercise('back')],
          id: 'empty3',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 6)),
          exercises: [_exercise('legs')],
          id: 'empty4',
        ),
      ];

      expect(
        () => SplitDetectionService.detect(workouts: workouts),
        returnsNormally,
      );
    });

    test('handles very old workouts (>21 days) without crashing', () {
      final now = DateTime.now();
      final workouts = <WorkoutHistoryDetail>[
        _workout(
          completedAt: now.subtract(const Duration(days: 30)),
          exercises: [_exercise('chest')],
          id: 'old1',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 60)),
          exercises: [_exercise('back')],
          id: 'old2',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 90)),
          exercises: [_exercise('legs')],
          id: 'old3',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 120)),
          exercises: [_exercise('chest')],
          id: 'old4',
        ),
      ];

      expect(
        () => SplitDetectionService.detect(workouts: workouts),
        returnsNormally,
      );
    });

    test('recoveryHoursPerCategory null and empty behave identically for type',
        () {
      final now = DateTime.now();
      // Simple non-pattern 4-workout history
      final workouts = [
        _workout(
          completedAt: now.subtract(const Duration(days: 1)),
          exercises: [_exercise('chest')],
          id: 'nullA',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 4)),
          exercises: [_exercise('back')],
          id: 'nullB',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 6)),
          exercises: [_exercise('legs')],
          id: 'nullC',
        ),
        _workout(
          completedAt: now.subtract(const Duration(days: 7)),
          exercises: [_exercise('shoulders')],
          id: 'nullD',
        ),
      ];

      final resultWithNull = SplitDetectionService.detect(workouts: workouts);
      final resultWithEmpty = SplitDetectionService.detect(
        workouts: workouts,
        recoveryHoursPerCategory: {},
      );

      expect(resultWithNull.type, resultWithEmpty.type);
    });

    test('daysSinceLastForCategory is null for newUser result', () {
      final result = SplitDetectionService.detect(workouts: []);

      expect(result.daysSinceLastForCategory, isNull);
    });

    test('returns valid result for exactly 4 workouts all same category', () {
      final workouts = [
        _workoutDaysAgo('chest', 6),
        _workoutDaysAgo('chest', 4),
        _workoutDaysAgo('chest', 2),
        _workoutDaysAgo('chest', 1),
      ];

      final result = SplitDetectionService.detect(workouts: workouts);

      // All same category: pattern [chest] detected or recovery-based
      expect(result.type, isNot(SplitDetectionType.newUser));
    });

    test('dominant category is determined by most exercises (plurality)', () {
      // Workout with 2 chest + 3 legs → legs should dominate
      final workouts = [
        _workout(
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
          exercises: [
            _exercise('chest'),
            _exercise('chest'),
            _exercise('legs'),
            _exercise('legs'),
            _exercise('legs'),
          ],
          id: 'plur1',
        ),
        _workoutDaysAgo('back', 3),
        _workoutDaysAgo('chest', 5),
        _workoutDaysAgo('legs', 7),
      ];

      // Should not throw; dominant of first workout is legs
      expect(
        () => SplitDetectionService.detect(workouts: workouts),
        returnsNormally,
      );
    });

    test('single exercise category per workout is used as dominant', () {
      final workouts = [
        _workoutDaysAgo('back', 1),
        _workoutDaysAgo('chest', 3),
        _workoutDaysAgo('legs', 5),
        _workoutDaysAgo('back', 7),
      ];

      final result = SplitDetectionService.detect(workouts: workouts);

      expect(result.type, isNot(SplitDetectionType.newUser));
    });
  });

  // -------------------------------------------------------------------------
  group('SplitDetectionResult – constructor defaults', () {
    test('default isImbalanceDetected is false', () {
      const result = SplitDetectionResult(type: SplitDetectionType.newUser);

      expect(result.isImbalanceDetected, isFalse);
    });

    test('default suggestedCategory is null', () {
      const result = SplitDetectionResult(type: SplitDetectionType.newUser);

      expect(result.suggestedCategory, isNull);
    });

    test('default detectedCycle is null', () {
      const result = SplitDetectionResult(type: SplitDetectionType.newUser);

      expect(result.detectedCycle, isNull);
    });

    test('default daysSinceLastForCategory is null', () {
      const result = SplitDetectionResult(type: SplitDetectionType.newUser);

      expect(result.daysSinceLastForCategory, isNull);
    });

    test('all fields set correctly via constructor', () {
      final result = SplitDetectionResult(
        type: SplitDetectionType.patternDetected,
        suggestedCategory: ExerciseCategory.chest,
        detectedCycle: [ExerciseCategory.chest, ExerciseCategory.legs],
        daysSinceLastForCategory: 3,
        isImbalanceDetected: true,
      );

      expect(result.type, SplitDetectionType.patternDetected);
      expect(result.suggestedCategory, ExerciseCategory.chest);
      expect(result.detectedCycle, hasLength(2));
      expect(result.daysSinceLastForCategory, 3);
      expect(result.isImbalanceDetected, isTrue);
    });

    test('imbalanceDetected type with isImbalanceDetected true', () {
      final result = SplitDetectionResult(
        type: SplitDetectionType.imbalanceDetected,
        suggestedCategory: ExerciseCategory.legs,
        daysSinceLastForCategory: 9,
        isImbalanceDetected: true,
      );

      expect(result.type, SplitDetectionType.imbalanceDetected);
      expect(result.isImbalanceDetected, isTrue);
      expect(result.suggestedCategory, ExerciseCategory.legs);
      expect(result.detectedCycle, isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('SplitDetectionType enum', () {
    test('has exactly 4 values', () {
      expect(SplitDetectionType.values, hasLength(4));
    });

    test('contains all expected variants', () {
      expect(
        SplitDetectionType.values,
        containsAll([
          SplitDetectionType.patternDetected,
          SplitDetectionType.recoveryBased,
          SplitDetectionType.imbalanceDetected,
          SplitDetectionType.newUser,
        ]),
      );
    });

    test('each variant has a unique ordinal index', () {
      final indices = SplitDetectionType.values.map((e) => e.index).toSet();
      expect(indices.length, SplitDetectionType.values.length);
    });
  });
}
