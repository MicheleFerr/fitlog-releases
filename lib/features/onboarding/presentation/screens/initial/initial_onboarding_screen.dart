import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final appLocale = ref.read(localeProvider);
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final isItalianDevice = deviceLocale.languageCode.toLowerCase() == 'it';
      final isAppItalian = appLocale.languageCode.toLowerCase() == 'it';

      // Keep onboarding localized for Italian devices even if legacy config
      // persisted an old English locale.
      if (isItalianDevice && !isAppItalian) {
        ref.read(appConfigProvider.notifier).setLanguage('it', 'IT');
      }
    });
  }

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
    final l10n = context.l10n;

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
      notifier.setError(l10n.errorInvalidInput);
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

      // Wait for Riverpod state to propagate before navigating
      print('🏠 [Onboarding] Waiting for state propagation...');
      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted && context.mounted) {
        // Navigate using GoRouter context extension (avoids circular import with app_router.dart)
        print('🎯 [Onboarding] Navigating to choice screen...');
        context.go(AppRoutes.onboardingChoicePath);
        print('✅ [Onboarding] Navigation to choice screen triggered');
      }

      // Keep spinner visible until navigation completes
      // DO NOT reset isCompleting flag here - let the new screen build
    } catch (e, stack) {
      // Reset both flags on error to allow retry
      _isHandlingCompletion = false;

      print('❌ [Onboarding] Error during completion: $e');
      print('Stack: $stack');
      notifier.setError(l10n.errorSaving(e.toString()));
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
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                  )
                : Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/images/splash_no_bkg.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
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
