import 'package:gymbro_flutter_new/features/workout/domain/entities/pattern_detection_result.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Service for detecting repeating patterns in workout history
///
/// Uses sliding window algorithm to find repeated sequences of workouts.
/// Works with arbitrary workout names (franco→ciccio→paolo, Push→Pull→Legs, etc.)
///
/// Algorithm:
/// 1. Extract workout name sequence from history
/// 2. Slide window of size 2-7 to find repeating patterns
/// 3. Score patterns by: repetitions * 10 + length
/// 4. Calculate confidence based on coverage, repetitions, length
///
/// Example:
/// ```dart
/// final service = PatternDetectionService();
/// final result = await service.detectPattern(
///   recentWorkouts: workouts,
///   minPatternLength: 2,
///   maxPatternLength: 7,
///   minRepetitions: 2,
/// );
/// if (result != null && result.isHighConfidence) {
///   print('Next workout: ${result.predictNext()}');
/// }
/// ```
class PatternDetectionService {
  /// Detect repeating pattern in workout history
  ///
  /// [recentWorkouts]: Last 30-50 workouts (newest first)
  /// [minPatternLength]: Minimum pattern length (default: 2)
  /// [maxPatternLength]: Maximum pattern length (default: 7)
  /// [minRepetitions]: Minimum cycles for valid pattern (default: 2)
  ///
  /// Returns: [PatternDetectionResult] if pattern found, null otherwise
  Future<PatternDetectionResult?> detectPattern({
    required List<Workout> recentWorkouts,
    int minPatternLength = 2,
    int maxPatternLength = 7,
    int minRepetitions = 2,
  }) async {
    // STEP 1: Extract workout name sequence (normalized)
    // Reverse to get chronological order (oldest → newest)
    final sequence = recentWorkouts.reversed
        .map((w) => _normalizeWorkoutName(w.name ?? 'Unknown'))
        .toList();

    // Check minimum data requirement (need at least minPatternLength * minRepetitions workouts)
    if (sequence.isEmpty || sequence.length < minPatternLength * minRepetitions) {
      return null; // Insufficient data
    }

    // STEP 2: Find all candidate patterns for each length
    final candidates = <List<String>, int>{};

    // Only search for pattern lengths that make sense given the data
    final effectiveMaxLength = maxPatternLength < sequence.length
        ? maxPatternLength
        : sequence.length;

    for (int len = minPatternLength; len <= effectiveMaxLength; len++) {
      final patterns = _findPatternsOfLength(sequence, len);

      for (final entry in patterns.entries) {
        if (entry.value >= minRepetitions) {
          candidates[entry.key] = entry.value;
        }
      }
    }

    if (candidates.isEmpty) return null;

    // STEP 3: Choose best pattern (highest score: repetitions * 10 + length)
    final bestEntry = candidates.entries.reduce((a, b) {
      // Scoring: prioritize repetitions, then length
      final scoreA = a.value * 10 + a.key.length;
      final scoreB = b.value * 10 + b.key.length;
      return scoreA >= scoreB ? a : b;
    });

    // STEP 4: Calculate confidence score
    final confidence = _calculateConfidence(
      repetitions: bestEntry.value,
      patternLength: bestEntry.key.length,
      totalWorkouts: sequence.length,
    );

    // STEP 5: Determine last position in pattern
    final lastWorkout = sequence.last;
    final lastPosition = bestEntry.key.indexOf(lastWorkout);

    return PatternDetectionResult(
      pattern: bestEntry.key,
      repetitions: bestEntry.value,
      confidence: confidence,
      lastPosition: lastPosition >= 0 ? lastPosition : 0,
    );
  }

  /// Normalize workout name for matching
  ///
  /// - Lowercase
  /// - Trim whitespace
  /// - Collapse multiple spaces
  ///
  /// Example: "  FRANCO v2  " → "franco v2"
  String _normalizeWorkoutName(String name) {
    return name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Find patterns of specific length using sliding window
  ///
  /// Returns: Map of pattern → count
  Map<List<String>, int> _findPatternsOfLength(
    List<String> sequence,
    int length,
  ) {
    final patternCounts = <String, int>{};

    // Sliding window through sequence
    for (int i = 0; i <= sequence.length - length; i++) {
      final window = sequence.sublist(i, i + length);
      final key = window.join('→'); // "franco→ciccio→paolo"
      patternCounts[key] = (patternCounts[key] ?? 0) + 1;
    }

    // Convert to Map<List<String>, int> and filter by min count
    final result = <List<String>, int>{};
    for (final entry in patternCounts.entries) {
      if (entry.value >= 2) {
        // Only patterns that repeat at least twice
        result[entry.key.split('→')] = entry.value;
      }
    }

    return result;
  }

  /// Calculate confidence score
  ///
  /// Factors:
  /// - Base confidence: 0.5 + (repetitions * 0.1)
  /// - Coverage bonus: (pattern_workouts / total_workouts) * 0.2
  /// - Length bonus: (length - 2) * 0.02
  ///
  /// Capped at 0.95 (never 100%)
  double _calculateConfidence({
    required int repetitions,
    required int patternLength,
    required int totalWorkouts,
  }) {
    // Base confidence from repetitions
    // 2 reps = 0.70, 3 reps = 0.80, 4 reps = 0.90
    double baseConfidence = 0.5 + (repetitions * 0.1);

    // Bonus if pattern covers high % of total workouts
    final coverage = (repetitions * patternLength) / totalWorkouts;
    final coverageBonus = coverage * 0.2; // Max +20%

    // Bonus for longer patterns (more specific)
    final lengthBonus = (patternLength - 2) * 0.02; // +2% per extra step

    final total = baseConfidence + coverageBonus + lengthBonus;

    // Cap at 0.95 (never 100% confidence)
    return total > 0.95 ? 0.95 : total;
  }
}
