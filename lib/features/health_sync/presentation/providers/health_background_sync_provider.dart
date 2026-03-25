import 'package:gymbro_flutter_new/core/providers/state_provider_helper.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_sync_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/data/services/health_background_service.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_sync_provider.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_permission_provider.dart';

// ============================================================
// BACKGROUND SYNC CONFIGURATION
// ============================================================

/// Configuration for background sync scheduling.
class BackgroundSyncConfig {
  const BackgroundSyncConfig({
    this.syncInterval = const Duration(hours: 24),
    this.retryInterval = const Duration(hours: 1),
    this.maxRetries = 3,
    this.syncOnAppLaunch = true,
    this.syncOnWifiOnly = false,
  });

  /// Interval between automatic background syncs (default: 24 hours).
  final Duration syncInterval;

  /// Interval between retry attempts for failed syncs (default: 1 hour).
  final Duration retryInterval;

  /// Maximum number of retry attempts before giving up (default: 3).
  final int maxRetries;

  /// Whether to trigger sync automatically on app launch (default: true).
  final bool syncOnAppLaunch;

  /// Whether to only sync when connected to WiFi (default: false).
  /// iOS/Android: Requires platform channel implementation.
  final bool syncOnWifiOnly;
}

/// Provider for background sync configuration.
///
/// **Customizable**: User can change sync frequency in settings.
final backgroundSyncConfigProvider = createStateProvider<BackgroundSyncConfig>(
  const BackgroundSyncConfig(),
);

// ============================================================
// BACKGROUND SYNC STATE
// ============================================================

/// State for background sync scheduler.
class BackgroundSyncState {
  const BackgroundSyncState({
    this.isScheduled = false,
    this.lastBackgroundSync,
    this.nextScheduledSync,
    this.isSyncing = false,
  });

  /// Whether background sync is currently scheduled (enabled).
  final bool isScheduled;

  /// Timestamp of last successful background sync.
  final DateTime? lastBackgroundSync;

  /// Timestamp of next scheduled background sync.
  final DateTime? nextScheduledSync;

  /// Whether a sync operation is currently in progress.
  final bool isSyncing;

