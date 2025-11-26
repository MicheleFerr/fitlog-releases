import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/providers/firebase_providers.dart';

/// Exercise review report model
class ExerciseReviewReport {

  ExerciseReviewReport({
    required this.id,
    required this.reportDate,
    required this.period,
    required this.statistics,
    required this.recommendations,
    required this.staleExercises,
    required this.flaggedExercises,
    required this.status,
    required this.createdAt,
  });

  /// Create from Firestore document
  factory ExerciseReviewReport.fromFirestore(Map<String, dynamic> data) {
    return ExerciseReviewReport(
      id: data['id'] as String? ?? 'unknown',
      reportDate: (data['reportDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      period: data['period'] as String? ?? 'unknown',
      statistics: ReviewStatistics.fromMap(
        data['statistics'] as Map<String, dynamic>? ?? {},
      ),
      recommendations:
          (data['recommendations'] as List?)?.cast<String>() ?? [],
      staleExercises: (data['staleExercises'] as List?)
              ?.map((e) => StaleExercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      flaggedExercises: (data['flaggedExercises'] as List?)
              ?.map((e) => FlaggedExercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: data['status'] as String? ?? 'unknown',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  final String id;
  final DateTime reportDate;
  final String period;
  final ReviewStatistics statistics;
  final List<String> recommendations;
  final List<StaleExercise> staleExercises;
  final List<FlaggedExercise> flaggedExercises;
  final String status;
  final DateTime createdAt;

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reportDate': reportDate,
      'period': period,
      'statistics': statistics.toMap(),
      'recommendations': recommendations,
      'staleExercises': staleExercises.map((e) => e.toMap()).toList(),
      'flaggedExercises': flaggedExercises.map((e) => e.toMap()).toList(),
      'status': status,
      'createdAt': createdAt,
    };
  }
}

/// Statistics from review report
class ReviewStatistics {

  ReviewStatistics({
    required this.staleExercisesCount,
    required this.flaggedExercisesCount,
    required this.totalFeedbackFlagged,
    required this.criticalIssuesCount,
  });

  /// Create from map
  factory ReviewStatistics.fromMap(Map<String, dynamic> data) {
    return ReviewStatistics(
      staleExercisesCount: (data['staleExercisesCount'] as num?)?.toInt() ?? 0,
      flaggedExercisesCount:
          (data['flaggedExercisesCount'] as num?)?.toInt() ?? 0,
      totalFeedbackFlagged:
          (data['totalFeedbackFlagged'] as num?)?.toInt() ?? 0,
      criticalIssuesCount: (data['criticalIssuesCount'] as num?)?.toInt() ?? 0,
    );
  }
  final int staleExercisesCount;
  final int flaggedExercisesCount;
  final int totalFeedbackFlagged;
  final int criticalIssuesCount;

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'staleExercisesCount': staleExercisesCount,
      'flaggedExercisesCount': flaggedExercisesCount,
      'totalFeedbackFlagged': totalFeedbackFlagged,
      'criticalIssuesCount': criticalIssuesCount,
    };
  }
}

/// Stale exercise in report
class StaleExercise {

  StaleExercise({
    required this.id,
    required this.nome,
    required this.lastModified,
    required this.lastModifiedDaysAgo,
  });

  /// Create from map
  factory StaleExercise.fromMap(Map<String, dynamic> data) {
    return StaleExercise(
      id: data['id'] as String? ?? 'unknown',
      nome: data['nome'] as String? ?? 'Unknown',
      lastModified:
          (data['lastModified'] as Timestamp?)?.toDate(),
      lastModifiedDaysAgo: (data['lastModifiedDaysAgo'] as num?)?.toInt() ?? 0,
    );
  }
  final String id;
  final String nome;
  final DateTime? lastModified;
  final int lastModifiedDaysAgo;

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'lastModified': lastModified,
      'lastModifiedDaysAgo': lastModifiedDaysAgo,
    };
  }
}

/// Flagged exercise in report
class FlaggedExercise {

  FlaggedExercise({
    required this.id,
    required this.nome,
    required this.feedbackCount,
    required this.criticalCount,
    required this.mostRecentFeedback,
  });

