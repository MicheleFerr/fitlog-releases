// Golden tests for TemplateCard widget using standard Flutter golden testing
//
// Run with: flutter test test/golden/template_card_golden_test.dart
// Update goldens: flutter test test/golden/template_card_golden_test.dart --update-goldens
//
// NOTE: Using standard Flutter goldens instead of Alchemist because
// leak_tracker_flutter_testing conflicts with Alchemist's pumpAndSettle.
// TemplateCard has fade-in animations so we use tester.pump() instead.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/template_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Creates a test WorkoutTemplate with configurable properties
///
/// Tags determine auto-detected category:
/// - 'strength', 'power', 'muscle' -> TemplateCategory.strength (red strip)
/// - 'cardio', 'hiit', 'endurance' -> TemplateCategory.cardio (blue strip)
/// - 'flexibility', 'mobility', 'yoga' -> TemplateCategory.flexibility (green strip)
/// - mixed tags -> TemplateCategory.hybrid (purple strip)
///
/// Difficulty is auto-detected from exercise count and sets:
/// - 1-3 exercises or 1-12 sets -> beginner (green badge)
/// - 4-5 exercises or 13-20 sets -> intermediate (amber badge)
/// - 6-8 exercises or 21-30 sets -> advanced (red badge)
/// - 9+ exercises or 31+ sets -> expert (purple badge)
WorkoutTemplate createTestTemplate({
  String name = 'Push Day',
  List<String> tags = const ['strength', 'upper'],
  String? difficulty,
  int exerciseCount = 4,
  int setsPerExercise = 3,
  int estimatedDuration = 45,
}) {
  return WorkoutTemplate(
    id: 'test-template-id',
    name: name,
    description: 'Test template description',
    exercises: List.generate(
      exerciseCount,
      (i) => ExerciseTemplate(
        exerciseId: 'exercise-$i',
        exerciseName: 'Exercise ${i + 1}',
        category: ExerciseCategory.chest,
        sets: List.generate(
          setsPerExercise,
          (s) => SetTemplate(setNumber: s + 1, targetReps: 10, targetWeight: 50),
        ),
      ),
    ),
    estimatedDuration: estimatedDuration,
    isPublic: false,
    userId: 'test-user',
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 15),
    tags: tags,
    difficulty: difficulty,
  );
}

/// Wraps widget in MaterialApp with localization and Riverpod
Widget createTestWidget({
  required Widget child,
  bool isDarkMode = false,
}) {
  return ProviderScope(
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: isDarkMode
          ? ThemeData.dark().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6750A4),
                brightness: Brightness.dark,
              ),
            )
          : ThemeData.light().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6750A4),
              ),
            ),
      home: Scaffold(
        body: Center(child: child),
      ),
    ),
  );
}

