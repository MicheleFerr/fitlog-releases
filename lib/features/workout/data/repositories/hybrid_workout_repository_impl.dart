/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: data/repositories
/// 🎯 Feature: workout
/// 🔧 Type: repository_implementation
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Hive (local storage)
/// - Firebase Firestore (cloud storage for premium)
/// - Domain entities
/// - Repository interface
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/core/auth/admin_role_helper.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/paginated_result.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/firebase_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';
import 'package:gymbro_flutter_new/shared/domain/concurrency/mutex_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';
import 'package:gymbro_flutter_new/shared/data/mixins/firestore_cache_first_mixin.dart';

// Import unawaited for fire-and-forget futures
// ignore: unused_import

/// Hybrid implementation of WorkoutRepository
/// - Free users: Local storage only (Hive)
/// - Premium users: Local storage + Cloud sync (Firebase)
class HybridWorkoutRepositoryImpl
    with FirestoreCacheFirstMixin
    implements WorkoutRepository {
  HybridWorkoutRepositoryImpl({
    required HiveWorkoutDataSource localDataSource,
    required FirebaseWorkoutDataSource remoteDataSource,
    required FirebaseAuth auth,
    AnalyticsRepository? analyticsRepository,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _auth = auth,
       _analyticsRepository = analyticsRepository {
    // Listen to user profile changes
    _initUserProfileListener();
  }
  final HiveWorkoutDataSource _localDataSource;
  final FirebaseWorkoutDataSource _remoteDataSource;
  final FirebaseAuth _auth;
  final AnalyticsRepository? _analyticsRepository;

  // Cache user profile to avoid frequent reads
  UserProfile? _cachedUserProfile;
  StreamSubscription? _userProfileSubscription;

  // MEMORY LEAK FIX: Disposal flag to prevent operations after dispose
  bool _isDisposed = false;

  // 🔒 RACE CONDITION PROTECTION: Mutex for write operations
  // Prevents concurrent save/update/delete operations that could corrupt data
  final _workoutWriteMutex = MutexWrapper(name: 'WorkoutWrite');

  // 🔄 SYNC QUEUE: Timer and connectivity for background sync
  Timer? _syncQueueTimer;
  Timer? _syncDebounceTimer; // ⚡ PERFORMANCE: Debounce rapid sync calls
  StreamSubscription? _connectivitySubscription;
  bool _isSyncInProgress = false;

  /// Initialize listener for user profile changes
  void _initUserProfileListener() {
    // MEMORY LEAK FIX: Assign subscription to variable for proper cleanup
    _userProfileSubscription = _auth.authStateChanges().listen((user) async {
      if (_isDisposed) return; // Guard against operations after dispose

      if (user != null) {
        await _loadUserProfile(user.uid);
        // Start sync queue processing for authenticated users
        _startSyncQueueProcessing();
      } else {
        _cachedUserProfile = null;
        _stopSyncQueueProcessing();
      }
    });

    // Listen to connectivity changes to trigger sync when back online
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (_isDisposed) return;

      // Check if we have any connectivity
      final hasConnectivity = results.any((r) => r != ConnectivityResult.none);
      if (hasConnectivity && _auth.currentUser != null) {
        if (kDebugMode) {
          debugPrint('🌐 [SyncQueue] Connectivity restored, triggering sync');
        }
        _scheduleSyncQueueProcessing();
      }
    });
  }

  /// Start periodic sync queue processing
  void _startSyncQueueProcessing() {
    _syncQueueTimer?.cancel();
    // Process queue every 2 minutes
    _syncQueueTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _scheduleSyncQueueProcessing();
    });
    // Also process immediately on start
    _scheduleSyncQueueProcessing();
  }

  /// Stop sync queue processing
  void _stopSyncQueueProcessing() {
    _syncQueueTimer?.cancel();
    _syncQueueTimer = null;
  }

  /// Schedule sync queue processing (debounced)
  ///
  /// PERFORMANCE FIX (Jan 2025): Added proper debouncing to coalesce
  /// rapid calls (e.g., auth + connectivity changes at startup).
  void _scheduleSyncQueueProcessing() {
    if (_isDisposed || _isSyncInProgress) return;

    // ⚡ DEBOUNCE: Cancel previous scheduled sync, only run once after 100ms
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (_isDisposed || _isSyncInProgress) return;
      Future(() async {
        await processSyncQueue();
      });
    });
  }

  /// Process pending items in sync queue with exponential backoff
  ///
  /// This method:
  /// 1. Gets items ready for processing (respecting backoff times)
  /// 2. Attempts to sync each item to the cloud
  /// 3. Marks items as completed or failed with backoff
  ///
  /// Returns the number of successfully synced items.
  Future<int> processSyncQueue() async {
    if (_isDisposed) return 0;
    if (_isSyncInProgress) return 0;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return 0;

    // Only premium users or admins can sync
    if (!isPremiumUser && !(await isAdminUser)) return 0;

    // Check connectivity before processing
    if (!(await hasConnection)) {
      if (kDebugMode) {
        debugPrint('📴 [SyncQueue] No connection, skipping sync');
      }
      return 0;
    }

    _isSyncInProgress = true;
    int syncedCount = 0;

    try {
      final pendingItems = await _localDataSource.getSyncQueueForProcessing(
        currentUser.uid,
      );

      if (pendingItems.isEmpty) {
        if (kDebugMode) {
          debugPrint('✅ [SyncQueue] No pending items to sync');
        }
        return 0;
      }

      if (kDebugMode) {
        debugPrint(
          '🔄 [SyncQueue] Processing ${pendingItems.length} pending items',
        );
      }

      for (final item in pendingItems) {
        if (_isDisposed) break;

        try {
          await _processSyncItem(item, currentUser.uid);
          await _localDataSource.markSyncCompleted(item.index);
          await _localDataSource.markWorkoutAsSynced(
            item.workoutId,
            currentUser.uid,
          );
          syncedCount++;

          if (kDebugMode) {
            debugPrint(
              '✅ [SyncQueue] Synced: ${item.operation} ${item.workoutId}',
            );
          }
        } catch (e) {
          await _localDataSource.markSyncFailed(item.index);
          if (kDebugMode) {
            debugPrint(
              '❌ [SyncQueue] Failed: ${item.operation} ${item.workoutId} - $e',
            );
          }
        }
      }

      if (kDebugMode) {
        debugPrint(
          '📊 [SyncQueue] Completed: $syncedCount/${pendingItems.length} items synced',
        );
      }
    } finally {
      _isSyncInProgress = false;
    }

    return syncedCount;
  }

  /// Process a single sync queue item
  Future<void> _processSyncItem(SyncQueueItem item, String userId) async {
    switch (item.operation) {
      case 'create':
      case 'update':
        final workout = await _localDataSource.getWorkout(
          item.workoutId,
          userId,
        );
        if (workout != null) {
          if (item.operation == 'create') {
            await _remoteDataSource.saveWorkout(workout, userId);
          } else {
            await _remoteDataSource.updateWorkout(workout, userId);
          }
        }
        break;

      case 'delete':
        await _remoteDataSource.deleteWorkout(item.workoutId, userId);
        break;
    }
  }

  /// Load user profile from Firestore
  Future<void> _loadUserProfile(String userId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

      final doc = await getCacheFirst(docRef);

      if (doc != null && doc.exists) {
        _cachedUserProfile = UserProfile.fromFirestore(doc);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load user profile: $e');
      }
      // Default to free tier if can't load profile
      _cachedUserProfile = null;
    }
  }

  /// Check if current user is premium
  bool get isPremiumUser {
    return _cachedUserProfile?.accountTier != AccountTier.free;
  }

  /// Check if current user is admin (always has cloud access)
  ///
  /// 🔐 SECURITY: Uses Firebase Custom Claims (server-validated)
  /// REPLACED: email.contains('michele.cozzolino93@gmail.com') || email.contains('admin@') (insecure)
  /// NEW: Async check via AdminRoleHelper.isCurrentUserAdmin()
  Future<bool> get isAdminUser async {
    return await AdminRoleHelper.isCurrentUserAdmin();
  }

  /// Check if we have internet connection
  /// Uses Firestore network state instead of querying a protected document
  Future<bool> get hasConnection async {
    try {
      // Use Firestore's built-in network connectivity check
      // This doesn't require any permission and is more reliable
      await FirebaseFirestore.instance.waitForPendingWrites().timeout(
        const Duration(seconds: 3),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Either<Failure, String>> saveWorkout(Workout workout) async {
    return await _workoutWriteMutex.protect(() async {
      try {
        final currentUser = _auth.currentUser;
        if (currentUser == null) {
          return left(const AuthenticationFailure('User not authenticated'));
        }

        final workoutModel = WorkoutModel.fromDomain(workout);

        // ALWAYS save locally first (instant response)
        final localResult = await _localDataSource.saveWorkout(
          workoutModel,
          currentUser.uid,
        );

        // If premium user or admin, sync to cloud asynchronously
        if (isPremiumUser || await isAdminUser) {
          _syncToCloudInBackground(
            workoutModel: workoutModel,
            userId: currentUser.uid,
            operation: 'save',
          );
        }

        return right(localResult);
      } catch (e) {
        return left(UnexpectedFailure('Failed to save workout: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, void>> updateWorkout(Workout workout) async {
    return await _workoutWriteMutex.protect(() async {
      try {
        final currentUser = _auth.currentUser;
        if (currentUser == null) {
          return left(const AuthenticationFailure('User not authenticated'));
        }

        final workoutModel = WorkoutModel.fromDomain(workout);

        // Update locally first
        await _localDataSource.updateWorkout(workoutModel, currentUser.uid);

        // Update analytics if workout is completed
        if (workout.isCompleted && _analyticsRepository != null) {
          await _updateAnalytics(workout, currentUser.uid);
        }

        // Sync to cloud if premium or admin
        if (isPremiumUser || await isAdminUser) {
          _syncToCloudInBackground(
            workoutModel: workoutModel,
            userId: currentUser.uid,
            operation: 'update',
          );
        }

        return right(null);
      } catch (e) {
        return left(UnexpectedFailure('Failed to update workout: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, Workout>> getWorkout(String workoutId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      // Try local first (fastest)
      final localWorkout = await _localDataSource.getWorkout(
        workoutId,
        currentUser.uid,
      );

      if (localWorkout != null) {
        return right(localWorkout.toDomain());
      }

      // If premium or admin and not found locally, try cloud
      if ((isPremiumUser || await isAdminUser) && await hasConnection) {
        final remoteWorkout = await _remoteDataSource.getWorkout(
          workoutId,
          currentUser.uid,
        );

        if (remoteWorkout != null) {
          // Cache it locally for next time
          await _localDataSource.saveWorkout(remoteWorkout, currentUser.uid);
          return right(remoteWorkout.toDomain());
        }
      }

      return left(const WorkoutNotFoundFailure('Workout not found'));
    } catch (e) {
      return left(UnexpectedFailure('Failed to get workout: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Workout>>> getWorkouts({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      // For admin users, always prioritize cloud data
      if (await isAdminUser && await hasConnection) {
        try {
          // Get cloud workouts directly
          final remoteWorkouts = await _remoteDataSource.getWorkouts(
            currentUser.uid,
            limit: limit,
            startDate: startDate,
            endDate: endDate,
          );

          // Also get local workouts
          final localWorkouts = await _localDataSource.getWorkouts(
            currentUser.uid,
            limit: limit,
            startDate: startDate,
            endDate: endDate,
          );

          // Merge and deduplicate (cloud data takes precedence)
          final mergedWorkouts = _mergeWorkouts(localWorkouts, remoteWorkouts);

          // Update local cache with cloud data
          await _updateLocalCache(remoteWorkouts, currentUser.uid);

          return right(mergedWorkouts.map((m) => m.toDomain()).toList());
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Admin cloud sync failed, trying local: $e');
          }
          // Fall back to local if cloud fails
          final localWorkouts = await _localDataSource.getWorkouts(
            currentUser.uid,
            limit: limit,
            startDate: startDate,
            endDate: endDate,
          );
          return right(localWorkouts.map((m) => m.toDomain()).toList());
        }
      }

      // Get local workouts first for non-admin users
      final localWorkouts = await _localDataSource.getWorkouts(
        currentUser.uid,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

      // If premium, merge with cloud data
      if (isPremiumUser && await hasConnection) {
        try {
          final remoteWorkouts = await _remoteDataSource.getWorkouts(
            currentUser.uid,
            limit: limit,
            startDate: startDate,
            endDate: endDate,
          );

          // Merge and deduplicate
          final mergedWorkouts = _mergeWorkouts(localWorkouts, remoteWorkouts);

          // Update local cache with any new remote workouts
          await _updateLocalCache(mergedWorkouts, currentUser.uid);

          return right(mergedWorkouts.map((m) => m.toDomain()).toList());
        } catch (e) {
          // If cloud sync fails, still return local data
          if (kDebugMode) {
            debugPrint('Cloud sync failed, using local data: $e');
          }
        }
      }

      return right(localWorkouts.map((m) => m.toDomain()).toList());
    } catch (e) {
      return left(UnexpectedFailure('Failed to get workouts: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWorkout(String workoutId) async {
    return await _workoutWriteMutex.protect(() async {
      try {
        final currentUser = _auth.currentUser;
        if (currentUser == null) {
          return left(const AuthenticationFailure('User not authenticated'));
        }

        // Delete locally first
        await _localDataSource.deleteWorkout(workoutId, currentUser.uid);

        // Delete from cloud if premium
        if (isPremiumUser) {
          _deleteFromCloudInBackground(
            workoutId: workoutId,
            userId: currentUser.uid,
          );
        }

        return right(null);
      } catch (e) {
        return left(UnexpectedFailure('Failed to delete workout: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, List<String>>> saveCompletedWorkout({
    required Workout workout,
    required String userEmail,
  }) async {
    return await _workoutWriteMutex.protect(() async {
      try {
        final currentUser = _auth.currentUser;
        if (currentUser == null) {
          return left(const AuthenticationFailure('User not authenticated'));
        }

        // Save workout to local Hive box for history
        await _localDataSource.saveWorkout(
          WorkoutModel.fromDomain(workout),
          currentUser.uid,
        );

        // NOTE: Exercise activities are now tracked via unified workout storage
        // Analytics read directly from workouts collection
        final activityIds = <String>[];

        return right(activityIds);
      } catch (e) {
        return left(UnexpectedFailure('Failed to save completed workout: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, WorkoutStats>> getWorkoutStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      // Get stats from local data (always available)
      final stats = await _localDataSource.getWorkoutStats(
        currentUser.uid,
        startDate: startDate,
        endDate: endDate,
      );

      return right(stats);
    } catch (e) {
      return left(UnexpectedFailure('Failed to get workout stats: $e'));
    }
  }

  @override
  Stream<Either<Failure, Workout?>> watchActiveWorkout() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(
        left(const AuthenticationFailure('User not authenticated')),
      );
    }

    // For now, poll local storage
    // In future, can implement proper stream with Hive listeners
    return Stream.periodic(const Duration(seconds: 1)).asyncMap((_) async {
      try {
        final workout = await _localDataSource.getActiveWorkout(
          currentUser.uid,
        );
        return right(workout?.toDomain());
      } catch (e) {
        return left(UnexpectedFailure('Failed to watch active workout: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, WorkoutHistory>> getWorkoutHistory({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      final history = await _localDataSource.getWorkoutHistory(
        currentUser.uid,
        page: page,
        limit: limit,
      );

      return right(history);
    } catch (e) {
      return left(UnexpectedFailure('Failed to get workout history: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateExerciseSet({
    required String workoutId,
    required String exerciseId,
    required ExerciseSet exerciseSet,
  }) async {
    return await _workoutWriteMutex.protect(() async {
      try {
        final currentUser = _auth.currentUser;
        if (currentUser == null) {
          return left(const AuthenticationFailure('User not authenticated'));
        }

        // Get workout from local storage
        final workout = await _localDataSource.getWorkout(
          workoutId,
          currentUser.uid,
        );
        if (workout == null) {
          return left(const WorkoutNotFoundFailure('Workout not found'));
        }

        // Update the exercise set in the workout
        final updatedExercises = workout.exercises.map((exercise) {
          if (exercise.id == exerciseId) {
            final updatedSets = exercise.sets.map((set) {
              if (set.id == exerciseSet.id) {
                return ExerciseSetModel.fromDomain(exerciseSet);
              }
              return set;
            }).toList();

            return exercise.copyWith(sets: updatedSets);
          }
          return exercise;
        }).toList();

        final updatedWorkout = workout.copyWith(exercises: updatedExercises);

        // Save updated workout locally
        await _localDataSource.updateWorkout(updatedWorkout, currentUser.uid);

        // Sync to cloud if premium
        if (isPremiumUser) {
          _updateExerciseSetInCloudBackground(
            workoutId: workoutId,
            exerciseId: exerciseId,
            exerciseSet: exerciseSet,
            userId: currentUser.uid,
          );
        }

        return right(null);
      } catch (e) {
        return left(UnexpectedFailure('Failed to update exercise set: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, void>> addExerciseToWorkout({
    required String workoutId,
    required Exercise exercise,
  }) async {
    return await _workoutWriteMutex.protect(() async {
      try {
        final currentUser = _auth.currentUser;
        if (currentUser == null) {
          return left(const AuthenticationFailure('User not authenticated'));
        }

        // Get workout from local storage
        final workout = await _localDataSource.getWorkout(
          workoutId,
          currentUser.uid,
        );
        if (workout == null) {
          return left(const WorkoutNotFoundFailure('Workout not found'));
        }

        // Add exercise to workout
        final exerciseModel = ExerciseModel.fromDomain(exercise);
        final updatedExercises = [...workout.exercises, exerciseModel];
        final updatedWorkout = workout.copyWith(exercises: updatedExercises);

        // Save updated workout locally
        await _localDataSource.updateWorkout(updatedWorkout, currentUser.uid);

        // Sync to cloud if premium
        if (isPremiumUser) {
          _addExerciseToCloudBackground(
            workoutId: workoutId,
            exercise: exercise,
            userId: currentUser.uid,
          );
        }

        return right(null);
      } catch (e) {
        return left(UnexpectedFailure('Failed to add exercise to workout: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, void>> removeExerciseFromWorkout({
    required String workoutId,
    required String exerciseId,
  }) async {
    return await _workoutWriteMutex.protect(() async {
      try {
        final currentUser = _auth.currentUser;
        if (currentUser == null) {
          return left(const AuthenticationFailure('User not authenticated'));
        }

        // Get workout from local storage
        final workout = await _localDataSource.getWorkout(
          workoutId,
          currentUser.uid,
        );
        if (workout == null) {
          return left(const WorkoutNotFoundFailure('Workout not found'));
        }

        // Remove exercise from workout
        final updatedExercises = workout.exercises
            .where((e) => e.id != exerciseId)
            .toList();
        final updatedWorkout = workout.copyWith(exercises: updatedExercises);

        // Save updated workout locally
        await _localDataSource.updateWorkout(updatedWorkout, currentUser.uid);

        // Sync to cloud if premium
        if (isPremiumUser) {
          _removeExerciseFromCloudBackground(
            workoutId: workoutId,
            exerciseId: exerciseId,
            userId: currentUser.uid,
          );
        }

        return right(null);
      } catch (e) {
        return left(
          UnexpectedFailure('Failed to remove exercise from workout: $e'),
        );
      }
    });
  }

  /// Merge local and remote workouts, handling conflicts
  List<WorkoutModel> _mergeWorkouts(
    List<WorkoutModel> localWorkouts,
    List<WorkoutModel> remoteWorkouts,
  ) {
    final merged = <String, WorkoutModel>{};

    // Add all local workouts
    for (final workout in localWorkouts) {
      merged[workout.id] = workout;
    }

    // Merge remote workouts (remote wins in case of conflict for now)
    for (final workout in remoteWorkouts) {
      final localVersion = merged[workout.id];
      if (localVersion == null) {
        // New workout from cloud
        merged[workout.id] = workout;
      } else {
        // Conflict resolution: take the most recently updated
        // Compare updatedAt timestamps
        if (workout.updatedAt.isAfter(localVersion.updatedAt)) {
          merged[workout.id] = workout;
        }
      }
    }

    return merged.values.toList();
  }

  /// ⚡ OPTIMIZED: Update local cache with new workouts
  /// Only saves if workout is new or has been updated (checks updatedAt timestamp)
  ///
  /// PERFORMANCE FIX (Jan 2025): Now uses batch operations instead of per-workout
  /// openBox() calls. Reduced from ~N openBox() calls to just 1-2.
  Future<void> _updateLocalCache(
    List<WorkoutModel> workouts,
    String userId,
  ) async {
    if (workouts.isEmpty) return;

    // ⚡ BATCH: Get all existing timestamps in ONE operation (1 openBox call)
    final existingTimestamps = await _localDataSource
        .getExistingWorkoutTimestamps(userId);

    // Separate workouts into new/updated vs unchanged
    final workoutsToSave = <WorkoutModel>[];
    int skippedCount = 0;

    for (final workout in workouts) {
      final existingTime = existingTimestamps[workout.id];

      if (existingTime == null) {
        // New workout
        workoutsToSave.add(workout);
      } else if (workout.updatedAt.isAfter(existingTime)) {
        // Updated workout
        workoutsToSave.add(workout);
      } else {
        // Already up-to-date - skip
        skippedCount++;
      }
    }

    // ⚡ BATCH: Save all changed workouts in ONE operation
    if (workoutsToSave.isNotEmpty) {
      await _localDataSource.batchSaveWorkouts(workoutsToSave, userId);
    }

    if (kDebugMode) {
      debugPrint(
        '⚡ [CACHE] Batch update: ${workoutsToSave.length} saved, $skippedCount skipped',
      );
    }
  }

  /// Sync to cloud in background using the sync queue
  ///
  /// ✅ FIXED: Now uses persistent sync queue instead of fire-and-forget.
  /// Items are already added to queue by HiveWorkoutDataSource.saveWorkout/updateWorkout.
  /// This method just triggers queue processing.
  void _syncToCloudInBackground({
    required WorkoutModel workoutModel,
    required String userId,
    required String operation,
  }) {
    // Schedule queue processing - items are already in queue from datasource
    _scheduleSyncQueueProcessing();

    if (kDebugMode) {
      debugPrint(
        '📤 [SyncQueue] Scheduled sync for $operation: ${workoutModel.id}',
      );
    }
  }

  /// Delete from cloud in background using the sync queue
  ///
  /// ✅ FIXED: Now uses persistent sync queue instead of fire-and-forget.
  /// Items are already added to queue by HiveWorkoutDataSource.deleteWorkout.
  /// This method just triggers queue processing.
  void _deleteFromCloudInBackground({
    required String workoutId,
    required String userId,
  }) {
    // Schedule queue processing - items are already in queue from datasource
    _scheduleSyncQueueProcessing();

    if (kDebugMode) {
      debugPrint('📤 [SyncQueue] Scheduled sync for delete: $workoutId');
    }
  }

  /// Update exercise set in cloud in background
  void _updateExerciseSetInCloudBackground({
    required String workoutId,
    required String exerciseId,
    required ExerciseSet exerciseSet,
    required String userId,
  }) {
    Future(() async {
      try {
        if (await hasConnection) {
          await _remoteDataSource.updateExerciseSet(
            workoutId,
            exerciseId,
            exerciseSet,
            userId,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Background cloud update exercise set failed: $e');
        }
      }
    });
  }

  /// Add exercise to cloud in background
  void _addExerciseToCloudBackground({
    required String workoutId,
    required Exercise exercise,
    required String userId,
  }) {
    Future(() async {
      try {
        if (await hasConnection) {
          await _remoteDataSource.addExerciseToWorkout(
            workoutId,
            exercise,
            userId,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Background cloud add exercise failed: $e');
        }
      }
    });
  }

  /// Remove exercise from cloud in background
  void _removeExerciseFromCloudBackground({
    required String workoutId,
    required String exerciseId,
    required String userId,
  }) {
    Future(() async {
      try {
        if (await hasConnection) {
          await _remoteDataSource.removeExerciseFromWorkout(
            workoutId,
            exerciseId,
            userId,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Background cloud remove exercise failed: $e');
        }
      }
    });
  }

  @override
  Future<Workout?> getLastCompletedWorkout(String userId) async {
    if (_isDisposed) return null;

    try {
      final workoutModel = await _localDataSource.getLastCompletedWorkout(
        userId,
      );
      return workoutModel?.toDomain(); // Convert WorkoutModel to Workout
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [HybridWorkoutRepository] getLastCompletedWorkout error: $e',
        );
      }
      return null; // Graceful fallback
    }
  }

  /// Update analytics for completed workout
  ///
  /// **Purpose**: Write-through strategy - update analytics collection when workout completes
  ///
  /// **Logic**:
  /// 1. Extract all completed exercises
  /// 2. Filter sets with valid weight/reps
  /// 3. Create ExerciseSession for each exercise
  /// 4. Update analytics collection via repository
  Future<void> _updateAnalytics(Workout workout, String userId) async {
    try {
      // Extract session date (use workout startTime or createdAt)
      final sessionDate = workout.startTime ?? workout.createdAt;

      // Process each exercise
      for (final exercise in workout.exercises) {
        // Filter completed sets with valid data
        final completedSets = exercise.sets
            .where(
              (set) =>
                  set.isCompleted &&
                  set.weight != null &&
                  set.weight! > 0 &&
                  (set.actualReps ?? set.reps) != null &&
                  (set.actualReps ?? set.reps)! > 0,
            )
            .toList();

        // Skip exercises with no valid sets
        if (completedSets.isEmpty) continue;

        // Convert to AnalyticsSets
        final analyticsSets = completedSets.map((set) {
          return AnalyticsSet(
            weight: set.weight!,
            reps: set.actualReps ?? set.reps!,
            date: set.completedAt ?? sessionDate,
          );
        }).toList();

        // Create ExerciseSession
        final session = ExerciseSession(
          exerciseName: exercise.name,
          muscleGroup: exercise.category.name, // Enum name matches string
          sets: analyticsSets,
          date: sessionDate,
        );

        // Update analytics with error tracking
        // NOTE: Using unawaited but with proper error handling
        debugPrint(
          '📊 [ANALYTICS_SYNC] Syncing "${exercise.name}" - ${analyticsSets.length} sets, '
          'max ${session.maxWeight}kg, est1RM ${session.highestEstimated1RM.toStringAsFixed(1)}kg',
        );

        unawaited(
          _analyticsRepository!
              .updateExerciseHistory(
                userId: userId,
                exerciseId: exercise.id,
                exerciseName: exercise.name,
                muscleGroup: exercise.category.name,
                session: session,
              )
              .then((result) {
            result.fold(
              (failure) {
                // LOG FAILURE - This is critical for debugging sync issues!
                debugPrint(
                  '❌ [ANALYTICS_SYNC] FAILED to sync "${exercise.name}": ${failure.message}',
                );
              },
              (_) {
                debugPrint(
                  '✅ [ANALYTICS_SYNC] Synced "${exercise.name}" successfully',
                );
              },
            );
          }).catchError((Object error, StackTrace stackTrace) {
            // Catch any unhandled errors
            debugPrint(
              '❌ [ANALYTICS_SYNC] Exception syncing "${exercise.name}": $error',
            );
            debugPrint('   Stack: $stackTrace');
          }),
        );
      }

      debugPrint(
        '📊 [ANALYTICS_SYNC] Initiated sync for ${workout.exercises.length} exercises from workout "${workout.name}"',
      );
    } catch (e, stackTrace) {
      // Log error but don't fail workout save
      debugPrint(
        '❌ [ANALYTICS_SYNC] Failed to process workout for analytics: $e',
      );
      debugPrint('   Stack: $stackTrace');
    }
  }

  /// Dispose of resources
  /// MEMORY LEAK FIX: Properly cancel stream subscription
  void dispose() {
    // 1. CRITICAL: Set disposed flag first to prevent operations after dispose
    _isDisposed = true;

    // 2. Cancel auth state changes subscription
    _userProfileSubscription?.cancel();
    _userProfileSubscription = null;

    // 3. Cancel sync queue timer and debounce timer
    _syncQueueTimer?.cancel();
    _syncQueueTimer = null;
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = null;

    // 4. Cancel connectivity subscription
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    // 5. Clear cached user profile
    _cachedUserProfile = null;

    if (kDebugMode) {
      debugPrint('✅ HybridWorkoutRepositoryImpl disposed');
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<Workout>>> getWorkoutsPaginated({
    int pageSize = 20,
    DocumentSnapshot? startAfter,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      final userId = currentUser.uid;

      if (kDebugMode) {
        debugPrint(
          '📖 [HybridRepo] getWorkoutsPaginated - pageSize: $pageSize',
        );
      }
      if (kDebugMode) {
        debugPrint(
          '📖 [HybridRepo] Cursor: ${startAfter?.id ?? "null (first page)"}',
        );
      }

      // For admin users, prioritize cloud data for consistency
      if (await isAdminUser && await hasConnection) {
        return await _getPaginatedFromCloud(
          userId: userId,
          pageSize: pageSize,
          startAfter: startAfter,
          dateFrom: dateFrom,
          dateTo: dateTo,
          status: status,
        );
      }

      // For premium users with connection, merge local + cloud
      if (isPremiumUser && await hasConnection) {
        return await _getPaginatedMerged(
          userId: userId,
          pageSize: pageSize,
          startAfter: startAfter,
          dateFrom: dateFrom,
          dateTo: dateTo,
          status: status,
        );
      }

      // Default: use local storage only (free users or offline)
      return await _getPaginatedFromLocal(
        userId: userId,
        pageSize: pageSize,
        startAfter: startAfter,
        dateFrom: dateFrom,
        dateTo: dateTo,
        status: status,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HybridRepo] getWorkoutsPaginated error: $e');
      }
      return left(UnexpectedFailure('Failed to get paginated workouts: $e'));
    }
  }

  /// Get paginated workouts from cloud (Firestore)
  Future<Either<Failure, PaginatedResult<Workout>>> _getPaginatedFromCloud({
    required String userId,
    required int pageSize,
    DocumentSnapshot? startAfter,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
  }) async {
    try {
      final result = await _remoteDataSource.getWorkoutsPaginated(
        userId,
        pageSize: pageSize,
        startAfter: startAfter,
        dateFrom: dateFrom,
        dateTo: dateTo,
        status: status,
      );

      // Convert WorkoutModel to Workout domain entities
      final workouts = result.items.map((model) => model.toDomain()).toList();

      // Cache fetched workouts locally (background, non-blocking)
      _cacheWorkoutsInBackground(result.items, userId);

      return right(
        PaginatedResult<Workout>(
          items: workouts,
          hasMore: result.hasMore,
          lastDocument: result.lastDocument,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [HybridRepo] Cloud pagination failed, falling back to local: $e',
        );
      }
      // Fallback to local on cloud failure
      return await _getPaginatedFromLocal(
        userId: userId,
        pageSize: pageSize,
        startAfter: startAfter,
        dateFrom: dateFrom,
        dateTo: dateTo,
        status: status,
      );
    }
  }

  /// Get paginated workouts from local storage (Hive)
  Future<Either<Failure, PaginatedResult<Workout>>> _getPaginatedFromLocal({
    required String userId,
    required int pageSize,
    DocumentSnapshot? startAfter,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
  }) async {
    // For Hive, we use the last workout ID as cursor (not DocumentSnapshot)
    // Extract lastWorkoutId from previous result if available
    String? lastWorkoutId;

    // If startAfter is provided but we're using local, we need to find the matching workout ID
    // This happens when switching from cloud to local pagination mid-session
    if (startAfter != null) {
      // Try to get the workout ID from the document
      try {
        final data = startAfter.data() as Map<String, dynamic>?;
        lastWorkoutId = data?['id'] as String?;
      } catch (_) {
        // If we can't extract ID, start from beginning
        lastWorkoutId = null;
      }
    }

    final result = await _localDataSource.getWorkoutsPaginated(
      userId,
      pageSize: pageSize,
      lastWorkoutId: lastWorkoutId,
      dateFrom: dateFrom,
      dateTo: dateTo,
      status: status,
    );

    // Convert WorkoutModel to Workout domain entities
    final workouts = result.items.map((model) => model.toDomain()).toList();

    return right(
      PaginatedResult<Workout>(
        items: workouts,
        hasMore: result.hasMore,
        lastDocument: null, // Local doesn't use DocumentSnapshot cursor
      ),
    );
  }

  /// Get paginated workouts merged from local + cloud (premium users)
  Future<Either<Failure, PaginatedResult<Workout>>> _getPaginatedMerged({
    required String userId,
    required int pageSize,
    DocumentSnapshot? startAfter,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
  }) async {
    try {
      // Fetch from cloud (source of truth for premium)
      final cloudResult = await _remoteDataSource.getWorkoutsPaginated(
        userId,
        pageSize: pageSize,
        startAfter: startAfter,
        dateFrom: dateFrom,
        dateTo: dateTo,
        status: status,
      );

      // Also fetch local unsynced workouts (may have workouts not yet synced)
      final localResult = await _localDataSource.getWorkoutsPaginated(
        userId,
        pageSize: pageSize,
        dateFrom: dateFrom,
        dateTo: dateTo,
        status: status,
      );

      // Merge results - cloud data takes precedence for synced items
      final mergedModels = _mergeWorkouts(localResult.items, cloudResult.items);

      // Sort merged results by date (newest first)
      mergedModels.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Take only pageSize items
      final trimmedModels = mergedModels.take(pageSize).toList();

      // Convert to domain entities
      final workouts = trimmedModels.map((model) => model.toDomain()).toList();

      // Cache cloud workouts locally
      _cacheWorkoutsInBackground(cloudResult.items, userId);

      return right(
        PaginatedResult<Workout>(
          items: workouts,
          hasMore: cloudResult.hasMore || localResult.hasMore,
          lastDocument: cloudResult.lastDocument,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [HybridRepo] Merged pagination failed: $e');
      }
      // Fallback to local only
      return await _getPaginatedFromLocal(
        userId: userId,
        pageSize: pageSize,
        startAfter: startAfter,
        dateFrom: dateFrom,
        dateTo: dateTo,
        status: status,
      );
    }
  }

  /// Cache workouts locally in background (fire and forget)
  ///
  /// PERFORMANCE FIX (Jan 2025): Now uses batchSaveWorkouts() instead of
  /// individual saveWorkout() calls. Reduced from N openBox() calls to 1.
  void _cacheWorkoutsInBackground(List<WorkoutModel> workouts, String userId) {
    if (workouts.isEmpty) return;

    Future(() async {
      try {
        // ⚡ BATCH: Save all workouts in ONE operation
        await _localDataSource.batchSaveWorkouts(workouts, userId);
        if (kDebugMode) {
          debugPrint(
            '✅ [HybridRepo] Batch cached ${workouts.length} workouts locally',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ [HybridRepo] Background cache failed: $e');
        }
      }
    });
  }
}
