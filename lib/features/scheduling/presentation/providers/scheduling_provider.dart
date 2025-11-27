import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/scheduling/data/repositories/scheduling_repository_impl.dart';
import 'package:gymbro_flutter_new/features/scheduling/data/services/scheduling_notification_service.dart';
import 'package:gymbro_flutter_new/features/scheduling/domain/entities/scheduled_workout.dart';
import 'package:gymbro_flutter_new/features/scheduling/domain/repositories/scheduling_repository.dart';
import 'package:gymbro_flutter_new/features/scheduling/services/schedule_live_activity_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:uuid/uuid.dart';

/// Provider for the scheduling repository
final schedulingRepositoryProvider = Provider<SchedulingRepository>((ref) {
  return SchedulingRepositoryImpl();
});

/// Provider for the scheduling notification service
final schedulingNotificationServiceProvider =
    Provider<SchedulingNotificationService>((ref) {
  return SchedulingNotificationService();
});

/// Provider for the schedule Live Activity service
final scheduleLiveActivityServiceProvider =
    Provider<ScheduleLiveActivityService>((ref) {
  return ScheduleLiveActivityService.instance;
});

/// State class for scheduling
class SchedulingState {
  const SchedulingState({
    this.scheduledWorkouts = const [],
    this.isLoading = false,
    this.error,
  });

  final List<ScheduledWorkout> scheduledWorkouts;
  final bool isLoading;
  final Object? error;

