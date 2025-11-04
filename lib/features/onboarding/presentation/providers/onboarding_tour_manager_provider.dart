import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/onboarding_tour_manager.dart';

/// Provider family for creating OnboardingTourManager instances
///
/// This provider creates a manager for a specific set of target widget keys.
/// The manager handles state, auto-scrolling, and positioning calculations.
///
/// Usage:
/// ```dart
/// final manager = ref.watch(onboardingTourManagerProvider(targetKeys));
/// ```
final onboardingTourManagerProvider = Provider.family<OnboardingTourManager, Map<String, GlobalKey>>(
  (ref, targetKeys) {
    final manager = OnboardingTourManager(targetKeys);

    // Cleanup when provider is disposed
    ref.onDispose(() {
      manager.dispose();
    });

    return manager;
  },
);

/// Provider for accessing the current tour manager
///
/// This is a state provider that holds the active manager instance.
/// Useful when you need to access the same manager from multiple widgets.
final activeTourManagerProvider = StateProvider<OnboardingTourManager?>((ref) => null);
