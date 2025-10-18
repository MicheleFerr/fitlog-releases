/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/providers
/// 🎯 Feature: admin
/// 🔧 Type: provider
///
/// Riverpod providers per gestire il feedback su esercizi
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modello per un singolo feedback su esercizio
class ExerciseFeedback {
  final String id;
  final String userId;
  final String userEmail;
  final String exerciseId;
  final String exerciseName;
  final String version;
  final String feedbackType; // BUG, SUGGESTION, TYPO, OTHER
  final String message;
  final int severity; // 1-5
  final DateTime createdAt;
  final String status; // OPEN, REVIEWING, RESOLVED, DISMISSED
  final String? adminNotes;

  ExerciseFeedback({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.exerciseId,
    required this.exerciseName,
    required this.version,
    required this.feedbackType,
    required this.message,
    required this.severity,
    required this.createdAt,
    required this.status,
    this.adminNotes,
  });

  factory ExerciseFeedback.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return ExerciseFeedback(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      exerciseId: data['exerciseId'] ?? '',
      exerciseName: data['exerciseName'] ?? '',
      version: data['version'] ?? '0.1.0',
      feedbackType: data['feedbackType'] ?? 'OTHER',
      message: data['message'] ?? '',
      severity: data['severity'] ?? 2,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'OPEN',
      adminNotes: data['adminNotes'],
    );
  }
}

/// Statistiche aggregate del feedback
class FeedbackStats {
  final int totalFeedback;
  final int openCount;
  final int reviewingCount;
  final int resolvedCount;
  final Map<String, int> byType; // feedbackType -> count
  final Map<String, int> byExercise; // exerciseId -> count
  final Map<String, int> bySeverity; // severity -> count

  FeedbackStats({
    required this.totalFeedback,
    required this.openCount,
    required this.reviewingCount,
    required this.resolvedCount,
    required this.byType,
    required this.byExercise,
    required this.bySeverity,
  });

  factory FeedbackStats.empty() {
    return FeedbackStats(
      totalFeedback: 0,
      openCount: 0,
      reviewingCount: 0,
      resolvedCount: 0,
      byType: {},
      byExercise: {},
      bySeverity: {},
    );
  }
}

/// 🔴 MASTER STREAM: Single Firestore listener for ALL feedback
/// 🎯 Consolidates 10+ queries into 1 stream → -90% Firestore reads
/// ✅ All derived providers filter from this single source in-memory
final allFeedbackProvider = StreamProvider<List<ExerciseFeedback>>((ref) {
  if (kDebugMode) {
    debugPrint('🔴 allFeedbackProvider: Starting master stream listener');
  }

  return FirebaseFirestore.instance
      .collection('exercise_feedback')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    if (kDebugMode) {
      debugPrint('🔴 allFeedbackProvider: Received snapshot with ${snapshot.docs.length} documents');
    }

    return snapshot.docs
        .map((doc) => ExerciseFeedback.fromFirestore(doc))
        .toList();
  });
});

/// ✅ DERIVED PROVIDER: Filter all feedback in-memory (no Firestore query)
/// Returns aggregated statistics from master stream
final feedbackStatsProvider = Provider<FeedbackStats>((ref) {
  final allFeedbackAsync = ref.watch(allFeedbackProvider);

  return allFeedbackAsync.when(
    data: (allFeedback) {
      if (kDebugMode) {
        debugPrint('📊 feedbackStatsProvider: Computing stats from ${allFeedback.length} feedback items');
      }

      int openCount = 0;
      int reviewingCount = 0;
      int resolvedCount = 0;
      final byType = <String, int>{};
      final byExercise = <String, int>{};
      final bySeverity = <String, int>{};

      // Filter and aggregate in-memory (no Firestore query!)
      for (final feedback in allFeedback) {
        // Conta per status
        switch (feedback.status) {
          case 'OPEN':
            openCount++;
          case 'REVIEWING':
            reviewingCount++;
          case 'RESOLVED':
            resolvedCount++;
        }

        // Conta per tipo
        byType[feedback.feedbackType] = (byType[feedback.feedbackType] ?? 0) + 1;

        // Conta per esercizio
        byExercise[feedback.exerciseId] = (byExercise[feedback.exerciseId] ?? 0) + 1;

        // Conta per severity
        final sevKey = feedback.severity.toString();
        bySeverity[sevKey] = (bySeverity[sevKey] ?? 0) + 1;
      }

      final stats = FeedbackStats(
        totalFeedback: allFeedback.length,
        openCount: openCount,
        reviewingCount: reviewingCount,
        resolvedCount: resolvedCount,
        byType: byType,
        byExercise: byExercise,
        bySeverity: bySeverity,
      );

      if (kDebugMode) {
        debugPrint('📊 feedbackStatsProvider: Stats computed - Total: ${stats.totalFeedback}, Open: ${stats.openCount}, Resolved: ${stats.resolvedCount}');
      }

      return stats;
    },
    loading: () => FeedbackStats.empty(),
    error: (err, stack) {
      if (kDebugMode) {
        debugPrint('❌ feedbackStatsProvider: Error - $err');
      }
      return FeedbackStats.empty();
    },
  );
});

