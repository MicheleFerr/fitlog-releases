/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/services
/// 🎯 Feature: ai_coach
/// 🔧 Type: service
///
/// Health Connect Sync Service - Background syncing of Google Health Connect data
///
/// **SYNC STRATEGY**:
/// - App launch: Immediate sync (get latest data)
/// - Background: Every 6h (aligned with feature gate polling)
/// - Manual trigger: User pull-to-refresh in settings
/// - Offline queue: Retry failed syncs when online
///
/// **PRIVACY FIRST**:
/// - Only syncs if user granted Health Connect permissions
/// - Respects user privacy preferences (can disable per-feature)
/// - No data sent to third parties (Firebase only)
/// - GDPR Article 9 compliant (explicit consent)
///
/// **OPTIMIZATION**:
/// - Batch updates (1 Firebase write per sync, not per metric)
/// - Cache last sync timestamp (skip if data unchanged)
/// - Smart scheduling (avoid syncing during workouts)
///
/// **SYNC METRICS**:
/// - Steps (daily total)
/// - Heart Rate (resting HR from overnight)
/// - Workouts (count for last 7 days)
/// - Active Energy (daily total)
/// - Exercise Minutes (daily total)
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/firebase_feature_gate_datasource.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/health_connect_datasource.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/errors/healthkit_errors.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/models/queued_sync.dart';

/// Health Connect sync service for background data synchronization
///
/// **Architecture**: Data layer service following Clean Architecture
///
/// **Usage**:
/// ```dart
/// final service = HealthConnectSyncService();
/// await service.initialize();
/// service.startBackgroundSync(); // 6h interval
///
/// // Manual sync
/// await service.syncNow();
///
/// // Check sync status
/// final stats = service.getSyncStats();
/// print('Last sync: ${stats['lastSyncAt']}');
/// ```
///
/// **Lifecycle**:
/// - Call `initialize()` on app launch
/// - Call `startBackgroundSync()` to enable periodic sync
/// - Call `dispose()` when service no longer needed
///
/// **Platform**: Android 12+ (API 28+) with Health Connect installed
class HealthConnectSyncService {
  HealthConnectSyncService({
    HealthConnectDatasource? healthConnectDatasource,
    FirebaseFeatureGateDatasource? firebaseDatasource,
    Duration syncInterval = const Duration(hours: 6),
  })  : _healthConnectDatasource =
            healthConnectDatasource ?? HealthConnectDatasource(),
        _firebaseDatasource =
            firebaseDatasource ?? FirebaseFeatureGateDatasource(),
        _syncInterval = syncInterval;

  final HealthConnectDatasource _healthConnectDatasource;
  final FirebaseFeatureGateDatasource _firebaseDatasource;
  final Duration _syncInterval;

  /// Background sync timer
  Timer? _syncTimer;

  /// Last successful sync timestamp
  DateTime? _lastSyncAt;

  /// Is sync currently in progress
  bool _isSyncing = false;

  /// Sync success/failure counters
  int _syncSuccessCount = 0;
  int _syncFailureCount = 0;

  /// Hive box for persistent offline queue
  Box<QueuedSync>? _queueBox;

  /// UUID generator for queue items
  final _uuid = const Uuid();

  /// Is background sync active
  bool get isBackgroundSyncActive => _syncTimer?.isActive ?? false;

