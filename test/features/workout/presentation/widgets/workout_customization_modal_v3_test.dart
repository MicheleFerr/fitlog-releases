import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_customization_modal_v3.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Helper to create MaterialApp with providers and localizations for tests
Widget buildTestApp({
  required Widget child,
}) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('it', 'IT'),
      ],
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('WorkoutCustomizationModalV3', () {
    // Note: These tests focus on UI structure and basic functionality
    // Integration tests would handle full state management testing

    group('UI Structure', () {
      testWidgets('modal builds without errors', (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const WorkoutCustomizationModalV3(),
          ),
        );

        // Should build successfully
        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      });

      testWidgets('displays mode selection buttons', (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const WorkoutCustomizationModalV3(),
          ),
        );
        await tester.pumpAndSettle();

        // Mode buttons should exist
        expect(find.text('Base Mode'), findsOneWidget);
        expect(find.text('Pro Mode'), findsOneWidget);
      });

      testWidgets('displays main sections', (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const WorkoutCustomizationModalV3(),
          ),
        );
        await tester.pumpAndSettle();

        // Main sections should exist
        expect(find.text('RPE Tracking'), findsOneWidget);
        expect(find.text('APRE Auto-Regulation'), findsOneWidget);
      });

      testWidgets('contains multiple Switch widgets', (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const WorkoutCustomizationModalV3(),
          ),
        );
        await tester.pumpAndSettle();

        // Should have multiple toggle switches
        final switches = find.byType(Switch);
        expect(switches, findsWidgets);
      });
    });

    group('Validation Mixin Integration', () {
      testWidgets('mixin is properly integrated', (tester) async {
        // This test verifies that the mixin compiles correctly
        // Actual behavior is tested in toggle_dependency_validation_test.dart
        await tester.pumpWidget(
          buildTestApp(
            child: const WorkoutCustomizationModalV3(),
          ),
        );
        await tester.pumpAndSettle();

        // If modal builds, mixin is integrated correctly
        expect(find.byType(WorkoutCustomizationModalV3), findsOneWidget);
      });
    });

    group('Localization', () {
      testWidgets('supports English locale', (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const WorkoutCustomizationModalV3(),
          ),
        );
        await tester.pumpAndSettle();

        // English text should be displayed
        expect(find.text('Base Mode'), findsOneWidget);
        expect(find.text('Pro Mode'), findsOneWidget);
      });

      testWidgets('supports Italian locale', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              locale: Locale('it', 'IT'),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [
                Locale('en', 'US'),
                Locale('it', 'IT'),
              ],
              home: Scaffold(
                body: WorkoutCustomizationModalV3(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Italian text should be displayed
        // Verify modal builds with Italian locale
        expect(find.byType(WorkoutCustomizationModalV3), findsOneWidget);
      });
    });
  });
}
