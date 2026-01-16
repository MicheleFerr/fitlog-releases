/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/onboarding/domain/services
/// Feature: Timer Tour
/// Type: Service
///
/// Interactive tour for the rest timer feature.
/// Shows contextual hints when timer first activates.
///
/// Trigger: First time timer starts after completing a set
/// Use Case: User completes first set, timer auto-starts,
///           tour explains timer features and Live Activities
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Timer tour steps - UX 2025: reduced to 1 essential step
/// Only explain auto-start behavior (not obvious), rest is intuitive
enum TimerTourStep {
  /// Step 1: Timer auto-starts after set - this is the key non-obvious behavior
  timerDisplay,

  // REMOVED - intuitive patterns:
  // - durationAdjust: users naturally try tapping/long-pressing
  // - liveActivity: iOS handles this UI, self-explanatory
  // - soundSettings: standard settings icon

  /// Tour completed
  completed,
}

/// State for the timer tour
class TimerTourState {
  const TimerTourState({
    required this.isActive,
    required this.currentStep,
    required this.hasCompletedTour,
    required this.hasSeenTimerOnce,
  });

  final bool isActive;
  final TimerTourStep currentStep;
  final bool hasCompletedTour;
  final bool hasSeenTimerOnce;

  TimerTourState copyWith({
    bool? isActive,
    TimerTourStep? currentStep,
    bool? hasCompletedTour,
    bool? hasSeenTimerOnce,
  }) {
    return TimerTourState(
      isActive: isActive ?? this.isActive,
      currentStep: currentStep ?? this.currentStep,
      hasCompletedTour: hasCompletedTour ?? this.hasCompletedTour,
      hasSeenTimerOnce: hasSeenTimerOnce ?? this.hasSeenTimerOnce,
    );
  }
}

/// Notifier for managing timer tour state
class TimerTourNotifier extends StateNotifier<TimerTourState> {
  TimerTourNotifier()
      : super(const TimerTourState(
          isActive: false,
          currentStep: TimerTourStep.timerDisplay,
          hasCompletedTour: false,
          hasSeenTimerOnce: false,
        )) {
    _loadState();
  }

