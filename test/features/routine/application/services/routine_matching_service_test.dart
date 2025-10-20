import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/routine/application/services/routine_matching_service.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

void main() {
  group('RoutineMatchingService', () {
    late RoutineMatchingService service;

    setUp(() {
      service = RoutineMatchingService();
    });

    group('analyzeWorkoutForRoutine', () {
      test('returns noTemplate when workout has no templateId', () async {
        final workout = _createWorkout(templateId: null);
        final routine = _createRoutine();

        final result = await service.analyzeWorkoutForRoutine(
          completedWorkout: workout,
          activeRoutine: routine,
          completionTime: DateTime.now(),
        );

        expect(result, isA<_NoTemplate>());
      });

      test('returns noTemplate when workout templateId is empty', () async {
        final workout = _createWorkout(templateId: '');
        final routine = _createRoutine();

        final result = await service.analyzeWorkoutForRoutine(
          completedWorkout: workout,
          activeRoutine: routine,
          completionTime: DateTime.now(),
        );

        expect(result, isA<_NoTemplate>());
      });

      test('returns noMatch when no days match the template', () async {
        final now = DateTime.now();
        final workout = _createWorkout(templateId: 'unknown_template');
        final routine = _createRoutine(
          schedule: {
            'day1': _createScheduledDay(
              date: now,
              templateId: 'leg_template',
            ),
          },
        );

        final result = await service.analyzeWorkoutForRoutine(
          completedWorkout: workout,
          activeRoutine: routine,
          completionTime: now,
        );

        expect(result, isA<_NoMatch>());
      });

      test('returns simpleMatch when single day matches', () async {
        final now = DateTime.now();
        final matchDate = now;
        final workout = _createWorkout(templateId: 'leg_template');
        final routine = _createRoutine(
          schedule: {
            'day1': _createScheduledDay(
              date: matchDate,
              templateId: 'leg_template',
            ),
          },
        );

        final result = await service.analyzeWorkoutForRoutine(
          completedWorkout: workout,
          activeRoutine: routine,
          completionTime: now,
        );

        expect(result, isA<_SimpleMatch>());
      });

      test('returns simpleMatch with correct date', () async {
        final now = DateTime.now();
        final matchDate = now.add(const Duration(days: 1));
        final workout = _createWorkout(templateId: 'leg_template');
        final routine = _createRoutine(
          schedule: {
            'day1': _createScheduledDay(
              date: matchDate,
              templateId: 'leg_template',
            ),
          },
        );

        final result = await service.analyzeWorkoutForRoutine(
          completedWorkout: workout,
          activeRoutine: routine,
          completionTime: now,
        );

        expect(result, isA<_SimpleMatch>());
        if (result is _SimpleMatch) {
          expect(result.matchedDate, equals(matchDate));
        }
      });

      test('ignores days outside ±14 day window', () async {
        final now = DateTime.now();
        final workout = _createWorkout(templateId: 'leg_template');
        final routine = _createRoutine(
          schedule: {
            'day1': _createScheduledDay(
              date: now.add(const Duration(days: 20)),
              templateId: 'leg_template',
            ),
          },
        );

        final result = await service.analyzeWorkoutForRoutine(
          completedWorkout: workout,
          activeRoutine: routine,
          completionTime: now,
        );

        expect(result, isA<_NoMatch>());
      });

      test('returns multipleMatches when multiple days match', () async {
        final now = DateTime.now();
        final workout = _createWorkout(templateId: 'leg_template');
        final routine = _createRoutine(
          schedule: {
            'day1': _createScheduledDay(
              date: now,
              templateId: 'leg_template',
            ),
            'day2': _createScheduledDay(
              date: now.add(const Duration(days: 7)),
              templateId: 'leg_template',
            ),
          },
        );

        final result = await service.analyzeWorkoutForRoutine(
          completedWorkout: workout,
          activeRoutine: routine,
          completionTime: now,
        );

        expect(result, isA<_MultipleMatches>());
      });

      test('returns swapOpportunity when smart swap detected', () async {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));

        final workout = _createWorkout(templateId: 'push_template');
        final routine = _createRoutine(
          schedule: {
            'today': _createScheduledDay(
              date: today,
              templateId: 'leg_template',
            ),
            'tomorrow': _createScheduledDay(
              date: tomorrow,
              templateId: 'push_template',
            ),
          },
        );

        final result = await service.analyzeWorkoutForRoutine(
          completedWorkout: workout,
          activeRoutine: routine,
          completionTime: now,
        );

        expect(result, isA<_SwapOpportunity>());
      });

      test('ignores non-actionable statuses', () async {
        final now = DateTime.now();
        final workout = _createWorkout(templateId: 'leg_template');
        final routine = _createRoutine(
          schedule: {
            'day1': _createScheduledDay(
              date: now,
              templateId: 'leg_template',
              status: DayStatus.completed,
            ),
          },
        );

        final result = await service.analyzeWorkoutForRoutine(
          completedWorkout: workout,
          activeRoutine: routine,
          completionTime: now,
        );

        expect(result, isA<_NoMatch>());
      });

      test('sorts candidates by proximity', () async {
        final now = DateTime.now();
        final day1 = now.add(const Duration(days: 7));
        final day2 = now;
        final day3 = now.add(const Duration(days: 14));

        final workout = _createWorkout(templateId: 'leg_template');
        final routine = _createRoutine(
          schedule: {
            'far': _createScheduledDay(
              date: day3,
              templateId: 'leg_template',
            ),
            'near': _createScheduledDay(
              date: day2,
              templateId: 'leg_template',
            ),
            'medium': _createScheduledDay(
              date: day1,
              templateId: 'leg_template',
            ),
          },
        );

        final result = await service.analyzeWorkoutForRoutine(
          completedWorkout: workout,
          activeRoutine: routine,
          completionTime: now,
        );

        expect(result, isA<_MultipleMatches>());
      });
    });

    group('when pattern matching', () {
      test('when() returns correct value for noTemplate', () async {
        final result = await service.analyzeWorkoutForRoutine(
          completedWorkout: _createWorkout(templateId: null),
          activeRoutine: _createRoutine(),
          completionTime: DateTime.now(),
        );

        final value = result.when(
          noTemplate: () => 'no_template',
          noMatch: () => 'no_match',
          simpleMatch: (_) => 'simple_match',
          multipleMatches: (_) => 'multiple_matches',
          swapOpportunity: (_) => 'swap_opportunity',
        );

        expect(value, equals('no_template'));
      });

      test('when() returns correct value for simpleMatch', () async {
        final now = DateTime.now();
        final result = await service.analyzeWorkoutForRoutine(
          completedWorkout: _createWorkout(templateId: 'leg_template'),
          activeRoutine: _createRoutine(
            schedule: {
              'day1': _createScheduledDay(
                date: now,
                templateId: 'leg_template',
              ),
            },
          ),
          completionTime: now,
        );

        final value = result.when(
          noTemplate: () => 'no_template',
          noMatch: () => 'no_match',
          simpleMatch: (_) => 'simple_match',
          multipleMatches: (_) => 'multiple_matches',
          swapOpportunity: (_) => 'swap_opportunity',
        );

        expect(value, equals('simple_match'));
      });
    });

    group('result type checking', () {
      test('isSimpleMatch returns true for simpleMatch', () async {
        final now = DateTime.now();
        final result = await service.analyzeWorkoutForRoutine(
          completedWorkout: _createWorkout(templateId: 'leg_template'),
          activeRoutine: _createRoutine(
            schedule: {
              'day1': _createScheduledDay(
                date: now,
                templateId: 'leg_template',
              ),
            },
          ),
          completionTime: now,
        );

        expect(result.isSimpleMatch, true);
        expect(result.hasSwapOpportunity, false);
        expect(result.hasMultipleCandidates, false);
      });
    });
  });
}

