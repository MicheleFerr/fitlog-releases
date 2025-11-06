import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collection/collection.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/pattern_detection_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_suggestion_analytics.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/recovery_time_calculator.dart';

/// Intelligent workout suggestion provider that learns from user's local history
final intelligentWorkoutSuggestionProvider = FutureProvider<WorkoutSuggestion?>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return null;

  final hiveDataSource = ref.read(hiveWorkoutDataSourceProvider);
  final templates = await ref.read(allWorkoutTemplatesProvider.future);

  try {
    final stopwatch = Stopwatch()..start();

    // Get recent workout history from local storage (last 30 days)
    final DateTime cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    final recentWorkouts = await hiveDataSource.getWorkouts(
      userId,
      limit: 50,
      startDate: cutoffDate,
    );

    if (recentWorkouts.isEmpty) {
      // Track fallback due to no history
      await WorkoutSuggestionAnalytics.trackFallbackUsed(
        reason: 'no_history',
      );
      return null; // No history, can't make intelligent suggestion
    }

    // LEVEL 1: Try pattern detection with new PatternDetectionService
    final patternService = PatternDetectionService();

    // Convert WorkoutModel to Workout domain entities
    final domainWorkouts = recentWorkouts.map((w) => w.toDomain()).toList();

    // Detect pattern from recent workouts
    final patternResult = await patternService.detectPattern(
      recentWorkouts: domainWorkouts,
      minPatternLength: 2,
      maxPatternLength: 7,
      minRepetitions: 2,
    );

    if (patternResult != null && patternResult.confidence >= 0.75) {
        // Pattern found!
        stopwatch.stop();

        if (kDebugMode) {
          debugPrint('🎯 Pattern detected: ${patternResult.pattern.join(" → ")}');
        }

        await WorkoutSuggestionAnalytics.trackPatternDetection(
          patternFound: true,
          confidence: patternResult.confidence,
          patternLength: patternResult.pattern.length,
          sequenceLength: recentWorkouts.length,
          computationTimeMs: stopwatch.elapsedMilliseconds,
        );

        final nextWorkoutType = patternResult.predictNext();
        final recoveryCalculator = RecoveryTimeCalculator();

        // Calculate recovery statuses for all workouts in pattern
        final recoveryStatuses = recoveryCalculator.calculateAllRecoveryStatuses(
          workoutTypes: patternResult.pattern,
          recentWorkouts: recentWorkouts,
          useExactNames: false,
        );

        final predictedRecoveryStatus = recoveryStatuses[nextWorkoutType];
        String finalWorkoutType = nextWorkoutType;
        String suggestionReason = patternResult.repetitions >= 3
            ? 'Continue your routine'
            : 'Next in rotation';

        if (predictedRecoveryStatus != null && !predictedRecoveryStatus.isRecovered) {
          final bestRecovered = recoveryCalculator.findBestRecoveredWorkout(
            recoveryStatuses: recoveryStatuses,
          );

          if (bestRecovered != null && bestRecovered != nextWorkoutType) {
            finalWorkoutType = bestRecovered;
            suggestionReason = 'Better recovery time';

            if (kDebugMode) {
              debugPrint('🔄 Recovery override: $nextWorkoutType → $finalWorkoutType');
            }
          }
        }

        // Find matching template
        final matchingTemplate = _findMatchingTemplate(
          templates,
          finalWorkoutType,
          preferExactMatch: false,
        );

        if (matchingTemplate != null) {
          final daysSinceLastWorkout = recentWorkouts.isNotEmpty && recentWorkouts.first.startTime != null
            ? DateTime.now().difference(recentWorkouts.first.startTime!).inDays
            : 0;

          double finalConfidence = patternResult.confidence;
          if (recoveryStatuses.containsKey(finalWorkoutType)) {
            final recoveryBoost = recoveryCalculator.getRecoveryConfidenceBoost(
              recoveryStatuses[finalWorkoutType]!,
            );
            finalConfidence = (finalConfidence + recoveryBoost).clamp(0.0, 1.0);
          }

          final suggestion = WorkoutSuggestion(
            templateName: matchingTemplate.name,
            reason: suggestionReason,
            confidence: finalConfidence,
            pattern: patternResult.pattern,
            daysSinceLastWorkout: daysSinceLastWorkout,
            recoveryStatus: recoveryStatuses[finalWorkoutType],
          );

          await WorkoutSuggestionAnalytics.trackSuggestionShown(
            templateName: suggestion.templateName,
            reason: suggestion.reason,
            confidence: suggestion.confidence,
            suggestionLevel: 'intelligent',
            pattern: suggestion.pattern,
          );

          return suggestion;
        }
      } else {
        // Track pattern detection attempt but low confidence
        stopwatch.stop();
        await WorkoutSuggestionAnalytics.trackPatternDetection(
          patternFound: patternResult != null,
          confidence: patternResult?.confidence ?? 0.0,
          patternLength: patternResult?.pattern.length ?? 0,
          sequenceLength: recentWorkouts.length,
          computationTimeMs: stopwatch.elapsedMilliseconds,
        );
      }


    // LEVEL 2: Fall back to frequency-based suggestion
    final frequencySuggestion = _getFrequencyBasedSuggestion(recentWorkouts, templates);

    if (frequencySuggestion != null) {
      // Track fallback to frequency-based
      await WorkoutSuggestionAnalytics.trackFallbackUsed(
        reason: 'low_confidence',
        errorDetails: 'Pattern detection confidence < 0.75',
      );

      // Track suggestion shown
      await WorkoutSuggestionAnalytics.trackSuggestionShown(
        templateName: frequencySuggestion.templateName,
        reason: frequencySuggestion.reason,
        confidence: frequencySuggestion.confidence,
        suggestionLevel: 'fallback',
        pattern: null,
      );
    }

    return frequencySuggestion;

  } catch (e) {
    if (kDebugMode) {
      debugPrint('Error getting intelligent suggestion: $e');
    }

    // Track error
    await WorkoutSuggestionAnalytics.trackFallbackUsed(
      reason: 'error',
      errorDetails: e.toString(),
    );

    return null;
  }
});


