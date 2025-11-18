/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: data/repositories
/// 🎯 Feature: workout
/// 🔧 Type: repository
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Hive (local storage)
/// - Firebase (cloud sync for premium)
/// - Domain entities
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';

/// Hybrid repository per gestire le attività degli esercizi
/// - Free users: Solo storage locale
/// - Premium users: Storage locale + sync Firebase
///
/// ⚠️ **DEPRECATED**: This repository queries the old 'exerciseActivities' collection
/// which no longer exists. Use WorkoutHistoryRepositoryEnhanced instead.
///
/// **Migration Plan**:
/// - Old structure: exerciseActivities/{activityId} (flat, one doc per exercise)
/// - New structure: workouts/{workoutId} with nested exercises[] array
///
/// **Status**: Temporarily fixed to query 'workouts' but this is NOT the correct
/// architecture. This repository should be replaced with workout_history_repository_enhanced.dart
class HybridExerciseActivityRepository {

  HybridExerciseActivityRepository({
    required HiveWorkoutDataSource localDataSource,
    FirebaseAuth? auth,
  }) : _localDataSource = localDataSource,
       _auth = auth ?? FirebaseAuth.instance {
    _loadUserProfile();
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final HiveWorkoutDataSource _localDataSource;
  final FirebaseAuth _auth;

  // Cache user profile
  UserProfile? _userProfile;

  // ⚠️ CHANGED: exerciseActivities → workouts (2025-01-18)
  // Old: static const String _collectionName = 'exerciseActivities';
  static const String _collectionName = 'workouts';
  
  /// Load user profile to check premium status
  Future<void> _loadUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          _userProfile = UserProfile.fromFirestore(doc);
        }
      }
    } catch (e) {
      debugPrint('Failed to load user profile: $e');
    }
  }
  
  /// Check if user is premium
  bool get _isPremiumUser {
    return _userProfile?.accountTier == AccountTier.premium ||
           _userProfile?.accountTier == AccountTier.pro;
  }
  
  /// Get user activities within a date range (optimized for lazy loading)
  Future<List<ExerciseActivity>> getUserActivitiesInDateRange({
    required String userEmail,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      debugPrint('📊 Loading activities from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
      
      // Always load from local first (fast!)
      final workouts = await _localDataSource.getWorkouts(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
      
      // Convert workouts to exercise activities
      final activities = <ExerciseActivity>[];
      
      for (final workout in workouts) {
        for (final exercise in workout.exercises) {
          final completedSets = exercise.sets.where((set) => set.isCompleted).toList();
          
          if (completedSets.isNotEmpty) {
            final activity = ExerciseActivity.fromExercise(
              exercise: exercise.toDomain(),
              userEmail: userEmail.toLowerCase().trim(),
              workoutName: workout.name,
              exerciseImageUrl: null,
              workoutDate: workout.startTime ?? workout.createdAt,
            );
            activities.add(activity);
          }
        }
      }
      
      debugPrint('📊 Found ${activities.length} activities in date range');
      
      return activities;
    } catch (e) {
      debugPrint('❌ Error loading activities in date range: $e');
      return [];
    }
  }

  /// Salva un allenamento completato
  /// SEMPRE salva in locale, NON sincronizza automaticamente
  Future<List<String>> saveCompletedWorkout({
    required Workout workout,
    required String userEmail,
    bool autoSync = false, // Disabilitato di default
  }) async {
    
    if (!workout.isCompleted) {
      throw Exception('Il workout deve essere completato per essere salvato');
    }

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // 1. SEMPRE salva in locale prima (istantaneo!)
      final workoutModel = WorkoutModel.fromDomain(workout);
      final localIds = await _localDataSource.saveCompletedWorkout(
        workoutModel,
        userEmail,
      );
      
      debugPrint('✅ Workout saved locally: ${localIds.length} activities');
      
      // 2. NON sincronizzare automaticamente con Firebase
      // Solo se esplicitamente richiesto E se premium
      if (_isPremiumUser && autoSync) {
        _syncToFirebaseInBackground(
          workout: workout,
          userEmail: userEmail,
        );
        debugPrint('☁️ Premium user - background sync initiated');
      } else {
        debugPrint('ℹ️ Local-only storage (sync disabled or free user)');
      }
      
      return localIds;
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving workout: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  /// Sync to Firebase in background (fire and forget)
  void _syncToFirebaseInBackground({
    required Workout workout,
    required String userEmail,
  }) {
    Future(() async {
      try {
        debugPrint('☁️ Starting background sync to Firebase...');
        
        // Normalizza email
        final normalizedEmail = userEmail.toLowerCase().trim();
        
        // Salva ogni esercizio come activity
        for (final exercise in workout.exercises) {
          final completedSets = exercise.sets.where((set) => set.isCompleted).toList();
          
          if (completedSets.isNotEmpty) {
            final exerciseActivity = ExerciseActivity.fromExercise(
              exercise: exercise,
              userEmail: normalizedEmail,
              workoutName: workout.name,
              exerciseImageUrl: null,
              workoutDate: workout.startTime ?? workout.createdAt,
            );

            await _firestore
                .collection(_collectionName)
                .add(exerciseActivity.toFirestore());
          }
        }
        
        debugPrint('✅ Background sync completed successfully');
        
      } catch (e) {
        debugPrint('⚠️ Background sync failed (will retry later): $e');
        // Non blocca l'app - verrà riprovato al prossimo sync
      }
    });
  }

  /// Ottiene tutte le attività di un utente
  /// Prima cerca in locale, poi merge con cloud se premium
  Future<List<ExerciseActivity>> getUserActivities({
    required String userEmail,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return [];
    }
    
    try {
      // 1. Ottieni sempre da locale prima (veloce!)
      // Per ora usiamo i workout locali come proxy per activities
      // debugPrint('📊 Analytics: Getting activities for user: $userEmail (uid: $userId)');
      
      final localWorkouts = await _localDataSource.getWorkouts(
        userId,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );
      
      // debugPrint('📊 Analytics: Found ${localWorkouts.length} local workouts');
      
      // Converti workout in activities
      final localActivities = <ExerciseActivity>[];
      for (final workout in localWorkouts) {
        // debugPrint('  - Processing workout: ${workout.name} with ${workout.exercises.length} exercises');
        for (final exercise in workout.exercises) {
          final completedSets = exercise.sets.where((s) => s.isCompleted).length;
          // debugPrint('    - Exercise: ${exercise.name} has $completedSets completed sets');
          
          if (exercise.sets.any((s) => s.isCompleted)) {
            localActivities.add(
              ExerciseActivity.fromExercise(
                exercise: exercise.toDomain(),
                userEmail: userEmail,
                workoutName: workout.name,
                exerciseImageUrl: null,
                workoutDate: workout.startTime ?? workout.createdAt, // Use actual workout date
              ),
            );
          }
        }
      }
      
      // debugPrint('📊 Analytics: Converted to ${localActivities.length} activities');
      
      // 2. Se premium e online, merge con cloud
      if (_isPremiumUser) {
        try {
          final cloudActivities = await _getCloudActivities(
            userId: userId, // ⚠️ CHANGED: userEmail → userId (2025-01-18)
            limit: limit,
            startDate: startDate,
            endDate: endDate,
          );
          
          // Merge e deduplica
          final merged = _mergeActivities(localActivities, cloudActivities);
          return merged;
          
        } catch (e) {
          debugPrint('Cloud fetch failed, using local only: $e');
          // Fallback to local if cloud fails
        }
      }
      
      return localActivities;
      
    } catch (e, stackTrace) {
      debugPrint('Error getting activities: $e');
      debugPrint('$stackTrace');
      return [];
    }
  }
  
  /// Get activities from cloud
  ///
  /// ⚠️ DEPRECATED: Queries 'workouts' but expects flat ExerciseActivity structure
  /// ⚠️ Will fail to parse nested workout.exercises[] correctly
  @Deprecated('Use WorkoutHistoryRepositoryEnhanced instead')
  Future<List<ExerciseActivity>> _getCloudActivities({
    required String userId, // ⚠️ CHANGED: userEmail → userId (2025-01-18)
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    debugPrint('⚠️ DEPRECATED: HybridExerciseActivityRepository._getCloudActivities() is deprecated');

    Query query = _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId) // ⚠️ CHANGED: email → userId (2025-01-18)
        .orderBy('completedAt', descending: true); // ⚠️ CHANGED: createdAt → completedAt (2025-01-18)

    if (startDate != null) {
      query = query.where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate)); // ⚠️ CHANGED
    }

    if (endDate != null) {
      query = query.where('completedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate)); // ⚠️ CHANGED
    }
    
    if (limit != null) {
      query = query.limit(limit);
    }

    final querySnapshot = await query.get();
    
    return querySnapshot.docs
        .map((doc) => ExerciseActivity.fromFirestore(doc))
        .toList();
  }
  
  /// Merge local and cloud activities
  List<ExerciseActivity> _mergeActivities(
    List<ExerciseActivity> local,
    List<ExerciseActivity> cloud,
  ) {
    // Simple deduplication by date + exercise name
    final merged = <String, ExerciseActivity>{};
    
    // Add local first
    for (final activity in local) {
      final key = '${activity.createdAt}_${activity.exerciseName}';
      merged[key] = activity;
    }
    
    // Add cloud (overwrites if duplicate)
    for (final activity in cloud) {
      final key = '${activity.createdAt}_${activity.exerciseName}';
      merged[key] = activity;
    }
    
    // Sort by date
    final result = merged.values.toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return result;
  }

  /// Ottiene attività per nome esercizio
  Future<List<ExerciseActivity>> getActivitiesByExercise({
    required String userEmail,
    required String exerciseName,
    int? limit,
  }) async {
    final activities = await getUserActivities(
      userEmail: userEmail,
      limit: limit,
    );
    
    return activities
        .where((a) => a.exerciseName == exerciseName)
        .toList();
  }

  /// Ottiene statistiche delle attività
  Future<Map<String, dynamic>> getActivityStats({
    required String userEmail,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final activities = await getUserActivities(
      userEmail: userEmail,
      startDate: startDate,
      endDate: endDate,
    );
    
    // Calcola statistiche
    final totalActivities = activities.length;
    final totalVolume = activities.fold<double>(
      0, 
      (sum, a) {
        // Calculate total volume from sets (weight * reps)
        double activityVolume = 0;
        for (final set in a.sets) {
          if (set.done) {
            final weight = double.tryParse(set.weight) ?? 0;
            final reps = double.tryParse(set.reps) ?? 0;
            activityVolume += weight * reps;
          }
        }
        return sum + activityVolume;
      },
    );
    
    final exerciseCount = <String, int>{};
    for (final activity in activities) {
      exerciseCount[activity.exerciseName] = 
          (exerciseCount[activity.exerciseName] ?? 0) + 1;
    }
    
    return {
      'totalActivities': totalActivities,
      'totalVolume': totalVolume,
      'exerciseCount': exerciseCount,
      'periodStart': startDate,
      'periodEnd': endDate,
    };
  }

  /// Clear local cache (for logout)
  Future<void> clearLocalCache() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _localDataSource.clearUserData(userId);
    }
  }
  
  /// Sincronizza tutti i workout non sincronizzati (per upgrade premium)
  Future<SyncResult> syncAllPendingWorkouts() async {
    // Check if user is admin (bypass premium check)
    final userEmail = _auth.currentUser?.email ?? '';
    final isAdmin = userEmail == 'ferrara-michele@hotmail.it' || 
                   userEmail.contains('admin@');
    
    if (!_isPremiumUser && !isAdmin) {
      return SyncResult(
        success: false,
        message: 'Sync available for premium users only',
        syncedCount: 0,
        failedCount: 0,
      );
    }
    
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return SyncResult(
        success: false,
        message: 'User not authenticated',
        syncedCount: 0,
        failedCount: 0,
      );
    }
    
    try {
      debugPrint('🔄 Starting retroactive sync for premium user...');
      
      // Ottieni tutti i workout non sincronizzati
      final unsyncedWorkouts = await _localDataSource.getUnsyncedWorkouts(userId);
      debugPrint('Found ${unsyncedWorkouts.length} unsynced workouts');
      
      int syncedCount = 0;
      int failedCount = 0;
      final List<String> errors = [];
      
      // Sync in batch per efficienza
      const batchSize = 10;
      for (int i = 0; i < unsyncedWorkouts.length; i += batchSize) {
        final batch = unsyncedWorkouts.skip(i).take(batchSize).toList();
        
        try {
          // Sync batch to Firebase
          for (final workoutModel in batch) {
            try {
              final workout = workoutModel.toDomain();
              await _syncWorkoutToFirebase(
                workout: workout,
                userEmail: _auth.currentUser!.email!,
              );
              
              // Marca come sincronizzato
              await _localDataSource.markWorkoutAsSynced(workoutModel.id, userId);
              syncedCount++;
              
            } catch (e) {
              failedCount++;
              errors.add('Failed to sync workout ${workoutModel.id}: $e');
              debugPrint('❌ Failed to sync workout: $e');
            }
          }
          
          debugPrint('✅ Synced batch ${i ~/ batchSize + 1}: $syncedCount/$unsyncedWorkouts.length');
          
        } catch (e) {
          debugPrint('❌ Batch sync failed: $e');
          errors.addAll(batch.map((w) => 'Batch sync failed for ${w.id}'));
          failedCount += batch.length;
        }
      }
      
      return SyncResult(
        success: failedCount == 0,
        message: 'Synced $syncedCount workouts${failedCount > 0 ? ', $failedCount failed' : ''}',
        syncedCount: syncedCount,
        failedCount: failedCount,
        errors: errors,
      );
      
    } catch (e) {
      debugPrint('❌ Sync all failed: $e');
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
        syncedCount: 0,
        failedCount: 0,
        errors: ['General sync error: $e'],
      );
    }
  }
  
  /// Sync singolo workout a Firebase (sincrono)
  Future<void> _syncWorkoutToFirebase({
    required Workout workout,
    required String userEmail,
  }) async {
    final normalizedEmail = userEmail.toLowerCase().trim();
    
    // Salva ogni esercizio come activity
    for (final exercise in workout.exercises) {
      final completedSets = exercise.sets.where((set) => set.isCompleted).toList();
      
      if (completedSets.isNotEmpty) {
        final exerciseActivity = ExerciseActivity.fromExercise(
          exercise: exercise,
          userEmail: normalizedEmail,
          workoutName: workout.name,
          exerciseImageUrl: null,
          workoutDate: workout.startTime ?? workout.createdAt,
        );

        await _firestore
            .collection(_collectionName)
            .add(exerciseActivity.toFirestore());
      }
    }
  }
}

/// Risultato operazione di sync
class SyncResult {
  
  SyncResult({
    required this.success,
    required this.message,
    required this.syncedCount,
    required this.failedCount,
    this.errors,
  });
  final bool success;
  final String message;
  final int syncedCount;
  final int failedCount;
  final List<String>? errors;
}