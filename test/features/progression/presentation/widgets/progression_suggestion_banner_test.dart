import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/progression/domain/entities/progression_suggestion.dart';
import 'package:gymbro_flutter_new/features/progression/presentation/widgets/progression_suggestion_banner.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

void main() {
  group('ProgressionSuggestionBanner', () {
    testWidgets('should display suggestion details correctly', (tester) async {
      // Arrange
      const suggestion = ProgressionSuggestion(
        exerciseName: 'Bench Press',
        currentWeight: 80.0,
        suggestedWeight: 82.5,
        targetReps: 6,
        reason: 'Try +2.5kg next time',
        confidence: ProgressionConfidence.high,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(
            body: ProgressionSuggestionBanner(suggestion: suggestion),
          ),
        ),
      );

      // Assert
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('80kg → 82.5kg'), findsOneWidget);
      expect(find.text('Try +2.5kg next time'), findsOneWidget);
      expect(find.text('6 reps'), findsOneWidget);
    });

    testWidgets('should show confidence indicator for high confidence',
        (tester) async {
      // Arrange
      const suggestion = ProgressionSuggestion(
        exerciseName: 'Squat',
        currentWeight: 100.0,
        suggestedWeight: 102.5,
        targetReps: 8,
        reason: 'Ready to progress',
        confidence: ProgressionConfidence.high,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(
            body: ProgressionSuggestionBanner(suggestion: suggestion),
          ),
        ),
      );

      // Assert - Should find high confidence indicator
      expect(find.byIcon(AppIcons.trendUp), findsOneWidget);
    });

    testWidgets('should display additional notes when provided',
        (tester) async {
      // Arrange
      const suggestion = ProgressionSuggestion(
        exerciseName: 'Deadlift',
        currentWeight: 120.0,
        suggestedWeight: 122.5,
        targetReps: 5,
        reason: 'Plateau detected',
        confidence: ProgressionConfidence.high,
        additionalNotes: 'Focus on form at new weight',
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(
            body: ProgressionSuggestionBanner(suggestion: suggestion),
          ),
        ),
      );

      // Assert
      expect(find.text('Focus on form at new weight'), findsOneWidget);
    });

    testWidgets('should be dismissible', (tester) async {
      // Arrange
      bool dismissed = false;
      const suggestion = ProgressionSuggestion(
        exerciseName: 'Bench Press',
        currentWeight: 80.0,
        suggestedWeight: 80.0,
        targetReps: 10,
        reason: 'Keep current weight',
        confidence: ProgressionConfidence.medium,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: ProgressionSuggestionBanner(
              suggestion: suggestion,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      // Find and tap dismiss button
      final dismissButton = find.byIcon(AppIcons.close);
      expect(dismissButton, findsOneWidget);
      await tester.tap(dismissButton);
      await tester.pumpAndSettle();

      // Assert
      expect(dismissed, true);
    });
  });
}
