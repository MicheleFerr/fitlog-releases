/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: data/datasources
/// 🎯 Feature: workout
/// 🔧 Type: cache datasource
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// ✅ PATTERN B: Exercise-level caching with 3-tier strategy
/// - Tier 1: Hive cache with 24h TTL (fast, <10ms)
/// - Tier 2: Firestore query (slow, 500ms-3s)
/// - Tier 3: Graceful fallback (null if all fail)
///
/// Performance Target: 90%+ cache hit rate (better than template-level 85%)
/// Cost Savings: 80%+ reduction in Firestore reads
library;

import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';

/// Lightweight model for cached exercise data
///
/// Stores only essential fields to minimize cache size:
/// - exerciseDbId: Stable ID from database
/// - weight: Average weight from last session
/// - reps: Average reps from last session
/// - lastPerformedDate: Timestamp of last workout
/// - matchType: How exercise was matched ('id' | 'name')
class CachedExerciseData {
  const CachedExerciseData({
    required this.exerciseDbId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.lastPerformedDate,
    required this.matchType,
  });

  factory CachedExerciseData.fromJson(Map<String, dynamic> json) {
    return CachedExerciseData(
      exerciseDbId: json['exerciseDbId'] as String?,
      exerciseName: json['exerciseName'] as String,
      weight: (json['weight'] as num).toDouble(),
      reps: json['reps'] as int,
      lastPerformedDate: DateTime.parse(json['lastPerformedDate'] as String),
      matchType: json['matchType'] as String,
    );
  }

  final String? exerciseDbId; // Nullable for backwards compatibility
  final String exerciseName;
  final double weight;
  final int reps;
  final DateTime lastPerformedDate;
  final String matchType; // 'id' | 'name'

  Map<String, dynamic> toJson() {
    return {
      'exerciseDbId': exerciseDbId,
      'exerciseName': exerciseName,
      'weight': weight,
      'reps': reps,
      'lastPerformedDate': lastPerformedDate.toIso8601String(),
      'matchType': matchType,
    };
  }
}

/// Cache data source for exercise-level previous data
///
/// Implements Tier 1 of 3-tier caching strategy:
/// 1. **Hive cache (24h TTL)** ← This class
/// 2. Firestore query with timeout
/// 3. Graceful fallback
///
/// Performance Target: 90%+ cache hit rate
/// Cost Savings: 80%+ reduction in Firestore reads
///
/// Cache key strategy:
/// - Primary: exerciseDbId (e.g., "3_4_sit_up")
/// - Fallback: exerciseName hash (for backwards compatibility)
class ExerciseCacheDataSource {
  /// Constructor with dependency injection
  ///
  /// Usage:
  /// ```dart
  /// final cacheSource = ExerciseCacheDataSource(
  ///   ref.watch(hiveBoxManagerProvider)
  /// );
  /// ```
  ExerciseCacheDataSource(this._boxManager);

  final HiveBoxManagerEnhanced _boxManager;

  /// 24-hour cache TTL (Time To Live)
  static const Duration _cacheTtl = Duration(hours: 24);

  /// Get cache box via HiveBoxManagerEnhanced
  /// Using Box<dynamic> to store both Map (exercise data) and int (timestamp)
  Future<Box<dynamic>> _getCacheBox() async {
    return await _boxManager.openBox<dynamic>(
      HiveBoxNames.workoutPreviousDataCache,
    );
  }

  /// Generate cache key for an exercise
  ///
  /// Strategy:
  /// - If exerciseDbId available: "exercise_{dbId}" (e.g., "exercise_3_4_sit_up")
  /// - If only name: "exercise_name_{hash}" (backwards compatibility)
  String _cacheKey({String? exerciseDbId, String? exerciseName}) {
    if (exerciseDbId != null && exerciseDbId.isNotEmpty) {
      return 'exercise_$exerciseDbId';
    } else if (exerciseName != null && exerciseName.isNotEmpty) {
      // Fallback: use name hash (less reliable but works for old data)
      final nameHash = exerciseName.toLowerCase().hashCode.abs();
      return 'exercise_name_$nameHash';
    } else {
      throw ArgumentError('Either exerciseDbId or exerciseName must be provided');
    }
  }

  /// Generate timestamp key for cache validation
  String _timestampKey({String? exerciseDbId, String? exerciseName}) {
    final key = _cacheKey(exerciseDbId: exerciseDbId, exerciseName: exerciseName);
    return '${key}_timestamp';
  }

