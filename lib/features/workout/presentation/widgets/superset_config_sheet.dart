import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    as ExerciseDB;
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_configuration.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/minimal_set_edit_sheet.dart';
import 'package:gymbro_flutter_new/shared/domain/utils/weight_helper.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Compact table-based configuration sheet for supersets.
/// Follows mobile UX best practices:
/// - 48dp touch targets
/// - Fixed first column (exercise names)
/// - Horizontal scroll for 4+ rounds
/// - Quick actions (copy R1 to all, progression)
class SupersetConfigSheet extends ConsumerStatefulWidget {
  const SupersetConfigSheet({
    super.key,
    required this.exercises,
    required this.onConfigurationComplete,
    this.initialConfiguration,
    this.initialRounds = 3,
    this.initialRestAfterRound = 90,
  });

  final List<ExerciseDB.Exercise> exercises;
  final Function(SupersetConfiguration) onConfigurationComplete;
  final SupersetConfiguration? initialConfiguration;
  final int initialRounds;
  final int initialRestAfterRound;

  /// Show as modal bottom sheet
  static Future<SupersetConfiguration?> show({
    required BuildContext context,
    required List<ExerciseDB.Exercise> exercises,
    SupersetConfiguration? initialConfiguration,
    int initialRounds = 3,
    int initialRestAfterRound = 90,
  }) {
    return showModalBottomSheet<SupersetConfiguration>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SupersetConfigSheet(
            exercises: exercises,
            initialConfiguration: initialConfiguration,
            initialRounds: initialConfiguration?.rounds.length ?? initialRounds,
            initialRestAfterRound: initialConfiguration?.restAfterRound ?? initialRestAfterRound,
            onConfigurationComplete: (config) {
              Navigator.of(context).pop(config);
            },
          ),
        ),
      ),
    );
  }

  @override
  ConsumerState<SupersetConfigSheet> createState() =>
      _SupersetConfigSheetState();
}

