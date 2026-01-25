/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout_templates
/// 🔧 Type: screen
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Riverpod: ConsumerWidget
/// - Firebase: Through providers
///
/// REDESIGNED: Profile-style layout with compact header,
/// metric cards, and DraggableActionButton (PiP).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_stats.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/providers/template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart' as workout_template;
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/template_quota_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/draggable_action_button.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/edit_template_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/pdf_export_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/pdf_preferences_provider.dart';
import 'package:gymbro_flutter_new/features/workout/services/pdf_template_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/presentation/providers/custom_exercise_providers.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/presentation/widgets/custom_exercise_form_sheet.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/providers/default_templates_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/dropset_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/rest_pause_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/superset_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/dropset_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/rest_pause_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/advanced_template_creation_modals.dart';

class TemplatesHomeScreen extends ConsumerStatefulWidget {
  const TemplatesHomeScreen({super.key});

  @override
  ConsumerState<TemplatesHomeScreen> createState() => _TemplatesHomeScreenState();
}

class _TemplatesHomeScreenState extends ConsumerState<TemplatesHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = true;

  // ═══════════════════════════════════════════════════════════════════════════
  // EDGE CASE: Prevent double-tap during save operation
  // ═══════════════════════════════════════════════════════════════════════════
  bool _isSaving = false;

  // Auto-minimize animation state
  bool _isMetricsMinimized = false;
  late AnimationController _minimizeController;
  late Animation<double> _minimizeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    // Setup auto-minimize animation
    _minimizeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _minimizeAnimation = CurvedAnimation(
      parent: _minimizeController,
      curve: Curves.easeInOutCubic,
    );

    // Auto-minimize after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isMetricsMinimized) {
        _minimizeController.forward();
        setState(() => _isMetricsMinimized = true);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _minimizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final myTemplatesAsync = ref.watch(customWorkoutTemplatesProvider);
    // 🔧 PERF FIX: Access templateProvider state safely
    // Note: We read the full state once but only extract the count we need
    final templateState = ref.watch(templateProvider);
    final publicTemplatesCount = templateState.publicTemplates.length;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Static header (back button, title, subtitle)
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sm,
                      AppSpacing.sm,
                      AppSpacing.sm,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row with actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: SemanticIcon(
                                icon: AppIcons.arrowBack,
                                semanticLabel: l10n.back,
                                size: AppIconSize.medium,
                                color: context.colors.onSurfaceVariant,
                              ),
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                            if (_tabController.index == 0)
                              IconButton(
                                icon: SemanticIcon(
                                  icon: _isGridView ? AppIcons.viewList : AppIcons.gridView,
                                  semanticLabel: _isGridView ? l10n.listView : l10n.gridView,
                                  size: AppIconSize.medium,
                                  color: context.colors.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  setState(() => _isGridView = !_isGridView);
                                },
                              )
                            else
                              const SizedBox(width: 48),
                          ],
                        ),

                        // Title and subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.workoutTemplates,
                                style: context.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                l10n.workoutRoutines,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Animated metrics row - minimizes after 3 seconds
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _minimizeAnimation,
                  builder: (context, child) {
                    final progress = _minimizeAnimation.value;
                    // Height goes from 90 (expanded) to 50 (minimized)
                    final height = 90.0 - (40.0 * progress);
                    // Labels fade out
                    final labelOpacity = 1.0 - progress;

                    return GestureDetector(
                      onTap: () {
                        // Toggle minimize on tap
                        if (_isMetricsMinimized) {
                          _minimizeController.reverse();
                        } else {
                          _minimizeController.forward();
                        }
                        setState(() => _isMetricsMinimized = !_isMetricsMinimized);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: SizedBox(
                          height: height,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildAnimatedMetricCard(
                                  context,
                                  icon: AppIcons.folderOutlined,
                                  value: myTemplatesAsync.when(
                                    data: (t) => '${t.length}',
                                    loading: () => '0',
                                    error: (_, __) => '0',
                                  ),
                                  label: l10n.myTemplates,
                                  color: context.colors.primary,
                                  labelOpacity: labelOpacity,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _buildAnimatedMetricCard(
                                  context,
                                  icon: AppIcons.public,
                                  value: '$publicTemplatesCount',
                                  label: l10n.discover,
                                  color: context.colors.secondary,
                                  labelOpacity: labelOpacity,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    final defaultCount = ref.watch(
                                      defaultTemplatesProvider.select(
                                        (state) => state.valueOrNull?.length ?? 30,
                                      ),
                                    );
                                    return _buildAnimatedMetricCard(
                                      context,
                                      icon: AppIcons.science,
                                      value: '$defaultCount',
                                      label: l10n.evidenceBased,
                                      color: context.colors.tertiary,
                                      labelOpacity: labelOpacity,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Tab bar - always visible, pinned
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  tabBar: TabBar(
                    controller: _tabController,
                    indicatorColor: context.colors.primary,
                    indicatorWeight: 3,
                    labelColor: context.colors.primary,
                    unselectedLabelColor: context.colors.onSurfaceVariant,
                    labelStyle: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: [
                      Tab(text: l10n.myTemplates),
                      Tab(text: l10n.exercises),
                      Tab(text: l10n.discover),
                    ],
                  ),
                  backgroundColor: context.colors.surface,
                ),
              ),

              // Tab content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMyTemplatesTab(context),
                    _buildAdvancedTemplatesTab(context),
                    _buildDiscoverTab(context),
                  ],
                ),
              ),
            ],
          ),

          // Draggable FAB with PiP functionality - on My Templates and Exercises tabs
          if (_tabController.index == 0 || _tabController.index == 1)
            DraggableActionButton(
              onPressed: () => _tabController.index == 0
                  ? _createNewTemplate(context)
                  : _showAdvancedTemplateTypeSelector(context),
              icon: AppIcons.add,
              label: _tabController.index == 0 ? l10n.newTemplate : l10n.advancedTechniques,
              positionKey: 'templates_screen_fab',
              backgroundColor: _tabController.index == 0
                  ? context.colors.primary
                  : context.colors.tertiary,
              foregroundColor: _tabController.index == 0
                  ? context.colors.onPrimary
                  : context.colors.onTertiary,
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMetricCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required double labelOpacity,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SemanticIcon(
                icon: icon,
                semanticLabel: label,
                size: AppIconSize.small,
                color: color,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                value,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          if (labelOpacity > 0.01) ...[
            const SizedBox(height: AppSpacing.xs),
            Opacity(
              opacity: labelOpacity,
              child: Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMyTemplatesTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);
    final entitlements = ref.watch(tierEntitlementsProvider);

    return templatesAsync.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => Center(
        child: Text(l10n.errorLoadingTemplates),
      ),
      data: (templates) {
        return RefreshIndicator(
          onRefresh: () => ref.refresh(customWorkoutTemplatesProvider.future),
          child: CustomScrollView(
            slivers: [
              // Quota indicator
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: TemplateQuotaIndicator(
                    usedPrivate: templates.where((t) => !t.isPublic).length,
                    usedPublic: templates.where((t) => t.isPublic).length,
                    maxPrivate: entitlements.maxTemplates,
                    maxPublic: entitlements.maxPublicTemplates,
                  ),
                ),
              ),

              // Templates content
              if (templates.isEmpty)
                SliverFillRemaining(
                  child: _EmptyTemplatesState(
                    onCreateTap: () => _createNewTemplate(context),
                  ),
                )
              else
                _isGridView
                    ? _buildMyTemplatesGrid(templates, context)
                    : _buildMyTemplatesList(templates, context),

              // Bottom padding for FAB
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyTemplatesGrid(List<workout_template.WorkoutTemplate> templates, BuildContext context) {
    // 🚀 OPTIMIZATION: Batch load all template stats in one pass
    final allStatsAsync = ref.watch(allTemplateStatsProvider);
    final allStats = allStatsAsync.valueOrNull ?? {};

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final template = templates[index];
            return _WorkoutTemplateCard(
              template: template,
              onTap: () => _editWorkoutTemplate(context, template), // Tap → Edit
              onStartWorkout: () => _openWorkoutTemplate(context, template), // Menu → Start workout
              onDuplicate: () => _duplicateTemplate(context, template),
              onShare: () => _shareTemplate(context, template),
              onDelete: () => _deleteWorkoutTemplate(context, template),
              preloadedStats: allStats[template.id], // Pass pre-calculated stats
            );
          },
          childCount: templates.length,
        ),
      ),
    );
  }

  Widget _buildMyTemplatesList(List<workout_template.WorkoutTemplate> templates, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final template = templates[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                onTap: () => _editWorkoutTemplate(context, template), // Tap → Edit
                leading: CircleAvatar(
                  backgroundColor: context.colors.primaryContainer,
                  child: SemanticIcon(
                    icon: AppIcons.workout,
                    semanticLabel: l10n.workout,
                    size: AppIconSize.small,
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  template.name,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  template.description.isNotEmpty ? template.description : l10n.noDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'start') _openWorkoutTemplate(context, template);
                    if (value == 'duplicate') _duplicateTemplate(context, template);
                    if (value == 'share') _shareTemplate(context, template);
                    if (value == 'delete') _deleteWorkoutTemplate(context, template);
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    // Start Workout option (primary action in menu)
                    PopupMenuItem<String>(
                      value: 'start',
                      child: Row(
                        children: [
                          SemanticIcon(
                            icon: AppIcons.play,
                            semanticLabel: l10n.startWorkout,
                            size: AppIconSize.small,
                            color: context.colors.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            l10n.startWorkout,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    // Duplicate option
                    PopupMenuItem<String>(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          SemanticIcon(
                            icon: AppIcons.copy,
                            semanticLabel: l10n.duplicate,
                            size: AppIconSize.small,
                            color: context.colors.onSurface,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(l10n.duplicate, style: context.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    // Share option
                    PopupMenuItem<String>(
                      value: 'share',
                      child: Row(
                        children: [
                          SemanticIcon(
                            icon: AppIcons.share,
                            semanticLabel: l10n.share,
                            size: AppIconSize.small,
                            color: context.colors.onSurface,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(l10n.share, style: context.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    // Make Public option (future feature - disabled)
                    PopupMenuItem<String>(
                      value: 'make_public',
                      enabled: false,
                      child: Row(
                        children: [
                          SemanticIcon(
                            icon: AppIcons.public,
                            semanticLabel: l10n.makePublic,
                            size: AppIconSize.small,
                            color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            l10n.makePublic,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Soon',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    // Delete option
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          SemanticIcon(
                            icon: AppIcons.delete,
                            semanticLabel: l10n.delete,
                            size: AppIconSize.small,
                            color: context.colors.error,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(l10n.delete, style: context.textTheme.bodyMedium?.copyWith(color: context.colors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: templates.length,
        ),
      ),
    );
  }

  void _openWorkoutTemplate(BuildContext context, workout_template.WorkoutTemplate template) async {
    try {
      // Increment usage count
      await ref.read(workoutTemplateNotifierProvider.notifier).incrementUsage(template.id);

      // Create and start workout from template with templateId for duration tracking
      final workoutNotifier = ref.read(currentWorkoutProvider.notifier);
      workoutNotifier.createWorkout(template.name, templateId: template.id);
      workoutNotifier.startWorkout();

      // Add exercises from template
      final exercises = template.toWorkoutExercises();
      for (final exercise in exercises) {
        workoutNotifier.addExercise(exercise);
      }

      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        SnackBarService.showSuccess(context, context.l10n.workoutStartedFromTemplate(template.name));
        // Navigate to workout tab (separate branch in StatefulShellRoute)
        context.go(AppRoutes.workoutPath);
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(context, context.l10n.errorStartingWorkout);
      }
    }
  }

  void _editWorkoutTemplate(BuildContext context, workout_template.WorkoutTemplate template) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTemplateScreen(template: template),
      ),
    );
  }

  Future<void> _deleteWorkoutTemplate(BuildContext context, workout_template.WorkoutTemplate template) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTemplate),
        content: Text(l10n.confirmDeleteTemplate(template.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(workoutTemplateNotifierProvider.notifier).deleteTemplate(template.id);
        if (context.mounted) {
          SnackBarService.showSuccess(context, l10n.templateDeleted(template.name));
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarService.showError(context, l10n.errorDeleting);
        }
      }
    }
  }

  Future<void> _duplicateTemplate(BuildContext context, workout_template.WorkoutTemplate template) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(workoutTemplateNotifierProvider.notifier).duplicateTemplate(template);
      if (context.mounted) {
        SnackBarService.showSuccess(context, l10n.templateDuplicated(template.name));
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(context, l10n.somethingWentWrong);
      }
    }
  }

  Future<void> _shareTemplate(BuildContext context, workout_template.WorkoutTemplate template) async {
    final l10n = AppLocalizations.of(context);

    // Store navigator before any async gap to avoid context issues
    final navigator = Navigator.of(context);

    // Check saved preference first
    final savedPreference = ref.read(pdfPreferencesProvider);
    var selectedLevel = savedPreference;

    // If no saved preference, show the bottom sheet
    if (savedPreference == null) {
      selectedLevel = await showPdfExportBottomSheet(context, ref);
      if (selectedLevel == null) return; // User cancelled
    }

    // Show loading dialog for PDF generation
    if (context.mounted) {
      unawaited(showDialog(
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
      ));
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
        ShareParams(
          files: [XFile(file.path)],
          subject: template.name,
        ),
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

  Widget _buildDiscoverTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Watch default templates from bundled JSON
    final defaultTemplatesAsync = ref.watch(defaultTemplatesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(defaultTemplatesProvider);
      },
      child: defaultTemplatesAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => Center(child: Text(l10n.errorLoadingTemplates)),
        data: (templates) {
          if (templates.isEmpty) {
            return Center(child: Text(l10n.noTemplatesFound));
          }

          // Group templates by category
          final categories = <String, List<workout_template.WorkoutTemplate>>{};
          for (final t in templates) {
            final cat = t.category ?? 'other';
            categories.putIfAbsent(cat, () => []).add(t);
          }

          // Category display info
          final categoryInfo = {
            'beginner': (l10n.beginner, AppIcons.school),
            'intermediate': (l10n.intermediate, AppIcons.trendUp),
            'advanced': (l10n.advanced, AppIcons.localFireDepartment),
            'home': (l10n.homeWorkouts, AppIcons.home),
            'dumbbell': (l10n.dumbbellOnly, AppIcons.workout),
            'express': (l10n.express, AppIcons.timer),
            'specialty': (l10n.specialty, AppIcons.star),
          };

          // Order of categories
          final orderedCategories = [
            'beginner', 'intermediate', 'advanced',
            'home', 'dumbbell', 'express', 'specialty',
          ];

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            itemCount: orderedCategories.length,
            itemBuilder: (context, index) {
              final categoryKey = orderedCategories[index];
              final categoryTemplates = categories[categoryKey];
              if (categoryTemplates == null || categoryTemplates.isEmpty) {
                return const SizedBox.shrink();
              }

              final (categoryName, categoryIcon) = categoryInfo[categoryKey] ?? (categoryKey, AppIcons.workout);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Compact category header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        SemanticIcon(
                          icon: categoryIcon,
                          semanticLabel: categoryName,
                          size: AppIconSize.small,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          categoryName,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${categoryTemplates.length}',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Horizontal scrollable templates
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryTemplates.length,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final template = categoryTemplates[i];
                        return _CompactTemplateCard(
                          template: template,
                          onTap: () => _previewDefaultTemplate(context, template),
                          onUse: () => _useDefaultTemplate(context, template),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _previewDefaultTemplate(BuildContext context, workout_template.WorkoutTemplate template) {
    HapticFeedback.lightImpact();
    // ═══════════════════════════════════════════════════════════════════════
    // EDGE CASE: Capture parent context before showing modal
    // The modal's context becomes invalid after Navigator.pop()
    // ═══════════════════════════════════════════════════════════════════════
    final parentContext = context;

    // Show template preview bottom sheet
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _DefaultTemplatePreviewSheet(
        template: template,
        onUse: () {
          Navigator.pop(modalContext); // Use modal context to close
          // Use parent context for _useDefaultTemplate (still valid)
          if (parentContext.mounted) {
            _useDefaultTemplate(parentContext, template);
          }
        },
      ),
    );
  }

  Future<void> _useDefaultTemplate(BuildContext context, workout_template.WorkoutTemplate template) async {
    // ═══════════════════════════════════════════════════════════════════════
    // EDGE CASE 1: Prevent double-tap - check if already saving
    // ═══════════════════════════════════════════════════════════════════════
    if (_isSaving) {
      return; // Silently ignore if already saving
    }

    HapticFeedback.mediumImpact();
    final l10n = AppLocalizations.of(context);

    // ═══════════════════════════════════════════════════════════════════════
    // EDGE CASE 2: User not logged in
    // ═══════════════════════════════════════════════════════════════════════
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      if (context.mounted) {
        SnackBarService.showWarning(context, l10n.pleaseLogin);
      }
      return;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EDGE CASE 3: Template with no exercises - warn user
    // ═══════════════════════════════════════════════════════════════════════
    if (template.exercises.isEmpty) {
      if (context.mounted) {
        SnackBarService.showWarning(context, l10n.emptyTemplate);
      }
      return;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EDGE CASE 4: Check template quota BEFORE attempting save
    // ═══════════════════════════════════════════════════════════════════════
    final entitlements = ref.read(tierEntitlementsProvider);
    final existingTemplates = ref.read(customWorkoutTemplatesProvider).valueOrNull ?? [];
    final currentCount = existingTemplates.length;

    if (!entitlements.canSaveTemplate(currentCount)) {
      if (context.mounted) {
        _showQuotaExceededDialog(context, entitlements.maxTemplates);
      }
      return;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EDGE CASE 5: Check for duplicate templates and find next available name
    // Handles: "PPL" -> "PPL (2)" -> "PPL (3)" etc.
    // ═══════════════════════════════════════════════════════════════════════
    final baseName = template.name;
    String finalName = baseName;
    int suffix = 1;

    // Find all existing names (case-insensitive)
    final existingNames = existingTemplates.map((t) => t.name.toLowerCase()).toSet();

    if (existingNames.contains(baseName.toLowerCase())) {
      // Show warning dialog first
      if (context.mounted) {
        final shouldContinue = await _showDuplicateWarningDialog(context, template.name);
        if (!shouldContinue) return;
      }

      // Find next available number
      suffix = 2;
      while (existingNames.contains('$baseName ($suffix)'.toLowerCase())) {
        suffix++;
        // Safety limit to prevent infinite loop
        if (suffix > 99) {
          if (context.mounted) {
            SnackBarService.showError(context, l10n.tooManyDuplicates);
          }
          return;
        }
      }
      finalName = '$baseName ($suffix)';
    }

    // ═══════════════════════════════════════════════════════════════════════
    // Set saving flag and show loading state
    // ═══════════════════════════════════════════════════════════════════════
    setState(() => _isSaving = true);

    if (context.mounted) {
      SnackBarService.showInfo(context, l10n.savingToFirebase);
    }

    // Create a copy of the template for the user with new ID and userId
    final userTemplate = template.copyWith(
      id: const Uuid().v4(),
      isCustom: true,
      usageCount: 0,
      userId: userId,
      name: finalName,
    );

    try {
      // Save as user's template
      final repository = ref.read(workoutTemplateRepositoryProvider);
      await repository.saveTemplate(userTemplate);

      // Refresh templates list
      ref.invalidate(customWorkoutTemplatesProvider);

      // ═══════════════════════════════════════════════════════════════════
      // BEST PRACTICE 2025: Success haptic + View action in snackbar
      // ═══════════════════════════════════════════════════════════════════
      HapticFeedback.heavyImpact(); // Success feedback

      if (mounted && context.mounted) {
        SnackBarService.dismiss(context);
        SnackBarService.showCustom(
          context,
          message: '✅ ${l10n.templateAddedToLibrary}',
          backgroundColor: context.successColor,
          actionLabel: l10n.view,
          onAction: () {
            // EDGE CASE 6: Check mounted before using _tabController
            if (mounted && _tabController.length > 0) {
              _tabController.animateTo(0);
            }
          },
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      // ═══════════════════════════════════════════════════════════════════
      // EDGE CASE 7: Handle specific error types
      // ═══════════════════════════════════════════════════════════════════
      HapticFeedback.vibrate(); // Error feedback

      if (mounted && context.mounted) {
        SnackBarService.dismiss(context);

        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('quota') || errorMessage.contains('limit')) {
          _showQuotaExceededDialog(context, entitlements.maxTemplates);
        } else if (errorMessage.contains('network') || errorMessage.contains('timeout')) {
          SnackBarService.showError(context, l10n.networkError);
        } else if (errorMessage.contains('permission') || errorMessage.contains('unauthenticated')) {
          // EDGE CASE 9: Session expired or permission denied
          SnackBarService.showError(context, l10n.sessionExpired);
        } else {
          SnackBarService.showError(context, l10n.errorSavingTemplate);
        }
      }
    } finally {
      // ═══════════════════════════════════════════════════════════════════
      // EDGE CASE 8: Always reset saving flag, even on error
      // ═══════════════════════════════════════════════════════════════════
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Shows quota exceeded dialog with upgrade option
  void _showQuotaExceededDialog(BuildContext context, int maxTemplates) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: SemanticIcon(
          icon: AppIcons.inventory2,
          semanticLabel: 'quota',
          size: AppIconSize.xlarge,
          color: context.warningColor,
        ),
        title: Text(l10n.templateQuotaExceeded),
        content: Text(l10n.templateQuotaExceededMessage(maxTemplates)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to premium upgrade
            },
            child: Text(l10n.upgrade),
          ),
        ],
      ),
    );
  }

  /// Shows warning when adding duplicate template
  Future<bool> _showDuplicateWarningDialog(BuildContext context, String templateName) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: SemanticIcon(
          icon: AppIcons.warningAmberRounded,
          semanticLabel: 'warning',
          size: AppIconSize.xlarge,
          color: context.warningColor,
        ),
        title: Text(l10n.duplicateTemplate),
        content: Text(l10n.duplicateTemplateMessage(templateName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.addAnyway),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Advanced Templates Tab - Aggregator for all template types
  /// Shows sections for: Singoli, Superset, Dropset, Rest-Pause
  Widget _buildAdvancedTemplatesTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Watch all template providers
    final customExercisesAsync = ref.watch(allCustomExercisesProvider);
    final supersetTemplatesAsync = ref.watch(customSupersetTemplatesProvider);
    final dropsetTemplatesAsync = ref.watch(customDropsetTemplatesProvider);
    final restPauseTemplatesAsync = ref.watch(customRestPauseTemplatesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allCustomExercisesProvider);
        ref.invalidate(customSupersetTemplatesProvider);
        ref.invalidate(customDropsetTemplatesProvider);
        ref.invalidate(customRestPauseTemplatesProvider);
      },
      child: CustomScrollView(
        slivers: [
          // Header with description
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                l10n.advancedTechniques,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Single Exercises Section
          SliverToBoxAdapter(
            child: _buildTemplateSection(
              context,
              title: l10n.standard,
              icon: AppIcons.workout,
              color: context.colors.primary,
              asyncValue: customExercisesAsync,
              emptyMessage: l10n.noCustomExercises,
              itemBuilder: (exercises) => Column(
                children: exercises.take(3).map((exercise) =>
                  _CustomExerciseCard(
                    exercise: exercise,
                    onTap: () => _editExercise(context, exercise),
                    onDelete: () => _deleteExercise(context, exercise),
                  ),
                ).toList(),
              ),
              onViewAll: (customExercisesAsync.valueOrNull?.length ?? 0) > 3 ? () => _showAllCustomExercises(context) : null,
              count: customExercisesAsync.valueOrNull?.length ?? 0,
            ),
          ),

          // Superset Section
          SliverToBoxAdapter(
            child: _buildTemplateSection(
              context,
              title: l10n.superset,
              icon: AppIcons.link,
              color: context.colors.secondary,
              asyncValue: supersetTemplatesAsync,
              emptyMessage: l10n.noSupersetTemplates,
              itemBuilder: (templates) => Column(
                children: templates.take(3).map((template) =>
                  _SupersetTemplateCard(
                    template: template,
                    onTap: () => _editSupersetTemplate(context, template),
                    onDelete: () => _deleteSupersetTemplate(context, template),
                  ),
                ).toList(),
              ),
              onViewAll: (supersetTemplatesAsync.valueOrNull?.length ?? 0) > 3
                  ? () => _showAllSupersetTemplates(context) : null,
              count: supersetTemplatesAsync.valueOrNull?.length ?? 0,
            ),
          ),

          // Dropset Section
          SliverToBoxAdapter(
            child: _buildTemplateSection(
              context,
              title: l10n.dropset,
              icon: AppIcons.trendDown,
              color: context.colors.tertiary,
              asyncValue: dropsetTemplatesAsync,
              emptyMessage: l10n.noDropsetTemplates,
              itemBuilder: (templates) => Column(
                children: templates.take(3).map((template) =>
                  _DropsetTemplateCard(
                    template: template,
                    onTap: () => _editDropsetTemplate(context, template),
                    onDelete: () => _deleteDropsetTemplate(context, template),
                  ),
                ).toList(),
              ),
              onViewAll: (dropsetTemplatesAsync.valueOrNull?.length ?? 0) > 3
                  ? () => _showAllDropsetTemplates(context) : null,
              count: dropsetTemplatesAsync.valueOrNull?.length ?? 0,
            ),
          ),

          // Rest-Pause Section
          SliverToBoxAdapter(
            child: _buildTemplateSection(
              context,
              title: l10n.restPause,
              icon: AppIcons.timer,
              color: context.colors.error,
              asyncValue: restPauseTemplatesAsync,
              emptyMessage: l10n.noRestPauseTemplates,
              itemBuilder: (templates) => Column(
                children: templates.take(3).map((template) =>
                  _RestPauseTemplateCard(
                    template: template,
                    onTap: () => _editRestPauseTemplate(context, template),
                    onDelete: () => _deleteRestPauseTemplate(context, template),
                  ),
                ).toList(),
              ),
              onViewAll: (restPauseTemplatesAsync.valueOrNull?.length ?? 0) > 3
                  ? () => _showAllRestPauseTemplates(context) : null,
              count: restPauseTemplatesAsync.valueOrNull?.length ?? 0,
            ),
          ),

          // Bottom padding for FAB
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  /// Build a collapsible section for each template type
  Widget _buildTemplateSection<T>(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required AsyncValue<List<T>> asyncValue,
    required String emptyMessage,
    required Widget Function(List<T>) itemBuilder,
    VoidCallback? onViewAll,
    required int count,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Row(
            children: [
              Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          initiallyExpanded: count > 0,
          childrenPadding: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          children: [
            asyncValue.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: LoadingIndicator(),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  error.toString(),
                  style: TextStyle(color: context.colors.error),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      emptyMessage,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    itemBuilder(items),
                    if (onViewAll != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: TextButton(
                          onPressed: onViewAll,
                          child: Text(AppLocalizations.of(context).viewAll),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show modal to select template type to create
  void _showAdvancedTemplateTypeSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SafeArea(
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
                    color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                l10n.advancedTechniques,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Options
              _TemplateTypeOption(
                icon: AppIcons.workout,
                title: l10n.standard,
                subtitle: l10n.customExercises,
                color: context.colors.primary,
                onTap: () {
                  Navigator.pop(context);
                  _createNewExercise(context);
                },
              ),
              _TemplateTypeOption(
                icon: AppIcons.link,
                title: l10n.superset,
                subtitle: l10n.supersetDescription,
                color: context.colors.secondary,
                onTap: () {
                  Navigator.pop(context);
                  _createSupersetTemplate(context);
                },
              ),
              _TemplateTypeOption(
                icon: AppIcons.trendDown,
                title: l10n.dropset,
                subtitle: l10n.dropsetDescription,
                color: context.colors.tertiary,
                onTap: () {
                  Navigator.pop(context);
                  _createDropsetTemplate(context);
                },
              ),
              _TemplateTypeOption(
                icon: AppIcons.timer,
                title: l10n.restPause,
                subtitle: l10n.restPauseDescription,
                color: context.colors.error,
                onTap: () {
                  Navigator.pop(context);
                  _createRestPauseTemplate(context);
                },
              ),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // Template CRUD operations
  // ============================================

  void _showAllCustomExercises(BuildContext context) {
    // Navigate to full list view
    context.push('/templates/exercises');
  }

  void _showAllSupersetTemplates(BuildContext context) {
    context.push('/templates/superset');
  }

  void _showAllDropsetTemplates(BuildContext context) {
    context.push('/templates/dropset');
  }

  void _showAllRestPauseTemplates(BuildContext context) {
    context.push('/templates/restpause');
  }

  void _createSupersetTemplate(BuildContext context) {
    SupersetTemplateCreationModal.show(context);
  }

  void _createDropsetTemplate(BuildContext context) {
    DropsetTemplateCreationModal.show(context);
  }

  void _createRestPauseTemplate(BuildContext context) {
    RestPauseTemplateCreationModal.show(context);
  }

  void _editSupersetTemplate(BuildContext context, SupersetTemplate template) {
    // TODO: Implement superset template edit
  }

  void _editDropsetTemplate(BuildContext context, DropsetTemplate template) {
    // TODO: Implement dropset template edit
  }

  void _editRestPauseTemplate(BuildContext context, RestPauseTemplate template) {
    // TODO: Implement rest-pause template edit
  }

  Future<void> _deleteSupersetTemplate(BuildContext context, SupersetTemplate template) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteTemplateConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: context.colors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(supersetTemplateNotifierProvider.notifier)
          .deleteCustomTemplate(template.id);
    }
  }

  Future<void> _deleteDropsetTemplate(BuildContext context, DropsetTemplate template) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteTemplateConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: context.colors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(dropsetTemplateNotifierProvider.notifier)
          .deleteCustomTemplate(template.id);
    }
  }

  Future<void> _deleteRestPauseTemplate(BuildContext context, RestPauseTemplate template) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteTemplateConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: context.colors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(restPauseTemplateNotifierProvider.notifier)
          .deleteCustomTemplate(template.id);
    }
  }

  Widget _buildExerciseQuotaBar(BuildContext context, {required int used, required int max}) {
    final isUnlimited = max >= 999;
    final progress = isUnlimited ? 0.0 : (used / max).clamp(0.0, 1.0);
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.customExercises,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              Text(
                isUnlimited ? '$used' : '$used / $max',
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (!isUnlimited) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: context.colors.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation(context.colors.tertiary),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _createNewExercise(BuildContext context) {
    final entitlements = ref.read(tierEntitlementsProvider);
    final exercisesAsync = ref.read(allCustomExercisesProvider);
    final exerciseCount = exercisesAsync.valueOrNull?.length ?? 0;
    final l10n = AppLocalizations.of(context);

    if (!entitlements.canCreateCustomExercise(exerciseCount)) {
      SnackBarService.showCustom(
        context,
        message: l10n.customExerciseLimit,
        actionLabel: l10n.upgrade,
        onAction: () {
          // TODO: Navigate to premium screen
        },
      );
      return;
    }

    HapticFeedback.mediumImpact();

    CustomExerciseFormSheet.show(
      context,
      onSave: (_) {}, // Refresh handled by stream provider
    );
  }

  void _editExercise(BuildContext context, CustomExercise exercise) {
    CustomExerciseFormSheet.show(
      context,
      existingCustom: exercise,
      onSave: (_) {}, // Refresh handled by stream provider
    );
  }

  Future<void> _deleteExercise(BuildContext context, CustomExercise exercise) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteExerciseDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final repository = ref.read(customExerciseRepositoryProvider);
        await repository.delete(exercise.id);
        if (context.mounted) {
          SnackBarService.showSuccess(context, l10n.exerciseDeleted);
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarService.showError(context, l10n.errorDeleting);
        }
      }
    }
  }

  void _createNewTemplate(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final availablePrivate = ref.read(templateProvider.notifier)
        .getAvailableTemplateCount(TemplateVisibility.private);

    if (availablePrivate <= 0) {
      SnackBarService.showCustom(
        context,
        message: l10n.maxTemplatesReached,
        actionLabel: l10n.upgrade,
        onAction: () {
          // TODO: Navigate to premium screen
        },
      );
      return;
    }

    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.createTemplate,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SemanticIcon(
                  icon: AppIcons.edit,
                  semanticLabel: l10n.createManually,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
              title: Text(l10n.createManually),
              subtitle: Text(l10n.buildFromScratch),
              onTap: () {
                Navigator.pop(context);
                // Create a new empty template and navigate to edit screen
                final userId = ref.read(currentUserIdProvider);
                final newTemplate = workout_template.WorkoutTemplate(
                  name: l10n.newTemplate,
                  description: '',
                  exercises: [],
                  estimatedDuration: 45,
                  tags: [],
                  isCustom: true,
                  userId: userId, // ✅ Required for Firestore security rules
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditTemplateScreen(template: newTemplate),
                  ),
                );
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _viewPublicTemplate(BuildContext context, WorkoutTemplate template) {
    context.push(AppRoutes.templateDetailPath, extra: template.id);
  }

  Future<void> _downloadTemplate(BuildContext context, WorkoutTemplate template) async {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.mediumImpact();

    final success = await ref.read(templateProvider.notifier)
        .downloadTemplate(template.id);

    if (success) {
      SnackBarService.showSuccess(
        context,
        l10n.templateDownloaded(template.name),
      );
    } else {
      SnackBarService.showError(
        context,
        l10n.failedToDownload,
      );
    }
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const TemplateFiltersSheet(),
    );
  }
}

// ============================================================================
// SLIVER TAB BAR DELEGATE
// ============================================================================

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate({
    required this.tabBar,
    required this.backgroundColor,
  });

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
           backgroundColor != oldDelegate.backgroundColor;
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class _EmptyTemplatesState extends StatelessWidget {
  const _EmptyTemplatesState({required this.onCreateTap});

  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: SemanticIcon(
              icon: AppIcons.workout,
              semanticLabel: l10n.workout,
              size: AppIconSize.xxlarge,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.noTemplatesYet,
            style: context.textTheme.titleLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.createFirstTemplate,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onCreateTap,
            icon: SemanticIcon(
              icon: AppIcons.add,
              semanticLabel: l10n.createTemplate,
            ),
            label: Text(l10n.createTemplate),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SUPPORTING WIDGETS
// ============================================================================

class TemplateFiltersSheet extends StatelessWidget {
  const TemplateFiltersSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(l10n.filtersComingSoon),
    );
  }
}

class PublicTemplateCard extends StatelessWidget {
  const PublicTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onDownload,
  });

  final WorkoutTemplate template;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: template.authorPhotoUrl != null
                        ? NetworkImage(template.authorPhotoUrl!)
                        : null,
                    child: template.authorPhotoUrl == null
                        ? SemanticIcon(
                            icon: AppIcons.person,
                            semanticLabel: l10n.profile,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
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
                        Text(
                          l10n.byAuthor(template.authorName ?? l10n.anonymous),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onDownload,
                    icon: SemanticIcon(
                      icon: AppIcons.download,
                      semanticLabel: l10n.downloadNow,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: context.colors.primaryContainer,
                    ),
                  ),
                ],
              ),
              if (template.description != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  template.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.star,
                    semanticLabel: l10n.rating,
                    size: AppIconSize.tiny,
                    color: context.colors.warning,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    template.averageRating.toStringAsFixed(1),
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '(${template.reviewCount})',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SemanticIcon(
                    icon: AppIcons.download,
                    semanticLabel: l10n.downloaded,
                    size: AppIconSize.tiny,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${template.downloadCount}',
                    style: context.textTheme.bodySmall,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SemanticIcon(
                    icon: AppIcons.workout,
                    semanticLabel: l10n.exercises,
                    size: AppIconSize.tiny,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    l10n.exercisesCount(template.exercises.length),
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyExercisesState extends StatelessWidget {
  const _EmptyExercisesState({required this.onCreateTap});

  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: SemanticIcon(
              icon: AppIcons.workout,
              semanticLabel: l10n.noExercisesYet,
              size: AppIconSize.xxlarge,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.noExercisesYet,
            style: context.textTheme.titleLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.createCustomExercise,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onCreateTap,
            icon: SemanticIcon(
              icon: AppIcons.add,
              semanticLabel: l10n.createCustomExercise,
            ),
            label: Text(l10n.createCustomExercise),
          ),
        ],
      ),
    );
  }
}

class _CustomExerciseCard extends StatelessWidget {
  const _CustomExerciseCard({
    required this.exercise,
    required this.onTap,
    required this.onDelete,
  });

  final CustomExercise exercise;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.colors.tertiaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: SemanticIcon(
              icon: exercise.isVariant ? AppIcons.copy : AppIcons.workout,
              semanticLabel: exercise.nome,
              size: AppIconSize.small,
              color: context.colors.tertiary,
            ),
          ),
        ),
        title: Text(
          exercise.nome,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          exercise.isVariant
              ? l10n.variant
              : '${exercise.focus} • ${exercise.tipoEsercizio}',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onTap();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.edit,
                    semanticLabel: l10n.edit,
                    size: AppIconSize.small,
                    color: context.colors.onSurface,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(l10n.edit, style: context.textTheme.bodyMedium),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.delete,
                    semanticLabel: l10n.delete,
                    size: AppIconSize.small,
                    color: context.colors.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.delete,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.error,
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
}

class _WorkoutTemplateCard extends ConsumerWidget {
  const _WorkoutTemplateCard({
    required this.template,
    required this.onTap,
    required this.onStartWorkout,
    required this.onDuplicate,
    required this.onShare,
    required this.onDelete,
    this.preloadedStats,
  });

  final workout_template.WorkoutTemplate template;
  final VoidCallback onTap; // Now goes to Edit
  final VoidCallback onStartWorkout; // Starts workout
  final VoidCallback onDuplicate; // Duplicates template
  final VoidCallback onShare; // Shares template
  final VoidCallback onDelete;

  /// Pre-calculated stats from parent (optimization: avoids N provider calls)
  final TemplateStats? preloadedStats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // 🚀 OPTIMIZATION: Use preloaded stats if available
    final TemplateStats? stats;
    if (preloadedStats != null) {
      stats = preloadedStats;
    } else {
      final statsAsync = ref.watch(templateStatsProvider(template.id));
      stats = statsAsync.valueOrNull;
    }

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: SemanticIcon(
                      icon: AppIcons.workout,
                      semanticLabel: l10n.workout,
                      size: AppIconSize.small,
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: SemanticIcon(
                      icon: AppIcons.moreVert,
                      semanticLabel: l10n.more,
                      size: AppIconSize.small,
                    ),
                    onSelected: (value) {
                      if (value == 'start') onStartWorkout();
                      if (value == 'duplicate') onDuplicate();
                      if (value == 'share') onShare();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      // Start Workout option (primary action in menu)
                      PopupMenuItem(
                        value: 'start',
                        child: Row(
                          children: [
                            SemanticIcon(
                              icon: AppIcons.play,
                              semanticLabel: l10n.startWorkout,
                              size: AppIconSize.small,
                              color: context.colors.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              l10n.startWorkout,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      // Duplicate option
                      PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            SemanticIcon(
                              icon: AppIcons.copy,
                              semanticLabel: l10n.duplicate,
                              size: AppIconSize.small,
                              color: context.colors.onSurface,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(l10n.duplicate, style: context.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      // Share option
                      PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            SemanticIcon(
                              icon: AppIcons.share,
                              semanticLabel: l10n.share,
                              size: AppIconSize.small,
                              color: context.colors.onSurface,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(l10n.share, style: context.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      // Make Public option (future feature - disabled)
                      PopupMenuItem(
                        value: 'make_public',
                        enabled: false, // Disabled for now
                        child: Row(
                          children: [
                            SemanticIcon(
                              icon: AppIcons.public,
                              semanticLabel: l10n.makePublic,
                              size: AppIconSize.small,
                              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              l10n.makePublic,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Soon',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      // Delete option
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            SemanticIcon(
                              icon: AppIcons.delete,
                              semanticLabel: l10n.delete,
                              size: AppIconSize.small,
                              color: context.colors.error,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              l10n.delete,
                              style: context.textTheme.bodyMedium?.copyWith(color: context.colors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                template.name,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const Spacer(),

            // Stats
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.workout,
                    semanticLabel: l10n.exercises,
                    size: AppIconSize.tiny,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${template.exercises.length}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SemanticIcon(
                    icon: AppIcons.timer,
                    semanticLabel: l10n.duration,
                    size: AppIconSize.tiny,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  // Duration display: real average or estimated
                  if (stats != null && stats.totalCompletions > 0 && stats.avgDuration != null)
                    Text(
                      '${stats.avgDuration!.inMinutes}m',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.success, // Green for real data
                      ),
                    )
                  else
                    Text(
                      '~${template.estimatedDuration}m',
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
    );
  }
}

// ============================================================================
// Helper Widgets for Discover Tab
// ============================================================================

/// Compact template card for horizontal scroll
class _CompactTemplateCard extends StatelessWidget {
  const _CompactTemplateCard({
    required this.template,
    required this.onTap,
    required this.onUse,
  });

  final workout_template.WorkoutTemplate template;
  final VoidCallback onTap;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: 180,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Template name (with ellipsis for long names)
                Text(
                  template.name,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Stats row
                Row(
                  children: [
                    SemanticIcon(
                      icon: AppIcons.workout,
                      semanticLabel: l10n.exercises,
                      size: AppIconSize.tiny,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${template.exercises.length}',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SemanticIcon(
                      icon: AppIcons.timer,
                      semanticLabel: l10n.duration,
                      size: AppIconSize.tiny,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    // Handle null/0 duration gracefully
                    Text(
                      '${template.estimatedDuration ?? 0}\'',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Use button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: onUse,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: const Size(0, 32),
                    ),
                    child: Text(
                      AppLocalizations.of(context).use,
                      style: context.textTheme.labelSmall,
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

/// Difficulty filter chip
class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({
    required this.label,
    this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      onSelected: (_) => onTap(),
      showCheckmark: false,
    );
  }
}

/// Section header for template groups
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.colors.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SemanticIcon(
            icon: icon,
            semanticLabel: title,
            size: AppIconSize.medium,
            color: context.colors.onSecondaryContainer,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
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
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Card for displaying a default template
class _DefaultTemplateCard extends StatelessWidget {
  const _DefaultTemplateCard({
    required this.template,
    required this.onTap,
    required this.onUse,
  });

  final workout_template.WorkoutTemplate template;
  final VoidCallback onTap;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          template.description,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: onUse,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                    child: Text(l10n.use),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Stats row
              Row(
                children: [
                  // Exercises count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SemanticIcon(
                          icon: AppIcons.workout,
                          semanticLabel: l10n.exercises,
                          size: AppIconSize.tiny,
                          color: context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${template.exercises.length} ${l10n.exercises}',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Duration
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SemanticIcon(
                          icon: AppIcons.timer,
                          semanticLabel: l10n.duration,
                          size: AppIconSize.tiny,
                          color: context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '~${template.estimatedDuration}m',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Tags
                  if (template.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: template.tags.take(2).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.onPrimaryContainer,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Preview sheet for default template
class _DefaultTemplatePreviewSheet extends StatelessWidget {
  const _DefaultTemplatePreviewSheet({
    required this.template,
    required this.onUse,
  });

  final workout_template.WorkoutTemplate template;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Only show difficulty badge if difficulty is not null
                              if (template.difficulty != null && template.difficulty!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    template.difficulty!.toUpperCase(),
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: context.colors.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (template.difficulty != null && template.difficulty!.isNotEmpty)
                                const SizedBox(width: AppSpacing.sm),
                              Text(
                                '${template.exercises.length} ${l10n.exercises}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '~${template.estimatedDuration}m',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: SemanticIcon(
                        icon: AppIcons.close,
                        semanticLabel: l10n.close,
                        size: AppIconSize.medium,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  template.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Exercises list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: template.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = template.exercises[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: context.colors.secondaryContainer,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: context.colors.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(exercise.exerciseName),
                      subtitle: Text(
                        '${exercise.sets.length} set × ${exercise.sets.firstOrNull?.targetReps ?? 0} rep',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      trailing: exercise.notes != null && exercise.notes!.isNotEmpty
                          ? IconButton(
                              onPressed: () => _showExerciseNotes(
                                context,
                                exercise.exerciseName,
                                exercise.notes!,
                              ),
                              icon: SemanticIcon(
                                icon: AppIcons.infoOutline,
                                semanticLabel: l10n.notes,
                                size: AppIconSize.small,
                                color: context.colors.primary,
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),

              // Use button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onUse,
                    icon: SemanticIcon(
                      icon: AppIcons.add,
                      semanticLabel: l10n.add,
                      size: AppIconSize.small,
                    ),
                    label: Text(l10n.addToMyTemplates),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows exercise notes in a dialog
  void _showExerciseNotes(
    BuildContext context,
    String exerciseName,
    String notes,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          exerciseName.isNotEmpty ? exerciseName : 'Note',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          notes,
          style: context.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).ok),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ADVANCED TEMPLATE CARDS
// ============================================================================

/// Option tile for template type selection modal
class _TemplateTypeOption extends StatelessWidget {
  const _TemplateTypeOption({
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
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          AppIcons.chevronRight,
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Card for displaying a superset template
class _SupersetTemplateCard extends StatelessWidget {
  const _SupersetTemplateCard({
    required this.template,
    required this.onTap,
    required this.onDelete,
  });

  final SupersetTemplate template;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.colors.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: SemanticIcon(
              icon: AppIcons.link,
              semanticLabel: l10n.superset,
              size: AppIconSize.small,
              color: context.colors.secondary,
            ),
          ),
        ),
        title: Text(
          template.name,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${template.exerciseIds.length} ${l10n.exercises}',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onTap();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.edit,
                    semanticLabel: l10n.edit,
                    size: AppIconSize.small,
                    color: context.colors.onSurface,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(l10n.edit, style: context.textTheme.bodyMedium),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.delete,
                    semanticLabel: l10n.delete,
                    size: AppIconSize.small,
                    color: context.colors.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.delete,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.error,
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
}

/// Card for displaying a dropset template
class _DropsetTemplateCard extends StatelessWidget {
  const _DropsetTemplateCard({
    required this.template,
    required this.onTap,
    required this.onDelete,
  });

  final DropsetTemplate template;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.colors.tertiaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: SemanticIcon(
              icon: AppIcons.trendDown,
              semanticLabel: l10n.dropset,
              size: AppIconSize.small,
              color: context.colors.tertiary,
            ),
          ),
        ),
        title: Text(
          template.name,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${template.drops} drops • ${template.exerciseName}',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onTap();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.edit,
                    semanticLabel: l10n.edit,
                    size: AppIconSize.small,
                    color: context.colors.onSurface,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(l10n.edit, style: context.textTheme.bodyMedium),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.delete,
                    semanticLabel: l10n.delete,
                    size: AppIconSize.small,
                    color: context.colors.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.delete,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.error,
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
}

/// Card for displaying a rest-pause template
class _RestPauseTemplateCard extends StatelessWidget {
  const _RestPauseTemplateCard({
    required this.template,
    required this.onTap,
    required this.onDelete,
  });

  final RestPauseTemplate template;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.colors.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: SemanticIcon(
              icon: AppIcons.timer,
              semanticLabel: l10n.restPause,
              size: AppIconSize.small,
              color: context.colors.error,
            ),
          ),
        ),
        title: Text(
          template.name,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${template.pauseDuration}s rest • ${template.exerciseName}',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onTap();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.edit,
                    semanticLabel: l10n.edit,
                    size: AppIconSize.small,
                    color: context.colors.onSurface,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(l10n.edit, style: context.textTheme.bodyMedium),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.delete,
                    semanticLabel: l10n.delete,
                    size: AppIconSize.small,
                    color: context.colors.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.delete,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.error,
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
}
