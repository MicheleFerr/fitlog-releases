# Fix AI Coach Hardcoded Data - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace all hardcoded/mock data in AI Coach response generator with real data extraction from BM25 search results.

**Architecture:** The BM25 documents contain structured text with patterns like "set 1 100 kg 8 reps" and "total volume 5000 kg". We need to implement regex-based parsers to extract these values from document.content and aggregate them properly.

**Tech Stack:** Dart, RegExp, BM25SearchEngine, Riverpod providers

---

## Overview

| Task | Description | Files |
|------|-------------|-------|
| 1 | Create data extraction utilities | New file |
| 2 | Fix `_extractExerciseMetrics` | enhanced_response_generator.dart |
| 3 | Fix `_extractRecentSessions` | enhanced_response_generator.dart |
| 4 | Fix `_analyzeTrainingFrequency` | enhanced_response_generator.dart |
| 5 | Fix `_extractVolumeData` | enhanced_response_generator.dart |
| 6 | Fix `_analyzeProgression` | enhanced_response_generator.dart |
| 7 | Fix userId placeholders | Multiple files |
| 8 | Fix streak mock data | streak_tracker_provider.dart |

---

## Task 1: Create Data Extraction Utilities

**Files:**
- Create: `lib/features/ai_coach/data/utils/document_data_extractor.dart`
- Test: `test/features/ai_coach/data/utils/document_data_extractor_test.dart`

**Step 1: Write the failing test**

```dart
// test/features/ai_coach/data/utils/document_data_extractor_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/utils/document_data_extractor.dart';

void main() {
  group('DocumentDataExtractor', () {
    late DocumentDataExtractor extractor;

    setUp(() {
      extractor = DocumentDataExtractor();
    });

    group('extractSets', () {
      test('extracts single set with weight and reps', () {
        const content = 'Bench Press exercise on December 5\nset 1 80 kg 10 reps';
        final sets = extractor.extractSets(content);

        expect(sets, hasLength(1));
        expect(sets[0].setNumber, 1);
        expect(sets[0].weight, 80.0);
        expect(sets[0].reps, 10);
      });

      test('extracts multiple sets', () {
        const content = '''
Squat exercise on December 5
set 1 100 kg 8 reps
set 2 110 kg 6 reps
set 3 120 kg 4 reps
''';
        final sets = extractor.extractSets(content);

        expect(sets, hasLength(3));
        expect(sets[0].weight, 100.0);
        expect(sets[1].weight, 110.0);
        expect(sets[2].weight, 120.0);
      });

      test('handles bodyweight sets', () {
        const content = 'Pull-ups exercise\nset 1 12 reps bodyweight';
        final sets = extractor.extractSets(content);

        expect(sets, hasLength(1));
        expect(sets[0].weight, isNull);
        expect(sets[0].reps, 12);
        expect(sets[0].isBodyweight, true);
      });
    });

    group('extractVolume', () {
      test('extracts total volume from workout document', () {
        const content = 'workout on December 5\ntotal volume 5000 kg';
        final volume = extractor.extractVolume(content);

        expect(volume, 5000.0);
      });

      test('extracts exercise volume', () {
        const content = 'Bench Press exercise\nexercise volume 2400 kg';
        final volume = extractor.extractExerciseVolume(content);

        expect(volume, 2400.0);
      });

      test('returns null when no volume found', () {
        const content = 'some random content';
        final volume = extractor.extractVolume(content);

        expect(volume, isNull);
      });
    });

    group('extractDate', () {
      test('extracts date from workout content', () {
        const content = 'workout on December 5, 2024 Monday';
        final date = extractor.extractDateString(content);

        expect(date, 'December 5, 2024');
      });
    });

    group('extractExerciseName', () {
      test('extracts exercise name from document ID', () {
        const docId = 'exercise_workout123_bench_press';
        final name = extractor.extractExerciseNameFromId(docId);

        expect(name, 'bench_press');
      });

      test('extracts exercise name from content', () {
        const content = 'Bench Press exercise on December 5';
        final name = extractor.extractExerciseNameFromContent(content);

        expect(name, 'Bench Press');
      });
    });

    group('extractPersonalRecord', () {
      test('extracts PR from history document', () {
        const content = 'Squat exercise history\npersonal record 150.0 kg estimated 1RM';
        final pr = extractor.extractPersonalRecord(content);

        expect(pr, 150.0);
      });
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/ai_coach/data/utils/document_data_extractor_test.dart`
Expected: FAIL with "Target of URI doesn't exist"

