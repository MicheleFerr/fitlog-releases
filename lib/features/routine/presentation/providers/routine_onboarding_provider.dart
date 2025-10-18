/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/providers
/// 🎯 Feature: flexible_routine
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// ROUTINE ONBOARDING PROVIDER - Tracks if user has seen onboarding
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Key for storing onboarding completion status
const String _kRoutineOnboardingKey = 'routine_onboarding_completed';

/// Provider for onboarding completion status
final routineOnboardingProvider =
    StateNotifierProvider<RoutineOnboardingNotifier, bool>((ref) {
  return RoutineOnboardingNotifier();
});

/// Notifier for routine onboarding state
class RoutineOnboardingNotifier extends StateNotifier<bool> {
  RoutineOnboardingNotifier() : super(false) {
    _loadOnboardingStatus();
  }

  /// Load onboarding status from SharedPreferences
  Future<void> _loadOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_kRoutineOnboardingKey) ?? false;
      state = completed;
    } catch (e) {
      // If error loading, assume not completed (safe default)
      state = false;
    }
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kRoutineOnboardingKey, true);
      state = true;
    } catch (e) {
      // Error saving - log but don't block user
      if (kDebugMode) {
        debugPrint('⚠️ Error saving onboarding status: $e');
      }
      state = true; // Still mark as completed in memory
    }
  }

  /// Reset onboarding (for testing or re-showing)
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kRoutineOnboardingKey, false);
      state = false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error resetting onboarding status: $e');
      }
    }
  }
}
