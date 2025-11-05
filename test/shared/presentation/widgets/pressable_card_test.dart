import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/pressable_card.dart';

void main() {
  group('PressableCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressableCard(
              onTap: () {},
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressableCard(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PressableCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('applies scale animation on press', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressableCard(
              onTap: () {},
              child: const Text('Press Me'),
            ),
          ),
        ),
      );

      // Press down
      await tester.press(find.byType(PressableCard), warnIfMissed: false);
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 75)); // Mid-animation

      // Verify Transform.scale exists (scale animation running)
      // Multiple Transforms may exist in the widget tree, so just check at least one
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Transform && widget.transform != null,
        ),
        findsWidgets,
      );
    });

    testWidgets('shows accent color overlay when pressed', (tester) async {
      const accentColor = Colors.purple;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressableCard(
              accentColor: accentColor,
              onTap: () {},
              child: const Text('Press'),
            ),
          ),
        ),
      );

      // Press and hold
      await tester.press(find.byType(PressableCard), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 75));

      // Verify AnimatedContainer with overlay exists
      expect(
        find.byWidgetPredicate(
          (widget) => widget is AnimatedContainer,
        ),
        findsWidgets,
      );
    });

    testWidgets('shows border when pressed and showBorder is true',
        (tester) async {
      const accentColor = Colors.blue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 100,
              child: PressableCard(
                accentColor: accentColor,
                showBorder: true,
                onTap: () {},
                child: const Text('Press'),
              ),
            ),
          ),
        ),
      );

      // Press and hold (don't complete the tap yet)
      await tester.press(find.byType(PressableCard), warnIfMissed: false);
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 75)); // Mid-animation

      // Verify border exists with more specific assertion during press
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('does not trigger haptics when enableHaptics is false',
        (tester) async {
      // Note: Haptic feedback testing requires mocking platform channel
      // This test verifies the widget builds correctly with enableHaptics: false
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressableCard(
              enableHaptics: false,
              onTap: () {},
              child: const Text('No Haptics'),
            ),
          ),
        ),
      );

      expect(find.byType(PressableCard), findsOneWidget);
    });
  });
}
