import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_tour_config.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_tour_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_state_provider.dart';

/// State for the onboarding tour
class OnboardingTourState {
  const OnboardingTourState({
    this.isActive = false,
    this.currentStepPosition = 0,
    this.isAutoAdvancing = false,
  });

  /// Whether the tour is currently active
  final bool isActive;

  /// Current step position (0-indexed)
  final int currentStepPosition;

  /// Whether auto-advance timer is running
  final bool isAutoAdvancing;

  /// Get current step
  OnboardingTourStep get currentStep =>
      OnboardingTourConfig.getStepByPosition(currentStepPosition)!;

  /// Whether can go to previous step
  bool get canGoBack => currentStepPosition > 0;

  /// Whether can go to next step
  bool get canGoForward =>
      currentStepPosition < OnboardingTourConfig.totalSteps - 1;

  /// Whether this is the last step
  bool get isLastStep =>
      currentStepPosition == OnboardingTourConfig.totalSteps - 1;

  OnboardingTourState copyWith({
    bool? isActive,
    int? currentStepPosition,
    bool? isAutoAdvancing,
  }) {
    return OnboardingTourState(
      isActive: isActive ?? this.isActive,
      currentStepPosition: currentStepPosition ?? this.currentStepPosition,
      isAutoAdvancing: isAutoAdvancing ?? this.isAutoAdvancing,
    );
  }
}

/// Notifier for managing onboarding tour state
class OnboardingTourNotifier extends StateNotifier<OnboardingTourState> {
  OnboardingTourNotifier(this.ref) : super(const OnboardingTourState());

  final Ref ref;
  Timer? _autoAdvanceTimer;

  /// Start the tour from the beginning
  void startTour() {
    debugPrint('🎯 [TOUR] Starting onboarding tour');
    state = const OnboardingTourState(
      isActive: true,
      currentStepPosition: 0,
      isAutoAdvancing: false,
    );

    // Start auto-advance timer if this is a SIMPLE step
    _startAutoAdvanceIfNeeded();
  }

  /// Go to the next step
  void nextStep() {
    if (!state.canGoForward) {
      // Last step reached - complete tour
      completeTour();
      return;
    }

    _cancelAutoAdvance();

    final nextPosition = state.currentStepPosition + 1;
    debugPrint('🎯 [TOUR] Moving to step ${nextPosition + 1}/${OnboardingTourConfig.totalSteps}');

    state = state.copyWith(
      currentStepPosition: nextPosition,
      isAutoAdvancing: false,
    );

    // Start auto-advance timer for the new step if SIMPLE
    _startAutoAdvanceIfNeeded();
  }

  /// Go to the previous step
  void previousStep() {
    if (!state.canGoBack) return;

    _cancelAutoAdvance();

    final previousPosition = state.currentStepPosition - 1;
    debugPrint('🎯 [TOUR] Moving back to step ${previousPosition + 1}/${OnboardingTourConfig.totalSteps}');

    state = state.copyWith(
      currentStepPosition: previousPosition,
      isAutoAdvancing: false,
    );

    // Start auto-advance timer for the new step if SIMPLE
    _startAutoAdvanceIfNeeded();
  }

  /// Skip the entire tour
  void skipTour() {
    debugPrint('🎯 [TOUR] Tour skipped by user');
    _cancelAutoAdvance();

    state = const OnboardingTourState(
      isActive: false,
      currentStepPosition: 0,
      isAutoAdvancing: false,
    );

    // Mark tour as seen in onboarding state
    ref.read(onboardingStateProvider.notifier).markOverlaySeen('homeTour');
  }

  /// Complete the tour successfully
  void completeTour() {
    debugPrint('🎯 [TOUR] Tour completed successfully');
    _cancelAutoAdvance();

    state = const OnboardingTourState(
      isActive: false,
      currentStepPosition: 0,
      isAutoAdvancing: false,
    );

    // Mark tour as seen in onboarding state
    ref.read(onboardingStateProvider.notifier).markOverlaySeen('homeTour');
  }

  /// Start auto-advance timer if current step is SIMPLE
  void _startAutoAdvanceIfNeeded() {
    final currentStep = state.currentStep;

    if (currentStep.isSimple && currentStep.autoAdvanceDuration != null) {
      debugPrint(
        '🎯 [TOUR] Starting auto-advance timer for ${currentStep.id} '
        '(${currentStep.autoAdvanceDuration!.inSeconds}s)',
      );

      state = state.copyWith(isAutoAdvancing: true);

      _autoAdvanceTimer = Timer(currentStep.autoAdvanceDuration!, () {
        debugPrint('🎯 [TOUR] Auto-advancing from ${currentStep.id}');
        nextStep();
      });
    }
  }

  /// Cancel auto-advance timer
  void _cancelAutoAdvance() {
    if (_autoAdvanceTimer != null) {
      _autoAdvanceTimer!.cancel();
      _autoAdvanceTimer = null;
      state = state.copyWith(isAutoAdvancing: false);
    }
  }

  @override
  void dispose() {
    _cancelAutoAdvance();
    super.dispose();
  }
}

/// Provider for onboarding tour state
final onboardingTourProvider =
    StateNotifierProvider<OnboardingTourNotifier, OnboardingTourState>((ref) {
  return OnboardingTourNotifier(ref);
});
