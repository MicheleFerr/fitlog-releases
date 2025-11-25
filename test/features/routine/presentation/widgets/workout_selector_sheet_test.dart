import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/workout_selector_sheet.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/workout_selector_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_pattern.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/skip_tracker.dart';

void main() {
  group('WorkoutSelectorSheet', () {
    final now = DateTime.now();
    final mockRoutine = FlexibleRoutine(
      id: 'routine-1',
      userId: 'user-1',
      name: 'Winter Arc',
      type: RoutineType.weekly,
      startDate: now,
      endDate: now.add(const Duration(days: 90)),
      pattern: const RoutinePattern(
        name: 'ABC Pattern',
        sequence: ['giorno-a', 'giorno-b', 'giorno-c'],
      ),
      schedule: {},
      skipTracker: const SkipTracker(
        skippedDays: {},
        recoveredDays: {},
      ),
      recoverySettings: RecoverySettings(),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final mockWorkouts = <Workout>[
      Workout(
        id: 'workout-1',
        name: 'Giorno A',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 45)),
        exercises: [],
        notes: null,
        templateId: 'giorno-a',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Workout(
        id: 'workout-2',
        name: 'Giorno B',
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(minutes: 50)),
        exercises: [],
        notes: null,
        templateId: 'giorno-b',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    testWidgets('shows workout list when data loaded', (tester) async {
      final container = ProviderContainer(
        overrides: [
          recentWorkoutsProvider(7).overrideWith((_) async => mockWorkouts),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSelectorSheet(
                routine: mockRoutine,
                date: DateTime(2025, 1, 5),
                templateId: 'giorno-a',
                onWorkoutSelected: (_) async {},
                onCompleteWithoutWorkout: () async {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header
      expect(find.text('Complete Day with Workout'), findsOneWidget);

      // Verify workout cards
      expect(find.byType(WorkoutSelectorCard), findsNWidgets(2));
    });

    testWidgets('shows empty state when no workouts', (tester) async {
      final container = ProviderContainer(
        overrides: [
          recentWorkoutsProvider(7).overrideWith((_) async => []),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSelectorSheet(
                routine: mockRoutine,
                date: DateTime(2025, 1, 5),
                templateId: 'giorno-a',
                onWorkoutSelected: (_) async {},
                onCompleteWithoutWorkout: () async {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No recent workouts found'), findsOneWidget);
      expect(find.text('Complete Day'), findsOneWidget);
    });

    testWidgets('highlights template match', (tester) async {
      final container = ProviderContainer(
        overrides: [
          recentWorkoutsProvider(7).overrideWith((_) async => mockWorkouts),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSelectorSheet(
                routine: mockRoutine,
                date: DateTime(2025, 1, 5),
                templateId: 'giorno-a', // Matches first workout
                onWorkoutSelected: (_) async {},
                onCompleteWithoutWorkout: () async {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find all WorkoutSelectorCard widgets
      final cards = tester.widgetList<WorkoutSelectorCard>(
        find.byType(WorkoutSelectorCard),
      ).toList();

      // First card should be a match
      expect(cards[0].isTemplateMatch, true);
      // Second card should not be a match
      expect(cards[1].isTemplateMatch, false);
    });

    testWidgets('calls onWorkoutSelected when card tapped', (tester) async {
      String? selectedWorkoutId;

      final container = ProviderContainer(
        overrides: [
          recentWorkoutsProvider(7).overrideWith((_) async => mockWorkouts),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSelectorSheet(
                routine: mockRoutine,
                date: DateTime(2025, 1, 5),
                templateId: 'giorno-a',
                onWorkoutSelected: (workoutId) async {
                  selectedWorkoutId = workoutId;
                },
                onCompleteWithoutWorkout: () async {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap first workout card
      await tester.tap(find.byType(WorkoutSelectorCard).first);
      await tester.pumpAndSettle();

      expect(selectedWorkoutId, 'workout-1');
    });

    testWidgets('shows loading indicator while fetching', (tester) async {
      final container = ProviderContainer(
        overrides: [
          recentWorkoutsProvider(7).overrideWith(
            (_) => Future.delayed(const Duration(seconds: 5), () => mockWorkouts),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSelectorSheet(
                routine: mockRoutine,
                date: DateTime(2025, 1, 5),
                templateId: 'giorno-a',
                onWorkoutSelected: (_) async {},
                onCompleteWithoutWorkout: () async {},
              ),
            ),
          ),
        ),
      );

      // Initial pump
      await tester.pump();

      // Verify loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state on fetch failure', (tester) async {
      final container = ProviderContainer(
        overrides: [
          recentWorkoutsProvider(7).overrideWith(
            (_) => Future.error(Exception('Network error')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSelectorSheet(
                routine: mockRoutine,
                date: DateTime(2025, 1, 5),
                templateId: 'giorno-a',
                onWorkoutSelected: (_) async {},
                onCompleteWithoutWorkout: () async {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Failed to load workouts'), findsOneWidget);
    });

    testWidgets('shows fallback button', (tester) async {
      bool completedWithoutWorkout = false;

      final container = ProviderContainer(
        overrides: [
          recentWorkoutsProvider(7).overrideWith((_) async => mockWorkouts),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSelectorSheet(
                routine: mockRoutine,
                date: DateTime(2025, 1, 5),
                templateId: 'giorno-a',
                onWorkoutSelected: (_) async {},
                onCompleteWithoutWorkout: () async {
                  completedWithoutWorkout = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap fallback button
      await tester.tap(find.text('Complete without workout'));
      await tester.pumpAndSettle();

      expect(completedWithoutWorkout, true);
    });
  });
}
