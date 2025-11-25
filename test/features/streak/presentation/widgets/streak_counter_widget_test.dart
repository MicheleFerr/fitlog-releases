import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/workout_streak.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/providers/streak_provider.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/widgets/streak_counter_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

void main() {
  Widget buildWidget(WorkoutStreak? streak, {bool isLoading = false, Object? error}) {
    return ProviderScope(
      overrides: [
        currentStreakProvider.overrideWith((ref) async {
          if (error != null) throw error;
          if (isLoading) {
            // Never complete - simulates loading
            return Completer<WorkoutStreak>().future;
          }
          return streak!;
        }),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(
          body: StreakCounterWidget(),
        ),
      ),
    );
  }

  group('StreakCounterWidget', () {
    testWidgets('should display current streak with fire emoji when active',
        (tester) async {
      const streak = WorkoutStreak(
        currentStreak: 5,
        longestStreak: 10,
        isActive: true,
        lastWorkoutDate: null,
        totalWorkoutDays: 50,
      );

      await tester.pumpWidget(buildWidget(streak));
      await tester.pumpAndSettle();

      // Should display fire emoji
      expect(find.text('🔥'), findsOneWidget);

      // Should display current streak number
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('should display progress to next milestone', (tester) async {
      const streak = WorkoutStreak(
        currentStreak: 5,
        longestStreak: 10,
        isActive: true,
        lastWorkoutDate: null,
        totalWorkoutDays: 50,
      );

      await tester.pumpWidget(buildWidget(streak));
      await tester.pumpAndSettle();

      // Should have progress indicator
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Progress should be visible (5 days towards 7 day milestone)
      final progressIndicator =
          tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(progressIndicator.value, isNotNull);
      expect(progressIndicator.value! > 0, isTrue);
    });

    testWidgets('should display longest streak stat', (tester) async {
      const streak = WorkoutStreak(
        currentStreak: 5,
        longestStreak: 10,
        isActive: true,
        lastWorkoutDate: null,
        totalWorkoutDays: 50,
      );

      await tester.pumpWidget(buildWidget(streak));
      await tester.pumpAndSettle();

      // Should display longest streak value
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('should display total workout days stat', (tester) async {
      const streak = WorkoutStreak(
        currentStreak: 5,
        longestStreak: 10,
        isActive: true,
        lastWorkoutDate: null,
        totalWorkoutDays: 50,
      );

      await tester.pumpWidget(buildWidget(streak));
      await tester.pumpAndSettle();

      // Should display total workout days
      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (tester) async {
      await tester.pumpWidget(buildWidget(null, isLoading: true));
      // Don't pump - loading state shows immediately

      // Should display loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle zero streak gracefully', (tester) async {
      const streak = WorkoutStreak(
        currentStreak: 0,
        longestStreak: 0,
        isActive: false,
        lastWorkoutDate: null,
        totalWorkoutDays: 0,
      );

      await tester.pumpWidget(buildWidget(streak));
      await tester.pumpAndSettle();

      // Should display zero streak
      expect(find.text('0'), findsWidgets);

      // Should not display fire emoji for inactive streak
      expect(find.text('🔥'), findsNothing);
    });

    testWidgets('should display error message on error', (tester) async {
      await tester.pumpWidget(buildWidget(null, error: Exception('Failed to load')));
      await tester.pumpAndSettle();

      // Should display error indicator or message
      expect(find.byType(Icon), findsOneWidget);
    });
  });
}