class _SupersetConfigSheetState extends ConsumerState<SupersetConfigSheet> {
  late int _roundCount;
  late int _restAfterRound;
  late Map<String, Map<int, _CellConfig>> _cellConfigs;
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _roundCount = widget.initialRounds;
    _restAfterRound = widget.initialRestAfterRound;
    _initializeCellConfigs();
  }

  void _initializeCellConfigs() {
    _cellConfigs = {};
    final initialConfig = widget.initialConfiguration;

    for (final exercise in widget.exercises) {
      _cellConfigs[exercise.id] = {};
      for (int r = 1; r <= _roundCount; r++) {
        // Try to get values from initial configuration
        double weight = 20.0;
        int reps = 12;

        if (initialConfig != null && r <= initialConfig.rounds.length) {
          final roundConfig = initialConfig.rounds[r - 1];
          final exerciseConfig = roundConfig.exerciseConfigs[exercise.id];
          if (exerciseConfig != null) {
            weight = exerciseConfig.targetWeight ?? 20.0;
            reps = exerciseConfig.targetReps;
          }
        }

        _cellConfigs[exercise.id]![r] = _CellConfig(
          weight: weight,
          reps: reps,
        );
      }
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _updateRoundCount(int delta) {
    final newCount = (_roundCount + delta).clamp(1, 10);
    if (newCount == _roundCount) return;

    setState(() {
      if (delta > 0) {
        // Adding rounds - copy from last round
        for (final exercise in widget.exercises) {
          final lastConfig = _cellConfigs[exercise.id]![_roundCount]!;
          _cellConfigs[exercise.id]![newCount] = _CellConfig(
            weight: lastConfig.weight,
            reps: lastConfig.reps,
          );
        }
      } else {
        // Removing rounds
        for (final exercise in widget.exercises) {
          _cellConfigs[exercise.id]!.remove(_roundCount);
        }
      }
      _roundCount = newCount;
    });
    HapticFeedback.selectionClick();
  }

  void _copyR1ToAll() {
    setState(() {
      for (final exercise in widget.exercises) {
        final r1Config = _cellConfigs[exercise.id]![1]!;
        for (int r = 2; r <= _roundCount; r++) {
          _cellConfigs[exercise.id]![r] = _CellConfig(
            weight: r1Config.weight,
            reps: r1Config.reps,
          );
        }
      }
    });
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.copiedToAllRounds),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _updateCell(String exerciseId, int round, _CellConfig config) {
    setState(() {
      _cellConfigs[exerciseId]![round] = config;
    });
  }

  void _updateCellForAllRounds(String exerciseId, _CellConfig config) {
    setState(() {
      for (int r = 1; r <= _roundCount; r++) {
        _cellConfigs[exerciseId]![r] = config;
      }
    });
  }

  SupersetConfiguration _buildConfiguration() {
    final rounds = <SupersetRound>[];
    for (int r = 1; r <= _roundCount; r++) {
      final exerciseConfigs = <String, SupersetExerciseConfig>{};
      for (final exercise in widget.exercises) {
        final cellConfig = _cellConfigs[exercise.id]![r]!;
        exerciseConfigs[exercise.id] = SupersetExerciseConfig(
          exerciseId: exercise.id,
          targetReps: cellConfig.reps,
          targetWeight: cellConfig.weight,
        );
      }
      rounds.add(SupersetRound(
        roundNumber: r,
        exerciseConfigs: exerciseConfigs,
      ));
    }

    return SupersetConfiguration(
      exercises: widget.exercises,
      rounds: rounds,
      restBetweenExercises: 0,
      restAfterRound: _restAfterRound,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Drag handle
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(AppIcons.link, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                context.l10n.configureSuperset,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Round counter
        _buildRoundCounter(theme),

        const SizedBox(height: 16),

        // Table
        Expanded(
          child: _buildTable(theme),
        ),

        // Quick actions
        _buildQuickActions(theme),

        // Rest time
        _buildRestTimeSetting(theme),

        // Create button
        _buildCreateButton(theme),

        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
      ],
    );
  }

  Widget _buildRoundCounter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Rounds:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _buildCounterButton(
            icon: AppIcons.remove,
            onTap: _roundCount > 1 ? () => _updateRoundCount(-1) : null,
            theme: theme,
          ),
          Container(
            width: 48,
            alignment: Alignment.center,
            child: Text(
              '$_roundCount',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          _buildCounterButton(
            icon: AppIcons.add,
            onTap: _roundCount < 10 ? () => _updateRoundCount(1) : null,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onTap,
    required ThemeData theme,
  }) {
    return Material(
      color: onTap != null
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: onTap != null
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildTable(ThemeData theme) {
    final unit = ref.watch(measurementUnitProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed column - Exercise names
          _buildFixedColumn(theme),

          // Scrollable columns - Rounds
          Expanded(
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _roundCount,
                  (index) => _buildRoundColumn(index + 1, theme, unit),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Text(
            context.l10n.exercise,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // Exercise rows
        ...widget.exercises.map((exercise) => Container(
              height: 56, // 48dp touch + 8dp padding
              width: 120,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Text(
                exercise.nome,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )),
      ],
    );
  }

  Widget _buildRoundColumn(int round, ThemeData theme, String unit) {
    final isFirstRound = round == 1;

    return Column(
      children: [
        // Header
        Container(
          height: 40,
          width: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFirstRound
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'R$round',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isFirstRound
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // Cells
        ...widget.exercises.map((exercise) {
          final config = _cellConfigs[exercise.id]![round]!;
          final isPlaceholder = round > 1 && _isSameAsR1(exercise.id, round);

          return _buildCell(
            exercise: exercise,
            round: round,
            config: config,
            isPlaceholder: isPlaceholder,
            theme: theme,
            unit: unit,
          );
        }),
      ],
    );
  }

  bool _isSameAsR1(String exerciseId, int round) {
    final r1 = _cellConfigs[exerciseId]![1]!;
    final current = _cellConfigs[exerciseId]![round]!;
    return r1.weight == current.weight && r1.reps == current.reps;
  }

  Widget _buildCell({
    required ExerciseDB.Exercise exercise,
    required int round,
    required _CellConfig config,
    required bool isPlaceholder,
    required ThemeData theme,
    required String unit,
  }) {
    final displayWeight = config.weight.toDisplayUnit(unit);
    final weightText = WeightHelper.formatPickerWeight(displayWeight, unit);

    return Container(
      height: 56,
      width: 80,
      padding: const EdgeInsets.all(4),
      child: Material(
        color: isPlaceholder
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _showCellPicker(exercise, round, config, unit),
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: isPlaceholder
                ? Text(
                    '···',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  )
                : Text(
                    '$weightText×${config.reps}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _showCellPicker(
    ExerciseDB.Exercise exercise,
    int round,
    _CellConfig currentConfig,
    String unit,
  ) {
    // Get previous round config if available
    ExerciseSet? previousSet;
    if (round > 1) {
      final previousConfig = _cellConfigs[exercise.id]![round - 1];
      if (previousConfig != null) {
        previousSet = ExerciseSet(
          setNumber: round - 1,
          weight: previousConfig.weight,
          reps: previousConfig.reps,
        );
      }
    }

    // Create ExerciseSet from current config
    final exerciseSet = ExerciseSet(
      setNumber: round,
      weight: currentConfig.weight,
      reps: currentConfig.reps,
    );

    context.showMinimalSetEditSheet(
      exerciseSet: exerciseSet,
      measurementUnit: unit,
      currentSetIndex: round - 1,
      totalSets: _roundCount,
      previousSet: previousSet,
      onSave: (updatedSet) {
        _updateCell(
          exercise.id,
          round,
          _CellConfig(
            weight: updatedSet.weight ?? 0,
            reps: updatedSet.reps ?? 10,
          ),
        );
      },
      onApplyToAll: _roundCount > 1
          ? (updatedSet) {
              _updateCellForAllRounds(
                exercise.id,
                _CellConfig(
                  weight: updatedSet.weight ?? 0,
                  reps: updatedSet.reps ?? 10,
                ),
              );
            }
          : null,
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _copyR1ToAll,
              icon: Icon(AppIcons.copy, size: 18),
              label: Text(context.l10n.copyR1ToAll),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestTimeSetting(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            AppIcons.timer,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.restAfterRound,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: _showRestTimePicker,
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Text(
                  '${_restAfterRound}s',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRestTimePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _RestTimePicker(
        currentValue: _restAfterRound,
        onSelected: (value) {
          setState(() => _restAfterRound = value);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildCreateButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            final config = _buildConfiguration();
            widget.onConfigurationComplete(config);
            HapticFeedback.mediumImpact();
          },
          icon: Icon(AppIcons.check),
          label: Text(context.l10n.createSuperset),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal cell configuration
class _CellConfig {
  _CellConfig({required this.weight, required this.reps});

  final double weight;
  final int reps;

  _CellConfig copyWith({double? weight, int? reps}) {
    return _CellConfig(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
    );
  }
}

/// Rest time picker
class _RestTimePicker extends StatelessWidget {
  const _RestTimePicker({
    required this.currentValue,
    required this.onSelected,
  });

  final int currentValue;
  final Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presets = [30, 45, 60, 90, 120, 180];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            context.l10n.restAfterRound,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: presets.map((seconds) {
              final isSelected = seconds == currentValue;
              final label = seconds >= 60
                  ? '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}'
                  : '${seconds}s';

              return FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) => onSelected(seconds),
              );
            }).toList(),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
