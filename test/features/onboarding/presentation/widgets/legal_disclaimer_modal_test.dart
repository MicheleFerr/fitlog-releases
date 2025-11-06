import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/legal_disclaimer_modal.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

void main() {
  group('LegalDisclaimerModal', () {
    testWidgets('displays disclaimer title and content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
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
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => LegalDisclaimerModal(
                        onAccept: () => Navigator.of(context).pop(),
                      ),
                    );
                  },
                  child: const Text('Show Disclaimer'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show Disclaimer'));
      await tester.pumpAndSettle();

      // Verify title
      expect(find.text('Medical Disclaimer'), findsOneWidget);

      // Verify content (key phrases)
      expect(find.textContaining('NOT a substitute'), findsOneWidget);
      expect(find.textContaining('Consult a physician'), findsOneWidget);
      expect(find.textContaining('sole responsibility'), findsOneWidget);

      // Verify "I Accept" button exists
      expect(find.text('I Accept'), findsOneWidget);
    });

    testWidgets('cannot dismiss dialog by tapping outside', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
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
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => LegalDisclaimerModal(
                        onAccept: () => Navigator.of(context).pop(),
                      ),
                    );
                  },
                  child: const Text('Show Disclaimer'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Disclaimer'));
      await tester.pumpAndSettle();

      // Try tapping outside dialog (barrier)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Dialog should still be visible
      expect(find.text('Medical Disclaimer'), findsOneWidget);
    });

    testWidgets('calls onAccept when "I Accept" tapped', (tester) async {
      bool wasAccepted = false;

      await tester.pumpWidget(
        MaterialApp(
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
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => LegalDisclaimerModal(
                        onAccept: () {
                          wasAccepted = true;
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                  child: const Text('Show Disclaimer'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Disclaimer'));
      await tester.pumpAndSettle();

      // Tap "I Accept"
      await tester.tap(find.text('I Accept'));
      await tester.pumpAndSettle();

      expect(wasAccepted, true);
    });

    testWidgets('displays scrollable content for long text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
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
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => LegalDisclaimerModal(
                        onAccept: () => Navigator.of(context).pop(),
                      ),
                    );
                  },
                  child: const Text('Show Disclaimer'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Disclaimer'));
      await tester.pumpAndSettle();

      // Verify SingleChildScrollView exists for scrollable content
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
