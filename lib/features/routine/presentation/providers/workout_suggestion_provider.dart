/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/providers
/// 🎯 Feature: routine_center
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// WORKOUT SUGGESTION PROVIDER - State management for AI workout suggestions
///
/// Provides:
/// - WorkoutSuggestion prediction using RoutinePredictionEngine
/// - Real-time updates when workout history changes
/// - 5-minute cache refresh
/// - Error handling
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_suggestion.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/routine_prediction_engine.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/pattern_detection_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/pattern_viability_checker.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';

/// Provider for current user ID from Firebase Auth
final _currentUserIdProvider = Provider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid;
});

/// Provider for PatternDetectionService instance
final _patternDetectionServiceProvider = Provider<PatternDetectionService>((ref) {
  return PatternDetectionService();
});

/// Provider for PatternViabilityChecker instance
final _patternViabilityCheckerProvider = Provider<PatternViabilityChecker>((ref) {
  return PatternViabilityChecker();
});

/// Provider for RoutinePredictionEngine instance
final _routinePredictionEngineProvider = Provider<RoutinePredictionEngine>((ref) {
  final patternService = ref.watch(_patternDetectionServiceProvider);
  final viabilityChecker = ref.watch(_patternViabilityCheckerProvider);

  return RoutinePredictionEngine(
    patternService: patternService,
    viabilityChecker: viabilityChecker,
  );
});

/// Provider for workout suggestion (auto-refreshes when history changes)
///
/// Uses RoutinePredictionEngine with 4-level fallback hierarchy:
/// 1. Pattern-Based (highest priority)
/// 2. Routine-Based (active routine template)
/// 3. Frequency-Based (most frequent workout)
/// 4. Day-Based (fallback default)
///
/// Returns: AsyncValue of WorkoutSuggestion
final workoutSuggestionProvider = FutureProvider<WorkoutSuggestion>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);

  if (userId == null) {
    throw Exception('User not authenticated. Please sign in to get workout suggestions.');
  }

  // Get workout repository
  final workoutRepository = ref.watch(workoutRepositoryProvider);

  // Fetch recent workout history (last 50 workouts)
  final workoutsResult = await workoutRepository.getWorkouts(limit: 50);

  final workouts = workoutsResult.fold(
    (failure) => throw Exception('Failed to load workout history: ${failure.message}'),
    (workouts) => workouts,
  );

  // Get active routine template ID (if any)
  final activeRoutineAsync = ref.watch(activeFlexibleRoutineProvider);
  final activeRoutineTemplateId = activeRoutineAsync.maybeWhen(
    data: (routine) => routine?.id,
    orElse: () => null,
  );

  // Get prediction engine
  final predictionEngine = ref.watch(_routinePredictionEngineProvider);

  // Predict next workout
  final suggestion = await predictionEngine.predictNextWorkout(
    workoutHistory: workouts,
    activeRoutineTemplateId: activeRoutineTemplateId,
    useCache: true,
  );

  return suggestion;
});

/// Provider to manually refresh workout suggestion (bypasses cache)
///
/// Use this when user completes a workout or wants fresh prediction.
///
/// Example:
/// ```dart
/// ref.read(refreshWorkoutSuggestionProvider);
/// ```
final refreshWorkoutSuggestionProvider = Provider<void>((ref) {
  final predictionEngine = ref.watch(_routinePredictionEngineProvider);

  // Clear cache to force recalculation
  predictionEngine.clearCache();

  // Invalidate the provider to trigger refresh
  ref.invalidate(workoutSuggestionProvider);
});

/// Provider to check if suggestion is stale (>5 minutes old)
///
/// Returns true if suggestion should be refreshed
final isSuggestionStaleProvider = Provider<bool>((ref) {
  final suggestionAsync = ref.watch(workoutSuggestionProvider);

  return suggestionAsync.maybeWhen(
    data: (suggestion) => suggestion.isStale,
    orElse: () => false,
  );
});
