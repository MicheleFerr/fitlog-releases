import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/mixins/safe_set_state_mixin.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Modal for executing a Rest-Pause set with guided flow
///
/// Rest-Pause technique:
/// 1. Perform set to failure at given weight
/// 2. Rest 10-15 seconds
/// 3. Perform another mini-set to failure
/// 4. Repeat until target reps reached or can't continue
class RestPauseExecutionModal extends StatefulWidget {
  const RestPauseExecutionModal({
    super.key,
    required this.exerciseName,
    required this.weight,
    required this.targetReps,
    required this.restPauseSets,
    this.defaultRestSeconds = 15,
  });

  final String exerciseName;
  final double weight;
  final int targetReps;
  final List<RestPauseSet> restPauseSets;
  final int defaultRestSeconds;

  @override
  State<RestPauseExecutionModal> createState() =>
      _RestPauseExecutionModalState();

  /// Show the modal and return updated sets with RPE
  static Future<RestPauseExecutionResult?> show({
    required BuildContext context,
    required String exerciseName,
    required double weight,
    required int targetReps,
    required List<RestPauseSet> restPauseSets,
    int defaultRestSeconds = 15,
  }) {
    return showModalBottomSheet<RestPauseExecutionResult>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => RestPauseExecutionModal(
        exerciseName: exerciseName,
        weight: weight,
        targetReps: targetReps,
        restPauseSets: restPauseSets,
        defaultRestSeconds: defaultRestSeconds,
      ),
    );
  }
}

/// Result of rest-pause execution
class RestPauseExecutionResult {
  RestPauseExecutionResult({required this.completedSets, required this.rpe});

  final List<RestPauseSet> completedSets;
  final int? rpe;
}

enum _ExecutionPhase {
  ready, // Ready to start a set
  resting, // Resting between sets
  logging, // Logging reps for current set
  completed, // All done, showing summary
}

