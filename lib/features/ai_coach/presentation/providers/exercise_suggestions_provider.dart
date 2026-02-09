/// Exercise Suggestions Provider
///
/// Manages smart suggestions state for AI Coach chat.
/// Debounces search requests by 300ms to avoid excessive queries.
///
/// **Layer**: Presentation - Provider
/// **Feature**: AI Coach
library;

import 'dart:async';

import 'package:gymbro_flutter_new/features/ai_coach/data/services/exercise_suggestion_service.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/exercise_suggestion.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'exercise_suggestions_provider.g.dart';

/// Provider for the exercise suggestion service
@riverpod
ExerciseSuggestionService exerciseSuggestionService(Ref ref) {
  final analyticsRepo = ref.watch(analyticsRepositoryProvider);
  return ExerciseSuggestionService(analyticsRepository: analyticsRepo);
}

/// State for exercise suggestions
///
/// **States**:
/// - data (empty list): No suggestions to show
/// - data (non-empty): Suggestions available
/// - loading: Search in progress (not exposed to UI)
/// - error: Search failed (silent, not exposed to UI)
@riverpod
class ExerciseSuggestions extends _$ExerciseSuggestions {
  Timer? _debounceTimer;

  @override
  AsyncValue<List<ExerciseSuggestion>> build() {
    // Cleanup timer on dispose
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    // Initial state: empty list (no suggestions)
    return const AsyncValue.data([]);
  }

  /// Update suggestions with 300ms debounce
  ///
  /// **Behavior**:
  /// - Query < 3 chars: Immediately clears suggestions
  /// - Query >= 3 chars: Waits 300ms, then searches
  /// - Loading/error states are silent (no UI feedback)
  void updateQuery(String query) {
    _debounceTimer?.cancel();

    final trimmed = query.trim();

    // Clear immediately if too short
    if (trimmed.length < 3) {
      state = const AsyncValue.data([]);
      return;
    }

    // Debounce 300ms
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      // Don't show loading state (design requirement: no flickering)

      try {
        final user = ref.read(currentUserProvider).value;
        final userId = user?.uid;

        if (userId == null) {
          state = const AsyncValue.data([]);
          return;
        }

        final service = ref.read(exerciseSuggestionServiceProvider);
        final suggestions = await service.getSuggestions(
          userId: userId,
          query: trimmed,
        );

        state = AsyncValue.data(suggestions);
      } catch (e, st) {
        // Silent error - log but don't expose to UI
        state = AsyncValue.error(e, st);
      }
    });
  }

  /// Clear suggestions
  ///
  /// Call when:
  /// - User selects a suggestion
  /// - User sends a message
  /// - Input loses focus
  void clear() {
    _debounceTimer?.cancel();
    state = const AsyncValue.data([]);
  }
}
