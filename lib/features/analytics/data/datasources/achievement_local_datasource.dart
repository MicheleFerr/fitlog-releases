import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/achievement.dart';

/// Local datasource for achievement caching
///
/// Handles Hive storage for achievement data with:
/// - 1-hour TTL caching strategy
/// - Offline support
/// - Fast local queries
///
/// Cache structure:
/// - Key: 'achievements:{userId}:unlocked'
/// - Value: {
///     'achievements': List<Map<String, dynamic>>,
///     'timestamp': ISO8601 string
///   }
class AchievementLocalDatasource {
  AchievementLocalDatasource({
    required this.cacheBoxName,
  });

  final String cacheBoxName;
  static const _cacheExpiryDuration = Duration(hours: 1);

  /// Get Hive cache box (lazy initialization)
  Future<Box<Map<dynamic, dynamic>>> _getCacheBox() async {
    if (!Hive.isBoxOpen(cacheBoxName)) {
      return await Hive.openBox<Map<dynamic, dynamic>>(cacheBoxName);
    }
    return Hive.box<Map<dynamic, dynamic>>(cacheBoxName);
  }

  /// Get cached achievements for a user
  ///
  /// Returns null if cache miss or expired.
  /// Returns CachedAchievements with data + timestamp if valid cache.
  Future<CachedAchievements?> getCachedAchievements(String userId) async {
    try {
      final box = await _getCacheBox();
      final cacheKey = 'achievements:$userId:unlocked';
      final data = box.get(cacheKey);

      if (data == null) return null;

      final achievementsJson = List<Map<String, dynamic>>.from(
        data['achievements'] as List,
      );
      final achievements = achievementsJson
          .map((json) => Achievement.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      final timestamp = DateTime.parse(data['timestamp'] as String);

      // Check if cache expired
      if (_isCacheExpired(timestamp)) {
        return null;
      }

      return CachedAchievements(
        achievements: achievements,
        timestamp: timestamp,
      );
    } catch (e) {
      // Cache read error, treat as cache miss
      return null;
    }
  }

  /// Save achievements to cache
  ///
  /// Stores achievements list with current timestamp for TTL tracking.
  /// Optionally appends to existing cache or replaces entirely.
  Future<void> cacheAchievements(
    String userId,
    List<Achievement> achievements, {
    bool append = false,
  }) async {
    try {
      final box = await _getCacheBox();
      final cacheKey = 'achievements:$userId:unlocked';

      List<Achievement> finalAchievements = achievements;

      if (append) {
        final existing = await getCachedAchievements(userId);
        if (existing != null) {
          // Merge existing + new, remove duplicates by ID
          final existingIds = existing.achievements.map((a) => a.id).toSet();
          final newAchievements = achievements
              .where((a) => !existingIds.contains(a.id))
              .toList();
          finalAchievements = [...existing.achievements, ...newAchievements];
        }
      }

      await box.put(cacheKey, {
        'achievements': finalAchievements.map((a) => a.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Cache write error, non-critical - continue without throwing
    }
  }

  /// Clear cached achievements for a user
  Future<void> clearCache(String userId) async {
    try {
      final box = await _getCacheBox();
      final cacheKey = 'achievements:$userId:unlocked';
      await box.delete(cacheKey);
    } catch (e) {
      // Ignore cache clear errors
    }
  }

  /// Clear all cached achievements (all users)
  Future<void> clearAllCaches() async {
    try {
      final box = await _getCacheBox();
      await box.clear();
    } catch (e) {
      // Ignore cache clear errors
    }
  }

  /// Check if a specific achievement is cached
  Future<bool> isCached(String userId, String achievementId) async {
    final cached = await getCachedAchievements(userId);
    if (cached == null) return false;

    return cached.achievements.any((a) => a.id == achievementId);
  }

  /// Check if cache is expired (1h TTL)
  bool _isCacheExpired(DateTime timestamp) {
    return DateTime.now().difference(timestamp) > _cacheExpiryDuration;
  }
}

/// Cached achievements with timestamp for TTL tracking
class CachedAchievements {
  CachedAchievements({
    required this.achievements,
    required this.timestamp,
  });

  final List<Achievement> achievements;
  final DateTime timestamp;

  /// Check if this cache is expired
  bool get isExpired =>
      DateTime.now().difference(timestamp) > const Duration(hours: 1);

  /// Age of this cache in minutes
  int get ageInMinutes => DateTime.now().difference(timestamp).inMinutes;
}
