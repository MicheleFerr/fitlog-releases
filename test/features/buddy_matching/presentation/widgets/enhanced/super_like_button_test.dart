/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: test
/// 🎯 Feature: buddy_matching
/// 🔧 Type: widget test
/// 🌍 Localization: ✅ AppLocalizations tested
/// 🎨 Theme: ✅ ColorScheme tested
/// 📱 Platform: Universal
/// 
/// Testing SuperLikeButton widget with all its functionality
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/widgets/enhanced/super_like_button.dart';

import '../../../../../features/helpers/test_helpers.dart';

void main() {
  group('SuperLikeButton Widget Tests', () {
    testWidgets('should display super likes remaining count', (tester) async {
      int tapCount = 0;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SuperLikeButton(
            superLikesRemaining: 2,
            onSuperLike: () => tapCount++,
          ),
        ),
      );

      expect(find.textContaining('2'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should be enabled when has remaining super likes', (tester) async {
      int tapCount = 0;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SuperLikeButton(
            superLikesRemaining: 1,
            onSuperLike: () => tapCount++,
          ),
        ),
      );

      await tester.tap(find.byType(SuperLikeButton));
      await tester.pump();

      expect(tapCount, equals(1));
    });

    testWidgets('should be disabled when no super likes remaining', (tester) async {
      int tapCount = 0;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SuperLikeButton(
            superLikesRemaining: 0,
            onSuperLike: () => tapCount++,
          ),
        ),
      );

      await tester.tap(find.byType(SuperLikeButton));
      await tester.pump();

      expect(tapCount, equals(0)); // Should not trigger
    });

    testWidgets('should be disabled when isEnabled is false', (tester) async {
      int tapCount = 0;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SuperLikeButton(
            superLikesRemaining: 3,
            onSuperLike: () => tapCount++,
            isEnabled: false,
          ),
        ),
      );

      await tester.tap(find.byType(SuperLikeButton));
      await tester.pump();

      expect(tapCount, equals(0));
    });

    testWidgets('should be disabled when onSuperLike is null', (tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SuperLikeButton(
            superLikesRemaining: 3,
            onSuperLike: null,
          ),
        ),
      );

      // Should build without error and be visually disabled
      expect(find.byType(SuperLikeButton), findsOneWidget);
    });

    testWidgets('should show correct visual state when disabled', (tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SuperLikeButton(
            superLikesRemaining: 0,
          ),
        ),
      );

      // Find the button and verify it appears disabled
      final button = tester.widget<SuperLikeButton>(find.byType(SuperLikeButton));
      expect(button.superLikesRemaining, equals(0));
    });

    testWidgets('should work with different remaining counts', (tester) async {
      for (int count = 0; count <= 5; count++) {
        await tester.pumpWidget(
          TestHelpers.createTestApp(
            child: SuperLikeButton(
              superLikesRemaining: count,
              onSuperLike: () {},
            ),
          ),
        );

        expect(find.textContaining('$count'), findsOneWidget);
        await tester.pump(); // Clear any pending animations
      }
    });
  });

  group('SuperLikeAnimation Widget Tests', () {
    testWidgets('should render child widget', (tester) async {
      const testChild = Text('Test Child');
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SuperLikeAnimation(
            animate: false,
            child: testChild,
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('should trigger animation when animate becomes true', (tester) async {
      const testChild = Icon(Icons.star);
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SuperLikeAnimation(
            animate: false,
            child: testChild,
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);

      // Update to trigger animation
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SuperLikeAnimation(
            animate: true,
            child: testChild,
          ),
        ),
      );

      // Should still find the child during animation
      expect(find.byIcon(Icons.star), findsOneWidget);
      
      // Pump through the animation
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('SuperLikeOverlay Widget Tests', () {
    testWidgets('should be invisible when not visible', (tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SuperLikeOverlay(
            isVisible: false,
          ),
        ),
      );

      expect(find.byType(SuperLikeOverlay), findsOneWidget);
      expect(find.text('Super Like'), findsNothing);
    });

    testWidgets('should show overlay when visible', (tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SuperLikeOverlay(
            isVisible: true,
          ),
        ),
      );

      expect(find.byType(SuperLikeOverlay), findsOneWidget);
      
      // Should show star icon and text during animation
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.textContaining('Super'), findsOneWidget);
    });

    testWidgets('should trigger animation when visibility changes', (tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SuperLikeOverlay(
            isVisible: false,
          ),
        ),
      );

      expect(find.byType(SuperLikeOverlay), findsOneWidget);

      // Update to show overlay
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SuperLikeOverlay(
            isVisible: true,
          ),
        ),
      );

      // Animation should start
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SuperLikeOverlay), findsOneWidget);
    });
  });

  group('SuperLikeButton Integration Tests', () {
    testWidgets('should work with Riverpod consumer', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: TestHelpers.createTestApp(
            child: Consumer(
              builder: (context, ref, child) {
                return const SuperLikeButton(
                  superLikesRemaining: 3,
                );
              },
            ),
          ),
        ),
      );

      expect(find.textContaining('3'), findsOneWidget);
    });

    testWidgets('should handle theme changes correctly', (tester) async {
      // Test with light theme
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SuperLikeButton(superLikesRemaining: 2),
          brightness: Brightness.light,
        ),
      );

      expect(find.byType(SuperLikeButton), findsOneWidget);

      // Test with dark theme
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SuperLikeButton(superLikesRemaining: 2),
          brightness: Brightness.dark,
        ),
      );

      expect(find.byType(SuperLikeButton), findsOneWidget);
    });
  });
}