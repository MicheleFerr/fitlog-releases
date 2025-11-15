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

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_suggestion.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/routine_prediction_engine.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';

/// Provider for current user ID from Firebase Auth
final _currentUserIdProvider = Provider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid;
});

/// Provider for RoutinePredictionEngine instance (simplified - no dependencies)
final _routinePredictionEngineProvider = Provider<RoutinePredictionEngine>((ref) {
  return RoutinePredictionEngine();
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
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final workoutSuggestionProvider = FutureProvider.autoDispose<WorkoutSuggestion>((ref) async {
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

  if (kDebugMode || kProfileMode) {
    debugPrint('🔍 [WORKOUT_SUGGESTION] Loaded ${workouts.length} workouts from history');
    if (workouts.isNotEmpty) {
      final recentWorkoutNames = workouts.take(5).map((w) => w.name).toList();
      debugPrint('🔍 [WORKOUT_SUGGESTION] Recent 5 workout names: $recentWorkoutNames');
    }
  }

  // Get active routine (FlexibleRoutine object)
  final activeRoutineAsync = ref.watch(activeFlexibleRoutineProvider);
  final activeRoutine = activeRoutineAsync.maybeWhen(
    data: (routine) => routine,
    orElse: () => null,
  );

  if (kDebugMode || kProfileMode) {
    debugPrint('🔍 [WORKOUT_SUGGESTION] Active routine: ${activeRoutine?.name ?? 'None'}');
    if (activeRoutine != null) {
      debugPrint('🔍 [WORKOUT_SUGGESTION] Routine pattern: ${activeRoutine.pattern.type}, sequence: ${activeRoutine.pattern.sequence}');
    }
  }

  // Get available template names for validation
  // NOTE: Using customWorkoutTemplatesProvider (combines legacy + unified)
  // instead of allWorkoutTemplatesProvider (legacy only, returns empty)
  // 🔧 FIX: Await template provider to ensure we have loaded templates
  // BEFORE predicting workout. This prevents validation from being skipped
  // when template list is empty due to loading/error state.
  List<dynamic> templates = [];
  List<String> availableTemplateNames = [];

  try {
    templates = await ref.watch(customWorkoutTemplatesProvider.future);
    availableTemplateNames = templates.map((t) => t.name?.toString() ?? '').where((name) => name.isNotEmpty).toList();

    if (kDebugMode || kProfileMode) {
      debugPrint('🔍 [WORKOUT_SUGGESTION] Successfully loaded ${templates.length} templates');
      debugPrint('🔍 [WORKOUT_SUGGESTION] Available template names: $availableTemplateNames');
      debugPrint('🔍 [WORKOUT_SUGGESTION] Template count: ${availableTemplateNames.length}');
    }
  } catch (e) {
    if (kDebugMode || kProfileMode) {
      debugPrint('❌ [WORKOUT_SUGGESTION] Error loading templates: $e');
    }
    // Continue with empty templates list, will fallback to other prediction methods
  }

  // Get prediction engine
  final predictionEngine = ref.watch(_routinePredictionEngineProvider);

  // Predict next workout using simplified 2-level fallback
  final suggestion = await predictionEngine.predictNextWorkout(
    workoutHistory: workouts,
    activeRoutine: activeRoutine, // ✅ SIMPLIFIED: Pass FlexibleRoutine object
    availableTemplateNames: availableTemplateNames,
    availableTemplates: templates, // For template ID→Name mapping
    useCache: true,
  );

  if (kDebugMode || kProfileMode) {
    debugPrint('🔍 [WORKOUT_SUGGESTION] Generated suggestion: ${suggestion.workoutName}');
    debugPrint('🔍 [WORKOUT_SUGGESTION] Suggestion level: ${suggestion.level}');
    debugPrint('🔍 [WORKOUT_SUGGESTION] Confidence: ${suggestion.confidence}');
    debugPrint('🔍 [WORKOUT_SUGGESTION] Reason: ${suggestion.reason}');
  }

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

/// ✅ NEW: Provider to check if today's workout is already completed
///
/// Returns completion info if workout is completed today, null otherwise.
/// Checks the active routine's schedule for today's completion status.
///
/// Returns: {completedAt: DateTime} or null
final todayCompletionStatusProvider =
    Provider<Map<String, dynamic>?>((ref) {
  final activeRoutineAsync = ref.watch(activeFlexibleRoutineProvider);

  return activeRoutineAsync.maybeWhen(
    data: (routine) {
      if (routine == null) return null;

      // ✅ FIX Bug #37: Get today's date (local normalized) per consistency con entity _dateKey()
      // Normalizza a mezzanotte locale (stesso formato di flexible_routine.dart)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Check if today's workout is completed
      final todayDay = routine.schedule[todayKey];
      if (todayDay == null) return null;

      if (todayDay.status != DayStatus.completed) {
        return null;
      }

      // Return completion info
      return {
        'completedAt': DateTime.now(),
        'templateId': todayDay.templateId,
        'workoutId': todayDay.workoutId, // ✅ ADD: workoutId for navigation
        'isRecovery': todayDay.isRecovery ?? false,
      };
    },
    orElse: () => null,
  );
});
