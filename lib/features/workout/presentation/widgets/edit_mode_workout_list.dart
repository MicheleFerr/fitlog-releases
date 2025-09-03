import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_edit_mode_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item_optimized.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/compact_exercise_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_swipeable_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_replacement_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/add_exercise_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'dart:ui' show lerpDouble;
import 'dart:math' as math;

/// Enhanced Workout List with Edit Mode capabilities
class EditModeWorkoutList extends ConsumerStatefulWidget {
  final Workout workout;
  final Function(Exercise) onEditExercise;
  final Function(String) onDeleteExercise;
  final Function(String, ExerciseSet) onUpdateSet;
  final Function(Exercise) onUpdateExercise;

  const EditModeWorkoutList({
    super.key,
    required this.workout,
    required this.onEditExercise,
    required this.onDeleteExercise,
    required this.onUpdateSet,
    required this.onUpdateExercise,
  });

  @override
  ConsumerState<EditModeWorkoutList> createState() => _EditModeWorkoutListState();
}

class _EditModeWorkoutListState extends ConsumerState<EditModeWorkoutList> 
    with TickerProviderStateMixin {
  
  // Animation controllers for edit mode
  late AnimationController _wiggleController;
  late AnimationController _editModeTransitionController;
  
  // Animations
  late Animation<double> _wiggleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize wiggle animation for edit mode
    _wiggleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _wiggleAnimation = Tween<double>(
      begin: 0,
      end: 0.02, // Small rotation in radians
    ).animate(CurvedAnimation(
      parent: _wiggleController,
      curve: Curves.elasticIn,
    ));
    
    // Initialize edit mode transition
    _editModeTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _wiggleController.dispose();
    _editModeTransitionController.dispose();
    super.dispose();
  }
  
  void _startWiggleAnimation() {
    _wiggleController.repeat(reverse: true);
    
    // Stop after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _wiggleController.stop();
        _wiggleController.reset();
      }
    });
  }
  
  void _showEditModeBanner() {
    final l10n = AppLocalizations.of(context)!;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.edit, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(l10n.editModeActive),
            const Spacer(),
            Text(
              l10n.swipeToExit,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final editModeState = ref.watch(workoutEditModeProvider);
    
    // Listen to edit mode state changes
    ref.listen<WorkoutEditModeState>(workoutEditModeProvider, (previous, next) {
      if (next.isEditMode && !(previous?.isEditMode ?? false)) {
        _startWiggleAnimation();
        _showEditModeBanner();
      } else if (!next.isEditMode && (previous?.isEditMode ?? true)) {
        _wiggleController.stop();
      }
      
      if (next.isEditMode) {
        _editModeTransitionController.forward();
      } else {
        _editModeTransitionController.reverse();
      }
    });
    
    if (widget.workout.exercises.isEmpty) {
      return _buildEmptyState(context, theme, l10n);
    }
    
    return Column(
      children: [
        // Edit mode toggle button
        if (!editModeState.isEditMode)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(workoutEditModeProvider.notifier).enterEditMode();
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.reorder_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.reorderExercises,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        
        // Exercise list
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: editModeState.isEditMode
                ? _buildEditModeList(context, theme, l10n)
                : _buildNormalList(context, theme, l10n),
          ),
        ),
      ],
    );
  }
  
  Widget _buildEditModeList(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
      ),
      child: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: widget.workout.exercises.length,
        onReorder: (oldIndex, newIndex) {
          HapticFeedback.mediumImpact();
          ref.read(currentWorkoutProvider.notifier).reorderExercises(oldIndex, newIndex);
          ref.read(workoutEditModeProvider.notifier).updateInteraction();
        },
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final double animValue = Curves.easeInOut.transform(animation.value);
              final double elevation = lerpDouble(2, 12, animValue)!;
              final double scale = lerpDouble(1, 1.05, animValue)!;
              
              return Transform.scale(
                scale: scale,
                child: Material(
                  elevation: elevation,
                  shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  child: child,
                ),
              );
            },
            child: child,
          );
        },
        itemBuilder: (context, index) {
          final exercise = widget.workout.exercises[index];
          
          return AnimatedBuilder(
            key: ValueKey(exercise.id),
            animation: _wiggleAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: math.sin(index * 0.5) * _wiggleAnimation.value,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: index == widget.workout.exercises.length - 1 ? 80 : 8,
                    top: index == 0 ? 8 : 0,
                  ),
                  child: CompactExerciseCard(
                    exercise: exercise,
                    index: index,
                    onTap: () {
                      // Blocked in edit mode - show feedback
                      HapticFeedback.lightImpact();
                      _showBlockedActionFeedback();
                    },
                    onReorderStart: () {
                      HapticFeedback.selectionClick();
                      ref.read(workoutEditModeProvider.notifier).updateInteraction();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildNormalList(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.workout.exercises.length,
      itemBuilder: (context, index) {
        final exercise = widget.workout.exercises[index];
        return ExerciseSwipeableCard(
          exercise: exercise,
          index: index,
          onTap: () => widget.onEditExercise(exercise),
          onEdit: () => widget.onEditExercise(exercise),
          onDelete: () => widget.onDeleteExercise(exercise.id),
          onReplace: () => _showReplacementModal(context, exercise),
          onExerciseUpdate: widget.onUpdateExercise,
          onSetUpdate: (updatedSet) => widget.onUpdateSet(exercise.id, updatedSet),
          child: OptimizedExerciseListItem(
            exerciseId: exercise.id,
            index: index,
            onTap: () => widget.onEditExercise(exercise),
            onDelete: () {}, // Gestito dalla card swipeable
            onSetUpdate: (updatedSet) => widget.onUpdateSet(exercise.id, updatedSet),
            onSetToggleComplete: (updatedSet) => widget.onUpdateSet(exercise.id, updatedSet),
            onExerciseUpdate: widget.onUpdateExercise,
          ),
        );
      },
    );
  }
  
  void _showReplacementModal(BuildContext context, Exercise exercise) {
    ExerciseReplacementModal.show(
      context,
      exercise,
      (newExercise) {
        // Replace exercise keeping the same ID and sets
        final replacedExercise = Exercise(
          id: exercise.id, // Keep the original ID
          name: newExercise.name,
          type: newExercise.type,
          category: newExercise.category,
          sets: exercise.sets, // Keep the original sets
          notes: exercise.notes ?? newExercise.notes,
          restTime: exercise.restTime ?? newExercise.restTime,
          isCompleted: exercise.isCompleted,
          isSkipped: exercise.isSkipped,
          skipReason: exercise.skipReason,
          totalVolume: exercise.totalVolume,
          completedAt: exercise.completedAt,
          skippedAt: exercise.skippedAt,
          createdAt: exercise.createdAt,
          updatedAt: DateTime.now(),
        );
        widget.onUpdateExercise(replacedExercise);
      },
    );
  }
  
  void _showBlockedActionFeedback() {
    final l10n = AppLocalizations.of(context)!;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(l10n.exitEditModeFirst),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noExercisesYet,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapToAddExercise,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}