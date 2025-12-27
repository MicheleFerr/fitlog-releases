import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_configuration.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/minimal_set_edit_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Round-based superset configuration sheet.
///
/// Design based on 2025 UX best practices:
/// - List view for 4+ exercises (NN/g recommendation)
/// - PageView for round navigation (max 3-4 swipes)
/// - Immutable state updates (copyWith pattern)
/// - Validation before confirmation
class SupersetRoundConfigSheet extends ConsumerStatefulWidget {
  const SupersetRoundConfigSheet({
    super.key,
    required this.exercises,
    this.initialConfiguration,
    this.initialRounds = 3,
    this.restAfterRound = 90,
    this.scrollController,
  });

  final List<ExerciseDefinition> exercises;
  final SupersetConfiguration? initialConfiguration;
  final int initialRounds;
  final int restAfterRound;
  final ScrollController? scrollController;

  /// Show as modal bottom sheet
  static Future<SupersetConfiguration?> show({
    required BuildContext context,
    required List<ExerciseDefinition> exercises,
    SupersetConfiguration? initialConfiguration,
    int initialRounds = 3,
    int restAfterRound = 90,
  }) {
    return showModalBottomSheet<SupersetConfiguration>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      isDismissible: false,
      enableDrag: false,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, scrollController) => SupersetRoundConfigSheet(
          exercises: exercises,
          initialConfiguration: initialConfiguration,
          initialRounds: initialConfiguration?.rounds.length ?? initialRounds,
          restAfterRound: initialConfiguration?.restAfterRound ?? restAfterRound,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  ConsumerState<SupersetRoundConfigSheet> createState() =>
      _SupersetRoundConfigSheetState();
}

class _SupersetRoundConfigSheetState
    extends ConsumerState<SupersetRoundConfigSheet> {
  late PageController _pageController;
  int _currentRoundIndex = 0;
  late List<_RoundConfig> _rounds;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeRounds();
  }

