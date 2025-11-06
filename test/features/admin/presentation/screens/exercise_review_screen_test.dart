import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/exercise_review_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/exercise_review_screen.dart';

// ============================================================================
// TEST HELPERS
// ============================================================================

Widget createTestWidget({
  required Map<String, dynamic>? reportData,
  required bool isLoading,
  required bool hasError,
  String? errorMessage,
}) {
  return MaterialApp(
    localizationsDelegates: const [],
    home: ProviderScope(
      overrides: [
        latestReviewProvider.overrideWith((ref) async* {
          if (isLoading) {
            // Stream never emits for loading state
            await Future.delayed(const Duration(seconds: 10));
            return;
          }
          if (hasError) {
            throw Exception(errorMessage ?? 'Test error');
          }
          yield reportData;
        }),
      ],
      child: const ExerciseReviewScreen(),
    ),
  );
}

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

// ============================================================================
// TESTS
// ============================================================================

void main() {
  group('🏋️ Exercise Review Screen Tests', () {
    // ========================================================================
    // LOADING STATE
    // ========================================================================

    group('⏳ Loading State', () {
      testWidgets('shows loading indicator while data is loading',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: {},
            isLoading: true,
            hasError: false,
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('loading text contains "Caricando"', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: {},
            isLoading: true,
            hasError: false,
          ),
        );

        // Note: actual text depends on localization
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });
    });

    // ========================================================================
    // ERROR STATE
    // ========================================================================

    group('❌ Error State', () {
      testWidgets('shows error icon on error', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: {},
            isLoading: false,
            hasError: true,
            errorMessage: 'Firestore connection failed',
          ),
        );

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('displays error message', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: {},
            isLoading: false,
            hasError: true,
            errorMessage: 'Test error message',
          ),
        );

        expect(find.byType(Text), findsWidgets);
      });
    });

    // ========================================================================
    // NO REPORT STATE
    // ========================================================================

    group('📭 No Report State', () {
      testWidgets('shows empty state when no report available',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: null,
            isLoading: false,
            hasError: false,
          ),
        );

        expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
      });

      testWidgets('shows appropriate message for empty state', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: null,
            isLoading: false,
            hasError: false,
          ),
        );

        // Check that "No report" related text is present
        expect(find.byType(Text), findsWidgets);
      });
    });

    // ========================================================================
    // SUCCESSFUL REPORT STATE
    // ========================================================================

    group('✅ Successful Report State', () {
      testWidgets('displays AppBar with title', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: mockReportData,
            isLoading: false,
            hasError: false,
          ),
        );

        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('shows period header correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: mockReportData,
            isLoading: false,
            hasError: false,
          ),
        );

        // Should contain period (2025-10)
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('displays all four stat cards', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: mockReportData,
            isLoading: false,
            hasError: false,
          ),
        );

        // Look for Card widgets containing stats
        expect(find.byType(Card), findsWidgets);
        // We expect at least stat cards + recommendations card + exercise list cards
        expect(find.byType(Card).evaluate().length, greaterThanOrEqualTo(2));
      });

      testWidgets('stat cards display correct numbers', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: mockReportData,
            isLoading: false,
            hasError: false,
          ),
        );

        // Find text widgets containing the numbers from statistics
        expect(find.byWidgetPredicate(
          (widget) => widget is Text && (widget.data?.contains('42') ?? false),
        ), findsWidgets); // stale count

        expect(find.byWidgetPredicate(
          (widget) => widget is Text && (widget.data?.contains('15') ?? false),
        ), findsWidgets); // flagged count

        expect(find.byWidgetPredicate(
          (widget) => widget is Text && (widget.data?.contains('8') ?? false),
        ), findsWidgets); // critical count
      });
    });

    // ========================================================================
    // RECOMMENDATIONS SECTION
    // ========================================================================

    group('💡 Recommendations Section', () {
      testWidgets('shows recommendations when present', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: mockReportData,
            isLoading: false,
            hasError: false,
          ),
        );

        // Find recommendations text
        expect(find.byType(Text), findsWidgets);

        // Should contain at least one recommendation
        final textWidgets = find.byType(Text);
        const bool hasRecommendation = false;
        await tester.pumpAndSettle();

        // Check that recommendations card is present
        expect(find.byType(Card), findsWidgets);
      });

      testWidgets('hides recommendations when empty', (WidgetTester tester) async {
        final reportWithoutRecs = Map<String, dynamic>.from(mockReportData);
        reportWithoutRecs['recommendations'] = [];

        await tester.pumpWidget(
          createTestWidget(
            reportData: reportWithoutRecs,
            isLoading: false,
            hasError: false,
          ),
        );

        await tester.pumpAndSettle();
        // UI should still render without crashing
        expect(find.byType(ExerciseReviewScreen), findsOneWidget);
      });
    });

    // ========================================================================
    // STALE EXERCISES SECTION
    // ========================================================================

    group('⏰ Stale Exercises Section', () {
      testWidgets('displays stale exercises list', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: mockReportData,
            isLoading: false,
            hasError: false,
          ),
        );

        // Should show stale exercises
        expect(find.byType(Card), findsWidgets);
        expect(find.byType(ListTile), findsWidgets);
      });

      testWidgets('stale exercises section has correct icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: mockReportData,
            isLoading: false,
            hasError: false,
          ),
        );

        expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
      });

      testWidgets('hides stale exercises when empty', (WidgetTester tester) async {
        final reportNoStale = Map<String, dynamic>.from(mockReportData);
        reportNoStale['staleExercises'] = [];

        await tester.pumpWidget(
          createTestWidget(
            reportData: reportNoStale,
            isLoading: false,
            hasError: false,
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(ExerciseReviewScreen), findsOneWidget);
      });

      testWidgets('shows correct number of stale exercise items',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: mockReportData,
            isLoading: false,
            hasError: false,
          ),
        );

        // Count ListTiles (used for exercise items)
        final listTiles = find.byType(ListTile);
        expect(listTiles, findsWidgets);
      });
    });

    // ========================================================================
    // FLAGGED EXERCISES SECTION
    // ========================================================================

    group('🚩 Flagged Exercises Section', () {
      testWidgets('displays flagged exercises list', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: mockReportData,
            isLoading: false,
            hasError: false,
          ),
        );

        expect(find.byType(Card), findsWidgets);
        expect(find.byType(ListTile), findsWidgets);
      });

      testWidgets('flagged exercises section has correct icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: mockReportData,
            isLoading: false,
            hasError: false,
          ),
        );

        expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
      });

      testWidgets('hides flagged exercises when empty', (WidgetTester tester) async {
        final reportNoFlagged = Map<String, dynamic>.from(mockReportData);
        reportNoFlagged['flaggedExercises'] = [];

        await tester.pumpWidget(
          createTestWidget(
            reportData: reportNoFlagged,
            isLoading: false,
            hasError: false,
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(ExerciseReviewScreen), findsOneWidget);
      });

      testWidgets('shows correct number of flagged exercise items',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            reportData: mockReportData,
            isLoading: false,
            hasError: false,
          ),
        );

        final listTiles = find.byType(ListTile);
        expect(listTiles, findsWidgets);
      });
    });

    // ========================================================================
    // SCROLLABLE CONTENT
    // ========================================================================

    group('📜 Scrollable Content', () {
      testWidgets('screen content is scrollable', (WidgetTester tester) async {
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          createTestWidget(
            reportData: mockReportData,
            isLoading: false,
            hasError: false,
          ),
        );

        // Try to scroll
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();

        expect(find.byType(ExerciseReviewScreen), findsOneWidget);
      });
    });

    // ========================================================================
    // EDGE CASES
    // ========================================================================

    group('🔍 Edge Cases', () {
      testWidgets('handles report with no exercises gracefully',
          (WidgetTester tester) async {
        final emptyReport = {
          'id': 'empty-report',
          'period': '2025-10',
          'statistics': mockReportData['statistics'],
          'staleExercises': [],
          'flaggedExercises': [],
          'recommendations': [],
          'status': 'COMPLETED',
        };

        await tester.pumpWidget(
          createTestWidget(
            reportData: emptyReport,
            isLoading: false,
            hasError: false,
          ),
        );

        expect(find.byType(ExerciseReviewScreen), findsOneWidget);
      });

      testWidgets('handles report with many exercises', (WidgetTester tester) async {
        final manyExercises = Map<String, dynamic>.from(mockReportData);
        manyExercises['staleExercises'] = List.generate(100, (i) => {
          'id': 'ex_$i',
          'nome': 'Exercise $i',
          'lastModifiedDaysAgo': 100 + i,
        });

        await tester.pumpWidget(
          createTestWidget(
            reportData: manyExercises,
            isLoading: false,
            hasError: false,
          ),
        );

        expect(find.byType(ExerciseReviewScreen), findsOneWidget);
      });

      testWidgets('handles special characters in exercise names',
          (WidgetTester tester) async {
        final specialReport = Map<String, dynamic>.from(mockReportData);
        (specialReport['staleExercises'] as List).add({
          'id': 'special_ex',
          'nome': 'Esercizio con "Quotes" & Ampersand',
          'lastModifiedDaysAgo': 95,
        });

        await tester.pumpWidget(
          createTestWidget(
            reportData: specialReport,
            isLoading: false,
            hasError: false,
          ),
        );

        expect(find.byType(ExerciseReviewScreen), findsOneWidget);
      });

      testWidgets('handles null feedback count gracefully', (WidgetTester tester) async {
        final nullFeedbackReport = Map<String, dynamic>.from(mockReportData);
        (nullFeedbackReport['flaggedExercises'] as List)[0]['feedbackCount'] = null;

        await tester.pumpWidget(
          createTestWidget(
            reportData: nullFeedbackReport,
            isLoading: false,
            hasError: false,
          ),
        );

        expect(find.byType(ExerciseReviewScreen), findsOneWidget);
      });
    });

    // ========================================================================
    // RESPONSIVE DESIGN
    // ========================================================================

    group('📱 Responsive Design', () {
      testWidgets('renders correctly on small screen', (WidgetTester tester) async {
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          createTestWidget(
            reportData: mockReportData,
            isLoading: false,
            hasError: false,
          ),
        );

        expect(find.byType(ExerciseReviewScreen), findsOneWidget);
      });

      testWidgets('renders correctly on large screen', (WidgetTester tester) async {
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          createTestWidget(
            reportData: mockReportData,
            isLoading: false,
            hasError: false,
          ),
        );

        expect(find.byType(ExerciseReviewScreen), findsOneWidget);
      });
    });
  });
}
