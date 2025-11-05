import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/suggestion_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_suggestion.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/pattern_detection_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/pattern_viability_checker.dart';

/// Prediction engine with 4-level fallback hierarchy
///
/// Provides workout suggestions using a hierarchical fallback system:
/// 1. **Pattern-Based** (highest priority): Detected repeating patterns
/// 2. **Routine-Based**: Active routine template schedule
/// 3. **Frequency-Based**: Most frequent workouts
/// 4. **Day-Based** (fallback): Default by day of week
///
/// Each level has specific requirements. If a level fails, the engine
/// automatically falls back to the next level.
///
/// Example:
/// ```dart
/// final engine = RoutinePredictionEngine(
///   patternService: PatternDetectionService(),
///   viabilityChecker: PatternViabilityChecker(),
/// );
///
/// final suggestion = await engine.predictNextWorkout(
///   workoutHistory: workouts,
///   activeRoutineTemplateId: 'routine_123', // optional
/// );
///
/// print('Suggestion: ${suggestion.workoutName}');
/// print('Level: ${suggestion.level}');
/// print('Confidence: ${suggestion.displayConfidence}');
/// ```
class RoutinePredictionEngine {

  RoutinePredictionEngine({
    required PatternDetectionService patternService,
    required PatternViabilityChecker viabilityChecker,
  })  : _patternService = patternService,
        _viabilityChecker = viabilityChecker;
  final PatternDetectionService _patternService;
  final PatternViabilityChecker _viabilityChecker;

  // Cache for performance (5-minute TTL)
  WorkoutSuggestion? _cachedSuggestion;
  DateTime? _cacheTimestamp;
  static const _cacheDuration = Duration(minutes: 5);

  /// Predict next workout using 4-level fallback hierarchy
  ///
  /// [workoutHistory]: Recent workouts (newest first, 30-50 workouts recommended)
  /// [activeRoutineTemplateId]: Optional active routine ID for Level 2
  /// [availableTemplateNames]: Optional list of existing template names for validation
  /// [useCache]: Whether to use cached suggestion (default: true)
  ///
  /// Returns: [WorkoutSuggestion] with predicted workout and confidence
  ///
  /// If [availableTemplateNames] is provided, the engine will validate suggestions
  /// against existing templates and fallback to generic "Workout" if template not found.
  Future<WorkoutSuggestion> predictNextWorkout({
    required List<Workout> workoutHistory,
    String? activeRoutineTemplateId,
    List<String>? availableTemplateNames,
    bool useCache = true,
  }) async {
    // Check cache first
    if (useCache && _isCacheValid()) {
      return _cachedSuggestion!;
    }

    // Try Level 1: Pattern-Based
    final patternSuggestion = await _tryPatternBased(workoutHistory);
    if (patternSuggestion != null) {
      return _cacheAndReturn(patternSuggestion);
    }

    // Try Level 2: Routine-Based
    if (activeRoutineTemplateId != null) {
      final routineSuggestion = await _tryRoutineBased(
        workoutHistory,
        activeRoutineTemplateId,
      );
      if (routineSuggestion != null) {
        return _cacheAndReturn(routineSuggestion);
      }
    }

    // Try Level 3: Frequency-Based
    final frequencySuggestion = await _tryFrequencyBased(workoutHistory);
    if (frequencySuggestion != null) {
      final validatedSuggestion = _validateTemplateExists(
        frequencySuggestion,
        availableTemplateNames,
        workoutHistory,
      );
      return _cacheAndReturn(validatedSuggestion);
    }

    // Fallback Level 4: Day-Based (always succeeds)
    final dayBasedSuggestion = await _tryDayBased(workoutHistory);
    final validatedSuggestion = _validateTemplateExists(
      dayBasedSuggestion,
      availableTemplateNames,
      workoutHistory,
    );
    return _cacheAndReturn(validatedSuggestion);
  }

  /// Clear cached suggestion (force recalculation next time)
  void clearCache() {
    _cachedSuggestion = null;
    _cacheTimestamp = null;
  }

  // ========== LEVEL 1: PATTERN-BASED ==========

