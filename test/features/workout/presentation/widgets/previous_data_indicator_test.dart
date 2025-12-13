/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 🧪 Test Suite: PreviousDataIndicator Widget
/// ✅ PREVIOUS_DATA: Tests for previous workout data display widget
///
/// Test Scenarios:
/// 1. Renders with previous data (weight, reps, days ago)
/// 2. Shows loading state
/// 3. OnTap callback triggers auto-fill
/// 4. Shows data source indicator (cache vs Firestore)
/// 5. Time formatting (today, yesterday, days, weeks, months ago)
/// 6. Shows copy icon when tappable
/// 7. Empty state when no previous data

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/previous_data_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_theme.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Helper function to wrap widget with MaterialApp + Localizations
Widget wrapWithApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'), // Force English for predictable tests
    home: Scaffold(body: child),
  );
}

void main() {
  group('PreviousDataIndicator Widget Tests', () {
    testWidgets('✅ Scenario 1: Renders with previous data', (tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithApp(
          const PreviousDataIndicator(
            previousWeight: 90.0,
            previousReps: 10,
            daysSinceLastSession: 5,
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Last: 90kg × 10 (5d ago)'), findsOneWidget);
      expect(find.byIcon(AppIcons.history), findsOneWidget);
    });

    testWidgets('✅ Scenario 2: Shows loading state', (tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithApp(
          const PreviousDataIndicator(
            previousWeight: 90.0,
            previousReps: 10,
            daysSinceLastSession: 5,
            isLoading: true,
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsOneWidget);
    });

    testWidgets('✅ Scenario 3: OnTap callback triggers', (tester) async {
      // Arrange
      bool tapped = false;
      await tester.pumpWidget(
        wrapWithApp(
          PreviousDataIndicator(
            previousWeight: 90.0,
            previousReps: 10,
            daysSinceLastSession: 5,
            onTap: () => tapped = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, true);
    });

    testWidgets('✅ Scenario 4: Shows Firestore data source indicator', (tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithApp(
          const PreviousDataIndicator(
            previousWeight: 90.0,
            previousReps: 10,
            daysSinceLastSession: 5,
            dataSource: 'firestore', // From Firestore (slow)
          ),
        ),
      );

      // Act & Assert
      expect(find.byIcon(AppIcons.cloud), findsOneWidget); // Cloud icon for Firestore
    });

    testWidgets('✅ Scenario 5: Does NOT show cloud icon for cache', (tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithApp(
          const PreviousDataIndicator(
            previousWeight: 90.0,
            previousReps: 10,
            daysSinceLastSession: 5,
            dataSource: 'cache', // From cache (fast)
          ),
        ),
      );

      // Act & Assert
      expect(find.byIcon(AppIcons.cloud), findsNothing); // No cloud icon for cache
    });

    testWidgets('✅ Scenario 6: Shows copy icon when tappable', (tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithApp(
          PreviousDataIndicator(
            previousWeight: 90.0,
            previousReps: 10,
            daysSinceLastSession: 5,
            onTap: () {}, // Tappable
          ),
        ),
      );

      // Act & Assert
      expect(find.byIcon(AppIcons.copy), findsOneWidget); // Copy icon when tappable
    });

    testWidgets('✅ Scenario 7: Does NOT show copy icon when not tappable', (tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithApp(
          const PreviousDataIndicator(
            previousWeight: 90.0,
            previousReps: 10,
            daysSinceLastSession: 5,
            // No onTap
          ),
        ),
      );

      // Act & Assert
      expect(find.byIcon(AppIcons.copy), findsNothing); // No copy icon when not tappable
    });

    group('Time Formatting Tests', () {
      testWidgets('✅ Shows "today" for 0 days', (tester) async {
        // Arrange
        await tester.pumpWidget(
          wrapWithApp(
            const PreviousDataIndicator(
              previousWeight: 90.0,
              previousReps: 10,
              daysSinceLastSession: 0, // Today
            ),
          ),
        );

        // Act & Assert
        expect(find.textContaining('(Today)'), findsOneWidget);
      });

      testWidgets('✅ Shows "yesterday" for 1 day', (tester) async {
        // Arrange
        await tester.pumpWidget(
          wrapWithApp(
            const PreviousDataIndicator(
              previousWeight: 90.0,
              previousReps: 10,
              daysSinceLastSession: 1, // Yesterday
            ),
          ),
        );

        // Act & Assert
        expect(find.textContaining('(Yesterday)'), findsOneWidget);
      });

      testWidgets('✅ Shows "5d ago" for 5 days', (tester) async {
        // Arrange
        await tester.pumpWidget(
          wrapWithApp(
            const PreviousDataIndicator(
              previousWeight: 90.0,
              previousReps: 10,
              daysSinceLastSession: 5, // 5 days
            ),
          ),
        );

        // Act & Assert
        expect(find.textContaining('(5d ago)'), findsOneWidget);
      });

      testWidgets('✅ Shows "2w ago" for 14 days', (tester) async {
        // Arrange
        await tester.pumpWidget(
          wrapWithApp(
            const PreviousDataIndicator(
              previousWeight: 90.0,
              previousReps: 10,
              daysSinceLastSession: 14, // 2 weeks
            ),
          ),
        );

        // Act & Assert
        expect(find.textContaining('(2w ago)'), findsOneWidget);
      });

      testWidgets('✅ Shows "2mo ago" for 60 days', (tester) async {
        // Arrange
        await tester.pumpWidget(
          wrapWithApp(
            const PreviousDataIndicator(
              previousWeight: 90.0,
              previousReps: 10,
              daysSinceLastSession: 60, // 2 months
            ),
          ),
        );

        // Act & Assert
        expect(find.textContaining('(2mo ago)'), findsOneWidget);
      });
    });

    group('Weight Formatting Tests', () {
      testWidgets('✅ Removes .0 from whole numbers', (tester) async {
        // Arrange
        await tester.pumpWidget(
          wrapWithApp(
            const PreviousDataIndicator(
              previousWeight: 90.0, // Whole number
              previousReps: 10,
              daysSinceLastSession: 5,
            ),
          ),
        );

        // Act & Assert
        expect(find.textContaining('90kg'), findsOneWidget); // NOT 90.0kg
      });

      testWidgets('✅ Shows decimal for fractional weights', (tester) async {
        // Arrange
        await tester.pumpWidget(
          wrapWithApp(
            const PreviousDataIndicator(
              previousWeight: 90.5, // Fractional
              previousReps: 10,
              daysSinceLastSession: 5,
            ),
          ),
        );

        // Act & Assert
        expect(find.textContaining('90.5kg'), findsOneWidget);
      });
    });
  });

  group('PreviousDataBadge Widget Tests', () {
    testWidgets('✅ Renders compact badge variant', (tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithApp(
          const PreviousDataBadge(
            previousWeight: 90.0,
            previousReps: 10,
          ),
        ),
      );

      // Act & Assert
      expect(find.text('90kg×10'), findsOneWidget); // Compact format
      expect(find.byIcon(AppIcons.history), findsOneWidget);
    });
  });

  group('NoPreviousDataIndicator Widget Tests', () {
    testWidgets('✅ Shows "First workout" when isFirstWorkout=true', (tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithApp(
          const NoPreviousDataIndicator(
            isFirstWorkout: true,
          ),
        ),
      );

      // Act & Assert
      expect(find.text('First Workout'), findsOneWidget); // Capital W to match localization
      expect(find.byIcon(AppIcons.newReleases), findsOneWidget);
    });

    testWidgets('✅ Shows nothing when isFirstWorkout=false', (tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithApp(
          const NoPreviousDataIndicator(
            isFirstWorkout: false,
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(NoPreviousDataIndicator), findsOneWidget);
      expect(find.text('First Workout'), findsNothing); // Should not show text
    });
  });
}
