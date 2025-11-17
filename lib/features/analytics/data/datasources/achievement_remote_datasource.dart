import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/achievement.dart';

/// Remote datasource for achievement persistence
///
/// Handles Firestore operations for achievement data:
/// - Save new achievement unlocks
/// - Query unlocked achievements
/// - Check if achievement already unlocked
/// - Get recent achievements
///
/// Firestore structure:
/// - Collection: users/{userId}/achievements
/// - Document ID: {badgeType.name} (e.g., 'firstPR', 'oneRepMonarch')
/// - Fields: achievement.toJson()
class AchievementRemoteDatasource {
  AchievementRemoteDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Save achievement to Firestore
  ///
  /// Document ID is the badge type name for easy querying and uniqueness.
  /// Overwrites existing achievement of same type (idempotent).
  Future<void> saveAchievement(Achievement achievement) async {
    await _firestore
        .collection('users')
        .doc(achievement.userId)
        .collection('achievements')
        .doc(achievement.badgeType.name)
        .set(achievement.toJson());
  }

  /// Get all unlocked achievements for a user
  ///
  /// Returns list of Achievement entities ordered by unlock date (newest first).
  Future<List<Achievement>> getUnlockedAchievements(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .orderBy('unlockedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Achievement.fromJson(doc.data()))
        .toList();
  }

  /// Check if a specific badge type is already unlocked
  ///
  /// Returns true if document exists, false otherwise.
  /// Uses document ID check for fast query (no full document read).
  Future<bool> isAchievementUnlocked(
    String userId,
    BadgeType badgeType,
  ) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(badgeType.name)
        .get();

    return doc.exists;
  }

  /// Get recent achievements (last N unlocked)
  ///
  /// Returns list of Achievement entities ordered by unlock date.
  /// Useful for displaying achievement notifications or history.
  Future<List<Achievement>> getRecentAchievements(
    String userId, {
    int limit = 10,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .orderBy('unlockedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => Achievement.fromJson(doc.data()))
        .toList();
  }

  /// Get achievement by badge type
  ///
  /// Returns Achievement or null if not unlocked.
  Future<Achievement?> getAchievementByType(
    String userId,
    BadgeType badgeType,
  ) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(badgeType.name)
        .get();

    if (!doc.exists) return null;

    return Achievement.fromJson(doc.data()!);
  }

  /// Delete an achievement (for testing/debugging only)
  ///
  /// Not used in production flow (achievements are permanent).
  Future<void> deleteAchievement(
    String userId,
    BadgeType badgeType,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(badgeType.name)
        .delete();
  }

  /// Delete all achievements for a user (for testing/debugging only)
  Future<void> deleteAllAchievements(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Get achievement count by badge type for a user
  ///
  /// Returns map of BadgeType -> count (always 0 or 1 per type).
  /// Useful for progress tracking UI.
  Future<Map<BadgeType, int>> getAchievementCounts(String userId) async {
    final achievements = await getUnlockedAchievements(userId);

    final counts = <BadgeType, int>{};
    for (final achievement in achievements) {
      counts[achievement.badgeType] = 1;
    }

    return counts;
  }
}
