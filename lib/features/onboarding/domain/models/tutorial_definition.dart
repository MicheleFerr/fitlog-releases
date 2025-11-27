import 'package:gymbro_flutter_new/features/onboarding/domain/entities/tutorial_state.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/events/tutorial_event.dart';

/// Types of tutorials.
///
/// - [behavior]: Triggered by user actions (e.g., tapping a set input)
/// - [proactive]: Shown proactively based on context (with 24h dismiss cooldown)
enum TutorialType {
  /// Behavior-triggered tutorials - shown when user performs specific action
  behavior,

  /// Proactive tutorials - shown based on context/timing
  /// Respects 24h cooldown after user dismisses
  proactive,
}

/// Condition function type for tutorial display logic.
///
/// Parameters:
/// - [state]: Current tutorial state (seen tutorials, workouts count, etc.)
/// - [event]: The event that triggered this check (may be null for proactive)
///
/// Returns true if the tutorial should be shown.
typedef TutorialCondition = bool Function(TutorialState state, TutorialEvent? event);

/// Definition of a contextual tutorial.
///
/// Each tutorial has:
/// - A unique [id] for tracking seen/dismissed state
/// - Localization keys for [titleKey] and [descriptionKey]
/// - A [type] (behavior or proactive)
/// - A [condition] function that determines when to show
///
/// Example:
/// ```dart
/// TutorialDefinition(
///   id: 'logging_set',
///   titleKey: 'tutorial_logging_set_title',
///   descriptionKey: 'tutorial_logging_set_desc',
///   type: TutorialType.behavior,
///   condition: (state, _) => !state.hasSeen('logging_set'),
/// )
/// ```
class TutorialDefinition {
  const TutorialDefinition({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.type,
    required this.condition,
    this.actionKey,
    this.secondaryActionKey,
    this.autoHideDuration = const Duration(seconds: 5),
    this.showSpotlight = true,
    this.showPulse = true,
  });

  /// Unique identifier for this tutorial.
  /// Used for tracking seen/dismissed state.
  /// Examples: 'logging_set', 'rest_timer', 'analytics_intro'
  final String id;

  /// Localization key for the tutorial title.
  /// Example: 'tutorial_logging_set_title' → "How to Log a Set"
  final String titleKey;

  /// Localization key for the tutorial description.
  /// Example: 'tutorial_logging_set_desc' → "Tap weight and reps..."
  final String descriptionKey;

  /// Optional localization key for primary action button.
  /// If null, shows only dismiss button.
  /// Example: 'tutorial_action_got_it' → "Got it!"
  final String? actionKey;

  /// Optional localization key for secondary action button.
  /// Example: 'tutorial_action_learn_more' → "Learn more"
  final String? secondaryActionKey;

  /// Type of tutorial (behavior-triggered or proactive).
  final TutorialType type;

  /// Condition function that returns true if tutorial should be shown.
  ///
  /// Receives current state and triggering event.
  /// Example: `(state, _) => !state.hasSeen('logging_set')`
  final TutorialCondition condition;

  /// Duration before auto-hiding the tutorial overlay.
  /// Default: 5 seconds (standard UX).
  /// Set to Duration.zero to disable auto-hide.
  final Duration autoHideDuration;

  /// Whether to show spotlight effect around target widget.
  /// Default: true
  final bool showSpotlight;

  /// Whether to show pulsing animation on spotlight.
  /// Default: true
  final bool showPulse;

  /// Check if this tutorial should be shown given current state and event.
  bool shouldShow(TutorialState state, TutorialEvent? event) {
    return condition(state, event);
  }

  @override
  String toString() {
    return 'TutorialDefinition(id: $id, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TutorialDefinition && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
