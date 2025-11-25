import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/home/data/repositories/insight_feedback_repository.dart';
import 'package:gymbro_flutter_new/features/home/domain/entities/insight_feedback.dart';
import 'package:gymbro_flutter_new/features/home/domain/services/ai_coach_service.dart';
import 'package:gymbro_flutter_new/features/feedback/presentation/providers/unified_feedback_provider.dart';

/// Provider for the Insight Feedback Repository
///
/// ⚠️ MIGRATION: Now uses unified feedback repository as backend
final insightFeedbackRepositoryProvider = Provider<InsightFeedbackRepository>((ref) {
  final unifiedRepository = ref.watch(unifiedFeedbackRepositoryProvider);
  return InsightFeedbackRepository(unifiedRepository: unifiedRepository);
});

/// Provider for feedback state of a specific insight (by hash)
/// Returns null if no feedback exists, InsightFeedback if user has already given feedback
final insightFeedbackProvider =
    FutureProvider.autoDispose.family<InsightFeedback?, String>((ref, insightHash) async {
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUser?.uid;

  if (userId == null) {
    return null;
  }

  final repository = ref.watch(insightFeedbackRepositoryProvider);

  try {
    return await repository.getFeedbackByHash(
      userId: userId,
      insightHash: insightHash,
    );
  } catch (e) {
    // Return null if feedback doesn't exist or error occurs
    return null;
  }
});

/// Provider for all user feedback
final userFeedbackListProvider =
    FutureProvider.autoDispose<List<InsightFeedback>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUser?.uid;

  if (userId == null) {
    return [];
  }

  final repository = ref.watch(insightFeedbackRepositoryProvider);

  try {
    return await repository.getUserFeedback(userId);
  } catch (e) {
    return [];
  }
});

/// Notifier for submitting feedback
class InsightFeedbackNotifier extends StateNotifier<AsyncValue<void>> {

  InsightFeedbackNotifier(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  /// Submit or update feedback for an insight
  Future<void> submitFeedback({
    required AIInsight insight,
    required bool isHelpful,
    String? comment,
  }) async {
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      state = AsyncValue.error(
        Exception('User not authenticated'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      final insightHash = insight.generateHash();
      final repository = ref.read(insightFeedbackRepositoryProvider);

      // Check if feedback already exists
      final existingFeedback = await repository.getFeedbackByHash(
        userId: userId,
        insightHash: insightHash,
      );

      final feedback = InsightFeedback(
        id: existingFeedback?.id ?? '${userId}_$insightHash',
        userId: userId,
        insightType: insight.type.toString(),
        insightHash: insightHash,
        isHelpful: isHelpful,
        comment: comment,
        timestamp: DateTime.now(),
      );

      await repository.saveFeedback(feedback);

      // Invalidate the feedback provider to refresh UI
      ref.invalidate(insightFeedbackProvider(insightHash));

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Delete feedback for an insight
  Future<void> deleteFeedback(String feedbackId, String insightHash) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(insightFeedbackRepositoryProvider);
      await repository.deleteFeedback(feedbackId);

      // Invalidate the feedback provider to refresh UI
      ref.invalidate(insightFeedbackProvider(insightHash));

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// Provider for the feedback notifier
final insightFeedbackNotifierProvider =
    StateNotifierProvider.autoDispose<InsightFeedbackNotifier, AsyncValue<void>>((ref) {
  return InsightFeedbackNotifier(ref);
});

/// Provider for feedback statistics of an insight type (for analytics)
final insightFeedbackStatsProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, insightType) async {
  final repository = ref.watch(insightFeedbackRepositoryProvider);

  try {
    return await repository.getFeedbackStats(insightType);
  } catch (e) {
    return {
      'total': 0,
      'helpful': 0,
      'notHelpful': 0,
      'helpfulPercentage': 0.0,
    };
  }
});

// ========================================
// ADMIN PROVIDERS
// ========================================

/// Provider for all feedback from all users (Admin only)
/// Returns limited number of recent feedback (default: 50)
final adminAllFeedbackProvider =
    FutureProvider.autoDispose.family<List<InsightFeedback>, int?>((ref, limit) async {
  final repository = ref.watch(insightFeedbackRepositoryProvider);

  try {
    return await repository.getAllFeedback(limit: limit ?? 50);
  } catch (e) {
    return [];
  }
});

/// Provider for overall feedback statistics (Admin only)
final adminFeedbackStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(insightFeedbackRepositoryProvider);

  try {
    return await repository.getOverallStats();
  } catch (e) {
    return {
      'totalFeedback': 0,
      'totalHelpful': 0,
      'totalNotHelpful': 0,
      'helpfulPercentage': 0.0,
      'uniqueUsers': 0,
      'byType': <String, dynamic>{},
    };
  }
});
