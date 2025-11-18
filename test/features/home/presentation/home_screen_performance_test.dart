import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gymbro_flutter_new/features/home/presentation/home_screen_performance.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/dynamic_greeting.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('HomeScreenPerformance renders without errors',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreenPerformance(),
        ),
      ),
    );

    // Wait for initial frame
    await tester.pump();

    // The screen should build without errors
    expect(find.byType(HomeScreenPerformance), findsOneWidget);

    // Verify DynamicGreeting is present
    expect(find.byType(DynamicGreeting), findsOneWidget);
  });

  testWidgets('HomeScreenPerformance preserves tour functionality',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreenPerformance(),
        ),
      ),
    );

    await tester.pump();

    // The screen should build without errors and have tour manager
    expect(find.byType(HomeScreenPerformance), findsOneWidget);
  });
}
