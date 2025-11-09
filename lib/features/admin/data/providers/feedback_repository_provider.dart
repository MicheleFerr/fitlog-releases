/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/data/providers
/// 🎯 Feature: admin
/// 🔧 Type: provider
///
/// Riverpod provider for dependency injection of FeedbackRepository
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/admin/data/repositories/feedback_repository.dart';

/// 🔌 Dependency Injection: FeedbackRepository Provider
/// 💡 Use this instead of creating FirestoreFeedbackRepository directly
/// 🧪 Easy to mock in tests with ref.watch override
final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FirestoreFeedbackRepository(
    firestore: FirebaseFirestore.instance,
  );
});

/// Master stream of ALL feedback (used by all other providers)
final allFeedbackProvider = StreamProvider<List<ExerciseFeedback>>((ref) {
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.watchAllFeedback();
});

/// Stream of feedback by exercise ID
final feedbackByExerciseProvider =
    StreamProvider.family<List<ExerciseFeedback>, String>((ref, exerciseId) {
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.watchFeedbackByExercise(exerciseId);
});

/// Stream of feedback by status
final feedbackByStatusProvider =
    StreamProvider.family<List<ExerciseFeedback>, String>((ref, status) {
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.watchFeedbackByStatus(status);
});

/// Stream of critical feedback (severity >= 4, status = OPEN)
final criticalFeedbackProvider = StreamProvider<List<ExerciseFeedback>>((ref) {
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.watchCriticalFeedback();
});

/// Get single feedback by ID (one-time read)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final feedbackByIdProvider =
    FutureProvider.autoDispose.family<ExerciseFeedback?, String>((ref, feedbackId) async {
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.getFeedbackById(feedbackId);
});

/// Create new feedback
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final createFeedbackProvider =
    FutureProvider.autoDispose.family<String, ExerciseFeedback>((ref, feedback) async {
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.createFeedback(feedback);
});

/// Update feedback status (admin only)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final updateFeedbackStatusProvider = FutureProvider.autoDispose.family<void,
    (String feedbackId, String newStatus)>((ref, params) async {
  final (feedbackId, newStatus) = params;
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.updateFeedbackStatus(feedbackId, newStatus);
});

/// Update admin notes (admin only)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final updateAdminNotesProvider =
    FutureProvider.autoDispose.family<void, (String feedbackId, String notes)>((ref, params) async {
  final (feedbackId, notes) = params;
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.updateAdminNotes(feedbackId, notes);
});

/// Update feedback severity (admin only)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final updateFeedbackSeverityProvider = FutureProvider.autoDispose.family<void,
    (String feedbackId, int severity)>((ref, params) async {
  final (feedbackId, severity) = params;
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.updateFeedbackSeverity(feedbackId, severity);
});

/// Delete feedback (admin only)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final deleteFeedbackProvider =
    FutureProvider.autoDispose.family<void, String>((ref, feedbackId) async {
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.deleteFeedback(feedbackId);
});

/// Count statistics providers
final feedbackCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.countTotalFeedback();
});

final feedbackCountByStatusProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.countByStatus();
});

final feedbackCountByTypeProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.countByType();
});

final feedbackCountBySeverityProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.countBySeverity();
});