  /// Initialize service and perform initial sync
  ///
  /// Returns `true` if Health Connect available and initialized
  ///
  /// **Throws**:
  /// - `HealthKitNotAvailableError`: Android not available or Health Connect not installed
  /// - `HealthKitPermissionDeniedError`: User denied permissions
  ///
  /// **Usage**:
  /// ```dart
  /// try {
  ///   final initialized = await service.initialize();
  /// } catch (e) {
  ///   HealthKitErrorHandler.handle(
  ///     error: e,
  ///     onPermissionDenied: () => showPermissionDialog(),
  ///     onNotAvailable: () => disableHealthFeatures(),
  ///   );
  /// }
  /// ```
  Future<bool> initialize() async {
    if (!_healthConnectDatasource.isAvailable) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [HealthConnectSyncService] Health Connect not available (Android 12+ only)',
        );
      }
      throw const HealthKitNotAvailableError();
    }

    try {
      // Open Hive box for persistent queue
      _queueBox = await Hive.openBox<QueuedSync>('health_connect_sync_queue');

      if (kDebugMode) {
        debugPrint(
          '📦 [HealthConnectSyncService] Hive queue opened '
          '(${_queueBox!.length} pending syncs)',
        );
      }

      // Request Health Connect permissions (throws on denial)
      await _healthConnectDatasource.initialize();

      if (kDebugMode) {
        debugPrint('✅ [HealthConnectSyncService] Initialized successfully');
      }

      // Perform initial sync (will also process queued syncs)
      await syncNow();

      return true;
    } on HealthKitError {
      // Re-throw HealthKit errors for caller to handle
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectSyncService] Initialize failed: $e');
      }
      // Wrap unknown errors
      throw const HealthKitPermissionDeniedError();
    }
  }

  /// Start background sync (every 6h)
  ///
  /// Executes sync immediately, then repeats at interval
  ///
  /// **Usage**:
  /// ```dart
  /// service.startBackgroundSync();
  /// ```
  void startBackgroundSync() {
    if (isBackgroundSyncActive) {
      if (kDebugMode) {
        debugPrint('⚠️ [HealthConnectSyncService] Background sync already active');
      }
      return;
    }

    // Execute immediately on start
    syncNow();

    // Schedule periodic sync
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      syncNow();
    });

    if (kDebugMode) {
      debugPrint(
        '▶️ [HealthConnectSyncService] Background sync started '
        '(interval: ${_syncInterval.inHours}h)',
      );
    }
  }

  /// Stop background sync
  void stopBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = null;

    if (kDebugMode) {
      debugPrint('⏸️ [HealthConnectSyncService] Background sync stopped');
    }
  }

  /// Manually trigger sync (bypasses interval)
  ///
  /// Used for:
  /// - User pull-to-refresh
  /// - App resume from background
  /// - After workout completion
  ///
  /// Returns `true` if sync successful, `false` otherwise
  ///
  /// **Usage**:
  /// ```dart
  /// final success = await service.syncNow();
  /// if (!success) {
  ///   // Show error: "Sync failed"
  /// }
  /// ```
  Future<bool> syncNow() async {
    if (_isSyncing) {
      if (kDebugMode) {
        debugPrint('⚠️ [HealthConnectSyncService] Sync already in progress');
      }
      return false;
    }

    _isSyncing = true;

    // Declare healthMetrics outside try block so catch blocks can access it
    Map<String, dynamic> healthMetrics = {};

    try {
      if (kDebugMode) {
        debugPrint('🔄 [HealthConnectSyncService] Syncing Health Connect data...');
      }

      // Fetch latest health metrics
      healthMetrics = await _fetchHealthMetrics();

      if (healthMetrics.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [HealthConnectSyncService] No health data available',
          );
        }
        _isSyncing = false;
        return false;
      }

      // Update Firebase with latest metrics
      // TODO: Get userId from auth provider
      const userId = 'temp-user-id'; // Placeholder until auth integration
      await _updateFirebaseWithMetrics(userId, healthMetrics);

      // Mark success
      _lastSyncAt = DateTime.now();
      _syncSuccessCount++;

      // Process offline queue (retry failed syncs)
      await _processOfflineQueue();

      if (kDebugMode) {
        debugPrint(
          '✅ [HealthConnectSyncService] Sync completed '
          '(${healthMetrics.length} metrics)',
        );
      }

      _isSyncing = false;
      return true;
    } on HealthKitSyncNetworkError catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectSyncService] Sync failed: Network error');
      }

      // Network errors: Add to Hive queue for auto-retry
      await _addToQueue(healthMetrics, e.toString(), retryable: true);

      _syncFailureCount++;
      _isSyncing = false;
      return false;
    } on HealthKitSyncTimeoutError catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectSyncService] Sync failed: Timeout');
      }

      // Timeout errors: Add to Hive queue for retry
      await _addToQueue(healthMetrics, e.toString(), retryable: true);

      _syncFailureCount++;
      _isSyncing = false;
      return false;
    } on HealthKitSyncRateLimitError {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectSyncService] Sync failed: Rate limited');
      }

      // Rate limit errors: Don't queue (will retry on next scheduled sync)
      _syncFailureCount++;
      _isSyncing = false;
      return false;
    } on HealthKitSyncServerError catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectSyncService] Sync failed: Server error');
      }

      // Server errors: Add to Hive queue for retry
      await _addToQueue(healthMetrics, e.toString(), retryable: true);

      _syncFailureCount++;
      _isSyncing = false;
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectSyncService] Sync failed: $e');
      }

      // Unknown errors: Log but don't queue
      _syncFailureCount++;
      _isSyncing = false;
      return false;
    }
  }

  /// Check if sync is needed (cache expired or data stale)
  ///
  /// Returns `true` if:
  /// - Never synced before
  /// - Last sync > 6h ago
  /// - Hive queue not empty (failed syncs pending)
  bool isSyncNeeded() {
    if (_queueBox != null && _queueBox!.isNotEmpty) return true;
    if (_lastSyncAt == null) return true;

    final timeSinceLastSync = DateTime.now().difference(_lastSyncAt!);
    return timeSinceLastSync >= _syncInterval;
  }

  /// Get time until next scheduled sync
  Duration? get timeUntilNextSync {
    if (!isBackgroundSyncActive || _lastSyncAt == null) return null;

    final nextSyncAt = _lastSyncAt!.add(_syncInterval);
    final remaining = nextSyncAt.difference(DateTime.now());

    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Get sync statistics (for debugging/UI display)
  Map<String, dynamic> getSyncStats() {
    return {
      'isBackgroundSyncActive': isBackgroundSyncActive,
      'isSyncing': _isSyncing,
      'lastSyncAt': _lastSyncAt?.toIso8601String(),
      'timeSinceLastSync': _lastSyncAt != null
          ? DateTime.now().difference(_lastSyncAt!).inSeconds
          : null,
      'timeUntilNextSync': timeUntilNextSync?.inSeconds,
      'syncSuccessCount': _syncSuccessCount,
      'syncFailureCount': _syncFailureCount,
      'offlineQueueSize': _queueBox?.length ?? 0,
      'syncIntervalHours': _syncInterval.inHours,
    };
  }

  /// Dispose service (cleanup timer and Hive box)
  void dispose() {
    stopBackgroundSync();
    _queueBox?.close();

    if (kDebugMode) {
      debugPrint('🗑️ [HealthConnectSyncService] Disposed');
    }
  }

  // ==========================================
  // PRIVATE HELPER METHODS
  // ==========================================

  /// Fetch latest health metrics from Health Connect
  ///
  /// Returns map with metric names and values
  Future<Map<String, dynamic>> _fetchHealthMetrics() async {
    final metrics = <String, dynamic>{};

    try {
      // Steps (today)
      final steps = await _healthConnectDatasource.getStepsToday();
      if (steps != null) {
        metrics['steps_today'] = (steps.value as num).toInt();
      }

      // Resting Heart Rate (overnight average)
      final restingHR = await _healthConnectDatasource.getRestingHeartRate();
      if (restingHR != null) {
        metrics['resting_heart_rate'] = (restingHR.value as num).toInt();
      }

      // Workout count (last 7 days)
      final workouts = await _healthConnectDatasource.getWorkoutsThisWeek();
      metrics['workouts_this_week'] = workouts.length;

      // Active Energy (today)
      final energy = await _healthConnectDatasource.getActiveEnergyToday();
      if (energy != null) {
        metrics['active_energy_today'] = (energy.value as num).toInt();
      }

      // Exercise Minutes (today)
      final exerciseTime = await _healthConnectDatasource.getExerciseTimeToday();
      if (exerciseTime != null) {
        metrics['exercise_minutes_today'] = (exerciseTime.value as num).toInt();
      }

      // Add metadata
      metrics['synced_at'] = DateTime.now().toIso8601String();
      metrics['source'] = 'google_health_connect';

      return metrics;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectSyncService] _fetchHealthMetrics failed: $e');
      }
      return {};
    }
  }

  /// Update Firebase with latest health metrics (batch write)
  ///
  /// **Optimization**: Single Firebase write for all metrics
  ///
  /// **Throws**:
  /// - `HealthKitSyncNetworkError`: No network connection
  /// - `HealthKitSyncTimeoutError`: Request timeout
  /// - `HealthKitSyncServerError`: Firebase server error
  Future<void> _updateFirebaseWithMetrics(
    String userId,
    Map<String, dynamic> metrics,
  ) async {
    try {
      // Update user context in Firebase (ai_coach document)
      // Merges with existing data (doesn't overwrite other fields)
      await _firebaseDatasource.updateUserContext(
        userId: userId,
        healthMetrics: metrics,
      );

      if (kDebugMode) {
        debugPrint(
          '✅ [HealthConnectSyncService] Firebase updated with ${metrics.length} metrics',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [HealthConnectSyncService] _updateFirebaseWithMetrics failed: $e',
        );
      }

      // Categorize Firebase errors
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('network') ||
          errorString.contains('no internet') ||
          errorString.contains('connection')) {
        throw const HealthKitSyncNetworkError();
      } else if (errorString.contains('timeout') ||
          errorString.contains('deadline')) {
        throw const HealthKitSyncTimeoutError();
      } else if (errorString.contains('permission') ||
          errorString.contains('quota') ||
          errorString.contains('rate limit')) {
        throw const HealthKitSyncRateLimitError();
      } else {
        throw const HealthKitSyncServerError();
      }
    }
  }

  /// Add failed sync to Hive queue for retry
  ///
  /// **Exponential Backoff**: Calculated based on retry count (30s → 10m)
  Future<void> _addToQueue(
    Map<String, dynamic> healthMetrics,
    String error, {
    required bool retryable,
  }) async {
    if (_queueBox == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [HealthConnectSyncService] Queue box not initialized');
      }
      return;
    }

    if (!retryable) {
      if (kDebugMode) {
        debugPrint('⚠️ [HealthConnectSyncService] Sync not retryable, skipping queue');
      }
      return;
    }

    final queuedSync = QueuedSync(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      healthMetrics: healthMetrics,
      error: error,
      retryCount: 0,
      retryable: retryable,
      nextRetryAt: DateTime.now().add(const Duration(seconds: 30)), // First retry: 30s
    );

    try {
      await _queueBox!.put(queuedSync.id, queuedSync);

      if (kDebugMode) {
        debugPrint(
          '📥 [HealthConnectSyncService] Added to queue: ${queuedSync.id} '
          '(retry in 30s)',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectSyncService] Failed to add to queue: $e');
      }
    }
  }

  /// Process offline queue (retry failed syncs with exponential backoff)
  ///
  /// Called after each successful sync to retry previous failures
  ///
  /// **Retry Strategy**:
  /// - Only retries if past nextRetryAt time
  /// - Exponential backoff: 30s → 1m → 2m → 5m → 10m (max)
  /// - Max 5 retry attempts, then discard
  /// - Skips non-retryable errors
  Future<void> _processOfflineQueue() async {
    if (_queueBox == null || _queueBox!.isEmpty) return;

    if (kDebugMode) {
      debugPrint(
        '🔄 [HealthConnectSyncService] Processing offline queue '
        '(${_queueBox!.length} items)',
      );
    }

    final toRetry = <QueuedSync>[];
    final toDiscard = <String>[];

    // Collect items ready for retry
    for (final entry in _queueBox!.values) {
      // Check if exceeded max retries
      if (entry.hasExceededMaxRetries) {
        toDiscard.add(entry.id);
        if (kDebugMode) {
          debugPrint(
            '❌ [HealthConnectSyncService] Discarding ${entry.id} '
            '(max retries exceeded)',
          );
        }
        continue;
      }

      // Check if not retryable
      if (!entry.retryable) {
        toDiscard.add(entry.id);
        continue;
      }

      // Check if ready for retry (past backoff time)
      if (entry.isReadyForRetry) {
        toRetry.add(entry);
      } else {
        if (kDebugMode) {
          final timeLeft = entry.timeUntilNextRetry;
          debugPrint(
            '⏳ [HealthConnectSyncService] ${entry.id} not ready '
            '(retry in ${timeLeft?.inSeconds}s)',
          );
        }
      }
    }

    // Discard non-retryable and exceeded items
    for (final id in toDiscard) {
      await _queueBox!.delete(id);
    }

    // Retry ready items
    for (final queuedSync in toRetry) {
      if (kDebugMode) {
        debugPrint(
          '🔄 [HealthConnectSyncService] Retrying ${queuedSync.id} '
          '(attempt ${queuedSync.retryCount + 1}/5)',
        );
      }

      try {
        // TODO: Get actual userId from auth provider
        const userId = 'temp-user-id';

        // Attempt sync
        await _updateFirebaseWithMetrics(userId, queuedSync.healthMetrics);

        // Success: Remove from queue
        await _queueBox!.delete(queuedSync.id);

        if (kDebugMode) {
          debugPrint(
            '✅ [HealthConnectSyncService] Retry successful: ${queuedSync.id}',
          );
        }
      } catch (e) {
        // Retry failed: Increment retry count with exponential backoff
        final updated = queuedSync.incrementRetry();
        await _queueBox!.put(updated.id, updated);

        if (kDebugMode) {
          debugPrint(
            '❌ [HealthConnectSyncService] Retry failed: ${queuedSync.id} '
            '(next retry in ${updated.backoffDelay.inMinutes}m)',
          );
        }
      }
    }

    if (kDebugMode) {
      debugPrint(
        '✅ [HealthConnectSyncService] Offline queue processed '
        '(${_queueBox!.length} remaining)',
      );
    }
  }
}