void main() {
  group('TemplateCard Golden Tests - Light Theme', () {
    testWidgets('Strength category - Intermediate - Light', (tester) async {
      // 4-5 exercises = intermediate difficulty (auto-detected)
      // 'strength' tag = strength category (red strip)
      final template = createTestTemplate(
        name: 'Push Day',
        tags: ['strength', 'upper'],
        exerciseCount: 4,
        setsPerExercise: 4, // 16 total sets = intermediate
      );

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          width: 400, // Fixed width for consistent golden
          child: TemplateCard(
            template: template,
            onTap: () {},
          ),
        ),
      ));

      // Pump animation frames (TemplateCard has 500ms fade-in)
      await tester.pump(const Duration(milliseconds: 600));

      await expectLater(
        find.byType(TemplateCard),
        matchesGoldenFile('goldens/template_card_strength_intermediate_light.png'),
      );
    });

    testWidgets('Cardio category - Beginner - Light', (tester) async {
      // 2 exercises = beginner difficulty (auto-detected)
      // 'cardio' tag = cardio category (blue strip)
      final template = createTestTemplate(
        name: 'HIIT Cardio',
        tags: ['cardio', 'hiit'],
        exerciseCount: 2,
        setsPerExercise: 3, // 6 total sets = beginner
        estimatedDuration: 30,
      );

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          width: 400,
          child: TemplateCard(
            template: template,
            onTap: () {},
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 600));

      await expectLater(
        find.byType(TemplateCard),
        matchesGoldenFile('goldens/template_card_cardio_beginner_light.png'),
      );
    });

    testWidgets('Flexibility category - Advanced - Light', (tester) async {
      // 7 exercises = advanced difficulty (auto-detected)
      // 'flexibility' tag = flexibility category (green strip)
      final template = createTestTemplate(
        name: 'Yoga Flow',
        tags: ['flexibility', 'yoga', 'mobility'],
        exerciseCount: 7,
        setsPerExercise: 4, // 28 total sets = advanced
        estimatedDuration: 60,
      );

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          width: 400,
          child: TemplateCard(
            template: template,
            onTap: () {},
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 600));

      await expectLater(
        find.byType(TemplateCard),
        matchesGoldenFile('goldens/template_card_flexibility_advanced_light.png'),
      );
    });

    testWidgets('Hybrid category - Expert - Light', (tester) async {
      // 10 exercises = expert difficulty (auto-detected)
      // mixed tags = hybrid category (purple strip)
      final template = createTestTemplate(
        name: 'CrossFit WOD',
        tags: ['strength', 'cardio', 'crossfit'], // Mixed = hybrid
        exerciseCount: 10,
        setsPerExercise: 4, // 40 total sets = expert
        estimatedDuration: 75,
      );

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          width: 400,
          child: TemplateCard(
            template: template,
            onTap: () {},
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 600));

      await expectLater(
        find.byType(TemplateCard),
        matchesGoldenFile('goldens/template_card_hybrid_expert_light.png'),
      );
    });

    testWidgets('Empty exercises - Light', (tester) async {
      final template = createTestTemplate(
        name: 'Empty Template',
        exerciseCount: 0,
      );

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          width: 400,
          child: TemplateCard(
            template: template,
            onTap: () {},
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 600));

      await expectLater(
        find.byType(TemplateCard),
        matchesGoldenFile('goldens/template_card_empty_light.png'),
      );
    });

    testWidgets('Long name truncation - Light', (tester) async {
      final template = createTestTemplate(
        name: 'This Is A Very Long Template Name That Should Be Truncated',
        exerciseCount: 5,
      );

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          width: 400,
          child: TemplateCard(
            template: template,
            onTap: () {},
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 600));

      await expectLater(
        find.byType(TemplateCard),
        matchesGoldenFile('goldens/template_card_long_name_light.png'),
      );
    });
  });

  group('TemplateCard Golden Tests - Dark Theme', () {
    testWidgets('Strength category - Dark', (tester) async {
      final template = createTestTemplate(
        name: 'Pull Day',
        tags: ['strength', 'back'],
        exerciseCount: 4,
        setsPerExercise: 4,
      );

      await tester.pumpWidget(createTestWidget(
        isDarkMode: true,
        child: SizedBox(
          width: 400,
          child: TemplateCard(
            template: template,
            onTap: () {},
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 600));

      await expectLater(
        find.byType(TemplateCard),
        matchesGoldenFile('goldens/template_card_strength_dark.png'),
      );
    });

    testWidgets('Cardio category - Dark', (tester) async {
      final template = createTestTemplate(
        name: 'Running',
        tags: ['cardio', 'endurance'],
        exerciseCount: 2,
        setsPerExercise: 3,
      );

      await tester.pumpWidget(createTestWidget(
        isDarkMode: true,
        child: SizedBox(
          width: 400,
          child: TemplateCard(
            template: template,
            onTap: () {},
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 600));

      await expectLater(
        find.byType(TemplateCard),
        matchesGoldenFile('goldens/template_card_cardio_dark.png'),
      );
    });

    testWidgets('Flexibility category - Dark', (tester) async {
      final template = createTestTemplate(
        name: 'Stretching',
        tags: ['flexibility', 'recovery'],
        exerciseCount: 7,
        setsPerExercise: 4,
      );

      await tester.pumpWidget(createTestWidget(
        isDarkMode: true,
        child: SizedBox(
          width: 400,
          child: TemplateCard(
            template: template,
            onTap: () {},
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 600));

      await expectLater(
        find.byType(TemplateCard),
        matchesGoldenFile('goldens/template_card_flexibility_dark.png'),
      );
    });

    testWidgets('Hybrid category - Expert - Dark', (tester) async {
      final template = createTestTemplate(
        name: 'AMRAP Challenge',
        tags: ['strength', 'cardio', 'functional'],
        exerciseCount: 10,
        setsPerExercise: 4,
      );

      await tester.pumpWidget(createTestWidget(
        isDarkMode: true,
        child: SizedBox(
          width: 400,
          child: TemplateCard(
            template: template,
            onTap: () {},
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 600));

      await expectLater(
        find.byType(TemplateCard),
        matchesGoldenFile('goldens/template_card_hybrid_dark.png'),
      );
    });
  });

  group('TemplateCard Golden Tests - Difficulty Badges', () {
    testWidgets('Beginner badge - Light', (tester) async {
      // 2 exercises with 3 sets each = 6 total sets = beginner
      final template = createTestTemplate(
        name: 'Beginner Workout',
        exerciseCount: 2,
        setsPerExercise: 3,
      );

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          width: 400,
          child: TemplateCard(
            template: template,
            onTap: () {},
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 600));

      await expectLater(
        find.byType(TemplateCard),
        matchesGoldenFile('goldens/template_card_beginner_badge.png'),
      );
    });

    testWidgets('Expert badge - Light', (tester) async {
      // 10 exercises = expert difficulty (auto-detected)
      final template = createTestTemplate(
        name: 'Expert Workout',
        exerciseCount: 10,
        setsPerExercise: 4, // 40 total sets = expert
      );

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          width: 400,
          child: TemplateCard(
            template: template,
            onTap: () {},
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 600));

      await expectLater(
        find.byType(TemplateCard),
        matchesGoldenFile('goldens/template_card_expert_badge.png'),
      );
    });
  });
}
