/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: data/services
/// 🎯 Feature: workout
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Hive (local storage)
/// - Firebase (cloud sync for premium)
/// - Connectivity monitoring
library;

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/firebase_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/shared/auth/entities/user_profile.dart';
import 'package:flutter/foundation.dart';

/// Service to handle background synchronization for premium users
class WorkoutSyncService {
  WorkoutSyncService({
    required HiveWorkoutDataSource localDataSource,
    required FirebaseWorkoutDataSource remoteDataSource,
    required FirebaseAuth auth,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _auth = auth;
  final HiveWorkoutDataSource _localDataSource;
  final FirebaseWorkoutDataSource _remoteDataSource;
  final FirebaseAuth _auth;

  Timer? _syncTimer;
  bool _isSyncing = false;
  UserProfile? _userProfile;

  // Sync status tracking
  final Map<String, SyncStatus> _syncStatuses = {};

  /// Initialize sync service
  Future<void> initialize() async {
    // Listen to auth changes
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _loadUserProfile(user.uid);
        if (_isPremiumUser) {
          startPeriodicSync();
        } else {
          stopPeriodicSync();
        }
      } else {
        stopPeriodicSync();
        _userProfile = null;
      }
    });
  }

  /// Load user profile to check premium status
  Future<void> _loadUserProfile(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        _userProfile = UserProfile.fromFirestore(doc);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load user profile for sync: $e');
      }
    }
  }

  /// Check if user is premium
  bool get _isPremiumUser {
    return _userProfile?.accountTier != AccountTier.free;
  }

  /// Start periodic sync for premium users
  void startPeriodicSync() {
    stopPeriodicSync(); // Cancel any existing timer

    // Initial sync
    syncNow();

    // Schedule periodic sync every 5 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncNow();
    });
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Perform sync now
  Future<SyncResult> syncNow() async {
    if (_isSyncing) {
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    if (!_isPremiumUser) {
      return SyncResult(
        success: false,
        message: 'Sync available for premium users only',
      );
    }

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return SyncResult(success: false, message: 'User not authenticated');
    }

    _isSyncing = true;
    final result = SyncResult();

    try {
      // Check connectivity
      final hasConnection = await _checkConnection();
      if (!hasConnection) {
        result.success = false;
        result.message = 'No internet connection';
        return result;
      }

      // 1. Get pending sync items from queue
      final pendingItems = await _localDataSource.getPendingSyncItems(userId);

      // 2. Process each pending item
      for (final item in pendingItems) {
        try {
          await _processSyncItem(item, userId);
          result.syncedItems++;
        } catch (e) {
          result.failedItems++;
          result.errors.add('Failed to sync ${item['key']}: $e');
        }
      }

      // 3. Pull new/updated workouts from cloud
      await _pullFromCloud(userId, result);

      // 4. Clean up old sync queue items
      await _localDataSource.cleanSyncQueue();

      result.success = true;
      result.message = 'Sync completed successfully';
      result.lastSyncTime = DateTime.now();
    } catch (e) {
      result.success = false;
      result.message = 'Sync failed: $e';
    } finally {
      _isSyncing = false;
    }

    return result;
  }

  /// Process a single sync item
  Future<void> _processSyncItem(
    Map<String, dynamic> item,
    String userId,
  ) async {
    final operation = item['operation'];
    final key = item['key'] as String;

    switch (operation) {
      case 'create':
      case 'update':
        // Get workout from local storage
        final workoutId = key.split('_').last;
        final workout = await _localDataSource.getWorkout(workoutId, userId);

        if (workout != null) {
          if (operation == 'create') {
            await _remoteDataSource.saveWorkout(workout, userId);
          } else {
            await _remoteDataSource.updateWorkout(workout, userId);
          }
        }
        break;

      case 'delete':
        final workoutId = key.split('_').last;
        await _remoteDataSource.deleteWorkout(workoutId, userId);
        break;
    }
  }

  /// Pull new/updated workouts from cloud
  Future<void> _pullFromCloud(String userId, SyncResult result) async {
    try {
      // Get last sync time (for incremental sync)
      final lastSyncTime = _getLastSyncTime();

      // Get all cloud workouts (modified after last sync if available)
      final cloudWorkouts = await _remoteDataSource.getWorkouts(
        userId,
        startDate: lastSyncTime,
      );

      // Update local storage with cloud data
      for (final cloudWorkout in cloudWorkouts) {
        final localWorkout = await _localDataSource.getWorkout(
          cloudWorkout.id,
          userId,
        );

        if (localWorkout == null) {
          // New workout from cloud
          await _localDataSource.saveWorkout(cloudWorkout, userId);
          result.pulledItems++;
        } else {
          // Check if cloud version is newer
          if (_shouldUpdateLocal(localWorkout, cloudWorkout)) {
            await _localDataSource.updateWorkout(cloudWorkout, userId);
            result.updatedItems++;
          }
        }
      }

      _saveLastSyncTime(DateTime.now());
    } catch (e) {
      result.errors.add('Failed to pull from cloud: $e');
    }
  }

  /// Check if local workout should be updated with cloud version
  bool _shouldUpdateLocal(WorkoutModel local, WorkoutModel cloud) {
    // Simple conflict resolution: cloud wins if newer
    return cloud.updatedAt.isAfter(local.updatedAt);
  }

  /// Check internet connection
  /// Uses Firestore's built-in pending writes check instead of protected document
  Future<bool> _checkConnection() async {
    try {
      await FirebaseFirestore.instance.waitForPendingWrites().timeout(
        const Duration(seconds: 3),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get last sync time from preferences
  DateTime? _getLastSyncTime() {
    // TODO: Implement using shared_preferences
    // For now, return null to sync all
    return null;
  }

  /// Save last sync time to preferences
  void _saveLastSyncTime(DateTime time) {
    // TODO: Implement using shared_preferences
  }

  /// Force conflict resolution for a specific workout
  Future<ConflictResolution> resolveConflict(
    String workoutId,
    ConflictResolutionStrategy strategy,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return ConflictResolution(
        success: false,
        message: 'User not authenticated',
      );
    }

    try {
      final localWorkout = await _localDataSource.getWorkout(workoutId, userId);
      final cloudWorkout = await _remoteDataSource.getWorkout(
        workoutId,
        userId,
      );

      if (localWorkout == null || cloudWorkout == null) {
        return ConflictResolution(
          success: false,
          message: 'Workout not found in one of the sources',
        );
      }

      switch (strategy) {
        case ConflictResolutionStrategy.keepLocal:
          await _remoteDataSource.updateWorkout(localWorkout, userId);
          break;

        case ConflictResolutionStrategy.keepCloud:
          await _localDataSource.updateWorkout(cloudWorkout, userId);
          break;

        case ConflictResolutionStrategy.merge:
          final merged = _mergeWorkouts(localWorkout, cloudWorkout);
          await _localDataSource.updateWorkout(merged, userId);
          await _remoteDataSource.updateWorkout(merged, userId);
          break;
      }

      return ConflictResolution(
        success: true,
        message: 'Conflict resolved successfully',
      );
    } catch (e) {
      return ConflictResolution(
        success: false,
        message: 'Failed to resolve conflict: $e',
      );
    }
  }

  /// Merge two workout versions
  WorkoutModel _mergeWorkouts(WorkoutModel local, WorkoutModel cloud) {
    // Complex merge logic
    // For now, take cloud metadata but local exercises if local is newer
    if (local.updatedAt.isAfter(cloud.updatedAt)) {
      // Local is newer - keep local exercises
      return local.copyWith(
        // Keep cloud metadata that might have been updated elsewhere
        status: cloud.status,
      );
    }

    // Cloud is newer
    return cloud;
  }

  /// Get sync status for a workout
  SyncStatus? getSyncStatus(String workoutId) {
    return _syncStatuses[workoutId];
  }

  /// Export all data for backup
  Future<Map<String, dynamic>> exportAllData() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return await _localDataSource.exportAllData(userId);
  }

  /// Import data from backup
  Future<void> importData(Map<String, dynamic> data) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _localDataSource.importData(data, userId);

    // If premium, sync imported data to cloud
    if (_isPremiumUser) {
      await syncNow();
    }
  }

  /// Clear all local data (for logout/account deletion)
  Future<void> clearAllData() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _localDataSource.clearUserData(userId);
  }

  /// Dispose of resources
  void dispose() {
    stopPeriodicSync();
  }
}

/// Sync result information
class SyncResult {
  SyncResult({
    this.success = false,
    this.message = '',
    this.syncedItems = 0,
    this.failedItems = 0,
    this.pulledItems = 0,
    this.updatedItems = 0,
    List<String>? errors,
    this.lastSyncTime,
  }) : errors = errors ?? [];
  bool success;
  String message;
  int syncedItems;
  int failedItems;
  int pulledItems;
  int updatedItems;
  List<String> errors;
  DateTime? lastSyncTime;

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'syncedItems': syncedItems,
    'failedItems': failedItems,
    'pulledItems': pulledItems,
    'updatedItems': updatedItems,
    'errors': errors,
    'lastSyncTime': lastSyncTime?.toIso8601String(),
  };
}

/// Sync status for individual items
enum SyncStatus { pending, syncing, synced, failed, conflict }

/// Conflict resolution strategies
enum ConflictResolutionStrategy { keepLocal, keepCloud, merge }

/// Conflict resolution result
class ConflictResolution {
  ConflictResolution({required this.success, required this.message});
  final bool success;
  final String message;
}
