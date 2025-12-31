import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/initial/initial_onboarding_completion_service.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/welcome_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/goal_selection_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/body_data_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/experience_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/healthkit_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/frequency_summary_step.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Main screen for initial onboarding flow.
///
/// Uses PageView to display 6 steps:
/// 1. Welcome
/// 2. Goal selection
/// 3. Body data (sex, weight)
/// 4. Experience level
/// 5. HealthKit permissions
/// 6. Frequency + Summary
class InitialOnboardingScreen extends ConsumerStatefulWidget {
  const InitialOnboardingScreen({
    super.key,
    this.onComplete,
  });

  /// Callback when onboarding is completed
  final VoidCallback? onComplete;

  @override
  ConsumerState<InitialOnboardingScreen> createState() =>
      _InitialOnboardingScreenState();
}

class _InitialOnboardingScreenState
    extends ConsumerState<InitialOnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(initialOnboardingNotifierProvider);
    final pageController = ref.watch(initialOnboardingPageControllerProvider);

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _ProgressBar(
              currentStep: state.currentStep,
              totalSteps: state.totalSteps,
              onStepTap: (step) {
                ref.read(initialOnboardingNotifierProvider.notifier).goToStep(step);
              },
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const WelcomeStep(),
                  const GoalSelectionStep(),
                  const BodyDataStep(),
                  const ExperienceStep(),
                  const HealthKitStep(),
                  FrequencySummaryStep(
                    onComplete: _handleComplete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleComplete() async {
    final notifier = ref.read(initialOnboardingNotifierProvider.notifier);
    final state = ref.read(initialOnboardingNotifierProvider);
    final completionService =
        ref.read(initialOnboardingCompletionServiceProvider);

    // Get onboarding data
    final data = state.toOnboardingData();
    if (data == null) {
      notifier.setError('Dati incompleti');
      return;
    }

    // Start completion
    notifier.startCompletion();

    try {
      // Save all data
      await completionService.complete(data);

      // Trigger callback if provided
      widget.onComplete?.call();

      // Navigate to Home - spotlight tutorial will start automatically
      // when user opens workout screen for the first time
      if (mounted) {
        context.goNamed(AppRoutes.homeName);
      }
    } catch (e) {
      notifier.setError('Errore durante il salvataggio: $e');
    }
  }
}

/// Progress bar showing current step with tappable indicators
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.currentStep,
    required this.totalSteps,
    required this.onStepTap,
  });

  final int currentStep;
  final int totalSteps;
  final ValueChanged<int> onStepTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Back button (visible from step 1 onwards)
          if (currentStep > 0)
            IconButton(
              onPressed: () => onStepTap(currentStep - 1),
              icon: Icon(
                AppIcons.arrowBackIosRounded,
                color: context.colors.onSurface,
                size: AppIconSize.small,
              ),
            )
          else
            const SizedBox(width: 48),

          // Step indicators
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalSteps,
                (index) => _StepIndicator(
                  isActive: index <= currentStep,
                  isCurrent: index == currentStep,
                  onTap: index < currentStep ? () => onStepTap(index) : null,
                ),
              ),
            ),
          ),

          // Skip button placeholder for balance
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

/// Individual step indicator dot
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.isActive,
    required this.isCurrent,
    this.onTap,
  });

  final bool isActive;
  final bool isCurrent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isCurrent ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isActive
              ? context.colors.primary
              : context.colors.onSurface.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
