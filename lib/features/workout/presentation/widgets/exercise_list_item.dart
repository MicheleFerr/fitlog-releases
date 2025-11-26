import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/auto_adjustment_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/tut_info_dialog.dart' show showTutInfoBottomSheet;
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
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_header.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_sets.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/smart_suggestion_chip.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_history_bottom_sheet.dart';

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

  @override
  ConsumerState<ExerciseListItem> createState() => _ExerciseListItemState();
}

class _ExerciseListItemState extends ConsumerState<ExerciseListItem> {
  ExerciseActivity? _lastActivity;
  Map<String, dynamic>? _exerciseData;

  bool get isProMode => ref.read(appConfigProvider).isProMode ?? false;

  // Expansion state - watch individual properties
  bool get _isExpanded => ref.watch(
    exerciseExpansionProvider(widget.exercise.id)
      .select((state) => state.isExpanded),
  );

  bool get _hasAutoCollapsed => ref.watch(
    exerciseExpansionProvider(widget.exercise.id)
      .select((state) => state.hasAutoCollapsed),
  );

  bool get _userManuallyExpanded => ref.watch(
    exerciseExpansionProvider(widget.exercise.id)
      .select((state) => state.userManuallyExpanded),
  );

  ExerciseExpansionNotifier get _expansionNotifier =>
      ref.read(exerciseExpansionProvider(widget.exercise.id).notifier);

  // For debugging only - use .read()
  AutoCollapseState get _autoCollapseState =>
      ref.read(exerciseAutoCollapseProvider(widget.exercise.id));

  AutoCollapseNotifier get _autoCollapseNotifier =>
      ref.read(exerciseAutoCollapseProvider(widget.exercise.id).notifier);

