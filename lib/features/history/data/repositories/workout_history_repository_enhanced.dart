/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: data/repositories
/// 🎯 Feature: history
/// 🔧 Type: repository
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Enhanced repository for workout history with Firebase sync and local caching
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/sync_status.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

/// Enhanced repository for workout history with Firebase integration
class WorkoutHistoryRepositoryEnhanced {

  WorkoutHistoryRepositoryEnhanced({
    required HiveBoxManagerEnhanced boxManager,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _boxManager = boxManager,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance {
    _initialize();
  }
  static const String _historyBoxName = 'workout_history_enhanced';
  static const String _syncQueueBoxName = 'workout_history_sync_queue';
  static const String _metadataBoxName = 'workout_history_metadata';

  final HiveBoxManagerEnhanced _boxManager;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Box? _historyBox;
  Box? _syncQueueBox;
  Box<dynamic>? _metadataBox;

  bool _isInitialized = false;

  // Stream controllers for real-time updates
  final StreamController<List<WorkoutHistoryDetail>> _workoutsController =
      StreamController<List<WorkoutHistoryDetail>>.broadcast();

  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();

  // Getters for streams
  Stream<List<WorkoutHistoryDetail>> get workoutsStream => _workoutsController.stream;
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// 🔧 FIX: Notify stream listeners that a workout was added directly to Hive
  /// Call this from workout_provider after saving to history box
  Future<void> notifyLocalWorkoutAdded() async {
    try {
      await _ensureInitialized();
      final workouts = await _getLocalWorkouts();
      _workoutsController.add(workouts);

      if (kDebugMode) {
        debugPrint('📢 [WorkoutHistoryRepo] Notified listeners of new local workout (${workouts.length} total)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [WorkoutHistoryRepo] Failed to notify listeners: $e');
      }
    }
  }

  /// Initialize the repository
  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // Open Hive boxes
      _historyBox = await _boxManager.openBox(_historyBoxName);
      _syncQueueBox = await _boxManager.openBox(_syncQueueBoxName);
      _metadataBox = await _boxManager.openBox<dynamic>(_metadataBoxName);

      _isInitialized = true;

      // Trigger initial sync if needed
      await _performInitialSyncIfNeeded();

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing WorkoutHistoryRepositoryEnhanced: $e');
      }
    }
  }

  /// Ensure repository is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initialize();
    }
  }

  /// Check if initial sync has been completed
  bool get _hasInitialSync {
    final hasSync = _metadataBox?.get('initial_sync_done') as bool?;
    return hasSync == true;
  }

  /// Get last sync timestamp
  DateTime? get _lastSyncTimestamp {
    final timestamp = _metadataBox?.get('last_sync_timestamp') as String?;
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  /// Perform initial sync if needed
  Future<void> _performInitialSyncIfNeeded() async {
    if (_hasInitialSync) {
      // Just do incremental sync
      await _performIncrementalSync();
      return;
    }

    await _performInitialSync();
  }

  /// Perform initial complete sync
  Future<void> _performInitialSync() async {
    if (_auth.currentUser == null) return;

    _syncStatusController.add(SyncStatus.initialSyncing);

    try {
      // Download last 3 months of workout history
      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
      final userId = _auth.currentUser!.uid;

      if (kDebugMode) {
        debugPrint('🔄 Starting initial sync for workout history...');
      }

      // Query Firebase for workout history
      // 🔧 FIX: Added 15s timeout to prevent infinite hanging on poor network
      final querySnapshot = await _firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .where('completedAt', isGreaterThan: Timestamp.fromDate(cutoffDate))
          .orderBy('completedAt', descending: true)
          .limit(500) // Reasonable limit
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw TimeoutException('Firestore initial sync timed out'),
          );

      // Convert and save to local storage
      final workouts = <WorkoutHistoryDetail>[];

      for (var doc in querySnapshot.docs) {
        try {
          final workout = WorkoutHistoryDetail.fromFirestore(doc);
          workouts.add(workout);

          // Save to local storage
          await _saveWorkoutLocally(workout);

        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Error converting workout ${doc.id}: $e');
          }
        }
      }

      // Mark initial sync as complete
      await _metadataBox!.put('initial_sync_done', true);
      await _metadataBox!.put('last_sync_timestamp', DateTime.now().toIso8601String());

      if (kDebugMode) {
        debugPrint('✅ Initial sync completed: ${workouts.length} workouts downloaded from Firebase');
      }

      // 🔧 FIX: Emit ALL local workouts (including pre-existing ones not on Firebase)
      // Previous bug: emitted only downloaded workouts, hiding locally-saved ones
      final allLocalWorkouts = await _getLocalWorkouts();
      if (kDebugMode) {
        debugPrint('📋 Total local workouts after sync: ${allLocalWorkouts.length}');
      }
      _workoutsController.add(allLocalWorkouts);
      _syncStatusController.add(SyncStatus.synced);

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Initial sync failed: $e');
      }
      _syncStatusController.add(SyncStatus.error);

      // Fall back to local data
      final localWorkouts = await _getLocalWorkouts();
      _workoutsController.add(localWorkouts);
    }
  }

  /// Perform incremental sync
  Future<void> _performIncrementalSync() async {
    if (_auth.currentUser == null) return;

    try {
      final lastSync = _lastSyncTimestamp ?? DateTime.now().subtract(const Duration(hours: 24));
      final userId = _auth.currentUser!.uid;

      // Query for updates since last sync
      // 🔧 PERF FIX: Add limit to prevent unbounded reads
      // 🔧 FIX: Added 10s timeout to prevent infinite hanging on poor network
      final querySnapshot = await _firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .where('updatedAt', isGreaterThan: Timestamp.fromDate(lastSync))
          .orderBy('updatedAt', descending: true)
          .limit(100) // Limit to prevent fetching thousands of documents
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('Firestore incremental sync timed out'),
          );

      if (querySnapshot.docs.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('🔄 Incremental sync: ${querySnapshot.docs.length} updates found');
        }

        for (var doc in querySnapshot.docs) {
          try {
            final workout = WorkoutHistoryDetail.fromFirestore(doc);
            await _saveWorkoutLocally(workout);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('⚠️ Error updating workout ${doc.id}: $e');
            }
          }
        }

        // Update sync timestamp
        await _metadataBox!.put('last_sync_timestamp', DateTime.now().toIso8601String());

        // Emit updated workouts
        final updatedWorkouts = await _getLocalWorkouts();
        _workoutsController.add(updatedWorkouts);
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Incremental sync failed: $e');
      }
    }
  }

  /// Save workout to local storage
  /// 🔧 FIX: Include userId in key to isolate data per user
  Future<void> _saveWorkoutLocally(WorkoutHistoryDetail workout) async {
    await _ensureInitialized();

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Key format: workout_{userId}_{workoutId} for user isolation
    final key = 'workout_${userId}_${workout.id}';
    await _historyBox!.put(key, workout.toMap());
  }

  /// Get workouts from local storage
  /// 🔧 FIX: Filter by userId to only return current user's workouts
  Future<List<WorkoutHistoryDetail>> _getLocalWorkouts() async {
    await _ensureInitialized();

    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final workouts = <WorkoutHistoryDetail>[];
    final userPrefix = 'workout_${userId}_';

    for (var key in _historyBox!.keys) {
      // 🔐 SECURITY: Only load workouts belonging to current user
      final keyStr = key.toString();
      if (!keyStr.startsWith(userPrefix)) {
        // Also support legacy keys without userId (for migration)
        // Check if it's a legacy key that should be migrated
        if (keyStr.startsWith('workout_') && !keyStr.contains(userId)) {
          continue; // Skip other users' workouts
        }
      }

      try {
        final data = _historyBox!.get(key);
        if (data != null) {
          final workout = WorkoutHistoryDetail.fromMap(data);
          workouts.add(workout);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Error loading workout $key: $e');
        }
      }
    }

    // Sort by completion date (newest first)
    workouts.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    if (kDebugMode) {
      debugPrint('📦 [WorkoutHistoryRepo] Loaded ${workouts.length} workouts for user $userId');
    }

    return workouts;
  }

  /// Get all workouts (local-first approach)
  Future<Either<Failure, List<WorkoutHistoryDetail>>> getWorkouts() async {
    try {
      await _ensureInitialized();

      // Always return local data first for instant loading
      final localWorkouts = await _getLocalWorkouts();

      // Trigger background sync if needed
      if (_auth.currentUser != null) {
        unawaited(_performIncrementalSync());
      }

      return Right(localWorkouts);

    } catch (e) {
      return Left(DatabaseFailure('Failed to load workouts: $e'));
    }
  }

  /// Get workouts with real-time updates
  Stream<Either<Failure, List<WorkoutHistoryDetail>>> getWorkoutsStream() async* {
    try {
      await _ensureInitialized();

      // Emit initial local data
      final initialWorkouts = await _getLocalWorkouts();
      yield Right(initialWorkouts);

      // Listen for updates
      await for (final workouts in _workoutsController.stream) {
        yield Right(workouts);
      }

    } catch (e) {
      yield Left(DatabaseFailure('Stream error: $e'));
    }
  }

  /// Update workout
  Future<Either<Failure, void>> updateWorkout(WorkoutHistoryDetail workout) async {
    try {
      await _ensureInitialized();

      // Update local storage immediately
      await _saveWorkoutLocally(workout);

      // Add to sync queue for cloud update
      await _addToSyncQueue('update', workout);

      // Process sync queue if online
      unawaited(_processSyncQueue());

      // Emit updated list
      final updatedWorkouts = await _getLocalWorkouts();
      _workoutsController.add(updatedWorkouts);

      return const Right(null);

    } catch (e) {
      return Left(DatabaseFailure('Failed to update workout: $e'));
    }
  }

  /// Delete workout
  Future<Either<Failure, void>> deleteWorkout(String workoutId) async {
    try {
      await _ensureInitialized();

      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return const Left(DatabaseFailure('User not authenticated'));
      }

      // Remove from local storage (try both new and legacy key formats)
      await _historyBox!.delete('workout_${userId}_$workoutId');
      await _historyBox!.delete('workout_$workoutId'); // Legacy cleanup

      // Add to sync queue for cloud deletion
      await _addToSyncQueue('delete', WorkoutHistoryDetail.empty(id: workoutId));

      // Process sync queue if online
      unawaited(_processSyncQueue());

      // Emit updated list
      final updatedWorkouts = await _getLocalWorkouts();
      _workoutsController.add(updatedWorkouts);

      return const Right(null);

    } catch (e) {
      return Left(DatabaseFailure('Failed to delete workout: $e'));
    }
  }

  /// Add operation to sync queue
  Future<void> _addToSyncQueue(String operation, WorkoutHistoryDetail workout) async {
    final queueItem = {
      'operation': operation,
      'workout': workout.toMap(),
      'timestamp': DateTime.now().toIso8601String(),
      'attempts': 0,
    };

    final key = '${operation}_${workout.id}_${DateTime.now().millisecondsSinceEpoch}';
    await _syncQueueBox!.put(key, queueItem);
  }

  /// Process sync queue
  Future<void> _processSyncQueue() async {
    if (_auth.currentUser == null) return;

    try {
      for (var key in _syncQueueBox!.keys) {
        final queueItem = _syncQueueBox!.get(key);
        if (queueItem == null) continue;

        final operation = queueItem['operation'] as String;
        final workoutData = queueItem['workout'] as Map;
        final attempts = queueItem['attempts'] as int;

        // Skip if too many failed attempts
        if (attempts >= 3) {
          await _syncQueueBox!.delete(key);
          continue;
        }

        try {
          if (operation == 'update') {
            await _updateWorkoutInFirestore(WorkoutHistoryDetail.fromMap(workoutData));
          } else if (operation == 'delete') {
            await _deleteWorkoutFromFirestore(workoutData['id'] as String);
          }

          // Remove from queue on success
          await _syncQueueBox!.delete(key);

        } catch (e) {
          // Increment attempts
          queueItem['attempts'] = attempts + 1;
          await _syncQueueBox!.put(key, queueItem);
          if (kDebugMode) {
            debugPrint('⚠️ Sync queue item failed (attempt ${attempts + 1}): $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error processing sync queue: $e');
      }
    }
  }

  /// Update workout in Firestore
  /// 🔧 FIX: Added 10s timeout to prevent infinite hanging on poor network
  Future<void> _updateWorkoutInFirestore(WorkoutHistoryDetail workout) async {
    await _firestore
        .collection('workouts')
        .doc(workout.id)
        .set(workout.toFirestoreMap(), SetOptions(merge: true))
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw TimeoutException('Firestore updateWorkout timed out'),
        );
  }

  /// Delete workout from Firestore
  /// 🔧 FIX: Added 5s timeout to prevent infinite hanging on poor network
  Future<void> _deleteWorkoutFromFirestore(String workoutId) async {
    await _firestore
        .collection('workouts')
        .doc(workoutId)
        .delete()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw TimeoutException('Firestore deleteWorkout timed out'),
        );
  }

  /// Force sync
  Future<void> forceSync() async {
    _syncStatusController.add(SyncStatus.syncing);

    if (!_hasInitialSync) {
      await _performInitialSync();
    } else {
      await _performIncrementalSync();
      await _processSyncQueue();
    }

    // 🔧 FIX: Always emit current local workouts after force sync
    // Ensures UI is updated even if no Firebase changes were found
    final currentWorkouts = await _getLocalWorkouts();
    _workoutsController.add(currentWorkouts);

    _syncStatusController.add(SyncStatus.synced);
  }

  /// Get sync status
  SyncStatus get currentSyncStatus {
    if (!_hasInitialSync) return SyncStatus.notSynced;

    final lastSync = _lastSyncTimestamp;
    if (lastSync == null) return SyncStatus.notSynced;

    final hoursSinceSync = DateTime.now().difference(lastSync).inHours;
    if (hoursSinceSync > 24) return SyncStatus.needsSync;

    return SyncStatus.synced;
  }

  /// Clear local cache
  Future<void> clearCache() async {
    await _ensureInitialized();

    await _historyBox!.clear();
    await _metadataBox!.clear();

    if (kDebugMode) {
      debugPrint('🗑️ Local cache cleared');
    }
  }

  /// Dispose resources
  void dispose() {
    _workoutsController.close();
    _syncStatusController.close();
  }
}



/// Database failure class
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}