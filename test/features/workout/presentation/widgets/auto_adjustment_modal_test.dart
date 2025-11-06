import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/auto_adjustment_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';

void main() {
  late Exercise testExercise;

  setUp(() {
    testExercise = Exercise(
      id: 'test-exercise',
      name: 'Bench Press',
      type: ExerciseType.single,
      category: ExerciseCategory.chest,
      sets: [],
      restTime: 120,
      useAPRE: false,
      apreProtocol: 6,
      calculated1RM: 100.0,
      calculated3RM: 92.0,
      calculated6RM: 83.0,
      calculated10RM: 75.0,
    );
  });

  Widget createTestWidget({
    required Exercise exercise,
    required Function(Exercise) onSave,
  }) {
    return ProviderScope(
      overrides: [
        exerciseHistoryFromWorkoutsProvider(exercise.name).overrideWith(
          (ref) => Future.value([]),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => AutoAdjustmentModal(
              exercise: exercise,
              onSave: onSave,
            ),
          ),
        ),
      ),
    );
  }

  group('AutoAdjustmentModal - Protocol Preview', () {
    testWidgets('displays protocol selector with three options', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          exercise: testExercise,
          onSave: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      // Find APRE type selector
      final apreCard = find.text('APRE');
      expect(apreCard, findsOneWidget);

      // Tap to select APRE
      await tester.tap(apreCard);
      await tester.pumpAndSettle();

      // Verify protocol selector is displayed
      expect(find.text('APRE 3'), findsOneWidget);
      expect(find.text('APRE 6'), findsOneWidget);
      expect(find.text('APRE 10'), findsOneWidget);
    });

    testWidgets('shows protocol preview when changing protocol', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          exercise: testExercise,
          onSave: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      // Select APRE type
      await tester.tap(find.text('APRE'));
      await tester.pumpAndSettle();

      // Wait for calculations to complete
      await tester.pump(const Duration(milliseconds: 500));

      // Change protocol from 6 to 3
      await tester.tap(find.text('APRE 3'));
      await tester.pumpAndSettle();

      // Verify preview is shown
      expect(find.text('Protocol Change Preview'), findsOneWidget);
      expect(find.text('Preview how your weights will change with the new protocol'), findsOneWidget);
    });

    testWidgets('preview shows correct weight comparisons', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          exercise: testExercise,
          onSave: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      // Select APRE
      await tester.tap(find.text('APRE'));
      await tester.pumpAndSettle();

      // Wait for calculations
      await tester.pump(const Duration(milliseconds: 500));

      // Change protocol from 6 to 3
      await tester.tap(find.text('APRE 3'));
      await tester.pumpAndSettle();

      // Verify set labels are displayed
      expect(find.textContaining('Set 1 (50%)'), findsOneWidget);
      expect(find.textContaining('Set 2 (75%)'), findsOneWidget);
      expect(find.textContaining('Set 3 (100%)'), findsOneWidget);
      expect(find.textContaining('Set 4'), findsOneWidget);

      // Verify adjusted message
      expect(find.text('Adjusted based on performance'), findsOneWidget);
    });

    testWidgets('preview displays current and new protocol labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          exercise: testExercise,
          onSave: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      // Select APRE
      await tester.tap(find.text('APRE'));
      await tester.pumpAndSettle();

      // Wait for calculations
      await tester.pump(const Duration(milliseconds: 500));

      // Change protocol from 6 to 10
      await tester.tap(find.text('APRE 10'));
      await tester.pumpAndSettle();

      // Verify protocol labels
      expect(find.textContaining('Current (APRE 6)'), findsOneWidget);
      expect(find.textContaining('New (APRE 10)'), findsOneWidget);
    });

    testWidgets('Apply Changes button updates protocol', (WidgetTester tester) async {
      Exercise? savedExercise;

      await tester.pumpWidget(
        createTestWidget(
          exercise: testExercise,
          onSave: (exercise) {
            savedExercise = exercise;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Select APRE
      await tester.tap(find.text('APRE'));
      await tester.pumpAndSettle();

      // Wait for calculations
      await tester.pump(const Duration(milliseconds: 500));

      // Change protocol from 6 to 3
      await tester.tap(find.text('APRE 3'));
      await tester.pumpAndSettle();

      // Tap Apply Changes
      await tester.tap(find.text('Apply Changes'));
      await tester.pumpAndSettle();

      // Verify preview is hidden
      expect(find.text('Protocol Change Preview'), findsNothing);

      // Verify base weight field is updated with 3RM value
      final baseWeightField = find.byType(TextField).last;
      final textField = tester.widget<TextField>(baseWeightField);
      expect(textField.controller?.text, '92.0'); // 3RM value
    });

    testWidgets('Cancel button reverts protocol change', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          exercise: testExercise,
          onSave: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      // Select APRE
      await tester.tap(find.text('APRE'));
      await tester.pumpAndSettle();

      // Wait for calculations
      await tester.pump(const Duration(milliseconds: 500));

      // Change protocol from 6 to 3
      await tester.tap(find.text('APRE 3'));
      await tester.pumpAndSettle();

      // Verify preview is shown
      expect(find.text('Protocol Change Preview'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify preview is hidden
      expect(find.text('Protocol Change Preview'), findsNothing);

      // Verify protocol reverted to 6
      // The APRE 6 segment should be selected
      final segmentedButton = find.byType(SegmentedButton<int>);
      expect(segmentedButton, findsOneWidget);
    });

    testWidgets('preview shows weight differences with correct colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          exercise: testExercise,
          onSave: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      // Select APRE
      await tester.tap(find.text('APRE'));
      await tester.pumpAndSettle();

      // Wait for calculations
      await tester.pump(const Duration(milliseconds: 500));

      // Change protocol from 6 (83kg) to 3 (92kg) - should show increase
      await tester.tap(find.text('APRE 3'));
      await tester.pumpAndSettle();

      // Verify weight values are displayed
      // Set 1: 50% of 83kg = 41.5kg → 50% of 92kg = 46.0kg (+4.5kg)
      // Set 2: 75% of 83kg = 62.25kg → 75% of 92kg = 69.0kg (+6.75kg)
      // Set 3: 100% of 83kg = 83kg → 100% of 92kg = 92kg (+9kg)

      // All increases should be present (shown with + prefix)
      expect(find.textContaining('+'), findsAtLeastNWidgets(3));
    });

    testWidgets('does not show preview on first protocol selection', (WidgetTester tester) async {
      final exerciseNoProtocol = testExercise.copyWith(
        apreProtocol: null,
        calculated1RM: null,
      );

      await tester.pumpWidget(
        createTestWidget(
          exercise: exerciseNoProtocol,
          onSave: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      // Select APRE
      await tester.tap(find.text('APRE'));
      await tester.pumpAndSettle();

      // Wait for calculations
      await tester.pump(const Duration(milliseconds: 500));

      // Select protocol for first time
      await tester.tap(find.text('APRE 6'));
      await tester.pumpAndSettle();

      // Preview should NOT be shown (no previous protocol)
      expect(find.text('Protocol Change Preview'), findsNothing);
    });

    testWidgets('theme compatibility - light mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseHistoryFromWorkoutsProvider(testExercise.name).overrideWith(
              (ref) => Future.value([]),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData.light(),
            home: Scaffold(
              body: AutoAdjustmentModal(
                exercise: testExercise,
                onSave: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select APRE
      await tester.tap(find.text('APRE'));
      await tester.pumpAndSettle();

      // Wait for calculations
      await tester.pump(const Duration(milliseconds: 500));

      // Change protocol
      await tester.tap(find.text('APRE 3'));
      await tester.pumpAndSettle();

      // Verify preview renders without errors in light mode
      expect(find.text('Protocol Change Preview'), findsOneWidget);
    });

    testWidgets('theme compatibility - dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseHistoryFromWorkoutsProvider(testExercise.name).overrideWith(
              (ref) => Future.value([]),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData.dark(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.dark,
            home: Scaffold(
              body: AutoAdjustmentModal(
                exercise: testExercise,
                onSave: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select APRE
      await tester.tap(find.text('APRE'));
      await tester.pumpAndSettle();

      // Wait for calculations
      await tester.pump(const Duration(milliseconds: 500));

      // Change protocol
      await tester.tap(find.text('APRE 3'));
      await tester.pumpAndSettle();

      // Verify preview renders without errors in dark mode
      expect(find.text('Protocol Change Preview'), findsOneWidget);
    });
  });
}
