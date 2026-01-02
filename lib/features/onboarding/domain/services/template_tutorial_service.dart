/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/onboarding/domain/services
/// Feature: Template Tutorial
/// Type: Service
///
/// Interactive tutorial for creating workout templates.
/// Shows when user first taps "Create Template" or "Save as Template".
///
/// Trigger: First tap on create/save template action
/// Use Case: User wants to save their workout as reusable template
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Template tutorial steps - 5 steps for complete flow
enum TemplateTutorialStep {
  /// Step 1: Template name input
  templateName,

  /// Step 2: Add exercises to template
  addExercises,

  /// Step 3: Configure default sets/reps
  configureDefaults,

  /// Step 4: Save template
  saveTemplate,

  /// Step 5: Use template (how to start from it)
  useTemplate,

  /// Tutorial completed
  completed,
}

/// State for the template tutorial
class TemplateTutorialState {
  const TemplateTutorialState({
    required this.isActive,
    required this.currentStep,
    required this.hasCompletedTutorial,
    required this.triggerSource,
  });

  final bool isActive;
  final TemplateTutorialStep currentStep;
  final bool hasCompletedTutorial;

  /// How the tutorial was triggered
  final TemplateTriggerSource? triggerSource;

  TemplateTutorialState copyWith({
    bool? isActive,
    TemplateTutorialStep? currentStep,
    bool? hasCompletedTutorial,
    TemplateTriggerSource? triggerSource,
    bool clearTrigger = false,
  }) {
    return TemplateTutorialState(
      isActive: isActive ?? this.isActive,
      currentStep: currentStep ?? this.currentStep,
      hasCompletedTutorial: hasCompletedTutorial ?? this.hasCompletedTutorial,
      triggerSource: clearTrigger ? null : (triggerSource ?? this.triggerSource),
    );
  }
}

/// How the template tutorial was triggered
enum TemplateTriggerSource {
  /// User tapped "Create New Template" from templates screen
  createNew,

  /// User tapped "Save as Template" from workout screen
  saveFromWorkout,
}

/// Notifier for managing template tutorial state
class TemplateTutorialNotifier extends StateNotifier<TemplateTutorialState> {
  TemplateTutorialNotifier()
      : super(const TemplateTutorialState(
          isActive: false,
          currentStep: TemplateTutorialStep.templateName,
          hasCompletedTutorial: false,
          triggerSource: null,
        )) {
    _loadState();
  }

