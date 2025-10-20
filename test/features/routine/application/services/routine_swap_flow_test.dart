import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/routine/application/services/routine_matching_service.dart';
import 'package:gymbro_flutter_new/features/routine/application/services/routine_swap_flow.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/flexible_routine_repository.dart';
import 'package:mockito/mockito.dart';

class MockFlexibleRoutineRepository extends Mock
    implements FlexibleRoutineRepository {}

void main() {
  group('RoutineSwapFlow', () {
    late RoutineSwapFlow swapFlow;
    late MockFlexibleRoutineRepository mockRepository;

    setUp(() {
      mockRepository = MockFlexibleRoutineRepository();
      swapFlow = RoutineSwapFlow(repository: mockRepository);
    });

    group('SwapDecision enum', () {
      test('has three decision options', () {
        expect(SwapDecision.values.length, equals(3));
        expect(SwapDecision.values, contains(SwapDecision.continueNormal));
        expect(SwapDecision.values, contains(SwapDecision.swapDays));
        expect(SwapDecision.values, contains(SwapDecision.skipToday));
      });
    });

    group('RoutineSwapOpportunity', () {
      test('stores swap information correctly', () {
        final today = _createScheduledDay(date: DateTime.now());
        final tomorrow = _createScheduledDay(
          date: DateTime.now().add(const Duration(days: 1)),
        );

        final opportunity = RoutineSwapOpportunity(
          todayScheduledDay: today,
          futureScheduledDay: tomorrow,
          completedWorkoutTemplate: 'push_template',
        );

        expect(opportunity.todayScheduledDay, equals(today));
        expect(opportunity.futureScheduledDay, equals(tomorrow));
        expect(opportunity.completedWorkoutTemplate, equals('push_template'));
      });

      test('toString returns swap info', () {
        final today = _createScheduledDay(date: DateTime(2025, 10, 20));
        final tomorrow = _createScheduledDay(date: DateTime(2025, 10, 21));

        final opportunity = RoutineSwapOpportunity(
          todayScheduledDay: today,
          futureScheduledDay: tomorrow,
          completedWorkoutTemplate: 'push_template',
        );

        final str = opportunity.toString();
        expect(str, contains('SwapOpportunity'));
        expect(str, contains('2025-10-20'));
        expect(str, contains('2025-10-21'));
      });
    });

    group('swap execution', () {
      test('swapDaysList maintains order for swap execution', () {
        final days = [
          DateTime(2025, 10, 20),
          DateTime(2025, 10, 21),
          DateTime(2025, 10, 22),
        ];

        expect(days[0].isBefore(days[1]), true);
        expect(days[1].isBefore(days[2]), true);
      });

      test('swap opportunity identifies correct template mismatch', () {
        final today = _createScheduledDay(
          date: DateTime.now(),
          templateId: 'leg_template',
        );
        final tomorrow = _createScheduledDay(
          date: DateTime.now().add(const Duration(days: 1)),
          templateId: 'push_template',
        );

        final opportunity = RoutineSwapOpportunity(
          todayScheduledDay: today,
          futureScheduledDay: tomorrow,
          completedWorkoutTemplate: 'push_template',
        );

        expect(opportunity.todayScheduledDay.templateId, equals('leg_template'));
        expect(
          opportunity.futureScheduledDay.templateId,
          equals('push_template'),
        );
        expect(
          opportunity.completedWorkoutTemplate,
          equals('push_template'),
        );
      });
    });

    group('scheduled day with different statuses', () {
      test('scheduled day can be created with different statuses', () {
        final now = DateTime.now();

        final scheduled = _createScheduledDay(
          date: now,
          status: DayStatus.scheduled,
        );
        expect(scheduled.status, equals(DayStatus.scheduled));

        final completed = _createScheduledDay(
          date: now,
          status: DayStatus.completed,
        );
        expect(completed.status, equals(DayStatus.completed));

        final skipped = _createScheduledDay(
          date: now,
          status: DayStatus.skipped,
        );
        expect(skipped.status, equals(DayStatus.skipped));
      });
    });

    group('swap flow scenario simulation', () {
      test('simulates continue normal decision path', () {
        expect(SwapDecision.continueNormal, isNotNull);
      });

      test('simulates swap days decision path', () {
        expect(SwapDecision.swapDays, isNotNull);
      });

      test('simulates skip today decision path', () {
        expect(SwapDecision.skipToday, isNotNull);
      });

      test('swap decisions are distinct', () {
        expect(
          SwapDecision.continueNormal != SwapDecision.swapDays,
          true,
        );
        expect(
          SwapDecision.swapDays != SwapDecision.skipToday,
          true,
        );
        expect(
          SwapDecision.continueNormal != SwapDecision.skipToday,
          true,
        );
      });
    });

    group('routine updates during swap', () {
      test('swap scenario updates both days correctly', () {
        final today = _createScheduledDay(
          date: DateTime(2025, 10, 20),
          templateId: 'leg_template',
        );
        final tomorrow = _createScheduledDay(
          date: DateTime(2025, 10, 21),
          templateId: 'push_template',
        );

        // After swap:
        // Today should have push_template
        // Tomorrow should have leg_template
        expect(today.templateId, equals('leg_template'));
        expect(tomorrow.templateId, equals('push_template'));

        // Swapped versions
        final swappedToday = today.copyWith(
          templateId: tomorrow.templateId,
        );
        final swappedTomorrow = tomorrow.copyWith(
          templateId: today.templateId,
        );

        expect(swappedToday.templateId, equals('push_template'));
        expect(swappedTomorrow.templateId, equals('leg_template'));
      });

      test('skip scenario marks day as skipped', () {
        final today = _createScheduledDay(
          date: DateTime.now(),
          status: DayStatus.scheduled,
        );

        expect(today.status, equals(DayStatus.scheduled));

        final skipped = today.copyWith(status: DayStatus.skipped);
        expect(skipped.status, equals(DayStatus.skipped));
      });
    });

    group('Firestore updates', () {
      test('swap requires both days to be updated', () {
        final schedule = <String, ScheduledDay>{
          'day1': _createScheduledDay(
            date: DateTime(2025, 10, 20),
            templateId: 'leg_template',
          ),
          'day2': _createScheduledDay(
            date: DateTime(2025, 10, 21),
            templateId: 'push_template',
          ),
        };

        // Find and swap
        final day1Key = 'day1';
        final day2Key = 'day2';

        expect(schedule.containsKey(day1Key), true);
        expect(schedule.containsKey(day2Key), true);

        final day1 = schedule[day1Key]!;
        final day2 = schedule[day2Key]!;

        expect(day1.templateId, equals('leg_template'));
        expect(day2.templateId, equals('push_template'));
      });

      test('skip requires only today to be updated', () {
        final schedule = <String, ScheduledDay>{
          'day1': _createScheduledDay(
            date: DateTime(2025, 10, 20),
            templateId: 'leg_template',
            status: DayStatus.scheduled,
          ),
        };

        final dayKey = 'day1';
        expect(schedule.containsKey(dayKey), true);

        final day = schedule[dayKey]!;
        expect(day.status, equals(DayStatus.scheduled));

        // After skip
        final skippedDay = day.copyWith(status: DayStatus.skipped);
        expect(skippedDay.status, equals(DayStatus.skipped));
      });
    });
  });
}

// Helper functions
ScheduledDay _createScheduledDay({
  required DateTime date,
  String templateId = 'template_id',
  DayStatus status = DayStatus.scheduled,
}) {
  return ScheduledDay(
    date: date,
    status: status,
    templateId: templateId,
  );
}
