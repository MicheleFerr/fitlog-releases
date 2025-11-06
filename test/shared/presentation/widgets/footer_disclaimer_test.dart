import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/footer_disclaimer.dart';

void main() {
  group('FooterDisclaimer', () {
    testWidgets('displays disclaimer text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'),
            Locale('it'),
          ],
          home: Scaffold(
            body: FooterDisclaimer(),
          ),
        ),
      );

      expect(find.textContaining('NOT medical advice'), findsOneWidget);
    });

    testWidgets('is visually subtle (low emphasis)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'),
            Locale('it'),
          ],
          home: Scaffold(
            body: FooterDisclaimer(),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text).first);
      expect(textWidget.style?.fontSize, lessThan(14)); // Small font
    });

    testWidgets('tapping opens full disclaimer dialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'),
            Locale('it'),
          ],
          home: Scaffold(
            body: FooterDisclaimer(),
          ),
        ),
      );

      await tester.tap(find.byType(FooterDisclaimer));
      await tester.pumpAndSettle();

      // Verify dialog opened
      expect(find.text('Medical Disclaimer'), findsOneWidget);
    });
  });
}
