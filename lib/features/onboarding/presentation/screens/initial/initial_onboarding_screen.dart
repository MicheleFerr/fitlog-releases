import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/navigation/app_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/initial/initial_onboarding_completion_service.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/welcome_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/goal_selection_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/personal_info_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/body_data_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/experience_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/frequency_summary_step.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/home_tour_service.dart';

/// Main screen for initial onboarding flow (Yazio-inspired, 6 steps).
///
/// Step 0: Welcome
/// Step 1: Goal selection
/// Step 2: Personal Info (sex + age)
/// Step 3: Body measurements (height + weight + HealthKit)
/// Step 4: Experience level
/// Step 5: Frequency + Summary
class InitialOnboardingScreen extends ConsumerStatefulWidget {
  const InitialOnboardingScreen({super.key, this.onComplete});

  /// Callback when onboarding is completed
  final VoidCallback? onComplete;

  @override
  ConsumerState<InitialOnboardingScreen> createState() =>
      _InitialOnboardingScreenState();
}

class _InitialOnboardingScreenState
    extends ConsumerState<InitialOnboardingScreen> {
  // CRITICAL: Local flag to prevent multiple completion calls
  // Riverpod state updates are async, so we need immediate synchronous protection
  bool _isHandlingCompletion = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(initialOnboardingNotifierProvider);
    final pageController = ref.watch(initialOnboardingPageControllerProvider);

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Linear progress bar (Yazio-style)
            _LinearProgressBar(
              currentStep: state.currentStep,
              totalSteps: state.totalSteps,
              onBack: state.currentStep > 0
                  ? () => ref
                        .read(initialOnboardingNotifierProvider.notifier)
                        .previousStep()
                  : null,
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const WelcomeStep(),
                  const GoalSelectionStep(),
                  const PersonalInfoStep(),
                  const BodyDataStep(),
                  const ExperienceStep(),
                  FrequencySummaryStep(onComplete: _handleComplete),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleComplete() async {
    // RELEASE MODE DEBUG: Always print (remove if blocks)
    print('🔵 [Onboarding] _handleComplete called');
    print('   - _isHandlingCompletion (local): $_isHandlingCompletion');

    // CRITICAL: Synchronous check with local flag (Riverpod state is async)
    if (_isHandlingCompletion) {
      print('⚠️ [Onboarding] Already handling completion - BLOCKED');
      return;
    }

    // Set local flag IMMEDIATELY (synchronous, before any await)
    _isHandlingCompletion = true;

    final notifier = ref.read(initialOnboardingNotifierProvider.notifier);
    final state = ref.read(initialOnboardingNotifierProvider);
    final completionService = ref.read(
      initialOnboardingCompletionServiceProvider,
    );

    print('   - isCompleting (state): ${state.isCompleting}');
    print('   - isComplete (state): ${state.isComplete}');

    // Get onboarding data
    final data = state.toOnboardingData();
    if (data == null) {
      print('❌ [Onboarding] Data incomplete - cannot proceed');
      notifier.setError('Dati incompleti');
      return;
    }

    // Start completion (shows spinner, disables button)
    print('🔄 [Onboarding] Starting completion...');
    notifier.startCompletion();

    try {
      // Save all data - this will set initialOnboardingCompleted = true
      print('💾 [Onboarding] Saving data...');
      await completionService.complete(data);

      print('✅ [Onboarding] Data saved successfully');

      // Trigger callback if provided
      widget.onComplete?.call();

      // Start home tour - will show automatically when Home renders
      ref.read(homeTourProvider.notifier).startTour();

      // CRITICAL FIX: Wait for Riverpod state to propagate to router provider
      // The router's redirect closure captures initialOnboardingCompleted at creation time.
      // We need to wait for:
      // 1. AppConfig state change to propagate
      // 2. Router provider to rebuild with new state
      // 3. New router instance to be installed in widget tree
      print('🏠 [Onboarding] Waiting for state propagation...');

      // Wait for next frame to ensure state is propagated
      await Future.delayed(const Duration(milliseconds: 150));

      if (mounted) {
        // Force router to rebuild by invalidating and re-reading
        print('🔄 [Onboarding] Invalidating router provider...');
        ref.invalidate(appRouterProvider);

        // Wait another frame for the new router to be created
        await Future.delayed(const Duration(milliseconds: 50));

        if (mounted) {
          // Now get the fresh router with updated state
          final router = ref.read(appRouterProvider);
          // Navigate to choice screen (guide me vs explore)
          print('🎯 [Onboarding] Navigating to choice screen...');
          router.go(AppRoutes.onboardingChoicePath);
          print('✅ [Onboarding] Navigation to choice screen triggered');
        }
      }

      // Keep spinner visible until navigation completes
      // DO NOT reset isCompleting flag here - let the new screen build
    } catch (e, stack) {
      // Reset both flags on error to allow retry
      _isHandlingCompletion = false;

      print('❌ [Onboarding] Error during completion: $e');
      print('Stack: $stack');
      notifier.setError('Errore durante il salvataggio: $e');
    }
  }
}

/// Yazio-style linear progress bar with back button
class _LinearProgressBar extends StatelessWidget {
  const _LinearProgressBar({
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    // Progress: step 0 = 0%, step 1 = 1/total, ..., last step = 1.0
    final progress = totalSteps > 1 ? currentStep / (totalSteps - 1) : 1.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
          SizedBox(
            width: 40,
            height: 40,
            // Accessibility: Back button with tooltip for screen readers
            child: onBack != null
                ? IconButton(
                    onPressed: onBack,
                    icon: Icon(
                      AppIcons.arrowBackIosRounded,
                      color: context.colors.onSurface,
                      size: AppIconSize.small,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(width: 12),

          // Linear progress indicator
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: context.colors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.colors.primary,
                  ),
                  minHeight: 6,
                ),
              ),
            ),
          ),

          const SizedBox(width: 52), // Balance for back button
        ],
      ),
    );
  }
}
