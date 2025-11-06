import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/suggestion_level.dart';

part 'workout_suggestion.freezed.dart';
part 'workout_suggestion.g.dart';

/// Workout suggestion from the prediction engine
///
/// Contains the predicted next workout with confidence level and reasoning.
/// Used by the 4-level fallback hierarchy to suggest workouts to the user.
///
/// Example:
/// ```dart
/// final suggestion = WorkoutSuggestion(
///   level: SuggestionLevel.pattern,
///   workoutName: 'Pull',
///   confidence: 0.85,
///   reason: 'Detected pattern: Push → Pull → Legs (85% confidence)',
///   patternInfo: 'You completed Push yesterday',
/// );
/// ```
@freezed
class WorkoutSuggestion with _$WorkoutSuggestion {
  const factory WorkoutSuggestion({
    /// Suggestion level (pattern/routine/frequency/dayBased)
    required SuggestionLevel level,

    /// Predicted workout name
    ///
    /// Examples: "Push", "Pull", "Legs", "franco", "ciccio", "paolo"
    required String workoutName,

    /// Confidence score (0.0 - 1.0)
    ///
    /// - Pattern: 0.70 - 0.95 (viability checked)
    /// - Routine: 0.80 - 0.90 (active routine exists)
    /// - Frequency: 0.50 - 0.70 (based on frequency)
    /// - DayBased: 0.30 - 0.50 (fallback default)
    required double confidence,

    /// Human-readable reason for this suggestion
    ///
    /// Examples:
    /// - "Detected pattern: Push → Pull → Legs (85% confidence)"
    /// - "Your routine schedule says: Upper Body"
    /// - "You do Push most often (5 times last month)"
    /// - "It's Monday - you usually do Franco"
    required String reason,

    /// Optional pattern information (only for pattern-based suggestions)
    ///
    /// Example: "You completed Push yesterday"
    String? patternInfo,

    /// Optional template ID (only for routine-based suggestions)
    String? routineTemplateId,

    /// Optional frequency data (only for frequency-based suggestions)
    ///
    /// Example: "5 times in last 30 days"
    String? frequencyData,

    /// Optional scheduled date for routine-based suggestions
    ///
    /// When provided, indicates the date when this workout is scheduled
    /// in the active routine. Used to display "This is the workout you should
    /// do on dd/mm/yyyy" in the UI.
    ///
    /// Example: DateTime(2025, 11, 8) → "08/11/2025"
    DateTime? scheduledDate,

    /// Timestamp when this suggestion was generated
    @Default(null) DateTime? generatedAt,

    /// ✅ NEW: Is this a recovery suggestion for a missed workout?
    @Default(false) bool isRecovery,

    /// ✅ NEW: Date of the missed workout being recovered
    DateTime? recoveryDate,
  }) = _WorkoutSuggestion;

  const WorkoutSuggestion._();

  factory WorkoutSuggestion.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSuggestionFromJson(json);

  /// Check if suggestion is high confidence (≥0.70)
  bool get isHighConfidence => confidence >= 0.70;

  /// Check if suggestion is pattern-based
  bool get isPatternBased => level == SuggestionLevel.pattern;

  /// Check if suggestion is routine-based
  bool get isRoutineBased => level == SuggestionLevel.routine;

  /// Check if suggestion is frequency-based
  bool get isFrequencyBased => level == SuggestionLevel.frequency;

  /// Check if suggestion is day-based (fallback)
  bool get isDayBased => level == SuggestionLevel.dayBased;

  /// Display confidence as percentage (e.g., "85%")
  String get displayConfidence => '${(confidence * 100).round()}%';

  /// Get confidence descriptor for UI
  ///
  /// Returns: "High" (≥70%), "Medium" (≥50%), "Low" (<50%)
  String get confidenceDescriptor {
    if (confidence >= 0.70) return 'High';
    if (confidence >= 0.50) return 'Medium';
    return 'Low';
  }

  /// Get badge color based on confidence
  ///
  /// Returns: 'success' (≥70%), 'warning' (≥50%), 'error' (<50%)
  String get badgeColor {
    if (confidence >= 0.70) return 'success'; // Green
    if (confidence >= 0.50) return 'warning'; // Orange
    return 'error'; // Red
  }

  /// Get extended reason with pattern/frequency info if available
  String get extendedReason {
    final base = reason;
    if (patternInfo != null) {
      return '$base\n$patternInfo';
    }
    if (frequencyData != null) {
      return '$base\n$frequencyData';
    }
    return base;
  }

  /// Check if suggestion is stale (>5 minutes old)
  bool get isStale {
    if (generatedAt == null) return false;
    final age = DateTime.now().difference(generatedAt!);
    return age.inMinutes > 5;
  }

  /// Copy with updated timestamp
  WorkoutSuggestion withUpdatedTimestamp() {
    return copyWith(generatedAt: DateTime.now());
  }
}
