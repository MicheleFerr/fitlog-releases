/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/onboarding/domain/services
/// Feature: Onboarding Choice Service
/// Type: Service + Providers
///
/// Manages the post-onboarding choice (guided wizard vs explore)
/// and the template wizard reminder card state.
library;

import 'package:gymbro_flutter_new/core/config/feature_flags.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User's choice after completing initial onboarding
enum OnboardingChoice {
  /// User chose "Guide me" - start template wizard
  guided,

  /// User chose "I'll explore" - go to home
  explore,

  /// Not asked yet (existing users, or not reached choice screen)
  notAsked,
}

/// Keys for SharedPreferences
class _Keys {
  static const onboardingChoice = 'onboarding_choice';
  static const templateWizardCompleted = 'template_wizard_completed';
  static const templateWizardDismissed = 'template_wizard_dismissed';

  // Guided V1 states
  static const guidedTestModeActive = 'guided_test_mode_active';
  static const guidedTestStarted = 'guided_test_started';
  static const guidedTestCompleted = 'guided_test_completed';
  static const guidedRealStarted = 'guided_real_started';
  static const guidedRealCompleted = 'guided_real_completed';
  static const guidedActiveWorkoutId = 'guided_active_workout_id';
  static const guidedSoftGateImpressions = 'guided_soft_gate_impressions';
  static const guidedLastReminderAt = 'guided_last_reminder_at';

  static const all = <String>[
    onboardingChoice,
    templateWizardCompleted,
    templateWizardDismissed,
    guidedTestModeActive,
    guidedTestStarted,
    guidedTestCompleted,
    guidedRealStarted,
    guidedRealCompleted,
    guidedActiveWorkoutId,
    guidedSoftGateImpressions,
    guidedLastReminderAt,
  ];
}

/// Service for managing onboarding choice state
class OnboardingChoiceService {
  const OnboardingChoiceService(this._prefs);

  final SharedPreferences _prefs;