  void _initializeRounds() {
    final initial = widget.initialConfiguration;
    if (initial != null && initial.rounds.isNotEmpty) {
      _rounds = initial.rounds
          .map((r) => _RoundConfig.fromSupersetRound(r, widget.exercises))
          .toList();
    } else {
      _rounds = List.generate(
        widget.initialRounds,
        (i) => _RoundConfig.defaultFor(widget.exercises, i + 1),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // State update methods (immutable pattern)

  void _updateExercise(int roundIndex, String exerciseId, _CellConfig config) {
    setState(() {
      _rounds = [
        for (int i = 0; i < _rounds.length; i++)
          if (i == roundIndex)
            _rounds[i].copyWithExercise(exerciseId, config)
          else
            _rounds[i]
      ];
      _hasUnsavedChanges = true;
    });
  }

  void _applyExerciseToAllRounds(String exerciseId, _CellConfig config) {
    setState(() {
      _rounds = [
        for (final round in _rounds) round.copyWithExercise(exerciseId, config)
      ];
      _hasUnsavedChanges = true;
    });
    HapticFeedback.mediumImpact();
    SnackBarService.showSuccess(context, context.l10n.appliedToAllRounds);
  }

  void _copyRoundToAll() {
    final sourceRound = _rounds[_currentRoundIndex];
    setState(() {
      _rounds = [
        for (int i = 0; i < _rounds.length; i++)
          _RoundConfig(
            roundNumber: i + 1,
            exercises: Map.from(sourceRound.exercises),
          )
      ];
      _hasUnsavedChanges = true;
    });
    HapticFeedback.mediumImpact();
    SnackBarService.showSuccess(context, context.l10n.copiedToAllRounds);
  }

  void _addRound() {
    if (_rounds.length >= 10) return;
    final lastRound = _rounds.last;
    setState(() {
      _rounds = [
        ..._rounds,
        _RoundConfig(
          roundNumber: _rounds.length + 1,
          exercises: Map.from(lastRound.exercises),
        ),
      ];
      _hasUnsavedChanges = true;
    });
    HapticFeedback.selectionClick();
    // Navigate to new round
    Future.delayed(const Duration(milliseconds: 100), () {
      _pageController.animateToPage(
        _rounds.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _removeRound() {
    if (_rounds.length <= 1) return;
    setState(() {
      _rounds = _rounds.sublist(0, _rounds.length - 1);
      if (_currentRoundIndex >= _rounds.length) {
        _currentRoundIndex = _rounds.length - 1;
      }
      _hasUnsavedChanges = true;
    });
    HapticFeedback.selectionClick();
  }

  bool get _isConfigurationValid {
    return _rounds
        .every((round) => round.exercises.values.every((cfg) => cfg.isValid));
  }

  SupersetConfiguration _buildConfiguration() {
    return SupersetConfiguration(
      exercises: widget.exercises,
      rounds: _rounds
          .map((r) => SupersetRound(
                roundNumber: r.roundNumber,
                exerciseConfigs: r.exercises.map(
                  (id, cfg) => MapEntry(
                    id,
                    SupersetExerciseConfig(
                      exerciseId: id,
                      targetReps: cfg.reps,
                      targetWeight: cfg.weight,
                    ),
                  ),
                ),
              ))
          .toList(),
      restBetweenExercises: 0,
      restAfterRound: widget.restAfterRound,
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.discardChanges),
        content: Text(context.l10n.unsavedChangesWillBeLost),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.discard),
          ),
        ],
      ),
    );
    return shouldDiscard ?? false;
  }

  void _openPicker(ExerciseDefinition exercise, int roundIndex) {
    final config = _rounds[roundIndex].exercises[exercise.id]!;
    final unit = ref.read(measurementUnitProvider);

    // Create ExerciseSet from config
    final exerciseSet = ExerciseSet(
      setNumber: roundIndex + 1,
      weight: config.weight,
      reps: config.reps,
    );

    context.showMinimalSetEditSheet(
      exerciseSet: exerciseSet,
      measurementUnit: unit,
      onSave: (updatedSet) {
        _updateExercise(
          roundIndex,
          exercise.id,
          _CellConfig(
            weight: updatedSet.weight ?? 0,
            reps: updatedSet.reps ?? 10,
          ),
        );
      },
      onApplyToAll: (updatedSet) {
        _applyExerciseToAllRounds(
          exercise.id,
          _CellConfig(
            weight: updatedSet.weight ?? 0,
            reps: updatedSet.reps ?? 10,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const _DragHandle(),
            _buildHeader(),
            _buildRoundIndicator(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _rounds.length,
                onPageChanged: (index) {
                  setState(() => _currentRoundIndex = index);
                  HapticFeedback.selectionClick();
                },
                itemBuilder: (context, roundIndex) {
                  return _RoundPage(
                    key: ValueKey('round_$roundIndex'),
                    exercises: widget.exercises,
                    roundConfig: _rounds[roundIndex],
                    onExerciseTap: (exercise) =>
                        _openPicker(exercise, roundIndex),
                  );
                },
              ),
            ),
            _buildQuickActions(),
            _buildConfirmButton(),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              if (_hasUnsavedChanges) {
                final shouldPop = await _onWillPop();
                if (shouldPop && context.mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(AppIcons.close),
          ),
          const SizedBox(width: 8),
          Icon(AppIcons.link, color: context.colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.configureSuperset,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Dot indicators
          Expanded(
            child: Row(
              children: [
                for (int i = 0; i < _rounds.length; i++)
                  GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      width: i == _currentRoundIndex ? 24 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: i == _currentRoundIndex
                            ? context.colors.primary
                            : context.colors.outlineVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  'Round ${_currentRoundIndex + 1} di ${_rounds.length}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Add/Remove round buttons
          IconButton(
            onPressed: _rounds.length > 1 ? _removeRound : null,
            icon: const Icon(AppIcons.remove),
            tooltip: context.l10n.removeRound,
          ),
          IconButton(
            onPressed: _rounds.length < 10 ? _addRound : null,
            icon: const Icon(AppIcons.add),
            tooltip: context.l10n.addRound,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: OutlinedButton.icon(
        onPressed: _copyRoundToAll,
        icon: const Icon(AppIcons.copy, size: 18),
        label: Text(context.l10n.copyRoundToAll),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    final isValid = _isConfigurationValid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FilledButton.icon(
        onPressed: isValid
            ? () {
                final config = _buildConfiguration();
                Navigator.of(context).pop(config);
                HapticFeedback.mediumImpact();
              }
            : null,
        icon: const Icon(AppIcons.check),
        label: Text(context.l10n.confirm),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 56),
          textStyle: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Private Widgets
// ===========================================================================

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: context.colors.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _RoundPage extends StatelessWidget {
  const _RoundPage({
    super.key,
    required this.exercises,
    required this.roundConfig,
    required this.onExerciseTap,
  });

  final List<ExerciseDefinition> exercises;
  final _RoundConfig roundConfig;
  final void Function(ExerciseDefinition) onExerciseTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final config = roundConfig.exercises[exercise.id] ??
            const _CellConfig(weight: 20, reps: 12);

        return _ExerciseCard(
          key: ValueKey('${exercise.id}_${roundConfig.roundNumber}'),
          exercise: exercise,
          config: config,
          index: index + 1,
          onTap: () => onExerciseTap(exercise),
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    super.key,
    required this.exercise,
    required this.config,
    required this.index,
    required this.onTap,
  });

  final ExerciseDefinition exercise;
  final _CellConfig config;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final showWarning = !config.isValid;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: showWarning
              ? BoxDecoration(
                  border: Border.all(color: context.colors.error, width: 2),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Row(
            children: [
              // Index badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Exercise name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.nome,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showWarning)
                      Text(
                        context.l10n.tapToConfigure,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.error,
                        ),
                      ),
                  ],
                ),
              ),
              // Weight × Reps badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: showWarning
                      ? context.colors.errorContainer
                      : context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${config.weight.toStringAsFixed(config.weight % 1 == 0 ? 0 : 1)} kg × ${config.reps}',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: showWarning
                        ? context.colors.onErrorContainer
                        : context.colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                AppIcons.chevronRight,
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Internal Models
// ===========================================================================

class _RoundConfig {
  final int roundNumber;
  final Map<String, _CellConfig> exercises;

  const _RoundConfig({
    required this.roundNumber,
    required this.exercises,
  });

  _RoundConfig copyWithExercise(String exerciseId, _CellConfig config) {
    return _RoundConfig(
      roundNumber: roundNumber,
      exercises: {...exercises, exerciseId: config},
    );
  }

  factory _RoundConfig.fromSupersetRound(
    SupersetRound round,
    List<ExerciseDefinition> exercises,
  ) {
    final Map<String, _CellConfig> configs = {};
    for (final exercise in exercises) {
      final existingConfig = round.exerciseConfigs[exercise.id];
      configs[exercise.id] = _CellConfig(
        weight: existingConfig?.targetWeight ?? 20,
        reps: existingConfig?.targetReps ?? 12,
      );
    }
    return _RoundConfig(
      roundNumber: round.roundNumber,
      exercises: configs,
    );
  }

  factory _RoundConfig.defaultFor(
      List<ExerciseDefinition> exercises, int roundNumber) {
    return _RoundConfig(
      roundNumber: roundNumber,
      exercises: {
        for (final ex in exercises)
          ex.id: const _CellConfig(weight: 20, reps: 12),
      },
    );
  }
}

class _CellConfig {
  final double weight;
  final int reps;

  const _CellConfig({required this.weight, required this.reps});

  bool get isValid => weight > 0 && reps > 0;
}
