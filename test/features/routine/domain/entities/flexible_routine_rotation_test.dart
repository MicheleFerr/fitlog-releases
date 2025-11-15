import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_pattern.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/skip_tracker.dart';

void main() {
  group('FlexibleRoutine Template Rotation', () {
    test('should cycle back to first template after completing the last one', () {
      // Setup: Create a routine with 4 templates (A, B, C, D)
      final startDate = DateTime(2025, 1, 1);
      final endDate = DateTime(2025, 3, 31);

      final pattern = RoutinePattern.repeating(
        name: '4-Day Cycle',
        sequence: [
          'template-a',
          'template-b',
          'template-c',
          'template-d',
          'rest',
        ],
      );

      var routine = FlexibleRoutine(
        id: 'test-routine',
        userId: 'test-user',
        name: 'Test Rotation',
        type: RoutineType.custom,
        startDate: startDate,
        endDate: endDate,
        pattern: pattern,
        schedule: {},
        skipTracker: const SkipTracker(
          skippedDays: {},
          recoveredDays: {},
        ),
        recoverySettings: RecoverySettings.defaultSettings(),
        totalWorkoutDays: 0,
        completedDays: 0,
        isActive: true,
        isArchived: false,
        isCompleted: false,
        isSyncPending: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Generate the schedule
      routine = routine.generateSchedule();

      // Simulate completing workouts in the pattern:
      // Day 4: Template A
      routine = routine.completeDay(DateTime(2025, 1, 4), 'workout-a');

      // Day 7: Template B
      routine = routine.completeDay(DateTime(2025, 1, 7), 'workout-b');

      // Day 8: Template C
      routine = routine.completeDay(DateTime(2025, 1, 8), 'workout-c');

      // Day 10: Template D
      routine = routine.completeDay(DateTime(2025, 1, 10), 'workout-d');

      // Act: Get next uncompleted workout (should be Template A)
      final nextWorkout = routine.getNextUncompletedWorkout();

      // Debug output
      if (nextWorkout == null) {
        print('DEBUG: Next workout is null');
        print('DEBUG: Pattern sequence: ${pattern.sequence}');
        print('DEBUG: Pattern type: ${pattern.type}');
        print('DEBUG: Today: ${DateTime.now()}');

        // Check schedule
        final today = DateTime.now();
        for (int i = 0; i < 10; i++) {
          final checkDate = today.add(Duration(days: i));
          final day = routine.getScheduledDay(checkDate);
          if (day != null) {
            print('DEBUG: Day $checkDate - Template: ${day.templateId}, Status: ${day.status}');
          }
        }
      } else {
        print('DEBUG: Next workout template: ${nextWorkout.templateId}');
      }

      // Assert: Should suggest Template A (cycling back to start)
      expect(nextWorkout, isNotNull);
      expect(nextWorkout!.templateId, equals('template-a'));
    });

    test('should handle mid-cycle restart correctly', () {
      // Setup: Create a routine with 3 templates
      final startDate = DateTime(2025, 1, 1);
      final endDate = DateTime(2025, 3, 31);

      final pattern = RoutinePattern.repeating(
        name: '3-Day Cycle',
        sequence: [
          'template-a',
          'template-b',
          'template-c',
        ],
      );

      var routine = FlexibleRoutine(
        id: 'test-routine-2',
        userId: 'test-user',
        name: 'Test Mid-Cycle',
        type: RoutineType.custom,
        startDate: startDate,
        endDate: endDate,
        pattern: pattern,
        schedule: {},
        skipTracker: const SkipTracker(
          skippedDays: {},
          recoveredDays: {},
        ),
        recoverySettings: RecoverySettings.defaultSettings(),
        totalWorkoutDays: 0,
        completedDays: 0,
        isActive: true,
        isArchived: false,
        isCompleted: false,
        isSyncPending: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Generate the schedule
      routine = routine.generateSchedule();

      // Complete only B template
      routine = routine.completeDay(DateTime(2025, 1, 2), 'workout-b');

      // Act: Get next workout (should be Template C, continuing from B)
      final nextWorkout = routine.getNextUncompletedWorkout();

      // Assert: Should suggest Template C (next in sequence after B)
      expect(nextWorkout, isNotNull);
      expect(nextWorkout!.templateId, equals('template-c'));
    });

    test('should handle multiple cycle completions', () {
      // Setup: Create a routine with 2 templates
      final startDate = DateTime(2025, 1, 1);
      final endDate = DateTime(2025, 3, 31);

      final pattern = RoutinePattern.repeating(
        name: '2-Day Cycle',
        sequence: [
          'template-a',
          'template-b',
        ],
      );

      var routine = FlexibleRoutine(
        id: 'test-routine-3',
        userId: 'test-user',
        name: 'Test Multiple Cycles',
        type: RoutineType.custom,
        startDate: startDate,
        endDate: endDate,
        pattern: pattern,
        schedule: {},
        skipTracker: const SkipTracker(
          skippedDays: {},
          recoveredDays: {},
        ),
        recoverySettings: RecoverySettings.defaultSettings(),
        totalWorkoutDays: 0,
        completedDays: 0,
        isActive: true,
        isArchived: false,
        isCompleted: false,
        isSyncPending: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Generate the schedule
      routine = routine.generateSchedule();

      // Complete first full cycle
      routine = routine.completeDay(DateTime(2025, 1, 1), 'workout-a1');
      routine = routine.completeDay(DateTime(2025, 1, 2), 'workout-b1');

      // Complete second full cycle
      routine = routine.completeDay(DateTime(2025, 1, 3), 'workout-a2');
      routine = routine.completeDay(DateTime(2025, 1, 4), 'workout-b2');

      // Act: Get next workout (should be Template A again)
      final nextWorkout = routine.getNextUncompletedWorkout();

      // Assert: Should cycle back to Template A
      expect(nextWorkout, isNotNull);
      expect(nextWorkout!.templateId, equals('template-a'));
    });

    test('should return null when no uncompleted workouts exist', () {
      // Setup: Create a short routine
      final startDate = DateTime(2025, 1, 1);
      final endDate = DateTime(2025, 1, 5);

      final pattern = RoutinePattern.repeating(
        name: '2-Day Cycle',
        sequence: [
          'template-a',
          'template-b',
        ],
      );

      var routine = FlexibleRoutine(
        id: 'test-routine-4',
        userId: 'test-user',
        name: 'Test All Complete',
        type: RoutineType.custom,
        startDate: startDate,
        endDate: endDate,
        pattern: pattern,
        schedule: {},
        skipTracker: const SkipTracker(
          skippedDays: {},
          recoveredDays: {},
        ),
        recoverySettings: RecoverySettings.defaultSettings(),
        totalWorkoutDays: 0,
        completedDays: 0,
        isActive: true,
        isArchived: false,
        isCompleted: false,
        isSyncPending: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Generate the schedule
      routine = routine.generateSchedule();

      // Complete all workouts in the routine period
      routine = routine.completeDay(DateTime(2025, 1, 1), 'workout-a1');
      routine = routine.completeDay(DateTime(2025, 1, 2), 'workout-b1');
      routine = routine.completeDay(DateTime(2025, 1, 3), 'workout-a2');
      routine = routine.completeDay(DateTime(2025, 1, 4), 'workout-b2');
      routine = routine.completeDay(DateTime(2025, 1, 5), 'workout-a3');

      // Act: Get next workout
      final nextWorkout = routine.getNextUncompletedWorkout();

      // Assert: Should return null (all workouts completed)
      expect(nextWorkout, isNull);
    });
  });
}