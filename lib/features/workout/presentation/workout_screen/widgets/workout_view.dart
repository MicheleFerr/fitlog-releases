import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/config/admob_config.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item/exercise_list_item.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_header.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen/widgets/empty_exercise_list.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/adaptive_banner_ad.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/material_scroll_list.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Main workout view displaying the active workout with exercises.
///
/// Features:
/// - Workout header with stats (floats above list)
/// - Exercise list scrolls under header with gradient fade
/// - Support for both regular exercises and supersets
/// - Drag-and-drop reordering
/// - Banner ad at bottom
class WorkoutView extends ConsumerStatefulWidget {
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
    this.tutorialFirstSetKey,
    this.tutorialExerciseMenuKey,
    super.key,
  });

  /// The active workout to display
  final Workout workout;

  /// Whether reorder mode is active
  final bool isReorderMode;

  /// Optional key for tutorial overlay on first set row (first exercise only)
  final GlobalKey? tutorialFirstSetKey;

  /// Optional key for tutorial overlay on exercise menu (first exercise only)
  final GlobalKey? tutorialExerciseMenuKey;

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
  ConsumerState<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends ConsumerState<WorkoutView> {
  final GlobalKey _headerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Measure header after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeader());
  }

  void _measureHeader() {
    final context = _headerKey.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && mounted) {
        // Header measurement available: box.size.height
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    // Debug logging in development mode
    if (kDebugMode) {
      debugPrint(
        '🏗️ [WorkoutView] Building view with ${widget.workout.exercises.length} exercises',
      );
    }

    return SafeArea(
      left: false,
      right: false,
      bottom: false, // Allow content to scroll under bottom navigation bar
      child: Column(
        children: [
          // Header section with gradient fade below
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Header
              KeyedSubtree(
                key: _headerKey,
                child: WorkoutHeader(workout: widget.workout),
              ),
              // Gradient fade below header (positioned at bottom edge)
              Positioned(
                left: 0,
                right: 0,
                bottom: -24, // Extend below header
                height: 24,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorScheme.surface,
                          colorScheme.surface.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Exercise List
          Expanded(
            child: widget.workout.exercises.isEmpty
                ? const EmptyExerciseList()
                : widget.isReorderMode
                ? _buildReorderableList(context, ref)
                : _buildNormalList(context, ref),
          ),

          // Banner Ad at bottom
          if (widget.workout.exercises.isNotEmpty)
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

  /// Builds the normal (non-reorderable) exercise list with material-like physics
  Widget _buildNormalList(BuildContext context, WidgetRef ref) {
    return MaterialScrollList(
      itemCount: widget.workout.exercises.length,
      // List is now below header in Column, no need for header padding
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: AppSpacing.md + 60 + context.tabBarInset, // FAB + tab bar
      ),
      itemBuilder: (context, index) {
        final exercise = widget.workout.exercises[index];

        return Padding(
          key: ValueKey(exercise.id), // Key for better performance
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          // RepaintBoundary isolates each exercise card from repaints
          // in other parts of the list (e.g., timer tick updates)
          child: RepaintBoundary(
            child:
                exercise.type == ExerciseType.superset &&
                    exercise is SupersetExercise
                ? SupersetCard(
                    superset: exercise,
                    index: index,
                    isReorderMode: false,
                    onTap: () => widget.onEditExercise(exercise),
                    onDelete: () => widget.onDeleteExercise(exercise.id),
                    onEdit: () => widget.onEditExercise(exercise),
                    onReplace: () => widget.onReplaceExercise(exercise),
                    onSetUpdate: (updatedSet) =>
                        widget.onUpdateExerciseSet(exercise.id, updatedSet),
                    onSetToggleComplete: (updatedSet) =>
                        widget.onUpdateExerciseSet(exercise.id, updatedSet),
                    onExerciseUpdate: widget.onUpdateExercise,
                    onSupersetSetUpdate: (supersetSet) =>
                        widget.onUpdateSupersetSet(exercise.id, supersetSet),
                  )
                : ExerciseListItem(
                    exercise: exercise,
                    isReorderMode: false,
                    onTap: () => widget.onEditExercise(exercise),
                    onDelete: () => widget.onDeleteExercise(exercise.id),
                    onEdit: () => widget.onEditExercise(exercise),
                    onReplace: () => widget.onReplaceExercise(exercise),
                    onSetUpdate: (updatedSet) =>
                        widget.onUpdateExerciseSet(exercise.id, updatedSet),
                    onSetToggleComplete: (updatedSet) =>
                        widget.onUpdateExerciseSet(exercise.id, updatedSet),
                    onExerciseUpdate: widget.onUpdateExercise,
                    // Pass tutorial keys only to the first exercise
                    tutorialFirstSetKey: index == 0
                        ? widget.tutorialFirstSetKey
                        : null,
                    tutorialExerciseMenuKey: index == 0
                        ? widget.tutorialExerciseMenuKey
                        : null,
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
        canvasColor: context.colors.surface.withValues(alpha: 0),
        shadowColor: context.colors.surface.withValues(alpha: 0),
      ),
      child: ReorderableListView.builder(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.sm,
          bottom: AppSpacing.md + 60 + context.tabBarInset, // FAB + tab bar
        ),
        itemCount: widget.workout.exercises.length,
        onReorder: (oldIndex, newIndex) {
          widget.onReorderExercises(oldIndex, newIndex);
          HapticFeedback.mediumImpact();
        },
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final double animValue = Curves.easeInOut.transform(
                animation.value,
              );
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
          final exercise = widget.workout.exercises[index];
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
                  child:
                      exercise.type == ExerciseType.superset &&
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
