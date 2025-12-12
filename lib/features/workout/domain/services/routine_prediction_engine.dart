import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/suggestion_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_suggestion.dart';
// ⚠️ ROUTINE FEATURE DISABLED (v2.0 API migration pending)
// import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';

/// Prediction engine with 2-level fallback hierarchy
///
/// Provides workout suggestions using a simplified fallback system:
/// 1. **Routine-Based** (highest priority): Active routine template schedule
/// 2. **Frequency-Based** (fallback): Most frequent workouts in last 30 days
///
/// Each level has specific requirements. If a level fails, the engine
/// automatically falls back to the next level.
///
/// Example:
/// ```dart
/// final engine = RoutinePredictionEngine();
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

  RoutinePredictionEngine();

  // Cache for performance (5-minute TTL)
  WorkoutSuggestion? _cachedSuggestion;
  DateTime? _cacheTimestamp;
  static const _cacheDuration = Duration(minutes: 5);

  /// Predict next workout using 2-level fallback hierarchy
  ///
  /// ⚠️ ROUTINE FEATURE DISABLED: Routine-based prediction temporarily unavailable
  ///
  /// [workoutHistory]: Recent workouts (newest first, 30-50 workouts recommended)
  /// [activeRoutine]: Optional active routine (currently ignored - feature disabled)
  /// [availableTemplateNames]: Optional list of existing template names for validation
  /// [availableTemplates]: Optional list of full templates for ID->Name mapping
  /// [useCache]: Whether to use cached suggestion (default: true)
  ///
  /// Returns: [WorkoutSuggestion] with predicted workout and confidence
  ///
  /// If [availableTemplateNames] is provided, the engine will validate suggestions
  /// against existing templates and fallback to generic "Workout" if template not found.
  Future<WorkoutSuggestion> predictNextWorkout({
    required List<Workout> workoutHistory,
    dynamic activeRoutine, // FlexibleRoutine? - type removed due to feature disabled
    List<String>? availableTemplateNames,
    List<dynamic>? availableTemplates, // WorkoutTemplate objects
    bool useCache = true,
  }) async {
    // Check cache first
    if (useCache && _isCacheValid()) {
      return _cachedSuggestion!;
    }

    // ⚠️ ROUTINE FEATURE DISABLED: Skip routine-based prediction
    // Try Level 1: Routine-Based (temporarily disabled)
    // if (activeRoutine != null) {
    //   final routineSuggestion = await _tryRoutineBased(
    //     activeRoutine: activeRoutine,
    //     availableTemplates: availableTemplates,
    //   );
    //   if (routineSuggestion != null) {
    //     return _cacheAndReturn(routineSuggestion);
    //   }
    // }

    // Fallback Level 2: Frequency-Based (always succeeds)
    final frequencySuggestion = await _tryFrequencyBased(workoutHistory);
    if (frequencySuggestion != null) {
      final validatedSuggestion = _validateTemplateExists(
        frequencySuggestion,
        availableTemplateNames,
        workoutHistory,
      );
      return _cacheAndReturn(validatedSuggestion);
    }

    // Final fallback: Generic "Workout" suggestion
    return _cacheAndReturn(
      WorkoutSuggestion(
        level: SuggestionLevel.frequency,
        workoutName: 'Workout',
        confidence: 0.20,
        reason: 'Start with any workout',
        generatedAt: DateTime.now(),
      ),
    );
  }

  /// Clear cached suggestion (force recalculation next time)
  void clearCache() {
    _cachedSuggestion = null;
    _cacheTimestamp = null;
  }

  // ========== LEVEL 1: ROUTINE-BASED (DISABLED) ==========

  /// ⚠️ ROUTINE FEATURE DISABLED (v2.0 API migration pending)
  /// Try routine-based suggestion using FlexibleRoutine.getNextWorkoutName()
  ///
  /// This method is currently stubbed out and always returns null.
  /// Delegates rotation logic to FlexibleRoutine entity (single source of truth).
  ///
  /// Requirements:
  /// - Active routine exists
  /// - Routine has repeating pattern
  /// - Available templates provided for name mapping
  Future<WorkoutSuggestion?> _tryRoutineBased({
    required dynamic activeRoutine, // FlexibleRoutine - type removed
    required List<dynamic>? availableTemplates,
  }) async {
    // ⚠️ ROUTINE FEATURE DISABLED: Always return null (skip routine-based prediction)
    // TODO: Re-enable when v2.0 routine API is ready
    return null;

    // Original implementation commented out:
    // // Validate templates available
    // if (availableTemplates == null || availableTemplates.isEmpty) {
    //   return null; // Cannot map template ID→Name without templates
    // }
    //
    // // ✅ SIMPLIFIED: Delegate to FlexibleRoutine.getNextWorkoutName()
    // // This is the single source of truth for workout rotation logic
    // try {
    //   final workoutName = activeRoutine.getNextWorkoutName(
    //     availableTemplates: availableTemplates,
    //   );
    //
    //   if (workoutName == null) {
    //     return null; // Non-repeating pattern, fallback to frequency-based
    //   }
    //
    //   // Get next uncompleted workout for scheduled date (optional)
    //   final nextUncompletedWorkout = activeRoutine.getNextUncompletedWorkout();
    //
    //   return WorkoutSuggestion(
    //     level: SuggestionLevel.routine,
    //     workoutName: workoutName,
    //     confidence: 0.95, // High confidence (routine-based + rotation logic)
    //     reason: 'Da routine ${activeRoutine.name}',
    //     scheduledDate: nextUncompletedWorkout?.date,
    //     generatedAt: DateTime.now(),
    //   );
    // } catch (e) {
    //   if (kDebugMode) {
    //   }
    //   return null; // Fallback to frequency-based
    // }
  }

  // ========== LEVEL 2: FREQUENCY-BASED ==========

  /// Try frequency-based suggestion (most frequent workout in last 30 days)
  ///
  /// Returns the least recently done workout to encourage balanced training.
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
