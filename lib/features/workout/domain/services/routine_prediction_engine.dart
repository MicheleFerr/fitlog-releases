import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/suggestion_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_suggestion.dart';

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
  /// [workoutHistory]: Recent workouts (newest first, 30-50 workouts recommended)
  /// [activeRoutineTemplateId]: Optional active routine ID for Level 1
  /// [nextWorkoutTemplateId]: Optional next uncompleted workout template ID from routine
  /// [nextWorkoutScheduledDate]: Optional scheduled date for next workout from routine
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
    String? activeRoutineTemplateId,
    String? nextWorkoutTemplateId,
    DateTime? nextWorkoutScheduledDate,
    List<String>? availableTemplateNames,
    List<dynamic>? availableTemplates, // WorkoutTemplate objects
    bool useCache = true,
  }) async {
    // Check cache first
    if (useCache && _isCacheValid()) {
      return _cachedSuggestion!;
    }

    // Try Level 1: Routine-Based
    if (activeRoutineTemplateId != null && nextWorkoutTemplateId != null) {
      final routineSuggestion = await _tryRoutineBased(
        workoutHistory,
        activeRoutineTemplateId,
        nextWorkoutTemplateId,
        nextWorkoutScheduledDate,
        availableTemplateNames,
        availableTemplates,
      );
      if (routineSuggestion != null) {
        return _cacheAndReturn(routineSuggestion);
      }
    }

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

  // ========== LEVEL 1: ROUTINE-BASED ==========

  /// Try routine-based suggestion (active routine template)
  ///
  /// Requirements:
  /// - Active routine exists
  /// - Routine has defined schedule
  /// - Not yet implemented (placeholder)
  Future<WorkoutSuggestion?> _tryRoutineBased(
    List<Workout> workoutHistory,
    String routineTemplateId,
    String nextWorkoutTemplateId,
    DateTime? scheduledDate,
    List<String>? availableTemplateNames,
    List<dynamic>? availableTemplates, // Full template objects
  ) async {
    // ✅ IMPLEMENTED: Use next uncompleted workout from active routine

    // Find template name from template ID using templates list
    if (availableTemplates == null || availableTemplates.isEmpty) {
      return null; // Cannot find template without templates list
    }

    // ✅ FIX: Find template by ID and get its name directly
    // Handle dynamic template objects safely
    String? workoutName;

    // Try to find matching template and extract name
    for (final template in availableTemplates) {
      try {
        // Safely access ID property (could be string or method)
        String? templateId;
        if (template is Map) {
          templateId = template['id']?.toString();
        } else {
          // Try accessing as object property
          try {
            templateId = (template as dynamic).id?.toString();
          } catch (_) {
            // Skip if can't access id
            continue;
          }
        }

        // Check if this is the template we're looking for
        if (templateId == nextWorkoutTemplateId) {
          // Extract name safely
          if (template is Map) {
            workoutName = template['name']?.toString();
          } else {
            try {
              workoutName = (template as dynamic).name?.toString();
            } catch (_) {
              // Use fallback name
              workoutName = 'Workout';
            }
          }
          break;
        }
      } catch (e) {
        // Skip this template if we can't access its properties
        continue;
      }
    }

    // If we couldn't find the template name, use a reasonable default
    // based on the template ID pattern (e.g., "template-a" → "Giorno A")
    if (workoutName == null || workoutName.isEmpty) {
      // Extract letter from template ID if it follows pattern "template-X"
      final letterMatch = RegExp(r'template-([a-d])', caseSensitive: false)
          .firstMatch(nextWorkoutTemplateId);
      if (letterMatch != null) {
        final letter = letterMatch.group(1)!.toUpperCase();
        workoutName = 'Giorno $letter';
      } else {
        // Last resort: use the template ID directly
        workoutName = nextWorkoutTemplateId;
      }
    }

    // Validate that this template name exists in available names
    if (availableTemplateNames != null &&
        !availableTemplateNames.contains(workoutName)) {
      // Template name doesn't exist in available names
      return null;
    }

    // Calculate confidence based on routine adherence
    // High confidence if user follows routine consistently
    const confidence = 0.80; // High confidence for routine-based suggestions

    return WorkoutSuggestion(
      level: SuggestionLevel.routine,
      workoutName: workoutName,
      confidence: confidence,
      reason: 'Next in your active routine',
      scheduledDate: scheduledDate, // ✅ NEW: Pass scheduled date to UI
      generatedAt: DateTime.now(),
    );
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
