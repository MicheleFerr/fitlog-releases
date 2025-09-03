import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/add_exercise_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'dart:ui' show lerpDouble;

/// Tier-1 Reorderable Exercise List Widget
class ReorderableWorkoutList extends ConsumerStatefulWidget {
  final Workout workout;
  final Function(Exercise) onEditExercise;
  final Function(String) onDeleteExercise;
  final Function(String, ExerciseSet) onUpdateSet;
  final Function(Exercise) onUpdateExercise;

  const ReorderableWorkoutList({
    super.key,
    required this.workout,
    required this.onEditExercise,
    required this.onDeleteExercise,
    required this.onUpdateSet,
    required this.onUpdateExercise,
  });

  @override
  ConsumerState<ReorderableWorkoutList> createState() => _ReorderableWorkoutListState();
}

class _ReorderableWorkoutListState extends ConsumerState<ReorderableWorkoutList> 
    with TickerProviderStateMixin {
  
  late AnimationController _insertAnimationController;
  int? _insertingAtIndex;
  
  @override
  void initState() {
    super.initState();
    _insertAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _insertAnimationController.dispose();
    super.dispose();
  }

  void _showAddExerciseModal(BuildContext context, {int? insertAtIndex}) {
    setState(() {
      _insertingAtIndex = insertAtIndex;
    });
    
    if (insertAtIndex != null) {
      _insertAnimationController.forward();
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddExerciseModal(
        onExerciseAdded: (exercise) {
          if (insertAtIndex != null) {
            ref.read(currentWorkoutProvider.notifier).insertExerciseAt(exercise, insertAtIndex);
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.exerciseInserted),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else {
            ref.read(currentWorkoutProvider.notifier).addExercise(exercise);
          }
          
          _insertAnimationController.reverse();
          setState(() {
            _insertingAtIndex = null;
          });
        },
      ),
    ).whenComplete(() {
      _insertAnimationController.reverse();
      setState(() {
        _insertingAtIndex = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    if (widget.workout.exercises.isEmpty) {
      return _buildEmptyState(context, theme, l10n);
    }

    return Theme(
      // Ensure reorderable items have proper theming
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      child: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: widget.workout.exercises.length,
        onReorder: (oldIndex, newIndex) {
          HapticFeedback.mediumImpact();
          ref.read(currentWorkoutProvider.notifier).reorderExercises(oldIndex, newIndex);
          
          // Show feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.exerciseReordered),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
        // Beautiful proxy decorator for drag animation
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
          final isFirstExercise = index == 0;
          final isLastExercise = index == widget.workout.exercises.length - 1;
          
          return Padding(
            key: ValueKey(exercise.id),
            padding: EdgeInsets.only(
              bottom: index == widget.workout.exercises.length - 1 ? 80 : 12,
              top: index == 0 ? 8 : 0,
            ),
            child: Column(
              children: [
                // Insert indicator above
                if (_insertingAtIndex == index)
                  _buildInsertIndicator(theme),
                
                // Exercise card with enhancements
                Stack(
                  children: [
                    // Main exercise card
                    Padding(
                      padding: const EdgeInsets.only(left: 32), // Space for drag handle
                      child: ExerciseListItem(
                        exercise: exercise,
                        onTap: () => widget.onEditExercise(exercise),
                        onDelete: () => widget.onDeleteExercise(exercise.id),
                        onSetUpdate: (updatedSet) => widget.onUpdateSet(exercise.id, updatedSet),
                        onSetToggleComplete: (updatedSet) => widget.onUpdateSet(exercise.id, updatedSet),
                        onExerciseUpdate: widget.onUpdateExercise,
                        // Enhanced menu options
                        additionalMenuItems: [
                          PopupMenuItem(
                            value: 'insert_above',
                            child: ListTile(
                              leading: Icon(
                                Icons.add_circle_outline,
                                color: theme.colorScheme.primary,
                              ),
                              title: Text(l10n.insertAbove),
                              dense: true,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'insert_below',
                            child: ListTile(
                              leading: Icon(
                                Icons.add_circle_outline,
                                color: theme.colorScheme.primary,
                              ),
                              title: Text(l10n.insertBelow),
                              dense: true,
                            ),
                          ),
                          if (!isFirstExercise)
                            PopupMenuItem(
                              value: 'move_up',
                              child: ListTile(
                                leading: const Icon(Icons.arrow_upward),
                                title: Text(l10n.moveUp),
                                dense: true,
                              ),
                            ),
                          if (!isLastExercise)
                            PopupMenuItem(
                              value: 'move_down',
                              child: ListTile(
                                leading: const Icon(Icons.arrow_downward),
                                title: Text(l10n.moveDown),
                                dense: true,
                              ),
                            ),
                        ],
                        onMenuItemSelected: (value) {
                          switch (value) {
                            case 'insert_above':
                              _showAddExerciseModal(context, insertAtIndex: index);
                              break;
                            case 'insert_below':
                              _showAddExerciseModal(context, insertAtIndex: index + 1);
                              break;
                            case 'move_up':
                              if (index > 0) {
                                HapticFeedback.lightImpact();
                                ref.read(currentWorkoutProvider.notifier)
                                    .reorderExercises(index, index - 1);
                              }
                              break;
                            case 'move_down':
                              if (index < widget.workout.exercises.length - 1) {
                                HapticFeedback.lightImpact();
                                ref.read(currentWorkoutProvider.notifier)
                                    .reorderExercises(index, index + 2);
                              }
                              break;
                          }
                        },
                      ),
                    ),
                    
                    // Drag handle - always visible for better UX
                    Positioned(
                      left: 0,
                      top: 20,
                      child: ReorderableDragStartListener(
                        index: index,
                        child: Container(
                          width: 28,
                          height: 60,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.drag_indicator,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                size: 20,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Exercise number badge - top right
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primaryContainer,
                              theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 12,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '#${index + 1}',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Insert indicator below (for last item)
                if (_insertingAtIndex == widget.workout.exercises.length && 
                    index == widget.workout.exercises.length - 1)
                  _buildInsertIndicator(theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInsertIndicator(ThemeData theme) {
    return AnimatedBuilder(
      animation: _insertAnimationController,
      builder: (context, child) {
        return Container(
          height: lerpDouble(0, 60, _insertAnimationController.value),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Center(
            child: Container(
              width: double.infinity,
              height: 3,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(
                  alpha: _insertAnimationController.value * 0.7,
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(
                      alpha: _insertAnimationController.value * 0.3,
                    ),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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