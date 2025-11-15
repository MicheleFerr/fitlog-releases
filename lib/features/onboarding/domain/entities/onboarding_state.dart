import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/user_goal.dart';

part 'onboarding_state.freezed.dart';

/// Onboarding state for P4 retention feature
///
/// Tracks user progress through goal-oriented onboarding flow
/// Part of P4 onboarding retention feature (+10-15% completion improvement)
/// Evidence: Clear progress tracking increases completion rates
@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    required OnboardingStep currentStep,
    required bool isCompleted,
    required UserGoal? userGoal,
  }) = _OnboardingState;

  /// Initial state (welcome screen)
  factory OnboardingState.initial() {
    return const OnboardingState(
      currentStep: OnboardingStep.welcome,
      isCompleted: false,
      userGoal: null,
    );
  }
}

/// Steps in the P4 retention-focused onboarding flow
enum OnboardingStep {
  /// Welcome screen - intro to the app
  welcome,

  /// Goal selection - what does user want to achieve?
  goalSelection,

  /// Weekly workout target - how many workouts per week?
  weeklyGoal,

  /// Onboarding completed
  completed,
}
