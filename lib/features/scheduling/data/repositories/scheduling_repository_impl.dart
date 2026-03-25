import 'package:gymbro_flutter_new/features/scheduling/data/datasources/hive_scheduling_datasource.dart';
import 'package:gymbro_flutter_new/features/scheduling/data/models/scheduled_workout_model.dart';
import 'package:gymbro_flutter_new/features/scheduling/domain/entities/scheduled_workout.dart';
import 'package:gymbro_flutter_new/features/scheduling/domain/repositories/scheduling_repository.dart';

/// Implementation of SchedulingRepository using Hive for local storage
class SchedulingRepositoryImpl implements SchedulingRepository {

  SchedulingRepositoryImpl({HiveSchedulingDatasource? datasource})
    : _datasource = datasource ?? HiveSchedulingDatasource();
  final HiveSchedulingDatasource _datasource;

  @override
  Future<List<ScheduledWorkout>> getScheduledWorkouts() async {
    final models = await _datasource.getAllScheduledWorkouts();
    return models.map((m) => m.toEntity()).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  @override
  Future<List<ScheduledWorkout>> getScheduledWorkoutsForDate(
    DateTime date,
  ) async {
    final models = await _datasource.getScheduledWorkoutsForDate(date);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ScheduledWorkout>> getScheduledWorkoutsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final models = await _datasource.getScheduledWorkoutsInRange(
      startDate: startDate,
      endDate: endDate,
    );
    return models.map((m) => m.toEntity()).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  @override
  Future<List<ScheduledWorkout>> getScheduledWorkoutsForTemplate(
    String templateId,
  ) async {
    final models = await _datasource.getScheduledWorkoutsForTemplate(
      templateId,
    );
    return models.map((m) => m.toEntity()).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  @override
  Future<ScheduledWorkout?> getScheduledWorkout(String id) async {
    final model = await _datasource.getScheduledWorkout(id);
    return model?.toEntity();
  }

  @override
  Future<List<ScheduledWorkout>> getUpcomingScheduledWorkouts() async {
    final models = await _datasource.getUpcomingScheduledWorkouts();
    return models.map((m) => m.toEntity()).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  @override
  Future<void> scheduleWorkout(ScheduledWorkout workout) async {
    final model = ScheduledWorkoutModel.fromEntity(workout);
    await _datasource.saveScheduledWorkout(model);
  }

  @override
  Future<void> scheduleMultipleWorkouts(List<ScheduledWorkout> workouts) async {
    final models = workouts
        .map((w) => ScheduledWorkoutModel.fromEntity(w))
        .toList();
    await _datasource.saveScheduledWorkouts(models);
  }

  @override
  Future<void> updateSchedule(ScheduledWorkout workout) async {
    final model = ScheduledWorkoutModel.fromEntity(workout);
    await _datasource.updateScheduledWorkout(model);
  }

  @override
  Future<void> deleteSchedule(String id) async {
    await _datasource.deleteScheduledWorkout(id);
  }

  @override
  Future<void> deleteSchedulesForTemplate(String templateId) async {
    await _datasource.deleteScheduledWorkoutsForTemplate(templateId);
  }

  @override
  Future<void> markAsCompleted(String id, {DateTime? completedAt}) async {
    final existing = await _datasource.getScheduledWorkout(id);
    if (existing == null) return;

    final updated = existing.copyWith(
      status: ScheduleStatusModel.completed,
      completedAt: completedAt ?? DateTime.now(),
    );
    await _datasource.updateScheduledWorkout(updated);
  }

  @override
  Future<void> markAsSkipped(String id) async {
    final existing = await _datasource.getScheduledWorkout(id);
    if (existing == null) return;

    final updated = existing.copyWith(status: ScheduleStatusModel.skipped);
    await _datasource.updateScheduledWorkout(updated);
  }

  @override
  Future<void> markAsMissed(String id) async {
    final existing = await _datasource.getScheduledWorkout(id);
    if (existing == null) return;

    final updated = existing.copyWith(status: ScheduleStatusModel.missed);
    await _datasource.updateScheduledWorkout(updated);
  }

  @override
  Future<void> updateMissedWorkouts() async {
    final allWorkouts = await _datasource.getAllScheduledWorkouts();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final workout in allWorkouts) {
      if (workout.status == ScheduleStatusModel.completed ||
          workout.status == ScheduleStatusModel.skipped ||
          workout.status == ScheduleStatusModel.missed) {
        continue;
      }

      final scheduleDate = DateTime(
        workout.scheduledDate.year,
        workout.scheduledDate.month,
        workout.scheduledDate.day,
      );

      if (scheduleDate.isBefore(today)) {
        final updated = workout.copyWith(status: ScheduleStatusModel.missed);
        await _datasource.updateScheduledWorkout(updated);
      } else if (scheduleDate.isAtSameMomentAs(today)) {
        final updated = workout.copyWith(status: ScheduleStatusModel.due);
        await _datasource.updateScheduledWorkout(updated);
      }
    }
  }

  @override
  Future<bool> hasScheduleForDate({
    required String templateId,
    required DateTime date,
  }) async {
    return _datasource.hasScheduleForDate(templateId: templateId, date: date);
  }

  @override
  Future<List<DateTime>> getScheduledDatesForTemplate(String templateId) async {
    return _datasource.getScheduledDatesForTemplate(templateId);
  }
}
