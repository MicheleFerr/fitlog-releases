/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test/golden
/// 🎯 Feature: testing
/// 🔧 Type: golden test
///
/// Design System Golden Tests
///
/// Testa i component principali del design system per prevenire
/// regressioni visuali accidentali.
///
/// ## Come Eseguire:
///
/// ```bash
/// # Run tests
/// flutter test test/golden/design_system_test.dart
///
/// # Update goldens (dopo modifiche intenzionali)
/// flutter test --update-goldens test/golden/design_system_test.dart
/// ```
///
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

void main() {
  group('Design System Golden Tests - Light Theme', () {
    testWidgets('Standard Card - Light', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
            ),
          ),
          home: Scaffold(
            body: Center(
              child: _StandardCardTest(),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(_StandardCardTest),
        matchesGoldenFile('goldens/standard_card_light.png'),
      );
    });

    testWidgets('Elevated Button - Light', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
            ),
          ),
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: AppSpacing.button,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Primary Button'),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ElevatedButton),
        matchesGoldenFile('goldens/elevated_button_light.png'),
      );
    });

    testWidgets('Semantic Colors - Light', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
            ),
          ),
          home: const Scaffold(
            body: Center(
              child: _SemanticColorsTest(),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(_SemanticColorsTest),
        matchesGoldenFile('goldens/semantic_colors_light.png'),
      );
    });

    testWidgets('Loading Indicator - Light', (tester) async {
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

      // Avanza un frame per vedere lo stato iniziale
      await tester.pump();

      await expectLater(
        find.byType(LoadingIndicator),
        matchesGoldenFile('goldens/loading_indicator_light.png'),
      );
    });
  });

  group('Design System Golden Tests - Dark Theme', () {
    testWidgets('Standard Card - Dark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
              brightness: Brightness.dark,
            ),
          ),
          home: Scaffold(
            body: Center(
              child: _StandardCardTest(),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(_StandardCardTest),
        matchesGoldenFile('goldens/standard_card_dark.png'),
      );
    });

    testWidgets('Elevated Button - Dark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
              brightness: Brightness.dark,
            ),
          ),
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: AppSpacing.button,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Primary Button'),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ElevatedButton),
        matchesGoldenFile('goldens/elevated_button_dark.png'),
      );
    });

    testWidgets('Semantic Colors - Dark', (tester) async {
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
              child: _SemanticColorsTest(),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(_SemanticColorsTest),
        matchesGoldenFile('goldens/semantic_colors_dark.png'),
      );
    });

    testWidgets('Loading Indicator - Dark', (tester) async {
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

      // Avanza un frame per vedere lo stato iniziale
      await tester.pump();

      await expectLater(
        find.byType(LoadingIndicator),
        matchesGoldenFile('goldens/loading_indicator_dark.png'),
      );
    });
  });
}

// ========================================
// Test Components
// ========================================

class _StandardCardTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Standard Card',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'This is a standard card with default padding and styling.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: context.colors.primary),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    'Info icon with text',
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SemanticColorsTest extends StatelessWidget {
  const _SemanticColorsTest();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _semanticColorCard(context, 'Success', context.successColor, context.textOnSuccess),
          const SizedBox(height: AppSpacing.xs),
          _semanticColorCard(context, 'Error', context.errorColor, context.textOnError),
          const SizedBox(height: AppSpacing.xs),
          _semanticColorCard(context, 'Warning', context.warningColor, context.textOnWarning),
          const SizedBox(height: AppSpacing.xs),
          _semanticColorCard(context, 'Info', context.infoColor, context.textOnInfo),
        ],
      ),
    );
  }

  Widget _semanticColorCard(BuildContext context, String label, Color bg, Color fg) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: fg, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
