/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/providers
/// 🎯 Feature: ai_coach
/// 🔧 Type: provider
///
/// Feature Gate Provider - Manages feature access state
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/repositories/feature_gate_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/feature_gate_config.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';

/// Feature Gate State
class FeatureGateState {
  const FeatureGateState({
    required this.featureStatuses,
    required this.userPreferences,
    this.isLoading = false,
  });

  final Map<AiCoachFeature, FeatureGateStatus> featureStatuses;
  final Map<AiCoachFeature, bool> userPreferences;
  final bool isLoading;

  FeatureGateState copyWith({
    Map<AiCoachFeature, FeatureGateStatus>? featureStatuses,
    Map<AiCoachFeature, bool>? userPreferences,
    bool? isLoading,
  }) {
    return FeatureGateState(
      featureStatuses: featureStatuses ?? this.featureStatuses,
      userPreferences: userPreferences ?? this.userPreferences,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Feature Gate Notifier
class FeatureGateNotifier extends StateNotifier<AsyncValue<FeatureGateState>> {
  FeatureGateNotifier(
    this._repository,
    this._experienceLevel,
    this._workoutCount,
    this._daysSinceRegistration,
  ) : super(const AsyncValue.loading()) {
    _initialize();
  }

  final FeatureGateRepository _repository;
  final ExperienceLevel _experienceLevel;
  final int _workoutCount;
  final int _daysSinceRegistration;

  /// Initialize feature gate state
  Future<void> _initialize() async {
    try {
      // TODO: Load user preferences from storage
      final userPreferences = <AiCoachFeature, bool>{
        AiCoachFeature.insights: true,
        AiCoachFeature.notifications: true,
      };

      final featureStatuses = await _repository.evaluateAllFeatureGates(
        userExperienceLevel: _experienceLevel,
        userWorkoutCount: _workoutCount,
        daysSinceRegistration: _daysSinceRegistration,
        userPreferences: userPreferences,
      );

      state = AsyncValue.data(
        FeatureGateState(
          featureStatuses: featureStatuses,
          userPreferences: userPreferences,
        ),
      );
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Check if feature is enabled
  bool isFeatureEnabled(AiCoachFeature feature) {
    final currentState = state.value;
    if (currentState == null) return false;

    return currentState.featureStatuses[feature]?.isEnabled ?? false;
  }

  /// Toggle user preference for feature
  Future<void> toggleFeaturePreference(AiCoachFeature feature) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Get current config
    final config = _repository
        .getAllFeatureGates()
        .firstWhere((c) => c.feature == feature);

    if (!config.userConfigurable) return; // Can't toggle

    try {
      // Update preference
      final updatedPreferences =
          Map<AiCoachFeature, bool>.from(currentState.userPreferences);
      updatedPreferences[feature] = !(updatedPreferences[feature] ?? false);

      // TODO: Save to storage
      // await _storage.saveUserPreferences(updatedPreferences);

      // Re-evaluate gates
      final featureStatuses = await _repository.evaluateAllFeatureGates(
        userExperienceLevel: _experienceLevel,
        userWorkoutCount: _workoutCount,
        daysSinceRegistration: _daysSinceRegistration,
        userPreferences: updatedPreferences,
      );

      state = AsyncValue.data(
        currentState.copyWith(
          featureStatuses: featureStatuses,
          userPreferences: updatedPreferences,
        ),
      );
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Refresh feature gates (after workout count increase, etc.)
  Future<void> refresh({
    ExperienceLevel? newExperienceLevel,
    int? newWorkoutCount,
  }) async {
    state = const AsyncValue.loading();

    // TODO: Update with new values
    await _initialize();
  }
}

/// Provider: Feature Gate Repository
final featureGateRepositoryProvider = Provider<FeatureGateRepository>((ref) {
  return FeatureGateRepository();
});

/// Provider: Feature Gate Notifier
final featureGateProvider =
    StateNotifierProvider<FeatureGateNotifier, AsyncValue<FeatureGateState>>(
        (ref) {
  // TODO: Get from auth/onboarding providers
  const experienceLevel = ExperienceLevel.beginner;
  const workoutCount = 0;
  const daysSinceRegistration = 0;

  final repository = ref.watch(featureGateRepositoryProvider);
  return FeatureGateNotifier(
    repository,
    experienceLevel,
    workoutCount,
    daysSinceRegistration,
  );
});

/// Provider: Is Feature Enabled
///
/// Check if specific feature is enabled for current user
final isFeatureEnabledProvider =
    Provider.family<bool, AiCoachFeature>((ref, feature) {
  ref.watch(featureGateProvider);
  final notifier = ref.read(featureGateProvider.notifier);

  return notifier.isFeatureEnabled(feature);
});

/// Provider: Feature Gate Status
///
/// Get detailed status for specific feature
final featureGateStatusProvider = Provider.family<FeatureGateStatus?,
    AiCoachFeature>((ref, feature) {
  final featureGateState = ref.watch(featureGateProvider);
  return featureGateState.value?.featureStatuses[feature];
});

/// Provider: Enabled Features
///
/// List of all enabled features for current user
final enabledFeaturesProvider = Provider<List<AiCoachFeature>>((ref) {
  final featureGateState = ref.watch(featureGateProvider);
  final featureStatuses = featureGateState.value?.featureStatuses ?? {};

  return featureStatuses.entries
      .where((entry) => entry.value.isEnabled)
      .map((entry) => entry.key)
      .toList();
});
