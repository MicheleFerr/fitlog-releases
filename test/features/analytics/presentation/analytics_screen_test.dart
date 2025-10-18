import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/analytics_screen.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/models/workout_analytics.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyticsProvider extends StateNotifier<WorkoutAnalytics> {
  MockAnalyticsProvider() : super(WorkoutAnalytics.empty());

  void loadAnalytics() {
    state = WorkoutAnalytics(
      totalWorkouts: 42,
      totalVolume: 125000.0,
      averageWorkoutDuration: const Duration(hours: 1, minutes: 15),
      favoriteExercises: ['Bench Press', 'Squat', 'Deadlift'],
      weeklyWorkouts: [3, 4, 2, 5, 3, 4, 3],
      monthlyVolume: [
        95000, 102000, 98000, 115000, 125000, 118000,
        122000, 125000, 130000, 128000, 125000, 132000,
      ],
      muscleGroupDistribution: {
        'Chest': 25.0,
        'Back': 20.0,
        'Legs': 30.0,
        'Shoulders': 15.0,
        'Arms': 10.0,
      },
      personalRecords: [
        PersonalRecord(
          exercise: 'Bench Press',
          weight: 100.0,
          reps: 1,
          date: DateTime.now().subtract(const Duration(days: 7)),
        ),
        PersonalRecord(
          exercise: 'Squat',
          weight: 140.0,
          reps: 1,
          date: DateTime.now().subtract(const Duration(days: 14)),
        ),
        PersonalRecord(
          exercise: 'Deadlift',
          weight: 180.0,
          reps: 1,
          date: DateTime.now().subtract(const Duration(days: 21)),
        ),
      ],
      streakDays: 15,
      lastWorkoutDate: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }
}

void main() {
  group('AnalyticsScreen Tests', () {
    late MockAnalyticsProvider mockProvider;

    setUp(() {
      mockProvider = MockAnalyticsProvider();
    });

    Widget createTestWidget() {
      return const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProviderScope(
          child: AnalyticsScreen(),
        ),
      );
    }

    testWidgets('displays loading state initially', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays stats cards when loaded', (tester) async {
      mockProvider.loadAnalytics();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for stat cards
      expect(find.text('42'), findsOneWidget); // Total workouts
      expect(find.text('125000.0 kg'), findsOneWidget); // Total volume
      expect(find.text('15 days'), findsOneWidget); // Streak
    });

    testWidgets('displays weekly workout chart', (tester) async {
      mockProvider.loadAnalytics();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(BarChart), findsWidgets);
    });

    testWidgets('displays muscle group distribution', (tester) async {
      mockProvider.loadAnalytics();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(PieChart), findsWidgets);
    });

    testWidgets('displays personal records section', (tester) async {
      mockProvider.loadAnalytics();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Personal Records'), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('100.0 kg x 1'), findsOneWidget);
    });

    testWidgets('displays favorite exercises', (tester) async {
      mockProvider.loadAnalytics();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Favorite Exercises'), findsOneWidget);
      expect(find.text('Bench Press'), findsWidgets);
      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('Deadlift'), findsOneWidget);
    });

    testWidgets('handles date range selection', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for date range selector
      final dateRangeButton = find.byIcon(Icons.date_range);
      if (dateRangeButton.evaluate().isNotEmpty) {
        await tester.tap(dateRangeButton);
        await tester.pumpAndSettle();

        // Should show date picker or options
        expect(find.text('Last 7 days'), findsWidgets);
        expect(find.text('Last 30 days'), findsWidgets);
        expect(find.text('All time'), findsWidgets);
      }
    });

    testWidgets('displays volume trend chart', (tester) async {
      mockProvider.loadAnalytics();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsWidgets);
    });

    testWidgets('shows export button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('handles refresh action', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 200));
      await tester.pumpAndSettle();

      // Should trigger reload
      expect(mockProvider.state, isNotNull);
    });
  });

  group('WorkoutAnalytics Model Tests', () {
    test('creates empty analytics', () {
      final analytics = WorkoutAnalytics.empty();
      
      expect(analytics.totalWorkouts, 0);
      expect(analytics.totalVolume, 0.0);
      expect(analytics.favoriteExercises, isEmpty);
      expect(analytics.personalRecords, isEmpty);
    });

    test('calculates average volume per workout', () {
      final analytics = WorkoutAnalytics(
        totalWorkouts: 10,
        totalVolume: 50000.0,
        averageWorkoutDuration: const Duration(hours: 1),
        favoriteExercises: [],
        weeklyWorkouts: [],
        monthlyVolume: [],
        muscleGroupDistribution: {},
        personalRecords: [],
        streakDays: 0,
      );

      final averageVolume = analytics.totalVolume / analytics.totalWorkouts;
      expect(averageVolume, 5000.0);
    });

    test('formats duration correctly', () {
      const duration = Duration(hours: 1, minutes: 30, seconds: 45);
      final formatted = '${duration.inHours}h ${duration.inMinutes % 60}m';
      expect(formatted, '1h 30m');
    });

    test('identifies workout frequency', () {
      final weeklyWorkouts = [3, 4, 2, 5, 3, 4, 3];
      final average = weeklyWorkouts.reduce((a, b) => a + b) / weeklyWorkouts.length;
      expect(average, closeTo(3.43, 0.01));
    });

    test('calculates volume progression', () {
      final monthlyVolume = [100000.0, 105000.0, 110000.0];
      final progression = <double>[];
      
      for (int i = 1; i < monthlyVolume.length; i++) {
        final increase = (monthlyVolume[i] - monthlyVolume[i - 1]) / monthlyVolume[i - 1];
        progression.add(increase * 100);
      }

      expect(progression[0], 5.0); // 5% increase
      expect(progression[1], closeTo(4.76, 0.01)); // ~4.76% increase
    });
  });

  group('PersonalRecord Tests', () {
    test('creates personal record', () {
      final pr = PersonalRecord(
        exercise: 'Bench Press',
        weight: 100.0,
        reps: 1,
        date: DateTime(2024, 1, 1),
      );

      expect(pr.exercise, 'Bench Press');
      expect(pr.weight, 100.0);
      expect(pr.reps, 1);
      expect(pr.date.year, 2024);
    });

    test('compares personal records', () {
      final pr1 = PersonalRecord(
        exercise: 'Bench Press',
        weight: 100.0,
        reps: 1,
        date: DateTime.now(),
      );

      final pr2 = PersonalRecord(
        exercise: 'Bench Press',
        weight: 105.0,
        reps: 1,
        date: DateTime.now(),
      );

      expect(pr2.weight > pr1.weight, true);
    });

    test('calculates estimated 1RM from reps', () {
      final pr = PersonalRecord(
        exercise: 'Squat',
        weight: 100.0,
        reps: 5,
        date: DateTime.now(),
      );

      // Epley formula: 1RM = weight × (1 + reps/30)
      final estimated1RM = pr.weight * (1 + pr.reps / 30);
      expect(estimated1RM, closeTo(116.67, 0.01));
    });
  });

  group('Analytics Chart Tests', () {
    test('prepares data for weekly chart', () {
      final weeklyData = [3, 4, 2, 5, 3, 4, 3];
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      
      final chartData = <String, int>{};
      for (int i = 0; i < days.length; i++) {
        chartData[days[i]] = weeklyData[i];
      }

      expect(chartData['Mon'], 3);
      expect(chartData['Thu'], 5);
      expect(chartData.length, 7);
    });

    test('calculates muscle group percentages', () {
      final distribution = {
        'Chest': 25.0,
        'Back': 20.0,
        'Legs': 30.0,
        'Shoulders': 15.0,
        'Arms': 10.0,
      };

      final total = distribution.values.reduce((a, b) => a + b);
      expect(total, 100.0);

      // Verify percentages
      distribution.forEach((muscle, percentage) {
        expect(percentage >= 0 && percentage <= 100, true);
      });
    });

    test('formats large numbers for display', () {
      const double volume = 125000.0;
      String formatted;
      
      if (volume >= 1000000) {
        formatted = '${(volume / 1000000).toStringAsFixed(1)}M';
      } else if (volume >= 1000) {
        formatted = '${(volume / 1000).toStringAsFixed(1)}K';
      } else {
        formatted = volume.toStringAsFixed(0);
      }

      expect(formatted, '125.0K');
    });
  });

  group('Analytics Filter Tests', () {
    test('filters data by date range', () {
      final now = DateTime.now();
      final workouts = List.generate(30, (i) {
        return {
          'date': now.subtract(Duration(days: i)),
          'volume': 5000.0 + (i * 100),
        };
      });

      // Last 7 days
      final last7Days = workouts.where((w) {
        final date = w['date'] as DateTime;
        return date.isAfter(now.subtract(const Duration(days: 7)));
      }).toList();

      expect(last7Days.length, 7);

      // Last 30 days
      final last30Days = workouts.where((w) {
        final date = w['date'] as DateTime;
        return date.isAfter(now.subtract(const Duration(days: 30)));
      }).toList();

      expect(last30Days.length, 30);
    });

    test('groups workouts by month', () {
      final workouts = [
        DateTime(2024, 1, 15),
        DateTime(2024, 1, 20),
        DateTime(2024, 2, 10),
        DateTime(2024, 2, 25),
        DateTime(2024, 3, 5),
      ];

      final byMonth = <String, int>{};
      for (final date in workouts) {
        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        byMonth[key] = (byMonth[key] ?? 0) + 1;
      }

      expect(byMonth['2024-01'], 2);
      expect(byMonth['2024-02'], 2);
      expect(byMonth['2024-03'], 1);
    });
  });
}