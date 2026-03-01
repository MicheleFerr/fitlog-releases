/// ScheduledWorkoutModel tests - covers .g.dart Hive adapters,
/// model→entity conversion, entity→model conversion, copyWith.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/scheduling/data/models/scheduled_workout_model.dart';
import 'package:gymbro_flutter_new/features/scheduling/domain/entities/scheduled_workout.dart';

void main() {
  group('ScheduleStatusModel', () {
    test('has 5 values matching domain enum', () {
      expect(ScheduleStatusModel.values.length, 5);
    });

    test('toEntity converts all statuses', () {
      expect(ScheduleStatusModel.pending.toEntity(), ScheduleStatus.pending);
      expect(ScheduleStatusModel.due.toEntity(), ScheduleStatus.due);
      expect(ScheduleStatusModel.completed.toEntity(), ScheduleStatus.completed);
      expect(ScheduleStatusModel.skipped.toEntity(), ScheduleStatus.skipped);
      expect(ScheduleStatusModel.missed.toEntity(), ScheduleStatus.missed);
    });

    test('fromEntity converts all statuses', () {
      expect(ScheduleStatusModelExtension.fromEntity(ScheduleStatus.pending), ScheduleStatusModel.pending);
      expect(ScheduleStatusModelExtension.fromEntity(ScheduleStatus.due), ScheduleStatusModel.due);
      expect(ScheduleStatusModelExtension.fromEntity(ScheduleStatus.completed), ScheduleStatusModel.completed);
      expect(ScheduleStatusModelExtension.fromEntity(ScheduleStatus.skipped), ScheduleStatusModel.skipped);
      expect(ScheduleStatusModelExtension.fromEntity(ScheduleStatus.missed), ScheduleStatusModel.missed);
    });
  });

  group('ScheduledWorkoutModel', () {
    ScheduledWorkoutModel buildModel({
      String id = 'm1',
      String templateId = 't1',
      String templateName = 'Push Day',
      DateTime? scheduledDate,
      int reminderHour = 9,
      int reminderMinute = 30,
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
        createdAt: createdAt,
        notificationId: notificationId,
      );
    }

    test('constructor stores all fields', () {
      final m = buildModel(
        completedAt: DateTime(2025, 6, 15, 18, 0),
        createdAt: DateTime(2025, 6, 1),
        notificationId: 'n1',
      );
      expect(m.id, 'm1');
      expect(m.templateId, 't1');
      expect(m.templateName, 'Push Day');
      expect(m.reminderHour, 9);
      expect(m.reminderMinute, 30);
      expect(m.status, ScheduleStatusModel.pending);
      expect(m.completedAt, DateTime(2025, 6, 15, 18, 0));
      expect(m.createdAt, DateTime(2025, 6, 1));
      expect(m.notificationId, 'n1');
    });

    test('toEntity converts correctly', () {
      final m = buildModel(
        status: ScheduleStatusModel.completed,
        completedAt: DateTime(2025, 6, 15, 18, 0),
        createdAt: DateTime(2025, 6, 1),
        notificationId: 'n1',
      );
      final entity = m.toEntity();

      expect(entity.id, m.id);
      expect(entity.templateId, m.templateId);
      expect(entity.templateName, m.templateName);
      expect(entity.scheduledDate, m.scheduledDate);
      expect(entity.reminderHour, m.reminderHour);
      expect(entity.reminderMinute, m.reminderMinute);
      expect(entity.status, ScheduleStatus.completed);
      expect(entity.completedAt, m.completedAt);
      expect(entity.createdAt, m.createdAt);
      expect(entity.notificationId, m.notificationId);
    });

    test('fromEntity creates model correctly', () {
      final entity = ScheduledWorkout(
        id: 'e1',
        templateId: 't2',
        templateName: 'Legs',
        scheduledDate: DateTime(2025, 7, 1),
        reminderHour: 8,
        reminderMinute: 0,
        status: ScheduleStatus.skipped,
        notificationId: 'n2',
      );
      final m = ScheduledWorkoutModel.fromEntity(entity);

      expect(m.id, entity.id);
      expect(m.templateId, entity.templateId);
      expect(m.templateName, entity.templateName);
      expect(m.scheduledDate, entity.scheduledDate);
      expect(m.reminderHour, entity.reminderHour);
      expect(m.reminderMinute, entity.reminderMinute);
      expect(m.status, ScheduleStatusModel.skipped);
      expect(m.notificationId, entity.notificationId);
    });

    test('round-trip model→entity→model preserves data', () {
      final original = buildModel(
        status: ScheduleStatusModel.due,
        createdAt: DateTime(2025, 1, 1),
      );
      final entity = original.toEntity();
      final restored = ScheduledWorkoutModel.fromEntity(entity);

      expect(restored.id, original.id);
      expect(restored.templateId, original.templateId);
      expect(restored.templateName, original.templateName);
      expect(restored.scheduledDate, original.scheduledDate);
      expect(restored.reminderHour, original.reminderHour);
      expect(restored.reminderMinute, original.reminderMinute);
      expect(restored.status, original.status);
      expect(restored.createdAt, original.createdAt);
    });

    group('copyWith', () {
      test('copies with new values', () {
        final m = buildModel();
        final copy = m.copyWith(
          templateName: 'Pull Day',
          status: ScheduleStatusModel.completed,
          notificationId: 'n3',
        );
        expect(copy.templateName, 'Pull Day');
        expect(copy.status, ScheduleStatusModel.completed);
        expect(copy.notificationId, 'n3');
        expect(copy.id, m.id); // unchanged
      });

      test('copies with all fields', () {
        final m = buildModel();
        final copy = m.copyWith(
          id: 'new-id',
          templateId: 'new-t',
          templateName: 'New',
          scheduledDate: DateTime(2026, 1, 1),
          reminderHour: 7,
          reminderMinute: 15,
          status: ScheduleStatusModel.missed,
          completedAt: DateTime(2026, 1, 2),
          createdAt: DateTime(2025, 12, 31),
          notificationId: 'n-new',
        );
        expect(copy.id, 'new-id');
        expect(copy.templateId, 'new-t');
        expect(copy.reminderHour, 7);
        expect(copy.reminderMinute, 15);
        expect(copy.status, ScheduleStatusModel.missed);
      });

      test('preserves original when no args', () {
        final m = buildModel(notificationId: 'x');
        final copy = m.copyWith();
        expect(copy.id, m.id);
        expect(copy.notificationId, m.notificationId);
      });
    });
  });

  group('ScheduledWorkoutModelAdapter', () {
    test('typeId is 62', () {
      final adapter = ScheduledWorkoutModelAdapter();
      expect(adapter.typeId, 62);
    });

    test('equality between adapters', () {
      final a = ScheduledWorkoutModelAdapter();
      final b = ScheduledWorkoutModelAdapter();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('ScheduleStatusModelAdapter', () {
    test('typeId is 61', () {
      final adapter = ScheduleStatusModelAdapter();
      expect(adapter.typeId, 61);
    });

    test('equality between adapters', () {
      final a = ScheduleStatusModelAdapter();
      final b = ScheduleStatusModelAdapter();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
