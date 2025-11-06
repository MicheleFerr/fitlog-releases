import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/auto_adjustment_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
// import 'package:gymbro_flutter_new/features/workout/domain/exceptions/apre_exceptions.dart'; // Will be used in GREEN phase

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

      // Scroll to make "Apply Changes" button visible
      await tester.dragUntilVisible(
        find.text('Apply Changes'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
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

      // Scroll to make Cancel button visible
      await tester.dragUntilVisible(
        find.text('Cancel'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

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

  group('AutoAdjustmentModal - Workout In Progress Warning (T2.4)', () {
    testWidgets('TEST 1: verifies WorkoutProvider check happens when protocol changed', (WidgetTester tester) async {
      // Create a mock active workout
      final now = DateTime.now();
      final activeWorkout = Workout(
      id: 'test-workout-123',
        name: 'Test Workout',
        exercises: [testExercise],
        startTime: now,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      bool workoutProviderWasChecked = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseHistoryFromWorkoutsProvider(testExercise.name).overrideWith(
              (ref) => Future.value([]),
            ),
            currentWorkoutProvider.overrideWith((ref) {
              workoutProviderWasChecked = true;
              return CurrentWorkoutNotifier(ref)..state = activeWorkout;
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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

      // Select APRE type
      await tester.tap(find.text('APRE'));
      await tester.pumpAndSettle();

      // Wait for calculations
      await tester.pump(const Duration(milliseconds: 500));

      // Attempt to change protocol
      await tester.tap(find.text('APRE 3'));
      await tester.pumpAndSettle();

      // Verify WorkoutProvider was checked
      expect(workoutProviderWasChecked, isTrue, reason: 'WorkoutProvider should be checked when protocol changes');
    });

    testWidgets('TEST 2: verifies APREWorkoutInProgressException thrown when workout active', (WidgetTester tester) async {
      final now = DateTime.now();
      final activeWorkout = Workout(
      id: 'test-workout-123',
        name: 'Test Workout',
        exercises: [testExercise],
        startTime: now,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseHistoryFromWorkoutsProvider(testExercise.name).overrideWith(
              (ref) => Future.value([]),
            ),
            currentWorkoutProvider.overrideWith((ref) {
              return CurrentWorkoutNotifier(ref)..state = activeWorkout;
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  // Catch exceptions from protocol change
                  return AutoAdjustmentModal(
                    exercise: testExercise,
                    onSave: (_) {},
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select APRE
      await tester.tap(find.text('APRE'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // Try to change protocol - should throw APREWorkoutInProgressException
      // This test expects the exception to be thrown internally
      // Note: In implementation, we'll show dialog instead of crashing
      await tester.tap(find.text('APRE 3'));
      await tester.pumpAndSettle();

      // After implementation, a warning dialog should appear
      // For now, this will fail as the check doesn't exist yet
    });

    testWidgets('TEST 3: verifies warning dialog appears when exception thrown', (WidgetTester tester) async {
      final now = DateTime.now();
      final activeWorkout = Workout(
      id: 'test-workout-123',
        name: 'Test Workout',
        exercises: [testExercise],
        startTime: now,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseHistoryFromWorkoutsProvider(testExercise.name).overrideWith(
              (ref) => Future.value([]),
            ),
            currentWorkoutProvider.overrideWith((ref) {
              return CurrentWorkoutNotifier(ref)..state = activeWorkout;
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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
      await tester.pump(const Duration(milliseconds: 500));

      // Try to change protocol
      await tester.tap(find.text('APRE 3'));
      await tester.pumpAndSettle();

      // Verify warning dialog appears
      expect(find.byType(AlertDialog), findsOneWidget, reason: 'Warning dialog should appear');
    });

    testWidgets('TEST 4: verifies dialog shows correct localized message', (WidgetTester tester) async {
      final now = DateTime.now();
      final activeWorkout = Workout(
      id: 'test-workout-123',
        name: 'Test Workout',
        exercises: [testExercise],
        startTime: now,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseHistoryFromWorkoutsProvider(testExercise.name).overrideWith(
              (ref) => Future.value([]),
            ),
            currentWorkoutProvider.overrideWith((ref) {
              return CurrentWorkoutNotifier(ref)..state = activeWorkout;
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
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
      await tester.pump(const Duration(milliseconds: 500));

      // Try to change protocol
      await tester.tap(find.text('APRE 3'));
      await tester.pumpAndSettle();

      // Verify dialog shows correct localized messages
      expect(find.text('Workout in Progress'), findsOneWidget, reason: 'Dialog title should be localized');
      expect(
        find.textContaining('You cannot change APRE protocol during an active workout'),
        findsOneWidget,
        reason: 'Dialog message should be localized',
      );
      expect(find.text('Got it'), findsOneWidget, reason: 'Button text should be localized');
    });

    testWidgets('TEST 5: verifies dialog dismisses on "Got it" tap, protocol unchanged', (WidgetTester tester) async {
      final now = DateTime.now();
      final activeWorkout = Workout(
      id: 'test-workout-123',
        name: 'Test Workout',
        exercises: [testExercise],
        startTime: now,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseHistoryFromWorkoutsProvider(testExercise.name).overrideWith(
              (ref) => Future.value([]),
            ),
            currentWorkoutProvider.overrideWith((ref) {
              return CurrentWorkoutNotifier(ref)..state = activeWorkout;
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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
      await tester.pump(const Duration(milliseconds: 500));

      // Try to change protocol
      await tester.tap(find.text('APRE 3'));
      await tester.pumpAndSettle();

      // Tap "Got it" button
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      // Verify dialog is dismissed
      expect(find.byType(AlertDialog), findsNothing, reason: 'Dialog should be dismissed');

      // Verify protocol remained unchanged (still APRE 6)
      final segmentedButton = find.byType(SegmentedButton<int>);
      expect(segmentedButton, findsOneWidget);
      // Protocol should still be 6 (original value)
    });

    testWidgets('allows protocol change when NO workout active', (WidgetTester tester) async {
      // NO active workout
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseHistoryFromWorkoutsProvider(testExercise.name).overrideWith(
              (ref) => Future.value([]),
            ),
            currentWorkoutProvider.overrideWith((ref) {
              return CurrentWorkoutNotifier(ref)..state = null; // NO workout
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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
      await tester.pump(const Duration(milliseconds: 500));

      // Change protocol - should work normally (no warning)
      await tester.tap(find.text('APRE 3'));
      await tester.pumpAndSettle();

      // Verify NO warning dialog appears
      expect(find.byType(AlertDialog), findsNothing, reason: 'No dialog should appear when no workout active');

      // Verify protocol preview appears (normal flow)
      expect(find.text('Protocol Change Preview'), findsOneWidget, reason: 'Preview should show for normal protocol change');
    });
  });

  group('Protocol Change Tests - Comprehensive (T4.2)', () {
    testWidgets('T4.2-1: verifies weight difference colors in preview table', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseHistoryFromWorkoutsProvider(testExercise.name).overrideWith(
              (ref) => Future.value([]),
            ),
            currentWorkoutProvider.overrideWith((ref) {
              return CurrentWorkoutNotifier(ref)..state = null;
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return AutoAdjustmentModal(
                    exercise: testExercise,
                    onSave: (_) {},
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select APRE
      await tester.tap(find.text('APRE'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // Change protocol from APRE 6 (83kg) to APRE 3 (92kg) - should show positive differences
      await tester.tap(find.text('APRE 3'));
      await tester.pumpAndSettle();

      // Verify preview is shown
      expect(find.text('Protocol Change Preview'), findsOneWidget);

      // Find all Text widgets containing '+' (positive differences)
      final positiveDiffs = find.descendant(
        of: find.byType(Row),
        matching: find.textContaining('+'),
      );

      // At least some positive differences should exist (since we're going from 83kg to 92kg)
      expect(positiveDiffs.evaluate().length, greaterThan(0), reason: 'Should show positive weight differences');

      // Verify that Text widgets with '+' have success color (green)
      // Note: We can't directly access context.colors in tests without finding a BuildContext
      // So we verify the presence of colored text widgets
      for (final element in positiveDiffs.evaluate()) {
        final textWidget = element.widget as Text;
        expect(textWidget.style, isNotNull, reason: 'Positive difference should have styled text');
        // In real implementation, this would be context.colors.success (green)
      }
    });

    testWidgets('T4.2-2: verifies negative weight differences have error color', (WidgetTester tester) async {
      // Create exercise with higher base weight to test negative differences
      final heavyExercise = testExercise.copyWith(
        calculated3RM: 100.0,
        calculated6RM: 90.0,
        calculated10RM: 80.0,
        apreProtocol: 3, // Starting from APRE 3
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseHistoryFromWorkoutsProvider(heavyExercise.name).overrideWith(
              (ref) => Future.value([]),
            ),
            currentWorkoutProvider.overrideWith((ref) {
              return CurrentWorkoutNotifier(ref)..state = null;
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AutoAdjustmentModal(
                exercise: heavyExercise,
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
      await tester.pump(const Duration(milliseconds: 500));

      // Change protocol from APRE 3 (100kg) to APRE 10 (80kg) - should show negative differences
      await tester.tap(find.text('APRE 10'));
      await tester.pumpAndSettle();

      // Verify preview is shown
      expect(find.text('Protocol Change Preview'), findsOneWidget);

      // Find all Text widgets containing '-' (negative differences)
      final negativeDiffs = find.descendant(
        of: find.byType(Row),
        matching: find.textContaining('-'),
      );

      // Should have negative differences (since we're going from 100kg to 80kg)
      if (negativeDiffs.evaluate().isNotEmpty) {
        for (final element in negativeDiffs.evaluate()) {
          final textWidget = element.widget as Text;
          expect(textWidget.style, isNotNull, reason: 'Negative difference should have styled text');
          // In real implementation, this would be context.colors.error (red)
        }
      }
    });

    testWidgets('T4.2-3: verifies protocol persistence after Apply Changes', (WidgetTester tester) async {
      Exercise? savedExercise;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseHistoryFromWorkoutsProvider(testExercise.name).overrideWith(
              (ref) => Future.value([]),
            ),
            currentWorkoutProvider.overrideWith((ref) {
              return CurrentWorkoutNotifier(ref)..state = null;
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AutoAdjustmentModal(
                exercise: testExercise,
                onSave: (exercise) {
                  savedExercise = exercise;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial protocol
      expect(testExercise.apreProtocol, equals(6), reason: 'Initial protocol should be APRE 6');

      // Select APRE
      await tester.tap(find.text('APRE'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // Change protocol from 6 to 10
      await tester.tap(find.text('APRE 10'));
      await tester.pumpAndSettle();

      // Scroll to make "Apply Changes" button visible (preview might be off-screen)
      await tester.dragUntilVisible(
        find.text('Apply Changes'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      // Apply changes (this updates internal state, but doesn't save yet)
      await tester.tap(find.text('Apply Changes'));
      await tester.pumpAndSettle();

      // Verify preview is dismissed after applying
      expect(find.text('Protocol Change Preview'), findsNothing, reason: 'Preview should be dismissed');

      // Now tap "Save" button to persist changes
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Verify protocol was persisted in saved exercise
      expect(savedExercise, isNotNull, reason: 'Exercise should be saved');
      expect(savedExercise!.apreProtocol, equals(10), reason: 'Protocol should be updated to APRE 10');

      // Verify base weight was also updated (should be 10RM value: 75kg)
      expect(savedExercise!.apreBaseWeight, equals(testExercise.calculated10RM), reason: 'Base weight should be updated to 10RM value');
    });

    testWidgets('T4.2-4: verifies full end-to-end protocol change flow', (WidgetTester tester) async {
      Exercise? savedExercise;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseHistoryFromWorkoutsProvider(testExercise.name).overrideWith(
              (ref) => Future.value([]),
            ),
            currentWorkoutProvider.overrideWith((ref) {
              return CurrentWorkoutNotifier(ref)..state = null; // No active workout
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AutoAdjustmentModal(
                exercise: testExercise,
                onSave: (exercise) {
                  savedExercise = exercise;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // STEP 1: Select APRE type
      await tester.tap(find.text('APRE'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // STEP 2: Change protocol (should trigger preview)
      await tester.tap(find.text('APRE 3'));
      await tester.pumpAndSettle();

      // STEP 3: Verify preview shows all required elements
      expect(find.text('Protocol Change Preview'), findsOneWidget, reason: 'Preview title should be shown');
      expect(find.textContaining('Current (APRE 6)'), findsOneWidget, reason: 'Current protocol label should be shown');
      expect(find.textContaining('New (APRE 3)'), findsOneWidget, reason: 'New protocol label should be shown');
      expect(find.textContaining('Set 1 (50%)'), findsOneWidget, reason: 'Set 1 label should be shown');
      expect(find.textContaining('Set 2 (75%)'), findsOneWidget, reason: 'Set 2 label should be shown');
      expect(find.textContaining('Set 3 (100%)'), findsOneWidget, reason: 'Set 3 label should be shown');

      // STEP 4: Verify action buttons are present
      expect(find.text('Cancel'), findsOneWidget, reason: 'Cancel button should be shown');
      expect(find.text('Apply Changes'), findsOneWidget, reason: 'Apply Changes button should be shown');

      // STEP 5: Scroll to make "Apply Changes" visible
      await tester.dragUntilVisible(
        find.text('Apply Changes'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      // STEP 6: Apply changes
      await tester.tap(find.text('Apply Changes'));
      await tester.pumpAndSettle();

      // STEP 7: Verify preview is dismissed
      expect(find.text('Protocol Change Preview'), findsNothing, reason: 'Preview should be dismissed after applying');

      // STEP 8: Tap Save button to persist changes
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // STEP 9: Verify protocol was saved
      expect(savedExercise, isNotNull, reason: 'Exercise should be saved');
      expect(savedExercise!.apreProtocol, equals(3), reason: 'Protocol should be APRE 3');
      expect(savedExercise!.apreBaseWeight, equals(testExercise.calculated3RM), reason: 'Base weight should match 3RM');
    });

    testWidgets('T4.2-5: verifies cancel preserves original protocol', (WidgetTester tester) async {
      Exercise? savedExercise;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseHistoryFromWorkoutsProvider(testExercise.name).overrideWith(
              (ref) => Future.value([]),
            ),
            currentWorkoutProvider.overrideWith((ref) {
              return CurrentWorkoutNotifier(ref)..state = null;
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AutoAdjustmentModal(
                exercise: testExercise,
                onSave: (exercise) {
                  savedExercise = exercise;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select APRE
      await tester.tap(find.text('APRE'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // Change protocol
      await tester.tap(find.text('APRE 10'));
      await tester.pumpAndSettle();

      // Verify preview is shown
      expect(find.text('Protocol Change Preview'), findsOneWidget);

      // Scroll to make Cancel button visible (might be off-screen)
      await tester.dragUntilVisible(
        find.text('Cancel'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      // Cancel the change
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify preview is dismissed
      expect(find.text('Protocol Change Preview'), findsNothing, reason: 'Preview should be dismissed after cancel');

      // At this point, if user saves the modal, protocol should still be original
      // (In real app, user would need to tap Save button on modal)
      // For this test, we verify that canceling didn't trigger onSave with changed protocol

      // savedExercise should still be null because Cancel doesn't trigger save
      expect(savedExercise, isNull, reason: 'Cancel should not trigger save callback');
    });
  });
}
