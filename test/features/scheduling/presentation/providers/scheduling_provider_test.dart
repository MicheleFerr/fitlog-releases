import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/scheduling/data/services/scheduling_notification_service.dart';
import 'package:gymbro_flutter_new/features/scheduling/domain/entities/scheduled_workout.dart';
import 'package:gymbro_flutter_new/features/scheduling/domain/repositories/scheduling_repository.dart';
import 'package:gymbro_flutter_new/features/scheduling/presentation/providers/scheduling_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

class _FakeSchedulingRepository implements SchedulingRepository {
  final List<ScheduledWorkout> storedWorkouts = [];
  Object? scheduleMultipleError;

  @override
  Future<List<ScheduledWorkout>> getScheduledWorkouts() async =>
      List.unmodifiable(storedWorkouts);

  @override
  Future<List<ScheduledWorkout>> getScheduledWorkoutsForDate(
    DateTime date,
  ) async {
    return storedWorkouts
        .where(
          (workout) =>
              workout.scheduledDate.year == date.year &&
              workout.scheduledDate.month == date.month &&
              workout.scheduledDate.day == date.day,
        )
        .toList();
  }

  @override
  Future<List<ScheduledWorkout>> getScheduledWorkoutsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return storedWorkouts
        .where(
          (workout) =>
              !workout.scheduledDate.isBefore(startDate) &&
              !workout.scheduledDate.isAfter(endDate),
        )
        .toList();
  }

  @override
  Future<List<ScheduledWorkout>> getScheduledWorkoutsForTemplate(
    String templateId,
  ) async {
    return storedWorkouts
        .where((workout) => workout.templateId == templateId)
        .toList();
  }

  @override
  Future<ScheduledWorkout?> getScheduledWorkout(String id) async {
    for (final workout in storedWorkouts) {
      if (workout.id == id) return workout;
    }
    return null;
  }

  @override
  Future<List<ScheduledWorkout>> getUpcomingScheduledWorkouts() async {
    return storedWorkouts
        .where((workout) => workout.status == ScheduleStatus.pending)
        .toList();
  }

  @override
  Future<void> scheduleWorkout(ScheduledWorkout workout) async {
    storedWorkouts.add(workout);
  }

  @override
  Future<void> scheduleMultipleWorkouts(List<ScheduledWorkout> workouts) async {
    if (scheduleMultipleError != null) {
      throw scheduleMultipleError!;
    }
    storedWorkouts.addAll(workouts);
  }

  @override
  Future<void> updateSchedule(ScheduledWorkout workout) async {
    await deleteSchedule(workout.id);
    storedWorkouts.add(workout);
  }

  @override
  Future<void> deleteSchedule(String id) async {
    storedWorkouts.removeWhere((workout) => workout.id == id);
  }

  @override
  Future<void> deleteSchedulesForTemplate(String templateId) async {
    storedWorkouts.removeWhere((workout) => workout.templateId == templateId);
  }

  @override
  Future<void> markAsCompleted(String id, {DateTime? completedAt}) async {}

  @override
  Future<void> markAsSkipped(String id) async {}

  @override
  Future<void> markAsMissed(String id) async {}

  @override
  Future<void> updateMissedWorkouts() async {}

  @override
  Future<bool> hasScheduleForDate({
    required String templateId,
    required DateTime date,
  }) async {
    return storedWorkouts.any(
      (workout) =>
          workout.templateId == templateId &&
          workout.scheduledDate.year == date.year &&
          workout.scheduledDate.month == date.month &&
          workout.scheduledDate.day == date.day,
    );
  }

  @override
  Future<List<DateTime>> getScheduledDatesForTemplate(String templateId) async {
    return storedWorkouts
        .where((workout) => workout.templateId == templateId)
        .map((workout) => workout.scheduledDate)
        .toList();
  }
}

class _FakeSchedulingNotificationService extends SchedulingNotificationService {
  List<ScheduledWorkout> scheduledWorkouts = const [];
  List<String> canceledWorkoutIds = [];
  Object? scheduleMultipleError;

  @override
  Future<void> initialize() async {}

  @override
  Future<Map<String, int>> scheduleMultipleReminders({
    required List<ScheduledWorkout> workouts,
    required String Function(ScheduledWorkout workout) titleBuilder,
    required String Function(ScheduledWorkout workout) bodyBuilder,
  }) async {
    if (scheduleMultipleError != null) {
      throw scheduleMultipleError!;
    }
    scheduledWorkouts = List.unmodifiable(workouts);
    return {
      for (final workout in workouts) workout.id: workout.id.hashCode.abs(),
    };
  }

  @override
  Future<void> cancelReminder(String workoutId) async {
    canceledWorkoutIds = [...canceledWorkoutIds, workoutId];
  }
}

Future<AppLocalizations> _loadL10n() {
  return AppLocalizations.delegate.load(const Locale('en'));
}

