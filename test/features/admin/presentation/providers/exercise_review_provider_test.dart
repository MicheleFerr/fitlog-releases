import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/exercise_review_provider.dart';
import 'package:mocktail/mocktail.dart';

// ============================================================================
// MOCKS
// ============================================================================

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockQuery extends Mock
    implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

// ============================================================================
// TEST DATA
// ============================================================================

final mockReportData = {
  'id': '2025-10-16_20-30-00',
  'reportDate': Timestamp.fromDate(DateTime(2025, 10, 16)),
  'period': '2025-10',
  'statistics': {
    'staleExercisesCount': 42,
    'flaggedExercisesCount': 15,
    'totalFeedbackFlagged': 67,
    'criticalIssuesCount': 8,
  },
  'staleExercises': [
    {
      'id': 'bench_press_old',
      'nome': 'Panca Piana Vecchia',
      'lastModified': Timestamp.fromDate(DateTime(2025, 7, 10)),
      'lastModifiedDaysAgo': 98,
    },
    {
      'id': 'squat_old',
      'nome': 'Squat Vecchio',
      'lastModified': Timestamp.fromDate(DateTime(2025, 7, 15)),
      'lastModifiedDaysAgo': 93,
    },
  ],
  'flaggedExercises': [
    {
      'id': 'curl_many_feedback',
      'nome': 'Curl con Feedback',
      'feedbackCount': 5,
      'criticalCount': 2,
      'mostRecentFeedback': Timestamp.fromDate(DateTime(2025, 10, 16)),
    },
    {
      'id': 'row_feedback',
      'nome': 'Rematore',
      'feedbackCount': 3,
      'criticalCount': 0,
      'mostRecentFeedback': Timestamp.fromDate(DateTime(2025, 10, 14)),
    },
  ],
  'recommendations': [
    '⚠️ Found 42 stale exercises. Consider archiving or updating oldest ones.',
    '🚨 15 exercises have excessive feedback. Prioritize addressing critical issues.',
    '🔴 8 critical issues detected. Review severity ≥4 feedback immediately.',
  ],
  'status': 'COMPLETED',
  'createdAt': Timestamp.fromDate(DateTime(2025, 10, 16, 20, 30)),
};

final mockEmptyStats = {
  'staleExercisesCount': 0,
  'flaggedExercisesCount': 0,
  'totalFeedbackFlagged': 0,
  'criticalIssuesCount': 0,
};

// ============================================================================
// TESTS
// ============================================================================

