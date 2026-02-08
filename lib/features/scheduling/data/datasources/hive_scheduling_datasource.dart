import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';
import 'package:gymbro_flutter_new/features/scheduling/data/models/scheduled_workout_model.dart';
import 'package:hive_ce/hive.dart';

/// Local datasource for scheduled workouts using Hive
class HiveSchedulingDatasource {
  static const String boxName = HiveBoxNames.scheduledWorkouts;

  /// Get or open the Hive box
  Future<Box<ScheduledWorkoutModel>> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<ScheduledWorkoutModel>(boxName);
    }
    return Hive.openBox<ScheduledWorkoutModel>(boxName);
  }

  /// Save a single scheduled workout
  Future<void> saveScheduledWorkout(ScheduledWorkoutModel model) async {
    final box = await _getBox();
    await box.put(model.id, model);
  }

  /// Save multiple scheduled workouts
  Future<void> saveScheduledWorkouts(List<ScheduledWorkoutModel> models) async {
    final box = await _getBox();
    final Map<String, ScheduledWorkoutModel> entries = {
      for (final model in models) model.id: model,
    };
    await box.putAll(entries);
  }

  /// Get all scheduled workouts
  Future<List<ScheduledWorkoutModel>> getAllScheduledWorkouts() async {
    final box = await _getBox();
    return box.values.toList();
  }

  /// Get a single scheduled workout by ID
  Future<ScheduledWorkoutModel?> getScheduledWorkout(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  /// Get scheduled workouts for a specific date
  Future<List<ScheduledWorkoutModel>> getScheduledWorkoutsForDate(
    DateTime date,
  ) async {
    final box = await _getBox();
    final targetDate = DateTime(date.year, date.month, date.day);

    return box.values.where((model) {
      final modelDate = DateTime(
        model.scheduledDate.year,
        model.scheduledDate.month,
        model.scheduledDate.day,
      );
      return modelDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  /// Get scheduled workouts in a date range
  Future<List<ScheduledWorkoutModel>> getScheduledWorkoutsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final box = await _getBox();
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    return box.values.where((model) {
      final modelDate = model.scheduledDate;
      return !modelDate.isBefore(start) && !modelDate.isAfter(end);
    }).toList();
  }

  /// Get scheduled workouts for a specific template
  Future<List<ScheduledWorkoutModel>> getScheduledWorkoutsForTemplate(
    String templateId,
  ) async {
    final box = await _getBox();
    return box.values.where((model) => model.templateId == templateId).toList();
  }

  /// Get upcoming scheduled workouts (pending or due status)
  Future<List<ScheduledWorkoutModel>> getUpcomingScheduledWorkouts() async {
    final box = await _getBox();
    return box.values.where((model) {
      return model.status == ScheduleStatusModel.pending ||
          model.status == ScheduleStatusModel.due;
    }).toList();
  }

  /// Update a scheduled workout
  Future<void> updateScheduledWorkout(ScheduledWorkoutModel model) async {
    final box = await _getBox();
    await box.put(model.id, model);
  }

  /// Delete a scheduled workout
  Future<void> deleteScheduledWorkout(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  /// Delete all scheduled workouts for a template
  Future<void> deleteScheduledWorkoutsForTemplate(String templateId) async {
    final box = await _getBox();
    final keysToDelete = box.values
        .where((model) => model.templateId == templateId)
        .map((model) => model.id)
        .toList();

    // PERFORMANCE FIX: Single batch delete instead of sequential deletes
    await box.deleteAll(keysToDelete);
  }

  /// Check if a date already has a scheduled workout for the given template
  Future<bool> hasScheduleForDate({
    required String templateId,
    required DateTime date,
  }) async {
    final box = await _getBox();
    final targetDate = DateTime(date.year, date.month, date.day);

    return box.values.any((model) {
      if (model.templateId != templateId) return false;
      final modelDate = DateTime(
        model.scheduledDate.year,
        model.scheduledDate.month,
        model.scheduledDate.day,
      );
      return modelDate.isAtSameMomentAs(targetDate);
    });
  }

  /// Get all dates that have scheduled workouts for a template
  Future<List<DateTime>> getScheduledDatesForTemplate(String templateId) async {
    final box = await _getBox();
    return box.values
        .where((model) => model.templateId == templateId)
        .map(
          (model) => DateTime(
            model.scheduledDate.year,
            model.scheduledDate.month,
            model.scheduledDate.day,
          ),
        )
        .toList();
  }

  /// Clear all scheduled workouts (for testing/reset)
  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }
}
