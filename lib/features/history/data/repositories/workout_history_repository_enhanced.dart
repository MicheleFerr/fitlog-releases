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
import 'package:gymbro_flutter_new/features/premium/data/services/premium_entitlement_store.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/shared/auth/entities/user_profile.dart';

/// Enhanced repository for workout history with Firebase integration
class WorkoutHistoryRepositoryEnhanced {
  WorkoutHistoryRepositoryEnhanced({
    required HiveBoxManagerEnhanced boxManager,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    PremiumEntitlementStore? entitlementStore,
    bool enableRemoteSync = true,
  }) : _boxManager = boxManager,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _entitlementStore =
           entitlementStore ??
           PremiumEntitlementStore(
             firestore: firestore ?? FirebaseFirestore.instance,
           ),
       _enableRemoteSync = enableRemoteSync {
    _initialize();
  }
  static const String _historyBoxName = 'workout_history_enhanced';
  static const String _syncQueueBoxName = 'workout_history_sync_queue';
  static const String _metadataBoxName = 'workout_history_metadata';

  final HiveBoxManagerEnhanced _boxManager;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final PremiumEntitlementStore _entitlementStore;
  final bool _enableRemoteSync;

  Box? _historyBox;
  Box? _syncQueueBox;
  Box<dynamic>? _metadataBox;

  bool _isInitialized = false;
  Completer<void>? _initCompleter;

  // Stream controllers for real-time updates
  final StreamController<List<WorkoutHistoryDetail>> _workoutsController =
      StreamController<List<WorkoutHistoryDetail>>.broadcast();

  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();

  // Getters for streams
  Stream<List<WorkoutHistoryDetail>> get workoutsStream =>
      _workoutsController.stream;
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// 🔧 FIX: Notify stream listeners that a workout was added directly to Hive
  /// Call this from workout_provider after saving to history box
  Future<void> notifyLocalWorkoutAdded() async {
    try {
      await _ensureInitialized();
      final workouts = await _getLocalWorkouts();
      _workoutsController.add(workouts);

      if (kDebugMode) {
        debugPrint(
          '📢 [WorkoutHistoryRepo] Notified listeners of new local workout (${workouts.length} total)',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [WorkoutHistoryRepo] Failed to notify listeners: $e');
      }
    }
  }

  /// Initialize the repository
  ///
  /// FIX: Uses Completer to prevent concurrent init race condition.
  /// Constructor calls _initialize() (fire-and-forget), and _ensureInitialized()
  /// may be called before it completes. Without dedup, both would open boxes twice.
  Future<void> _initialize() async {
    if (_isInitialized) return;
    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer<void>();

    try {
      // Open Hive boxes in parallel
      final results = await Future.wait([
        _boxManager.openBox(_historyBoxName),
        _boxManager.openBox(_syncQueueBoxName),
        _boxManager.openBox<dynamic>(_metadataBoxName),
      ]);
      _historyBox = results[0];
      _syncQueueBox = results[1];
      _metadataBox = results[2];

      _isInitialized = true;
      _initCompleter!.complete();

      if (_enableRemoteSync) {
        // Trigger initial sync if needed only for the interactive app session.
        await _performInitialSyncIfNeeded();
      }
    } catch (e) {
      _initCompleter!.completeError(e);
      _initCompleter = null; // Allow retry on next call
      if (kDebugMode) {
        debugPrint('❌ Error initializing WorkoutHistoryRepositoryEnhanced: $e');
      }
    }
  }

  /// Ensure repository is initialized
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    await _initialize();
  }

  /// Check if initial sync has been completed
  bool get _hasInitialSync {
    final hasSync = _metadataBox?.get('initial_sync_done') as bool?;
    return hasSync == true;
  }

  /// Check if a premium user has already backfilled the full remote history
  bool get _hasFullHistorySync {
    final hasSync = _metadataBox?.get('full_history_sync_done') as bool?;
    return hasSync == true;
  }

  /// Get last sync timestamp
  DateTime? get _lastSyncTimestamp {
    final timestamp = _metadataBox?.get('last_sync_timestamp') as String?;
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  /// Perform initial sync if needed
  Future<void> _performInitialSyncIfNeeded() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final accountTier = await _getCurrentAccountTier(userId);
    final shouldSyncFullHistory = accountTier != AccountTier.free;

    if (!_hasInitialSync) {
      await _performInitialSync(fullHistory: shouldSyncFullHistory);
      return;
    }

    if (shouldSyncFullHistory && !_hasFullHistorySync) {
      await _performPremiumHistoryBackfill(userId);
    }

    await _performIncrementalSync();
  }

