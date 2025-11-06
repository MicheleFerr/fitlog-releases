import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_state_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/language_selection_screen.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/steps/01_welcome_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/steps/02_mode_selection_with_toggles.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/steps/03_toggle_panorama_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/steps/04_create_workout_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/steps/05_add_exercise_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/steps/06_execute_set_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/steps/07_timer_rest_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/steps/08_advanced_features_step.dart';

class GlobalOnboardingScreen extends ConsumerStatefulWidget {
  const GlobalOnboardingScreen({super.key});

  @override
  ConsumerState<GlobalOnboardingScreen> createState() => _GlobalOnboardingScreenState();
}

class _GlobalOnboardingScreenState extends ConsumerState<GlobalOnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLanguageSelected = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();

    // Check if language is already selected and initialize onboarding state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appConfig = ref.read(appConfigProvider);
      final state = ref.read(onboardingStateProvider);

      // Check if language has been set (not null and not empty)
      final hasLanguageSet = appConfig.languageCode.isNotEmpty;

      setState(() {
        _isLanguageSelected = hasLanguageSet;
      });

      // Only start onboarding if language is selected and we need to start fresh
      if (_isLanguageSelected) {
        if (!state.hasStarted && !state.hasSeenGlobalOnboarding) {
          debugPrint('🆕 Starting fresh onboarding for user with selected language');
          ref.read(onboardingStateProvider.notifier).startOnboarding();
        } else {
          debugPrint('👤 Onboarding already in progress or completed, not starting new session');
          if (kDebugMode) {
            ref.read(onboardingStateProvider.notifier).debugOnboardingState();
          }
        }
      } else {
        debugPrint('🌍 Language not selected, showing language selection first');
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final state = ref.read(onboardingStateProvider);
    final notifier = ref.read(onboardingStateProvider.notifier);

    if (state.currentStep < OnboardingState.totalSteps - 1) {
      notifier.nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    final state = ref.read(onboardingStateProvider);
    final notifier = ref.read(onboardingStateProvider.notifier);

    if (state.currentStep > 0) {
      notifier.goToStep(state.currentStep - 1);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToStep(int stepIndex) {
    final notifier = ref.read(onboardingStateProvider.notifier);

    if (notifier.isStepAccessible(stepIndex)) {
      notifier.goToStep(stepIndex);
      _pageController.animateToPage(
        stepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    ref.read(onboardingStateProvider.notifier).skipOnboarding();
    // Note: No longer updating AppConfig - OnboardingState is the single source of truth
    context.goNamed('home');
  }

  void _completeOnboarding() {
    ref.read(onboardingStateProvider.notifier).completeOnboarding();
    // Note: No longer updating AppConfig - OnboardingState is the single source of truth
    context.goNamed('home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Show language selection if language not set
    if (!_isLanguageSelected) {
      return const LanguageSelectionScreen();
    }

    final l10n = AppLocalizations.of(context);
    final state = ref.watch(onboardingStateProvider);

    return Material(
      color: colorScheme.surface,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: Column(
              children: [
                // Header with progress and skip
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Progress info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.onboardingStepOf(state.currentStep + 1, OnboardingState.totalSteps),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            OnboardingStep.fromIndex(state.currentStep).title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Skip button
                      TextButton(
                        onPressed: _skipOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        child: Text(
                          l10n.onboardingSkip,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  child: Stack(
                    children: [
                      // Background
                      Container(
                        width: double.infinity,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      // Progress
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (state.currentStep + 1) / OnboardingState.totalSteps,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.primaryContainer,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Step indicator dots
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(OnboardingState.totalSteps, (index) {
                      final isCompleted = state.isStepCompleted(index);
                      final isCurrent = state.currentStep == index;
                      final isAccessible = ref.read(onboardingStateProvider.notifier)
                          .isStepAccessible(index);

                      return GestureDetector(
                        onTap: isAccessible ? () => _goToStep(index) : null,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isCurrent ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: isCompleted || isCurrent
                                ? colorScheme.primary
                                : isAccessible
                                    ? colorScheme.outline
                                    : colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      ref.read(onboardingStateProvider.notifier).goToStep(index);
                    },
                    children: [
                      WelcomeStep(onNext: _nextStep),
                      ModeSelectionWithTogglesStep(onNext: _nextStep),
                      TogglePanoramaStep(onNext: _nextStep),
                      CreateWorkoutStep(onNext: _nextStep),
                      AddExerciseStep(onNext: _nextStep),
                      ExecuteSetStep(onNext: _nextStep),
                      TimerRestStep(onNext: _nextStep),
                      AdvancedFeaturesStep(onNext: _completeOnboarding),
                    ],
                  ),
                ),

                // Navigation buttons
                Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      // Back button
                      if (state.currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: colorScheme.outline),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              l10n.onboardingBack,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      if (state.currentStep > 0) const SizedBox(width: 16),

                      // Next/Done button
                      Expanded(
                        flex: state.currentStep > 0 ? 1 : 2,
                        child: FilledButton(
                          onPressed: _nextStep,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            state.currentStep == OnboardingState.totalSteps - 1
                                ? l10n.onboardingStart
                                : l10n.onboardingNext,
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}