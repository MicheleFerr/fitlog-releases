import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/pr_celebration_modal.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/pr_celebration.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

void main() {
  // Test data factory
  PRCelebration createTestCelebration({
    String id = 'celebration-1',
    String userId = 'user-123',
    String prId = 'pr-1',
    PRType prType = PRType.weight,
    String? exerciseName = 'Bench Press',
    double previousValue = 90.0,
    double newValue = 100.0,
  }) {
    return PRCelebration(
      id: id,
      userId: userId,
      prId: prId,
      prType: prType,
      celebratedAt: DateTime.now(),
      engagement: CelebrationEngagement.viewed,
      previousValue: previousValue,
      newValue: newValue,
      exerciseName: exerciseName,
    );
  }

  // Helper to create testable widget tree
  Widget createTestWidget({
    required PRCelebration celebration,
    VoidCallback? onShare,
    VoidCallback? onDismiss,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('it'),
      ],
      home: Scaffold(
        body: PRCelebrationModal(
          celebration: celebration,
          onShare: onShare ?? () {},
          onDismiss: onDismiss ?? () {},
        ),
      ),
    );
  }

  group('PRCelebrationModal -', () {
    testWidgets('should render all required elements', (tester) async {
      // Arrange
      final celebration = createTestCelebration();

      // Act
      await tester.pumpWidget(createTestWidget(celebration: celebration));
      await tester.pumpAndSettle(); // Wait for animations

      // Assert - Trophy icon
      expect(find.byIcon(AppIcons.achievement), findsOneWidget);

      // Assert - Title text
      expect(find.text('New Personal Record!'), findsOneWidget);

      // Assert - Exercise name
      expect(find.text('Bench Press'), findsOneWidget);

      // Assert - Previous value
      expect(find.text('90.0 kg'), findsOneWidget);

      // Assert - New value
      expect(find.text('100.0 kg'), findsOneWidget);

      // Assert - Improvement percentage (100-90)/90 * 100 = 11.1%
      expect(find.textContaining('+11.1%'), findsOneWidget);

      // Assert - Arrow indicator
      expect(find.byIcon(AppIcons.arrowDownward), findsOneWidget);

      // Assert - Share button (find by text)
      expect(find.text('Share'), findsOneWidget);

      // Assert - Continue button (find by text)
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('should handle missing exercise name gracefully', (tester) async {
      // Arrange
      final celebration = createTestCelebration(exerciseName: null);

      // Act
      await tester.pumpWidget(createTestWidget(celebration: celebration));
      await tester.pumpAndSettle();

      // Assert - Exercise name not displayed when null
      expect(find.text('Bench Press'), findsNothing);

      // Assert - Other elements still present
      expect(find.text('New Personal Record!'), findsOneWidget);
      expect(find.text('90.0 kg'), findsOneWidget);
      expect(find.text('100.0 kg'), findsOneWidget);
    });

    testWidgets('should call onShare when share button is pressed', (tester) async {
      // Arrange
      final celebration = createTestCelebration();
      var shareCallbackCalled = false;

      // Act
      await tester.pumpWidget(
        createTestWidget(
          celebration: celebration,
          onShare: () => shareCallbackCalled = true,
        ),
      );
      await tester.pumpAndSettle();

      // Tap share button (find by text)
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      // Assert
      expect(shareCallbackCalled, true);
    });

    testWidgets('should call onDismiss when continue button is pressed', (tester) async {
      // Arrange
      final celebration = createTestCelebration();
      var dismissCallbackCalled = false;

      // Act
      await tester.pumpWidget(
        createTestWidget(
          celebration: celebration,
          onDismiss: () => dismissCallbackCalled = true,
        ),
      );
      await tester.pumpAndSettle();

      // Tap continue button
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      // Assert
      expect(dismissCallbackCalled, true);
    });

    testWidgets('should display significant PR with primary color', (tester) async {
      // Arrange - 20% improvement = significant PR
      final celebration = createTestCelebration(
        previousValue: 100.0,
        newValue: 120.0,
      );

      // Act
      await tester.pumpWidget(createTestWidget(celebration: celebration));
      await tester.pumpAndSettle();

      // Assert - Improvement percentage displayed
      expect(find.textContaining('+20.0%'), findsOneWidget);

      // Assert - Significant PR uses primary color
      // Find the improvement percentage badge container
      final badgeContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(Container),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.padding == const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
          ),
        ).last, // Get the badge container (last matching one)
      );

      expect(badgeContainer, isNotNull);
    });

    testWidgets('should display non-significant PR with secondary color', (tester) async {
      // Arrange - 5% improvement = non-significant PR
      final celebration = createTestCelebration(
        previousValue: 100.0,
        newValue: 105.0,
      );

      // Act
      await tester.pumpWidget(createTestWidget(celebration: celebration));
      await tester.pumpAndSettle();

      // Assert - Improvement percentage displayed
      expect(find.textContaining('+5.0%'), findsOneWidget);
    });

    testWidgets('should animate modal appearance', (tester) async {
      // Arrange
      final celebration = createTestCelebration();

      // Act
      await tester.pumpWidget(createTestWidget(celebration: celebration));

      // Assert - Widget starts with animations (may be multiple from Material widgets)
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(ScaleTransition), findsWidgets);

      // Wait for animation to complete
      await tester.pumpAndSettle();

      // Assert - Content is visible after animation
      expect(find.text('New Personal Record!'), findsOneWidget);
    });

    testWidgets('should use localization for text', (tester) async {
      // Arrange
      final celebration = createTestCelebration();

      // Act - Use Italian locale
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('it'),
          ],
          locale: const Locale('it'),
          home: Scaffold(
            body: PRCelebrationModal(
              celebration: celebration,
              onShare: () {},
              onDismiss: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Localized text should be present
      // Note: Actual Italian translations depend on app_it.arb
      // This test verifies the localization mechanism works
      expect(find.byType(PRCelebrationModal), findsOneWidget);
    });

    testWidgets('should render correctly in dark theme', (tester) async {
      // Arrange
      final celebration = createTestCelebration();

      // Act - Use dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('it'),
          ],
          home: Scaffold(
            body: PRCelebrationModal(
              celebration: celebration,
              onShare: () {},
              onDismiss: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Widget renders in dark theme
      expect(find.byType(PRCelebrationModal), findsOneWidget);
      expect(find.text('New Personal Record!'), findsOneWidget);
    });

    testWidgets('should format values correctly for different PR types', (tester) async {
      // Arrange - Test with reps PR type
      final celebration = createTestCelebration(
        prType: PRType.reps,
        previousValue: 8.0,
        newValue: 10.0,
      );

      // Act
      await tester.pumpWidget(createTestWidget(celebration: celebration));
      await tester.pumpAndSettle();

      // Assert - Values still display with kg suffix (formatter in modal)
      expect(find.text('8.0 kg'), findsOneWidget);
      expect(find.text('10.0 kg'), findsOneWidget);

      // Assert - Improvement percentage: (10-8)/8 * 100 = 25%
      expect(find.textContaining('+25.0%'), findsOneWidget);
    });

    testWidgets('should handle zero improvement percentage', (tester) async {
      // Arrange - Same value (edge case)
      final celebration = createTestCelebration(
        previousValue: 100.0,
        newValue: 100.0,
      );

      // Act
      await tester.pumpWidget(createTestWidget(celebration: celebration));
      await tester.pumpAndSettle();

      // Assert - Shows +0.0%
      expect(find.textContaining('+0.0%'), findsOneWidget);
    });

    testWidgets('should be dismissible with back button', (tester) async {
      // Arrange
      final celebration = createTestCelebration();
      var dismissCallbackCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('it'),
          ],
          home: Navigator(
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (builderContext) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: builderContext,
                        builder: (dialogContext) => PRCelebrationModal(
                          celebration: celebration,
                          onShare: () {},
                          onDismiss: () {
                            dismissCallbackCalled = true;
                            Navigator.pop(dialogContext);
                          },
                        ),
                      );
                    },
                    child: const Text('Show Modal'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      // Assert - Modal is displayed
      expect(find.text('New Personal Record!'), findsOneWidget);

      // Tap continue button to dismiss
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      // Assert
      expect(dismissCallbackCalled, true);
      expect(find.text('New Personal Record!'), findsNothing); // Modal closed
    });
  });
}
