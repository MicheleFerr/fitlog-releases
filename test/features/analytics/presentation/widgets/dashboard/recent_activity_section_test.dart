import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/recent_activity_section.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

void main() {
  group('RecentActivitySection', () {
    final testWorkouts = [
      RecentWorkoutData(
        id: '1',
        name: 'Push Day',
        date: DateTime.now(),
        durationMinutes: 45,
        exerciseCount: 8,
        totalVolume: 12400,
        muscleGroups: ['Chest', 'Shoulders', 'Triceps'],
        prCount: 2,
      ),
      RecentWorkoutData(
        id: '2',
        name: 'Leg Day',
        date: DateTime.now().subtract(const Duration(days: 1)),
        durationMinutes: 52,
        exerciseCount: 6,
        totalVolume: 18200,
        muscleGroups: ['Quadriceps', 'Glutes'],
        prCount: 0,
      ),
    ];

    testWidgets('displays workout names', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecentActivitySection(workouts: testWorkouts),
            ),
          ),
        ),
      );

      expect(find.text('Push Day'), findsOneWidget);
      expect(find.text('Leg Day'), findsOneWidget);
    });

    testWidgets('shows PR badge when prCount > 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecentActivitySection(workouts: testWorkouts),
            ),
          ),
        ),
      );

      expect(find.textContaining('2'), findsWidgets); // PR count
    });

    testWidgets('displays empty state when no workouts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: RecentActivitySection(workouts: []),
            ),
          ),
        ),
      );

      expect(find.text('Push Day'), findsNothing);
      expect(find.text('Leg Day'), findsNothing);
    });

    testWidgets('limits visible workouts based on maxVisible', (tester) async {
      final manyWorkouts = List.generate(
        5,
        (i) => RecentWorkoutData(
          id: '$i',
          name: 'Workout $i',
          date: DateTime.now().subtract(Duration(days: i)),
          durationMinutes: 30,
          exerciseCount: 5,
          totalVolume: 10000,
          muscleGroups: ['Chest'],
          prCount: 0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecentActivitySection(
                workouts: manyWorkouts,
                maxVisible: 2,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Workout 0'), findsOneWidget);
      expect(find.text('Workout 1'), findsOneWidget);
      expect(find.text('Workout 2'), findsNothing);
    });

    testWidgets('calls onWorkoutTap when card is tapped', (tester) async {
      String? tappedId;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecentActivitySection(
                workouts: testWorkouts,
                onWorkoutTap: (id) => tappedId = id,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Push Day'));
      expect(tappedId, '1');
    });
  });
}
