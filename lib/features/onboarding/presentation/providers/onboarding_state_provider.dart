import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

final onboardingStateProvider = StateNotifierProvider<OnboardingStateNotifier, OnboardingState>((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  return OnboardingStateNotifier(boxManager);
});

class OnboardingStateNotifier extends StateNotifier<OnboardingState> {

  OnboardingStateNotifier(this._boxManager) : super(const OnboardingState()) {
    _initializeOnboarding();
  }

  final HiveBoxManagerEnhanced _boxManager;
  static const String _boxName = 'onboarding_state';
  late Box<OnboardingState> _onboardingBox;

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
        debugPrint('📋 Onboarding state loaded: step ${savedState.currentStep}/${OnboardingState.totalSteps}');
        // Validate and fix any inconsistencies
        await validateOnboardingState();
      } else {
        debugPrint('📋 No saved onboarding state, checking for legacy migration');
        await _migrateFromLegacyAppConfig();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Onboarding initialization failed: $e');
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
        final appConfigBox = Hive.box(appConfigBoxName);
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
          debugPrint('✅ Migrated onboarding state from legacy AppConfig');
          return;
        }
      }

      debugPrint('📋 No legacy state found, using default onboarding state');
    } catch (e, stackTrace) {
      debugPrint('⚠️ Legacy migration failed: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      // Continue with default state if migration fails
    }
  }

  Future<void> _saveState() async {
    int retries = 3;

    while (retries > 0) {
      try {
        await _onboardingBox.put('state', state);
        debugPrint('💾 Onboarding state saved successfully: step ${state.currentStep}, completed: ${state.hasSeenGlobalOnboarding}');
        return; // Success, exit retry loop
      } catch (e, stackTrace) {
        retries--;
        debugPrint('❌ Error saving onboarding state (${3 - retries}/3): $e');

        if (retries == 0) {
          debugPrint('❌ Failed to save onboarding state after 3 attempts');
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
      debugPrint('🚀 Onboarding started');
    } else {
      debugPrint('⚠️ Onboarding already completed, skipping start');
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
      debugPrint('🔧 Auto-fixing: isCompleted true but hasSeenGlobal false');
      state = state.copyWith(hasSeenGlobalOnboarding: true);
      needsSave = true;
    }

    // Fix inconsistent state: seen but no completed steps
    if (state.hasSeenGlobalOnboarding && state.completedSteps.isEmpty) {
      debugPrint('🔧 Auto-fixing: hasSeenGlobal true but no completed steps');
      state = state.copyWith(
        completedSteps: List.generate(OnboardingState.totalSteps, (i) => i),
        currentStep: OnboardingState.totalSteps - 1,
      );
      needsSave = true;
    }

    // Fix invalid current step
    if (state.currentStep >= OnboardingState.totalSteps) {
      debugPrint('🔧 Auto-fixing: currentStep ${state.currentStep} >= totalSteps ${OnboardingState.totalSteps}');
      state = state.copyWith(currentStep: OnboardingState.totalSteps - 1);
      needsSave = true;
    }

    if (needsSave) {
      await _saveState();
      debugPrint('✅ Onboarding state auto-fixed and saved');
    }
  }

  // Debug method to print current onboarding state
  void debugOnboardingState() {
    debugPrint('=== 📋 Onboarding State Debug ===');
    debugPrint('hasSeenGlobalOnboarding: ${state.hasSeenGlobalOnboarding}');
    debugPrint('isCompleted: ${state.isCompleted}');
    debugPrint('canResume: ${state.canResume}');
    debugPrint('currentStep: ${state.currentStep}/${OnboardingState.totalSteps}');
    debugPrint('completedSteps: ${state.completedSteps}');
    debugPrint('progress: ${(state.progress * 100).toStringAsFixed(1)}%');
    debugPrint('lastInteraction: ${state.lastInteraction}');
    debugPrint('shouldShow: ${shouldShowOnboarding()}');
    debugPrint('stateValid: ${_isStateValid()}');
    debugPrint('===============================');
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