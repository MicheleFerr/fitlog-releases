/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/providers
/// 🎯 Feature: ai_coach
/// 🔧 Type: provider
///
/// Feedback Provider - Manages feedback state and submission
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/repositories/feedback_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/feedback_data.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/feedback/presentation/providers/unified_feedback_provider.dart';
import 'package:uuid/uuid.dart';

/// Feedback State
class FeedbackState {
  const FeedbackState({
    required this.userFeedbackHistory,
    required this.suppressedInsightTypes,
    this.isSubmitting = false,
    this.lastError,
  });

  final List<FeedbackData> userFeedbackHistory;
  final Set<String> suppressedInsightTypes;
  final bool isSubmitting;
  final String? lastError;

  FeedbackState copyWith({
    List<FeedbackData>? userFeedbackHistory,
    Set<String>? suppressedInsightTypes,
    bool? isSubmitting,
    String? lastError,
  }) {
    return FeedbackState(
      userFeedbackHistory: userFeedbackHistory ?? this.userFeedbackHistory,
      suppressedInsightTypes:
          suppressedInsightTypes ?? this.suppressedInsightTypes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      lastError: lastError ?? this.lastError,
    );
  }
}

/// Feedback Notifier
///
/// Manages:
/// - Submitting feedback on insights
/// - Tracking user feedback history
/// - Managing suppressed insight types
/// - Calculating insight effectiveness
class FeedbackNotifier extends AsyncNotifier<FeedbackState> {
  late final FeedbackRepository _repository;
  final _uuid = const Uuid();

  String get _userId => ref.read(currentUserIdProvider) ?? 'anonymous';

  @override
  Future<FeedbackState> build() async {
    _repository = ref.read(feedbackRepositoryProvider);
    return await _initialize();
  }

  /// Initialize feedback state
  Future<FeedbackState> _initialize() async {
    final history = await _repository.getUserFeedbackHistory(_userId);

    // Load suppressed insight types
    final suppressedTypes = <String>{};
    // TODO: Load from storage or calculate from stats

    return FeedbackState(
      userFeedbackHistory: history,
      suppressedInsightTypes: suppressedTypes,
    );
  }

  /// Submit helpful feedback
  ///
  /// User found insight useful and actionable
  Future<void> markAsHelpful({
    required String insightId,
    required String insightType,
    required String insightCategory,
    int viewDurationSeconds = 0,
  }) async {
    await _submitFeedback(
      insightId: insightId,
      insightType: insightType,
      insightCategory: insightCategory,
      feedbackType: FeedbackType.helpful,
      viewDurationSeconds: viewDurationSeconds,
    );
  }

  /// Submit not helpful feedback
  ///
  /// User dismissed insight as not useful
  Future<void> markAsNotHelpful({
    required String insightId,
    required String insightType,
    required String insightCategory,
    DismissReason? reason,
    String? comment,
    int viewDurationSeconds = 0,
  }) async {
    await _submitFeedback(
      insightId: insightId,
      insightType: insightType,
      insightCategory: insightCategory,
      feedbackType: FeedbackType.notHelpful,
      dismissReason: reason,
      comment: comment,
      viewDurationSeconds: viewDurationSeconds,
    );
  }

  /// Submit dismissed feedback (neutral)
  ///
  /// User dismissed insight without explicit feedback
  Future<void> markAsDismissed({
    required String insightId,
    required String insightType,
    required String insightCategory,
    int viewDurationSeconds = 0,
  }) async {
    await _submitFeedback(
      insightId: insightId,
      insightType: insightType,
      insightCategory: insightCategory,
      feedbackType: FeedbackType.dismissed,
      viewDurationSeconds: viewDurationSeconds,
    );
  }

  /// Submit acted upon feedback
  ///
  /// User acted on insight (implicit positive feedback)
  Future<void> markAsActedUpon({
    required String insightId,
    required String insightType,
    required String insightCategory,
    int viewDurationSeconds = 0,
  }) async {
    await _submitFeedback(
      insightId: insightId,
      insightType: insightType,
      insightCategory: insightCategory,
      feedbackType: FeedbackType.actedUpon,
      viewDurationSeconds: viewDurationSeconds,
    );
  }