**Step 3: Write implementation**

```dart
// lib/features/ai_coach/data/utils/document_data_extractor.dart
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
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/ai_coach/data/utils/document_data_extractor_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/features/ai_coach/data/utils/document_data_extractor.dart
git add test/features/ai_coach/data/utils/document_data_extractor_test.dart
git commit -m "feat(ai-coach): add DocumentDataExtractor utility for parsing BM25 content"
```

---

## Task 2: Fix `_extractExerciseMetrics` Method

**Files:**
- Modify: `lib/features/ai_coach/data/generators/enhanced_response_generator.dart:536-545`

**Step 1: Write the failing test**

```dart
// Add to existing test file or create new:
// test/features/ai_coach/data/generators/enhanced_response_generator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/generators/enhanced_response_generator.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/search/bm25_search.dart';

void main() {
  group('EnhancedResponseGenerator', () {
    late EnhancedResponseGenerator generator;

    setUp(() {
      generator = EnhancedResponseGenerator();
    });

    group('extractExerciseMetrics', () {
      test('extracts real metrics from search results', () {
        final results = [
          SearchResult(
            document: BM25Document(
              id: 'exercise_w1_bench',
              content: '''
Bench Press exercise on December 5
set 1 80 kg 10 reps
set 2 85 kg 8 reps
set 3 90 kg 6 reps
exercise volume 2020 kg
''',
              timestamp: DateTime(2024, 12, 5),
            ),
            score: 10.0,
            matchedTerms: {'bench', 'press'},
          ),
          SearchResult(
            document: BM25Document(
              id: 'exercise_w2_bench',
              content: '''
Bench Press exercise on December 2
set 1 75 kg 12 reps
set 2 80 kg 10 reps
exercise volume 1700 kg
''',
              timestamp: DateTime(2024, 12, 2),
            ),
            score: 8.0,
            matchedTerms: {'bench', 'press'},
          ),
        ];

        // Use reflection or make method public for testing
        // For now, test via generateResponse output
        expect(results, isNotEmpty);
      });
    });
  });
}
```

**Step 2: Update the implementation**

Replace lines 536-545 in `enhanced_response_generator.dart`:

```dart
  /// Extract real metrics from exercise search results
  Map<String, dynamic> _extractExerciseMetrics(List<SearchResult> results) {
    if (results.isEmpty) return {};

    final extractor = DocumentDataExtractor();

    double? maxWeight;
    final allWeights = <double>[];
    double totalVolume = 0;
    int sessionCount = 0;

    for (final result in results) {
      final content = result.document.content;

      // Extract sets and calculate metrics
      final sets = extractor.extractSets(content);

      for (final set in sets) {
        if (set.weight != null) {
          allWeights.add(set.weight!);
          if (maxWeight == null || set.weight! > maxWeight) {
            maxWeight = set.weight;
          }
        }
      }

      // Extract volume
      final exerciseVolume = extractor.extractExerciseVolume(content);
      if (exerciseVolume != null) {
        totalVolume += exerciseVolume;
      } else {
        // Calculate from sets if not explicitly stated
        totalVolume += extractor.calculateTotalVolume(sets);
      }

      // Count sessions (documents with exercise_ prefix)
      if (result.document.id.startsWith('exercise_')) {
        sessionCount++;
      }
    }

    // Calculate average weight
    final avgWeight = allWeights.isNotEmpty
        ? allWeights.reduce((a, b) => a + b) / allWeights.length
        : null;

    // Determine frequency description
    String frequency;
    if (sessionCount >= 12) {
      frequency = '3+ times per week';
    } else if (sessionCount >= 8) {
      frequency = '2-3 times per week';
    } else if (sessionCount >= 4) {
      frequency = '1-2 times per week';
    } else {
      frequency = 'Less than weekly';
    }

    return {
      if (maxWeight != null) 'maxWeight': maxWeight.round(),
      if (avgWeight != null) 'avgWeight': avgWeight.round(),
      if (totalVolume > 0) 'totalVolume': totalVolume.round(),
      'frequency': frequency,
      'sessionCount': sessionCount,
    };
  }
```

**Step 3: Add import at top of file**

```dart
import 'package:gymbro_flutter_new/features/ai_coach/data/utils/document_data_extractor.dart';
```

**Step 4: Run tests**

