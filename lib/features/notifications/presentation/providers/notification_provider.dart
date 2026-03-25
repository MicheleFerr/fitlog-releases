/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/notifications/presentation/providers
/// Feature: Local Notifications System
/// Type: Riverpod Provider
///
/// Provides notification scheduler to the app.
library;

import 'package:gymbro_flutter_new/core/providers/state_provider_helper.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/notification_scheduler.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/notification_message_pool.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:gymbro_flutter_new/features/notifications/data/datasources/local_notification_datasource.dart';
import 'package:gymbro_flutter_new/features/notifications/data/datasources/notification_storage_datasource.dart';

/// Provider for the message pool (stateless, can be instantiated directly)
final notificationMessagePoolProvider = Provider<NotificationMessagePool>((
  ref,
) {
  return NotificationMessagePool();
});

/// Provider for the storage datasource
final notificationStorageDatasourceProvider =
    Provider<NotificationStorageDatasource>((ref) {
      return NotificationStorageDatasource();
    });

/// Provider for the local notification datasource
final localNotificationDatasourceProvider =
    Provider<LocalNotificationDatasource>((ref) {
      return LocalNotificationDatasource();
    });

/// Provider holding a pending deep link path from notification tap (warm-start).
///
/// Set by [NotificationRepositoryImpl] when a notification is tapped while the
/// app is running. Listened to by [FitLogApp] to trigger GoRouter navigation.
final pendingNotificationDeepLinkProvider = createStateProvider<String?>(null);

/// Extract deep link path from notification payload.
///
/// Expected shape: `type:recordId:/deep-link`.
String? extractNotificationDeepLink(String? payload) {
  if (payload == null) return null;

  final parts = payload.split(':');
  if (parts.length < 3) return null;

  final deepLink = parts.sublist(2).join(':');
  return deepLink.isEmpty ? null : deepLink;
}

/// Provider for the notification repository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  ref.keepAlive(); // FIX: previene ricreazione repository
  final localDatasource = ref.watch(localNotificationDatasourceProvider);
  final storageDatasource = ref.watch(notificationStorageDatasourceProvider);

  return NotificationRepositoryImpl(
    localNotificationDatasource: localDatasource,
    storageDatasource: storageDatasource,
    onDeepLinkNavigation: (deepLink) {
      ref.read(pendingNotificationDeepLinkProvider.notifier).state = deepLink;
    },
  );
});

/// Provider for the notification scheduler
final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  ref.keepAlive(); // FIX: previene ricreazione scheduler con stato
  final repository = ref.watch(notificationRepositoryProvider);
  final messagePool = ref.watch(notificationMessagePoolProvider);

  return NotificationScheduler(
    repository: repository,
    messagePool: messagePool,
  );
});

/// Provider to track if notification system is initialized
final notificationInitializedProvider = createStateProvider<bool>(false);

/// Initialize the notification system.
///
/// Should be called once during app startup.
Future<void> initializeNotifications(WidgetRef ref) async {
  final scheduler = ref.read(notificationSchedulerProvider);
  await scheduler.initialize();
  ref.read(notificationInitializedProvider.notifier).state = true;
}
