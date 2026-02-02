/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/onboarding/domain/services
/// Feature: Exercise Search Tutorial
/// Type: Service
///
/// Interactive tutorial service for the exercise search screen.
/// Shows contextual hints for search, filters, and selection.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Tutorial steps for exercise search screen
enum ExerciseSearchTutorialStep {
  /// Step 1: Search bar - how to search exercises
  searchBar,

  /// Step 2: Filter button - access filters
  filterButton,

  /// Step 3: Quick filter chips - muscle group shortcuts
  quickFilters,

  /// Step 4: Exercise card - how to select
  exerciseCard,

  /// Step 5: Add button - confirm selection
  addButton,

  /// Tutorial completed
  completed,
}

/// State for the exercise search tutorial
class ExerciseSearchTutorialState {
  const ExerciseSearchTutorialState({
    required this.isActive,
    required this.currentStep,
    required this.hasCompletedTutorial,
  });

  final bool isActive;
  final ExerciseSearchTutorialStep currentStep;
  final bool hasCompletedTutorial;

  ExerciseSearchTutorialState copyWith({
    bool? isActive,
    ExerciseSearchTutorialStep? currentStep,
    bool? hasCompletedTutorial,
  }) {
    return ExerciseSearchTutorialState(
      isActive: isActive ?? this.isActive,
      currentStep: currentStep ?? this.currentStep,
      hasCompletedTutorial: hasCompletedTutorial ?? this.hasCompletedTutorial,
    );
  }
}

/// Notifier for managing exercise search tutorial
class ExerciseSearchTutorialNotifier
    extends StateNotifier<ExerciseSearchTutorialState> {
  ExerciseSearchTutorialNotifier()
    : super(
        const ExerciseSearchTutorialState(
          isActive: false,
          currentStep: ExerciseSearchTutorialStep.searchBar,
          hasCompletedTutorial: false,
        ),
      ) {
    _loadState();
  }

  static const String _completedKey = 'exercise_search_tutorial_completed';
  TutorialCoachMark? _currentTutorial;

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_completedKey) ?? false;
    state = state.copyWith(hasCompletedTutorial: completed);
  }

  /// Start the tutorial
  void startTutorial() {
    state = state.copyWith(
      isActive: true,
      currentStep: ExerciseSearchTutorialStep.searchBar,
    );
  }

  /// Stop/cancel the tutorial
  void stopTutorial() {
    _currentTutorial?.finish();
    _currentTutorial = null;
    state = state.copyWith(isActive: false);
  }

  /// Mark tutorial as completed
  Future<void> completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);
    state = state.copyWith(
      isActive: false,
      hasCompletedTutorial: true,
      currentStep: ExerciseSearchTutorialStep.completed,
    );
  }

  /// Reset tutorial (for testing)
  Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedKey);
    state = state.copyWith(
      isActive: false,
      hasCompletedTutorial: false,
      currentStep: ExerciseSearchTutorialStep.searchBar,
    );
  }

  /// Scrolls to target widget before showing spotlight
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
      debugPrint('⚠️ [ExerciseSearchTutorial] Scroll failed: $e');
    }
  }

  /// Show tutorial with all steps
  Future<void> showTutorial({
    required BuildContext context,
    required Map<ExerciseSearchTutorialStep, GlobalKey> targetKeys,
    VoidCallback? onComplete,
    VoidCallback? onSkip,
  }) async {
    if (!state.isActive) return;

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Scroll to first target
    final firstKey = targetKeys[ExerciseSearchTutorialStep.searchBar];
    if (firstKey != null) {
      await _scrollToTarget(firstKey);
    }

    final targets = <TargetFocus>[];

    for (final step in ExerciseSearchTutorialStep.values) {
      if (step == ExerciseSearchTutorialStep.completed) continue;

      final key = targetKeys[step];
      if (key == null || key.currentContext == null) {
        debugPrint(
          '⚠️ [ExerciseSearchTutorial] Skipping step $step - no valid key',
        );
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
                        '${_getStepNumber(step)}/${ExerciseSearchTutorialStep.values.length - 1}',
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
                              step == ExerciseSearchTutorialStep.addButton
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
      debugPrint('❌ [ExerciseSearchTutorial] No valid targets found');
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
      debugPrint(
        '⚠️ [ExerciseSearchTutorial] Context no longer mounted, aborting',
      );
      return;
    }

    _currentTutorial!.show(context: context);
  }

  int _getStepNumber(ExerciseSearchTutorialStep step) {
    return ExerciseSearchTutorialStep.values.indexOf(step) + 1;
  }

  ExerciseSearchTutorialStep? _getNextStep(ExerciseSearchTutorialStep current) {
    const values = ExerciseSearchTutorialStep.values;
    final currentIndex = values.indexOf(current);
    if (currentIndex < 0 || currentIndex >= values.length - 2) return null;
    return values[currentIndex + 1];
  }

  _StepConfig _getStepConfig(
    ExerciseSearchTutorialStep step,
    AppLocalizations l10n,
  ) {
    switch (step) {
      case ExerciseSearchTutorialStep.searchBar:
        return _StepConfig(
          title: l10n.tutorialSearchBarTitle,
          message: l10n.tutorialSearchBarMessage,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contentAlign: ContentAlign.bottom,
        );
      case ExerciseSearchTutorialStep.filterButton:
        return _StepConfig(
          title: l10n.tutorialFilterButtonTitle,
          message: l10n.tutorialFilterButtonMessage,
          shape: ShapeLightFocus.Circle,
          radius: 8,
          contentAlign: ContentAlign.bottom,
        );
      case ExerciseSearchTutorialStep.quickFilters:
        return _StepConfig(
          title: l10n.tutorialQuickFiltersTitle,
          message: l10n.tutorialQuickFiltersMessage,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          contentAlign: ContentAlign.bottom,
        );
      case ExerciseSearchTutorialStep.exerciseCard:
        return _StepConfig(
          title: l10n.tutorialExerciseCardTitle,
          message: l10n.tutorialExerciseCardMessage,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contentAlign: ContentAlign.top,
        );
      case ExerciseSearchTutorialStep.addButton:
        return _StepConfig(
          title: l10n.tutorialAddButtonTitle,
          message: l10n.tutorialAddButtonMessage,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          contentAlign: ContentAlign.top,
        );
      case ExerciseSearchTutorialStep.completed:
        return const _StepConfig(
          title: '',
          message: '',
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

/// Provider for exercise search tutorial state
final exerciseSearchTutorialProvider =
    StateNotifierProvider<
      ExerciseSearchTutorialNotifier,
      ExerciseSearchTutorialState
    >((ref) => ExerciseSearchTutorialNotifier());

/// Provider to check if tutorial is completed
final exerciseSearchTutorialCompletedProvider = Provider<bool>((ref) {
  return ref.watch(exerciseSearchTutorialProvider).hasCompletedTutorial;
});
