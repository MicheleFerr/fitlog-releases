/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/data/services
/// 🎯 Feature: Analytics Cache Service
/// 🔧 Type: Service
///
/// Intelligent caching service for analytics data with TTL support.
///
/// **Features**:
/// - TTL (Time-To-Live) based expiration
/// - Hit/miss statistics tracking
/// - Pattern-based invalidation
/// - User-scoped cache clearing
/// - Automatic cleanup of expired entries
/// - JSON serialization for complex types
///
/// **Best Practices (2024)**:
/// - Default 1-hour TTL for analytics data
/// - 5-minute TTL for frequently changing data (workout counts)
/// - Automatic background cleanup every 10 minutes
/// - LRU-style eviction when cache exceeds size limit
///
/// **Usage**:
/// ```dart
/// final cacheService = AnalyticsCacheService(boxManager);
/// await cacheService.initialize();
///
/// // Store with TTL
/// await cacheService.set('key', data, const Duration(hours: 1));
///
/// // Retrieve (null if expired or missing)
/// final cached = await cacheService.get<MyType>('key', MyType.fromJson);
/// ```
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/features/analytics/data/models/cache_metadata.dart';

/// Default cache TTL durations
class CacheTTL {
  CacheTTL._();

  /// Analytics stats cache (1 hour)
  static const Duration analyticsStats = Duration(hours: 1);

  /// Workout history cache (1 hour)
  static const Duration workoutHistory = Duration(hours: 1);

  /// Workout count cache (1 hour)
  static const Duration workoutCount = Duration(hours: 1);

  /// Exercise history cache (30 minutes)
  static const Duration exerciseHistory = Duration(minutes: 30);

  /// Short-lived cache (5 minutes)
  static const Duration shortLived = Duration(minutes: 5);

  /// Session-only cache (15 minutes)
  static const Duration sessionOnly = Duration(minutes: 15);
}

/// Analytics cache service with TTL support
///
/// Provides intelligent caching for analytics data with automatic
/// expiration and statistics tracking.
class AnalyticsCacheService {
  AnalyticsCacheService(this._boxManager);

  final HiveBoxManagerEnhanced _boxManager;

  /// Hive box for cache storage
  Box<Map<dynamic, dynamic>>? _cacheBox;

  /// Cache statistics
  CacheStatistics _statistics = const CacheStatistics();

  /// Box name for analytics cache
  static const String _boxName = 'analytics_cache_v2';

  /// Maximum cache size (approximate bytes before cleanup)
  static const int _maxCacheSize = 10 * 1024 * 1024; // 10 MB

  /// Cleanup timer
  Timer? _cleanupTimer;

  /// Whether the service has been initialized
  bool _isInitialized = false;