  /// Create from map
  factory FlaggedExercise.fromMap(Map<String, dynamic> data) {
    return FlaggedExercise(
      id: data['id'] as String? ?? 'unknown',
      nome: data['nome'] as String? ?? 'Unknown',
      feedbackCount: (data['feedbackCount'] as num?)?.toInt() ?? 0,
      criticalCount: (data['criticalCount'] as num?)?.toInt() ?? 0,
      mostRecentFeedback:
          (data['mostRecentFeedback'] as Timestamp?)?.toDate(),
    );
  }
  final String id;
  final String nome;
  final int feedbackCount;
  final int criticalCount;
  final DateTime? mostRecentFeedback;

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'feedbackCount': feedbackCount,
      'criticalCount': criticalCount,
      'mostRecentFeedback': mostRecentFeedback,
    };
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================
// NOTE: firestoreProvider is now in core/providers/firebase_providers.dart (canonical)

/// Provider to get latest review report (real-time stream)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final latestReviewProvider = StreamProvider.autoDispose<Map<String, dynamic>?>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('admin_reports')
      .orderBy('reportDate', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;
        return snapshot.docs.first.data();
      });
});

/// Provider to get all review reports
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final allReviewsProvider = StreamProvider.autoDispose<List<ExerciseReviewReport>>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('admin_reports')
      .orderBy('reportDate', descending: true)
      .limit(12) // Last 12 months
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => ExerciseReviewReport.fromFirestore(doc.data()))
            .toList();
      });
});

/// Provider to get review report by period (e.g., "2025-10")
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final reviewByPeriodProvider =
    StreamProvider.autoDispose.family<ExerciseReviewReport?, String>((ref, period) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('admin_reports')
      .where('period', isEqualTo: period)
      .limit(1)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;
        return ExerciseReviewReport.fromFirestore(snapshot.docs.first.data());
      });
});

/// Provider to get review statistics summary
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final reviewStatsSummaryProvider =
    StreamProvider.autoDispose<Map<String, dynamic>?>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('admin_reports')
      .orderBy('reportDate', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;

        final report = snapshot.docs.first.data();
        final stats = report['statistics'] as Map<String, dynamic>? ?? {};

        return {
          'staleExercisesCount': stats['staleExercisesCount'] ?? 0,
          'flaggedExercisesCount': stats['flaggedExercisesCount'] ?? 0,
          'totalFeedbackFlagged': stats['totalFeedbackFlagged'] ?? 0,
          'criticalIssuesCount': stats['criticalIssuesCount'] ?? 0,
          'period': report['period'] ?? 'unknown',
          'reportDate': report['reportDate'],
        };
      });
});

/// Provider to count stale exercises in latest report
final staleExercisesCountProvider = Provider<int>((ref) {
  final stats = ref.watch(reviewStatsSummaryProvider);

  return stats.whenData((data) {
    return data?['staleExercisesCount'] as int? ?? 0;
  }).asData?.value ?? 0;
});

/// Provider to count flagged exercises in latest report
final flaggedExercisesCountProvider = Provider<int>((ref) {
  final stats = ref.watch(reviewStatsSummaryProvider);

  return stats.whenData((data) {
    return data?['flaggedExercisesCount'] as int? ?? 0;
  }).asData?.value ?? 0;
});

/// Provider to count critical issues in latest report
final criticalIssuesCountProvider = Provider<int>((ref) {
  final stats = ref.watch(reviewStatsSummaryProvider);

  return stats.whenData((data) {
    return data?['criticalIssuesCount'] as int? ?? 0;
  }).asData?.value ?? 0;
});

/// Provider to get top stale exercises from latest report
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final topStaleExercisesProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('admin_reports')
      .orderBy('reportDate', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) return [];

        final report = snapshot.docs.first.data();
        final staleExercises =
            (report['staleExercises'] as List?)?.cast<Map<String, dynamic>>() ??
                [];

        // Return top 5
        return staleExercises.take(5).toList();
      });
});

/// Provider to get top flagged exercises from latest report
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final topFlaggedExercisesProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('admin_reports')
      .orderBy('reportDate', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) return [];

        final report = snapshot.docs.first.data();
        final flaggedExercises = (report['flaggedExercises'] as List?)
                ?.cast<Map<String, dynamic>>() ??
            [];

        // Return top 5, sorted by feedback count
        final sorted = List<Map<String, dynamic>>.from(flaggedExercises);
        sorted.sort((a, b) {
          final countA = (a['feedbackCount'] as num?)?.toInt() ?? 0;
          final countB = (b['feedbackCount'] as num?)?.toInt() ?? 0;
          return countB.compareTo(countA);
        });

        return sorted.take(5).toList();
      });
});

/// Provider to check if critical issues exist
final hasCriticalIssuesProvider = Provider<bool>((ref) {
  final criticalCount = ref.watch(criticalIssuesCountProvider);
  return criticalCount > 0;
});
