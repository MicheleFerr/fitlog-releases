import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/template_coverage.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_compact_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/muscle_priority_card.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

// Helper: Create NeglectedMuscle
NeglectedMuscle createNeglectedMuscle({
  required String name,
  required NeglectSeverity severity,
  double volumePercentage = 3.0,
  double priority = 7.0,
}) {
  return NeglectedMuscle(
    muscleName: name,
    volumePercentage: volumePercentage,
    severity: severity,
    priority: priority,
  );
}

// Helper: Create AdjustedNeglectedMuscle
AdjustedNeglectedMuscle createAdjustedMuscle({
  required String name,
  NeglectSeverity severity = NeglectSeverity.high,
  double volumePercentage = 3.0,
  double priority = 7.0,
  TemplateMuscleScore? coverage,
}) {
  return AdjustedNeglectedMuscle(
    original: createNeglectedMuscle(
      name: name,
      severity: severity,
      volumePercentage: volumePercentage,
      priority: priority,
    ),
    coverage: coverage,
  );
}

// Helper: Create ExerciseSuggestion
ExerciseSuggestion createSuggestion({
  required String name,
  required String targetMuscle,
  ExerciseDifficulty difficulty = ExerciseDifficulty.intermediate,
  String equipment = 'Barbell',
  String exerciseType = 'Compound',
  String? imageUrl,
}) {
  return ExerciseSuggestion(
    exerciseId: 'ex-${name.hashCode}',
    exerciseName: name,
    targetMuscle: targetMuscle,
    priority: 7.0,
    difficulty: difficulty,
    equipment: equipment,
    description: 'Test exercise',
    countingMode: ExerciseCountingMode.weighted,
    exerciseType: exerciseType,
    imageUrl: imageUrl,
  );
}

// Helper: Create WorkoutTemplate
WorkoutTemplate createTemplate({
  required String name,
  List<ExerciseTemplate>? exercises,
}) {
  return WorkoutTemplate(
    id: 'template-${name.hashCode}',
    name: name,
    description: 'Test template',
    exercises: exercises ?? [],
  );
}

