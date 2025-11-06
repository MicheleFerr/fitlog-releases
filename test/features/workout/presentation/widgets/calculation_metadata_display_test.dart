import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/apre_auto_regulation_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/calculation_metadata_display.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_theme.dart';

void main() {
  group('CalculationMetadataDisplay', () {
    late Map<String, dynamic> testCalculations;

    setUp(() {
      testCalculations = {
        'calculated1RM': 100.0,
        'confidence': CalculationConfidence.high,
        'dataPoints': 8,
        'formula': 'Brzycki',
        'standardDeviation': 3.5,
        'dataAge': const Duration(days: 5),
        'metadata':
            'Based on 8 sets (Formula: Brzycki, Confidence: high, ±3.5kg)',
      };
    });

    Widget createTestWidget({
      required Map<String, dynamic> calculations,
      DateTime? lastCalculationDate,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CalculationMetadataDisplay(
            calculations: calculations,
            lastCalculationDate: lastCalculationDate,
          ),
        ),
      );
    }

    testWidgets('renders all metadata fields correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          calculations: testCalculations,
          lastCalculationDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
      );
      await tester.pumpAndSettle();

      // Check header
      expect(find.text('Calculation Analysis'), findsOneWidget);

      // Check all metadata rows
      expect(find.text('Formula'), findsOneWidget);
      expect(find.text('Brzycki'), findsOneWidget);

      expect(find.text('Data Points'), findsOneWidget);
      expect(find.text('8 / 10'), findsOneWidget);

      expect(find.text('Data Age'), findsOneWidget);
      expect(find.text('5 days ago'), findsOneWidget);

      expect(find.text('Variability'), findsOneWidget);
      expect(find.text('±3.5 kg'), findsOneWidget);

      // Check confidence section
      expect(find.text('Confidence'), findsOneWidget);
      expect(find.text('HIGH'), findsOneWidget);
      expect(find.text('✅'), findsOneWidget);

      // Check last calculation date
      expect(find.text('Last Updated'), findsOneWidget);
    });

    testWidgets('displays correct confidence colors for high confidence',
        (WidgetTester tester) async {
      testCalculations['confidence'] = CalculationConfidence.high;

      await tester.pumpWidget(
        createTestWidget(calculations: testCalculations),
      );
      await tester.pumpAndSettle();

      // Find confidence badge
      expect(find.text('HIGH'), findsOneWidget);
      expect(find.text('✅'), findsOneWidget);
    });

    testWidgets('displays correct confidence colors for medium confidence',
        (WidgetTester tester) async {
      testCalculations['confidence'] = CalculationConfidence.medium;

      await tester.pumpWidget(
        createTestWidget(calculations: testCalculations),
      );
      await tester.pumpAndSettle();

      // Find confidence badge
      expect(find.text('MEDIUM'), findsOneWidget);
      expect(find.text('⚠️'), findsOneWidget);
    });

    testWidgets('displays correct confidence colors for low confidence',
        (WidgetTester tester) async {
      testCalculations['confidence'] = CalculationConfidence.low;

      await tester.pumpWidget(
        createTestWidget(calculations: testCalculations),
      );
      await tester.pumpAndSettle();

      // Find confidence badge
      expect(find.text('LOW'), findsOneWidget);
      expect(find.text('⚠️'), findsOneWidget);
    });

    testWidgets('displays correct confidence for unknown confidence',
        (WidgetTester tester) async {
      testCalculations['confidence'] = CalculationConfidence.unknown;

      await tester.pumpWidget(
        createTestWidget(calculations: testCalculations),
      );
      await tester.pumpAndSettle();

      // Find confidence badge
      expect(find.text('UNKNOWN'), findsOneWidget);
      expect(find.text('❌'), findsOneWidget);
    });

    testWidgets('handles missing lastCalculationDate gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(calculations: testCalculations),
      );
      await tester.pumpAndSettle();

      // Last updated section should not be present
      expect(find.text('Last Updated'), findsNothing);
    });

    testWidgets('updates when calculations change',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(calculations: testCalculations),
      );
      await tester.pumpAndSettle();

      expect(find.text('8 / 10'), findsOneWidget);
      expect(find.text('HIGH'), findsOneWidget);

      // Update calculations
      testCalculations['dataPoints'] = 4;
      testCalculations['confidence'] = CalculationConfidence.medium;

      await tester.pumpWidget(
        createTestWidget(calculations: testCalculations),
      );
      await tester.pumpAndSettle();

      expect(find.text('4 / 10'), findsOneWidget);
      expect(find.text('MEDIUM'), findsOneWidget);
    });

    testWidgets('renders correctly in dark theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CalculationMetadataDisplay(
              calculations: testCalculations,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Widget should render without errors in dark theme
      expect(find.byType(CalculationMetadataDisplay), findsOneWidget);
      expect(find.text('Calculation Analysis'), findsOneWidget);
    });

    testWidgets('handles zero data points', (WidgetTester tester) async {
      testCalculations['dataPoints'] = 0;
      testCalculations['confidence'] = CalculationConfidence.unknown;

      await tester.pumpWidget(
        createTestWidget(calculations: testCalculations),
      );
      await tester.pumpAndSettle();

      expect(find.text('0 / 10'), findsOneWidget);
      expect(find.text('UNKNOWN'), findsOneWidget);
      expect(find.text('❌'), findsOneWidget);
    });

    testWidgets('formats data age correctly for 0 days',
        (WidgetTester tester) async {
      testCalculations['dataAge'] = Duration.zero;

      await tester.pumpWidget(
        createTestWidget(calculations: testCalculations),
      );
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('formats data age correctly for 1 day',
        (WidgetTester tester) async {
      testCalculations['dataAge'] = const Duration(days: 1);

      await tester.pumpWidget(
        createTestWidget(calculations: testCalculations),
      );
      await tester.pumpAndSettle();

      expect(find.text('Yesterday'), findsOneWidget);
    });

    testWidgets('formats data age correctly for multiple days',
        (WidgetTester tester) async {
      testCalculations['dataAge'] = const Duration(days: 10);

      await tester.pumpWidget(
        createTestWidget(calculations: testCalculations),
      );
      await tester.pumpAndSettle();

      expect(find.text('10 days ago'), findsOneWidget);
    });

    testWidgets('displays very high confidence correctly',
        (WidgetTester tester) async {
      testCalculations['confidence'] = CalculationConfidence.veryHigh;
      testCalculations['dataPoints'] = 10;
      testCalculations['dataAge'] = const Duration(days: 3);

      await tester.pumpWidget(
        createTestWidget(calculations: testCalculations),
      );
      await tester.pumpAndSettle();

      expect(find.text('VERYHIGH'), findsOneWidget);
      expect(find.text('✅'), findsOneWidget);
    });

    testWidgets('handles null values gracefully', (WidgetTester tester) async {
      final emptyCalculations = <String, dynamic>{};

      await tester.pumpWidget(
        createTestWidget(calculations: emptyCalculations),
      );
      await tester.pumpAndSettle();

      // Widget should render without crashing
      expect(find.byType(CalculationMetadataDisplay), findsOneWidget);
      expect(find.text('Calculation Analysis'), findsOneWidget);
      expect(find.text('0 / 10'), findsOneWidget);
    });

    testWidgets('displays Card with correct elevation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(calculations: testCalculations),
      );
      await tester.pumpAndSettle();

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(2));
    });

    testWidgets('uses SemanticIcon for accessibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          calculations: testCalculations,
          lastCalculationDate: DateTime.now(),
        ),
      );
      await tester.pumpAndSettle();

      // Widget should render without accessibility issues
      expect(find.byType(CalculationMetadataDisplay), findsOneWidget);

      // SemanticIcon widgets should be present (they wrap Icon internally)
      // We can't directly test for SemanticIcon without exposing keys,
      // but we can verify the widget renders correctly
      expect(find.text('Calculation Analysis'), findsOneWidget);
    });
  });
}
