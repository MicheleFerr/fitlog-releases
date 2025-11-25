import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart' as fpdart show Either, Right, Left;
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/achievement.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/achievement_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Achievement repository implementation with Firestore + Hive caching
///
/// Uses cache-first strategy with 1h TTL for performance and offline support.
/// Follows HybridAnalyticsService pattern for dual storage.
class AchievementRepositoryImpl implements AchievementRepository {
  AchievementRepositoryImpl({
    FirebaseFirestore? firestore,
    required this.cacheBoxName,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String cacheBoxName;

  static const _cacheExpiryDuration = Duration(hours: 1);

  /// Get Hive cache box (lazy initialization)
  Future<Box<Map<dynamic, dynamic>>> _getCacheBox() async {
    if (!Hive.isBoxOpen(cacheBoxName)) {
      return await Hive.openBox<Map<dynamic, dynamic>>(cacheBoxName);
    }
    return Hive.box<Map<dynamic, dynamic>>(cacheBoxName);
  }

  @override
  Future<fpdart.Either<Failure, Achievement>> unlockAchievement(
    String userId,
    BadgeType badgeType, {
    Map<String, dynamic>? evidence,
  }) async {
    try {
      // Check if already unlocked
      final isUnlockedResult = await isAchievementUnlocked(userId, badgeType);
      final isUnlocked = isUnlockedResult.fold(
        (l) => false,
        (r) => r,
      );

      if (isUnlocked) {
        return fpdart.Left(
          ValidationFailure('Achievement ${badgeType.name} already unlocked'),
        );
      }

      // Create achievement
      final achievement = Achievement(
        id: '${userId}_${badgeType.name}_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        badgeType: badgeType,
        unlockedAt: DateTime.now(),
        evidence: evidence ?? {},
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(badgeType.name)
          .set(achievement.toJson());

      // Update cache
      await _updateCache(userId, [achievement], append: true);

      return fpdart.Right(achievement);
    } on FirebaseException catch (e) {
      return fpdart.Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return fpdart.Left(UnexpectedFailure('Failed to unlock achievement: $e'));
    }
  }

  @override
  Future<fpdart.Either<Failure, List<Achievement>>> getUnlockedAchievements(
    String userId,
  ) async {
    try {
      // Try cache first
      final cached = await _getCachedAchievements(userId);
      if (cached != null && !_isCacheExpired(cached.timestamp)) {
        return fpdart.Right(cached.achievements);
      }

      // Fetch from Firestore
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .get();

      final achievements = snapshot.docs
          .map((doc) => Achievement.fromJson(doc.data()))
          .toList();

      // Update cache
      await _updateCache(userId, achievements);

      return fpdart.Right(achievements);
    } on FirebaseException catch (e) {
      // Return cached data if available (offline support)
      final cached = await _getCachedAchievements(userId);
      if (cached != null) {
        return fpdart.Right(cached.achievements);
      }
      return fpdart.Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return fpdart.Left(
        UnexpectedFailure('Failed to fetch achievements: $e'),
      );
    }
  }

  @override
  Future<fpdart.Either<Failure, List<BadgeType>>> checkNewAchievements(
    String userId,
    WorkoutMetrics metrics,
  ) async {
    // This method delegates to CheckAndUnlockAchievementsUseCase
    // Repository doesn't contain business logic for badge evaluation
    return const fpdart.Right([]);
  }

  @override
  Future<fpdart.Either<Failure, bool>> isAchievementUnlocked(
    String userId,
    BadgeType badgeType,
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(badgeType.name)
          .get();

      return fpdart.Right(doc.exists);
    } on FirebaseException catch (e) {
      return fpdart.Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return fpdart.Left(UnexpectedFailure('Failed to check achievement: $e'));
    }
  }

  @override
  Future<fpdart.Either<Failure, List<Achievement>>> getRecentAchievements(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .orderBy('unlockedAt', descending: true)
          .limit(limit)
          .get();

      final achievements = snapshot.docs
          .map((doc) => Achievement.fromJson(doc.data()))
          .toList();

      return fpdart.Right(achievements);
    } on FirebaseException catch (e) {
      return fpdart.Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return fpdart.Left(
        UnexpectedFailure('Failed to fetch recent achievements: $e'),
      );
    }
  }

  /// Get cached achievements
  Future<_CachedAchievements?> _getCachedAchievements(String userId) async {
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

      return _CachedAchievements(
        achievements: achievements,
        timestamp: DateTime.parse(data['timestamp'] as String),
      );
    } catch (e) {
      return null; // Cache miss or error
    }
  }

  /// Update cache with achievements
  Future<void> _updateCache(
    String userId,
    List<Achievement> achievements, {
    bool append = false,
  }) async {
    try {
      final box = await _getCacheBox();
      final cacheKey = 'achievements:$userId:unlocked';

      List<Achievement> finalAchievements = achievements;

      if (append) {
        final existing = await _getCachedAchievements(userId);
        if (existing != null) {
          finalAchievements = [...existing.achievements, ...achievements];
        }
      }

      await box.put(cacheKey, {
        'achievements': finalAchievements.map((a) => a.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Ignore cache errors (non-critical)
    }
  }

  /// Check if cache is expired (1h TTL)
  bool _isCacheExpired(DateTime timestamp) {
    return DateTime.now().difference(timestamp) > _cacheExpiryDuration;
  }
}

/// Internal class for cached achievements with timestamp
class _CachedAchievements {
  _CachedAchievements({
    required this.achievements,
    required this.timestamp,
  });

  final List<Achievement> achievements;
  final DateTime timestamp;
}
