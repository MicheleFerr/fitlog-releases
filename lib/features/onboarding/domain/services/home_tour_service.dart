/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/onboarding/domain/services
/// Feature: Home Screen Tour
/// Type: Service
///
/// Interactive tour service for the home screen.
/// Shows contextual hints for each widget on the home screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Home tour steps in order (matching MinimalHomeScreen layout)
enum HomeTourStep {
  /// Step 1: XP Progress Bar - Your level and experience
  xpProgress,

  /// Step 2: Activity Rings - HealthKit integration
  activityRings,

  /// Step 3: Pro Insights - Analytics preview
  proInsights,

  /// Step 4: Recovery Insight - Sleep-based recovery
  recoveryInsight,

  /// Step 5: Stress Prediction - Training load predictions
  stressPrediction,

  /// Step 6: Template Suggestion - AI workout recommendation
  templateSuggestion,

  /// Step 7: Start Workout - Main CTA
  startWorkout,

  /// Step 8: Templates Carousel - Quick access templates
  templatesCarousel,

  /// Step 9: Exercise Wiki - Community database
  exerciseWiki,

  /// Step 10: Settings - App configuration
  settings,

  /// Tour completed
  completed,
}

/// State for the home tour
class HomeTourState {
  const HomeTourState({
    required this.isActive,
    required this.currentStep,
    required this.hasCompletedTour,
  });

  /// Whether the tour is currently running
  final bool isActive;

  /// Current step in the tour
  final HomeTourStep currentStep;

  /// Whether user has completed the full tour before
  final bool hasCompletedTour;

  HomeTourState copyWith({
    bool? isActive,
    HomeTourStep? currentStep,
    bool? hasCompletedTour,
  }) {
    return HomeTourState(
      isActive: isActive ?? this.isActive,
      currentStep: currentStep ?? this.currentStep,
      hasCompletedTour: hasCompletedTour ?? this.hasCompletedTour,
    );
  }
}

/// Notifier for managing home tour state
class HomeTourNotifier extends StateNotifier<HomeTourState> {
  HomeTourNotifier()
      : super(const HomeTourState(
          isActive: false,
          currentStep: HomeTourStep.xpProgress,
          hasCompletedTour: false,
        )) {
    _loadState();
  }