/// Frequency-based suggestion from workout history
WorkoutSuggestion? _getFrequencyBasedSuggestion(
  List<WorkoutModel> recentWorkouts,
  List<WorkoutTemplate> templates,
) {
  // Count frequency of workout names
  final templateFrequency = <String, int>{};
  for (var workout in recentWorkouts) {
    final templateName = workout.name;
    templateFrequency[templateName] = (templateFrequency[templateName] ?? 0) + 1;
  }

  if (templateFrequency.isEmpty) {
    return _createFallbackSuggestion('Quick Workout');
  }

  // Get most frequent template
  final mostFrequentTemplate = templateFrequency.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;

  // Calculate days since last workout
  final daysSinceLastWorkout = recentWorkouts.isNotEmpty && recentWorkouts.first.startTime != null
    ? DateTime.now().difference(recentWorkouts.first.startTime!).inDays
    : 0;

  return WorkoutSuggestion(
    templateName: mostFrequentTemplate,
    reason: 'Your most frequent workout',
    confidence: 0.6, // Moderate confidence for frequency-based
    daysSinceLastWorkout: daysSinceLastWorkout,
  );
}

/// Find a template matching the predicted workout type
///
/// Supporta sia nomi esatti (custom) che categorie normalizzate
WorkoutTemplate? _findMatchingTemplate(
  List<WorkoutTemplate> templates,
  String workoutType, {
  bool preferExactMatch = true, // NUOVO: prova prima match esatto
}) {
  // STEP 1: Try exact name match first (per nomi custom come "Pippo", "Giovanni")
  if (preferExactMatch) {
    final exactNameMatch = templates.firstWhereOrNull(
      (t) => t.name.trim().toLowerCase() == workoutType.trim().toLowerCase(),
    );
    if (exactNameMatch != null) {
      if (kDebugMode) {
        debugPrint('✅ Found exact template match: ${exactNameMatch.name}');
      }
      return exactNameMatch;
    }
  }

  // STEP 2: Try normalized match (per categorie come PUSH, PULL, LEGS)
  // Normalize workout names for matching (lowercase and trim)
  final normalizedWorkoutType = workoutType.trim().toLowerCase();
  final normalizedMatch = templates.firstWhereOrNull(
    (t) => t.name.trim().toLowerCase() == normalizedWorkoutType,
  );

  if (normalizedMatch != null) {
    if (kDebugMode) {
      debugPrint('✅ Found normalized template match: ${normalizedMatch.name}');
    }
    return normalizedMatch;
  }

  // STEP 3: Try partial match for common types
  final workoutTypeLower = workoutType.toLowerCase();

  // Map normalized types to common template names
  final typeMapping = {
    'push': ['push', 'chest', 'petto', 'spinta', 'tricep', 'shoulder'],
    'pull': ['pull', 'back', 'schiena', 'tirata', 'bicep', 'dorsal'],
    'legs': ['legs', 'gambe', 'quad', 'glute', 'squat'],
    'upper': ['upper', 'superiore', 'upper body', 'torso'],
    'lower': ['lower', 'inferiore', 'lower body', 'gambe'],
    'full_body': ['full', 'total', 'completo', 'circuit', 'hiit'],
  };

  // Find templates matching the type
  final keywords = typeMapping[workoutTypeLower] ?? [workoutTypeLower];

  for (final template in templates) {
    final templateNameLower = template.name.toLowerCase();
    for (final keyword in keywords) {
      if (templateNameLower.contains(keyword)) {
        if (kDebugMode) {
          debugPrint('✅ Found keyword template match: ${template.name}');
        }
        return template;
      }
    }
  }

  // STEP 4: If no match found, return the first template as fallback
  if (kDebugMode && templates.isNotEmpty) {
    debugPrint('⚠️ No match for "$workoutType", using fallback: ${templates.first.name}');
  }
  return templates.isNotEmpty ? templates.first : null;
}