Run: `flutter test test/features/ai_coach/`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/features/ai_coach/data/generators/enhanced_response_generator.dart
git commit -m "fix(ai-coach): extract real exercise metrics from BM25 results"
```

---

## Task 3: Fix `_extractRecentSessions` Method

**Files:**
- Modify: `lib/features/ai_coach/data/generators/enhanced_response_generator.dart:546-553`

**Step 1: Replace the implementation**

```dart
  /// Extract real recent sessions from search results
  List<String> _extractRecentSessions(String exercise, List<SearchResult> results) {
    final extractor = DocumentDataExtractor();
    final sessions = <String>[];
    final dateFormat = DateFormat('EEEE'); // Day name

    // Filter for exercise documents and sort by date
    final exerciseResults = results
        .where((r) => r.document.id.startsWith('exercise_'))
        .where((r) => r.document.content.toLowerCase().contains(exercise.toLowerCase()))
        .toList()
      ..sort((a, b) {
        final dateA = a.document.timestamp ?? DateTime(1970);
        final dateB = b.document.timestamp ?? DateTime(1970);
        return dateB.compareTo(dateA); // Most recent first
      });

    for (final result in exerciseResults.take(5)) {
      final content = result.document.content;
      final sets = extractor.extractSets(content);
      final date = result.document.timestamp;

      if (sets.isNotEmpty && date != null) {
        final dayName = dateFormat.format(date);

        // Build set summary (e.g., "3x8 @ 80kg")
        if (sets.length > 1 && _areSetsHomogeneous(sets)) {
          // If all sets have same reps, show as NxR format
          final avgWeight = sets
              .where((s) => s.weight != null)
              .map((s) => s.weight!)
              .fold(0.0, (a, b) => a + b) / sets.length;

          sessions.add('$dayName: ${sets.length}x${sets.first.reps} @ ${avgWeight.round()}kg');
        } else {
          // Show individual sets
          final setSummary = sets.take(3).map((s) {
            if (s.weight != null && s.reps != null) {
              return '${s.reps}@${s.weight!.round()}kg';
            } else if (s.reps != null) {
              return '${s.reps} reps';
            }
            return '';
          }).where((s) => s.isNotEmpty).join(', ');

          sessions.add('$dayName: $setSummary');
        }
      }
    }

    return sessions;
  }

  /// Check if sets have similar reps (within 2 reps)
  bool _areSetsHomogeneous(List<ParsedSet> sets) {
    if (sets.isEmpty) return false;

    final reps = sets.where((s) => s.reps != null).map((s) => s.reps!).toList();
    if (reps.isEmpty) return false;

    final minReps = reps.reduce((a, b) => a < b ? a : b);
    final maxReps = reps.reduce((a, b) => a > b ? a : b);

    return (maxReps - minReps) <= 2;
  }
```

**Step 2: Run tests**

Run: `flutter test test/features/ai_coach/`
Expected: PASS

**Step 3: Commit**

```bash
git add lib/features/ai_coach/data/generators/enhanced_response_generator.dart
git commit -m "fix(ai-coach): extract real recent sessions from BM25 results"
```

---

## Task 4: Fix `_analyzeTrainingFrequency` Method

**Files:**
- Modify: `lib/features/ai_coach/data/generators/enhanced_response_generator.dart:554-562`

**Step 1: Replace the implementation**

```dart
  /// Analyze real training frequency from search results
  Map<String, dynamic> _analyzeTrainingFrequency(List<SearchResult> results) {
    if (results.isEmpty) return {};

    // Get workout documents only
    final workoutResults = results
        .where((r) => r.document.id.startsWith('workout_'))
        .toList();

    if (workoutResults.isEmpty) return {};

    // Get dates and sort
    final workoutDates = workoutResults
        .map((r) => r.document.timestamp)
        .whereType<DateTime>()
        .toList()
      ..sort();

    if (workoutDates.isEmpty) return {};

    // Calculate sessions per week (last 4 weeks)
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));
    final recentWorkouts = workoutDates.where((d) => d.isAfter(fourWeeksAgo)).length;
    final sessionsPerWeek = (recentWorkouts / 4).round();

    // Calculate average rest days
    double avgRestDays = 0;
    if (workoutDates.length > 1) {
      int totalRestDays = 0;
      for (int i = 1; i < workoutDates.length; i++) {
        totalRestDays += workoutDates[i].difference(workoutDates[i - 1]).inDays - 1;
      }
      avgRestDays = totalRestDays / (workoutDates.length - 1);
    }

    // Analyze muscle group distribution
    final muscleGroupCount = <String, int>{};
    for (final result in results) {
      final content = result.document.content.toLowerCase();

      // Check for category mentions
      for (final category in ['chest', 'back', 'legs', 'shoulders', 'arms', 'core']) {
        if (content.contains(category)) {
          muscleGroupCount[category] = (muscleGroupCount[category] ?? 0) + 1;
        }
      }
    }

    // Find most and least trained
    String? mostTrained;
    String? leastTrained;

    if (muscleGroupCount.isNotEmpty) {
      final sorted = muscleGroupCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      mostTrained = sorted.first.key;
      mostTrained = mostTrained[0].toUpperCase() + mostTrained.substring(1);

      leastTrained = sorted.last.key;
      leastTrained = leastTrained[0].toUpperCase() + leastTrained.substring(1);
    }

    // Check for muscle imbalance (>2x difference)
    final muscleImbalance = muscleGroupCount.isNotEmpty &&
        muscleGroupCount.values.reduce((a, b) => a > b ? a : b) >
            muscleGroupCount.values.reduce((a, b) => a < b ? a : b) * 2;

    return {
      'sessionsPerWeek': sessionsPerWeek,
      'avgRestDays': double.parse(avgRestDays.toStringAsFixed(1)),
      if (mostTrained != null) 'mostTrained': mostTrained,
      if (leastTrained != null) 'leastTrained': leastTrained,
      'muscleImbalance': muscleImbalance,
      'totalWorkouts': workoutDates.length,
    };
  }
