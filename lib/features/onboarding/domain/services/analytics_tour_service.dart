/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/onboarding/domain/services
/// Feature: Analytics Tour
/// Type: Service
///
/// Interactive tour service for the analytics screen.
/// Shows contextual hints for statistics, graphs, and PR tracking.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Analytics tour steps in order
enum AnalyticsTourStep {
  /// Step 1: Period selector - choose time range
  periodSelector,

  /// Step 2: Hero stat card - overview of workouts
  heroStatCard,

  /// Step 3: Weekly dashboard - weekly progress
  weeklyDashboard,

  /// Step 4: Muscle heatmap - muscle group distribution
  muscleHeatmap,

  /// Step 5: PR tracking button - access personal records
  prTracking,

  /// Step 6: Detailed analysis button - access exercise progress
  detailedAnalysis,

  /// Tour completed
  completed,
}

/// State for the analytics tour
class AnalyticsTourState {
  const AnalyticsTourState({
    required this.isActive,
    required this.currentStep,
    required this.hasCompletedTour,
  });

  final bool isActive;
  final AnalyticsTourStep currentStep;
  final bool hasCompletedTour;

  AnalyticsTourState copyWith({
    bool? isActive,
    AnalyticsTourStep? currentStep,
    bool? hasCompletedTour,
  }) {
    return AnalyticsTourState(
      isActive: isActive ?? this.isActive,
      currentStep: currentStep ?? this.currentStep,
      hasCompletedTour: hasCompletedTour ?? this.hasCompletedTour,
    );
  }
}

/// Notifier for managing analytics tour state
class AnalyticsTourNotifier extends StateNotifier<AnalyticsTourState> {
  AnalyticsTourNotifier()
      : super(const AnalyticsTourState(
          isActive: false,
          currentStep: AnalyticsTourStep.periodSelector,
          hasCompletedTour: false,
        )) {
    _loadState();
  }

  static const String _completedKey = 'analytics_tour_completed';
  TutorialCoachMark? _currentTour;

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_completedKey) ?? false;
      state = state.copyWith(hasCompletedTour: completed);
    } catch (e) {
      // EDGE CASE: SharedPreferences failure - default to not completed
      debugPrint('⚠️ [AnalyticsTour] Failed to load state: $e');
    }
  }

  /// Start the analytics tour
  void startTour() {
    state = state.copyWith(
      isActive: true,
      currentStep: AnalyticsTourStep.periodSelector,
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
      // EDGE CASE: Save failure - still update local state
      debugPrint('⚠️ [AnalyticsTour] Failed to save completion: $e');
    }
    state = state.copyWith(
      isActive: false,
      hasCompletedTour: true,
      currentStep: AnalyticsTourStep.completed,
    );
  }

  /// Reset tour (for testing)
  Future<void> resetTour() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_completedKey);
    } catch (e) {
      debugPrint('⚠️ [AnalyticsTour] Failed to reset: $e');
    }
    state = state.copyWith(
      isActive: false,
      hasCompletedTour: false,
      currentStep: AnalyticsTourStep.periodSelector,
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
      debugPrint('⚠️ [AnalyticsTour] Scroll failed: $e');
    }
  }

  /// Gets the next step after the current one
  AnalyticsTourStep? _getNextStep(AnalyticsTourStep current) {
    const values = AnalyticsTourStep.values;
    final currentIndex = values.indexOf(current);
    if (currentIndex < 0 || currentIndex >= values.length - 2) return null;
    return values[currentIndex + 1];
  }

  /// Show tour with all steps
  Future<void> showTour({
    required BuildContext context,
    required Map<AnalyticsTourStep, GlobalKey> targetKeys,
    VoidCallback? onComplete,
    VoidCallback? onSkip,
  }) async {
    if (!state.isActive) return;

    // EDGE CASE: Context no longer valid
    if (!context.mounted) {
      debugPrint('⚠️ [AnalyticsTour] Context not mounted at start');
      stopTour();
      return;
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Scroll to first target
    final firstKey = targetKeys[AnalyticsTourStep.periodSelector];
    if (firstKey != null) {
      await _scrollToTarget(firstKey);
    }

    final targets = <TargetFocus>[];

    for (final step in AnalyticsTourStep.values) {
      if (step == AnalyticsTourStep.completed) continue;

      final key = targetKeys[step];
      // EDGE CASE: Widget not rendered (conditional/premium)
      if (key == null || key.currentContext == null) {
        debugPrint('⚠️ [AnalyticsTour] Skipping step $step - no valid key');
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
                        '${_getStepNumber(step)}/${AnalyticsTourStep.values.length - 1}',
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
                              step == AnalyticsTourStep.detailedAnalysis
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

    // EDGE CASE: No valid targets found
    if (targets.isEmpty) {
      debugPrint('❌ [AnalyticsTour] No valid targets found');
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

    // EDGE CASE: Context became invalid after async operations
    if (!context.mounted) {
      debugPrint('⚠️ [AnalyticsTour] Context no longer mounted, aborting');
      return;
    }

    _currentTour!.show(context: context);
  }

  int _getStepNumber(AnalyticsTourStep step) {
    return AnalyticsTourStep.values.indexOf(step) + 1;
  }

  _StepConfig _getStepConfig(AnalyticsTourStep step, AppLocalizations l10n) {
    switch (step) {
      case AnalyticsTourStep.periodSelector:
        return _StepConfig(
          title: l10n.tourPeriodSelectorTitle,
          message: l10n.tourPeriodSelectorDescription,
          shape: ShapeLightFocus.RRect,
          radius: 24,
          contentAlign: ContentAlign.bottom,
        );
      case AnalyticsTourStep.heroStatCard:
        return _StepConfig(
          title: l10n.tourHeroStatCardTitle,
          message: l10n.tourHeroStatCardDescription,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          contentAlign: ContentAlign.bottom,
        );
      case AnalyticsTourStep.weeklyDashboard:
        return _StepConfig(
          title: l10n.tourWeeklyDashboardTitle,
          message: l10n.tourWeeklyDashboardDescription,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          contentAlign: ContentAlign.bottom,
        );
      case AnalyticsTourStep.muscleHeatmap:
        return _StepConfig(
          title: l10n.tourMuscleHeatmapTitle,
          message: l10n.tourMuscleHeatmapDescription,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          contentAlign: ContentAlign.top,
        );
      case AnalyticsTourStep.prTracking:
        return _StepConfig(
          title: l10n.tourPrTrackingTitle,
          message: l10n.tourPrTrackingDescription,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          contentAlign: ContentAlign.top,
        );
      case AnalyticsTourStep.detailedAnalysis:
        return _StepConfig(
          title: l10n.tourDetailedAnalysisTitle,
          message: l10n.tourDetailedAnalysisDescription,
          shape: ShapeLightFocus.Circle,
          radius: 8,
          contentAlign: ContentAlign.bottom,
        );
      case AnalyticsTourStep.completed:
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

/// Provider for analytics tour state
final analyticsTourProvider =
    StateNotifierProvider<AnalyticsTourNotifier, AnalyticsTourState>(
  (ref) => AnalyticsTourNotifier(),
);

/// Provider to check if analytics tour is completed
final analyticsTourCompletedProvider = Provider<bool>((ref) {
  return ref.watch(analyticsTourProvider).hasCompletedTour;
});