  /// Submit feedback to repository
  Future<void> _submitFeedback({
    required String insightId,
    required String insightType,
    required String insightCategory,
    required FeedbackType feedbackType,
    DismissReason? dismissReason,
    String? comment,
    int viewDurationSeconds = 0,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      // Set submitting state
      state = AsyncValue.data(
        currentState.copyWith(isSubmitting: true),
      );

      final feedback = FeedbackData(
        id: _uuid.v4(),
        userId: _userId,
        insightId: insightId,
        insightType: insightType,
        insightCategory: insightCategory,
        feedbackType: feedbackType,
        dismissReason: dismissReason,
        comment: comment,
        timestamp: DateTime.now(),
        viewDurationSeconds: viewDurationSeconds,
      );

      await _repository.submitFeedback(feedback);

      // Add to history
      final updatedHistory = [
        feedback,
        ...currentState.userFeedbackHistory,
      ];

      // Check if insight type should be suppressed
      final shouldSuppress =
          await _repository.shouldSuppressInsightType(insightType);

      final updatedSuppressed = Set<String>.from(
        currentState.suppressedInsightTypes,
      );

      if (shouldSuppress) {
        updatedSuppressed.add(insightType);
      }

      state = AsyncValue.data(
        FeedbackState(
          userFeedbackHistory: updatedHistory,
          suppressedInsightTypes: updatedSuppressed,
          isSubmitting: false,
        ),
      );
    } catch (error, _) {
      state = AsyncValue.data(
        currentState.copyWith(
          isSubmitting: false,
          lastError: error.toString(),
        ),
      );
    }
  }

  /// Get feedback statistics for insight type
  Future<FeedbackStats> getStatsForInsightType(String insightType) async {
    return _repository.getStatsForInsightType(insightType);
  }

  /// Get feedback statistics for category
  Future<FeedbackStats> getStatsForCategory(String category) async {
    return _repository.getStatsForCategory(category);
  }

  /// Check if insight type is suppressed
  bool isInsightTypeSuppressed(String insightType) {
    final currentState = state.value;
    if (currentState == null) return false;

    return currentState.suppressedInsightTypes.contains(insightType);
  }

  /// Get most common dismiss reason for insight type
  Future<DismissReason?> getMostCommonDismissReason(String insightType) async {
    return _repository.getMostCommonDismissReason(insightType);
  }

  /// Refresh feedback state
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Provider: Feedback Repository
final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  // Inject unified repository for Firestore persistence
  final unifiedRepository = ref.watch(unifiedFeedbackRepositoryProvider);
  return FeedbackRepository(unifiedRepository);
});

/// Provider: Feedback Notifier
///
/// Requires user ID from auth provider
final feedbackProvider =
    AsyncNotifierProvider<FeedbackNotifier, FeedbackState>(
  FeedbackNotifier.new,
);

/// Provider: Is Insight Type Suppressed
///
/// Check if specific insight type should be suppressed
final isInsightTypeSuppressedProvider =
    Provider.family<bool, String>((ref, insightType) {
  ref.watch(feedbackProvider);
  final notifier = ref.read(feedbackProvider.notifier);

  return notifier.isInsightTypeSuppressed(insightType);
});

/// Provider: Feedback Stats for Insight Type
///
/// Get statistics for specific insight type
final feedbackStatsForInsightTypeProvider =
    FutureProvider.family<FeedbackStats, String>((ref, insightType) async {
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.getStatsForInsightType(insightType);
});

/// Provider: User Feedback History
///
/// Get user's recent feedback
final userFeedbackHistoryProvider = Provider<List<FeedbackData>>((ref) {
  final feedbackState = ref.watch(feedbackProvider);
  return feedbackState.value?.userFeedbackHistory ?? [];
});
