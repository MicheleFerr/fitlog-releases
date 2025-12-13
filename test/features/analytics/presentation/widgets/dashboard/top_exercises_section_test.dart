import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/top_exercises_section.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

void main() {
  group('TopExercisesSection', () {
    final testExercises = [
      TopExerciseData(
        name: 'Bench Press',
        sessionCount: 4,
        lastWeight: 80,
        lastReps: 8,
        weightDelta: 2.5,
        measurementUnit: 'kg',
      ),
      TopExerciseData(
        name: 'Squat',
        sessionCount: 3,
        lastWeight: 100,
        lastReps: 5,
        weightDelta: 0,
        measurementUnit: 'kg',
        isPR: true,
      ),
      TopExerciseData(
        name: 'Deadlift',
        sessionCount: 2,
        lastWeight: 120,
        lastReps: 3,
        weightDelta: -5,
        measurementUnit: 'kg',
      ),
    ];

    Widget buildTestWidget(Widget child) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('displays exercise name', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(TopExercisesSection(exercises: testExercises)),
      );

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Squat'), findsOneWidget);
    });

    testWidgets('shows weight delta with arrow for positive change', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(TopExercisesSection(exercises: testExercises)),
      );

      expect(find.textContaining('+2.5'), findsOneWidget);
    });

    testWidgets('shows PR badge when isPR is true', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(TopExercisesSection(exercises: testExercises)),
      );

      expect(find.text('🏆 PR'), findsOneWidget);
    });

    testWidgets('displays session count and last set info', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(TopExercisesSection(exercises: testExercises)),
      );

      expect(find.textContaining('4 sessioni'), findsOneWidget);
      expect(find.textContaining('80kg x 8'), findsOneWidget);
    });

    testWidgets('shows "See all" button when more exercises than maxVisible', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          TopExercisesSection(
            exercises: testExercises,
            maxVisible: 2,
          ),
        ),
      );

      expect(find.textContaining('See all'), findsOneWidget);
    });

    testWidgets('handles exercise tap callback', (tester) async {
      String? tappedExercise;

      await tester.pumpWidget(
        buildTestWidget(
          TopExercisesSection(
            exercises: testExercises,
            onExerciseTap: (name) => tappedExercise = name,
          ),
        ),
      );

      await tester.tap(find.text('Bench Press'));
      expect(tappedExercise, 'Bench Press');
    });
  });
}