  static const String _completedKey = 'home_tour_completed';
  TutorialCoachMark? _currentTour;

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_completedKey) ?? false;
    state = state.copyWith(hasCompletedTour: completed);
  }

  /// Start the home tour
  void startTour() {
    state = state.copyWith(
      isActive: true,
      currentStep: HomeTourStep.xpProgress,
    );
  }

  /// Stop/cancel the tour
  void stopTour() {
    _currentTour?.finish();
    _currentTour = null;
    state = state.copyWith(isActive: false);
  }

  /// Move to the next step
  void advanceToStep(HomeTourStep step) {
    if (!state.isActive) return;
    state = state.copyWith(currentStep: step);
  }

  /// Mark tour as completed
  Future<void> completeTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);
    state = state.copyWith(
      isActive: false,
      hasCompletedTour: true,
      currentStep: HomeTourStep.completed,
    );
  }

  /// Reset tour (for testing)
  Future<void> resetTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedKey);
    state = state.copyWith(
      isActive: false,
      hasCompletedTour: false,
      currentStep: HomeTourStep.xpProgress,
    );
  }

  /// Show all tour steps as a guided sequence
  void showTour({
    required BuildContext context,
    required Map<HomeTourStep, GlobalKey> targetKeys,
    VoidCallback? onComplete,
    VoidCallback? onSkip,
  }) {
    if (!state.isActive) return;

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final targets = <TargetFocus>[];

    // Build targets for each step that has a valid key
    for (final step in HomeTourStep.values) {
      if (step == HomeTourStep.completed) continue;

      final key = targetKeys[step];
      if (key == null || key.currentContext == null) {
        debugPrint('⚠️ [HomeTour] Skipping step $step - no valid key');
        continue;
      }

      final config = _getStepConfig(step, l10n);

      targets.add(
        TargetFocus(
          identify: step.name,
          keyTarget: key,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          enableTargetTab: true,
          shape: ShapeLightFocus.RRect,
          radius: config.radius,
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
                        '${_getStepNumber(step)}/10',
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        config.title,
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
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
                      // Next button
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
                              step == HomeTourStep.settings
                                  ? l10n.tutorialGotIt
                                  : l10n.tutorialNext,
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
      debugPrint('❌ [HomeTour] No valid targets found');
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
      onClickTarget: (target) {
        debugPrint('🎯 [HomeTour] Clicked target: ${target.identify}');
      },
      onSkip: () {
        stopTour();
        onSkip?.call();
        return true;
      },
    );

    _currentTour!.show(context: context);
  }

  int _getStepNumber(HomeTourStep step) {
    return HomeTourStep.values.indexOf(step) + 1;
  }

  _StepConfig _getStepConfig(HomeTourStep step, AppLocalizations l10n) {
    switch (step) {
      case HomeTourStep.xpProgress:
        return _StepConfig(
          title: l10n.tourXpProgressTitle,
          message: l10n.tourXpProgressDescription,
          contentAlign: ContentAlign.bottom,
          radius: 12,
        );
      case HomeTourStep.activityRings:
        return _StepConfig(
          title: l10n.tourActivityRingsTitle,
          message: l10n.tourActivityRingsDescription,
          contentAlign: ContentAlign.bottom,
          radius: 16,
        );
      case HomeTourStep.proInsights:
        return _StepConfig(
          title: l10n.tourProInsightsTitle,
          message: l10n.tourProInsightsDescription,
          contentAlign: ContentAlign.bottom,
          radius: 16,
        );
      case HomeTourStep.recoveryInsight:
        return _StepConfig(
          title: l10n.tourRecoveryInsightTitle,
          message: l10n.tourRecoveryInsightDescription,
          contentAlign: ContentAlign.bottom,
          radius: 16,
        );
      case HomeTourStep.stressPrediction:
        return _StepConfig(
          title: l10n.tourStressPredictionTitle,
          message: l10n.tourStressPredictionDescription,
          contentAlign: ContentAlign.top,
          radius: 16,
        );
      case HomeTourStep.templateSuggestion:
        return _StepConfig(
          title: l10n.tourTemplateSuggestionTitle,
          message: l10n.tourTemplateSuggestionDescription,
          contentAlign: ContentAlign.top,
          radius: 16,
        );
      case HomeTourStep.startWorkout:
        return _StepConfig(
          title: l10n.tourStartWorkoutTitle,
          message: l10n.tourStartWorkoutDescription,
          contentAlign: ContentAlign.top,
          radius: 20,
        );
      case HomeTourStep.templatesCarousel:
        return _StepConfig(
          title: l10n.tourTemplatesCarouselTitle,
          message: l10n.tourTemplatesCarouselDescription,
          contentAlign: ContentAlign.top,
          radius: 16,
        );
      case HomeTourStep.exerciseWiki:
        return _StepConfig(
          title: l10n.tourExerciseWikiTitle,
          message: l10n.tourExerciseWikiDescription,
          contentAlign: ContentAlign.top,
          radius: 16,
        );
      case HomeTourStep.settings:
        return _StepConfig(
          title: l10n.tourSettingsTitle,
          message: l10n.tourSettingsDescription,
          contentAlign: ContentAlign.bottom,
          radius: 24,
        );
      case HomeTourStep.completed:
        return const _StepConfig(
          title: '',
          message: '',
          contentAlign: ContentAlign.bottom,
          radius: 0,
        );
    }
  }
}

class _StepConfig {
  const _StepConfig({
    required this.title,
    required this.message,
    required this.contentAlign,
    required this.radius,
  });

  final String title;
  final String message;
  final ContentAlign contentAlign;
  final double radius;
}

/// Provider for home tour state
final homeTourProvider =
    StateNotifierProvider<HomeTourNotifier, HomeTourState>(
  (ref) => HomeTourNotifier(),
);

/// Provider to check if home tour is completed
final homeTourCompletedProvider = Provider<bool>((ref) {
  return ref.watch(homeTourProvider).hasCompletedTour;
});