// Helper functions
Workout _createWorkout({
  String? templateId,
  DateTime? endTime,
}) {
  return Workout(
    id: 'test_workout_${DateTime.now().millisecondsSinceEpoch}',
    userId: 'test_user',
    templateId: templateId,
    date: DateTime.now(),
    startTime: DateTime.now(),
    endTime: endTime ?? DateTime.now(),
    exercises: const [],
    notes: '',
    isCompleted: false,
    totalDuration: const Duration(),
  );
}

FlexibleRoutine _createRoutine({
  Map<String, ScheduledDay>? schedule,
}) {
  return FlexibleRoutine(
    id: 'test_routine_${DateTime.now().millisecondsSinceEpoch}',
    userId: 'test_user',
    name: 'Test Routine',
    type: RoutineType.weekly,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 90)),
    pattern: RoutinePattern.weekly(
      daysWithWorkouts: const [true, true, false, true, false, true, false],
    ),
    schedule: schedule ?? {},
    skipTracker: const SkipTracker(),
    recoverySettings: const RecoverySettings(),
  );
}

ScheduledDay _createScheduledDay({
  required DateTime date,
  required String templateId,
  DayStatus status = DayStatus.scheduled,
}) {
  return ScheduledDay(
    date: date,
    status: status,
    templateId: templateId,
  );
}
