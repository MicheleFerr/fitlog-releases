/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/onboarding/domain/services
/// Feature: Onboarding Choice Service
/// Type: Service + Providers
///
/// Manages the post-onboarding choice (guided wizard vs explore)
/// and the template wizard reminder card state.
library;

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

  /// Reset all flags (for testing)
  Future<void> resetAll() async {
    await _prefs.remove(_Keys.onboardingChoice);
    await _prefs.remove(_Keys.templateWizardCompleted);
    await _prefs.remove(_Keys.templateWizardDismissed);
  }
}

/// Provider for SharedPreferences instance
final _sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// Provider for OnboardingChoiceService
final onboardingChoiceServiceProvider = Provider<OnboardingChoiceService?>((ref) {
  final prefsAsync = ref.watch(_sharedPrefsProvider);
  return prefsAsync.whenOrNull(
    data: (prefs) => OnboardingChoiceService(prefs),
  );
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
