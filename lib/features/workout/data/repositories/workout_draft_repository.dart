import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_draft.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Repository for managing workout drafts in local storage
class WorkoutDraftRepository {
  WorkoutDraftRepository([HiveBoxManagerEnhanced? boxManager])
      : _boxManager = boxManager ?? HiveBoxManagerEnhanced();

  static const String _boxName = 'workout_drafts';
  // 🔐 User-scoped cache keys
  String get _currentDraftKey => userCacheKeys.userScopedKey('current_draft');
  String get _recoveredDraftsKey => userCacheKeys.userScopedKey('recovered_drafts');

  final HiveBoxManagerEnhanced _boxManager;
  Box<WorkoutDraft>? _draftBox;
  Box? _recoveredBox;

  /// Flag to track if init failed (prevents repeated failing attempts)
  bool _initFailed = false;
  /// Flag to track if already initialized successfully
  bool _initialized = false;

  /// Initialize the draft storage with corruption recovery
  Future<void> init() async {
    // ⚡ PERFORMANCE: Skip if already initialized (prevents 5x init messages)
    if (_initialized) return;

    // Skip if init already failed to prevent repeated errors
    if (_initFailed) {
      if (kDebugMode) {
        debugPrint('⚠️ [WorkoutDraftRepository] Skipping init - previous attempt failed');
      }
      return;
    }

    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _draftBox = await _boxManager.openBox<WorkoutDraft>(_boxName);
      } else {
        _draftBox = Hive.box<WorkoutDraft>(_boxName);
      }

      // Initialize recovered drafts box
      if (!Hive.isBoxOpen('recovered_drafts')) {
        _recoveredBox = await _boxManager.openBox('recovered_drafts');
      } else {
        _recoveredBox = Hive.box('recovered_drafts');
      }

