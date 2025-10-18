import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/workout_history_repository.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

// Re-export the data classes from workout_history_repository
export 'package:gymbro_flutter_new/features/workout/data/repositories/workout_history_repository.dart' show WorkoutPattern, WorkoutHistoryEntry, TemplateFrequency;

// Workout History Repository provider
final workoutHistoryRepositoryProvider = Provider<WorkoutHistoryRepository>((ref) {
  return WorkoutHistoryRepository();
});

/// Intelligent workout suggestion provider that learns from user's local history
final intelligentWorkoutSuggestionProvider = FutureProvider<WorkoutSuggestion?>((ref) async {
  final historyRepository = ref.read(workoutHistoryRepositoryProvider);
  
  try {
    // Get recent workout history from local storage
    final recentWorkouts = await historyRepository.getRecentWorkouts(days: 30);
    
    if (recentWorkouts.isEmpty) {
      return null; // No history, can't make intelligent suggestion
    }
    
    // Get detected pattern from repository
    final detectedPattern = await historyRepository.getDetectedPattern();
    
    if (detectedPattern != null) {
      return _getNextWorkoutFromPattern(detectedPattern);
    }
    
    // Fallback: suggest most frequent workout
    return _getFallbackSuggestion(recentWorkouts);
    
  } catch (e) {
    print('Error getting intelligent suggestion: $e');
    return null;
  }
});

/// Generate next workout suggestion from detected pattern
WorkoutSuggestion _getNextWorkoutFromPattern(WorkoutPattern pattern) {
  if (pattern.rotation.isEmpty) {
    return _createFallbackSuggestion(pattern.frequentTemplates.first.name);
  }
  
  // Find last workout in rotation
  final lastWorkoutIndex = pattern.rotation.indexOf(pattern.lastWorkout.templateName);
  
  if (lastWorkoutIndex == -1) {
    // Last workout not in rotation, suggest first of rotation
    return WorkoutSuggestion(
      templateName: pattern.rotation.first,
      reason: 'Start new cycle', // Will be localized in UI
      confidence: 0.7,
      pattern: pattern.rotation,
    );
  }
  
  // Get next in rotation
  final nextIndex = (lastWorkoutIndex + 1) % pattern.rotation.length;
  final nextTemplate = pattern.rotation[nextIndex];
  
  // Calculate days since last workout
  final daysSinceLastWorkout = DateTime.now()
      .difference(pattern.lastWorkout.completedAt)
      .inDays;
  
  String reason;
  double confidence = pattern.confidence;
  
  if (daysSinceLastWorkout == 0) {
    reason = 'Next in rotation';
    confidence = 0.8;
  } else if (daysSinceLastWorkout == 1) {
    reason = 'Continue your routine';
    confidence = 0.9;
  } else if (daysSinceLastWorkout <= 3) {
    reason = 'Resume after $daysSinceLastWorkout days';
    confidence = 0.85;
  } else {
    reason = 'Restart cycle after $daysSinceLastWorkout days';
    confidence = 0.6;
  }
  
  return WorkoutSuggestion(
    templateName: nextTemplate,
    reason: reason,
    confidence: confidence,
    pattern: pattern.rotation,
    daysSinceLastWorkout: daysSinceLastWorkout,
  );
}

/// Fallback suggestion based on workout history
WorkoutSuggestion _getFallbackSuggestion(List<WorkoutHistoryEntry> recentWorkouts) {
  // Count frequency of templates
  final templateFrequency = <String, int>{};
  for (var workout in recentWorkouts) {
    templateFrequency[workout.templateName] = 
        (templateFrequency[workout.templateName] ?? 0) + 1;
  }
  
  // Get most frequent template
  final mostFrequentTemplate = templateFrequency.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;
  
  return _createFallbackSuggestion(mostFrequentTemplate);
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
  final String templateName;
  final String reason;
  final double confidence; // 0-1, how confident we are in this suggestion
  final List<String>? pattern;
  final int? daysSinceLastWorkout;
  
  WorkoutSuggestion({
    required this.templateName,
    required this.reason,
    required this.confidence,
    this.pattern,
    this.daysSinceLastWorkout,
  });
  
  /// Shows the detected pattern like "Push → Pull → Legs"
  String get patternDescription {
    if (pattern == null || pattern!.isEmpty) return '';
    return pattern!.join(' → ');
  }
  
  /// Creates a localized version of this suggestion
  WorkoutSuggestion localizeWith(AppLocalizations l10n) {
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
    );
  }
}