import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/user_goal.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/screens/goal_selection_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

void main() {
  group('GoalSelectionScreen', () {
    testWidgets('should display all goal type options', (tester) async {
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: GoalSelectionScreen(),
          ),
        ),
      );

      // Assert - Should find cards for each goal type
      expect(find.text('Build Muscle'), findsOneWidget);
      expect(find.text('Lose Weight'), findsOneWidget);
      expect(find.text('Get Stronger'), findsOneWidget);
      expect(find.text('Stay Fit'), findsOneWidget);
    });

    testWidgets('should call onGoalSelected when goal is tapped', (tester) async {
      // Arrange
      GoalType? selectedGoal;

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: GoalSelectionScreen(
              onGoalSelected: (goal) => selectedGoal = goal,
            ),
          ),
        ),
      );

      // Tap "Build Muscle" option
      await tester.tap(find.text('Build Muscle'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedGoal, GoalType.buildMuscle);
    });

    testWidgets('should display title and subtitle', (tester) async {
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: GoalSelectionScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text('What is your goal?'), findsOneWidget);
      expect(find.text('Choose your primary fitness objective'), findsOneWidget);
    });
  });
}