class _RestPauseExecutionModalState extends State<RestPauseExecutionModal>
    with SafeSetStateMixin {
  final List<RestPauseSet> _completedSets = [];
  final TextEditingController _repsController = TextEditingController();

  _ExecutionPhase _phase = _ExecutionPhase.ready;
  int _currentSetIndex = 0;
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  int? _selectedRpe;

  int get _totalRepsCompleted =>
      _completedSets.fold(0, (sum, set) => sum + set.effectiveReps);
  bool get _targetReached => _totalRepsCompleted >= widget.targetReps;

  @override
  void initState() {
    super.initState();
    // Pre-fill with target reps for guidance
    _repsController.text = '';
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _repsController.dispose();
    super.dispose();
  }

  void _startSet() {
    setState(() {
      _phase = _ExecutionPhase.logging;
      _repsController.text = '';
    });
    HapticFeedback.mediumImpact();
  }

  void _logReps() {
    final reps = int.tryParse(_repsController.text.trim());
    if (reps == null || reps <= 0) return;

    final newSet = RestPauseSet(
      reps: reps,
      restSeconds: _currentSetIndex == 0 ? 0 : widget.defaultRestSeconds,
      actualReps: reps,
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    setState(() {
      _completedSets.add(newSet);
      _currentSetIndex++;
    });

    HapticFeedback.lightImpact();

    // Check if target reached or ask to continue
    if (_targetReached) {
      _showCompletion();
    } else {
      _startRest();
    }
  }

  void _startRest() {
    setState(() {
      _phase = _ExecutionPhase.resting;
      _restSecondsRemaining = widget.defaultRestSeconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining <= 1) {
        timer.cancel();
        safeSetState(() {
          _phase = _ExecutionPhase.ready;
        });
        HapticFeedback.heavyImpact();
      } else {
        safeSetState(() {
          _restSecondsRemaining--;
        });
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _phase = _ExecutionPhase.ready;
    });
  }

  void _showCompletion() {
    setState(() {
      _phase = _ExecutionPhase.completed;
    });
  }

  void _finishEarly() {
    if (_completedSets.isEmpty) {
      Navigator.pop(context);
      return;
    }
    _showCompletion();
  }

  void _confirmCompletion() {
    final result = RestPauseExecutionResult(
      completedSets: _completedSets,
      rpe: _selectedRpe,
    );
    Navigator.pop(context, result);
  }

  void _cancelExecution() {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.cancelRestPause),
        content: Text(context.l10n.cancelRestPauseMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.no),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.yes),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _cancelExecution();
        }
      },
      child: Container(
        constraints: BoxConstraints(maxHeight: context.screenHeight * 0.9),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildProgress(context),
                    const SizedBox(height: 16),
                    _buildPhaseContent(context),
                    if (_completedSets.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildCompletedSetsPreview(context),
                    ],
                    SizedBox(height: context.bottomPadding + 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colors.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.timer,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rest-Pause',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.exerciseName} - ${widget.weight}kg',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _cancelExecution,
                icon: const Icon(AppIcons.close),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    final progress = widget.targetReps > 0
        ? (_totalRepsCompleted / widget.targetReps).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.totalReps,
                style: context.textTheme.labelMedium,
              ),
              Text(
                '$_totalRepsCompleted / ${widget.targetReps}',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _targetReached ? context.colors.success : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: context.colors.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(
                _targetReached
                    ? context.colors.success
                    : context.colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseContent(BuildContext context) {
    switch (_phase) {
      case _ExecutionPhase.ready:
        return _buildReadyPhase(context);
      case _ExecutionPhase.resting:
        return _buildRestingPhase(context);
      case _ExecutionPhase.logging:
        return _buildLoggingPhase(context);
      case _ExecutionPhase.completed:
        return _buildCompletedPhase(context);
    }
  }

  Widget _buildReadyPhase(BuildContext context) {
    final setNumber = _currentSetIndex + 1;
    final repsNeeded = widget.targetReps - _totalRepsCompleted;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colors.primary.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              Text(
                'Set $setNumber',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.restPauseGoToFailure,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (repsNeeded > 0) ...[
                const SizedBox(height: 4),
                Text(
                  context.l10n.repsRemaining(repsNeeded),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _startSet,
          icon: const Icon(AppIcons.playCircleOutline),
          label: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              context.l10n.startSet,
              style: context.textTheme.titleMedium,
            ),
          ),
        ),
        if (_completedSets.isNotEmpty) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: _finishEarly,
            child: Text(context.l10n.finishRestPause),
          ),
        ],
      ],
    );
  }

  Widget _buildRestingPhase(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: context.colors.tertiaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colors.tertiary.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              Icon(AppIcons.timer, size: 48, color: context.colors.tertiary),
              const SizedBox(height: 16),
              Text(
                '$_restSecondsRemaining',
                style: context.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.tertiary,
                ),
              ),
              Text(
                context.l10n.secondsRest,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: _skipRest,
          child: Text(context.l10n.skipRest),
        ),
      ],
    );
  }

  Widget _buildLoggingPhase(BuildContext context) {
    return Column(
      children: [
        Text(
          context.l10n.howManyReps,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 120,
          child: TextField(
            controller: _repsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            autofocus: true,
            style: context.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '0',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
            ),
            onSubmitted: (_) => _logReps(),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _logReps,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              context.l10n.logReps,
              style: context.textTheme.titleMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedPhase(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.colors.successContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colors.success.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              Icon(
                AppIcons.checkCircle,
                size: 48,
                color: context.colors.success,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.restPauseCompleted,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.success,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.restPauseSummary(
                  _completedSets.length,
                  _totalRepsCompleted,
                ),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // RPE Selection
        Text(
          context.l10n.howHardWasIt,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildRpeSelector(context),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _confirmCompletion,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.l10n.complete,
              style: context.textTheme.titleMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRpeSelector(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [6, 7, 8, 9, 10].map((rpe) {
        final isSelected = _selectedRpe == rpe;
        return ChoiceChip(
          label: Text('$rpe'),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedRpe = selected ? rpe : null;
            });
            HapticFeedback.selectionClick();
          },
        );
      }).toList(),
    );
  }

  Widget _buildCompletedSetsPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.completedSets,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _completedSets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: context.colors.success.withValues(
                    alpha: 0.2,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                label: Text('${set.effectiveReps} reps'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
