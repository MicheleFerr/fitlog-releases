import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/edit_set_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/quick_edit_overlay_v2.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/edit_exercise_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_replacement_dialog.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_database.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rpe_selector_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/auto_adjustment_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_extensions.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/set_duration_tracker_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/tut_info_dialog.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/warmup_suggestion_card.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/smart_suggestion_chip.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/exercise_data_provider.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/dropset_execution_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/restpause_execution_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_widget.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_gif_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_expansion_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_autocollapse_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_suggestion_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/counting_mode_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/counting_mode_warning_dialog.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_options_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/community_contribution_modal.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_card_feedback.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/community_advice_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/haptic_feedback_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_counting_mode_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/calculation_metadata_display.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/apre_auto_regulation_service.dart';

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
  bool _loadingHistory = false;
  bool _warmupSuggestionDismissed = false;
  bool _isEditingNotes = false;
  // REFACTORED: _isExpanded, _hasAutoCollapsed, _userManuallyExpanded → exerciseExpansionProvider
  late TextEditingController _notesController;
  Timer? _saveDebounceTimer;
  // REFACTORED: _autoCollapseTimer, _countdownTimer, _collapseCountdown → exerciseAutoCollapseProvider
  bool _savingNotes = false;
  bool _autoCollapseInProgress = false; // Local flag for protection
  // Cache per performance
  bool? _cachedCompletionStatus;
  // REFACTORED: Community suggestions → exerciseSuggestionsProvider
  Map<String, dynamic>? _exerciseData;
  // APRE metadata banner state
  bool _showMetadataBanner = false; // Collapsed by default

  bool get isProMode => ref.read(appConfigProvider).isProMode ?? false;

  // ⚡ OPTIMIZATION: Watch only specific properties with .select()
  // This prevents rebuilds when other properties change

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

  // For debugging/logging only - use .read() to avoid rebuilds
  ExerciseExpansionState get _expansionState =>
      ref.read(exerciseExpansionProvider(widget.exercise.id));

  ExerciseExpansionNotifier get _expansionNotifier =>
      ref.read(exerciseExpansionProvider(widget.exercise.id).notifier);

  // Auto-collapse state - watch countdown
  int get _countdown => ref.watch(
    exerciseAutoCollapseProvider(widget.exercise.id)
      .select((state) => state.countdown),
  );

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

    // 🐛 DEBUG: Test logs removed from production (uncomment if needed for debugging)
    // if (kDebugMode) {
    //   debugPrint('🚨 [ExerciseListItem.initState] WIDGET COSTRUITO: ${widget.exercise.name}');
    //   debugPrint('✅ [ExerciseListItem.initState] kDebugMode = TRUE, countingMode=${widget.exercise.countingMode.name}');
    // }

    _loadLastActivity();
    _notesController = TextEditingController(text: widget.exercise.notes ?? '');
    _notesController.addListener(_onNotesChanged);
    _loadExerciseData();

    // ✅ CRITICAL FIX: Defer provider state modification until AFTER widget tree finishes building
    // This prevents Riverpod error: "Tried to modify a provider while the widget tree was building"
    // The _checkForCommunitySuggestions() method calls _suggestionsNotifier.generateSuggestions()
    // which modifies provider state - this must happen post-frame
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

    // ✅ FIX: Trigger rebuild if counting mode changed
    // This ensures UI updates when user switches between weight/reps and time modes
    if (oldWidget.exercise.countingMode != widget.exercise.countingMode) {
      // 🐛 DEBUG: Log removed from production (uncomment if needed for debugging)
      // if (kDebugMode) {
      //   debugPrint(
      //     '🔄 [ExerciseListItem.didUpdateWidget] COUNTING MODE CHANGED: '
      //     '${oldWidget.exercise.countingMode.name} → ${widget.exercise.countingMode.name} '
      //     'for ${widget.exercise.name}',
      //   );
      // }
      // Trigger rebuild to update UI (set input fields, display format, etc.)
      setState(() {});
    }

    // Check if auto-collapse should be triggered after widget update
    final config = ref.read(appConfigProvider);
    if (config.autoCollapseCompleted ?? false) {
      // Calculate completion status for old and new widget
      final wasCompleted =
          oldWidget.exercise.sets.isNotEmpty &&
          oldWidget.exercise.sets.every((set) => set.isCompleted);
      final isNowCompleted =
          widget.exercise.sets.isNotEmpty &&
          widget.exercise.sets.every((set) => set.isCompleted);

      if (kDebugMode) {
        debugPrint(
          '🔄 WIDGET UPDATE - wasCompleted=$wasCompleted, isNowCompleted=$isNowCompleted, isExpanded=${_expansionState.isExpanded}, hasAutoCollapsed=${_expansionState.hasAutoCollapsed}, userManuallyExpanded=${_expansionState.userManuallyExpanded}',
        );
      }

      // Reset flags if exercise becomes incomplete again (user started working on it)
      if (wasCompleted && !isNowCompleted) {
        if (kDebugMode) {
          debugPrint(
            '🔄 EXERCISE INCOMPLETE AGAIN - Resetting autocollapse flags for ${widget.exercise.name}',
          );
        }
        // REFACTORED: Use provider instead of setState
        _expansionNotifier.resetForIncomplete();
      }

      // Trigger auto-collapse if:
      // - Exercise just became complete (!wasCompleted && isNowCompleted)
      // - Card is currently expanded (_isExpanded)
      // - Not already in progress (!_autoCollapseInProgress)
      // - Hasn't auto-collapsed before (!_hasAutoCollapsed)
      // - User hasn't manually expanded (!_userManuallyExpanded)
      if (!wasCompleted &&
          isNowCompleted &&
          _isExpanded &&
          !_autoCollapseInProgress &&
          !_hasAutoCollapsed &&
          !_userManuallyExpanded) {
        if (kDebugMode) {
          debugPrint(
            '✅ AUTO-COLLAPSE TRIGGERED via didUpdateWidget for ${widget.exercise.name}',
          );
        }
        _autoCollapseIfCompleted();
      }
    }
  }

  @override
  void dispose() {
    _notesController.removeListener(_onNotesChanged);
    _notesController.dispose();

    // Cleanup timer (notes debounce)
    _saveDebounceTimer?.cancel();

    // REFACTORED: autocollapse timers now managed by provider

    // Reset local flags
    _autoCollapseInProgress = false;
    // REFACTORED: expansion state and countdown now managed by providers
    _cachedCompletionStatus = null;

    super.dispose();
  }

  void _onNotesChanged() {
    if (!_isEditingNotes) return;

    // Cancel previous timer
    _saveDebounceTimer?.cancel();

    // Start new timer for auto-save after 750ms
    _saveDebounceTimer = Timer(const Duration(milliseconds: 750), () {
      _saveNotes();
    });
  }

  Future<void> _saveNotes() async {
    if (_notesController.text == widget.exercise.notes) return;

    setState(() {
      _savingNotes = true;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Save notes
    final updated = widget.exercise.copyWith(notes: _notesController.text);
    widget.onExerciseUpdate?.call(updated);

    // Show success animation
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _savingNotes = false;
      });

      // Show success feedback
      SnackBarService.showSuccess(
        context,
        '✅ ${context.l10n.notesSavedMessage}',
      );
    }
  }

  void _toggleNotesEdit() {
    setState(() {
      _isEditingNotes = !_isEditingNotes;
    });

    if (_isEditingNotes) {
      HapticFeedback.lightImpact();
      // Focus on text field will be handled by autofocus
    } else {
      // Save if there are changes
      if (_notesController.text != widget.exercise.notes) {
        _saveNotes();
      }
    }
  }

  bool _areAllSetsCompleted() {
    // Sempre invalida cache per evitare problemi di timing
    _cachedCompletionStatus = null;

    // Calcola il risultato fresco
    if (widget.exercise.sets.isEmpty) {
      _cachedCompletionStatus = false;
    } else {
      _cachedCompletionStatus = widget.exercise.sets.every(
        (set) => set.isCompleted,
      );
    }

    if (kDebugMode) {
      debugPrint(
        '🔍 _areAllSetsCompleted: ${widget.exercise.name} = $_cachedCompletionStatus (${widget.exercise.sets.length} sets, ${widget.exercise.sets.where((s) => s.isCompleted).length} completed)',
      );
    }
    return _cachedCompletionStatus!;
  }

  void _autoCollapseIfCompleted() {
    if (kDebugMode) {
      debugPrint(
        '🔍 AUTO-COLLAPSE CHECK: allCompleted=${_areAllSetsCompleted()}, isExpanded=${_expansionState.isExpanded}, inProgress=$_autoCollapseInProgress, hasAutoCollapsed=${_expansionState.hasAutoCollapsed}, userManuallyExpanded=${_expansionState.userManuallyExpanded}',
      );
    }
    try {
      // Don't autocollapse if:
      // - Already collapsed
      // - Already in progress
      // - Already auto-collapsed before
      // - User manually expanded
      if (_areAllSetsCompleted() &&
          _isExpanded && // FIX: Use ref.watch() instead of ref.read()
          !_autoCollapseInProgress &&
          !_hasAutoCollapsed && // FIX: Use ref.watch() instead of ref.read()
          !_userManuallyExpanded) { // FIX: Use ref.watch() instead of ref.read()
        if (kDebugMode) {
          debugPrint('✅ AUTO-COLLAPSE TRIGGERED for ${widget.exercise.name}');
        }

        // Previene chiamate multiple
        _autoCollapseInProgress = true;

        // Delay ottimizzato - 1.5 secondi per utenti Base, 2.5 per Pro
        final config = ref.read(appConfigProvider);
        final delay = (config.simplifiedAnimations ?? false)
            ? const Duration(milliseconds: 1500)
            : const Duration(milliseconds: 2500);

        // Countdown duration
        final countdownDuration = (config.simplifiedAnimations ?? false)
            ? 2
            : 3;

        // Show countdown?
        final showCountdown =
            config.showCollapseCountdown ?? (config.isProMode ?? false);

        // REFACTORED: Use provider for autocollapse timer management
        _autoCollapseNotifier.startAutoCollapse(
          initialDelay: delay,
          countdownSeconds: countdownDuration,
          showCountdown: showCountdown,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error inizializzazione auto-collasso: $e');
      }
      _autoCollapseInProgress = false;
    }
  }

  void _performCollapse() {
    try {
      if (mounted && _areAllSetsCompleted()) {
        // REFACTORED: Use provider to mark as auto-collapsed
        _expansionNotifier.markAutoCollapsed();

        _showCompletionFeedback();
      }
    } catch (e) {
      debugPrint('Error durante collasso: $e');
    } finally {
      _autoCollapseInProgress = false; // Reset protezione sempre
      // hasAutoCollapsed remains true in provider to prevent re-triggering
    }
  }

  void _showCompletionFeedback() {
    try {
      SnackBarService.showCustom(
        context,
        message:
            '✅ ${context.l10n.exerciseCompletedTapToExpand(widget.exercise.name)}',
        backgroundColor: context.successColor,
        actionLabel: context.l10n.expandLabel,
        onAction: () {
          // REFACTORED: Use provider to expand
          _expansionNotifier.expand();

          if (kDebugMode) {
            debugPrint(
              '👆 USER MANUALLY EXPANDED via Snackbar for ${widget.exercise.name}',
            );
          }
        },
      );
    } catch (e) {
      debugPrint('Error mostrando feedback: $e');
    }
  }

  void _cancelAutoCollapse() {
    try {
      // REFACTORED: Cancel via provider
      _autoCollapseNotifier.cancel();
      _autoCollapseInProgress = false; // Reset protezione

      if (mounted) {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint('Error cancellando auto-collasso: $e');
    }
  }

  Future<void> _loadLastActivity() async {
    try {
      // NEW: Use workouts collection instead of exerciseActivities
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
        debugPrint('❌ Errore caricamento ultimo peso: $e');
      }
      // Fallback: prova con il vecchio metodo se il nuovo fallisce
      await _loadLastActivityFallback();
    }
  }

  /// Fallback method using old exerciseActivities collection
  Future<void> _loadLastActivityFallback() async {
    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;

    if (currentUser?.email != null) {
      final repository = ExerciseActivityRepository();
      final activities = await repository.getActivitiesByExercise(
        userId: currentUser!.email!, // ⚠️ Parameter name is userId (expects user ID/email string)
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
    // REFACTORED: Use smart suggestion provider instead of hardcoded setState logic

    // Build suggestion context
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

    // Calculate total volume (weight × reps for completed sets)
    double totalVolume = 0;
    for (final set in widget.exercise.sets) {
      if (set.isCompleted && set.weight != null && set.reps != null) {
        totalVolume += (set.weight! * set.reps!);
      }
    }

    // Get exercise history count
    int exerciseHistoryCount = 0;
    try {
      final historyAsync = ref.read(
        recentWeightsWithDetailsProvider(widget.exercise.name),
      );
      final history = historyAsync.value;
      exerciseHistoryCount = history?.length ?? 0;
    } catch (e) {
      // If error fetching history, default to 0
      exerciseHistoryCount = 0;
    }

    // Get existing contributions
    final contributionsAsync = ref.read(
      exerciseContributionsProvider(widget.exercise.name),
    );
    final contributions = contributionsAsync.value ?? [];

    // Get user level
    final userLevel = ref.read(userLevelProvider);

    // Get user stats
    final userStatsAsync = ref.read(userContributionStatsProvider);
    final userStats = userStatsAsync.value;

    // Get current workout info for timing
    final currentWorkout = ref.read(currentWorkoutProvider);
    final workoutExercises = currentWorkout?.exercises ?? [];
    final currentIndex = workoutExercises.indexWhere(
      (e) => e.id == widget.exercise.id,
    );
    final isLastExercise = currentIndex == workoutExercises.length - 1;

    // Get user account info
    final user = ref.read(firebaseUserProvider).asData?.value;
    final accountAgeInDays = user?.metadata.creationTime != null
        ? DateTime.now().difference(user!.metadata.creationTime!).inDays
        : 0;

    // TODO: Implement proper workout tracking providers:
    // - WorkoutHistoryProvider for totalWorkoutsCompleted, averageWorkoutVolume
    // - ExerciseVarietyProvider for uniqueExercisesCount
    // - WorkoutFrequencyProvider for workoutsPerWeek
    // For now, use smart placeholder values based on available data

    final totalWorkoutsCompleted =
        accountAgeInDays ~/ 3; // Rough estimate: 1 workout every 3 days
    final workoutStartTime = currentWorkout?.startTime;

    // Estimate average volume from current workout (placeholder)
    // A better implementation would query last 5 workouts from Firestore
    final averageWorkoutVolume = totalVolume > 0 ? totalVolume : 2000.0;

    // Estimate exercise variety from exercise history count
    // A better implementation would count distinct exercise names from Firestore
    final uniqueExercisesCount = exerciseHistoryCount > 0
        ? exerciseHistoryCount
        : 5;

    // Estimate workout frequency from account age and total workouts
    // A better implementation would query workouts in last 28 days
    final workoutsPerWeek = accountAgeInDays > 0
        ? (totalWorkoutsCompleted * 7.0) / accountAgeInDays
        : 2.0;

    final context = SuggestionContext(
      exercise: widget.exercise,
      exerciseData: _exerciseData,
      hasNotes: widget.exercise.notes?.isNotEmpty ?? false,
      isFirstTime: _lastActivity == null,
      completedSets: completedSets,
      totalSets: widget.exercise.sets.length,
      minWeight: minWeight,
      maxWeight: maxWeight,
      existingContributions: contributions,
      userLevel: userLevel,
      userContributionCount: userStats?.totalContributions ?? 0,
      exerciseHistoryCount: exerciseHistoryCount,
      totalVolume: totalVolume,
      totalWorkoutsCompleted: totalWorkoutsCompleted,
      accountAgeInDays: accountAgeInDays,
      workoutStartTime: workoutStartTime,
      isLastExerciseInWorkout: isLastExercise,
      currentExerciseIndex: currentIndex >= 0 ? currentIndex : 0,
      totalExercisesInWorkout: workoutExercises.length,
      averageWorkoutVolume: averageWorkoutVolume,
      uniqueExercisesCount: uniqueExercisesCount,
      workoutsPerWeek: workoutsPerWeek,
    );

    // Generate suggestions using provider
    await _suggestionsNotifier.generateSuggestions(context);
  }

  void _handleCommunitySuggestionTap(SmartSuggestion suggestion) {
    // REFACTORED: Pass selected suggestion to modal
    _showContributionModal(suggestion);
  }

  void _showContributionModal(SmartSuggestion suggestion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommunityContributionModal(
        exercise: widget.exercise,
        suggestionType: suggestion.type,
        initialSuggestion: suggestion.text,
        contextType: suggestion.contextType,
        exerciseData: _exerciseData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🐛 DEBUG: Log build with counting mode (debug only, removed from production)
    // Uncomment if needed for debugging:
    // if (kDebugMode) {
    //   debugPrint('🎨 [ExerciseListItem.build] Building ${widget.exercise.name}, countingMode=${widget.exercise.countingMode.name}');
    // }

    // Listen for autocollapse signals from provider
    ref.listen<AutoCollapseState>(
      exerciseAutoCollapseProvider(widget.exercise.id),
      (previous, next) {
        if (next.shouldExecuteCollapse &&
            (previous == null || !previous.shouldExecuteCollapse)) {
          // Collapse was signaled by provider
          _performCollapse();
          _autoCollapseNotifier.acknowledgeCollapse();
        }
      },
    );

    final config = ref.watch(appConfigProvider);
    final isCompleted = _areAllSetsCompleted();
    final isProMode = config.isProMode ?? false;

    return Card(
      elevation: 2,
      color: isCompleted && !_isExpanded // FIX: Use ref.watch() instead of ref.read()
          ? context.successContainer
          : null,
      child: InkWell(
        onTap: widget.isReorderMode
            ? null // Disable tap in reorder mode
            : !_isExpanded // FIX: Use ref.watch() instead of ref.read()
            ? () {
                // EXPAND: Card is collapsed, expand it
                _cancelAutoCollapse();

                // REFACTORED: Use provider to expand
                _expansionNotifier.expand();
                HapticFeedback.lightImpact();

                if (kDebugMode) {
                  debugPrint(
                    '👆 USER MANUALLY EXPANDED ${widget.exercise.name}',
                  );
                }
              }
            : (isCompleted
                  ? () {
                      // COLLAPSE: Card is expanded and exercise is complete, allow manual collapse
                      // REFACTORED: Use provider to collapse
                      _expansionNotifier.collapse();
                      HapticFeedback.lightImpact();

                      if (kDebugMode) {
                        debugPrint(
                          '👇 USER MANUALLY COLLAPSED ${widget.exercise.name}',
                        );
                      }
                    }
                  : widget
                        .onTap), // EDIT: Card is expanded but exercise not complete, allow editing
        onLongPress: () {
          // 🐛 DEBUG: Log removed from production (uncomment if needed for debugging)
          // if (kDebugMode) {
          //   debugPrint('👆 [InkWell.onLongPress] LONG PRESS DETECTED on ${widget.exercise.name}');
          // }
          _showExerciseOptions(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise header
              Row(
                children: [
                  _buildExerciseTypeIcon(context),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome esercizio - tappabile per dettagli
                        InkWell(
                          onTap: () {
                            context.pushNamed(
                              'workout-exercise-detail',
                              pathParameters: {
                                'exerciseName': Uri.encodeComponent(
                                  widget.exercise.name,
                                ),
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(8), // Standard border radius (design system)
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.exercise.name,
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SemanticIcon(
                                  icon: AppIcons.info,
                                  semanticLabel: 'Information',
                                  size: AppIconSize.small,
                                  color: context.colors.primary.withValues(alpha: 
                                    0.7,
                                )
                              ],
                            ),
                          ),
                        ),
                        // Spacing tra nome e badge
                        const SizedBox(height: 6),
                        // Badge row (APRE, Timer, Countdown) - Horizontally scrollable
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // APRE badge indicator (tappable)
                              if (widget.exercise.autoAdjustmentType ==
                                      AutoAdjustmentType.apre &&
                                  (config.enableApre ?? false)) ...[
                                InkWell(
                                  onTap: () =>
                                      _showAutoAdjustmentModal(context),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.colors.primary.withValues(alpha: 
                                        0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: context.colors.primary.withValues(alpha: 
                                          0.4,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SemanticIcon(
                                          icon: AppIcons.autoAwesome,
                                          semanticLabel: 'AI suggestion',
                                          size: AppIconSize.tiny,
                                          color: context.colors.primary,
                                        )
                                        SizedBox(width: 4),
                                        Text(
                                          'APRE ${widget.exercise.apreProtocol ?? 6}',
                                          style: context.textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: context.colors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                              ],
                              // Rest timer indicator (tappable) - conditional on showCustomTimers
                              if (config.showCustomTimers ?? isProMode) ...[
                                InkWell(
                                  onTap: () => _showQuickTimerSettings(context),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.exercise.restTime != null
                                          ? context.colors.primaryContainer
                                                .withValues(alpha: 0.5)
                                          : context
                                                .colors
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: widget.exercise.restTime != null
                                            ? context.colors.primary
                                                  .withValues(alpha: 0.3)
                                            : Colors.transparent,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SemanticIcon(
                                          icon: AppIcons.timer,
                                          semanticLabel: 'Rest timer',
                                          size: AppIconSize.tiny,
                                          color: widget.exercise.restTime != null
                                              ? context.colors.primary
                                              : context.colors.onSurfaceVariant,
                                        )
                                        SizedBox(width: 4),
                                        Text(
                                          widget.exercise.restTime != null
                                              ? _formatRestTime(
                                                  widget.exercise.restTime!,
                                                )
                                              : 'Default',
                                          style: context.textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                widget.exercise.restTime != null
                                                ? context.colors.primary
                                                : context
                                                      .colors
                                                      .onSurfaceVariant,
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        SemanticIcon(
                                          icon: AppIcons.edit,
                                          semanticLabel: 'Edit',
                                          size: AppIconSize.tiny,
                                          color: widget.exercise.restTime != null
                                              ? context.colors.primary
                                                    .withValues(alpha: 0.7,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              // Countdown visuale per auto-collasso - conditional on showCollapseCountdown
                              // REFACTORED: countdown now from provider
                              if (_autoCollapseState.countdown > 0 &&
                                  (config.showCollapseCountdown ??
                                      isProMode)) ...[
                                InkWell(
                                  onTap: _cancelAutoCollapse,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.colors.tertiaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: context.colors.tertiary
                                            .withValues(alpha: 0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SemanticIcon(
                                          icon: AppIcons.unfoldLess,
                                          semanticLabel: 'Collapse',
                                          size: AppIconSize.tiny,
                                          color: context.colors.tertiary,
                                        )
                                        SizedBox(width: 4),
                                        Text(
                                          '${_autoCollapseState.countdown}',
                                          style: context.textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: context.colors.tertiary,
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        SemanticIcon(
                                          icon: AppIcons.close,
                                          semanticLabel: 'Close',
                                          size: AppIconSize.tiny,
                                          color: context.colors.tertiary
                                              .withValues(alpha: 0.7,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                              ],
                              // TUT chip - moved here
                              if (config.showTutInfo ?? isProMode) ...[
                                _buildTutChip(context),
                                SizedBox(width: 8),
                              ],
                              // Quick Info icon
                              if (config.showQuickInfoIcon ?? isProMode) ...[
                                _buildQuickActionIcon(
                                  context: context,
                                  icon: AppIcons.info,
                                  color: context.infoColor,
                                  onTap: () async {
                                    final data =
                                        await _loadExerciseDataFromJson();
                                    if (data != null && mounted) {
                                      _showExerciseInfoModal(context, data);
                                    }
                                  },
                                ),
                                SizedBox(width: 8),
                              ],
                              // Warmup icon
                              if (config.showWarmupIcon ?? isProMode) ...[
                                _buildQuickActionIcon(
                                  context: context,
                                  icon: AppIcons.whatshot,
                                  color: context.warningColor,
                                  onTap: () async {
                                    final data =
                                        await _loadExerciseDataFromJson();
                                    if (data != null &&
                                        _hasWarmupData(data) &&
                                        mounted) {
                                      _showWarmupModal(context, data);
                                    }
                                  },
                                ),
                                SizedBox(width: 8),
                              ],
                              // Prevention icon
                              if (config.showPreventionIcon ?? isProMode) ...[
                                _buildQuickActionIcon(
                                  context: context,
                                  icon: AppIcons.shieldOutlined,
                                  color: context.successColor,
                                  onTap: () async {
                                    final data =
                                        await _loadExerciseDataFromJson();
                                    if (data != null &&
                                        _hasInjuryPreventionData(data) &&
                                        mounted) {
                                      _showInjuryPreventionModal(context, data);
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Insight chip - conditional on showExerciseInsights
                        if (_lastActivity != null &&
                            (config.showExerciseInsights ?? isProMode)) ...[
                          const SizedBox(height: 4),
                          _buildInsightChip(context),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'auto_adjustment':
                          _showAutoAdjustmentModal(context);
                          break;
                        case 'edit':
                          _showExerciseEditor(context);
                          break;
                        case 'change_exercise':
                          _showExerciseReplacement(context);
                          break;
                        case 'duplicate':
                          _duplicateExercise();
                          break;
                        // case 'counting_mode':  // TODO: Implement _showCountingModeSelector
                        //   _showCountingModeSelector(context);
                        //   break;
                        case 'delete':
                          _showDeleteConfirmation(context);
                          break;
                        case 'insight':
                          _showExerciseHistory(context);
                          break;
                        case 'community_advice':
                          _showCommunityAdvice(context);
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      final showAdvanced = config.showAdvancedMenu ?? isProMode;
                      final showCommunity =
                          config.showCommunitySuggestions ?? isProMode;
                      final showInsights =
                          config.showExerciseInsights ?? isProMode;

                      return [
                        // Auto Adjustment - always shown
                        PopupMenuItem(
                          value: 'auto_adjustment',
                          child: Row(
                            children: [
                              SemanticIcon(
                                icon: AppIcons.autoAwesome,
                                semanticLabel: 'AI suggestion',
                                size: AppIconSize.small,
                                color: widget.exercise.autoAdjustmentType != null
                                    ? context.colors.primary
                                    : null,
                              )
                              SizedBox(width: 8),
                              Text(
                                context.l10n.autoAdjustment,
                                style:
                                    widget.exercise.autoAdjustmentType != null
                                    ? context.textTheme.bodyMedium?.copyWith(
                                        color: context.colors.primary,
                                        fontWeight: FontWeight.w600,
                                      )
                                    : null,
                              ),
                              if (widget.exercise.autoAdjustmentType !=
                                  null) ...[
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(8), // Standard border radius (design system)
                                  ),
                                  child: Text(
                                    widget.exercise.autoAdjustmentType ==
                                            AutoAdjustmentType.apre
                                        ? 'APRE'
                                        : 'RPE',
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: context.colors.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),

                        // Basic items always shown
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              SemanticIcon(
                                icon: AppIcons.delete,
                                semanticLabel: 'Delete',
                                size: AppIconSize.small,
                                color: context.errorColor,
                              )
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: context.textTheme.bodyMedium?.copyWith(color: context.errorColor),
                              ),
                            ],
                          ),
                        ),

                        // Advanced options - conditional
                        if (showAdvanced) ...[
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                SemanticIcon(
                                  icon: AppIcons.edit,
                                  semanticLabel: 'Edit',
                                  size: AppIconSize.small,
                                )
                                SizedBox(width: 8),
                                Text(context.l10n.exerciseListEdit),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'change_exercise',
                            child: Row(
                              children: [
                                SemanticIcon(
                                  icon: AppIcons.swapHoriz,
                                  semanticLabel: 'Change exercise',
                                  size: AppIconSize.small,
                                )
                                SizedBox(width: 8),
                                Text(context.l10n.exerciseChangeVariation),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                SemanticIcon(
                                  icon: AppIcons.copy,
                                  semanticLabel: 'Duplicate',
                                  size: AppIconSize.small,
                                )
                                SizedBox(width: 8),
                                Text(context.l10n.exerciseListDuplicate),
                              ],
                            ),
                          ),
                        ],

                        // Insights - conditional
                        if (showInsights && showAdvanced)
                          PopupMenuItem(
                            value: 'insight',
                            child: Row(
                              children: [
                                SemanticIcon(
                                  icon: AppIcons.insights,
                                  semanticLabel: 'View insights',
                                  size: AppIconSize.small,
                                )
                                SizedBox(width: 8),
                                Text(context.l10n.exerciseListInsight),
                              ],
                            ),
                          ),

                        // Counting mode - conditional
                        // TODO: Implement counting mode selector + localization
                        // if (showAdvanced)
                        //   PopupMenuItem(
                        //     value: 'counting_mode',
                        //     child: Row(
                        //       children: [
                        //         Icon(AppIcons.formatListNumbered, size: 20),
                        //         SizedBox(width: 8),
                        //         Text(context.l10n.changeCountingMode),
                        //       ],
                        //     ),
                        //   ),

                        // Community advice - conditional
                        if (showCommunity && showAdvanced)
                          PopupMenuItem(
                            value: 'community_advice',
                            child: Row(
                              children: [
                                SemanticIcon(
                                  icon: AppIcons.tip,
                                  semanticLabel: 'Tips',
                                  size: AppIconSize.small,
                                )
                                SizedBox(width: 8),
                                Text(context.l10n.communityAdvice),
                              ],
                            ),
                          ),
                      ];
                    },
                  ),
                ],
              ),

              // Notes section - conditional on showExerciseNotes
              if (config.showExerciseNotes ?? isProMode) ...[
                SizedBox(height: 8),
                GestureDetector(
                  onTap: _toggleNotesEdit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    padding: EdgeInsets.all(_isEditingNotes ? 12 : 8),
                    decoration: BoxDecoration(
                      color: _isEditingNotes
                          ? context.colors.primaryContainer.withValues(alpha: 0.3)
                          : context.colors.surfaceContainerHighest.withOpacity(
                              0.5,
                            ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isEditingNotes
                            ? context.colors.primary
                            : Colors.transparent,
                        width: _isEditingNotes ? 2 : 0,
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 300),
                          turns: _isEditingNotes
                              ? 0.125
                              : 0, // 45 degree rotation
                          child: SemanticIcon(
                            icon: _isEditingNotes ? AppIcons.edit : AppIcons.note,
                            semanticLabel: _isEditingNotes ? 'Edit note' : 'Note',
                            size: AppIconSize.tiny,
                            color: _isEditingNotes
                                ? context.colors.primary
                                : context.colors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isEditingNotes
                                ? TextField(
                                    key: const ValueKey('notes-editor'),
                                    controller: _notesController,
                                    autofocus: true,
                                    maxLines: null,
                                    style: context.textTheme.bodySmall,
                                    decoration: InputDecoration(
                                      hintText: context.l10n.exerciseListAddNotesHint,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                    onSubmitted: (_) => _toggleNotesEdit(),
                                  )
                                : Text(
                                    key: const ValueKey('notes-text'),
                                    widget.exercise.notes?.isNotEmpty == true
                                        ? widget.exercise.notes!
                                        : context.l10n.exerciseListTapToAddNotes,
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                          color:
                                              widget
                                                      .exercise
                                                      .notes
                                                      ?.isNotEmpty ==
                                                  true
                                              ? context.colors.onSurfaceVariant
                                              : context.colors.onSurfaceVariant
                                                    .withValues(alpha: 0.5),
                                          fontStyle:
                                              widget
                                                      .exercise
                                                      .notes
                                                      ?.isNotEmpty ==
                                                  true
                                              ? FontStyle.normal
                                              : FontStyle.italic,
                                        ),
                                  ),
                          ),
                        ),
                        if (_savingNotes)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.colors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Warmup suggestion (smart display logic)
              if (_shouldShowWarmupSuggestion())
                WarmupSuggestionCard(
                  exerciseName: widget.exercise.name,
                  workingWeight: _getMaxWorkingWeight(),
                  targetReps: _getTargetReps(),
                  onAddWarmupSets: _addWarmupSets,
                  onDismiss: () {
                    // Store dismissal in local state or preferences
                  },
                ),

              // REFACTORED: Smart suggestion chips from provider (top 3, priority-sorted)
              if (_suggestions.isNotEmpty &&
                  (config.showCommunitySuggestions ?? isProMode))
                ..._suggestions.map(
                  (suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SmartSuggestionChip(
                      suggestion: suggestion.text,
                      icon: _getSuggestionIcon(suggestion.type),
                      onTap: () => _handleCommunitySuggestionTap(suggestion),
                      onDismiss: () {
                        _suggestionsNotifier.dismissSuggestion(suggestion.id);
                      },
                      displayDuration: const Duration(
                        seconds: 8,
                      ), // Increased from 7
                    ),
                  ),
                ),

              // Sets display - hidden when collapsed, completed, or in reorder mode
              if (widget.isReorderMode)
                // Reorder mode: Show compact view with set count
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SemanticIcon(
                        icon: AppIcons.workout,
                        semanticLabel: 'Workout',
                        size: AppIconSize.tiny,
                        color: context.colors.onSurfaceVariant,
                      )
                      SizedBox(width: 8),
                      Text(
                        '${widget.exercise.sets.length} ${widget.exercise.sets.length == 1 ? 'set' : 'sets'}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.exercise.sets
                          .where((s) => s.isCompleted)
                          .isNotEmpty) ...[
                        SizedBox(width: 8),
                        Text(
                          '• ${widget.exercise.sets.where((s) => s.isCompleted).length}/${widget.exercise.sets.length} completati',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.successColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              else if (_isExpanded || !isCompleted) // FIX: Use ref.watch() instead of ref.read()
                _buildSetsSection(context, config)
              else
                // Show compact summary when collapsed
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SemanticIcon(
                        icon: AppIcons.complete,
                        semanticLabel: 'Complete',
                        size: AppIconSize.tiny,
                        color: context.successColor,
                      )
                      SizedBox(width: 8),
                      Text(
                        '${widget.exercise.sets.where((s) => s.isCompleted).length} sets completati',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.successColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Tocca per espandere',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseTypeIcon(BuildContext context) {
    final colorScheme = context.colors;

    // Per esercizi di tipo single, usa la GIF animata
    if (widget.exercise.type == ExerciseType.single) {
      final gifUrlAsync = ref.watch(
        exerciseGifUrlProvider(widget.exercise.name),
      );

      return gifUrlAsync.when(
        // ⚡ REPAINT OPTIMIZATION: RepaintBoundary isolates GIF animation from parent repaints
        // GIF widget has AutomaticKeepAliveClientMixin + RepaintBoundary = optimal performance
        data: (gifUrl) => RepaintBoundary(
          child: ExerciseGifWidget(
            gifUrl: gifUrl,
            exerciseName: widget.exercise.name,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            iconColor: colorScheme.primary,
          ),
        ),
        loading: () => Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          ),
        ),
        error: (_, __) => Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: SemanticIcon(
            icon: AppIcons.workout,
            semanticLabel: 'Workout',
            color: colorScheme.primary,
            size: AppIconSize.small,
          ),
        ),
      );
    }

    // Per altri tipi di esercizio, usa le icone tradizionali
    IconData icon;
    Color color;

    switch (widget.exercise.type) {
      case ExerciseType.superset:
        icon = AppIcons.repeat;
        color = colorScheme.secondary;
        break;
      case ExerciseType.dropset:
        icon = AppIcons.trendDown;
        color = colorScheme.tertiary;
        break;
      case ExerciseType.restPause:
        icon = AppIcons.pauseCircle;
        color = colorScheme.error;
        break;
      case ExerciseType.single:
        icon = AppIcons.workout;
        color = colorScheme.primary;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: SemanticIcon(
        icon: icon,
        semanticLabel: 'Suggestion',
        color: color,
        size: AppIconSize.small,
      ),
    );
  }

  IconData _getSuggestionIcon(ContributionType type) {
    switch (type) {
      case ContributionType.tip:
        return AppIcons.tip;
      case ContributionType.warning:
        return AppIcons.warningAmberRounded;
      case ContributionType.correction:
        return AppIcons.editNote;
      case ContributionType.technique:
        return AppIcons.workout;
      default:
        return AppIcons.tipsAndUpdates;
    }
  }

  Widget _buildCategoryChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.exercise.category.name.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context) {
    Color color;
    switch (widget.exercise.type) {
      case ExerciseType.single:
        color = context.colors.primary;
        break;
      case ExerciseType.superset:
        color = context.colors.secondary;
        break;
      case ExerciseType.dropset:
        color = context.colors.tertiary;
        break;
      case ExerciseType.restPause:
        color = context.colors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.exercise.type.name.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTutChip(BuildContext context) {
    final tutText = widget.exercise.tut ?? _getDefaultTut();
    final isDefault = widget.exercise.tut == null;

    return GestureDetector(
      onTap: () => _showTutExplanationModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDefault
              ? context.colors.surfaceContainerHighest.withValues(alpha: 0.3)
              : context.colors.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDefault
                ? context.colors.outline.withValues(alpha: 0.3)
                : context.colors.primary.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemanticIcon(
              icon: AppIcons.speed,
              semanticLabel: 'Speed',
              size: AppIconSize.tiny,
              color: isDefault
                  ? context.colors.onSurfaceVariant
                  : context.colors.primary,
            )
            SizedBox(width: 4),
            Text(
              _formatTutDisplay(tutText),
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDefault
                    ? context.colors.onSurfaceVariant
                    : context.colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDefaultTut() {
    // Default TUT based on exercise type
    switch (widget.exercise.type) {
      case ExerciseType.single:
        return widget.exercise.category == ExerciseCategory.legs
            ? '3-0-1-0'
            : '2-1-2-0';
      case ExerciseType.superset:
        return '2-0-1-0';
      case ExerciseType.dropset:
        return '2-1-2-0';
      case ExerciseType.restPause:
        return '2-1-2-1';
    }
  }

  String _formatTutDisplay(String tut) {
    if (tut == 'ISO') return 'ISO';
    if (tut == 'EXP') return 'ESP';
    return tut; // Show as-is for tempo like "3-1-2-0"
  }

  Widget _buildQuickActionIcon({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  Widget _buildSetsSection(BuildContext context, AppConfig config) {
    if (widget.exercise.sets.isEmpty) {
      // For DropSet exercises, show execute button instead of "No sets yet"
      if (widget.exercise.type == ExerciseType.dropset) {
        final dropsetExercise = widget.exercise as DropSetExercise;
        return GestureDetector(
          onTap: () => _executeDropSet(dropsetExercise),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.colors.tertiary.withValues(alpha: 0.5),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.playCircleOutline,
                  semanticLabel: 'Playcircleoutline',
                  size: AppIconSize.small,
                  color: context.colors.tertiary,
                )
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.executeDropset,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SemanticIcon(
                  icon: AppIcons.forwardIos,
                  semanticLabel: 'Forwardios',
                  size: AppIconSize.tiny,
                  color: context.colors.tertiary,
                )
              ],
            ),
          ),
        );
      }

      // For RestPause exercises, show execute button
      if (widget.exercise.type == ExerciseType.restPause) {
        final restPauseExercise = widget.exercise as RestPauseExercise;
        return GestureDetector(
          onTap: () => _executeRestPause(restPauseExercise),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.5),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.playCircleOutline,
                  semanticLabel: 'Playcircleoutline',
                  size: AppIconSize.small,
                  color: context.colors.primary,
                )
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.executeRestPause,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SemanticIcon(
                  icon: AppIcons.forwardIos,
                  semanticLabel: 'Forwardios',
                  size: AppIconSize.tiny,
                  color: context.colors.primary,
                )
              ],
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.colors.outline.withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            SemanticIcon(
              icon: AppIcons.addCircleOutline,
              semanticLabel: 'Addcircleoutline',
              size: AppIconSize.small,
              color: context.colors.onSurfaceVariant,
            )
            SizedBox(width: 8),
            Text(
              'No sets yet - tap to add',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.exerciseListSetsProgress(
                widget.exercise.sets.where((s) => s.isCompleted).length.toString(),
                widget.exercise.sets.length.toString(),
              ),
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (widget.exercise.sets.isNotEmpty)
              Text(
                'Weight × Reps',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...widget.exercise.sets.asMap().entries.expand(
          (entry) => [
            _buildSetItem(context, entry.key, entry.value, config),
            // Inject metadata banner after Set 4 if APRE enabled
            if (entry.key == 3 && widget.exercise.useAPRE && widget.exercise.sets.length >= 4)
              _buildMetadataBanner(context),
          ],
        ),
        const SizedBox(height: 8),
        // Add set button (with smooth animated collapse button when completed)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            // Combine slide and fade for smooth transition
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: _areAllSetsCompleted() && _isExpanded // FIX: Use ref.watch() instead of ref.read()
              ? Row(
                  key: const ValueKey('buttons_with_collapse'),
                  children: [
                    // Add Set button (left) - animates to half width
                    Expanded(
                      child: InkWell(
                        onTap: () => _addNewSet(),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: context.colors.primaryContainer.withOpacity(
                              0.2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: context.colors.primary.withValues(alpha: 0.3),
                              style: BorderStyle.solid,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SemanticIcon(
                                icon: AppIcons.addCircleOutline,
                                semanticLabel: 'Addcircleoutline',
                                size: AppIconSize.small,
                                color: context.colors.primary,
                              )
                              SizedBox(width: 8),
                              Text(
                                context.l10n.addSet,
                                style: context.textTheme.labelLarge?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Collapse button (right) - fades in smoothly
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: InkWell(
                          onTap: () {
                            // REFACTORED: Use provider to collapse
                            _expansionNotifier.collapse();
                            HapticFeedback.lightImpact();

                            if (kDebugMode) {
                              debugPrint(
                                '👇 USER MANUALLY COLLAPSED via button for ${widget.exercise.name}',
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: context.colors.secondaryContainer
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.colors.secondary.withOpacity(
                                  0.3,
                                ),
                                style: BorderStyle.solid,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SemanticIcon(
                                  icon: AppIcons.unfoldLess,
                                  semanticLabel: 'Collapse',
                                  size: AppIconSize.small,
                                  color: context.colors.secondary,
                                )
                                SizedBox(width: 8),
                                Text(
                                  context.l10n.collapseExercise,
                                  style: context.textTheme.labelLarge?.copyWith(
                                    color: context.colors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  key: const ValueKey('button_add_only'),
                  onTap: () => _addNewSet(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: context.colors.primary.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SemanticIcon(
                          icon: AppIcons.addCircleOutline,
                          semanticLabel: 'Addcircleoutline',
                          size: AppIconSize.small,
                          color: context.colors.primary,
                        )
                        SizedBox(width: 8),
                        Text(
                          context.l10n.addSet,
                          style: context.textTheme.labelLarge?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSetItem(
    BuildContext context,
    int index,
    ExerciseSet set,
    AppConfig config,
  ) {
    final isWarmup = set.isWarmup;

    return Dismissible(
      key: Key('${widget.exercise.id}_set_${set.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: context.errorColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(AppIcons.deleteOutline, color: Colors.white, size: 24),
      ),
      confirmDismiss: (direction) async {
        // Show smooth animated confirmation dialog
        final l10n = context.l10n;

        return await showGeneralDialog<bool>(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Dismiss',
          barrierColor: Colors.black.withValues(alpha: 0.54),
          transitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) {
            return Container(); // Not used with transitionBuilder
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            // Smooth scale and fade animation
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: curvedAnimation,
                child: AlertDialog(
                  title: Text(
                    isWarmup
                        ? l10n.deleteWarmupSetTitle
                        : l10n.deleteSetTitle(index + 1),
                  ),
                  content: Text(l10n.deleteSetMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: context.errorColor),
                      child: Text(l10n.delete),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteSet(set, index);
      },
      child: GestureDetector(
        onTap: widget.onSetToggleComplete != null
            ? () => _toggleSetCompletionWithFeedback(context, set)
            : null,
        onDoubleTap: widget.onSetUpdate != null
            ? () => _quickEditSet(context, set)
            : null,
        onLongPress: widget.onSetUpdate != null
            ? () => _editSet(context, set)
            : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isWarmup
                ? context.warningContainer // Warmup color
                : set.isCompleted
                ? context.colors.tertiary.withValues(alpha: 0.1)
                : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: isWarmup
                ? Border.all(color: context.warningColor.withValues(alpha: 0.3))
                : set.isCompleted
                ? Border.all(color: context.colors.tertiary.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            children: [
              // Set number with warmup indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isWarmup
                      ? context.warningColor.withValues(alpha: 0.3)
                      : set.isCompleted
                      ? context.colors.tertiary
                      : context.colors.outline.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isWarmup
                      ? Icon(
                          AppIcons.streak,
                          size: 14,
                          color: context.warningColor,
                        )
                      : Text(
                          '${index + 1}',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: set.isCompleted
                                ? context.colors.onTertiary
                                : context.colors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 12),

              // Warmup badge
              if (isWarmup) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.warningContainer,
                    borderRadius: BorderRadius.circular(8), // Standard border radius (design system)
                  ),
                  child: Text(
                    'W',
                    style: context.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.warningColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Set details (adapted based on counting mode)
              Expanded(
                child: Row(
                  children: [
                    // Determine counting mode to show appropriate fields
                    ..._buildSetDetailsForMode(set, config),

                    // RPE indicator if completed
                    if (set.isCompleted && set.rpe != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getRpeIndicatorColor(
                            set.rpe!,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8), // Standard border radius (design system)
                          border: Border.all(
                            color: _getRpeIndicatorColor(
                              set.rpe!,
                            ).withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'RPE ${set.rpe}',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: _getRpeIndicatorColor(set.rpe!),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],

                    // Quick edit hint
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.outline.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8), // Standard border radius (design system)
                      ),
                      child: Text(
                        '✏️',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant.withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Completion status - clickable toggle
              InkWell(
                onTap: widget.onSetToggleComplete != null
                    ? () => _toggleSetCompletionWithFeedback(context, set)
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: set.isCompleted
                        ? Icon(
                            AppIcons.complete,
                            key: const ValueKey('completed'),
                            size: 20,
                            color: context.colors.tertiary,
                          )
                        : Icon(
                            AppIcons.radioButtonUnchecked,
                            key: const ValueKey('uncompleted'),
                            size: 20,
                            color: context.colors.outline,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewSet() {
    if (widget.onExerciseUpdate == null) return;

    // Get the last set's values as defaults for the new set
    ExerciseSet? lastSet;
    if (widget.exercise.sets.isNotEmpty) {
      // Find the last non-warmup set
      final workingSets = widget.exercise.sets
          .where((s) => !s.isWarmup)
          .toList();
      lastSet = workingSets.isNotEmpty
          ? workingSets.last
          : widget.exercise.sets.last;
    }

    // Create new set with default or copied values
    final newSet = ExerciseSet(
      setNumber: widget.exercise.sets.length + 1,
      weight: lastSet?.weight,
      reps: lastSet?.reps ?? 10,
      isWarmup: false,
    );

    final updatedSets = [...widget.exercise.sets, newSet];
    final updatedExercise = widget.exercise.copyWith(sets: updatedSets);
    widget.onExerciseUpdate!(updatedExercise);

    // Show feedback
    SnackBarService.showInfo(
      context,
      context.l10n.exerciseListSetAdded(newSet.setNumber.toString()),
    );

    HapticFeedback.lightImpact();
  }

  void _handleAPRESuggestion(ExerciseSet currentSet, double suggestedWeight) {
    if (widget.onExerciseUpdate == null) return;

    // Find the next set (Set 4 in APRE protocol)
    final nextSetIndex = currentSet.setNumber; // Set 4 is after Set 3
    if (nextSetIndex < widget.exercise.sets.length) {
      final updatedSets = List<ExerciseSet>.from(widget.exercise.sets);
      updatedSets[nextSetIndex] = updatedSets[nextSetIndex].copyWith(
        weight: suggestedWeight,
      );

      final updatedExercise = widget.exercise.copyWith(sets: updatedSets);
      widget.onExerciseUpdate!(updatedExercise);

      // Show confirmation
      SnackBarService.showInfo(
        context,
        'APRE: Set ${nextSetIndex + 1} weight adjusted to ${suggestedWeight.toStringAsFixed(1)} kg',
      );
    }
  }

  void _handleRPESuggestion(double suggestedWeight) {
    if (widget.onExerciseUpdate == null) return;

    // Apply suggested weight to all remaining incomplete sets
    final updatedSets = List<ExerciseSet>.from(widget.exercise.sets);
    bool hasUpdated = false;

    for (int i = 0; i < updatedSets.length; i++) {
      if (!updatedSets[i].isCompleted) {
        updatedSets[i] = updatedSets[i].copyWith(weight: suggestedWeight);
        hasUpdated = true;
      }
    }

    if (hasUpdated) {
      final updatedExercise = widget.exercise.copyWith(sets: updatedSets);
      widget.onExerciseUpdate!(updatedExercise);

      // Show confirmation
      final l10n = AppLocalizations.of(context);
      SnackBarService.showInfo(
        context,
        '${l10n.rpeAutoregulation}: ${l10n.weightAdjustedTo} ${suggestedWeight.toStringAsFixed(1)} kg',
      );
    }
  }

  void _deleteSet(ExerciseSet set, int index) {
    if (widget.onExerciseUpdate == null) return;

    // Remove the set from the list
    final updatedSets = List<ExerciseSet>.from(widget.exercise.sets);
    updatedSets.removeAt(index);

    // Renumber remaining sets
    for (var i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }

    final updatedExercise = widget.exercise.copyWith(sets: updatedSets);
    widget.onExerciseUpdate!(updatedExercise);

    // Show feedback
    SnackBarService.showCustom(
      context,
      message: set.isWarmup
          ? '🗑️ Warmup set deleted'
          : '🗑️ Set ${index + 1} deleted',
      actionLabel: 'Undo',
      onAction: () {
        // Restore the set
        final restoredSets = List<ExerciseSet>.from(updatedSets);
        restoredSets.insert(index, set);

        // Renumber again
        for (var i = 0; i < restoredSets.length; i++) {
          restoredSets[i] = restoredSets[i].copyWith(setNumber: i + 1);
        }

        final restoredExercise = widget.exercise.copyWith(sets: restoredSets);
        widget.onExerciseUpdate!(restoredExercise);
      },
    );

    HapticFeedback.mediumImpact();
  }

  void _showExerciseOptions(BuildContext context) {
    // 🐛 DEBUG: Log removed from production (uncomment if needed for debugging)
    // if (kDebugMode) {
    //   debugPrint('📝 [_showExerciseOptions] Showing options menu for ${widget.exercise.name}');
    // }

    ExerciseOptionsModal.show(
      context,
      widget.exercise,
      onEdit: () => _showExerciseEditor(context),
      onHistory: () => _showExerciseHistory(context),
      onDuplicate: () => _duplicateExercise(),
      onDelete: () => _showDeleteConfirmation(context),
      onChangeCountingMode: () {
        // 🐛 DEBUG: Now with kDebugMode guard for production safety
        if (kDebugMode) {
          debugPrint('🔘 [onChangeCountingMode] CALLBACK TRIGGERED!');
        }
        _handleCountingModeChange(context);
      },
    );
  }

  Future<void> _handleCountingModeChange(BuildContext context) async {
    // 🐛 DEBUG: Entry point (now with kDebugMode guard for production safety)
    if (kDebugMode) {
      debugPrint('🚀 [_handleCountingModeChange] METHOD CALLED for ${widget.exercise.name}');
      debugPrint('   Current mode: ${widget.exercise.countingMode.name}');
    }

    // Show counting mode picker
    final newMode = await CountingModePickerModal.show(
      context,
      currentMode: widget.exercise.countingMode,
    );

    // 🐛 DEBUG: After modal (now with kDebugMode guard for production safety)
    if (kDebugMode) {
      debugPrint('📱 [_handleCountingModeChange] Modal returned: ${newMode?.name ?? "NULL (cancelled)"}');
    }

    // User cancelled
    if (newMode == null || !mounted) return;

    // Check if there are completed sets
    final completedSetsCount = ref.read(currentWorkoutProvider.notifier).getCompletedSetsCount(widget.exercise.id);

    if (completedSetsCount > 0) {
      // Show warning dialog
      final action = await CountingModeWarningDialog.show(
        context,
        completedSetsCount: completedSetsCount,
        fromMode: widget.exercise.countingMode.getDisplayName(context.l10n),
        toMode: newMode.getDisplayName(context.l10n),
      );

      // User cancelled
      if (action == CountingModeWarningAction.cancelled || !mounted) return;

      // TODO: Handle reset action if user chose reset
      // For now, we always keep data (action == keep || action == reset)
    }

    // Change counting mode in provider
    if (mounted) {
      // 🐛 DEBUG: Now with kDebugMode guard for production safety
      if (kDebugMode) {
        debugPrint('🔄 [_handleCountingModeChange] CALLING changeExerciseCountingMode: ${widget.exercise.countingMode.name} → ${newMode.name}');
      }

      ref.read(currentWorkoutProvider.notifier).changeExerciseCountingMode(
        widget.exercise.id,
        newMode,
      );

      // 🐛 DEBUG: Now with kDebugMode guard for production safety
      if (kDebugMode) {
        debugPrint('✅ [_handleCountingModeChange] changeExerciseCountingMode CALLED');
      }

      // Show success feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.countingModeChanged),
            duration: const Duration(seconds: 2),
            backgroundColor: context.colors.primary,
          ),
        );
      }
    }
  }

  void _openContributionModal(ContributionType type, {String? contextType}) {
    final suggestion = SmartSuggestion(
      id: 'manual_contribution',
      text: '',
      type: type,
      contextType: contextType ?? 'general',
      priority: 50,
      createdAt: DateTime.now(),
      trigger: 'manual_open',
    );
    _showContributionModal(suggestion);
  }

  void _showExerciseEditor(BuildContext context) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.edit, color: context.colors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Modifica esercizio',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(AppIcons.close),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Editor form
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: EditExerciseModal(
                    exercise: widget.exercise,
                    onSave: (updatedExercise) {
                      // Close the modal FIRST
                      if (context.mounted) {
                        Navigator.pop(context);
                      }

                      // Then update the exercise
                      Future.microtask(() {
                        widget.onExerciseUpdate?.call(updatedExercise);
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _duplicateExercise() {
    // Crea una copia dell'esercizio
    final duplicatedExercise = Exercise(
      name: '${widget.exercise.name} (Copy)',
      type: widget.exercise.type,
      category: widget.exercise.category,
      sets: widget.exercise.sets
          .map(
            (set) => ExerciseSet(
              setNumber: set.setNumber,
              weight: set.weight,
              reps: set.reps,
              notes: set.notes,
            ),
          )
          .toList(),
      notes: widget.exercise.notes,
      restTime: widget.exercise.restTime,
    );

    // Aggiungi l'esercizio duplicato
    widget.onExerciseUpdate?.call(duplicatedExercise);

    // Mostra feedback
    if (context.mounted) {
      SnackBarService.showSuccess(
        context,
        '✅ Duplicated "${widget.exercise.name}"',
      );
    }
  }

  Future<void> _showExerciseReplacement(BuildContext context) async {
    // Haptic feedback
    HapticFeedbackService.selection(ref);

    final selectedExercise = await showDialog<ExerciseDatabase>(
      context: context,
      builder: (context) => ExerciseReplacementDialog(
        currentExercise: widget.exercise,
        onReplace: (newExercise) {
          Navigator.of(context).pop(newExercise);
        },
      ),
    );

    if (selectedExercise != null && context.mounted) {
      // Create updated exercise with new name and category
      final updatedExercise = Exercise(
        id: widget.exercise.id,
        name: selectedExercise.name,
        type: widget.exercise.type,
        category: _mapCategoryFromDatabase(selectedExercise),
        sets: widget.exercise.sets,
        notes: widget.exercise.notes,
        restTime: widget.exercise.restTime,
        tut: widget.exercise.tut,
        autoAdjustmentType: widget.exercise.autoAdjustmentType,
        apreProtocol: widget.exercise.apreProtocol,
      );

      // Update exercise via callback
      widget.onExerciseUpdate?.call(updatedExercise);

      // Show success message
      SnackBarService.showSuccess(
        context,
        context.l10n.exerciseChangeVariationSuccess,
      );
    }
  }

  ExerciseCategory _mapCategoryFromDatabase(ExerciseDatabase dbExercise) {
    // Map from database category string to ExerciseCategory enum
    final categoryStr = dbExercise.category?.toLowerCase() ?? '';

    if (categoryStr.contains('chest') || categoryStr.contains('petto')) {
      return ExerciseCategory.chest;
    } else if (categoryStr.contains('back') || categoryStr.contains('dorso') || categoryStr.contains('schiena')) {
      return ExerciseCategory.back;
    } else if (categoryStr.contains('shoulder') || categoryStr.contains('spalla') || categoryStr.contains('spalle')) {
      return ExerciseCategory.shoulders;
    } else if (categoryStr.contains('bicep') || categoryStr.contains('bicipiti')) {
      return ExerciseCategory.arms;
    } else if (categoryStr.contains('tricep') || categoryStr.contains('tricipiti')) {
      return ExerciseCategory.arms;
    } else if (categoryStr.contains('legs') || categoryStr.contains('leg') || categoryStr.contains('gambe') || categoryStr.contains('quadri') || categoryStr.contains('femorali')) {
      return ExerciseCategory.legs;
    } else if (categoryStr.contains('abs') || categoryStr.contains('addominali') || categoryStr.contains('core')) {
      return ExerciseCategory.abs;
    } else if (categoryStr.contains('cardio')) {
      return ExerciseCategory.cardio;
    } else {
      return ExerciseCategory.other;
    }
  }

  void _showQuickTimerSettings(BuildContext context) {
    // Haptic feedback per feedback tattile
    HapticFeedback.lightImpact();

    int? selectedTime = widget.exercise.restTime;
    final List<int> quickOptions = [30, 60, 90, 120, 150, 180, 240, 300];

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Title
              Row(
                children: [
                  Icon(AppIcons.timer, color: context.colors.primary),
                  SizedBox(width: 12),
                  Text(
                    'Rest Timer Settings',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                context.l10n.exerciseListSetRestTimeMessage(widget.exercise.name),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 20),

              // Default option
              Card(
                elevation: 0,
                color: selectedTime == null
                    ? context.colors.primaryContainer.withValues(alpha: 0.3)
                    : context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                child: InkWell(
                  onTap: () {
                    setState(() => selectedTime = null);
                    HapticFeedback.selectionClick();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        SemanticIcon(
                          icon: AppIcons.timerOff,
                          semanticLabel: 'Timeroff',
                          color: selectedTime == null
                              ? context.colors.primary
                              : context.colors.onSurfaceVariant,
                        )
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.exerciseListUseDefaultTimer,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: selectedTime == null
                                      ? context.colors.primary
                                      : context.colors.onSurface,
                                ),
                              ),
                              Text(
                                context.l10n.exerciseListUsesGlobalRestTimer,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selectedTime == null)
                          SemanticIcon(
                            icon: AppIcons.complete,
                            semanticLabel: 'Complete',
                            color: context.colors.primary,
                          )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Quick options
              Text(
                context.l10n.exerciseListQuickOptions,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickOptions.map((seconds) {
                  final isSelected = selectedTime == seconds;
                  return FilterChip(
                    selected: isSelected,
                    label: Text(_formatRestTime(seconds)),
                    onSelected: (selected) {
                      setState(() => selectedTime = selected ? seconds : null);
                      HapticFeedback.selectionClick();
                    },
                    selectedColor: context.colors.primaryContainer,
                    checkmarkColor: context.colors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.l10n.exerciseListCancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: selectedTime != widget.exercise.restTime
                          ? () {
                              final updated = widget.exercise.copyWith(
                                restTime: selectedTime,
                              );
                              widget.onExerciseUpdate?.call(updated);
                              Navigator.pop(context);

                              // Show feedback
                              SnackBarService.showInfo(
                                context,
                                selectedTime != null
                                    ? context.l10n.exerciseListRestTimerSetTo(_formatRestTime(selectedTime!))
                                    : context.l10n.exerciseListUsingDefaultTimer,
                              );
                            }
                          : null,
                      child: Text(context.l10n.exerciseListSave),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showRestTimerSettings(BuildContext context) {
    int? selectedTime = widget.exercise.restTime;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.colors.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Text(
                context.l10n.exerciseListSetRestTimer,
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Timer options
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [30, 60, 90, 120, 180, 240, 300].map((seconds) {
                  final minutes = seconds ~/ 60;
                  final remainingSeconds = seconds % 60;
                  final label = minutes > 0
                      ? (remainingSeconds > 0
                            ? '${minutes}m ${remainingSeconds}s'
                            : '${minutes}m')
                      : '${seconds}s';

                  return ChoiceChip(
                    label: Text(label),
                    selected: selectedTime == seconds,
                    onSelected: (selected) {
                      setState(() {
                        selectedTime = selected ? seconds : null;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 8),

              // Custom time option
              OutlinedButton.icon(
                onPressed: () async {
                  // Show time picker per tempo personalizzato
                  final customTime = await _showCustomTimePicker(
                    context,
                    selectedTime ?? 60,
                  );
                  if (customTime != null) {
                    setState(() {
                      selectedTime = customTime;
                    });
                  }
                },
                icon: const Icon(AppIcons.edit, size: 18),
                label: Text(
                  selectedTime != null &&
                          ![
                            30,
                            60,
                            90,
                            120,
                            180,
                            240,
                            300,
                          ].contains(selectedTime)
                      ? context.l10n.exerciseListCustomTime(_formatTime(selectedTime!))
                      : context.l10n.exerciseListCustom,
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.exerciseListCancel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: selectedTime != null
                        ? () {
                            final updated = widget.exercise.copyWith(
                              restTime: selectedTime,
                            );
                            widget.onExerciseUpdate?.call(updated);
                            Navigator.pop(context);

                            // Show confirmation
                            SnackBarService.showInfo(
                              context,
                              context.l10n.exerciseListRestTimerSetTo(_formatTime(selectedTime!)),
                            );
                          }
                        : null,
                    child: Text(context.l10n.exerciseListConfirm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int?> _showCustomTimePicker(
    BuildContext context,
    int initialSeconds,
  ) async {
    int minutes = initialSeconds ~/ 60;
    int seconds = initialSeconds % 60;

    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.exerciseListCustomRestTime),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minutes picker
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.exerciseListMinutes, style: context.textTheme.bodySmall),
                const SizedBox(height: 8),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: TextEditingController(text: minutes.toString()),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      minutes = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Text(':', style: context.textTheme.headlineSmall),
            const SizedBox(width: 16),
            // Seconds picker
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.exerciseListSeconds, style: context.textTheme.bodySmall),
                const SizedBox(height: 8),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: TextEditingController(text: seconds.toString()),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      seconds = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.exerciseListCancel),
          ),
          FilledButton(
            onPressed: () {
              final totalSeconds = (minutes * 60) + seconds;
              Navigator.pop(context, totalSeconds > 0 ? totalSeconds : null);
            },
            child: Text(context.l10n.exerciseListSetButton),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return remainingSeconds > 0
          ? '${minutes}m ${remainingSeconds}s'
          : '${minutes}m';
    }
    return '${seconds}s';
  }

  String _formatRestTime(int seconds) {
    // Format più compatto per il badge del timer
    if (seconds >= 60) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      if (remainingSeconds == 0) {
        return '${minutes}m';
      } else if (remainingSeconds == 30) {
        return '$minutes:30';
      } else {
        return '${minutes}m${remainingSeconds}s';
      }
    }
    return '${seconds}s';
  }

  /// Get counting mode for current exercise
  ExerciseCountingMode _getCountingMode() {
    final mode = ExerciseCountingModeService.getModeFromWorkoutExercise(widget.exercise);
    // 🐛 DEBUG: Log counting mode (debug only, removed from production)
    // Uncomment if needed for debugging:
    // if (kDebugMode) {
    //   debugPrint('🎯 [_getCountingMode] Returning mode: ${mode.name} for ${widget.exercise.name}');
    // }
    return mode;
  }

  /// Build set details widgets based on counting mode
  List<Widget> _buildSetDetailsForMode(ExerciseSet set, AppConfig config) {
    final mode = _getCountingMode();

    switch (mode) {
      case ExerciseCountingMode.weighted:
        // Weighted: Show weight × reps
        return [
          if (set.weight != null) ...[
            Text(
              set.weight!.formatWeight(config.measurementUnit),
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            SizedBox(width: 4),
            Text('×', style: context.textTheme.bodySmall),
            SizedBox(width: 4),
          ],
          if (set.reps != null)
            Text(
              set.actualReps != null && set.isCompleted
                  ? '${set.actualReps}/${set.reps} reps'
                  : '${set.reps} reps',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
        ];

      case ExerciseCountingMode.reps:
        // Reps-only: Show reps only (bodyweight exercises)
        return [
          if (set.reps != null)
            Text(
              set.actualReps != null && set.isCompleted
                  ? '${set.actualReps}/${set.reps} reps'
                  : '${set.reps} reps',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
        ];

      case ExerciseCountingMode.time:
        // Time-based: Show duration (isometric exercises)
        // Note: For TIME exercises, duration is stored in 'reps' field
        return [
          if (set.reps != null)
            Text(
              '${set.reps}s',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          // Also show 'seconds' field if exists (for backward compatibility)
          if (set.seconds != null && set.reps == null)
            Text(
              '${set.seconds}s',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
        ];
    }
  }

  String _calculateAverageWeight() {
    final weightsWithValues = widget.exercise.sets
        .where((s) => s.weight != null && s.weight! > 0)
        .map((s) => s.weight!)
        .toList();

    if (weightsWithValues.isEmpty) return '0';

    final average =
        weightsWithValues.reduce((a, b) => a + b) / weightsWithValues.length;
    return average % 1 == 0
        ? average.toInt().toString()
        : average.toStringAsFixed(1);
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          SemanticIcon(
            icon: icon,
            semanticLabel: 'Icon',
            size: AppIconSize.small,
            color: color,
          )
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  void _showNotesEditor(BuildContext context) {
    final controller = TextEditingController(text: widget.exercise.notes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: context.mediaQuery.viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Exercise Notes', // TODO: Add localization
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Add notes for this exercise...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      final updated = widget.exercise.copyWith(
                        notes: controller.text,
                      );
                      widget.onExerciseUpdate?.call(updated);
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommunityAdvice(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommunityAdviceModal(exercise: widget.exercise),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: Text(
          'Are you sure you want to delete "${widget.exercise.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editSet(BuildContext context, ExerciseSet set) {
    if (widget.onSetUpdate == null) return;

    // Find previous set for APRE calculations
    ExerciseSet? previousSet;
    final currentSetIndex = widget.exercise.sets.indexWhere(
      (s) => s.id == set.id,
    );
    if (currentSetIndex > 0) {
      previousSet = widget.exercise.sets[currentSetIndex - 1];
    }

    context.showEditSetModal(
      set,
      widget.onSetUpdate!,
      exercise: widget.exercise,
      previousSet: previousSet,
    );
  }

  void _quickEditSet(BuildContext context, ExerciseSet set) {
    if (widget.onSetUpdate == null) return;

    // Get the position of the set item for the overlay
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    // Find the previous set for copying values
    ExerciseSet? previousSet;
    final currentSetIndex = widget.exercise.sets.indexWhere(
      (s) => s.id == set.id,
    );
    if (currentSetIndex > 0) {
      previousSet = widget.exercise.sets[currentSetIndex - 1];
    }

    // Get recent weights from completed sets
    List<double> recentWeights = [];
    for (final s in widget.exercise.sets) {
      if (s.weight != null && s.isCompleted) {
        if (!recentWeights.contains(s.weight)) {
          recentWeights.add(s.weight!);
        }
      }
    }
    recentWeights = recentWeights.take(3).toList(); // Max 3 recent weights

    // Calculate estimated 1RM from best set
    double? oneRepMax;
    for (final s in widget.exercise.sets) {
      if (s.weight != null && s.actualReps != null && s.actualReps! > 0) {
        // Epley formula: 1RM = weight × (1 + reps/30)
        final estimated1RM = s.weight! * (1 + s.actualReps! / 30);
        if (oneRepMax == null || estimated1RM > oneRepMax) {
          oneRepMax = estimated1RM;
        }
      }
    }

    // Haptic feedback for quick edit
    HapticFeedback.selectionClick();

    // Use V2 quick edit with superset support
    // ✅ FIX: Pass counting mode so quick edit shows correct fields (time/reps/weighted)
    context.showQuickEditOverlayV2(
      exerciseSet: set,
      onSave: widget.onSetUpdate!,
      position: position,
      previousSet: previousSet,
      countingMode: widget.exercise.countingMode, // ✅ Pass counting mode
    );
  }

  void _toggleSetCompletion(ExerciseSet set) {
    if (widget.onSetToggleComplete == null) return;

    final updatedSet = set.copyWith(isCompleted: !set.isCompleted);
    widget.onSetToggleComplete!(updatedSet);
  }

  void _toggleSetCompletionWithFeedback(BuildContext context, ExerciseSet set) {
    // Store the original state to determine what action was taken
    final wasCompleted = set.isCompleted;

    // Check if RPE tracking is enabled and if it's NOT a warmup set
    final config = ref.read(appConfigProvider);
    final rpeEnabled = config.rpeTracking ?? true; // Default to true
    final isWarmupSet = set.isWarmup;

    if (!wasCompleted) {
      // If RPE tracking is disabled OR it's a warmup set, complete directly
      if (!rpeEnabled || isWarmupSet) {
        debugPrint('🔥 Completing set ${set.setNumber} (warmup: $isWarmupSet)');
        double? duration;
        DateTime? existingStartTime;

        // Only track duration for non-warmup sets
        if (!isWarmupSet) {
          final durationTracker = ref.read(setDurationTrackerProvider);

          // Check if we have a start time for this set
          existingStartTime = durationTracker.getSetStartTime(
            widget.exercise.id,
            set.setNumber,
          );

          // If no start time, calculate one based on previous sets
          if (existingStartTime == null) {
            if (set.setNumber == 1) {
              // For first set, default to 30 seconds ago
              existingStartTime = DateTime.now().subtract(
                const Duration(seconds: 30),
              );
              durationTracker.setStartTime(
                widget.exercise.id,
                set.setNumber,
                existingStartTime,
              );
            } else {
              // For subsequent sets, use previous set completion time
              final previousSetIndex = set.setNumber - 2;
              if (previousSetIndex >= 0 &&
                  previousSetIndex < widget.exercise.sets.length) {
                final previousSet = widget.exercise.sets[previousSetIndex];
                if (previousSet.completedAt != null) {
                  existingStartTime = previousSet.completedAt!;
                  durationTracker.setStartTime(
                    widget.exercise.id,
                    set.setNumber,
                    existingStartTime,
                  );
                }
              }

              // Fallback to 30 seconds ago
              if (existingStartTime == null) {
                existingStartTime = DateTime.now().subtract(
                  const Duration(seconds: 30),
                );
                durationTracker.setStartTime(
                  widget.exercise.id,
                  set.setNumber,
                  existingStartTime,
                );
              }
            }
          }

          // Calculate duration
          duration = DateTime.now()
              .difference(existingStartTime)
              .inMilliseconds
              .toDouble();

          // Cap at 5 minutes max
          if (duration > 300000) {
            duration = 30000; // Default to 30 seconds
          }
        }

        // Update set with duration (null for warmup sets)
        // IMPORTANT: Preserve warmup flag
        final updatedSet = set.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
          setDurationMillis: isWarmupSet
              ? null
              : duration, // ✅ Salva durata esecuzione (null per warmup)
          setStartedAt: isWarmupSet
              ? null
              : existingStartTime, // ✅ Salva timestamp inizio (null per warmup)
          isWarmup: set.isWarmup, // Explicitly preserve warmup flag
        );

        debugPrint(
          '✅ Set completed: #${set.setNumber}, warmup: ${set.isWarmup}, preserved: ${updatedSet.isWarmup}',
        );

        widget.onSetToggleComplete!(updatedSet);

        // Haptic feedback for set completion (wrapped for safety)
        try {
          HapticFeedbackService.setCompletion(ref);
        } catch (e) {
          // Log error but don't block timer from starting
          if (kDebugMode) {
            debugPrint('Haptic feedback error: $e');
          }
        }

        // Start rest timer for next set (if not warmup)
        if (!isWarmupSet) {
          _startRestTimerWithSetInfo(context, updatedSet);
        }

        // Show feedback
        if (isWarmupSet) {
          SnackBarService.showCustom(
            context,
            message: '🔥 Warmup set ${set.setNumber} completed!',
            backgroundColor: context.warningColor,
          );
        } else {
          SnackBarService.showInfo(
            context,
            '✅ Set ${set.setNumber} completed!',
          );
        }
        return;
      }

      // Show RPE selector when completing a set
      final targetReps = set.reps ?? 10;

      RpeSelectorBottomSheet.show(
        context: context,
        set: set,
        targetReps: targetReps,
        exercise: widget.exercise, // Pass exercise for APRE and RPE checking
        onAPRESuggestion: (suggestedWeight) {
          // Handle APRE suggestion
          _handleAPRESuggestion(set, suggestedWeight);
        },
        onRPESuggestion: (suggestedWeight) {
          // Handle RPE autoregulation suggestion
          _handleRPESuggestion(suggestedWeight);
        },
        onConfirm: (actualReps, actualWeight, rpe) {
          final durationTracker = ref.read(setDurationTrackerProvider);

          // Check if we have a start time for this set
          var existingStartTime = durationTracker.getSetStartTime(
            widget.exercise.id,
            set.setNumber,
          );

          // If no start time exists, we need to handle different cases
          if (existingStartTime == null) {
            if (set.setNumber == 1) {
              // For the first set, if no start time exists, use the last completed set time
              // or a reasonable default (e.g., 30 seconds ago)
              final previousCompletedSet = widget.exercise.sets
                  .where(
                    (s) =>
                        s.isCompleted && s.completedAt != null && !s.isWarmup,
                  )
                  .lastOrNull;

              if (previousCompletedSet?.completedAt != null) {
                // Use time since last completed set
                existingStartTime = previousCompletedSet!.completedAt!;
              } else {
                // Default to 30 seconds ago for first set if not tracked
                existingStartTime = DateTime.now().subtract(
                  const Duration(seconds: 30),
                );
              }

              // Store this calculated start time
              durationTracker.setStartTime(
                widget.exercise.id,
                set.setNumber,
                existingStartTime,
              );
              if (kDebugMode) {
                debugPrint(
                  '⏱️ Set 1: Using calculated start time (30s ago or from last set)',
                );
              }
            } else {
              // For subsequent sets, the timer provider already called startSet when rest ended
              // Just retrieve the existing timestamp (don't call startSet again!)
              existingStartTime = durationTracker.getSetStartTime(
                widget.exercise.id,
                set.setNumber,
              );

              if (existingStartTime != null) {
                if (kDebugMode) {
                  debugPrint(
                    '⏱️ Set ${set.setNumber}: Using timer end timestamp: ${existingStartTime.toIso8601String()}',
                  );
                }
              } else {
                // Fallback: Timer didn't set it, use completion time of previous set
                final previousCompletedSet = widget.exercise.sets
                    .where(
                      (s) =>
                          s.isCompleted && s.completedAt != null && !s.isWarmup,
                    )
                    .lastOrNull;

                if (previousCompletedSet?.completedAt != null) {
                  existingStartTime = previousCompletedSet!.completedAt!;
                  if (kDebugMode) {
                    debugPrint(
                      '⚠️ Set ${set.setNumber}: Timer didn\'t set timestamp, using previous set completion',
                    );
                  }
                } else {
                  // Last resort: use 30s ago
                  existingStartTime = DateTime.now().subtract(
                    const Duration(seconds: 30),
                  );
                  if (kDebugMode) {
                    debugPrint(
                      '⚠️ Set ${set.setNumber}: No timer timestamp, using 30s default',
                    );
                  }
                }
              }
            }
          }

          // Calculate duration from set start to now
          double? duration;
          // Calculate duration from start time to now
          duration = DateTime.now()
              .difference(existingStartTime)
              .inMilliseconds
              .toDouble();

          // Sanity check - if duration is too long (> 5 minutes), use a default
          if (duration > 300000) {
            duration = 30000; // Default to 30 seconds
            if (kDebugMode) {
              debugPrint(
                '⚠️ Duration too long (${(duration / 1000).toStringAsFixed(2)}s), using default 30s',
              );
            }
          }

          if (kDebugMode) {
            debugPrint(
              '🕐 Set ${set.setNumber} duration: ${(duration / 1000).toStringAsFixed(2)}s',
            );
          }

          // Update set with RPE, actual reps/weight/time based on counting mode
          // ✅ NEW: For time-based exercises, actualReps contains total seconds
          // ✅ NEW: For reps-only exercises, actualReps contains reps and actualWeight is 0
          // ✅ NEW: For weighted exercises, both actualReps and actualWeight are used
          final countingMode = widget.exercise.countingMode;
          final updatedSet = set.copyWith(
            actualReps: countingMode == ExerciseCountingMode.time ? null : actualReps,
            seconds: countingMode == ExerciseCountingMode.time ? actualReps : null,
            rpe: rpe,
            weight: countingMode == ExerciseCountingMode.weighted ? actualWeight : null,
            isCompleted: true,
            completedAt: DateTime.now(),
            setDurationMillis: duration, // ✅ Salva durata esecuzione
            setStartedAt: existingStartTime, // ✅ Salva timestamp inizio
          );

          widget.onSetToggleComplete!(updatedSet);

          // Haptic feedback for set completion (wrapped for safety)
          try {
            HapticFeedbackService.setCompletion(ref);
          } catch (e) {
            // Log error but don't block timer from starting
            if (kDebugMode) {
              debugPrint('Haptic feedback error: $e');
            }
          }

          // Start rest timer (will always execute even if haptic fails)
          _startRestTimerWithSetInfo(context, updatedSet);

          // Mark next set as starting when rest timer ends
          final nextSetNumber = set.setNumber + 1;
          if (nextSetNumber <= widget.exercise.sets.length) {
            // The timer provider will call startSet() when it reaches 00:00
            // This marks the exact timestamp when rest ends as the start of the next set
            // Ensuring we measure ONLY execution time, NOT rest time
          }

          // Visual feedback with snackbar
          final rpeText = rpe > 0 ? ' (RPE $rpe)' : '';
          final message = '💪 Set ${set.setNumber} completed!$rpeText';

          SnackBarService.showInfo(context, message);
        },
      );
    } else {
      // Set already completed - show RPE selector to allow editing
      final targetReps = set.reps ?? 10;

      RpeSelectorBottomSheet.show(
        context: context,
        set: set,
        targetReps: targetReps,
        exercise: widget.exercise, // Pass exercise for APRE and RPE checking
        onAPRESuggestion: (suggestedWeight) {
          // Handle APRE suggestion
          _handleAPRESuggestion(set, suggestedWeight);
        },
        onRPESuggestion: (suggestedWeight) {
          // Handle RPE autoregulation suggestion
          _handleRPESuggestion(suggestedWeight);
        },
        onConfirm: (actualReps, actualWeight, rpe) {
          // ✅ NEW: Handle toggle state via rpe special codes
          // rpe = -1 → User toggled OFF completion (unmarca)
          // rpe = 0  → User skipped RPE but kept completion
          // rpe > 0  → Normal RPE value

          if (rpe == -1) {
            // ✅ User toggled OFF completion → unmarca set
            _toggleSetCompletion(set);
            SnackBarService.showInfo(
              context,
              '↩️ Set ${set.setNumber} marked as incomplete',
            );
          } else if (rpe == 0) {
            // ✅ User skipped RPE but kept completion → update without RPE
            final countingMode = widget.exercise.countingMode;
            final updatedSet = set.copyWith(
              actualReps: countingMode == ExerciseCountingMode.time ? null : actualReps,
              seconds: countingMode == ExerciseCountingMode.time ? actualReps : null,
              weight: countingMode == ExerciseCountingMode.weighted ? actualWeight : null,
              rpe: null, // Remove RPE if skipped
              isCompleted: true,
            );

            widget.onSetToggleComplete!(updatedSet);

            // Haptic feedback for set update
            try {
              HapticFeedbackService.setCompletion(ref);
            } catch (e) {
              if (kDebugMode) {
                debugPrint('Haptic feedback error: $e');
              }
            }

            SnackBarService.showInfo(
              context,
              '✅ Set ${set.setNumber} updated',
            );
          } else {
            // ✅ Normal RPE value → update set with RPE
            final countingMode = widget.exercise.countingMode;
            final updatedSet = set.copyWith(
              actualReps: countingMode == ExerciseCountingMode.time ? null : actualReps,
              seconds: countingMode == ExerciseCountingMode.time ? actualReps : null,
              weight: countingMode == ExerciseCountingMode.weighted ? actualWeight : null,
              rpe: rpe,
              isCompleted: true,
            );

            widget.onSetToggleComplete!(updatedSet);

            // Haptic feedback for set update (wrapped for safety)
            try {
              HapticFeedbackService.setCompletion(ref);
            } catch (e) {
              // Log error but continue with visual feedback
              if (kDebugMode) {
                debugPrint('Haptic feedback error: $e');
              }
            }

            // Visual feedback with snackbar
            final rpeText = ' (RPE $rpe updated)';
            final message = '💪 Set ${set.setNumber} updated!$rpeText';

            SnackBarService.showInfo(context, message);
          }
        },
      );
    }

    // Auto-collapse logic moved to didUpdateWidget for better timing
    // This ensures the widget has been rebuilt with updated data before checking
  }

  void _startRestTimer(BuildContext context) {
    final autoStartTimer = ref.read(appConfigProvider).autoRestTimer ?? true;

    // Only start timer if auto-start is enabled
    if (!autoStartTimer) return;

    // Find completed sets
    final completedSets = widget.exercise.sets
        .where((set) => set.isCompleted)
        .toList();
    if (completedSets.isEmpty) return;

    final totalSets = widget.exercise.sets.length;
    final completedSetCount = completedSets.length;

    // Don't start timer if this is the last set of the exercise
    if (completedSetCount >= totalSets) return;

    final lastSet = completedSets.last;
    final reps = lastSet.reps ?? 10; // Default to 10 if reps not set

    // Start smart rest timer based on rep range
    final timerActions = ref.read(tier1TimerActionsProvider);
    timerActions.startSmartRest(
      exerciseName: widget.exercise.name,
      reps: reps,
      currentSet: completedSetCount + 1, // Next set
      totalSets: totalSets,
    );
  }

  Color _getRpeIndicatorColor(int rpe) {
    if (rpe <= 6) return context.successColor;
    if (rpe <= 7) return context.successColor;
    if (rpe <= 8) return context.warningColor;
    if (rpe <= 9) return context.warningColor;
    return context.errorColor;
  }

  void _startRestTimerWithSetInfo(
    BuildContext context,
    ExerciseSet completedSet,
  ) {
    final autoStartTimer = ref.read(appConfigProvider).autoRestTimer ?? true;

    // Only start timer if auto-start is enabled
    if (!autoStartTimer) return;

    final totalSets = widget.exercise.sets.length;
    final currentSetNumber = completedSet.setNumber;

    // Don't start timer if this is the last set of the exercise
    if (currentSetNumber >= totalSets) return;

    final reps = completedSet.reps ?? 10; // Default to 10 if reps not set

    // Use exercise-specific rest time if set, otherwise use smart calculation
    final exerciseRestTime = widget.exercise.restTime;

    if (exerciseRestTime != null) {
      // Use exercise-specific timer
      final timerActions = ref.read(tier1TimerActionsProvider);
      timerActions.startExerciseRest(
        seconds: exerciseRestTime,
        exerciseName: widget.exercise.name,
        currentSet: currentSetNumber + 1,
        totalSets: totalSets,
        exerciseId: widget.exercise.id,
      );
    } else {
      // Use smart rest timer based on rep range
      final timerActions = ref.read(tier1TimerActionsProvider);
      timerActions.startSmartRest(
        exerciseName: widget.exercise.name,
        reps: reps,
        currentSet: currentSetNumber + 1, // Next set
        totalSets: totalSets,
        exerciseId: widget.exercise.id,
      );
    }
  }

  Widget _buildInsightChip(BuildContext context) {
    if (_lastActivity == null || _lastActivity!.sets.isEmpty) {
      return const SizedBox.shrink();
    }

    // Trova il peso massimo usato nell'ultimo allenamento
    double maxWeight = 0;
    int maxReps = 0;

    for (final set in _lastActivity!.sets) {
      if (set.done) {
        final weight = double.tryParse(set.weight.toString()) ?? 0;
        final reps = int.tryParse(set.reps.toString()) ?? 0;
        if (weight > maxWeight) {
          maxWeight = weight;
          maxReps = reps;
        }
      }
    }

    if (maxWeight == 0) return const SizedBox.shrink();

    final daysAgo = DateTime.now().difference(_lastActivity!.createdAt).inDays;
    final String timeAgo = daysAgo == 0
        ? 'Oggi'
        : daysAgo == 1
        ? 'Ieri'
        : '$daysAgo giorni fa';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          _showExerciseHistory(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0, end: 1),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Icon(
                      AppIcons.insights,
                      size: 14,
                      color: context.colors.primary,
                    ),
                  );
                },
              ),
              SizedBox(width: 4),
              Text(
                'Ultimo: ${maxWeight.toStringAsFixed(1)}kg x $maxReps ($timeAgo)',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              SemanticIcon(
                icon: AppIcons.chevronRight,
                semanticLabel: 'Chevronright',
                size: AppIconSize.tiny,
                color: context.colors.primary.withValues(alpha: 0.7,
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Execute DropSet exercise using the dedicated modal
  Future<void> _executeDropSet(DropSetExercise exercise) async {
    await DropSetExecutionModal.show(context: context, exercise: exercise);
  }

  /// Execute RestPause exercise using the execution sheet
  Future<void> _executeRestPause(RestPauseExercise exercise) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RestPauseExecutionSheet(
        restPause: exercise,
        setIndex: 0,
        onComplete: (weight, reps, rpe) {
          // Create updated RestPauseExercise with completed data
          // For each rep count, create a RestPauseSet entry
          final completedSets = <RestPauseSet>[
            for (int repCount in reps)
              RestPauseSet(
                reps: repCount,
                restSeconds: 15, // Default rest-pause rest time
                isCompleted: true,
              ),
          ];

          final updatedExercise = RestPauseExercise(
            id: exercise.id,
            name: exercise.name,
            category: exercise.category,
            weight: weight,
            targetReps: exercise.targetReps,
            restPauseSets: [
              ...exercise.restPauseSets,
              ...completedSets,
            ],
            notes: exercise.notes,
          );

          // Update workout provider with the completed exercise
          ref.read(currentWorkoutProvider.notifier)
              .updateExerciseOnly(updatedExercise);

          // Show success feedback
          HapticFeedback.mediumImpact();
          SnackBarService.showSuccess(
            context,
            '${exercise.name} Rest-Pause completed!',
          );
        },
      ),
    );
  }

  Future<void> _showExerciseHistory(BuildContext context) async {
    setState(() {
      _loadingHistory = true;
    });

    List<ExerciseActivity> activities = [];

    try {
      // NEW: Use workouts collection instead of exerciseActivities
      final service = ref.read(workoutHistoryServiceProvider);
      activities = await service.getActivitiesByExercise(
        userEmail: '', // Non più necessario con il nuovo sistema
        exerciseName: widget.exercise.name,
        limit: 10,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Errore caricamento storico: $e');
      }
      // Fallback: prova con il vecchio metodo se il nuovo fallisce
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser?.email != null) {
        final repository = ExerciseActivityRepository();
        activities = await repository.getActivitiesByExercise(
          userId: currentUser!.email!, // ⚠️ Parameter name is userId (expects user ID/email string)
          exerciseName: widget.exercise.name,
          limit: 10,
        );
      }
    }

    setState(() {
      _loadingHistory = false;
    });

    if (!mounted) return;

    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(AppIcons.history, color: context.colors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Storico: ${widget.exercise.name}',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ultimi ${activities.length} allenamenti',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Content
              Expanded(
                child: activities.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SemanticIcon(
                              icon: AppIcons.workout,
                              semanticLabel: 'Workout',
                              size: AppIconSize.medium,
                              color: context.colors.outline,
                            )
                            SizedBox(height: 16),
                            Text(
                              'Nessun allenamento precedente',
                              style: context.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: activities.length,
                        itemBuilder: (context, index) {
                          final activity = activities[index];
                          return _buildHistoryCard(context, activity);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, ExerciseActivity activity) {
    final date = activity.createdAt;
    final formattedDate = '${date.day}/${date.month}/${date.year}';

    // Calcola statistiche
    double maxWeight = 0;
    int totalSets = 0;
    int totalReps = 0;
    double totalVolume = 0;

    for (final set in activity.sets) {
      if (set.done) {
        final weight = double.tryParse(set.weight.toString()) ?? 0;
        final reps = int.tryParse(set.reps.toString()) ?? 0;

        if (weight > maxWeight) maxWeight = weight;
        totalSets++;
        totalReps += reps;
        totalVolume += weight * reps;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (activity.schedaName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.secondaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      activity.schedaName,
                      style: context.textTheme.labelSmall,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Statistiche riassuntive
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Serie', '$totalSets'),
                _buildStatItem(
                  context,
                  'Max',
                  '${maxWeight.toStringAsFixed(1)}kg',
                ),
                _buildStatItem(context, 'Reps Tot', '$totalReps'),
                _buildStatItem(
                  context,
                  'Volume',
                  '${totalVolume.toStringAsFixed(0)}kg',
                ),
              ],
            ),

            SizedBox(height: 12),

            // Dettaglio serie
            ExpansionTile(
              title: Text(
                'Dettaglio serie',
                style: context.textTheme.bodyMedium,
              ),
              children: activity.sets.where((s) => s.done).map((set) {
                final weight = double.tryParse(set.weight.toString()) ?? 0;
                final reps = int.tryParse(set.reps.toString()) ?? 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.primaryContainer,
                        ),
                        child: Center(
                          child: Text(
                            '${activity.sets.indexOf(set) + 1}',
                            style: context.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '${weight.toStringAsFixed(1)}kg x $reps',
                        style: context.textTheme.bodyMedium,
                      ),
                      if (set.effort > 0) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getEffortColorByNumber(
                              set.effort,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8), // Standard border radius (design system)
                          ),
                          child: Text(
                            'RPE ${set.effort}',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: _getEffortColorByNumber(set.effort),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getEffortColor(String effort) {
    switch (effort.toLowerCase()) {
      case 'easy':
        return context.successColor;
      case 'medium':
        return context.warningColor;
      case 'hard':
        return context.errorColor;
      default:
        return context.colors.outline;
    }
  }

  Color _getEffortColorByNumber(int effort) {
    if (effort <= 6) {
      return context.successColor;
    } else if (effort <= 8) {
      return context.warningColor;
    } else {
      return context.errorColor;
    }
  }

  void _editExercise(BuildContext context) {
    if (widget.onExerciseUpdate == null) return;

    context.showEditExerciseModal(widget.exercise, widget.onExerciseUpdate!);
  }

  void _showAutoAdjustmentModal(BuildContext context) async {
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

  // Load exercise data from JSON with Community Corrections merged
  Future<Map<String, dynamic>?> _loadExerciseDataFromJson() async {
    try {
      // Prima prova a caricare i dati merged con correzioni community
      final mergedData = await ref.read(
        exerciseDataProvider(widget.exercise.name).future,
      );

      if (mergedData.isNotEmpty) {
        // Se ci sono correzioni community, mostra un indicatore
        if (mergedData['hasCommunityCorrections'] == true) {
          if (kDebugMode) {
            debugPrint(
              '✅ Using community-corrected data for ${widget.exercise.name}',
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

    // Fallback: carica solo dal JSON se il provider fallisce
    // Safety check dopo operazioni async
    if (!mounted) return null;

    try {
      // ✅ USA REF invece di context per evitare problemi con async gap
      final config = ref.read(appConfigProvider);
      final isItalian = config.languageCode == 'it';
      final jsonFile = isItalian
          ? 'assets/data/exercises_it.json'
          : 'assets/data/exercises.json';

      if (kDebugMode) {
        debugPrint(
          '📚 Loading exercise data from: $jsonFile (locale: ${config.languageCode})',
        );
      }

      final String jsonString = await rootBundle.loadString(jsonFile);
      final List<dynamic> exercises = json.decode(jsonString);

      // Search for exercise by name (case insensitive)
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

  // Check if exercise has warmup data
  bool _hasWarmupData(Map<String, dynamic> data) {
    return data['mobilitaPre'] != null ||
        data['attivazionePre'] != null ||
        data['warmupSets'] != null ||
        data['tempoWarmup'] != null;
  }

  // Check if exercise has injury prevention data
  bool _hasInjuryPreventionData(Map<String, dynamic> data) {
    return data['prevenzioneInfortuni'] != null ||
        data['cooldownConsigliato'] != null ||
        data['drillTecnico'] != null ||
        data['noteTecniche'] != null;
  }

  // Build interactive chip widget
  Widget _buildInteractiveChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.08)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SemanticIcon(
                icon: icon,
                semanticLabel: 'Icon',
                size: AppIconSize.tiny,
                color: color,
              )
              const SizedBox(width: 6),
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show warmup modal
  void _showWarmupModal(BuildContext context, Map<String, dynamic> data) {
    final groups = <_GroupedModalSection>[];

    // Group 1: Preparation (Mobility + Activation)
    final preparationItems = <_ModalItem>[];
    if (data['mobilitaPre'] != null) {
      preparationItems.add(
        _ModalItem(
          label: context.l10n.preWorkoutMobility,
          value: data['mobilitaPre'],
          icon: AppIcons.accessibility,
        ),
      );
    }
    if (data['attivazionePre'] != null) {
      preparationItems.add(
        _ModalItem(
          label: context.l10n.muscleActivation,
          value: data['attivazionePre'],
          icon: AppIcons.flashOn,
        ),
      );
    }
    if (preparationItems.isNotEmpty) {
      groups.add(
        _GroupedModalSection(
          groupTitle: context.l10n.preparation,
          groupIcon: AppIcons.accessibility,
          items: preparationItems,
          accentColor: context.warningColor,
        ),
      );
    }

    // Group 2: Specific Warmup (Sets + Duration)
    final warmupItems = <_ModalItem>[];
    if (data['warmupSets'] != null) {
      warmupItems.add(
        _ModalItem(
          label: context.l10n.warmupSets,
          value: data['warmupSets'].toString(),
          icon: AppIcons.workout,
        ),
      );
    }
    if (data['tempoWarmup'] != null) {
      warmupItems.add(
        _ModalItem(
          label: context.l10n.warmupDuration,
          value: data['tempoWarmup'],
          icon: AppIcons.timer,
        ),
      );
    }
    if (warmupItems.isNotEmpty) {
      groups.add(
        _GroupedModalSection(
          groupTitle: context.l10n.specificWarmup,
          groupIcon: AppIcons.whatshot,
          items: warmupItems,
          accentColor: context.warningColor,
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGroupedPremiumModal(
        context: context,
        title: context.l10n.warmupAndMobility,
        icon: AppIcons.whatshot,
        color: context.warningColor,
        groups: groups,
        onCorrection: () {
          Navigator.pop(context);
          _openContributionModal(
            ContributionType.correction,
            contextType: 'warmup',
          );
        },
        onAddTip: () {
          Navigator.pop(context);
          _openContributionModal(ContributionType.tip, contextType: 'warmup');
        },
      ),
    );
  }

  // Show exercise info modal
  void _showExerciseInfoModal(BuildContext context, Map<String, dynamic> data) {
    final groups = <_GroupedModalSection>[];

    // Group 1: Target Muscles
    final muscleItems = <_ModalItem>[];
    if (data['focus'] != null) {
      muscleItems.add(
        _ModalItem(
          label: context.l10n.primaryMuscles,
          value: data['focus'],
          icon: AppIcons.workout,
        ),
      );
    }
    if (data['muscoliSecondari'] != null) {
      muscleItems.add(
        _ModalItem(
          label: context.l10n.secondaryMuscles,
          value: data['muscoliSecondari'],
          icon: AppIcons.sportsGymnastics,
        ),
      );
    }
    if (muscleItems.isNotEmpty) {
      groups.add(
        _GroupedModalSection(
          groupTitle: context.l10n.targetMuscles,
          groupIcon: AppIcons.workout,
          items: muscleItems,
          accentColor: context.colors.primary,
        ),
      );
    }

    // Group 2: Exercise Details
    final detailItems = <_ModalItem>[];
    if (data['difficolta'] != null) {
      detailItems.add(
        _ModalItem(
          label: context.l10n.difficultyLevel,
          value: data['difficolta'],
          icon: AppIcons.trendUp,
        ),
      );
    }
    if (data['tipoEsercizio'] != null) {
      detailItems.add(
        _ModalItem(
          label: context.l10n.exerciseType,
          value: data['tipoEsercizio'],
          icon: AppIcons.category,
        ),
      );
    }
    if (data['attrezzatura'] != null) {
      detailItems.add(
        _ModalItem(
          label: context.l10n.equipment,
          value: data['attrezzatura'],
          icon: AppIcons.build,
        ),
      );
    }
    if (data['patternMovimento'] != null) {
      detailItems.add(
        _ModalItem(
          label: context.l10n.movementPattern,
          value: data['patternMovimento'],
          icon: AppIcons.repeat,
        ),
      );
    }
    if (detailItems.isNotEmpty) {
      groups.add(
        _GroupedModalSection(
          groupTitle: context.l10n.exerciseDetails,
          groupIcon: AppIcons.info,
          items: detailItems,
          accentColor: context.infoColor,
        ),
      );
    }

    // Group 3: Rep Range (standalone)
    if (data['rangeRipetizioni'] != null) {
      groups.add(
        _GroupedModalSection(
          groupTitle: context.l10n.repRange,
          groupIcon: AppIcons.formatListNumbered,
          items: [_ModalItem(label: '', value: data['rangeRipetizioni'])],
          accentColor: context.colors.primary,
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGroupedPremiumModal(
        context: context,
        title: context.l10n.exerciseInformation,
        icon: AppIcons.info,
        color: context.colors.primary,
        groups: groups,
        onCorrection: () {
          Navigator.pop(context);
          _openContributionModal(
            ContributionType.correction,
            contextType: 'exercise_info',
          );
        },
        onAddTip: () {
          Navigator.pop(context);
          _openContributionModal(
            ContributionType.tip,
            contextType: 'exercise_info',
          );
        },
      ),
    );
  }

  // Show injury prevention modal
  void _showInjuryPreventionModal(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final groups = <_GroupedModalSection>[];

    // Group 1: Safety & Technique (Prevention + Technical Notes + Drills)
    final safetyItems = <_ModalItem>[];
    if (data['prevenzioneInfortuni'] != null) {
      safetyItems.add(
        _ModalItem(
          label: context.l10n.injuryPrevention,
          value: data['prevenzioneInfortuni'],
          icon: AppIcons.shield,
        ),
      );
    }
    if (data['noteTecniche'] != null) {
      safetyItems.add(
        _ModalItem(
          label: context.l10n.technicalNotes,
          value: data['noteTecniche'],
          icon: AppIcons.note,
        ),
      );
    }
    if (data['drillTecnico'] != null) {
      safetyItems.add(
        _ModalItem(
          label: context.l10n.technicalDrills,
          value: data['drillTecnico'],
          icon: AppIcons.sports,
        ),
      );
    }
    if (safetyItems.isNotEmpty) {
      groups.add(
        _GroupedModalSection(
          groupTitle: context.l10n.safetyAndTechnique,
          groupIcon: AppIcons.healthAndSafety,
          items: safetyItems,
          accentColor: context.errorColor,
        ),
      );
    }

    // Group 2: Recovery (Cooldown standalone)
    if (data['cooldownConsigliato'] != null) {
      groups.add(
        _GroupedModalSection(
          groupTitle: context.l10n.recovery,
          groupIcon: AppIcons.acUnit,
          items: [
            _ModalItem(
              label: context.l10n.recommendedCooldown,
              value: data['cooldownConsigliato'],
              icon: AppIcons.acUnit,
            ),
          ],
          accentColor: context.colors.tertiary,
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGroupedPremiumModal(
        context: context,
        title: context.l10n.safetyAndPrevention,
        icon: AppIcons.healthAndSafety,
        color: context.errorColor,
        groups: groups,
        onCorrection: () {
          Navigator.pop(context);
          _openContributionModal(
            ContributionType.correction,
            contextType: 'injury_prevention',
          );
        },
        onAddTip: () {
          Navigator.pop(context);
          _openContributionModal(
            ContributionType.warning,
            contextType: 'injury_prevention',
          );
        },
      ),
    );
  }

  // Helper to format step text for better readability
  String _formatStepText(String text) {
    // Se il testo contiene " | ", lo dividiamo per gli step
    if (text.contains(' | ')) {
      return text.split(' | ').join('\n\n');
    }
    return text;
  }

  // Build grouped premium modal
  Widget _buildGroupedPremiumModal({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<_GroupedModalSection> groups,
    VoidCallback? onCorrection,
    VoidCallback? onAddTip,
  }) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.colors.surface,
              context.colors.surface.withValues(alpha: 0.98),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: context.colors.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.2),
                          color.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.exercise.name,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(AppIcons.close, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Content with grouped sections
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ...groups.map(
                    (group) => Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.colors.surfaceContainerHighest.withOpacity(
                              0.3,
                            ),
                            context.colors.surfaceContainerHighest.withOpacity(
                              0.1,
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.colors.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Group header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (group.accentColor ?? context.colors.primary)
                                      .withValues(alpha: 0.08),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  group.groupIcon,
                                  size: 20,
                                  color:
                                      group.accentColor ??
                                      context.colors.primary,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  group.groupTitle,
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            group.accentColor ??
                                            context.colors.primary,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          // Group items
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: group.items.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final item = entry.value;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (index > 0)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Divider(
                                          color: context.colors.outline
                                              .withValues(alpha: 0.1),
                                          height: 1,
                                        ),
                                      ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (item.icon != null) ...[
                                          Icon(
                                            item.icon,
                                            size: 16,
                                            color:
                                                context.colors.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.label,
                                                style: context
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: context
                                                          .colors
                                                          .onSurfaceVariant,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatStepText(item.value),
                                                style: context
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(height: 1.4),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            // Context-aware contribution buttons
            if (onCorrection != null || onAddTip != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  border: Border(
                    top: BorderSide(
                      color: context.colors.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (onCorrection != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onCorrection,
                          icon: const Icon(AppIcons.editNote, size: 18),
                          label: const Text('Correggi info'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                          ),
                        ),
                      ),
                    if (onCorrection != null && onAddTip != null)
                      SizedBox(width: 12),
                    if (onAddTip != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onAddTip,
                          icon: Icon(AppIcons.tip, size: 18),
                          label: Text('Aggiungi tip'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            foregroundColor: context.colors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Build premium modal (old version kept for compatibility)
  Widget _buildPremiumModal({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<_ModalSection> sections,
  }) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.colors.surface,
              context.colors.surface.withValues(alpha: 0.98),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: context.colors.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.2),
                          color.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.exercise.name,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(AppIcons.close, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ...sections.map(
                    (section) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.colors.surfaceContainerHighest.withOpacity(
                              0.3,
                            ),
                            context.colors.surfaceContainerHighest.withOpacity(
                              0.1,
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.colors.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  section.icon,
                                  size: 20,
                                  color: context.colors.primary,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  section.title,
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              section.content,
                              style: context.textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTutExplanationModal(BuildContext context) {
    final tutText = widget.exercise.tut ?? _getDefaultTut();
    showTutInfoBottomSheet(context, tutText);
  }
}

// Helper class for modal sections
class _ModalSection {
  const _ModalSection({
    required this.title,
    required this.content,
    required this.icon,
  });
  final String title;
  final String content;
  final IconData icon;
}

// Helper class for grouped modal sections
class _GroupedModalSection {
  const _GroupedModalSection({
    required this.groupTitle,
    required this.groupIcon,
    required this.items,
    this.accentColor,
  });
  final String groupTitle;
  final IconData groupIcon;
  final List<_ModalItem> items;
  final Color? accentColor;
}

// Individual item within a grouped section
class _ModalItem {
  const _ModalItem({required this.label, required this.value, this.icon});
  final String label;
  final String value;
  final IconData? icon;
}

// Extension methods for ExerciseListItem
extension _ExerciseListItemHelpers on _ExerciseListItemState {
  bool _shouldShowWarmupSuggestion() {
    // Use .select() to watch only warmupSuggestions, not entire config
    final warmupSuggestionsEnabled = ref.watch(
      appConfigProvider.select((config) => config.warmupSuggestions ?? true),
    );

    // Check if warmup suggestions are enabled
    if (!warmupSuggestionsEnabled) return false;

    // Don't show if already dismissed
    if (_warmupSuggestionDismissed) return false;

    // Don't show if there are no sets
    if (widget.exercise.sets.isEmpty) return false;

    // Don't show if there are already warmup sets
    if (widget.exercise.sets.any((s) => s.isWarmup)) return false;

    // Check if it's a compound exercise or heavy enough
    final maxWeight = _getMaxWorkingWeight();
    if (maxWeight < 40) return false; // Too light for warmup

    // Check exercise type (compound movements need warmup)
    final exerciseLower = widget.exercise.name.toLowerCase();
    final isCompound =
        exerciseLower.contains('squat') ||
        exerciseLower.contains('bench') ||
        exerciseLower.contains('deadlift') ||
        exerciseLower.contains('press') ||
        exerciseLower.contains('row') ||
        exerciseLower.contains('pull');

    return isCompound || maxWeight >= 60;
  }

  double _getMaxWorkingWeight() {
    if (widget.exercise.sets.isEmpty) return 0;

    double maxWeight = 0;
    for (final set in widget.exercise.sets) {
      if (!set.isWarmup && set.weight != null && set.weight! > maxWeight) {
        maxWeight = set.weight!;
      }
    }
    return maxWeight;
  }

  int _getTargetReps() {
    if (widget.exercise.sets.isEmpty) return 8;

    // Get the average reps from non-warmup sets
    final workingSets = widget.exercise.sets.where(
      (s) => !s.isWarmup && s.reps != null,
    );
    if (workingSets.isEmpty) return 8;

    final totalReps = workingSets.fold(0, (sum, set) => sum + set.reps!);
    return (totalReps / workingSets.length).round();
  }

  void _addWarmupSets(List<ExerciseSet> warmupSets) {
    if (widget.onExerciseUpdate == null) return;

    // Add warmup sets at the beginning with proper numbering
    final updatedSets = <ExerciseSet>[];

    // Add warmup sets with correct numbering and warmup flag
    for (var i = 0; i < warmupSets.length; i++) {
      updatedSets.add(
        warmupSets[i].copyWith(
          setNumber: i + 1,
          isWarmup: true, // Ensure warmup flag is set
        ),
      );
    }

    debugPrint('🔥 Adding ${warmupSets.length} warmup sets');

    // Renumber existing sets
    for (var i = 0; i < widget.exercise.sets.length; i++) {
      updatedSets.add(
        widget.exercise.sets[i].copyWith(setNumber: updatedSets.length + 1),
      );
    }

    final updatedExercise = widget.exercise.copyWith(sets: updatedSets);

    widget.onExerciseUpdate!(updatedExercise);

    setState(() {
      _warmupSuggestionDismissed = true;
    });
  }

  /// Builds collapsible metadata banner for APRE calculations
  Widget _buildMetadataBanner(BuildContext context) {
    final calculations = _parseCalculationMetadata();

    // Don't show banner if no calculations available
    if (calculations == null) return const SizedBox.shrink();

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        children: [
          SizedBox(height: 12),
          // Collapsible header
          InkWell(
            onTap: () {
              setState(() {
                _showMetadataBanner = !_showMetadataBanner;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.expandLess,
                    semanticLabel: 'Collapse',
                    size: AppIconSize.small,
                    color: context.colors.primary,
                  )
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _showMetadataBanner
                          ? context.l10n.apreHideCalculationDetails
                          : context.l10n.apreShowCalculationDetails,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SemanticIcon(
                    icon: AppIcons.info,
                    semanticLabel: 'Information',
                    size: AppIconSize.small,
                    color: context.colors.primary,
                  )
                ],
              ),
            ),
          ),
          // Expanded metadata details
          if (_showMetadataBanner) ...[
            const SizedBox(height: 8),
            CalculationMetadataDisplay(
              calculations: calculations,
              lastCalculationDate: widget.exercise.lastCalculationDate,
            ),
          ],
        ],
      ),
    );
  }

  /// Parses calculation metadata from JSON string
  Map<String, dynamic>? _parseCalculationMetadata() {
    if (widget.exercise.calculationMetadata == null) return null;

    try {
      final decoded = jsonDecode(widget.exercise.calculationMetadata!);
      // Convert to expected format for CalculationMetadataDisplay
      return {
        'confidence': _parseConfidence(decoded['confidence']),
        'dataPoints': decoded['dataPoints'] ?? 0,
        'formula': decoded['formula'] ?? 'Brzycki',
        'dataAge': Duration(days: decoded['dataAge']?['inDays'] ?? 0),
        'standardDeviation': decoded['standardDeviation']?.toDouble() ?? 0.0,
      };
    } catch (e) {
      debugPrint('⚠️ Error parsing calculation metadata: $e');
      return null;
    }
  }

  /// Parses confidence string to enum
  CalculationConfidence _parseConfidence(dynamic confidence) {
    if (confidence == null) return CalculationConfidence.unknown;
    if (confidence is CalculationConfidence) return confidence;

    final confStr = confidence.toString().toLowerCase();
    switch (confStr) {
      case 'veryhigh':
        return CalculationConfidence.veryHigh;
      case 'high':
        return CalculationConfidence.high;
      case 'medium':
        return CalculationConfidence.medium;
      case 'low':
        return CalculationConfidence.low;
      default:
        return CalculationConfidence.unknown;
    }
  }
}

// Premium Success Dialog Widget
