import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/models/tutorial_definition.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/trigger_engine.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/tutorial_state_notifier.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/unified_contextual_overlay.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Provider for TutorialOverlayService.
///
/// Requires initialization with BuildContext via [initialize].
final tutorialOverlayServiceProvider = Provider<TutorialOverlayService>((ref) {
  final service = TutorialOverlayService(ref);

  // Set up the callback for TriggerEngine
  ref.read(triggerEngineProvider).setShowCallback(service.showTutorial);

  return service;
});

/// Service for managing tutorial overlay display.
///
/// ## Features:
/// - Single overlay at a time (auto-removes previous)
/// - Localization support via l10n keys
/// - Fallback to snackbar if positioning fails
/// - Automatic state persistence on dismiss
///
/// ## Usage:
/// ```dart
/// // Initialize early in app lifecycle
/// ref.read(tutorialOverlayServiceProvider).initialize(context);
///
/// // Show tutorial (usually called by TriggerEngine)
/// ref.read(tutorialOverlayServiceProvider).showTutorial(
///   tutorial,
///   targetLink: _layerLink,
///   targetKey: _targetKey,
/// );
/// ```
class TutorialOverlayService {
  TutorialOverlayService(this._ref);

  final Ref _ref;

  /// Current overlay entry (if any).
  OverlayEntry? _currentOverlay;

  /// Currently showing tutorial ID.
  String? _currentTutorialId;

  /// Navigator overlay state for inserting overlays.
  OverlayState? _overlayState;

  /// Initialize service with overlay state.
  /// Call this early in app lifecycle (e.g., in MainApp).
  void initialize(BuildContext context) {
    _overlayState = Overlay.of(context);
  }

  /// Show a tutorial overlay.
  ///
  /// Parameters:
  /// - [tutorial]: The tutorial definition to show
  /// - [targetLink]: LayerLink for positioning (optional)
  /// - [targetKey]: GlobalKey for target widget (optional)
  ///
  /// If positioning fails, falls back to snackbar.
  void showTutorial(
    TutorialDefinition tutorial, {
    LayerLink? targetLink,
    GlobalKey? targetKey,
  }) {
    // Remove existing overlay first
    _removeCurrentOverlay();

    // Get overlay state
    final overlayState = _overlayState;
    if (overlayState == null) {
      debugPrint('⚠️ TutorialOverlayService: Not initialized');
      return;
    }

    // Check if we have positioning info
    if (targetLink == null || targetKey == null) {
      _showFallback(tutorial);
      return;
    }

    _currentTutorialId = tutorial.id;

    // Create overlay entry
    _currentOverlay = OverlayEntry(
      builder: (context) => UnifiedContextualOverlay(
        targetLink: targetLink,
        targetKey: targetKey,
        title: _getTitle(context, tutorial),
        description: _getDescription(context, tutorial),
        actionLabel: tutorial.actionKey != null
            ? _getLocalizedString(context, tutorial.actionKey!)
            : null,
        onAction: () => _handleAction(tutorial),
        onDismiss: () => _handleDismiss(tutorial),
        autoHide: tutorial.autoHideDuration,
        showPulse: tutorial.showPulse,
        showSpotlight: tutorial.showSpotlight,
      ),
    );

    // Insert overlay
    overlayState.insert(_currentOverlay!);
    debugPrint('🎯 TutorialOverlayService: Showing ${tutorial.id}');
  }

  /// Show fallback snackbar when overlay positioning fails.
  void _showFallback(TutorialDefinition tutorial) {
    // The fallback is handled by UnifiedContextualOverlay itself
    // when it can't calculate position
    debugPrint(
      '⚠️ TutorialOverlayService: Missing positioning info for ${tutorial.id}',
    );

    // Mark as seen anyway to prevent repeated attempts
    _ref.read(tutorialStateProvider.notifier).markTutorialSeen(tutorial.id);
  }

  /// Get localized title for tutorial.
  String _getTitle(BuildContext context, TutorialDefinition tutorial) {
    return _getLocalizedString(context, tutorial.titleKey);
  }

  /// Get localized description for tutorial.
  String _getDescription(BuildContext context, TutorialDefinition tutorial) {
    return _getLocalizedString(context, tutorial.descriptionKey);
  }

