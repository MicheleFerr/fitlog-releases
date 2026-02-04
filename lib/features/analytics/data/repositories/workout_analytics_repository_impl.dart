/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: data
/// 🎯 Feature: analytics
/// 🔧 Type: repository implementation
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Firebase: Firestore
/// - Hive: Local storage
/// - workout/domain/entities: Workout
/// - analytics/domain: Repository, Entities, Services
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/workout_analytics_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/shared/data/repositories/rate_limited_firestore_mixin.dart';
import 'package:gymbro_flutter_new/features/analytics/data/services/analytics_cache_service.dart';

/// Firebase and Hive implementation of WorkoutAnalyticsRepository
///
/// ✅ UPDATED for HiveBoxManagerEnhanced pattern (Oct 2025)
/// 🔒 RATE LIMITING: All Firestore operations are rate-limited to prevent quota exhaustion
/// 💾 CACHING: Aggressive 1-hour cache for analytics to reduce Firebase reads
class WorkoutAnalyticsRepositoryImpl
    with RateLimitedFirestoreMixin
    implements WorkoutAnalyticsRepository {
  WorkoutAnalyticsRepositoryImpl({
    FirebaseFirestore? firestore,
    required Box metricsCache,
    required HiveBoxManagerEnhanced boxManager,
    PRTracker? prTracker,
    HiveWorkoutDataSource? hiveWorkoutDataSource,
    AnalyticsCacheService? cacheService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _metricsCache = metricsCache,
       _prTracker = prTracker ?? PRTracker(),
       _hiveWorkoutDataSource =
           hiveWorkoutDataSource ?? HiveWorkoutDataSource(boxManager),
       _cacheService = cacheService ?? AnalyticsCacheService(boxManager);
  final FirebaseFirestore _firestore;
  final Box _metricsCache;
  final PRTracker _prTracker;
  final HiveWorkoutDataSource _hiveWorkoutDataSource;
  final AnalyticsCacheService _cacheService;

  // Stream controllers for real-time updates
  final Map<String, StreamController<WorkoutAnalyticsUpdate>>
  _updateControllers = {};

  // Sync progress callback (can be set externally)
  Function(int current, int total)? _syncProgressCallback;

  /// Set sync progress callback
  void setSyncProgressCallback(Function(int current, int total)? callback) {
    _syncProgressCallback = callback;
  }

  /// ⚡ HELPER: Normalize cached workout data for Workout.fromJson()
  /// Converts DateTime objects to ISO strings (Hive stores DateTime, Workout.fromJson expects String)
  Map<String, dynamic> _normalizeWorkoutData(Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data);

    // Date fields that Workout.fromJson expects as String
    for (final key in [
      'createdAt',
      'updatedAt',
      'startTime',
      'endTime',
      'preloadExpiry',
    ]) {
      final value = normalized[key];
      if (value is DateTime) {
        normalized[key] = value.toIso8601String();
      } else if (value is Timestamp) {
        normalized[key] = value.toDate().toIso8601String();
      }
    }

    // Also normalize exercises if present
    if (normalized['exercises'] is List) {
      normalized['exercises'] = (normalized['exercises'] as List).map((e) {
        if (e is Map) {
          return _normalizeExerciseData(Map<String, dynamic>.from(e));
        }
        return e;
      }).toList();
    }

    return normalized;
  }

  /// ⚡ HELPER: Normalize exercise data
  Map<String, dynamic> _normalizeExerciseData(Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data);

    for (final key in ['createdAt', 'updatedAt', 'completedAt']) {
      final value = normalized[key];
      if (value is DateTime) {
        normalized[key] = value.toIso8601String();
      } else if (value is Timestamp) {
        normalized[key] = value.toDate().toIso8601String();
      }
    }

    // Normalize sets if present
    if (normalized['sets'] is List) {
      normalized['sets'] = (normalized['sets'] as List).map((s) {
        if (s is Map) {
          final setData = Map<String, dynamic>.from(s);
          for (final key in ['completedAt', 'setStartedAt']) {
            final value = setData[key];
            if (value is DateTime) {
              setData[key] = value.toIso8601String();
            } else if (value is Timestamp) {
              setData[key] = value.toDate().toIso8601String();
            }
          }
          return setData;
        }
        return s;
      }).toList();
    }

    return normalized;
  }

  @override
  Future<List<Workout>> getHistoricalWorkouts(
    String userId, {
    int limit = 50,
    DateTime? since,
  }) async {
    try {
      // 💾 CACHING: Check cache first
      final cacheKey = AnalyticsCacheKeys.workoutHistory(
        userId,
        limit: limit,
        since: since,
      );
      // ⚡ PERFORMANCE: Use .map() instead of .cast() for Hive nested maps
      final cached = await _cacheService.get<List<Map<String, dynamic>>>(
        cacheKey,
        (json) => (json['workouts'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      );

      if (cached != null) {
        if (kDebugMode) {
          debugPrint(
            '💾 [Analytics] Using cached workouts (${cached.length} workouts)',
          );
        }
        // Convert cached data to Workout entities
        // ⚡ Use _normalizeWorkoutData to convert DateTime→String for Workout.fromJson
        return cached
            .map((workoutMap) {
              try {
                return Workout.fromJson(_normalizeWorkoutData(workoutMap));
              } catch (e) {
                if (kDebugMode) {
                  debugPrint(
                    '❌ [Analytics] Failed to parse cached workout: $e',
                  );
                }
                return null;
              }
            })
            .whereType<Workout>()
            .toList();
      }

      // ✅ HiveBoxManagerEnhanced handles initialization automatically

      // 🎯 PAGINATION: Default to 30 days if no since date provided
      final effectiveSince =
          since ?? DateTime.now().subtract(const Duration(days: 30));

      if (kDebugMode) {
        debugPrint(
          '📊 [Analytics] Fetching workouts since: ${effectiveSince.toIso8601String()}',
        );
      }

      // 🎯 SMART SYNC: Check if Firebase has more workouts than Hive
      final firebaseCount = await _getFirebaseWorkoutCount(userId);
      final hiveCount = await _getHiveWorkoutCount(userId);

      if (kDebugMode) {
        debugPrint(
          '📊 [Analytics] Workout count - Firebase: $firebaseCount, Hive: $hiveCount',
        );
      }

      // If Firebase has more workouts, sync is needed
      if (firebaseCount > hiveCount) {
        await _syncFirebaseToHive(
          userId,
          totalCount: firebaseCount,
          onProgress: _syncProgressCallback,
        );
      } else {
        if (kDebugMode) {
          debugPrint('✅ [Analytics] Hive is up to date ($hiveCount workouts)');
        }
      }

      // Get workouts from Hive (now synced) with pagination
      final localWorkouts = await _getLocalWorkouts(
        userId,
        limit: limit,
        since: effectiveSince,
      );

      if (localWorkouts.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
            '📊 Analytics: Returning ${localWorkouts.length} workouts from Hive',
          );
        }

        // 💾 CACHING: Save to cache for next time
        final workoutMaps = localWorkouts.map((w) => w.toJson()).toList();
        await _cacheService.set(
          cacheKey,
          workoutMaps,
          const Duration(hours: 1), // Cache for 1 hour
          (data) => {'workouts': data},
        );

        return localWorkouts;
      }

      return [];
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching historical workouts: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      return [];
    }
  }

  /// Get count of completed workouts on Firebase (fast query)
  /// Note: Many workouts on Firebase have status=null, so we query for both
  /// completed status and null status (treating null as completed)
  ///
  /// 🚀 PERFORMANCE FIX: Added 1-hour cache to prevent O(N) reads on every analytics screen open
  /// Cache key: 'workout_count_$userId'
  /// Reduces: ~100 reads → 1 read per hour (for user with 100 workouts)
  Future<int> _getFirebaseWorkoutCount(String userId) async {
    // 🔧 CACHE CHECK: Try to get count from cache first (1h TTL)
    final cacheKey = 'workout_count_$userId';
    final cached = await _cacheService.get<int>(cacheKey);

    if (cached != null) {
      if (kDebugMode) {
        debugPrint('✅ [Count] Cache HIT for user $userId: $cached workouts');
      }
      return cached;
    }

    if (kDebugMode) {
      debugPrint('⚠️ [Count] Cache MISS - fetching from Firestore');
    }

    return await rateLimitedQuery(() async {
      try {
        // Query for ALL workouts for this user (many have status=null on Firebase)
        // We'll filter on the client side to only count completed/null workouts
        final snapshot = await _firestore
            .collection('workouts')
            .where('userId', isEqualTo: userId)
            .get();

        // Count workouts that should be synced
        // Since Firebase workouts have status=null and often no endTime,
        // we need to be more permissive and check for actual workout data
        int validWorkoutCount = 0;
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final exercises = data['exercises'] as List?;
          final name = data['name'] as String?;

          // Consider a workout valid for analytics if:
          // 1. It has exercises (actual workout data), OR
          // 2. It has a non-empty name (named workout)
          // This filters out empty/placeholder workouts
          final hasExercises = exercises != null && exercises.isNotEmpty;
          final hasName = name != null && name.isNotEmpty;

          if (hasExercises || hasName) {
            validWorkoutCount++;
          }
        }

        // 🔧 CACHE SAVE: Store count for 1 hour
        await _cacheService.set(cacheKey, validWorkoutCount);

        if (kDebugMode) {
          debugPrint(
            '✅ [Count] Cached $validWorkoutCount workouts for user $userId',
          );
        }

        return validWorkoutCount;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ [Count] Failed to get Firebase count: $e');
        }
        return 0;
      }
    });
  }

  /// Cached local workouts to prevent double reading from Hive
  /// Key: userId, Value: (timestamp, workouts)
  final Map<String, (DateTime, List<WorkoutModel>)> _localWorkoutsCache = {};

  /// Cache TTL for local workouts (30 seconds - just to prevent double reads in same flow)
  static const _localCacheTTL = Duration(seconds: 30);

  /// Get all local workouts with in-memory caching
  /// This prevents double Hive reads in the same getHistoricalWorkouts() call
  Future<List<WorkoutModel>> _getCachedLocalWorkouts(String userId) async {
    // Check in-memory cache
    final cached = _localWorkoutsCache[userId];
    if (cached != null) {
      final (timestamp, workouts) = cached;
      if (DateTime.now().difference(timestamp) < _localCacheTTL) {
        return workouts;
      }
    }

    // Read from Hive once
    final workoutModels = await _hiveWorkoutDataSource.getWorkoutsForAnalytics(
      userId,
      limit: null, // Get all
    );

    // Cache for subsequent calls
    _localWorkoutsCache[userId] = (DateTime.now(), workoutModels);

    return workoutModels;
  }

  /// Get count of workouts in local Hive storage
  /// Uses in-memory cache to prevent double reads
  Future<int> _getHiveWorkoutCount(String userId) async {
    try {
      final workoutModels = await _getCachedLocalWorkouts(userId);

      // Count only completed workouts
      final completedCount = workoutModels
          .where((model) => model.status == 'completed')
          .length;

      return completedCount;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [Count] Failed to get Hive count: $e');
      }
      return 0;
    }
  }

  /// Sync workouts from Firebase to Hive with progress tracking
  Future<void> _syncFirebaseToHive(
    String userId, {
    int? totalCount,
    Function(int current, int total)? onProgress,
  }) async {
    return await rateLimitedQuery(() async {
      try {
        if (kDebugMode) {
          debugPrint(
            '🔄 [Sync] Starting Firebase → Hive sync for user: $userId',
          );
        }

        // Get ALL workouts from Firebase (many have status=null)
        // We can't use .where('status', isEqualTo: 'completed') because many workouts have null status
        final snapshot = await _firestore
            .collection('workouts')
            .where('userId', isEqualTo: userId)
            .get();

        if (kDebugMode) {
          debugPrint(
            '🔄 [Sync] Found ${snapshot.docs.length} total workouts in Firebase',
          );
        }

        // Filter to only workouts with actual data (exercises or name)
        final validDocs = snapshot.docs.where((doc) {
          final data = doc.data();
          final exercises = data['exercises'] as List?;
          final name = data['name'] as String?;

          final hasExercises = exercises != null && exercises.isNotEmpty;
          final hasName = name != null && name.isNotEmpty;

          return hasExercises || hasName;
        }).toList();

        // Sort by createdAt or updatedAt descending
        validDocs.sort((a, b) {
          final aData = a.data();
          final bData = b.data();

          // Try endTime first, then updatedAt, then createdAt
          final aTime =
              aData['endTime'] ?? aData['updatedAt'] ?? aData['createdAt'];
          final bTime =
              bData['endTime'] ?? bData['updatedAt'] ?? bData['createdAt'];

          if (aTime == null || bTime == null) return 0;

          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }

          return 0;
        });

        final total = totalCount ?? validDocs.length;
        if (kDebugMode) {
          debugPrint(
            '🔄 [Sync] Found ${validDocs.length} valid workouts to sync (with exercises/name)',
          );
        }

        if (validDocs.isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [Sync] No valid workouts found in Firebase for user: $userId',
            );
          }
          return;
        }

        // Convert valid docs to WorkoutModel and save to Hive
        int savedCount = 0;
        for (final doc in validDocs) {
          try {
            final data = doc.data();
            data['id'] = doc.id;

            // Parse WorkoutModel from Firebase data
            final workoutModel = WorkoutModel.fromJson(data);

            // Save to Hive
            await _hiveWorkoutDataSource.saveWorkout(workoutModel, userId);
            savedCount++;

            // Notify progress
            if (onProgress != null) {
              onProgress(savedCount, total);
            }

            if (kDebugMode) {
              debugPrint(
                '💾 [Sync] Saved workout ${doc.id} ($savedCount/$total)',
              );
            }
          } catch (e, stackTrace) {
            if (kDebugMode) {
              debugPrint('❌ [Sync] Failed to parse/save workout ${doc.id}: $e');
              debugPrint('📍 Stack trace: $stackTrace');
            }
            // Continue with next workout instead of failing completely
          }
        }

        if (kDebugMode) {
          debugPrint(
            '✅ [Sync] Successfully synced $savedCount/$total workouts to Hive',
          );
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ [Sync] Firebase → Hive sync failed: $e');
          debugPrint('📍 [Sync] Stack trace: $stackTrace');
        }
        rethrow; // Re-throw to allow error handling in UI
      }
    });
  }

  /// Get workouts from local Hive storage via HiveWorkoutDataSource
  /// Uses in-memory cache to prevent double reads in the same flow
  Future<List<Workout>> _getLocalWorkouts(
    String userId, {
    int? limit,
    DateTime? since,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📊 [Analytics] Getting local workouts for user: $userId (using cache)',
        );
      }

      // 🚀 PERFORMANCE: Use cached workouts to prevent double Hive reads
      final workoutModels = await _getCachedLocalWorkouts(userId);

      // Convert to domain entities and filter by completion status and date
      var workouts = workoutModels
          .map((model) => model.toDomain())
          .where((workout) => workout.status == WorkoutStatus.completed)
          .toList();

      // Apply date filter if specified
      if (since != null) {
        workouts = workouts
            .where((w) => (w.endTime ?? w.updatedAt).isAfter(since))
            .toList();
      }

      if (kDebugMode) {
        debugPrint(
          '📊 [Analytics] Found ${workouts.length} completed workouts',
        );
      }

      // Sort by date (most recent first)
      workouts.sort(
        (a, b) =>
            (b.endTime ?? b.updatedAt).compareTo(a.endTime ?? a.updatedAt),
      );

      // Apply limit if specified
      if (limit != null && workouts.length > limit) {
        workouts = workouts.take(limit).toList();
      }

      if (kDebugMode) {
        debugPrint('✅ [Analytics] Returning ${workouts.length} local workouts');
      }
      return workouts;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [Analytics] Error fetching local workouts: $e');
        debugPrint('📍 [Analytics] Stack trace: $stackTrace');
      }
      return [];
    }
  }

  @override
  Future<List<Workout>> getSimilarWorkouts(
    String userId,
    Workout targetWorkout, {
    int limit = 10,
    double minSimilarity = 0.3,
  }) async {
    // For now, get recent workouts and filter by muscle groups
    // In a full implementation, this would use ML/vector similarity

    final recentWorkouts = await getHistoricalWorkouts(userId, limit: 100);
    final targetMuscleGroups = targetWorkout.exercises
        .map((e) => e.category)
        .toSet();

    final similarWorkouts = recentWorkouts
        .where((workout) {
          final workoutMuscleGroups = workout.exercises
              .map((e) => e.category)
              .toSet();

          final overlap = targetMuscleGroups.intersection(workoutMuscleGroups);
          final union = targetMuscleGroups.union(workoutMuscleGroups);

          final similarity = union.isEmpty
              ? 0.0
              : overlap.length / union.length;
          return similarity >= minSimilarity;
        })
        .take(limit)
        .toList();

    return similarWorkouts;
  }

  @override
  Future<List<PersonalRecord>> getUserPRs(String userId) async {
    return await _prTracker.getUserPRs(userId);
  }

  @override
  Future<Map<PRType, PersonalRecord>> getExercisePRs(
    String userId,
    String exerciseId,
  ) async {
    return await _prTracker.getExercisePRs(userId, exerciseId);
  }

  @override
  Future<void> savePR(PersonalRecord pr) async {
    await _prTracker.savePR(pr);

    // Notify subscribers of PR achievement
    _notifyPRUpdate(pr);
  }

  @override
  Future<List<WorkoutMetrics>> getWorkoutMetricsHistory(
    String userId, {
    int limit = 30,
    DateTime? since,
  }) async {
    try {
      Query query = _firestore
          .collection('workoutMetrics')
          .where('userId', isEqualTo: userId)
          .orderBy('calculatedAt', descending: true)
          .limit(limit);

      if (since != null) {
        query = query.where(
          'calculatedAt',
          isGreaterThan: Timestamp.fromDate(since),
        );
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _workoutMetricsFromFirestore(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching workout metrics history: $e');
      }
      return [];
    }
  }

  @override
  Future<void> cacheWorkoutMetrics(WorkoutMetrics metrics) async {
    try {
      final data = _workoutMetricsToMap(metrics);
      await _metricsCache.put(metrics.workoutId, data);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error caching workout metrics: $e');
      }
    }
  }

  @override
  Future<WorkoutMetrics?> getCachedWorkoutMetrics(String workoutId) async {
    try {
      final data = _metricsCache.get(workoutId);
      if (data == null) return null;

      return _workoutMetricsFromMap(data);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting cached workout metrics: $e');
      }
      return null;
    }
  }

  @override
  Future<WorkoutAnalyticsStats> getAnalyticsStats(String userId) async {
    try {
      // 💾 CACHING: Check cache first
      final cacheKey = AnalyticsCacheKeys.analyticsStats(userId);
      final cached = await _cacheService.get<Map<String, dynamic>>(
        cacheKey,
        (json) => json,
      );

      if (cached != null) {
        if (kDebugMode) {
          debugPrint('💾 [Analytics] Using cached analytics stats');
        }
        return WorkoutAnalyticsStats.fromJson(cached);
      }

      // Get workout statistics from local storage first, then Firestore
      // 🎯 PAGINATION: Limit to 1 year for performance
      final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
      final workouts = await getHistoricalWorkouts(
        userId,
        limit: 1000,
        since: oneYearAgo,
      );
      final prs = await getUserPRs(userId);

      if (kDebugMode) {
        debugPrint(
          '📊 Analytics Stats: Found ${workouts.length} total workouts for stats calculation',
        );
      }

      if (workouts.isEmpty) {
        return const WorkoutAnalyticsStats(
          totalWorkouts: 0,
          totalPRs: 0,
          averageWorkoutVolume: 0,
          averageWorkoutDuration: 0,
          totalVolumeLifted: 0,
          exerciseFrequency: {},
          exerciseVolumeDistribution: {},
        );
      }

      // Calculate statistics
      final totalVolume = workouts.fold(0.0, (sum, workout) {
        return sum + WorkoutMetrics.fromWorkout(workout).totalVolume;
      });

      final totalDuration = workouts.fold(0.0, (sum, workout) {
        return sum + (workout.duration?.inMinutes ?? 0);
      });

      final exerciseFreq = <String, int>{};
      final exerciseVolDist = <String, double>{};

      for (final workout in workouts) {
        for (final exercise in workout.exercises) {
          exerciseFreq[exercise.name] = (exerciseFreq[exercise.name] ?? 0) + 1;

          final exerciseVolume = exercise.sets
              .where((s) => s.isCompleted)
              .fold(0.0, (sum, set) => sum + set.volume);

          exerciseVolDist[exercise.name] =
              (exerciseVolDist[exercise.name] ?? 0) + exerciseVolume;
        }
      }

      workouts.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));

      final stats = WorkoutAnalyticsStats(
        totalWorkouts: workouts.length,
        totalPRs: prs.length,
        averageWorkoutVolume: totalVolume / workouts.length,
        averageWorkoutDuration: totalDuration / workouts.length,
        totalVolumeLifted: totalVolume,
        exerciseFrequency: exerciseFreq,
        exerciseVolumeDistribution: exerciseVolDist,
        firstWorkoutDate: workouts.isNotEmpty ? workouts.first.updatedAt : null,
        lastWorkoutDate: workouts.isNotEmpty ? workouts.last.updatedAt : null,
      );

      // 💾 CACHING: Save to cache for next time
      await _cacheService.set(
        cacheKey,
        stats.toJson(),
        const Duration(hours: 1), // Cache for 1 hour
        (data) => data,
      );

      return stats;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error calculating analytics stats: $e');
      }
      return const WorkoutAnalyticsStats(
        totalWorkouts: 0,
        totalPRs: 0,
        averageWorkoutVolume: 0,
        averageWorkoutDuration: 0,
        totalVolumeLifted: 0,
        exerciseFrequency: {},
        exerciseVolumeDistribution: {},
      );
    }
  }

  @override
  Stream<WorkoutAnalyticsUpdate> watchWorkoutUpdates(String workoutId) {
    if (!_updateControllers.containsKey(workoutId)) {
      _updateControllers[workoutId] =
          StreamController<WorkoutAnalyticsUpdate>.broadcast();
    }

    return _updateControllers[workoutId]!.stream;
  }

  /// Notify subscribers of workout metrics update
  void notifyWorkoutUpdate(WorkoutMetrics metrics) {
    final controller = _updateControllers[metrics.workoutId];
    if (controller != null && !controller.isClosed) {
      controller.add(
        WorkoutAnalyticsUpdate(
          workoutId: metrics.workoutId,
          metrics: metrics,
          newPRs: metrics.personalRecords,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> syncWorkoutsFromFirebase(
    String userId, {
    Function(int current, int total)? onProgress,
  }) async {
    await _syncFirebaseToHive(userId, onProgress: onProgress);
  }

  /// Get sync status (counts comparison)
  Future<({int firebase, int hive, bool needsSync})> getSyncStatus(
    String userId,
  ) async {
    final firebaseCount = await _getFirebaseWorkoutCount(userId);
    final hiveCount = await _getHiveWorkoutCount(userId);

    return (
      firebase: firebaseCount,
      hive: hiveCount,
      needsSync: firebaseCount > hiveCount,
    );
  }

  /// Notify subscribers of PR achievement
  void _notifyPRUpdate(PersonalRecord pr) {
    // This would typically be called from the workout context
    // For now, we'll emit a minimal update
    final prAchieved = PersonalRecordAchieved(
      exerciseId: pr.exerciseId,
      exerciseName: pr.exerciseName,
      type: pr.type,
      newValue: pr.value,
      previousValue: pr.previousValue,
      achievedAt: pr.achievedAt,
      context: pr.metadata,
    );

    // Find the appropriate controller (would need workout context)
    for (final controller in _updateControllers.values) {
      if (!controller.isClosed) {
        controller.add(
          WorkoutAnalyticsUpdate(
            workoutId: 'unknown', // Would need workout context
            metrics: WorkoutMetrics.empty('unknown'),
            newPRs: [prAchieved],
            timestamp: DateTime.now(),
          ),
        );
      }
    }
  }

  /// Save workout metrics to Firestore
  Future<void> saveWorkoutMetrics(WorkoutMetrics metrics, String userId) async {
    return await rateLimitedWrite(() async {
      try {
        final data = _workoutMetricsToFirestore(metrics, userId);
        await _firestore.collection('workoutMetrics').add(data);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error saving workout metrics: $e');
        }
      }
    });
  }

  /// Invalidate analytics cache for user (call after workout completion)
  Future<void> invalidateAnalyticsCache(String userId) async {
    try {
      await _cacheService.invalidateUser(userId);
      if (kDebugMode) {
        debugPrint(
          '🗑️ [Analytics] Invalidated all analytics cache for user: $userId',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [Analytics] Error invalidating cache: $e');
      }
    }
  }

  /// Get cache statistics for monitoring
  Map<String, dynamic> getCacheStatistics() {
    return _cacheService.getStatistics();
  }

  /// Clean up resources
  Future<void> dispose() async {
    await Future.wait(
      _updateControllers.values.map((controller) => controller.close()),
    );
    _updateControllers.clear();

    // Clear in-memory workout cache
    _localWorkoutsCache.clear();

    // Print final cache statistics
    if (kDebugMode) {
      final stats = _cacheService.getStatistics();
      debugPrint('📊 [Analytics] Final cache statistics: $stats');
    }

    await _cacheService.dispose();
  }

  // Private helper methods

  Map<String, dynamic> _workoutMetricsToFirestore(
    WorkoutMetrics metrics,
    String userId,
  ) {
    return {
      'userId': userId,
      'workoutId': metrics.workoutId,
      'workoutName': metrics.workoutName,
      'workoutDate': metrics.workoutDate != null
          ? Timestamp.fromDate(metrics.workoutDate!)
          : null,
      'calculatedAt': Timestamp.fromDate(metrics.calculatedAt),
      'totalVolume': metrics.totalVolume,
      'workingSetsVolume': metrics.workingSetsVolume,
      'warmupVolume': metrics.warmupVolume,
      'volumeByMuscleGroup': metrics.volumeByMuscleGroup.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'totalSets': metrics.totalSets,
      'completedSets': metrics.completedSets,
      'workingSets': metrics.workingSets,
      'warmupSets': metrics.warmupSets,
      'averageWeight': metrics.averageWeight,
      'averageRPE': metrics.averageRPE,
      'averageIntensity': metrics.averageIntensity,
      'peakIntensity': metrics.peakIntensity,
      'totalDurationMinutes': metrics.totalDuration.inMinutes,
      'workingTimeMinutes': metrics.workingTime.inMinutes,
      'restTimeMinutes': metrics.restTime.inMinutes,
      'trainingDensity': metrics.trainingDensity,
      'completionPercentage': metrics.completionPercentage,
      'exercisesCompleted': metrics.exercisesCompleted,
      'totalExercises': metrics.totalExercises,
      'qualityScore': metrics.qualityScore,
    };
  }

  WorkoutMetrics _workoutMetricsFromFirestore(Map<String, dynamic> data) {
    return WorkoutMetrics(
      workoutId: data['workoutId'] ?? '',
      workoutName: data['workoutName'],
      workoutDate: data['workoutDate'] != null
          ? (data['workoutDate'] as Timestamp).toDate()
          : null,
      calculatedAt: (data['calculatedAt'] as Timestamp).toDate(),
      totalVolume: (data['totalVolume'] as num?)?.toDouble() ?? 0,
      workingSetsVolume: (data['workingSetsVolume'] as num?)?.toDouble() ?? 0,
      warmupVolume: (data['warmupVolume'] as num?)?.toDouble() ?? 0,
      volumeByMuscleGroup: _parseVolumeByMuscleGroup(
        data['volumeByMuscleGroup'],
      ),
      totalSets: data['totalSets'] ?? 0,
      completedSets: data['completedSets'] ?? 0,
      workingSets: data['workingSets'] ?? 0,
      warmupSets: data['warmupSets'] ?? 0,
      averageWeight: (data['averageWeight'] as num?)?.toDouble() ?? 0,
      averageRPE: (data['averageRPE'] as num?)?.toDouble() ?? 0,
      averageIntensity: (data['averageIntensity'] as num?)?.toDouble() ?? 0,
      peakIntensity: (data['peakIntensity'] as num?)?.toDouble() ?? 0,
      totalDuration: Duration(minutes: data['totalDurationMinutes'] ?? 0),
      workingTime: Duration(minutes: data['workingTimeMinutes'] ?? 0),
      restTime: Duration(minutes: data['restTimeMinutes'] ?? 0),
      trainingDensity: (data['trainingDensity'] as num?)?.toDouble() ?? 0,
      completionPercentage:
          (data['completionPercentage'] as num?)?.toDouble() ?? 0,
      exercisesCompleted: data['exercisesCompleted'] ?? 0,
      totalExercises: data['totalExercises'] ?? 0,
    );
  }

  Map<String, dynamic> _workoutMetricsToMap(WorkoutMetrics metrics) {
    return {
      'workoutId': metrics.workoutId,
      'workoutName': metrics.workoutName,
      'workoutDate': metrics.workoutDate?.toIso8601String(),
      'calculatedAt': metrics.calculatedAt.toIso8601String(),
      'totalVolume': metrics.totalVolume,
      'completedSets': metrics.completedSets,
      'totalSets': metrics.totalSets,
      'completionPercentage': metrics.completionPercentage,
      'trainingDensity': metrics.trainingDensity,
      'averageRPE': metrics.averageRPE,
      'totalDurationMinutes': metrics.totalDuration.inMinutes,
    };
  }

  WorkoutMetrics _workoutMetricsFromMap(Map<String, dynamic> data) {
    return WorkoutMetrics(
      workoutId: data['workoutId'] ?? '',
      workoutName: data['workoutName'],
      workoutDate: data['workoutDate'] != null
          ? DateTime.parse(data['workoutDate'])
          : null,
      calculatedAt: DateTime.parse(
        data['calculatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      totalVolume: (data['totalVolume'] as num?)?.toDouble() ?? 0,
      workingSetsVolume: 0, // Simplified for cache
      warmupVolume: 0,
      volumeByMuscleGroup: {},
      totalSets: data['totalSets'] ?? 0,
      completedSets: data['completedSets'] ?? 0,
      workingSets: 0,
      warmupSets: 0,
      averageWeight: 0,
      averageRPE: (data['averageRPE'] as num?)?.toDouble() ?? 0,
      averageIntensity: 0,
      peakIntensity: 0,
      totalDuration: Duration(minutes: data['totalDurationMinutes'] ?? 0),
      workingTime: Duration.zero,
      restTime: Duration.zero,
      trainingDensity: (data['trainingDensity'] as num?)?.toDouble() ?? 0,
      completionPercentage:
          (data['completionPercentage'] as num?)?.toDouble() ?? 0,
      exercisesCompleted: 0,
      totalExercises: 0,
    );
  }

  Map<ExerciseCategory, double> _parseVolumeByMuscleGroup(dynamic data) {
    final result = <ExerciseCategory, double>{};
    if (data is Map<String, dynamic>) {
      for (final entry in data.entries) {
        try {
          final category = ExerciseCategory.values.firstWhere(
            (cat) => cat.name == entry.key,
          );
          result[category] = (entry.value as num?)?.toDouble() ?? 0;
        } catch (e) {
          // Skip invalid categories
        }
      }
    }
    return result;
  }
}
