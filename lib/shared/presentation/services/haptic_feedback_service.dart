/// 🎯 Haptic Feedback Service
///
/// Centralized service for providing haptic feedback throughout the app.
/// Respects user preferences from FeedbackSettings.
///
/// Usage:
/// ```dart
/// // In a widget with WidgetRef:
/// HapticFeedbackService.setCompletion(ref);
/// ```
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/feedback_settings.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/feedback_settings_provider.dart';

/// Service for haptic feedback based on user settings
class HapticFeedbackService {

  /// Trigger haptic feedback for set completion (from widgets)
  /// Uses light impact by default
  static void setCompletion(dynamic ref) {
    // Use asData?.value to safely handle AsyncLoading state
    final asyncValue = ref.read(feedbackSettingsProvider);
    final settings = asyncValue.asData?.value;

    if (settings == null || !settings.hapticEnabled) {
      return;
    }

    // Light impact for set completion
    _triggerHaptic(HapticIntensity.light);
  }

  /// Trigger haptic feedback for exercise completion (from widgets)
  /// Uses medium impact by default
  static void exerciseCompletion(dynamic ref) {
    // Use asData?.value to safely handle AsyncLoading state
    final asyncValue = ref.read(feedbackSettingsProvider);
    final settings = asyncValue.asData?.value;

    if (settings == null || !settings.hapticEnabled) {
      return;
    }

    // Use user's preferred intensity for exercise completion
    _triggerHaptic(settings.hapticIntensity);
  }

  /// Trigger haptic feedback for workout completion (from providers)
  /// Uses heavy impact by default
  static void workoutCompletion(dynamic ref) {
    // Use valueOrNull to safely handle AsyncLoading state
    final asyncValue = ref.read(feedbackSettingsProvider);
    final settings = asyncValue.valueOrNull;

    if (settings == null || !settings.hapticEnabled) {
      return;
    }

    // Heavy impact for workout completion
    _triggerHaptic(HapticIntensity.heavy);
  }

  /// Trigger haptic with specific intensity
  static void _triggerHaptic(HapticIntensity intensity) {
    switch (intensity) {
      case HapticIntensity.light:
        HapticFeedback.lightImpact();
        break;
      case HapticIntensity.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticIntensity.heavy:
        HapticFeedback.heavyImpact();
        break;
    }
  }

  /// Trigger custom haptic feedback (for buttons, selections, etc.)
  /// This respects user settings but uses a lighter feedback
  /// Accepts both WidgetRef (from widgets) and Ref (from providers)
  static void selection(Ref ref) {
    // Use asData?.value to safely handle AsyncLoading state
    final asyncValue = ref.read(feedbackSettingsProvider);
    final settings = asyncValue.asData?.value;

    if (settings == null || !settings.hapticEnabled) {
      return;
    }

    HapticFeedback.selectionClick();
  }
}
