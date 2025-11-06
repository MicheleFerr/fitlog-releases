/// Suggestion level in the 4-level fallback hierarchy
///
/// The prediction engine uses a fallback hierarchy to provide workout suggestions:
/// 1. **Pattern**: Detected repeating pattern (highest confidence)
/// 2. **Routine**: Active routine template (medium confidence)
/// 3. **Frequency**: Most frequent workout (lower confidence)
/// 4. **DayBased**: Default by day of week (lowest confidence, always available)
enum SuggestionLevel {
  /// Level 1: Pattern-based suggestion (franco→ciccio→paolo)
  ///
  /// Detected repeating pattern in workout history.
  /// Requires: ≥6 workouts, ≥18 days, ≥3 cycles, confidence ≥0.70
  ///
  /// Example: "You've been doing Push→Pull→Legs. Next: Pull"
  pattern,

  /// Level 2: Routine-based suggestion (active routine template)
  ///
  /// Uses the active routine's template rotation.
  /// Requires: Active routine with defined schedule
  ///
  /// Example: "Your routine says: Upper Body today"
  routine,

  /// Level 3: Frequency-based suggestion (most frequent workout)
  ///
  /// Suggests the workout you do most often.
  /// Requires: ≥3 workouts in last 30 days
  ///
  /// Example: "You do Push most often (5 times last month)"
  frequency,

  /// Level 4: Day-based suggestion (default fallback)
  ///
  /// Default workout based on day of week.
  /// Always available as last resort.
  ///
  /// Example: "It's Monday - you usually do Franco"
  dayBased;

  /// Display name for UI (localization key)
  String get displayNameKey {
    switch (this) {
      case SuggestionLevel.pattern:
        return 'suggestionLevelPattern';
      case SuggestionLevel.routine:
        return 'suggestionLevelRoutine';
      case SuggestionLevel.frequency:
        return 'suggestionLevelFrequency';
      case SuggestionLevel.dayBased:
        return 'suggestionLevelDayBased';
    }
  }

  /// Confidence tier (for UI badge color)
  ///
  /// Returns: 'high', 'medium', 'low'
  String get confidenceTier {
    switch (this) {
      case SuggestionLevel.pattern:
        return 'high'; // Green badge
      case SuggestionLevel.routine:
        return 'medium'; // Blue badge
      case SuggestionLevel.frequency:
        return 'medium'; // Blue badge
      case SuggestionLevel.dayBased:
        return 'low'; // Gray badge
    }
  }

  /// Priority order (lower = higher priority)
  int get priority {
    switch (this) {
      case SuggestionLevel.pattern:
        return 1;
      case SuggestionLevel.routine:
        return 2;
      case SuggestionLevel.frequency:
        return 3;
      case SuggestionLevel.dayBased:
        return 4;
    }
  }

  /// Icon name for UI
  String get iconName {
    switch (this) {
      case SuggestionLevel.pattern:
        return 'pattern'; // Repeating pattern icon
      case SuggestionLevel.routine:
        return 'calendar'; // Calendar/schedule icon
      case SuggestionLevel.frequency:
        return 'trending_up'; // Trending/frequency icon
      case SuggestionLevel.dayBased:
        return 'today'; // Today/day icon
    }
  }
}
