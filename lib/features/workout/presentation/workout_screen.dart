import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/draggable_tutorial_overlay.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/expandable_fab.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart' as wt;
import 'package:gymbro_flutter_new/features/workout/domain/entities/pdf_detail_level.dart';
import 'package:gymbro_flutter_new/features/workout/services/pdf_template_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_auto_save_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/pdf_preferences_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/add_exercise_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/pdf_export_options_dialog.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/create_template_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/quick_start/context_gathering_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/helpers/save_template_helper.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/edit_template_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/workout_templates_screen.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/widgets/tier1_minimal_timer_overlay.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_customization_modal_v3.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_state_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/contextual_overlay_manager.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_template_cache_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

// Sub-component imports
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen/widgets/welcome_view.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen/widgets/preloaded_view.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen/widgets/workout_view.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen/controllers/workout_screen_controller.dart';

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
/// - Conditional AppBar actions (reorder, complete, settings)
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
  });

  /// Optional template ID to pre-load when opening the screen
  final String? initialTemplateId;

  /// Session ID for analytics correlation
  final String? sessionId;

  /// Whether this screen was opened from the Smart CTA
  final bool fromSmartCTA;

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with WidgetsBindingObserver {
  // PHASE 2: GlobalKeys for contextual overlays
  final GlobalKey _addExerciseFABKey = GlobalKey();
  final GlobalKey _completeWorkoutButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Preload interstitial ad for workout completion
    ref.read(workoutScreenControllerProvider.notifier).preloadCompletionAd();

    // Add lifecycle observer for force-saving when app goes to background
    WidgetsBinding.instance.addObserver(this);

    // PHASE 2: Show welcome overlay for beginners on first workout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFirstWorkoutWelcomeIfNeeded();
    });
  }

  @override
  void dispose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Force save when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Save template cache
      final cacheService = ref.read(workoutTemplateCacheServiceProvider);
      cacheService.forceSave();

      // Emergency save current workout if active
      final currentWorkout = ref.read(currentWorkoutProvider);
      if (currentWorkout != null && currentWorkout.isActive) {
        final autoSave = ref.read(workoutAutoSaveProvider.notifier);
        autoSave.emergencySave(currentWorkout);

        if (kDebugMode) {
          debugPrint(
              '💾 [WorkoutScreen] Emergency saved active workout due to app lifecycle: $state');
        }
      }

      if (kDebugMode) {
        debugPrint(
            '💾 [WorkoutScreen] Force saved template cache due to app lifecycle: $state');
      }
    }
  }

  /// PHASE 2: Show welcome overlay to guide beginner through first workout
  Future<void> _showFirstWorkoutWelcomeIfNeeded() async {
    if (!mounted) return;

    final onboardingState = ref.read(onboardingProvider);
    final currentWorkout = ref.read(currentWorkoutProvider);

    // Show only if:
    // 1. User is beginner
    // 2. In first workout flow (hasn't completed first workout yet)
    // 3. Workout has no exercises yet (empty state)
    // 4. Hasn't seen this overlay before
    if (onboardingState.isInGuidedFirstWorkout &&
        (currentWorkout == null || currentWorkout.exercises.isEmpty) &&
        !onboardingState.hasSeenOverlay('firstWorkoutWelcome')) {
      // Wait a bit for UI to settle
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        await ContextualOverlayManager.show(
          context: context,
          ref: ref,
          overlayId: 'firstWorkoutWelcome',
          targetKey: _addExerciseFABKey,
          message: ContextualOverlayManager
              .commonOverlays['firstWorkoutWelcome']!.message,
          actionLabel: ContextualOverlayManager
              .commonOverlays['firstWorkoutWelcome']!.actionLabel,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWorkout = ref.watch(currentWorkoutProvider);
    final controllerState = ref.watch(workoutScreenControllerProvider);
    final shouldShowTimer = ref.watch(shouldShowTier1TimerProvider);

    // Determine which view to show
    final isPreloaded = currentWorkout != null && !currentWorkout.isActive;
    final isActive = currentWorkout != null && currentWorkout.isActive;
    final isEmpty = currentWorkout == null;

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
          if (isEmpty) _buildWelcomeView(),
          if (isPreloaded) _buildPreloadedView(currentWorkout),
          if (isActive) _buildWorkoutView(currentWorkout, controllerState),

          // Timer overlay (only when timer should be shown)
          if (shouldShowTimer)
            const Tier1MinimalTimerOverlay(),

          // Draggable tutorial overlay (only in active workout)
          if (isActive && !controllerState.isReorderMode)
            const DraggableTutorialOverlay(
              tutorialKey: 'workout_fab',
              child: SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  /// Build welcome/empty state view
  Widget _buildWelcomeView() {
    return WelcomeView(
      onQuickStart: () => _startQuickWorkout(context),
      onStartTemplate: (template) => _startTemplateWorkout(template),
      onShareTemplate: (template) => _shareTemplatePdf(context, template),
      onDuplicateTemplate: (template) => _duplicateTemplate(context, template),
      onEditTemplate: (template) => _editTemplateFromQuickStart(context, template),
      onDeleteTemplate: (template) => _deleteTemplateFromQuickStart(context, template),
      onCreateTemplate: () => _showCreateTemplateModal(context),
    );
  }

  /// Build preloaded workout view
  Widget _buildPreloadedView(Workout workout) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workout),
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
        sessionId: widget.sessionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        onStartWorkout: () {
          ref.read(workoutScreenControllerProvider.notifier).startWorkout(
            context: context,
            sessionId: widget.sessionId,
          );
        },
        onBrowseTemplates: () => _navigateToTemplates(context),
      ),
    );
  }

  /// Build active workout view
  Widget _buildWorkoutView(Workout workout, WorkoutScreenState state) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workout),
        leading: IconButton(
          icon: SemanticIcon(
            icon: AppIcons.back,
            size: AppIconSize.medium,
            semanticLabel: l10n.back,
          ),
          onPressed: () => _handleBackNavigation(context),
        ),
        actions: [
          // Reorder mode toggle (only if exercises exist)
          if (workout.exercises.isNotEmpty && !state.isReorderMode)
            IconButton(
              icon: SemanticIcon(
                icon: AppIcons.dragHandle,
                size: AppIconSize.medium,
                semanticLabel: l10n.reorderExercises,
              ),
              onPressed: () {
                ref.read(workoutScreenControllerProvider.notifier).toggleReorderMode();
              },
            ),

          // Complete workout (only if not in reorder mode)
          if (!state.isReorderMode)
            IconButton(
              key: _completeWorkoutButtonKey,
              icon: SemanticIcon(
                icon: AppIcons.check,
                size: AppIconSize.medium,
                semanticLabel: l10n.completeWorkout,
              ),
              onPressed: () {
                ref.read(workoutScreenControllerProvider.notifier).endWorkout(
                  context: context,
                );
              },
            ),

          // Settings menu
          if (!state.isReorderMode)
            IconButton(
              icon: SemanticIcon(
                icon: AppIcons.moreVert,
                size: AppIconSize.medium,
                semanticLabel: l10n.settings,
              ),
              onPressed: () => _showSettingsMenu(context),
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
        onUpdateExercise: (updatedExercise) =>
            _updateExercise(updatedExercise),
        onUpdateSupersetSet: (supersetId, supersetSet) =>
            _updateSupersetSet(supersetId, supersetSet),
        onReorderExercises: (oldIndex, newIndex) {
          ref.read(workoutScreenControllerProvider.notifier)
              .reorderExercises(oldIndex, newIndex);
        },
      ),
      floatingActionButton: _buildFAB(state),
    );
  }

  /// Build floating action button based on state
  Widget _buildFAB(WorkoutScreenState state) {
    final l10n = AppLocalizations.of(context);

    if (state.isReorderMode) {
      // Exit reorder mode button
      return FloatingActionButton.extended(
        key: const ValueKey('exitReorderFAB'),
        onPressed: () {
          ref.read(workoutScreenControllerProvider.notifier).toggleReorderMode();
        },
        icon: SemanticIcon(
          icon: AppIcons.check,
          size: AppIconSize.medium,
          semanticLabel: l10n.done,
        ),
        label: Text(l10n.done),
      );
    }

    // Normal mode: Expandable FAB with actions
    return ExpandableFAB(
      key: _addExerciseFABKey,
      icon: AppIcons.add,
      label: l10n.addExercise,
      options: [
        ExpandableFabOption(
          icon: AppIcons.add,
          label: l10n.addExercise,
          onTap: () => _showAddExercise(context),
        ),
      ],
    );
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton.tonal(
              onPressed: () async {
                Navigator.of(context).pop();
                // Force save and pause workout
                final cacheService = ref.read(workoutTemplateCacheServiceProvider);
                await cacheService.forceSave();
                ref.read(currentWorkoutProvider.notifier).pauseWorkout();
                if (context.mounted) {
                  context.goNamed('home');
                }
              },
              child: Text(l10n.yes),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(workoutScreenControllerProvider.notifier).discardWorkout(
                  context: context,
                );
              },
              child: Text(
                l10n.discard,
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colors.error,
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
      MaterialPageRoute(
        builder: (context) => const WorkoutTemplatesScreen(),
      ),
    );
  }

  // ========================================================================
  // WORKOUT ACTIONS
  // ========================================================================

  /// Start quick workout (context gathering flow)
  void _startQuickWorkout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ContextGatheringBottomSheet(),
    );
  }

  /// Start workout from template
  void _startTemplateWorkout(wt.WorkoutTemplate template) {
    ref.read(workoutScreenControllerProvider.notifier).startWorkout(
      context: context,
      template: template,
      sessionId: widget.sessionId,
    );
  }

  /// Show add exercise modal
  void _showAddExercise(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExerciseModal(
        onExerciseAdded: (exercise) {
          ref.read(workoutScreenControllerProvider.notifier).addExercise(exercise);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Show create template modal
  void _showCreateTemplateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateTemplateModal(),
    );
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

  /// Delete exercise
  void _deleteExercise(String exerciseId) {
    ref.read(workoutScreenControllerProvider.notifier).removeExercise(exerciseId);
  }

  /// Replace exercise - swap one exercise for another at the same position
  void _replaceExercise(BuildContext context, Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExerciseModal(
        onExerciseAdded: (newExercise) {
          // Update the exercise at the old exercise's ID position
          ref.read(currentWorkoutProvider.notifier).updateExercise(
            exercise.id,
            newExercise,
          );
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Update exercise set
  void _updateExerciseSet(String exerciseId, ExerciseSet updatedSet) {
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout == null) return;

    final exerciseIndex = currentWorkout.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = currentWorkout.exercises[exerciseIndex];
    final setIndex = exercise.sets.indexWhere((s) => s.id == updatedSet.id);
    if (setIndex == -1) return;

    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets[setIndex] = updatedSet;

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    _updateExercise(updatedExercise);
  }

  /// Update exercise using notifier method
  void _updateExercise(Exercise updatedExercise) {
    ref.read(currentWorkoutProvider.notifier).updateExerciseOnly(updatedExercise);
  }

  /// Update superset set
  void _updateSupersetSet(String supersetId, SupersetSet updatedSupersetSet) {
    ref.read(currentWorkoutProvider.notifier).updateSupersetSet(
      supersetId,
      updatedSupersetSet,
    );
  }

  // ========================================================================
  // TEMPLATE ACTIONS
  // ========================================================================

  /// Edit template from quick start
  void _editTemplateFromQuickStart(BuildContext context, wt.WorkoutTemplate template) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTemplateScreen(template: template),
      ),
    );
  }

  /// Share template as PDF
  Future<void> _shareTemplatePdf(
    BuildContext context,
    wt.WorkoutTemplate template,
  ) async {
    // Check saved preference
    final savedPreference = ref.read(pdfPreferencesProvider);

    // Use saved preference or show dialog
    PdfDetailLevel? selectedLevel = savedPreference;

    if (savedPreference == null) {
      selectedLevel = await showPdfExportOptionsDialog(context, ref);
      if (selectedLevel == null) return; // User cancelled
    }

    // Show loading
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LoadingIndicator(),
                  const SizedBox(height: AppSpacing.md),
                  Text(context.l10n.generatingPdf),
                ],
              ),
            ),
          ),
        ),
      );
    }

    try {
      // Generate and share PDF with selected detail level
      await PdfTemplateService.shareTemplatePdf(
        template,
        detailLevel: selectedLevel!,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        SnackBarService.showSuccess(context, '✅ PDF shared successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        SnackBarService.showError(context, '❌ Error sharing PDF: $e');
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(workoutTemplateNotifierProvider.notifier).deleteTemplate(template.id);
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
        ],
      ),
    );
  }

  /// Duplicate template
  Future<void> _duplicateTemplate(
    BuildContext context,
    wt.WorkoutTemplate template,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final l10n = AppLocalizations.of(context);

    if (userId == null) {
      SnackBarService.showError(
        context,
        l10n.workoutTemplateDuplicationError('User not authenticated'),
      );
      return;
    }

    // Create duplicate with "(Copy)" suffix
    final duplicatedTemplate = template.copyWith(
      name: '${template.name} (${l10n.copy})',
      isCustom: true,
      updatedAt: DateTime.now(),
    );

    try {
      await ref
          .read(workoutTemplateNotifierProvider.notifier)
          .saveTemplate(duplicatedTemplate);

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

  // ========================================================================
  // SETTINGS MENU
  // ========================================================================

  /// Show settings menu bottom sheet
  void _showSettingsMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Customize workout
              ListTile(
                leading: SemanticIcon(
                  icon: AppIcons.tune,
                  size: AppIconSize.medium,
                  semanticLabel: l10n.customizeWorkout,
                ),
                title: Text(l10n.customizeWorkout),
                subtitle: Text(l10n.rpeTimerAndMore),
                onTap: () {
                  Navigator.of(context).pop();
                  _showWorkoutCustomization(context);
                },
              ),
              // Save as template
              ListTile(
                leading: SemanticIcon(
                  icon: AppIcons.save,
                  size: AppIconSize.medium,
                  semanticLabel: l10n.saveAsTemplate,
                ),
                title: Text(l10n.saveAsTemplate),
                onTap: () {
                  Navigator.of(context).pop();
                  _saveCurrentWorkoutAsTemplate(context);
                },
              ),
              // Discard workout
              ListTile(
                leading: SemanticIcon(
                  icon: AppIcons.delete,
                  size: AppIconSize.medium,
                  semanticLabel: l10n.deleteWorkout,
                  color: context.colors.error,
                ),
                title: Text(
                  l10n.deleteWorkout,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.error,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _handleBackNavigation(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Save current workout as template
  void _saveCurrentWorkoutAsTemplate(BuildContext context) {
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout == null) return;

    SaveTemplateHelper.showSaveAsTemplateDialog(context, ref);
  }

  /// Show workout customization modal
  void _showWorkoutCustomization(BuildContext context) {
    WorkoutCustomizationModalV3.show(context);
  }
}
