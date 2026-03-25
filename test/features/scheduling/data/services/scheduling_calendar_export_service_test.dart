import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/scheduling/data/services/scheduling_calendar_export_service.dart';
import 'package:gymbro_flutter_new/features/scheduling/domain/entities/scheduled_workout.dart';

void main() {
  group('SchedulingCalendarExportService', () {
    test('builds ICS content with sorted events and reminder alarm', () {
      final service = SchedulingCalendarExportService(
        now: () => DateTime.utc(2026, 3, 1, 10, 0),
      );

      final workouts = [
        ScheduledWorkout.create(
          id: 'b',
          templateId: 'template-1',
          templateName: 'Push Day',
          scheduledDate: DateTime(2026, 3, 12),
          reminderTime: const TimeOfDay(hour: 8, minute: 30),
        ),
        ScheduledWorkout.create(
          id: 'a',
          templateId: 'template-1',
          templateName: 'Push Day',
          scheduledDate: DateTime(2026, 3, 10),
          reminderTime: const TimeOfDay(hour: 8, minute: 30),
        ),
      ];

      final content = service.buildCalendarContent(workouts: workouts);

      expect(content, contains('BEGIN:VCALENDAR'));
      expect(content, contains('END:VCALENDAR'));
      expect(content, contains('SUMMARY:Push Day'));
      expect(content, contains('TRIGGER:-PT15M'));
      expect(
        content.indexOf('UID:a@fitlogpro.local') <
            content.indexOf('UID:b@fitlogpro.local'),
        isTrue,
      );
    });

    test('writes an .ics file to the temporary directory', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'scheduling_calendar_export_service_test',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      final service = SchedulingCalendarExportService(
        temporaryDirectoryProvider: () async => tempDir,
        now: () => DateTime.utc(2026, 3, 1, 10, 0),
      );

      final file = await service.createCalendarFile(
        workouts: [
          ScheduledWorkout.create(
            id: 'workout-1',
            templateId: 'template-1',
            templateName: 'Leg Day',
            scheduledDate: DateTime(2026, 3, 10),
            reminderTime: const TimeOfDay(hour: 18, minute: 0),
          ),
        ],
        templateName: 'Leg Day',
      );

      expect(await file.exists(), isTrue);
      expect(file.path, endsWith('.ics'));
      expect(file.path, contains('fitlog_schedule_leg_day_'));

      final content = await file.readAsString();
      expect(content, contains('SUMMARY:Leg Day'));
      expect(content, contains('UID:workout-1@fitlogpro.local'));
    });
  });
}