/// ✅ DERIVED PROVIDER: Filter by exercise (no Firestore query)
final exerciseFeedbackProvider =
    Provider.family<List<ExerciseFeedback>, String>((ref, exerciseId) {
  final allFeedbackAsync = ref.watch(allFeedbackProvider);

  return allFeedbackAsync.whenData((allFeedback) {
    return allFeedback
        .where((f) => f.exerciseId == exerciseId)
        .toList();
  }).value ?? [];
});

/// ✅ DERIVED PROVIDER: Filter by status (no Firestore query)
final feedbackByStatusProvider = Provider.family<List<ExerciseFeedback>, String>(
  (ref, status) {
    final allFeedbackAsync = ref.watch(allFeedbackProvider);

    return allFeedbackAsync.whenData((allFeedback) {
      return allFeedback
          .where((f) => f.status == status)
          .toList();
    }).value ?? [];
  },
);

/// ✅ DERIVED PROVIDER: Filter critical feedback (severity >= 4, OPEN status)
/// No Firestore query! Filtered and sorted in-memory
final criticalFeedbackProvider = Provider<List<ExerciseFeedback>>((ref) {
  final allFeedbackAsync = ref.watch(allFeedbackProvider);

  return allFeedbackAsync.whenData((allFeedback) {
    return allFeedback
        .where((f) => f.severity >= 4 && f.status == 'OPEN')
        .toList()
        ..sort((a, b) {
          // Sort by severity descending, then by date descending
          final sevCompare = b.severity.compareTo(a.severity);
          if (sevCompare != 0) return sevCompare;
          return b.createdAt.compareTo(a.createdAt);
        });
  }).value ?? [];
});

/// Provider per aggiornare lo status di un feedback
final updateFeedbackStatusProvider =
    FutureProvider.family<void, (String feedbackId, String newStatus)>(
  (ref, params) async {
    final (feedbackId, newStatus) = params;
    await FirebaseFirestore.instance
        .collection('exercise_feedback')
        .doc(feedbackId)
        .update({
      'status': newStatus,
    });
  },
);

/// Provider per aggiungere note admin a un feedback
final updateFeedbackNotesProvider =
    FutureProvider.family<void, (String feedbackId, String notes)>(
  (ref, params) async {
    final (feedbackId, notes) = params;
    await FirebaseFirestore.instance
        .collection('exercise_feedback')
        .doc(feedbackId)
        .update({
      'adminNotes': notes,
    });
  },
);

/// ✅ DERIVED PROVIDER: Count unread feedback (no Firestore query)
final unreadFeedbackCountProvider = Provider<int>((ref) {
  final allFeedbackAsync = ref.watch(allFeedbackProvider);

  return allFeedbackAsync.whenData((allFeedback) {
    return allFeedback
        .where((f) => f.status == 'OPEN')
        .length;
  }).value ?? 0;
});

/// ✅ DERIVED PROVIDER: Top exercises with most feedback
final topFeedbackExercisesProvider =
    Provider<List<(String exerciseId, int count)>>((ref) {
  final stats = ref.watch(feedbackStatsProvider);

  // Sort by count descending and take top 10
  final sorted = stats.byExercise.entries
      .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

  return sorted.take(10).map((e) => (e.key, e.value)).toList();
});
