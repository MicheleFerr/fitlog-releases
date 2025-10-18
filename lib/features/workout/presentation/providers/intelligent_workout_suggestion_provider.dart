import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';

/// Intelligent workout suggestion provider that learns from user's local history
final intelligentWorkoutSuggestionProvider = FutureProvider<WorkoutSuggestion?>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return null;

  final hiveDataSource = ref.read(hiveWorkoutDataSourceProvider);

  try {
    // Get recent workout history from local storage (last 30 days)
    final DateTime cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    final recentWorkouts = await hiveDataSource.getWorkouts(
      userId,
      limit: 50,
      startDate: cutoffDate,
    );

    if (recentWorkouts.isEmpty) {
      return null; // No history, can't make intelligent suggestion
    }

    // Simple suggestion based on most frequent workout
    return _getFallbackSuggestion(recentWorkouts);

  } catch (e) {
    debugPrint('Error getting intelligent suggestion: $e');
    return null;
  }
});


/// Fallback suggestion based on workout history
WorkoutSuggestion _getFallbackSuggestion(List<WorkoutModel> recentWorkouts) {
  // Count frequency of workout names
  final templateFrequency = <String, int>{};
  for (var workout in recentWorkouts) {
    final templateName = workout.name ?? 'Unknown Workout';
    templateFrequency[templateName] = (templateFrequency[templateName] ?? 0) + 1;
  }

  if (templateFrequency.isEmpty) {
    return _createFallbackSuggestion('Quick Workout');
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
  
  WorkoutSuggestion({
    required this.templateName,
    required this.reason,
    required this.confidence,
    this.pattern,
    this.daysSinceLastWorkout,
  });
  final String templateName;
  final String reason;
  final double confidence; // 0-1, how confident we are in this suggestion
  final List<String>? pattern;
  final int? daysSinceLastWorkout;
  
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
    );
  }
}