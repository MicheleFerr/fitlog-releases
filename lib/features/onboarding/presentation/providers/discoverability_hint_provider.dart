import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/onboarding/domain/models/hint_config.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/discoverability_hint_service.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/tutorial_state_notifier.dart';

/// Singleton instance of the hint service.
/// Uses keepAlive to prevent disposal (expensive singleton).
final discoverabilityHintServiceProvider =
    Provider<DiscoverabilityHintService>((ref) {
  ref.keepAlive();
  return DiscoverabilityHintService();
});

/// Provider for the currently active hint.
///
/// Returns the active HintConfig if a hint is being displayed, null otherwise.
/// Widget pattern renderers watch this to know what to show.
final activeHintProvider = Provider<HintConfig?>((ref) {
  // Watch tutorial state for reactivity (changes trigger re-evaluation)
  ref.watch(tutorialStateProvider);
  final service = ref.read(discoverabilityHintServiceProvider);
  return service.activeHint;
});

/// Provider that checks if a specific hint should be shown.
///
/// Usage in widgets:
/// ```dart
/// final shouldShow = ref.watch(shouldShowHintProvider('tap_complete_set'));
/// if (shouldShow) { /* render hint widget */ }
/// ```
final shouldShowHintProvider = Provider.family<bool, String>((ref, hintId) {
  final tutorialState = ref.watch(tutorialStateProvider);
  final service = ref.read(discoverabilityHintServiceProvider);
  return service.shouldShow(hintId, tutorialState);
});

/// Provider to get the next best hint from the priority queue.
///
/// Returns a FutureProvider since the service uses a Lock internally.
/// Widgets that show proactive hints should watch this.
final nextHintProvider = FutureProvider<HintConfig?>((ref) async {
  final tutorialState = ref.watch(tutorialStateProvider);
  final service = ref.read(discoverabilityHintServiceProvider);
  return service.getNextHint(tutorialState);
});

/// Notifier for hint lifecycle actions (show, dismiss, reset).
///
/// Thin provider - delegates all logic to [DiscoverabilityHintService]
/// and persistence to [TutorialStateNotifier].
final hintActionsProvider =
    NotifierProvider<HintActionsNotifier, void>(HintActionsNotifier.new);

class HintActionsNotifier extends Notifier<void> {
  @override
  void build() {
    // No state needed - this is an action-only notifier
  }

  DiscoverabilityHintService get _service =>
      ref.read(discoverabilityHintServiceProvider);

  /// Show a hint and update service state.
  ///
  /// Call this when a hint widget appears on screen.
  /// Does NOT persist - call [dismissHint] or [completeHint] to persist.
  void showHint(HintConfig hint) {
    _service.markHintShown(hint);
    ref.invalidate(activeHintProvider);
    ref.invalidate(nextHintProvider);
  }

  /// Dismiss the active hint with cooldown (for non-permanent hints).
  ///
  /// Uses [TutorialStateNotifier.dismissHint] for 24h cooldown.
  Future<void> dismissHint(String hintId) async {
    _service.markHintDismissed();
    await ref.read(tutorialStateProvider.notifier).dismissHint(hintId);
    ref.invalidate(activeHintProvider);
    ref.invalidate(nextHintProvider);
  }

  /// Complete a hint permanently (for permanent hints).
  ///
  /// Uses [TutorialStateNotifier.markTutorialSeen] for permanent dismiss.
  Future<void> completeHint(String hintId) async {
    _service.markHintDismissed();
    await ref.read(tutorialStateProvider.notifier).markTutorialSeen(hintId);
    ref.invalidate(activeHintProvider);
    ref.invalidate(nextHintProvider);
  }

  /// Reset session counters (call on app restart/new session).
  void resetSession() {
    _service.resetSession();
    ref.invalidate(activeHintProvider);
    ref.invalidate(nextHintProvider);
  }

  /// Reset everything for testing: tutorial state + session counters.
  /// All hints will be eligible, including workout-gated ones.
  Future<void> resetAllForTesting() async {
    await ref.read(tutorialStateProvider.notifier).resetAllTutorials();
    _service.resetSession();
    ref.invalidate(activeHintProvider);
    ref.invalidate(nextHintProvider);
    ref.invalidate(shouldShowHintProvider);
  }
}
