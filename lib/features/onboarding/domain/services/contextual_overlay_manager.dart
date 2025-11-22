import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_state_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/contextual_overlay.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Service for managing contextual overlays (tooltips, hints, guides)
/// Uses action-based triggers (not time-based) for 3x effectiveness
///
/// **Philosophy**: Just-in-time help when user needs it, not upfront tours
///
/// **Usage**:
/// ```dart
/// await ContextualOverlayManager.show(
///   context: context,
///   ref: ref,
///   overlayId: 'createWorkoutCTA',
///   targetKey: _createButtonKey,
///   message: 'Tap here to create your first workout',
/// );
/// ```
class ContextualOverlayManager {
  ContextualOverlayManager._(); // Private constructor

  /// Show a contextual overlay if not already seen
  ///
  /// Returns true if overlay was shown, false if already seen or conditions not met
  static Future<bool> show({
    required BuildContext context,
    required WidgetRef ref,
    required String overlayId,
    required GlobalKey targetKey,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 8),
    bool dismissible = true,
  }) async {
    // Check if user has already seen this overlay
    final onboardingState = ref.read(onboardingProvider);
    if (onboardingState.hasSeenOverlay(overlayId)) {
      return false; // Already seen, don't show again
    }

    // Check if target widget is mounted and visible
    final targetContext = targetKey.currentContext;
    if (targetContext == null || !targetContext.mounted) {
      return false; // Target not available
    }

    // Show the overlay
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: dismissible,
        barrierColor: context.colors.onSurface.withValues(alpha: 0.7),
        builder: (dialogContext) => ContextualOverlay(
          targetKey: targetKey,
          message: message,
          actionLabel: actionLabel,
          onAction: () {
            Navigator.of(dialogContext).pop();
            onAction?.call();
          },
          onDismiss: () {
            Navigator.of(dialogContext).pop();
          },
        ),
      );

      // Mark as seen
      await ref.read(onboardingProvider.notifier).markOverlaySeen(overlayId);
      return true;
    }

    return false;
  }

  /// Check if overlay should be shown (without showing it)
  static bool shouldShow({
    required WidgetRef ref,
    required String overlayId,
    required GlobalKey targetKey,
  }) {
    final onboardingState = ref.read(onboardingProvider);
    if (onboardingState.hasSeenOverlay(overlayId)) {
      return false;
    }

    final targetContext = targetKey.currentContext;
    if (targetContext == null || !targetContext.mounted) {
      return false;
    }

    return true;
  }

  /// Predefined overlay configurations for common cases
  static const Map<String, OverlayConfig> commonOverlays = {
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // PHASE 1: Quick Start & Empty States
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    'createWorkoutCTA': OverlayConfig(
      message: 'Tap the + button to create your first workout',
      actionLabel: 'Got it',
      duration: Duration(seconds: 10),
    ),

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // PHASE 2: Guided First Workout (Beginner Journey)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Step 1: Welcome to workout screen
    'firstWorkoutWelcome': OverlayConfig(
      message: 'Welcome! Let\'s create your first workout together. I\'ll guide you step-by-step.',
      actionLabel: 'Let\'s go!',
      duration: Duration(seconds: 12),
    ),

    /// Step 2: Add first exercise
    'addFirstExercise': OverlayConfig(
      message: 'Great! Now tap here to add your first exercise.',
      actionLabel: 'Show me',
      duration: Duration(seconds: 10),
    ),

    /// Step 3: Exercise picker tips
    'exercisePickerTips': OverlayConfig(
      message: 'Search by name or browse by muscle group. Choose any exercise to get started!',
      actionLabel: 'Got it',
      duration: Duration(seconds: 10),
    ),

    /// Step 4: Add first set
    'addFirstSet': OverlayConfig(
      message: 'Perfect! Now tap "Add Set" to log your first set.',
      actionLabel: 'Add set',
      duration: Duration(seconds: 10),
    ),

    /// Step 5: Set input explanation
    'firstSetInput': OverlayConfig(
      message: 'Enter the weight you lifted and how many reps you did, then tap ✓ to save.',
      actionLabel: 'Got it',
      duration: Duration(seconds: 12),
    ),

    /// Step 6: Rest timer explanation (after first set)
    'restTimerExplain': OverlayConfig(
      message: 'Great job! 💪 The rest timer started automatically. Take a break between sets.',
      actionLabel: 'Thanks!',
      duration: Duration(seconds: 10),
    ),

    /// Step 7: Complete workout
    'completeFirstWorkout': OverlayConfig(
      message: 'Amazing work! 🎉 You\'ve completed your sets. Tap here to finish your workout.',
      actionLabel: 'Finish!',
      duration: Duration(seconds: 12),
    ),

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // PHASE 3: Feature Discovery & Advanced
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    'routineCenterIntro': OverlayConfig(
      message: 'Create workout routines to follow a structured program',
      actionLabel: 'Explore',
      duration: Duration(seconds: 8),
    ),
    'analyticsIntro': OverlayConfig(
      message: 'Track your progress and PRs over time',
      actionLabel: 'View',
      duration: Duration(seconds: 7),
    ),

    // Legacy (Phase 1, kept for backward compatibility)
    'addExerciseHelp': OverlayConfig(
      message: 'Add exercises to your workout by tapping here',
      actionLabel: 'Show me',
      duration: Duration(seconds: 8),
    ),
    'startTimerHint': OverlayConfig(
      message: 'Tap to start the rest timer between sets',
      actionLabel: 'Understood',
      duration: Duration(seconds: 6),
    ),
  };
}

/// Configuration for a contextual overlay
class OverlayConfig {
  const OverlayConfig({
    required this.message,
    this.actionLabel,
    this.duration = const Duration(seconds: 8),
    this.dismissible = true,
  });

  final String message;
  final String? actionLabel;
  final Duration duration;
  final bool dismissible;
}

/// Overlay trigger conditions (when to show overlay)
enum OverlayTrigger {
  /// Show on home screen if no workouts exist (beginner empty state)
  homeEmptyState,

  /// Show after workout screen opens for first time
  workoutScreenFirstOpen,

  /// Show when user hovers over exercise card for 3+ seconds
  exerciseCardLongPress,

  /// Show when user opens routine center for first time
  routineCenterFirstOpen,

  /// Show when user opens analytics for first time
  analyticsFirstOpen,

  /// Show after first workout is completed
  firstWorkoutCompleted,

  /// Show when user creates 3+ workouts (advanced features unlock)
  advancedFeaturesUnlock,
}

/// Helper extension for checking triggers
extension OverlayTriggerExtension on OverlayTrigger {
  bool shouldTrigger(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.read(onboardingProvider);

    switch (this) {
      case OverlayTrigger.homeEmptyState:
        return onboardingState.isBeginner && !onboardingState.hasCompletedFirstWorkout;

      case OverlayTrigger.firstWorkoutCompleted:
        return onboardingState.hasCompletedFirstWorkout &&
            !onboardingState.hasSeenOverlay('firstWorkoutCelebration');

      case OverlayTrigger.advancedFeaturesUnlock:
        // TODO: Check workout count from WorkoutProvider
        return false; // Placeholder

      default:
        return false;
    }
  }
}
