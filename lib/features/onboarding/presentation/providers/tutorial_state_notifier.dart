import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/tutorial_state.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

/// Provider for the new contextual tutorial system.
///
/// This replaces the complex legacy onboarding system with:
/// - Zero upfront onboarding
/// - Just-in-time contextual tutorials
/// - Behavior-triggered overlays
/// - Anti-spam protection (cooldowns)
final tutorialStateProvider =
    NotifierProvider<TutorialStateNotifier, TutorialState>(
  TutorialStateNotifier.new,
);

/// StateNotifier for the contextual tutorial system.
///
/// Manages:
/// - Seen tutorials (behavior-triggered)
/// - Dismissed hints (proactive, with 24h cooldown)
/// - Workout count (for progressive triggers)
/// - Persistence via Hive
class TutorialStateNotifier extends Notifier<TutorialState> {
  static const String _boxName = 'tutorial_state';
  static const String _stateKey = 'state';

  Box<TutorialState>? _box;

  HiveBoxManagerEnhanced get _boxManager => ref.read(hiveBoxManagerProvider);

  @override
  TutorialState build() {
    // Initialize asynchronously, start with empty state
    _initializeTutorialState();
    return TutorialState.initial();
  }

  /// Initialize Hive box and load saved state.
  Future<void> _initializeTutorialState() async {
    try {
      // Register adapter if not already registered
      if (!Hive.isAdapterRegistered(60)) {
        Hive.registerAdapter(TutorialStateAdapter());
      }

      // Open or get existing box
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await _boxManager.openBox<TutorialState>(_boxName);
      } else {
        _box = Hive.box<TutorialState>(_boxName);
      }

      // Load saved state
      final savedState = _box!.get(_stateKey);
      if (savedState != null) {
        state = savedState;
        if (kDebugMode) {
          debugPrint(
            '📚 Tutorial state loaded: ${savedState.seenTutorialsList.length} seen, '
            '${savedState.totalWorkouts} workouts',
          );
        }
      } else {
        if (kDebugMode) {
          debugPrint('📚 No saved tutorial state, using initial state');
        }
        // Check for legacy migration
        await _migrateFromLegacyOnboarding();
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Tutorial state initialization failed: $e');
      }
      debugPrint('📍 Stack trace: $stackTrace');
      // Continue with default state on error
      state = TutorialState.initial();
    }
  }

  /// Migrate from legacy OnboardingState if it exists.
  Future<void> _migrateFromLegacyOnboarding() async {
    try {
      const legacyBoxName = 'onboarding_state';
      if (!Hive.isBoxOpen(legacyBoxName)) {
        if (kDebugMode) {
          debugPrint('📚 No legacy onboarding box found, skipping migration');
        }
        return;
      }

      // Use correct type - the box is opened as Box<OnboardingState>
      final legacyBox = Hive.box<OnboardingState>(legacyBoxName);
      final legacyState = legacyBox.get('state');

      if (legacyState == null) {
        if (kDebugMode) {
          debugPrint('📚 No legacy onboarding state found');
        }
        return;
      }

      // Convert legacy state to new format
      final seenTutorials = <String>[];

      // Map legacy fields to new tutorial IDs
      if (legacyState.hasSeenGlobalOnboarding == true) {
        seenTutorials.addAll([
          'logging_set',
          'rest_timer',
          'workout_completion',
        ]);
      }

      for (final overlay in legacyState.seenOverlays) {
        final mapped = _mapLegacyOverlay(overlay);
        if (mapped != null && !seenTutorials.contains(mapped)) {
          seenTutorials.add(mapped);
        }
      }

      // Create new state
      state = TutorialState(
        seenTutorialsList: seenTutorials,
        dismissedHintsList: const [],
        lastDismissTimeList: const [],
        totalWorkouts: legacyState.hasCompletedFirstWorkout ? 1 : 0,
        firstWorkoutDate: legacyState.quickStartCompletedAt,
      );

      await _saveState();
      if (kDebugMode) {
        debugPrint(
          '✅ Migrated from legacy onboarding: ${seenTutorials.length} tutorials marked as seen',
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('⚠️ Legacy migration failed: $e');
      }
      debugPrint('📍 Stack trace: $stackTrace');
      // Continue with default state if migration fails
    }
  }

  /// Map legacy overlay ID to new tutorial ID.
  String? _mapLegacyOverlay(String legacyId) {
    return switch (legacyId) {
      'addFirstExercise' => 'exercise_management',
      'completeFirstWorkout' => 'workout_completion',
      'restTimerExplanation' => 'rest_timer',
      'createWorkoutCTA' => 'logging_set',
      _ => null,
    };
  }

  /// Save state to Hive with retry logic.
  Future<void> _saveState() async {
    if (_box == null || !_box!.isOpen) {
      if (kDebugMode) {
        debugPrint('⚠️ Tutorial box not open, skipping save');
      }
      return;
    }

    int retries = 3;
    while (retries > 0) {
      try {
        await _box!.put(_stateKey, state);
        return; // Success
      } catch (e) {
        retries--;
        if (kDebugMode) {
          debugPrint('❌ Error saving tutorial state (${3 - retries}/3): $e');
        }
        if (retries > 0) {
          await Future.delayed(Duration(milliseconds: 100 * (3 - retries)));
        }
      }
    }
    if (kDebugMode) {
      debugPrint('❌ Failed to save tutorial state after 3 attempts');
    }
  }

  // ============ PUBLIC METHODS ============

  /// Mark a tutorial as seen.
  /// Call this when a tutorial overlay is dismissed or completed.
  Future<void> markTutorialSeen(String tutorialId) async {
    if (state.hasSeen(tutorialId)) return; // Already seen

    state = state.copyWith(
      seenTutorialsList: [...state.seenTutorialsList, tutorialId],
    );
    await _saveState();
    if (kDebugMode) {
      debugPrint('👁️ Tutorial seen: $tutorialId');
    }
  }

  /// Dismiss a proactive hint.
  /// The hint will not be shown again for 24 hours.
  Future<void> dismissHint(String hintId) async {
    final newDismissedList = state.dismissedHintsList.contains(hintId)
        ? state.dismissedHintsList
        : [...state.dismissedHintsList, hintId];

    // Update or add timestamp entry
    final newTimeList = state.lastDismissTimeList
        .where((e) => !e.startsWith('$hintId:'))
        .toList()
      ..add('$hintId:${DateTime.now().toIso8601String()}');

    state = state.copyWith(
      dismissedHintsList: newDismissedList,
      lastDismissTimeList: newTimeList,
    );
    await _saveState();
    if (kDebugMode) {
      debugPrint('🚫 Hint dismissed: $hintId (24h cooldown started)');
    }
  }

  /// Increment workout count.
  /// Call this when a workout is completed.
  Future<void> incrementWorkoutCount() async {
    state = state.copyWith(
      totalWorkouts: state.totalWorkouts + 1,
      firstWorkoutDate: state.firstWorkoutDate ?? DateTime.now(),
    );
    await _saveState();
    if (kDebugMode) {
      debugPrint('💪 Workout completed! Total: ${state.totalWorkouts}');
    }
  }

  /// Reset all seen tutorials (preserves tutorialsEnabled setting).
  /// Call this from Settings when user wants to replay all tutorials.
  Future<void> resetAllTutorials() async {
    state = state.copyWith(
      seenTutorialsList: const [],
      dismissedHintsList: const [],
      lastDismissTimeList: const [],
    );
    await _saveState();
    if (kDebugMode) {
      debugPrint('🔄 All tutorials reset - user can see them again');
    }
  }

  /// Reset all tutorial state including settings (for testing/debugging).
  Future<void> resetTutorialState() async {
    state = TutorialState.initial();
    await _saveState();
    if (kDebugMode) {
      debugPrint('🔄 Tutorial state fully reset');
    }
  }

  /// Toggle tutorials enabled/disabled.
  /// When disabled, no contextual tutorials will be shown.
  Future<void> setTutorialsEnabled(bool enabled) async {
    if (state.tutorialsEnabled == enabled) return;

    state = state.copyWith(tutorialsEnabled: enabled);
    await _saveState();
    if (kDebugMode) {
      debugPrint('🔔 Tutorials ${enabled ? 'enabled' : 'disabled'}');
    }
  }

  /// Debug method to print current state.
  void debugTutorialState() {
    if (kDebugMode) {
      debugPrint('=== 📚 Tutorial State Debug ===');
    }
    debugPrint('Seen tutorials: ${state.seenTutorialsList}');
    if (kDebugMode) {
      debugPrint('Dismissed hints: ${state.dismissedHintsList}');
    }
    debugPrint('Total workouts: ${state.totalWorkouts}');
    if (kDebugMode) {
      debugPrint('First workout: ${state.firstWorkoutDate}');
    }
    debugPrint('Is new user: ${state.isNewUser}');
    if (kDebugMode) {
      debugPrint('==============================');
    }
  }
}

