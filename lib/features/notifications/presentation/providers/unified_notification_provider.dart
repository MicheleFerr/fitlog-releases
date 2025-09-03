import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/unified_notification.dart';
import '../../domain/entities/unified_notification_state.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/use_cases/schedule_notification_use_case.dart';
import '../adapters/notification_platform_adapter.dart';
import '../adapters/platform_adapter_factory.dart';
import '../../data/repositories/simple_notification_repository.dart';

/// Unified notification provider that serves as the single source of truth
/// for all notification functionality in the app
/// Similar to UnifiedTimerProvider pattern
class UnifiedNotificationProvider extends StateNotifier<UnifiedNotificationState> {
  final NotificationRepository _repository;
  final ScheduleNotificationUseCase _scheduleUseCase;
  final NotificationPlatformAdapter _platformAdapter;

  // Streams for real-time updates
  StreamSubscription<UnifiedNotification>? _notificationSubscription;
  StreamSubscription<NotificationDeliveryReceipt>? _deliveryReceiptSubscription;
  StreamSubscription<NotificationMetrics>? _metricsSubscription;

  // Internal timers for periodic tasks
  Timer? _metricsUpdateTimer;
  Timer? _cleanupTimer;
  Timer? _syncTimer;

  UnifiedNotificationProvider(
    this._repository,
    this._scheduleUseCase,
    this._platformAdapter,
  ) : super(UnifiedNotificationState.initial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      state = state.updateSystemStatus(NotificationSystemStatus.initializing);

      // 1. Check platform permissions
      await _checkAndRequestPermissions();

      // 2. Load existing notifications
      await _loadExistingNotifications();

      // 3. Load user preferences
      await _loadPreferences();

      // 4. Setup real-time streams
      await _setupStreams();

      // 5. Setup periodic tasks
      _setupPeriodicTasks();

      // 6. Sync with cloud
      await _performInitialSync();

      state = state.updateSystemStatus(NotificationSystemStatus.ready);
    } catch (error) {
      state = state.setError('Failed to initialize notification system: $error');
    }
  }

  // === CORE SCHEDULING API ===

  /// Schedule a single notification with intelligent optimization
  Future<ScheduleNotificationResult> scheduleNotification(ScheduleNotificationParams params) async {
    try {
      final result = await _scheduleUseCase.execute(params);

      if (result.isSuccess && result.notification != null) {
        // Add to local state immediately for responsive UI
        state = state.addNotification(result.notification!);

        // Update metrics
        final updatedMetrics = _updateMetricsForScheduled(state.metrics);
        state = state.updateMetrics(updatedMetrics);
      }

      return result;
    } catch (error) {
      return ScheduleNotificationResult.failure('Unexpected error: $error');
    }
  }

  /// Schedule multiple notifications in batch
  Future<List<ScheduleNotificationResult>> scheduleMultipleNotifications(
    List<ScheduleNotificationParams> paramsList,
  ) async {
    final results = <ScheduleNotificationResult>[];
    
    try {
      // Add all to pending queue first for immediate UI feedback
      final pendingNotifications = paramsList.map((params) => 
        UnifiedNotification(
          type: params.type,
          title: params.title,
          body: params.body,
          scheduledTime: params.scheduledTime,
          status: NotificationDeliveryStatus.pending,
        )
      ).toList();

      state = state.copyWith(
        pendingQueue: [...state.pendingQueue, ...pendingNotifications]
      );

      // Process each notification
      for (final params in paramsList) {
        final result = await scheduleNotification(params);
        results.add(result);
      }

      // Clear pending queue
      state = state.copyWith(pendingQueue: []);
      
      return results;
    } catch (error) {
      state = state.copyWith(pendingQueue: []);
      return paramsList.map((_) => ScheduleNotificationResult.failure('Batch error: $error')).toList();
    }
  }

  /// Cancel a notification
  Future<bool> cancelNotification(String notificationId) async {
    try {
      final success = await _repository.cancelNotification(notificationId);
      
      if (success) {
        state = state.removeNotification(notificationId);
        
        // Update metrics
        final updatedMetrics = _updateMetricsForCancelled(state.metrics);
        state = state.updateMetrics(updatedMetrics);
      }
      
      return success;
    } catch (error) {
      state = state.setError('Failed to cancel notification: $error');
      return false;
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final success = await _repository.markAsRead(notificationId);
      
      if (success) {
        state = state.markAsRead(notificationId);
      }
      
      return success;
    } catch (error) {
      state = state.setError('Failed to mark as read: $error');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final notificationIds = state.unreadNotifications.map((n) => n.id).toList();
      final success = await _repository.markMultipleAsRead(notificationIds);
      
      if (success) {
        state = state.markAllAsRead();
      }
      
      return success;
    } catch (error) {
      state = state.setError('Failed to mark all as read: $error');
      return false;
    }
  }

  // === PREFERENCES MANAGEMENT ===

  /// Update notification preferences
  Future<bool> updatePreferences(NotificationPreferences preferences) async {
    try {
      final success = await _repository.updatePreferences(preferences);
      
      if (success) {
        state = state.copyWith(preferences: preferences);
        
        // Apply new preferences to platform
        await _platformAdapter.updatePreferences(preferences);
      }
      
      return success;
    } catch (error) {
      state = state.setError('Failed to update preferences: $error');
      return false;
    }
  }

  /// Toggle notification type on/off
  Future<bool> toggleNotificationType(NotificationType type, bool enabled) async {
    try {
      final updatedPreferences = NotificationPreferences(
        enabled: state.preferences.enabled,
        typePreferences: {
          ...state.preferences.typePreferences,
          type: enabled,
        },
        quietHours: state.preferences.quietHours,
        soundPreferences: state.preferences.soundPreferences,
        vibrationEnabled: state.preferences.vibrationEnabled,
        frequency: state.preferences.frequency,
        language: state.preferences.language,
      );
      
      return await updatePreferences(updatedPreferences);
    } catch (error) {
      state = state.setError('Failed to toggle notification type: $error');
      return false;
    }
  }

  // === SYSTEM MANAGEMENT ===

  /// Perform health check on the notification system
  Future<bool> performHealthCheck() async {
    try {
      state = state.updateSystemStatus(NotificationSystemStatus.syncing);
      
      // Check platform permissions
      final hasPermissions = await _platformAdapter.hasPermissions();
      if (!hasPermissions) {
        state = state.setError('Notification permissions not granted');
        return false;
      }

      // Check repository health
      final repoHealthy = await _repository.isSystemHealthy();
      if (!repoHealthy) {
        state = state.setError('Repository health check failed');
        return false;
      }

      // Check platform adapter health
      final adapterHealthy = await _platformAdapter.performHealthCheck();
      if (!adapterHealthy) {
        state = state.setError('Platform adapter health check failed');
        return false;
      }

      state = state.updateSystemStatus(NotificationSystemStatus.ready);
      return true;
    } catch (error) {
      state = state.setError('Health check failed: $error');
      return false;
    }
  }

  /// Force sync with cloud services
  Future<bool> forceSync() async {
    try {
      state = state.updateSystemStatus(NotificationSystemStatus.syncing);
      
      final success = await _repository.syncWithCloud();
      
      if (success) {
        // Reload data after sync
        await _loadExistingNotifications();
        await _loadPreferences();
        
        state = state.copyWith(
          lastSyncTime: DateTime.now(),
          systemStatus: NotificationSystemStatus.ready,
        );
      } else {
        state = state.setError('Sync failed');
      }
      
      return success;
    } catch (error) {
      state = state.setError('Sync error: $error');
      return false;
    }
  }

  /// Clear all notifications
  Future<bool> clearAllNotifications() async {
    try {
      // Cancel all pending notifications
      final pendingIds = state.notifications
          .where((n) => n.isPending)
          .map((n) => n.id)
          .toList();

      if (pendingIds.isNotEmpty) {
        await _repository.cancelMultipleNotifications(pendingIds);
      }

      // Clear from state
      state = state.copyWith(
        notifications: [],
        unreadCount: 0,
        lastSyncTime: DateTime.now(),
      );

      return true;
    } catch (error) {
      state = state.setError('Failed to clear notifications: $error');
      return false;
    }
  }

  // === INTERNAL METHODS ===

  Future<void> _checkAndRequestPermissions() async {
    final hasPermissions = await _platformAdapter.hasPermissions();
    if (!hasPermissions) {
      await _platformAdapter.requestPermissions();
    }
  }

  Future<void> _loadExistingNotifications() async {
    try {
      final notifications = await _repository.getAllNotifications(limit: 100);
      final unreadCount = notifications.where((n) => !n.isRead).length;
      
      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
      );
    } catch (error) {
      // Log but don't fail initialization
      print('Failed to load existing notifications: $error');
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final preferences = await _repository.getPreferences();
      state = state.copyWith(preferences: preferences);
    } catch (error) {
      // Use defaults on error
      print('Failed to load preferences, using defaults: $error');
    }
  }

  Future<void> _setupStreams() async {
    // Listen to incoming notifications
    _notificationSubscription = _repository.notificationStream.listen(
      (notification) {
        state = state.addNotification(notification);
      },
      onError: (error) {
        state = state.setError('Notification stream error: $error');
      },
    );

    // Listen to delivery receipts
    _deliveryReceiptSubscription = _repository.deliveryReceiptStream.listen(
      (receipt) {
        final updatedDeliveryStatus = {
          ...state.deliveryStatus,
          receipt.notificationId: receipt,
        };
        
        state = state.copyWith(deliveryStatus: updatedDeliveryStatus);
        
        // Update notification status based on receipt
        if (receipt.status == NotificationDeliveryStatus.delivered) {
          _updateNotificationStatus(receipt.notificationId, NotificationDeliveryStatus.delivered);
        } else if (receipt.status == NotificationDeliveryStatus.failed) {
          _updateNotificationStatus(receipt.notificationId, NotificationDeliveryStatus.failed);
        }
      },
      onError: (error) {
        state = state.setError('Delivery receipt stream error: $error');
      },
    );

    // Listen to metrics updates
    _metricsSubscription = _repository.metricsStream.listen(
      (metrics) {
        state = state.updateMetrics(metrics);
      },
      onError: (error) {
        print('Metrics stream error: $error');
      },
    );
  }

  void _setupPeriodicTasks() {
    // Update metrics every 30 seconds
    _metricsUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateMetrics(),
    );

    // Cleanup old notifications every hour
    _cleanupTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _performCleanup(),
    );

    // Sync every 15 minutes
    _syncTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _performPeriodicSync(),
    );
  }

  Future<void> _performInitialSync() async {
    try {
      await _repository.syncWithCloud();
    } catch (error) {
      // Log but don't fail initialization
      print('Initial sync failed: $error');
    }
  }

  void _updateNotificationStatus(String notificationId, NotificationDeliveryStatus status) {
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(status: status);
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);
  }

  NotificationMetrics _updateMetricsForScheduled(NotificationMetrics currentMetrics) {
    return NotificationMetrics(
      totalScheduled: currentMetrics.totalScheduled + 1,
      totalDelivered: currentMetrics.totalDelivered,
      totalFailed: currentMetrics.totalFailed,
      totalRead: currentMetrics.totalRead,
      duplicatesPrevented: currentMetrics.duplicatesPrevented,
      deliveryByType: currentMetrics.deliveryByType,
      recentErrors: currentMetrics.recentErrors,
      lastCleanupTime: currentMetrics.lastCleanupTime,
      averageSchedulingLatency: currentMetrics.averageSchedulingLatency,
      averageDeliveryLatency: currentMetrics.averageDeliveryLatency,
      batteryImpact: currentMetrics.batteryImpact,
    );
  }

  NotificationMetrics _updateMetricsForCancelled(NotificationMetrics currentMetrics) {
    return NotificationMetrics(
      totalScheduled: currentMetrics.totalScheduled - 1,
      totalDelivered: currentMetrics.totalDelivered,
      totalFailed: currentMetrics.totalFailed,
      totalRead: currentMetrics.totalRead,
      duplicatesPrevented: currentMetrics.duplicatesPrevented,
      deliveryByType: currentMetrics.deliveryByType,
      recentErrors: currentMetrics.recentErrors,
      lastCleanupTime: currentMetrics.lastCleanupTime,
      averageSchedulingLatency: currentMetrics.averageSchedulingLatency,
      averageDeliveryLatency: currentMetrics.averageDeliveryLatency,
      batteryImpact: currentMetrics.batteryImpact,
    );
  }

  Future<void> _updateMetrics() async {
    try {
      final metrics = await _repository.getMetrics();
      state = state.updateMetrics(metrics);
    } catch (error) {
      print('Failed to update metrics: $error');
    }
  }

  Future<void> _performCleanup() async {
    try {
      await _repository.cleanupOldNotifications();
    } catch (error) {
      print('Cleanup failed: $error');
    }
  }

  Future<void> _performPeriodicSync() async {
    try {
      if (state.systemStatus == NotificationSystemStatus.ready) {
        await _repository.syncWithCloud();
        state = state.copyWith(lastSyncTime: DateTime.now());
      }
    } catch (error) {
      print('Periodic sync failed: $error');
    }
  }

  @override
  void dispose() {
    // Cancel all subscriptions
    _notificationSubscription?.cancel();
    _deliveryReceiptSubscription?.cancel();
    _metricsSubscription?.cancel();

    // Cancel all timers
    _metricsUpdateTimer?.cancel();
    _cleanupTimer?.cancel();
    _syncTimer?.cancel();

    super.dispose();
  }
}

