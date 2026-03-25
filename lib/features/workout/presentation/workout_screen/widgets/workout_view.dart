import 'dart:async';

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
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/core/navigation/main_shell.dart';

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
  static const int _inlineAdEveryNExercises = 3;

  final GlobalKey _headerKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  /// Keys for each exercise card — used to scroll to a specific exercise
  final Map<String, GlobalKey> _exerciseKeys = {};

  @override
  void initState() {
    super.initState();
    // Measure header after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeader());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  bool get _isNearTop {
    if (!_scrollController.hasClients) return true;
    return _scrollController.offset < 50;
  }

  ({int index, GlobalKey key})? _firstUsefulExerciseTarget() {
    for (var index = 0; index < widget.workout.exercises.length; index++) {
      final exercise = widget.workout.exercises[index];
      if (!exercise.isCompleted) {
        return (index: index, key: _keyForExercise(exercise.id));
      }
    }
    return null;
  }

  double _estimatedOffsetForExerciseIndex(int index) {
    const estimatedCollapsedCardHeight = 132.0;
    const estimatedAdBlockHeight = 58.0;
    final adsBefore = index ~/ _inlineAdEveryNExercises;

    return (index * estimatedCollapsedCardHeight) +
        (adsBefore * estimatedAdBlockHeight);
  }

  /// Same-tab tap: normalize the list near the top, then jump to the first
  /// still-useful exercise if there is one.
  Future<void> _handleSameTabTap() async {
    if (!_scrollController.hasClients) return;

    final target = _firstUsefulExerciseTarget();

    if (!_isNearTop) {
      await _scrollToTop();
      if (!mounted || target == null) return;
      await Future<void>.delayed(const Duration(milliseconds: 80));
    }

    if (target != null) {
      if (target.key.currentContext == null) {
        final estimatedOffset = _estimatedOffsetForExerciseIndex(target.index);
        final clampedOffset = estimatedOffset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );

        await _scrollController.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );

        if (!mounted) return;
        await Future<void>.delayed(const Duration(milliseconds: 60));
      }

      if (target.key.currentContext != null) {
        await Scrollable.ensureVisible(
          target.key.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          alignment: 0.1,
        );
        return;
      }
    }

    await _scrollToTop();
  }

  Future<void> _scrollToTop() {
    return _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Get or create a GlobalKey for the exercise card
  GlobalKey _keyForExercise(String exerciseId) {
    return _exerciseKeys.putIfAbsent(exerciseId, () => GlobalKey());
  }

  bool _shouldShowInlineAd(int index, int totalItems) {
    if (widget.isReorderMode) return false;
    if (totalItems < 2) return false;

    final isNotLastItem = index < totalItems - 1;
    final shouldInsertAfterItem = (index + 1) % _inlineAdEveryNExercises == 0;

    return isNotLastItem && shouldInsertAfterItem;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    // Listen for same-tab tap on the workout tab.
    ref.listen(sameTabTapSignalProvider, (previous, next) {
      unawaited(_handleSameTabTap());
    });

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
                : _buildReorderableList(context, ref),
          ),
        ],
      ),
    );
  }

  /// Builds the exercise list with long-press drag-and-drop.
  Widget _buildReorderableList(BuildContext context, WidgetRef ref) {
    final compactMode = widget.isReorderMode;

    return Theme(
      data: context.theme.copyWith(
        canvasColor: context.colors.surface.withValues(alpha: 0),
        shadowColor: context.colors.surface.withValues(alpha: 0),
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ReorderableListView.builder(
          scrollController: _scrollController,
          buildDefaultDragHandles: false,
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
            final exercise = widget.workout.exercises[index];
            final proxyChild = _buildCompactDragProxy(context, exercise);

            return AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
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
                    child: proxyChild,
                  ),
                );
              },
            );
          },
          itemBuilder: (context, index) {
            final exercise = widget.workout.exercises[index];
            final card = RepaintBoundary(
              child:
                  exercise.type == ExerciseType.superset &&
                      exercise is SupersetExercise
                  ? SupersetCard(
                      superset: exercise,
                      index: index,
                      isReorderMode: compactMode,
                      onTap: compactMode
                          ? () {}
                          : () => widget.onEditExercise(exercise),
                      onDelete: compactMode
                          ? () {}
                          : () => widget.onDeleteExercise(exercise.id),
                      onEdit: compactMode
                          ? () {}
                          : () => widget.onEditExercise(exercise),
                      onReplace: compactMode
                          ? () {}
                          : () => widget.onReplaceExercise(exercise),
                      onSetUpdate: compactMode
                          ? (_) {}
                          : (updatedSet) => widget.onUpdateExerciseSet(
                              exercise.id,
                              updatedSet,
                            ),
                      onSetToggleComplete: compactMode
                          ? (_) {}
                          : (updatedSet) => widget.onUpdateExerciseSet(
                              exercise.id,
                              updatedSet,
                            ),
                      onExerciseUpdate: compactMode
                          ? (_) {}
                          : widget.onUpdateExercise,
                      onSupersetSetUpdate: compactMode
                          ? (_) {}
                          : (supersetSet) => widget.onUpdateSupersetSet(
                              exercise.id,
                              supersetSet,
                            ),
                    )
                  : ExerciseListItem(
                      exercise: exercise,
                      isReorderMode: compactMode,
                      onTap: compactMode
                          ? () {}
                          : () => widget.onEditExercise(exercise),
                      onDelete: compactMode
                          ? () {}
                          : () => widget.onDeleteExercise(exercise.id),
                      onEdit: compactMode
                          ? () {}
                          : () => widget.onEditExercise(exercise),
                      onReplace: compactMode
                          ? () {}
                          : () => widget.onReplaceExercise(exercise),
                      onSetUpdate: compactMode
                          ? (_) {}
                          : (updatedSet) => widget.onUpdateExerciseSet(
                              exercise.id,
                              updatedSet,
                            ),
                      onSetToggleComplete: compactMode
                          ? (_) {}
                          : (updatedSet) => widget.onUpdateExerciseSet(
                              exercise.id,
                              updatedSet,
                            ),
                      onExerciseUpdate: compactMode
                          ? (_) {}
                          : widget.onUpdateExercise,
                      tutorialFirstSetKey: !compactMode && index == 0
                          ? widget.tutorialFirstSetKey
                          : null,
                      tutorialExerciseMenuKey: !compactMode && index == 0
                          ? widget.tutorialExerciseMenuKey
                          : null,
                    ),
            );

            final animatedCard = AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: KeyedSubtree(
                key: ValueKey('exercise-${exercise.id}-compact-$compactMode'),
                child: card,
              ),
            );

            final content = widget.isReorderMode
                ? Row(
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          width: 40,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg,
                          ),
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
                      ),
                      Expanded(child: animatedCard),
                    ],
                  )
                : ReorderableDelayedDragStartListener(
                    index: index,
                    child: Semantics(
                      hint: 'Long press and drag to reorder',
                      child: animatedCard,
                    ),
                  );

            final totalItems = widget.workout.exercises.length;
            final showInlineAd = _shouldShowInlineAd(index, totalItems);

            return Padding(
              key: ValueKey(exercise.id),
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: KeyedSubtree(
                key: _keyForExercise(exercise.id),
                child: Column(
                  children: [
                    content,
                    if (showInlineAd) ...[
                      const SizedBox(height: AppSpacing.sm),
                      RepaintBoundary(
                        child: AdaptiveBannerAd(
                          adUnitId: AdMobConfig.bannerAnalytics,
                          height: 50,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompactDragProxy(BuildContext context, Exercise exercise) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(AppIcons.dragHandle, color: context.colors.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  exercise.name,
                  style: context.textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