  /// Try pattern-based suggestion (franco→ciccio→paolo)
  ///
  /// Requirements:
  /// - ≥6 workouts
  /// - ≥18 days of data
  /// - ≥3 complete cycles
  /// - Confidence ≥0.70
  /// - Coverage >50%
  Future<WorkoutSuggestion?> _tryPatternBased(
    List<Workout> workoutHistory,
  ) async {
    // Detect pattern
    final pattern = await _patternService.detectPattern(
      recentWorkouts: workoutHistory,
    );

    if (pattern == null) return null;

    // Check viability
    final viability = _viabilityChecker.isViable(
      pattern: pattern,
      workoutHistory: workoutHistory,
    );

    if (!viability.isViable) return null;

    // Generate suggestion
    final nextWorkout = pattern.predictNext();
    final lastWorkout = _getLastWorkoutName(workoutHistory);

    return WorkoutSuggestion(
      level: SuggestionLevel.pattern,
      workoutName: nextWorkout,
      confidence: pattern.confidence,
      reason: 'Detected pattern: ${pattern.displayPattern} '
          '(${pattern.displayConfidence} confidence)',
      patternInfo: lastWorkout != null
          ? 'You completed $lastWorkout last time'
          : null,
      generatedAt: DateTime.now(),
    );
  }

  // ========== LEVEL 2: ROUTINE-BASED ==========

  /// Try routine-based suggestion (active routine template)
  ///
  /// Requirements:
  /// - Active routine exists
  /// - Routine has defined schedule
  /// - Not yet implemented (placeholder)
  Future<WorkoutSuggestion?> _tryRoutineBased(
    List<Workout> workoutHistory,
    String routineTemplateId,
  ) async {
    // TODO: Implement routine-based logic
    // 1. Fetch routine template by ID
    // 2. Get current day in rotation
    // 3. Return template workout for today
    // 4. Calculate confidence based on routine adherence

    // Placeholder: Always return null for now
    return null;
  }

  // ========== LEVEL 3: FREQUENCY-BASED ==========

