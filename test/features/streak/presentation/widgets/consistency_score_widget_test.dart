import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/consistency_score.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/weekly_stats.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/widgets/consistency_score_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

void main() {
  Widget buildWidget(ConsistencyScore score) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('it'),
        ],
        home: Scaffold(
          body: CompactScoreCard(score: score),
        ),
      ),
    );
  }

  group('ConsistencyScoreWidget', () {
    testWidgets('shows green badge when 2-3 indicators optimal', (tester) async {
      final score = ConsistencyScore(
        frequencyOptimal: true,
        restOptimal: true,
        progressionPositive: false,
        frequencyScore: 85,
        restScore: 90,
        progressionScore: 60,
        weeklyStats: WeeklyStats(
          avgWorkoutsPerWeek: 4.2,
          avgRestDaysPerWeek: 2.8,
          totalWorkouts: 18,
          totalRestDays: 12,
          totalActiveDays: 18,
          weekStartDate: DateTime.now().subtract(const Duration(days: 30)),
          weekEndDate: DateTime.now(),
        ),
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildWidget(score));

      // Should show "Doing well!" badge
      expect(find.textContaining('Doing well'), findsOneWidget);
      expect(find.text('(2/3 ✅)'), findsOneWidget);

      // Should show 3 indicator rows
      expect(find.textContaining('Training'), findsOneWidget);
      expect(find.textContaining('Rest'), findsOneWidget);
      expect(find.textContaining('Progress'), findsOneWidget);
    });

    testWidgets('shows yellow badge when 1 indicator optimal', (tester) async {
      final score = ConsistencyScore(
        frequencyOptimal: false,
        restOptimal: true,
        progressionPositive: false,
        frequencyScore: 60,
        restScore: 85,
        progressionScore: 50,
        weeklyStats: WeeklyStats(
          avgWorkoutsPerWeek: 2.5,
          avgRestDaysPerWeek: 2.8,
          totalWorkouts: 10,
          totalRestDays: 20,
          totalActiveDays: 10,
          weekStartDate: DateTime.now().subtract(const Duration(days: 30)),
          weekEndDate: DateTime.now(),
        ),
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildWidget(score));

      expect(find.textContaining('Can improve'), findsOneWidget);
      expect(find.text('(1/3 ✅)'), findsOneWidget);
    });

    testWidgets('shows red badge when 0 indicators optimal', (tester) async {
      final score = ConsistencyScore(
        frequencyOptimal: false,
        restOptimal: false,
        progressionPositive: false,
        frequencyScore: 50,
        restScore: 40,
        progressionScore: 45,
        weeklyStats: WeeklyStats(
          avgWorkoutsPerWeek: 2.0,
          avgRestDaysPerWeek: 1.5,
          totalWorkouts: 8,
          totalRestDays: 6,
          totalActiveDays: 8,
          weekStartDate: DateTime.now().subtract(const Duration(days: 30)),
          weekEndDate: DateTime.now(),
        ),
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildWidget(score));

      expect(find.textContaining('Review your routine'), findsOneWidget);
      expect(find.text('(0/3 ✅)'), findsOneWidget);
    });

    testWidgets('shows check icon for optimal indicators', (tester) async {
      final score = ConsistencyScore(
        frequencyOptimal: true,
        restOptimal: false,
        progressionPositive: true,
        frequencyScore: 85,
        restScore: 60,
        progressionScore: 90,
        weeklyStats: WeeklyStats.empty(),
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildWidget(score));

      // Find check and cancel icons
      // 2 optimal indicators in rows + 1 checkCircle in badge (2/3 optimal) = 3 total
      expect(find.byIcon(AppIcons.checkCircle), findsNWidgets(3));
      expect(find.byIcon(AppIcons.cancel), findsOneWidget); // 1 not optimal
    });
  });
}
