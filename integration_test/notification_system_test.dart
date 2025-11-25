import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/workout_notification.dart' as workout;

/// Integration tests for the GymBro notification system
///
/// These tests verify:
/// - UnifiedNotification entity behavior
/// - Entity conversion (WorkoutNotification -> UnifiedNotification)
/// - State transitions and computed properties
/// - Serialization roundtrips
///
/// Note: Actual notification display requires platform channels and
/// cannot be fully tested in integration tests. These tests focus on
/// the business logic layer.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🔔 Notification System Integration Tests', () {

    group('📦 UnifiedNotification Entity Integration', () {
      testWidgets('Creates notification with all required fields', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold()),
          ),
        );

        final notification = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Workout Time',
          body: 'Time for your Push Day workout!',
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          priority: NotificationPriority.high,
        );

        expect(notification.id, isNotEmpty);
        expect(notification.type, NotificationType.workoutReminder);
        expect(notification.title, 'Workout Time');
        expect(notification.body, 'Time for your Push Day workout!');
        expect(notification.priority, NotificationPriority.high);
        expect(notification.status, NotificationDeliveryStatus.pending);
        expect(notification.isPending, true);
      });

      testWidgets('State transitions work correctly', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold()),
          ),
        );

        final original = UnifiedNotification(
          type: NotificationType.timerComplete,
          title: 'Rest Timer',
          body: 'Rest time is over!',
        );

        // Test markAsDelivered
        final delivered = original.markAsDelivered();
        expect(delivered.status, NotificationDeliveryStatus.delivered);
        expect(delivered.deliveredAt, isNotNull);
        expect(delivered.isDelivered, true);
        expect(original.isPending, true); // Original unchanged

        // Test markAsFailed
        final failed = original.markAsFailed('Network error');
        expect(failed.status, NotificationDeliveryStatus.failed);
        expect(failed.errorMessage, 'Network error');
        expect(failed.isFailed, true);

        // Test markAsRead
        final read = delivered.markAsRead();
        expect(read.readAt, isNotNull);
        expect(read.isRead, true);
      });

      testWidgets('Serialization roundtrip preserves data', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold()),
          ),
        );

        final original = UnifiedNotification(
          id: 'test-serialization-id',
          type: NotificationType.achievementUnlocked,
          title: 'Achievement!',
          body: 'You earned a new badge',
          scheduledTime: DateTime(2025, 1, 15, 10, 30),
          priority: NotificationPriority.high,
          deliveryMethod: NotificationDeliveryMethod.local,
          payload: {'achievementId': 'first-workout', 'xp': 100},
          tags: ['achievement', 'milestone'],
          userId: 'user-123',
          status: NotificationDeliveryStatus.pending,
          retryCount: 0,
        );

        final json = original.toJson();
        final restored = UnifiedNotification.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.type, original.type);
        expect(restored.title, original.title);
        expect(restored.body, original.body);
        expect(restored.priority, original.priority);
        expect(restored.deliveryMethod, original.deliveryMethod);
        expect(restored.payload?['achievementId'], 'first-workout');
        expect(restored.payload?['xp'], 100);
        expect(restored.tags, contains('achievement'));
        expect(restored.userId, 'user-123');
        expect(restored.status, original.status);
        expect(restored.retryCount, original.retryCount);
      });
    });

    group('🔄 WorkoutNotification Conversion Integration', () {
      testWidgets('Converts workout reminder correctly', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold()),
          ),
        );

        final workoutNotification = workout.WorkoutNotification(
          id: 12345,
          type: workout.NotificationType.workoutReminder,
          title: 'Workout Reminder',
          body: 'Time for your Push Day workout!',
          scheduledTime: DateTime(2025, 1, 15, 9, 0),
          priority: workout.NotificationPriority.medium,
          routineId: 'routine-123',
          workoutName: 'Push Day',
        );

        final unified = UnifiedNotification.fromWorkoutNotification(workoutNotification);

        expect(unified.id, '12345');
        expect(unified.type, NotificationType.workoutReminder);
        expect(unified.title, 'Workout Reminder');
        expect(unified.body, 'Time for your Push Day workout!');
        expect(unified.scheduledTime, DateTime(2025, 1, 15, 9, 0));
        expect(unified.priority, NotificationPriority.normal); // medium -> normal
        expect(unified.payload?['routineId'], 'routine-123');
        expect(unified.payload?['workoutName'], 'Push Day');
        expect(unified.workoutId, 'routine-123');
      });

      testWidgets('Converts recovery alert type', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold()),
          ),
        );

        final workoutNotification = workout.WorkoutNotification(
          id: 999,
          type: workout.NotificationType.recoveryAlert,
          title: 'Recovery Needed',
          body: 'You have 2 skipped days!',
          scheduledTime: DateTime.now(),
          priority: workout.NotificationPriority.high,
          daysToRecover: 2,
        );

        final unified = UnifiedNotification.fromWorkoutNotification(workoutNotification);

        expect(unified.type, NotificationType.restReminder);
        expect(unified.priority, NotificationPriority.high);
        expect(unified.payload?['daysToRecover'], 2);
      });

      testWidgets('Converts streak motivation type', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold()),
          ),
        );

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

      testWidgets('Handles delivered notification status', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold()),
          ),
        );

        final deliveredAt = DateTime(2025, 1, 15, 10, 0);
        final workoutNotification = workout.WorkoutNotification(
          id: 555,
          type: workout.NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test body',
          scheduledTime: DateTime.now(),
          priority: workout.NotificationPriority.medium,
          isDelivered: true,
          deliveredAt: deliveredAt,
        );

        final unified = UnifiedNotification.fromWorkoutNotification(workoutNotification);

        expect(unified.status, NotificationDeliveryStatus.delivered);
        expect(unified.deliveredAt, deliveredAt);
      });
    });

    group('📊 Computed Properties Integration', () {
      testWidgets('canRetry respects retry limit', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold()),
          ),
        );

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

      testWidgets('isOverdue detects overdue notifications', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold()),
          ),
        );

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

    group('⚖️ Equality and Hashing', () {
      testWidgets('Notifications with same ID are equal', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold()),
          ),
        );

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

      testWidgets('Notifications with different IDs are not equal', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold()),
          ),
        );

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

    group('🎯 Platform-Specific Configuration', () {
      testWidgets('iOS configuration is properly created', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold()),
          ),
        );

        final iosConfig = IOSNotificationConfig(
          critical: true,
          volume: 0.8,
          categoryId: 'workout_reminder',
          threadId: 'workouts',
          badge: 1,
        );

        final notification = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test',
          iosConfig: iosConfig,
        );

        expect(notification.iosConfig?.critical, true);
        expect(notification.iosConfig?.volume, 0.8);
        expect(notification.iosConfig?.categoryId, 'workout_reminder');
        expect(notification.iosConfig?.threadId, 'workouts');
        expect(notification.iosConfig?.badge, 1);
      });

      testWidgets('Android configuration is properly created', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold()),
          ),
        );

        final androidConfig = AndroidNotificationConfig(
          channelId: 'workout_reminders',
          channelName: 'Workout Reminders',
          channelDescription: 'Notifications for workout reminders',
          autoCancel: true,
        );

        final notification = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test',
          androidConfig: androidConfig,
        );

        expect(notification.androidConfig?.channelId, 'workout_reminders');
        expect(notification.androidConfig?.channelName, 'Workout Reminders');
        expect(notification.androidConfig?.autoCancel, true);
      });
    });

    group('📝 CopyWith Integration', () {
      testWidgets('copyWith creates correct copies', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold()),
          ),
        );

        final original = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Original Title',
          body: 'Original Body',
          priority: NotificationPriority.normal,
        );

        final updated = original.copyWith(
          title: 'Updated Title',
          priority: NotificationPriority.high,
          tags: ['important', 'workout'],
        );

        // Updated fields
        expect(updated.title, 'Updated Title');
        expect(updated.priority, NotificationPriority.high);
        expect(updated.tags, contains('important'));

        // Unchanged fields
        expect(updated.id, original.id);
        expect(updated.body, 'Original Body');
        expect(updated.type, NotificationType.workoutReminder);
      });
    });

    group('🔄 Retry Logic Integration', () {
      testWidgets('incrementRetry schedules future retry', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold()),
          ),
        );

        final failedNotification = UnifiedNotification(
          type: NotificationType.workoutReminder,
          title: 'Test',
          body: 'Test body',
          status: NotificationDeliveryStatus.failed,
          retryCount: 1,
        );

        final beforeRetry = DateTime.now();
        final retried = failedNotification.incrementRetry();

        expect(retried.retryCount, 2);
        expect(retried.status, NotificationDeliveryStatus.pending);
        expect(retried.scheduledTime.isAfter(beforeRetry), true);
        // With retryCount=1, formula adds 1*5=5 minutes
        expect(
          retried.scheduledTime.difference(beforeRetry).inMinutes,
          greaterThanOrEqualTo(4), // Allow for execution time
        );
      });
    });
  });
}
