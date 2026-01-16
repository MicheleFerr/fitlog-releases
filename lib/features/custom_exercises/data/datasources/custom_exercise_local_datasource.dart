/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: data/datasources
/// 🎯 Feature: custom_exercises
/// 🔧 Type: datasource
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Hive (local storage)
/// - Domain entities
library;

import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Local Hive data source for custom exercise storage
/// Provides persistent storage for user-created custom exercises
///
/// ✅ Uses LazyBox for memory efficiency - only loads entries when accessed
/// ✅ All keys are user-scoped for multi-user support
/// ✅ Follows pattern from UserExercisePreferencesRepository
class CustomExerciseLocalDatasource {
  /// Constructor with dependency injection
  CustomExerciseLocalDatasource([HiveBoxManagerEnhanced? boxManager])
      : _boxManager = boxManager ?? HiveBoxManagerEnhanced();

  static const String _boxName = 'custom_exercises';

  final HiveBoxManagerEnhanced _boxManager;
  LazyBox<CustomExercise>? _box;

  /// Flag to track if init failed (prevents repeated failing attempts)
  bool _initFailed = false;

  /// Initialize the custom exercises storage with corruption recovery
  Future<void> init() async {
    // Skip if init already failed to prevent repeated errors
    if (_initFailed) {
      if (kDebugMode) {
        debugPrint('⚠️ [CustomExerciseLocalDatasource] Skipping init - previous attempt failed');
      }
      return;
    }

    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await _boxManager.openLazyBox<CustomExercise>(_boxName);
      } else {
        _box = Hive.lazyBox<CustomExercise>(_boxName);
      }

