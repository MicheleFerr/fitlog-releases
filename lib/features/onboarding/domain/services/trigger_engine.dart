import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/events/tutorial_event.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/models/tutorial_definition.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/registry/tutorial_registry.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/tutorial_state_notifier.dart';

/// Callback type for showing tutorial overlay.
///
/// Parameters:
/// - [tutorial]: The tutorial definition to show
/// - [targetLink]: LayerLink for positioning (optional)
/// - [targetKey]: GlobalKey for target widget (optional)
typedef ShowTutorialCallback = void Function(
  TutorialDefinition tutorial, {
  LayerLink? targetLink,
  GlobalKey? targetKey,
});

/// Provider for TriggerEngine.
///
/// Requires a ShowTutorialCallback to be set via [setShowCallback]
/// before processing events.
final triggerEngineProvider = Provider<TriggerEngine>((ref) {
  return TriggerEngine(ref);
});

/// Engine that processes tutorial events and triggers overlay display.
///
/// ## Responsibilities:
/// - Receive TutorialEvents from widgets
/// - Look up tutorials in TutorialRegistry
/// - Verify conditions (seen? cooldown?)
/// - Coordinate overlay display via callback
///
/// ## Anti-Spam Rules:
/// - 2 minute cooldown between tutorials
/// - 24 hour cooldown after dismiss (proactive hints)
/// - Max 1 proactive hint per session
/// - 5 second auto-hide duration
///
/// ## Usage:
/// ```dart
/// // In widget
/// ref.read(triggerEngineProvider).emit(SetInputTapped());
///
/// // With positioning
/// ref.read(triggerEngineProvider).emit(
///   SetInputTapped(),
///   targetLink: _layerLink,
///   targetKey: _inputKey,
/// );
/// ```
class TriggerEngine {
  TriggerEngine(this._ref);

  final Ref _ref;

  /// Callback to show tutorial overlay.
  ShowTutorialCallback? _showCallback;

  /// Last time a tutorial was shown (for cooldown).
  DateTime? _lastTutorialTime;

  /// Count of proactive hints shown this session.
  int _proactiveHintsShown = 0;

  /// Cooldown duration between tutorials.
  static const _tutorialCooldown = Duration(minutes: 2);

  /// Max proactive hints per session.
  static const _maxProactivePerSession = 1;

  /// Set the callback for showing tutorials.
  /// Must be called before [emit] will work.
  void setShowCallback(ShowTutorialCallback callback) {
    _showCallback = callback;
  }

  /// Emit a tutorial event.
  ///
  /// This is the main entry point for triggering tutorials.
  /// Widgets call this when user performs an action that might
  /// trigger a tutorial.
  ///
  /// Parameters:
  /// - [event]: The tutorial event to process
  /// - [targetLink]: Optional LayerLink for overlay positioning
  /// - [targetKey]: Optional GlobalKey for target widget bounds
  void emit(
    TutorialEvent event, {
    LayerLink? targetLink,
    GlobalKey? targetKey,
  }) {
    if (_showCallback == null) {
      debugPrint('⚠️ TriggerEngine: showCallback not set, ignoring event');
      return;
    }

    // Get current state
    final state = _ref.read(tutorialStateProvider);

    // Check if tutorials are globally enabled
    if (!state.tutorialsEnabled) {
      debugPrint('📚 TriggerEngine: Tutorials disabled globally, ignoring');
      return;
    }

    // Look up tutorial for this event
    final tutorial = TutorialRegistry.findTutorial(event);
    if (tutorial == null) {
      debugPrint('📚 TriggerEngine: No tutorial for ${event.runtimeType}');
      return;
    }

    // Check if tutorial should be shown (using state already loaded above)
    if (!tutorial.shouldShow(state, event)) {
      debugPrint('📚 TriggerEngine: Condition not met for ${tutorial.id}');
      return;
    }

    // Apply anti-spam rules
    if (!_passesAntiSpamRules(tutorial)) {
      debugPrint('📚 TriggerEngine: Anti-spam blocked ${tutorial.id}');
      return;
    }

    // Show the tutorial
    debugPrint('🎯 TriggerEngine: Showing tutorial ${tutorial.id}');
    _lastTutorialTime = DateTime.now();

    if (tutorial.type == TutorialType.proactive) {
      _proactiveHintsShown++;
    }

    _showCallback!(
      tutorial,
      targetLink: targetLink,
      targetKey: targetKey,
    );
  }

  /// Check if event passes anti-spam rules.
  bool _passesAntiSpamRules(TutorialDefinition tutorial) {
    // Check cooldown between tutorials
    if (_lastTutorialTime != null) {
      final elapsed = DateTime.now().difference(_lastTutorialTime!);
      if (elapsed < _tutorialCooldown) {
        debugPrint(
          '📚 TriggerEngine: Cooldown active '
          '(${elapsed.inSeconds}s < ${_tutorialCooldown.inSeconds}s)',
        );
        return false;
      }
    }

    // Check proactive hint limit
    if (tutorial.type == TutorialType.proactive) {
      if (_proactiveHintsShown >= _maxProactivePerSession) {
        debugPrint(
          '📚 TriggerEngine: Max proactive hints reached '
          '($_proactiveHintsShown >= $_maxProactivePerSession)',
        );
        return false;
      }

      // Check 24h dismiss cooldown for proactive hints
      final state = _ref.read(tutorialStateProvider);
      if (!state.canShowHint(tutorial.id)) {
        debugPrint('📚 TriggerEngine: 24h dismiss cooldown active');
        return false;
      }
    }

    return true;
  }

  /// Mark a tutorial as seen.
  /// Call this when user dismisses or completes a tutorial.
  Future<void> markSeen(String tutorialId) async {
    await _ref.read(tutorialStateProvider.notifier).markTutorialSeen(tutorialId);
  }

  /// Dismiss a proactive hint.
  /// Starts 24h cooldown for this hint.
  Future<void> dismissHint(String hintId) async {
    await _ref.read(tutorialStateProvider.notifier).dismissHint(hintId);
  }

  /// Reset session state (proactive hint counter).
  /// Call this when app is backgrounded/resumed.
  void resetSession() {
    _proactiveHintsShown = 0;
    debugPrint('📚 TriggerEngine: Session reset');
  }

  /// Get remaining cooldown duration.
  /// Returns Duration.zero if no cooldown active.
  Duration get remainingCooldown {
    if (_lastTutorialTime == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_lastTutorialTime!);
    if (elapsed >= _tutorialCooldown) return Duration.zero;
    return _tutorialCooldown - elapsed;
  }

  /// Check if engine is ready to show tutorials.
  bool get isReady => _showCallback != null;

  /// Debug method to print engine state.
  void debugState() {
    debugPrint('=== 🎯 TriggerEngine State ===');
    debugPrint('Ready: $isReady');
    debugPrint('Last tutorial: $_lastTutorialTime');
    debugPrint('Cooldown remaining: ${remainingCooldown.inSeconds}s');
    debugPrint('Proactive hints shown: $_proactiveHintsShown');
    debugPrint('==============================');
  }
}

// ============ CONVENIENCE EXTENSION ============

/// Extension for easy tutorial event emission from widgets.
extension TutorialEventEmitter on WidgetRef {
  /// Emit a tutorial event.
  ///
  /// Usage:
  /// ```dart
  /// ref.emitTutorial(SetInputTapped());
  /// ```
  void emitTutorial(
    TutorialEvent event, {
    LayerLink? targetLink,
    GlobalKey? targetKey,
  }) {
    read(triggerEngineProvider).emit(
      event,
      targetLink: targetLink,
      targetKey: targetKey,
    );
  }
}
