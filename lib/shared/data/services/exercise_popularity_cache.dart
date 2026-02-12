import 'package:hive_ce/hive.dart';
import 'package:gymbro_flutter_new/shared/data/models/exercise_popularity_hive_model.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise_popularity_data.dart';
import 'package:synchronized/synchronized.dart';

/// Local cache for exercise popularity data using Hive
///
/// Provides zero-latency access to popularity counts for search boost.
/// Data is synced from Firebase Data Bundle (generated daily by Cloud Functions).
///
/// Performance:
/// - Cache reads: O(1) - direct Hive box access
/// - TTL check: O(1) - in-memory timestamp comparison
/// - Batch updates: Single putAll() operation (not loop)
///
/// Thread safety: Uses Lock for initialization
///
/// @see docs/design/EXERCISE_POPULARITY_RANKING.md
class ExercisePopularityCache {
  static const String _boxName = 'exercise_popularity';
  static const Duration _cacheDuration = Duration(days: 1);

  Box<ExercisePopularityHiveModel>? _box;
  bool _initialized = false;
  final _initLock = Lock();

  /// Singleton instance (ensures single box opening)
  static ExercisePopularityCache? _instance;
  factory ExercisePopularityCache() {
    _instance ??= ExercisePopularityCache._();
    return _instance!;
  }
  ExercisePopularityCache._();

  /// Initialize Hive box
  ///
  /// Thread-safe initialization with lock.
  /// Safe to call multiple times (no-op if already initialized).
  Future<void> init() async {
    await _initLock.synchronized(() async {
      if (_initialized) return; // Already initialized

      _box = await Hive.openBox<ExercisePopularityHiveModel>(_boxName);
      _initialized = true;
    });
  }

  /// Get popularity count for exercise
  ///
  /// Returns:
  /// - Cached count if entry exists and not expired
  /// - 0 if entry missing, expired, or any error
  ///
  /// Graceful degradation: Never throws, always returns valid int.
  int getPopularity(String exerciseId) {
    try {
      final data = _box?.get(exerciseId);
      if (data == null) return 0;

      // Check cache expiration (soft TTL)
      if (DateTime.now().difference(data.lastUpdated) > _cacheDuration) {
        return 0; // Expired, return default
      }

      return data.count;
    } catch (e) {
      // Graceful degradation: return 0 on any error
      // (cache read error should not break search)
      return 0;
    }
  }

  /// Update cache with batch data from bundle
  ///
  /// Performance: Single putAll() operation, not loop.
  /// Converts domain entities to Hive models before batch write.
  ///
  /// Throws: Only if box is not initialized (caller should handle)
  Future<void> updateBatch(List<ExercisePopularityData> popularityData) async {
    if (_box == null) {
      throw StateError('Cache not initialized. Call init() first.');
    }

    // Convert to Hive models (NOT in loop - build map first)
    final entries = <String, ExercisePopularityHiveModel>{};

    for (final data in popularityData) {
      entries[data.exerciseId] = ExercisePopularityHiveModel.fromDomain(
        data.exerciseId,
        data.count,
        data.lastUpdated,
      );
    }

    // Batch write (single Hive operation)
    await _box!.putAll(entries);
  }

  /// Check if cache needs sync (based on oldest entry TTL)
  ///
  /// Returns:
  /// - true if cache is empty
  /// - true if oldest entry is >24h old
  /// - false if cache is fresh
  bool needsSync() {
    if (_box == null || _box!.isEmpty) return true;

    // Find oldest update timestamp
    final timestamps = _box!.values.map((e) => e.lastUpdated);
    if (timestamps.isEmpty) return true;

    final oldestUpdate = timestamps.reduce(
      (a, b) => a.isBefore(b) ? a : b,
    );

    return DateTime.now().difference(oldestUpdate) > _cacheDuration;
  }

  /// Get cache statistics (for debugging/monitoring)
  Map<String, dynamic> getStats() {
    if (_box == null) {
      return {
        'initialized': false,
        'entries': 0,
      };
    }

    final entries = _box!.values.toList();
    final now = DateTime.now();
    final expiredCount = entries.where((e) {
      return now.difference(e.lastUpdated) > _cacheDuration;
    }).length;

    return {
      'initialized': true,
      'entries': entries.length,
      'expired': expiredCount,
      'fresh': entries.length - expiredCount,
      'needsSync': needsSync(),
    };
  }

  /// Clear all cache (for testing/debugging)
  Future<void> clear() async {
    await _box?.clear();
  }

  /// Close box and reset instance (for testing/cleanup)
  Future<void> close() async {
    await _box?.close();
    _box = null;
    _initialized = false;
    _instance = null;
  }
}
