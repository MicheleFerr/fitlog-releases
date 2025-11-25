import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/workout_notification.dart' as workout;

void main() {
  group('🔔 UnifiedNotification Tests', () {
    group('📦 Basic Entity', () {
      test('✅ Creates notification with default values', () {
        final notification = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Test Title',
          body: 'Test Body',
        );

        expect(notification.id, isNotEmpty);
        expect(notification.type, NotificationType.workoutReminder);
        expect(notification.title, 'Test Title');
        expect(notification.body, 'Test Body');
        expect(notification.priority, NotificationPriority.normal);
        expect(notification.status, NotificationDeliveryStatus.pending);
        expect(notification.retryCount, 0);
      });

      test('✅ Creates notification with custom ID', () {
        final notification = UnifiedNotification(
          id: 'custom-id-123',
          type: NotificationType.timerComplete,
          title: 'Timer Done',
          body: 'Your timer has completed',
        );

        expect(notification.id, 'custom-id-123');
      });

      test('✅ Creates notification with all fields', () {
        final scheduledTime = DateTime(2024, 1, 15, 10, 30);
        final createdAt = DateTime(2024, 1, 14, 9, 0);

        final notification = UnifiedNotification(
          id: 'full-notification',
          type: NotificationType.achievementUnlocked,
          title: 'Achievement!',
          body: 'You unlocked a new achievement',
          scheduledTime: scheduledTime,
          priority: NotificationPriority.high,
          deliveryMethod: NotificationDeliveryMethod.push,
          payload: {'achievementId': '123'},
          imageUrl: 'https://example.com/image.png',
          soundName: 'achievement.mp3',
          userId: 'user-123',
          workoutId: 'workout-456',
          tags: ['achievement', 'milestone'],
          status: NotificationDeliveryStatus.pending,
          createdAt: createdAt,
        );

        expect(notification.scheduledTime, scheduledTime);
        expect(notification.priority, NotificationPriority.high);
        expect(notification.deliveryMethod, NotificationDeliveryMethod.push);
        expect(notification.payload?['achievementId'], '123');
        expect(notification.imageUrl, 'https://example.com/image.png');
        expect(notification.soundName, 'achievement.mp3');
        expect(notification.userId, 'user-123');
        expect(notification.workoutId, 'workout-456');
        expect(notification.tags, contains('achievement'));
        expect(notification.createdAt, createdAt);
      });
    });

    group('🔄 State Transitions', () {
      test('✅ markAsDelivered updates status and timestamp', () {
        final notification = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test body',
        );

        final delivered = notification.markAsDelivered();

        expect(delivered.status, NotificationDeliveryStatus.delivered);
        expect(delivered.deliveredAt, isNotNull);
        expect(notification.status, NotificationDeliveryStatus.pending); // Original unchanged
      });

      test('✅ markAsFailed updates status and error message', () {
        final notification = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test body',
        );

        final failed = notification.markAsFailed('Network error');

        expect(failed.status, NotificationDeliveryStatus.failed);
        expect(failed.errorMessage, 'Network error');
      });

      test('✅ markAsRead updates readAt timestamp', () {
        final notification = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test body',
        );

        final read = notification.markAsRead();

        expect(read.readAt, isNotNull);
        expect(read.isRead, true);
      });

      test('✅ incrementRetry increases count and reschedules', () {
        // Start with retryCount = 1 so next retry schedules 5 minutes in future
        final notification = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test body',
          status: NotificationDeliveryStatus.failed,
          retryCount: 1,
        );

        final beforeRetry = DateTime.now();
        final retried = notification.incrementRetry();

        expect(retried.retryCount, 2);
        expect(retried.status, NotificationDeliveryStatus.pending);
        // With retryCount=1, formula adds 1*5=5 minutes
        expect(retried.scheduledTime.isAfter(beforeRetry), true);
      });
    });

    group('📊 Computed Properties', () {
      test('✅ isPending returns correct value', () {
        final pending = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test',
          status: NotificationDeliveryStatus.pending,
        );

        final delivered = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test',
          status: NotificationDeliveryStatus.delivered,
        );

        expect(pending.isPending, true);
        expect(delivered.isPending, false);
      });

      test('✅ isDelivered returns correct value', () {
        final delivered = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test',
          status: NotificationDeliveryStatus.delivered,
        );

        expect(delivered.isDelivered, true);
      });

      test('✅ isFailed returns correct value', () {
        final failed = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test',
          status: NotificationDeliveryStatus.failed,
        );

        expect(failed.isFailed, true);
      });

      test('✅ canRetry returns true when failed and under limit', () {
        final retriable = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test',
          status: NotificationDeliveryStatus.failed,
          retryCount: 2,
        );

        final maxRetries = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test',
          status: NotificationDeliveryStatus.failed,
          retryCount: 3,
        );

        expect(retriable.canRetry, true);
        expect(maxRetries.canRetry, false);
      });

      test('✅ isOverdue returns correct value', () {
        final overdue = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test',
          scheduledTime: DateTime.now().subtract(const Duration(hours: 1)),
          status: NotificationDeliveryStatus.pending,
        );

        final future = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test',
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          status: NotificationDeliveryStatus.pending,
        );

        expect(overdue.isOverdue, true);
        expect(future.isOverdue, false);
      });
    });

    group('📋 CopyWith', () {
      test('✅ copyWith creates new instance with updated fields', () {
        final original = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Original',
          body: 'Original body',
        );

        final updated = original.copyWith(
          title: 'Updated Title',
          priority: NotificationPriority.high,
        );

        expect(updated.title, 'Updated Title');
        expect(updated.priority, NotificationPriority.high);
        expect(updated.body, 'Original body'); // Unchanged
        expect(updated.id, original.id); // Same ID
      });
    });

    group('📝 Serialization', () {
      test('✅ toJson and fromJson roundtrip', () {
        final original = UnifiedNotification(
          id: 'test-id',
          type: NotificationType.achievementUnlocked,
          title: 'Test Title',
          body: 'Test Body',
          scheduledTime: DateTime(2024, 1, 15, 10, 30),
          priority: NotificationPriority.high,
          deliveryMethod: NotificationDeliveryMethod.local,
          status: NotificationDeliveryStatus.pending,
          retryCount: 1,
        );

        final json = original.toJson();
        final restored = UnifiedNotification.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.type, original.type);
        expect(restored.title, original.title);
        expect(restored.body, original.body);
        expect(restored.priority, original.priority);
        expect(restored.status, original.status);
        expect(restored.retryCount, original.retryCount);
      });
    });

    group('🔄 WorkoutNotification Conversion', () {
      test('✅ Converts WorkoutNotification to UnifiedNotification', () {
        final workoutNotification = workout.WorkoutNotification(
          id: 12345,
          type: workout.NotificationType.workoutReminder,
          title: 'Workout Reminder',
          body: 'Time for your Push Day workout!',
          scheduledTime: DateTime(2024, 1, 15, 9, 0),
          priority: workout.NotificationPriority.medium,
          routineId: 'routine-123',
          workoutName: 'Push Day',
        );

        final unified = UnifiedNotification.fromWorkoutNotification(workoutNotification);

        expect(unified.id, '12345');
        expect(unified.type, NotificationType.workoutReminder);
        expect(unified.title, 'Workout Reminder');
        expect(unified.body, 'Time for your Push Day workout!');
        expect(unified.scheduledTime, DateTime(2024, 1, 15, 9, 0));
        expect(unified.priority, NotificationPriority.normal); // medium -> normal
        expect(unified.payload?['routineId'], 'routine-123');
        expect(unified.payload?['workoutName'], 'Push Day');
        expect(unified.workoutId, 'routine-123');
      });

      test('✅ Converts recovery alert type', () {
        final workoutNotification = workout.WorkoutNotification(
          id: 999,
          type: workout.NotificationType.recoveryAlert,
          title: 'Recovery Needed',
          body: 'You have 2 skipped days to recover!',
          scheduledTime: DateTime.now(),
          priority: workout.NotificationPriority.high,
          daysToRecover: 2,
        );

        final unified = UnifiedNotification.fromWorkoutNotification(workoutNotification);

        expect(unified.type, NotificationType.restReminder);
        expect(unified.priority, NotificationPriority.high);
        expect(unified.payload?['daysToRecover'], 2);
      });

      test('✅ Converts streak motivation type', () {
        final workoutNotification = workout.WorkoutNotification(
          id: 888,
          type: workout.NotificationType.streakMotivation,
          title: 'Keep Your Streak!',
          body: '7 days streak!',
          scheduledTime: DateTime.now(),
          priority: workout.NotificationPriority.low,
        );

        final unified = UnifiedNotification.fromWorkoutNotification(workoutNotification);

        expect(unified.type, NotificationType.streakReminder);
        expect(unified.priority, NotificationPriority.low);
      });

      test('✅ Converts rest day reminder type', () {
        final workoutNotification = workout.WorkoutNotification(
          id: 777,
          type: workout.NotificationType.restDayReminder,
          title: 'Rest Day',
          body: 'Recovery is important!',
          scheduledTime: DateTime.now(),
          priority: workout.NotificationPriority.low,
        );

        final unified = UnifiedNotification.fromWorkoutNotification(workoutNotification);

        expect(unified.type, NotificationType.restReminder);
      });

      test('✅ Handles delivered notification status', () {
        final workoutNotification = workout.WorkoutNotification(
          id: 555,
          type: workout.NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test',
          scheduledTime: DateTime.now(),
          priority: workout.NotificationPriority.medium,
          isDelivered: true,
          deliveredAt: DateTime(2024, 1, 15, 10, 0),
        );

        final unified = UnifiedNotification.fromWorkoutNotification(workoutNotification);

        expect(unified.status, NotificationDeliveryStatus.delivered);
        expect(unified.deliveredAt, DateTime(2024, 1, 15, 10, 0));
      });
    });

    group('⚖️ Equality', () {
      test('✅ Notifications with same ID are equal', () {
        final notification1 = UnifiedNotification(
          id: 'same-id',
          type: NotificationType.workoutReminder,
          title: 'Title 1',
          body: 'Body 1',
        );

        final notification2 = UnifiedNotification(
          id: 'same-id',
          type: NotificationType.timerComplete,
          title: 'Title 2',
          body: 'Body 2',
        );

        expect(notification1, equals(notification2));
        expect(notification1.hashCode, notification2.hashCode);
      });

      test('✅ Notifications with different IDs are not equal', () {
        final notification1 = UnifiedNotification(
          id: 'id-1',
          type: NotificationType.workoutReminder,
          title: 'Same Title',
          body: 'Same Body',
        );

        final notification2 = UnifiedNotification(
          id: 'id-2',
          type: NotificationType.workoutReminder,
          title: 'Same Title',
          body: 'Same Body',
        );

        expect(notification1, isNot(equals(notification2)));
      });
    });
  });
}
