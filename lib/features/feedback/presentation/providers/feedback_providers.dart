/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/feedback/presentation/providers
/// 🎯 Feature: user_feedback
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// FEEDBACK PROVIDERS - Riverpod providers for feedback system
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/entities/user_feedback.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:gymbro_flutter_new/features/feedback/data/repositories/firebase_feedback_repository.dart';

/// Provider for FeedbackRepository instance
final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FirebaseFeedbackRepository();
});

/// Provider for current user ID
final _currentUserIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

/// Stream provider for all feedback (admin only)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically cancels Firestore listener when widget is disposed
final allFeedbackProvider = StreamProvider.autoDispose<List<UserFeedback>>((ref) {
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.watchAllFeedback();
});

/// Stream provider for new feedback count (admin only)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically cancels Firestore listener when widget is disposed
final newFeedbackCountProvider = StreamProvider.autoDispose<int>((ref) {
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.watchNewFeedbackCount();
});

/// Future provider for feedback statistics (admin only)
final feedbackStatisticsProvider = FutureProvider((ref) {
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.getFeedbackStatistics();
});

/// Future provider for user's own feedback
final userFeedbackProvider = FutureProvider<List<UserFeedback>>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return [];

  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.getUserFeedback(userId);
});

/// Notifier for feedback submission
class FeedbackNotifier extends StateNotifier<AsyncValue<void>> {

  FeedbackNotifier(this._repository) : super(const AsyncValue.data(null));
  final FeedbackRepository _repository;

  /// Submit new feedback
  Future<bool> submitFeedback(UserFeedback feedback) async {
    state = const AsyncValue.loading();
    try {
      await _repository.submitFeedback(feedback);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

/// Provider for FeedbackNotifier
final feedbackNotifierProvider =
    StateNotifierProvider<FeedbackNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(feedbackRepositoryProvider);
  return FeedbackNotifier(repository);
});