  /// Get localized string by key.
  ///
  /// Falls back to key itself if not found (for development).
  String _getLocalizedString(BuildContext context, String key) {
    // Use reflection to call l10n method by name
    // This is a workaround since we can't dynamically access l10n keys
    try {
      final l10n = context.l10n;
      // Map of known tutorial keys to l10n methods
      return switch (key) {
        // Logging set tutorial
        'tutorial_logging_set_title' => l10n.tutorialLoggingSetTitle,
        'tutorial_logging_set_desc' => l10n.tutorialLoggingSetDesc,

        // Rest timer tutorial
        'tutorial_rest_timer_title' => l10n.tutorialRestTimerTitle,
        'tutorial_rest_timer_desc' => l10n.tutorialRestTimerDesc,

        // Exercise management tutorial
        'tutorial_exercise_mgmt_title' => l10n.tutorialExerciseMgmtTitle,
        'tutorial_exercise_mgmt_desc' => l10n.tutorialExerciseMgmtDesc,

        // Workout completion tutorial
        'tutorial_workout_complete_title' => l10n.tutorialWorkoutCompleteTitle,
        'tutorial_workout_complete_desc' => l10n.tutorialWorkoutCompleteDesc,

        // Analytics tutorial
        'tutorial_analytics_title' => l10n.tutorialAnalyticsTitle,
        'tutorial_analytics_desc' => l10n.tutorialAnalyticsDesc,

        // Templates tutorial
        'tutorial_templates_title' => l10n.tutorialTemplatesTitle,
        'tutorial_templates_desc' => l10n.tutorialTemplatesDesc,

        // Advanced techniques tutorial
        'tutorial_advanced_title' => l10n.tutorialAdvancedTitle,
        'tutorial_advanced_desc' => l10n.tutorialAdvancedDesc,

        // Superset builder tutorial
        'tutorial_superset_builder_title' => l10n.tutorialSupersetBuilderTitle,
        'tutorial_superset_builder_desc' => l10n.tutorialSupersetBuilderDesc,

        // Exercise database tutorial
        'tutorial_exercise_db_title' => l10n.tutorialExerciseDbTitle,
        'tutorial_exercise_db_desc' => l10n.tutorialExerciseDbDesc,

        // RPE selector tutorial
        'tutorial_rpe_title' => l10n.tutorialRpeTitle,
        'tutorial_rpe_desc' => l10n.tutorialRpeDesc,

        // Quick edit tutorial
        'tutorial_quick_edit_title' => l10n.tutorialQuickEditTitle,
        'tutorial_quick_edit_desc' => l10n.tutorialQuickEditDesc,

        // History tutorial
        'tutorial_history_title' => l10n.tutorialHistoryTitle,
        'tutorial_history_desc' => l10n.tutorialHistoryDesc,

        // Routine center tutorial
        'tutorial_routine_center_title' => l10n.tutorialRoutineCenterTitle,
        'tutorial_routine_center_desc' => l10n.tutorialRoutineCenterDesc,

        // Settings tutorial
        'tutorial_settings_title' => l10n.tutorialSettingsTitle,
        'tutorial_settings_desc' => l10n.tutorialSettingsDesc,

        // Export data tutorial
        'tutorial_export_title' => l10n.tutorialExportTitle,
        'tutorial_export_desc' => l10n.tutorialExportDesc,

        // Action buttons
        'tutorial_action_got_it' => l10n.tutorialActionGotIt,
        'tutorial_action_learn_more' => l10n.tutorialActionLearnMore,

        // Fallback: return key for development
        _ => key,
      };
    } catch (e) {
      debugPrint('⚠️ Missing l10n key: $key');
      return key;
    }
  }

  /// Handle action button tap.
  void _handleAction(TutorialDefinition tutorial) {
    debugPrint('🎯 TutorialOverlayService: Action for ${tutorial.id}');
    // Action-specific logic can be added here
  }

  /// Handle overlay dismiss.
  void _handleDismiss(TutorialDefinition tutorial) {
    debugPrint('🎯 TutorialOverlayService: Dismissing ${tutorial.id}');

    // Mark tutorial as seen
    _ref.read(tutorialStateProvider.notifier).markTutorialSeen(tutorial.id);

    // If proactive, also add dismiss timestamp for cooldown
    if (tutorial.type == TutorialType.proactive) {
      _ref.read(tutorialStateProvider.notifier).dismissHint(tutorial.id);
    }

    _removeCurrentOverlay();
  }

  /// Remove current overlay if any.
  void _removeCurrentOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
    _currentTutorialId = null;
  }

  /// Force dismiss current overlay.
  /// Use when navigating away or when user performs action.
  void dismiss() {
    if (_currentTutorialId != null) {
      final state = _ref.read(tutorialStateProvider);
      final alreadySeen = state.seenTutorialsList.contains(_currentTutorialId);

      if (!alreadySeen) {
        // Mark as seen if not already
        _ref
            .read(tutorialStateProvider.notifier)
            .markTutorialSeen(_currentTutorialId!);
      }
    }
    _removeCurrentOverlay();
  }

  /// Check if an overlay is currently showing.
  bool get isShowing => _currentOverlay != null;

  /// Get currently showing tutorial ID (if any).
  String? get currentTutorialId => _currentTutorialId;

  /// Dispose service.
  void dispose() {
    _removeCurrentOverlay();
    _overlayState = null;
  }
}