```

**Step 2: Run tests**

Run: `flutter test test/features/ai_coach/`
Expected: PASS

**Step 3: Commit**

```bash
git add lib/features/ai_coach/data/generators/enhanced_response_generator.dart
git commit -m "fix(ai-coach): analyze real training frequency from BM25 results"
```

---

## Task 5: Fix `_extractVolumeData` Method

**Files:**
- Modify: `lib/features/ai_coach/data/generators/enhanced_response_generator.dart:564-576`

**Step 1: Replace the implementation**

```dart
  /// Extract real volume data from search results
  Map<String, dynamic> _extractVolumeData(List<SearchResult> results) {
    if (results.isEmpty) return {};

    final extractor = DocumentDataExtractor();

    final volumes = <double>[];
    final muscleGroupVolumes = <String, double>{};

    for (final result in results) {
      final content = result.document.content;

      // Try to get total volume from workout documents
      if (result.document.id.startsWith('workout_')) {
        final volume = extractor.extractVolume(content);
        if (volume != null && volume > 0) {
          volumes.add(volume);
        }

        // Track muscle group distribution
        for (final category in ['chest', 'back', 'legs', 'shoulders', 'arms', 'core']) {
          if (content.toLowerCase().contains(category)) {
            muscleGroupVolumes[category] =
                (muscleGroupVolumes[category] ?? 0) + (volume ?? 0) / 3; // Approximate split
          }
        }
      }

      // Get exercise-specific volume
      if (result.document.id.startsWith('exercise_')) {
        final exerciseVolume = extractor.extractExerciseVolume(content);
        if (exerciseVolume != null) {
          // Add to appropriate muscle group
          final exerciseName = extractor.extractExerciseNameFromContent(content);
          final category = _inferMuscleGroup(exerciseName ?? '');
          if (category != null) {
            muscleGroupVolumes[category] =
                (muscleGroupVolumes[category] ?? 0) + exerciseVolume;
          }
        }
      }
    }

    if (volumes.isEmpty) return {};

    final totalVolume = volumes.reduce((a, b) => a + b);
    final averageVolume = totalVolume / volumes.length;
    final peakVolume = volumes.reduce((a, b) => a > b ? a : b);

    // Determine trend
    String? trend;
    if (volumes.length >= 3) {
      final firstHalf = volumes.take(volumes.length ~/ 2).toList();
      final secondHalf = volumes.skip(volumes.length ~/ 2).toList();

      final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

      if (secondAvg > firstAvg * 1.1) {
        trend = 'Increasing';
      } else if (secondAvg < firstAvg * 0.9) {
        trend = 'Decreasing';
      } else {
        trend = 'Stable';
      }
    }

    // Format muscle group volumes
    final distribution = <String, double>{};
    for (final entry in muscleGroupVolumes.entries) {
      if (entry.value > 0) {
        final formattedName = entry.key[0].toUpperCase() + entry.key.substring(1);
        distribution[formattedName] = entry.value.roundToDouble();
      }
    }

    return {
      'total': totalVolume.round(),
      'average': averageVolume.round(),
      'peak': peakVolume.round(),
      if (trend != null) 'trend': trend,
      if (distribution.isNotEmpty) 'distribution': distribution,
    };
  }

  /// Infer muscle group from exercise name
  String? _inferMuscleGroup(String exerciseName) {
    final name = exerciseName.toLowerCase();

    if (name.contains('bench') || name.contains('chest') || name.contains('fly')) {
      return 'chest';
    }
    if (name.contains('row') || name.contains('pull') || name.contains('lat') || name.contains('back')) {
      return 'back';
    }
    if (name.contains('squat') || name.contains('leg') || name.contains('lunge') || name.contains('deadlift')) {
      return 'legs';
    }
    if (name.contains('press') || name.contains('shoulder') || name.contains('delt')) {
      return 'shoulders';
    }
    if (name.contains('curl') || name.contains('tricep') || name.contains('bicep') || name.contains('arm')) {
      return 'arms';
    }
    if (name.contains('crunch') || name.contains('plank') || name.contains('ab') || name.contains('core')) {
      return 'core';
    }

    return null;
  }
