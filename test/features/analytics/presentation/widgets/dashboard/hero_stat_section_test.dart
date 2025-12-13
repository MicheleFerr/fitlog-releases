import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/hero_stat_section.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('HeroStatSection', () {
    testWidgets('displays workout count prominently', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const HeroStatSection(
            workoutCount: 4,
            previousWeekCount: 2,
            weeklyGoal: 5,
          ),
        ),
      );

      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('shows positive delta when improved', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const HeroStatSection(
            workoutCount: 4,
            previousWeekCount: 2,
            weeklyGoal: 5,
          ),
        ),
      );

      expect(find.textContaining('+2'), findsOneWidget);
    });

    testWidgets('shows negative delta when decreased', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const HeroStatSection(
            workoutCount: 2,
            previousWeekCount: 4,
            weeklyGoal: 5,
          ),
        ),
      );

      expect(find.textContaining('-2'), findsOneWidget);
    });
  });
}