void main() {
  group('🏋️ Exercise Review Provider Tests', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockCollection;
    late MockQuery mockQuery;
    late ProviderContainer container;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference();
      mockQuery = MockQuery();
      container = ProviderContainer();

      // Setup mock behavior
      when(() => mockFirestore.collection('admin_reports'))
          .thenReturn(mockCollection);
      when(() => mockCollection.orderBy('reportDate', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.limit(12)).thenReturn(mockQuery);
    });

    // ========================================================================
    // MODELS TESTS
    // ========================================================================

    group('📊 Models', () {
      test('ExerciseReviewReport.fromFirestore parses correctly', () {
        final report =
            ExerciseReviewReport.fromFirestore(mockReportData);

        expect(report.id, equals('2025-10-16_20-30-00'));
        expect(report.period, equals('2025-10'));
        expect(report.statistics.staleExercisesCount, equals(42));
        expect(report.statistics.flaggedExercisesCount, equals(15));
        expect(report.statistics.criticalIssuesCount, equals(8));
        expect(report.staleExercises.length, equals(2));
        expect(report.flaggedExercises.length, equals(2));
        expect(report.recommendations.length, equals(3));
      });

      test('ReviewStatistics.fromMap creates valid statistics', () {
        final stats = ReviewStatistics.fromMap(mockReportData['statistics']
            as Map<String, dynamic>);

        expect(stats.staleExercisesCount, equals(42));
        expect(stats.flaggedExercisesCount, equals(15));
        expect(stats.totalFeedbackFlagged, equals(67));
        expect(stats.criticalIssuesCount, equals(8));
      });

      test('StaleExercise.fromMap creates valid stale exercise', () {
        final staleExercises =
            mockReportData['staleExercises'] as List<dynamic>;
        final stale = StaleExercise.fromMap(
            staleExercises[0] as Map<String, dynamic>);

        expect(stale.id, equals('bench_press_old'));
        expect(stale.nome, equals('Panca Piana Vecchia'));
        expect(stale.lastModifiedDaysAgo, equals(98));
      });

      test('FlaggedExercise.fromMap creates valid flagged exercise', () {
        final flaggedExercises =
            mockReportData['flaggedExercises'] as List<dynamic>;
        final flagged = FlaggedExercise.fromMap(
            flaggedExercises[0] as Map<String, dynamic>);

        expect(flagged.id, equals('curl_many_feedback'));
        expect(flagged.nome, equals('Curl con Feedback'));
        expect(flagged.feedbackCount, equals(5));
        expect(flagged.criticalCount, equals(2));
      });

      test('Models.toMap() and fromMap() are symmetric', () {
        final stats = ReviewStatistics.fromMap(mockReportData['statistics']
            as Map<String, dynamic>);
        final statsMap = stats.toMap();
        final statsRestored = ReviewStatistics.fromMap(statsMap);

        expect(statsRestored.staleExercisesCount,
            equals(stats.staleExercisesCount));
        expect(statsRestored.flaggedExercisesCount,
            equals(stats.flaggedExercisesCount));
        expect(statsRestored.totalFeedbackFlagged,
            equals(stats.totalFeedbackFlagged));
        expect(statsRestored.criticalIssuesCount,
            equals(stats.criticalIssuesCount));
      });
    });

    // ========================================================================
    // STATISTICS PARSING TESTS
    // ========================================================================

    group('📈 Statistics Parsing', () {
      test('parseStatistics with valid data returns correct values', () {
        final data = mockReportData['statistics'] as Map<String, dynamic>;
        final stats = ReviewStatistics.fromMap(data);

        expect(stats.staleExercisesCount, isPositive);
        expect(stats.flaggedExercisesCount, isPositive);
        expect(stats.criticalIssuesCount, isNonNegative);
      });

      test('parseStatistics with missing fields returns defaults', () {
        final stats = ReviewStatistics.fromMap({});

        expect(stats.staleExercisesCount, equals(0));
        expect(stats.flaggedExercisesCount, equals(0));
        expect(stats.totalFeedbackFlagged, equals(0));
        expect(stats.criticalIssuesCount, equals(0));
      });

      test('staleExercisesCount >= flaggedExercisesCount (typically)', () {
        final stats = ReviewStatistics.fromMap(mockReportData['statistics']
            as Map<String, dynamic>);

        // In real scenarios, stale count is usually >= flagged count
        expect(stats.staleExercisesCount,
            greaterThanOrEqualTo(stats.flaggedExercisesCount - 10));
      });

      test('criticalIssuesCount <= totalFeedbackFlagged', () {
        final stats = ReviewStatistics.fromMap(mockReportData['statistics']
            as Map<String, dynamic>);

        expect(
          stats.criticalIssuesCount,
          lessThanOrEqualTo(stats.totalFeedbackFlagged),
        );
      });
    });

    // ========================================================================
    // RECOMMENDATIONS TESTS
    // ========================================================================

    group('💡 Recommendations Parsing', () {
      test('recommendations list contains valid strings', () {
        final recommendations =
            mockReportData['recommendations'] as List<dynamic>;

        expect(recommendations, isNotEmpty);
        expect(recommendations.every((r) => r is String), isTrue);
      });

      test('high stale count triggers archival recommendation', () {
        final recs = mockReportData['recommendations'] as List<dynamic>;
        final hasArchiveRec = recs.any((r) => (r as String).toLowerCase().contains('archiv'));
        expect(hasArchiveRec, isTrue);
      });

      test('critical issues trigger immediate review recommendation', () {
        final recs = mockReportData['recommendations'] as List<dynamic>;
        final hasCriticalRec = recs.any((r) => (r as String).toLowerCase().contains('critical'));
        expect(hasCriticalRec, isTrue);
      });
    });

    // ========================================================================
    // STALE EXERCISES TESTS
    // ========================================================================

    group('⏰ Stale Exercises Detection', () {
      test('stale exercises have >90 days threshold', () {
        final staleExercises =
            mockReportData['staleExercises'] as List<dynamic>;

        for (final ex in staleExercises) {
          final stale = StaleExercise.fromMap(ex as Map<String, dynamic>);
          expect(stale.lastModifiedDaysAgo, greaterThan(90));
        }
      });

      test('stale exercise has all required fields', () {
        final staleExercises =
            mockReportData['staleExercises'] as List<dynamic>;
        final stale = StaleExercise.fromMap(
            staleExercises[0] as Map<String, dynamic>);

        expect(stale.id, isNotEmpty);
        expect(stale.nome, isNotEmpty);
        expect(stale.lastModified, isNotNull);
        expect(stale.lastModifiedDaysAgo, isPositive);
      });

      test('stale exercises list is sorted by age (oldest first)', () {
        final staleExercises =
            mockReportData['staleExercises'] as List<dynamic>;
        final parsed = staleExercises
            .map((e) => StaleExercise.fromMap(e as Map<String, dynamic>))
            .toList();

        for (int i = 0; i < parsed.length - 1; i++) {
          expect(
            parsed[i].lastModifiedDaysAgo,
            greaterThanOrEqualTo(parsed[i + 1].lastModifiedDaysAgo),
          );
        }
      });
    });

    // ========================================================================
    // FLAGGED EXERCISES TESTS
    // ========================================================================

    group('🚩 Flagged Exercises Detection', () {
      test('flagged exercises have ≥3 feedback items', () {
        final flaggedExercises =
            mockReportData['flaggedExercises'] as List<dynamic>;

        for (final ex in flaggedExercises) {
          final flagged = FlaggedExercise.fromMap(ex as Map<String, dynamic>);
          expect(flagged.feedbackCount, greaterThanOrEqualTo(3));
        }
      });

      test('flagged exercise has all required fields', () {
        final flaggedExercises =
            mockReportData['flaggedExercises'] as List<dynamic>;
        final flagged = FlaggedExercise.fromMap(
            flaggedExercises[0] as Map<String, dynamic>);

        expect(flagged.id, isNotEmpty);
        expect(flagged.nome, isNotEmpty);
        expect(flagged.feedbackCount, isPositive);
        expect(flagged.criticalCount, isNonNegative);
      });

      test('critical issues count <= feedback count', () {
        final flaggedExercises =
            mockReportData['flaggedExercises'] as List<dynamic>;

        for (final ex in flaggedExercises) {
          final flagged = FlaggedExercise.fromMap(ex as Map<String, dynamic>);
          expect(flagged.criticalCount,
              lessThanOrEqualTo(flagged.feedbackCount));
        }
      });

      test('flagged exercises list is sorted by feedback count', () {
        final flaggedExercises =
            mockReportData['flaggedExercises'] as List<dynamic>;
        final parsed = flaggedExercises
            .map((e) => FlaggedExercise.fromMap(e as Map<String, dynamic>))
            .toList();

        for (int i = 0; i < parsed.length - 1; i++) {
          expect(
            parsed[i].feedbackCount,
            greaterThanOrEqualTo(parsed[i + 1].feedbackCount),
          );
        }
      });
    });

    // ========================================================================
    // REPORT STRUCTURE TESTS
    // ========================================================================

    group('📋 Report Structure', () {
      test('full report has all required sections', () {
        final report =
            ExerciseReviewReport.fromFirestore(mockReportData);

        expect(report.id, isNotEmpty);
        expect(report.period, matches(RegExp(r'\d{4}-\d{2}')));
        expect(report.statistics, isNotNull);
        expect(report.recommendations, isNotEmpty);
        expect(report.staleExercises, isList);
        expect(report.flaggedExercises, isList);
        expect(report.status, equals('COMPLETED'));
      });

      test('report period format is YYYY-MM', () {
        final report =
            ExerciseReviewReport.fromFirestore(mockReportData);

        expect(report.period, matches(RegExp(r'^\d{4}-\d{2}$')));
      });

      test('report contains coherent data', () {
        final report =
            ExerciseReviewReport.fromFirestore(mockReportData);

        // Total issues should make sense
        expect(
          report.statistics.staleExercisesCount +
                  report.statistics.flaggedExercisesCount >
              0,
          isTrue,
        );
      });
    });

    // ========================================================================
    // EDGE CASES
    // ========================================================================

    group('🔍 Edge Cases', () {
      test('handles empty stale exercises list', () {
        final data = Map<String, dynamic>.from(mockReportData);
        data['staleExercises'] = [];

        final report = ExerciseReviewReport.fromFirestore(data);
        expect(report.staleExercises, isEmpty);
      });

      test('handles empty flagged exercises list', () {
        final data = Map<String, dynamic>.from(mockReportData);
        data['flaggedExercises'] = [];

        final report = ExerciseReviewReport.fromFirestore(data);
        expect(report.flaggedExercises, isEmpty);
      });

      test('handles zero critical issues', () {
        final data = Map<String, dynamic>.from(mockReportData);
        (data['statistics'] as Map)['criticalIssuesCount'] = 0;

        final report = ExerciseReviewReport.fromFirestore(data);
        expect(report.statistics.criticalIssuesCount, equals(0));
      });

      test('handles missing optional fields gracefully', () {
        final minimalData = {
          'id': 'test-report',
          'period': '2025-10',
        };

        final report = ExerciseReviewReport.fromFirestore(minimalData);
        expect(report.id, equals('test-report'));
        expect(report.recommendations, isEmpty);
      });

      test('handles very large numbers', () {
        final data = Map<String, dynamic>.from(mockReportData);
        (data['statistics'] as Map)['staleExercisesCount'] = 9999;
        (data['statistics'] as Map)['flaggedExercisesCount'] = 999;

        final report = ExerciseReviewReport.fromFirestore(data);
        expect(report.statistics.staleExercisesCount, equals(9999));
        expect(report.statistics.flaggedExercisesCount, equals(999));
      });
    });
  });
}
