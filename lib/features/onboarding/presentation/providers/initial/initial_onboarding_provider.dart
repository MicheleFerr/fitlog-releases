import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/initial/initial_onboarding_data.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';

/// State for initial onboarding flow (5 steps, HealthKit moved to post-workout)
class InitialOnboardingState {
  const InitialOnboardingState({
    this.currentStep = 0,
    this.totalSteps = 5,
    this.goal,
    this.sex,
    this.bodyweightKg,
    this.experience,
    this.healthKitConnected = false,
    this.selectedHealthTypes = const [],
    this.workoutsPerWeek = 3,
    this.isLoading = false,
    this.isCompleting = false,
    this.errorMessage,
  });

  /// Current step index (0-5)
  final int currentStep;

  /// Total number of steps
  final int totalSteps;

  // Step 2: Goal
  final TrainingGoalUI? goal;

  // Step 3: Body data
  final BiologicalSex? sex;
  final double? bodyweightKg;

  // Step 4: Experience
  final ExperienceLevelUI? experience;

  // Step 5: HealthKit
  final bool healthKitConnected;
  final List<HealthDataType> selectedHealthTypes;

  // Step 6: Frequency
  final int workoutsPerWeek;

  // UI State
  final bool isLoading;
  final bool isCompleting;
  final String? errorMessage;

  /// Check if current step data is valid and user can proceed
  bool canProceedFromStep(int step) {
    switch (step) {
      case 0: // Welcome
        return true;
      case 1: // Goal
        return goal != null;
      case 2: // Body data
        return sex != null && bodyweightKg != null && bodyweightKg! >= 30;
      case 3: // Experience
        return experience != null;
      case 4: // Frequency (HealthKit moved to post-workout)
        return workoutsPerWeek >= 1 && workoutsPerWeek <= 7;
      default:
        return false;
    }
  }

  /// Check if all required data is collected
  bool get isComplete =>
      goal != null &&
      sex != null &&
      bodyweightKg != null &&
      experience != null;

  /// Build final onboarding data
  InitialOnboardingData? toOnboardingData() {
    if (!isComplete) return null;

    return InitialOnboardingData(
      goal: goal!,
      sex: sex!,
      bodyweightKg: bodyweightKg!,
      experience: experience!,
      healthKitConnected: healthKitConnected,
      healthKitPermissionsGranted:
          selectedHealthTypes.map((e) => e.name).toList(),
      workoutsPerWeek: workoutsPerWeek,
      completedAt: DateTime.now(),
    );
  }

  /// Progress percentage (0.0 - 1.0)
  double get progress => (currentStep + 1) / totalSteps;

