/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/providers
/// 🎯 Feature: ai_coach
/// 🔧 Type: provider
///
/// Feature Gate Provider - Manages feature access state
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/repositories/feature_gate_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/feature_gate_polling_service.dart';
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
    this._daysSinceRegistration, {
    FeatureGatePollingService? pollingService,
  })  : _pollingService = pollingService ?? FeatureGatePollingService(),
        super(const AsyncValue.loading()) {
    _initialize();
  }

  final FeatureGateRepository _repository;
  final FeatureGatePollingService _pollingService;
  final ExperienceLevel _experienceLevel;
  final int _workoutCount;
  final int _daysSinceRegistration;

  @override
  void dispose() {
    _pollingService.dispose();
    super.dispose();
  }

  /// Initialize feature gate state
  ///
  /// OPTIMIZATION (Task 1.4 + Task 2.3): Load from Firebase with cache + start polling
  /// - Cache hit = 0 Firestore reads
  /// - Cache miss = 1 Firestore read
  /// - Polling = 4 reads/day (6h interval, aligned with cache TTL)
  /// - Result: 4 reads/day instead of 40 (90% reduction vs real-time streams)
  Future<void> _initialize() async {
    try {
      // Load user preferences from Firebase (with cache)
      // TODO: Get userId from auth provider
      const userId = 'temp-user-id'; // Placeholder until auth integration
      final userPreferences = await _repository.loadUserPreferences(userId);

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

      // Start background polling (Task 2.3)
      // Polls every 6h to keep cache fresh
      _pollingService.startPolling(() async {
        await _refreshSilently();
      });
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Silent refresh (used by polling service)
  ///
  /// Refreshes data without showing loading state
  /// to avoid UI flicker during background polls
  Future<void> _refreshSilently() async {
    try {
      const userId = 'temp-user-id'; // Placeholder until auth integration
      final userPreferences = await _repository.loadUserPreferences(userId);

      final featureStatuses = await _repository.evaluateAllFeatureGates(
        userExperienceLevel: _experienceLevel,
        userWorkoutCount: _workoutCount,
        daysSinceRegistration: _daysSinceRegistration,
        userPreferences: userPreferences,
      );

      // Update state without loading indicator
      state = AsyncValue.data(
        FeatureGateState(
          featureStatuses: featureStatuses,
          userPreferences: userPreferences,
        ),
      );
    } catch (error) {
      // Log error but don't update state
      // (keeps showing last valid data)
      if (kDebugMode) {
        debugPrint('❌ [FeatureGateNotifier] Silent refresh failed: $error');
      }
    }
  }

  /// Check if feature is enabled
  bool isFeatureEnabled(AiCoachFeature feature) {
    final currentState = state.value;
    if (currentState == null) return false;

    return currentState.featureStatuses[feature]?.isEnabled ?? false;
  }

  /// Toggle user preference for feature
  ///
  /// OPTIMIZATION (Task 1.4): Save to Firebase with cache update
  /// - 1 Firestore write
  /// - Cache updated immediately (instant UI feedback)
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
      final newValue = !(updatedPreferences[feature] ?? false);
      updatedPreferences[feature] = newValue;

      // Save to Firebase (with cache update)
      // TODO: Get userId from auth provider
      const userId = 'temp-user-id'; // Placeholder until auth integration
      await _repository.saveUserPreference(
        userId: userId,
        feature: feature,
        enabled: newValue,
      );

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
  ///
  /// OPTIMIZATION (Task 1.4): Update Firebase context + invalidate cache
  /// - Updates user context in Firebase (1 write)
  /// - Invalidates cache (forces re-evaluation on next load)
  /// - Checks for newly unlocked features
  Future<void> refresh({
    ExperienceLevel? newExperienceLevel,
    int? newWorkoutCount,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Update user context in Firebase
      // TODO: Get userId from auth provider
      const userId = 'temp-user-id'; // Placeholder until auth integration

      if (newExperienceLevel != null || newWorkoutCount != null) {
        await _repository.updateUserContext(
          userId: userId,
          experienceLevel: newExperienceLevel?.name,
          workoutCount: newWorkoutCount,
        );
      }

      // Re-initialize (will load from Firebase)
      await _initialize();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Called when a feature is unlocked (Task 1.4 + Task 2.4 + Task 3.4)
  ///
  /// Actions:
  /// 1. Invalidates cache to ensure UI shows latest unlock state
  /// 2. Triggers immediate poll (bypasses 6h interval)
  /// 3. Tracks analytics event (Task 3.4)
  /// 4. Refreshes UI state
  ///
  /// UI Integration (Task 3.3):
  /// - Show AchievementUnlockAnimation widget
  /// - Play haptic feedback
  /// - Display confetti animation
  Future<void> onFeatureUnlock(AiCoachFeature feature) async {
    // TODO: Get userId from auth provider
    const userId = 'temp-user-id'; // Placeholder until auth integration

    // Invalidate cache
    _repository.invalidateCacheOnUnlock(userId, feature);

    // Task 3.4: Track analytics event
    // TODO: Integrate with Firebase Analytics when available
    // await _analytics.logEvent(
    //   name: 'feature_unlocked',
    //   parameters: {
    //     'feature_name': feature.name,
    //     'workout_count': _workoutCount,
    //     'days_since_registration': _daysSinceRegistration,
    //     'experience_level': _experienceLevel.name,
    //     'unlock_method': 'automatic', // vs 'manual_override'
    //   },
    // );

    if (kDebugMode) {
      debugPrint(
        '🔓 [FeatureGateNotifier] Feature unlocked: ${feature.name} '
        '(workouts: $_workoutCount, days: $_daysSinceRegistration)',
      );
    }

    // Trigger immediate poll (Task 2.4)
    // Bypasses 6h interval to get fresh data immediately
    await _pollingService.pollNow();

    // Refresh UI state
    await refresh();
  }

  /// Manual refresh trigger (Task 2.4)
  ///
  /// Called by user actions:
  /// - Pull-to-refresh in settings
  /// - Feature toggle
  /// - App resume (if cache expired)
  Future<void> manualRefresh() async {
    // Trigger immediate poll
    await _pollingService.pollNow();
  }

  /// Get polling statistics (for debugging)
  Map<String, dynamic> getPollingStats() {
    return _pollingService.stats;
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
