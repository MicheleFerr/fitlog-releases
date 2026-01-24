/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/onboarding/domain/services
/// Feature: Workout Tutorial
/// Type: Service
///
/// Interactive tutorial service for the workout screen.
/// Shows contextual hints as user completes actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Tutorial steps in order
enum WorkoutTutorialStep {
  /// Step 1: Highlight the FAB to add first exercise
  addExercise,

  /// Step 2: After adding exercise, show how to tap a set
  tapSet,

  /// Step 3: Show the exercise menu (3 dots)
  exerciseMenu,

  /// Step 4: Show the reorder button
  reorder,

  /// Step 5: Show the settings menu
  settings,

  /// Step 6: Show the finish button
  finish,

  /// Tutorial completed
  completed,
}

/// State for the interactive tutorial
class WorkoutTutorialState {
  const WorkoutTutorialState({
    required this.isActive,
    required this.currentStep,
    required this.hasCompletedTutorial,
    required this.hasStartedTutorial,
  });

  /// Whether the tutorial is currently running
  final bool isActive;

  /// Current step in the tutorial
  final WorkoutTutorialStep currentStep;

  /// Whether user has completed the full tutorial before
  final bool hasCompletedTutorial;

  /// Whether user has started the tutorial at least once (even if not completed)
  /// This prevents the tutorial from auto-showing repeatedly if user dismisses it
  final bool hasStartedTutorial;

  WorkoutTutorialState copyWith({
    bool? isActive,
    WorkoutTutorialStep? currentStep,
    bool? hasCompletedTutorial,
    bool? hasStartedTutorial,
  }) {
    return WorkoutTutorialState(
      isActive: isActive ?? this.isActive,
      currentStep: currentStep ?? this.currentStep,
      hasCompletedTutorial: hasCompletedTutorial ?? this.hasCompletedTutorial,
      hasStartedTutorial: hasStartedTutorial ?? this.hasStartedTutorial,
    );
  }
}

/// Notifier for managing interactive tutorial state
class WorkoutTutorialNotifier extends StateNotifier<WorkoutTutorialState> {
  // ✅ FIX: Static cache to survive provider rebuilds (background/foreground transitions)
  // This prevents tutorial from restarting when app resumes
  static WorkoutTutorialState? _cachedState;

  WorkoutTutorialNotifier()
      : super(_cachedState ?? const WorkoutTutorialState(
          isActive: false,
          currentStep: WorkoutTutorialStep.addExercise,
          hasCompletedTutorial: false,
          hasStartedTutorial: false,
        )) {
    // Load from SharedPreferences if no cache available
    if (_cachedState == null) {
      _loadState();
    }
  }

