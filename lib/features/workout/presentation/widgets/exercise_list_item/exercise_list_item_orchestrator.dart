import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_gif_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/auto_adjustment_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/workout/timer/presentation/providers/unified_timer_extensions.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/tut_info_dialog.dart'
    show showTutInfoBottomSheet;
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_expansion_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_autocollapse_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_suggestion_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/haptic_feedback_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_header.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_sets.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_footer.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_history_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/counting_mode_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rest_time_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/weight_jump_indicator.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    as db;
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/warmup_suggestion.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_details_modal.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/warmup_calculator_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/warmup_customization_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_link_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/dropset_weight_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/dropset_completion_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rest_pause_execution_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item/utils/exercise_notes_handler.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/user_exercise_preferences_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/exercise_preferences_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/entities/merge_candidate.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/quick_upgrade_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_upgrade_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/rpe_autoregulation_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/plate_calculator_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/exercise_card_settings_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Orchestrator widget that coordinates ExerciseListItemHeader and ExerciseListItemSets
///
/// This widget maintains the same public interface as the original ExerciseListItem
/// but delegates UI rendering to specialized components:
/// - ExerciseListItemHeader: Displays exercise name, badges, popup menu
/// - ExerciseListItemSets: Displays sets, handles set editing/completion
///
/// Responsibilities:
/// - Manages providers (expansion, auto-collapse, suggestions)
/// - Loads exercise history on init
/// - Implements callback handlers for header actions
/// - Implements callback handlers for sets actions
/// - Coordinates state between header and sets components
class ExerciseListItem extends ConsumerStatefulWidget {
  const ExerciseListItem({
    super.key,
    required this.exercise,
    required this.onTap,
    required this.onDelete,
    this.onEdit,
    this.onReplace,
    this.onSetUpdate,
    this.onSetToggleComplete,
    this.onExerciseUpdate,
    this.isReorderMode = false,
    this.tutorialFirstSetKey,
    this.tutorialExerciseMenuKey,
  });

  final Exercise exercise;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onReplace;
  final Function(ExerciseSet)? onSetUpdate;
  final Function(ExerciseSet)? onSetToggleComplete;
  final Function(Exercise)? onExerciseUpdate;
  final bool isReorderMode;

  /// Optional key for tutorial overlay on first set row
  final GlobalKey? tutorialFirstSetKey;

  /// Optional key for tutorial overlay on exercise menu (⋮)
  final GlobalKey? tutorialExerciseMenuKey;

  @override
  ConsumerState<ExerciseListItem> createState() => _ExerciseListItemState();
}

class _ExerciseListItemState extends ConsumerState<ExerciseListItem> {
  ExerciseActivity? _lastActivity;
  Map<String, dynamic>? _exerciseData;

  bool get isProMode => ref.read(appConfigProvider).isProMode ?? false;

  // ✅ PERFORMANCE FIX: Expansion state getters use ref.read for non-reactive access
  // These are used in callbacks (didUpdateWidget, _autoCollapseIfCompleted) where
  // we need current value but don't want to trigger rebuilds.
  // Reactive watching is done ONLY in build() method with local variables.
  bool get _isExpandedRead =>
      ref.read(exerciseExpansionProvider(widget.exercise.id)).isExpanded;

  bool get _hasAutoCollapsedRead =>
      ref.read(exerciseExpansionProvider(widget.exercise.id)).hasAutoCollapsed;

  bool get _userManuallyExpandedRead => ref
      .read(exerciseExpansionProvider(widget.exercise.id))
      .userManuallyExpanded;

  // ✅ RESTORED: NotifierProvider.family now works
  ExerciseExpansionNotifier get _expansionNotifier =>
      ref.read(exerciseExpansionProvider(widget.exercise.id).notifier);

  // For debugging only - use .read()
  AutoCollapseState get _autoCollapseState =>
      ref.read(exerciseAutoCollapseProvider(widget.exercise.id));

  // ✅ RESTORED: NotifierProvider.family now works
  AutoCollapseNotifier get _autoCollapseNotifier =>
      ref.read(exerciseAutoCollapseProvider(widget.exercise.id).notifier);

  // TEMPORARY: Disabled for Riverpod 3.x migration
  // TODO: Restore when migrating to @riverpod codegen
  // ExerciseSuggestionsNotifier get _suggestionsNotifier =>
  //     ref.read(exerciseSuggestionsProvider(widget.exercise.id).notifier);

  @override
  void initState() {
    super.initState();

    _loadLastActivity();
    _loadExerciseData();

    // Defer provider state modification until AFTER widget tree finishes building
    Future.microtask(() {
      if (mounted) {
        _checkForCommunitySuggestions();
      }
    });
  }

  Future<void> _loadExerciseData() async {
    final data = await _loadExerciseDataFromJson();
    if (mounted && data != null) {
      setState(() {
        _exerciseData = data;
      });
    }
  }

