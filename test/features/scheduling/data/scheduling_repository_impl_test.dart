import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/scheduling/data/datasources/hive_scheduling_datasource.dart';
import 'package:gymbro_flutter_new/features/scheduling/data/models/scheduled_workout_model.dart';
import 'package:gymbro_flutter_new/features/scheduling/data/repositories/scheduling_repository_impl.dart';
import 'package:gymbro_flutter_new/features/scheduling/domain/entities/scheduled_workout.dart';

// ---------------------------------------------------------------------------
// Manual fake implementation — no mockito/mocktail required
// ---------------------------------------------------------------------------

class FakeHiveSchedulingDatasource implements HiveSchedulingDatasource {
  // In-memory store keyed by workout id
  final Map<String, ScheduledWorkoutModel> _store = {};

  // Errors to inject per method
  Exception? saveError;
  Exception? getAllError;
  Exception? getOneError;
  Exception? updateError;
  Exception? deleteError;

  // Recorded calls for assertion
  final List<ScheduledWorkoutModel> savedModels = [];
  final List<ScheduledWorkoutModel> updatedModels = [];
  final List<String> deletedIds = [];

  // ---------- seed helpers --------------------------------------------------

  void seed(ScheduledWorkoutModel model) => _store[model.id] = model;
  void seedAll(Iterable<ScheduledWorkoutModel> models) {
    for (final m in models) {
      _store[m.id] = m;
    }
  }

  void clear() => _store.clear();

  // ---------- interface methods ---------------------------------------------

  @override
  Future<void> saveScheduledWorkout(ScheduledWorkoutModel model) async {
    if (saveError != null) throw saveError!;
    _store[model.id] = model;
    savedModels.add(model);
  }

  @override
  Future<void> saveScheduledWorkouts(
    List<ScheduledWorkoutModel> models,
  ) async {
    if (saveError != null) throw saveError!;
    for (final m in models) {
      _store[m.id] = m;
      savedModels.add(m);
    }
  }

  @override
  Future<List<ScheduledWorkoutModel>> getAllScheduledWorkouts() async {
    if (getAllError != null) throw getAllError!;
    return List.unmodifiable(_store.values);
  }

  @override
  Future<ScheduledWorkoutModel?> getScheduledWorkout(String id) async {
    if (getOneError != null) throw getOneError!;
    return _store[id];
  }

  @override
  Future<List<ScheduledWorkoutModel>> getScheduledWorkoutsForDate(
    DateTime date,
  ) async {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _store.values.where((m) {
      final d = DateTime(
        m.scheduledDate.year,
        m.scheduledDate.month,
        m.scheduledDate.day,
      );
      return d.isAtSameMomentAs(targetDate);
    }).toList();
  }

  @override
  Future<List<ScheduledWorkoutModel>> getScheduledWorkoutsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
    );
    return _store.values.where((m) {
      return !m.scheduledDate.isBefore(start) &&
          !m.scheduledDate.isAfter(end);
    }).toList();
  }

  @override
  Future<List<ScheduledWorkoutModel>> getScheduledWorkoutsForTemplate(
    String templateId,
  ) async {
    return _store.values
        .where((m) => m.templateId == templateId)
        .toList();
  }

  @override
  Future<List<ScheduledWorkoutModel>> getUpcomingScheduledWorkouts() async {
    return _store.values.where((m) {
      return m.status == ScheduleStatusModel.pending ||
          m.status == ScheduleStatusModel.due;
    }).toList();
  }

  @override
  Future<void> updateScheduledWorkout(ScheduledWorkoutModel model) async {
    if (updateError != null) throw updateError!;
    _store[model.id] = model;
    updatedModels.add(model);
  }

  @override
  Future<void> deleteScheduledWorkout(String id) async {
    if (deleteError != null) throw deleteError!;
    _store.remove(id);
    deletedIds.add(id);
  }

  @override
  Future<void> deleteScheduledWorkoutsForTemplate(String templateId) async {
    final ids =
        _store.values.where((m) => m.templateId == templateId).map((m) => m.id).toList();
    for (final id in ids) {
      _store.remove(id);
      deletedIds.add(id);
    }
  }

  @override
  Future<bool> hasScheduleForDate({
    required String templateId,
    required DateTime date,
  }) async {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _store.values.any((m) {
      if (m.templateId != templateId) return false;
      final d = DateTime(
        m.scheduledDate.year,
        m.scheduledDate.month,
        m.scheduledDate.day,
      );
      return d.isAtSameMomentAs(targetDate);
    });
  }

  @override
  Future<List<DateTime>> getScheduledDatesForTemplate(
    String templateId,
  ) async {
    return _store.values
        .where((m) => m.templateId == templateId)
        .map(
          (m) => DateTime(
            m.scheduledDate.year,
            m.scheduledDate.month,
            m.scheduledDate.day,
          ),
        )
        .toList();
  }

  @override
  Future<void> clearAll() async => _store.clear();
}

