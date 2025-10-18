import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Modal for executing DropSet exercises during workouts
///
/// Handles the progressive execution of dropset stages:
/// 1. User performs first stage to failure (e.g., 100kg × 8 reps)
/// 2. User marks stage complete
/// 3. Modal shows next stage (e.g., 80kg × 6 reps)
/// 4. User immediately reduces weight (NO REST!)
/// 5. User performs to failure again
/// 6. Repeat until all stages complete
/// 7. DropSet marked as complete
class DropSetExecutionModal extends ConsumerStatefulWidget {

  const DropSetExecutionModal({
    super.key,
    required this.exercise,
  });
  final DropSetExercise exercise;

  @override
  ConsumerState<DropSetExecutionModal> createState() => _DropSetExecutionModalState();

  /// Static method to show modal
  static Future<void> show({
    required BuildContext context,
    required DropSetExercise exercise,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DropSetExecutionModal(exercise: exercise),
    );
  }
}

class _DropSetExecutionModalState extends ConsumerState<DropSetExecutionModal>
    with SingleTickerProviderStateMixin {

  late int _currentStageIndex;
  late List<DropSetStage> _stages;
  late DateTime _startTime;
  bool _isCompleting = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _stages = List.from(widget.exercise.stages);
    _startTime = DateTime.now();

    // Find first incomplete stage or start at 0
    _currentStageIndex = _stages.indexWhere((stage) => !stage.isCompleted);
    if (_currentStageIndex == -1) {
      _currentStageIndex = 0;
    }

    // Setup pulse animation for current stage highlight
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Mark current stage as complete and move to next
  Future<void> _completeCurrentStage() async {
    if (_currentStageIndex >= _stages.length) return;

    setState(() {
      _stages[_currentStageIndex] = _stages[_currentStageIndex].copyWith(
        isCompleted: true,
      );
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Check if all stages complete
    if (_isAllStagesComplete) {
      await _completeDropSet();
    } else {
      // Move to next stage
      setState(() {
        _currentStageIndex++;
      });

      // Show weight change reminder
      if (_currentStageIndex < _stages.length) {
        final nextWeight = _stages[_currentStageIndex].weight;
        SnackBarService.showWarning(
          context,
          context.l10n.dropsetReduceWeightNow(nextWeight.toStringAsFixed(1)),
        );
      }
    }
  }

  /// Complete entire dropset and update workout
  Future<void> _completeDropSet() async {
    if (_isCompleting) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      // Create updated exercise with completed stages
      final updatedExercise = DropSetExercise(
        id: widget.exercise.id,
        name: widget.exercise.name,
        category: widget.exercise.category,
        stages: _stages,
        notes: widget.exercise.notes,
      );

      // Update workout state
      ref.read(currentWorkoutProvider.notifier).updateExerciseOnly(updatedExercise);

      // Haptic feedback
      HapticFeedback.heavyImpact();

      // Show success message
      SnackBarService.showSuccess(
        context,
        context.l10n.dropsetCompleted,
      );

      // Close modal
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      SnackBarService.showError(
        context,
        context.l10n.errorSavingWorkout,
      );

      setState(() {
        _isCompleting = false;
      });
    }
  }

  /// Cancel dropset execution (ask for confirmation)
  Future<void> _cancelDropSet() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.cancelDropset),
        content: Text(context.l10n.cancelDropsetMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.yes),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  bool get _isAllStagesComplete =>
      _stages.every((stage) => stage.isCompleted);

  int get _completedStagesCount =>
      _stages.where((stage) => stage.isCompleted).length;

  Duration get _elapsedTime => DateTime.now().difference(_startTime);

  String get _motivationalMessage {
    if (_currentStageIndex == 0) {
      return context.l10n.dropsetGetReady;
    } else if (_currentStageIndex == _stages.length - 1) {
      return context.l10n.dropsetLastStage;
    } else {
      return context.l10n.dropsetNoRest;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _buildHeader(),

          // Progress indicator
          _buildProgressIndicator(),

          // Motivational message
          _buildMotivationalMessage(),

          // Stages list
          Expanded(
            child: _buildStagesList(),
          ),

          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // Exercise icon with tertiary color (dropset)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.tertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_down,
                  color: context.colors.tertiary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Exercise name and stage count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.exercise.name,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.dropsetStages(_stages.length),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: context.colors.onSecondaryContainer,
                    ),
                    const SizedBox(width: 4),
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        final elapsed = _elapsedTime;
                        final minutes = elapsed.inMinutes;
                        final seconds = elapsed.inSeconds % 60;
                        return Text(
                          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = _completedStagesCount / _stages.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.progress,
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$_completedStagesCount/${_stages.length}',
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: context.colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.tertiary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flash_on,
            color: context.colors.onTertiaryContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _motivationalMessage,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onTertiaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStagesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _stages.length,
      itemBuilder: (context, index) {
        final stage = _stages[index];
        final isCurrent = index == _currentStageIndex;
        final isCompleted = stage.isCompleted;
        final isUpcoming = index > _currentStageIndex;

        Widget stageCard = Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrent
                ? context.colors.tertiaryContainer
                : isCompleted
                    ? context.colors.surfaceContainerHighest
                    : context.colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrent
                  ? context.colors.tertiary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Stage number or checkmark
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? context.colors.tertiary
                      : isCurrent
                          ? context.colors.tertiary.withValues(alpha: 0.3)
                          : context.colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          color: context.colors.onTertiary,
                          size: 24,
                        )
                      : Text(
                          '${index + 1}',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: isCurrent
                                ? context.colors.onTertiaryContainer
                                : context.colors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Stage details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.dropsetStage(index + 1),
                      style: context.textTheme.labelMedium?.copyWith(
                        color: isCurrent
                            ? context.colors.onTertiaryContainer
                            : isCompleted
                                ? context.colors.onSurfaceVariant
                                : context.colors.onSurface,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 16,
                          color: isCurrent
                              ? context.colors.tertiary
                              : context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${stage.weight.toStringAsFixed(1)} kg',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: isCurrent
                                ? context.colors.tertiary
                                : isCompleted
                                    ? context.colors.onSurfaceVariant
                                    : context.colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.repeat,
                          size: 16,
                          color: isCurrent
                              ? context.colors.tertiary
                              : context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.l10n.targetReps(stage.reps),
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: isCurrent
                                ? context.colors.onTertiaryContainer
                                : context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status badge
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.tertiary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    context.l10n.completed,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (isUpcoming)
                Icon(
                  Icons.lock_outline,
                  color: context.colors.onSurfaceVariant,
                  size: 20,
                ),
            ],
          ),
        );

        // Add pulse animation to current stage
        if (isCurrent && !isCompleted) {
          stageCard = ScaleTransition(
            scale: _pulseAnimation,
            child: stageCard,
          );
        }

        return stageCard;
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        context.bottomPadding + 16,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(
            color: context.colors.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main action button
          if (_isAllStagesComplete)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isCompleting ? null : _completeDropSet,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.tertiary,
                  foregroundColor: context.colors.onTertiary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isCompleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(
                  context.l10n.completeDropset,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _completeCurrentStage,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.tertiary,
                  foregroundColor: context.colors.onTertiary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check),
                label: Text(
                  context.l10n.completeStage(_currentStageIndex + 1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Cancel button
          TextButton(
            onPressed: _cancelDropSet,
            child: Text(
              context.l10n.cancel,
              style: TextStyle(
                color: context.colors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
