/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/data/repositories
/// 🎯 Feature: analytics
/// 🔧 Type: repository implementation
///
/// AnalyticsRepositoryImpl - Firestore + Hive cache implementation
///
/// **Strategy**: Write-through cache with Option B (separate analytics collection)
///
/// **Firestore Collections**:
/// 1. `users/{userId}/workouts` - Main workout data (unchanged)
/// 2. `users/{userId}/analytics/{exerciseName}` - Pre-computed analytics (NEW)
///
/// **Write-Through Logic**:
/// - On workout completion → Write to BOTH collections
/// - Workout data → `workouts` (via WorkoutRepository)
/// - Analytics data → `analytics` (THIS repository)
///
/// **Cache Strategy**:
/// - Hive local cache with 5-minute TTL
/// - Cache key: `analytics_{userId}_{exerciseName}`
/// - Invalidate on write operations
///
/// **Usage**:
/// ```dart
/// final repository = AnalyticsRepositoryImpl(firestore, hive);
///
/// // Read analytics (cached)
/// final result = await repository.getExerciseHistoryByName(
///   userId: 'user123',
///   exerciseName: 'Bench Press',
/// );
///
/// // Write analytics (on workout completion)
/// await repository.updateExerciseHistory(
///   userId: 'user123',
///   exerciseName: 'Bench Press',
///   session: newSession,
/// );
/// ```
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/analytics/data/models/exercise_history_model.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Analytics repository implementation with Firestore + Hive cache
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final FirebaseFirestore _firestore;
  final Box<Map<dynamic, dynamic>> _cacheBox;

  /// Cache TTL: 5 minutes
  static const _cacheTTL = Duration(minutes: 5);

  AnalyticsRepositoryImpl({
    required FirebaseFirestore firestore,
    required Box<Map<dynamic, dynamic>> cacheBox,
  })  : _firestore = firestore,
        _cacheBox = cacheBox;

  /// Get all exercise history for a user with real-time sync
  ///
  /// **Firestore Query**: `users/{userId}/analytics` (all documents)
  ///
  /// **Returns**: Stream of all exercise histories (real-time updates)
  ///
  /// **Example**:
  /// ```dart
  /// repository.getExerciseHistory('user123').listen((result) {
  ///   result.fold(
  ///     (failure) => print('Error: $failure'),
  ///     (histories) => print('Loaded ${histories.length} exercises'),
  ///   );
  /// });
  /// ```
  @override
  Stream<Either<Failure, List<ExerciseHistory>>> getExerciseHistory(
    String userId,
  ) {
    try {
      print('📊 [ANALYTICS] Subscribing to analytics stream for user: $userId');

      return _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .snapshots()
          .map((snapshot) {
        try {
          print('📊 [ANALYTICS] Received snapshot: ${snapshot.docs.length} documents');

          if (snapshot.docs.isEmpty) {
            print('⚠️ [ANALYTICS] Empty analytics collection! Run migration to populate.');
          } else {
            print('📊 [ANALYTICS] Exercises found: ${snapshot.docs.map((d) => d.id).join(", ")}');
          }

          final histories = snapshot.docs
              .map((doc) => ExerciseHistoryModel.fromFirestore(doc).toDomain())
              .toList();

          // Sort by exercise name alphabetically
          histories.sort((a, b) => a.exerciseName.compareTo(b.exerciseName));

          print('✅ [ANALYTICS] Returning ${histories.length} exercise histories');

          return Right(histories);
        } catch (e) {
          print('❌ [ANALYTICS] Parse error: $e');
          return Left(CacheFailure( 'Failed to parse analytics: $e'));
        }
      });
    } catch (e) {
      print('❌ [ANALYTICS] Stream error: $e');
      return Stream.value(
        Left(ServerFailure( 'Failed to fetch analytics: $e')),
      );
    }
  }

  /// Get sessions for a specific exercise within a timeframe
  ///
  /// **Firestore Query**: Read single document + filter sessions by date
  ///
  /// **Logic**:
  /// 1. Read `users/{userId}/analytics/{exerciseName}`
  /// 2. Filter sessions where date is between start and end
  ///
  /// **Example**:
  /// ```dart
  /// final last30Days = DateTime.now().subtract(Duration(days: 30));
  /// final result = await repository.getSessionsByTimeframe(
  ///   userId: 'user123',
  ///   exerciseName: 'Bench Press',
  ///   start: last30Days,
  ///   end: DateTime.now(),
  /// );
  /// ```
  @override
  Future<Either<Failure, List<ExerciseSession>>> getSessionsByTimeframe({
    required String userId,
    required String exerciseName,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      // Check cache first
      final cacheKey = _getCacheKey(userId, exerciseName);
      final cached = _getFromCache(cacheKey);
      if (cached != null) {
        // Filter sessions by timeframe
        final filteredSessions = cached.getSessionsByTimeframe(start, end);
        return Right(filteredSessions);
      }

      // Fetch from Firestore
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .doc(exerciseName)
          .get();

      if (!doc.exists) {
        return const Right([]); // No history for this exercise yet
      }

      final model = ExerciseHistoryModel.fromFirestore(doc);
      final history = model.toDomain();

      // Cache for future reads
      _saveToCache(cacheKey, history);

      // Filter sessions by timeframe
      final filteredSessions = history.getSessionsByTimeframe(start, end);
      return Right(filteredSessions);
    } catch (e) {
      return Left(ServerFailure( 'Failed to fetch sessions: $e'));
    }
  }

  /// Search exercises by name (fuzzy search)
  ///
  /// **Firestore Limitation**: Firestore doesn't support fuzzy search natively
  ///
  /// **Workaround**:
  /// 1. Fetch ALL analytics documents for user
  /// 2. Filter client-side using case-insensitive contains
  ///
  /// **Example**:
  /// ```dart
  /// final result = await repository.searchExercises(
  ///   userId: 'user123',
  ///   query: 'bench', // Matches "Bench Press", "Incline Bench", etc.
  /// );
  /// ```
  @override
  Future<Either<Failure, List<ExerciseHistory>>> searchExercises({
    required String userId,
    required String query,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .get();

      final queryLower = query.toLowerCase();
      final matchingHistories = snapshot.docs
          .map((doc) => ExerciseHistoryModel.fromFirestore(doc).toDomain())
          .where((history) =>
              history.exerciseName.toLowerCase().contains(queryLower))
          .toList();

      // Sort by relevance (exact match first, then alphabetically)
      matchingHistories.sort((a, b) {
        final aExact = a.exerciseName.toLowerCase() == queryLower;
        final bExact = b.exerciseName.toLowerCase() == queryLower;
        if (aExact && !bExact) return -1;
        if (!aExact && bExact) return 1;
        return a.exerciseName.compareTo(b.exerciseName);
      });

      return Right(matchingHistories);
    } catch (e) {
      return Left(ServerFailure( 'Failed to search exercises: $e'));
    }
  }

  /// Get exercise history for a specific exercise
  ///
  /// **Firestore Query**: Read single document
  ///
  /// **Cache Strategy**: Check Hive first (5-min TTL), then Firestore
  ///
  /// **Example**:
  /// ```dart
  /// final result = await repository.getExerciseHistoryByName(
  ///   userId: 'user123',
  ///   exerciseName: 'Bench Press',
  /// );
  /// ```
  @override
  Future<Either<Failure, ExerciseHistory>> getExerciseHistoryByName({
    required String userId,
    required String exerciseName,
  }) async {
    try {
      // Check cache first
      final cacheKey = _getCacheKey(userId, exerciseName);
      final cached = _getFromCache(cacheKey);
      if (cached != null) {
        return Right(cached);
      }

      // Fetch from Firestore
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .doc(exerciseName)
          .get();

      if (!doc.exists) {
        return Left(
          CacheFailure( 'No history found for $exerciseName'),
        );
      }

      final model = ExerciseHistoryModel.fromFirestore(doc);
      final history = model.toDomain();

      // Cache for future reads
      _saveToCache(cacheKey, history);

      return Right(history);
    } catch (e) {
      return Left(ServerFailure( 'Failed to fetch history: $e'));
    }
  }

  /// Update exercise history (write-through to analytics collection)
  ///
  /// **Write Logic**:
  /// 1. Read existing analytics document (if exists)
  /// 2. Append new session to sessions array
  /// 3. Write back to Firestore
  /// 4. Invalidate cache
  ///
  /// **Called By**: Workout completion hook (Task 2.5)
  ///
  /// **Example**:
  /// ```dart
  /// await repository.updateExerciseHistory(
  ///   userId: 'user123',
  ///   exerciseName: 'Bench Press',
  ///   session: ExerciseSession(
  ///     exerciseName: 'Bench Press',
  ///     muscleGroup: 'chest',
  ///     sets: [...],
  ///     date: DateTime.now(),
  ///   ),
  /// );
  /// ```
  Future<Either<Failure, void>> updateExerciseHistory({
    required String userId,
    required String exerciseName,
    required String muscleGroup,
    required ExerciseSession session,
  }) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .doc(exerciseName);

      // Read existing document
      final doc = await docRef.get();

      ExerciseHistory updatedHistory;
      if (doc.exists) {
        // Append session to existing history
        final model = ExerciseHistoryModel.fromFirestore(doc);
        final existingHistory = model.toDomain();
        updatedHistory = ExerciseHistory(
          exerciseName: exerciseName,
          muscleGroup: muscleGroup,
          sessions: [...existingHistory.sessions, session],
        );
      } else {
        // Create new history with first session
        updatedHistory = ExerciseHistory(
          exerciseName: exerciseName,
          muscleGroup: muscleGroup,
          sessions: [session],
        );
      }

      // Write back to Firestore
      final updatedModel = ExerciseHistoryModel.fromDomain(updatedHistory);
      await docRef.set(updatedModel.toFirestore());

      // Invalidate cache
      final cacheKey = _getCacheKey(userId, exerciseName);
      await _cacheBox.delete(cacheKey);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure( 'Failed to update analytics: $e'));
    }
  }

  /// Delete all analytics for a user (for testing/cleanup)
  ///
  /// **WARNING**: This is a destructive operation!
  ///
  /// **Use Case**: User data deletion, testing cleanup
  ///
  /// **Example**:
  /// ```dart
  /// await repository.deleteAllAnalytics(userId: 'user123');
  /// ```
  Future<Either<Failure, void>> deleteAllAnalytics({
    required String userId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .get();

      // Delete all documents in batch
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Clear all cache for this user
      final cacheKeys =
          _cacheBox.keys.where((key) => key.toString().contains(userId));
      for (final key in cacheKeys) {
        await _cacheBox.delete(key);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure( 'Failed to delete analytics: $e'));
    }
  }

  // ============================================================================
  // CACHE HELPERS
  // ============================================================================

  /// Generate cache key for exercise history
  String _getCacheKey(String userId, String exerciseName) {
    return 'analytics_${userId}_$exerciseName';
  }

  /// Get exercise history from Hive cache (with TTL check)
  ///
  /// **Returns**: Cached history if valid (within TTL), null if expired/missing
  ExerciseHistory? _getFromCache(String cacheKey) {
    try {
      final cached = _cacheBox.get(cacheKey);
      if (cached == null) return null;

      final cachedAt = DateTime.parse(cached['cachedAt'] as String);
      final now = DateTime.now();

      // Check TTL
      if (now.difference(cachedAt) > _cacheTTL) {
        _cacheBox.delete(cacheKey); // Expired, delete
        return null;
      }

      // Deserialize from cache
      final jsonData = Map<String, dynamic>.from(cached['data'] as Map);
      final model = ExerciseHistoryModel.fromJson(jsonData);
      return model.toDomain();
    } catch (e) {
      // Cache corruption, delete
      _cacheBox.delete(cacheKey);
      return null;
    }
  }

  /// Save exercise history to Hive cache (with timestamp)
  void _saveToCache(String cacheKey, ExerciseHistory history) {
    try {
      final model = ExerciseHistoryModel.fromDomain(history);
      final jsonData = model.toJson();

      _cacheBox.put(cacheKey, {
        'cachedAt': DateTime.now().toIso8601String(),
        'data': jsonData,
      });
    } catch (e) {
      // Ignore cache write errors (non-critical)
    }
  }

  /// Clear local cache for analytics data
  ///
  /// **Use Cases**:
  /// - Force refresh from Firestore
  /// - Clear stale data
  /// - Reset after sync issues
  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await _cacheBox.clear();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure( 'Failed to clear cache: $e'));
    }
  }

  /// Check if local cache is valid for a user
  ///
  /// **Logic**:
  /// - Check if any cache entry for this user exists
  /// - If exists and within TTL → valid
  /// - If missing or expired → invalid
  @override
  Future<bool> isCacheValid(String userId) async {
    try {
      final userCacheKeys = _cacheBox.keys
          .where((key) => key.toString().contains('analytics_$userId'));

      for (final key in userCacheKeys) {
        final cached = _cacheBox.get(key);
        if (cached != null) {
          final cachedAt = DateTime.parse(cached['cachedAt'] as String);
          final now = DateTime.now();
          if (now.difference(cachedAt) <= _cacheTTL) {
            return true; // At least one valid cache entry found
          }
        }
      }

      return false; // No valid cache entries
    } catch (e) {
      return false; // Error reading cache, consider invalid
    }
  }
}