      _initialized = true; // ⚡ Mark as initialized to prevent repeated init
      if (kDebugMode) {
        debugPrint('✅ [WorkoutDraftRepository] Initialized successfully');
      }
    } on BoxCorruptedException catch (e) {
      // HiveBoxManagerEnhanced already deleted corrupted box, box is recreated empty
      if (kDebugMode) {
        debugPrint('⚠️ [WorkoutDraftRepository] Box was corrupted and recovered: $e');
      }
      // Try again - box should be recreated
      try {
        _draftBox = await _boxManager.openBox<WorkoutDraft>(_boxName);
        _recoveredBox = await _boxManager.openBox('recovered_drafts');
      } catch (retryError) {
        _initFailed = true;
        if (kDebugMode) {
          debugPrint('❌ [WorkoutDraftRepository] Init failed after corruption recovery: $retryError');
        }
      }
    } on BoxOpenException catch (e) {
      _initFailed = true;
      if (kDebugMode) {
        debugPrint('❌ [WorkoutDraftRepository] Failed to open box: $e');
      }
    } catch (e) {
      _initFailed = true;
      if (kDebugMode) {
        debugPrint('❌ [WorkoutDraftRepository] Unexpected init error: $e');
      }
    }
  }

  /// Save current workout as draft
  Future<void> saveCurrentDraft(Workout workout) async {
    try {
      await init();
      
      final draft = WorkoutDraft.fromWorkout(workout);
      await _draftBox?.put(_currentDraftKey, draft);
      
      if (kDebugMode) {
        debugPrint('✅ Workout draft saved at ${draft.lastSaved}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to save workout draft: $e');
      }
    }
  }

  /// Get current draft if exists
  ///
  /// Handles potential data corruption/incompatibility by:
  /// 1. Catching type casting errors (format changed between app versions)
  /// 2. Deleting corrupted data if unreadable
  /// 3. Returning null safely instead of crashing
  Future<WorkoutDraft?> getCurrentDraft() async {
    try {
      await init();
      if (_draftBox == null || _initFailed) return null;

      final draft = _draftBox?.get(_currentDraftKey);

      // Validate draft is usable (catches partial corruption)
      if (draft != null) {
        try {
          // Test that draft can be converted to workout
          draft.toWorkout();
          return draft;
        } catch (conversionError) {
          // Draft data is corrupted or incompatible with current code
          if (kDebugMode) {
            debugPrint('⚠️ [WorkoutDraftRepository] Draft conversion failed, clearing corrupt data: $conversionError');
          }
          await clearCurrentDraft();
          return null;
        }
      }
      return null;
    } on TypeError catch (e) {
      // Type mismatch - data format changed between app versions
      if (kDebugMode) {
        debugPrint('⚠️ [WorkoutDraftRepository] Type error reading draft (format changed?): $e');
      }
      // Clear corrupted/incompatible data
      await clearCurrentDraft();
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutDraftRepository] Failed to get workout draft: $e');
      }
      return null;
    }
  }

  /// Check if there's a recoverable draft
  Future<bool> hasRecoverableDraft() async {
    final draft = await getCurrentDraft();
    if (draft == null) return false;

    // Don't recover if already recovered or too old
    if (draft.isRecovered || draft.isStale) return false;

    // BUG FIX: Recover if workout has exercises, not just completed sets
    // Users expect workout to be saved even before completing any sets.
    // Previous logic required hasCompletedSets which caused data loss
    // when user closed app before completing any sets.
    final workout = draft.toWorkout();
    final hasExercises = workout.exercises.isNotEmpty;

    return hasExercises;
  }

  /// Recover draft and mark as recovered
  Future<Workout?> recoverDraft() async {
    try {
      final draft = await getCurrentDraft();
      if (draft == null) return null;
      
      // Mark as recovered to prevent showing again
      final recoveredDraft = draft.copyWith(isRecovered: true);
      await _draftBox?.put(_currentDraftKey, recoveredDraft);
      
      // Also save to recovered drafts history
      final existing = _recoveredBox?.get(_recoveredDraftsKey);
      final recoveredList = (existing is List) ? List.from(existing) : [];
      recoveredList.add(recoveredDraft);
      await _recoveredBox?.put(_recoveredDraftsKey, recoveredList);
      
      return draft.toWorkout();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to recover workout draft: $e');
      }
      return null;
    }
  }

  /// Clear current draft (after successful save or user dismissal)
  Future<void> clearCurrentDraft() async {
    try {
      await init();
      await _draftBox?.delete(_currentDraftKey);
      if (kDebugMode) {
        debugPrint('✅ Workout draft cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to clear workout draft: $e');
      }
    }
  }

  /// Get all recovered drafts history
  Future<List<WorkoutDraft>> getRecoveredDrafts() async {
    try {
      await init();
      final drafts = _recoveredBox?.get(_recoveredDraftsKey);
      if (drafts is List) {
        return drafts.whereType<WorkoutDraft>().toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get recovered drafts: $e');
      }
      return [];
    }
  }

  /// Clear old drafts (maintenance)
  Future<void> clearOldDrafts() async {
    try {
      await init();

      // Clear stale current draft
      final current = await getCurrentDraft();
      if (current?.isStale ?? false) {
        await clearCurrentDraft();
      }

      // Clear old recovered drafts (keep last 5)
      final recovered = await getRecoveredDrafts();
      if (recovered.length > 5) {
        final toKeep = recovered.sublist(recovered.length - 5);
        await _recoveredBox?.put(_recoveredDraftsKey, toKeep);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to clear old drafts: $e');
      }
    }
  }

  /// MEMORY LEAK FIX: Close Hive boxes to free memory
  Future<void> dispose() async {
    try {
      int closedCount = 0;

      // Close draft box
      if (_draftBox != null && _draftBox!.isOpen) {
        await _draftBox!.close();
        _draftBox = null;
        closedCount++;
        if (kDebugMode) {
          debugPrint('✅ Closed workout_drafts box');
        }
      }

      // Close recovered box
      if (_recoveredBox != null && _recoveredBox!.isOpen) {
        await _recoveredBox!.close();
        _recoveredBox = null;
        closedCount++;
        if (kDebugMode) {
          debugPrint('✅ Closed recovered_drafts box');
        }
      }

      if (kDebugMode) {
        debugPrint('✅ WorkoutDraftRepository disposed: $closedCount boxes closed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error disposing WorkoutDraftRepository: $e');
      }
    }
  }
}