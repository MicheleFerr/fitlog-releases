import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/draggable_action_button.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart'
    as wt;
import 'package:gymbro_flutter_new/features/workout/domain/entities/pdf_detail_level.dart';
import 'package:gymbro_flutter_new/features/workout/services/pdf_template_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_weight_prefill_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/pdf_preferences_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/add_exercise_modal.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/exercise_search_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/pdf_export_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/scheduling/presentation/widgets/schedule_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/edit_template_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/workout_templates_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_customization_modal_v3.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/minimal_set_edit_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rpe_selector_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/utils/exercise_replacement_utils.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/workout_tutorial_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_template_cache_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/watch_connectivity_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/workout/services/workout_share_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/warmup_calculator_service.dart';

// Sub-component imports
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen/widgets/welcome_view.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen/widgets/preloaded_view.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen/widgets/workout_view.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen/controllers/workout_screen_controller.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/utils/template_error_localizer.dart';

/// Orchestrator for WorkoutScreen that delegates to sub-components.
///
/// This is the main entry point for the workout screen, replacing the
/// monolithic implementation with a clean orchestrator pattern.
///
/// **Architecture**:
/// - **WelcomeView**: Empty/no workout state
/// - **PreloadedView**: Workout suggested but not started
/// - **WorkoutView**: Active workout
/// - **WorkoutScreenController**: Business logic
///
/// **Features**:
/// - Conditional AppBar actions (complete, settings)
/// - FAB behavior (ExpandableFAB vs done button)
/// - Timer overlay (Tier1MinimalTimerOverlay)
/// - Lifecycle management (auto-save on background)
/// - Onboarding overlays (contextual overlay manager)
class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({
    super.key,
    this.initialTemplateId,
    this.sessionId,
    this.fromSmartCTA = false,
    this.freeWorkoutTrigger,
  });

  /// Optional template ID to pre-load when opening the screen
  final String? initialTemplateId;

  /// Session ID for analytics correlation
  final String? sessionId;

  /// Whether this screen was opened from the Smart CTA
  final bool fromSmartCTA;

  /// One-shot trigger used to start a free workout when arriving from Home.
  final String? freeWorkoutTrigger;

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with WidgetsBindingObserver {
  static const String _reorderHintShownPrefKey =
      'workout_long_press_reorder_hint_shown_v1';
  static const int _tutorialTargetMaxRetries = 6;

  // GlobalKeys for contextual overlays and tutorial targets
  final GlobalKey _addExerciseFABKey = GlobalKey();
  final GlobalKey _completeWorkoutButtonKey = GlobalKey();
  final GlobalKey _firstSetRowKey = GlobalKey();
  final GlobalKey _exerciseMenuKey = GlobalKey();
  final GlobalKey _workoutOptionsMenuKey = GlobalKey();
  final GlobalKey _addExerciseModalBrowseKey = GlobalKey();
  final GlobalKey _addExerciseModalFiltersCustomKey = GlobalKey();
  String? _lastConsumedFreeWorkoutTrigger;
  bool _startingFreeWorkout = false;
  Future<void> Function()? _openDatabaseFromTutorialAction;
  bool _reorderHintShownInSession = false;
  bool _reorderHintCheckInProgress = false;

  /// Map of tutorial step keys for the WorkoutTutorialService
  Map<WorkoutTutorialStep, GlobalKey> get _tutorialTargetKeys => {
    WorkoutTutorialStep.welcome: _addExerciseFABKey,
    WorkoutTutorialStep.addExercise: _addExerciseFABKey,
    WorkoutTutorialStep.browseDatabase: _addExerciseModalBrowseKey,
    WorkoutTutorialStep.workoutSettings: _workoutOptionsMenuKey,
    WorkoutTutorialStep.editSetGestures: _firstSetRowKey,
    WorkoutTutorialStep.completeSetRpe: _firstSetRowKey,
  };

  @override
  void initState() {
    super.initState();

    // Preload interstitial ad for workout completion
    ref.read(workoutScreenControllerProvider.notifier).preloadCompletionAd();

    // EDGE CASE FIX: Add lifecycle observer for tutorial re-show on app resume
    // NOTE: Other lifecycle handling (emergency save, draft recovery) is in AppLifecycleManager
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _consumeFreeWorkoutTriggerIfNeeded();
      _showFirstWorkoutWelcomeIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant WorkoutScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.freeWorkoutTrigger != widget.freeWorkoutTrigger) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _consumeFreeWorkoutTriggerIfNeeded();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // EDGE CASE FIX: Re-show tutorial overlay when app returns from background
    // This handles the "distracted user" who gets interrupted by a phone call
    if (state == AppLifecycleState.resumed) {
      final tutorialState = ref.read(workoutTutorialProvider);

      // BUG FIX: Don't re-show tutorial if:
      // - User has already completed it
      if (tutorialState.isActive &&
          !tutorialState.hasCompletedTutorial &&
          mounted) {
        // Re-show the current tutorial step after UI settles
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _showCurrentTutorialStep();
        });
      }
    }
  }

  // NOTE: _checkAndRecoverDraft REMOVED - handled centrally by AppLifecycleManager
  // Draft recovery now happens globally on app startup via AppLifecycleManager._checkAndRecoverDraftGlobally()

  // NOTE: dispose() with removeObserver REMOVED - no observer to remove
  // NOTE: didChangeAppLifecycleState REMOVED - handled centrally by AppLifecycleManager
  // AppLifecycleManager handles:
  // - Emergency save current workout
  // - Force save template cache
  // - Schedule workout forgotten notification
  // - Draft recovery on app startup

  /// Auto-start spotlight tutorial for new users
  ///
  /// Shows the interactive tutorial that highlights UI elements
  /// step by step, teaching users how to use the workout screen.
  Future<void> _showFirstWorkoutWelcomeIfNeeded() async {
    if (!mounted) return;

    if (_startingFreeWorkout || _lastConsumedFreeWorkoutTrigger != null) {
      return;
    }

    // ✅ FIX: Wait for tutorial state to be loaded from SharedPreferences
    // This prevents race condition where tutorial starts before prefs are loaded
    await ref.read(workoutTutorialProvider.notifier).waitForLoad();

    if (!mounted) return;

    // Wait a bit for UI to settle and for template to load exercises
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final tutorialState = ref.read(workoutTutorialProvider);
    final currentWorkout = ref.read(currentWorkoutProvider);

    // Check if workout has exercises (either added manually or from template)
    final hasExercises =
        currentWorkout != null && currentWorkout.exercises.isNotEmpty;
    final isFromTemplate = currentWorkout?.templateId != null;

    // FIX: If tutorial is active but workout has exercises (e.g., loaded from template),
    // stop the tutorial to avoid showing it over content
    if (tutorialState.isActive && (hasExercises || isFromTemplate)) {
      if (kDebugMode) {
        debugPrint(
          '📚 [Tutorial] Stopping active tutorial - hasExercises: $hasExercises, fromTemplate: $isFromTemplate',
        );
      }
      ref.read(workoutTutorialProvider.notifier).stopTutorial();
      return;
    }

    // If tutorial is already active, re-show the current step instead of bailing out.
    if (tutorialState.isActive && !tutorialState.hasCompletedTutorial) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _showCurrentTutorialStep();
      });
      return;
    }

    // Early exit only if already started in the past but not active now.
    if (tutorialState.hasStartedTutorial) {
      return;
    }

    // Start spotlight tutorial if:
    // 1. Tutorial not started yet (first time)
    // 2. Tutorial not currently active
    // 3. Workout has no exercises yet (empty state - good time to learn)
    // 4. Workout is not from a template (templates have pre-defined exercises)
    // Note: Once tutorial is started, it won't auto-show again even if dismissed
    // User can manually restart it from settings menu
    if (hasExercises || isFromTemplate) {
      if (kDebugMode) {
        debugPrint(
          '📚 [Tutorial] Skipping - hasExercises: $hasExercises, fromTemplate: $isFromTemplate',
        );
      }
      return;
    }

    if (mounted) {
      await _startWorkoutTutorial();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ PERFORMANCE FIX: Use select() to only rebuild when exercises change
    // Previously watched full workout object, causing rebuild on EVERY change
    // (including updatedAt timestamp changes that don't affect UI)
    // Now only rebuilds when: status, exercises list, name, or data changes
    // ✅ FIX: Added updatedAt to detect Watch target modifications
    final currentWorkout = ref.watch(
      currentWorkoutProvider.select(
        (workout) => workout == null
            ? null
            : (
                id: workout.id,
                name: workout.name,
                status: workout.status,
                exercises: workout.exercises,
                isActive: workout.isActive,
                startTime: workout.startTime,
                updatedAt:
                    workout.updatedAt, // ✅ FIX: Detect data changes from Watch
              ),
      ),
    );

    // Convert back to Workout for downstream widgets
    // This is a lightweight operation since we're just reading from provider
    final fullWorkout = ref.read(currentWorkoutProvider);

    final controllerState = ref.watch(workoutScreenControllerProvider);

    // Determine which view to show
    // Note: paused workouts should show WorkoutView (not PreloadedView)
    final isActiveOrPaused =
        currentWorkout != null &&
        (currentWorkout.status == WorkoutStatus.inProgress ||
            currentWorkout.status == WorkoutStatus.paused);
    final isPreloaded = currentWorkout != null && !isActiveOrPaused;
    final isActive = isActiveOrPaused;
    final isEmpty = currentWorkout == null;

    // Debug logging for workout status determination
    if (kDebugMode) {
      debugPrint('🏋️ [WorkoutScreen] Build called:');
      debugPrint('  - currentWorkout: ${currentWorkout?.name ?? "null"}');
      debugPrint('  - status: ${currentWorkout?.status}');
      debugPrint('  - isActiveOrPaused: $isActiveOrPaused');
      debugPrint('  - isPreloaded: $isPreloaded');
      debugPrint('  - isActive: $isActive');
      debugPrint('  - isEmpty: $isEmpty');
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackNavigation(context);
        }
      },
      child: Stack(
        children: [
          // Main content based on state
          // ✅ Use fullWorkout (from ref.read) for passing to child widgets
          // The select() above ensures we only rebuild when meaningful changes occur
          if (isEmpty) _buildWelcomeView(),
          if (isPreloaded && fullWorkout != null)
            _buildPreloadedView(fullWorkout),
          if (isActive && fullWorkout != null)
            _buildWorkoutView(fullWorkout, controllerState),

          // Timer overlay - COMMENTED OUT: timer now in header
          // if (shouldShowTimer)
          //   const Tier1MinimalTimerOverlay(),

          // FAB for adding exercises (show in both active AND preloaded states)
          // Hidden when a bottom sheet is open (FAB is above Scaffold overlay layer)
          if ((isActive || isPreloaded) && !controllerState.isReorderMode)
            ValueListenableBuilder<int>(
              valueListenable: ModalService.openSheetCount,
              builder: (context, sheetCount, child) {
                if (sheetCount > 0) return const SizedBox.shrink();
                return child!;
              },
              child: _buildDraggableFAB(),
            ),
        ],
      ),
    );
  }

  /// Build welcome/empty state view
  Widget _buildWelcomeView() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: WelcomeView(
        onStartFreeWorkout: () => _startFreeWorkout(context),
        onStartTemplate: (template) => _startTemplateWorkout(template),
        onShareTemplate: (template) => _shareTemplatePdf(context, template),
        onDuplicateTemplate: (template) =>
            _duplicateTemplate(context, template),
        onEditTemplate: (template) =>
            _editTemplateFromQuickStart(context, template),
        onDeleteTemplate: (template) =>
            _deleteTemplateFromQuickStart(context, template),
        onCreateTemplate: () => _showCreateTemplateModal(context),
        onScheduleTemplate: (template) => _scheduleTemplate(context, template),
        onRefreshTemplate: (template) => _refreshTemplate(template),
        onViewTemplate: (template) => _viewTemplate(template),
      ),
    );
  }

  /// Build preloaded workout view
  Widget _buildPreloadedView(Workout workout) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text(workout.name)),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticIcon(
                    icon: AppIcons.autoAwesome,
                    semanticLabel: 'Auto awesome',
                    size: AppIconSize.tiny,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    l10n.suggested,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: SemanticIcon(
            icon: AppIcons.back,
            size: AppIconSize.medium,
            semanticLabel: l10n.back,
          ),
          onPressed: () => _handleBackNavigation(context),
        ),
      ),
      body: PreloadedView(
        workout: workout,
        sessionId:
            widget.sessionId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        onStartWorkout: () {
          ref
              .read(workoutScreenControllerProvider.notifier)
              .startWorkout(context: context, sessionId: widget.sessionId);
        },
        onBrowseTemplates: () => _navigateToTemplates(context),
      ),
    );
  }

  /// Build active workout view
  Widget _buildWorkoutView(Workout workout, WorkoutScreenState state) {
    final l10n = AppLocalizations.of(context);

    final colorScheme = Theme.of(context).colorScheme;

    // Watch connectivity for HR display
    final watchData = ref.watch(watchConnectivityProvider);
    final hasValidHR =
        watchData.currentHeartRate > 0 && watchData.hasRecentHealthMetrics;

    _maybeShowLongPressReorderHint(workout, state);

    return Scaffold(
      appBar: AppBar(
        // ✅ IMPROVED: Different title and styling in reorder mode
        title: Row(
          children: [
            // Titolo (solo in reorder mode mostra testo specifico)
            if (state.isReorderMode)
              Flexible(
                child: Text(
                  l10n.reorderExercises,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )
            else ...[
              // Workout name with share icon (tappable)
              Flexible(
                child: GestureDetector(
                  onTap: () => _shareWorkoutProgress(context, workout),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            workout.name,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          AppIcons.share,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // HR Badge from Apple Watch (only when connected and valid)
              if (hasValidHR) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.favorite,
                        size: 14,
                        color: context.colors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${watchData.currentHeartRate.toInt()}',
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
        backgroundColor: state.isReorderMode
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        leading: state.isReorderMode
            // In reorder mode: X to cancel
            ? IconButton(
                icon: SemanticIcon(
                  icon: AppIcons.close,
                  size: AppIconSize.medium,
                  semanticLabel: l10n.cancel,
                ),
                onPressed: () {
                  ref
                      .read(workoutScreenControllerProvider.notifier)
                      .toggleReorderMode();
                  HapticFeedback.lightImpact();
                },
              )
            // Normal mode: back arrow
            : IconButton(
                icon: SemanticIcon(
                  icon: AppIcons.back,
                  size: AppIconSize.medium,
                  semanticLabel: l10n.back,
                ),
                onPressed: () => _handleBackNavigation(context),
              ),
        actions: [
          // ✅ REORDER MODE: Done button in app bar (iOS style)
          if (state.isReorderMode)
            TextButton.icon(
              onPressed: () {
                ref
                    .read(workoutScreenControllerProvider.notifier)
                    .toggleReorderMode();
                HapticFeedback.mediumImpact();
              },
              icon: SemanticIcon(
                icon: AppIcons.check,
                size: AppIconSize.small,
                semanticLabel: l10n.done,
                color: colorScheme.primary,
              ),
              label: Text(
                l10n.done,
                style: context.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // ✅ IMPROVED: More prominent "Finish" button (best practice UX)
          if (!state.isReorderMode)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: FilledButton.tonalIcon(
                key: _completeWorkoutButtonKey,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref
                      .read(workoutScreenControllerProvider.notifier)
                      .endWorkout(context: context);
                },
                icon: SemanticIcon(
                  icon: AppIcons.check,
                  size: AppIconSize.small,
                  semanticLabel: l10n.finish,
                ),
                label: Text(
                  l10n.finish,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),

          // Overflow menu: CupertinoActionSheet (iOS native style)
          if (!state.isReorderMode)
            IconButton(
              key: _workoutOptionsMenuKey,
              icon: SemanticIcon(
                icon: AppIcons.moreVert,
                size: AppIconSize.medium,
                semanticLabel: l10n.settings,
              ),
              onPressed: () => _showWorkoutActionsSheet(context, workout),
            ),
        ],
      ),
      body: WorkoutView(
        workout: workout,
        isReorderMode: state.isReorderMode,
        onEditExercise: (exercise) => _editExercise(context, exercise),
        onDeleteExercise: (exerciseId) => _deleteExercise(exerciseId),
        onReplaceExercise: (exercise) => _replaceExercise(context, exercise),
        onUpdateExerciseSet: (exerciseId, updatedSet) =>
            _updateExerciseSet(exerciseId, updatedSet),
        onUpdateExercise: (updatedExercise) => _updateExercise(updatedExercise),
        onUpdateSupersetSet: (supersetId, supersetSet) =>
            _updateSupersetSet(supersetId, supersetSet),
        onReorderExercises: (oldIndex, newIndex) {
          ref
              .read(workoutScreenControllerProvider.notifier)
              .reorderExercises(oldIndex, newIndex);
        },
        // Tutorial keys for interactive onboarding
        tutorialFirstSetKey: _firstSetRowKey,
        tutorialExerciseMenuKey: _exerciseMenuKey,
      ),
      floatingActionButton: _buildFAB(state),
    );
  }

  void _maybeShowLongPressReorderHint(
    Workout workout,
    WorkoutScreenState state,
  ) {
    if (!mounted || state.isReorderMode || workout.exercises.length < 2) return;
    if (_reorderHintShownInSession || _reorderHintCheckInProgress) return;

    _reorderHintCheckInProgress = true;
    unawaited(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final alreadyShown = prefs.getBool(_reorderHintShownPrefKey) ?? false;

        if (alreadyShown) {
          _reorderHintShownInSession = true;
          return;
        }

        await prefs.setBool(_reorderHintShownPrefKey, true);
        _reorderHintShownInSession = true;

        if (!mounted) return;
        final isItalian = Localizations.localeOf(context).languageCode == 'it';
        final message = isItalian
            ? 'Suggerimento: tieni premuta una card e trascina per riordinare gli esercizi.'
            : 'Tip: long press a card and drag to reorder exercises.';

        SnackBarService.showInfo(
          context,
          message,
          duration: const Duration(seconds: 4),
        );
      } finally {
        _reorderHintCheckInProgress = false;
      }
    }());
  }

  /// Shows a CupertinoActionSheet with workout-level actions.
  Future<void> _showWorkoutActionsSheet(BuildContext context, Workout workout) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return showCupertinoModalPopup<_WorkoutActionsSheetSelection>(
      context: context,
      builder: (BuildContext sheetContext) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(
              sheetContext,
              _WorkoutActionsSheetSelection.generateWarmups,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.whatshotOutlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.generateAllWarmups,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(
              sheetContext,
              _WorkoutActionsSheetSelection.openSettings,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.settings, color: colorScheme.secondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.workoutSettings,
                  style: TextStyle(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () =>
              Navigator.pop(sheetContext, _WorkoutActionsSheetSelection.cancel),
          isDefaultAction: true,
          child: Text(l10n.cancel),
        ),
      ),
    ).then((selection) async {
      if (!mounted) return;

      switch (selection) {
        case _WorkoutActionsSheetSelection.generateWarmups:
          _generateAllWarmups(workout);
          return;
        case _WorkoutActionsSheetSelection.openSettings:
          // Wait action sheet dismissal animation before opening next modal.
          await Future<void>.delayed(const Duration(milliseconds: 120));
          if (!mounted || !context.mounted) return;
          await WorkoutCustomizationModalV3.show(context);
          return;
        case _WorkoutActionsSheetSelection.cancel:
        case null:
          return;
      }
    });
  }

  /// Build floating action button based on state
  /// No FAB in reorder mode - "Done" is now in AppBar (iOS style)
  /// Normal mode: FAB is handled by _buildDraggableFAB() in the main Stack
  Widget? _buildFAB(WorkoutScreenState state) {
    return null;
  }

  /// Build draggable FAB for adding exercises (PiP-style with hide/show)
  Widget _buildDraggableFAB() {
    final l10n = AppLocalizations.of(context);

    return DraggableActionButton(
      key: _addExerciseFABKey,
      onPressed: () => _showAddExercise(context), // Tap normale: modal standard
      icon: AppIcons.add,
      label: l10n.addExercise,
      positionKey: 'workout_screen_fab',
      onShowHistory: () {
        // Navigate to workout history
        context.pushNamed('workoutHistory');
      },
      // ✅ NEW: Advanced set options for long-press menu dropdown
      additionalOptions: [
        DraggableActionOption(
          icon: AppIcons.link,
          label: l10n.tabSuperset,
          onTap: () => _showAddExerciseAdvanced(context, advancedTab: 0),
        ),
        DraggableActionOption(
          icon: AppIcons.trendingDown,
          label: l10n.tabDropSet,
          onTap: () => _showAddExerciseAdvanced(context, advancedTab: 1),
        ),
        DraggableActionOption(
          icon: AppIcons.pause,
          label: l10n.tabRestPause,
          onTap: () => _showAddExerciseAdvanced(context, advancedTab: 2),
        ),
      ],
    );
  }

  // ========================================================================
  // WORKOUT SHARING
  // ========================================================================

  /// Share current workout progress as an image
  Future<void> _shareWorkoutProgress(
    BuildContext context,
    Workout workout,
  ) async {
    final l10n = AppLocalizations.of(context);

    // Get user name from Firebase
    final user = FirebaseAuth.instance.currentUser;
    final userName =
        user?.displayName ?? user?.email?.split('@').first ?? 'Atleta';

    // Calculate elapsed duration
    final elapsedDuration = workout.startTime != null
        ? DateTime.now().difference(workout.startTime!)
        : Duration.zero;

    // Get share button position for iPad
    final shareButtonRect = context.globalPaintBounds;

    // Show loading indicator
    SnackBarService.showInfo(context, l10n.workoutShareGenerating);

    // Generate and share
    final success = await WorkoutShareService.shareWorkout(
      context: context,
      workout: workout,
      userName: userName,
      elapsedDuration: elapsedDuration,
      shareButtonRect: shareButtonRect,
    );

    if (!success && context.mounted) {
      SnackBarService.showError(context, l10n.workoutShareError);
    }
  }

  // ========================================================================
  // NAVIGATION
  // ========================================================================

  /// Handle back navigation with confirmation if workout is active
  void _handleBackNavigation(BuildContext context) {
    final currentWorkout = ref.read(currentWorkoutProvider);
    final l10n = AppLocalizations.of(context);

    if (currentWorkout != null && currentWorkout.isActive) {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.keepWorkoutActive),
          content: Text(l10n.keepWorkoutActiveMessage),
          actions: [
            Semantics(
              label: l10n.cancel,
              button: true,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ),
            Semantics(
              label: l10n.yes,
              button: true,
              child: FilledButton.tonal(
                onPressed: () async {
                  Navigator.of(context).pop();
                  // Force save and pause workout
                  final cacheService = ref.read(
                    workoutTemplateCacheServiceProvider,
                  );
                  await cacheService.forceSave();
                  ref.read(currentWorkoutProvider.notifier).pauseWorkout();
                  if (context.mounted) {
                    context.goNamed('home');
                  }
                },
                child: Text(l10n.yes),
              ),
            ),
            Semantics(
              label: l10n.discard,
              button: true,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref
                      .read(workoutScreenControllerProvider.notifier)
                      .discardWorkout(context: context);
                },
                child: Text(
                  l10n.discard,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      context.goNamed('home');
    }
  }

  /// Navigate to templates screen
  void _navigateToTemplates(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const WorkoutTemplatesScreen()),
    );
  }

  // ========================================================================
  // WORKOUT ACTIONS
  // ========================================================================

  Future<void> _consumeFreeWorkoutTriggerIfNeeded() async {
    final trigger = widget.freeWorkoutTrigger;

    if (!mounted ||
        trigger == null ||
        trigger.isEmpty ||
        trigger == _lastConsumedFreeWorkoutTrigger ||
        _startingFreeWorkout) {
      return;
    }

    _lastConsumedFreeWorkoutTrigger = trigger;
    await _startFreeWorkout(context);
  }

  /// Start a free workout and open the exercise picker immediately.
  Future<void> _startFreeWorkout(BuildContext context) async {
    if (_startingFreeWorkout || !mounted) return;

    _startingFreeWorkout = true;

    try {
      final currentWorkout = ref.read(currentWorkoutProvider);
      final hasActiveWorkout =
          currentWorkout != null &&
          (currentWorkout.status == WorkoutStatus.inProgress ||
              currentWorkout.status == WorkoutStatus.paused);

      if (!hasActiveWorkout) {
        if (currentWorkout != null) {
          ref.read(currentWorkoutProvider.notifier).clearWorkout();
        }

        await ref
            .read(workoutScreenControllerProvider.notifier)
            .startWorkout(context: context, sessionId: widget.sessionId);
      }

      await Future<void>.delayed(const Duration(milliseconds: 150));

      if (!mounted || !context.mounted) return;

      _showAddExercise(context);
    } finally {
      _startingFreeWorkout = false;
    }
  }

  /// Start workout from template
  void _startTemplateWorkout(wt.WorkoutTemplate template) {
    ref
        .read(workoutScreenControllerProvider.notifier)
        .startWorkout(
          context: context,
          template: template,
          sessionId: widget.sessionId,
        );
  }

  /// Show add exercise modal (standard Single tab)
  void _showAddExercise(BuildContext context) {
    _showAddExerciseInternal(context, initialTab: 0);
  }

  /// Show add exercise modal on Advanced tab with specific sub-tab
  void _showAddExerciseAdvanced(
    BuildContext context, {
    required int advancedTab,
  }) {
    _showAddExerciseInternal(
      context,
      initialTab: 1, // Advanced tab
      initialAdvancedTab: advancedTab,
    );
  }

  /// Internal helper for showing add exercise modal with tab selection
  void _showAddExerciseInternal(
    BuildContext context, {
    int initialTab = 0,
    int initialAdvancedTab = 0,
    bool fromTutorialStepAdvance = false,
  }) {
    // If user taps FAB directly during step 2, move tutorial to the modal flow.
    final tutorialNotifier = ref.read(workoutTutorialProvider.notifier);
    final tutorialState = ref.read(workoutTutorialProvider);
    if (tutorialState.isActive &&
        !fromTutorialStepAdvance &&
        tutorialState.currentStep == WorkoutTutorialStep.addExercise) {
      tutorialNotifier.advanceToStep(WorkoutTutorialStep.browseDatabase);
    }

    // Track if exercise was added during this modal session
    bool exerciseWasAdded = false;
    final skipCustomizationOnContinue =
        ref.read(currentWorkoutProvider)?.templateId == null;

    Future<void> openBrowseDatabase() async {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (searchContext) => ExerciseSearchScreen(
            onExerciseAdded: (exercise) async {
              exerciseWasAdded = true;
              final exerciseToAdd = await _applyWeightPrefill(exercise);
              unawaited(
                ref
                    .read(workoutScreenControllerProvider.notifier)
                    .addExercise(exerciseToAdd),
              );
              onExerciseAdded();
            },
            skipCustomizationOnContinue: skipCustomizationOnContinue,
            showSupersetTemplates: false,
          ),
        ),
      );

      if (!mounted) return;
      final tutorialStateAfterSearch = ref.read(workoutTutorialProvider);
      if (tutorialStateAfterSearch.isActive &&
          tutorialStateAfterSearch.currentStep ==
              WorkoutTutorialStep.filtersAndCustom) {
        // Filters step is handled inside ExerciseSearchScreen.
        // If user exits search before completing it, bring them back to browse step.
        ref
            .read(workoutTutorialProvider.notifier)
            .advanceToStep(WorkoutTutorialStep.browseDatabase);
        Future.delayed(const Duration(milliseconds: 260), () {
          if (mounted) _showCurrentTutorialStep();
        });
      }
    }

    _openDatabaseFromTutorialAction = openBrowseDatabase;

    final modalFuture = AddExerciseModal.show(
      context,
      initialTab: initialTab,
      initialAdvancedTab: initialAdvancedTab,
      tutorialBrowseDatabaseKey: _addExerciseModalBrowseKey,
      tutorialFiltersAndCustomKey: _addExerciseModalFiltersCustomKey,
      onBrowseDatabaseRequested: openBrowseDatabase,
      onExerciseAdded: (exercise) async {
        debugPrint(
          '🎯 [WorkoutScreen] CALLBACK RECEIVED: name=${exercise.name}, countingMode=${exercise.countingMode}',
        );
        exerciseWasAdded = true;

        // Pre-fill sets with suggested weight/reps (non-blocking, 2s timeout)
        final exerciseToAdd = await _applyWeightPrefill(exercise);

        unawaited(
          ref
              .read(workoutScreenControllerProvider.notifier)
              .addExercise(exerciseToAdd),
        );
        // Note: Navigator.pop() is called by AddExerciseModal after this callback
        // Do NOT call pop() here - it would cause double-pop and black screen!

        // Trigger tutorial step if active
        onExerciseAdded();
      },
      skipCustomizationOnContinue: skipCustomizationOnContinue,
    );

    final modalTutorialState = ref.read(workoutTutorialProvider);
    if (modalTutorialState.isActive &&
        modalTutorialState.currentStep == WorkoutTutorialStep.browseDatabase) {
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) _showCurrentTutorialStep();
      });
    }

    modalFuture.whenComplete(() {
      _openDatabaseFromTutorialAction = null;

      // EDGE CASE FIX: Re-show tutorial if modal was dismissed without adding exercise
      // This handles the "distracted user" who opens modal but dismisses it without action
      if (!exerciseWasAdded && mounted) {
        final tutorialState = ref.read(workoutTutorialProvider);
        if (tutorialState.isActive) {
          // If modal tutorial was interrupted without selection, go back to step 2.
          const modalOrWaitingSteps = <WorkoutTutorialStep>{
            WorkoutTutorialStep.browseDatabase,
            WorkoutTutorialStep.filtersAndCustom,
            WorkoutTutorialStep.customizeExercise,
          };
          if (modalOrWaitingSteps.contains(tutorialState.currentStep)) {
            ref
                .read(workoutTutorialProvider.notifier)
                .advanceToStep(WorkoutTutorialStep.addExercise);
          }
          // Re-show the current tutorial step after a short delay
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _showCurrentTutorialStep();
          });
        }
      } else if (mounted) {
        final tutorialState = ref.read(workoutTutorialProvider);
        if (tutorialState.isActive &&
            tutorialState.currentStep == WorkoutTutorialStep.workoutSettings) {
          Future.delayed(const Duration(milliseconds: 350), () {
            if (mounted) _showCurrentTutorialStep();
          });
        }
      }
    });
  }

  /// Apply weight pre-fill suggestions to an exercise's sets.
  /// Returns the exercise with updated sets, or the original if no suggestion.
  Future<Exercise> _applyWeightPrefill(Exercise exercise) async {
    try {
      final prefill = await ref
          .read(exerciseWeightPrefillProvider(exercise.name).future)
          .timeout(const Duration(seconds: 2), onTimeout: () => null);

      if (prefill == null) return exercise;

      final updatedSets = exercise.sets.map((s) {
        return s.copyWith(
          weight: s.weight ?? prefill.weight,
          reps: s.reps ?? prefill.reps,
        );
      }).toList();

      debugPrint(
        '💡 [WeightPrefill] ${exercise.name}: '
        '${prefill.weight}kg × ${prefill.reps} (${prefill.source.name})',
      );

      return exercise.copyWith(sets: updatedSets);
    } catch (e) {
      debugPrint('⚠️ [WeightPrefill] Error: $e');
      return exercise;
    }
  }

  /// Navigate to templates screen for template creation
  /// Template creation now happens only from "Le mie schede" section
  void _showCreateTemplateModal(BuildContext context) {
    context.go('/templates');
  }

  // ========================================================================
  // BATCH WARMUP GENERATION
  // ========================================================================

  /// Generates warmup sets for all applicable exercises in the workout.
  ///
  /// Logic per exercise:
  /// - Skip if already has warmup sets
  /// - Skip if isolation/stretching/cardio (via movementType)
  /// - Skip if no working sets or weight = 0
  /// - Same category already trained → skip (muscle already irrorated)
  /// - Synergistic category trained → abbreviated warmup (1 set)
  /// - First compound per category → full warmup protocol
  void _generateAllWarmups(Workout workout) {
    final warmupCalc = WarmupCalculatorService();
    final notifier = ref.read(currentWorkoutProvider.notifier);
    final categoriesWarmedUp = <ExerciseCategory>{};
    var generatedCount = 0;

    for (final exercise in workout.exercises) {
      // Skip if already has warmup sets
      if (exercise.sets.any((s) => s.isWarmup)) continue;

      // Skip isolation/cardio based on movementType
      final mt = exercise.movementType;
      if (mt == MovementType.isolationLight) continue;

      // Skip exercises without working sets or without weight
      final workingSets = exercise.sets.where((s) => !s.isWarmup).toList();
      if (workingSets.isEmpty) continue;
      final targetWeight = workingSets.first.weight ?? 0.0;
      if (targetWeight <= 0) continue;

      // Determine warmup context: direct match → skip, synergistic → abbreviated
      final warmupContext = WarmupCalculatorService.determineContext(
        exercise.category,
        categoriesWarmedUp,
      );

      // Determine if barbell from exercise name (no _exerciseData at this level)
      final isBarbell = warmupCalc.isLikelyBarbellExercise(exercise.name);

      // Generate warmup sets
      final warmupSets = warmupCalc.calculateWarmupSetsV2(
        targetWeight,
        warmupContext: warmupContext,
        isBarbell: isBarbell,
      );

      // Always track that this category has been trained (even if skipped)
      categoriesWarmedUp.add(exercise.category);

      if (warmupSets.isEmpty) continue;

      // Convert WarmupSet → ExerciseSet
      final warmupExerciseSets = warmupSets
          .asMap()
          .map(
            (index, warmup) => MapEntry(
              index,
              ExerciseSet(
                setNumber: index + 1,
                weight: warmup.weight,
                reps: warmup.reps,
                isWarmup: true,
                isCompleted: false,
              ),
            ),
          )
          .values
          .toList();

      // Renumber working sets after warmup
      final renumberedWorkingSets = workingSets
          .asMap()
          .map(
            (index, set) => MapEntry(
              index,
              set.copyWith(setNumber: warmupExerciseSets.length + index + 1),
            ),
          )
          .values
          .toList();

      // Apply
      final updatedExercise = exercise.copyWith(
        sets: [...warmupExerciseSets, ...renumberedWorkingSets],
        updatedAt: DateTime.now(),
      );
      notifier.updateExercise(exercise.id, updatedExercise);

      generatedCount++;
    }

    // Feedback
    HapticFeedback.mediumImpact();
    if (generatedCount > 0) {
      SnackBarService.showSuccess(
        context,
        context.l10n.allWarmupsGenerated(generatedCount.toString()),
      );
    } else {
      SnackBarService.showInfo(context, context.l10n.noExercisesNeedWarmup);
    }

    if (kDebugMode) {
      debugPrint(
        '🔥 [WorkoutScreen] Generated warmup for $generatedCount exercises',
      );
    }
  }

  // ========================================================================
  // EXERCISE ACTIONS
  // ========================================================================

  /// Edit exercise - opens the edit modal from the exercise list item
  /// Note: The actual editing UI is handled by ExerciseListItem's internal edit modal
  /// This method is called when the user taps on an exercise card
  void _editExercise(BuildContext context, Exercise exercise) {
    // The editing is handled by ExerciseListItem via onEdit callback
    // which shows EditExerciseModal internally
    // This placeholder allows for future customization if needed
    if (kDebugMode) {
      debugPrint('📝 [WorkoutScreen] Edit exercise tapped: ${exercise.name}');
    }
  }

  /// Delete exercise with confirmation dialog (P0-2 fix)
  Future<void> _deleteExercise(String exerciseId) async {
    final config = ref.read(appConfigProvider);

    // Skip confirmation if user has opted out
    if (config.skipExerciseDeleteConfirmation) {
      unawaited(
        ref
            .read(workoutScreenControllerProvider.notifier)
            .removeExercise(exerciseId),
      );
      return;
    }

    // Look up exercise name from current workout
    final workout = ref.read(currentWorkoutProvider);
    final exercise = workout?.exercises
        .where((e) => e.id == exerciseId)
        .firstOrNull;
    final exerciseName = exercise?.name ?? 'Exercise';

    // Show confirmation dialog
    final result = await _showDeleteExerciseConfirmation(context, exerciseName);
    if (result == null) return; // Dialog dismissed

    if (result.confirmed) {
      unawaited(
        ref
            .read(workoutScreenControllerProvider.notifier)
            .removeExercise(exerciseId),
      );

      // Save preference if "Don't ask again" was checked
      if (result.dontAskAgain) {
        final currentConfig = ref.read(appConfigProvider);
        unawaited(
          ref
              .read(appConfigProvider.notifier)
              .updateConfig(
                currentConfig.copyWith(skipExerciseDeleteConfirmation: true),
              ),
        );
      }
    }
  }

  /// Show delete exercise confirmation dialog
  /// Returns DeleteConfirmationResult with confirmed status and dontAskAgain preference
  Future<_DeleteConfirmationResult?> _showDeleteExerciseConfirmation(
    BuildContext context,
    String exerciseName,
  ) async {
    final l10n = context.l10n;
    bool dontAskAgain = false;

    return showGeneralDialog<_DeleteConfirmationResult>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: context.colors.onSurface.withValues(alpha: 0.54),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(l10n.deleteExercise),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise name
                      Text(
                        '"$exerciseName"',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Confirmation message
                      Text(
                        l10n.deleteExerciseDescription,
                        style: context.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      // "Don't ask again" checkbox
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: dontAskAgain,
                              onChanged: (value) {
                                setState(() => dontAskAgain = value ?? false);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => dontAskAgain = !dontAskAgain),
                              child: Text(
                                l10n.dontAskAgain,
                                style: context.textTheme.bodySmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    Semantics(
                      label: l10n.cancel,
                      button: true,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(
                          _DeleteConfirmationResult(
                            confirmed: false,
                            dontAskAgain: false,
                          ),
                        ),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    Semantics(
                      label: l10n.delete,
                      button: true,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(
                          _DeleteConfirmationResult(
                            confirmed: true,
                            dontAskAgain: dontAskAgain,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: context.colors.error,
                        ),
                        child: Text(l10n.delete),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Replace exercise - swap one exercise for another at the same position
  void _replaceExercise(BuildContext context, Exercise exercise) {
    ModalService.showSheet(
      context,
      isScrollControlled: true,
      builder: (context) => AddExerciseModal(
        onExerciseAdded: (newExercise) {
          final replacementExercise = buildReplacementExercise(
            currentExercise: exercise,
            replacementExercise: newExercise,
          );

          // Update the exercise at the old exercise's ID position
          ref
              .read(currentWorkoutProvider.notifier)
              .updateExercise(exercise.id, replacementExercise);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Update exercise set
  void _updateExerciseSet(String exerciseId, ExerciseSet updatedSet) {
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout == null) return;

    final exerciseIndex = currentWorkout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = currentWorkout.exercises[exerciseIndex];
    final setIndex = exercise.sets.indexWhere((s) => s.id == updatedSet.id);
    if (setIndex == -1) return;

    final previousSet = exercise.sets[setIndex];
    final notifier = ref.read(currentWorkoutProvider.notifier);
    final isNewCompletion = updatedSet.isCompleted && !previousSet.isCompleted;

    ref.read(workoutScreenControllerProvider.notifier).trackGuidedSetEdited();

    // Route fresh non-warmup completions through the workout provider so the
    // timer policy stays consistent with Watch/Live Activity flows.
    notifier.updateExerciseSet(exerciseId, updatedSet);

    if (isNewCompletion && !updatedSet.isWarmup) {
      notifier.completeSet(exerciseId, updatedSet.id);
    }
  }

  /// Update exercise using notifier method
  void _updateExercise(Exercise updatedExercise) {
    ref
        .read(currentWorkoutProvider.notifier)
        .updateExerciseOnly(updatedExercise);
  }

  /// Update superset set
  void _updateSupersetSet(String supersetId, SupersetSet updatedSupersetSet) {
    ref
        .read(currentWorkoutProvider.notifier)
        .updateSupersetSet(supersetId, updatedSupersetSet);
  }

  // ========================================================================
  // TEMPLATE ACTIONS
  // ========================================================================

  /// Edit template from quick start
  Future<void> _editTemplateFromQuickStart(
    BuildContext context,
    wt.WorkoutTemplate template,
  ) async {
    try {
      final repository = ref.read(workoutTemplateRepositoryProvider);
      final editableTemplate = await repository.ensureEditableTemplate(
        template,
      );

      if (!context.mounted) return;

      if (editableTemplate.id != template.id) {
        SnackBarService.showInfo(
          context,
          context.l10n.templatePrivateDraftCreated(template.name),
        );
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditTemplateScreen(template: editableTemplate),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(
          context,
          localizeTemplateErrorMessage(context, e),
        );
      }
    }
  }

  /// Share template as PDF
  Future<void> _shareTemplatePdf(
    BuildContext context,
    wt.WorkoutTemplate template,
  ) async {
    final l10n = AppLocalizations.of(context);

    // Store navigator before any async gap to avoid context issues
    final navigator = Navigator.of(context);

    // Check saved preference
    final savedPreference = ref.read(pdfPreferencesProvider);

    // Use saved preference or show dialog
    PdfDetailLevel? selectedLevel = savedPreference;

    if (savedPreference == null) {
      selectedLevel = await showPdfExportBottomSheet(context, ref);
      if (selectedLevel == null) return; // User cancelled
    }

    // Show loading dialog for PDF generation
    if (context.mounted) {
      unawaited(
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LoadingIndicator(),
                    const SizedBox(height: AppSpacing.md),
                    Text(l10n.generatingPdf),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    try {
      // Step 1: Generate PDF (with loading visible)
      final pdfData = await PdfTemplateService.generateTemplatePdf(
        template,
        detailLevel: selectedLevel!,
      );

      // Step 2: Save to temp file
      final tempDir = await getTemporaryDirectory();
      final fileName = '${template.name.replaceAll(' ', '_')}_template.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfData);

      // Step 3: Dismiss loading BEFORE showing share sheet
      if (navigator.mounted) {
        navigator.pop();
      }

      // Step 4: Share with share_plus (provides proper callbacks)
      final result = await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: template.name),
      );

      // Step 5: Handle result (optional: show feedback)
      if (result.status == ShareResultStatus.dismissed && context.mounted) {
        // User dismissed without sharing - no action needed
      }

      // Clean up temp file
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Dismiss loading if still visible
      if (navigator.mounted) {
        navigator.pop();
      }
      if (context.mounted) {
        SnackBarService.showError(context, l10n.errorSharingPdf);
      }
    }
  }

  /// Delete template from quick start
  void _deleteTemplateFromQuickStart(
    BuildContext context,
    wt.WorkoutTemplate template,
  ) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTemplate),
        content: Text(l10n.deleteTemplateQuestion(template.name)),
        actions: [
          Semantics(
            label: l10n.cancel,
            button: true,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ),
          Semantics(
            label: l10n.delete,
            button: true,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref
                    .read(workoutTemplateNotifierProvider.notifier)
                    .deleteTemplate(template.id);
                SnackBarService.showSuccess(
                  context,
                  l10n.templateDeletedSuccessfully(template.name),
                );
              },
              child: Text(
                l10n.delete,
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Schedule template - opens the schedule bottom sheet
  void _scheduleTemplate(BuildContext context, wt.WorkoutTemplate template) {
    ScheduleBottomSheet.show(
      context,
      templateId: template.id,
      templateName: template.name,
    );
  }

  /// View template in presentation mode
  void _viewTemplate(wt.WorkoutTemplate template) {
    context.push('/templates/detail', extra: template.id);
  }

  /// Refresh template from exercise database - syncs TUT and other fields
  Future<void> _refreshTemplate(wt.WorkoutTemplate template) async {
    final l10n = AppLocalizations.of(context);

    try {
      final updatedCount = await ref
          .read(workoutTemplateNotifierProvider.notifier)
          .refreshTemplateFromDatabase(template);

      if (mounted) {
        if (updatedCount > 0) {
          // Invalidate providers to refresh UI
          ref.invalidate(customWorkoutTemplatesProvider);

          SnackBarService.showSuccess(
            context,
            l10n.refreshFromDatabaseSuccess(updatedCount),
          );
        } else {
          SnackBarService.showInfo(context, l10n.refreshFromDatabaseNoUpdates);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, 'Errore: $e');
      }
    }
  }

  /// Duplicate template
  Future<void> _duplicateTemplate(
    BuildContext context,
    wt.WorkoutTemplate template,
  ) async {
    final l10n = AppLocalizations.of(context);

    try {
      final duplicatedTemplate = await ref
          .read(workoutTemplateNotifierProvider.notifier)
          .duplicateTemplate(template);

      if (context.mounted) {
        SnackBarService.showSuccess(
          context,
          l10n.workoutTemplateDuplicatedSuccess(duplicatedTemplate.name),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error duplicating template: $e');
      }
      if (context.mounted) {
        SnackBarService.showError(
          context,
          l10n.workoutTemplateDuplicationError(e.toString()),
        );
      }
    }
  }

  /// Start the workout tutorial from the beginning
  Future<void> _startWorkoutTutorial() async {
    // Start the interactive tutorial
    await ref.read(workoutTutorialProvider.notifier).startTutorial();

    // Show the first step after a short delay to let the UI settle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCurrentTutorialStep();
    });
  }

  /// Show the current tutorial step based on state
  void _showCurrentTutorialStep({int attempt = 0}) {
    final tutorialState = ref.read(workoutTutorialProvider);
    if (!tutorialState.isActive) return;

    final targetKey = _tutorialTargetKeys[tutorialState.currentStep];
    if (targetKey == null) return;

    // UI can still be laying out right after navigation/sheet transitions.
    // Retry a few times before giving up to avoid a silent no-op tutorial start.
    if (targetKey.currentContext == null) {
      if (attempt >= _tutorialTargetMaxRetries) return;
      Future.delayed(const Duration(milliseconds: 220), () {
        if (mounted) _showCurrentTutorialStep(attempt: attempt + 1);
      });
      return;
    }

    ref
        .read(workoutTutorialProvider.notifier)
        .showCurrentStep(
          context: context,
          targetKey: targetKey,
          onComplete: () =>
              _handleTutorialStepComplete(tutorialState.currentStep),
        );
  }

  /// Handle tutorial step completion and advance to next step
  void _handleTutorialStepComplete(WorkoutTutorialStep completedStep) {
    if (!mounted) return;

    // Last tutorial step still performs a guided action before closing.
    if (completedStep == WorkoutTutorialStep.completeSetRpe) {
      unawaited(_showTutorialRpeCompletionSheet());
      unawaited(ref.read(workoutTutorialProvider.notifier).completeTutorial());
      SnackBarService.showSuccess(
        context,
        AppLocalizations.of(context).tutorialCompletedMessage,
      );
      return;
    }

    final nextStep = _getNextTutorialStep(completedStep);
    if (nextStep == null) {
      // Tutorial completed
      ref.read(workoutTutorialProvider.notifier).completeTutorial();
      SnackBarService.showSuccess(
        context,
        AppLocalizations.of(context).tutorialCompletedMessage,
      );
      return;
    }

    // Step 2 must continue inside the Add Exercise modal.
    if (completedStep == WorkoutTutorialStep.addExercise) {
      ref.read(workoutTutorialProvider.notifier).advanceToStep(nextStep);
      _showAddExerciseInternal(
        context,
        initialTab: 0,
        fromTutorialStepAdvance: true,
      );
      return;
    }

    // Step 3 should execute guided action: open database search.
    if (completedStep == WorkoutTutorialStep.browseDatabase) {
      ref.read(workoutTutorialProvider.notifier).advanceToStep(nextStep);
      final openAction = _openDatabaseFromTutorialAction;
      if (openAction != null) {
        unawaited(openAction());
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _showCurrentTutorialStep();
        });
      }
      return;
    }

    // Step 6 should execute guided action: open workout settings sheet.
    if (completedStep == WorkoutTutorialStep.workoutSettings) {
      ref.read(workoutTutorialProvider.notifier).advanceToStep(nextStep);
      final workout = ref.read(currentWorkoutProvider);
      if (workout != null) {
        unawaited(
          _showWorkoutActionsSheet(context, workout).whenComplete(() {
            Future.delayed(const Duration(milliseconds: 320), () {
              if (mounted) _showCurrentTutorialStep();
            });
          }),
        );
      } else {
        Future.delayed(const Duration(milliseconds: 320), () {
          if (mounted) _showCurrentTutorialStep();
        });
      }
      return;
    }

    // Step 7 should execute guided action: open first set editor.
    if (completedStep == WorkoutTutorialStep.editSetGestures) {
      ref.read(workoutTutorialProvider.notifier).advanceToStep(nextStep);
      unawaited(
        _showTutorialSetEditor().whenComplete(() {
          Future.delayed(const Duration(milliseconds: 320), () {
            if (mounted) _showCurrentTutorialStep();
          });
        }),
      );
      return;
    }

    // For filtersAndCustom step, we wait for user to actually add an exercise.
    // For other steps, show immediately
    if (completedStep == WorkoutTutorialStep.filtersAndCustom) {
      // Continue in ExerciseCustomizationScreen for counting/rest guidance.
      // Workout screen should not show this step.
      ref.read(workoutTutorialProvider.notifier).advanceToStep(nextStep);
      // Next overlay is shown by ExerciseCustomizationScreen.
    } else {
      // Advance and show next step
      ref.read(workoutTutorialProvider.notifier).advanceToStep(nextStep);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showCurrentTutorialStep();
      });
    }
  }

  ({Exercise exercise, ExerciseSet set, int setIndex})? _findTutorialSetTarget({
    String? exerciseId,
    int? preferredSetIndex,
    bool preferIncomplete = false,
  }) {
    final workout = ref.read(currentWorkoutProvider);
    if (workout == null || workout.exercises.isEmpty) return null;

    final candidates = <Exercise>[];
    if (exerciseId != null) {
      for (final exercise in workout.exercises) {
        if (exercise.id == exerciseId && exercise is! SupersetExercise) {
          candidates.add(exercise);
          break;
        }
      }
    } else {
      for (final exercise in workout.exercises) {
        if (exercise is! SupersetExercise && exercise.sets.isNotEmpty) {
          candidates.add(exercise);
        }
      }
    }

    for (final exercise in candidates) {
      if (exercise.sets.isEmpty) continue;

      var setIndex = -1;

      if (preferIncomplete) {
        setIndex = exercise.sets.indexWhere(
          (s) => !s.isWarmup && !s.isCompleted,
        );
        if (setIndex == -1) {
          setIndex = exercise.sets.indexWhere((s) => !s.isCompleted);
        }
      }

      if (setIndex == -1 && preferredSetIndex != null) {
        if (preferredSetIndex >= 0 &&
            preferredSetIndex < exercise.sets.length) {
          setIndex = preferredSetIndex;
        }
      }

      if (setIndex == -1) {
        setIndex = exercise.sets.indexWhere((s) => !s.isWarmup);
      }

      if (setIndex == -1) {
        setIndex = 0;
      }

      if (setIndex >= 0 && setIndex < exercise.sets.length) {
        return (
          exercise: exercise,
          set: exercise.sets[setIndex],
          setIndex: setIndex,
        );
      }
    }

    return null;
  }

  Future<void> _showTutorialSetEditor({
    String? exerciseId,
    int? preferredSetIndex,
  }) async {
    final target = _findTutorialSetTarget(
      exerciseId: exerciseId,
      preferredSetIndex: preferredSetIndex,
    );
    if (target == null || !mounted) return;

    final appConfig = ref.read(appConfigProvider);

    double? suggestedWeight;
    try {
      final prefill = await ref
          .read(exerciseWeightPrefillProvider(target.exercise.name).future)
          .timeout(const Duration(seconds: 2), onTimeout: () => null);
      suggestedWeight = prefill?.weight;
    } catch (_) {
      suggestedWeight = null;
    }

    if (!mounted) return;

    await context.showMinimalSetEditSheet(
      exerciseSet: target.set,
      countingMode: target.exercise.countingMode,
      measurementUnit: appConfig.measurementUnit,
      suggestedWeight: suggestedWeight,
      currentSetIndex: target.setIndex,
      totalSets: target.exercise.sets.length,
      allSets: target.exercise.sets,
      previousSet: target.setIndex > 0
          ? target.exercise.sets[target.setIndex - 1]
          : null,
      onSave: (updatedSet) {
        _updateExerciseSet(target.exercise.id, updatedSet);
      },
      onApplyToAll: (updatedSet) {
        final latestTarget = _findTutorialSetTarget(
          exerciseId: target.exercise.id,
        );
        if (latestTarget == null) return;
        final updatedSets = latestTarget.exercise.sets.map((set) {
          if (set.isWarmup) return set;
          return set.copyWith(
            weight: updatedSet.weight,
            reps: updatedSet.reps,
            minReps: updatedSet.minReps,
            maxReps: updatedSet.maxReps,
            seconds: updatedSet.seconds,
          );
        }).toList();
        _updateExercise(latestTarget.exercise.copyWith(sets: updatedSets));
        ref
            .read(workoutScreenControllerProvider.notifier)
            .trackGuidedSetEdited();
      },
      onSaveAndNext: (updatedSet) {
        _updateExerciseSet(target.exercise.id, updatedSet);
        final nextIndex = target.setIndex + 1;
        if (nextIndex < target.exercise.sets.length) {
          unawaited(
            _showTutorialSetEditor(
              exerciseId: target.exercise.id,
              preferredSetIndex: nextIndex,
            ),
          );
        }
      },
      onSaveAndPrevious: (updatedSet) {
        _updateExerciseSet(target.exercise.id, updatedSet);
        final previousIndex = target.setIndex - 1;
        if (previousIndex >= 0) {
          unawaited(
            _showTutorialSetEditor(
              exerciseId: target.exercise.id,
              preferredSetIndex: previousIndex,
            ),
          );
        }
      },
    );
  }

  Future<void> _showTutorialRpeCompletionSheet() async {
    final target = _findTutorialSetTarget(preferIncomplete: true);
    if (target == null || !mounted) return;

    final targetReps =
        target.set.reps ?? target.set.minReps ?? target.set.maxReps ?? 10;

    await RpeSelectorBottomSheet.show(
      context: context,
      set: target.set,
      targetReps: targetReps,
      exercise: target.exercise,
      onConfirm: (actualReps, actualWeight, rpe) {
        final updatedSet = target.set.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
          actualReps: actualReps,
          weight: actualWeight,
          rpe: rpe,
        );
        _updateExerciseSet(target.exercise.id, updatedSet);
      },
    );
  }

  /// Get the next tutorial step
  WorkoutTutorialStep? _getNextTutorialStep(WorkoutTutorialStep current) {
    switch (current) {
      case WorkoutTutorialStep.welcome:
        return WorkoutTutorialStep.addExercise;
      case WorkoutTutorialStep.addExercise:
        return WorkoutTutorialStep.browseDatabase;
      case WorkoutTutorialStep.browseDatabase:
        return WorkoutTutorialStep.filtersAndCustom;
      case WorkoutTutorialStep.filtersAndCustom:
        return WorkoutTutorialStep.customizeExercise;
      case WorkoutTutorialStep.customizeExercise:
        return WorkoutTutorialStep.workoutSettings;
      case WorkoutTutorialStep.workoutSettings:
        return WorkoutTutorialStep.editSetGestures;
      case WorkoutTutorialStep.editSetGestures:
        return WorkoutTutorialStep.completeSetRpe;
      case WorkoutTutorialStep.completeSetRpe:
        return null; // Tutorial complete
      case WorkoutTutorialStep.completed:
        return null;
    }
  }

  /// Called when an exercise is added to the workout
  /// Triggers next tutorial step if tutorial is active
  void onExerciseAdded() {
    final tutorialState = ref.read(workoutTutorialProvider);
    if (!tutorialState.isActive) return;

    // Counting/rest guidance is now shown in ExerciseCustomizationScreen.
    // If user adds directly without passing through that screen, advance anyway.
    if (tutorialState.currentStep == WorkoutTutorialStep.customizeExercise) {
      ref
          .read(workoutTutorialProvider.notifier)
          .advanceToStep(WorkoutTutorialStep.workoutSettings);
    }
  }
}

/// Helper class for delete confirmation dialog result (P0-2)
class _DeleteConfirmationResult {
  _DeleteConfirmationResult({
    required this.confirmed,
    required this.dontAskAgain,
  });

  final bool confirmed;
  final bool dontAskAgain;
}

enum _WorkoutActionsSheetSelection { generateWarmups, openSettings, cancel }
