/// Integration test for Consistency Score Provider
///
/// Tests full flow: Provider → Calculator → Entity → Widget
/// Scenarios: Optimal, Overtraining, Undertraining
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/providers/streak_provider.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/widgets/consistency_score_widget.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:mocktail/mocktail.dart';

// Mock WorkoutRepository
class MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  group('ConsistencyScoreProvider Integration Test', () {
    late MockWorkoutRepository mockWorkoutRepository;

    setUp(() {
      mockWorkoutRepository = MockWorkoutRepository();
    });

    testWidgets('Scenario 1: Optimal performance (3/3 ✅)', (tester) async {
      // GIVEN: Optimal workout pattern
      // - 10 workouts over 17 days = 4.1 workouts/week (optimal: 3-5)
      // - 17 - 10 = 7 rest days = 2.8 rest days/week (optimal: 2-3)
      // - 10% weight improvement (optimal: >5%)
      final optimalWorkouts = _createOptimalWorkouts();

      when(() => mockWorkoutRepository.getWorkouts())
          .thenAnswer((_) async => Right(optimalWorkouts));

      // WHEN: Widget is pumped with provider override
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutRepositoryProvider.overrideWithValue(mockWorkoutRepository),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ConsistencyScoreWidget(),
            ),
          ),
        ),
      );

      // Wait for provider to load
      await tester.pumpAndSettle();

      // THEN: Verify entity binary indicators
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ConsistencyScoreWidget)),
      );
      final scoreAsync = container.read(consistencyScoreProvider);

      expect(scoreAsync.hasValue, true, reason: 'Provider should have data');
      final score = scoreAsync.requireValue;

      expect(score.frequencyOptimal, true,
          reason: '4.1 workouts/week is optimal (3-5 range)');
      expect(score.restOptimal, true,
          reason: '2.8 rest days/week is optimal (2-3 range)');
      expect(score.progressionPositive, true,
          reason: '10% improvement is positive (>5% threshold)');

      // THEN: Verify widget rendering
      expect(find.text('Consistency Indicators'), findsOneWidget,
          reason: 'Card title should be visible');

      // Verify 4 green checkmark icons (3 indicators + 1 in badge)
      expect(find.byIcon(AppIcons.checkCircle), findsNWidgets(4),
          reason: 'All 3 indicators + badge should show green checkmarks');

      // Verify green badge (2+ optimal indicators)
      expect(find.textContaining('Doing well'), findsOneWidget,
          reason: 'Badge should show "Doing well!" for 3/3 optimal');
      expect(find.text('(3/3 ✅)'), findsOneWidget,
          reason: 'Badge should show 3/3 count');

      // Verify actual values displayed
      expect(find.textContaining('4.'), findsOneWidget,
          reason: 'Should show ~4.1 workouts/week');
      expect(find.textContaining('2.'), findsOneWidget,
          reason: 'Should show ~2.8 rest days/week');
    });

    testWidgets('Scenario 2: Overtraining pattern (0/3 ✅)', (tester) async {
      // GIVEN: Overtraining workout pattern
      // - 12 workouts over 14 days = 6 workouts/week (too many: >5)
      // - 14 - 12 = 2 rest days total = 1 rest day/week (too few: <2)
      // - -3% weight regression (negative progression)
      final overtrainingWorkouts = _createOvertrainingWorkouts();

      when(() => mockWorkoutRepository.getWorkouts())
          .thenAnswer((_) async => Right(overtrainingWorkouts));

      // WHEN: Widget is pumped
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutRepositoryProvider.overrideWithValue(mockWorkoutRepository),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ConsistencyScoreWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // THEN: Verify entity binary indicators (all false)
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ConsistencyScoreWidget)),
      );
      final scoreAsync = container.read(consistencyScoreProvider);
      final score = scoreAsync.requireValue;

      expect(score.frequencyOptimal, false,
          reason: '6 workouts/week is too many (>5 threshold)');
      expect(score.restOptimal, false,
          reason: '1 rest day/week is too few (<2 threshold)');
      expect(score.progressionPositive, false,
          reason: '-3% regression is negative (<5% threshold)');

      // THEN: Verify widget rendering (0 optimal)
      expect(find.byIcon(AppIcons.cancel), findsNWidgets(4),
          reason: 'All 3 indicators + badge should show red cancel icons');

      // Verify red badge (0 optimal indicators)
      expect(find.textContaining('Review your routine'), findsOneWidget,
          reason: 'Badge should show "Review your routine" for 0/3 optimal');
      expect(find.text('(0/3 ✅)'), findsOneWidget,
          reason: 'Badge should show 0/3 count');
    });

    testWidgets('Scenario 3: Undertraining pattern (1/3 ✅)', (tester) async {
      // GIVEN: Undertraining workout pattern
      // - 6 workouts over 30 days = 1.4 workouts/week (too few: <3)
      // - 30 - 6 = 24 rest days = 5.6 rest days/week (too many: >3)
      // - 8% weight improvement (optimal: >5%)
      final undertrainingWorkouts = _createUndertrainingWorkouts();

      when(() => mockWorkoutRepository.getWorkouts())
          .thenAnswer((_) async => Right(undertrainingWorkouts));

      // WHEN: Widget is pumped
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutRepositoryProvider.overrideWithValue(mockWorkoutRepository),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ConsistencyScoreWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // THEN: Verify entity binary indicators (only progression optimal)
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ConsistencyScoreWidget)),
      );
      final scoreAsync = container.read(consistencyScoreProvider);
      final score = scoreAsync.requireValue;

      expect(score.frequencyOptimal, false,
          reason: '1.4 workouts/week is too few (<3 threshold)');
      expect(score.restOptimal, false,
          reason: '5.6 rest days/week is too many (>3 threshold)');
      expect(score.progressionPositive, true,
          reason: '8% improvement is positive (>5% threshold)');

      // THEN: Verify widget rendering (1 optimal, 2 not optimal)
      expect(find.byIcon(AppIcons.checkCircle), findsOneWidget,
          reason: '1 indicator should show green checkmark (progression)');
      expect(find.byIcon(AppIcons.cancel), findsNWidgets(2),
          reason: '2 indicators should show red cancel icons (frequency, rest)');

      // Verify yellow badge (1 optimal indicator)
      expect(find.textContaining('Can improve'), findsOneWidget,
          reason: 'Badge should show "Can improve" for 1/3 optimal');
      expect(find.text('(1/3 ✅)'), findsOneWidget,
          reason: 'Badge should show 1/3 count');
    });
  });
}

