/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/custom_exercises/data/repositories
/// 🎯 Feature: custom_exercises
/// 🔧 Type: repository_implementation
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// CUSTOM EXERCISE REPOSITORY IMPLEMENTATION
///
/// Concrete implementation of CustomExerciseRepository interface.
/// Manages local-first storage with optional cloud sync for Premium users.
///
/// **Storage Strategy**:
/// - Local-first: All operations save to Hive immediately
/// - Cloud sync: Background sync for Premium users only
/// - Conflict resolution: Local wins (most recent timestamp)
///
/// **Free Tier**:
/// - 5 permanent custom exercises
/// - Unlimited temporary exercises (7-day expiry)
///
/// **Premium Tier**:
/// - Unlimited permanent custom exercises
/// - Cloud sync across devices
/// - No expiration
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/features/custom_exercises/domain/repositories/custom_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/data/datasources/custom_exercise_local_datasource.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';

// Fix for unawaited futures
// ignore_for_file: unawaited_futures

/// Custom Exercise Repository Implementation
///
/// Implements CustomExerciseRepository with local Hive storage and
/// optional Firestore sync for Premium users.
class CustomExerciseRepositoryImpl implements CustomExerciseRepository {
  CustomExerciseRepositoryImpl({
    required CustomExerciseLocalDatasource localDatasource,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _localDatasource = localDatasource,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final CustomExerciseLocalDatasource _localDatasource;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _firestoreCollection = 'custom_exercises';
  static const int _freeUserLimit = 5;

  // Cache user profile to reduce Firestore queries
  UserProfile? _cachedUserProfile;
  DateTime? _profileCacheTime;
  static const Duration _cacheValidity = Duration(hours: 1);

  /// Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Check if current user is Premium
  Future<bool> _isPremiumUser() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return false;

      // Check cache first
      if (_cachedUserProfile != null &&
          _profileCacheTime != null &&
          DateTime.now().difference(_profileCacheTime!) < _cacheValidity) {
        return _cachedUserProfile!.isPremium;
      }

      // Fetch from Firestore
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return false;

      final data = doc.data();
      if (data == null) return false;

      _cachedUserProfile = UserProfile.fromJson(data);
      _profileCacheTime = DateTime.now();

      return _cachedUserProfile!.isPremium;
    } catch (e) {
      debugPrint('❌ Error checking Premium status: $e');
      return false;
    }
  }

  // ============================================================
  // READ OPERATIONS
  // ============================================================

