import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/day_detail_sheet.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/workout_selector_sheet.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/workout_selector_card.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_notifier.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'day_detail_sheet_test.mocks.dart';

@GenerateMocks([FlexibleRoutineNotifier])
void main() {
  group('DayDetailSheet - WorkoutSelector Integration', () {
    testWidgets('Complete button opens WorkoutSelectorSheet', (tester) async {
      final mockRoutine = FlexibleRoutine(
        id: 'routine-1',
        userId: 'user-1',
        name: 'Winter Arc',
        type: RoutineType.custom,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
        pattern: RoutinePattern(
          sequence: ['giorno-a'],
        ),
        schedule: {
          '2025-01-05': ScheduledDay(
            date: DateTime(2025, 1, 5),
            status: DayStatus.scheduled,
            templateId: 'giorno-a',
          ),
        },
        skipTracker: SkipTracker(
          skippedDays: {},
          recoveredDays: {},
        ),
        recoverySettings: RecoverySettings(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          flexibleRoutineNotifierProvider.overrideWith(
            () => MockFlexibleRoutineNotifier(),
          ),
          recentWorkoutsProvider(7).overrideWith((_) async => []),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: DayDetailSheet(
                routine: mockRoutine,
                date: DateTime(2025, 1, 5),
                dayInfo: mockRoutine.schedule['2025-01-05']!,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap Complete button
      final completeButton = find.text('Complete');
      expect(completeButton, findsOneWidget);

      await tester.tap(completeButton);
      await tester.pumpAndSettle();

      // Verify WorkoutSelectorSheet is visible
      expect(find.byType(WorkoutSelectorSheet), findsOneWidget);
      expect(find.text('Complete Day with Workout'), findsOneWidget);
    });

    testWidgets('WorkoutSelectorSheet completion with workout calls completeDayWorkout', (tester) async {
      // Test that selecting a workout calls the correct notifier method
      bool calledCompleteDayWorkout = false;
      String? capturedWorkoutId;

      final mockNotifier = MockFlexibleRoutineNotifier();
      when(mockNotifier.completeDayWorkout(
        routineId: anyNamed('routineId'),
        date: anyNamed('date'),
        workoutId: anyNamed('workoutId'),
      )).thenAnswer((invocation) async {
        calledCompleteDayWorkout = true;
        capturedWorkoutId = invocation.namedArguments[#workoutId] as String;
        return true;
      });

      final mockRoutine = FlexibleRoutine(
        id: 'routine-1',
        userId: 'user-1',
        name: 'Winter Arc',
        type: RoutineType.custom,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
        pattern: RoutinePattern(
          sequence: ['giorno-a'],
        ),
        schedule: {
          '2025-01-05': ScheduledDay(
            date: DateTime(2025, 1, 5),
            status: DayStatus.scheduled,
            templateId: 'giorno-a',
          ),
        },
        skipTracker: SkipTracker(
          skippedDays: {},
          recoveredDays: {},
        ),
        recoverySettings: RecoverySettings(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockWorkout = Workout(
        id: 'workout-1',
        name: 'Giorno A',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 45)),
        exercises: [],
        notes: null,
        templateId: 'giorno-a',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          flexibleRoutineNotifierProvider.overrideWith(() => mockNotifier),
          recentWorkoutsProvider(7).overrideWith((_) async => [mockWorkout]),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: DayDetailSheet(
                routine: mockRoutine,
                date: DateTime(2025, 1, 5),
                dayInfo: mockRoutine.schedule['2025-01-05']!,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Complete button
      await tester.tap(find.text('Complete'));
      await tester.pumpAndSettle();

      // Verify sheet opened
      expect(find.byType(WorkoutSelectorSheet), findsOneWidget);

      // Tap first workout card
      await tester.tap(find.byType(WorkoutSelectorCard).first);
      await tester.pumpAndSettle();

      // Verify completeDayWorkout was called
      expect(calledCompleteDayWorkout, true);
      expect(capturedWorkoutId, 'workout-1');

      // Verify success snackbar
      expect(find.text('Day completed with workout!'), findsOneWidget);
    });
  });
}
