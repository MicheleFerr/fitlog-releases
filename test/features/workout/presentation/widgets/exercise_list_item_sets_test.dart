import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/set_display_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_sets.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

class _SyncAppConfigNotifier extends AppConfigNotifier {
  _SyncAppConfigNotifier(this._config);

  final AppConfig _config;

  @override
  AppConfig build() => _config;
}

Widget _buildTestApp({required Widget child, required AppConfig config}) {
  return ProviderScope(
    overrides: [
      appConfigProvider.overrideWith(() => _SyncAppConfigNotifier(config)),
      setDisplayProvider.overrideWithValue(SetDisplayMode.comfortable),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('it', 'IT')],
      home: Scaffold(body: child),
    ),
  );
}

Exercise _buildExercise() {
  return Exercise(
    id: 'exercise-1',
    name: 'Bench Press',
    type: ExerciseType.single,
    category: ExerciseCategory.chest,
    sets: [ExerciseSet(id: 'set-1', setNumber: 1, weight: 80, reps: 8)],
  );
}

Exercise _buildExerciseWithTwoSets() {
  return Exercise(
    id: 'exercise-1',
    name: 'Bench Press',
    type: ExerciseType.single,
    category: ExerciseCategory.chest,
    sets: [
      ExerciseSet(id: 'set-1', setNumber: 1, weight: 80, reps: 8),
      ExerciseSet(id: 'set-2', setNumber: 2, weight: 80, reps: 8),
    ],
  );
}

class _ExerciseListItemSetsHarness extends StatefulWidget {
  const _ExerciseListItemSetsHarness({
    required this.initialExercise,
    required this.config,
    required this.onExerciseChanged,
  });

  final Exercise initialExercise;
  final AppConfig config;
  final ValueChanged<Exercise> onExerciseChanged;

  @override
  State<_ExerciseListItemSetsHarness> createState() =>
      _ExerciseListItemSetsHarnessState();
}

class _ExerciseListItemSetsHarnessState
    extends State<_ExerciseListItemSetsHarness> {
  late Exercise _exercise;

  @override
  void initState() {
    super.initState();
    _exercise = widget.initialExercise;
  }

  void _updateExercise(Exercise updatedExercise) {
    setState(() {
      _exercise = updatedExercise;
    });
    widget.onExerciseChanged(updatedExercise);
  }

  void _updateSet(ExerciseSet updatedSet) {
    final setIndex = _exercise.sets.indexWhere(
      (set) => set.id == updatedSet.id,
    );
    if (setIndex == -1) return;

    final updatedSets = List<ExerciseSet>.from(_exercise.sets);
    updatedSets[setIndex] = updatedSet;
    _updateExercise(_exercise.copyWith(sets: updatedSets));
  }

  @override
  Widget build(BuildContext context) {
    return ExerciseListItemSets(
      exercise: _exercise,
      config: widget.config,
      onExerciseUpdate: _updateExercise,
      onSetToggleComplete: _updateSet,
      onStartRestTimer: (_, __) {},
      onExecuteDropSet: (_) {},
      onExecuteRestPause: (_) {},
      onCollapseExercise: () {},
    );
  }
}

void main() {
  LeakTesting.settings = LeakTesting.settings.withIgnoredAll();

  const trackedConfig = AppConfig(
    setDurationTracking: true,
    rpeTracking: false,
  );
  const autoAdjustConfig = AppConfig(
    rpeTracking: true,
    autoAdjustWeightFromRpe: true,
    autoAdjustRestFromRpe: false,
    setDurationTracking: false,
  );

  group('ExerciseListItemSets', () {
    testWidgets('shows inline hint before the first set starts', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          config: trackedConfig,
          child: ExerciseListItemSets(
            exercise: _buildExercise(),
            config: trackedConfig,
            onExerciseUpdate: (_) {},
            onSetToggleComplete: (_) {},
            onStartRestTimer: (_, __) {},
            onExecuteDropSet: (_) {},
            onExecuteRestPause: (_) {},
            onCollapseExercise: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Start tracking duration'), findsOneWidget);
      expect(
        find.text(
          'Before your first set, tap Start Set so the duration is saved correctly.',
        ),
        findsOneWidget,
      );
      expect(find.text('Start Set'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('keeps completion non-blocking and shows a soft warning', (
      tester,
    ) async {
      ExerciseSet? completedSet;

      await tester.pumpWidget(
        _buildTestApp(
          config: trackedConfig,
          child: ExerciseListItemSets(
            exercise: _buildExercise(),
            config: trackedConfig,
            onExerciseUpdate: (_) {},
            onSetToggleComplete: (set) => completedSet = set,
            onStartRestTimer: (_, __) {},
            onExecuteDropSet: (_) {},
            onExecuteRestPause: (_) {},
            onCollapseExercise: () {},
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('8 reps'));
      await tester.pump();

      expect(completedSet?.isCompleted, isTrue);
      expect(
        find.text(
          'First set duration was estimated. For better accuracy next time, tap Start Set before you begin.',
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets(
      'keeps the set completed when RPE 10 triggers weight auto-adjustment',
      (tester) async {
        var latestExercise = _buildExerciseWithTwoSets();
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _buildTestApp(
            config: autoAdjustConfig,
            child: _ExerciseListItemSetsHarness(
              initialExercise: latestExercise,
              config: autoAdjustConfig,
              onExerciseChanged: (exercise) => latestExercise = exercise,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('8 reps').first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Max'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Confirm Set'));
        await tester.pumpAndSettle();

        expect(latestExercise.sets.first.isCompleted, isTrue);
        expect(latestExercise.sets.first.completedAt, isNotNull);
        expect(latestExercise.sets.first.rpe, 10);
        expect(latestExercise.sets.first.actualReps, 8);
        expect(latestExercise.sets[1].weight, 77.5);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  });
}