  @override
  Future<Either<Failure, List<CustomExercise>>> getAll() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      final exercises = await _localDatasource.getAll();
      return right(exercises);
    } catch (e) {
      debugPrint('❌ Failed to get all custom exercises: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CustomExercise>>> getActive() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      // Note: datasource.getAll() already filters for active (non-expired) exercises
      final exercises = await _localDatasource.getAll();
      return right(exercises);
    } catch (e) {
      debugPrint('❌ Failed to get active custom exercises: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomExercise?>> getById(String id) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      final exercise = await _localDatasource.getById(id);
      return right(exercise);
    } catch (e) {
      debugPrint('❌ Failed to get custom exercise by ID: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomExercise?>> findByName(String exerciseName) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      final exercise = await _localDatasource.findByName(exerciseName);
      return right(exercise);
    } catch (e) {
      debugPrint('❌ Failed to find custom exercise by name: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  // ============================================================
  // QUOTA CHECKING
  // ============================================================

  @override
  Future<Either<Failure, int>> getPermanentCount() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      final count = await _localDatasource.getPermanentCount();
      return right(count);
    } catch (e) {
      debugPrint('❌ Failed to get permanent count: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasReachedFreeLimit() async {
    try {
      // Premium users never reach limit
      final isPremium = await _isPremiumUser();
      if (isPremium) return right(false);

      // Check if free user has reached limit
      final countResult = await getPermanentCount();
      return countResult.fold(
        (failure) => left(failure),
        (permanentCount) => right(permanentCount >= _freeUserLimit),
      );
    } catch (e) {
      debugPrint('❌ Failed to check free limit: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  // ============================================================
  // WRITE OPERATIONS
  // ============================================================

  @override
  Future<Either<Failure, void>> save(CustomExercise exercise) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      // Validate free tier limits
      if (exercise.isPermanent) {
        final hasReachedLimit = await hasReachedFreeLimit();
        final limitReached = hasReachedLimit.fold(
          (failure) => false,
          (reached) => reached,
        );

        if (limitReached) {
          return left(
            const QuotaExceededFailure(
              'Free tier limit reached (5 permanent exercises). Upgrade to Premium for unlimited.',
              code: 'QUOTA_EXCEEDED',
            ),
          );
        }
      }

      // Save to local storage
      await _localDatasource.save(exercise);

      // Background sync for Premium users
      final isPremium = await _isPremiumUser();
      if (isPremium) {
        unawaited(_syncToCloudBackground(exercise, userId));
      }

      return right(null);
    } catch (e) {
      debugPrint('❌ Failed to save custom exercise: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> update(CustomExercise exercise) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      // Get existing exercise to check validation rules
      final existingResult = await getById(exercise.id);
      final existing = existingResult.fold(
        (failure) => null,
        (ex) => ex,
      );

      if (existing == null) {
        return left(
          const ValidationFailure('Custom exercise not found', code: 'NOT_FOUND'),
        );
      }

      // Cannot change isPermanent from true to false
      if (existing.isPermanent && !exercise.isPermanent) {
        return left(
          const ValidationFailure(
            'Cannot change permanent exercise to temporary',
            code: 'INVALID_OPERATION',
          ),
        );
      }

      // Cannot change isPermanent from false to true if limit reached
      if (!existing.isPermanent && exercise.isPermanent) {
        final hasReachedLimit = await hasReachedFreeLimit();
        final limitReached = hasReachedLimit.fold(
          (failure) => false,
          (reached) => reached,
        );

        if (limitReached) {
          return left(
            const QuotaExceededFailure(
              'Cannot make permanent: Free tier limit reached',
              code: 'QUOTA_EXCEEDED',
            ),
          );
        }
      }

      // Update local storage
      await _localDatasource.save(exercise);

      // Background sync for Premium users
      final isPremium = await _isPremiumUser();
      if (isPremium) {
        unawaited(_syncToCloudBackground(exercise, userId));
      }

      return right(null);
    } catch (e) {
      debugPrint('❌ Failed to update custom exercise: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      // Delete from local storage
      await _localDatasource.delete(id);

      // Background sync for Premium users
      final isPremium = await _isPremiumUser();
      if (isPremium) {
        unawaited(_deleteFromCloudBackground(id, userId));
      }

      return right(null);
    } catch (e) {
      debugPrint('❌ Failed to delete custom exercise: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> extendUnlock(String id, {int days = 7}) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      await _localDatasource.extendUnlock(id, days: days);

      return right(null);
    } catch (e) {
      debugPrint('❌ Failed to extend unlock: $e');
      return left(CacheFailure(e.toString()));
    }
  }

  // ============================================================
  // REACTIVE STREAMS
  // ============================================================

  @override
  Stream<Either<Failure, List<CustomExercise>>> watchAll() async* {
    final userId = _currentUserId;
    if (userId == null) {
      yield left(const AuthenticationFailure('User not authenticated'));
      return;
    }

    try {
      await for (final exercises in _localDatasource.watchAll()) {
        yield right(exercises);
      }
    } catch (e) {
      debugPrint('❌ Failed to watch all custom exercises: $e');
      yield left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<CustomExercise>>> watchActive() async* {
    final userId = _currentUserId;
    if (userId == null) {
      yield left(const AuthenticationFailure('User not authenticated'));
      return;
    }

    try {
      // Note: datasource.watchAll() already filters for active (non-expired) exercises
      await for (final exercises in _localDatasource.watchAll()) {
        yield right(exercises);
      }
    } catch (e) {
      debugPrint('❌ Failed to watch active custom exercises: $e');
      yield left(CacheFailure(e.toString()));
    }
  }

  // ============================================================
  // CLOUD SYNC (Premium Only)
  // ============================================================

  @override
  Future<Either<Failure, void>> syncToCloud() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      final isPremium = await _isPremiumUser();
      if (!isPremium) {
        return left(
          const PermissionDeniedFailure(
            'Cloud sync requires Premium subscription',
            code: 'NOT_PREMIUM',
          ),
        );
      }

      // Get all local exercises
      final exercisesResult = await getAll();
      final exercises = exercisesResult.fold(
        (failure) => <CustomExercise>[],
        (list) => list,
      );

      // Sync each to Firestore
      final batch = _firestore.batch();
      for (final exercise in exercises) {
        final docRef = _firestore
            .collection(_firestoreCollection)
            .doc(userId)
            .collection('exercises')
            .doc(exercise.id);

        batch.set(docRef, exercise.toJson());
      }

      await batch.commit();
      debugPrint('✅ Synced ${exercises.length} custom exercises to cloud');

      return right(null);
    } catch (e) {
      debugPrint('❌ Failed to sync to cloud: $e');
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> refreshFromCloud() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      final isPremium = await _isPremiumUser();
      if (!isPremium) {
        return left(
          const PermissionDeniedFailure(
            'Cloud sync requires Premium subscription',
            code: 'NOT_PREMIUM',
          ),
        );
      }

      // Fetch from Firestore
      final snapshot = await _firestore
          .collection(_firestoreCollection)
          .doc(userId)
          .collection('exercises')
          .get();

      // Save each to local storage (server wins)
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final exercise = CustomExercise.fromJson(data);
          await _localDatasource.save(exercise);
        } catch (e) {
          debugPrint('⚠️ Failed to parse exercise ${doc.id}: $e');
        }
      }

      debugPrint('✅ Refreshed ${snapshot.docs.length} custom exercises from cloud');

      return right(null);
    } catch (e) {
      debugPrint('❌ Failed to refresh from cloud: $e');
      return left(ServerFailure(e.toString()));
    }
  }

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

  /// Background sync to Firestore (fire and forget)
  Future<void> _syncToCloudBackground(CustomExercise exercise, String userId) async {
    try {
      await _firestore
          .collection(_firestoreCollection)
          .doc(userId)
          .collection('exercises')
          .doc(exercise.id)
          .set(exercise.toJson());

      debugPrint('☁️ Synced custom exercise "${exercise.nome}" to cloud');
    } catch (e) {
      debugPrint('❌ Background sync failed: $e');
    }
  }

  /// Background delete from Firestore (fire and forget)
  Future<void> _deleteFromCloudBackground(String exerciseId, String userId) async {
    try {
      await _firestore
          .collection(_firestoreCollection)
          .doc(userId)
          .collection('exercises')
          .doc(exerciseId)
          .delete();

      debugPrint('☁️ Deleted custom exercise $exerciseId from cloud');
    } catch (e) {
      debugPrint('❌ Background delete failed: $e');
    }
  }
}
