// Golden tests for LoadingIndicator widget using standard Flutter golden testing
//
// Run with: flutter test test/golden/loading_indicator_golden_test.dart
// Update goldens: flutter test test/golden/loading_indicator_golden_test.dart --update-goldens
//
// NOTE: Using standard Flutter goldens instead of Alchemist because
// leak_tracker_flutter_testing conflicts with Alchemist's pumpAndSettle.
// The alchemist package is still available for other widgets that don't animate.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

void main() {
  group('LoadingIndicator Golden Tests - Light Theme', () {
    testWidgets('Circular default - Light', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
            ),
          ),
          home: const Scaffold(
            body: Center(
              child: LoadingIndicator(),
            ),
          ),
        ),
      );

      await tester.pump(); // Single frame for animated widget

      await expectLater(
        find.byType(LoadingIndicator),
        matchesGoldenFile('goldens/loading_circular_light.png'),
      );
    });

    testWidgets('Circular with message - Light', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
            ),
          ),
          home: const Scaffold(
            body: Center(
              child: LoadingIndicator(
                message: 'Loading workout...',
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      await expectLater(
        find.byType(LoadingIndicator),
        matchesGoldenFile('goldens/loading_circular_message_light.png'),
      );
    });

    testWidgets('Linear default - Light', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
            ),
          ),
          home: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: LoadingIndicator.linear(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      await expectLater(
        find.byType(LoadingIndicator),
        matchesGoldenFile('goldens/loading_linear_light.png'),
      );
    });

    testWidgets('Linear with progress - Light', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
            ),
          ),
          home: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: LoadingIndicator.linear(
                  progress: 0.65,
                  message: '65% complete',
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      await expectLater(
        find.byType(LoadingIndicator),
        matchesGoldenFile('goldens/loading_linear_progress_light.png'),
      );
    });

    testWidgets('Adaptive - Light', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
            ),
          ),
          home: const Scaffold(
            body: Center(
              child: LoadingIndicator.adaptive(
                message: 'Loading...',
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      await expectLater(
        find.byType(LoadingIndicator),
        matchesGoldenFile('goldens/loading_adaptive_light.png'),
      );
    });
  });

  group('LoadingIndicator Golden Tests - Dark Theme', () {
    testWidgets('Circular default - Dark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
              brightness: Brightness.dark,
            ),
          ),
          home: const Scaffold(
            body: Center(
              child: LoadingIndicator(),
            ),
          ),
        ),
      );

      await tester.pump();

      await expectLater(
        find.byType(LoadingIndicator),
        matchesGoldenFile('goldens/loading_circular_dark.png'),
      );
    });

    testWidgets('Circular with message - Dark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
              brightness: Brightness.dark,
            ),
          ),
          home: const Scaffold(
            body: Center(
              child: LoadingIndicator(
                message: 'Loading workout...',
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      await expectLater(
        find.byType(LoadingIndicator),
        matchesGoldenFile('goldens/loading_circular_message_dark.png'),
      );
    });

    testWidgets('Linear with progress - Dark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
              brightness: Brightness.dark,
            ),
          ),
          home: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: LoadingIndicator.linear(
                  progress: 0.65,
                  message: '65% complete',
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      await expectLater(
        find.byType(LoadingIndicator),
        matchesGoldenFile('goldens/loading_linear_progress_dark.png'),
      );
    });

    testWidgets('Adaptive - Dark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
              brightness: Brightness.dark,
            ),
          ),
          home: const Scaffold(
            body: Center(
              child: LoadingIndicator.adaptive(
                message: 'Loading...',
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      await expectLater(
        find.byType(LoadingIndicator),
        matchesGoldenFile('goldens/loading_adaptive_dark.png'),
      );
    });
  });

  group('LoadingIndicator Golden Tests - Size Variants', () {
    testWidgets('Small size (16)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
            ),
          ),
          home: const Scaffold(
            body: Center(
              child: LoadingIndicator(
                size: 16,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      await expectLater(
        find.byType(LoadingIndicator),
        matchesGoldenFile('goldens/loading_size_small.png'),
      );
    });

    testWidgets('Large size (60)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
            ),
          ),
          home: const Scaffold(
            body: Center(
              child: LoadingIndicator(
                size: 60,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      await expectLater(
        find.byType(LoadingIndicator),
        matchesGoldenFile('goldens/loading_size_large.png'),
      );
    });
  });
}
