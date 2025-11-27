import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_tour_step.freezed.dart';

/// Represents a single step in the onboarding tour
///
/// Each step highlights a specific widget and shows an explanation in a bottom sheet.
/// Steps can be SIMPLE (auto-advance after duration) or COMPLEX (user-controlled with buttons).
@freezed
abstract class OnboardingTourStep with _$OnboardingTourStep {
  const factory OnboardingTourStep({
    /// Unique identifier for this step (e.g., 'aiCoach', 'fab', 'analytics')
    required String id,

    /// Localization key for the title (used in bottom sheet header)
    required String titleKey,

    /// Localization key for the description text
    required String descriptionKey,

    /// Optional localization keys for bullet points (used for COMPLEX steps)
    @Default([]) List<String> bulletPointKeys,

    /// Step complexity type
    @Default(TourStepType.simple) TourStepType type,

    /// Auto-advance duration (null = user-controlled, only for COMPLEX steps)
    Duration? autoAdvanceDuration,

    /// GlobalKey for the widget to spotlight
    /// This key should be attached to the target widget in the UI
    required String targetWidgetKey,

    /// Step position in the tour (0-indexed)
    required int position,

    /// Total number of steps in the tour
    required int totalSteps,

    /// Bottom sheet position (bottom or top) - default is bottom
    /// Use top for FAB to avoid obscuring it
    @Default(BottomSheetPosition.bottom) BottomSheetPosition bottomSheetPosition,
  }) = _OnboardingTourStep;

  const OnboardingTourStep._();

  /// Whether this step is simple (auto-advance)
  bool get isSimple => type == TourStepType.simple;

  /// Whether this step is complex (user-controlled)
  bool get isComplex => type == TourStepType.complex;

  /// Whether this step has bullet points
  bool get hasBulletPoints => bulletPointKeys.isNotEmpty;

  /// Progress percentage (0.0 to 1.0)
  double get progress => (position + 1) / totalSteps;

  /// Whether this is the first step
  bool get isFirst => position == 0;

  /// Whether this is the last step
  bool get isLast => position == totalSteps - 1;
}

/// Type of tour step (affects pacing and UI)
enum TourStepType {
  /// Simple step: auto-advance after duration, casual tone, 2-3 sentences
  simple,

  /// Complex step: user-controlled, detailed tone with bullet points, 4-5 lines
  complex,
}

/// Position of the bottom sheet (for avoiding obscuring target widgets)
enum BottomSheetPosition {
  /// Bottom of screen (default) - standard positioning
  bottom,

  /// Top of screen - used for FAB to avoid obscuring it
  top,
}
