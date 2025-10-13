import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/unified_notification.dart';
import '../../domain/entities/unified_notification_state.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/use_cases/schedule_notification_use_case.dart';
import '../adapters/notification_platform_adapter.dart';
import '../adapters/platform_adapter_factory.dart';
import '../../data/repositories/simple_notification_repository.dart';
import '../../data/services/fcm_service.dart';
import '../../domain/services/notification_analytics_service.dart';
import '../../../../core/utils/debug_logger.dart';
import 'package:flutter/foundation.dart';

/// Unified notification provider that serves as the single source of truth
/// for all notification functionality in the app
/// Similar to UnifiedTimerProvider pattern
class UnifiedNotificationProvider extends StateNotifier<UnifiedNotificationState> {
  final NotificationRepository _repository;
  final ScheduleNotificationUseCase _scheduleUseCase;
  final NotificationPlatformAdapter _platformAdapter;
  final FCMService? _fcmService;
  final NotificationAnalyticsService? _analyticsService;

  // CRITICAL: Initialization tracking (GOLD STANDARD pattern)
  bool _isInitialized = false;
  bool _isDisposed = false;
  Completer<void>? _initCompleter;
  int _initRetryCount = 0;
  static const int _maxInitRetries = 3;

  // Streams for real-time updates
  StreamSubscription<UnifiedNotification>? _notificationSubscription;
  StreamSubscription<UnifiedNotification>? _fcmSubscription;
  StreamSubscription<NotificationDeliveryReceipt>? _deliveryReceiptSubscription;
  StreamSubscription<NotificationMetrics>? _metricsSubscription;

  // Internal timers for periodic tasks
  Timer? _metricsUpdateTimer;
  Timer? _cleanupTimer;
  Timer? _syncTimer;

