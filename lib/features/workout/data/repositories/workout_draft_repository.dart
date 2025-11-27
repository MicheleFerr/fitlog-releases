import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_draft.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

/// Repository for managing workout drafts in local storage
class WorkoutDraftRepository {
  WorkoutDraftRepository([HiveBoxManagerEnhanced? boxManager])
      : _boxManager = boxManager ?? HiveBoxManagerEnhanced();

  static const String _boxName = 'workout_drafts';
  static const String _currentDraftKey = 'current_draft';
  static const String _recoveredDraftsKey = 'recovered_drafts';

  final HiveBoxManagerEnhanced _boxManager;
  Box<WorkoutDraft>? _draftBox;
  Box? _recoveredBox;

  /// Initialize the draft storage
  Future<void> init() async {
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
  Future<WorkoutDraft?> getCurrentDraft() async {
    try {
      await init();
      return _draftBox?.get(_currentDraftKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get workout draft: $e');
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
    
    // Check if draft has meaningful data
    final workout = draft.toWorkout();
    final hasCompletedSets = workout.exercises.any(
      (exercise) => exercise.sets.any((set) => set.isCompleted)
    );
    
    return hasCompletedSets;
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