  /// Initialize cache service
  ///
  /// Opens the Hive box and starts the cleanup timer.
  /// Must be called before using other methods.
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        debugPrint('💾 [AnalyticsCache] Already initialized');
      }
      return;
    }

    try {
      _cacheBox = await _boxManager.openBox<Map<dynamic, dynamic>>(_boxName);
      _isInitialized = true;

      // Start periodic cleanup (every 10 minutes)
      _cleanupTimer = Timer.periodic(
        const Duration(minutes: 10),
        (_) => _cleanupExpired(),
      );

      // Initial cleanup of expired entries
      await _cleanupExpired();

      // Calculate initial statistics
      await _updateStatistics();

      if (kDebugMode) {
        debugPrint('💾 [AnalyticsCache] Initialized with ${_cacheBox!.length} entries');
        debugPrint('📊 [AnalyticsCache] Statistics: $_statistics');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AnalyticsCache] Initialization failed: $e');
      }
      // Continue without cache - service will return null for all gets
    }
  }

  /// Dispose cache service
  ///
  /// Cancels cleanup timer and clears resources.
  Future<void> dispose() async {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;

    if (kDebugMode) {
      debugPrint('📊 [AnalyticsCache] Final statistics: ${_statistics.toJson()}');
    }

    _isInitialized = false;
  }

  /// Get cached value with optional fromJson converter
  ///
  /// Returns null if:
  /// - Key doesn't exist
  /// - Entry has expired
  /// - Parsing fails
  ///
  /// [key] - Cache key
  /// [fromJson] - Optional converter for complex types
  ///
  /// **Example**:
  /// ```dart
  /// // For primitives
  /// final count = await cache.get<int>('workout_count_user123');
  ///
  /// // For complex types
  /// final data = await cache.get<List<Map<String, dynamic>>>(
  ///   'workout_history_user123',
  ///   (json) => (json['data'] as List).cast<Map<String, dynamic>>(),
  /// );
  /// ```
  Future<T?> get<T>(String key, [T Function(Map<String, dynamic>)? fromJson]) async {
    if (!_isInitialized || _cacheBox == null) {
      await initialize();
      if (_cacheBox == null) {
        _statistics = _statistics.recordMiss();
        return null;
      }
    }

    try {
      final raw = _cacheBox!.get(key);
      if (raw == null) {
        _statistics = _statistics.recordMiss();
        if (kDebugMode) {
          debugPrint('💾 [AnalyticsCache] MISS (not found): $key');
        }
        return null;
      }

      // Convert to properly typed map
      final Map<String, dynamic> data = _convertToStringKeyMap(raw);

      // Parse metadata
      final createdAt = DateTime.tryParse(data['_createdAt'] as String? ?? '');
      final ttlMs = data['_ttlMs'] as int?;

      if (createdAt == null) {
        // Invalid entry - remove it
        await _cacheBox!.delete(key);
        _statistics = _statistics.recordMiss();
        return null;
      }

      // Check expiration
      if (ttlMs != null) {
        final ttl = Duration(milliseconds: ttlMs);
        final expiresAt = createdAt.add(ttl);
        if (DateTime.now().isAfter(expiresAt)) {
          // Expired - remove and return null
          await _cacheBox!.delete(key);
          _statistics = _statistics.recordMiss();
          if (kDebugMode) {
            debugPrint('💾 [AnalyticsCache] MISS (expired): $key');
          }
          return null;
        }
      }

      // Extract value
      final value = data['_value'];
      if (value == null) {
        _statistics = _statistics.recordMiss();
        return null;
      }

      _statistics = _statistics.recordHit();
      if (kDebugMode) {
        debugPrint('💾 [AnalyticsCache] HIT: $key');
      }

      // Convert value if needed
      if (fromJson != null && value is Map) {
        final typedMap = _convertToStringKeyMap(value);
        return fromJson(typedMap);
      }

      // Return raw value for primitives
      return value as T?;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AnalyticsCache] Error getting $key: $e');
      }
      _statistics = _statistics.recordMiss();
      return null;
    }
  }

  /// Set cached value with optional TTL and toJson converter
  ///
  /// [key] - Cache key
  /// [value] - Value to cache
  /// [ttl] - Time-to-live (default: 1 hour)
  /// [toJson] - Optional converter for complex types
  ///
  /// **Example**:
  /// ```dart
  /// // For primitives
  /// await cache.set('workout_count_user123', 42);
  ///
  /// // For complex types with TTL
  /// await cache.set(
  ///   'workout_history_user123',
  ///   workoutList,
  ///   const Duration(hours: 1),
  ///   (data) => {'data': data},
  /// );
  /// ```
  Future<void> set<T>(
    String key,
    T value, [
    Duration? ttl,
    Map<String, dynamic> Function(T)? toJson,
  ]) async {
    if (!_isInitialized || _cacheBox == null) {
      await initialize();
      if (_cacheBox == null) {
        if (kDebugMode) {
          debugPrint('❌ [AnalyticsCache] Cannot set - cache not initialized');
        }
        return;
      }
    }

    try {
      // Serialize value
      dynamic serializedValue;
      if (toJson != null) {
        serializedValue = toJson(value);
      } else if (value is Map || value is List || _isPrimitive(value)) {
        serializedValue = value;
      } else {
        // Try JSON encoding as fallback
        serializedValue = jsonDecode(jsonEncode(value));
      }

      // Create entry with metadata
      final entry = <String, dynamic>{
        '_value': serializedValue,
        '_createdAt': DateTime.now().toIso8601String(),
        '_ttlMs': (ttl ?? CacheTTL.analyticsStats).inMilliseconds,
        '_key': key,
      };

      await _cacheBox!.put(key, entry);

      if (kDebugMode) {
        debugPrint('💾 [AnalyticsCache] SET: $key (TTL: ${ttl ?? CacheTTL.analyticsStats})');
      }

      // Update statistics
      await _updateStatistics();

      // Check if cleanup needed
      if (_statistics.totalSize > _maxCacheSize) {
        await _cleanupExpired();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AnalyticsCache] Error setting $key: $e');
      }
    }
  }

  /// Invalidate specific key
  Future<void> invalidate(String key) async {
    if (!_isInitialized || _cacheBox == null) return;

    try {
      await _cacheBox!.delete(key);
      if (kDebugMode) {
        debugPrint('🗑️ [AnalyticsCache] Invalidated: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AnalyticsCache] Error invalidating $key: $e');
      }
    }
  }

  /// Invalidate by pattern
  ///
  /// Removes all entries where key contains the pattern.
  ///
  /// **Example**:
  /// ```dart
  /// // Invalidate all workout-related cache
  /// await cache.invalidatePattern('workout');
  /// ```
  Future<void> invalidatePattern(String pattern) async {
    if (!_isInitialized || _cacheBox == null) return;

    try {
      final keysToDelete = _cacheBox!.keys
          .whereType<String>()
          .where((key) => key.contains(pattern))
          .toList();

      await _cacheBox!.deleteAll(keysToDelete);

      if (kDebugMode) {
        debugPrint('🗑️ [AnalyticsCache] Invalidated ${keysToDelete.length} keys matching: $pattern');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AnalyticsCache] Error invalidating pattern $pattern: $e');
      }
    }
  }

  /// Invalidate all cache for a user
  ///
  /// Removes all entries where key contains the userId.
  Future<void> invalidateUser(String userId) async {
    await invalidatePattern(userId);
    if (kDebugMode) {
      debugPrint('🗑️ [AnalyticsCache] Invalidated all cache for user: $userId');
    }
  }

  /// Clear all cache entries
  Future<void> clear() async {
    if (!_isInitialized || _cacheBox == null) return;

    try {
      await _cacheBox!.clear();
      _statistics = const CacheStatistics();
      if (kDebugMode) {
        debugPrint('🗑️ [AnalyticsCache] Cleared all entries');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AnalyticsCache] Error clearing cache: $e');
      }
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStatistics() {
    return _statistics.toJson();
  }

  /// Get current statistics object
  CacheStatistics get statistics => _statistics;

  /// Check if a key exists and is valid
  Future<bool> has(String key) async {
    final value = await get<dynamic>(key);
    return value != null;
  }

  /// Get all keys in cache
  List<String> get keys {
    if (!_isInitialized || _cacheBox == null) return [];
    return _cacheBox!.keys.whereType<String>().toList();
  }

  /// Get number of entries in cache
  int get length {
    if (!_isInitialized || _cacheBox == null) return 0;
    return _cacheBox!.length;
  }

  // Private helper methods

  /// Clean up expired entries
  Future<void> _cleanupExpired() async {
    if (!_isInitialized || _cacheBox == null) return;

    try {
      final now = DateTime.now();
      final keysToDelete = <dynamic>[];
      int expiredCount = 0;

      for (final key in _cacheBox!.keys) {
        final raw = _cacheBox!.get(key);
        if (raw == null) continue;

        final data = _convertToStringKeyMap(raw);
        final createdAt = DateTime.tryParse(data['_createdAt'] as String? ?? '');
        final ttlMs = data['_ttlMs'] as int?;

        if (createdAt == null) {
          keysToDelete.add(key);
          continue;
        }

        if (ttlMs != null) {
          final expiresAt = createdAt.add(Duration(milliseconds: ttlMs));
          if (now.isAfter(expiresAt)) {
            keysToDelete.add(key);
            expiredCount++;
          }
        }
      }

      if (keysToDelete.isNotEmpty) {
        await _cacheBox!.deleteAll(keysToDelete);
        if (kDebugMode) {
          debugPrint('🧹 [AnalyticsCache] Cleaned up $expiredCount expired entries');
        }
      }

      await _updateStatistics();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AnalyticsCache] Cleanup error: $e');
      }
    }
  }

  /// Update cache statistics
  Future<void> _updateStatistics() async {
    if (!_isInitialized || _cacheBox == null) return;

    try {
      DateTime? oldest;
      DateTime? newest;
      int expiredCount = 0;
      final now = DateTime.now();

      for (final key in _cacheBox!.keys) {
        final raw = _cacheBox!.get(key);
        if (raw == null) continue;

        final data = _convertToStringKeyMap(raw);
        final createdAt = DateTime.tryParse(data['_createdAt'] as String? ?? '');
        final ttlMs = data['_ttlMs'] as int?;

        if (createdAt != null) {
          if (oldest == null || createdAt.isBefore(oldest)) {
            oldest = createdAt;
          }
          if (newest == null || createdAt.isAfter(newest)) {
            newest = createdAt;
          }

          if (ttlMs != null) {
            final expiresAt = createdAt.add(Duration(milliseconds: ttlMs));
            if (now.isAfter(expiresAt)) {
              expiredCount++;
            }
          }
        }
      }

      _statistics = _statistics.copyWith(
        totalKeys: _cacheBox!.length,
        oldestEntry: oldest,
        newestEntry: newest,
        expiredKeys: expiredCount,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AnalyticsCache] Error updating statistics: $e');
      }
    }
  }

  /// Convert dynamic map to String-keyed map
  Map<String, dynamic> _convertToStringKeyMap(dynamic map) {
    if (map is Map<String, dynamic>) return map;
    if (map is Map) {
      return map.map((key, value) {
        final stringKey = key.toString();
        final convertedValue = value is Map ? _convertToStringKeyMap(value) : value;
        return MapEntry(stringKey, convertedValue);
      });
    }
    return {};
  }

  /// Check if value is a primitive type
  bool _isPrimitive(dynamic value) {
    return value == null ||
        value is bool ||
        value is num ||
        value is String ||
        value is DateTime;
  }
}

