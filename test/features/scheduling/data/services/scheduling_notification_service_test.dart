import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/scheduling/data/services/scheduling_notification_service.dart';
import 'package:gymbro_flutter_new/features/scheduling/domain/entities/scheduled_workout.dart';
import 'package:gymbro_flutter_new/features/scheduling/presentation/models/scheduled_workout_notification_highlight.dart';

void main() {
  group('SchedulingNotificationService', () {
    test('builds a payload that can deep-link to the scheduled template', () {
      final service = SchedulingNotificationService();
      final workout = ScheduledWorkout.create(
        id: 'schedule-1',
        templateId: 'template-42',
        templateName: 'Push Day',
        scheduledDate: DateTime(2026, 3, 9),
        reminderTime: const TimeOfDay(hour: 18, minute: 30),
      );

      final payload = service.buildReminderPayload(workout);

      expect(payload, startsWith('scheduled_workout:schedule-1:'));

      final deepLink = payload.split(':').sublist(2).join(':');
      final uri = Uri.parse(deepLink);

      expect(uri.path, '/templates/detail');
      expect(uri.queryParameters['id'], 'template-42');
      expect(uri.queryParameters['scheduledWorkoutId'], 'schedule-1');
      expect(uri.queryParameters['source'], 'notification');

      final highlight = ScheduledWorkoutNotificationHighlight.fromUri(uri);
      expect(highlight, isNotNull);
      expect(highlight!.scheduledWorkoutId, 'schedule-1');
      expect(highlight.scheduledDate, DateTime(2026, 3, 9));
      expect(highlight.reminderHour, 18);
      expect(highlight.reminderMinute, 30);
    });
  });
}
