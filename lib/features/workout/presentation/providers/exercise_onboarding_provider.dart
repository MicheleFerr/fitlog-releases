/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: provider
/// 🌍 Localization: N/A (State management)
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Provider for managing exercise onboarding state and progression.
/// Persists completion state using SharedPreferences.
///
/// Total Steps: 6
/// 1. Single Exercise tab
/// 2. Select exercise button
/// 3. Search bar
/// 4. First exercise in list
/// 5. Category filters
/// 6. Confirm button
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider per lo stato dell'onboarding degli esercizi
final exerciseOnboardingProvider =
    StateNotifierProvider<ExerciseOnboardingNotifier, ExerciseOnboardingState>(
  (ref) => ExerciseOnboardingNotifier(),
);

/// Stato dell'onboarding degli esercizi
class ExerciseOnboardingState {
  const ExerciseOnboardingState({
    this.hasSeenOnboarding = false,
    this.currentStep = 0,
    this.isActive = false,
  });

  final bool hasSeenOnboarding;
  final int currentStep;
  final bool isActive;

  ExerciseOnboardingState copyWith({
    bool? hasSeenOnboarding,
    int? currentStep,
    bool? isActive,
  }) {
    return ExerciseOnboardingState(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      currentStep: currentStep ?? this.currentStep,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Notifier per gestire lo stato dell'onboarding degli esercizi
class ExerciseOnboardingNotifier extends StateNotifier<ExerciseOnboardingState> {
  ExerciseOnboardingNotifier() : super(const ExerciseOnboardingState()) {
    _loadOnboardingState();
  }

  static const String _onboardingKey = 'exercise_onboarding_seen';
  static const int totalSteps = 6;

  /// Carica lo stato dell'onboarding da SharedPreferences
  Future<void> _loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool(_onboardingKey) ?? false;
    state = state.copyWith(hasSeenOnboarding: hasSeenOnboarding);
  }

  /// Avvia l'onboarding se non è stato ancora visto
  Future<void> startOnboarding() async {
    if (!state.hasSeenOnboarding) {
      state = state.copyWith(
        isActive: true,
        currentStep: 0,
      );
    }
  }

  /// Passa allo step successivo
  void nextStep() {
    if (state.currentStep < totalSteps - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    } else {
      _completeOnboarding();
    }
  }

  /// Salta l'onboarding
  Future<void> skipOnboarding() async {
    await _completeOnboarding();
  }

  /// Completa l'onboarding e salva in SharedPreferences
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    state = state.copyWith(
      hasSeenOnboarding: true,
      isActive: false,
      currentStep: 0,
    );
  }

  /// Reset dell'onboarding (per testing)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
    state = const ExerciseOnboardingState();
  }
}
