import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/mixins/safe_set_state_mixin.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

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
    this.resumeFromSets,
    this.showTutorialOnFirstUse = false,
    this.onTutorialSeen,
  });

  final String exerciseName;
  final double weight;
  final int targetReps;
  final List<RestPauseSet> restPauseSets;
  final int defaultRestSeconds;
  final List<RestPauseSet>? resumeFromSets;
  final bool showTutorialOnFirstUse;
  final VoidCallback? onTutorialSeen;

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
    List<RestPauseSet>? resumeFromSets,
    bool showTutorialOnFirstUse = false,
    VoidCallback? onTutorialSeen,
  }) {
    return ModalService.showSheet<RestPauseExecutionResult>(context,
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
        resumeFromSets: resumeFromSets,
        showTutorialOnFirstUse: showTutorialOnFirstUse,
        onTutorialSeen: onTutorialSeen,
      ),
    );
  }
}

/// Result of rest-pause execution
class RestPauseExecutionResult {
  RestPauseExecutionResult({
    required this.completedSets,
    required this.rpe,
    this.isPaused = false,
  });

  final List<RestPauseSet> completedSets;
  final int? rpe;
  final bool isPaused;
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
  final Stopwatch _executionStopwatch = Stopwatch();

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
    _repsController.text = '';
    _executionStopwatch.start();

    // Resume from paused state if provided
    if (widget.resumeFromSets != null && widget.resumeFromSets!.isNotEmpty) {
      _completedSets.addAll(widget.resumeFromSets!);
      _currentSetIndex = _completedSets.length;
    }

    // Show tutorial on first use
    if (widget.showTutorialOnFirstUse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showHelpDialog();
          widget.onTutorialSeen?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _repsController.dispose();
    _executionStopwatch.stop();
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

  void _applyQuickReps(int reps) {
    _repsController.text = reps.toString();
    _logReps();
  }

  List<int> _calculateQuickSuggestions() {
    final repsRemaining = widget.targetReps - _totalRepsCompleted;
    if (_completedSets.isEmpty) {
      // First set: suggest typical starting values
      return [8, 6, 5];
    }
    final lastReps = _completedSets.last.effectiveReps;
    // Decreasing pattern typical of rest-pause
    final suggestions = <int>{
      (lastReps * 0.75).round().clamp(1, lastReps - 1),
      (lastReps * 0.5).round().clamp(1, lastReps - 1),
      repsRemaining.clamp(1, 10),
    };
    // Remove duplicates and sort descending
    final list = suggestions.where((r) => r > 0).toList()
      ..sort((a, b) => b.compareTo(a));
    return list.take(3).toList();
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

  void _adjustRestTimer(int delta) {
    setState(() {
      _restSecondsRemaining = (_restSecondsRemaining + delta).clamp(5, 60);
    });
    HapticFeedback.selectionClick();
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _phase = _ExecutionPhase.ready;
    });
  }

  void _showCompletion() {
    _executionStopwatch.stop();
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
    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.pauseOrCancel),
        content: Text(context.l10n.pauseOrCancelMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: Text(context.l10n.cancelWorkout),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'pause'),
            child: Text(context.l10n.pauseAndContinueLater),
          ),
        ],
      ),
    ).then((result) {
      if (!mounted) return;
      if (result == 'cancel') {
        Navigator.pop(context);
      } else if (result == 'pause') {
        // Return partial result with isPaused flag
        final partialResult = RestPauseExecutionResult(
          completedSets: _completedSets,
          rpe: null,
          isPaused: true,
        );
        Navigator.pop(context, partialResult);
      }
    });
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(AppIcons.info, color: context.colors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(context.l10n.restPauseHelpTitle)),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            context.l10n.restPauseHelpBody,
            style: context.textTheme.bodyMedium,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.ok),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  double _calculateVolume() {
    return widget.weight * _totalRepsCompleted;
  }

  int _calculateIntensityBoost() {
    // Rest-pause typically provides 20-30% more volume than traditional sets
    // Calculate based on additional sets beyond the first
    if (_completedSets.length <= 1) return 0;
    final extraSets = _completedSets.length - 1;
    return (extraSets * 15).clamp(0, 50);
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
              // Help button
              IconButton(
                onPressed: _showHelpDialog,
                icon: const Icon(AppIcons.help),
                tooltip: context.l10n.restPauseHelpTitle,
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
          // Progress bar with milestones
          _buildProgressBarWithMilestones(context, progress),
        ],
      ),
    );
  }

  Widget _buildProgressBarWithMilestones(
    BuildContext context,
    double progress,
  ) {
    final milestones = [0.25, 0.5, 0.75, 1.0];
    final progressColor =
        _targetReached ? context.colors.success : context.colors.primary;
    final backgroundColor = context.colors.outline.withValues(alpha: 0.2);

    return SizedBox(
      height: 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Progress bar
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          // Milestone markers
          Row(
            children: milestones.map((milestone) {
              final isReached = progress >= milestone;
              return Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 3,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isReached
                          ? context.colors.onPrimary
                          : context.colors.outline.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
              );
            }).toList(),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      context.l10n.restPauseGoToFailure,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: context.l10n.goToFailureHelp,
                    child: Icon(
                      AppIcons.info,
                      size: 18,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
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
              const SizedBox(height: 16),
              // Timer adjustment controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: _restSecondsRemaining > 5
                        ? () => _adjustRestTimer(-5)
                        : null,
                    icon: const Icon(AppIcons.remove),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          context.colors.tertiary.withValues(alpha: 0.2),
                      foregroundColor: context.colors.tertiary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      context.l10n.adjustTimer,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: _restSecondsRemaining < 60
                        ? () => _adjustRestTimer(5)
                        : null,
                    icon: const Icon(AppIcons.add),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          context.colors.tertiary.withValues(alpha: 0.2),
                      foregroundColor: context.colors.tertiary,
                    ),
                  ),
                ],
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
    final suggestions = _calculateQuickSuggestions();

    return Column(
      children: [
        Text(
          context.l10n.howManyReps,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // Quick rep selection chips
        if (suggestions.isNotEmpty) ...[
          Text(
            context.l10n.quickRepSelection,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: suggestions.map((reps) {
              return ActionChip(
                label: Text(
                  '$reps',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _applyQuickReps(reps),
                backgroundColor:
                    context.colors.primaryContainer.withValues(alpha: 0.5),
                side: BorderSide(
                  color: context.colors.primary.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            '— or —',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
        ],
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
            decoration: const InputDecoration(
              hintText: '0',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
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
        const SizedBox(height: 16),
        // Stats summary
        _buildStatsRow(context),
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

  Widget _buildStatsRow(BuildContext context) {
    final volume = _calculateVolume();
    final duration = _executionStopwatch.elapsed;
    final intensityBoost = _calculateIntensityBoost();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            icon: AppIcons.fitnessCenter,
            label: context.l10n.totalVolume,
            value: '${volume.toStringAsFixed(0)} kg',
          ),
          Container(
            width: 1,
            height: 40,
            color: context.colors.outline.withValues(alpha: 0.3),
          ),
          _buildStatItem(
            context,
            icon: AppIcons.timer,
            label: context.l10n.timeUnderTension,
            value: _formatDuration(duration),
          ),
          if (intensityBoost > 0) ...[
            Container(
              width: 1,
              height: 40,
              color: context.colors.outline.withValues(alpha: 0.3),
            ),
            _buildStatItem(
              context,
              icon: AppIcons.trendingUp,
              label: context.l10n.intensityBoost,
              value: '+$intensityBoost%',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: context.colors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.primary,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
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
