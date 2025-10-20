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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/firebase_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';
import 'package:flutter/foundation.dart';

/// Hybrid implementation of WorkoutRepository
/// - Free users: Local storage only (Hive)
/// - Premium users: Local storage + Cloud sync (Firebase)
class HybridWorkoutRepositoryImpl implements WorkoutRepository {
  
  HybridWorkoutRepositoryImpl({
    required HiveWorkoutDataSource localDataSource,
    required FirebaseWorkoutDataSource remoteDataSource,
    required FirebaseAuth auth,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _auth = auth {
    // Listen to user profile changes
    _initUserProfileListener();
  }
  final HiveWorkoutDataSource _localDataSource;
  final FirebaseWorkoutDataSource _remoteDataSource;
  final FirebaseAuth _auth;
  
  // Cache user profile to avoid frequent reads
  UserProfile? _cachedUserProfile;
  StreamSubscription? _userProfileSubscription;

  // MEMORY LEAK FIX: Disposal flag to prevent operations after dispose
  bool _isDisposed = false;
  
  /// Initialize listener for user profile changes
  void _initUserProfileListener() {
    // MEMORY LEAK FIX: Assign subscription to variable for proper cleanup
    _userProfileSubscription = _auth.authStateChanges().listen((user) async {
      if (_isDisposed) return; // Guard against operations after dispose

      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _cachedUserProfile = null;
      }
    });
  }
  
  /// Load user profile from Firestore
  Future<void> _loadUserProfile(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists) {
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
    return _cachedUserProfile?.accountTier == AccountTier.premium ||
           _cachedUserProfile?.accountTier == AccountTier.pro;
  }
  
  /// Check if current user is admin (always has cloud access)
  bool get isAdminUser {
    // Check if user email is admin email
    final email = _cachedUserProfile?.email ?? _auth.currentUser?.email ?? '';
    return email.contains('michele.cozzolino93@gmail.com') || 
           email.contains('admin@');
  }
  
  /// Check if we have internet connection
  Future<bool> get hasConnection async {
    try {
      // Simple connectivity check
      await FirebaseFirestore.instance
          .collection('_connectivity_check')
          .doc('test')
          .get(const GetOptions(source: Source.server));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Either<Failure, String>> saveWorkout(Workout workout) async {
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
      if (isPremiumUser || isAdminUser) {
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
  }

  @override
  Future<Either<Failure, void>> updateWorkout(Workout workout) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }
      
      final workoutModel = WorkoutModel.fromDomain(workout);
      
      // Update locally first
      await _localDataSource.updateWorkout(
        workoutModel,
        currentUser.uid,
      );
      
      // Sync to cloud if premium or admin
      if (isPremiumUser || isAdminUser) {
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
      if ((isPremiumUser || isAdminUser) && await hasConnection) {
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
      if (isAdminUser && await hasConnection) {
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
  }

  @override
  Future<Either<Failure, List<String>>> saveCompletedWorkout({
    required Workout workout,
    required String userEmail,
  }) async {
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
      return Stream.value(left(const AuthenticationFailure('User not authenticated')));
    }
    
    // For now, poll local storage
    // In future, can implement proper stream with Hive listeners
    return Stream.periodic(const Duration(seconds: 1))
        .asyncMap((_) async {
      try {
        final workout = await _localDataSource.getActiveWorkout(currentUser.uid);
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
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }
      
      // Get workout from local storage
      final workout = await _localDataSource.getWorkout(workoutId, currentUser.uid);
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
  }

  @override
  Future<Either<Failure, void>> addExerciseToWorkout({
    required String workoutId,
    required Exercise exercise,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }
      
      // Get workout from local storage
      final workout = await _localDataSource.getWorkout(workoutId, currentUser.uid);
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
  }

  @override
  Future<Either<Failure, void>> removeExerciseFromWorkout({
    required String workoutId,
    required String exerciseId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }
      
      // Get workout from local storage
      final workout = await _localDataSource.getWorkout(workoutId, currentUser.uid);
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
      return left(UnexpectedFailure('Failed to remove exercise from workout: $e'));
    }
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

  /// Update local cache with new workouts
  Future<void> _updateLocalCache(
    List<WorkoutModel> workouts,
    String userId,
  ) async {
    for (final workout in workouts) {
      await _localDataSource.saveWorkout(workout, userId);
    }
  }

  /// Sync to cloud in background (fire and forget)
  void _syncToCloudInBackground({
    required WorkoutModel workoutModel,
    required String userId,
    required String operation,
  }) {
    // Run async without awaiting
    Future(() async {
      try {
        if (await hasConnection) {
          if (operation == 'save') {
            await _remoteDataSource.saveWorkout(workoutModel, userId);
          } else if (operation == 'update') {
            await _remoteDataSource.updateWorkout(workoutModel, userId);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Background cloud sync failed: $e');
        }
        // Will be retried next time
      }
    });
  }

  /// Delete from cloud in background
  void _deleteFromCloudInBackground({
    required String workoutId,
    required String userId,
  }) {
    Future(() async {
      try {
        if (await hasConnection) {
          await _remoteDataSource.deleteWorkout(workoutId, userId);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Background cloud delete failed: $e');
        }
      }
    });
  }

  /// Complete workout in cloud in background
  void _completeWorkoutInCloudBackground({
    required WorkoutModel workoutModel,
    required String userEmail,
  }) {
    Future(() async {
      try {
        if (await hasConnection) {
          await _remoteDataSource.saveCompletedWorkout(workoutModel, userEmail);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Background cloud complete workout failed: $e');
        }
      }
    });
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

  /// Dispose of resources
  /// MEMORY LEAK FIX: Properly cancel stream subscription
  void dispose() {
    // 1. CRITICAL: Set disposed flag first to prevent operations after dispose
    _isDisposed = true;

    // 2. Cancel auth state changes subscription
    _userProfileSubscription?.cancel();
    _userProfileSubscription = null;

    // 3. Clear cached user profile
    _cachedUserProfile = null;

    if (kDebugMode) {
      debugPrint('✅ HybridWorkoutRepositoryImpl disposed');
      debugPrint('   - Auth state subscription cancelled');
    }
  }
}