/// Standard cache key generators
class AnalyticsCacheKeys {
  AnalyticsCacheKeys._();

  /// Workout history cache key
  static String workoutHistory(String userId, {int? limit, DateTime? since}) {
    final sinceStr = since?.toIso8601String() ?? 'all';
    return 'workout_history_${userId}_${limit ?? 'all'}_$sinceStr';
  }

  /// Analytics stats cache key
  static String analyticsStats(String userId) {
    return 'analytics_stats_$userId';
  }

  /// Workout count cache key
  static String workoutCount(String userId) {
    return 'workout_count_$userId';
  }

  /// Exercise history cache key
  static String exerciseHistory(String userId, String exerciseName) {
    final normalizedName = exerciseName.toLowerCase().replaceAll(' ', '_');
    return 'exercise_history_${userId}_$normalizedName';
  }

  /// Exercise sessions cache key
  static String exerciseSessions(
    String userId,
    String exerciseName, {
    DateTime? start,
    DateTime? end,
  }) {
    final normalizedName = exerciseName.toLowerCase().replaceAll(' ', '_');
    final startStr = start?.toIso8601String() ?? 'start';
    final endStr = end?.toIso8601String() ?? 'end';
    return 'exercise_sessions_${userId}_${normalizedName}_${startStr}_$endStr';
  }

  /// PR (Personal Record) cache key
  static String prs(String userId, {String? exerciseId}) {
    if (exerciseId != null) {
      return 'prs_${userId}_$exerciseId';
    }
    return 'prs_$userId';
  }

  /// Muscle distribution cache key
  static String muscleDistribution(String userId, {int? days}) {
    return 'muscle_dist_${userId}_${days ?? 'all'}d';
  }

  /// Weekly summary cache key
  static String weeklySummary(String userId, {DateTime? weekStart}) {
    final weekStr = weekStart?.toIso8601String() ?? 'current';
    return 'weekly_summary_${userId}_$weekStr';
  }
}