// === PROVIDER INSTANCES ===

/// Main unified notification provider instance
final unifiedNotificationProvider = StateNotifierProvider<UnifiedNotificationProvider, UnifiedNotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  final scheduleUseCase = ref.watch(scheduleNotificationUseCaseProvider);
  final platformAdapter = ref.watch(notificationPlatformAdapterProvider);

  return UnifiedNotificationProvider(repository, scheduleUseCase, platformAdapter);
});

// === COMPUTED PROVIDERS ===

/// Current notification count
final notificationCountProvider = Provider<int>((ref) {
  return ref.watch(unifiedNotificationProvider.select((state) => state.notifications.length));
});

/// Unread notification count
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(unifiedNotificationProvider.select((state) => state.unreadCount));
});

/// System health status
final notificationSystemHealthProvider = Provider<bool>((ref) {
  final state = ref.watch(unifiedNotificationProvider);
  return state.systemStatus == NotificationSystemStatus.ready && !state.hasError;
});

/// Today's notifications
final todayNotificationsProvider = Provider<List<UnifiedNotification>>((ref) {
  return ref.watch(unifiedNotificationProvider.select((state) => state.todayNotifications));
});

/// Notification metrics
final notificationMetricsProvider = Provider<NotificationMetrics>((ref) {
  return ref.watch(unifiedNotificationProvider.select((state) => state.metrics));
});

/// System status
final notificationSystemStatusProvider = Provider<NotificationSystemStatus>((ref) {
  return ref.watch(unifiedNotificationProvider.select((state) => state.systemStatus));
});

// === DEPENDENCY PROVIDERS ===
// These will be implemented in their respective files

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return SimpleNotificationRepository();
});

final scheduleNotificationUseCaseProvider = Provider<ScheduleNotificationUseCase>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return ScheduleNotificationUseCase(repository);
});

final notificationPlatformAdapterProvider = Provider<NotificationPlatformAdapter>((ref) {
  // Use the factory to create the platform-specific adapter
  return NotificationPlatformAdapterFactory.create();
});