  /// Get the user's onboarding choice
  OnboardingChoice getChoice() {
    final value = _prefs.getString(_Keys.onboardingChoice);
    return OnboardingChoice.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OnboardingChoice.notAsked,
    );
  }

  /// Set the user's onboarding choice
  Future<void> setChoice(OnboardingChoice choice) async {
    await _prefs.setString(_Keys.onboardingChoice, choice.name);
  }

  /// Check if template wizard was completed
  bool isTemplateWizardCompleted() {
    return _prefs.getBool(_Keys.templateWizardCompleted) ?? false;
  }

  /// Mark template wizard as completed
  Future<void> setTemplateWizardCompleted(bool value) async {
    await _prefs.setBool(_Keys.templateWizardCompleted, value);
  }

  /// Check if template wizard reminder was dismissed
  bool isTemplateWizardDismissed() {
    return _prefs.getBool(_Keys.templateWizardDismissed) ?? false;
  }

  /// Dismiss template wizard reminder card
  Future<void> dismissTemplateWizardReminder() async {
    await _prefs.setBool(_Keys.templateWizardDismissed, true);
  }

  // ---------------------------------------------------------------------------
  // Guided V1 (test + real mode)
  // ---------------------------------------------------------------------------

  bool isGuidedTestModeActive() {
    return _prefs.getBool(_Keys.guidedTestModeActive) ?? false;
  }

  bool isGuidedTestStarted() {
    return _prefs.getBool(_Keys.guidedTestStarted) ?? false;
  }

  bool isGuidedTestCompleted() {
    return _prefs.getBool(_Keys.guidedTestCompleted) ?? false;
  }

  bool isGuidedRealStarted() {
    return _prefs.getBool(_Keys.guidedRealStarted) ?? false;
  }

  bool isGuidedRealCompleted() {
    return _prefs.getBool(_Keys.guidedRealCompleted) ?? false;
  }

  String? getGuidedActiveWorkoutId() {
    return _prefs.getString(_Keys.guidedActiveWorkoutId);
  }

  int getGuidedSoftGateImpressions() {
    return _prefs.getInt(_Keys.guidedSoftGateImpressions) ?? 0;
  }

  DateTime? getGuidedLastReminderAt() {
    final raw = _prefs.getString(_Keys.guidedLastReminderAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> startGuidedTestMode({required String workoutId}) async {
    await _prefs.setBool(_Keys.guidedTestModeActive, true);
    await _prefs.setBool(_Keys.guidedTestStarted, true);
    await _prefs.setBool(_Keys.guidedTestCompleted, false);
    await _prefs.setBool(_Keys.guidedRealStarted, false);
    await _prefs.setBool(_Keys.guidedRealCompleted, false);
    await _prefs.setInt(_Keys.guidedSoftGateImpressions, 0);
    await _prefs.remove(_Keys.guidedLastReminderAt);
    await _prefs.setString(_Keys.guidedActiveWorkoutId, workoutId);
  }

  Future<void> completeGuidedTestMode() async {
    await _prefs.setBool(_Keys.guidedTestModeActive, false);
    await _prefs.setBool(_Keys.guidedTestCompleted, true);
    await _prefs.remove(_Keys.guidedActiveWorkoutId);
  }

  Future<void> cancelGuidedTestMode() async {
    await _prefs.setBool(_Keys.guidedTestModeActive, false);
    await _prefs.remove(_Keys.guidedActiveWorkoutId);
  }

  Future<void> startGuidedRealMode() async {
    await _prefs.setBool(_Keys.guidedRealStarted, true);
  }

  Future<void> completeGuidedRealMode() async {
    await _prefs.setBool(_Keys.guidedRealStarted, true);
    await _prefs.setBool(_Keys.guidedRealCompleted, true);
    await _prefs.setBool(_Keys.guidedTestModeActive, false);
    await _prefs.remove(_Keys.guidedActiveWorkoutId);
  }

  bool isGuidedActiveTestWorkout(String workoutId) {
    if (!isGuidedTestModeActive()) return false;
    return getGuidedActiveWorkoutId() == workoutId;
  }

  Future<int> incrementGuidedReminderImpression() async {
    final next = getGuidedSoftGateImpressions() + 1;
    await _prefs.setInt(_Keys.guidedSoftGateImpressions, next);
    return next;
  }

  Future<void> deferGuidedRealReminder() async {
    await _prefs.setString(
      _Keys.guidedLastReminderAt,
      DateTime.now().toIso8601String(),
    );
  }

  bool shouldShowGuidedSoftGateReminder({
    DateTime? now,
    Duration cooldown = const Duration(hours: 8),
    int maxImpressions = 8,
  }) {
    if (!FeatureFlags.guidedTestModeEnabled) return false;
    if (getChoice() != OnboardingChoice.guided) return false;
    if (!isGuidedTestCompleted()) return false;
    if (isGuidedRealCompleted()) return false;
    if (isGuidedTestModeActive()) return false;
    if (getGuidedSoftGateImpressions() >= maxImpressions) return false;

    final lastReminder = getGuidedLastReminderAt();
    if (lastReminder == null) return true;
    return (now ?? DateTime.now()).difference(lastReminder) >= cooldown;
  }

  /// Reset all flags (for testing)
  Future<void> resetAll() async {
    for (final key in _Keys.all) {
      await _prefs.remove(key);
    }
  }
}

/// Provider for SharedPreferences instance
final _sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// Provider for OnboardingChoiceService
final onboardingChoiceServiceProvider = Provider<OnboardingChoiceService?>((
  ref,
) {
  final prefsAsync = ref.watch(_sharedPrefsProvider);
  return prefsAsync.whenOrNull(data: (prefs) => OnboardingChoiceService(prefs));
});

/// Provider for current onboarding choice
final onboardingChoiceProvider = Provider<OnboardingChoice>((ref) {
  final service = ref.watch(onboardingChoiceServiceProvider);
  return service?.getChoice() ?? OnboardingChoice.notAsked;
});

/// Provider for template wizard completed status
final templateWizardCompletedProvider = Provider<bool>((ref) {
  final service = ref.watch(onboardingChoiceServiceProvider);
  return service?.isTemplateWizardCompleted() ?? false;
});

/// Provider for template wizard dismissed status
final templateWizardDismissedProvider = Provider<bool>((ref) {
  final service = ref.watch(onboardingChoiceServiceProvider);
  return service?.isTemplateWizardDismissed() ?? false;
});

/// Provider for guided test mode active state.
final guidedTestModeActiveProvider = Provider<bool>((ref) {
  final service = ref.watch(onboardingChoiceServiceProvider);
  return service?.isGuidedTestModeActive() ?? false;
});

/// Provider for guided test completion state.
final guidedTestCompletedProvider = Provider<bool>((ref) {
  final service = ref.watch(onboardingChoiceServiceProvider);
  return service?.isGuidedTestCompleted() ?? false;
});

/// Provider for guided real completion state.
final guidedRealCompletedProvider = Provider<bool>((ref) {
  final service = ref.watch(onboardingChoiceServiceProvider);
  return service?.isGuidedRealCompleted() ?? false;
});

/// Provider to determine if we should show the template wizard reminder card
/// Shows only if:
/// 1. User chose "explore" OR wasn't asked (existing users)
/// 2. Template wizard not completed
/// 3. Reminder not dismissed
final shouldShowTemplateWizardReminderProvider = Provider<bool>((ref) {
  final choice = ref.watch(onboardingChoiceProvider);
  final completed = ref.watch(templateWizardCompletedProvider);
  final dismissed = ref.watch(templateWizardDismissedProvider);

  // Don't show if user chose guided (they went through wizard)
  if (choice == OnboardingChoice.guided) return false;

  // Don't show if wizard already completed
  if (completed) return false;

  // Don't show if dismissed
  if (dismissed) return false;

  return true;
});

/// Soft gate reminder in Home to push guided users toward first real workout.
final shouldShowGuidedSoftGateReminderProvider = Provider<bool>((ref) {
  final service = ref.watch(onboardingChoiceServiceProvider);
  return service?.shouldShowGuidedSoftGateReminder() ?? false;
});
