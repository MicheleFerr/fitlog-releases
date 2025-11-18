/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/repositories
/// 🎯 Feature: ai_coach
/// 🔧 Type: repository
///
/// Health Connect Repository - Clean Architecture repository for Android health data
///
/// **Architecture**: Coordinates datasource, mapper, and sync service
/// **Caching**: In-memory cache with 6h TTL (aligned with feature gate cache)
/// **Thread-Safety**: Single sync guard prevents concurrent requests
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/health_connect_datasource.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/mappers/health_data_mapper.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/health_connect_sync_service.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/errors/healthkit_errors.dart'; // Shared error types for both platforms
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/health_metric.dart';

/// HealthConnect repository following Clean Architecture pattern
///
/// **Responsibilities**:
/// - Provide clean interface for presentation layer
/// - Coordinate datasource, mapper, and sync service
/// - Implement caching strategy (6h TTL)
/// - Handle errors gracefully with user-friendly messages
///
/// **Usage**:
/// ```dart
/// final repository = HealthConnectRepository();
/// await repository.initialize();
///
/// // Fetch today's steps (cached)
/// final stepsResult = await repository.getStepsToday();
/// stepsResult.fold(
///   (error) => print('Error: ${error.message}'),
///   (metric) => print('Steps: ${metric.formattedValue}'),
/// );
///
/// // Start background sync
/// repository.startBackgroundSync();
/// ```
///
/// **Cache Strategy**:
/// - In-memory cache with 6h TTL (same as feature gate cache)
/// - Cache invalidated on manual sync
/// - Cache key: metric type + date range
class HealthConnectRepository {
  HealthConnectRepository({
    HealthConnectDatasource? datasource,
    HealthConnectSyncService? syncService,
  })  : _datasource = datasource ?? HealthConnectDatasource(),
        _syncService = syncService ?? HealthConnectSyncService();

  final HealthConnectDatasource _datasource;
  final HealthConnectSyncService _syncService;

  /// In-memory cache for health metrics
  /// Key: "{metricType}_{dateRange}" (e.g., "steps_today", "workouts_week")
  /// Value: (metric, timestamp)
  final Map<String, (HealthMetric, DateTime)> _metricCache = {};

  /// In-memory cache for metric lists (workouts)
  /// Key: "{metricType}_{dateRange}" (e.g., "workouts_today", "workouts_week")
  /// Value: (metrics, timestamp)
  final Map<String, (List<HealthMetric>, DateTime)> _listCache = {};

  /// Cache TTL (6 hours, aligned with feature gate cache)
  static const _cacheTTL = Duration(hours: 6);

  /// Is repository initialized
  bool _isInitialized = false;

  /// Is HealthConnect available on this device
  bool get isAvailable => _datasource.isAvailable;

  /// Is repository initialized
  bool get isInitialized => _isInitialized;