  /// Perform initial complete sync
  Future<void> _performInitialSync({required bool fullHistory}) async {
    if (_auth.currentUser == null) return;

    _syncStatusController.add(SyncStatus.initialSyncing);

    try {
      // Free users only need the last 3 months locally.
      // Premium users must receive the full remote history on first sync.
      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
      final userId = _auth.currentUser!.uid;

      if (kDebugMode) {
        debugPrint(
          fullHistory
              ? '🔄 Starting full history sync for premium user...'
              : '🔄 Starting initial 90-day sync for workout history...',
        );
      }

      final docs = fullHistory
          ? await _fetchAllWorkoutDocs(userId)
          : await _fetchRecentWorkoutDocs(
              userId: userId,
              cutoffDate: cutoffDate,
            );

      // Convert and save to local storage
      final workouts = <WorkoutHistoryDetail>[];

      for (final doc in docs) {
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
      await _metadataBox!.put('full_history_sync_done', fullHistory);
      await _metadataBox!.put(
        'last_sync_timestamp',
        DateTime.now().toIso8601String(),
      );

      if (kDebugMode) {
        debugPrint(
          '✅ Initial sync completed: ${workouts.length} workouts downloaded from Firebase'
          '${fullHistory ? ' (full history)' : ' (90-day window)'}',
        );
      }

      // 🔧 FIX: Emit ALL local workouts (including pre-existing ones not on Firebase)
      // Previous bug: emitted only downloaded workouts, hiding locally-saved ones
      final allLocalWorkouts = await _getLocalWorkouts();
      if (kDebugMode) {
        debugPrint(
          '📋 Total local workouts after sync: ${allLocalWorkouts.length}',
        );
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

  Future<void> _performPremiumHistoryBackfill(String userId) async {
    _syncStatusController.add(SyncStatus.syncing);

    try {
      if (kDebugMode) {
        debugPrint(
          '🔄 Starting premium history backfill to unlock workouts older than 90 days...',
        );
      }

      final docs = await _fetchAllWorkoutDocs(userId);

      for (final doc in docs) {
        try {
          final workout = WorkoutHistoryDetail.fromFirestore(doc);
          await _saveWorkoutLocally(workout);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Error backfilling workout ${doc.id}: $e');
          }
        }
      }

      await _metadataBox!.put('full_history_sync_done', true);
      await _metadataBox!.put(
        'last_sync_timestamp',
        DateTime.now().toIso8601String(),
      );

      final allLocalWorkouts = await _getLocalWorkouts();
      _workoutsController.add(allLocalWorkouts);
      _syncStatusController.add(SyncStatus.synced);

      if (kDebugMode) {
        debugPrint(
          '✅ Premium history backfill completed: ${docs.length} workouts scanned from Firebase',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Premium history backfill failed: $e');
      }
      _syncStatusController.add(SyncStatus.error);
    }
  }

  /// Perform incremental sync
  Future<void> _performIncrementalSync() async {
    if (_auth.currentUser == null) return;

    try {
      final lastSync =
          _lastSyncTimestamp ??
          DateTime.now().subtract(const Duration(hours: 24));
      final userId = _auth.currentUser!.uid;

      // Query for updates since last sync
      // 🔧 PERF FIX: Add limit to prevent unbounded reads
      // 🔧 FIX: Added 10s timeout to prevent infinite hanging on poor network
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
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
          debugPrint(
            '🔄 Incremental sync: ${querySnapshot.docs.length} updates found',
          );
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
        await _metadataBox!.put(
          'last_sync_timestamp',
          DateTime.now().toIso8601String(),
        );

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

    if (workout.isHealthImportedWorkout) {
      if (kDebugMode) {
        debugPrint(
          '⏭️ [WorkoutHistoryRepo] Skipping health-imported workout ${workout.id}',
        );
      }
      return;
    }

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Key format: workout_{userId}_{workoutId} for user isolation
    final key = 'workout_${userId}_${workout.id}';
    await _historyBox!.put(key, workout.toMap());

    // 🔥 FIX: Force immediate disk flush to prevent data loss
    // Ensures workout history is persisted even if app crashes/terminates
    await _historyBox!.flush();
  }

  /// Save workout to local history and notify listeners.
  ///
  /// Public wrapper for workout completion flow. Uses the repository's
  /// already-initialized box instead of opening it directly.
  Future<void> saveAndNotify(
    WorkoutHistoryDetail workout, {
    required String userId,
  }) async {
    await _ensureInitialized();

    if (workout.isHealthImportedWorkout) {
      if (kDebugMode) {
        debugPrint(
          '⏭️ [WorkoutHistoryRepo] Ignoring health-imported workout ${workout.id} during saveAndNotify',
        );
      }
      return;
    }

    final key = 'workout_${userId}_${workout.id}';
    await _historyBox!.put(key, workout.toMap());
    await _historyBox!.flush();

    // Notify stream listeners for immediate UI update
    final workouts = await _getLocalWorkouts();
    _workoutsController.add(workouts);
  }

  /// Get workouts from local storage
  /// 🔧 FIX: Filter by userId to only return current user's workouts
  /// Supports both new format (workout_{userId}_{id}) and legacy format (workout_{id})
  Future<List<WorkoutHistoryDetail>> _getLocalWorkouts() async {
    await _ensureInitialized();

    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final workouts = <WorkoutHistoryDetail>[];
    final userPrefix = 'workout_${userId}_';
    final legacyKeysToMigrate = <String, WorkoutHistoryDetail>{};
    final orphanedLegacyKeys = <String>[];

    for (var key in _historyBox!.keys) {
      final keyStr = key.toString();

      // Skip non-workout keys
      if (!keyStr.startsWith('workout_')) continue;

      try {
        final data = _historyBox!.get(key);
        if (data == null) continue;

        final workout = WorkoutHistoryDetail.fromMap(data);

        if (workout.isHealthImportedWorkout) {
          continue;
        }

        // 🔐 SECURITY: Only include workouts belonging to current user
        // Case 1: New format key (workout_{userId}_{workoutId})
        if (keyStr.startsWith(userPrefix)) {
          workouts.add(workout);
          continue;
        }

        // Case 2: Legacy format key (workout_{workoutId}) - only adopt if the
        // payload already proves ownership. Empty userId is ambiguous and can
        // leak another person's local history after account switch.
        if (workout.userId == userId) {
          workouts.add(workout);
          // Queue for migration to new key format
          legacyKeysToMigrate[keyStr] = workout;
          continue;
        }

        if (workout.userId.isEmpty) {
          orphanedLegacyKeys.add(keyStr);
        }
        // Case 3: Different user's workout - skip silently
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Error loading workout $key: $e');
        }
      }
    }

    // 🔄 Migrate legacy keys to new format (background, non-blocking)
    if (legacyKeysToMigrate.isNotEmpty) {
      unawaited(_migrateLegacyKeys(legacyKeysToMigrate, userId));
    }

    // Sort by completion date (newest first)
    workouts.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    if (kDebugMode) {
      debugPrint(
        '📦 [WorkoutHistoryRepo] Loaded ${workouts.length} workouts for user $userId'
        '${legacyKeysToMigrate.isNotEmpty ? ' (migrating ${legacyKeysToMigrate.length} legacy keys)' : ''}'
        '${orphanedLegacyKeys.isNotEmpty ? ' (skipped ${orphanedLegacyKeys.length} orphaned legacy keys)' : ''}',
      );
    }

    return workouts;
  }

  /// Migrate legacy keys to new format with userId
  /// Runs in background to avoid blocking the main read operation
  Future<void> _migrateLegacyKeys(
    Map<String, WorkoutHistoryDetail> legacyWorkouts,
    String userId,
  ) async {
    for (final entry in legacyWorkouts.entries) {
      try {
        final oldKey = entry.key;
        final workout = entry.value;
        final newKey = 'workout_${userId}_${workout.id}';

        // Save with new key format
        await _historyBox!.put(newKey, workout.toMap());
        // Delete old key
        await _historyBox!.delete(oldKey);

        if (kDebugMode) {
          debugPrint('🔄 [WorkoutHistoryRepo] Migrated key: $oldKey → $newKey');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [WorkoutHistoryRepo] Failed to migrate key ${entry.key}: $e',
          );
        }
      }
    }

    // 🔥 FIX: Flush after batch migration to ensure all migrated data is persisted
    // Only one flush for all migrations (performance optimization)
    await _historyBox!.flush();
  }

  /// Get all workouts (local-first approach)
  Future<Either<Failure, List<WorkoutHistoryDetail>>> getWorkouts() async {
    try {
      await _ensureInitialized();

      // Always return local data first for instant loading
      final localWorkouts = await _applyHistoryAccessPolicy(
        await _getLocalWorkouts(),
      );

      // Trigger background sync if needed
      if (_enableRemoteSync && _auth.currentUser != null) {
        unawaited(_performIncrementalSync());
      }

      return Right(localWorkouts);
    } catch (e) {
      return Left(DatabaseFailure('Failed to load workouts: $e'));
    }
  }

  /// Get workouts with real-time updates
  Stream<Either<Failure, List<WorkoutHistoryDetail>>>
  getWorkoutsStream() async* {
    try {
      await _ensureInitialized();

      // Emit initial local data
      final initialWorkouts = await _applyHistoryAccessPolicy(
        await _getLocalWorkouts(),
      );
      yield Right(initialWorkouts);

      // Listen for updates
      await for (final workouts in _workoutsController.stream) {
        yield Right(await _applyHistoryAccessPolicy(workouts));
      }
    } catch (e) {
      yield Left(DatabaseFailure('Stream error: $e'));
    }
  }

  /// Update workout
  Future<Either<Failure, void>> updateWorkout(
    WorkoutHistoryDetail workout,
  ) async {
    try {
      await _ensureInitialized();

      // Update local storage immediately
      await _saveWorkoutLocally(workout);

      // Add to sync queue for cloud update
      await _addToSyncQueue('update', workout);

      if (_enableRemoteSync) {
        // Process sync queue if online only when remote sync is enabled.
        unawaited(_processSyncQueue());
      }

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
      await _addToSyncQueue(
        'delete',
        WorkoutHistoryDetail.empty(id: workoutId),
      );

      if (_enableRemoteSync) {
        // Process sync queue if online only when remote sync is enabled.
        unawaited(_processSyncQueue());
      }

      // Emit updated list
      final updatedWorkouts = await _getLocalWorkouts();
      _workoutsController.add(updatedWorkouts);

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete workout: $e'));
    }
  }

  /// Add operation to sync queue
  Future<void> _addToSyncQueue(
    String operation,
    WorkoutHistoryDetail workout,
  ) async {
    final queueItem = {
      'operation': operation,
      'workout': workout.toMap(),
      'timestamp': DateTime.now().toIso8601String(),
      'attempts': 0,
    };

    final key =
        '${operation}_${workout.id}_${DateTime.now().millisecondsSinceEpoch}';
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
            await _updateWorkoutInFirestore(
              WorkoutHistoryDetail.fromMap(workoutData),
            );
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
            debugPrint(
              '⚠️ Sync queue item failed (attempt ${attempts + 1}): $e',
            );
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
        .collection('users')
        .doc(workout.userId)
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
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('users')
        .doc(userId)
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

    if (!_enableRemoteSync) {
      _syncStatusController.add(SyncStatus.synced);
      return;
    }

    await _performInitialSyncIfNeeded();
    await _processSyncQueue();

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

  Future<AccountTier> _getCurrentAccountTier(String userId) async {
    try {
      return await _entitlementStore.getEffectiveAccountTier(userId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [WorkoutHistoryRepo] Failed to load account tier: $e');
      }
    }

    return AccountTier.free;
  }

  Future<List<WorkoutHistoryDetail>> _applyHistoryAccessPolicy(
    List<WorkoutHistoryDetail> workouts,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final accountTier = await _getCurrentAccountTier(userId);
    if (accountTier != AccountTier.free) {
      return workouts;
    }

    final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
    return workouts.where((w) => w.completedAt.isAfter(cutoffDate)).toList();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _fetchRecentWorkoutDocs({
    required String userId,
    required DateTime cutoffDate,
  }) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .where('endTime', isGreaterThan: Timestamp.fromDate(cutoffDate))
        .orderBy('endTime', descending: true)
        .limit(500)
        .get()
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () =>
              throw TimeoutException('Firestore initial sync timed out'),
        );

    return querySnapshot.docs;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _fetchAllWorkoutDocs(String userId) async {
    final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    QueryDocumentSnapshot<Map<String, dynamic>>? lastDoc;

    while (true) {
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .orderBy(FieldPath.documentId)
          .limit(500);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final querySnapshot = await query.get().timeout(
        const Duration(seconds: 15),
        onTimeout: () =>
            throw TimeoutException('Firestore full history sync timed out'),
      );

      docs.addAll(querySnapshot.docs);

      if (querySnapshot.docs.length < 500) {
        break;
      }

      lastDoc = querySnapshot.docs.last;
    }

    return docs;
  }
}

/// Database failure class
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}
