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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/core/data/mixins/firebase_error_mapper_mixin.dart';
import 'package:gymbro_flutter_new/features/analytics/data/models/exercise_history_model.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Analytics repository implementation with Firestore + Hive cache
class AnalyticsRepositoryImpl
    with FirebaseErrorMapperMixin
    implements AnalyticsRepository {
  AnalyticsRepositoryImpl({
    required FirebaseFirestore firestore,
    required Box<Map<dynamic, dynamic>> cacheBox,
  }) : _firestore = firestore,
       _cacheBox = cacheBox;
  final FirebaseFirestore _firestore;
  final Box<Map<dynamic, dynamic>> _cacheBox;

  /// Cache TTL: 5 minutes
  static const _cacheTTL = Duration(minutes: 5);

  /// Active stream subscriptions per user (for proper disposal)
  /// Key: userId, Value: Firestore subscription
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      _activeListeners = {};

  /// Stream controllers for each user (to properly close streams)
  final Map<String, StreamController<Either<Failure, List<ExerciseHistory>>>>
      _streamControllers = {};

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
    // Cancel any existing listener for this user (prevent memory leak)
    _activeListeners[userId]?.cancel();
    _streamControllers[userId]?.close();

    if (kDebugMode) {
      debugPrint(
        '📊 [ANALYTICS] Subscribing to analytics stream for user: $userId',
      );
    }

    // Create a new controller for this user
    final controller =
        StreamController<Either<Failure, List<ExerciseHistory>>>();
    _streamControllers[userId] = controller;

    // Subscribe to Firestore snapshots
    _activeListeners[userId] = _firestore
        .collection('users')
        .doc(userId)
        .collection('analytics')
        .snapshots()
        .listen(
      (snapshot) {
        try {
          if (kDebugMode) {
            debugPrint(
              '📊 [ANALYTICS] Received snapshot: ${snapshot.docs.length} documents',
            );
            if (snapshot.docs.isEmpty) {
              debugPrint(
                '⚠️ [ANALYTICS] Empty analytics collection! Run migration to populate.',
              );
            } else {
              debugPrint(
                '📊 [ANALYTICS] Exercises found: ${snapshot.docs.map((d) => d.id).join(", ")}',
              );
            }
          }

          final histories = snapshot.docs
              .map(
                (doc) => ExerciseHistoryModel.fromFirestore(doc).toDomain(),
              )
              .toList();

          // Sort by exercise name alphabetically
          histories.sort(
            (a, b) => a.exerciseName.compareTo(b.exerciseName),
          );

          if (kDebugMode) {
            debugPrint(
              '✅ [ANALYTICS] Returning ${histories.length} exercise histories',
            );
          }

          controller.add(Right(histories));
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ [ANALYTICS] Parse error: $e');
          }
          controller.add(Left(CacheFailure('Failed to parse analytics: $e')));
        }
      },
      onError: (Object e) {
        if (kDebugMode) {
          debugPrint('❌ [ANALYTICS] Stream error: $e');
        }
        controller
            .add(Left(ServerFailure('Failed to fetch analytics: $e')));
      },
    );

    return controller.stream;
  }

  /// Cancel all active listeners and close stream controllers
  /// Call this when the repository is no longer needed
  void dispose() {
    if (kDebugMode) {
      debugPrint(
        '🧹 [ANALYTICS] Disposing ${_activeListeners.length} active listeners',
      );
    }
    for (final subscription in _activeListeners.values) {
      subscription.cancel();
    }
    _activeListeners.clear();

    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
  }

  /// Cancel listener for a specific user
  void cancelUserListener(String userId) {
    _activeListeners[userId]?.cancel();
    _activeListeners.remove(userId);
    _streamControllers[userId]?.close();
    _streamControllers.remove(userId);
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
    // Check cache first
    final cacheKey = _getCacheKey(userId, exerciseName);
    final cached = _getFromCache(cacheKey);
    if (cached != null) {
      // Filter sessions by timeframe
      final filteredSessions = cached.getSessionsByTimeframe(start, end);
      return Right(filteredSessions);
    }

    // Fetch from Firestore using mixin
    return handleFirebaseOperation(() async {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .doc(exerciseName)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!doc.exists) {
        return <ExerciseSession>[]; // No history for this exercise yet
      }

      final model = ExerciseHistoryModel.fromFirestore(doc);
      final history = model.toDomain();

      // Cache for future reads
      _saveToCache(cacheKey, history);

      // Filter sessions by timeframe
      return history.getSessionsByTimeframe(start, end);
    }, operationName: 'getSessionsByTimeframe');
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
    return handleFirebaseOperation(() async {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .get()
          .timeout(const Duration(seconds: 10));

      final queryLower = query.toLowerCase();
      final matchingHistories = snapshot.docs
          .map((doc) => ExerciseHistoryModel.fromFirestore(doc).toDomain())
          .where(
            (history) =>
                history.exerciseName.toLowerCase().contains(queryLower),
          )
          .toList();

      // Sort by relevance (exact match first, then alphabetically)
      matchingHistories.sort((a, b) {
        final aExact = a.exerciseName.toLowerCase() == queryLower;
        final bExact = b.exerciseName.toLowerCase() == queryLower;
        if (aExact && !bExact) return -1;
        if (!aExact && bExact) return 1;
        return a.exerciseName.compareTo(b.exerciseName);
      });

      return matchingHistories;
    }, operationName: 'searchExercises');
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
    // Check cache first
    final cacheKey = _getCacheKey(userId, exerciseName);
    final cached = _getFromCache(cacheKey);
    if (cached != null) {
      return Right(cached);
    }

    // Fetch from Firestore using mixin
    return handleFirebaseOperation(() async {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .doc(exerciseName)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!doc.exists) {
        throw NotFoundFailure('No history found for $exerciseName');
      }

      final model = ExerciseHistoryModel.fromFirestore(doc);
      final history = model.toDomain();

      // Cache for future reads
      _saveToCache(cacheKey, history);

      return history;
    }, operationName: 'getExerciseHistoryByName');
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
  @override
  Future<Either<Failure, void>> updateExerciseHistory({
    required String userId,
    required String exerciseId,
    required String exerciseName,
    required String muscleGroup,
    required ExerciseSession session,
  }) async {
    final result = await handleFirebaseVoidOperation(() async {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .doc(exerciseName);

      // Read existing document
      final doc = await docRef.get().timeout(const Duration(seconds: 10));

      ExerciseHistory updatedHistory;
      if (doc.exists) {
        // Append session to existing history
        final model = ExerciseHistoryModel.fromFirestore(doc);
        final existingHistory = model.toDomain();
        updatedHistory = ExerciseHistory(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          muscleGroup: muscleGroup,
          sessions: [...existingHistory.sessions, session],
        );
      } else {
        // Create new history with first session
        updatedHistory = ExerciseHistory(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          muscleGroup: muscleGroup,
          sessions: [session],
        );
      }

      // Write back to Firestore
      final updatedModel = ExerciseHistoryModel.fromDomain(updatedHistory);
      await docRef
          .set(updatedModel.toFirestore())
          .timeout(const Duration(seconds: 10));

      // Invalidate cache
      final cacheKey = _getCacheKey(userId, exerciseName);
      await _cacheBox.delete(cacheKey);
    }, operationName: 'updateExerciseHistory');

    // Convert Either<Failure, Unit> to Either<Failure, void> for backward compatibility
    return result.fold((failure) => Left(failure), (_) => const Right(null));
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
    final result = await handleFirebaseVoidOperation(() async {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .get()
          .timeout(const Duration(seconds: 10));

      // Delete all documents in batch
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit().timeout(const Duration(seconds: 15));

      // Clear all cache for this user
      final cacheKeys = _cacheBox.keys.where(
        (key) => key.toString().contains(userId),
      );
      for (final key in cacheKeys) {
        await _cacheBox.delete(key);
      }
    }, operationName: 'deleteAllAnalytics');

    // Convert Either<Failure, Unit> to Either<Failure, void> for backward compatibility
    return result.fold((failure) => Left(failure), (_) => const Right(null));
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
      return Left(CacheFailure('Failed to clear cache: $e'));
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
      final userCacheKeys = _cacheBox.keys.where(
        (key) => key.toString().contains('analytics_$userId'),
      );

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