  /// Initialize repository (requests HealthConnect permissions)
  ///
  /// Returns `true` if initialized successfully
  ///
  /// **Throws**:
  /// - `HealthKitNotAvailableError`: Android not available
  /// - `HealthKitPermissionDeniedError`: User denied permissions
  ///
  /// **Usage**:
  /// ```dart
  /// try {
  ///   await repository.initialize();
  /// } catch (e) {
  ///   HealthKitErrorHandler.handle(
  ///     error: e,
  ///     onPermissionDenied: () => showPermissionDialog(),
  ///   );
  /// }
  /// ```
  Future<bool> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        debugPrint('⚠️ [HealthConnectRepository] Already initialized');
      }
      return true;
    }

    try {
      // Initialize datasource (requests permissions)
      await _datasource.initialize();

      // Initialize sync service (performs initial sync)
      await _syncService.initialize();

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ [HealthConnectRepository] Initialized successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectRepository] Initialize failed: $e');
      }
      rethrow;
    }
  }

  // ==========================================
  // STEPS DATA
  // ==========================================

  /// Get today's step count
  ///
  /// Returns cached value if available and fresh (less than 6h old)
  ///
  /// **Returns**: Tuple (HealthKitError?, HealthMetric?)
  Future<(HealthKitError?, HealthMetric?)> getStepsToday() async {
    if (!_isInitialized) {
      return (const HealthKitPermissionNotDeterminedError(), null);
    }

    const cacheKey = 'steps_today';

    // Check cache
    final cached = _getFromCache(cacheKey);
    if (cached != null) {
      if (kDebugMode) {
        debugPrint('📦 [HealthConnectRepository] Cache hit: $cacheKey');
      }
      return (null, cached);
    }

    try {
      final dataPoint = await _datasource.getStepsToday();
      if (dataPoint == null) {
        return (const HealthKitNoDataError('steps'), null);
      }

      final metric = HealthDataMapper.toHealthMetric(dataPoint);
      if (metric == null) {
        return (const HealthKitInvalidDataError(), null);
      }

      // Cache result
      _cacheMetric(cacheKey, metric);

      return (null, metric);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectRepository] getStepsToday failed: $e');
      }

      if (e is HealthKitError) {
        return (e, null);
      }
      return (const HealthKitNoDataError('steps'), null);
    }
  }

  /// Get total steps for the last 7 days
  Future<(HealthKitError?, HealthMetric?)> getStepsThisWeek() async {
    if (!_isInitialized) {
      return (const HealthKitPermissionNotDeterminedError(), null);
    }

    const cacheKey = 'steps_week';

    final cached = _getFromCache(cacheKey);
    if (cached != null) return (null, cached);

    try {
      final dataPoint = await _datasource.getStepsThisWeek();
      if (dataPoint == null) {
        return (const HealthKitNoDataError('steps'), null);
      }

      final metric = HealthDataMapper.toHealthMetric(dataPoint);
      if (metric == null) {
        return (const HealthKitInvalidDataError(), null);
      }

      _cacheMetric(cacheKey, metric);
      return (null, metric);
    } catch (e) {
      if (e is HealthKitError) return (e, null);
      return (const HealthKitNoDataError('steps'), null);
    }
  }

  /// Get total steps for the last 30 days
  Future<(HealthKitError?, HealthMetric?)> getStepsThisMonth() async {
    if (!_isInitialized) {
      return (const HealthKitPermissionNotDeterminedError(), null);
    }

    const cacheKey = 'steps_month';

    final cached = _getFromCache(cacheKey);
    if (cached != null) return (null, cached);

    try {
      final dataPoint = await _datasource.getStepsThisMonth();
      if (dataPoint == null) {
        return (const HealthKitNoDataError('steps'), null);
      }

      final metric = HealthDataMapper.toHealthMetric(dataPoint);
      if (metric == null) {
        return (const HealthKitInvalidDataError(), null);
      }

      _cacheMetric(cacheKey, metric);
      return (null, metric);
    } catch (e) {
      if (e is HealthKitError) return (e, null);
      return (const HealthKitNoDataError('steps'), null);
    }
  }

  // ==========================================
  // HEART RATE DATA
  // ==========================================

  /// Get average heart rate for today
  Future<(HealthKitError?, HealthMetric?)> getHeartRateToday() async {
    if (!_isInitialized) {
      return (const HealthKitPermissionNotDeterminedError(), null);
    }

    const cacheKey = 'heart_rate_today';

    final cached = _getFromCache(cacheKey);
    if (cached != null) return (null, cached);

    try {
      final dataPoint = await _datasource.getHeartRateToday();
      if (dataPoint == null) {
        return (const HealthKitNoDataError('heart rate'), null);
      }

      final metric = HealthDataMapper.toHealthMetric(dataPoint);
      if (metric == null) {
        return (const HealthKitInvalidDataError(), null);
      }

      _cacheMetric(cacheKey, metric);
      return (null, metric);
    } catch (e) {
      if (e is HealthKitError) return (e, null);
      return (const HealthKitNoDataError('heart rate'), null);
    }
  }

  /// Get resting heart rate (overnight average)
  Future<(HealthKitError?, HealthMetric?)> getRestingHeartRate() async {
    if (!_isInitialized) {
      return (const HealthKitPermissionNotDeterminedError(), null);
    }

    const cacheKey = 'resting_heart_rate';

    final cached = _getFromCache(cacheKey);
    if (cached != null) return (null, cached);

    try {
      final dataPoint = await _datasource.getRestingHeartRate();
      if (dataPoint == null) {
        return (const HealthKitNoDataError('resting heart rate'), null);
      }

      final metric = HealthDataMapper.toHealthMetric(dataPoint);
      if (metric == null) {
        return (const HealthKitInvalidDataError(), null);
      }

      _cacheMetric(cacheKey, metric);
      return (null, metric);
    } catch (e) {
      if (e is HealthKitError) return (e, null);
      return (const HealthKitNoDataError('resting heart rate'), null);
    }
  }

  // ==========================================
  // WORKOUT DATA
  // ==========================================

  /// Get all workouts for today
  Future<(HealthKitError?, List<HealthMetric>)> getWorkoutsToday() async {
    if (!_isInitialized) {
      return (const HealthKitPermissionNotDeterminedError(), <HealthMetric>[]);
    }

    const cacheKey = 'workouts_today';

    final cached = _getFromListCache(cacheKey);
    if (cached != null) return (null, cached);

    try {
      final dataPoints = await _datasource.getWorkoutsToday();
      final metrics = HealthDataMapper.toHealthMetrics(dataPoints);

      _cacheMetricList(cacheKey, metrics);
      return (null, metrics);
    } catch (e) {
      if (e is HealthKitError) return (e, <HealthMetric>[]);
      return (const HealthKitNoDataError('workouts'), <HealthMetric>[]);
    }
  }

  /// Get all workouts for the last 7 days
  Future<(HealthKitError?, List<HealthMetric>)> getWorkoutsThisWeek() async {
    if (!_isInitialized) {
      return (const HealthKitPermissionNotDeterminedError(), <HealthMetric>[]);
    }

    const cacheKey = 'workouts_week';

    final cached = _getFromListCache(cacheKey);
    if (cached != null) return (null, cached);

    try {
      final dataPoints = await _datasource.getWorkoutsThisWeek();
      final metrics = HealthDataMapper.toHealthMetrics(dataPoints);

      _cacheMetricList(cacheKey, metrics);
      return (null, metrics);
    } catch (e) {
      if (e is HealthKitError) return (e, <HealthMetric>[]);
      return (const HealthKitNoDataError('workouts'), <HealthMetric>[]);
    }
  }

  /// Get all workouts for the last 30 days
  Future<(HealthKitError?, List<HealthMetric>)> getWorkoutsThisMonth() async {
    if (!_isInitialized) {
      return (const HealthKitPermissionNotDeterminedError(), <HealthMetric>[]);
    }

    const cacheKey = 'workouts_month';

    final cached = _getFromListCache(cacheKey);
    if (cached != null) return (null, cached);

    try {
      final dataPoints = await _datasource.getWorkoutsThisMonth();
      final metrics = HealthDataMapper.toHealthMetrics(dataPoints);

      _cacheMetricList(cacheKey, metrics);
      return (null, metrics);
    } catch (e) {
      if (e is HealthKitError) return (e, <HealthMetric>[]);
      return (const HealthKitNoDataError('workouts'), <HealthMetric>[]);
    }
  }

  // ==========================================
  // ACTIVE ENERGY & EXERCISE TIME
  // ==========================================

  /// Get total active energy burned today (kcal)
  Future<(HealthKitError?, HealthMetric?)> getActiveEnergyToday() async {
    if (!_isInitialized) {
      return (const HealthKitPermissionNotDeterminedError(), null);
    }

    const cacheKey = 'active_energy_today';

    final cached = _getFromCache(cacheKey);
    if (cached != null) return (null, cached);

    try {
      final dataPoint = await _datasource.getActiveEnergyToday();
      if (dataPoint == null) {
        return (const HealthKitNoDataError('active energy'), null);
      }

      final metric = HealthDataMapper.toHealthMetric(dataPoint);
      if (metric == null) {
        return (const HealthKitInvalidDataError(), null);
      }

      _cacheMetric(cacheKey, metric);
      return (null, metric);
    } catch (e) {
      if (e is HealthKitError) return (e, null);
      return (const HealthKitNoDataError('active energy'), null);
    }
  }

  /// Get total exercise minutes today
  Future<(HealthKitError?, HealthMetric?)> getExerciseTimeToday() async {
    if (!_isInitialized) {
      return (const HealthKitPermissionNotDeterminedError(), null);
    }

    const cacheKey = 'exercise_time_today';

    final cached = _getFromCache(cacheKey);
    if (cached != null) return (null, cached);

    try {
      final dataPoint = await _datasource.getExerciseTimeToday();
      if (dataPoint == null) {
        return (const HealthKitNoDataError('exercise time'), null);
      }

      final metric = HealthDataMapper.toHealthMetric(dataPoint);
      if (metric == null) {
        return (const HealthKitInvalidDataError(), null);
      }

      _cacheMetric(cacheKey, metric);
      return (null, metric);
    } catch (e) {
      if (e is HealthKitError) return (e, null);
      return (const HealthKitNoDataError('exercise time'), null);
    }
  }

  // ==========================================
  // SYNC OPERATIONS
  // ==========================================

  /// Start background sync (every 6h)
  ///
  /// Syncs health data to Firebase in background
  void startBackgroundSync() {
    _syncService.startBackgroundSync();

    if (kDebugMode) {
      debugPrint('▶️ [HealthConnectRepository] Background sync started');
    }
  }

  /// Stop background sync
  void stopBackgroundSync() {
    _syncService.stopBackgroundSync();

    if (kDebugMode) {
      debugPrint('⏸️ [HealthConnectRepository] Background sync stopped');
    }
  }

  /// Manually trigger sync
  ///
  /// Invalidates cache and fetches fresh data from HealthConnect
  ///
  /// Returns `true` if sync successful
  Future<bool> syncNow() async {
    if (!_isInitialized) return false;

    // Invalidate all caches
    _metricCache.clear();
    _listCache.clear();

    if (kDebugMode) {
      debugPrint('🗑️ [HealthConnectRepository] Cache cleared');
    }

    // Trigger sync
    final success = await _syncService.syncNow();

    if (kDebugMode) {
      debugPrint(
        success
            ? '✅ [HealthConnectRepository] Sync successful'
            : '❌ [HealthConnectRepository] Sync failed',
      );
    }

    return success;
  }

  /// Check if sync is needed (cache expired or offline queue not empty)
  bool isSyncNeeded() {
    return _syncService.isSyncNeeded();
  }

  /// Get time until next scheduled sync
  Duration? get timeUntilNextSync => _syncService.timeUntilNextSync;

  /// Get sync statistics (for debugging/UI display)
  Map<String, dynamic> getSyncStats() {
    return _syncService.getSyncStats();
  }

  // ==========================================
  // GDPR COMPLIANCE
  // ==========================================

  /// Delete all cached health data (GDPR Article 17: Right to erasure)
  ///
  /// **Note**: Only deletes local cache. HealthConnect data remains in Google Health Connect.
  Future<bool> deleteAllHealthData() async {
    // Clear in-memory caches
    _metricCache.clear();
    _listCache.clear();

    // Delete datasource cache (if any)
    final datasourceDeleted = await _datasource.deleteAllHealthData();

    if (kDebugMode) {
      debugPrint(
        '🗑️ [HealthConnectRepository] All health data deleted (GDPR Article 17)',
      );
    }

    return datasourceDeleted;
  }

  /// Export all health data as JSON (GDPR Article 20: Data portability)
  Future<Map<String, dynamic>> exportHealthData() async {
    if (!_isInitialized) return {};

    return _datasource.exportHealthData();
  }

  // ==========================================
  // PRIVATE HELPER METHODS
  // ==========================================

  /// Get metric from cache if fresh (< 6h old)
  HealthMetric? _getFromCache(String key) {
    final cached = _metricCache[key];
    if (cached == null) return null;

    final (metric, timestamp) = cached;
    final age = DateTime.now().difference(timestamp);

    if (age > _cacheTTL) {
      // Cache expired
      _metricCache.remove(key);
      return null;
    }

    return metric;
  }

  /// Get metric list from cache if fresh (< 6h old)
  List<HealthMetric>? _getFromListCache(String key) {
    final cached = _listCache[key];
    if (cached == null) return null;

    final (metrics, timestamp) = cached;
    final age = DateTime.now().difference(timestamp);

    if (age > _cacheTTL) {
      // Cache expired
      _listCache.remove(key);
      return null;
    }

    return metrics;
  }

  /// Cache metric with current timestamp
  void _cacheMetric(String key, HealthMetric metric) {
    _metricCache[key] = (metric, DateTime.now());
  }

  /// Cache metric list with current timestamp
  void _cacheMetricList(String key, List<HealthMetric> metrics) {
    _listCache[key] = (metrics, DateTime.now());
  }

  /// Dispose repository (cleanup sync service)
  void dispose() {
    _syncService.dispose();
    _metricCache.clear();
    _listCache.clear();

    if (kDebugMode) {
      debugPrint('🗑️ [HealthConnectRepository] Disposed');
    }
  }
}