  InitialOnboardingState copyWith({
    int? currentStep,
    int? totalSteps,
    TrainingGoalUI? goal,
    BiologicalSex? sex,
    double? bodyweightKg,
    ExperienceLevelUI? experience,
    bool? healthKitConnected,
    List<HealthDataType>? selectedHealthTypes,
    int? workoutsPerWeek,
    bool? isLoading,
    bool? isCompleting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InitialOnboardingState(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      goal: goal ?? this.goal,
      sex: sex ?? this.sex,
      bodyweightKg: bodyweightKg ?? this.bodyweightKg,
      experience: experience ?? this.experience,
      healthKitConnected: healthKitConnected ?? this.healthKitConnected,
      selectedHealthTypes: selectedHealthTypes ?? this.selectedHealthTypes,
      workoutsPerWeek: workoutsPerWeek ?? this.workoutsPerWeek,
      isLoading: isLoading ?? this.isLoading,
      isCompleting: isCompleting ?? this.isCompleting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier for managing initial onboarding state
class InitialOnboardingNotifier extends Notifier<InitialOnboardingState> {
  @override
  InitialOnboardingState build() {
    return const InitialOnboardingState();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  /// Go to next step if current step is valid
  void nextStep() {
    final current = state.currentStep;
    if (state.canProceedFromStep(current) && current < state.totalSteps - 1) {
      state = state.copyWith(currentStep: current + 1, clearError: true);
    }
  }

  /// Go to previous step
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        clearError: true,
      );
    }
  }

  /// Jump to specific step (for progress indicator taps)
  void goToStep(int step) {
    if (step >= 0 && step < state.totalSteps) {
      // Only allow going back or to current step
      if (step <= state.currentStep) {
        state = state.copyWith(currentStep: step, clearError: true);
      }
    }
  }

  // ============================================================
  // STEP 2: GOAL
  // ============================================================

  /// Set training goal and auto-advance
  void setGoal(TrainingGoalUI goal) {
    state = state.copyWith(goal: goal, clearError: true);
    // Auto-advance after selection
    Future.delayed(const Duration(milliseconds: 200), nextStep);
  }

  // ============================================================
  // STEP 3: BODY DATA
  // ============================================================

  /// Set biological sex
  void setSex(BiologicalSex sex) {
    state = state.copyWith(sex: sex, clearError: true);
  }

  /// Set bodyweight in kg
  void setBodyweight(double kg) {
    if (kg >= 30 && kg <= 300) {
      state = state.copyWith(bodyweightKg: kg, clearError: true);
    }
  }

  /// Import weight from HealthKit (called from UI)
  Future<void> importWeightFromHealthKit(double? weight) async {
    if (weight != null && weight >= 30 && weight <= 300) {
      state = state.copyWith(bodyweightKg: weight, clearError: true);
    }
  }

  // ============================================================
  // STEP 4: EXPERIENCE
  // ============================================================

  /// Set experience level and auto-advance
  void setExperience(ExperienceLevelUI level) {
    state = state.copyWith(experience: level, clearError: true);
    // Auto-advance after selection
    Future.delayed(const Duration(milliseconds: 200), nextStep);
  }

  // ============================================================
  // STEP 5: HEALTHKIT
  // ============================================================

  /// Toggle a health data type for permission request
  void toggleHealthType(HealthDataType type) {
    final current = List<HealthDataType>.from(state.selectedHealthTypes);
    if (current.contains(type)) {
      current.remove(type);
    } else {
      current.add(type);
    }
    state = state.copyWith(selectedHealthTypes: current);
  }

  /// Mark HealthKit as connected after successful permission request
  void setHealthKitConnected(bool connected) {
    state = state.copyWith(healthKitConnected: connected);
  }

  /// Skip HealthKit and proceed
  void skipHealthKit() {
    state = state.copyWith(
      healthKitConnected: false,
      selectedHealthTypes: [],
    );
    nextStep();
  }

  // ============================================================
  // STEP 6: FREQUENCY
  // ============================================================

  /// Set workouts per week
  void setWorkoutsPerWeek(int count) {
    if (count >= 1 && count <= 7) {
      state = state.copyWith(workoutsPerWeek: count, clearError: true);
    }
  }

  // ============================================================
  // COMPLETION
  // ============================================================

  /// Mark onboarding as completing (for loading state)
  void startCompletion() {
    state = state.copyWith(isCompleting: true, clearError: true);
  }

  /// Set completion error
  void setError(String message) {
    state = state.copyWith(isCompleting: false, errorMessage: message);
  }

  /// Reset state (for testing or error recovery)
  void reset() {
    state = const InitialOnboardingState();
  }
}

/// Provider for initial onboarding state
final initialOnboardingNotifierProvider =
    NotifierProvider<InitialOnboardingNotifier, InitialOnboardingState>(
  InitialOnboardingNotifier.new,
);

/// Provider for page controller to sync with state
final initialOnboardingPageControllerProvider = Provider.autoDispose<PageController>((ref) {
  final controller = PageController();

  // Listen to state changes and sync page
  ref.listen(initialOnboardingNotifierProvider, (previous, next) {
    if (previous?.currentStep != next.currentStep) {
      if (controller.hasClients) {
        controller.animateToPage(
          next.currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  });

  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});