  BackgroundSyncState copyWith({
    bool? isScheduled,
    DateTime? lastBackgroundSync,
    DateTime? nextScheduledSync,
    bool? isSyncing,
  }) {
    return BackgroundSyncState(
      isScheduled: isScheduled ?? this.isScheduled,
      lastBackgroundSync: lastBackgroundSync ?? this.lastBackgroundSync,
      nextScheduledSync: nextScheduledSync ?? this.nextScheduledSync,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

// ============================================================
// BACKGROUND SYNC CONTROLLER
// ============================================================

/// Controller for managing background health sync operations.
///
/// **Features**:
/// - Daily background sync scheduling
/// - Automatic retry for failed syncs (exponential backoff)
/// - Platform-specific task scheduling (iOS BackgroundTasks, Android WorkManager)
/// - Smart sync triggers (app launch, connectivity changes)
///
/// **Platform Support**:
/// - iOS: BackgroundTasks API (requires entitlement + app refresh enabled)
/// - Android: WorkManager API (requires worker implementation)
///
/// Usage:
/// ```dart
/// final controller = ref.read(healthBackgroundSyncControllerProvider.notifier);
///
/// // Enable background sync (schedules daily task)
/// await controller.enableBackgroundSync();
///
/// // Disable background sync (cancels scheduled task)
/// await controller.disableBackgroundSync();
///
/// // Manually trigger background sync
/// await controller.triggerBackgroundSync();
/// ```
final healthBackgroundSyncControllerProvider =
    NotifierProvider<HealthBackgroundSyncController, BackgroundSyncState>(
      HealthBackgroundSyncController.new,
    );

class HealthBackgroundSyncController extends Notifier<BackgroundSyncState> {
  @override
  BackgroundSyncState build() {
    // Defer auto-sync to avoid modifying other providers during initialization
    // Riverpod doesn't allow providers to modify other providers in build()
    ref.onDispose(() {
      // Cleanup when provider is disposed
    });

    Future.microtask(() async {
      await _restoreSchedulerState();
      await _syncOnAppLaunchIfEnabled();
    });

    return const BackgroundSyncState();
  }

  /// Enables background sync scheduling.
  ///
  /// **Platform Behavior**:
  /// - iOS: Registers BackgroundTask with identifier "com.fitlog.healthSync"
  /// - Android: Schedules PeriodicWorkRequest with tag "health_sync"
  ///
  /// **Requirements**:
  /// - User must have granted health permissions
  /// - Background refresh must be enabled (iOS Settings)
  /// - Battery optimization must be disabled (Android Settings)
  Future<void> enableBackgroundSync() async {
    // Check if user has any authorized permissions
    final permissionStatus = await ref.read(
      healthPermissionStatusProvider.future,
    );

    if (!permissionStatus.hasAnySyncAccess) {
      throw Exception(
        'Cannot enable background sync: No health permissions granted',
      );
    }

    final config = ref.read(backgroundSyncConfigProvider);
    await HealthBackgroundService.instance.enable(
      syncInterval: config.syncInterval,
    );

    if (Platform.isIOS) {
      await _scheduleIOSBackgroundTask();
    } else if (Platform.isAndroid) {
      await _scheduleAndroidWorkManager();
    }

    state = state.copyWith(
      isScheduled: true,
      nextScheduledSync: DateTime.now().add(config.syncInterval),
    );
  }

  /// Disables background sync scheduling.
  ///
  /// **Platform Behavior**:
  /// - iOS: Cancels all pending BackgroundTasks with "com.fitlog.healthSync" identifier
  /// - Android: Cancels all workers with tag "health_sync"
  Future<void> disableBackgroundSync() async {
    // Cancel platform-specific background task
    if (Platform.isIOS) {
      await _cancelIOSBackgroundTask();
    } else if (Platform.isAndroid) {
      await _cancelAndroidWorkManager();
    }

    await HealthBackgroundService.instance.disable();

    state = state.copyWith(isScheduled: false, nextScheduledSync: null);
  }

  /// Manually triggers a background sync operation.
  ///
  /// **Use when**:
  /// - User clicks "Sync Now" button in settings
  /// - App returns to foreground after long inactivity
  /// - Connectivity restored after being offline
  ///
  /// **Smart behavior**:
  /// - Checks permissions before syncing
  /// - Only syncs authorized data types
  /// - Updates last sync timestamp
  Future<void> triggerBackgroundSync() async {
    if (state.isSyncing) {
      return; // Already syncing, skip
    }

    state = state.copyWith(isSyncing: true);

    try {
      // Get sync controller
      final syncController = ref.read(healthSyncControllerProvider.notifier);

      // Trigger sync for all authorized data types
      await syncController.syncAll();
      final now = DateTime.now();
      await HealthBackgroundService.instance.recordSuccessfulSync(now);

      // Update state
      state = state.copyWith(
        isSyncing: false,
        lastBackgroundSync: now,
        nextScheduledSync: now.add(
          ref.read(backgroundSyncConfigProvider).syncInterval,
        ),
      );
    } catch (e) {
      await HealthBackgroundService.instance.recordFailedSync(e);
      state = state.copyWith(isSyncing: false);
      rethrow;
    }
  }

  /// Checks if any failed syncs need retry and triggers them.
  ///
  /// **Exponential Backoff**:
  /// - Retry 1: After 1 hour
  /// - Retry 2: After 4 hours
  /// - Retry 3: After 24 hours
  /// - Max retries: 3 (then gives up)
  ///
  /// **Auto-called** by background sync task.
  Future<void> retryFailedSyncs() async {
    final syncController = ref.read(healthSyncControllerProvider.notifier);

    // Check workout sync status
    final workoutStatus = await ref.read(
      healthSyncStatusProvider(HealthDataType.workout).future,
    );

    if (workoutStatus.shouldRetry()) {
      await syncController.retryFailedSync(HealthDataType.workout);
    }

    // Check body weight sync status
    final weightStatus = await ref.read(
      healthSyncStatusProvider(HealthDataType.bodyWeight).future,
    );

    if (weightStatus.shouldRetry()) {
      await syncController.retryFailedSync(HealthDataType.bodyWeight);
    }

    // TODO: Add retry logic for other data types when implemented
  }

  /// Auto-syncs on app launch if enabled in config.
  ///
  /// **Throttling**: Only syncs if last sync was > 12 hours ago.
  Future<void> _syncOnAppLaunchIfEnabled() async {
    final config = ref.read(backgroundSyncConfigProvider);

    if (!config.syncOnAppLaunch) {
      return; // App launch sync disabled
    }

    try {
      final permissionStatus = await ref.read(
        healthPermissionStatusProvider.future,
      );
      final syncableTypes = [
        if (permissionStatus.canAttemptSync(HealthDataType.workout))
          HealthDataType.workout,
        if (permissionStatus.canAttemptSync(HealthDataType.bodyWeight))
          HealthDataType.bodyWeight,
      ];

      if (syncableTypes.isEmpty) {
        return;
      }

      final backgroundSnapshot = await HealthBackgroundService.instance
          .getSnapshot();
      if (!backgroundSnapshot.enabled) {
        return;
      }

      var shouldSync = false;
      for (final dataType in syncableTypes) {
        final status = await ref.read(
          healthSyncStatusProvider(dataType).future,
        );
        if (status.shouldAutoSync()) {
          shouldSync = true;
          break;
        }
      }

      if (!shouldSync) {
        return;
      }

      await triggerBackgroundSync();
    } catch (_) {
      // Startup sync is best-effort and should not surface as an uncaught error.
    }
  }

  // ============================================================
  // PLATFORM-SPECIFIC TASK SCHEDULING
  // ============================================================

  Future<void> _restoreSchedulerState() async {
    final config = ref.read(backgroundSyncConfigProvider);
    await HealthBackgroundService.instance.configure(
      syncInterval: config.syncInterval,
    );

    final snapshot = await HealthBackgroundService.instance.getSnapshot();
    state = state.copyWith(
      isScheduled: snapshot.enabled,
      lastBackgroundSync: snapshot.lastBackgroundSync,
      nextScheduledSync: snapshot.enabled && snapshot.lastBackgroundSync != null
          ? snapshot.lastBackgroundSync!.add(config.syncInterval)
          : null,
    );
  }

  /// iOS: Schedules BackgroundTask using BackgroundTasks API.
  ///
  /// **Requirements**:
  /// - Add "com.fitlog.healthSync" to Info.plist BGTaskSchedulerPermittedIdentifiers
  /// - Register task handler in AppDelegate.swift
  /// - Enable Background Modes > Background fetch capability
  ///
  /// **Implementation**: Calls platform channel to native iOS code.
  Future<void> _scheduleIOSBackgroundTask() async {
    await HealthBackgroundService.instance.enable(
      syncInterval: ref.read(backgroundSyncConfigProvider).syncInterval,
    );
  }

  /// iOS: Cancels all pending BackgroundTasks.
  Future<void> _cancelIOSBackgroundTask() async {
    await HealthBackgroundService.instance.disable();
  }

  /// Android: Schedules PeriodicWorkRequest using WorkManager.
  ///
  /// **Requirements**:
  /// - Add androidx.work:work-runtime dependency to build.gradle
  /// - Implement HealthSyncWorker extending Worker
  /// - Handle doWork() method for sync logic
  ///
  /// **Implementation**: Calls platform channel to native Android code.
  Future<void> _scheduleAndroidWorkManager() async {
    await HealthBackgroundService.instance.handleAppBackgrounded(
      syncInterval: ref.read(backgroundSyncConfigProvider).syncInterval,
    );
  }

  /// Android: Cancels all workers with "health_sync" tag.
  Future<void> _cancelAndroidWorkManager() async {
    await HealthBackgroundService.instance.handleAppForegrounded();
  }
}