/// Helper: Create optimal workout pattern
///
/// Pattern:
/// - 10 workouts over 17 days = 4.1 workouts/week (optimal: 3-5)
/// - 17 - 10 = 7 rest days = 2.8 rest days/week (optimal: 2-3)
/// - Weight progression: 50kg → 55kg = 10% improvement (optimal: >5%)
List<Workout> _createOptimalWorkouts() {
  const baseWeight = 50.0;
  final now = DateTime.now();

  // Days with workouts: [0, 2, 4, 5, 7, 9, 11, 13, 15, 16] (within 17-day period)
  // This gives ~4.1 workouts/week, 2.8 rest days/week
  const workoutDays = [0, 2, 4, 5, 7, 9, 11, 13, 15, 16];

  return workoutDays.asMap().entries.map((entry) {
    final index = entry.key;
    final daysAgo = 17 - entry.value;

    // Recent half (last 5 workouts) has 10% more weight
    final isRecentHalf = index >= 5;
    final weight = isRecentHalf ? baseWeight * 1.10 : baseWeight; // 55kg vs 50kg

    return Workout(
      id: 'workout_$index',
      name: 'Optimal Workout $index',
      status: WorkoutStatus.completed,
      exercises: [
        Exercise(
          id: 'exercise_$index',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(
              id: 'set_${index}_1',
              setNumber: 1,
              weight: weight,
              reps: 10,
              actualReps: 10,
              isCompleted: true,
              completedAt: now.subtract(Duration(days: daysAgo)),
            ),
            ExerciseSet(
              id: 'set_${index}_2',
              setNumber: 2,
              weight: weight,
              reps: 10,
              actualReps: 10,
              isCompleted: true,
              completedAt: now.subtract(Duration(days: daysAgo)),
            ),
            ExerciseSet(
              id: 'set_${index}_3',
              setNumber: 3,
              weight: weight,
              reps: 10,
              actualReps: 10,
              isCompleted: true,
              completedAt: now.subtract(Duration(days: daysAgo)),
            ),
          ],
        ),
      ],
      createdAt: now.subtract(Duration(days: daysAgo)),
      updatedAt: now.subtract(Duration(days: daysAgo)),
      startTime: now.subtract(Duration(days: daysAgo, hours: 1)),
      endTime: now.subtract(Duration(days: daysAgo)),
    );
  }).toList().cast<Workout>();
}