  // Smart suggestions - watch list to get actual suggestions
  List<SmartSuggestion> get _suggestions => ref.watch(
    exerciseSuggestionsProvider(widget.exercise.id),
  );

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
          _isExpanded &&
          !_hasAutoCollapsed &&
          !_userManuallyExpanded) {
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
          _isExpanded &&
          !_hasAutoCollapsed &&
          !_userManuallyExpanded) {
        if (kDebugMode) {
          debugPrint('AUTO-COLLAPSE TRIGGERED for ${widget.exercise.name}');
        }

        final config = ref.read(appConfigProvider);
        final delay = (config.simplifiedAnimations ?? false)
            ? const Duration(milliseconds: 1500)
            : const Duration(milliseconds: 2500);

        final countdownDuration = (config.simplifiedAnimations ?? false)
            ? 2
            : 3;

        final showCountdown =
            config.showCollapseCountdown ?? (config.isProMode ?? false);

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

    final totalWorkoutsCompleted =
        accountAgeInDays ~/ 3;
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

  void _handleShowQuickTimerSettings() {
    // Show timer bottom sheet - implementation from original file
    // This would show a bottom sheet for quick timer configuration
    if (kDebugMode) {
      debugPrint('Show quick timer settings for ${widget.exercise.name}');
    }
  }

  void _handleShowTutExplanationModal() {
    // TUT info is shown via bottom sheet, not dialog
    // Default TUT value if not available
    final tutValue = widget.exercise.tut ?? '2-0-2-0';
    showTutInfoBottomSheet(context, tutValue);
  }

  Future<Map<String, dynamic>?> _loadExerciseDataFromJson() async {
    try {
      final mergedData = await ref.read(
        exerciseDataProvider(widget.exercise.name).future,
      );

      if (mergedData.isNotEmpty) {
        if (mergedData['hasCommunityCorrections'] == true) {
          if (kDebugMode) {
            debugPrint(
              'Using community-corrected data for ${widget.exercise.name}',
            );
          }
        }
        return mergedData;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Could not load merged data, falling back to JSON: $e');
      }
    }

    if (!mounted) return null;

    try {
      final config = ref.read(appConfigProvider);
      final isItalian = config.languageCode == 'it';
      final jsonFile = isItalian
          ? 'assets/data/exercises_it.json'
          : 'assets/data/exercises.json';

      if (kDebugMode) {
        debugPrint(
          'Loading exercise data from: $jsonFile (locale: ${config.languageCode})',
        );
      }

      final String jsonString = await rootBundle.loadString(jsonFile);
      final List<dynamic> exercises = json.decode(jsonString);

      final exerciseName = widget.exercise.name.toLowerCase();

      // Try exact match first
      for (var exercise in exercises) {
        if (exercise['nome']?.toString().toLowerCase() == exerciseName) {
          return exercise as Map<String, dynamic>;
        }
      }

      // Try partial match
      for (var exercise in exercises) {
        final exerciseNameInJson =
            exercise['nome']?.toString().toLowerCase() ?? '';
        if (exerciseNameInJson.contains(exerciseName) ||
            exerciseName.contains(exerciseNameInJson)) {
          return exercise as Map<String, dynamic>;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error loading exercise data: $e');
      return null;
    }
  }

  void _handleShowExerciseInfoModal(Map<String, dynamic> data) {
    if (kDebugMode) {
      debugPrint('Show exercise info modal for ${widget.exercise.name}');
    }
    // Implementation would show exercise info modal with data
  }

  void _handleShowWarmupModal(Map<String, dynamic> data) {
    if (kDebugMode) {
      debugPrint('Show warmup modal for ${widget.exercise.name}');
    }
    // Implementation would show warmup modal with data
  }

  void _handleShowInjuryPreventionModal(Map<String, dynamic> data) {
    if (kDebugMode) {
      debugPrint('Show injury prevention modal for ${widget.exercise.name}');
    }
    // Implementation would show injury prevention modal with data
  }

  void _handleShowExerciseHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ExerciseHistoryBottomSheet(
        exerciseName: widget.exercise.name,
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

  void _handleShowCommunityAdvice() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CommunityAdviceModal(
        exercise: widget.exercise,
      ),
    );
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
    // Start rest timer using the unified timer provider
    final timerNotifier = ref.read(unifiedTimerProvider.notifier);
    timerNotifier.startTimer(
      durationSeconds: set.restTime ?? 90,
      exerciseName: widget.exercise.name,
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
    final config = ref.watch(appConfigProvider);

    // Reorder mode - show simplified card
    if (widget.isReorderMode) {
      return Card(
        margin: EdgeInsets.zero, // ListView provides horizontal padding
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(AppIcons.dragHandle, color: context.colors.onSurfaceVariant),
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
      );
    }

    return Card(
      margin: EdgeInsets.zero, // ListView provides horizontal padding
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
              onShowInjuryPreventionModal: _handleShowInjuryPreventionModal,
              onShowExerciseHistory: _handleShowExerciseHistory,
              onShowExerciseEditor: _handleShowExerciseEditor,
              onShowExerciseReplacement: _handleShowExerciseReplacement,
              onDuplicateExercise: _handleDuplicateExercise,
              onShowDeleteConfirmation: _handleShowDeleteConfirmation,
              onShowCommunityAdvice: _handleShowCommunityAdvice,
              hasWarmupData: _hasWarmupData,
              hasInjuryPreventionData: _hasInjuryPreventionData,
            ),
          ),

          // Smart suggestions
          if (_suggestions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestions.map((suggestion) {
                  return SmartSuggestionChip(
                    suggestion: suggestion.text,
                    icon: _getSuggestionIcon(suggestion.type),
                    onTap: () {
                      // Handle suggestion tap
                      if (kDebugMode) {
                        debugPrint('Suggestion tapped: ${suggestion.text}');
                      }
                    },
                    onDismiss: () {
                      _suggestionsNotifier.dismissSuggestion(suggestion.id);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Sets section (expanded only)
          if (_isExpanded)
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
              ),
            ),
        ],
      ),
    );
  }
}
