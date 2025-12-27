import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';

final onboardingStateProvider = NotifierProvider<OnboardingStateNotifier, OnboardingState>(OnboardingStateNotifier.new);

// Alias for convenience (used in quick_start_screen.dart)
final onboardingProvider = onboardingStateProvider;

class OnboardingStateNotifier extends Notifier<OnboardingState> {
  static const String _boxName = 'onboarding_state';
  late Box<OnboardingState> _onboardingBox;

  @override
  OnboardingState build() {
    // Initialize onboarding asynchronously
    _initializeOnboarding();
    return const OnboardingState();
  }

  HiveBoxManagerEnhanced get _boxManager => ref.read(hiveBoxManagerProvider);

  Future<void> _initializeOnboarding() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _onboardingBox = await _boxManager.openBox<OnboardingState>(_boxName);
      } else {
        _onboardingBox = Hive.box<OnboardingState>(_boxName);
      }
      final savedState = _onboardingBox.get('state');
      if (savedState != null) {
        state = savedState;
        if (kDebugMode) {
          debugPrint('📋 Onboarding state loaded: step ${savedState.currentStep}/${OnboardingState.totalSteps}');
        }
        // Validate and fix any inconsistencies
        await validateOnboardingState();
      } else {
        if (kDebugMode) {
          debugPrint('📋 No saved onboarding state, checking for legacy migration');
        }
        await _migrateFromLegacyAppConfig();
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Onboarding initialization failed: $e');
      }
      debugPrint('📍 Stack trace: $stackTrace');
      // If there's an error, use default state
      state = const OnboardingState();
    }
  }

  // Migration from legacy AppConfig hasSeenWorkoutOnboarding
  Future<void> _migrateFromLegacyAppConfig() async {
    try {
      // Check if legacy AppConfig has onboarding state
      const appConfigBoxName = 'app_config';
      if (Hive.isBoxOpen(appConfigBoxName)) {
        // IMPORTANT: Must use same type parameter as box was opened with
        final appConfigBox = Hive.box<AppConfig>(appConfigBoxName);
        final legacyConfig = appConfigBox.get('config');

        // Check if legacy has seen onboarding
        if (legacyConfig != null && legacyConfig.hasSeenWorkoutOnboarding == true) {
          // Migrate to new system - mark as completed
          state = state.copyWith(
            hasSeenGlobalOnboarding: true,
            currentStep: OnboardingState.totalSteps - 1,
            completedSteps: List.generate(OnboardingState.totalSteps, (i) => i),
            canResume: false,
            lastInteraction: DateTime.now(),
          );
          await _saveState();
          if (kDebugMode) {
            debugPrint('✅ Migrated onboarding state from legacy AppConfig');
          }
          return;
        }
      }

      if (kDebugMode) {
        debugPrint('📋 No legacy state found, using default onboarding state');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('⚠️ Legacy migration failed: $e');
      }
      debugPrint('📍 Stack trace: $stackTrace');
      // Continue with default state if migration fails
    }
  }

  Future<void> _saveState() async {
    int retries = 3;

    while (retries > 0) {
      try {
        await _onboardingBox.put('state', state);
        if (kDebugMode) {
          debugPrint('💾 Onboarding state saved successfully: step ${state.currentStep}, completed: ${state.hasSeenGlobalOnboarding}');
        }
        return; // Success, exit retry loop
      } catch (e, stackTrace) {
        retries--;
        if (kDebugMode) {
          debugPrint('❌ Error saving onboarding state (${3 - retries}/3): $e');
        }

        if (retries == 0) {
          if (kDebugMode) {
            debugPrint('❌ Failed to save onboarding state after 3 attempts');
          }
          debugPrint('📍 Stack trace: $stackTrace');
          // Could potentially show a snackbar to user in the future
          // For now, just log the error - the app should continue working
        } else {
          // Wait before retrying
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    }
  }

  // Start the onboarding process
  Future<void> startOnboarding() async {
    // Only start if onboarding hasn't been seen or completed
    if (!state.hasSeenGlobalOnboarding && !state.isCompleted) {
      state = state.copyWith(
        currentStep: 0,
        canResume: true,
        lastInteraction: DateTime.now(),
      );
      await _saveState();
      if (kDebugMode) {
        debugPrint('🚀 Onboarding started');
      }
    } else {
      if (kDebugMode) {
        debugPrint('⚠️ Onboarding already completed, skipping start');
      }
    }
  }

  // Move to next step
  Future<void> nextStep() async {
    if (state.currentStep < OnboardingState.totalSteps - 1) {
      final newCompletedSteps = List<int>.from(state.completedSteps);
      if (!newCompletedSteps.contains(state.currentStep)) {
        newCompletedSteps.add(state.currentStep);
      }

      state = state.copyWith(
        currentStep: state.currentStep + 1,
        completedSteps: newCompletedSteps,
        lastInteraction: DateTime.now(),
      );
      await _saveState();
    }
  }

  // Go to specific step
  Future<void> goToStep(int stepIndex) async {
    if (stepIndex >= 0 && stepIndex < OnboardingState.totalSteps) {
      state = state.copyWith(
        currentStep: stepIndex,
        lastInteraction: DateTime.now(),
      );
      await _saveState();
    }
  }

  // Mark step as completed
  Future<void> completeStep(int stepIndex) async {
    final newCompletedSteps = List<int>.from(state.completedSteps);
    if (!newCompletedSteps.contains(stepIndex)) {
      newCompletedSteps.add(stepIndex);
    }

    state = state.copyWith(
      completedSteps: newCompletedSteps,
      lastInteraction: DateTime.now(),
    );
    await _saveState();
  }

  // Complete entire onboarding
  Future<void> completeOnboarding() async {
    final allSteps = List.generate(OnboardingState.totalSteps, (index) => index);

    state = state.copyWith(
      hasSeenGlobalOnboarding: true,
      currentStep: OnboardingState.totalSteps - 1,
      completedSteps: allSteps,
      canResume: false,
      lastInteraction: DateTime.now(),
    );
    await _saveState();
  }

  // Skip onboarding
  Future<void> skipOnboarding() async {
    state = state.copyWith(
      hasSeenGlobalOnboarding: true,
      canResume: false,
      lastInteraction: DateTime.now(),
    );
    await _saveState();
  }

  // NEW ONBOARDING SYSTEM METHODS

  /// Complete Quick Start and set user experience level
  /// @param experienceLevel: 'beginner' or 'expert'
  ///
  /// For 'beginner' users:
  ///   - Does NOT mark global onboarding as seen (allows tour to auto-start)
  ///   - Tour will start on home screen after Quick Start
  ///   - Global onboarding is marked complete only after tour completion
  ///
  /// For 'expert' users:
  ///   - Marks global onboarding as seen immediately (skips tour)
  ///   - Goes straight to main app without guided tour
  Future<void> completeQuickStart(String experienceLevel) async {
    final isBeginner = experienceLevel == 'beginner';

    state = state.copyWith(
      userExperienceLevel: experienceLevel,
      quickStartCompletedAt: DateTime.now(),
      // Only mark onboarding as seen for expert users (skip tour)
      // Beginner users will see the tour on home screen
      hasSeenGlobalOnboarding: !isBeginner,
      lastInteraction: DateTime.now(),
    );
    await _saveState();
    if (kDebugMode) {
      debugPrint('✅ Quick Start completed: $experienceLevel (hasSeenGlobal: ${!isBeginner})');
    }
  }

  /// P4 RETENTION: Select fitness goal and weekly workout target
  /// @param goalType: 'buildMuscle' | 'loseWeight' | 'getStronger' | 'stayFit'
  /// @param weeklyTarget: Number of workouts per week (2-7)
  /// Part of P4 onboarding retention feature (+10-15% completion improvement)
  Future<void> selectGoal(String goalType, int weeklyTarget) async {
    state = state.copyWith(
      userGoal: goalType,
      weeklyWorkoutTarget: weeklyTarget,
      lastInteraction: DateTime.now(),
    );
    await _saveState();
    if (kDebugMode) {
      debugPrint('🎯 P4 Goal selected: $goalType, target: $weeklyTarget workouts/week');
    }
  }

  /// Mark an overlay as seen
  /// @param overlayId: identifier for the overlay (e.g., 'createWorkoutCTA')
  Future<void> markOverlaySeen(String overlayId) async {
    if (!state.hasSeenOverlay(overlayId)) {
      final newSeenOverlays = List<String>.from(state.seenOverlays)..add(overlayId);
      state = state.copyWith(
        seenOverlays: newSeenOverlays,
        lastInteraction: DateTime.now(),
      );
      await _saveState();
      if (kDebugMode) {
        debugPrint('👁️ Overlay seen: $overlayId');
      }
    }
  }

  /// Mark first workout as completed (triggers Phase 2)
  Future<void> markFirstWorkoutCompleted() async {
    if (!state.hasCompletedFirstWorkout) {
      state = state.copyWith(
        hasCompletedFirstWorkout: true,
        lastInteraction: DateTime.now(),
      );
      await _saveState();
      if (kDebugMode) {
        debugPrint('🎉 First workout completed! Phase 2 unlocked');
      }
    }
  }

  // PHASE 2: Guided First Workout Methods

  /// Mark when user adds their first exercise
  Future<void> markFirstExerciseAdded() async {
    if (state.firstExerciseAddedAt == null) {
      state = state.copyWith(
        firstExerciseAddedAt: DateTime.now(),
        lastInteraction: DateTime.now(),
      );
      await _saveState();
      if (kDebugMode) {
        debugPrint('✅ First exercise added');
      }
    }
  }

  /// Mark when user completes their first set
  Future<void> markFirstSetCompleted() async {
    if (state.firstSetCompletedAt == null) {
      state = state.copyWith(
        firstSetCompletedAt: DateTime.now(),
        lastInteraction: DateTime.now(),
      );
      await _saveState();
      if (kDebugMode) {
        debugPrint('💪 First set completed!');
      }
    }
  }

  /// Mark rest timer explanation as seen
  Future<void> markRestTimerExplanationSeen() async {
    if (!state.hasSeenRestTimerExplanation) {
      state = state.copyWith(
        hasSeenRestTimerExplanation: true,
        lastInteraction: DateTime.now(),
      );
      await _saveState();
      if (kDebugMode) {
        debugPrint('⏱️ Rest timer explanation seen');
      }
    }
  }

  /// Accept legal disclaimer (medical/liability)
  /// Required before user can access main app features
  Future<void> acceptLegalDisclaimer() async {
    if (!state.hasAcceptedLegalDisclaimer) {
      state = state.copyWith(
        hasAcceptedLegalDisclaimer: true,
        legalDisclaimerAcceptedAt: DateTime.now(),
        lastInteraction: DateTime.now(),
      );
      await _saveState();
      if (kDebugMode) {
        debugPrint('⚖️ Legal disclaimer accepted at ${state.legalDisclaimerAcceptedAt}');
      }
    }
  }

  /// Reset overlay version (for testing/deprecation)
  Future<void> resetOverlayVersion() async {
    state = state.copyWith(
      seenOverlays: [],
      overlayVersionSeen: state.overlayVersionSeen + 1,
      lastInteraction: DateTime.now(),
    );
    await _saveState();
    if (kDebugMode) {
      debugPrint('🔄 Overlay version reset to ${state.overlayVersionSeen}');
    }
  }

  // Save step-specific data
  Future<void> saveStepData(String key, dynamic value) async {
    final newStepData = Map<String, dynamic>.from(state.stepData);
    newStepData[key] = value;

    state = state.copyWith(
      stepData: newStepData,
      lastInteraction: DateTime.now(),
    );
    await _saveState();
  }

  // Get step-specific data
  T? getStepData<T>(String key) {
    return state.stepData[key] as T?;
  }

  // Reset onboarding (for debugging/testing)
  Future<void> resetOnboarding() async {
    state = const OnboardingState();
    await _saveState();
  }

  // Check if user should see onboarding
  bool shouldShowOnboarding() {
    // Show only if user hasn't seen it AND it's not completed
    // This prevents showing onboarding after completion/skip
    return !state.hasSeenGlobalOnboarding && !state.isCompleted;
  }

  // Get current step info
  OnboardingStep getCurrentStep() {
    return OnboardingStep.fromIndex(state.currentStep);
  }

  // Check if step is accessible (previous steps completed)
  bool isStepAccessible(int stepIndex) {
    if (stepIndex == 0) return true; // First step is always accessible
    return state.isStepCompleted(stepIndex - 1);
  }

  // Validate onboarding state consistency
  Future<void> validateOnboardingState() async {
    bool needsSave = false;

    // Fix inconsistent state: completed but not seen
    if (state.isCompleted && !state.hasSeenGlobalOnboarding) {
      if (kDebugMode) {
        debugPrint('🔧 Auto-fixing: isCompleted true but hasSeenGlobal false');
      }
      state = state.copyWith(hasSeenGlobalOnboarding: true);
      needsSave = true;
    }

    // Fix inconsistent state: seen but no completed steps
    if (state.hasSeenGlobalOnboarding && state.completedSteps.isEmpty) {
      if (kDebugMode) {
        debugPrint('🔧 Auto-fixing: hasSeenGlobal true but no completed steps');
      }
      state = state.copyWith(
        completedSteps: List.generate(OnboardingState.totalSteps, (i) => i),
        currentStep: OnboardingState.totalSteps - 1,
      );
      needsSave = true;
    }

    // Fix invalid current step
    if (state.currentStep >= OnboardingState.totalSteps) {
      if (kDebugMode) {
        debugPrint('🔧 Auto-fixing: currentStep ${state.currentStep} >= totalSteps ${OnboardingState.totalSteps}');
      }
      state = state.copyWith(currentStep: OnboardingState.totalSteps - 1);
      needsSave = true;
    }

    if (needsSave) {
      await _saveState();
      if (kDebugMode) {
        debugPrint('✅ Onboarding state auto-fixed and saved');
      }
    }
  }

  // Debug method to print current onboarding state
  void debugOnboardingState() {
    if (kDebugMode) {
      debugPrint('=== 📋 Onboarding State Debug ===');
    }
    debugPrint('hasSeenGlobalOnboarding: ${state.hasSeenGlobalOnboarding}');
    if (kDebugMode) {
      debugPrint('isCompleted: ${state.isCompleted}');
    }
    debugPrint('canResume: ${state.canResume}');
    if (kDebugMode) {
      debugPrint('currentStep: ${state.currentStep}/${OnboardingState.totalSteps}');
    }
    debugPrint('completedSteps: ${state.completedSteps}');
    if (kDebugMode) {
      debugPrint('progress: ${(state.progress * 100).toStringAsFixed(1)}%');
    }
    debugPrint('lastInteraction: ${state.lastInteraction}');
    if (kDebugMode) {
      debugPrint('shouldShow: ${shouldShowOnboarding()}');
    }
    debugPrint('stateValid: ${_isStateValid()}');
    if (kDebugMode) {
      debugPrint('===============================');
    }
  }

  // Check if current state is valid/consistent
  bool _isStateValid() {
    // Check consistency rules
    if (state.isCompleted && !state.hasSeenGlobalOnboarding) return false;
    if (state.hasSeenGlobalOnboarding && state.completedSteps.isEmpty) return false;
    if (state.currentStep >= OnboardingState.totalSteps) return false;
    if (state.currentStep < 0) return false;
    return true;
  }
}

// Helper providers
final currentOnboardingStepProvider = Provider<OnboardingStep>((ref) {
  final state = ref.watch(onboardingStateProvider);
  return OnboardingStep.fromIndex(state.currentStep);
});

final onboardingProgressProvider = Provider<double>((ref) {
  final state = ref.watch(onboardingStateProvider);
  return state.progress;
});

final shouldShowOnboardingProvider = Provider<bool>((ref) {
  final state = ref.watch(onboardingStateProvider);
  return !state.hasSeenGlobalOnboarding && !state.isCompleted;
});

final onboardingCanResumeProvider = Provider<bool>((ref) {
  final state = ref.watch(onboardingStateProvider);
  return state.canResume && !state.isCompleted;
});