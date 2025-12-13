import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/stats_bar_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

void main() {
  group('StatsBarWidget', () {
    testWidgets('displays volume, streak, and PR count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StatsBarWidget(
              totalVolume: 12400,
              streakDays: 5,
              prCount: 2,
              measurementUnit: 'kg',
            ),
          ),
        ),
      );

      expect(find.text('12.4k'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });
}
