import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/user_exercise_preferences.dart';

/// Repository for managing user exercise preferences (Form Cues)
///
/// Uses LazyBox for memory efficiency - only loads entries when accessed.
/// All keys are user-scoped for multi-user support.
class UserExercisePreferencesRepository {
  UserExercisePreferencesRepository([HiveBoxManagerEnhanced? boxManager])
    : _boxManager = boxManager ?? HiveBoxManagerEnhanced();

  static const String _boxName = 'user_exercise_preferences';

  final HiveBoxManagerEnhanced _boxManager;
  LazyBox<UserExercisePreferences>? _preferencesBox;

  /// Flag to track if init failed (prevents repeated failing attempts)
  bool _initFailed = false;

  /// Initialize the preferences storage with corruption recovery
  Future<void> init() async {
    // Skip if init already failed to prevent repeated errors
    if (_initFailed) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [UserExercisePreferencesRepository] Skipping init - previous attempt failed',
        );
      }
      return;
    }

    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _preferencesBox = await _boxManager
            .openLazyBox<UserExercisePreferences>(_boxName);
      } else {
        _preferencesBox = Hive.lazyBox<UserExercisePreferences>(_boxName);
      }

      if (kDebugMode) {
        debugPrint(
          '✅ [UserExercisePreferencesRepository] Initialized successfully',
        );
      }
    } on BoxCorruptedException catch (e) {
      // HiveBoxManagerEnhanced already deleted corrupted box, box is recreated empty
      if (kDebugMode) {
        debugPrint(
          '⚠️ [UserExercisePreferencesRepository] Box was corrupted and recovered: $e',
        );
      }
      // Try again - box should be recreated
      try {
        _preferencesBox = await _boxManager
            .openLazyBox<UserExercisePreferences>(_boxName);
      } catch (retryError) {
        _initFailed = true;
        if (kDebugMode) {
          debugPrint(
            '❌ [UserExercisePreferencesRepository] Init failed after corruption recovery: $retryError',
          );
        }
      }
    } on BoxOpenException catch (e) {
      _initFailed = true;
      if (kDebugMode) {
        debugPrint(
          '❌ [UserExercisePreferencesRepository] Failed to open box: $e',
        );
      }
    } catch (e) {
      _initFailed = true;
      if (kDebugMode) {
        debugPrint(
          '❌ [UserExercisePreferencesRepository] Unexpected init error: $e',
        );
      }
    }
  }

  /// Generate user-scoped key for exercise preferences
  String _userKey(String exerciseKey) {
    return userCacheKeys.userScopedKey('exercise_prefs_$exerciseKey');
  }

  /// Get form cues for a specific exercise
  ///
  /// Returns null if no form cues are set for this exercise.
  ///
  /// [exerciseId] - Optional unique exercise ID (preferred)
  /// [exerciseName] - Display name of the exercise (fallback if no ID)
  Future<String?> getFormCues(String? exerciseId, String exerciseName) async {
    try {
      await init();
      if (_preferencesBox == null || _initFailed) return null;

      final key = UserExercisePreferences.generateKey(exerciseId, exerciseName);
      final userKey = _userKey(key);

      final preferences = await _preferencesBox?.get(userKey);
      return preferences?.formCues;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get form cues for $exerciseName: $e');
      }
      return null;
    }
  }

  /// Save form cues for a specific exercise
  ///
  /// Creates new preferences entry if none exists, updates existing otherwise.
  /// Pass null for [formCues] to delete the form cues.
  ///
  /// [exerciseId] - Optional unique exercise ID (preferred)
  /// [exerciseName] - Display name of the exercise
  /// [formCues] - The form cues text to save (null to delete)
  Future<void> saveFormCues(
    String? exerciseId,
    String exerciseName,
    String? formCues,
  ) async {
    try {
      await init();
      if (_preferencesBox == null || _initFailed) return;

      final key = UserExercisePreferences.generateKey(exerciseId, exerciseName);
      final userKey = _userKey(key);

      // If formCues is null or empty, delete the entry
      if (formCues == null || formCues.trim().isEmpty) {
        await _preferencesBox?.delete(userKey);
        if (kDebugMode) {
          debugPrint('✅ Form cues deleted for $exerciseName');
        }
        return;
      }

      // Get existing preferences or create new
      final existing = await _preferencesBox?.get(userKey);

      final preferences =
          existing?.copyWith(
            formCues: formCues,
            updatedAt: DateTime.now(),
            needsSync: true, // Mark for premium Firebase sync
          ) ??
          UserExercisePreferences(
            visibleId: key,
            exerciseName: exerciseName,
            formCues: formCues,
            updatedAt: DateTime.now(),
            needsSync: true,
          );

      await _preferencesBox?.put(userKey, preferences);

      if (kDebugMode) {
        debugPrint('✅ Form cues saved for $exerciseName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to save form cues for $exerciseName: $e');
      }
    }
  }

  /// Check if exercise has form cues set
  ///
  /// [exerciseId] - Optional unique exercise ID (preferred)
  /// [exerciseName] - Display name of the exercise
  Future<bool> hasFormCues(String? exerciseId, String exerciseName) async {
    try {
      await init();
      if (_preferencesBox == null || _initFailed) return false;

      final key = UserExercisePreferences.generateKey(exerciseId, exerciseName);
      final userKey = _userKey(key);

      final preferences = await _preferencesBox?.get(userKey);
      return preferences?.formCues != null && preferences!.formCues!.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to check form cues for $exerciseName: $e');
      }
      return false;
    }
  }

  /// Get all exercises with form cues (for display in lists)
  ///
  /// Returns a list of all UserExercisePreferences that have form cues set.
  Future<List<UserExercisePreferences>> getAllWithFormCues() async {
    try {
      await init();
      if (_preferencesBox == null || _initFailed) return [];

      final allPreferences = <UserExercisePreferences>[];

      // LazyBox requires iterating through keys
      for (final key in _preferencesBox!.keys) {
        final pref = await _preferencesBox?.get(key);
        if (pref != null &&
            pref.formCues != null &&
            pref.formCues!.isNotEmpty) {
          allPreferences.add(pref);
        }
      }

      return allPreferences;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get all form cues: $e');
      }
      return [];
    }
  }

  /// Get preferences that need Firebase sync (premium feature)
  ///
  /// Returns list of preferences with needsSync flag set to true.
  Future<List<UserExercisePreferences>> getPendingSyncPreferences() async {
    try {
      await init();
      if (_preferencesBox == null || _initFailed) return [];

      final pendingSync = <UserExercisePreferences>[];

      for (final key in _preferencesBox!.keys) {
        final pref = await _preferencesBox?.get(key);
        if (pref != null && pref.needsSync) {
          pendingSync.add(pref);
        }
      }

      return pendingSync;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get pending sync preferences: $e');
      }
      return [];
    }
  }

  /// Mark preference as synced (clear needsSync flag)
  ///
  /// [exerciseId] - Optional unique exercise ID (preferred)
  /// [exerciseName] - Display name of the exercise
  Future<void> markAsSynced(String? exerciseId, String exerciseName) async {
    try {
      await init();
      if (_preferencesBox == null || _initFailed) return;

      final key = UserExercisePreferences.generateKey(exerciseId, exerciseName);
      final userKey = _userKey(key);

      final preferences = await _preferencesBox?.get(userKey);
      if (preferences != null) {
        final updated = preferences.copyWith(needsSync: false);
        await _preferencesBox?.put(userKey, updated);

        if (kDebugMode) {
          debugPrint('✅ Preferences marked as synced for $exerciseName');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to mark as synced for $exerciseName: $e');
      }
    }
  }

  /// Clear all preferences (for testing or account reset)
  Future<void> clearAll() async {
    try {
      await init();
      if (_preferencesBox == null || _initFailed) return;

      await _preferencesBox?.clear();

      if (kDebugMode) {
        debugPrint('✅ All exercise preferences cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to clear preferences: $e');
      }
    }
  }

  /// Close the box to free memory
  Future<void> dispose() async {
    try {
      if (_preferencesBox != null && _preferencesBox!.isOpen) {
        await _preferencesBox!.close();
        _preferencesBox = null;
        if (kDebugMode) {
          debugPrint('✅ UserExercisePreferencesRepository disposed');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error disposing UserExercisePreferencesRepository: $e');
      }
    }
  }
}
