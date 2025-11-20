/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/data/repositories
/// 🎯 Feature: analytics
/// 🔧 Type: repository
///
/// ExercisePreferencesRepository - Manages Firestore persistence for exercise preferences
///
/// **Responsibilities**:
/// - Read/write user exercise preferences from/to Firestore
/// - Optimize Firestore costs with single document strategy
/// - Debounce writes to reduce write operations
/// - Stream real-time updates
///
/// **Firestore Structure**:
/// ```
/// userExercisePreferences/{userId}
/// {
///   favorites: ['Bench Press', 'Squat'],
///   lastUpdated: Timestamp
/// }
/// ```
///
/// **Cost Optimization**:
/// - ✅ Single document per user (1 read instead of N)
/// - ✅ Debounced writes (500ms) to batch rapid toggles
/// - ✅ Local caching via StateNotifier
/// - ✅ Optimistic updates (UI updates before Firestore)
///
/// **Usage**:
/// ```dart
/// final repo = ref.read(exercisePreferencesRepositoryProvider);
///
/// // Toggle favorite (debounced write)
/// await repo.toggleFavorite('Bench Press');
///
/// // Stream updates
/// final stream = repo.watchPreferences();
/// ```
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/data/models/exercise_preferences_model.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';

/// Repository for exercise preferences with Firestore cost optimization
class ExercisePreferencesRepository {
  ExercisePreferencesRepository({
    required FirebaseFirestore firestore,
    required String userId,
  })  : _firestore = firestore,
        _userId = userId;

  final FirebaseFirestore _firestore;
  final String _userId;

  /// Debounce timer for batching rapid writes
  ///
  /// When user rapidly toggles favorites, we wait 500ms before writing to Firestore
  /// to reduce write operations (cost optimization)
  Timer? _debounceTimer;

  /// Pending favorites state to write
  ///
  /// Used by debounce mechanism to store the latest state
  Set<String>? _pendingFavorites;

  /// Collection reference
  CollectionReference get _collection =>
      _firestore.collection('userExercisePreferences');

  /// Document reference for current user
  DocumentReference get _userDoc => _collection.doc(_userId);

  /// Get exercise preferences (1 read operation)
  ///
  /// Returns null if document doesn't exist (first time user)
  ///
  /// **Firestore Cost**: 1 read
  Future<ExercisePreferencesModel?> getPreferences() async {
    try {
      final doc = await _userDoc.get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      return ExercisePreferencesModel.fromJson(data);
    } catch (e) {
      // Return null on error (provider will use empty set)
      return null;
    }
  }

  /// Watch preferences stream (real-time updates)
  ///
  /// **Firestore Cost**: 1 read on initial load + 1 read per update
  ///
  /// **Optimization**: Only call this when Analytics screen is visible
  /// (avoid background reads)
  Stream<ExercisePreferencesModel?> watchPreferences() {
    return _userDoc.snapshots().map((doc) {
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      return ExercisePreferencesModel.fromJson(data);
    });
  }

  /// Set favorites with debouncing (cost optimization)
  ///
  /// **Debounce**: Waits 500ms before writing to Firestore.
  /// If another call comes within 500ms, restarts timer.
  ///
  /// **Example**: User toggles 3 exercises in 1 second
  /// - Without debounce: 3 writes
  /// - With debounce: 1 write (saves 2 write operations)
  ///
  /// **Firestore Cost**: 1 write (after debounce delay)
  ///
  /// **Parameters**:
  /// - favorites: Complete set of favorite exercise names
  Future<void> setFavorites(Set<String> favorites) async {
    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Store pending state
    _pendingFavorites = favorites;

    // Start new debounce timer (500ms)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (_pendingFavorites == null) return;

      try {
        final model = ExercisePreferencesModel(
          favorites: _pendingFavorites!.toList(),
          lastUpdated: DateTime.now(),
        );

        await _userDoc.set(model.toJson());

        _pendingFavorites = null;
      } catch (e) {
        // Silently fail (UI already updated optimistically)
        // TODO: Add error reporting/retry mechanism
      }
    });
  }

  /// Toggle favorite status for a single exercise
  ///
  /// **Note**: This method requires reading current state first,
  /// which is handled by the provider (local state).
  ///
  /// **Prefer**: Using `setFavorites()` directly from provider
  /// instead of this method.
  ///
  /// **Firestore Cost**: 1 read + 1 write (debounced)
  Future<void> toggleFavorite(String exerciseName) async {
    // Get current favorites
    final current = await getPreferences();
    final currentSet = current?.favoritesSet ?? {};

    // Toggle
    final newSet = Set<String>.from(currentSet);
    if (newSet.contains(exerciseName)) {
      newSet.remove(exerciseName);
    } else {
      newSet.add(exerciseName);
    }

    // Write (debounced)
    await setFavorites(newSet);
  }

  /// Dispose resources
  ///
  /// Call this when provider is disposed to cancel pending debounce timers
  void dispose() {
    _debounceTimer?.cancel();
  }
}

/// Provider for ExercisePreferencesRepository
///
/// Automatically creates repository with current user ID
///
/// **Dependencies**: firebaseUserProvider (for userId)
final exercisePreferencesRepositoryProvider =
    Provider.autoDispose<ExercisePreferencesRepository?>((ref) {
  final user = ref.watch(firebaseUserProvider).valueOrNull;

  if (user == null) return null;

  final repo = ExercisePreferencesRepository(
    firestore: FirebaseFirestore.instance,
    userId: user.uid,
  );

  // Dispose debounce timer when provider is disposed
  ref.onDispose(() => repo.dispose());

  return repo;
});