/// Helper: Create overtraining workout pattern
///
/// Pattern:
/// - 12 workouts over 14 days = 6 workouts/week (too many: >5)
/// - 14 - 12 = 2 rest days total = 1 rest day/week (too few: <2)
/// - Weight regression: 50kg → 48.5kg = -3% regression
List<Workout> _createOvertrainingWorkouts() {
  const baseWeight = 50.0;
  final now = DateTime.now();

  // Days with workouts: [0, 1, 3, 4, 5, 7, 8, 9, 10, 12, 13, 14] (within 14-day period)
  // This gives 6 workouts/week, 1 rest day/week
  const workoutDays = [0, 1, 3, 4, 5, 7, 8, 9, 10, 12, 13, 14];

  return workoutDays.asMap().entries.map((entry) {
    final index = entry.key;
    final daysAgo = 14 - entry.value;

    // Recent half has 3% less weight (regression from overtraining)
    final isRecentHalf = index >= 6;
    final weight = isRecentHalf ? baseWeight * 0.97 : baseWeight; // 48.5kg vs 50kg

    return Workout(
      id: 'workout_$index',
      name: 'Overtraining Workout $index',
      status: WorkoutStatus.completed,
      exercises: [
        Exercise(
          id: 'exercise_$index',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(
              id: 'set_${index}_1',
              setNumber: 1,
              weight: weight,
              reps: 8,
              actualReps: 8,
              isCompleted: true,
              completedAt: now.subtract(Duration(days: daysAgo)),
            ),
            ExerciseSet(
              id: 'set_${index}_2',
              setNumber: 2,
              weight: weight,
              reps: 7,
              actualReps: 7,
              isCompleted: true,
              completedAt: now.subtract(Duration(days: daysAgo)),
            ),
          ],
        ),
      ],
      createdAt: now.subtract(Duration(days: daysAgo)),
      updatedAt: now.subtract(Duration(days: daysAgo)),
      startTime: now.subtract(Duration(days: daysAgo, hours: 1)),
      endTime: now.subtract(Duration(days: daysAgo)),
    );
  }).toList().cast<Workout>();
}

/// Helper: Create undertraining workout pattern
///
/// Pattern:
/// - 6 workouts over 30 days = 1.4 workouts/week (too few: <3)
/// - 30 - 6 = 24 rest days = 5.6 rest days/week (too many: >3)
/// - Weight progression: 50kg → 54kg = 8% improvement (optimal: >5%)
List<Workout> _createUndertrainingWorkouts() {
  const baseWeight = 50.0;
  final now = DateTime.now();

  // Days with workouts: [0, 5, 10, 15, 20, 25] (within 30-day period)
  // This gives 1.4 workouts/week, 5.6 rest days/week
  const workoutDays = [0, 5, 10, 15, 20, 25];

  return workoutDays.asMap().entries.map((entry) {
    final index = entry.key;
    final daysAgo = 30 - entry.value;

    // Recent half (last 3 workouts) has 8% more weight
    final isRecentHalf = index >= 3;
    final weight = isRecentHalf ? baseWeight * 1.08 : baseWeight; // 54kg vs 50kg

    return Workout(
      id: 'workout_$index',
      name: 'Undertraining Workout $index',
      status: WorkoutStatus.completed,
      exercises: [
        Exercise(
          id: 'exercise_$index',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(
              id: 'set_${index}_1',
              setNumber: 1,
              weight: weight,
              reps: 10,
              actualReps: 10,
              isCompleted: true,
              completedAt: now.subtract(Duration(days: daysAgo)),
            ),
            ExerciseSet(
              id: 'set_${index}_2',
              setNumber: 2,
              weight: weight,
              reps: 10,
              actualReps: 10,
              isCompleted: true,
              completedAt: now.subtract(Duration(days: daysAgo)),
            ),
          ],
        ),
      ],
      createdAt: now.subtract(Duration(days: daysAgo)),
      updatedAt: now.subtract(Duration(days: daysAgo)),
      startTime: now.subtract(Duration(days: daysAgo, hours: 1)),
      endTime: now.subtract(Duration(days: daysAgo)),
    );
  }).toList().cast<Workout>();
}