  static const String _completedKey = 'workout_tutorial_completed';
  static const String _startedKey = 'workout_tutorial_started';
  TutorialCoachMark? _currentTutorial;

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_completedKey) ?? false;
    final started = prefs.getBool(_startedKey) ?? false;
    state = state.copyWith(
      hasCompletedTutorial: completed,
      hasStartedTutorial: started,
    );
    // ✅ FIX: Update cache after loading from SharedPreferences
    _cachedState = state;
  }

  /// Start the interactive tutorial
  Future<void> startTutorial() async {
    // Mark tutorial as started (prevents auto-showing again)
    if (!state.hasStartedTutorial) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_startedKey, true);
    }

    state = state.copyWith(
      isActive: true,
      currentStep: WorkoutTutorialStep.addExercise,
      hasStartedTutorial: true,
    );
    // ✅ FIX: Update cache after state change
    _cachedState = state;
  }

  /// Stop/cancel the tutorial
  void stopTutorial() {
    _currentTutorial?.finish();
    _currentTutorial = null;
    state = state.copyWith(isActive: false);
    // ✅ FIX: Update cache after state change
    _cachedState = state;
  }

  /// Move to the next step
  void advanceToStep(WorkoutTutorialStep step) {
    if (!state.isActive) return;
    state = state.copyWith(currentStep: step);
    // ✅ FIX: Update cache after state change
    _cachedState = state;
  }

  /// Mark tutorial as completed
  Future<void> completeTutorial() async {
    // NOTE: Do NOT call _currentTutorial?.finish() here!
    // This would trigger onFinish callback again, causing infinite loop.
    // The tutorial is already finished when this method is called from onComplete callback.
    _currentTutorial = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);
    state = state.copyWith(
      isActive: false,
      hasCompletedTutorial: true,
      currentStep: WorkoutTutorialStep.completed,
    );
    // ✅ FIX: Update cache after state change
    _cachedState = state;
  }

  /// Reset tutorial (for testing)
  Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedKey);
    await prefs.remove(_startedKey);
    state = state.copyWith(
      isActive: false,
      hasCompletedTutorial: false,
      hasStartedTutorial: false,
      currentStep: WorkoutTutorialStep.addExercise,
    );
    // ✅ FIX: Update cache after state change
    _cachedState = state;
  }

  /// Show the current step's overlay
  void showCurrentStep({
    required BuildContext context,
    required GlobalKey targetKey,
    VoidCallback? onComplete,
  }) {
    if (!state.isActive) return;

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Check if target exists
    if (targetKey.currentContext == null) {
      debugPrint('⚠️ [Tutorial] Target not found for ${state.currentStep}');
      return;
    }

    final stepConfig = _getStepConfig(state.currentStep, l10n);
    if (stepConfig == null) return;

    // For addExercise step, allow tapping the FAB to open the exercise picker
    // This is required because the next step (tapSet) needs an exercise to exist
    final isAddExerciseStep = state.currentStep == WorkoutTutorialStep.addExercise;

    final target = TargetFocus(
      identify: state.currentStep.name,
      keyTarget: targetKey,
      alignSkip: Alignment.topRight,
      // Enable target tap only for addExercise step (user needs to tap FAB)
      // For other steps, disable to prevent accidental widget activation
      enableTargetTab: isAddExerciseStep,
      enableOverlayTab: false,
      shape: stepConfig.shape,
      radius: stepConfig.radius,
      paddingFocus: 10,
      contents: [
        TargetContent(
          align: stepConfig.contentAlign,
          builder: (context, controller) => _buildContent(
            context: context,
            title: stepConfig.title,
            message: stepConfig.message,
            stepNumber: state.currentStep.index + 1,
            totalSteps: WorkoutTutorialStep.values.length - 1, // exclude 'completed'
            onNext: () {
              // Only call controller.next() - onFinish callback handles onComplete
              // to avoid double-calling when tutorial finishes
              controller.next();
            },
            onSkip: () {
              controller.skip();
              stopTutorial();
            },
            colors: colors,
            isLast: state.currentStep == WorkoutTutorialStep.finish,
          ),
        ),
      ],
    );

    _currentTutorial = TutorialCoachMark(
      targets: [target],
      colorShadow: colors.surface,
      opacityShadow: 0.85,
      textSkip: l10n.skip,
      textStyleSkip: textTheme.labelMedium!.copyWith(
        color: colors.onSurface.withValues(alpha: 0.7),
        fontWeight: FontWeight.w500,
      ),
      paddingFocus: 10,
      focusAnimationDuration: const Duration(milliseconds: 400),
      unFocusAnimationDuration: const Duration(milliseconds: 300),
      pulseAnimationDuration: const Duration(milliseconds: 800),
      hideSkip: true, // Skip button is already in custom dialog content
      onFinish: () {
        onComplete?.call();
      },
      onSkip: () {
        stopTutorial();
        return true;
      },
    );

    _currentTutorial!.show(context: context);
  }

  /// Get configuration for a step
  _StepConfig? _getStepConfig(WorkoutTutorialStep step, AppLocalizations l10n) {
    switch (step) {
      case WorkoutTutorialStep.addExercise:
        return _StepConfig(
          title: l10n.tutorialAddExerciseTitle,
          message: l10n.tutorialAddExerciseMessage,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          contentAlign: ContentAlign.top,
        );
      case WorkoutTutorialStep.tapSet:
        return _StepConfig(
          title: l10n.tutorialFirstSetTitle,
          message: l10n.tutorialFirstSetMessage,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contentAlign: ContentAlign.bottom,
        );
      case WorkoutTutorialStep.exerciseMenu:
        return _StepConfig(
          title: l10n.tutorialExerciseMenuTitle,
          message: l10n.tutorialExerciseMenuMessage,
          shape: ShapeLightFocus.Circle,
          radius: 8,
          contentAlign: ContentAlign.bottom,
        );
      case WorkoutTutorialStep.reorder:
        return _StepConfig(
          title: l10n.tutorialReorderTitle,
          message: l10n.tutorialReorderMessage,
          shape: ShapeLightFocus.Circle,
          radius: 8,
          contentAlign: ContentAlign.bottom,
        );
      case WorkoutTutorialStep.settings:
        return _StepConfig(
          title: l10n.tutorialSettingsTitle,
          message: l10n.tutorialSettingsMessage,
          shape: ShapeLightFocus.Circle,
          radius: 8,
          contentAlign: ContentAlign.bottom,
        );
      case WorkoutTutorialStep.finish:
        return _StepConfig(
          title: l10n.tutorialFinishTitle,
          message: l10n.tutorialFinishMessage,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contentAlign: ContentAlign.bottom,
        );
      case WorkoutTutorialStep.completed:
        return null;
    }
  }

  /// Build content widget for a tutorial step
  static Widget _buildContent({
    required BuildContext context,
    required String title,
    required String message,
    required int stepNumber,
    required int totalSteps,
    required VoidCallback onNext,
    required VoidCallback onSkip,
    required ColorScheme colors,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with step indicator
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$stepNumber/$totalSteps',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Message
          Text(
            message,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isLast)
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    AppLocalizations.of(context).skip,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isLast
                      ? AppLocalizations.of(context).tutorialGotIt
                      : AppLocalizations.of(context).tutorialNext,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Configuration for a tutorial step
class _StepConfig {
  const _StepConfig({
    required this.title,
    required this.message,
    required this.shape,
    required this.radius,
    required this.contentAlign,
  });

  final String title;
  final String message;
  final ShapeLightFocus shape;
  final double radius;
  final ContentAlign contentAlign;
}

/// Provider for the workout tutorial state
final workoutTutorialProvider =
    StateNotifierProvider<WorkoutTutorialNotifier, WorkoutTutorialState>((ref) {
  return WorkoutTutorialNotifier();
});

/// Provider for checking if tutorial is completed
final workoutTutorialCompletedProvider = Provider<bool>((ref) {
  return ref.watch(workoutTutorialProvider).hasCompletedTutorial;
});