  @override
  void didUpdateWidget(ExerciseListItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger rebuild if counting mode changed
    if (oldWidget.exercise.countingMode != widget.exercise.countingMode) {
      setState(() {});
    }

    // Check if auto-collapse should be triggered after widget update
    final config = ref.read(appConfigProvider);
    if (config.autoCollapseCompleted ?? false) {
      final wasCompleted =
          oldWidget.exercise.sets.isNotEmpty &&
          oldWidget.exercise.sets.every((set) => set.isCompleted);
      final isNowCompleted =
          widget.exercise.sets.isNotEmpty &&
          widget.exercise.sets.every((set) => set.isCompleted);

      // Reset flags if exercise becomes incomplete again
      if (wasCompleted && !isNowCompleted) {
// TEMPORARY: Disabled -         _expansionNotifier.resetForIncomplete();
      }

      // Trigger auto-collapse if exercise just became complete
      if (!wasCompleted &&
          isNowCompleted &&
          _isExpandedRead &&
          !_hasAutoCollapsedRead &&
          !_userManuallyExpandedRead) {
        if (kDebugMode) {
          debugPrint(
            'AUTO-COLLAPSE TRIGGERED via didUpdateWidget for ${widget.exercise.name}',
          );
        }
        _autoCollapseIfCompleted();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _areAllSetsCompleted() {
    // Use the isCompleted getter which handles all exercise types:
    // - RestPauseExercise: checks restPauseSets
    // - DropSetExercise: checks stages
    // - SupersetExercise: checks supersetSets
    // - Regular Exercise: checks sets
    return widget.exercise.isCompleted;
  }

  void _autoCollapseIfCompleted() {
    try {
      if (_areAllSetsCompleted() &&
          _isExpandedRead &&
          !_hasAutoCollapsedRead &&
          !_userManuallyExpandedRead) {
        if (kDebugMode) {
          debugPrint('AUTO-COLLAPSE TRIGGERED for ${widget.exercise.name}');
        }

        final config = ref.read(appConfigProvider);
        // Fixed values - no need for toggle (was simplifiedAnimations)
        const delay = Duration(milliseconds: 1800);
        const countdownDuration = 2;

        final showCountdown = config.showCollapseCountdown ?? false;

        // ✅ RESTORED: Start auto-collapse
        _autoCollapseNotifier.startAutoCollapse(
          initialDelay: delay,
          countdownSeconds: countdownDuration,
          showCountdown: showCountdown,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing auto-collapse: $e');
      }
    }
  }

  Future<void> _loadLastActivity() async {
    try {
      final service = ref.read(workoutHistoryServiceProvider);
      final activity = await service.getLastActivityByExercise(
        exerciseName: widget.exercise.name,
      );

      if (mounted && activity != null) {
        setState(() {
          _lastActivity = activity;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading last activity: $e');
      }
      await _loadLastActivityFallback();
    }
  }

  Future<void> _loadLastActivityFallback() async {
    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;

    if (currentUser?.email != null) {
      final repository = ExerciseActivityRepository();
      final activities = await repository.getActivitiesByExercise(
        userId: currentUser!.email!,
        exerciseName: widget.exercise.name,
        limit: 1,
      );

      if (mounted && activities.isNotEmpty) {
        setState(() {
          _lastActivity = activities.first;
        });
      }
    }
  }

  Future<void> _checkForCommunitySuggestions() async {
    // TEMPORARY: Disabled - community suggestions feature
    // TODO: Re-enable when community contributions are implemented
  }

  // ========================================================================
  // HEADER CALLBACKS
  // ========================================================================

  void _handleCancelAutoCollapse() {
    try {
      _autoCollapseNotifier.cancel();
      if (mounted) {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint('Error cancelling auto-collapse: $e');
    }
  }

  void _handleShowAutoAdjustmentModal() async {
    if (widget.onExerciseUpdate == null) return;

    await ModalService.showSheet(context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: context.mediaQuery.viewInsets.bottom,
          ),
          child: AutoAdjustmentModal(
            exercise: widget.exercise,
            onSave: widget.onExerciseUpdate!,
          ),
        ),
      ),
    );
  }

  Future<void> _handleShowQuickTimerSettings() async {
    await ModalService.showSheet(context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => RestTimePickerModal(
        initialRestTime: widget.exercise.restTime,
        onRestTimeSelected: (newRestTime) {
          // Update exercise with new rest time
          if (widget.onExerciseUpdate != null) {
            final updatedExercise = widget.exercise.copyWith(
              restTime: newRestTime,
              clearRestTime:
                  newRestTime == null, // ✅ FIX: Allow clearing restTime to null
              updatedAt: DateTime.now(),
            );
            widget.onExerciseUpdate!(updatedExercise);
          }
          // Note: Modal now closes itself after confirm
        },
        source: 'exercise_list_item_header',
        exerciseId: widget.exercise.id,
      ),
    );
  }

  void _handleShowTutExplanationModal() {
    // TUT info is shown via bottom sheet, not dialog
    // Default TUT value if not available
    final tutValue = widget.exercise.tut ?? '2-0-2-0';
    showTutInfoBottomSheet(context, tutValue);
  }

  void _handleShowPlatesCalculator() {
    // Use first uncompleted working set weight, fallback to 60kg default
    final workingSets = widget.exercise.sets
        .where((s) => !s.isWarmup)
        .toList();
    double targetWeight = 60.0;
    if (workingSets.isNotEmpty) {
      final nextSet = workingSets.where((s) => !s.isCompleted).firstOrNull;
      final setToShow = nextSet ?? workingSets.first;
      final w = double.tryParse(setToShow.weight.toString()) ?? 0;
      if (w > 0) targetWeight = w;
    }
    _showPlatesCupertinoPopup(context, targetWeight);
  }

  /// Whether this exercise uses plate-loadable equipment
  /// (barbell, EZ bar, trap bar, smith machine, leg press, hack squat, etc.)
  bool _usesPlateLoadableEquipment() {
    final attrezzatura = (_exerciseData?['attrezzatura'] as String? ?? '').toLowerCase();
    // Barbell variants
    if (attrezzatura == 'bilanciere' ||
        attrezzatura == 'barbell' ||
        attrezzatura == 'olympic barbell' ||
        attrezzatura == 'ez bar' ||
        attrezzatura == 'trap bar' ||
        attrezzatura == 'smith machine' ||
        attrezzatura == 'smith') {
      return true;
    }
    // Plate-loaded machines
    if (attrezzatura.contains('leg press') ||
        attrezzatura.contains('hack squat') ||
        attrezzatura.contains('pendulum') ||
        attrezzatura.contains('plate-loaded') ||
        attrezzatura.contains('macchina con dischi')) {
      return true;
    }
    // Adjustable dumbbells
    if (attrezzatura.contains('manubri componibili') ||
        attrezzatura.contains('adjustable dumbbell')) {
      return true;
    }
    // Fallback: name-based heuristic (barbell only)
    if (attrezzatura.isEmpty) {
      return WarmupCalculatorService().isLikelyBarbellExercise(widget.exercise.name);
    }
    return false;
  }

  /// Shows Tips bottom sheet with Info/Warmup/Prevention options
  /// Part of Exercise Card redesign - Tips moved from header to footer
  void _handleShowTipsBottomSheet() async {
    final data = await _loadExerciseDataFromJson();

    if (!mounted) return;

    final hasInfo = data != null;
    final hasWarmup = data != null && _hasWarmupData(data);
    final hasPrevention = data != null && _hasInjuryPreventionData(data);

    ModalService.showSheet(context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: context.colors.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Text(
                widget.exercise.name,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Options
              if (hasInfo)
                _buildTipsOption(
                  ctx,
                  icon: AppIcons.info,
                  label: context.l10n.exerciseInfo,
                  color: context.colors.primary,
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleShowExerciseInfoModal(data);
                  },
                ),
              if (hasWarmup) ...[
                const SizedBox(height: 8),
                _buildTipsOption(
                  ctx,
                  icon: AppIcons.whatshot,
                  label: context.l10n.warmupProtocol,
                  color: context.warningColor,
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleShowWarmupModal(data);
                  },
                ),
              ],
              if (hasPrevention) ...[
                const SizedBox(height: 8),
                _buildTipsOption(
                  ctx,
                  icon: AppIcons.shieldOutlined,
                  label: context.l10n.injuryPrevention,
                  color: context.successColor,
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleShowInjuryPreventionModal(data);
                  },
                ),
              ],
              // Fallback if no data
              if (!hasInfo && !hasWarmup && !hasPrevention)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      context.l10n.noExerciseInfoAvailable,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single option row for the Tips bottom sheet
  Widget _buildTipsOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: AppIconSize.medium),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              AppIcons.chevronRight,
              color: context.colors.onSurfaceVariant,
              size: AppIconSize.small,
            ),
          ],
        ),
      ),
    );
  }

  /// ⚡ PERFORMANCE: Uses cached exercisesDatabaseProvider
  /// JSON is loaded ONCE and cached for entire session - no repeated file loads
  Future<Map<String, dynamic>?> _loadExerciseDataFromJson() async {
    if (!mounted) return null;

    // ⚡ Use cached database directly
    try {
      final exercises = await ref.read(exercisesDatabaseProvider.future);
      final exerciseName = widget.exercise.name.toLowerCase();

      // Try exact match first
      for (var exercise in exercises) {
        if (exercise['nome']?.toString().toLowerCase() == exerciseName) {
          return exercise;
        }
      }

      // Try partial match
      for (var exercise in exercises) {
        final exerciseNameInJson =
            exercise['nome']?.toString().toLowerCase() ?? '';
        if (exerciseNameInJson.contains(exerciseName) ||
            exerciseName.contains(exerciseNameInJson)) {
          return exercise;
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  void _handleShowExerciseInfoModal(Map<String, dynamic> data) {
    // Use the existing ExerciseDetailsModal which has proper styling
    // and shows both technical notes and warmup sections
    final exerciseDefinition = db.ExerciseDefinition.fromJson(data);

    // Find current exercise index for warmup insertion
    final workout = ref.read(currentWorkoutProvider);
    final exerciseIndex =
        workout?.exercises.indexWhere((e) => e.id == widget.exercise.id) ?? -1;

    // ✅ BUG FIX: Capture the provider notifier BEFORE showing modal
    // This prevents "Cannot use ref after widget disposed" error when
    // callback is invoked after user scrolls away from this exercise
    final workoutNotifier = ref.read(currentWorkoutProvider.notifier);
    final exerciseName = widget.exercise.name; // Capture for debug logging

    ExerciseDetailsModal.show(
      context,
      exerciseDefinition,
      currentExerciseIndex: exerciseIndex >= 0 ? exerciseIndex : null,
      onWarmupExerciseAdded: exerciseIndex >= 0
          ? (suggestion, beforeIndex) {
              // Use captured notifier instead of ref.read()
              _addWarmupExerciseWithNotifier(
                suggestion,
                beforeIndex,
                workoutNotifier,
                exerciseName,
              );
            }
          : null,
    );
  }

  /// Add a warmup exercise before the current exercise
  /// Uses pre-captured notifier to avoid "ref after disposed" error
  void _addWarmupExerciseWithNotifier(
    WarmupSuggestion suggestion,
    int beforeIndex,
    CurrentWorkoutNotifier workoutNotifier,
    String originalExerciseName,
  ) {
    // Create Exercise from suggestion
    final exercise = Exercise(
      name: suggestion.exerciseName,
      type: ExerciseType.single,
      category: ExerciseCategory.other,
      sets: List.generate(
        suggestion.sets,
        (i) => ExerciseSet(
          setNumber: i + 1,
          reps: suggestion.reps,
          isCompleted: false,
          isWarmup: true,
        ),
      ),
    );

    // Insert before current exercise using captured notifier
    workoutNotifier.insertExerciseAt(beforeIndex, exercise);

    if (kDebugMode) {
      debugPrint(
        '🔥 [Warmup] Added ${suggestion.exerciseName} before $originalExerciseName',
      );
    }
  }

  void _handleShowWarmupModal(Map<String, dynamic> data) {
    final theme = Theme.of(context);
    // Use correct JSON field names: mobilitaPre, attivazionePre, warmupSets, tempoWarmup
    final mobilita = data['mobilitaPre'] as String?;
    final attivazione = data['attivazionePre'] as String?;
    final warmupSets = data['warmupSets'] as String?;
    final tempoWarmup = data['tempoWarmup'] as String?;

    ModalService.showSheet(context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Row(
              children: [
                Icon(AppIcons.whatshot, color: context.warningColor),
                const SizedBox(width: 12),
                Text(
                  context.l10n.warmupProtocol,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Phase 1: Mobility
            if (mobilita != null && mobilita.isNotEmpty) ...[
              _buildWarmupPhase(
                theme,
                context.l10n.warmupPhase1Title,
                mobilita,
                context.colors.primary,
              ),
              const SizedBox(height: 16),
            ],
            // Phase 2: Activation
            if (attivazione != null && attivazione.isNotEmpty) ...[
              _buildWarmupPhase(
                theme,
                context.l10n.warmupPhase2Title,
                attivazione,
                context.warningColor,
              ),
              const SizedBox(height: 16),
            ],
            // Phase 3: Warmup Sets
            if (warmupSets != null && warmupSets.isNotEmpty) ...[
              _buildWarmupPhase(
                theme,
                context.l10n.warmupSetsLabel,
                warmupSets,
                context.successColor,
              ),
              const SizedBox(height: 16),
            ],
            // Phase 4: Warmup Time
            if (tempoWarmup != null && tempoWarmup.isNotEmpty) ...[
              _buildWarmupPhase(
                theme,
                context.l10n.warmupTimeLabel,
                tempoWarmup,
                context.colors.tertiary,
              ),
            ],
            // Fallback if no warmup data
            if ((mobilita == null || mobilita.isEmpty) &&
                (attivazione == null || attivazione.isEmpty) &&
                (warmupSets == null || warmupSets.isEmpty) &&
                (tempoWarmup == null || tempoWarmup.isEmpty))
              Text(
                context.l10n.noWarmupProtocolAvailable,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleShowInjuryPreventionModal(Map<String, dynamic> data) {
    final theme = Theme.of(context);
    // Use correct JSON field names: prevenzioneInfortuni, cooldownConsigliato, drillTecnico
    final prevention = data['prevenzioneInfortuni'] as String?;
    final cooldown = data['cooldownConsigliato'] as String?;
    final drillTecnico = data['drillTecnico'] as String?;

    ModalService.showSheet(context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Row(
              children: [
                Icon(AppIcons.shieldOutlined, color: context.successColor),
                const SizedBox(width: 12),
                Text(
                  context.l10n.injuryPrevention,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Prevention Tips
            if (prevention != null && prevention.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.successColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.safetyTips,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.successColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      prevention,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Technical Drill
            if (drillTecnico != null && drillTecnico.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.trackChanges,
                          size: 18,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.technicalDrill,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      drillTecnico,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Cooldown
            if (cooldown != null && cooldown.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colors.tertiary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.spa,
                          size: 18,
                          color: context.colors.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.recommendedCooldown,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.tertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cooldown,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Fallback if no data
            if ((prevention == null || prevention.isEmpty) &&
                (cooldown == null || cooldown.isEmpty) &&
                (drillTecnico == null || drillTecnico.isEmpty))
              Text(
                context.l10n.noInjuryPreventionInfo,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarmupPhase(
    ThemeData theme,
    String title,
    String content,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _handleShowExerciseHistory() {
    ModalService.showSheet(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseHistoryBottomSheet(
        exerciseName: widget.exercise.name,
        exerciseId: widget.exercise.id,
      ),
    );
  }

  void _handleShowExerciseEditor() {
    widget.onEdit?.call();
  }

  void _handleShowExerciseReplacement() {
    widget.onReplace?.call();
  }

  void _handleDuplicateExercise() {
    if (kDebugMode) {
      debugPrint('Duplicate exercise: ${widget.exercise.name}');
    }
    // Duplicate exercise implementation would be in workout provider
    // For now, just log the action
    HapticFeedback.mediumImpact();
    SnackBarService.showSuccess(
      context,
      'Exercise duplicated: ${widget.exercise.name}',
    );
  }

  void _handleShowDeleteConfirmation() {
    widget.onDelete();
  }

  Future<void> _handleEditNotes() async {
    // Get current Form Cues from repository
    final prefsRepository = ref.read(userExercisePreferencesRepositoryProvider);
    final currentFormCues = await prefsRepository.getFormCues(
      widget.exercise.id,
      widget.exercise.name,
    );

    if (!mounted) return;

    // Show the two-section notes dialog
    final result = await ExerciseNotesHandler.showNotesDialog(
      context,
      exerciseId: widget.exercise.id,
      exerciseName: widget.exercise.name,
      currentSessionNotes: widget.exercise.notes,
      currentFormCues: currentFormCues,
    );

    if (result != null && mounted) {
      // Save Form Cues if changed
      if (result.formCues != currentFormCues) {
        await prefsRepository.saveFormCues(
          widget.exercise.id,
          widget.exercise.name,
          result.formCues,
        );
        // Invalidate the provider to refresh UI
        ref.invalidate(
          formCuesProvider((
            exerciseId: widget.exercise.id,
            exerciseName: widget.exercise.name,
          )),
        );
      }

      // Save Session Notes if changed
      if (result.sessionNotes != widget.exercise.notes &&
          widget.onExerciseUpdate != null) {
        final updatedExercise = widget.exercise.copyWith(
          notes: result.sessionNotes?.isEmpty == true
              ? null
              : result.sessionNotes,
          updatedAt: DateTime.now(),
        );
        widget.onExerciseUpdate!(updatedExercise);
      }

      await HapticFeedback.lightImpact();
      if (mounted) {
        SnackBarService.showSuccess(context, context.l10n.notesSaved);
      }
    }
  }

  /// Opens SupersetLinkModal to create a superset starting from this exercise
  void _handleCreateSuperset() async {
    // Get workout exercises (excluding current exercise)
    final workout = ref.read(currentWorkoutProvider);
    if (workout == null) return;

    // Show modal
    final result = await SupersetLinkModal.show(
      context: context,
      currentExercise: widget.exercise,
      workoutExercises: workout.exercises,
    );

    if (result != null && mounted) {
      // TODO: Create superset from configuration result
      // For now, log the selection
      if (kDebugMode) {
        debugPrint(
          '🔗 [Superset] Created with ${result.exercises.length} exercises',
        );
        for (final ex in result.exercises) {
          debugPrint('   - ${ex.nome}');
        }
      }

      unawaited(HapticFeedback.mediumImpact());
      SnackBarService.showSuccess(context, context.l10n.supersetCreated);
    }
  }

  /// Show quick upgrade modal for exercise metadata update
  Future<void> _handleShowQuickUpgrade(MergeCandidate candidate) async {
    // Get affected items count before showing modal
    final upgradeService = ref.read(exerciseUpgradeServiceProvider);
    final affectedItems = await upgradeService.countAffectedItems(
      widget.exercise.name,
    );

    if (!mounted) return;

    final result = await QuickUpgradeModal.show(
      context,
      currentExerciseName: widget.exercise.name,
      candidate: candidate,
      affectedWorkoutsCount: affectedItems.total,
    );

    if (!context.mounted) return;

    if (result != null) {
      // Update exercise with new metadata from target exercise
      final workoutNotifier = ref.read(currentWorkoutProvider.notifier);

      // Update exercise name in current workout
      workoutNotifier.updateExercise(
        widget.exercise.id,
        widget.exercise.copyWith(name: result.targetExercise.nome),
      );

      // If user wants to update other workouts/templates
      if (result.updateOtherWorkouts && affectedItems.hasAffectedItems) {
        final updatedCount = await upgradeService.updateExerciseAcrossItems(
          oldExerciseName: widget.exercise.name,
          newExerciseName: result.targetExercise.nome,
        );

        if (kDebugMode) {
          debugPrint(
            '🔄 [QuickUpgrade] Updated $updatedCount workouts/templates',
          );
        }
      }

      if (!context.mounted) return;
      unawaited(HapticFeedback.mediumImpact());
      // ignore: use_build_context_synchronously
      SnackBarService.showSuccess(context, context.l10n.exerciseUpgraded);
    }
  }

  /// BUG FIX: Show counting mode picker to change exercise counting mode
  /// This was missing from the new orchestrator implementation
  ///
  /// Now supports saving the counting mode as a permanent default for the exercise.
  Future<void> _handleShowCountingModePicker() async {
    final result = await CountingModePickerModal.show(
      context,
      currentMode: widget.exercise.countingMode,
      exerciseId: widget
          .exercise
          .id, // ✅ workout exercise uses 'id' (preserves database exercise ID)
      exerciseName: widget.exercise.name,
    );

    if (result != null &&
        result.mode != widget.exercise.countingMode &&
        mounted) {
      // Update exercise with new counting mode
      final updatedExercise = widget.exercise.copyWith(
        countingMode: result.mode,
        updatedAt: DateTime.now(),
      );

      // Update via provider
      ref
          .read(currentWorkoutProvider.notifier)
          .updateExercise(widget.exercise.id, updatedExercise);

      // If user wants to save as default, persist to Firestore
      if (result.saveAsDefault) {
        final repo = ref.read(exercisePreferencesRepositoryProvider);
        if (repo != null) {
          await repo.setCountingModeOverride(
            widget
                .exercise
                .id, // ✅ workout exercise uses 'id' (preserves database exercise ID)
            result.mode.name,
          );
        }
      }

      // Show confirmation
      if (mounted) {
        unawaited(HapticFeedback.mediumImpact());
        final message = result.saveAsDefault
            ? context.l10n.countingModeChangedAndSaved
            : context.l10n.countingModeChanged;
        SnackBarService.showSuccess(context, message);
      }

      if (kDebugMode) {
        debugPrint(
          '🔄 [CountingMode] Changed from ${widget.exercise.countingMode.name} to ${result.mode.name}'
          '${result.saveAsDefault ? ' (saved as default)' : ''}',
        );
      }
    }
  }

  // === Warmup Helper Methods ===

  /// Whether this exercise is a compound movement.
  ///
  /// Uses exerciseData['tipoEsercizio'] first (most accurate),
  /// falls back to Exercise.movementType, defaults to true (safe).
  bool _isCompoundExercise() {
    // Check structured DB field first
    final tipo = _exerciseData?['tipoEsercizio'] as String?;
    if (tipo != null) {
      return tipo == 'Compound' || tipo == 'compound';
    }
    // Fallback to Exercise entity movementType
    final mt = widget.exercise.movementType;
    if (mt != null) {
      return mt == MovementType.compoundHeavy ||
          mt == MovementType.compoundMedium;
    }
    // Safe default: assume compound (better to warmup unnecessarily)
    return true;
  }

  /// Whether this exercise uses a barbell.
  ///
  /// Checks exerciseData['attrezzatura'] first, falls back to name heuristic.
  bool _isBarbellExercise() {
    final warmupCalc = WarmupCalculatorService();
    final attrezzatura = _exerciseData?['attrezzatura'] as String?;
    if (warmupCalc.isBarbellByAttrezzatura(attrezzatura)) return true;
    return warmupCalc.isLikelyBarbellExercise(widget.exercise.name);
  }

  /// Whether this exercise needs warmup sets.
  ///
  /// Returns false for isolation, stretching, and cardio exercises.
  /// Delegates to [_isCompoundExercise] for structured detection.
  bool _needsWarmup() {
    // Check explicit non-warmup types from DB
    final tipo = _exerciseData?['tipoEsercizio'] as String?;
    if (tipo != null) {
      final lower = tipo.toLowerCase();
      if (lower == 'stretching' || lower == 'cardio') return false;
    }
    // Use compound detection for the rest
    return _isCompoundExercise();
  }

  /// Determines warmup context by checking if previous exercises in this
  /// workout have already trained the same or synergistic muscle groups.
  ///
  /// Uses [WarmupCalculatorService.determineContext] which considers:
  /// - Direct match (same category) → [WarmupContext.alreadyWarm] (skip)
  /// - Synergistic match (e.g. chest→shoulders) → [WarmupContext.subsequent]
  /// - No prior work → [WarmupContext.firstCompound]
  WarmupContext _determineWarmupContext() {
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout == null) return WarmupContext.firstCompound;

    final exercises = currentWorkout.exercises;
    final myCategory = widget.exercise.category;
    final myIndex = exercises.indexWhere((e) => e.id == widget.exercise.id);

    // Collect categories trained before this exercise
    // An exercise counts as "trained" if it has any non-warmup sets
    final categoriesTrained = <ExerciseCategory>{};
    for (var i = 0; i < myIndex; i++) {
      final ex = exercises[i];
      if (ex.sets.any((s) => !s.isWarmup)) {
        categoriesTrained.add(ex.category);
      }
    }

    return WarmupCalculatorService.determineContext(
      myCategory,
      categoriesTrained,
    );
  }

  /// Add or edit warmup sets for the exercise.
  ///
  /// **Edit path** (warmup already exist): opens modal to edit them.
  /// **New path**: one-tap generation using V2 protocol with smart detection.
  void _handleAddWarmupSets() {
    // Check for existing warmup sets
    final existingWarmupSets =
        widget.exercise.sets.where((s) => s.isWarmup).toList();
    final workingSets =
        widget.exercise.sets.where((s) => !s.isWarmup).toList();

    // If editing existing warmup sets — open modal
    if (existingWarmupSets.isNotEmpty) {
      final warmupSetsForModal = existingWarmupSets.map((s) {
        final targetWeight = workingSets.isNotEmpty
            ? workingSets.first.weight ?? 0.0
            : 0.0;
        final percentage = targetWeight > 0
            ? ((s.weight ?? 0) / targetWeight * 100).round()
            : 0;
        return WarmupSet(
          weight: s.weight ?? 0.0,
          reps: s.reps ?? 10,
          percentage: percentage,
        );
      }).toList();

      _showWarmupModal(warmupSetsForModal, isEditing: true);
      return;
    }

    // Guard: isolation exercises don't need warmup
    if (!_needsWarmup()) {
      SnackBarService.showInfo(
        context,
        context.l10n.warmupNotNeededForIsolation,
      );
      return;
    }

    // Guard: need working sets
    if (workingSets.isEmpty) {
      SnackBarService.showError(context, context.l10n.addWorkingSetFirst);
      return;
    }

    final targetWeight = workingSets.first.weight ?? 0.0;

    // Guard: need a weight
    if (targetWeight <= 0) {
      SnackBarService.showError(context, context.l10n.setTargetWeightFirst);
      return;
    }

    // Generate V2 warmup sets with smart detection
    final warmupCalculator = WarmupCalculatorService();
    final warmupContext = _determineWarmupContext();
    final generatedSets = warmupCalculator.calculateWarmupSetsV2(
      targetWeight,
      warmupContext: warmupContext,
      isBarbell: _isBarbellExercise(),
    );

    // One-tap: apply directly without opening modal
    _applyWarmupSets(generatedSets, isEditing: false);
  }

  /// Shows the warmup customization modal and handles the result
  void _showWarmupModal(
    List<WarmupSet> initialSets, {
    required bool isEditing,
  }) {
    HapticFeedback.lightImpact();

    WarmupCustomizationModal.show(
      context: context,
      initialSets: initialSets,
      onConfirm: (updatedSets) {
        _applyWarmupSets(updatedSets, isEditing: isEditing);
      },
    );
  }

  /// Applies the warmup sets from the modal to the exercise
  void _applyWarmupSets(List<WarmupSet> warmupSets, {required bool isEditing}) {
    if (warmupSets.isEmpty) {
      // User deleted all warmup sets
      if (isEditing) {
        // Remove all warmup sets from exercise
        final workingSets = widget.exercise.sets
            .where((s) => !s.isWarmup)
            .toList();
        final renumberedSets = workingSets
            .asMap()
            .map((index, set) {
              return MapEntry(index, set.copyWith(setNumber: index + 1));
            })
            .values
            .toList();

        final updatedExercise = widget.exercise.copyWith(
          sets: renumberedSets,
          updatedAt: DateTime.now(),
        );

        ref
            .read(currentWorkoutProvider.notifier)
            .updateExercise(widget.exercise.id, updatedExercise);

        HapticFeedback.mediumImpact();
        SnackBarService.showSuccess(
          context,
          context.l10n.warmupSetsUpdated('0'),
        );
      }
      return;
    }

    // Convert WarmupSet to ExerciseSet
    final newWarmupExerciseSets = warmupSets
        .asMap()
        .map((index, warmup) {
          return MapEntry(
            index,
            ExerciseSet(
              setNumber: index + 1,
              weight: warmup.weight,
              reps: warmup.reps,
              isWarmup: true,
              isCompleted: false,
            ),
          );
        })
        .values
        .toList();

    // Get working sets (non-warmup)
    final workingSets = widget.exercise.sets.where((s) => !s.isWarmup).toList();

    // Renumber working sets to come after warmup sets
    final renumberedWorkingSets = workingSets
        .asMap()
        .map((index, set) {
          return MapEntry(
            index,
            set.copyWith(setNumber: newWarmupExerciseSets.length + index + 1),
          );
        })
        .values
        .toList();

    // Combine: warmup sets first, then working sets
    final allSets = [...newWarmupExerciseSets, ...renumberedWorkingSets];

    // Update exercise
    final updatedExercise = widget.exercise.copyWith(
      sets: allSets,
      updatedAt: DateTime.now(),
    );

    ref
        .read(currentWorkoutProvider.notifier)
        .updateExercise(widget.exercise.id, updatedExercise);

    // Show feedback
    HapticFeedback.mediumImpact();
    if (isEditing) {
      SnackBarService.showSuccess(
        context,
        context.l10n.warmupSetsUpdated(warmupSets.length.toString()),
      );
    } else {
      SnackBarService.showSuccess(
        context,
        context.l10n.warmupSetsAdded(warmupSets.length.toString()),
      );
    }

    if (kDebugMode) {
      final action = isEditing ? 'Updated' : 'Added';
      debugPrint(
        '🔥 [Warmup] $action ${warmupSets.length} warmup sets for ${widget.exercise.name}',
      );
    }
  }

  bool _hasWarmupData(Map<String, dynamic> data) {
    return data['mobilitaPre'] != null ||
        data['attivazionePre'] != null ||
        data['warmupSets'] != null ||
        data['tempoWarmup'] != null;
  }

  bool _hasInjuryPreventionData(Map<String, dynamic> data) {
    return data['prevenzioneInfortuni'] != null ||
        data['cooldownConsigliato'] != null ||
        data['drillTecnico'] != null ||
        data['noteTecniche'] != null;
  }

  // ========================================================================
  // SETS CALLBACKS
  // ========================================================================

  void _handleStartRestTimer(BuildContext context, ExerciseSet set) {
    // Start rest timer using tier1 timer actions (includes UI + sound preference)
    // BUG FIX: Use set.restTime → exercise.restTime → 90s fallback chain
    // Previously only used set.restTime ?? 90, ignoring exercise-level custom timer
    final config = ref.read(appConfigProvider);
    final baseRestSeconds = set.restTime ?? widget.exercise.restTime ?? 90;

    // 🔄 RPE-based rest time adjustment (when enabled)
    // If user completed set with RPE and autoAdjustRestFromRpe is enabled,
    // adjust rest time based on perceived exertion:
    // - High RPE (9-10): +30-60s more rest for recovery
    // - Moderate RPE (7-8): standard rest
    // - Low RPE (<7): -15-30s less rest (not as fatigued)
    int adjustedRestSeconds = baseRestSeconds;

    if ((config.autoAdjustRestFromRpe ?? false) && set.rpe != null) {
      final adjustment = RPEAutoregulationService.calculateRestTimeAdjustment(
        baseRestSeconds: baseRestSeconds,
        actualRPE: set.rpe!.toDouble(),
      );

      adjustedRestSeconds = adjustment.adjustedRestSeconds;

      // ✅ Show user feedback when rest time is adjusted
      if (adjustment.hasAdjustment && mounted) {
        final sign = adjustment.needsMoreRest ? '+' : '';
        final adjustmentSecs = adjustment.adjustmentSeconds;
        SnackBarService.showInfo(
          context,
          '⏱️ ${context.l10n.restTimeAdjusted}: ${baseRestSeconds}s → ${adjustedRestSeconds}s ($sign${adjustmentSecs}s)',
        );
      }

      if (kDebugMode && adjustment.hasAdjustment) {
        debugPrint(
          '🔄 [RPE Rest Adjustment] ${adjustment.reason} '
          '(${baseRestSeconds}s → ${adjustedRestSeconds}s)',
        );
      }
    }

    final timerActions = ref.read(tier1TimerActionsProvider);
    timerActions.startExerciseRest(
      seconds: adjustedRestSeconds,
      exerciseName: widget.exercise.name,
      exerciseId: widget.exercise.id,
      currentSet: set.setNumber,
      totalSets: widget.exercise.sets.length,
    );
  }

  void _handleExecuteDropSet(DropSetExercise dropsetExercise) {
    if (kDebugMode) {
      debugPrint('Execute dropset for ${widget.exercise.name}');
    }

    // Find first incomplete stage
    final firstIncompleteIndex = dropsetExercise.stages.indexWhere(
      (stage) => !stage.isCompleted,
    );

    if (firstIncompleteIndex == -1) {
      // All stages completed - show completion message
      SnackBarService.showSuccess(context, context.l10n.dropsetCompleted);
      return;
    }

    // Start the dropset execution flow
    _executeDropSetStage(
      dropsetExercise: dropsetExercise,
      stageIndex: firstIncompleteIndex,
    );
  }

  /// Executes a single dropset stage, then continues to the next if available
  Future<void> _executeDropSetStage({
    required DropSetExercise dropsetExercise,
    required int stageIndex,
  }) async {
    if (!mounted) return;

    // Get previous stage weight for percentage calculation
    final previousStageWeight = stageIndex > 0
        ? dropsetExercise.stages[stageIndex - 1].weight
        : null;

    // Get current stage for initial weight (if editing)
    final currentStage = dropsetExercise.stages[stageIndex];

    // Try to get exercise definition for equipment detection
    db.Exercise? selectedExercise;
    if (_exerciseData != null) {
      try {
        selectedExercise = db.ExerciseDefinition.fromJson(_exerciseData!);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Could not parse exercise data: $e');
        }
      }
    }

    // Show weight picker modal
    final selectedWeight = await DropSetWeightPickerModal.show(
      context: context,
      stageIndex: stageIndex,
      previousStageWeight: previousStageWeight,
      initialWeight: currentStage.weight > 0 ? currentStage.weight : null,
      selectedExercise: selectedExercise,
      exerciseName: dropsetExercise.name,
    );

    // User cancelled
    if (selectedWeight == null || !mounted) return;

    // Update the stage with the selected weight and mark as completed
    final updatedStages = List<DropSetStage>.from(dropsetExercise.stages);
    updatedStages[stageIndex] = currentStage.copyWith(
      weight: selectedWeight,
      isCompleted: true,
    );

    // Create updated exercise
    final updatedExercise = DropSetExercise(
      id: dropsetExercise.id,
      name: dropsetExercise.name,
      category: dropsetExercise.category,
      stages: updatedStages,
      notes: dropsetExercise.notes,
      restTime: dropsetExercise.restTime,
    );

    // Notify parent of the update
    widget.onExerciseUpdate?.call(updatedExercise);

    // ✅ Haptic feedback for stage completion using centralized service
    // Respects user preferences for haptic intensity
    HapticFeedbackService.setCompletion(ref);

    // Check if there are more stages
    final nextStageIndex = stageIndex + 1;
    if (nextStageIndex < updatedExercise.stages.length) {
      // Show brief feedback then continue to next stage
      if (mounted) {
        SnackBarService.showInfo(
          context,
          '${context.l10n.stageCompleted(stageIndex + 1)} - ${context.l10n.continueToNextStage}',
        );
      }

      // Small delay for user to see feedback, then continue
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        // Continue to next stage
        await _executeDropSetStage(
          dropsetExercise: updatedExercise,
          stageIndex: nextStageIndex,
        );
      }
    } else {
      // All stages completed - show completion modal for summary and RPE
      if (mounted) {
        final selectedRpe = await DropSetCompletionModal.show(
          context: context,
          exerciseName: updatedExercise.name,
          stages: updatedExercise.stages,
        );

        // Update all stages with the selected RPE
        if (selectedRpe != null && mounted) {
          final stagesWithRpe = updatedExercise.stages
              .map((stage) => stage.copyWith(rpe: selectedRpe))
              .toList();

          final exerciseWithRpe = DropSetExercise(
            id: updatedExercise.id,
            name: updatedExercise.name,
            category: updatedExercise.category,
            stages: stagesWithRpe,
            notes: updatedExercise.notes,
            restTime: updatedExercise.restTime,
          );

          // Notify parent of the update with RPE
          widget.onExerciseUpdate?.call(exerciseWithRpe);
        }

        // Start rest timer after completing dropset
        if (mounted) {
          _handleStartRestTimer(
            context,
            ExerciseSet(
              setNumber: 1,
              weight: updatedExercise.stages.first.weight,
              reps: updatedExercise.stages.first.reps,
              restTime: updatedExercise.restTime,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleExecuteRestPause(
    RestPauseExercise restPauseExercise,
  ) async {
    if (kDebugMode) {
      debugPrint('Execute rest-pause for ${widget.exercise.name}');
    }

    // Check if already completed
    final allCompleted =
        restPauseExercise.restPauseSets.isNotEmpty &&
        restPauseExercise.restPauseSets.every((s) => s.isCompleted);

    if (allCompleted) {
      // Ask if user wants to re-run
      final shouldRerun = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.rerunRestPause),
          content: Text(context.l10n.restPauseAlreadyCompleted),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.rerunRestPause),
            ),
          ],
        ),
      );

      if (shouldRerun != true || !mounted) return;
    }

    // Check if we're resuming from paused state
    final existingIncompleteSets = restPauseExercise.restPauseSets
        .where((s) => s.isCompleted)
        .toList();
    final hasPartialProgress = existingIncompleteSets.isNotEmpty && !allCompleted;

    // Check if user has seen Rest-Pause tutorial
    final config = ref.read(appConfigProvider);
    final showTutorial = !config.hasSeenRestPauseTutorial;

    // Show execution modal
    final result = await RestPauseExecutionModal.show(
      context: context,
      exerciseName: restPauseExercise.name,
      weight: restPauseExercise.weight,
      targetReps: restPauseExercise.targetReps,
      restPauseSets: restPauseExercise.restPauseSets,
      resumeFromSets: hasPartialProgress ? existingIncompleteSets : null,
      showTutorialOnFirstUse: showTutorial,
      onTutorialSeen: () {
        ref.read(appConfigProvider.notifier).setHasSeenRestPauseTutorial(true);
      },
    );

    // User cancelled
    if (result == null || !mounted) return;

    // Update the exercise with completed sets and RPE
    // Using copyWith() to preserve all fields (restAfterExercise, tut, advanced fields)
    final updatedSets = result.completedSets.map((set) {
      return set.copyWith(rpe: result.rpe);
    }).toList();

    final updatedExercise = restPauseExercise.copyWith(
      restPauseSets: updatedSets,
    );

    // Notify parent of the update
    widget.onExerciseUpdate?.call(updatedExercise);

    // Handle paused state - save progress but don't start rest timer
    if (result.isPaused) {
      if (kDebugMode) {
        debugPrint(
          '⏸️ [RestPause] Paused with ${result.completedSets.length} sets, '
          'total ${result.completedSets.fold(0, (sum, s) => sum + s.effectiveReps)} reps',
        );
      }
      // Show paused snackbar
      if (mounted) {
        SnackBarService.showInfo(
          context,
          context.l10n.pauseAndContinueLater,
          actionLabel: context.l10n.resumeRestPause,
          onAction: () => _handleExecuteRestPause(updatedExercise),
        );
      }
      return;
    }

    // Haptic feedback for completion
    unawaited(HapticFeedback.heavyImpact());

    if (kDebugMode) {
      debugPrint(
        '✅ [RestPause] Completed ${result.completedSets.length} sets, '
        'total ${result.completedSets.fold(0, (sum, s) => sum + s.effectiveReps)} reps, '
        'RPE: ${result.rpe}',
      );
    }

    // Start rest timer after completing rest-pause
    if (mounted) {
      _handleStartRestTimer(
        context,
        ExerciseSet(
          setNumber: 1,
          weight: restPauseExercise.weight,
          reps: restPauseExercise.targetReps,
          restTime: restPauseExercise.restTime,
        ),
      );
    }
  }

  void _handleCollapseExercise() {
    _expansionNotifier.collapse();
  }

  IconData _getSuggestionIcon(String suggestionType) {
    switch (suggestionType) {
      case 'technique':
        return AppIcons.edit;
      case 'warning':
        return AppIcons.warning;
      case 'tip':
        return AppIcons.lightbulb;
      case 'variant':
        return AppIcons.sync;
      case 'correction':
        return AppIcons.checkCircle;
      case 'translation':
        return AppIcons.translate;
      default:
        return AppIcons.info;
    }
  }

  // ========================================================================
  // BUILD
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    // Watch full config for child widgets that need multiple properties
    final config = ref.watch(appConfigProvider);

    // ✅ Watch ExerciseCardSettings for visual toggles
    final density = ref.watch(exerciseCardDensityProvider);

    // ✅ PERFORMANCE FIX: Watch ONLY the specific properties needed for rendering
    // Previously, getters with ref.watch were causing rebuild chains when accessed.
    // Now we watch once in build() and use the local variables.
    final isExpanded = ref.watch(
      exerciseExpansionProvider(
        widget.exercise.id,
      ).select((state) => state.isExpanded),
    );
    final suggestions = ref.watch(
      exerciseSuggestionsProvider(widget.exercise.id),
    );

    // Watch Form Cues for this exercise (persistent technique reminders)
    final formCuesAsync = ref.watch(
      formCuesProvider((
        exerciseId: widget.exercise.id,
        exerciseName: widget.exercise.name,
      )),
    );
    final formCues = formCuesAsync.value;

    // Listen for auto-collapse completion
    ref.listen(
      exerciseAutoCollapseProvider(
        widget.exercise.id,
      ).select((state) => state.shouldExecuteCollapse),
      (previous, shouldCollapse) {
        if (shouldCollapse) {
          // Execute the collapse
          _expansionNotifier.autoCollapse();
          _autoCollapseNotifier.acknowledgeCollapse();

          if (kDebugMode) {
            debugPrint(
              '✅ [AutoCollapse] Exercise "${widget.exercise.name}" auto-collapsed',
            );
          }
        }
      },
    );

    // ✅ FIX: Listen for autoCollapseCompleted toggle changes
    // This ensures immediate reactivity when user changes the toggle in settings modal
    ref.listen(appConfigProvider.select((c) => c.autoCollapseCompleted), (
      previous,
      next,
    ) {
      // When toggle is enabled and exercise is completed, trigger auto-collapse
      if (next == true && previous == false && _areAllSetsCompleted()) {
        _autoCollapseIfCompleted();
      }
    });

    // Reorder mode - show simplified card (matching normal card styling)
    if (widget.isReorderMode) {
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
                Icon(
                  AppIcons.dragHandle,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.exercise.name,
                    style: context.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // BUG FIX #4: Wrap card in GestureDetector to allow expanding collapsed exercises
    // When exercise is collapsed, tapping anywhere on the card expands it

    // 🔧 PERF FIX: Wrap entire list item in RepaintBoundary to isolate repaints
    return RepaintBoundary(
      child: GestureDetector(
      onTap: !isExpanded
          ? () {
              _expansionNotifier.expand();
              HapticFeedback.lightImpact();
              if (kDebugMode) {
                debugPrint(
                  '📖 [Expand] Exercise "${widget.exercise.name}" expanded by tap',
                );
              }
            }
          : null,
      // ✅ DESIGN: Full-width cards with no horizontal margin (like superset cards)
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        child: DecoratedBox(
          decoration: BoxDecoration(
            // ✅ UX IMPROVEMENT: Visual state differentiation
            // Collapsed cards are slightly lighter to indicate "completed/inactive" state
            // Expanded cards use normal surfaceContainer for "active" feel
            color: !isExpanded
                ? context.colors.surfaceContainerLowest
                : context.colors.surfaceContainer,
            // ✅ DESIGN: Slightly softer corners
            borderRadius: BorderRadius.circular(16),
            // ✅ UX IMPROVEMENT: Collapsed cards have more subtle border
            // This creates hierarchy: expanded = active (prominent), collapsed = inactive (subtle)
            border: Border.all(
              color: !isExpanded
                  ? context.colors.outline.withValues(alpha: 0.15)
                  : context.colors.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              // ✅ DESIGN: Lighter, more subtle shadow
              BoxShadow(
                color: context.colors.shadow.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Material(
            color: context.colors.surface.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                // ✅ FIX: Use density from ExerciseCardSettings
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: density.horizontalPadding,
                    vertical: density.verticalPadding,
                  ),
                  child: ExerciseListItemHeader(
                    exercise: widget.exercise,
                    config: config,
                    isProMode: isProMode,
                    autoCollapseState: _autoCollapseState,
                    lastActivity: _lastActivity,
                    formCues: formCues,
                    onCancelAutoCollapse: _handleCancelAutoCollapse,
                    onShowAutoAdjustmentModal: _handleShowAutoAdjustmentModal,
                    onShowQuickTimerSettings: _handleShowQuickTimerSettings,
                    onShowTutExplanationModal: _handleShowTutExplanationModal,
                    onLoadExerciseData: _loadExerciseDataFromJson,
                    onShowExerciseInfoModal: _handleShowExerciseInfoModal,
                    onShowWarmupModal: _handleShowWarmupModal,
                    onShowInjuryPreventionModal:
                        _handleShowInjuryPreventionModal,
                    onShowExerciseHistory: _handleShowExerciseHistory,
                    onShowExerciseEditor: _handleShowExerciseEditor,
                    onShowExerciseReplacement: _handleShowExerciseReplacement,
                    onDuplicateExercise: _handleDuplicateExercise,
                    onShowDeleteConfirmation: _handleShowDeleteConfirmation,
                    onShowCountingModePicker: _handleShowCountingModePicker,
                    onAddWarmupSets: _handleAddWarmupSets,
                    onEditNotes: _handleEditNotes,
                    onCreateSuperset: _handleCreateSuperset,
                    onShowQuickUpgrade: _handleShowQuickUpgrade,
                    hasWarmupData: _hasWarmupData,
                    hasInjuryPreventionData: _hasInjuryPreventionData,
                    tutorialMenuKey: widget.tutorialExerciseMenuKey,
                    isExpanded: isExpanded,
                  ),
                ),

                // Weight Jump Indicator (minimal, stable, no auto-dismiss)
                // Calculated locally to avoid provider re-renders
                Builder(
                  builder: (context) {
                    final weights = widget.exercise.sets
                        .where((s) => s.isCompleted && !s.isWarmup)
                        .map((s) => s.weight)
                        .whereType<double>()
                        .where((w) => w > 0)
                        .toList();

                    if (weights.length < 2) {
                      return const SizedBox.shrink();
                    }

                    final minWeight = weights.reduce((a, b) => a < b ? a : b);
                    final maxWeight = weights.reduce((a, b) => a > b ? a : b);

                    if (!WeightJumpIndicator.hasWeightJump(
                      minWeight: minWeight,
                      maxWeight: maxWeight,
                    )) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        density.horizontalPadding, 0, density.horizontalPadding, density.sectionSpacing,
                      ),
                      child: WeightJumpIndicator(
                        minWeight: minWeight,
                        maxWeight: maxWeight,
                        showLabel: true,
                      ),
                    );
                  },
                ),

                // Smart suggestions (filtered: excludes weight_jump warnings)
                Builder(
                  builder: (context) {
                    // Filter out weight jump suggestions (handled by indicator above)
                    final filteredSuggestions = suggestions
                        .where((s) => !s.id.contains('weight_jump'))
                        .toList();

                    if (filteredSuggestions.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: density.horizontalPadding),
                      child: Column(
                        children: [
                          Wrap(
                            spacing: density.sectionSpacing,
                            runSpacing: density.sectionSpacing,
                            children: filteredSuggestions.map((suggestion) {
                              return SmartSuggestionChip(
                                key: ValueKey(suggestion.id),
                                suggestion: suggestion.text,
                                icon: _getSuggestionIcon(suggestion.type),
                                fullSuggestion: suggestion,
                                onDismiss: () {
                                  // TEMPORARY: Disabled for Riverpod 3.x migration
                                  /* _suggestionsNotifier.dismissSuggestion(
                                    suggestion.id,
                                  ); */
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    );
                  },
                ),

                // Sets section with smooth animation
                // ✅ UX IMPROVEMENT: AnimatedSize provides smooth expand/collapse transition
                // Instead of instant show/hide, content animates in/out for better UX
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: isExpanded
                      ? Padding(
                          // ✅ FIX: Use density from ExerciseCardSettings
                          padding: EdgeInsets.fromLTRB(
                            density.horizontalPadding,
                            0,
                            density.horizontalPadding,
                            density.verticalPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExerciseListItemSets(
                                exercise: widget.exercise,
                                config: config,
                                onExerciseUpdate: (exercise) {
                                  widget.onExerciseUpdate?.call(exercise);
                                },
                                onSetToggleComplete: (set) {
                                  widget.onSetToggleComplete?.call(set);
                                },
                                onStartRestTimer: _handleStartRestTimer,
                                onExecuteDropSet: _handleExecuteDropSet,
                                onExecuteRestPause: _handleExecuteRestPause,
                                onCollapseExercise: _handleCollapseExercise,
                                tutorialFirstSetKey: widget.tutorialFirstSetKey,
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // ✅ NEW: Footer section with Tips, TUT, Notes
                // Shows compact chips, expandable for full content
                // Part of Exercise Card redesign to reduce information overload
                // ✅ Footer hidden when collapsed (no TUT/timer when compressed)
                if (isExpanded)
                  ExerciseListItemFooter(
                    exercise: widget.exercise,
                    formCues: formCues,
                    onEditNotes: _handleEditNotes,
                    onShowTutExplanationModal: _handleShowTutExplanationModal,
                    onShowTipsBottomSheet: () => _handleShowTipsBottomSheet(),
                    onShowPlatesCalculator: _handleShowPlatesCalculator,
                    showPlatesCalculator: _usesPlateLoadableEquipment(),
                  ),

                // ✅ Collapsed summary: tonnage + muscle focus (no TUT/timer)
                if (!isExpanded)
                  _CollapsedSummary(exercise: widget.exercise),
              ],
            ),
          ),
        ),
      ),
      ), // 🔧 PERF FIX: Close RepaintBoundary
    );
  }
}

/// Collapsed summary showing tonnage + muscle focus
///
/// Replaces the "tap to expand" hint with useful data:
/// - Total tonnage (weight × reps for completed sets) in kg
/// - Muscle focus category
class _CollapsedSummary extends StatelessWidget {
  const _CollapsedSummary({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    // Calculate tonnage from completed non-warmup sets
    double tonnage = 0;
    for (final set in exercise.sets) {
      if (set.isCompleted && !set.isWarmup) {
        final weight = set.weight ?? 0;
        final reps = set.reps ?? 0;
        tonnage += weight * reps;
      }
    }

    // Category display name
    final categoryLabel = _categoryToLabel(context, exercise.category);

    // Format tonnage - remove decimal if .0
    final tonnageStr = tonnage == tonnage.truncateToDouble()
        ? tonnage.truncate().toString()
        : tonnage.toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          // Tonnage chip
          if (tonnage > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.workout,
                    size: AppIconSize.tiny,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${tonnageStr}kg',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Category chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.secondaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              categoryLabel,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          // Expand hint icon
          Icon(
            AppIcons.expandMore,
            size: AppIconSize.tiny,
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  String _categoryToLabel(BuildContext context, ExerciseCategory category) {
    return switch (category) {
      ExerciseCategory.chest => context.l10n.exerciseCategoryChest,
      ExerciseCategory.back => context.l10n.exerciseCategoryBack,
      ExerciseCategory.shoulders => context.l10n.exerciseCategoryShoulders,
      ExerciseCategory.arms => context.l10n.exerciseCategoryArms,
      ExerciseCategory.legs => context.l10n.exerciseCategoryLegs,
      ExerciseCategory.abs => context.l10n.exerciseCategoryAbs,
      ExerciseCategory.cardio => context.l10n.exerciseCategoryCardio,
      ExerciseCategory.other => context.l10n.exerciseCategoryOther,
    };
  }
}

/// Temporary widget for showing smart suggestions
/// TODO: Move to dedicated file when community contributions feature is implemented
class SmartSuggestionChip extends StatelessWidget {
  const SmartSuggestionChip({
    super.key,
    required this.suggestion,
    required this.icon,
    required this.fullSuggestion,
    required this.onDismiss,
  });

  final String suggestion;
  final IconData icon;
  final SmartSuggestion fullSuggestion;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: AppIconSize.small),
      label: Text(
        suggestion,
        style: context.textTheme.bodySmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: onDismiss,
      backgroundColor: context.colors.surfaceContainerHighest,
    );
  }
}

/// ✅ NEW: Plate Calculator Chip widget
/// Shows calculated plates for the exercise weight and opens configurator on tap
/// Uses ConsumerWidget to read available plates from appConfigProvider
/// so it auto-updates when user changes plate configuration
class _PlateCalculatorChip extends ConsumerWidget {
  const _PlateCalculatorChip({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read available plates from config (auto-updates when user changes in modal)
    final config = ref.watch(appConfigProvider);
    final availablePlates = config.availablePlates ??
        [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25, 0.5];

    // Find working sets with weight > 0 (skip warmup sets)
    final workingSets = exercise.sets
        .where((s) => !s.isWarmup && (double.tryParse(s.weight.toString()) ?? 0) > 0)
        .toList();

    if (workingSets.isEmpty) {
      return const SizedBox.shrink();
    }

    // ✅ FIX: Use the first UNCOMPLETED working set's weight for calculation
    // If all sets are completed, fall back to first working set
    final nextSet = workingSets.where((s) => !s.isCompleted).firstOrNull;
    final setToShow = nextSet ?? workingSets.first;
    final targetWeight = double.tryParse(setToShow.weight.toString()) ?? 0;
    if (targetWeight <= 0) {
      return const SizedBox.shrink();
    }

    // Calculate plates using configured available plates
    final platesSummary = _calculatePlatesSummary(targetWeight, availablePlates);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Semantics(
        label: 'Plate calculator: $platesSummary',
        hint: 'Tap to configure available plates',
        button: true,
        child: InkWell(
          onTap: () => _showPlateCalculatorModal(context, targetWeight),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.colors.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.secondary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.calculateRounded,
                  size: AppIconSize.small,
                  color: context.colors.secondary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Plates: $platesSummary',
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  AppIcons.settings,
                  size: AppIconSize.tiny,
                  color: context.colors.secondary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Calculate plates summary for display (e.g., "2×20kg + 1×10kg")
  /// Uses the provided availablePlates list from user configuration
  String _calculatePlatesSummary(double targetWeight, List<double> availablePlates) {
    const barbellWeight = 20.0;

    if (targetWeight <= barbellWeight) {
      return 'Only barbell';
    }

    final remainingWeight = targetWeight - barbellWeight;
    final weightPerSide = remainingWeight / 2;

    final plateCounts = <double, int>{};
    var remaining = weightPerSide;

    // Sort plates descending to use greedy algorithm
    final sortedPlates = List<double>.from(availablePlates)..sort((a, b) => b.compareTo(a));

    for (final plate in sortedPlates) {
      final count = (remaining / plate).floor();
      if (count > 0) {
        plateCounts[plate] = count;
        remaining -= count * plate;
      }
    }

    if (plateCounts.isEmpty) {
      return 'Only barbell';
    }

    return plateCounts.entries
        .map((e) => '${e.value}×${e.key.truncate() == e.key ? e.key.truncate() : e.key}kg')
        .join(' + ');
  }

  void _showPlateCalculatorModal(BuildContext context, double targetWeight) {
    HapticFeedback.lightImpact();

    ModalService.showSheet(context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Row(
                children: [
                  Icon(
                    AppIcons.calculateRounded,
                    color: context.colors.secondary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Plate Calculator',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Plate calculator widget
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: PlateCalculatorWidget(
                    targetWeight: targetWeight,
                    onWeightChanged: (_) {}, // Read-only for now
                    unit: 'kg',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cupertino-style popup for plate calculator
/// Shows a compact native iOS action sheet with plate breakdown
void _showPlatesCupertinoPopup(BuildContext context, double targetWeight) {
  HapticFeedback.lightImpact();
  showCupertinoModalPopup<void>(
    context: context,
    builder: (ctx) => _PlatesCupertinoSheet(targetWeight: targetWeight),
  );
}

/// Visual Cupertino plate calculator popup
/// Palestra-first UX: colori immediati, font grande, visual dischi
class _PlatesCupertinoSheet extends ConsumerStatefulWidget {
  const _PlatesCupertinoSheet({required this.targetWeight});
  final double targetWeight;

  @override
  ConsumerState<_PlatesCupertinoSheet> createState() => _PlatesCupertinoSheetState();
}

class _PlatesCupertinoSheetState extends ConsumerState<_PlatesCupertinoSheet> {
  static const List<double> _defaultPlates = [25, 20, 15, 10, 5, 2.5, 1.25, 0.5];
  // Standard barbell options
  static const List<double?> _barbellOptions = [20.0, 15.0, null]; // null = no bar

  double? _barbellWeight = 20.0;

  Map<double, int> _calcPlates(List<double> available) {
    final bar = _barbellWeight ?? 0.0;
    if (widget.targetWeight <= bar) return {};
    final perSide = (widget.targetWeight - bar) / 2;
    var remaining = perSide;
    final result = <double, int>{};
    final sorted = List<double>.from(available)..sort((a, b) => b.compareTo(a));
    for (final p in sorted) {
      final n = (remaining / p).floor();
      if (n > 0) {
        result[p] = n;
        remaining -= n * p;
      }
    }
    return result;
  }

  Color _plateColor(double kg) {
    if (kg >= 25) return const Color(0xFFD32F2F); // red
    if (kg >= 20) return const Color(0xFF1565C0); // blue
    if (kg >= 15) return const Color(0xFFF9A825); // yellow
    if (kg >= 10) return const Color(0xFF2E7D32); // green
    if (kg >= 5)  return const Color(0xFF757575); // gray
    if (kg >= 2.5) return const Color(0xFFD32F2F); // light red
    return const Color(0xFF90A4AE); // silver
  }

  double _plateHeight(double kg) {
    if (kg >= 25) return 64;
    if (kg >= 20) return 56;
    if (kg >= 15) return 50;
    if (kg >= 10) return 44;
    if (kg >= 5)  return 36;
    if (kg >= 2.5) return 30;
    return 24;
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final available = config.availablePlates ?? _defaultPlates;
    final plates = _calcPlates(available);
    final weightStr = widget.targetWeight == widget.targetWeight.truncateToDouble()
        ? widget.targetWeight.truncate().toString()
        : widget.targetWeight.toStringAsFixed(1);

    return Material(
      type: MaterialType.transparency,
      child: Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Titolo con peso
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(AppIcons.calculateRounded, size: 20, color: CupertinoColors.activeBlue),
                const SizedBox(width: 8),
                Text(
                  'Dischi da caricare',
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
                    fontSize: 17,
                  ),
                ),
                const Spacer(),
                // Peso totale in evidenza
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${weightStr}kg',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Selettore bilanciere ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Bilanciere',
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                ..._barbellOptions.map((opt) {
                  final selected = opt == _barbellWeight;
                  final label = opt == null ? 'No bar' : '${opt.truncate()}kg';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _barbellWeight = opt);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: selected
                              ? CupertinoColors.activeBlue
                              : CupertinoColors.systemGrey5.resolveFrom(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? CupertinoColors.white : CupertinoColors.label.resolveFrom(context),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Visual bilanciere con dischi ──
          _buildBarbellVisual(plates),

          const SizedBox(height: 16),

          // ── Lista dischi (per lato) ──
          if (plates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                _barbellWeight != null
                    ? 'Solo bilanciere ${_barbellWeight!.truncate()}kg'
                    : 'Nessun disco',
                style: const TextStyle(
                  fontSize: 17,
                  color: CupertinoColors.systemGrey,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Per lato:',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...plates.entries.map((e) => _buildPlateRow(context, e.key, e.value)),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // ── Configura dischi ──
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
              _showFullPlateSheet(context, widget.targetWeight);
            },
            child: Text(
              'Configura dischi disponibili →',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.activeBlue.resolveFrom(context),
              ),
            ),
          ),

          // ── Chiudi ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: CupertinoColors.systemGrey5.resolveFrom(context),
                borderRadius: BorderRadius.circular(14),
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Chiudi',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ), // Container
    ); // Material
  }

  Widget _buildBarbellVisual(Map<double, int> plates) {
    // Expand plates into ordered list (biggest first, repeated by count)
    final plateList = <double>[];
    for (final entry in plates.entries) {
      for (var i = 0; i < entry.value; i++) {
        plateList.add(entry.key);
      }
    }

    return SizedBox(
      height: 72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side plates (reversed so biggest is closest to barbell)
          ...plateList.reversed.map((kg) => _buildPlateVisual(kg)),
          // Barbell
          Container(
            width: 48,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF9E9E9E),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
            ),
          ),
          // Right side plates
          ...plateList.map((kg) => _buildPlateVisual(kg)),
        ],
      ),
    );
  }

  Widget _buildPlateVisual(double kg) {
    final color = _plateColor(kg);
    final height = _plateHeight(kg);

    return Container(
      width: 10,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
    );
  }

  Widget _buildPlateRow(BuildContext context, double kg, int count) {
    final color = _plateColor(kg);
    final kgStr = kg == kg.truncateToDouble() ? kg.truncate().toString() : kg.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // Colored plate badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                kgStr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Count x weight
          Text(
            '${count}×',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${kgStr}kg',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullPlateSheet(BuildContext context, double targetWeight) {
    ModalService.showSheet(
      context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Icon(AppIcons.calculateRounded, color: context.colors.secondary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Configura Plate Calculator',
                      style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: PlateCalculatorWidget(
                    targetWeight: targetWeight,
                    onWeightChanged: (_) {},
                    unit: 'kg',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
