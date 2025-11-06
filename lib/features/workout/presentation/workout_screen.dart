import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_template_cache_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/add_exercise_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/pdf_export_options_dialog.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_header.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_customization_modal_v2.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/create_template_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/edit_template_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/workout_templates_screen.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/widgets/tier1_minimal_timer_overlay.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_extensions.dart';
import 'package:gymbro_flutter_new/shared/data/services/interstitial_ad_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/adaptive_banner_ad.dart';
import 'package:gymbro_flutter_new/core/config/admob_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:flutter/foundation.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  /// Optional template ID to pre-load when opening the screen
  final String? initialTemplateId;

  /// Session ID for analytics correlation
  final String? sessionId;

  /// Whether this screen was opened from the Smart CTA
  final bool fromSmartCTA;

  const WorkoutScreen({
    super.key,
    this.initialTemplateId,
    this.sessionId,
    this.fromSmartCTA = false,
  });

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> with WidgetsBindingObserver {
  bool _isReorderMode = false;
  final _interstitialAdService = InterstitialAdService();

  @override
  void initState() {
    super.initState();
    // Pre-load interstitial ad for workout completion
    _interstitialAdService.preloadWorkoutCompleteAd();

    // 💾 Add lifecycle observer for force-saving when app goes to background
    WidgetsBinding.instance.addObserver(this);

    // 🚀 Auto-load template from Smart CTA if provided
    if (widget.initialTemplateId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadTemplateAndStart(widget.initialTemplateId!);
      });
    }
  }

  @override
  void dispose() {
    // 💾 Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // 💾 Force save any pending modifications before disposing
    final cacheService = ref.read(workoutTemplateCacheServiceProvider);
    cacheService.forceSave();

    // 💾 Emergency save current workout if active
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout != null && currentWorkout.isActive) {
      final autoSave = ref.read(workoutAutoSaveProvider.notifier);
      autoSave.emergencySave(currentWorkout);
    }

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

    final currentWorkout = ref.watch(currentWorkoutProvider);
    if (kDebugMode) {
      debugPrint('🏗️ Current workout: ${currentWorkout?.name}, exercises: ${currentWorkout?.exercises.length}');
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
            title: Text(currentWorkout?.name ?? context.l10n.myWorkouts),
            leading: currentWorkout != null && currentWorkout.isActive
                ? IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () => _handleBackNavigation(context, ref),
                    tooltip: context.l10n.backToHomeKeepWorkoutActive,
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.goNamed('home'),
                    tooltip: context.l10n.backToHome,
                  ),
            actions: [
            if (currentWorkout != null && currentWorkout.isActive && currentWorkout.exercises.isNotEmpty)
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
                icon: Icon(_isReorderMode ? Icons.done : Icons.swap_vert),
                tooltip: _isReorderMode ? context.l10n.confirmReorder : context.l10n.reorderExercises,
              ),
            if (currentWorkout != null && currentWorkout.isActive)
              IconButton(
                onPressed: () => _completeWorkout(context, ref),
                icon: const Icon(Icons.check_circle),
                tooltip: context.l10n.completeWorkout,
              ),
            IconButton(
              onPressed: () => _showSettingsMenu(context, ref),
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: Stack(
          children: [
            currentWorkout == null 
                ? _buildWelcomeView(context, ref)
                : _buildWorkoutView(context, ref, currentWorkout),
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
            if (currentWorkout == null)
              ExpandableFAB(
                icon: Icons.note_add,
                label: AppLocalizations.of(context).createTemplate,
                options: [
                  ExpandableFabOption(
                    icon: Icons.flash_on,
                    label: context.l10n.startNow,
                    onTap: () => _startQuickWorkout(context, ref),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  ExpandableFabOption(
                    icon: Icons.edit,
                    label: AppLocalizations.of(context).createManually,
                    onTap: () => _showCreateTemplateManually(context),
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.onPrimary,
                  ),
                  ExpandableFabOption(
                    icon: Icons.upload_file,
                    label: AppLocalizations.of(context).importFromJSON,
                    onTap: () => _showImportFromJson(context),
                    backgroundColor: context.colors.secondary,
                    foregroundColor: context.colors.onSecondary,
                  ),
                ],
              )
            else
              DraggableActionButton(
                onPressed: () => _showAddExercise(context, ref),
                icon: Icons.add,
                label: AppLocalizations.of(context).addExercise,
                positionKey: 'workout_screen_fab',
                additionalOptions: [
                  DraggableActionOption(
                    icon: Icons.timer,
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
                    color: Colors.orange,
                  ),
                  DraggableActionOption(
                    icon: Icons.save,
                    label: context.l10n.saveAsTemplate,
                    onTap: () {
                      // Salva workout corrente come template
                      SnackBarService.showInfo(
                        context,
                        context.l10n.saveTemplateFunctionComingSoon,
                      );
                    },
                    color: Colors.blue,
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
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(context.l10n.errorOccurred),
              const SizedBox(height: 8),
              Text('Error: $e', style: const TextStyle(fontSize: 12)),
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
          Container(
            color: context.colors.surface,
            child: TabBar(
              labelColor: context.colors.primary,
              unselectedLabelColor: context.colors.onSurface.withOpacity(0.6),
              indicatorColor: context.colors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: [
                Tab(
                  icon: const Icon(Icons.person),
                  text: context.l10n.yourTemplates,
                ),
                Tab(
                  icon: const Icon(Icons.stars),
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
            Icon(
              isCustomTab ? Icons.note_add : Icons.inventory_2_outlined,
              size: 64,
              color: context.colors.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isCustomTab ? context.l10n.noCustomTemplates : context.l10n.noPredefinedWorkouts,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCustomTab ? context.l10n.createFirstTemplate : context.l10n.predefinedWorkoutsComingSoon,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withOpacity(0.4),
              ),
            ),
            if (isCustomTab) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _showCreateTemplateModal(context),
                icon: const Icon(Icons.add),
                label: Text(context.l10n.createNewTemplate),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return _buildGridTemplateCard(context, ref, template);
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
                    baseColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 36,
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
                            Icon(
                              Icons.format_list_bulleted,
                              size: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              context.l10n.customBadge,
                              style: TextStyle(
                                fontSize: 10,
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
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Template name header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: template.isCustom
                        ? Theme.of(modalContext).colorScheme.primary
                        : Theme.of(modalContext).colorScheme.secondary,
                    size: 28,
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
                            Icon(Icons.format_list_bulleted, size: 14, color: Theme.of(modalContext).colorScheme.onSurface.withOpacity(0.6)),
                            const SizedBox(width: 4),
                            Text(
                              '${template.exercises.length} ${AppLocalizations.of(modalContext).exercises}',
                              style: Theme.of(modalContext).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.timer_outlined, size: 14, color: Theme.of(modalContext).colorScheme.onSurface.withOpacity(0.6)),
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
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.green),
              ),
              title: Text(AppLocalizations.of(modalContext).startWorkout, style: const TextStyle(fontWeight: FontWeight.w500)),
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
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.blue),
                ),
                title: Text(AppLocalizations.of(modalContext).editTemplate, style: const TextStyle(fontWeight: FontWeight.w500)),
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
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share, color: Colors.orange),
              ),
              title: Text(AppLocalizations.of(modalContext).sharePdf, style: const TextStyle(fontWeight: FontWeight.w500)),
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
                  color: Colors.purple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.print, color: Colors.purple),
              ),
              title: Text(AppLocalizations.of(modalContext).print, style: const TextStyle(fontWeight: FontWeight.w500)),
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
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                title: Text(AppLocalizations.of(modalContext).deleteTemplate, style: const TextStyle(fontWeight: FontWeight.w500)),
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
        _QuickStartCard(
          icon: Icons.fitness_center,
          title: context.l10n.upperBody,
          subtitle: context.l10n.upperBodySubtitle,
          color: context.colors.secondary,
          onTap: () => _startTemplateWorkout(context, ref, 'Upper Body'),
        ),
        const SizedBox(height: 12),
        _QuickStartCard(
          icon: Icons.directions_run,
          title: context.l10n.lowerBody,
          subtitle: context.l10n.lowerBodySubtitle,
          color: context.colors.tertiary,
          onTap: () => _startTemplateWorkout(context, ref, 'Lower Body'),
        ),
        const SizedBox(height: 12),
        _QuickStartCard(
          icon: Icons.timer,
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

  void _startWorkoutFromTemplate(BuildContext context, WidgetRef ref, wt.WorkoutTemplate template) async {
    try {
      // Incrementa contatore utilizzo
      await ref.read(workoutTemplateNotifierProvider.notifier).incrementUsage(template.id);

      // Crea workout dal template
      final workoutNotifier = ref.read(currentWorkoutProvider.notifier);
      workoutNotifier.createWorkout(template.name);
      workoutNotifier.startWorkout();

      // Aggiungi esercizi dal template
      final exercises = template.toWorkoutExercises();
      for (final exercise in exercises) {
        workoutNotifier.addExercise(exercise);
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


  void _handleBackNavigation(BuildContext context, WidgetRef ref) {
    final currentWorkout = ref.read(currentWorkoutProvider);
    
    if (currentWorkout != null && currentWorkout.isActive) {
      // Show dialog to confirm navigation while keeping workout active
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.keepWorkoutActive),
          content: const Text(
            'Do you want to go back to Home and keep your workout running in the background?\n\n'
            'You can return to continue your workout anytime.',
          ),
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

  Widget _buildWelcomeView(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Start Card - Most prominent
            Card(
              elevation: 4,
              color: Colors.green.shade50,
              child: InkWell(
                onTap: () => _startQuickWorkout(context, ref),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.flash_on,
                          color: Colors.white,
                          size: 32,
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
                                color: Colors.green.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.startImmediately,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.green.shade700,
                      ),
                    ],
                  ),
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
                                      child: Icon(
                                        Icons.drag_indicator,
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
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
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
                          );
                        },
                      ),
          ),

          // 📱 Banner Ad (non-invasive, at bottom)
          if (workout.exercises.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: AdaptiveBannerAd(
                adUnitId: AdMobConfig.bannerAnalytics,
                height: 50,
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
          Icon(
            Icons.fitness_center,
            size: 64,
            color: context.colors.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noExercisesYet,
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colors.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.tapToAddExercise,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _startQuickWorkout(BuildContext context, WidgetRef ref) {
    // Create workout with today's date
    final now = DateTime.now();
    final workoutName = 'Allenamento ${now.day}/${now.month}/${now.year}';

    // Start the workout immediately - no dialogs, no friction
    ref.read(currentWorkoutProvider.notifier).createWorkout(workoutName);
    ref.read(currentWorkoutProvider.notifier).startWorkout();

    // Show quick feedback
    SnackBarService.showSuccess(
      context,
      '⚡ ${context.l10n.workoutStartedQuickly}',
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

  void _showImportFromJson(BuildContext context) {
    final l10n = context.l10n;
    final TextEditingController jsonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importFromJSON),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: context.colors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.jsonFormat,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.pasteJsonHere,
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: TextField(
                    controller: jsonController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: '{\n  "name": "My Workout",\n  "description": "...",\n  "exercises": [...]\n}',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              if (jsonController.text.trim().isNotEmpty) {
                // Naviga alla schermata template per processare l'import
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WorkoutTemplatesScreen(),
                  ),
                );

                // Mostra feedback temporaneo
                SnackBarService.showInfo(
                  context,
                  context.l10n.useImportFunctionInTemplateScreen,
                );
              }
            },
            child: Text(context.l10n.import),
          ),
        ],
      ),
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

  void _updateExerciseSet(WidgetRef ref, String exerciseId, ExerciseSet updatedSet) {
    ref.read(currentWorkoutProvider.notifier).updateExerciseSet(exerciseId, updatedSet);
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

  void _completeWorkout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.completeWorkout),
        content: Text(context.l10n.completeWorkoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              ref.read(currentWorkoutProvider.notifier).completeWorkout();
              Navigator.pop(context);
              SnackBarService.showSuccess(
                context,
                context.l10n.workoutCompletedSuccess,
              );

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
                  ref.read(currentWorkoutProvider.notifier).clearWorkout();
                  context.goNamed('home');
                }
              });
            },
            child: Text(context.l10n.complete),
          ),
        ],
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
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          if (ref.watch(currentWorkoutProvider) != null) ...[
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: Text(context.l10n.saveAsTemplate),
              subtitle: Text(context.l10n.saveToFirebase),
              onTap: () {
                Navigator.pop(context);
                _SaveTemplateHelper.showSaveAsTemplateDialog(context, ref);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.pause),
              title: Text(context.l10n.pauseWorkout),
              onTap: () {
                ref.read(currentWorkoutProvider.notifier).pauseWorkout();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.stop, color: Colors.red),
              title: Text(context.l10n.endWorkout),
              onTap: () {
                Navigator.pop(context);
                _completeWorkout(context, ref);
              },
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.tune),
            title: Text(context.l10n.customizeWorkout),
            subtitle: Text(context.l10n.rpeTimerMore),
            onTap: () {
              Navigator.pop(context);
              WorkoutCustomizationModalV2.show(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
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
              style: TextStyle(
                fontSize: 12,
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {

  const _QuickStartCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: context.colors.onSurface.withOpacity(0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card speciale per template nei Quick Start
class _TemplateQuickStartCard extends StatelessWidget {

  const _TemplateQuickStartCard({
    required this.template,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });
  final wt.WorkoutTemplate template;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        onLongPress: template.isCustom ? () => _showContextMenu(context) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icona template
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: template.isCustom 
                      ? context.colors.primary.withValues(alpha: 0.1)
                      : context.colors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  template.isCustom ? Icons.person : Icons.star,
                  color: template.isCustom 
                      ? context.colors.primary
                      : context.colors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Info template
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Statistiche mini
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 12,
                          color: context.colors.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${template.exercises.length}',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: context.colors.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${template.estimatedDuration}min',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        if (template.usageCount > 0) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.trending_up,
                            size: 12,
                            color: context.colors.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${template.usageCount}',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Freccia
              Icon(
                Icons.arrow_forward_ios,
                color: context.colors.onSurface.withValues(alpha: 0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    // Haptic feedback per il long press
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            // Titolo
            Row(
              children: [
                Icon(
                  template.isCustom ? Icons.person : Icons.star,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    template.name,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Opzioni menu
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: context.colors.primary,
                ),
              ),
              title: Text(context.l10n.startWorkoutAction),
              subtitle: Text(context.l10n.startWorkoutDescription),
              onTap: () {
                Navigator.of(context).pop();
                onTap();
              },
            ),
            
            if (onEdit != null)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    color: context.colors.secondary,
                  ),
                ),
                title: Text(context.l10n.modifyTemplate),
                subtitle: Text(context.l10n.addOrRemoveExercises),
                onTap: () {
                  Navigator.of(context).pop();
                  onEdit!();
                },
              ),
            
            if (onDelete != null)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
                title: Text(context.l10n.deleteTemplate),
                subtitle: Text(context.l10n.removePermanentlyAction),
                onTap: () {
                  Navigator.of(context).pop();
                  onDelete!();
                },
              ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

}

// Helper class for template saving
class _SaveTemplateHelper {
  static void showSaveAsTemplateDialog(BuildContext context, WidgetRef ref) async {
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout == null) return;

    // Import the provider (assuming it's available)
    // Check user quota
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    
    int usedTemplates = 0;
    int maxTemplates = 10;
    
    if (userDoc.exists) {
      final data = userDoc.data()!;
      final quotaData = data['templateQuota'] as Map<String, dynamic>?;
      if (quotaData != null) {
        usedTemplates = quotaData['usedPrivateTemplates'] ?? 0;
        maxTemplates = quotaData['maxPrivateTemplates'] ?? 10;
      }
    }
    
    // Check if quota exceeded
    if (usedTemplates >= maxTemplates) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.limitReached),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2,
                size: 48,
                color: context.colors.error,
              ),
              const SizedBox(height: 16),
              Text(context.l10n.templateQuotaLimit(maxTemplates)),
              const SizedBox(height: 8),
              const Text(
                'Elimina un template esistente o passa a Premium per avere più spazio.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.ok),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Navigate to premium screen
              },
              child: Text(context.l10n.upgrade),
            ),
          ],
        ),
      );
      return;
    }

    final nameController = TextEditingController(text: currentWorkout.name);
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(context.l10n.saveAsTemplate),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: usedTemplates >= maxTemplates - 2
                    ? Colors.orange.withOpacity(0.2)
                    : context.colors.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$usedTemplates/$maxTemplates',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: usedTemplates >= maxTemplates - 2
                      ? Colors.orange
                      : context.colors.primary,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show warning if close to limit
              if (maxTemplates - usedTemplates <= 2 && maxTemplates - usedTemplates > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Solo ${maxTemplates - usedTemplates} template rimanenti nel piano Free',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.templateName,
                  hintText: context.l10n.templateNameHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.fitness_center),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: context.l10n.description,
                  hintText: context.l10n.descriptionHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.colors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Il template verrà salvato su Firebase e sarà disponibile su tutti i tuoi dispositivi',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: () async {
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              
              if (name.isEmpty) {
                SnackBarService.showWarning(
                  context,
                  context.l10n.enterTemplateName,
                );
                return;
              }
              
              Navigator.of(context).pop();
              
              try {
                // Mostra loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: LoadingIndicator(),
                        ),
                        const SizedBox(width: 16),
                        Text(context.l10n.savingToFirebase),
                      ],
                    ),
                    duration: const Duration(seconds: 30),
                  ),
                );
                
                // Crea e salva il template
                await ref.read(workoutTemplateNotifierProvider.notifier)
                    .createTemplateFromWorkout(
                      name: name,
                      description: description.isEmpty ? 'Template personalizzato' : description,
                      exercises: currentWorkout.exercises,
                      tags: [], // Potremmo aggiungere tags in futuro
                    );
                
                // Rimuovi loading e mostra successo
                ScaffoldMessenger.of(context).clearSnackBars();
                SnackBarService.showCustom(
                  context,
                  message: '✅ ${context.l10n.templateSavedSuccessfully(name)}',
                  backgroundColor: Colors.green,
                  actionLabel: context.l10n.view,
                  onAction: () => context.push('/templates'),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).clearSnackBars();
                
                // Check if it's a quota error
                final errorMessage = e.toString();
                final isQuotaError = errorMessage.contains('quota exceeded');
                
                if (isQuotaError) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(context.l10n.limitReached),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.inventory_2,
                            size: 48,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          Text(errorMessage.replaceAll('Exception: ', '')),
                          const SizedBox(height: 8),
                          const Text(
                            'Elimina template esistenti o passa a Premium.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(context.l10n.ok),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // TODO: Navigate to premium
                          },
                          child: Text(context.l10n.upgrade),
                        ),
                      ],
                    ),
                  );
                } else {
                  SnackBarService.showError(
                    context,
                    context.l10n.savingErrorMessage(errorMessage.replaceAll('Exception: ', '')),
                  );
                }
              }
            },
            icon: const Icon(Icons.cloud_upload),
            label: Text(context.l10n.saveToFirebase),
          ),
        ],
      ),
    );
  }
}