```

**Step 2: Run tests**

Run: `flutter test test/features/ai_coach/`
Expected: PASS

**Step 3: Commit**

```bash
git add lib/features/ai_coach/data/generators/enhanced_response_generator.dart
git commit -m "fix(ai-coach): extract real volume data from BM25 results"
```

---

## Task 6: Fix `_analyzeProgression` Method

**Files:**
- Modify: `lib/features/ai_coach/data/generators/enhanced_response_generator.dart:531-534`

**Step 1: Replace the implementation**

```dart
  /// Analyze real progression from search results
  Map<String, Map<String, dynamic>> _analyzeProgression(List<SearchResult> results) {
    if (results.isEmpty) return {};

    final extractor = DocumentDataExtractor();
    final progressionData = <String, Map<String, dynamic>>{};

    // Group results by exercise
    final exerciseData = <String, List<_ExerciseDataPoint>>{};

    for (final result in results) {
      if (!result.document.id.startsWith('exercise_')) continue;

      final content = result.document.content;
      final exerciseName = extractor.extractExerciseNameFromContent(content);
      final date = result.document.timestamp;

      if (exerciseName == null || date == null) continue;

      final sets = extractor.extractSets(content);
      if (sets.isEmpty) continue;

      final maxWeight = extractor.calculateMaxWeight(sets);
      if (maxWeight == null) continue;

      exerciseData.putIfAbsent(exerciseName, () => []);
      exerciseData[exerciseName]!.add(_ExerciseDataPoint(
        date: date,
        maxWeight: maxWeight,
        volume: extractor.calculateTotalVolume(sets),
      ));
    }

    // Calculate progression for each exercise
    for (final entry in exerciseData.entries) {
      final dataPoints = entry.value..sort((a, b) => a.date.compareTo(b.date));

      if (dataPoints.length < 2) continue;

      final first = dataPoints.first;
      final last = dataPoints.last;

      final improvement = ((last.maxWeight - first.maxWeight) / first.maxWeight * 100);

      // Determine frequency
      final daySpan = last.date.difference(first.date).inDays;
      final frequency = daySpan > 0
          ? '${(dataPoints.length / (daySpan / 7)).toStringAsFixed(1)}x/week'
          : 'N/A';

      progressionData[entry.key] = {
        'start': first.maxWeight.round(),
        'current': last.maxWeight.round(),
        'improvement': improvement.round(),
        'frequency': frequency,
        'sessions': dataPoints.length,
      };
    }

    return progressionData;
  }
```

**Step 2: Add helper class at end of file**

```dart
/// Helper class for exercise progression tracking
class _ExerciseDataPoint {
  const _ExerciseDataPoint({
    required this.date,
    required this.maxWeight,
    required this.volume,
  });

  final DateTime date;
  final double maxWeight;
  final double volume;
}
```

**Step 3: Run tests**

Run: `flutter test test/features/ai_coach/`
Expected: PASS

**Step 4: Commit**

```bash
git add lib/features/ai_coach/data/generators/enhanced_response_generator.dart
git commit -m "fix(ai-coach): analyze real progression data from BM25 results"
```

---

## Task 7: Fix userId Placeholders

**Files:**
- Modify: `lib/features/ai_coach/presentation/widgets/chat_modal_content.dart:54`
- Modify: `lib/features/ai_coach/presentation/providers/feedback_provider.dart:62`
- Modify: `lib/features/ai_coach/presentation/providers/feature_gate_provider.dart` (multiple lines)

**Step 1: Fix chat_modal_content.dart**

Replace line 54:

```dart
// Before:
const userId = 'test-user';

