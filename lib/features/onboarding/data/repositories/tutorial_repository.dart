import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/tutorial_state.dart';

/// Repository for storing and retrieving tutorial/onboarding state.
///
/// Uses Hive for local persistence. State includes:
/// - Seen tutorials (behavior-triggered)
/// - Dismissed hints (proactive, with 24h cooldown)
/// - Workout count (for progressive triggers)
///
/// This replaces the complex legacy OnboardingState with a simpler
/// contextual tutorial system.
class TutorialRepository {
  static const String _boxName = 'tutorial_state';
  static const String _stateKey = 'state';

  Box<TutorialState>? _box;

  /// Check if repository is initialized.
  bool get isInitialized => _box?.isOpen ?? false;

  /// Initialize Hive box for tutorial state storage.
  /// Must be called before any other method.
  Future<void> initialize() async {
    if (_box?.isOpen ?? false) return;

    // Register adapter if not already registered
    if (!Hive.isAdapterRegistered(60)) {
      Hive.registerAdapter(TutorialStateAdapter());
    }

    _box = await Hive.openBox<TutorialState>(_boxName);
  }

  /// Load tutorial state from storage.
  /// Returns null if no state exists (first launch).
  Future<TutorialState?> loadState() async {
    _ensureInitialized();
    try {
      return _box!.get(_stateKey);
    } catch (e) {
      debugPrint('TutorialRepository: Failed to load state: $e');
      return null;
    }
  }

  /// Save tutorial state to storage.
  Future<void> saveState(TutorialState state) async {
    _ensureInitialized();
    try {
      await _box!.put(_stateKey, state);
    } catch (e) {
      debugPrint('TutorialRepository: Failed to save state: $e');
      rethrow;
    }
  }

  /// Clear all tutorial state (reset to initial).
  /// Useful for testing or when user wants to see tutorials again.
  Future<void> clearState() async {
    _ensureInitialized();
    try {
      await _box!.delete(_stateKey);
    } catch (e) {
      debugPrint('TutorialRepository: Failed to clear state: $e');
      rethrow;
    }
  }

  /// Mark a specific tutorial as seen.
  /// Convenience method that loads, updates, and saves state.
  Future<void> markTutorialSeen(String tutorialId) async {
    _ensureInitialized();
    final current = await loadState() ?? TutorialState.initial();

    if (current.hasSeen(tutorialId)) return; // Already seen

    final updated = current.copyWith(
      seenTutorialsList: [...current.seenTutorialsList, tutorialId],
    );
    await saveState(updated);
  }

  /// Dismiss a hint with cooldown tracking.
  /// Convenience method that loads, updates, and saves state.
  Future<void> dismissHint(String hintId) async {
    _ensureInitialized();
    final current = await loadState() ?? TutorialState.initial();

    final newDismissedList = current.dismissedHintsList.contains(hintId)
        ? current.dismissedHintsList
        : [...current.dismissedHintsList, hintId];

    // Update or add timestamp entry
    final newTimeList = current.lastDismissTimeList
        .where((e) => !e.startsWith('$hintId:'))
        .toList()
      ..add('$hintId:${DateTime.now().toIso8601String()}');

    final updated = current.copyWith(
      dismissedHintsList: newDismissedList,
      lastDismissTimeList: newTimeList,
    );
    await saveState(updated);
  }

  /// Increment workout count.
  /// Convenience method that loads, updates, and saves state.
  Future<void> incrementWorkoutCount() async {
    _ensureInitialized();
    final current = await loadState() ?? TutorialState.initial();

    final updated = current.copyWith(
      totalWorkouts: current.totalWorkouts + 1,
      firstWorkoutDate: current.firstWorkoutDate ?? DateTime.now(),
    );
    await saveState(updated);
  }

  /// Dispose repository and close Hive box.
  Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }

  void _ensureInitialized() {
    if (!isInitialized) {
      throw StateError(
        'TutorialRepository not initialized. Call initialize() first.',
      );
    }
  }
}
