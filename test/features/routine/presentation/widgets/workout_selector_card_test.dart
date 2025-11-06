// test/features/routine/presentation/widgets/workout_selector_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/workout_selector_card.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

void main() {
  group('WorkoutSelectorCard', () {
    // Helper to create mock exercises
    List<Exercise> createMockExercises(int count) {
      return List.generate(
        count,
        (i) => Exercise(
          name: 'Exercise $i',
          type: ExerciseType.single,
          category: ExerciseCategory.other,
        ),
      );
    }

    // Helper to wrap widget with MaterialApp and localizations
    Widget wrapWithMaterialApp(Widget child) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Scaffold(body: child),
      );
    }

    final mockWorkout = Workout(
      id: 'workout-1',
      name: 'Giorno A',
      startTime: DateTime(2025, 1, 5, 14, 30),
      endTime: DateTime(2025, 1, 5, 15, 15),
      exercises: createMockExercises(8), // 8 exercises
      notes: null,
      templateId: 'giorno-a',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('displays workout name and metadata', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          WorkoutSelectorCard(
            workout: mockWorkout,
            isTemplateMatch: false,
            isAlreadyLinked: false,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Giorno A'), findsOneWidget);
      expect(find.textContaining('45min'), findsOneWidget);
      expect(find.textContaining('8 exercises'), findsOneWidget);
    });

    testWidgets('shows match badge when isTemplateMatch is true', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          WorkoutSelectorCard(
            workout: mockWorkout,
            isTemplateMatch: true,
            isAlreadyLinked: false,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('match'), findsOneWidget);
      // Check icon is present in match badge
      expect(find.byIcon(AppIcons.checkCircle), findsOneWidget);
    });

    testWidgets('shows linked warning when isAlreadyLinked is true', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          WorkoutSelectorCard(
            workout: mockWorkout,
            isTemplateMatch: false,
            isAlreadyLinked: true,
            linkedDate: DateTime(2025, 1, 3),
            onTap: () {},
          ),
        ),
      );

      expect(find.textContaining('Linked to'), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        wrapWithMaterialApp(
          WorkoutSelectorCard(
            workout: mockWorkout,
            isTemplateMatch: false,
            isAlreadyLinked: false,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(WorkoutSelectorCard));
      expect(tapped, true);
    });

    testWidgets('applies highlight styling when isTemplateMatch is true', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          WorkoutSelectorCard(
            workout: mockWorkout,
            isTemplateMatch: true,
            isAlreadyLinked: false,
            onTap: () {},
          ),
        ),
      );

      // Find the card Container
      final cardContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('Giorno A'),
          matching: find.byType(Container),
        ).first,
      );

      // Verify decoration has border
      final decoration = cardContainer.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });
  });
}
