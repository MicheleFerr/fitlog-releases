/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: provider
/// 🌍 Localization: N/A (state management)
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Riverpod: StateNotifier
/// - SharedPreferences: Persistent storage
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Provider per lo stato dell'onboarding del template
final templateOnboardingProvider = NotifierProvider<TemplateOnboardingNotifier, TemplateOnboardingState>(TemplateOnboardingNotifier.new);

/// Stato dell'onboarding
class TemplateOnboardingState {
  const TemplateOnboardingState({
    this.hasSeenOnboarding = false,
    this.currentStep = 0,
    this.isActive = false,
  });

  final bool hasSeenOnboarding;
  final int currentStep;
  final bool isActive;

  TemplateOnboardingState copyWith({
    bool? hasSeenOnboarding,
    int? currentStep,
    bool? isActive,
  }) {
    return TemplateOnboardingState(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      currentStep: currentStep ?? this.currentStep,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Notifier per gestire l'onboarding
class TemplateOnboardingNotifier extends Notifier<TemplateOnboardingState> {
  // 🔐 User-scoped cache key
  String get _onboardingKey => userCacheKeys.userScopedKey('template_onboarding_seen');
  static const int totalSteps = 4; // Nome, Descrizione, Tag, Timer

  @override
  TemplateOnboardingState build() {
    _loadOnboardingState();
    return const TemplateOnboardingState();
  }

  /// Carica lo stato salvato
  Future<void> _loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool(_onboardingKey) ?? false;
    state = state.copyWith(hasSeenOnboarding: hasSeenOnboarding);
  }

  /// Avvia l'onboarding
  void startOnboarding() {
    if (!state.hasSeenOnboarding) {
      state = state.copyWith(isActive: true, currentStep: 0);
    }
  }

  /// Passa allo step successivo
  void nextStep() {
    if (state.currentStep < totalSteps - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    } else {
      completeOnboarding();
    }
  }

  /// Salta l'onboarding
  Future<void> skipOnboarding() async {
    await completeOnboarding();
  }

  /// Completa l'onboarding
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    state = state.copyWith(
      hasSeenOnboarding: true,
      isActive: false,
      currentStep: 0,
    );
  }

  /// Reset onboarding (per testing)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
    state = const TemplateOnboardingState();
  }
}