  SchedulingState copyWith({
    List<ScheduledWorkout>? scheduledWorkouts,
    bool? isLoading,
    Object? error,
  }) {
    return SchedulingState(
      scheduledWorkouts: scheduledWorkouts ?? this.scheduledWorkouts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing scheduled workouts
class SchedulingNotifier extends StateNotifier<SchedulingState> {
  SchedulingNotifier(
    this._repository,
    this._notificationService,
    this._liveActivityService,
  ) : super(const SchedulingState());

  final SchedulingRepository _repository;
  final SchedulingNotificationService _notificationService;
  final ScheduleLiveActivityService _liveActivityService;
  final _uuid = const Uuid();

  /// Threshold for starting Live Activity (minutes before workout)
  static const int _liveActivityThresholdMinutes = 120; // 2 hours before

  /// Initialize and load scheduled workouts
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Update missed workouts on load
      await _repository.updateMissedWorkouts();

      final workouts = await _repository.getScheduledWorkouts();
      state = state.copyWith(
        scheduledWorkouts: workouts,
        isLoading: false,
      );

      // Check for upcoming workouts and start Live Activity if needed
      await _checkAndStartLiveActivity();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  /// Check for upcoming workouts and start Live Activity if within threshold
  Future<void> _checkAndStartLiveActivity() async {
    if (!Platform.isIOS) return;

    final upcoming = await _repository.getUpcomingScheduledWorkouts();
    if (upcoming.isEmpty) return;

    // Find the next workout within the threshold
    final now = DateTime.now();
    final nextWorkout = upcoming.firstWhere(
      (w) {
        final minutesUntil =
            w.reminderDateTime.difference(now).inMinutes;
        return minutesUntil > 0 &&
            minutesUntil <= _liveActivityThresholdMinutes;
      },
      orElse: () => upcoming.first,
    );

    final minutesUntil =
        nextWorkout.reminderDateTime.difference(now).inMinutes;

    // Only start Live Activity if within threshold
    if (minutesUntil > 0 && minutesUntil <= _liveActivityThresholdMinutes) {
      await _liveActivityService.startScheduleLiveActivity(
        workoutName: nextWorkout.templateName,
        workoutId: nextWorkout.templateId,
        scheduledTime: nextWorkout.reminderDateTime,
        reminderTime: nextWorkout.reminderDateTime,
      );
    }
  }

  /// Start Live Activity for a specific workout
  Future<void> startLiveActivityForWorkout(ScheduledWorkout workout) async {
    if (!Platform.isIOS) return;

    await _liveActivityService.startScheduleLiveActivity(
      workoutName: workout.templateName,
      workoutId: workout.templateId,
      scheduledTime: workout.reminderDateTime,
      reminderTime: workout.reminderDateTime,
    );
  }

  /// Stop any active schedule Live Activity
  Future<void> stopLiveActivity() async {
    if (!Platform.isIOS) return;
    await _liveActivityService.endScheduleLiveActivity();
  }

  /// Schedule workouts for multiple dates
  Future<void> scheduleWorkouts({
    required String templateId,
    required String templateName,
    required List<DateTime> selectedDates,
    required TimeOfDay reminderTime,
    required AppLocalizations l10n,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final workouts = <ScheduledWorkout>[];

      for (final date in selectedDates) {
        final workout = ScheduledWorkout.create(
          id: _uuid.v4(),
          templateId: templateId,
          templateName: templateName,
          scheduledDate: date,
          reminderTime: reminderTime,
        );
        workouts.add(workout);
      }

      // Save to repository
      await _repository.scheduleMultipleWorkouts(workouts);

      // Schedule notifications
      await _notificationService.scheduleMultipleReminders(
        workouts: workouts,
        titleBuilder: (_) => l10n.workoutReminderTitle,
        bodyBuilder: (w) => l10n.workoutReminderBody(w.templateName),
      );

      // Refresh state
      final updated = await _repository.getScheduledWorkouts();
      state = state.copyWith(
        scheduledWorkouts: updated,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  /// Delete a scheduled workout
  Future<void> deleteSchedule(String id) async {
    try {
      // Cancel notification
      await _notificationService.cancelReminder(id);

      // Delete from repository
      await _repository.deleteSchedule(id);

      // Update state
      state = state.copyWith(
        scheduledWorkouts:
            state.scheduledWorkouts.where((w) => w.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e);
    }
  }

  /// Mark a scheduled workout as completed
  Future<void> markAsCompleted(String id) async {
    try {
      await _repository.markAsCompleted(id);

      // Update state
      final updated = await _repository.getScheduledWorkouts();
      state = state.copyWith(scheduledWorkouts: updated);
    } catch (e) {
      state = state.copyWith(error: e);
    }
  }

  /// Mark a scheduled workout as skipped
  Future<void> markAsSkipped(String id) async {
    try {
      // Cancel notification
      await _notificationService.cancelReminder(id);

      await _repository.markAsSkipped(id);

      // Update state
      final updated = await _repository.getScheduledWorkouts();
      state = state.copyWith(scheduledWorkouts: updated);
    } catch (e) {
      state = state.copyWith(error: e);
    }
  }

  /// Get scheduled dates for a template (for calendar disabling)
  Future<List<DateTime>> getScheduledDatesForTemplate(String templateId) async {
    return _repository.getScheduledDatesForTemplate(templateId);
  }

  /// Refresh the scheduled workouts list
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateMissedWorkouts();
      final updated = await _repository.getScheduledWorkouts();
      state = state.copyWith(
        scheduledWorkouts: updated,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }
}

/// Provider for scheduling state
final schedulingProvider =
    StateNotifierProvider<SchedulingNotifier, SchedulingState>((ref) {
  final repository = ref.watch(schedulingRepositoryProvider);
  final notificationService = ref.watch(schedulingNotificationServiceProvider);
  final liveActivityService = ref.watch(scheduleLiveActivityServiceProvider);
  final notifier = SchedulingNotifier(
    repository,
    notificationService,
    liveActivityService,
  );
  // Initialize on creation
  notifier.initialize();
  return notifier;
});

/// Provider for upcoming scheduled workouts only
final upcomingScheduledWorkoutsProvider =
    FutureProvider<List<ScheduledWorkout>>((ref) async {
  final repository = ref.watch(schedulingRepositoryProvider);
  await repository.updateMissedWorkouts();
  return repository.getUpcomingScheduledWorkouts();
});

/// Provider for today's scheduled workouts
final todaysScheduledWorkoutsProvider =
    FutureProvider<List<ScheduledWorkout>>((ref) async {
  final repository = ref.watch(schedulingRepositoryProvider);
  return repository.getScheduledWorkoutsForDate(DateTime.now());
});
