import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_gif_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/auto_adjustment_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_extensions.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/tut_info_dialog.dart'
    show showTutInfoBottomSheet;
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/exercise_data_provider.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_expansion_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_autocollapse_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_suggestion_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/community_advice_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_header.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_sets.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/smart_suggestion_chip.dart';
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

class _ExerciseListItemState extends ConsumerState<ExerciseListItem>
    with AutomaticKeepAliveClientMixin {
  ExerciseActivity? _lastActivity;
  Map<String, dynamic>? _exerciseData;

  // ✅ PERFORMANCE FIX: Keep widget alive when scrolling out of view
  // This prevents dispose/initState cycle when scrolling up/down
  // which was causing repeated JSON loads and GIF requests
  @override
  bool get wantKeepAlive => true;

  bool get isProMode => ref.read(appConfigProvider).isProMode ?? false;

  // ✅ PERFORMANCE FIX: Expansion state getters use ref.read for non-reactive access
  // These are used in callbacks (didUpdateWidget, _autoCollapseIfCompleted) where
  // we need current value but don't want to trigger rebuilds.
  // Reactive watching is done ONLY in build() method with local variables.
  bool get _isExpandedRead => ref.read(
    exerciseExpansionProvider(widget.exercise.id),
  ).isExpanded;

  bool get _hasAutoCollapsedRead => ref.read(
    exerciseExpansionProvider(widget.exercise.id),
  ).hasAutoCollapsed;

  bool get _userManuallyExpandedRead => ref.read(
    exerciseExpansionProvider(widget.exercise.id),
  ).userManuallyExpanded;

  ExerciseExpansionNotifier get _expansionNotifier =>
      ref.read(exerciseExpansionProvider(widget.exercise.id).notifier);

  // For debugging only - use .read()
  AutoCollapseState get _autoCollapseState =>
      ref.read(exerciseAutoCollapseProvider(widget.exercise.id));

  AutoCollapseNotifier get _autoCollapseNotifier =>
      ref.read(exerciseAutoCollapseProvider(widget.exercise.id).notifier);

  ExerciseSuggestionsNotifier get _suggestionsNotifier =>
      ref.read(exerciseSuggestionsProvider(widget.exercise.id).notifier);

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
        _expansionNotifier.resetForIncomplete();
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
    if (widget.exercise.sets.isEmpty) {
      return false;
    }
    return widget.exercise.sets.every((set) => set.isCompleted);
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
    final weights = widget.exercise.sets
        .map((s) => s.weight)
        .whereType<double>()
        .toList();

    final minWeight = weights.isNotEmpty
        ? weights.reduce((a, b) => a < b ? a : b)
        : null;
    final maxWeight = weights.isNotEmpty
        ? weights.reduce((a, b) => a > b ? a : b)
        : null;

    final completedSets = widget.exercise.sets
        .where((s) => s.isCompleted)
        .length;

    double totalVolume = 0;
    for (final set in widget.exercise.sets) {
      if (set.isCompleted && set.weight != null && set.reps != null) {
        totalVolume += (set.weight! * set.reps!);
      }
    }

    int exerciseHistoryCount = 0;
    try {
      final historyAsync = ref.read(
        recentWeightsWithDetailsProvider(widget.exercise.name),
      );
      final history = historyAsync.value;
      exerciseHistoryCount = history?.length ?? 0;
    } catch (e) {
      exerciseHistoryCount = 0;
    }

    final contributionsAsync = ref.read(
      exerciseContributionsProvider(widget.exercise.name),
    );
    final contributions = contributionsAsync.value ?? [];

    final userLevel = ref.read(userLevelProvider);

    final userStatsAsync = ref.read(userContributionStatsProvider);
    final userStats = userStatsAsync.value;

    final currentWorkout = ref.read(currentWorkoutProvider);
    final workoutExercises = currentWorkout?.exercises ?? [];
    final currentIndex = workoutExercises.indexWhere(
      (e) => e.id == widget.exercise.id,
    );
    final isLastExercise = currentIndex == workoutExercises.length - 1;

    final user = ref.read(firebaseUserProvider).asData?.value;
    final accountAgeInDays = user?.metadata.creationTime != null
        ? DateTime.now().difference(user!.metadata.creationTime!).inDays
        : 0;

    final totalWorkoutsCompleted = accountAgeInDays ~/ 3;
    final workoutStartTime = currentWorkout?.startTime;

    final averageWorkoutVolume = totalVolume > 0 ? totalVolume : 2000.0;

    final uniqueExercisesCount = exerciseHistoryCount > 0
        ? exerciseHistoryCount
        : 5;

    final workoutsPerWeek = accountAgeInDays > 0
        ? (totalWorkoutsCompleted * 7.0) / accountAgeInDays
        : 2.0;

    final suggestionContext = SuggestionContext(
      exercise: widget.exercise,
      exerciseData: _exerciseData,
      hasNotes: widget.exercise.notes?.isNotEmpty ?? false,
      isFirstTime: _lastActivity == null,
      completedSets: completedSets,
      totalSets: widget.exercise.sets.length,
      minWeight: minWeight,
      maxWeight: maxWeight,
      totalVolume: totalVolume,
      exerciseHistoryCount: exerciseHistoryCount,
      existingContributions: contributions,
      userLevel: userLevel,
      userContributionCount: userStats?.totalContributions ?? 0,
      accountAgeInDays: accountAgeInDays,
      totalWorkoutsCompleted: totalWorkoutsCompleted,
      averageWorkoutVolume: averageWorkoutVolume,
      uniqueExercisesCount: uniqueExercisesCount,
      workoutsPerWeek: workoutsPerWeek,
      isLastExerciseInWorkout: isLastExercise,
      currentExerciseIndex: currentIndex >= 0 ? currentIndex : 0,
      totalExercisesInWorkout: workoutExercises.length,
      workoutStartTime: workoutStartTime,
    );

    await _suggestionsNotifier.generateSuggestions(suggestionContext);
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

    await showModalBottomSheet(
      context: context,
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
    await showModalBottomSheet(
      context: context,
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
              clearRestTime: newRestTime == null, // ✅ FIX: Allow clearing restTime to null
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

  /// ⚡ PERFORMANCE: Uses cached exerciseDataProvider which uses exercisesDatabaseProvider
  /// JSON is loaded ONCE and cached for entire session - no repeated file loads
  Future<Map<String, dynamic>?> _loadExerciseDataFromJson() async {
    try {
      // exerciseDataProvider uses exercisesDatabaseProvider (cached JSON)
      final mergedData = await ref.read(
        exerciseDataProvider(widget.exercise.name).future,
      );

      if (mergedData.isNotEmpty) {
        return mergedData;
      }
    } catch (_) {
      // Silently fall through to cached database lookup
    }

    if (!mounted) return null;

    // ⚡ Fallback: Use cached database directly (no JSON reload)
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

    showModalBottomSheet(
      context: context,
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

    showModalBottomSheet(
      context: context,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ExerciseHistoryBottomSheet(exerciseName: widget.exercise.name),
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

  void _handleShowCommunityAdvice() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CommunityAdviceModal(exercise: widget.exercise),
    );
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
        debugPrint('🔗 [Superset] Created with ${result.exercises.length} exercises');
        for (final ex in result.exercises) {
          debugPrint('   - ${ex.nome}');
        }
      }

      HapticFeedback.mediumImpact();
      SnackBarService.showSuccess(
        context,
        context.l10n.supersetCreated,
      );
    }
  }

  /// BUG FIX: Show counting mode picker to change exercise counting mode
  /// This was missing from the new orchestrator implementation
  Future<void> _handleShowCountingModePicker() async {
    final newMode = await CountingModePickerModal.show(
      context,
      currentMode: widget.exercise.countingMode,
    );

    if (newMode != null && newMode != widget.exercise.countingMode && mounted) {
      // Update exercise with new counting mode
      final updatedExercise = widget.exercise.copyWith(
        countingMode: newMode,
        updatedAt: DateTime.now(),
      );

      // Update via provider
      ref
          .read(currentWorkoutProvider.notifier)
          .updateExercise(widget.exercise.id, updatedExercise);

      // Show confirmation
      if (mounted) {
        HapticFeedback.mediumImpact();
        SnackBarService.showSuccess(
          context,
          'Counting mode changed to ${newMode.name}',
        );
      }

      if (kDebugMode) {
        debugPrint(
          '🔄 [CountingMode] Changed from ${widget.exercise.countingMode.name} to ${newMode.name}',
        );
      }
    }
  }

  /// Add or edit warmup sets for the exercise
  ///
  /// If warmup sets already exist: opens modal to EDIT them (not add more)
  /// If no warmup sets: generates defaults based on target weight, opens modal to configure
  void _handleAddWarmupSets() {
    // Check for existing warmup sets
    final existingWarmupSets = widget.exercise.sets.where((s) => s.isWarmup).toList();
    final workingSets = widget.exercise.sets.where((s) => !s.isWarmup).toList();

    // If editing existing warmup sets
    if (existingWarmupSets.isNotEmpty) {
      // Convert ExerciseSet to WarmupSet for the modal
      final warmupSetsForModal = existingWarmupSets.map((s) {
        // Calculate percentage if we have working sets
        final targetWeight = workingSets.isNotEmpty ? workingSets.first.weight ?? 0.0 : 0.0;
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

    // No existing warmup sets - generate new ones
    if (workingSets.isEmpty) {
      SnackBarService.showError(
        context,
        context.l10n.addWorkingSetFirst,
      );
      return;
    }

    final targetWeight = workingSets.first.weight ?? 0.0;

    if (targetWeight <= 0) {
      SnackBarService.showError(
        context,
        context.l10n.setTargetWeightFirst,
      );
      return;
    }

    // Generate warmup sets using WarmupCalculatorService
    final warmupCalculator = WarmupCalculatorService();
    final isBarbell = warmupCalculator.isLikelyBarbellExercise(widget.exercise.name);
    final generatedSets = warmupCalculator.calculateWarmupSets(
      targetWeight,
      isBarbell: isBarbell,
    );

    _showWarmupModal(generatedSets, isEditing: false);
  }

  /// Shows the warmup customization modal and handles the result
  void _showWarmupModal(List<WarmupSet> initialSets, {required bool isEditing}) {
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
        final workingSets = widget.exercise.sets.where((s) => !s.isWarmup).toList();
        final renumberedSets = workingSets.asMap().map((index, set) {
          return MapEntry(index, set.copyWith(setNumber: index + 1));
        }).values.toList();

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
    final newWarmupExerciseSets = warmupSets.asMap().map((index, warmup) {
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
    }).values.toList();

    // Get working sets (non-warmup)
    final workingSets = widget.exercise.sets.where((s) => !s.isWarmup).toList();

    // Renumber working sets to come after warmup sets
    final renumberedWorkingSets = workingSets.asMap().map((index, set) {
      return MapEntry(
        index,
        set.copyWith(setNumber: newWarmupExerciseSets.length + index + 1),
      );
    }).values.toList();

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
      debugPrint('🔥 [Warmup] $action ${warmupSets.length} warmup sets for ${widget.exercise.name}');
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
    final timerActions = ref.read(tier1TimerActionsProvider);
    timerActions.startExerciseRest(
      seconds: set.restTime ?? widget.exercise.restTime ?? 90,
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
    // Dropset execution modal implementation from original file
    // This would show the dropset execution flow
  }

  void _handleExecuteRestPause(RestPauseExercise restPauseExercise) {
    if (kDebugMode) {
      debugPrint('Execute rest-pause for ${widget.exercise.name}');
    }
    // Rest-pause execution sheet implementation from original file
    // This would show the rest-pause execution flow
  }

  void _handleCollapseExercise() {
    _expansionNotifier.collapse();
  }

  IconData _getSuggestionIcon(ContributionType suggestionType) {
    switch (suggestionType) {
      case ContributionType.technique:
        return AppIcons.edit;
      case ContributionType.warning:
        return AppIcons.warning;
      case ContributionType.tip:
        return AppIcons.lightbulb;
      case ContributionType.variant:
        return AppIcons.sync;
      case ContributionType.correction:
        return AppIcons.checkCircle;
      case ContributionType.translation:
        return AppIcons.translate;
    }
  }

  // ========================================================================
  // BUILD
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    // ✅ Required when using AutomaticKeepAliveClientMixin
    super.build(context);

    // ✅ PERFORMANCE FIX: Use ref.read instead of ref.watch for config
    // AppConfig rarely changes during a workout session, and watching it
    // causes unnecessary rebuilds of ALL exercise cards when ANY config property changes.
    // This was the root cause of the insight chip flickering during scroll.
    // If config changes mid-session (rare), user can scroll to refresh the card.
    final config = ref.read(appConfigProvider);

    // ✅ PERFORMANCE FIX: Watch ONLY the specific properties needed for rendering
    // Previously, getters with ref.watch were causing rebuild chains when accessed.
    // Now we watch once in build() and use the local variables.
    final isExpanded = ref.watch(
      exerciseExpansionProvider(widget.exercise.id)
          .select((state) => state.isExpanded),
    );
    final suggestions = ref.watch(exerciseSuggestionsProvider(widget.exercise.id));

    // Listen for auto-collapse completion
    ref.listen(
      exerciseAutoCollapseProvider(widget.exercise.id)
          .select((state) => state.shouldExecuteCollapse),
      (previous, shouldCollapse) {
        if (shouldCollapse) {
          // Execute the collapse
          _expansionNotifier.markAutoCollapsed();
          _autoCollapseNotifier.acknowledgeCollapse();

          if (kDebugMode) {
            debugPrint(
              '✅ [AutoCollapse] Exercise "${widget.exercise.name}" auto-collapsed',
            );
          }
        }
      },
    );

    // Reorder mode - show simplified card (matching normal card styling)
    if (widget.isReorderMode) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        child: Container(
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

    return GestureDetector(
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
        child: Container(
          decoration: BoxDecoration(
            // ✅ DESIGN: Lighter background color for cleaner look
            color: context.colors.surfaceContainer,
            // ✅ DESIGN: Slightly softer corners
            borderRadius: BorderRadius.circular(16),
            // ✅ DESIGN: Subtle border instead of heavy shadow
            border: Border.all(
              color: context.colors.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              // ✅ DESIGN: Lighter, more subtle shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ExerciseListItemHeader(
                    exercise: widget.exercise,
                    config: config,
                    isProMode: isProMode,
                    autoCollapseState: _autoCollapseState,
                    lastActivity: _lastActivity,
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
                    onShowCommunityAdvice: _handleShowCommunityAdvice,
                    onShowCountingModePicker: _handleShowCountingModePicker,
                    onAddWarmupSets: _handleAddWarmupSets,
                    onCreateSuperset: _handleCreateSuperset,
                    hasWarmupData: _hasWarmupData,
                    hasInjuryPreventionData: _hasInjuryPreventionData,
                    tutorialMenuKey: widget.tutorialExerciseMenuKey,
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: filteredSuggestions.map((suggestion) {
                              return SmartSuggestionChip(
                                key: ValueKey(suggestion.id),
                                suggestion: suggestion.text,
                                icon: _getSuggestionIcon(suggestion.type),
                                fullSuggestion: suggestion,
                                onDismiss: () {
                                  _suggestionsNotifier.dismissSuggestion(
                                    suggestion.id,
                                  );
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

                // Sets section (expanded only)
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: ExerciseListItemSets(
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
                  ),

                // BUG FIX #4: Visual hint to expand collapsed exercise
                // ✅ FIX: Removed infinite rebuild loop caused by onEnd + setState
                // Previous implementation called setState() in onEnd to restart animation,
                // causing ~1.6s rebuild loops for ALL collapsed exercise cards.
                // Now uses static hint without pulsing - better for performance.
                // 🐛 BUG FIX #5: Added InkWell to make hint tappable
                // The outer GestureDetector doesn't receive taps because Material widget
                // and header's interactive widgets (InkWell, PopupMenuButton) consume them.
                if (!isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Center(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _expansionNotifier.expand();
                            HapticFeedback.lightImpact();
                            if (kDebugMode) {
                              debugPrint(
                                '📖 [Expand] Exercise "${widget.exercise.name}" expanded via hint tap',
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.primaryContainer.withValues(
                                alpha: 0.3,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: context.colors.primary.withValues(
                                  alpha: 0.4,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SemanticIcon(
                                  icon: AppIcons.expandMore,
                                  semanticLabel: context.l10n.expandExercise,
                                  size: AppIconSize.small,
                                  color: context.colors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  context.l10n.tapToExpand,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
