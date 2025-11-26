import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/config/admob_config.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_header.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen/widgets/empty_exercise_list.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/adaptive_banner_ad.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Main workout view displaying the active workout with exercises.
///
/// Features:
/// - Workout header with stats
/// - Exercise list (normal or reorder mode)
/// - Support for both regular exercises and supersets
/// - Drag-and-drop reordering
/// - Banner ad at bottom
/// - Performance optimizations (RepaintBoundary, ValueKey)
class WorkoutView extends ConsumerWidget {
  const WorkoutView({
    required this.workout,
    required this.isReorderMode,
    required this.onEditExercise,
    required this.onDeleteExercise,
    required this.onReplaceExercise,
    required this.onUpdateExerciseSet,
    required this.onUpdateExercise,
    required this.onUpdateSupersetSet,
    required this.onReorderExercises,
    super.key,
  });

  /// The active workout to display
  final Workout workout;

  /// Whether reorder mode is active
  final bool isReorderMode;

  /// Callback when user wants to edit an exercise
  final void Function(Exercise exercise) onEditExercise;

  /// Callback when user wants to delete an exercise
  final void Function(String exerciseId) onDeleteExercise;

  /// Callback when user wants to replace an exercise
  final void Function(Exercise exercise) onReplaceExercise;

  /// Callback when user updates a set
  final void Function(String exerciseId, ExerciseSet updatedSet)
      onUpdateExerciseSet;

  /// Callback when user updates an exercise
  final void Function(Exercise updatedExercise) onUpdateExercise;

  /// Callback when user updates a superset set
  final void Function(String supersetId, SupersetSet supersetSet)
      onUpdateSupersetSet;

  /// Callback when user reorders exercises
  final void Function(int oldIndex, int newIndex) onReorderExercises;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Debug logging in development mode
    if (kDebugMode) {
      debugPrint(
          '🏗️ [WorkoutView] Building view with ${workout.exercises.length} exercises');
      for (final ex in workout.exercises) {
        debugPrint('   - ${ex.name}: countingMode=${ex.countingMode.name}');
      }
    }

    return SafeArea(
      // Only apply top/bottom safe area - horizontal handled by Scaffold
      left: false,
      right: false,
      child: Column(
        children: [
          // Workout Header with stats
          WorkoutHeader(workout: workout),

          // Exercise List
          Expanded(
            child: workout.exercises.isEmpty
                ? const EmptyExerciseList()
                : isReorderMode
                    ? _buildReorderableList(context, ref)
                    : _buildNormalList(context, ref),
          ),

          // Banner Ad (non-invasive, at bottom)
          // RepaintBoundary isolates static banner from list repaints
          if (workout.exercises.isNotEmpty)
            RepaintBoundary(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs,
                ),
                child: AdaptiveBannerAd(
                  adUnitId: AdMobConfig.bannerAnalytics,
                  height: 50,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the normal (non-reorderable) exercise list
  Widget _buildNormalList(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: workout.exercises.length,
      itemBuilder: (context, index) {
        final exercise = workout.exercises[index];

        // Debug logging in development mode
        if (kDebugMode) {
          debugPrint(
              '📋 [ListView.builder] Creating ExerciseListItem for: ${exercise.name}, countingMode=${exercise.countingMode.name}');
        }

        return Padding(
          key: ValueKey(exercise.id), // Key for better performance
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          // RepaintBoundary isolates each exercise card from repaints
          // in other parts of the list (e.g., timer tick updates)
          child: RepaintBoundary(
            child: exercise.type == ExerciseType.superset &&
                    exercise is SupersetExercise
                ? SupersetCard(
                    superset: exercise,
                    index: index,
                    isReorderMode: false,
                    onTap: () => onEditExercise(exercise),
                    onDelete: () => onDeleteExercise(exercise.id),
                    onEdit: () => onEditExercise(exercise),
                    onReplace: () => onReplaceExercise(exercise),
                    onSetUpdate: (updatedSet) =>
                        onUpdateExerciseSet(exercise.id, updatedSet),
                    onSetToggleComplete: (updatedSet) =>
                        onUpdateExerciseSet(exercise.id, updatedSet),
                    onExerciseUpdate: onUpdateExercise,
                    onSupersetSetUpdate: (supersetSet) =>
                        onUpdateSupersetSet(exercise.id, supersetSet),
                  )
                : ExerciseListItem(
                    exercise: exercise,
                    isReorderMode: false,
                    onTap: () => onEditExercise(exercise),
                    onDelete: () => onDeleteExercise(exercise.id),
                    onEdit: () => onEditExercise(exercise),
                    onReplace: () => onReplaceExercise(exercise),
                    onSetUpdate: (updatedSet) =>
                        onUpdateExerciseSet(exercise.id, updatedSet),
                    onSetToggleComplete: (updatedSet) =>
                        onUpdateExerciseSet(exercise.id, updatedSet),
                    onExerciseUpdate: onUpdateExercise,
                  ),
          ),
        );
      },
    );
  }

  /// Builds the reorderable exercise list for drag-and-drop
  Widget _buildReorderableList(BuildContext context, WidgetRef ref) {
    return Theme(
      data: context.theme.copyWith(
        canvasColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      child: ReorderableListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: workout.exercises.length,
        onReorder: (oldIndex, newIndex) {
          onReorderExercises(oldIndex, newIndex);
          HapticFeedback.mediumImpact();
        },
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final double animValue =
                  Curves.easeInOut.transform(animation.value);
              final double scale = 1 + (animValue * 0.05);
              final double elevation = 4 + (animValue * 12);

              return Transform.scale(
                scale: scale,
                child: Material(
                  elevation: elevation,
                  borderRadius: BorderRadius.circular(16),
                  color: context.colors.surface,
                  child: child,
                ),
              );
            },
            child: child,
          );
        },
        itemBuilder: (context, index) {
          final exercise = workout.exercises[index];
          return Padding(
            key: ValueKey(exercise.id),
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                // Drag handle with slide-in animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: 40,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: 1.0,
                    child: SemanticIcon(
                      icon: AppIcons.dragIndicator,
                      semanticLabel: 'Drag to reorder',
                      size: AppIconSize.medium,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
                // Exercise item (disabled interactions in reorder mode)
                Expanded(
                  child: exercise.type == ExerciseType.superset &&
                          exercise is SupersetExercise
                      ? SupersetCard(
                          superset: exercise,
                          index: index,
                          isReorderMode: true,
                          onTap: () {}, // Disabled in reorder mode
                          onDelete: () {}, // Disabled in reorder mode
                          onEdit: () {}, // Disabled in reorder mode
                          onReplace: () {}, // Disabled in reorder mode
                          onSetUpdate: (_) {}, // Disabled in reorder mode
                          onSetToggleComplete:
                              (_) {}, // Disabled in reorder mode
                          onExerciseUpdate: (_) {}, // Disabled in reorder mode
                          onSupersetSetUpdate:
                              (_) {}, // Disabled in reorder mode
                        )
                      : ExerciseListItem(
                          exercise: exercise,
                          isReorderMode: true,
                          onTap: () {}, // Disabled in reorder mode
                          onDelete: () {}, // Disabled in reorder mode
                          onEdit: () {}, // Disabled in reorder mode
                          onReplace: () {}, // Disabled in reorder mode
                          onSetUpdate: (_) {}, // Disabled in reorder mode
                          onSetToggleComplete:
                              (_) {}, // Disabled in reorder mode
                          onExerciseUpdate: (_) {}, // Disabled in reorder mode
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
