/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/notifications/presentation/providers
/// Feature: Local Notifications System
/// Type: Riverpod Provider
///
/// Provides notification scheduler to the app.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/notification_scheduler.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/notification_message_pool.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:gymbro_flutter_new/features/notifications/data/datasources/local_notification_datasource.dart';
import 'package:gymbro_flutter_new/features/notifications/data/datasources/notification_storage_datasource.dart';

/// Provider for the message pool (stateless, can be instantiated directly)
final notificationMessagePoolProvider = Provider<NotificationMessagePool>((ref) {
  return NotificationMessagePool();
});

/// Provider for the storage datasource
final notificationStorageDatasourceProvider = Provider<NotificationStorageDatasource>((ref) {
  return NotificationStorageDatasource();
});

/// Provider for the local notification datasource
final localNotificationDatasourceProvider = Provider<LocalNotificationDatasource>((ref) {
  return LocalNotificationDatasource();
});

/// Provider for the notification repository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  ref.keepAlive(); // FIX: previene ricreazione repository
  final localDatasource = ref.watch(localNotificationDatasourceProvider);
  final storageDatasource = ref.watch(notificationStorageDatasourceProvider);

  return NotificationRepositoryImpl(
    localNotificationDatasource: localDatasource,
    storageDatasource: storageDatasource,
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
final notificationInitializedProvider = StateProvider<bool>((ref) => false);

/// Initialize the notification system.
///
/// Should be called once during app startup.
Future<void> initializeNotifications(WidgetRef ref) async {
  final scheduler = ref.read(notificationSchedulerProvider);
  await scheduler.initialize();
  ref.read(notificationInitializedProvider.notifier).state = true;
}