  static const String _completedKey = 'timer_tour_completed';
  static const String _seenTimerKey = 'timer_seen_once';
  TutorialCoachMark? _currentTour;

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_completedKey) ?? false;
      final seenOnce = prefs.getBool(_seenTimerKey) ?? false;
      state = state.copyWith(
        hasCompletedTour: completed,
        hasSeenTimerOnce: seenOnce,
      );
    } catch (e) {
      debugPrint('⚠️ [TimerTour] Failed to load state: $e');
    }
  }

  /// Called when timer is shown for the first time
  /// Returns true if tour should start
  Future<bool> onTimerShown() async {
    if (state.hasCompletedTour) return false;
    if (state.hasSeenTimerOnce) return false;

    // Mark as seen
    state = state.copyWith(hasSeenTimerOnce: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_seenTimerKey, true);
    } catch (e) {
      debugPrint('⚠️ [TimerTour] Failed to save seen state: $e');
    }

    return true;
  }

  /// Start the timer tour
  void startTour() {
    state = state.copyWith(
      isActive: true,
      currentStep: TimerTourStep.timerDisplay,
    );
  }

  /// Stop/cancel the tour
  void stopTour() {
    _currentTour?.finish();
    _currentTour = null;
    state = state.copyWith(isActive: false);
  }

  /// Mark tour as completed
  Future<void> completeTour() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_completedKey, true);
    } catch (e) {
      debugPrint('⚠️ [TimerTour] Failed to save completion: $e');
    }
    state = state.copyWith(
      isActive: false,
      hasCompletedTour: true,
      currentStep: TimerTourStep.completed,
    );
  }

  /// Reset tour (for testing)
  Future<void> resetTour() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_completedKey);
      await prefs.remove(_seenTimerKey);
    } catch (e) {
      debugPrint('⚠️ [TimerTour] Failed to reset: $e');
    }
    state = state.copyWith(
      isActive: false,
      hasCompletedTour: false,
      hasSeenTimerOnce: false,
      currentStep: TimerTourStep.timerDisplay,
    );
  }

  /// Show tour with all steps
  Future<void> showTour({
    required BuildContext context,
    required Map<TimerTourStep, GlobalKey> targetKeys,
    VoidCallback? onComplete,
    VoidCallback? onSkip,
  }) async {
    if (!state.isActive) return;

    if (!context.mounted) {
      debugPrint('⚠️ [TimerTour] Context not mounted');
      stopTour();
      return;
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final targets = <TargetFocus>[];

    for (final step in TimerTourStep.values) {
      if (step == TimerTourStep.completed) continue;

      final key = targetKeys[step];
      if (key == null || key.currentContext == null) {
        debugPrint('⚠️ [TimerTour] Skipping step $step - no valid key');
        continue;
      }

      final config = _getStepConfig(step, l10n);

      targets.add(
        TargetFocus(
          identify: step.name,
          keyTarget: key,
          alignSkip: Alignment.topRight,
          enableOverlayTab: false,
          enableTargetTab: false,
          shape: config.shape,
          radius: config.radius,
          paddingFocus: 8,
          contents: [
            TargetContent(
              align: config.contentAlign,
              builder: (context, controller) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step indicator
                      Text(
                        '${_getStepNumber(step)}/1',
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title with icon
                      Row(
                        children: [
                          Icon(
                            config.icon,
                            size: 20,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              config.title,
                              style: textTheme.titleMedium?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Description
                      Text(
                        config.message,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _currentTour?.finish();
                              onSkip?.call();
                            },
                            child: Text(l10n.skip),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () => controller.next(),
                            child: Text(
                              // With only 1 step, always show "Got it"
                              l10n.tutorialGotIt,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    if (targets.isEmpty) {
      debugPrint('❌ [TimerTour] No valid targets found');
      stopTour();
      return;
    }

    _currentTour = TutorialCoachMark(
      targets: targets,
      colorShadow: colors.scrim,
      opacityShadow: 0.85,
      hideSkip: true,
      onFinish: () {
        completeTour();
        onComplete?.call();
      },
      onSkip: () {
        stopTour();
        onSkip?.call();
        return true;
      },
    );

    if (!context.mounted) {
      debugPrint('⚠️ [TimerTour] Context no longer mounted');
      return;
    }

    _currentTour!.show(context: context);
  }

  int _getStepNumber(TimerTourStep step) {
    return TimerTourStep.values.indexOf(step) + 1;
  }

  _StepConfig _getStepConfig(TimerTourStep step, AppLocalizations l10n) {
    switch (step) {
      case TimerTourStep.timerDisplay:
        return _StepConfig(
          title: l10n.timerTourDisplayTitle,
          message: l10n.timerTourDisplayDescription,
          icon: AppIcons.timerOutlined,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          contentAlign: ContentAlign.bottom,
        );
      case TimerTourStep.completed:
        return const _StepConfig(
          title: '',
          message: '',
          icon: AppIcons.check,
          shape: ShapeLightFocus.RRect,
          radius: 0,
          contentAlign: ContentAlign.bottom,
        );
    }
  }
}

class _StepConfig {
  const _StepConfig({
    required this.title,
    required this.message,
    required this.icon,
    required this.shape,
    required this.radius,
    required this.contentAlign,
  });

  final String title;
  final String message;
  final IconData icon;
  final ShapeLightFocus shape;
  final double radius;
  final ContentAlign contentAlign;
}

/// Provider for timer tour state
final timerTourProvider =
    StateNotifierProvider<TimerTourNotifier, TimerTourState>(
  (ref) => TimerTourNotifier(),
);

/// Provider to check if timer tour is completed
final timerTourCompletedProvider = Provider<bool>((ref) {
  return ref.watch(timerTourProvider).hasCompletedTour;
});

/// Provider to check if timer tour should auto-start
final shouldShowTimerTourProvider = Provider<bool>((ref) {
  final state = ref.watch(timerTourProvider);
  return !state.hasCompletedTour && !state.hasSeenTimerOnce;
});
