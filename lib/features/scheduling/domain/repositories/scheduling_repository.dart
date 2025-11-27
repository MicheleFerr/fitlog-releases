import 'package:gymbro_flutter_new/features/scheduling/domain/entities/scheduled_workout.dart';

/// Repository contract for managing scheduled workouts
abstract class SchedulingRepository {
  /// Get all scheduled workouts
  Future<List<ScheduledWorkout>> getScheduledWorkouts();

  /// Get scheduled workouts for a specific date
  Future<List<ScheduledWorkout>> getScheduledWorkoutsForDate(DateTime date);

  /// Get scheduled workouts for a date range
  Future<List<ScheduledWorkout>> getScheduledWorkoutsInRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get scheduled workouts for a specific template
  Future<List<ScheduledWorkout>> getScheduledWorkoutsForTemplate(String templateId);

  /// Get a single scheduled workout by ID
  Future<ScheduledWorkout?> getScheduledWorkout(String id);

  /// Get upcoming scheduled workouts (pending or due)
  Future<List<ScheduledWorkout>> getUpcomingScheduledWorkouts();

  /// Schedule a single workout
  Future<void> scheduleWorkout(ScheduledWorkout workout);

  /// Schedule multiple workouts at once (batch operation)
  Future<void> scheduleMultipleWorkouts(List<ScheduledWorkout> workouts);

  /// Update an existing scheduled workout
  Future<void> updateSchedule(ScheduledWorkout workout);

  /// Delete a scheduled workout
  Future<void> deleteSchedule(String id);

  /// Delete all scheduled workouts for a template
  Future<void> deleteSchedulesForTemplate(String templateId);

  /// Mark a scheduled workout as completed
  Future<void> markAsCompleted(String id, {DateTime? completedAt});

  /// Mark a scheduled workout as skipped
  Future<void> markAsSkipped(String id);

  /// Mark a scheduled workout as missed
  Future<void> markAsMissed(String id);

  /// Update status of past-due workouts to 'missed'
  /// Should be called on app startup or periodically
  Future<void> updateMissedWorkouts();

  /// Check if a date already has a scheduled workout for the given template
  Future<bool> hasScheduleForDate({
    required String templateId,
    required DateTime date,
  });

  /// Get all dates that have scheduled workouts for a template
  /// Useful for showing disabled dates in calendar picker
  Future<List<DateTime>> getScheduledDatesForTemplate(String templateId);
}
