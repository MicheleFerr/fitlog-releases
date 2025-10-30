/// Haptic Feedback Intensity
enum HapticIntensity {
  light,
  medium,
  heavy,
}

/// Feedback Settings Entity
///
/// Manages user preferences for haptic feedback during workouts.
class FeedbackSettings {
  const FeedbackSettings({
    required this.hapticEnabled,
    required this.hapticIntensity,
  });

  /// Default settings (enabled with light intensity)
  factory FeedbackSettings.defaults() {
    return const FeedbackSettings(
      hapticEnabled: true,
      hapticIntensity: HapticIntensity.light,
    );
  }

  final bool hapticEnabled;
  final HapticIntensity hapticIntensity;

  /// Copy with modifications
  FeedbackSettings copyWith({
    bool? hapticEnabled,
    HapticIntensity? hapticIntensity,
  }) {
    return FeedbackSettings(
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      hapticIntensity: hapticIntensity ?? this.hapticIntensity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FeedbackSettings &&
        other.hapticEnabled == hapticEnabled &&
        other.hapticIntensity == hapticIntensity;
  }

  @override
  int get hashCode => hapticEnabled.hashCode ^ hapticIntensity.hashCode;

  @override
  String toString() {
    return 'FeedbackSettings(hapticEnabled: $hapticEnabled, hapticIntensity: $hapticIntensity)';
  }
}
