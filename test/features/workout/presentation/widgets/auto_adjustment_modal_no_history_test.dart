import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/auto_adjustment_modal_no_history.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

void main() {
  group('AutoAdjustmentModalNoHistory', () {
    Widget buildTestWidget({required Widget child}) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('it', ''),
        ],
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('displays title and description', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => AutoAdjustmentModalNoHistory(
                      onOptionSelected: (option, value) {},
                    ),
                  );
                },
                child: const Text('Show Modal'),
              );
            },
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      // Verify title and description are displayed
      expect(find.textContaining('No Historical Data'), findsOneWidget);
      expect(find.textContaining('historical data'), findsOneWidget);
    });

    testWidgets('displays 3 input method options', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => AutoAdjustmentModalNoHistory(
                      onOptionSelected: (option, value) {},
                    ),
                  );
                },
                child: const Text('Show Modal'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      // Verify all 3 options are present
      expect(find.textContaining('Last Workout'), findsOneWidget);
      expect(find.textContaining('Manual'), findsOneWidget);
      expect(find.textContaining('Test Set'), findsOneWidget);
    });

    testWidgets('shows preview when option selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => AutoAdjustmentModalNoHistory(
                      onOptionSelected: (option, value) {},
                    ),
                  );
                },
                child: const Text('Show Modal'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      // Tap manual estimate option
      await tester.tap(find.textContaining('Manual'));
      await tester.pumpAndSettle();

      // Should show input field
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('validates manual input', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => AutoAdjustmentModalNoHistory(
                      onOptionSelected: (option, value) {},
                    ),
                  );
                },
                child: const Text('Show Modal'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      // Select manual option
      await tester.tap(find.textContaining('Manual'));
      await tester.pumpAndSettle();

      // Try to continue without entering value
      final continueButton = find.widgetWithText(FilledButton, 'Continue');
      expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);

      // Enter invalid value
      await tester.enterText(find.byType(TextField), '0');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);

      // Enter valid value
      await tester.enterText(find.byType(TextField), '100');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(continueButton).onPressed, isNotNull);
    });

    testWidgets('calls onOptionSelected with correct values', (WidgetTester tester) async {
      String? selectedOption;
      double? selectedValue;

      await tester.pumpWidget(
        buildTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => AutoAdjustmentModalNoHistory(
                      onOptionSelected: (option, value) {
                        selectedOption = option;
                        selectedValue = value;
                      },
                    ),
                  );
                },
                child: const Text('Show Modal'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      // Select manual and enter value
      await tester.tap(find.textContaining('Manual'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '100');
      await tester.pumpAndSettle();

      // Scroll to make continue button visible
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      // Tap continue
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(selectedOption, equals('manual'));
      expect(selectedValue, equals(100.0));
    });

    testWidgets('cancel button closes modal', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => AutoAdjustmentModalNoHistory(
                      onOptionSelected: (option, value) {},
                    ),
                  );
                },
                child: const Text('Show Modal'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      // Verify modal is open
      expect(find.textContaining('No Historical Data'), findsOneWidget);

      // Scroll to make cancel button visible
      await tester.ensureVisible(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Verify modal is closed
      expect(find.textContaining('No Historical Data'), findsNothing);
    });

    testWidgets('displays weight preview for manual input', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => AutoAdjustmentModalNoHistory(
                      onOptionSelected: (option, value) {},
                    ),
                  );
                },
                child: const Text('Show Modal'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      // Select manual
      await tester.tap(find.textContaining('Manual'));
      await tester.pumpAndSettle();

      // Enter 1RM value
      await tester.enterText(find.byType(TextField), '100');
      await tester.pumpAndSettle();

      // Should show calculated weights preview
      expect(find.textContaining('Preview'), findsOneWidget);
      expect(find.textContaining('92.0'), findsOneWidget); // 92% for 3RM
      expect(find.textContaining('83.0'), findsOneWidget); // 83% for 6RM
      expect(find.textContaining('75.0'), findsOneWidget); // 75% for 10RM
    });
  });
}