      if (kDebugMode) {
        debugPrint('✅ [CustomExerciseLocalDatasource] Initialized successfully');
      }
    } on BoxCorruptedException catch (e) {
      // HiveBoxManagerEnhanced already deleted corrupted box, box is recreated empty
      if (kDebugMode) {
        debugPrint('⚠️ [CustomExerciseLocalDatasource] Box was corrupted and recovered: $e');
      }
      // Try again - box should be recreated
      try {
        _box = await _boxManager.openLazyBox<CustomExercise>(_boxName);
      } catch (retryError) {
        _initFailed = true;
        if (kDebugMode) {
          debugPrint('❌ [CustomExerciseLocalDatasource] Init failed after corruption recovery: $retryError');
        }
      }
    } on BoxOpenException catch (e) {
      _initFailed = true;
      if (kDebugMode) {
        debugPrint('❌ [CustomExerciseLocalDatasource] Failed to open box: $e');
      }
    } catch (e) {
      _initFailed = true;
      if (kDebugMode) {
        debugPrint('❌ [CustomExerciseLocalDatasource] Unexpected init error: $e');
      }
    }
  }

  /// Generate user-scoped key for custom exercise
  String _userKey(String exerciseId) {
    return userCacheKeys.userScopedKey('custom_exercise_$exerciseId');
  }

  /// Save custom exercise locally
  Future<void> save(CustomExercise exercise) async {
    try {
      await init();
      if (_box == null || _initFailed) return;

      final userKey = _userKey(exercise.id);
      await _box?.put(userKey, exercise);

      if (kDebugMode) {
        debugPrint('✅ Custom exercise saved: ${exercise.nome}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to save custom exercise: $e');
      }
    }
  }

  /// Delete custom exercise by ID
  Future<void> delete(String id) async {
    try {
      await init();
      if (_box == null || _initFailed) return;

      final userKey = _userKey(id);
      await _box?.delete(userKey);

      if (kDebugMode) {
        debugPrint('✅ Custom exercise deleted: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to delete custom exercise: $e');
      }
    }
  }

  /// Get all custom exercises for current user
  ///
  /// Returns only active exercises (not expired).
  /// Sorted by creation date (newest first).
  ///
  /// 🔒 USER ISOLATION: Only returns exercises for current user
  Future<List<CustomExercise>> getAll() async {
    try {
      await init();
      if (_box == null || _initFailed) return [];

      final currentUserId = userCacheKeys.currentUserId;
      if (currentUserId == null) {
        if (kDebugMode) {
          debugPrint('⚠️ [CustomExerciseLocalDatasource] No user logged in');
        }
        return [];
      }

      final exercises = <CustomExercise>[];

      // 🔒 FIX: Only iterate keys belonging to current user
      final userPrefix = 'custom_exercise_';
      final userSuffix = '_$currentUserId';

      for (final key in _box!.keys) {
        final keyStr = key.toString();
        // Only process keys that belong to current user
        if (keyStr.startsWith(userPrefix) && keyStr.endsWith(userSuffix)) {
          final exercise = await _box?.get(key);
          if (exercise != null && exercise.isActive) {
            exercises.add(exercise);
          }
        }
      }

      // Sort by creation date (newest first)
      exercises.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return exercises;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get all custom exercises: $e');
      }
      return [];
    }
  }

  /// Get custom exercise by ID
  Future<CustomExercise?> getById(String id) async {
    try {
      await init();
      if (_box == null || _initFailed) return null;

      final userKey = _userKey(id);
      final exercise = await _box?.get(userKey);

      // Return only if active (not expired)
      if (exercise != null && exercise.isActive) {
        return exercise;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get custom exercise by ID: $e');
      }
      return null;
    }
  }

  /// Find custom exercise by name (case-insensitive)
  Future<CustomExercise?> findByName(String exerciseName) async {
    final all = await getAll();
    final lowerCaseName = exerciseName.toLowerCase();

    try {
      return all.firstWhere(
        (exercise) => exercise.nome.toLowerCase() == lowerCaseName,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get count of permanent custom exercises
  Future<int> getPermanentCount() async {
    final all = await getAll();
    return all.where((exercise) => exercise.isPermanent).length;
  }

  /// Extend unlock for temporary exercise
  Future<void> extendUnlock(String id, {int days = 7}) async {
    final exercise = await getById(id);
    if (exercise == null) {
      if (kDebugMode) {
        debugPrint('❌ Cannot extend unlock: Exercise not found');
      }
      return;
    }

    if (exercise.isPermanent) {
      if (kDebugMode) {
        debugPrint('⚠️ Cannot extend permanent exercise');
      }
      return;
    }

    // Calculate new expiration date
    final now = DateTime.now();
    final currentExpiry = exercise.unlockedUntil ?? now;
    final newExpiry = (currentExpiry.isAfter(now) ? currentExpiry : now)
        .add(Duration(days: days));

    final updated = exercise.copyWith(unlockedUntil: newExpiry);
    await save(updated);

    if (kDebugMode) {
      debugPrint('⏱️ Extended unlock for "${exercise.nome}" by $days days (expires: $newExpiry)');
    }
  }

  /// Watch for custom exercise changes
  ///
  /// Returns Stream of List of CustomExercise that emits on any change
  Stream<List<CustomExercise>> watchAll() async* {
    await init();
    if (_box == null || _initFailed) {
      yield [];
      return;
    }

    // Initial load
    yield await getAll();

    // Watch for changes
    await for (final _ in _box!.watch()) {
      // Re-fetch all exercises on any change
      yield await getAll();
    }
  }

  /// Clear all custom exercises for current user
  ///
  /// Warning: This is destructive and cannot be undone.
  /// Only use for account reset or testing.
  Future<void> clear() async {
    try {
      await init();
      if (_box == null || _initFailed) return;

      // Only delete keys belonging to current user
      final currentUserId = userCacheKeys.currentUserId;
      if (currentUserId == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Cannot clear - no user logged in');
        }
        return;
      }

      final userPrefix = 'custom_exercise_$currentUserId';
      final keysToDelete = _box!.keys
          .where((key) => key.toString().startsWith(userPrefix))
          .toList();

      for (final key in keysToDelete) {
        await _box?.delete(key);
      }

      if (kDebugMode) {
        debugPrint('✅ All custom exercises cleared for user: $currentUserId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to clear custom exercises: $e');
      }
    }
  }

  /// Get all expired custom exercises (for cleanup)
  ///
  /// Returns list of custom exercises that have passed their unlock deadline.
  ///
  /// 🔒 USER ISOLATION: Only returns exercises for current user
  Future<List<CustomExercise>> getExpired() async {
    try {
      await init();
      if (_box == null || _initFailed) return [];

      final currentUserId = userCacheKeys.currentUserId;
      if (currentUserId == null) {
        if (kDebugMode) {
          debugPrint('⚠️ [CustomExerciseLocalDatasource] No user logged in');
        }
        return [];
      }

      final expired = <CustomExercise>[];

      // 🔒 FIX: Only iterate keys belonging to current user
      final userPrefix = 'custom_exercise_';
      final userSuffix = '_$currentUserId';

      for (final key in _box!.keys) {
        final keyStr = key.toString();
        // Only process keys that belong to current user
        if (keyStr.startsWith(userPrefix) && keyStr.endsWith(userSuffix)) {
          final exercise = await _box?.get(key);
          if (exercise != null && exercise.isExpired) {
            expired.add(exercise);
          }
        }
      }

      return expired;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get expired custom exercises: $e');
      }
      return [];
    }
  }

  /// Get custom exercises based on base exercise ID
  ///
  /// Returns all variants created from a specific base exercise.
  ///
  /// 🔒 USER ISOLATION: Only returns exercises for current user
  Future<List<CustomExercise>> getVariantsOf(String baseExerciseId) async {
    try {
      await init();
      if (_box == null || _initFailed) return [];

      final currentUserId = userCacheKeys.currentUserId;
      if (currentUserId == null) {
        if (kDebugMode) {
          debugPrint('⚠️ [CustomExerciseLocalDatasource] No user logged in');
        }
        return [];
      }

      final variants = <CustomExercise>[];

      // 🔒 FIX: Only iterate keys belonging to current user
      final userPrefix = 'custom_exercise_';
      final userSuffix = '_$currentUserId';

      for (final key in _box!.keys) {
        final keyStr = key.toString();
        // Only process keys that belong to current user
        if (keyStr.startsWith(userPrefix) && keyStr.endsWith(userSuffix)) {
          final exercise = await _box?.get(key);
          if (exercise != null &&
              exercise.isActive &&
              exercise.baseExerciseId == baseExerciseId) {
            variants.add(exercise);
          }
        }
      }

      return variants;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get variants: $e');
      }
      return [];
    }
  }

  /// Get count of active custom exercises for current user
  ///
  /// Performance: Fast - only counts keys, doesn't load data
  Future<int> getActiveCount() async {
    try {
      await init();
      if (_box == null || _initFailed) return 0;

      final currentUserId = userCacheKeys.currentUserId;
      if (currentUserId == null) return 0;

      final userPrefix = 'custom_exercise_$currentUserId';
      int count = 0;

      // Count active exercises
      for (final key in _box!.keys) {
        if (key.toString().startsWith(userPrefix)) {
          final exercise = await _box?.get(key);
          if (exercise != null && exercise.isActive) {
            count++;
          }
        }
      }

      return count;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to count custom exercises: $e');
      }
      return 0;
    }
  }

  /// Export custom exercises for backup
  Future<Map<String, dynamic>?> exportCustomExercises() async {
    final exercises = await getAll();

    if (exercises.isEmpty) return null;

    final userId = userCacheKeys.currentUserId;

    return {
      'exportDate': DateTime.now().toIso8601String(),
      'userId': userId,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'count': exercises.length,
      'version': '1.0.0',
    };
  }

  /// Import custom exercises from backup
  Future<void> importCustomExercises(Map<String, dynamic> data) async {
    if (data['exercises'] != null) {
      final exercisesList = data['exercises'] as List;
      for (final exerciseJson in exercisesList) {
        try {
          final exercise = CustomExercise.fromJson(exerciseJson);
          await save(exercise);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Failed to import exercise: $e');
          }
        }
      }

      if (kDebugMode) {
        debugPrint('📥 Imported ${exercisesList.length} custom exercises');
      }
    }
  }

  /// Close the box to free memory
  Future<void> dispose() async {
    try {
      if (_box != null && _box!.isOpen) {
        await _box!.close();
        _box = null;
        if (kDebugMode) {
          debugPrint('✅ CustomExerciseLocalDatasource disposed');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error disposing CustomExerciseLocalDatasource: $e');
      }
    }
  }
}
