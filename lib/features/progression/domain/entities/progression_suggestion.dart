import 'package:freezed_annotation/freezed_annotation.dart';

part 'progression_suggestion.freezed.dart';

/// Confidence level for progression suggestions
///
/// Based on data quality and pattern detection:
/// - high: 3+ weeks of consistent data with clear pattern
/// - medium: 1-2 weeks of data or mixed patterns
/// - low: Insufficient data or inconsistent patterns
enum ProgressionConfidence { low, medium, high }

/// Deterministic progressive overload suggestion
///
/// Uses transparent rules (no AI) to analyze workout history
/// and suggest next step for progression
@freezed
abstract class ProgressionSuggestion with _$ProgressionSuggestion {
  const factory ProgressionSuggestion({
    required String exerciseName,
    required double currentWeight,
    required double suggestedWeight,
    required int targetReps,
    required String reason,
    required ProgressionConfidence confidence,
    String? additionalNotes,
  }) = _ProgressionSuggestion;
}
