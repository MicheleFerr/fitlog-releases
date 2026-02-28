/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/onboarding/domain/services
/// Feature: Templates Screen Tour
/// Type: Service
///
/// Interactive tour service for the templates screen.
/// Shows contextual hints for template management features.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/onboarding_choice_service.dart';

/// Templates tour steps in order
enum TemplatesTourStep {
  /// Step 1: My Templates tab - your personal templates
  myTemplates,

  /// Step 2: Exercises tab - manage custom exercises
  exercises,

  /// Step 3: Discover tab - explore templates from the community
  discover,

  /// Step 4: Create button - how to create new templates
  createButton,

  /// Tour completed
  completed,
}

/// State for the templates tour
class TemplatesTourState {
  const TemplatesTourState({
    required this.isActive,
    required this.currentStep,
    required this.hasCompletedTour,
  });

  final bool isActive;
  final TemplatesTourStep currentStep;
  final bool hasCompletedTour;

  TemplatesTourState copyWith({
    bool? isActive,
    TemplatesTourStep? currentStep,
    bool? hasCompletedTour,
  }) {
    return TemplatesTourState(
      isActive: isActive ?? this.isActive,
      currentStep: currentStep ?? this.currentStep,
      hasCompletedTour: hasCompletedTour ?? this.hasCompletedTour,
    );
  }
}

/// Notifier for managing templates tour state
class TemplatesTourNotifier extends Notifier<TemplatesTourState> {
  @override
  TemplatesTourState build() {
    _loadState();
    return const TemplatesTourState(
      isActive: false,
      currentStep: TemplatesTourStep.myTemplates,
      hasCompletedTour: false,
    );
  }

  static const String _completedKey = 'templates_tour_completed';
  TutorialCoachMark? _currentTour;

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_completedKey) ?? false;
    state = state.copyWith(hasCompletedTour: completed);
  }

  /// Start the templates tour
  void startTour() {
    state = state.copyWith(
      isActive: true,
      currentStep: TemplatesTourStep.myTemplates,
    );
  }

  /// Stop/cancel the tour
  void stopTour() {
    _currentTour?.finish();
    _currentTour = null;
    state = state.copyWith(isActive: false);
  }

  /// Move to the next step
  void advanceToStep(TemplatesTourStep step) {
    if (!state.isActive) return;
    state = state.copyWith(currentStep: step);
  }

  /// Mark tour as completed
  Future<void> completeTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);

    // Also mark the template wizard as completed in OnboardingChoiceService
    final choiceService = OnboardingChoiceService(prefs);
    await choiceService.setTemplateWizardCompleted(true);

    state = state.copyWith(
      isActive: false,
      hasCompletedTour: true,
      currentStep: TemplatesTourStep.completed,
    );
  }

  /// Reset tour (for testing)
  Future<void> resetTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedKey);
    state = state.copyWith(
      isActive: false,
      hasCompletedTour: false,
      currentStep: TemplatesTourStep.myTemplates,
    );
  }

  /// Show all tour steps as a guided sequence
  Future<void> showTour({
    required BuildContext context,
    required Map<TemplatesTourStep, GlobalKey> targetKeys,
    VoidCallback? onComplete,
    VoidCallback? onSkip,
  }) async {
    if (!state.isActive) return;

    final totalSteps = TemplatesTourStep.values.length - 1;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final targets = <TargetFocus>[];

    // Build targets for each step that has a valid key
    for (final step in TemplatesTourStep.values) {
      if (step == TemplatesTourStep.completed) continue;

      final key = targetKeys[step];
      if (key == null || key.currentContext == null) {
        debugPrint('[TemplatesTour] Skipping step $step - no valid key');
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
                        '${_getStepNumber(step)}/$totalSteps',
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
                            onPressed: () {
                              controller.next();
                            },
                            child: Text(
                              step == TemplatesTourStep.createButton
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
      debugPrint('[TemplatesTour] No valid targets found');
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
      debugPrint('[TemplatesTour] Context no longer mounted, aborting tour');
      return;
    }

    _currentTour!.show(context: context);
  }

  int _getStepNumber(TemplatesTourStep step) {
    return TemplatesTourStep.values.indexOf(step) + 1;
  }

  _StepConfig _getStepConfig(TemplatesTourStep step, AppLocalizations l10n) {
    switch (step) {
      case TemplatesTourStep.myTemplates:
        return _StepConfig(
          title: l10n.tourMyTemplatesTitle,
          message: l10n.tourMyTemplatesDescription,
          contentAlign: ContentAlign.bottom,
          radius: 12,
        );
      case TemplatesTourStep.exercises:
        return _StepConfig(
          title: l10n.customExercises,
          message: l10n.exerciseNotFoundCreate,
          contentAlign: ContentAlign.bottom,
          radius: 12,
        );
      case TemplatesTourStep.discover:
        return _StepConfig(
          title: l10n.tourDiscoverTitle,
          message: l10n.tourDiscoverDescription,
          contentAlign: ContentAlign.bottom,
          radius: 12,
        );
      case TemplatesTourStep.createButton:
        return _StepConfig(
          title: l10n.tourCreateTemplateTitle,
          message: l10n.tourCreateTemplateDescription,
          contentAlign: ContentAlign.top,
          radius: 28,
        );
      case TemplatesTourStep.completed:
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

/// Provider for templates tour state
final templatesTourProvider =
    NotifierProvider<TemplatesTourNotifier, TemplatesTourState>(
      TemplatesTourNotifier.new,
    );

/// Provider to check if templates tour is completed
final templatesTourCompletedProvider = Provider<bool>((ref) {
  return ref.watch(templatesTourProvider).hasCompletedTour;
});