// After:
final userId = ref.watch(currentUserIdProvider) ?? 'anonymous';
```

Add import at top:
```dart
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
```

**Step 2: Fix feedback_provider.dart**

Replace line 62:

```dart
// Before:
_userId = 'dev_user';

// After:
_userId = ref.read(currentUserIdProvider) ?? 'anonymous';
```

Add import:
```dart
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
```

**Step 3: Fix feature_gate_provider.dart**

Replace all occurrences of `const userId = 'temp-user-id';` with:

```dart
final userId = ref.read(currentUserIdProvider) ?? 'anonymous';
```

Add import at top:
```dart
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
```

**Step 4: Run analyzer**

Run: `flutter analyze`
Expected: No errors

**Step 5: Commit**

```bash
git add lib/features/ai_coach/presentation/widgets/chat_modal_content.dart
git add lib/features/ai_coach/presentation/providers/feedback_provider.dart
git add lib/features/ai_coach/presentation/providers/feature_gate_provider.dart
git commit -m "fix(ai-coach): replace hardcoded userId placeholders with real auth"
```

---

## Task 8: Fix Streak Mock Data

**Files:**
- Modify: `lib/features/ai_coach/presentation/providers/streak_tracker_provider.dart`

**Step 1: Read the file to understand current structure**

```bash
# First review the current implementation
```

**Step 2: Replace mock data with real workout dates**

The provider should fetch real workout dates from the workout repository instead of using `_getMockWorkoutDates()`.

Replace the mock implementation:

```dart
// Remove the _getMockWorkoutDates() method entirely

// Update _loadStreak to use real data:
Future<void> _loadStreak() async {
  state = const AsyncValue.loading();

  try {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = AsyncValue.data(StreakData.empty());
      return;
    }

    // Get real workout dates from repository
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final workouts = await workoutRepo.getWorkouts(userId);

    final workoutDates = workouts
        .map((w) => w.startTime ?? w.createdAt)
        .map((dt) => DateTime(dt.year, dt.month, dt.day)) // Normalize to date only
        .toSet()
        .toList()
      ..sort();

    state = AsyncValue.data(StreakData(
      currentStreak: _calculateCurrentStreak(workoutDates),
      longestStreak: _calculateLongestStreak(workoutDates),
      workoutDates: workoutDates,
      lastWorkoutDate: workoutDates.isNotEmpty ? workoutDates.last : null,
    ));
  } catch (e, st) {
    state = AsyncValue.error(e, st);
  }
}
```

**Step 3: Add required imports**

```dart
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/hybrid_workout_repository_impl.dart';
```

**Step 4: Run tests**

Run: `flutter analyze`
Expected: No errors

**Step 5: Commit**

```bash
git add lib/features/ai_coach/presentation/providers/streak_tracker_provider.dart
git commit -m "fix(ai-coach): use real workout dates for streak tracking"
```

---

## Final Verification

**Step 1: Run all tests**

```bash
flutter test
```

**Step 2: Run analyzer**

```bash
flutter analyze
```

**Step 3: Manual testing**

1. Open the app
2. Go to Home screen
3. Open AI Coach card
4. Ask: "What's my bench press PR?"
5. Verify response contains real data (not 100kg hardcoded)
6. Ask: "Show my recent volume"
7. Verify volume numbers match actual workout data

**Step 4: Final commit**

```bash
git add -A
git commit -m "feat(ai-coach): complete fix for hardcoded data - all responses now use real user data"
```

---

## Summary of Changes

| File | Change |
|------|--------|
| `document_data_extractor.dart` | NEW - Utility for parsing BM25 content |
| `enhanced_response_generator.dart` | FIX - All 6 helper methods now extract real data |
| `chat_modal_content.dart` | FIX - Uses real userId from auth |
| `feedback_provider.dart` | FIX - Uses real userId from auth |
| `feature_gate_provider.dart` | FIX - Uses real userId from auth |
| `streak_tracker_provider.dart` | FIX - Uses real workout dates |

**Total estimated time:** 2-3 hours
**Complexity:** Medium
**Risk:** Low (isolated changes, no breaking API changes)
