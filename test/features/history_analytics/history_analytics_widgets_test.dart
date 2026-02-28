/// Widget tests for History and Analytics feature presentation components.
///
/// Covers:
/// - HeroStatCard (analytics/widgets/hero_stat_card.dart)
/// - MiniSparkline (analytics/widgets/mini_sparkline.dart)
/// - TrainingPatternCard (analytics/widgets/training_pattern_card.dart)
/// - TrainingPatternsList (analytics/widgets/training_pattern_card.dart)
/// - ExerciseCompactCard (analytics/widgets/exercise_compact_card.dart)
/// - MetricChip (analytics/widgets/metric_chip.dart)
/// - ChartLegend (analytics/widgets/chart_legend.dart)
/// - ProInsightsBadge (analytics/widgets/pro_insights_badge.dart)
/// - HistoryShareCard (history/widgets/history_share_card.dart)

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/training_pattern.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/landscape_metrics_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/chart_legend.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_compact_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/hero_stat_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/metric_chip.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/mini_sparkline.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/pro_insights_badge.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/training_pattern_card.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/history/presentation/widgets/history_share_card.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/abstractions/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:riverpod/src/framework.dart' show Override;

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

Widget buildTestApp({
  required Widget child,
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('it')],
      locale: locale,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

WorkoutHistoryDetail _buildWorkoutHistoryDetail({
  String name = 'Push Day',
  Duration duration = const Duration(minutes: 75),
  List<ExerciseHistoryDetail> exercises = const [],
}) {
  final now = DateTime(2024, 6, 15, 10, 0);
  return WorkoutHistoryDetail(
    id: 'workout-001',
    userId: 'user-001',
    name: name,
    description: 'A great push session',
    createdAt: now,
    startedAt: now,
    completedAt: now.add(duration),
    updatedAt: now,
    duration: duration,
    exercises: exercises,
    metadata: {},
  );
}

ExerciseHistoryDetail _buildExerciseHistoryDetail({
  String name = 'Bench Press',
  List<SetHistoryDetail> sets = const [],
}) {
  return ExerciseHistoryDetail(
    id: 'ex-001',
    name: name,
    category: 'chest',
    sets: sets,
    exerciseData: {},
  );
}

SetHistoryDetail _buildSet({
  double weight = 80,
  int reps = 8,
  int rpe = 7,
  bool isWarmup = false,
  int setNumber = 1,
}) {
  return SetHistoryDetail(
    setNumber: setNumber,
    weight: weight,
    reps: reps,
    rpe: rpe,
    isWarmup: isWarmup,
  );
}

TrainingPattern _buildPattern({
  PatternType type = PatternType.greatProgression,
  PatternSeverity severity = PatternSeverity.positive,
  double confidence = 0.85,
  Map<String, double> triggerMetrics = const {},
  String? scienceKey,
}) {
  return TrainingPattern(
    type: type,
    severity: severity,
    confidence: confidence,
    titleKey: 'test_title',
    descriptionKey: 'test_description',
    recommendationKey: 'test_recommendation',
    scienceKey: scienceKey,
    sessionsAnalyzed: 8,
    triggerMetrics: triggerMetrics,
  );
}

TrainingPatternResults _buildPatternResults({
  List<TrainingPattern> patterns = const [],
}) {
  return TrainingPatternResults(
    patterns: patterns,
    primaryPattern: patterns.isNotEmpty ? patterns.first : null,
    overallStatus: patterns.isEmpty
        ? TrainingStatus.insufficientData
        : TrainingStatus.progressing,
    analyzedAt: DateTime(2024, 6, 15),
    dataPointsUsed: patterns.isEmpty ? 0 : 10,
  );
}

ExerciseSuggestion _buildSuggestion({
  String name = 'Barbell Row',
  ExerciseDifficulty difficulty = ExerciseDifficulty.intermediate,
  bool hasImageUrl = false,
}) {
  return ExerciseSuggestion(
    exerciseId: 'ex-barbell-row',
    exerciseName: name,
    targetMuscle: 'back',
    priority: 7.5,
    difficulty: difficulty,
    equipment: 'Barbell',
    description: 'Compound pulling movement',
    countingMode: ExerciseCountingMode.weighted,
    exerciseType: 'Compound',
    imageUrl: hasImageUrl ? 'https://example.com/exercise.gif' : null,
  );
}

ExerciseHistory _buildExerciseHistory() {
  final now = DateTime(2024, 6, 15);
  return ExerciseHistory(
    exerciseId: 'bench-press',
    exerciseName: 'Bench Press',
    muscleGroup: 'chest',
    sessions: [
      ExerciseSession(
        exerciseName: 'Bench Press',
        muscleGroup: 'chest',
        sets: [
          AnalyticsSet(
            weight: 80.0,
            reps: 10,
            date: now.subtract(const Duration(days: 14)),
          ),
          AnalyticsSet(
            weight: 85.0,
            reps: 8,
            date: now.subtract(const Duration(days: 7)),
          ),
        ],
        date: now.subtract(const Duration(days: 7)),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Notifier overrides for LandscapeMetricsProvider
// ---------------------------------------------------------------------------

class _EmptyMetricsNotifier extends LandscapeMetricsNotifier {
  @override
  Set<MetricType> build() => {};
}

class _VolumeWeightMetricsNotifier extends LandscapeMetricsNotifier {
  @override
  Set<MetricType> build() => {MetricType.volume, MetricType.weight};
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // HeroStatCard
  // -------------------------------------------------------------------------

  group('HeroStatCard', () {
    testWidgets('renders title, value and subtitle', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const HeroStatCard(
            title: 'Total Volume',
            value: '12,400 kg',
            subtitle: 'Last 30 days',
          ),
        ),
      );

      expect(find.text('Total Volume'), findsOneWidget);
      expect(find.text('12,400 kg'), findsOneWidget);
      expect(find.text('Last 30 days'), findsOneWidget);
    });

    testWidgets('renders with custom gradient colors', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: HeroStatCard(
            title: 'Workouts',
            value: '24',
            subtitle: 'This month',
            gradientColors: [Colors.purple, Colors.blue],
          ),
        ),
      );

      expect(find.text('Workouts'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestApp(
          child: HeroStatCard(
            title: 'Workouts',
            value: '24',
            subtitle: 'This month',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders optional chart child when provided', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const HeroStatCard(
            title: 'Volume',
            value: '8,200 kg',
            subtitle: 'Weekly',
            chart: SizedBox(key: Key('chart-child'), height: 40),
          ),
        ),
      );

      expect(find.byKey(const Key('chart-child')), findsOneWidget);
    });

    testWidgets('renders in dark theme without overflow or error', (tester) async {
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
                child: HeroStatCard(
                  title: 'Strength',
                  value: '1RM: 120 kg',
                  subtitle: 'Personal best',
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Strength'), findsOneWidget);
    });

    testWidgets('renders without onTap (no interaction) without error', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const HeroStatCard(
            title: 'Sets',
            value: '120',
            subtitle: 'All time',
          ),
        ),
      );

      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // MiniSparkline
  // -------------------------------------------------------------------------

  group('MiniSparkline', () {
    testWidgets('renders CustomPaint with enough data points', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const MiniSparkline(
            dataPoints: [60.0, 65.0, 70.0, 68.0, 75.0, 80.0, 78.0, 85.0],
            isPositiveTrend: true,
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows placeholder icon when dataPoints is empty', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const MiniSparkline(dataPoints: [], isPositiveTrend: true),
        ),
      );

      // Placeholder renders a SizedBox with a centered Icon (not a CustomPaint)
      expect(find.byType(Icon), findsWidgets);
      // No SparklinePainter-based CustomPaint created for empty data
      expect(
        find.byWidgetPredicate((w) => w is CustomPaint && w.painter != null),
        findsNothing,
      );
    });

    testWidgets('shows placeholder icon when only one data point', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const MiniSparkline(
            dataPoints: [100.0],
            isPositiveTrend: false,
          ),
        ),
      );

      expect(find.byType(Icon), findsWidgets);
      expect(
        find.byWidgetPredicate((w) => w is CustomPaint && w.painter != null),
        findsNothing,
      );
    });

    testWidgets('renders with negative trend flag without error', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const MiniSparkline(
            dataPoints: [80.0, 75.0, 70.0, 65.0, 60.0],
            isPositiveTrend: false,
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders with custom width and height dimensions', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const MiniSparkline(
            dataPoints: [50.0, 60.0, 55.0],
            isPositiveTrend: true,
            width: 100,
            height: 40,
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('handles flat data where all values are equal', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const MiniSparkline(
            dataPoints: [80.0, 80.0, 80.0, 80.0, 80.0],
            isPositiveTrend: true,
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  // -------------------------------------------------------------------------
  // TrainingPatternCard
  // -------------------------------------------------------------------------

  group('TrainingPatternCard', () {
    testWidgets('mounts without error', (tester) async {
      final pattern = _buildPattern(type: PatternType.greatProgression);

      await tester.pumpWidget(
        buildTestApp(child: TrainingPatternCard(pattern: pattern)),
      );
      await tester.pump();

      expect(find.byType(TrainingPatternCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('starts collapsed by default (initiallyExpanded = false)', (tester) async {
      final pattern = _buildPattern();

      await tester.pumpWidget(
        buildTestApp(child: TrainingPatternCard(pattern: pattern)),
      );
      await tester.pump();

      final card = tester.widget<TrainingPatternCard>(
        find.byType(TrainingPatternCard),
      );
      expect(card.initiallyExpanded, isFalse);
    });

    testWidgets('starts in expanded state when initiallyExpanded is true', (tester) async {
      final pattern = _buildPattern(type: PatternType.fatigueWarning);

      await tester.pumpWidget(
        buildTestApp(
          child: TrainingPatternCard(
            pattern: pattern,
            initiallyExpanded: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // RotationTransition exists (may be >1 due to AnimatedCrossFade internals)
      expect(find.byType(RotationTransition), findsWidgets);
    });

    testWidgets('expands and shows AnimatedCrossFade when tapped', (tester) async {
      final pattern = _buildPattern(type: PatternType.optimalTraining);

      await tester.pumpWidget(
        buildTestApp(child: TrainingPatternCard(pattern: pattern)),
      );
      await tester.pump();

      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedCrossFade), findsOneWidget);
    });

    testWidgets('calls onTap callback when card is tapped', (tester) async {
      var tapped = false;
      final pattern = _buildPattern();

      await tester.pumpWidget(
        buildTestApp(
          child: TrainingPatternCard(
            pattern: pattern,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders all PatternSeverity levels without crashing', (tester) async {
      for (final severity in PatternSeverity.values) {
        final pattern = _buildPattern(
          type: PatternType.adaptation,
          severity: severity,
        );

        await tester.pumpWidget(
          buildTestApp(child: TrainingPatternCard(pattern: pattern)),
        );
        await tester.pump();

        expect(
          tester.takeException(),
          isNull,
          reason: 'PatternSeverity.$severity caused an exception',
        );
      }
    });

    testWidgets('renders all PatternType values without crashing', (tester) async {
      for (final type in PatternType.values) {
        final pattern = _buildPattern(type: type);
        await tester.pumpWidget(
          buildTestApp(child: TrainingPatternCard(pattern: pattern)),
        );
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: 'PatternType.$type caused an exception',
        );
      }
    });

    testWidgets('shows Wrap with metric chips when expanded with triggerMetrics', (tester) async {
      final pattern = _buildPattern(
        triggerMetrics: {'avg_rpe': 8.5, 'volume_change': 0.15},
      );

      await tester.pumpWidget(
        buildTestApp(
          child: TrainingPatternCard(pattern: pattern, initiallyExpanded: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Wrap), findsWidgets);
    });
  });

  // -------------------------------------------------------------------------
  // TrainingPatternsList
  // -------------------------------------------------------------------------

  group('TrainingPatternsList', () {
    testWidgets('renders nothing when no patterns exist', (tester) async {
      final results = _buildPatternResults();

      await tester.pumpWidget(
        buildTestApp(child: TrainingPatternsList(results: results)),
      );
      await tester.pump();

      expect(find.byType(TrainingPatternCard), findsNothing);
    });

    testWidgets('renders at most maxPatterns cards', (tester) async {
      final patterns = [
        _buildPattern(type: PatternType.greatProgression),
        _buildPattern(type: PatternType.adaptation),
        _buildPattern(type: PatternType.volumeSpike),
      ];
      final results = _buildPatternResults(patterns: patterns);

      await tester.pumpWidget(
        buildTestApp(
          child: TrainingPatternsList(results: results, maxPatterns: 2),
        ),
      );
      await tester.pump();

      expect(find.byType(TrainingPatternCard), findsNWidgets(2));
    });

    testWidgets('shows only warning-severity patterns when warningsOnly is true', (tester) async {
      final patterns = [
        _buildPattern(
          type: PatternType.greatProgression,
          severity: PatternSeverity.positive,
        ),
        _buildPattern(
          type: PatternType.fatigueWarning,
          severity: PatternSeverity.warning,
        ),
        _buildPattern(
          type: PatternType.overreachingRisk,
          severity: PatternSeverity.alert,
        ),
      ];
      final results = _buildPatternResults(patterns: patterns);

      await tester.pumpWidget(
        buildTestApp(
          child: TrainingPatternsList(results: results, warningsOnly: true),
        ),
      );
      await tester.pump();

      // warning + alert = 2 cards; positive pattern excluded
      expect(find.byType(TrainingPatternCard), findsNWidgets(2));
    });

    testWidgets('renders nothing when only positive patterns and warningsOnly is true', (tester) async {
      final patterns = [
        _buildPattern(
          type: PatternType.greatProgression,
          severity: PatternSeverity.positive,
        ),
      ];
      final results = _buildPatternResults(patterns: patterns);

      await tester.pumpWidget(
        buildTestApp(
          child: TrainingPatternsList(results: results, warningsOnly: true),
        ),
      );
      await tester.pump();

      expect(find.byType(TrainingPatternCard), findsNothing);
    });

    testWidgets('shows single pattern when exactly one pattern exists', (tester) async {
      final patterns = [_buildPattern(type: PatternType.adaptation)];
      final results = _buildPatternResults(patterns: patterns);

      await tester.pumpWidget(
        buildTestApp(
          child: TrainingPatternsList(results: results),
        ),
      );
      await tester.pump();

      expect(find.byType(TrainingPatternCard), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // ExerciseCompactCard
  // -------------------------------------------------------------------------

  group('ExerciseCompactCard', () {
    testWidgets('renders exercise name', (tester) async {
      final suggestion = _buildSuggestion(name: 'Barbell Row');

      await tester.pumpWidget(
        buildTestApp(
          child: ExerciseCompactCard(
            suggestion: suggestion,
            isInSelectedTemplate: false,
            onAdd: () {},
          ),
        ),
      );

      expect(find.text('Barbell Row'), findsOneWidget);
    });

    testWidgets('shows Add button when not in selected template', (tester) async {
      final suggestion = _buildSuggestion();
      var addCalled = false;

      await tester.pumpWidget(
        buildTestApp(
          child: ExerciseCompactCard(
            suggestion: suggestion,
            isInSelectedTemplate: false,
            onAdd: () => addCalled = true,
          ),
        ),
      );

      // Per CLAUDE.md: use find.text() for FilledButton.icon
      expect(find.text('Add'), findsOneWidget);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(addCalled, isTrue);
    });

    testWidgets('shows Added label when isInSelectedTemplate is true', (tester) async {
      final suggestion = _buildSuggestion();

      await tester.pumpWidget(
        buildTestApp(
          child: ExerciseCompactCard(
            suggestion: suggestion,
            isInSelectedTemplate: true,
            onAdd: () {},
          ),
        ),
      );

      // The l10n key "alreadyAdded" maps to "Added" in app_en.arb
      expect(find.text('Added'), findsOneWidget);
      expect(find.text('Add'), findsNothing);
    });

    testWidgets('shows Beginner difficulty label in English', (tester) async {
      final suggestion = _buildSuggestion(difficulty: ExerciseDifficulty.beginner);

      await tester.pumpWidget(
        buildTestApp(
          child: ExerciseCompactCard(
            suggestion: suggestion,
            isInSelectedTemplate: false,
            onAdd: () {},
          ),
        ),
      );

      expect(find.text('Beginner'), findsOneWidget);
    });

    testWidgets('shows Intermediate difficulty label in English', (tester) async {
      final suggestion = _buildSuggestion(difficulty: ExerciseDifficulty.intermediate);

      await tester.pumpWidget(
        buildTestApp(
          child: ExerciseCompactCard(
            suggestion: suggestion,
            isInSelectedTemplate: false,
            onAdd: () {},
          ),
        ),
      );

      expect(find.text('Intermediate'), findsOneWidget);
    });

    testWidgets('shows Advanced difficulty label in English', (tester) async {
      final suggestion = _buildSuggestion(difficulty: ExerciseDifficulty.advanced);

      await tester.pumpWidget(
        buildTestApp(
          child: ExerciseCompactCard(
            suggestion: suggestion,
            isInSelectedTemplate: false,
            onAdd: () {},
          ),
        ),
      );

      expect(find.text('Advanced'), findsOneWidget);
    });

    testWidgets('renders placeholder image when no imageUrl provided', (tester) async {
      final suggestion = _buildSuggestion(hasImageUrl: false);

      await tester.pumpWidget(
        buildTestApp(
          child: ExerciseCompactCard(
            suggestion: suggestion,
            isInSelectedTemplate: false,
            onAdd: () {},
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('shows Principiante label in Italian locale', (tester) async {
      final suggestion = _buildSuggestion(difficulty: ExerciseDifficulty.beginner);

      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('it'),
          child: ExerciseCompactCard(
            suggestion: suggestion,
            isInSelectedTemplate: false,
            onAdd: () {},
          ),
        ),
      );

      expect(find.text('Principiante'), findsOneWidget);
    });

    testWidgets('shows exercise type and equipment in description row', (tester) async {
      final suggestion = _buildSuggestion();

      await tester.pumpWidget(
        buildTestApp(
          child: ExerciseCompactCard(
            suggestion: suggestion,
            isInSelectedTemplate: false,
            onAdd: () {},
          ),
        ),
      );

      // Should contain "Compound • Barbell" (bullet separator)
      expect(find.textContaining('Compound'), findsOneWidget);
      expect(find.textContaining('Barbell'), findsWidgets);
    });
  });

  // -------------------------------------------------------------------------
  // MetricChip
  // -------------------------------------------------------------------------

  group('MetricChip', () {
    testWidgets('Volume chip is selected by default', (tester) async {
      await tester.pumpWidget(
        buildTestApp(child: const MetricChip(metric: MetricType.volume)),
      );

      final chip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(chip.selected, isTrue);
    });

    testWidgets('Weight chip is unselected by default', (tester) async {
      await tester.pumpWidget(
        buildTestApp(child: const MetricChip(metric: MetricType.weight)),
      );

      final chip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(chip.selected, isFalse);
    });

    testWidgets('Weight chip becomes selected after single tap', (tester) async {
      await tester.pumpWidget(
        buildTestApp(child: const MetricChip(metric: MetricType.weight)),
      );

      // Initially unselected
      FilterChip chip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(chip.selected, isFalse);

      await tester.tap(find.byType(FilterChip));
      await tester.pumpAndSettle();

      chip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(chip.selected, isTrue);
    });

    testWidgets('Volume chip is deselected after tap (toggle off)', (tester) async {
      await tester.pumpWidget(
        buildTestApp(child: const MetricChip(metric: MetricType.volume)),
      );

      // Volume is selected by default — tap to deselect
      await tester.tap(find.byType(FilterChip));
      await tester.pumpAndSettle();

      final chip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(chip.selected, isFalse);
    });

    testWidgets('shows Volume label in English', (tester) async {
      await tester.pumpWidget(
        buildTestApp(child: const MetricChip(metric: MetricType.volume)),
      );

      expect(find.text('Volume'), findsOneWidget);
    });

    testWidgets('shows Weight label in English', (tester) async {
      await tester.pumpWidget(
        buildTestApp(child: const MetricChip(metric: MetricType.weight)),
      );

      expect(find.text('Weight'), findsOneWidget);
    });

    testWidgets('renders all MetricType variants without error', (tester) async {
      for (final metric in MetricType.values) {
        await tester.pumpWidget(
          buildTestApp(child: MetricChip(metric: metric)),
        );
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: 'MetricType.$metric caused an exception',
        );
      }
    });

    testWidgets('two MetricChips in same scope share state correctly', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MetricChip(metric: MetricType.volume),
              MetricChip(metric: MetricType.weight),
            ],
          ),
        ),
      );

      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
      expect(chips.length, equals(2));
      // Volume selected, Weight unselected
      expect(chips[0].selected, isTrue);
      expect(chips[1].selected, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // ChartLegend
  // -------------------------------------------------------------------------

  group('ChartLegend', () {
    testWidgets('renders nothing (SizedBox.shrink) when no metrics selected', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            landscapeMetricsProvider.overrideWith(_EmptyMetricsNotifier.new),
          ],
          child: const ChartLegend(),
        ),
      );

      // Widget resolves to SizedBox.shrink — no Container rendered
      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('renders Volume legend item when volume metric is selected', (tester) async {
      // Default LandscapeMetricsNotifier state includes MetricType.volume
      await tester.pumpWidget(
        buildTestApp(child: const ChartLegend()),
      );

      expect(find.text('Volume'), findsOneWidget);
    });

    testWidgets('renders Volume and Weight items when both metrics selected', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            landscapeMetricsProvider.overrideWith(
              _VolumeWeightMetricsNotifier.new,
            ),
          ],
          child: const ChartLegend(),
        ),
      );

      expect(find.text('Volume'), findsOneWidget);
      expect(find.text('Weight'), findsOneWidget);
    });

    testWidgets('renders color indicators alongside metric labels', (tester) async {
      await tester.pumpWidget(
        buildTestApp(child: const ChartLegend()),
      );

      // Each legend item has a small circular container next to the label
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders in Italian locale without error', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('it'),
          child: const ChartLegend(),
        ),
      );

      expect(tester.takeException(), isNull);
      // Volume is unchanged in Italian
      expect(find.text('Volume'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // ProInsightsBadge
  // -------------------------------------------------------------------------

  group('ProInsightsBadge', () {
    testWidgets('shows PRO label for free users', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [isPremiumUserProvider.overrideWithValue(false)],
          child: ProInsightsBadge(exerciseHistories: const []),
        ),
      );

      expect(find.text('PRO'), findsOneWidget);
    });

    testWidgets('shows PRO label for premium users', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [isPremiumUserProvider.overrideWithValue(true)],
          child: ProInsightsBadge(exerciseHistories: const []),
        ),
      );

      expect(find.text('PRO'), findsOneWidget);
    });

    testWidgets('renders without error when exerciseHistories is empty', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [isPremiumUserProvider.overrideWithValue(false)],
          child: ProInsightsBadge(exerciseHistories: const []),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without error with exercise history data', (tester) async {
      final history = _buildExerciseHistory();

      await tester.pumpWidget(
        buildTestApp(
          overrides: [isPremiumUserProvider.overrideWithValue(true)],
          child: ProInsightsBadge(exerciseHistories: [history]),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('PRO'), findsOneWidget);
    });

    testWidgets('renders a chevron/arrow icon for navigation affordance', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [isPremiumUserProvider.overrideWithValue(false)],
          child: ProInsightsBadge(exerciseHistories: const []),
        ),
      );

      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('renders in Italian locale without error', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('it'),
          overrides: [isPremiumUserProvider.overrideWithValue(false)],
          child: ProInsightsBadge(exerciseHistories: const []),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('PRO'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // HistoryShareCard
  // -------------------------------------------------------------------------

  group('HistoryShareCard', () {
    testWidgets('renders workout name in uppercase', (tester) async {
      final workout = _buildWorkoutHistoryDetail(name: 'Push Day');

      await tester.pumpWidget(
        buildTestApp(child: HistoryShareCard(workout: workout)),
      );

      expect(find.text('PUSH DAY'), findsOneWidget);
    });

    testWidgets('renders FitLog Pro brand label', (tester) async {
      final workout = _buildWorkoutHistoryDetail();

      await tester.pumpWidget(
        buildTestApp(child: HistoryShareCard(workout: workout)),
      );

      expect(find.text('FitLog Pro'), findsOneWidget);
    });

    testWidgets('renders duration as minutes when under one hour', (tester) async {
      final workout = _buildWorkoutHistoryDetail(
        duration: const Duration(minutes: 45),
      );

      await tester.pumpWidget(
        buildTestApp(child: HistoryShareCard(workout: workout)),
      );

      expect(find.text('45m'), findsOneWidget);
    });

    testWidgets('renders duration as hours and minutes when over one hour', (tester) async {
      final workout = _buildWorkoutHistoryDetail(
        duration: const Duration(hours: 1, minutes: 30),
      );

      await tester.pumpWidget(
        buildTestApp(child: HistoryShareCard(workout: workout)),
      );

      expect(find.text('1h 30m'), findsOneWidget);
    });

    testWidgets('renders working sets and excludes warmup sets', (tester) async {
      final sets = [
        _buildSet(weight: 40, reps: 15, rpe: 5, isWarmup: true, setNumber: 1),
        _buildSet(weight: 80, reps: 8, rpe: 7, isWarmup: false, setNumber: 2),
        _buildSet(weight: 85, reps: 6, rpe: 8, isWarmup: false, setNumber: 3),
      ];
      final exercise = _buildExerciseHistoryDetail(
        name: 'Bench Press',
        sets: sets,
      );
      final workout = _buildWorkoutHistoryDetail(exercises: [exercise]);

      // HistoryShareCard has a fixed width of 400px – provide enough space to
      // avoid RenderFlex overflow errors in the test viewport.
      await tester.pumpWidget(
        buildTestApp(
          child: SizedBox(
            width: 460,
            child: HistoryShareCard(workout: workout),
          ),
        ),
      );

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.textContaining('80kg × 8 reps'), findsOneWidget);
      expect(find.textContaining('85kg × 6 reps'), findsOneWidget);
      // Warmup row must not appear
      expect(find.textContaining('40kg × 15 reps'), findsNothing);
    });

    testWidgets('renders set count stat in header area', (tester) async {
      final sets = [
        _buildSet(weight: 100, reps: 5, isWarmup: false, setNumber: 1),
        _buildSet(weight: 100, reps: 5, isWarmup: false, setNumber: 2),
        _buildSet(weight: 100, reps: 5, isWarmup: false, setNumber: 3),
      ];
      final exercise = _buildExerciseHistoryDetail(sets: sets);
      final workout = _buildWorkoutHistoryDetail(exercises: [exercise]);

      await tester.pumpWidget(
        buildTestApp(
          child: SizedBox(
            width: 460,
            child: HistoryShareCard(workout: workout),
          ),
        ),
      );

      expect(find.text('3 set'), findsOneWidget);
    });

    testWidgets('renders RPE badge when rpe is greater than zero', (tester) async {
      final sets = [_buildSet(weight: 80, reps: 8, rpe: 8, isWarmup: false)];
      final exercise = _buildExerciseHistoryDetail(sets: sets);
      final workout = _buildWorkoutHistoryDetail(exercises: [exercise]);

      await tester.pumpWidget(
        buildTestApp(
          child: SizedBox(
            width: 460,
            child: HistoryShareCard(workout: workout),
          ),
        ),
      );

      expect(find.textContaining('RPE 8'), findsWidgets);
    });

    testWidgets('renders formatted completion date', (tester) async {
      final now = DateTime(2024, 6, 15);
      final workout = WorkoutHistoryDetail(
        id: 'w-001',
        userId: 'u-001',
        name: 'Test Workout',
        description: '',
        createdAt: now,
        startedAt: now,
        completedAt: now,
        updatedAt: now,
        duration: const Duration(minutes: 60),
        exercises: const [],
        metadata: const {},
      );

      await tester.pumpWidget(
        buildTestApp(child: HistoryShareCard(workout: workout)),
      );

      expect(find.text('15 Jun 2024'), findsOneWidget);
    });

    testWidgets('renders without error when exercises list is empty', (tester) async {
      final workout = _buildWorkoutHistoryDetail(exercises: const []);

      await tester.pumpWidget(
        buildTestApp(child: HistoryShareCard(workout: workout)),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('PUSH DAY'), findsOneWidget);
    });

    testWidgets('skips exercises that contain only warmup sets', (tester) async {
      final warmupOnlySet = _buildSet(
        weight: 40,
        reps: 15,
        isWarmup: true,
      );
      final exercise = _buildExerciseHistoryDetail(
        name: 'Warmup Exercise',
        sets: [warmupOnlySet],
      );
      final workout = _buildWorkoutHistoryDetail(exercises: [exercise]);

      await tester.pumpWidget(
        buildTestApp(child: HistoryShareCard(workout: workout)),
      );

      // Exercise with only warmup sets must not appear in the share card
      expect(find.text('Warmup Exercise'), findsNothing);
    });

    testWidgets('does not crash when rpe is zero (no RPE badge shown)', (tester) async {
      final sets = [_buildSet(weight: 80, reps: 8, rpe: 0, isWarmup: false)];
      final exercise = _buildExerciseHistoryDetail(sets: sets);
      final workout = _buildWorkoutHistoryDetail(exercises: [exercise]);

      await tester.pumpWidget(
        buildTestApp(child: HistoryShareCard(workout: workout)),
      );

      expect(tester.takeException(), isNull);
      expect(find.textContaining('RPE 0'), findsNothing);
    });

    testWidgets('renders RPE average stat in header when rpe data present', (tester) async {
      final sets = [
        _buildSet(weight: 80, reps: 8, rpe: 8, isWarmup: false),
        _buildSet(weight: 85, reps: 6, rpe: 9, isWarmup: false),
      ];
      final exercise = _buildExerciseHistoryDetail(sets: sets);
      final workout = _buildWorkoutHistoryDetail(exercises: [exercise]);

      await tester.pumpWidget(
        buildTestApp(
          child: SizedBox(
            width: 460,
            child: HistoryShareCard(workout: workout),
          ),
        ),
      );

      // Header shows average RPE stat (e.g., "RPE 8.5")
      expect(find.textContaining('RPE'), findsWidgets);
    });
  });
}
