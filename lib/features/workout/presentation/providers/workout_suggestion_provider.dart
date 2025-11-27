/// 🏋️‍♂️ GymBro TrackLog - Smart Workout Suggestion Provider
///
/// 📁 Layer: features/workout/presentation/providers
/// 🎯 Feature: Smart Workout Suggestion
/// 🔧 Type: provider
///
/// Provider per lo stato della Smart Workout Suggestion
/// Combina service + history + templates per generare SuggestionState
///
/// Reference: Design doc 2025-01-25-smart-workout-suggestion-design.md
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/suggestion_feedback.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/suggestion_state.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_suggestion_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';

/// Service provider (singleton)
final workoutSuggestionServiceProvider = Provider<WorkoutSuggestionService>((ref) {
  return WorkoutSuggestionService();
});

/// Tracks if suggestion provider has logged this session (avoid spam)
bool _suggestionLoggedOnce = false;

/// Main suggestion state provider
///
/// Returns [SuggestionState] based on:
/// - Today's workout status (REST_MODE if already worked out)
/// - Workout history count (INSUFFICIENT_DATA if <3)
/// - Muscle readiness + antagonist conflicts (READY or WARNING)
///
/// Uses autoDispose to properly clean up resources when not in use.
final workoutSuggestionProvider = FutureProvider.autoDispose<SuggestionState>((ref) async {
  // Log only once per session to avoid spam
  if (kDebugMode && !_suggestionLoggedOnce) {
    _suggestionLoggedOnce = true;
    debugPrint('🎯 [SUGGESTION_PROVIDER] Initializing...');
  }

  // Get service
  final service = ref.read(workoutSuggestionServiceProvider);

  // Watch today's completed workout
  final todayWorkoutAsync = ref.watch(todayCompletedWorkoutProvider);

  // Watch workout history
  final historyState = ref.watch(workoutHistoryProvider);

  // Watch available templates
  final templatesAsync = ref.watch(allWorkoutTemplatesProvider);

  // Watch feedback history (if implemented)
  final feedbackHistory = ref.watch(suggestionFeedbackHistoryProvider);

  // Handle loading states
  if (todayWorkoutAsync.isLoading || templatesAsync.isLoading || historyState.isLoading) {
    return const SuggestionLoading();
  }

  // Handle errors
  if (todayWorkoutAsync.hasError) {
    return SuggestionError(
      message: 'Failed to check today\'s workout',
      error: todayWorkoutAsync.error,
    );
  }

  if (templatesAsync.hasError) {
    return SuggestionError(
      message: 'Failed to load templates',
      error: templatesAsync.error,
    );
  }

  if (historyState.hasError) {
    return SuggestionError(
      message: 'Failed to load workout history',
      error: historyState.error,
    );
  }

  // Get resolved values
  final todayWorkout = todayWorkoutAsync.valueOrNull;
  final templates = templatesAsync.valueOrNull ?? [];
  final workoutHistory = historyState.valueOrNull ?? [];

  // Generate suggestion state
  return service.generateSuggestion(
    workoutHistory: workoutHistory,
    availableTemplates: templates,
    todayWorkout: todayWorkout,
    feedbackHistory: feedbackHistory,
  );
});

/// Notifier for managing suggestion feedback
class SuggestionFeedbackNotifier extends Notifier<List<SuggestionFeedback>> {
  @override
  List<SuggestionFeedback> build() => [];

  /// Record that user accepted a suggestion
  Future<void> recordAcceptance({
    required String templateSuggested,
    String? muscleGroupAffected,
    double? confidenceAtSuggestion,
  }) async {
    final userId = ref.read(firebaseUserProvider).valueOrNull?.uid;
    if (userId == null) return;

    final feedback = SuggestionFeedback.accepted(
      id: const Uuid().v4(),
      userId: userId,
      templateSuggested: templateSuggested,
      muscleGroupAffected: muscleGroupAffected,
      confidenceAtSuggestion: confidenceAtSuggestion,
    );

    state = [...state, feedback];

    if (kDebugMode) {
      debugPrint('✅ [FEEDBACK] Recorded acceptance: ${feedback.templateSuggested}');
    }

    // TODO: Persist to Firebase/local storage
  }

  /// Record that user rejected a suggestion with reason
  Future<void> recordRejection({
    required String templateSuggested,
    required RejectionReason reason,
    String? customReason,
    String? templateChosen,
    String? muscleGroupAffected,
    double? confidenceAtSuggestion,
  }) async {
    final userId = ref.read(firebaseUserProvider).valueOrNull?.uid;
    if (userId == null) return;

    final feedback = SuggestionFeedback.rejected(
      id: const Uuid().v4(),
      userId: userId,
      templateSuggested: templateSuggested,
      reason: reason,
      customReason: customReason,
      templateChosen: templateChosen,
      muscleGroupAffected: muscleGroupAffected,
      confidenceAtSuggestion: confidenceAtSuggestion,
    );

    state = [...state, feedback];

    if (kDebugMode) {
      debugPrint('❌ [FEEDBACK] Recorded rejection: ${feedback.templateSuggested}');
      debugPrint('   Reason: ${reason.name}');
      if (customReason != null) debugPrint('   Custom: $customReason');
    }

    // Clear service cache to force recalculation with penalty
    ref.read(workoutSuggestionServiceProvider).clearCache();

    // Invalidate suggestion provider to trigger refresh
    ref.invalidate(workoutSuggestionProvider);

    // TODO: Persist to Firebase/local storage
  }

  /// Clear all feedback (for testing/reset)
  void clear() {
    state = [];
  }

  /// Get recent feedback (last 7 days)
  List<SuggestionFeedback> get recentFeedback {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return state.where((f) => f.timestamp.isAfter(cutoff)).toList();
  }
}

/// Provider for feedback notifier
final suggestionFeedbackNotifierProvider =
    NotifierProvider<SuggestionFeedbackNotifier, List<SuggestionFeedback>>(SuggestionFeedbackNotifier.new);

/// Convenience provider for feedback history (read-only)
final suggestionFeedbackHistoryProvider = Provider<List<SuggestionFeedback>>((ref) {
  return ref.watch(suggestionFeedbackNotifierProvider);
});

/// Provider to check if suggestions are available
/// (enough data + templates exist)
final suggestionAvailableProvider = Provider<bool>((ref) {
  final stateAsync = ref.watch(workoutSuggestionProvider);

  return stateAsync.maybeWhen(
    data: (state) => state.isReady || state.isWarning,
    orElse: () => false,
  );
});

/// Provider for quick check if user worked out today
final hasWorkedOutTodayProvider = Provider<bool>((ref) {
  final stateAsync = ref.watch(workoutSuggestionProvider);

  return stateAsync.maybeWhen(
    data: (state) => state.isRestMode,
    orElse: () => false,
  );
});

/// Provider for the suggested template name (if available)
final suggestedTemplateNameProvider = Provider<String?>((ref) {
  final stateAsync = ref.watch(workoutSuggestionProvider);

  return stateAsync.maybeWhen(
    data: (state) => state.suggestionOrNull?.workoutName,
    orElse: () => null,
  );
});

/// Provider for the suggestion confidence (if available)
final suggestionConfidenceProvider = Provider<double?>((ref) {
  final stateAsync = ref.watch(workoutSuggestionProvider);

  return stateAsync.maybeWhen(
    data: (state) => state.suggestionOrNull?.confidence,
    orElse: () => null,
  );
});
