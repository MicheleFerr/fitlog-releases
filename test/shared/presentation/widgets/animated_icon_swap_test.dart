import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/animated_icon_swap.dart';

void main() {
  group('AnimatedIconSwap', () {
    testWidgets('shows outlined icon when not pressed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedIconSwap(
              outlinedIcon: Icons.analytics_outlined,
              filledIcon: Icons.analytics,
              isPressed: false,
            ),
          ),
        ),
      );

      // Find icon with outlined variant
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon && widget.icon == Icons.analytics_outlined,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows filled icon when pressed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedIconSwap(
              outlinedIcon: Icons.analytics_outlined,
              filledIcon: Icons.analytics,
              isPressed: true,
            ),
          ),
        ),
      );

      // Find icon with filled variant
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.analytics,
        ),
        findsOneWidget,
      );
    });

    testWidgets('swaps icon when isPressed changes', (tester) async {
      var isPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    AnimatedIconSwap(
                      outlinedIcon: Icons.settings_outlined,
                      filledIcon: Icons.settings,
                      isPressed: isPressed,
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => isPressed = !isPressed),
                      child: const Text('Toggle'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Initially outlined
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon && widget.icon == Icons.settings_outlined,
        ),
        findsOneWidget,
      );

      // Toggle to pressed
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      // Now filled
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.settings,
        ),
        findsOneWidget,
      );
    });

    testWidgets('applies custom color', (tester) async {
      const customColor = Colors.purple;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedIconSwap(
              outlinedIcon: Icons.history_outlined,
              filledIcon: Icons.history,
              isPressed: false,
              color: customColor,
            ),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(
        find.byWidgetPredicate((widget) => widget is Icon),
      );

      expect(iconWidget.color, customColor);
    });

    testWidgets('applies custom size', (tester) async {
      const customSize = 32.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedIconSwap(
              outlinedIcon: Icons.insights_outlined,
              filledIcon: Icons.insights,
              isPressed: false,
              size: customSize,
            ),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(
        find.byWidgetPredicate((widget) => widget is Icon),
      );

      expect(iconWidget.size, customSize);
    });
  });
}
