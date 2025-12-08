/// Utility class to extract structured data from BM25 document content
///
/// The BM25 documents contain text like:
/// - "set 1 100 kg 8 reps"
/// - "total volume 5000 kg"
/// - "personal record 120.0 kg estimated 1RM"
library;

/// Represents a parsed set from document content
class ParsedSet {
  const ParsedSet({
    required this.setNumber,
    this.weight,
    this.reps,
    this.seconds,
    this.isBodyweight = false,
  });

  final int setNumber;
  final double? weight;
  final int? reps;
  final int? seconds;
  final bool isBodyweight;

  double get volume => (weight ?? 0) * (reps ?? 0);
}

/// Extracts structured data from BM25 document content strings
class DocumentDataExtractor {
  // Regex patterns for data extraction
  static final _setWithWeightPattern = RegExp(
    r'set (\d+) ([\d.]+) kg (\d+) reps',
    caseSensitive: false,
  );

  static final _setBodyweightPattern = RegExp(
    r'set (\d+) (\d+) reps bodyweight',
    caseSensitive: false,
  );

  static final _setSecondsPattern = RegExp(
    r'set (\d+) (\d+) seconds',
    caseSensitive: false,
  );

  static final _totalVolumePattern = RegExp(
    r'total volume ([\d.]+) kg',
    caseSensitive: false,
  );

  static final _exerciseVolumePattern = RegExp(
    r'exercise volume ([\d.]+) kg',
    caseSensitive: false,
  );

  static final _personalRecordPattern = RegExp(
    r'personal record ([\d.]+) kg',
    caseSensitive: false,
  );

  static final _datePattern = RegExp(
    r'on (\w+ \d+(?:, \d+)?)',
    caseSensitive: false,
  );

  static final _exerciseNamePattern = RegExp(
    r'^(.+?) exercise',
    caseSensitive: false,
    multiLine: true,
  );

  static final _workoutDurationPattern = RegExp(
    r'workout duration (\d+) minutes',
    caseSensitive: false,
  );

  static final _totalSetsPattern = RegExp(
    r'completed (\d+) sets',
    caseSensitive: false,
  );

  /// Extract all sets from document content
  List<ParsedSet> extractSets(String content) {
    final sets = <ParsedSet>[];

    // Extract sets with weight
    for (final match in _setWithWeightPattern.allMatches(content)) {
      sets.add(ParsedSet(
        setNumber: int.parse(match.group(1)!),
        weight: double.parse(match.group(2)!),
        reps: int.parse(match.group(3)!),
      ));
    }

    // Extract bodyweight sets
    for (final match in _setBodyweightPattern.allMatches(content)) {
      sets.add(ParsedSet(
        setNumber: int.parse(match.group(1)!),
        reps: int.parse(match.group(2)!),
        isBodyweight: true,
      ));
    }

    // Extract timed sets
    for (final match in _setSecondsPattern.allMatches(content)) {
      sets.add(ParsedSet(
        setNumber: int.parse(match.group(1)!),
        seconds: int.parse(match.group(2)!),
      ));
    }

    // Sort by set number
    sets.sort((a, b) => a.setNumber.compareTo(b.setNumber));

    return sets;
  }

  /// Extract total volume from workout document
  double? extractVolume(String content) {
    final match = _totalVolumePattern.firstMatch(content);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Extract exercise-specific volume
  double? extractExerciseVolume(String content) {
    final match = _exerciseVolumePattern.firstMatch(content);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Extract personal record value
  double? extractPersonalRecord(String content) {
    final match = _personalRecordPattern.firstMatch(content);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Extract date string from content
  String? extractDateString(String content) {
    final match = _datePattern.firstMatch(content);
    return match?.group(1);
  }

  /// Extract exercise name from document ID
  /// Format: exercise_workoutId_exerciseName
  String? extractExerciseNameFromId(String docId) {
    if (!docId.startsWith('exercise_')) return null;

    final parts = docId.split('_');
    if (parts.length >= 3) {
      // Join remaining parts (exercise name might have underscores)
      return parts.sublist(2).join('_');
    }
    return null;
  }

  /// Extract exercise name from content
  String? extractExerciseNameFromContent(String content) {
    final match = _exerciseNamePattern.firstMatch(content);
    return match?.group(1)?.trim();
  }

  /// Extract workout duration in minutes
  int? extractDuration(String content) {
    final match = _workoutDurationPattern.firstMatch(content);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Extract total sets count
  int? extractTotalSets(String content) {
    final match = _totalSetsPattern.firstMatch(content);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Calculate max weight from parsed sets
  double? calculateMaxWeight(List<ParsedSet> sets) {
    if (sets.isEmpty) return null;

    final weights = sets
        .where((s) => s.weight != null)
        .map((s) => s.weight!);

    if (weights.isEmpty) return null;
    return weights.reduce((a, b) => a > b ? a : b);
  }

  /// Calculate average weight from parsed sets
  double? calculateAverageWeight(List<ParsedSet> sets) {
    if (sets.isEmpty) return null;

    final weights = sets
        .where((s) => s.weight != null)
        .map((s) => s.weight!)
        .toList();

    if (weights.isEmpty) return null;
    return weights.reduce((a, b) => a + b) / weights.length;
  }

  /// Calculate total volume from parsed sets
  double calculateTotalVolume(List<ParsedSet> sets) {
    return sets.fold(0.0, (sum, set) => sum + set.volume);
  }
}