// Helper: wrap widget with ProviderScope and MaterialApp with l10n
Widget createTestWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: SingleChildScrollView(
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  group('MusclePriorityCard rendering', () {
    testWidgets('shows localized muscle name', (tester) async {
      await tester.pumpWidget(createTestWidget(
        MusclePriorityCard(
          adjustedMuscle: createAdjustedMuscle(name: 'chest'),
          suggestions: const [],
          coverage: TemplateCoverageResult.empty(),
          userTemplates: const [],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Chest'), findsOneWidget);
    });

    testWidgets('shows severity badge', (tester) async {
      await tester.pumpWidget(createTestWidget(
        MusclePriorityCard(
          adjustedMuscle: createAdjustedMuscle(
            name: 'back',
            severity: NeglectSeverity.critical,
          ),
          suggestions: const [],
          coverage: TemplateCoverageResult.empty(),
          userTemplates: const [],
        ),
      ));
      await tester.pumpAndSettle();

      // "Critical" badge text from l10n
      expect(find.textContaining('Critical'), findsOneWidget);
    });

    testWidgets('shows planned badge when muscle has coverage', (tester) async {
      const coverage = TemplateMuscleScore(
        muscleName: 'chest',
        templateCount: 2,
        totalExercises: 3,
        estimatedWeeklySets: 9,
        templateNames: ['Push Day', 'Full Body'],
      );

      await tester.pumpWidget(createTestWidget(
        MusclePriorityCard(
          adjustedMuscle: createAdjustedMuscle(
            name: 'chest',
            coverage: coverage,
          ),
          suggestions: const [],
          coverage: TemplateCoverageResult.empty(),
          userTemplates: const [],
        ),
      ));
      await tester.pumpAndSettle();

      // Planned badge should be visible
      expect(find.textContaining('Planned'), findsOneWidget);
    });

    testWidgets('does NOT show planned badge without coverage', (tester) async {
      await tester.pumpWidget(createTestWidget(
        MusclePriorityCard(
          adjustedMuscle: createAdjustedMuscle(name: 'chest'),
          suggestions: const [],
          coverage: TemplateCoverageResult.empty(),
          userTemplates: const [],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Planned'), findsNothing);
    });

    testWidgets('shows template dropdown when templates available', (tester) async {
      final templates = [
        createTemplate(name: 'Push Day'),
        createTemplate(name: 'Pull Day'),
      ];

      await tester.pumpWidget(createTestWidget(
        MusclePriorityCard(
          adjustedMuscle: createAdjustedMuscle(name: 'chest'),
          suggestions: const [],
          coverage: TemplateCoverageResult.empty(),
          userTemplates: templates,
        ),
      ));
      await tester.pumpAndSettle();

      // Dropdown should show first template
      expect(find.text('Push Day'), findsOneWidget);
    });

    testWidgets('does NOT show template dropdown when no templates', (tester) async {
      await tester.pumpWidget(createTestWidget(
        MusclePriorityCard(
          adjustedMuscle: createAdjustedMuscle(name: 'chest'),
          suggestions: const [],
          coverage: TemplateCoverageResult.empty(),
          userTemplates: const [],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    });

    testWidgets('shows exercise compact cards in horizontal grid', (tester) async {
      final suggestions = [
        createSuggestion(name: 'Bench Press', targetMuscle: 'chest'),
        createSuggestion(name: 'Incline Press', targetMuscle: 'chest'),
        createSuggestion(
          name: 'Cable Fly',
          targetMuscle: 'chest',
          difficulty: ExerciseDifficulty.beginner,
        ),
      ];

      await tester.pumpWidget(createTestWidget(
        MusclePriorityCard(
          adjustedMuscle: createAdjustedMuscle(name: 'chest'),
          suggestions: suggestions,
          coverage: TemplateCoverageResult.empty(),
          userTemplates: [createTemplate(name: 'Push Day')],
        ),
      ));
      await tester.pumpAndSettle();

      // Should find ExerciseCompactCard widgets
      expect(find.byType(ExerciseCompactCard), findsNWidgets(3));
    });

    testWidgets('shows no exercise grid when suggestions empty', (tester) async {
      await tester.pumpWidget(createTestWidget(
        MusclePriorityCard(
          adjustedMuscle: createAdjustedMuscle(name: 'chest'),
          suggestions: const [],
          coverage: TemplateCoverageResult.empty(),
          userTemplates: const [],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ExerciseCompactCard), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('shows info button for priority explanation', (tester) async {
      await tester.pumpWidget(createTestWidget(
        MusclePriorityCard(
          adjustedMuscle: createAdjustedMuscle(name: 'chest'),
          suggestions: const [],
          coverage: TemplateCoverageResult.empty(),
          userTemplates: const [],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(IconButton), findsOneWidget);
    });
  });

  group('ExerciseCompactCard rendering', () {
    testWidgets('shows exercise name and type/equipment', (tester) async {
      final suggestion = createSuggestion(
        name: 'Barbell Row',
        targetMuscle: 'back',
        equipment: 'Barbell',
        exerciseType: 'Compound',
      );

      await tester.pumpWidget(createTestWidget(
        SizedBox(
          height: ExerciseCompactCard.cardHeight,
          child: ExerciseCompactCard(
            suggestion: suggestion,
            isInSelectedTemplate: false,
            onAdd: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Barbell Row'), findsOneWidget);
      // Type and equipment shown together
      expect(find.textContaining('Compound \u2022 Barbell'), findsOneWidget);
    });

    testWidgets('shows "Add" button when not in template', (tester) async {
      final suggestion = createSuggestion(
        name: 'Lat Pulldown',
        targetMuscle: 'back',
      );

      await tester.pumpWidget(createTestWidget(
        SizedBox(
          height: ExerciseCompactCard.cardHeight,
          child: ExerciseCompactCard(
            suggestion: suggestion,
            isInSelectedTemplate: false,
            onAdd: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // FilledButton.icon() creates an internal subtype, so find by text
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('shows "Added" when in selected template', (tester) async {
      final suggestion = createSuggestion(
        name: 'Lat Pulldown',
        targetMuscle: 'back',
      );

      await tester.pumpWidget(createTestWidget(
        SizedBox(
          height: ExerciseCompactCard.cardHeight,
          child: ExerciseCompactCard(
            suggestion: suggestion,
            isInSelectedTemplate: true,
            onAdd: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Added'), findsOneWidget);
    });

    testWidgets('calls onAdd when add button tapped', (tester) async {
      var addCalled = false;
      final suggestion = createSuggestion(
        name: 'Pull-ups',
        targetMuscle: 'back',
      );

      await tester.pumpWidget(createTestWidget(
        SizedBox(
          height: ExerciseCompactCard.cardHeight,
          child: ExerciseCompactCard(
            suggestion: suggestion,
            isInSelectedTemplate: false,
            onAdd: () => addCalled = true,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      expect(addCalled, isTrue);
    });

    testWidgets('add button is disabled when already added', (tester) async {
      final suggestion = createSuggestion(
        name: 'Pull-ups',
        targetMuscle: 'back',
      );

      await tester.pumpWidget(createTestWidget(
        SizedBox(
          height: ExerciseCompactCard.cardHeight,
          child: ExerciseCompactCard(
            suggestion: suggestion,
            isInSelectedTemplate: true,
            onAdd: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // OutlinedButton should be disabled (onPressed: null)
      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows difficulty badge', (tester) async {
      final suggestion = createSuggestion(
        name: 'Deadlift',
        targetMuscle: 'back',
        difficulty: ExerciseDifficulty.advanced,
      );

      await tester.pumpWidget(createTestWidget(
        SizedBox(
          height: ExerciseCompactCard.cardHeight,
          child: ExerciseCompactCard(
            suggestion: suggestion,
            isInSelectedTemplate: false,
            onAdd: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Advanced'), findsOneWidget);
    });
  });

  group('MusclePriorityCard template interaction', () {
    testWidgets('exercise shows as "in template" when ID matches selected template', (tester) async {
      const exerciseId = 'bench-press-123';
      final suggestions = [
        const ExerciseSuggestion(
          exerciseId: exerciseId,
          exerciseName: 'Bench Press',
          targetMuscle: 'chest',
          priority: 7.0,
          difficulty: ExerciseDifficulty.intermediate,
          equipment: 'Barbell',
          description: 'Test',
          countingMode: ExerciseCountingMode.weighted,
          exerciseType: 'Compound',
        ),
        createSuggestion(name: 'Cable Fly', targetMuscle: 'chest'),
      ];

      final template = WorkoutTemplate(
        id: 'push-template',
        name: 'Push Day',
        description: 'Push workout',
        exercises: [
          const ExerciseTemplate(
            exerciseId: exerciseId,
            exerciseName: 'Bench Press',
            category: ExerciseCategory.chest,
            sets: [SetTemplate(setNumber: 1)],
          ),
        ],
      );

      await tester.pumpWidget(createTestWidget(
        MusclePriorityCard(
          adjustedMuscle: createAdjustedMuscle(name: 'chest'),
          suggestions: suggestions,
          coverage: TemplateCoverageResult.empty(),
          userTemplates: [template],
        ),
      ));
      await tester.pumpAndSettle();

      // First exercise (Bench Press) should show "Added" (in template)
      // Second exercise (Cable Fly) should show "Add" (not in template)
      expect(find.text('Added'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });
  });

  group('Template selection defaults', () {
    testWidgets('defaults to first template when no last-used saved', (tester) async {
      final templates = [
        createTemplate(name: 'Push Day'),
        createTemplate(name: 'Pull Day'),
      ];

      await tester.pumpWidget(createTestWidget(
        MusclePriorityCard(
          adjustedMuscle: createAdjustedMuscle(name: 'chest'),
          suggestions: const [],
          coverage: TemplateCoverageResult.empty(),
          userTemplates: templates,
        ),
      ));
      await tester.pumpAndSettle();

      // First template (Push Day) should be selected by default
      expect(find.text('Push Day'), findsOneWidget);
    });
  });
}
