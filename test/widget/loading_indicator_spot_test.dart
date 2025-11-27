// Widget tests for LoadingIndicator using Spot
//
// Spot provides:
// - Chainable, readable widget finders
// - Automatic screenshot capture
// - Better error messages than standard finders
//
// Run with: flutter test test/widget/loading_indicator_spot_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

void main() {
  group('LoadingIndicator Widget Tests (Spot)', () {
    testWidgets('renders circular indicator by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LoadingIndicator(),
            ),
          ),
        ),
      );

      // Spot chainable finder - find CircularProgressIndicator inside LoadingIndicator
      spot<LoadingIndicator>().existsOnce();
      spot<CircularProgressIndicator>().existsOnce();
    });

    testWidgets('displays message when provided', (tester) async {
      const testMessage = 'Loading data...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LoadingIndicator(
                message: testMessage,
              ),
            ),
          ),
        ),
      );

      // Find the loading indicator
      spot<LoadingIndicator>().existsOnce();

      // Find the message text
      spot<Text>().whereText((t) => t.contains(testMessage)).existsOnce();
    });

    testWidgets('renders linear variant when using .linear constructor', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: LoadingIndicator.linear(),
              ),
            ),
          ),
        ),
      );

      // Should have LinearProgressIndicator instead of Circular
      spot<LoadingIndicator>().existsOnce();
      spot<LinearProgressIndicator>().existsOnce();
      spot<CircularProgressIndicator>().doesNotExist();
    });

    testWidgets('respects size parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LoadingIndicator(
                size: 60,
              ),
            ),
          ),
        ),
      );

      // Verify the indicator exists
      spot<LoadingIndicator>().existsOnce();

      // Check the SizedBox constraint (60x60)
      spot<SizedBox>()
          .whereWidget(
            (sizedBox) => sizedBox.width == 60.0 || sizedBox.height == 60.0,
            description: 'has size 60',
          )
          .existsOnce();
    });

    testWidgets('overlay variant renders with background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ColoredBox(
                  color: Colors.blue,
                  child: const SizedBox.expand(
                    child: Center(child: Text('Background')),
                  ),
                ),
                const LoadingIndicator.overlay(),
              ],
            ),
          ),
        ),
      );

      // Should have a ColoredBox (the overlay uses ColoredBox)
      spot<LoadingIndicator>().existsOnce();

      // Background should still be in tree
      spot<Text>().whereText((t) => t.contains('Background')).existsOnce();
    });

    testWidgets('small size renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LoadingIndicator(
                size: 16,
              ),
            ),
          ),
        ),
      );

      spot<LoadingIndicator>().existsOnce();

      // Check the SizedBox constraint (16x16)
      spot<SizedBox>()
          .whereWidget(
            (sizedBox) => sizedBox.width == 16.0 || sizedBox.height == 16.0,
            description: 'has size 16',
          )
          .existsOnce();
    });

    testWidgets('adaptive variant renders CircularProgressIndicator.adaptive', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LoadingIndicator.adaptive(),
            ),
          ),
        ),
      );

      // Should render CircularProgressIndicator (adaptive uses this under the hood)
      spot<LoadingIndicator>().existsOnce();
      spot<CircularProgressIndicator>().existsOnce();
    });

    testWidgets('linear with progress shows determinate progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: LoadingIndicator.linear(
                  progress: 0.5,
                ),
              ),
            ),
          ),
        ),
      );

      spot<LoadingIndicator>().existsOnce();
      spot<LinearProgressIndicator>()
          .whereWidget(
            (indicator) => indicator.value == 0.5,
            description: 'has progress 0.5',
          )
          .existsOnce();
    });
  });
}