  /// Try frequency-based suggestion (most frequent workout)
  ///
  /// Requirements:
  /// - ≥3 workouts in last 30 days
  /// - Clear frequency leader (>2x more than others)
  Future<WorkoutSuggestion?> _tryFrequencyBased(
    List<Workout> workoutHistory,
  ) async {
    // Filter to last 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentWorkouts = workoutHistory.where((w) {
      return w.startTime != null && w.startTime!.isAfter(thirtyDaysAgo);
    }).toList();

    if (recentWorkouts.length < 3) return null;

    // Count workout frequencies
    // 🔧 FIX: Preserve original capitalization by mapping normalized → original
    final frequencies = <String, int>{};
    final normalizedToOriginal = <String, String>{}; // Map lowercase → original

    for (final workout in recentWorkouts) {
      final originalName = workout.name ?? 'Unknown';
      final normalizedName = _normalizeWorkoutName(originalName);

      frequencies[normalizedName] = (frequencies[normalizedName] ?? 0) + 1;
      // Keep the first occurrence's capitalization as canonical
      normalizedToOriginal[normalizedName] ??= originalName;
    }

    if (frequencies.isEmpty) return null;

    // Find most frequent workout
    final sortedEntries = frequencies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final mostFrequentNormalized = sortedEntries.first;
    final secondMostFrequent =
        sortedEntries.length > 1 ? sortedEntries[1] : null;

    // Require clear leader (>2x more frequent)
    if (secondMostFrequent != null &&
        mostFrequentNormalized.value < secondMostFrequent.value * 2) {
      return null; // No clear winner
    }

    // 🔧 FIX: Use original capitalization instead of normalized lowercase
    final mostFrequentOriginal = normalizedToOriginal[mostFrequentNormalized.key] ?? mostFrequentNormalized.key;

    // Calculate confidence based on frequency ratio
    final totalWorkouts = recentWorkouts.length;
    final frequencyRatio = mostFrequentNormalized.value / totalWorkouts;
    final confidence = 0.50 + (frequencyRatio * 0.20); // 0.50 - 0.70

    return WorkoutSuggestion(
      level: SuggestionLevel.frequency,
      workoutName: mostFrequentOriginal,
      confidence: confidence,
      reason: 'You do $mostFrequentOriginal most often',
      frequencyData: '${mostFrequentNormalized.value} times in last 30 days',
      generatedAt: DateTime.now(),
    );
  }

  // ========== LEVEL 4: DAY-BASED (FALLBACK) ==========

  /// Try day-based suggestion (default by weekday)
  ///
  /// Always succeeds - uses historical data to find default workout for today
  Future<WorkoutSuggestion> _tryDayBased(
    List<Workout> workoutHistory,
  ) async {
    final today = DateTime.now().weekday; // 1=Monday, 7=Sunday

    // Find most common workout for this weekday
    final workoutsOnThisDay = workoutHistory.where((w) {
      return w.startTime?.weekday == today;
    }).toList();

    String defaultWorkout;
    String reason;
    double confidence;

    if (workoutsOnThisDay.isNotEmpty) {
      // Count frequencies for this day
      final frequencies = <String, int>{};
      for (final workout in workoutsOnThisDay) {
        final name = _normalizeWorkoutName(workout.name ?? 'Unknown');
        frequencies[name] = (frequencies[name] ?? 0) + 1;
      }

      // Get most common
      final mostCommon = frequencies.entries.reduce((a, b) {
        return a.value > b.value ? a : b;
      });

      defaultWorkout = mostCommon.key;
      final dayName = _getDayName(today);
      reason = 'On $dayName, you usually do $defaultWorkout';
      confidence = 0.30 + (mostCommon.value / workoutsOnThisDay.length) * 0.20;
    } else {
      // No historical data for this day - use overall most frequent
      final frequencies = <String, int>{};
      for (final workout in workoutHistory) {
        final name = _normalizeWorkoutName(workout.name ?? 'Unknown');
        frequencies[name] = (frequencies[name] ?? 0) + 1;
      }

      if (frequencies.isNotEmpty) {
        final mostCommon = frequencies.entries.reduce((a, b) {
          return a.value > b.value ? a : b;
        });
        defaultWorkout = mostCommon.key;
      } else {
        // No data at all - generic fallback
        defaultWorkout = 'Workout';
      }

      reason = 'Start with any workout';
      confidence = 0.30;
    }

    return WorkoutSuggestion(
      level: SuggestionLevel.dayBased,
      workoutName: defaultWorkout,
      confidence: confidence,
      reason: reason,
      generatedAt: DateTime.now(),
    );
  }

  // ========== HELPER METHODS ==========

  /// Normalize workout name for matching
  String _normalizeWorkoutName(String name) {
    return name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Validate that suggested template exists, fallback to generic if not
  ///
  /// If [availableTemplateNames] is null, returns suggestion as-is (no validation)
  /// If template doesn't exist, finds next best alternative or fallback to "Workout"
  WorkoutSuggestion _validateTemplateExists(
    WorkoutSuggestion suggestion,
    List<String>? availableTemplateNames,
    List<Workout> workoutHistory,
  ) {
    if (kDebugMode || kProfileMode) {
      debugPrint('🔍 [VALIDATE_TEMPLATE] Called with suggestion: "${suggestion.workoutName}"');
      debugPrint('🔍 [VALIDATE_TEMPLATE] Available templates: $availableTemplateNames');
    }

    // 🔧 FIX: If no templates provided, use generic fallback instead of skipping
    // This prevents returning deleted templates when template list is empty
    if (availableTemplateNames == null || availableTemplateNames.isEmpty) {
      if (kDebugMode || kProfileMode) {
        debugPrint('🔍 [VALIDATE_TEMPLATE] ⚠️ No templates provided! Using generic fallback');
        debugPrint('🔍 [VALIDATE_TEMPLATE] Original suggestion was: "${suggestion.workoutName}"');
      }
      return WorkoutSuggestion(
        level: SuggestionLevel.dayBased,
        workoutName: 'Workout',
        confidence: 0.20,
        reason:
            'Could not validate template "${suggestion.workoutName}". Start with any workout',
        generatedAt: DateTime.now(),
      );
    }

    // Normalize available template names for case-insensitive matching
    final normalizedTemplates = availableTemplateNames
        .map((name) => _normalizeWorkoutName(name))
        .toSet();

    if (kDebugMode || kProfileMode) {
      debugPrint('🔍 [VALIDATE_TEMPLATE] Normalized templates: $normalizedTemplates');
    }

    // Check if suggested workout exists as template
    final normalizedSuggestion = _normalizeWorkoutName(suggestion.workoutName);

    if (kDebugMode || kProfileMode) {
      debugPrint('🔍 [VALIDATE_TEMPLATE] Normalized suggestion: "$normalizedSuggestion"');
      debugPrint('🔍 [VALIDATE_TEMPLATE] Template exists? ${normalizedTemplates.contains(normalizedSuggestion)}');
    }

    if (normalizedTemplates.contains(normalizedSuggestion)) {
      if (kDebugMode || kProfileMode) {
        debugPrint('🔍 [VALIDATE_TEMPLATE] ✅ Template exists! Returning as-is');
      }
      return suggestion; // Template exists, return as-is
    }

    // Template doesn't exist! Find fallback:
    if (kDebugMode || kProfileMode) {
      debugPrint('🔍 [VALIDATE_TEMPLATE] ❌ Template NOT found! Finding alternative...');
    }

    // 1. Try to find most frequent workout that DOES have a template
    // 🔧 FIX: Preserve original capitalization by mapping normalized → original
    final frequencies = <String, int>{};
    final normalizedToOriginal = <String, String>{}; // Map lowercase → original

    for (final workout in workoutHistory) {
      final originalName = workout.name ?? 'Unknown';
      final normalizedName = _normalizeWorkoutName(originalName);

      if (normalizedTemplates.contains(normalizedName)) {
        frequencies[normalizedName] = (frequencies[normalizedName] ?? 0) + 1;
        // Keep the first occurrence's capitalization as canonical
        normalizedToOriginal[normalizedName] ??= originalName;
      }
    }

    if (kDebugMode || kProfileMode) {
      debugPrint('🔍 [VALIDATE_TEMPLATE] Frequencies of valid templates: $frequencies');
      debugPrint('🔍 [VALIDATE_TEMPLATE] Original names mapping: $normalizedToOriginal');
    }

    // If found valid alternative, use it
    if (frequencies.isNotEmpty) {
      final normalizedBest = frequencies.entries.reduce((a, b) {
        return a.value > b.value ? a : b;
      }).key;

      // 🔧 FIX: Use original capitalization instead of normalized lowercase
      final bestAlternative = normalizedToOriginal[normalizedBest] ?? normalizedBest;

      if (kDebugMode || kProfileMode) {
        debugPrint('🔍 [VALIDATE_TEMPLATE] ✅ Found alternative: "$bestAlternative" (normalized: "$normalizedBest")');
      }

      return WorkoutSuggestion(
        level: suggestion.level,
        workoutName: bestAlternative,
        confidence: suggestion.confidence * 0.8, // Lower confidence (alternative)
        reason:
            'Template "${suggestion.workoutName}" not found. Suggesting "$bestAlternative" instead',
        generatedAt: DateTime.now(),
      );
    }

    // No valid alternatives found - use generic fallback
    if (kDebugMode || kProfileMode) {
      debugPrint('🔍 [VALIDATE_TEMPLATE] ⚠️ No valid alternatives! Using generic "Workout"');
    }

    return WorkoutSuggestion(
      level: SuggestionLevel.dayBased,
      workoutName: 'Workout',
      confidence: 0.20,
      reason:
          'Template "${suggestion.workoutName}" not found. Start with any workout',
      generatedAt: DateTime.now(),
    );
  }

  /// Get last workout name from history
  String? _getLastWorkoutName(List<Workout> workoutHistory) {
    if (workoutHistory.isEmpty) return null;
    return workoutHistory.first.name; // Already newest first
  }

  /// Get day name from weekday number
  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1]; // weekday is 1-based
  }

  /// Check if cache is valid (not expired)
  bool _isCacheValid() {
    if (_cachedSuggestion == null || _cacheTimestamp == null) {
      return false;
    }

    final age = DateTime.now().difference(_cacheTimestamp!);
    return age < _cacheDuration;
  }

  /// Cache suggestion and return it
  WorkoutSuggestion _cacheAndReturn(WorkoutSuggestion suggestion) {
    _cachedSuggestion = suggestion;
    _cacheTimestamp = DateTime.now();
    return suggestion;
  }
}
