/// Widget tests for the Workout Templates presentation layer.
///
/// Covers:
/// - WorkoutTemplateCard: name, exercise count, estimated duration, callbacks
/// - WorkoutTemplateListItem: list-format rendering, name, exercise count, callbacks
/// - TemplateQuotaIndicator: quota display (used/max), expanded state, upgrade prompt
/// - EmptyTemplatesState: empty-state rendering, create button callback
///
/// Skip conditions:
/// - Navigation tests (GoRouter context required) are skipped; rendering is tested.
/// - WorkoutTemplateCard / WorkoutTemplateListItem use templateStatsProvider
///   (FutureProvider.autoDispose.family) which is overridden with preloadedStats
///   to avoid Firebase/Hive setup in unit/widget tests.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_stats.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/cards/workout_template_card.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/cards/workout_template_list_item.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/common/empty_templates_state.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/template_quota_indicator.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Wraps [child] with ProviderScope + MaterialApp + localizations (no GoRouter).
/// Used for widgets that do not perform navigation.
Widget buildSimpleTestApp({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('it')],
      locale: const Locale('en'),
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

/// Creates a minimal [WorkoutTemplate] for testing.
WorkoutTemplate makeTemplate({
  String id = 'template-1',
  String name = 'Push Day',
  String description = 'Chest and shoulders session',
  int estimatedDuration = 45,
  List<ExerciseTemplate>? exercises,
  String? difficulty,
  String? forkedFromTemplateId,
  String? originalAuthorName,
}) {
  return WorkoutTemplate(
    id: id,
    name: name,
    description: description,
    estimatedDuration: estimatedDuration,
    exercises: exercises ?? [],
    difficulty: difficulty,
    forkedFromTemplateId: forkedFromTemplateId,
    originalAuthorName: originalAuthorName,
  );
}

/// Creates a minimal [ExerciseTemplate] for testing.
ExerciseTemplate makeExerciseTemplate({
  String exerciseId = 'ex-1',
  String exerciseName = 'Bench Press',
  ExerciseCategory category = ExerciseCategory.chest,
}) {
  return ExerciseTemplate(
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    category: category,
  );
}

// ---------------------------------------------------------------------------
// WorkoutTemplateCard tests
// ---------------------------------------------------------------------------

void main() {
  group('WorkoutTemplateCard', () {
    testWidgets('renders template name', (tester) async {
      final template = makeTemplate(name: 'Upper Body Blast');

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: SizedBox(
            width: 300,
            height: 250,
            child: WorkoutTemplateCard(
              template: template,
              onTap: () {},
              onStartWorkout: () {},
              onDuplicate: () {},
              onShare: () {},
              onDelete: () {},
              preloadedStats: TemplateStats.empty(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upper Body Blast'), findsOneWidget);
    });

    testWidgets('renders exercise count in stats row', (tester) async {
      final exercises = [
        makeExerciseTemplate(exerciseId: 'ex-1', exerciseName: 'Bench Press'),
        makeExerciseTemplate(exerciseId: 'ex-2', exerciseName: 'Fly'),
        makeExerciseTemplate(exerciseId: 'ex-3', exerciseName: 'Dips'),
      ];
      final template = makeTemplate(exercises: exercises);

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: SizedBox(
            width: 300,
            height: 250,
            child: WorkoutTemplateCard(
              template: template,
              onTap: () {},
              onStartWorkout: () {},
              onDuplicate: () {},
              onShare: () {},
              onDelete: () {},
              preloadedStats: TemplateStats.empty(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Exercise count is rendered as the number string in the stats row
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders exercise preview text for 3 exercises', (tester) async {
      final exercises = [
        makeExerciseTemplate(exerciseId: 'ex-1', exerciseName: 'Bench Press'),
        makeExerciseTemplate(exerciseId: 'ex-2', exerciseName: 'Fly'),
        makeExerciseTemplate(exerciseId: 'ex-3', exerciseName: 'Dips'),
      ];
      final template = makeTemplate(exercises: exercises);

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: SizedBox(
            width: 300,
            height: 250,
            child: WorkoutTemplateCard(
              template: template,
              onTap: () {},
              onStartWorkout: () {},
              onDuplicate: () {},
              onShare: () {},
              onDelete: () {},
              preloadedStats: TemplateStats.empty(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Bench Press · Fly · Dips'),
        findsOneWidget,
      );
    });

    testWidgets('renders exercise preview with overflow indicator when >3 exercises',
        (tester) async {
      final exercises = List.generate(
        5,
        (i) => makeExerciseTemplate(
          exerciseId: 'ex-$i',
          exerciseName: 'Exercise ${i + 1}',
        ),
      );
      final template = makeTemplate(exercises: exercises);

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: SizedBox(
            width: 300,
            height: 250,
            child: WorkoutTemplateCard(
              template: template,
              onTap: () {},
              onStartWorkout: () {},
              onDuplicate: () {},
              onShare: () {},
              onDelete: () {},
              preloadedStats: TemplateStats.empty(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show first 3 exercises and "+2" overflow
      expect(find.text('Exercise 1 · Exercise 2 · Exercise 3 +2'), findsOneWidget);
    });

    testWidgets('renders estimated duration from template when no stats',
        (tester) async {
      final template = makeTemplate(estimatedDuration: 60);

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: SizedBox(
            width: 300,
            height: 250,
            child: WorkoutTemplateCard(
              template: template,
              onTap: () {},
              onStartWorkout: () {},
              onDuplicate: () {},
              onShare: () {},
              onDelete: () {},
              preloadedStats: TemplateStats.empty(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Estimated duration shows as "60m" in italic style (no real stats)
      expect(find.text('60m'), findsOneWidget);
    });

    testWidgets('renders avg duration from preloaded stats when available',
        (tester) async {
      final stats = TemplateStats(
        lastPerformed: DateTime.now().subtract(const Duration(days: 3)),
        totalCompletions: 5,
        avgDuration: const Duration(minutes: 52),
      );
      final template = makeTemplate(estimatedDuration: 45);

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: SizedBox(
            width: 300,
            height: 250,
            child: WorkoutTemplateCard(
              template: template,
              onTap: () {},
              onStartWorkout: () {},
              onDuplicate: () {},
              onShare: () {},
              onDelete: () {},
              preloadedStats: stats,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Real avg duration shows as "~52m"
      expect(find.text('~52m'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      final template = makeTemplate();

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: SizedBox(
            width: 300,
            height: 250,
            child: WorkoutTemplateCard(
              template: template,
              onTap: () => tapped = true,
              onStartWorkout: () {},
              onDuplicate: () {},
              onShare: () {},
              onDelete: () {},
              preloadedStats: TemplateStats.empty(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(WorkoutTemplateCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders fork attribution badge when forkedFromTemplateId set',
        (tester) async {
      final template = makeTemplate(
        forkedFromTemplateId: 'original-123',
        originalAuthorName: 'Marco',
      );

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: SizedBox(
            width: 300,
            height: 250,
            child: WorkoutTemplateCard(
              template: template,
              onTap: () {},
              onStartWorkout: () {},
              onDuplicate: () {},
              onShare: () {},
              onDelete: () {},
              preloadedStats: TemplateStats.empty(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The fork attribution text contains the original author name
      expect(find.textContaining('Marco'), findsWidgets);
    });

    testWidgets('renders in dark theme without overflow errors', (tester) async {
      final template = makeTemplate(name: 'Night Workout');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            locale: const Locale('en'),
            home: Scaffold(
              body: SizedBox(
                width: 300,
                height: 250,
                child: WorkoutTemplateCard(
                  template: template,
                  onTap: () {},
                  onStartWorkout: () {},
                  onDuplicate: () {},
                  onShare: () {},
                  onDelete: () {},
                  preloadedStats: TemplateStats.empty(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Night Workout'), findsOneWidget);
    });

    testWidgets('renders template with beginner difficulty set explicitly',
        (tester) async {
      final template = makeTemplate(difficulty: 'beginner');

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: SizedBox(
            width: 300,
            height: 250,
            child: WorkoutTemplateCard(
              template: template,
              onTap: () {},
              onStartWorkout: () {},
              onDuplicate: () {},
              onShare: () {},
              onDelete: () {},
              preloadedStats: TemplateStats.empty(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // DifficultyBadge is rendered; the localized "Beginner" label must appear
      expect(find.textContaining('Beginner'), findsOneWidget);
    });

    testWidgets('renders correctly with no exercises (empty template)',
        (tester) async {
      final template = makeTemplate(exercises: []);

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: SizedBox(
            width: 300,
            height: 250,
            child: WorkoutTemplateCard(
              template: template,
              onTap: () {},
              onStartWorkout: () {},
              onDuplicate: () {},
              onShare: () {},
              onDelete: () {},
              preloadedStats: TemplateStats.empty(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Exercise count should show "0"
      expect(find.text('0'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // WorkoutTemplateListItem tests
  // ---------------------------------------------------------------------------

  group('WorkoutTemplateListItem', () {
    testWidgets('renders template name in list format', (tester) async {
      final template = makeTemplate(name: 'Full Body Power');

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: WorkoutTemplateListItem(
            template: template,
            onTap: () {},
            onStartWorkout: () {},
            onDuplicate: () {},
            onShare: () {},
            onDelete: () {},
            preloadedStats: TemplateStats.empty(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Full Body Power'), findsOneWidget);
    });

    testWidgets('renders exercise preview for non-empty exercises', (tester) async {
      final exercises = [
        makeExerciseTemplate(exerciseId: 'ex-1', exerciseName: 'Squat'),
        makeExerciseTemplate(exerciseId: 'ex-2', exerciseName: 'Deadlift'),
      ];
      final template = makeTemplate(exercises: exercises);

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: WorkoutTemplateListItem(
            template: template,
            onTap: () {},
            onStartWorkout: () {},
            onDuplicate: () {},
            onShare: () {},
            onDelete: () {},
            preloadedStats: TemplateStats.empty(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Squat · Deadlift'), findsOneWidget);
    });

    testWidgets('renders exercise count in stats row', (tester) async {
      final exercises = [
        makeExerciseTemplate(exerciseId: 'ex-1', exerciseName: 'Squat'),
        makeExerciseTemplate(exerciseId: 'ex-2', exerciseName: 'Deadlift'),
      ];
      final template = makeTemplate(exercises: exercises);

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: WorkoutTemplateListItem(
            template: template,
            onTap: () {},
            onStartWorkout: () {},
            onDuplicate: () {},
            onShare: () {},
            onDelete: () {},
            preloadedStats: TemplateStats.empty(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders description when no exercises', (tester) async {
      final template = makeTemplate(
        exercises: [],
        description: 'My custom template description',
      );

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: WorkoutTemplateListItem(
            template: template,
            onTap: () {},
            onStartWorkout: () {},
            onDuplicate: () {},
            onShare: () {},
            onDelete: () {},
            preloadedStats: TemplateStats.empty(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My custom template description'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      final template = makeTemplate();

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: WorkoutTemplateListItem(
            template: template,
            onTap: () => tapped = true,
            onStartWorkout: () {},
            onDuplicate: () {},
            onShare: () {},
            onDelete: () {},
            preloadedStats: TemplateStats.empty(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(WorkoutTemplateListItem));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders estimated duration when stats have no completions',
        (tester) async {
      final template = makeTemplate(estimatedDuration: 30);

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: WorkoutTemplateListItem(
            template: template,
            onTap: () {},
            onStartWorkout: () {},
            onDuplicate: () {},
            onShare: () {},
            onDelete: () {},
            preloadedStats: TemplateStats.empty(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('30m'), findsOneWidget);
    });

    testWidgets('renders avg duration from preloaded stats', (tester) async {
      final stats = TemplateStats(
        lastPerformed: DateTime.now().subtract(const Duration(days: 1)),
        totalCompletions: 3,
        avgDuration: const Duration(minutes: 38),
      );
      final template = makeTemplate(estimatedDuration: 45);

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: WorkoutTemplateListItem(
            template: template,
            onTap: () {},
            onStartWorkout: () {},
            onDuplicate: () {},
            onShare: () {},
            onDelete: () {},
            preloadedStats: stats,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('~38m'), findsOneWidget);
    });

    testWidgets('renders fork attribution when forkedFromTemplateId is set',
        (tester) async {
      final template = makeTemplate(
        forkedFromTemplateId: 'source-template-abc',
        originalAuthorName: 'Luca',
      );

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: WorkoutTemplateListItem(
            template: template,
            onTap: () {},
            onStartWorkout: () {},
            onDuplicate: () {},
            onShare: () {},
            onDelete: () {},
            preloadedStats: TemplateStats.empty(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Luca'), findsWidgets);
    });

    testWidgets('renders in Italian locale', (tester) async {
      final template = makeTemplate(name: 'Allenamento Gambe');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('it')],
            locale: const Locale('it'),
            home: Scaffold(
              body: SingleChildScrollView(
                child: WorkoutTemplateListItem(
                  template: template,
                  onTap: () {},
                  onStartWorkout: () {},
                  onDuplicate: () {},
                  onShare: () {},
                  onDelete: () {},
                  preloadedStats: TemplateStats.empty(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Allenamento Gambe'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // TemplateQuotaIndicator tests
  // ---------------------------------------------------------------------------

  group('TemplateQuotaIndicator', () {
    // NOTE: TemplateQuotaIndicator uses context.pushNamed (GoRouter) only inside
    // the upgrade button callback. Since no test below taps that button, all tests
    // use buildSimpleTestApp (plain MaterialApp) to avoid GoRouter lifecycle leaks.

    testWidgets('renders "Template Quota" header text', (tester) async {
      await tester.pumpWidget(
        buildSimpleTestApp(
          child: const TemplateQuotaIndicator(
            usedPrivate: 3,
            usedPublic: 1,
            maxPrivate: 10,
            maxPublic: 5,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Template Quota'), findsOneWidget);
    });

    testWidgets('renders "FREE PLAN" badge', (tester) async {
      await tester.pumpWidget(
        buildSimpleTestApp(
          child: const TemplateQuotaIndicator(
            usedPrivate: 2,
            usedPublic: 0,
            maxPrivate: 10,
            maxPublic: 5,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('FREE PLAN'), findsOneWidget);
    });

    testWidgets('shows quota bar labels when expanded', (tester) async {
      await tester.pumpWidget(
        buildSimpleTestApp(
          child: const TemplateQuotaIndicator(
            usedPrivate: 3,
            usedPublic: 1,
            maxPrivate: 10,
            maxPublic: 5,
            isExpanded: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Private Templates'), findsOneWidget);
      expect(find.text('Public Templates'), findsOneWidget);
    });

    testWidgets('shows "3 / 10" for private quota when expanded', (tester) async {
      await tester.pumpWidget(
        buildSimpleTestApp(
          child: const TemplateQuotaIndicator(
            usedPrivate: 3,
            usedPublic: 1,
            maxPrivate: 10,
            maxPublic: 5,
            isExpanded: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3 / 10'), findsOneWidget);
    });

    testWidgets('shows "1 / 5" for public quota when expanded', (tester) async {
      await tester.pumpWidget(
        buildSimpleTestApp(
          child: const TemplateQuotaIndicator(
            usedPrivate: 3,
            usedPublic: 1,
            maxPrivate: 10,
            maxPublic: 5,
            isExpanded: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 / 5'), findsOneWidget);
    });

    testWidgets('collapse state has expand icon not rotated', (tester) async {
      // AnimatedCrossFade keeps both children in the widget tree but only
      // renders one visible. We verify the collapsed state by checking that the
      // expand/collapse icon has not rotated (turns == 0 when collapsed).
      // Rather than asserting text absence (AnimatedCrossFade renders both
      // children for animation), we verify the isExpanded=false prop is respected
      // by checking the widget is present and rendered without error.
      await tester.pumpWidget(
        buildSimpleTestApp(
          child: const TemplateQuotaIndicator(
            usedPrivate: 3,
            usedPublic: 1,
            maxPrivate: 10,
            maxPublic: 5,
            isExpanded: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In collapsed state the header is still visible; widget renders cleanly.
      expect(find.text('Template Quota'), findsOneWidget);
      // AnimatedRotation with turns=0 (not rotated) indicates collapsed state
      final rotations = tester.widgetList<AnimatedRotation>(
        find.byType(AnimatedRotation),
      );
      expect(rotations.any((r) => r.turns == 0.0), isTrue);
    });

    testWidgets('shows upgrade prompt when private quota is full and expanded',
        (tester) async {
      await tester.pumpWidget(
        buildSimpleTestApp(
          child: const TemplateQuotaIndicator(
            usedPrivate: 10,
            usedPublic: 0,
            maxPrivate: 10,
            maxPublic: 5,
            isExpanded: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Need more templates?'), findsOneWidget);
      expect(
        find.text('Upgrade to Premium for unlimited templates'),
        findsOneWidget,
      );
    });

    testWidgets('shows upgrade prompt when public quota is full and expanded',
        (tester) async {
      await tester.pumpWidget(
        buildSimpleTestApp(
          child: const TemplateQuotaIndicator(
            usedPrivate: 0,
            usedPublic: 5,
            maxPrivate: 10,
            maxPublic: 5,
            isExpanded: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Need more templates?'), findsOneWidget);
    });

    testWidgets('does NOT show upgrade prompt when both quotas have space',
        (tester) async {
      await tester.pumpWidget(
        buildSimpleTestApp(
          child: const TemplateQuotaIndicator(
            usedPrivate: 3,
            usedPublic: 1,
            maxPrivate: 10,
            maxPublic: 5,
            isExpanded: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Need more templates?'), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: TemplateQuotaIndicator(
            usedPrivate: 3,
            usedPublic: 1,
            maxPrivate: 10,
            maxPublic: 5,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TemplateQuotaIndicator));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders LinearProgressIndicator for each quota bar when expanded',
        (tester) async {
      await tester.pumpWidget(
        buildSimpleTestApp(
          child: const TemplateQuotaIndicator(
            usedPrivate: 5,
            usedPublic: 2,
            maxPrivate: 10,
            maxPublic: 5,
            isExpanded: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Two LinearProgressIndicators – one per quota bar
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    });

    testWidgets('renders in dark theme without errors', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            locale: const Locale('en'),
            home: const Scaffold(
              body: SingleChildScrollView(
                child: TemplateQuotaIndicator(
                  usedPrivate: 3,
                  usedPublic: 1,
                  maxPrivate: 10,
                  maxPublic: 5,
                  isExpanded: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Template Quota'), findsOneWidget);
    });

    testWidgets('shows "10 / 10" when private quota is exactly full',
        (tester) async {
      await tester.pumpWidget(
        buildSimpleTestApp(
          child: const TemplateQuotaIndicator(
            usedPrivate: 10,
            usedPublic: 0,
            maxPrivate: 10,
            maxPublic: 5,
            isExpanded: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('10 / 10'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // EmptyTemplatesState tests
  // ---------------------------------------------------------------------------

  group('EmptyTemplatesState', () {
    testWidgets('renders "no templates yet" heading', (tester) async {
      await tester.pumpWidget(
        buildSimpleTestApp(
          child: EmptyTemplatesState(onCreateTap: () {}),
        ),
      );
      await tester.pumpAndSettle();

      // Uses l10n.noTemplatesYet key – in English: "No templates yet"
      expect(find.textContaining('No templates'), findsOneWidget);
    });

    testWidgets('renders create template subtitle text', (tester) async {
      await tester.pumpWidget(
        buildSimpleTestApp(
          child: EmptyTemplatesState(onCreateTap: () {}),
        ),
      );
      await tester.pumpAndSettle();

      // l10n.createFirstTemplate – should contain some guidance text
      expect(find.textContaining('template'), findsWidgets);
    });

    testWidgets('renders a create button', (tester) async {
      await tester.pumpWidget(
        buildSimpleTestApp(
          child: EmptyTemplatesState(onCreateTap: () {}),
        ),
      );
      await tester.pumpAndSettle();

      // FilledButton.icon creates _FilledButtonWithIcon – use find.text() instead
      // of find.byType(FilledButton) as per CLAUDE.md TESTING GOTCHAS
      expect(find.textContaining('Create'), findsAtLeastNWidgets(1));
    });

    testWidgets('calls onCreateTap when create button is tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildSimpleTestApp(
          child: EmptyTemplatesState(onCreateTap: () => tapped = true),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the create template button by its text label
      await tester.tap(find.textContaining('Create').last);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders in Italian locale', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('it')],
            locale: const Locale('it'),
            home: Scaffold(
              body: EmptyTemplatesState(onCreateTap: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Italian locale is loaded; no overflow/assertion errors
      expect(find.byType(EmptyTemplatesState), findsOneWidget);
    });

    testWidgets('renders in dark theme without errors', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            locale: const Locale('en'),
            home: Scaffold(
              body: EmptyTemplatesState(onCreateTap: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyTemplatesState), findsOneWidget);
    });
  });
}