  static const String _completedKey = 'template_tutorial_completed';
  TutorialCoachMark? _currentTutorial;

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_completedKey) ?? false;
      state = state.copyWith(hasCompletedTutorial: completed);
    } catch (e) {
      debugPrint('⚠️ [TemplateTutorial] Failed to load state: $e');
    }
  }

  /// Check if tutorial should be shown for given trigger
  bool shouldShowFor(TemplateTriggerSource source) {
    return !state.hasCompletedTutorial;
  }

  /// Start the template tutorial
  void startTutorial(TemplateTriggerSource source) {
    state = state.copyWith(
      isActive: true,
      currentStep: TemplateTutorialStep.templateName,
      triggerSource: source,
    );
  }

  /// Stop/cancel the tutorial
  void stopTutorial() {
    _currentTutorial?.finish();
    _currentTutorial = null;
    state = state.copyWith(isActive: false, clearTrigger: true);
  }

  /// Mark tutorial as completed
  Future<void> completeTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_completedKey, true);
    } catch (e) {
      debugPrint('⚠️ [TemplateTutorial] Failed to save completion: $e');
    }
    state = state.copyWith(
      isActive: false,
      hasCompletedTutorial: true,
      currentStep: TemplateTutorialStep.completed,
      clearTrigger: true,
    );
  }

  /// Reset tutorial (for testing)
  Future<void> resetTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_completedKey);
    } catch (e) {
      debugPrint('⚠️ [TemplateTutorial] Failed to reset: $e');
    }
    state = state.copyWith(
      isActive: false,
      hasCompletedTutorial: false,
      currentStep: TemplateTutorialStep.templateName,
      clearTrigger: true,
    );
  }

  /// Scrolls to target widget
  Future<void> _scrollToTarget(GlobalKey targetKey) async {
    final targetContext = targetKey.currentContext;
    if (targetContext == null) return;

    try {
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('⚠️ [TemplateTutorial] Scroll failed: $e');
    }
  }

  /// Gets the next step
  TemplateTutorialStep? _getNextStep(TemplateTutorialStep current) {
    const values = TemplateTutorialStep.values;
    final currentIndex = values.indexOf(current);
    if (currentIndex < 0 || currentIndex >= values.length - 2) return null;
    return values[currentIndex + 1];
  }

  /// Show tutorial with all steps
  Future<void> showTutorial({
    required BuildContext context,
    required Map<TemplateTutorialStep, GlobalKey> targetKeys,
    VoidCallback? onComplete,
    VoidCallback? onSkip,
  }) async {
    if (!state.isActive) return;

    if (!context.mounted) {
      debugPrint('⚠️ [TemplateTutorial] Context not mounted');
      stopTutorial();
      return;
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Scroll to first target
    final firstKey = targetKeys[TemplateTutorialStep.templateName];
    if (firstKey != null) {
      await _scrollToTarget(firstKey);
    }

    final targets = <TargetFocus>[];

    for (final step in TemplateTutorialStep.values) {
      if (step == TemplateTutorialStep.completed) continue;

      final key = targetKeys[step];
      if (key == null || key.currentContext == null) {
        debugPrint('⚠️ [TemplateTutorial] Skipping step $step - no valid key');
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
                        '${_getStepNumber(step)}/5',
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
                      // Pro tip for certain steps
                      if (config.proTip != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                AppIcons.lightbulbOutline,
                                size: 16,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  config.proTip!,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colors.onPrimaryContainer,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _currentTutorial?.finish();
                              onSkip?.call();
                            },
                            child: Text(l10n.skip),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () async {
                              // Scroll to next target before advancing
                              final nextStep = _getNextStep(step);
                              if (nextStep != null) {
                                final nextKey = targetKeys[nextStep];
                                if (nextKey != null) {
                                  await _scrollToTarget(nextKey);
                                }
                              }
                              controller.next();
                            },
                            child: Text(
                              step == TemplateTutorialStep.useTemplate
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
      debugPrint('❌ [TemplateTutorial] No valid targets found');
      stopTutorial();
      return;
    }

    _currentTutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: colors.scrim,
      opacityShadow: 0.85,
      hideSkip: true,
      onFinish: () {
        completeTutorial();
        onComplete?.call();
      },
      onSkip: () {
        stopTutorial();
        onSkip?.call();
        return true;
      },
    );

    if (!context.mounted) {
      debugPrint('⚠️ [TemplateTutorial] Context no longer mounted');
      return;
    }

    _currentTutorial!.show(context: context);
  }

  int _getStepNumber(TemplateTutorialStep step) {
    return TemplateTutorialStep.values.indexOf(step) + 1;
  }

  _StepConfig _getStepConfig(TemplateTutorialStep step, AppLocalizations l10n) {
    switch (step) {
      case TemplateTutorialStep.templateName:
        return _StepConfig(
          title: l10n.templateTutorialNameTitle,
          message: l10n.templateTutorialNameDescription,
          icon: AppIcons.edit,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contentAlign: ContentAlign.bottom,
          proTip: l10n.templateTutorialNameTip,
        );
      case TemplateTutorialStep.addExercises:
        return _StepConfig(
          title: l10n.templateTutorialAddExercisesTitle,
          message: l10n.templateTutorialAddExercisesDescription,
          icon: AppIcons.fitnessCenterOutlined,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          contentAlign: ContentAlign.bottom,
          proTip: null,
        );
      case TemplateTutorialStep.configureDefaults:
        return _StepConfig(
          title: l10n.templateTutorialConfigureTitle,
          message: l10n.templateTutorialConfigureDescription,
          icon: AppIcons.tune,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contentAlign: ContentAlign.top,
          proTip: l10n.templateTutorialConfigureTip,
        );
      case TemplateTutorialStep.saveTemplate:
        return _StepConfig(
          title: l10n.templateTutorialSaveTitle,
          message: l10n.templateTutorialSaveDescription,
          icon: AppIcons.save,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          contentAlign: ContentAlign.top,
          proTip: null,
        );
      case TemplateTutorialStep.useTemplate:
        return _StepConfig(
          title: l10n.templateTutorialUseTitle,
          message: l10n.templateTutorialUseDescription,
          icon: AppIcons.playCircleOutline,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          contentAlign: ContentAlign.top,
          proTip: l10n.templateTutorialUseTip,
        );
      case TemplateTutorialStep.completed:
        return const _StepConfig(
          title: '',
          message: '',
          icon: AppIcons.check,
          shape: ShapeLightFocus.RRect,
          radius: 0,
          contentAlign: ContentAlign.bottom,
          proTip: null,
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
    required this.proTip,
  });

  final String title;
  final String message;
  final IconData icon;
  final ShapeLightFocus shape;
  final double radius;
  final ContentAlign contentAlign;
  final String? proTip;
}

/// Provider for template tutorial state
final templateTutorialProvider =
    StateNotifierProvider<TemplateTutorialNotifier, TemplateTutorialState>(
  (ref) => TemplateTutorialNotifier(),
);

/// Provider to check if template tutorial is completed
final templateTutorialCompletedProvider = Provider<bool>((ref) {
  return ref.watch(templateTutorialProvider).hasCompletedTutorial;
});

/// Provider to check if template tutorial should be shown
final shouldShowTemplateTutorialProvider = Provider<bool>((ref) {
  return !ref.watch(templateTutorialProvider).hasCompletedTutorial;
});