  /// Check if cached data is still valid (within 24h TTL)
  ///
  /// Returns:
  /// - `true` if cache exists and is fresh (<24h old)
  /// - `false` if cache doesn't exist or is stale (>24h old)
  ///
  /// Example:
  /// ```dart
  /// final isValid = await cacheSource.isCacheValid(exerciseDbId: '3_4_sit_up');
  /// if (isValid) {
  ///   // Use cached data
  /// } else {
  ///   // Fetch from Firestore
  /// }
  /// ```
  Future<bool> isCacheValid({String? exerciseDbId, String? exerciseName}) async {
    try {
      final box = await _getCacheBox();
      final timestamp = box.get(_timestampKey(
        exerciseDbId: exerciseDbId,
        exerciseName: exerciseName,
      )) as int?;

      if (timestamp == null) {
        if (kDebugMode) {
          debugPrint('💾 [ExerciseCache] Cache MISS - No timestamp for exercise: ${exerciseDbId ?? exerciseName}');
        }
        return false;
      }

      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAge = _cacheTtl.inMilliseconds;
      final isValid = cacheAge < maxAge;

      if (kDebugMode) {
        if (isValid) {
          final hoursOld = (cacheAge / (1000 * 60 * 60)).toStringAsFixed(1);
          debugPrint('✅ [ExerciseCache] Cache HIT - Exercise ${exerciseDbId ?? exerciseName} ($hoursOld hours old)');
        } else {
          debugPrint('⏰ [ExerciseCache] Cache STALE - Exercise ${exerciseDbId ?? exerciseName} (>24h old)');
        }
      }

      return isValid;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ExerciseCache] Cache validity check failed: $e');
      }
      return false;
    }
  }

  /// Get cached exercise data (if valid)
  ///
  /// Returns:
  /// - `CachedExerciseData` if cache exists and is valid
  /// - `null` if cache doesn't exist, is stale, or Hive corrupted
  ///
  /// Handles Hive corruption gracefully with try-catch fallback
  ///
  /// Example:
  /// ```dart
  /// final cachedData = await cacheSource.getCachedExercise(exerciseDbId: '3_4_sit_up');
  /// if (cachedData != null) {
  ///   // Use cached data (Firestore read saved!)
  /// } else {
  ///   // Query Firestore
  /// }
  /// ```
  Future<CachedExerciseData?> getCachedExercise({
    String? exerciseDbId,
    String? exerciseName,
  }) async {
    try {
      final box = await _getCacheBox();
      final json = box.get(_cacheKey(
        exerciseDbId: exerciseDbId,
        exerciseName: exerciseName,
      ));

      if (json == null) {
        if (kDebugMode) {
          debugPrint('💾 [ExerciseCache] No cached data for exercise: ${exerciseDbId ?? exerciseName}');
        }
        return null;
      }

      // Convert Map<dynamic, dynamic> to Map<String, dynamic> if needed
      final Map<String, dynamic> dataJson = Map<String, dynamic>.from(json as Map);

      final cachedData = CachedExerciseData.fromJson(dataJson);

      if (kDebugMode) {
        debugPrint('✅ [ExerciseCache] Retrieved cached data: ${cachedData.weight}kg × ${cachedData.reps} reps (${cachedData.matchType} match)');
      }

      return cachedData;
    } catch (e, stackTrace) {
      // ✅ Hive corruption handling: graceful fallback to Firestore
      if (kDebugMode) {
        debugPrint('⚠️ [ExerciseCache] Hive cache corrupted - falling back to Firestore: $e');
        debugPrint('Stack trace: $stackTrace');
      }

      return null; // Fallback to Firestore query
    }
  }

  /// Cache exercise data for future use
  ///
  /// Saves both:
  /// - Exercise data (weight, reps, date, match type)
  /// - Current timestamp for TTL validation
  ///
  /// Example:
  /// ```dart
  /// final data = CachedExerciseData(
  ///   exerciseDbId: '3_4_sit_up',
  ///   exerciseName: 'Sit Up',
  ///   weight: 70.0,
  ///   reps: 12,
  ///   lastPerformedDate: DateTime.now(),
  ///   matchType: 'id',
  /// );
  /// await cacheSource.cacheExercise(data);
  /// ```
  Future<void> cacheExercise(CachedExerciseData data) async {
    try {
      final box = await _getCacheBox();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Convert data to JSON
      final Map<String, dynamic> dataJson = data.toJson();

      // Save exercise data + timestamp atomically
      final key = _cacheKey(
        exerciseDbId: data.exerciseDbId,
        exerciseName: data.exerciseName,
      );
      final timestampKey = _timestampKey(
        exerciseDbId: data.exerciseDbId,
        exerciseName: data.exerciseName,
      );

      await box.put(key, dataJson);
      await box.put(timestampKey, now);

      if (kDebugMode) {
        debugPrint('💾 [ExerciseCache] Cached exercise: ${data.exerciseName} (${data.exerciseDbId})');
        debugPrint('💾 [ExerciseCache] Cache size: ${box.keys.length} entries');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ExerciseCache] Failed to cache exercise: $e');
      }
      // Don't throw - caching is non-critical
    }
  }

  /// Invalidate (delete) cached exercise data
  ///
  /// Use when:
  /// - Exercise is completed in a new workout
  /// - Exercise database is updated
  /// - User manually refreshes data
  ///
  /// Example:
  /// ```dart
  /// await cacheSource.invalidateCache(exerciseDbId: '3_4_sit_up');
  /// ```
  Future<void> invalidateCache({String? exerciseDbId, String? exerciseName}) async {
    try {
      final box = await _getCacheBox();

      // Delete both exercise data and timestamp
      final key = _cacheKey(exerciseDbId: exerciseDbId, exerciseName: exerciseName);
      final timestampKey = _timestampKey(exerciseDbId: exerciseDbId, exerciseName: exerciseName);

      await box.delete(key);
      await box.delete(timestampKey);

      if (kDebugMode) {
        debugPrint('🗑️ [ExerciseCache] Invalidated cache for exercise: ${exerciseDbId ?? exerciseName}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ExerciseCache] Failed to invalidate cache: $e');
      }
    }
  }

  /// Clear all cached exercise data (useful for testing or manual refresh)
  ///
  /// Example:
  /// ```dart
  /// await cacheSource.clearAllCache();
  /// ```
  Future<void> clearAllCache() async {
    try {
      final box = await _getCacheBox();
      await box.clear();

      if (kDebugMode) {
        debugPrint('🗑️ [ExerciseCache] Cleared ALL cached exercises');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ExerciseCache] Failed to clear cache: $e');
      }
    }
  }

  /// Get cache statistics (for analytics and debugging)
  ///
  /// Returns map with:
  /// - `totalEntries`: Total cached exercises
  /// - `validEntries`: Exercises with valid (<24h) cache
  /// - `staleEntries`: Exercises with stale (>24h) cache
  /// - `cacheHitRate`: Percentage of valid cache entries
  ///
  /// Example:
  /// ```dart
  /// final stats = await cacheSource.getCacheStats();
  /// print('Cache hit rate: ${stats['cacheHitRate']}%');
  /// ```
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final box = await _getCacheBox();
      final allKeys = box.keys.toList();

      // Filter exercise timestamp keys only
      final timestampKeys = allKeys
          .where((key) => key.toString().contains('exercise_') && key.toString().endsWith('_timestamp'))
          .toList();

      int validEntries = 0;
      int staleEntries = 0;

      for (final key in timestampKeys) {
        final timestamp = box.get(key) as int?;
        if (timestamp == null) continue;

        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (cacheAge < _cacheTtl.inMilliseconds) {
          validEntries++;
        } else {
          staleEntries++;
        }
      }

      final totalEntries = timestampKeys.length;
      final cacheHitRate = totalEntries > 0
          ? (validEntries / totalEntries * 100).toStringAsFixed(1)
          : '0.0';

      final stats = {
        'totalEntries': totalEntries,
        'validEntries': validEntries,
        'staleEntries': staleEntries,
        'cacheHitRate': cacheHitRate,
      };

      if (kDebugMode) {
        debugPrint('📊 [ExerciseCache] Stats: $stats');
      }

      return stats;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ExerciseCache] Failed to get cache stats: $e');
      }
      return {
        'totalEntries': 0,
        'validEntries': 0,
        'staleEntries': 0,
        'cacheHitRate': '0.0',
        'error': e.toString(),
      };
    }
  }
}
