import 'package:freezed_annotation/freezed_annotation.dart';

part 'pattern_detection_result.freezed.dart';
part 'pattern_detection_result.g.dart';

/// Result of pattern detection analysis on workout history
///
/// Represents a detected repeating pattern in user's workout sequence.
/// Example: ["Push", "Pull", "Legs"] detected with 4 repetitions
@freezed
abstract class PatternDetectionResult with _$PatternDetectionResult {
  const factory PatternDetectionResult({
    /// The detected pattern sequence (e.g., ["Franco", "Ciccio", "Paolo"])
    required List<String> pattern,

    /// Number of times the pattern repeats in workout history
    /// Must be >= 2 for valid pattern
    required int repetitions,

    /// Confidence score (0.0 - 1.0)
    /// Based on: repetitions, coverage, pattern length
    /// Typical range: 0.60-0.90
    required double confidence,

    /// Position of last completed workout in pattern (0-indexed)
    /// Used to predict next workout
    /// Example: lastPosition=1 means user just did pattern[1]
    required int lastPosition,
  }) = _PatternDetectionResult;

  factory PatternDetectionResult.fromJson(Map<String, dynamic> json) =>
      _$PatternDetectionResultFromJson(json);

  const PatternDetectionResult._();

  /// Predict next workout in the pattern
  ///
  /// Circular logic: (lastPosition + 1) % pattern.length
  /// Example: pattern=["A","B","C"], lastPosition=2 → next="A" (wraps around)
  String predictNext() {
    final nextIndex = (lastPosition + 1) % pattern.length;
    return pattern[nextIndex];
  }

  /// Display pattern for UI (arrow-separated)
  ///
  /// Example: "Franco → Ciccio → Paolo"
  String get displayPattern => pattern.join(' → ');

  /// Visual pattern with dots indicating current position
  ///
  /// Example: "●━━○━━○" (current at position 0)
  String get visualPattern {
    return pattern
        .asMap()
        .entries
        .map((e) => e.key == lastPosition ? '●' : '○')
        .join('━━');
  }

  /// Check if confidence is high enough for pattern-based suggestions
  ///
  /// Threshold: 0.70 (updated from consultant feedback)
  bool get isHighConfidence => confidence >= 0.70;

  /// Check if confidence is excellent (for UI celebrations)
  ///
  /// Threshold: 0.80 (updated from consultant feedback)
  bool get isExcellentConfidence => confidence >= 0.80;

  /// Pattern length (number of unique workouts)
  int get patternLength => pattern.length;

  /// Estimated days per cycle
  ///
  /// Assumes 2-3 rest days between workouts on average
  int get estimatedDaysPerCycle => pattern.length * 3;

  /// Display confidence as percentage
  ///
  /// Example: 0.85 → "85%"
  String get displayConfidence => '${(confidence * 100).toInt()}%';

  /// Get color for confidence level
  ///
  /// - Green (>=0.80): Excellent
  /// - Blue (>=0.75): Good
  /// - Orange (>=0.70): Fair
  /// - Grey (<0.70): Low
  String get confidenceColorHex {
    if (confidence >= 0.80) return '#4CAF50'; // Green
    if (confidence >= 0.75) return '#2196F3'; // Blue
    if (confidence >= 0.70) return '#FF9800'; // Orange
    return '#9E9E9E'; // Grey
  }
}
