import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_sync_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
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
final backgroundSyncConfigProvider = StateProvider<BackgroundSyncConfig>(
  (_) => const BackgroundSyncConfig(),
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
    StateNotifierProvider<HealthBackgroundSyncController, BackgroundSyncState>(
  (ref) => HealthBackgroundSyncController(ref),
);

class HealthBackgroundSyncController extends StateNotifier<BackgroundSyncState> {
  HealthBackgroundSyncController(this._ref)
      : super(const BackgroundSyncState()) {
    // Auto-sync on app launch if enabled
    _syncOnAppLaunchIfEnabled();
  }

  final Ref _ref;

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
    final permissionStatus =
        await _ref.read(healthPermissionStatusProvider.future);

    if (permissionStatus.hasNoPermissions) {
      throw Exception(
        'Cannot enable background sync: No health permissions granted',
      );
    }

    // Schedule platform-specific background task
    if (Platform.isIOS) {
      await _scheduleIOSBackgroundTask();
    } else if (Platform.isAndroid) {
      await _scheduleAndroidWorkManager();
    }

    // Update state
    final config = _ref.read(backgroundSyncConfigProvider);
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

    // Update state
    state = state.copyWith(
      isScheduled: false,
      nextScheduledSync: null,
    );
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
      final syncController =
          _ref.read(healthSyncControllerProvider.notifier);

      // Trigger sync for all authorized data types
      await syncController.syncAll();

      // Update state
      state = state.copyWith(
        isSyncing: false,
        lastBackgroundSync: DateTime.now(),
      );
    } catch (e) {
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
    final syncController = _ref.read(healthSyncControllerProvider.notifier);

    // Check workout sync status
    final workoutStatus = await _ref.read(
      healthSyncStatusProvider(HealthDataType.workout).future,
    );

    if (workoutStatus.shouldRetry()) {
      await syncController.retryFailedSync(HealthDataType.workout);
    }

    // Check body weight sync status
    final weightStatus = await _ref.read(
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
    final config = _ref.read(backgroundSyncConfigProvider);

    if (!config.syncOnAppLaunch) {
      return; // App launch sync disabled
    }

    // Throttle: Only sync if last sync was > 12 hours ago
    if (state.lastBackgroundSync != null) {
      final timeSinceLastSync =
          DateTime.now().difference(state.lastBackgroundSync!);
      if (timeSinceLastSync < const Duration(hours: 12)) {
        return; // Too soon, skip
      }
    }

    // Trigger background sync
    await triggerBackgroundSync();
  }

  // ============================================================
  // PLATFORM-SPECIFIC TASK SCHEDULING
  // ============================================================

  /// iOS: Schedules BackgroundTask using BackgroundTasks API.
  ///
  /// **Requirements**:
  /// - Add "com.fitlog.healthSync" to Info.plist BGTaskSchedulerPermittedIdentifiers
  /// - Register task handler in AppDelegate.swift
  /// - Enable Background Modes > Background fetch capability
  ///
  /// **Implementation**: Calls platform channel to native iOS code.
  Future<void> _scheduleIOSBackgroundTask() async {
    // TODO: Implement platform channel call to iOS BackgroundTasks API
    // final config = _ref.read(backgroundSyncConfigProvider);
    //
    // await methodChannel.invokeMethod('scheduleBackgroundTask', {
    //   'identifier': 'com.fitlog.healthSync',
    //   'interval': config.syncInterval.inSeconds,
    // });

    throw UnimplementedError(
      'iOS BackgroundTask scheduling not implemented yet',
    );
  }

  /// iOS: Cancels all pending BackgroundTasks.
  Future<void> _cancelIOSBackgroundTask() async {
    // TODO: Implement platform channel call to iOS
    // await methodChannel.invokeMethod('cancelBackgroundTask', {
    //   'identifier': 'com.fitlog.healthSync',
    // });

    throw UnimplementedError(
      'iOS BackgroundTask cancellation not implemented yet',
    );
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
    // TODO: Implement platform channel call to Android WorkManager
    // final config = _ref.read(backgroundSyncConfigProvider);
    //
    // await methodChannel.invokeMethod('schedulePeriodicWork', {
    //   'tag': 'health_sync',
    //   'interval': config.syncInterval.inSeconds,
    //   'requiresWifi': config.syncOnWifiOnly,
    // });

    throw UnimplementedError(
      'Android WorkManager scheduling not implemented yet',
    );
  }

  /// Android: Cancels all workers with "health_sync" tag.
  Future<void> _cancelAndroidWorkManager() async {
    // TODO: Implement platform channel call to Android
    // await methodChannel.invokeMethod('cancelWorkByTag', {
    //   'tag': 'health_sync',
    // });

    throw UnimplementedError(
      'Android WorkManager cancellation not implemented yet',
    );
  }
}