ProviderContainer _buildContainer({
  required SchedulingRepository repository,
  required SchedulingNotificationService notificationService,
}) {
  final container = ProviderContainer(
    overrides: [
      schedulingRepositoryProvider.overrideWith((ref) => repository),
      schedulingNotificationServiceProvider.overrideWith(
        (ref) => notificationService,
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('SchedulingNotifier.scheduleWorkouts', () {
    test('stores workouts and refreshes state on success', () async {
      final repository = _FakeSchedulingRepository();
      final notifications = _FakeSchedulingNotificationService();
      final l10n = await _loadL10n();
      final container = _buildContainer(
        repository: repository,
        notificationService: notifications,
      );

      container.read(schedulingProvider);
      await Future<void>.delayed(Duration.zero);

      final scheduledWorkouts = await container
          .read(schedulingProvider.notifier)
          .scheduleWorkouts(
            templateId: 'template-1',
            templateName: 'Push Day',
            selectedDates: [DateTime(2026, 3, 10), DateTime(2026, 3, 12)],
            reminderTime: const TimeOfDay(hour: 8, minute: 30),
            l10n: l10n,
          );

      final state = container.read(schedulingProvider);

      expect(repository.storedWorkouts, hasLength(2));
      expect(notifications.scheduledWorkouts, hasLength(2));
      expect(scheduledWorkouts, hasLength(2));
      expect(
        repository.storedWorkouts.every(
          (workout) => workout.notificationId != null,
        ),
        isTrue,
      );
      expect(state.scheduledWorkouts, hasLength(2));
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('cancels notifications when persistence fails', () async {
      final repository = _FakeSchedulingRepository()
        ..scheduleMultipleError = StateError('save failed');
      final notifications = _FakeSchedulingNotificationService();
      final l10n = await _loadL10n();
      final container = _buildContainer(
        repository: repository,
        notificationService: notifications,
      );

      container.read(schedulingProvider);
      await Future<void>.delayed(Duration.zero);

      await expectLater(
        container
            .read(schedulingProvider.notifier)
            .scheduleWorkouts(
              templateId: 'template-1',
              templateName: 'Push Day',
              selectedDates: [DateTime(2026, 3, 10)],
              reminderTime: const TimeOfDay(hour: 8, minute: 30),
              l10n: l10n,
            ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'save failed',
          ),
        ),
      );

      final state = container.read(schedulingProvider);

      expect(state.isLoading, isFalse);
      expect(state.error, isA<StateError>());
      expect(repository.storedWorkouts, isEmpty);
      expect(notifications.scheduledWorkouts, hasLength(1));
      expect(notifications.canceledWorkoutIds, hasLength(1));
    });

    test(
      'does not persist workouts when notification scheduling fails',
      () async {
        final repository = _FakeSchedulingRepository();
        final notifications = _FakeSchedulingNotificationService()
          ..scheduleMultipleError = const SchedulingNotificationException(
            SchedulingNotificationExceptionType.notificationsDisabled,
          );
        final l10n = await _loadL10n();
        final container = _buildContainer(
          repository: repository,
          notificationService: notifications,
        );

        container.read(schedulingProvider);
        await Future<void>.delayed(Duration.zero);

        await expectLater(
          container
              .read(schedulingProvider.notifier)
              .scheduleWorkouts(
                templateId: 'template-1',
                templateName: 'Push Day',
                selectedDates: [DateTime(2026, 3, 10)],
                reminderTime: const TimeOfDay(hour: 8, minute: 30),
                l10n: l10n,
              ),
          throwsA(isA<SchedulingNotificationException>()),
        );

        final state = container.read(schedulingProvider);

        expect(state.isLoading, isFalse);
        expect(state.error, isA<SchedulingNotificationException>());
        expect(repository.storedWorkouts, isEmpty);
        expect(notifications.scheduledWorkouts, isEmpty);
        expect(notifications.canceledWorkoutIds, isEmpty);
      },
    );

    test('rejects reminders scheduled in the past for today', () async {
      final repository = _FakeSchedulingRepository();
      final notifications = _FakeSchedulingNotificationService();
      final l10n = await _loadL10n();
      final container = _buildContainer(
        repository: repository,
        notificationService: notifications,
      );

      container.read(schedulingProvider);
      await Future<void>.delayed(Duration.zero);

      final pastTime = TimeOfDay.fromDateTime(
        DateTime.now().subtract(const Duration(minutes: 5)),
      );

      await expectLater(
        container
            .read(schedulingProvider.notifier)
            .scheduleWorkouts(
              templateId: 'template-1',
              templateName: 'Push Day',
              selectedDates: [DateTime.now()],
              reminderTime: pastTime,
              l10n: l10n,
            ),
        throwsA(
          isA<SchedulingNotificationException>().having(
            (error) => error.type,
            'type',
            SchedulingNotificationExceptionType.reminderTimeInPast,
          ),
        ),
      );

      final state = container.read(schedulingProvider);
      expect(state.isLoading, isFalse);
      expect(state.error, isA<SchedulingNotificationException>());
      expect(repository.storedWorkouts, isEmpty);
      expect(notifications.scheduledWorkouts, isEmpty);
    });
  });
}
