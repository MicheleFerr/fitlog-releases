/// Types of visual hint patterns for discoverability V2.
///
/// Each type corresponds to a specific widget pattern:
/// - [subtleText]: Inline text hint near the action area
/// - [peek]: Partial reveal animation showing hidden content
/// - [contextualChip]: Small chip/badge near the target element
/// - [softPulse]: Gentle pulsing animation on the target
/// - [microTip]: Tiny tooltip-like hint near the element
/// - [suggestionCard]: Small card with suggestion and dismiss action
enum HintType {
  subtleText,
  peek,
  contextualChip,
  softPulse,
  microTip,
  suggestionCard,
}

/// Priority levels for hint scheduling.
///
/// P0 hints are shown first and are the most critical for feature discovery.
/// The [DiscoverabilityHintService] uses priority to order the hint queue.
enum HintPriority {
  /// Critical - core interaction patterns users miss most
  p0,

  /// Important - useful secondary gestures
  p1,

  /// Nice to have - advanced features
  p2,
}

/// Types of gestures that a hint can teach the user about.
enum GestureHintType {
  swipeLeft,
  swipeRight,
  swipeHorizontal,
  longPress,
  drag,
  doubleTap,
  tap,
  pinchZoom,
}

/// Immutable configuration for a single discoverability hint.
///
/// Each hint is defined once in [HintRegistry] and referenced by [hintId].
/// The [messageKey] maps to a localization key resolved via `context.l10n`
/// in the presentation layer.
///
/// Example:
/// ```dart
/// const HintConfig(
///   hintId: 'tap_complete_set',
///   type: HintType.subtleText,
///   priority: HintPriority.p0,
///   messageKey: 'hint_tap_complete_set',
///   requiredWorkouts: 0,
///   permanent: true,
///   autoTimeout: Duration(seconds: 5),
/// )
/// ```
class HintConfig {
  const HintConfig({
    required this.hintId,
    required this.type,
    required this.priority,
    required this.messageKey,
    this.accentKey,
    this.gestureType,
    this.requiredWorkouts = 0,
    this.permanent = true,
    this.autoTimeout = const Duration(seconds: 5),
    this.maxShowCount = 1,
  });

  /// Unique identifier for this hint. Must match keys used in TutorialState.
  final String hintId;

  /// Visual pattern type for rendering.
  final HintType type;

  /// Scheduling priority (P0 > P1 > P2).
  final HintPriority priority;

  /// Localization key for the hint message.
  /// Resolved in presentation layer via `context.l10n`.
  final String messageKey;

  /// Optional localization key for an accented/highlighted portion of the message.
  final String? accentKey;

  /// Optional gesture type this hint teaches about.
  final GestureHintType? gestureType;

  /// Minimum number of completed workouts before showing this hint.
  final int requiredWorkouts;

  /// If true, uses `markTutorialSeen` (permanent dismiss).
  /// If false, uses `dismissHint` (24h cooldown).
  final bool permanent;

  /// Duration before the hint auto-dismisses.
  final Duration autoTimeout;

  /// Maximum number of times this hint can be shown.
  /// Default: 1 for permanent hints, 3 for dismissable hints.
  final int maxShowCount;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HintConfig && other.hintId == hintId;
  }

  @override
  int get hashCode => hintId.hashCode;

  @override
  String toString() =>
      'HintConfig(id: $hintId, type: $type, priority: $priority)';
}