// ---------------------------------------------------------------------------
// Test factories
// ---------------------------------------------------------------------------

ScheduledWorkoutModel _makeModel({
  String id = 'model-1',
  String templateId = 'tmpl-1',
  String templateName = 'Push Day',
  DateTime? scheduledDate,
  int reminderHour = 8,
  int reminderMinute = 0,
  ScheduleStatusModel status = ScheduleStatusModel.pending,
  DateTime? completedAt,
  DateTime? createdAt,
  String? notificationId,
}) {
  return ScheduledWorkoutModel(
    id: id,
    templateId: templateId,
    templateName: templateName,
    scheduledDate: scheduledDate ?? DateTime(2025, 6, 15),
    reminderHour: reminderHour,
    reminderMinute: reminderMinute,
    status: status,
    completedAt: completedAt,
    createdAt: createdAt ?? DateTime(2025, 6, 1),
    notificationId: notificationId,
  );
}

ScheduledWorkout _makeEntity({
  String id = 'entity-1',
  String templateId = 'tmpl-1',
  String templateName = 'Push Day',
  DateTime? scheduledDate,
  int reminderHour = 8,
  int reminderMinute = 0,
  ScheduleStatus status = ScheduleStatus.pending,
  DateTime? completedAt,
  DateTime? createdAt,
  String? notificationId,
}) {
  return ScheduledWorkout(
    id: id,
    templateId: templateId,
    templateName: templateName,
    scheduledDate: scheduledDate ?? DateTime(2025, 6, 15),
    reminderHour: reminderHour,
    reminderMinute: reminderMinute,
    status: status,
    completedAt: completedAt,
    createdAt: createdAt ?? DateTime(2025, 6, 1),
    notificationId: notificationId,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeHiveSchedulingDatasource fakeDatasource;
  late SchedulingRepositoryImpl repository;

  setUp(() {
    fakeDatasource = FakeHiveSchedulingDatasource();
    repository = SchedulingRepositoryImpl(datasource: fakeDatasource);
  });

  // -------------------------------------------------------------------------
  group('getScheduledWorkouts', () {
    test('returns empty list when datasource has no records', () async {
      final result = await repository.getScheduledWorkouts();
      expect(result, isEmpty);
    });

    test('converts all models to entities', () async {
      fakeDatasource.seedAll([
        _makeModel(id: 'a', scheduledDate: DateTime(2025, 6, 20)),
        _makeModel(id: 'b', scheduledDate: DateTime(2025, 6, 18)),
      ]);

      final result = await repository.getScheduledWorkouts();

      expect(result.length, 2);
      expect(result.every((e) => e is ScheduledWorkout), isTrue);
    });

    test('sorts results by scheduledDate ascending', () async {
      fakeDatasource.seedAll([
        _makeModel(id: 'later', scheduledDate: DateTime(2025, 8, 1)),
        _makeModel(id: 'earliest', scheduledDate: DateTime(2025, 6, 1)),
        _makeModel(id: 'middle', scheduledDate: DateTime(2025, 7, 1)),
      ]);

      final result = await repository.getScheduledWorkouts();

      expect(result[0].id, 'earliest');
      expect(result[1].id, 'middle');
      expect(result[2].id, 'later');
    });

    test('propagates exceptions from datasource', () async {
      fakeDatasource.getAllError = Exception('storage failure');

      expect(() => repository.getScheduledWorkouts(), throwsException);
    });
  });

  // -------------------------------------------------------------------------
  group('getScheduledWorkoutsForDate', () {
    test('returns only workouts scheduled for the given date', () async {
      final targetDate = DateTime(2025, 6, 15);
      fakeDatasource.seedAll([
        _makeModel(
          id: 'match',
          scheduledDate: DateTime(2025, 6, 15, 10, 30),
        ),
        _makeModel(
          id: 'no-match',
          scheduledDate: DateTime(2025, 6, 16),
        ),
      ]);

      final result =
          await repository.getScheduledWorkoutsForDate(targetDate);

      expect(result.length, 1);
      expect(result.first.id, 'match');
    });

    test('returns empty list when no workouts match the date', () async {
      fakeDatasource.seed(_makeModel(scheduledDate: DateTime(2025, 7, 1)));

      final result =
          await repository.getScheduledWorkoutsForDate(DateTime(2025, 6, 1));

      expect(result, isEmpty);
    });

    test('entity fields are preserved correctly after conversion', () async {
      final date = DateTime(2025, 6, 15);
      fakeDatasource.seed(
        _makeModel(
          id: 'check-fields',
          templateId: 'tmpl-99',
          templateName: 'Leg Day',
          scheduledDate: date,
          reminderHour: 7,
          reminderMinute: 30,
          status: ScheduleStatusModel.due,
          notificationId: 'notif-123',
        ),
      );

      final result = await repository.getScheduledWorkoutsForDate(date);

      expect(result.length, 1);
      final entity = result.first;
      expect(entity.id, 'check-fields');
      expect(entity.templateId, 'tmpl-99');
      expect(entity.templateName, 'Leg Day');
      expect(entity.reminderHour, 7);
      expect(entity.reminderMinute, 30);
      expect(entity.status, ScheduleStatus.due);
      expect(entity.notificationId, 'notif-123');
    });
  });

  // -------------------------------------------------------------------------
  group('getScheduledWorkoutsInRange', () {
    test('returns workouts within the date range, sorted', () async {
      fakeDatasource.seedAll([
        _makeModel(id: 'before', scheduledDate: DateTime(2025, 5, 31)),
        _makeModel(id: 'start', scheduledDate: DateTime(2025, 6, 1)),
        _makeModel(id: 'mid', scheduledDate: DateTime(2025, 6, 15)),
        _makeModel(id: 'end', scheduledDate: DateTime(2025, 6, 30)),
        _makeModel(id: 'after', scheduledDate: DateTime(2025, 7, 1)),
      ]);

      final result = await repository.getScheduledWorkoutsInRange(
        startDate: DateTime(2025, 6, 1),
        endDate: DateTime(2025, 6, 30),
      );

      final ids = result.map((e) => e.id).toList();
      expect(ids, containsAll(['start', 'mid', 'end']));
      expect(ids, isNot(contains('before')));
      expect(ids, isNot(contains('after')));
    });

    test('results within range are sorted by scheduledDate ascending', () async {
      fakeDatasource.seedAll([
        _makeModel(id: 'z', scheduledDate: DateTime(2025, 6, 30)),
        _makeModel(id: 'a', scheduledDate: DateTime(2025, 6, 1)),
        _makeModel(id: 'm', scheduledDate: DateTime(2025, 6, 15)),
      ]);

      final result = await repository.getScheduledWorkoutsInRange(
        startDate: DateTime(2025, 6, 1),
        endDate: DateTime(2025, 6, 30),
      );

      expect(result[0].id, 'a');
      expect(result[1].id, 'm');
      expect(result[2].id, 'z');
    });

    test('returns empty list when range contains no workouts', () async {
      fakeDatasource.seed(_makeModel(scheduledDate: DateTime(2025, 12, 1)));

      final result = await repository.getScheduledWorkoutsInRange(
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 6, 30),
      );

      expect(result, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('getScheduledWorkoutsForTemplate', () {
    test('returns only workouts for the given templateId', () async {
      fakeDatasource.seedAll([
        _makeModel(id: 'a', templateId: 'tmpl-A'),
        _makeModel(id: 'b', templateId: 'tmpl-B'),
        _makeModel(id: 'c', templateId: 'tmpl-A'),
      ]);

      final result =
          await repository.getScheduledWorkoutsForTemplate('tmpl-A');

      expect(result.map((e) => e.id).toList(), containsAll(['a', 'c']));
      expect(result.map((e) => e.id).toList(), isNot(contains('b')));
    });

    test('results are sorted by scheduledDate ascending', () async {
      fakeDatasource.seedAll([
        _makeModel(
          id: 'last',
          templateId: 'tmpl-X',
          scheduledDate: DateTime(2025, 9, 1),
        ),
        _makeModel(
          id: 'first',
          templateId: 'tmpl-X',
          scheduledDate: DateTime(2025, 7, 1),
        ),
      ]);

      final result =
          await repository.getScheduledWorkoutsForTemplate('tmpl-X');

      expect(result[0].id, 'first');
      expect(result[1].id, 'last');
    });

    test('returns empty list when template has no scheduled workouts', () async {
      final result =
          await repository.getScheduledWorkoutsForTemplate('unknown-tmpl');

      expect(result, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('getScheduledWorkout', () {
    test('returns entity when model exists', () async {
      fakeDatasource.seed(_makeModel(id: 'found'));

      final result = await repository.getScheduledWorkout('found');

      expect(result, isNotNull);
      expect(result!.id, 'found');
    });

    test('returns null when workout does not exist', () async {
      final result = await repository.getScheduledWorkout('missing');

      expect(result, isNull);
    });

    test('all fields are correctly mapped from model to entity', () async {
      final completedAt = DateTime(2025, 6, 15, 14, 0);
      final createdAt = DateTime(2025, 6, 1);
      fakeDatasource.seed(
        _makeModel(
          id: 'full-fields',
          templateId: 'tmpl-full',
          templateName: 'Full Body',
          scheduledDate: DateTime(2025, 6, 15),
          reminderHour: 6,
          reminderMinute: 45,
          status: ScheduleStatusModel.completed,
          completedAt: completedAt,
          createdAt: createdAt,
          notificationId: 'notif-42',
        ),
      );

      final result = await repository.getScheduledWorkout('full-fields');

      expect(result, isNotNull);
      expect(result!.templateId, 'tmpl-full');
      expect(result.templateName, 'Full Body');
      expect(result.reminderHour, 6);
      expect(result.reminderMinute, 45);
      expect(result.status, ScheduleStatus.completed);
      expect(result.completedAt, completedAt);
      expect(result.createdAt, createdAt);
      expect(result.notificationId, 'notif-42');
      expect(result.reminderTime, const TimeOfDay(hour: 6, minute: 45));
    });
  });

  // -------------------------------------------------------------------------
  group('getUpcomingScheduledWorkouts', () {
    test('returns only pending and due workouts', () async {
      fakeDatasource.seedAll([
        _makeModel(
          id: 'pending',
          status: ScheduleStatusModel.pending,
        ),
        _makeModel(
          id: 'due',
          status: ScheduleStatusModel.due,
        ),
        _makeModel(
          id: 'completed',
          status: ScheduleStatusModel.completed,
        ),
        _makeModel(
          id: 'skipped',
          status: ScheduleStatusModel.skipped,
        ),
        _makeModel(
          id: 'missed',
          status: ScheduleStatusModel.missed,
        ),
      ]);

      final result = await repository.getUpcomingScheduledWorkouts();

      final ids = result.map((e) => e.id).toList();
      expect(ids, containsAll(['pending', 'due']));
      expect(ids, isNot(contains('completed')));
      expect(ids, isNot(contains('skipped')));
      expect(ids, isNot(contains('missed')));
    });

    test('returns results sorted by scheduledDate ascending', () async {
      fakeDatasource.seedAll([
        _makeModel(
          id: 'far',
          status: ScheduleStatusModel.pending,
          scheduledDate: DateTime(2025, 10, 1),
        ),
        _makeModel(
          id: 'near',
          status: ScheduleStatusModel.due,
          scheduledDate: DateTime(2025, 6, 15),
        ),
      ]);

      final result = await repository.getUpcomingScheduledWorkouts();

      expect(result[0].id, 'near');
      expect(result[1].id, 'far');
    });

    test('returns empty list when all workouts are completed or past', () async {
      fakeDatasource.seedAll([
        _makeModel(id: 'done', status: ScheduleStatusModel.completed),
        _makeModel(id: 'miss', status: ScheduleStatusModel.missed),
      ]);

      final result = await repository.getUpcomingScheduledWorkouts();

      expect(result, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('scheduleWorkout', () {
    test('converts entity to model and saves via datasource', () async {
      final entity = _makeEntity(id: 'new-workout');

      await repository.scheduleWorkout(entity);

      expect(fakeDatasource.savedModels.length, 1);
      final saved = fakeDatasource.savedModels.first;
      expect(saved.id, 'new-workout');
      expect(saved.templateId, entity.templateId);
      expect(saved.templateName, entity.templateName);
      expect(saved.reminderHour, entity.reminderHour);
      expect(saved.reminderMinute, entity.reminderMinute);
    });

    test('maps entity status to model status correctly', () async {
      final entity = _makeEntity(
        id: 'status-check',
        status: ScheduleStatus.due,
      );

      await repository.scheduleWorkout(entity);

      final saved = fakeDatasource.savedModels.first;
      expect(saved.status, ScheduleStatusModel.due);
    });

    test('propagates exceptions from datasource', () async {
      fakeDatasource.saveError = Exception('disk full');

      expect(
        () => repository.scheduleWorkout(_makeEntity()),
        throwsException,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('scheduleMultipleWorkouts', () {
    test('saves all entities as models in a batch', () async {
      final entities = [
        _makeEntity(id: 'batch-1', templateId: 'tmpl-B'),
        _makeEntity(id: 'batch-2', templateId: 'tmpl-B'),
        _makeEntity(id: 'batch-3', templateId: 'tmpl-B'),
      ];

      await repository.scheduleMultipleWorkouts(entities);

      expect(fakeDatasource.savedModels.length, 3);
      final ids = fakeDatasource.savedModels.map((m) => m.id).toList();
      expect(ids, containsAll(['batch-1', 'batch-2', 'batch-3']));
    });

    test('handles empty list without error', () async {
      await repository.scheduleMultipleWorkouts([]);

      expect(fakeDatasource.savedModels, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('updateSchedule', () {
    test('converts entity to model and updates via datasource', () async {
      final entity = _makeEntity(
        id: 'upd-1',
        templateName: 'Updated Name',
        status: ScheduleStatus.due,
      );

      await repository.updateSchedule(entity);

      expect(fakeDatasource.updatedModels.length, 1);
      final updated = fakeDatasource.updatedModels.first;
      expect(updated.id, 'upd-1');
      expect(updated.templateName, 'Updated Name');
      expect(updated.status, ScheduleStatusModel.due);
    });

    test('propagates exceptions from datasource', () async {
      fakeDatasource.updateError = Exception('update failed');

      expect(
        () => repository.updateSchedule(_makeEntity()),
        throwsException,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('deleteSchedule', () {
    test('delegates deletion by id to datasource', () async {
      fakeDatasource.seed(_makeModel(id: 'del-me'));

      await repository.deleteSchedule('del-me');

      expect(fakeDatasource.deletedIds, contains('del-me'));
      expect(fakeDatasource._store, isEmpty);
    });

    test('propagates exceptions from datasource', () async {
      fakeDatasource.deleteError = Exception('delete failed');

      expect(
        () => repository.deleteSchedule('any-id'),
        throwsException,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('deleteSchedulesForTemplate', () {
    test('deletes all workouts belonging to a template', () async {
      fakeDatasource.seedAll([
        _makeModel(id: 'keep', templateId: 'tmpl-keep'),
        _makeModel(id: 'del-1', templateId: 'tmpl-del'),
        _makeModel(id: 'del-2', templateId: 'tmpl-del'),
      ]);

      await repository.deleteSchedulesForTemplate('tmpl-del');

      expect(fakeDatasource._store.containsKey('keep'), isTrue);
      expect(fakeDatasource._store.containsKey('del-1'), isFalse);
      expect(fakeDatasource._store.containsKey('del-2'), isFalse);
    });

    test('does not fail when template has no scheduled workouts', () async {
      await expectLater(
        repository.deleteSchedulesForTemplate('non-existent'),
        completes,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('markAsCompleted — status transition', () {
    test('updates status to completed and sets completedAt', () async {
      final before = DateTime(2025, 6, 15, 9, 0);
      fakeDatasource.seed(_makeModel(id: 'comp-1'));

      await repository.markAsCompleted('comp-1', completedAt: before);

      expect(fakeDatasource.updatedModels.length, 1);
      final updated = fakeDatasource.updatedModels.first;
      expect(updated.status, ScheduleStatusModel.completed);
      expect(updated.completedAt, before);
    });

    test('uses DateTime.now() when completedAt is not provided', () async {
      fakeDatasource.seed(_makeModel(id: 'comp-now'));
      final before = DateTime.now();

      await repository.markAsCompleted('comp-now');

      final updated = fakeDatasource.updatedModels.first;
      expect(updated.completedAt, isNotNull);
      // Allow 2-second window to avoid test flakiness
      expect(
        updated.completedAt!.isAfter(before.subtract(const Duration(seconds: 2))),
        isTrue,
      );
    });

    test('does nothing when workout id does not exist', () async {
      await repository.markAsCompleted('ghost-id');

      expect(fakeDatasource.updatedModels, isEmpty);
    });

    test('preserves all other fields when marking completed', () async {
      fakeDatasource.seed(
        _makeModel(
          id: 'preserve',
          templateId: 'tmpl-pres',
          templateName: 'Preserve Me',
          reminderHour: 9,
          reminderMinute: 15,
          notificationId: 'notif-pres',
        ),
      );

      await repository.markAsCompleted(
        'preserve',
        completedAt: DateTime(2025, 6, 15),
      );

      final updated = fakeDatasource.updatedModels.first;
      expect(updated.templateId, 'tmpl-pres');
      expect(updated.templateName, 'Preserve Me');
      expect(updated.reminderHour, 9);
      expect(updated.reminderMinute, 15);
      expect(updated.notificationId, 'notif-pres');
    });
  });

  // -------------------------------------------------------------------------
  group('markAsSkipped — status transition', () {
    test('updates status to skipped', () async {
      fakeDatasource.seed(_makeModel(id: 'skip-1'));

      await repository.markAsSkipped('skip-1');

      expect(fakeDatasource.updatedModels.first.status,
          ScheduleStatusModel.skipped);
    });

    test('does nothing when workout id does not exist', () async {
      await repository.markAsSkipped('ghost-skip');

      expect(fakeDatasource.updatedModels, isEmpty);
    });

    test('preserves all other fields when marking skipped', () async {
      final original = _makeModel(
        id: 'skip-pres',
        templateName: 'Keep Me',
        status: ScheduleStatusModel.due,
      );
      fakeDatasource.seed(original);

      await repository.markAsSkipped('skip-pres');

      final updated = fakeDatasource.updatedModels.first;
      expect(updated.templateName, 'Keep Me');
      expect(updated.status, ScheduleStatusModel.skipped);
    });
  });

  // -------------------------------------------------------------------------
  group('markAsMissed — status transition', () {
    test('updates status to missed', () async {
      fakeDatasource.seed(_makeModel(id: 'miss-1'));

      await repository.markAsMissed('miss-1');

      expect(fakeDatasource.updatedModels.first.status,
          ScheduleStatusModel.missed);
    });

    test('does nothing when workout id does not exist', () async {
      await repository.markAsMissed('ghost-miss');

      expect(fakeDatasource.updatedModels, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('updateMissedWorkouts', () {
    // Helper: build a date-only DateTime using today's components
    DateTime todayDate() {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }

    test('marks past-due pending workouts as missed', () async {
      final yesterday = todayDate().subtract(const Duration(days: 1));
      fakeDatasource.seed(
        _makeModel(
          id: 'past-pending',
          scheduledDate: yesterday,
          status: ScheduleStatusModel.pending,
        ),
      );

      await repository.updateMissedWorkouts();

      expect(
        fakeDatasource._store['past-pending']!.status,
        ScheduleStatusModel.missed,
      );
    });

    test('marks today pending workouts as due', () async {
      final today = todayDate();
      fakeDatasource.seed(
        _makeModel(
          id: 'today-pending',
          scheduledDate: today,
          status: ScheduleStatusModel.pending,
        ),
      );

      await repository.updateMissedWorkouts();

      expect(
        fakeDatasource._store['today-pending']!.status,
        ScheduleStatusModel.due,
      );
    });

    test('does not change already-completed workouts', () async {
      final yesterday = todayDate().subtract(const Duration(days: 1));
      fakeDatasource.seed(
        _makeModel(
          id: 'already-done',
          scheduledDate: yesterday,
          status: ScheduleStatusModel.completed,
        ),
      );

      await repository.updateMissedWorkouts();

      expect(
        fakeDatasource._store['already-done']!.status,
        ScheduleStatusModel.completed,
      );
    });

    test('does not change already-skipped workouts', () async {
      final yesterday = todayDate().subtract(const Duration(days: 1));
      fakeDatasource.seed(
        _makeModel(
          id: 'already-skipped',
          scheduledDate: yesterday,
          status: ScheduleStatusModel.skipped,
        ),
      );

      await repository.updateMissedWorkouts();

      expect(
        fakeDatasource._store['already-skipped']!.status,
        ScheduleStatusModel.skipped,
      );
    });

    test('does not change future pending workouts', () async {
      final tomorrow = todayDate().add(const Duration(days: 2));
      fakeDatasource.seed(
        _makeModel(
          id: 'future',
          scheduledDate: tomorrow,
          status: ScheduleStatusModel.pending,
        ),
      );

      await repository.updateMissedWorkouts();

      // Future workouts should remain pending
      expect(
        fakeDatasource._store['future']!.status,
        ScheduleStatusModel.pending,
      );
    });

    test('handles mixed statuses and dates in a single pass', () async {
      final yesterday = todayDate().subtract(const Duration(days: 1));
      final today = todayDate();
      final tomorrow = todayDate().add(const Duration(days: 2));

      fakeDatasource.seedAll([
        _makeModel(
          id: 'miss-me',
          scheduledDate: yesterday,
          status: ScheduleStatusModel.pending,
        ),
        _makeModel(
          id: 'due-today',
          scheduledDate: today,
          status: ScheduleStatusModel.pending,
        ),
        _makeModel(
          id: 'stay-future',
          scheduledDate: tomorrow,
          status: ScheduleStatusModel.pending,
        ),
        _makeModel(
          id: 'already-completed',
          scheduledDate: yesterday,
          status: ScheduleStatusModel.completed,
        ),
      ]);

      await repository.updateMissedWorkouts();

      expect(
        fakeDatasource._store['miss-me']!.status,
        ScheduleStatusModel.missed,
      );
      expect(
        fakeDatasource._store['due-today']!.status,
        ScheduleStatusModel.due,
      );
      expect(
        fakeDatasource._store['stay-future']!.status,
        ScheduleStatusModel.pending,
      );
      expect(
        fakeDatasource._store['already-completed']!.status,
        ScheduleStatusModel.completed,
      );
    });

    test('handles empty store without error', () async {
      await expectLater(repository.updateMissedWorkouts(), completes);
    });
  });

  // -------------------------------------------------------------------------
  group('hasScheduleForDate', () {
    test('returns true when a schedule exists for template and date', () async {
      fakeDatasource.seed(
        _makeModel(
          id: 'exists',
          templateId: 'tmpl-check',
          scheduledDate: DateTime(2025, 6, 15, 8, 0),
        ),
      );

      final result = await repository.hasScheduleForDate(
        templateId: 'tmpl-check',
        date: DateTime(2025, 6, 15),
      );

      expect(result, isTrue);
    });

    test('returns false when date does not match', () async {
      fakeDatasource.seed(
        _makeModel(
          id: 'wrong-date',
          templateId: 'tmpl-check',
          scheduledDate: DateTime(2025, 6, 16),
        ),
      );

      final result = await repository.hasScheduleForDate(
        templateId: 'tmpl-check',
        date: DateTime(2025, 6, 15),
      );

      expect(result, isFalse);
    });

    test('returns false when template does not match', () async {
      fakeDatasource.seed(
        _makeModel(
          id: 'wrong-tmpl',
          templateId: 'tmpl-other',
          scheduledDate: DateTime(2025, 6, 15),
        ),
      );

      final result = await repository.hasScheduleForDate(
        templateId: 'tmpl-check',
        date: DateTime(2025, 6, 15),
      );

      expect(result, isFalse);
    });

    test('returns false when store is empty', () async {
      final result = await repository.hasScheduleForDate(
        templateId: 'any-tmpl',
        date: DateTime(2025, 6, 15),
      );

      expect(result, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('getScheduledDatesForTemplate', () {
    test('returns normalized date-only values for the template', () async {
      fakeDatasource.seedAll([
        _makeModel(
          id: 'a',
          templateId: 'tmpl-dates',
          scheduledDate: DateTime(2025, 6, 15, 10, 30),
        ),
        _makeModel(
          id: 'b',
          templateId: 'tmpl-dates',
          scheduledDate: DateTime(2025, 7, 4, 8, 0),
        ),
        _makeModel(
          id: 'other',
          templateId: 'other-tmpl',
          scheduledDate: DateTime(2025, 8, 1),
        ),
      ]);

      final result =
          await repository.getScheduledDatesForTemplate('tmpl-dates');

      expect(result.length, 2);
      // Dates must be normalized to midnight
      for (final d in result) {
        expect(d.hour, 0);
        expect(d.minute, 0);
        expect(d.second, 0);
      }
      expect(result.map((d) => d.day).toList(), containsAll([15, 4]));
    });

    test('returns empty list when no dates for template', () async {
      final result =
          await repository.getScheduledDatesForTemplate('tmpl-no-dates');

      expect(result, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('Model <-> Entity conversion', () {
    test(
        'ScheduleStatus enum values map correctly through round-trip conversion',
        () {
      final statusPairs = [
        (ScheduleStatusModel.pending, ScheduleStatus.pending),
        (ScheduleStatusModel.due, ScheduleStatus.due),
        (ScheduleStatusModel.completed, ScheduleStatus.completed),
        (ScheduleStatusModel.skipped, ScheduleStatus.skipped),
        (ScheduleStatusModel.missed, ScheduleStatus.missed),
      ];

      for (final (model, entity) in statusPairs) {
        expect(model.toEntity(), entity,
            reason: 'Model $model should map to entity $entity');
        expect(
          ScheduleStatusModelExtension.fromEntity(entity),
          model,
          reason: 'Entity $entity should map back to model $model',
        );
      }
    });

    test(
        'ScheduledWorkoutModel.fromEntity captures all fields without loss',
        () {
      final completedAt = DateTime(2025, 6, 15, 14, 0);
      final createdAt = DateTime(2025, 6, 1);
      final entity = _makeEntity(
        id: 'round-trip',
        templateId: 'tmpl-rt',
        templateName: 'Round Trip',
        scheduledDate: DateTime(2025, 6, 15),
        reminderHour: 6,
        reminderMinute: 30,
        status: ScheduleStatus.completed,
        completedAt: completedAt,
        createdAt: createdAt,
        notificationId: 'notif-rt',
      );

      final model = ScheduledWorkoutModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.templateId, entity.templateId);
      expect(model.templateName, entity.templateName);
      expect(model.scheduledDate, entity.scheduledDate);
      expect(model.reminderHour, entity.reminderHour);
      expect(model.reminderMinute, entity.reminderMinute);
      expect(model.status, ScheduleStatusModel.completed);
      expect(model.completedAt, completedAt);
      expect(model.createdAt, createdAt);
      expect(model.notificationId, 'notif-rt');
    });

    test('ScheduledWorkoutModel.toEntity() produces correct domain object',
        () {
      final model = _makeModel(
        id: 'to-entity',
        templateId: 'tmpl-te',
        templateName: 'To Entity',
        scheduledDate: DateTime(2025, 6, 20),
        reminderHour: 7,
        reminderMinute: 45,
        status: ScheduleStatusModel.due,
        notificationId: 'notif-te',
      );

      final entity = model.toEntity();

      expect(entity.id, 'to-entity');
      expect(entity.templateId, 'tmpl-te');
      expect(entity.templateName, 'To Entity');
      expect(entity.scheduledDate, DateTime(2025, 6, 20));
      expect(entity.reminderHour, 7);
      expect(entity.reminderMinute, 45);
      expect(entity.status, ScheduleStatus.due);
      expect(entity.notificationId, 'notif-te');
    });

    test('reminderTime getter reconstructs TimeOfDay correctly', () async {
      fakeDatasource.seed(
        _makeModel(
          id: 'reminder',
          reminderHour: 6,
          reminderMinute: 45,
        ),
      );

      final entity = await repository.getScheduledWorkout('reminder');

      expect(entity!.reminderTime.hour, 6);
      expect(entity.reminderTime.minute, 45);
    });
  });
}