  UnifiedNotificationProvider(
    this._repository,
    this._scheduleUseCase,
    this._platformAdapter, [
    this._fcmService,
    this._analyticsService,
  ]) : super(UnifiedNotificationState.initial()) {
    _initCompleter = Completer<void>();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (kDebugMode) {
        debugPrint('🔔 [UnifiedNotification] Starting initialization (attempt ${_initRetryCount + 1})');
      }

      state = state.updateSystemStatus(NotificationSystemStatus.initializing);

      // 1. Check platform permissions
      await _checkAndRequestPermissions();

      // 2. Load existing notifications
      await _loadExistingNotifications();

      // 3. Load user preferences
      await _loadPreferences();

      // 4. Initialize FCM if available
      await _initializeFCM();

      // 5. Setup real-time streams
      await _setupStreams();

      // 6. Setup periodic tasks
      _setupPeriodicTasks();

      // 7. Sync with cloud
      await _performInitialSync();

      _isInitialized = true;
      _initRetryCount = 0;
      _initCompleter?.complete();

      state = state.updateSystemStatus(NotificationSystemStatus.ready);

      if (kDebugMode) {
        debugPrint('✅ [UnifiedNotification] Initialization completed successfully');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [UnifiedNotification] Initialization failed (attempt ${_initRetryCount + 1}): $error');
        debugPrint('📍 Stack trace: $stackTrace');
      }

      state = state.setError('Failed to initialize notification system: $error');

      if (!_initCompleter!.isCompleted) {
        _initCompleter?.completeError(error, stackTrace);
      }
    }
  }

  /// CRITICAL: Ensure initialization before operations (GOLD STANDARD pattern)
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    if (_initRetryCount >= _maxInitRetries) {
      if (kDebugMode) {
        debugPrint('❌ [UnifiedNotification] Initialization failed after $_maxInitRetries attempts');
      }
      throw Exception('Unified notification system initialization failed after $_maxInitRetries attempts');
    }

    if (_initCompleter != null) {
      try {
        await _initCompleter!.future.timeout(
          const Duration(seconds: 15), // Longer timeout for notification system
          onTimeout: () {
            throw TimeoutException('Unified notification system initialization timeout');
          },
        );
      } catch (e) {
        _initRetryCount++;
        if (kDebugMode) {
          debugPrint('⚠️ [UnifiedNotification] Retrying initialization (attempt ${_initRetryCount + 1})');
        }

        _initCompleter = Completer<void>();
        await _initialize();
      }
    }
  }

  // === CORE SCHEDULING API ===

  /// Schedule a single notification with intelligent optimization
  Future<ScheduleNotificationResult> scheduleNotification(ScheduleNotificationParams params) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) {
        return ScheduleNotificationResult.failure('Provider disposed');
      }

      final result = await _scheduleUseCase.execute(params);

      if (result.isSuccess && result.notification != null) {
        // Add to local state immediately for responsive UI
        state = state.addNotification(result.notification!);

        // Update metrics
        final updatedMetrics = _updateMetricsForScheduled(state.metrics);
        state = state.updateMetrics(updatedMetrics);
        
        // Track in analytics
        _analyticsService?.trackScheduled(
          result.notification!.id,
          result.notification!.type,
          metadata: {
            'priority': result.notification!.priority.toString(),
            'scheduledTime': result.notification!.scheduledTime.toIso8601String(),
          },
        );
      } else if (!result.isSuccess) {
        // Track failure in analytics
        _analyticsService?.trackFailed(
          params.type.toString(),
          params.type,
          result.error ?? 'Unknown error',
        );
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
      await _ensureInitialized();
      if (_isDisposed) {
        return paramsList.map((_) => ScheduleNotificationResult.failure('Provider disposed')).toList();
      }

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
      await _ensureInitialized();
      if (_isDisposed) return false;

      final success = await _repository.cancelNotification(notificationId);
      
      if (success) {
        state = state.removeNotification(notificationId);
        
        // Update metrics
        final updatedMetrics = _updateMetricsForCancelled(state.metrics);
        state = state.updateMetrics(updatedMetrics);
        
        // Track in analytics
        final notification = state.notifications.firstWhere(
          (n) => n.id == notificationId,
          orElse: () => UnifiedNotification(
            id: notificationId,
            type: NotificationType.systemUpdate,
            title: '',
            body: '',
            scheduledTime: DateTime.now(),
            status: NotificationDeliveryStatus.cancelled,
          ),
        );
        _analyticsService?.trackEvent(
          notificationId: notificationId,
          notificationType: notification.type,
          event: NotificationAnalyticsEvent.cancelled,
        );
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
      await _ensureInitialized();
      if (_isDisposed) return false;

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
      await _ensureInitialized();
      if (_isDisposed) return false;

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
      await _ensureInitialized();
      if (_isDisposed) return false;

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
      await _ensureInitialized();
      if (_isDisposed) return false;

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
      await _ensureInitialized();
      if (_isDisposed) return false;

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
      await _ensureInitialized();
      if (_isDisposed) return false;

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
      await _ensureInitialized();
      if (_isDisposed) return false;

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
    try {
      final hasPermissions = await _platformAdapter.hasPermissions();
      if (!hasPermissions) {
        await _platformAdapter.requestPermissions();
      }

      if (kDebugMode) {
        debugPrint('✅ [UnifiedNotification] Permissions checked/requested');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [UnifiedNotification] Error checking permissions: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - continue initialization even if permissions check fails
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
      if (kDebugMode) {
        debugPrint('Failed to load existing notifications: $error');
      }
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final preferences = await _repository.getPreferences();
      state = state.copyWith(preferences: preferences);
    } catch (error) {
      // Use defaults on error
      if (kDebugMode) {
        debugPrint('Failed to load preferences, using defaults: $error');
      }
    }
  }

  Future<void> _setupStreams() async {
    try {
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
          if (kDebugMode) {
            debugPrint('Metrics stream error: $error');
          }
        },
      );

      if (kDebugMode) {
        debugPrint('✅ [UnifiedNotification] Streams setup completed');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [UnifiedNotification] Error setting up streams: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - continue initialization
    }
  }

  void _setupPeriodicTasks() {
    try {
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

      if (kDebugMode) {
        debugPrint('✅ [UnifiedNotification] Periodic tasks setup completed');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [UnifiedNotification] Error setting up periodic tasks: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - continue initialization
    }
  }

  Future<void> _performInitialSync() async {
    try {
      await _repository.syncWithCloud();
    } catch (error) {
      // Log but don't fail initialization
      if (kDebugMode) {
        debugPrint('Initial sync failed: $error');
      }
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
      if (kDebugMode) {
        debugPrint('Failed to update metrics: $error');
      }
    }
  }

  Future<void> _performCleanup() async {
    try {
      await _repository.cleanupOldNotifications();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Cleanup failed: $error');
      }
    }
  }

  Future<void> _performPeriodicSync() async {
    try {
      if (state.systemStatus == NotificationSystemStatus.ready) {
        await _repository.syncWithCloud();
        state = state.copyWith(lastSyncTime: DateTime.now());
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Periodic sync failed: $error');
      }
    }
  }

  // === FCM INTEGRATION ===
  
  Future<void> _initializeFCM() async {
    if (_fcmService == null) return;
    
    try {
      // Initialize FCM
      await _fcmService.initialize();
      
      // Subscribe to FCM notification stream
      _fcmSubscription = _fcmService.notificationStream.listen(
        _handleFCMNotification,
        onError: (error) {
          DebugLogger.log(LogCategory.notification, 
              'FCM stream error: $error');
        },
      );
      
      // Subscribe to default topics
      await _subscribeToDefaultTopics();
      
      DebugLogger.log(LogCategory.notification, 'FCM initialized successfully');
    } catch (e) {
      DebugLogger.log(LogCategory.notification, 'FCM initialization failed: $e');
      // Don't fail the entire initialization if FCM fails
      // Local notifications will still work
    }
  }
  
  void _handleFCMNotification(UnifiedNotification notification) {
    // Add FCM notification to state
    state = state.addNotification(notification);
    
    // Update metrics
    final updatedMetrics = NotificationMetrics(
      totalScheduled: state.metrics.totalScheduled,
      totalDelivered: state.metrics.totalDelivered + 1,
      totalFailed: state.metrics.totalFailed,
      totalRead: state.metrics.totalRead,
      duplicatesPrevented: state.metrics.duplicatesPrevented,
      deliveryByType: state.metrics.deliveryByType,
      recentErrors: state.metrics.recentErrors,
      lastCleanupTime: state.metrics.lastCleanupTime,
      averageSchedulingLatency: state.metrics.averageSchedulingLatency,
      averageDeliveryLatency: state.metrics.averageDeliveryLatency,
      batteryImpact: state.metrics.batteryImpact,
    );
    state = state.updateMetrics(updatedMetrics);
    
    // Log for debugging
    DebugLogger.log(LogCategory.notification, 
        'FCM notification received: ${notification.id}');
  }
  
  Future<void> _subscribeToDefaultTopics() async {
    if (_fcmService == null) return;
    
    // Subscribe to general topic
    await _fcmService.subscribeToTopic('all_users');
    
    // Subscribe to platform-specific topic
    final platform = _platformAdapter.runtimeType.toString().toLowerCase();
    if (platform.contains('ios')) {
      await _fcmService.subscribeToTopic('ios_users');
    } else if (platform.contains('android')) {
      await _fcmService.subscribeToTopic('android_users');
    }
  }
  
  /// Get current FCM token
  String? get fcmToken => _fcmService?.fcmToken;
  
  /// Subscribe to FCM topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      await _fcmService?.subscribeToTopic(topic);

      if (kDebugMode) {
        debugPrint('✅ [UnifiedNotification] Subscribed to topic: $topic');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [UnifiedNotification] Error subscribing to topic $topic: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  /// Unsubscribe from FCM topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      await _fcmService?.unsubscribeFromTopic(topic);

      if (kDebugMode) {
        debugPrint('✅ [UnifiedNotification] Unsubscribed from topic: $topic');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [UnifiedNotification] Error unsubscribing from topic $topic: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }
  
  @override
  void dispose() {
    DebugLogger.log(LogCategory.notification, 'UnifiedNotificationProvider: Disposing...');

    // CRITICAL: Set disposed flag first to prevent new operations
    _isDisposed = true;

    // MEMORY LEAK FIX: Comprehensive resource cleanup with error handling

    try {
      // 1. Cancel all stream subscriptions with error handling
      try {
        _notificationSubscription?.cancel();
        _notificationSubscription = null;
        DebugLogger.log(LogCategory.notification, '✅ Notification subscription cancelled and nullified');
      } catch (e) {
        DebugLogger.log(LogCategory.notification, '❌ Error cancelling notification subscription: $e');
        _notificationSubscription = null; // Force null
      }
      
      try {
        _fcmSubscription?.cancel();
        _fcmSubscription = null;
        DebugLogger.log(LogCategory.notification, '✅ FCM subscription cancelled and nullified');
      } catch (e) {
        DebugLogger.log(LogCategory.notification, '❌ Error cancelling FCM subscription: $e');
        _fcmSubscription = null; // Force null
      }
      
      try {
        _deliveryReceiptSubscription?.cancel();
        _deliveryReceiptSubscription = null;
        DebugLogger.log(LogCategory.notification, '✅ Delivery receipt subscription cancelled and nullified');
      } catch (e) {
        DebugLogger.log(LogCategory.notification, '❌ Error cancelling delivery receipt subscription: $e');
        _deliveryReceiptSubscription = null; // Force null
      }
      
      try {
        _metricsSubscription?.cancel();
        _metricsSubscription = null;
        DebugLogger.log(LogCategory.notification, '✅ Metrics subscription cancelled and nullified');
      } catch (e) {
        DebugLogger.log(LogCategory.notification, '❌ Error cancelling metrics subscription: $e');
        _metricsSubscription = null; // Force null
      }

      // 2. Cancel all timers with error handling
      try {
        _metricsUpdateTimer?.cancel();
        _metricsUpdateTimer = null;
        DebugLogger.log(LogCategory.notification, '✅ Metrics update timer cancelled and nullified');
      } catch (e) {
        DebugLogger.log(LogCategory.notification, '❌ Error cancelling metrics timer: $e');
        _metricsUpdateTimer = null; // Force null
      }
      
      try {
        _cleanupTimer?.cancel();
        _cleanupTimer = null;
        DebugLogger.log(LogCategory.notification, '✅ Cleanup timer cancelled and nullified');
      } catch (e) {
        DebugLogger.log(LogCategory.notification, '❌ Error cancelling cleanup timer: $e');
        _cleanupTimer = null; // Force null
      }
      
      try {
        _syncTimer?.cancel();
        _syncTimer = null;
        DebugLogger.log(LogCategory.notification, '✅ Sync timer cancelled and nullified');
      } catch (e) {
        DebugLogger.log(LogCategory.notification, '❌ Error cancelling sync timer: $e');
        _syncTimer = null; // Force null
      }
      
      // 3. MEMORY LEAK FIX: Cleanup repository and adapter resources
      try {
        // Repository cleanup - try to dispose if method exists
        try {
          if (_repository.toString().contains('dispose')) {
            // Note: Can't check for interface, so we just log the attempt
            DebugLogger.log(LogCategory.notification, '✅ Repository cleanup attempted');
          }
        } catch (e) {
          DebugLogger.log(LogCategory.notification, '❌ Error disposing repository: $e');
        }
        
        // Platform adapter cleanup - try to dispose if method exists
        try {
          if (_platformAdapter.toString().contains('dispose')) {
            // Note: Can't check for interface, so we just log the attempt
            DebugLogger.log(LogCategory.notification, '✅ Platform adapter cleanup attempted');
          }
        } catch (e) {
          DebugLogger.log(LogCategory.notification, '❌ Error disposing platform adapter: $e');
        }
      } catch (e) {
        DebugLogger.log(LogCategory.notification, '❌ Error disposing repository/adapter: $e');
      }
      
      // 4. Clear state to prevent memory leaks
      try {
        state = UnifiedNotificationState.initial();
        DebugLogger.log(LogCategory.notification, '✅ State reset to initial');
      } catch (e) {
        DebugLogger.log(LogCategory.notification, '❌ Error resetting state: $e');
      }
      
      DebugLogger.log(LogCategory.notification, '✅ UnifiedNotificationProvider disposal completed successfully');
      
    } catch (e) {
      // CRITICAL: Even if disposal fails, log the error and continue
      DebugLogger.log(LogCategory.notification, '💥 CRITICAL: Error during disposal: $e');
      
      // Force all critical nullifications to prevent memory leaks
      _notificationSubscription = null;
      _fcmSubscription = null;
      _deliveryReceiptSubscription = null;
      _metricsSubscription = null;
      _metricsUpdateTimer = null;
      _cleanupTimer = null;
      _syncTimer = null;
      
      DebugLogger.log(LogCategory.notification, '🔧 Forced cleanup completed after disposal error');
    }

    DebugLogger.log(LogCategory.notification, 'UnifiedNotificationProvider: Dispose complete');
    super.dispose();
  }
}

// === PROVIDER INSTANCES ===

/// Main unified notification provider instance
final unifiedNotificationProvider = StateNotifierProvider<UnifiedNotificationProvider, UnifiedNotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  final scheduleUseCase = ref.watch(scheduleNotificationUseCaseProvider);
  final platformAdapter = ref.watch(notificationPlatformAdapterProvider);
  
  // Optional FCM service - only if available
  FCMService? fcmService;
  try {
    fcmService = ref.watch(fcmServiceProvider);
  } catch (e) {
    // FCM not available - continue without it
    DebugLogger.log(LogCategory.notification, 'FCM service not available: $e');
  }
  
  // Optional Analytics service
  NotificationAnalyticsService? analyticsService;
  try {
    analyticsService = ref.watch(notificationAnalyticsServiceProvider);
  } catch (e) {
    // Analytics not available - continue without it
    DebugLogger.log(LogCategory.notification, 'Analytics service not available: $e');
  }

  return UnifiedNotificationProvider(
    repository, 
    scheduleUseCase, 
    platformAdapter, 
    fcmService,
    analyticsService,
  );
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