// ============ HELPER PROVIDERS ============

/// Check if a specific tutorial has been seen.
final hasTutorialBeenSeenProvider = Provider.family<bool, String>((ref, tutorialId) {
  final state = ref.watch(tutorialStateProvider);
  return state.hasSeen(tutorialId);
});

/// Check if a hint can be shown (not in cooldown).
final canShowHintProvider = Provider.family<bool, String>((ref, hintId) {
  final state = ref.watch(tutorialStateProvider);
  return state.canShowHint(hintId);
});

/// Get total workout count.
final tutorialWorkoutCountProvider = Provider<int>((ref) {
  final state = ref.watch(tutorialStateProvider);
  return state.totalWorkouts;
});

/// Check if user is considered "new" (< 3 workouts).
final isNewUserProvider = Provider<bool>((ref) {
  final state = ref.watch(tutorialStateProvider);
  return state.isNewUser;
});

/// Check if contextual tutorials are enabled.
final tutorialsEnabledProvider = Provider<bool>((ref) {
  final state = ref.watch(tutorialStateProvider);
  return state.tutorialsEnabled;
});

/// Get count of seen tutorials.
final seenTutorialsCountProvider = Provider<int>((ref) {
  final state = ref.watch(tutorialStateProvider);
  return state.seenTutorialsList.length;
});
