import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/draggable_action_button.dart';
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
import 'package:gymbro_flutter_new/features/workout/presentation/providers/previous_workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_template_cache_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/add_exercise_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/pdf_export_options_dialog.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_header.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_customization_modal_v3.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/create_template_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/quick_start/context_gathering_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/quick_start_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/helpers/save_template_helper.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/edit_template_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/workout_templates_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/swipeable_template_card.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/widgets/tier1_minimal_timer_overlay.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_extensions.dart';
import 'package:gymbro_flutter_new/shared/data/services/interstitial_ad_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/adaptive_banner_ad.dart';
import 'package:gymbro_flutter_new/core/config/admob_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_state_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/contextual_overlay_manager.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_analytics.dart';
import 'package:uuid/uuid.dart';
// 🏆 PR Celebration imports
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/pr_celebration_modal.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/achievement_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/pr_celebration.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

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

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> with WidgetsBindingObserver {
  bool _isReorderMode = false;
  final _interstitialAdService = InterstitialAdService();

  // PHASE 2: GlobalKeys for contextual overlays
  final GlobalKey _addExerciseFABKey = GlobalKey();
  final GlobalKey _completeWorkoutButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Pre-load interstitial ad for workout completion
    _interstitialAdService.preloadWorkoutCompleteAd();

    // 💾 Add lifecycle observer for force-saving when app goes to background
    WidgetsBinding.instance.addObserver(this);

    // PHASE 2: Show welcome overlay for beginners on first workout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFirstWorkoutWelcomeIfNeeded();
    });
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
          message: ContextualOverlayManager.commonOverlays['firstWorkoutWelcome']!.message,
          actionLabel: ContextualOverlayManager.commonOverlays['firstWorkoutWelcome']!.actionLabel,
        );
      }
    }
  }

  @override
  void dispose() {
    // 💾 Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // NOTE: Cannot use ref.read() in dispose() as widget is already unmounted
    // The auto-save is already handled by the lifecycle observer in didChangeAppLifecycleState
    // Emergency saves should be triggered there, not in dispose()

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 💾 Force save when app goes to background
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Save template cache
      final cacheService = ref.read(workoutTemplateCacheServiceProvider);
      cacheService.forceSave();

      // 💾 Emergency save current workout if active
      final currentWorkout = ref.read(currentWorkoutProvider);
      if (currentWorkout != null && currentWorkout.isActive) {
        final autoSave = ref.read(workoutAutoSaveProvider.notifier);
        autoSave.emergencySave(currentWorkout);

        if (kDebugMode) {
          debugPrint('💾 [WorkoutScreen] Emergency saved active workout due to app lifecycle: $state');
        }
      }

      if (kDebugMode) {
        debugPrint('💾 [WorkoutScreen] Force saved template cache due to app lifecycle: $state');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('🏗️ WorkoutScreen.build called');
    }

    // ⚡ OPTIMIZATION: Use .select() for granular rebuilds
    // Only rebuild when specific properties change, not entire workout object
    final sessionId = (GoRouterState.of(context).extra as Map?)?['sessionId'] as String?;

    final workoutName = ref.watch(
      currentWorkoutProvider.select((workout) => workout?.name),
    );
    final isActive = ref.watch(
      currentWorkoutProvider.select((workout) => workout?.isActive ?? false),
    );
    final hasExercises = ref.watch(
      currentWorkoutProvider.select((workout) => workout?.exercises.isNotEmpty ?? false),
    );
    final hasWorkout = ref.watch(
      currentWorkoutProvider.select((workout) => workout != null),
    );

    // Check if this is a pre-loaded workout
    final isPreloaded = ref.watch(
      currentWorkoutProvider.select((workout) => workout?.isPreloaded ?? false),
    );

    // ✅ FIX #7: Track workout_screen_viewed when workout is loaded
    ref.listen(
      currentWorkoutProvider,
      (previous, next) {
        // Track when workout first appears (null → non-null transition)
        if (previous == null && next != null) {
          WorkoutAnalytics.trackEvent(
            'workout_screen_viewed',
            properties: {
              'sessionId': sessionId ?? next.sessionId ?? _generateSessionId(),
              'sourceFlow': next.isPreloaded ? 'smart_cta' : 'fab',
              'exerciseCount': next.exercises.length,
              'timestamp': DateTime.now().toIso8601String(),
            },
          );
        }
      },
    );

    // PHASE 2: Listen for first exercise added to show "addFirstSet" overlay
    ref.listen(
      currentWorkoutProvider.select((workout) => workout?.exercises.length ?? 0),
      (previous, current) {
        final onboardingState = ref.read(onboardingProvider);

        // Show overlay when first exercise is added (0 → 1 transition)
        if (previous == 0 && current == 1 && onboardingState.shouldShowAddFirstExercise) {
          // Wait for UI to settle and modal to close
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              ContextualOverlayManager.show(
                context: context,
                ref: ref,
                overlayId: 'addFirstSet',
                targetKey: _addExerciseFABKey,
                message: ContextualOverlayManager.commonOverlays['addFirstSet']!.message,
                actionLabel: ContextualOverlayManager.commonOverlays['addFirstSet']!.actionLabel,
              );
            }
          });
        }
      },
    );

    // PHASE 2: Listen for first set completed to show "completeFirstWorkout" overlay
    ref.listen(
      onboardingProvider.select((state) => state.hasCompletedFirstSet),
      (previous, current) {
        final onboardingState = ref.read(onboardingProvider);

        // Show overlay when first set is completed AND user should see complete workout overlay
        if (previous == false && current == true && onboardingState.shouldShowCompleteWorkout) {
          // Wait for rest timer overlay to dismiss and UI to settle
          Future.delayed(const Duration(milliseconds: 2500), () {
            if (mounted) {
              ContextualOverlayManager.show(
                context: context,
                ref: ref,
                overlayId: 'completeFirstWorkout',
                targetKey: _completeWorkoutButtonKey,
                message: ContextualOverlayManager.commonOverlays['completeFirstWorkout']!.message,
                actionLabel: ContextualOverlayManager.commonOverlays['completeFirstWorkout']!.actionLabel,
              );
            }
          });
        }
      },
    );

    if (kDebugMode) {
      debugPrint('🏗️ Current workout: $workoutName, hasExercises: $hasExercises');
    }

    // Add error boundary for debugging
    try {
      final scaffold = PopScope(
        canPop: false, // Prevent default back navigation
          onPopInvoked: (didPop) {
            if (!didPop) {
              _handleBackNavigation(context, ref);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(workoutName ?? context.l10n.myWorkouts),
              leading: isActive
                ? IconButton(
                    icon: const SemanticIcon(
  icon: AppIcons.home,
  semanticLabel: 'Home',
),
                    onPressed: () => _handleBackNavigation(context, ref),
                    tooltip: context.l10n.backToHomeKeepWorkoutActive,
                  )
                : IconButton(
                    icon: const SemanticIcon(
  icon: AppIcons.back,
  semanticLabel: 'Back',
),
                    onPressed: () => context.goNamed('home'),
                    tooltip: context.l10n.backToHome,
                  ),
              actions: [
                if (isActive && hasExercises)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isReorderMode = !_isReorderMode;
                      });
                      if (!_isReorderMode) {
                        // Show feedback when exiting reorder mode
                        SnackBarService.showSuccess(
                          context,
                          context.l10n.orderSaved,
                        );
                      }
                    },
                    icon: SemanticIcon(
                      icon: _isReorderMode ? AppIcons.done : AppIcons.swapVert,
                      semanticLabel: _isReorderMode ? 'Confirm reorder' : 'Reorder exercises',
                    ),
                    tooltip: _isReorderMode ? context.l10n.confirmReorder : context.l10n.reorderExercises,
                  ),
                if (isActive)
                  IconButton(
                    key: _completeWorkoutButtonKey, // PHASE 2: GlobalKey for contextual overlay
                    onPressed: () => _completeWorkout(context, ref),
                    icon: const SemanticIcon(
  icon: AppIcons.checkCircle,
  semanticLabel: 'Complete',
),
                    tooltip: context.l10n.completeWorkout,
                  ),
                IconButton(
                  onPressed: () => _showSettingsMenu(context, ref),
                  icon: const SemanticIcon(
  icon: AppIcons.moreVert,
  semanticLabel: 'More options',
),
                ),
              ],
            ),
            body: Stack(
              children: [
                // Conditional rendering based on workout state
                if (!hasWorkout)
                  _buildWelcomeView(context, ref)
                else if (isPreloaded && hasExercises)
                  // ⚡ OPTIMIZATION: Only watch full workout for preloaded view
                  Consumer(
                    builder: (context, ref, child) {
                      final currentWorkout = ref.watch(currentWorkoutProvider);
                      if (currentWorkout == null) return const SizedBox.shrink();
                      return _buildPreloadedView(context, ref, currentWorkout, sessionId ?? _generateSessionId());
                    },
                  )
                else
                  // ⚡ CRITICAL FIX FOR INFINITE GIF RELOAD LOOP - SOLUTION 2 (Surgical Fix)
                  // ROOT CAUSE: Consumer watches ENTIRE provider → rebuilds on every state change (timer, flags, etc.)
                  // SOLUTION: Use .select() to watch ONLY the exercises list (what ListView actually needs)
                  // This prevents rebuilds when timer/internal flags change, only rebuilding on exercise changes
                  // Expected: 100+ rebuilds/sec → ~0-5 rebuilds (only when exercises actually change)
                  Consumer(
                    builder: (context, ref, child) {
                      // ⚡ OPTIMIZATION: Watch only exercises list, not entire workout
                      // This uses Riverpod's .select() to create a granular dependency
                      final exercises = ref.watch(
                        currentWorkoutProvider.select((workout) => workout?.exercises ?? []),
                      );

                      // Watch workout name separately for AppBar (rarely changes)
                      final workoutName = ref.watch(
                        currentWorkoutProvider.select((workout) => workout?.name ?? ''),
                      );

                      // Watch workout ID for key stability
                      final workoutId = ref.watch(
                        currentWorkoutProvider.select((workout) => workout?.id),
                      );

                      // 🐛 DEBUG: Log ONLY when exercises actually change (not on timer updates)
                      if (kDebugMode) {
                        debugPrint('🏗️ [WorkoutScreen] Building workout view with ${exercises.length} exercises (ID: $workoutId)');
                      }

                      // 🔧 FIX: Solo mostra loading se workoutId è null (workout non esiste ancora)
                      // NON mostrare loading se exercises è vuoto - quello è gestito da _buildWorkoutView
                      // che mostra _buildEmptyExerciseList appropriatamente
                      if (workoutId == null) {
                        return const Center(child: LoadingIndicator());
                      }

                      // Get full workout object only when needed for _buildWorkoutView
                      // This is read-only access (no rebuild trigger)
                      final currentWorkout = ref.read(currentWorkoutProvider);

                      if (currentWorkout == null) {
                        return const Center(child: LoadingIndicator());
                      }

                      return _buildWorkoutView(context, ref, currentWorkout);
                    },
                  ),
                // Timer Overlay
                Consumer(
                  builder: (context, ref, child) {
                    final shouldShow = ref.watch(shouldShowTier1TimerProvider);
                    return shouldShow ? const Tier1MinimalTimerOverlay() : const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        );

      // Wrap con il button draggabile e tutorial
      return DraggableTutorialOverlay(
        tutorialKey: 'workout_fab',
        child: Stack(
          children: [
            scaffold,
            // Mostra ExpandableFAB quando non c'è workout attivo, DraggableActionButton altrimenti
            if (!hasWorkout)
              ExpandableFAB(
                icon: AppIcons.noteAdd,
                label: AppLocalizations.of(context).createTemplate,
                options: [
                  ExpandableFabOption(
                    icon: AppIcons.flashOn,
                    label: context.l10n.startNow,
                    onTap: () => _startQuickWorkout(context, ref),
                    backgroundColor: context.successColor,
                    foregroundColor: context.colors.surface,
                  ),
                  ExpandableFabOption(
                    icon: AppIcons.edit,
                    label: AppLocalizations.of(context).createManually,
                    onTap: () => _showCreateTemplateManually(context),
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.onPrimary,
                  ),
                ],
              )
            else
              DraggableActionButton(
                key: _addExerciseFABKey, // PHASE 2: GlobalKey for contextual overlay
                onPressed: () => _showAddExercise(context, ref),
                icon: AppIcons.add,
                label: AppLocalizations.of(context).addExercise,
                positionKey: 'workout_screen_fab',
                additionalOptions: [
                  DraggableActionOption(
                    icon: AppIcons.timer,
                    label: context.l10n.timerRest,
                    onTap: () {
                      // Mostra timer riposo manuale
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => SizedBox(
                          height: 400,
                          child: Center(
                            child: Text(context.l10n.timerRest),
                          ),
                        ),
                      );
                    },
                    color: context.warningColor,
                  ),
                  DraggableActionOption(
                    icon: AppIcons.save,
                    label: context.l10n.saveAsTemplate,
                    onTap: () {
                      // Salva workout corrente come template
                      SnackBarService.showInfo(
                        context,
                        context.l10n.saveTemplateFunctionComingSoon,
                      );
                    },
                    color: context.infoColor,
                  ),
                ],
              ),
          ],
        ),
      );
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ Error building WorkoutScreen: $e');
      }
      if (kDebugMode) {
        debugPrint('Stack: $stack');
      }
      
      // Return error widget instead of black screen
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.error),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SemanticIcon(
  icon: AppIcons.error,
  semanticLabel: 'Error',
  size: AppIconSize.medium,
  color: context.errorColor,
),
              const SizedBox(height: 16),
              Text(context.l10n.errorOccurred),
              const SizedBox(height: 8),
              Text('Error: $e', style: context.textTheme.bodySmall),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.goNamed('home'),
                child: Text(context.l10n.goHome),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildQuickStartList(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2, // I Tuoi Template, Schede Predefinite
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Bar
          ColoredBox(
            color: context.colors.surface,
            child: TabBar(
              labelColor: context.colors.primary,
              unselectedLabelColor: context.colors.onSurface.withValues(alpha: 0.6),
              indicatorColor: context.colors.primary,
              indicatorWeight: 3,
              labelStyle: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              tabs: [
                Tab(
                  icon: SemanticIcon(
                    icon: AppIcons.person,
                    semanticLabel: context.l10n.yourTemplates,
                    size: AppIconSize.medium,
                  ),
                  text: context.l10n.yourTemplates,
                ),
                Tab(
                  icon: SemanticIcon(
                    icon: AppIcons.stars,
                    semanticLabel: context.l10n.predefinedWorkouts,
                    size: AppIconSize.medium,
                  ),
                  text: context.l10n.predefinedWorkouts,
                ),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final customTemplatesAsync = ref.watch(customWorkoutTemplatesProvider);
                final allTemplatesAsync = ref.watch(allWorkoutTemplatesProvider);

                return TabBarView(
                  children: [
                    // Tab 1: I Tuoi Template (Custom)
                    customTemplatesAsync.when(
                      loading: () => const LoadingIndicator(),
                      error: (error, stack) => Center(
                        child: Text(context.l10n.errorLoading(error.toString())),
                      ),
                      data: (customTemplates) {
                        return _buildTemplateGrid(
                          context,
                          ref,
                          customTemplates,
                          context.l10n.yourTemplates,
                          isCustomTab: true,
                        );
                      },
                    ),

                    // Tab 2: Schede Predefinite (Predefined)
                    allTemplatesAsync.when(
                      loading: () => const LoadingIndicator(),
                      error: (error, stack) => Center(
                        child: Text(context.l10n.errorLoading(error.toString())),
                      ),
                      data: (allTemplates) {
                        // Filtra solo i template predefiniti (non custom)
                        final predefinedTemplates = allTemplates.where((t) => !t.isCustom).toList();
                        return _buildTemplateGrid(
                          context,
                          ref,
                          predefinedTemplates,
                          context.l10n.predefinedWorkouts,
                          isCustomTab: false,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  // Build template grid for each tab
  Widget _buildTemplateGrid(BuildContext context, WidgetRef ref, List<wt.WorkoutTemplate> templates, String categoryTitle, {bool isCustomTab = false}) {
    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: isCustomTab ? AppIcons.noteAdd : AppIcons.inventory2Outlined,
              semanticLabel: isCustomTab ? 'No custom templates' : 'No predefined workouts',
              size: AppIconSize.xxlarge,
              color: context.colors.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isCustomTab ? context.l10n.noCustomTemplates : context.l10n.noPredefinedWorkouts,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCustomTab ? context.l10n.createFirstTemplate : context.l10n.predefinedWorkoutsComingSoon,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.4),
              ),
            ),
            if (isCustomTab) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _showCreateTemplateModal(context),
                icon: SemanticIcon(
                  icon: AppIcons.add,
                  semanticLabel: context.l10n.createNewTemplate,
                  size: AppIconSize.medium,
                ),
                label: Text(context.l10n.createNewTemplate),
              ),
            ],
          ],
        ),
      );
    }

    // Use vertical ListView with SwipeableTemplateCard (iOS-style swipe actions)
    return ListView.builder(
      itemCount: templates.length,
      itemExtent: 216, // 200px card + 16px margin (8px top + 8px bottom)
      itemBuilder: (context, index) {
        final template = templates[index];
        return SwipeableTemplateCard(
          key: ValueKey(template.id),
          template: template,
          onTap: () => _startWorkoutFromTemplate(context, ref, template),
          onShare: () => _shareTemplatePdf(context, template),
          onDuplicate: () => _duplicateTemplate(context, ref, template),
          onEdit: () => _editTemplateFromQuickStart(context, template),
          onDelete: () => _deleteTemplateFromQuickStart(context, ref, template),
        );
      },
    );
  }

  // Grid template card design
  Widget _buildGridTemplateCard(BuildContext context, WidgetRef ref, wt.WorkoutTemplate template) {
    final theme = context.theme;

    // Usa colori del tema invece di colori basati sul nome
    final baseColor = template.isCustom
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showTemplateOptions(context, ref, template),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient header with icon
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: [
                    baseColor,
                    baseColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: SemanticIcon(
                  icon: AppIcons.workout,
                  semanticLabel: 'Workout template',
                  size: AppIconSize.xlarge,
                  color: context.colors.surface,
                ),
              ),
            ),

            // Template details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      template.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Stats
                    Column(
                      children: [
                        // Exercises count
                        Row(
                          children: [
                            SemanticIcon(
  icon: AppIcons.formatListBulleted,
  semanticLabel: 'Format list bulleted',
  size: AppIconSize.tiny,
  color: theme.colorScheme.onSurface.withValues(alpha: 0.6,
),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.exercisesCount(template.exercises.length),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Duration
                        Row(
                          children: [
                            SemanticIcon(
  icon: AppIcons.timer,
  semanticLabel: 'Timer',
  size: AppIconSize.tiny,
  color: theme.colorScheme.onSurface.withValues(alpha: 0.6,
),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '~${template.estimatedDuration} min',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Custom badge
                        if (template.isCustom)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              context.l10n.customBadge,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Show template options on tap
  void _showTemplateOptions(BuildContext context, WidgetRef ref, wt.WorkoutTemplate template) {
    final parentContext = context; // Capture parent context
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),

            // Template name header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.workout,
                    semanticLabel: 'Workout template',
                    size: AppIconSize.large,
                    color: template.isCustom
                        ? Theme.of(modalContext).colorScheme.primary
                        : Theme.of(modalContext).colorScheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: Theme.of(modalContext).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            SemanticIcon(
  icon: AppIcons.formatListBulleted,
  semanticLabel: 'Format list bulleted',
  size: AppIconSize.tiny,
  color: Theme.of(modalContext,
).colorScheme.onSurface.withValues(alpha: 0.6)),
                            const SizedBox(width: 4),
                            Text(
                              '${template.exercises.length} ${AppLocalizations.of(modalContext).exercises}',
                              style: Theme.of(modalContext).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 12),
                            SemanticIcon(
  icon: AppIcons.timer,
  semanticLabel: 'Timer',
  size: AppIconSize.tiny,
  color: Theme.of(modalContext,
).colorScheme.onSurface.withValues(alpha: 0.6)),
                            const SizedBox(width: 4),
                            Text(
                              '~${template.estimatedDuration} min',
                              style: Theme.of(modalContext).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Options
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.successContainer,
                  shape: BoxShape.circle,
                ),
                child: SemanticIcon(
                  icon: AppIcons.play,
                  semanticLabel: 'Start workout',
                  size: AppIconSize.medium,
                  color: context.successColor,
                ),
              ),
              title: Text(AppLocalizations.of(modalContext).startWorkout, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
              subtitle: Text(AppLocalizations.of(modalContext).startWorkoutWithTemplate),
              onTap: () {
                Navigator.pop(modalContext);
                _startWorkoutFromTemplate(parentContext, ref, template);
              },
            ),

            if (template.isCustom) ...[
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.infoContainer,
                    shape: BoxShape.circle,
                  ),
                  child: SemanticIcon(
                    icon: AppIcons.edit,
                    semanticLabel: 'Edit template',
                    size: AppIconSize.medium,
                    color: context.infoColor,
                  ),
                ),
                title: Text(AppLocalizations.of(modalContext).editTemplate, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
                subtitle: Text(AppLocalizations.of(modalContext).editTemplateSubtitle),
                onTap: () {
                  Navigator.pop(modalContext);
                  _editTemplateFromQuickStart(parentContext, template);
                },
              ),
            ],

            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.warningContainer,
                  shape: BoxShape.circle,
                ),
                child: SemanticIcon(
                  icon: AppIcons.share,
                  semanticLabel: 'Share PDF',
                  size: AppIconSize.medium,
                  color: context.warningColor,
                ),
              ),
              title: Text(AppLocalizations.of(modalContext).sharePdf, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
              subtitle: Text(AppLocalizations.of(modalContext).sharePdfSubtitle),
              onTap: () async {
                Navigator.pop(modalContext);
                _shareTemplatePdf(parentContext, template);
              },
            ),

            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: SemanticIcon(
                  icon: AppIcons.print,
                  semanticLabel: 'Print template',
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
              ),
              title: Text(AppLocalizations.of(modalContext).print, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
              subtitle: Text(AppLocalizations.of(modalContext).printTemplate),
              onTap: () async {
                Navigator.pop(modalContext);
                _printTemplatePdf(parentContext, template);
              },
            ),

            if (template.isCustom) ...[
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: SemanticIcon(
                    icon: AppIcons.delete,
                    semanticLabel: 'Delete template',
                    size: AppIconSize.medium,
                    color: context.errorColor,
                  ),
                ),
                title: Text(AppLocalizations.of(modalContext).deleteTemplate, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
                subtitle: Text(AppLocalizations.of(modalContext).deleteTemplateSubtitle),
                onTap: () {
                  Navigator.pop(modalContext);
                  _deleteTemplateFromQuickStart(parentContext, ref, template);
                },
              ),
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackTemplates(BuildContext context, WidgetRef ref) {
    // Template di fallback hardcoded (come prima)
    return Column(
      children: [
        QuickStartCard(
          icon: AppIcons.workout,
          title: context.l10n.upperBody,
          subtitle: context.l10n.upperBodySubtitle,
          color: context.colors.secondary,
          onTap: () => _startTemplateWorkout(context, ref, 'Upper Body'),
        ),
        const SizedBox(height: 12),
        QuickStartCard(
          icon: AppIcons.cardio,
          title: context.l10n.lowerBody,
          subtitle: context.l10n.lowerBodySubtitle,
          color: context.colors.tertiary,
          onTap: () => _startTemplateWorkout(context, ref, 'Lower Body'),
        ),
        const SizedBox(height: 12),
        QuickStartCard(
          icon: AppIcons.timer,
          title: context.l10n.hiitTraining,
          subtitle: context.l10n.hiitTrainingSubtitle,
          color: context.colors.error,
          onTap: () => _startTemplateWorkout(context, ref, 'HIIT'),
        ),
      ],
    );
  }

  void _navigateToTemplates(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WorkoutTemplatesScreen(),
      ),
    );
  }

  /// Load template by ID and start workout (called from Smart CTA)
  Future<void> _loadTemplateAndStart(String templateId) async {
    if (!mounted) return;

    try {
      // Load all templates from provider
      final templatesAsync = ref.read(customWorkoutTemplatesProvider);

      await templatesAsync.when(
        data: (templates) async {
          // Find the template by ID
          final template = templates.where((t) => t.id == templateId).firstOrNull;

          if (template == null) {
            if (mounted) {
              SnackBarService.showError(
                context,
                context.l10n.templateNotFound,
              );
            }
            return;
          }

          // Start workout from template
          if (mounted) {
            await _startWorkoutFromTemplate(context, ref, template);

            // Show CTA-specific message if needed
            if (widget.fromSmartCTA && mounted) {
              if (kDebugMode) {
                debugPrint('🚀 [WorkoutScreen] Started workout from Smart CTA: ${template.name}');
              }
            }
          }
        },
        loading: () {
          if (mounted) {
            SnackBarService.showInfo(context, context.l10n.loadingTemplate);
          }
        },
        error: (error, stack) {
          if (mounted) {
            SnackBarService.showError(
              context,
              context.l10n.templateLoadError(error.toString()),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          context.l10n.unexpectedError(e.toString()),
        );
      }
    }
  }

  Future<void> _startWorkoutFromTemplate(BuildContext context, WidgetRef ref, wt.WorkoutTemplate template) async {
    try {
      // Incrementa contatore utilizzo
      await ref.read(workoutTemplateNotifierProvider.notifier).incrementUsage(template.id);

      // ✅ PREVIOUS_DATA: Load previous workout data (async with 3-tier caching)
      Workout? previousWorkout;
      try {
        previousWorkout = await ref.read(previousWorkoutFromTemplateProvider(template.id).future);

        if (kDebugMode && previousWorkout != null) {
          debugPrint('✅ [WorkoutScreen] Loaded previous workout data for template: ${template.id}');
          debugPrint('   Previous workout: ${previousWorkout.name} (${previousWorkout.exercises.length} exercises)');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ [WorkoutScreen] Failed to load previous workout data: $e');
        }
        // Continue without previous data - graceful fallback
      }

      // Crea workout dal template
      final workoutNotifier = ref.read(currentWorkoutProvider.notifier);
      workoutNotifier.createWorkout(template.name);
      workoutNotifier.startWorkout();

      // Aggiungi esercizi dal template WITH previous data populated
      final exercises = template.toWorkoutExercises();
      for (final exercise in exercises) {
        // ✅ PREVIOUS_DATA: Match exercise with previous workout by name
        final enrichedExercise = _enrichExerciseWithPreviousData(exercise, previousWorkout);
        workoutNotifier.addExercise(enrichedExercise);
      }

      // Mostra messaggio di successo
      SnackBarService.showSuccess(
        context,
        context.l10n.workoutStarted(template.name),
      );
    } catch (e) {
      SnackBarService.showError(
        context,
        context.l10n.workoutStartError(e.toString()),
      );
    }
  }

  /// ✅ PREVIOUS_DATA: Enrich exercise with previous workout data
  ///
  /// Matches exercise by name (case-insensitive) and calculates average weight/reps
  /// from completed sets in the previous workout.
  Exercise _enrichExerciseWithPreviousData(Exercise exercise, Workout? previousWorkout) {
    if (kDebugMode) {
      debugPrint('🔍 [_enrichExerciseWithPreviousData] Starting for: ${exercise.name}');
      debugPrint('   previousWorkout: ${previousWorkout != null ? "✅ Found (${previousWorkout.exercises.length} exercises)" : "❌ NULL"}');
    }

    if (previousWorkout == null) {
      if (kDebugMode) {
        debugPrint('   ❌ Returning exercise as-is (no previous workout)');
      }
      return exercise;
    }

    // Find matching exercise by name (case-insensitive)
    final previousExercise = previousWorkout.exercises
        .where((e) => e.name.toLowerCase() == exercise.name.toLowerCase())
        .firstOrNull;

    if (kDebugMode) {
      debugPrint('   Previous exercise match: ${previousExercise != null ? "✅ Found" : "❌ NOT FOUND"}');
      if (previousExercise == null) {
        debugPrint('   Available exercises in previous workout:');
        for (final e in previousWorkout.exercises) {
          debugPrint('     - ${e.name}');
        }
      }
    }

    if (previousExercise == null) {
      if (kDebugMode) {
        debugPrint('   ❌ Returning exercise as-is (no matching exercise in previous workout)');
      }
      return exercise;
    }

    // Calculate average weight and reps from previous sets
    final completedSets = previousExercise.sets
        .where((s) => s.isCompleted)
        .where((s) => s.weight != null && s.reps != null) // Filter out nulls
        .toList();

    if (kDebugMode) {
      debugPrint('   Completed sets with data: ${completedSets.length}/${previousExercise.sets.length}');
    }

    if (completedSets.isEmpty) {
      if (kDebugMode) {
        debugPrint('   ❌ Returning exercise as-is (no completed sets with weight/reps)');
      }
      return exercise;
    }

    // Calculate averages (now safe because we filtered nulls)
    final avgWeight = completedSets.map((s) => s.weight!).reduce((a, b) => a + b) / completedSets.length;
    final avgReps = completedSets.map((s) => s.reps!).reduce((a, b) => a + b) / completedSets.length;

    if (kDebugMode) {
      debugPrint('✅ [WorkoutScreen] Enriched exercise: ${exercise.name}');
      debugPrint('   Previous: ${avgWeight.toStringAsFixed(1)}kg × ${avgReps.round()} reps');
      debugPrint('   Date: ${previousWorkout.startTime}');
      debugPrint('   Source: single');
    }

    // TODO(previous-data): Add previousWeight/previousReps fields to Exercise entity
    // For now, just return exercise as-is until Exercise entity supports these fields
    return exercise;
  }


  void _handleBackNavigation(BuildContext context, WidgetRef ref) {
    final currentWorkout = ref.read(currentWorkoutProvider);
    
    if (currentWorkout != null && currentWorkout.isActive) {
      // Show dialog to confirm navigation while keeping workout active
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.keepWorkoutActive),
          content: Text(context.l10n.keepWorkoutActiveMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            FilledButton.tonal(
              onPressed: () async {
                // 💾 Force save any pending modifications before pausing
                final cacheService = ref.read(workoutTemplateCacheServiceProvider);
                await cacheService.forceSave();

                // Pause workout and go to home
                ref.read(currentWorkoutProvider.notifier).pauseWorkout();
                Navigator.pop(context);
                context.goNamed('home');
                
                SnackBarService.showInfo(
                  context,
                  '⏸️ ${context.l10n.workoutPausedMessage}',
                );
              },
              child: Text(context.l10n.goToHome),
            ),
          ],
        ),
      );
    } else {
      // No active workout, just go back
      context.goNamed('home');
    }
  }

  String _generateSessionId() => const Uuid().v4();

  Widget _buildPreloadedView(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
    String sessionId,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(workout.name),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(width: 4),
                  Text(
                    'Suggerito',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // "Cambio Programma" banner
          _buildChangeWorkoutBanner(context, ref, sessionId),

          // Exercise list
          Expanded(
            child: ListView.builder(
              itemCount: workout.exercises.length,
              itemBuilder: (_, i) {
                final exercise = workout.exercises[i];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${i + 1}'),
                  ),
                  title: Text(exercise.name),
                  subtitle: Text(exercise.category.toString().split('.').last),
                );
              },
            ),
          ),

          // Start button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => _onStartWorkout(context, ref, workout, sessionId),
              icon: const SemanticIcon(
  icon: AppIcons.playArrowRounded,
  semanticLabel: 'Play arrow rounded',
),
              label: Text(context.l10n.startWorkout),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.successColor,
                foregroundColor: context.colors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeWorkoutBanner(
    BuildContext context,
    WidgetRef ref,
    String sessionId,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '💡 Non è quello che volevi?',
              style: context.textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: () => _showTemplateSelection(context, ref, sessionId),
            child: const Text('Sfoglia Template'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTemplateSelection(
    BuildContext context,
    WidgetRef ref,
    String sessionId,
  ) async {
    // Pause cleanup timer while user browses templates
    ref.read(currentWorkoutProvider.notifier).pauseCleanupTimer();

    try {
      // Show template selection modal
      final templates = await ref.read(customWorkoutTemplatesProvider.future);

      if (context.mounted) {
        await showModalBottomSheet(
          context: context,
          isDismissible: true,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (modalContext) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, scrollController) => Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Seleziona Template',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                // Template list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: templates.length,
                    itemBuilder: (_, index) {
                      final template = templates[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                          child: SemanticIcon(
                            icon: AppIcons.workout,
                            semanticLabel: 'Workout template',
                            size: AppIconSize.medium,
                            color: context.colors.primary,
                          ),
                        ),
                        title: Text(template.name),
                        subtitle: Text('${template.exercises.length} esercizi • ~${template.estimatedDuration} min'),
                        trailing: const SemanticIcon(
                          icon: AppIcons.arrowForwardRounded,
                          semanticLabel: 'Select template',
                          size: AppIconSize.small,
                        ),
                        onTap: () async {
                          // Replace exercises with selected template
                          await ref
                              .read(currentWorkoutProvider.notifier)
                              .replaceExercisesFromTemplate(template);

                          // Track modification
                          await WorkoutAnalytics.trackEvent(
                            'workout_template_changed',
                            properties: {
                              'sessionId': sessionId,
                              'newTemplateName': template.name,
                              'exerciseCount': template.exercises.length,
                              'timestamp': DateTime.now().toIso8601String(),
                            },
                          );

                          if (modalContext.mounted) {
                            Navigator.pop(modalContext);
                            // Resume cleanup timer
                            ref.read(currentWorkoutProvider.notifier).resumeCleanupTimer();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } finally {
      // Ensure timer resumed even if error occurs
      ref.read(currentWorkoutProvider.notifier).resumeCleanupTimer();
    }
  }

  Future<void> _onStartWorkout(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
    String sessionId,
  ) async {
    // Track analytics
    await WorkoutAnalytics.trackEvent(
      'workout_started',
      properties: {
        'sessionId': sessionId,
        'sourceFlow': workout.isPreloaded ? 'smart_cta' : 'fab',
        'exercisesModified': workout.exercisesModified ?? false,
        'exerciseCount': workout.exercises.length,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Update workout status to active
    ref.read(currentWorkoutProvider.notifier).startWorkout();

    // Show success feedback
    SnackBarService.showSuccess(
      context,
      '⚡ ${context.l10n.workoutStarted(workout.name)}',
    );

    // The UI will rebuild based on workout status
  }

  Widget _buildWelcomeView(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Start Card - Most prominent (Apple HIG design)
            InkWell(
              onTap: () => _startQuickWorkout(context, ref),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // Apple HIG standard
                  color: context.colors.primary, // Solid primary color (NO gradient)
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.onSurface.withValues(alpha: context.isDarkMode ? 0.2 : 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: context.colors.onPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SemanticIcon(
                        icon: AppIcons.flashOn,
                        semanticLabel: 'Start workout now',
                        size: AppIconSize.xlarge,
                        color: context.colors.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.startNow,
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.startImmediately,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onPrimary.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SemanticIcon(
                      icon: AppIcons.forwardIos,
                      semanticLabel: 'Start',
                      size: AppIconSize.medium,
                      color: context.colors.onPrimary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Start e Template
            Expanded(
              child: _buildQuickStartList(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutView(BuildContext context, WidgetRef ref, Workout workout) {
    // 🐛 DEBUG: Log exercises in _buildWorkoutView (now with kDebugMode guard for production safety)
    if (kDebugMode) {
      debugPrint('🏗️ [_buildWorkoutView] Building view with ${workout.exercises.length} exercises');
      for (final ex in workout.exercises) {
        debugPrint('   - ${ex.name}: countingMode=${ex.countingMode.name}');
      }
    }

    return SafeArea(
      child: Column(
        children: [
          // Workout Header with stats
          WorkoutHeader(workout: workout),

          // Exercise List
          Expanded(
            child: workout.exercises.isEmpty
                ? _buildEmptyExerciseList(context)
                : _isReorderMode
                    ? Theme(
                        data: context.theme.copyWith(
                          canvasColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: ReorderableListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: workout.exercises.length,
                          onReorder: (oldIndex, newIndex) {
                            ref.read(currentWorkoutProvider.notifier).reorderExercises(oldIndex, newIndex);
                            HapticFeedback.mediumImpact();
                          },
                          proxyDecorator: (child, index, animation) {
                            return AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) {
                                final double animValue = Curves.easeInOut.transform(animation.value);
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
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  // Drag handle with slide-in animation
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOutCubic,
                                    width: 40,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
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
                                  // Exercise item
                                  Expanded(
                                    child: exercise.type == ExerciseType.superset && exercise is SupersetExercise
                                        ? SupersetCard(
                                            superset: exercise,
                                            index: index,
                                            isReorderMode: true,
                                            onTap: () {},
                                            onDelete: () {},
                                            onEdit: () {},
                                            onReplace: () {},
                                            onSetUpdate: (_) {},
                                            onSetToggleComplete: (_) {},
                                            onExerciseUpdate: (_) {},
                                            onSupersetSetUpdate: (_) {},
                                          )
                                        : ExerciseListItem(
                                            exercise: exercise,
                                            isReorderMode: true,
                                            onTap: () {},
                                            onDelete: () {},
                                            onEdit: () {},
                                            onReplace: () {},
                                            onSetUpdate: (_) {},
                                            onSetToggleComplete: (_) {},
                                            onExerciseUpdate: (_) {},
                                          ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: workout.exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = workout.exercises[index];

                          // 🐛 DEBUG: Log exercise being passed to ExerciseListItem (now with kDebugMode guard for production safety)
                          if (kDebugMode) {
                            debugPrint('📋 [ListView.builder] Creating ExerciseListItem for: ${exercise.name}, countingMode=${exercise.countingMode.name}');
                          }

                          return Padding(
                            key: ValueKey(exercise.id), // ⚡ OPTIMIZATION: Key for better performance on list changes
                            padding: const EdgeInsets.only(bottom: 12),
                            // ⚡ REPAINT OPTIMIZATION: RepaintBoundary isolates each exercise card
                            // from repaints in other parts of the list (e.g., timer tick updates)
                            // Each card is on a separate layer, reducing GPU work significantly
                            child: RepaintBoundary(
                              child: exercise.type == ExerciseType.superset && exercise is SupersetExercise
                                  ? SupersetCard(
                                      superset: exercise,
                                      index: index,
                                      isReorderMode: false,
                                      onTap: () => _editExercise(context, ref, exercise),
                                      onDelete: () => _deleteExercise(ref, exercise.id),
                                      onEdit: () => _editExercise(context, ref, exercise),
                                      onReplace: () => _replaceExercise(context, ref, exercise),
                                      onSetUpdate: (updatedSet) => _updateExerciseSet(ref, exercise.id, updatedSet),
                                      onSetToggleComplete: (updatedSet) => _updateExerciseSet(ref, exercise.id, updatedSet),
                                      onExerciseUpdate: (updatedExercise) => _updateExercise(ref, updatedExercise),
                                      onSupersetSetUpdate: (supersetSet) => _updateSupersetSet(ref, exercise.id, supersetSet),
                                    )
                                  : ExerciseListItem(
                                      exercise: exercise,
                                      isReorderMode: false,
                                      onTap: () => _editExercise(context, ref, exercise),
                                      onDelete: () => _deleteExercise(ref, exercise.id),
                                      onEdit: () => _editExercise(context, ref, exercise),
                                      onReplace: () => _replaceExercise(context, ref, exercise),
                                      onSetUpdate: (updatedSet) => _updateExerciseSet(ref, exercise.id, updatedSet),
                                      onSetToggleComplete: (updatedSet) => _updateExerciseSet(ref, exercise.id, updatedSet),
                                      onExerciseUpdate: (updatedExercise) => _updateExercise(ref, updatedExercise),
                                    ),
                            ),
                          );
                        },
                      ),
          ),

          // 📱 Banner Ad (non-invasive, at bottom)
          // ⚡ REPAINT OPTIMIZATION: RepaintBoundary isolates static banner from list repaints
          if (workout.exercises.isNotEmpty)
            RepaintBoundary(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget _buildEmptyExerciseList(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
  size: AppIconSize.medium,
  color: context.colors.onSurface.withValues(alpha: 0.3,
),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noExercisesYet,
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.tapToAddExercise,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _startQuickWorkout(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const ContextGatheringBottomSheet(),
    );
  }

  void _startNewWorkout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.newWorkout),
        content: TextField(
          decoration: InputDecoration(
            labelText: context.l10n.workoutName,
            hintText: context.l10n.workoutNameHint,
          ),
          onSubmitted: (name) {
            if (name.isNotEmpty) {
              ref.read(currentWorkoutProvider.notifier).createWorkout(name);
              ref.read(currentWorkoutProvider.notifier).startWorkout();
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(currentWorkoutProvider.notifier).createWorkout('Quick Workout');
              ref.read(currentWorkoutProvider.notifier).startWorkout();
              Navigator.pop(context);
            },
            child: Text(context.l10n.start),
          ),
        ],
      ),
    );
  }

  void _startTemplateWorkout(BuildContext context, WidgetRef ref, String templateName) {
    ref.read(currentWorkoutProvider.notifier).createWorkout(templateName);
    ref.read(currentWorkoutProvider.notifier).startWorkout();
    
    // Add template exercises based on template name
    // This is simplified - in a real app you'd have proper templates
    if (templateName == 'Upper Body') {
      _addTemplateExercises(ref, [
        ('Panca Piana', ExerciseCategory.chest),
        ('Trazioni', ExerciseCategory.back),
        ('Shoulder Press', ExerciseCategory.shoulders),
      ]);
    }
  }

  void _addTemplateExercises(WidgetRef ref, List<(String, ExerciseCategory)> exercises) {
    for (final (name, category) in exercises) {
      final exercise = Exercise(
        name: name,
        type: ExerciseType.single,
        category: category,
        sets: [
          ExerciseSet(setNumber: 1, weight: 0, reps: 10),
          ExerciseSet(setNumber: 2, weight: 0, reps: 10),
          ExerciseSet(setNumber: 3, weight: 0, reps: 10),
        ],
      );
      ref.read(currentWorkoutProvider.notifier).addExercise(exercise);
    }
  }

  void _showAddExercise(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddExerciseModal(),
    );
  }

  void _showCreateTemplateModal(BuildContext context) {
    // Per ora naviga alla schermata dei template
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WorkoutTemplatesScreen(),
      ),
    );

    // In futuro potrebbe mostrare un modal per creare direttamente un template
    SnackBarService.showInfo(
      context,
      context.l10n.templateUseFunctionComingSoon,
    );
  }

  void _showCreateTemplateManually(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreateTemplateModal(),
    );
  }

  void _editExercise(BuildContext context, WidgetRef ref, Exercise exercise) {
    // TODO: Implement exercise editing
    SnackBarService.showInfo(
      context,
      context.l10n.exerciseEditingComingSoon,
    );
  }

  void _deleteExercise(WidgetRef ref, String exerciseId) {
    ref.read(currentWorkoutProvider.notifier).removeExercise(exerciseId);
  }

  void _replaceExercise(BuildContext context, WidgetRef ref, Exercise exercise) {
    // TODO: Implement exercise replacement with similar exercises
    SnackBarService.showInfo(
      context,
      context.l10n.exerciseReplacementComingSoon,
    );
  }

  Future<void> _updateExerciseSet(WidgetRef ref, String exerciseId, ExerciseSet updatedSet) async {
    ref.read(currentWorkoutProvider.notifier).updateExerciseSet(exerciseId, updatedSet);

    // PHASE 2: Track first set completed for beginner guidance
    if (updatedSet.isCompleted) {
      final onboardingState = ref.read(onboardingProvider);
      if (onboardingState.isInGuidedFirstWorkout && !onboardingState.hasCompletedFirstSet) {
        await ref.read(onboardingProvider.notifier).markFirstSetCompleted();

        // Show rest timer explanation overlay after first set
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 500), () async {
            if (mounted) {
              await ContextualOverlayManager.show(
                context: context,
                ref: ref,
                overlayId: 'restTimerExplain',
                targetKey: _addExerciseFABKey, // TODO: Should target timer widget if visible
                message: ContextualOverlayManager.commonOverlays['restTimerExplain']!.message,
                actionLabel: ContextualOverlayManager.commonOverlays['restTimerExplain']!.actionLabel,
              );

              // Mark rest timer explanation as seen
              await ref.read(onboardingProvider.notifier).markRestTimerExplanationSeen();
            }
          });
        }

        if (kDebugMode) {
          debugPrint('✅ PHASE 2: First set completed, rest timer explanation shown');
        }
      }
    }
  }

  void _updateSupersetSet(WidgetRef ref, String exerciseId, SupersetSet updatedSupersetSet) {
    ref.read(currentWorkoutProvider.notifier).updateSupersetSet(exerciseId, updatedSupersetSet);
  }

  void _updateExercise(WidgetRef ref, Exercise updatedExercise) {
    if (kDebugMode) {
      debugPrint('🎯 _updateExercise called in WorkoutScreen');
    }
    if (kDebugMode) {
      debugPrint('🎯 Exercise to update: ${updatedExercise.name}');
    }
    if (kDebugMode) {
      debugPrint('🎯 Rest time: ${updatedExercise.restTime}');
    }
    
    try {
      ref.read(currentWorkoutProvider.notifier).updateExerciseOnly(updatedExercise);
      if (kDebugMode) {
        debugPrint('✅ Exercise update completed');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ Error in _updateExercise: $e');
      }
      if (kDebugMode) {
        debugPrint('Stack: $stack');
      }
    }
  }

  Future<void> _completeWorkout(BuildContext context, WidgetRef ref) async {
    // PHASE 2: Track first workout completed for beginner guidance
    final onboardingState = ref.read(onboardingProvider);
    if (onboardingState.isInGuidedFirstWorkout) {
      await ref.read(onboardingProvider.notifier).markFirstWorkoutCompleted();

      if (kDebugMode) {
        debugPrint('🎉 PHASE 2: First workout completed! Phase 2 complete');
      }
    }

    // ✅ NEW: Immediate completion without confirmation dialog
    // Save workout immediately
    ref.read(currentWorkoutProvider.notifier).completeWorkout(context);

    // Haptic feedback for completion
    HapticFeedback.mediumImpact();

    // Show SnackBar with Undo button (5 seconds)
    final snackBar = SnackBar(
      content: Text('✅ ${context.l10n.workoutCompletedSuccess}'),
      duration: const Duration(seconds: 5),
      backgroundColor: context.colors.primary,
      action: SnackBarAction(
        label: context.l10n.undo,
        textColor: context.colors.onPrimary,
        onPressed: () {
          // Undo completion - restore workout to "in progress"
          ref.read(currentWorkoutProvider.notifier).undoCompletion();
          SnackBarService.showInfo(
            context,
            context.l10n.workoutResumed,
          );
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // Schedule final cleanup after undo window expires
    Future.delayed(const Duration(seconds: 5), () async {
      // Check if workout is still completed (not undone)
      final currentWorkout = ref.read(currentWorkoutProvider);
      if (currentWorkout != null && currentWorkout.isCompleted) {
        // 🏆 Check for newly detected PRs and show celebration modal
        final newPRs = ref.read(newlyDetectedPRsProvider);
        if (newPRs.isNotEmpty && context.mounted) {
          // Show PR celebration modal for the first PR
          await _showPRCelebrationModal(context, ref, newPRs.first);

          // Clear the PRs from state after showing modal
          ref.read(newlyDetectedPRsProvider.notifier).state = [];
        }

        // Completion is final - show ad and navigate
        // 📱 Show interstitial ad after workout completion
        await Future.delayed(const Duration(milliseconds: 500));

        _interstitialAdService.showAdIfReady(
          onAdClosed: () {
            // Clear workout and navigate after ad is closed (or not shown)
            ref.read(currentWorkoutProvider.notifier).clearWorkout();
            if (context.mounted) {
              context.goNamed('home');
            }
          },
        );

        // If ad didn't show, navigate after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            final stillCompleted = ref.read(currentWorkoutProvider);
            if (stillCompleted != null && stillCompleted.isCompleted) {
              ref.read(currentWorkoutProvider.notifier).clearWorkout();
              context.goNamed('home');
            }
          }
        });
      }
    });
  }

  /// Show PR celebration modal with engagement tracking
  ///
  /// Displays modal for the given PR and tracks user engagement
  /// (viewed, shared, or dismissed). Analytics tracked to Firestore.
  Future<void> _showPRCelebrationModal(
    BuildContext context,
    WidgetRef ref,
    PRCelebration celebration,
  ) async {
    if (!context.mounted) return;

    final celebrationRepo = ref.read(prCelebrationRepositoryProvider);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [WorkoutScreen] Cannot show PR modal: user not authenticated');
      }
      return;
    }

    // Track that user viewed the modal
    await celebrationRepo.trackEngagement(
      userId,
      celebration.prId,
      CelebrationEngagement.viewed,
    );

    if (!context.mounted) return;

    // Show the celebration modal
    await showDialog(
      context: context,
      barrierDismissible: false, // Require user action
      builder: (_) => PRCelebrationModal(
        celebration: celebration,
        onShare: () async {
          // Track share engagement
          await celebrationRepo.trackEngagement(
            userId,
            celebration.prId,
            CelebrationEngagement.shared,
          );

          // TODO: Implement actual sharing (Task 3.6 or later)
          if (context.mounted) {
            SnackBarService.showSuccess(
              context,
              'PR shared! 🎉', // TODO: Localize
            );
            Navigator.of(context).pop();
          }
        },
        onDismiss: () async {
          // Track dismiss engagement
          await celebrationRepo.trackEngagement(
            userId,
            celebration.prId,
            CelebrationEngagement.dismissed,
          );

          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _showSettingsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          // ⚡ OPTIMIZATION: Use .select() to only rebuild when existence changes
          if (ref.watch(currentWorkoutProvider.select((w) => w != null))) ...[
            ListTile(
              leading: const SemanticIcon(
  icon: AppIcons.saveAlt,
  semanticLabel: 'Save alt',
),
              title: Text(context.l10n.saveAsTemplate),
              subtitle: Text(context.l10n.saveToFirebase),
              onTap: () {
                Navigator.pop(context);
                SaveTemplateHelper.showSaveAsTemplateDialog(context, ref);
              },
            ),
            const Divider(),
            ListTile(
              leading: const SemanticIcon(
  icon: AppIcons.pause,
  semanticLabel: 'Pause',
),
              title: Text(context.l10n.pauseWorkout),
              onTap: () {
                ref.read(currentWorkoutProvider.notifier).pauseWorkout();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: SemanticIcon(
                icon: AppIcons.stop,
                semanticLabel: 'End workout',
                size: AppIconSize.medium,
                color: context.errorColor,
              ),
              title: Text(context.l10n.endWorkout),
              onTap: () {
                Navigator.pop(context);
                _completeWorkout(context, ref);
              },
            ),
            const Divider(),
          ],
          ListTile(
            leading: const SemanticIcon(
  icon: AppIcons.tune,
  semanticLabel: 'Tune',
),
            title: Text(context.l10n.customizeWorkout),
            subtitle: Text(context.l10n.rpeTimerMore),
            onTap: () {
              Navigator.pop(context);
              WorkoutCustomizationModalV3.show(context);
            },
          ),
          ListTile(
            leading: const SemanticIcon(
  icon: AppIcons.logout,
  semanticLabel: 'Logout',
),
            title: Text(context.l10n.signOut),
            onTap: () {
              Navigator.pop(context);
              context.go('/login');
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _editTemplateFromQuickStart(BuildContext context, wt.WorkoutTemplate template) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTemplateScreen(template: template),
      ),
    );
  }

  // Condividi template come PDF
  void _shareTemplatePdf(BuildContext context, wt.WorkoutTemplate template) async {
    // Controlla se c'è una preferenza salvata
    final savedPreference = ref.read(pdfPreferencesProvider);

    // Se non c'è preferenza salvata, mostra il dialog
    PdfDetailLevel? selectedLevel = savedPreference;

    if (savedPreference == null) {
      // Mostra dialog per selezionare le opzioni
      selectedLevel = await showPdfExportOptionsDialog(context, ref);

      // Se l'utente ha annullato, esci
      if (selectedLevel == null) {
        return;
      }
    }

    // Mostra loading
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LoadingIndicator(),
                  const SizedBox(height: 16),
                  Text(context.l10n.generatingPdf),
                ],
              ),
            ),
          ),
        ),
      );
    }

    try {
      // Genera e condividi PDF con il livello di dettaglio selezionato
      await PdfTemplateService.shareTemplatePdf(
        template,
        detailLevel: selectedLevel!,
      );

      // Chiudi loading
      if (context.mounted) {
        Navigator.pop(context);
        SnackBarService.showSuccess(
          context,
          '✅ PDF condiviso con successo!',
        );
      }
    } catch (e) {
      // Chiudi loading e mostra errore
      if (context.mounted) {
        Navigator.pop(context);
        SnackBarService.showError(
          context,
          '❌ Errore nella condivisione: ${e.toString()}',
        );
      }
    }
  }

  // Stampa template
  void _printTemplatePdf(BuildContext context, wt.WorkoutTemplate template) async {
    // Controlla se c'è una preferenza salvata
    final savedPreference = ref.read(pdfPreferencesProvider);

    // Se non c'è preferenza salvata, mostra il dialog
    PdfDetailLevel? selectedLevel = savedPreference;

    if (savedPreference == null) {
      // Mostra dialog per selezionare le opzioni
      selectedLevel = await showPdfExportOptionsDialog(context, ref);

      // Se l'utente ha annullato, esci
      if (selectedLevel == null) {
        return;
      }
    }

    // Mostra loading
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LoadingIndicator(),
                  const SizedBox(height: 16),
                  Text(context.l10n.preparingPrint),
                ],
              ),
            ),
          ),
        ),
      );
    }

    try {
      // Prepara per la stampa con il livello di dettaglio selezionato
      await PdfTemplateService.printTemplatePdf(
        template,
        detailLevel: selectedLevel!,
      );

      // Chiudi loading
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Chiudi loading e mostra errore
      if (context.mounted) {
        Navigator.pop(context);
        SnackBarService.showError(
          context,
          '❌ Errore nella stampa: ${e.toString()}',
        );
      }
    }
  }

  void _deleteTemplateFromQuickStart(BuildContext context, WidgetRef ref, wt.WorkoutTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteTemplate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.deleteTemplateQuestion(template.name)),
            const SizedBox(height: 8),
            Text(
              'Questa azione non può essere annullata.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                await ref.read(workoutTemplateNotifierProvider.notifier)
                    .deleteTemplate(template.id);

                if (context.mounted) {
                  SnackBarService.showSuccess(
                    context,
                    context.l10n.templateDeletedSuccessfully(template.name),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  SnackBarService.showError(
                    context,
                    context.l10n.errorWithMessage(e.toString()),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: context.errorColor),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }

  void _duplicateTemplate(BuildContext context, WidgetRef ref, wt.WorkoutTemplate template) async {
    try {
      // Create a duplicate with "(Copia)" suffix
      final duplicatedTemplate = template.copyWith(
        name: '${template.name} (Copia)',
        isCustom: true,
        updatedAt: DateTime.now(),
      );

      // Save to legacy repository
      await ref.read(workoutTemplateNotifierProvider.notifier).saveTemplate(duplicatedTemplate);

      // Invalidate providers to refresh list
      ref.invalidate(customWorkoutTemplatesProvider);

      if (mounted) {
        SnackBarService.showSuccess(
          context,
          context.l10n.workoutTemplateDuplicatedSuccess(duplicatedTemplate.name),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          context.l10n.workoutTemplateDuplicationError(e.toString()),
        );
      }
    }
  }
}