/// Create a fallback suggestion when no pattern is detected
WorkoutSuggestion _createFallbackSuggestion(String templateName) {
  return WorkoutSuggestion(
    templateName: templateName,
    reason: 'Your most frequent workout', // Will be localized in UI
    confidence: 0.5,
  );
}

/// Provider for localized workout suggestions
final localizedWorkoutSuggestionProvider = Provider.family<WorkoutSuggestion?, WorkoutSuggestion?>(
  (ref, suggestion) {
    if (suggestion == null) return null;
    
    // Note: In a real app, you'd get the BuildContext here to access AppLocalizations
    // For now, we'll return the suggestion as-is since this provider doesn't have access to context
    // The localization will be handled in the UI layer
    return suggestion;
  },
);

class WorkoutSuggestion {

  WorkoutSuggestion({
    required this.templateName,
    required this.reason,
    required this.confidence,
    this.pattern,
    this.daysSinceLastWorkout,
    this.recoveryStatus,
  });
  final String templateName;
  final String reason;
  final double confidence; // 0-1, how confident we are in this suggestion
  final List<String>? pattern;
  final int? daysSinceLastWorkout;
  final RecoveryStatus? recoveryStatus;
  
  /// Shows the detected pattern like "Push → Pull → Legs"
  String get patternDescription {
    if (pattern == null || pattern!.isEmpty) return '';
    return pattern!.join(' → ');
  }
  
  /// Creates a localized version of this suggestion
  // TODO: Implement localization when needed
  WorkoutSuggestion localizeWith(dynamic l10n) {
    String localizedReason;
    
    if (reason.contains('Start new cycle')) {
      localizedReason = l10n.startNewCycle;
    } else if (reason.contains('Continue your routine')) {
      localizedReason = l10n.continueRoutine;
    } else if (reason.contains('Resume after')) {
      final days = daysSinceLastWorkout ?? 0;
      localizedReason = l10n.resumeAfterDays(days);
    } else if (reason.contains('Restart cycle after')) {
      final days = daysSinceLastWorkout ?? 0;
      localizedReason = l10n.restartCycleAfterDays(days);
    } else if (reason.contains('Next in rotation')) {
      localizedReason = l10n.nextInRotation;
    } else if (reason.contains('Your most frequent workout')) {
      localizedReason = l10n.yourMostFrequentWorkout;
    } else {
      localizedReason = reason; // Fallback to original
    }
    
    return WorkoutSuggestion(
      templateName: templateName,
      reason: localizedReason,
      confidence: confidence,
      pattern: pattern,
      daysSinceLastWorkout: daysSinceLastWorkout,
      recoveryStatus: recoveryStatus,
    );
  }
}