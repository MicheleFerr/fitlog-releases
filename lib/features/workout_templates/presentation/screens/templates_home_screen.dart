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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
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
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/template_share_sheet.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';

class TemplatesHomeScreen extends ConsumerStatefulWidget {
  const TemplatesHomeScreen({super.key});

  @override
  ConsumerState<TemplatesHomeScreen> createState() => _TemplatesHomeScreenState();
}

class _TemplatesHomeScreenState extends ConsumerState<TemplatesHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = true;

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
    final templateState = ref.watch(templateProvider);

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
                                  value: '${templateState.publicTemplates.length}',
                                  label: l10n.discover,
                                  color: context.colors.secondary,
                                  labelOpacity: labelOpacity,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _buildAnimatedMetricCard(
                                  context,
                                  icon: AppIcons.star,
                                  value: '4.8',
                                  label: l10n.avgRating,
                                  color: context.colors.tertiary,
                                  labelOpacity: labelOpacity,
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
                      Tab(text: l10n.discover),
                      Tab(text: l10n.trending),
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
                    _buildDiscoverTab(context),
                    _buildTrendingTab(context),
                  ],
                ),
              ),
            ],
          ),

          // Draggable FAB with PiP functionality - only on My Templates tab
          if (_tabController.index == 0)
            DraggableActionButton(
              onPressed: () => _createNewTemplate(context),
              icon: AppIcons.add,
              label: l10n.newTemplate,
              positionKey: 'templates_screen_fab',
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.onPrimary,
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
    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);

    return templatesAsync.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
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
                    maxPrivate: TemplateQuota.maxPrivateTemplates,
                    maxPublic: TemplateQuota.maxPublicTemplates,
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
                              borderRadius: BorderRadius.circular(4),
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

      // Create and start workout from template
      final workoutNotifier = ref.read(currentWorkoutProvider.notifier);
      workoutNotifier.createWorkout(template.name);
      workoutNotifier.startWorkout();

      // Add exercises from template
      final exercises = template.toWorkoutExercises();
      for (final exercise in exercises) {
        workoutNotifier.addExercise(exercise);
      }

      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        SnackBarService.showSuccess(context, l10n.workoutStartedFromTemplate(template.name));
        // Navigate to workout tab (separate branch in StatefulShellRoute)
        context.go(AppRoutes.workoutPath);
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(context, 'Error starting workout: $e');
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
          SnackBarService.showError(context, 'Error: $e');
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
        SnackBarService.showError(context, 'Error: $e');
      }
    }
  }

  void _shareTemplate(BuildContext context, workout_template.WorkoutTemplate template) {
    showTemplateShareSheet(context: context, template: template);
  }

  Widget _buildDiscoverTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final templateState = ref.watch(templateProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(templateProvider.notifier).loadPublicTemplates(),
      child: CustomScrollView(
        slivers: [
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.searchTemplates,
                  prefixIcon: SemanticIcon(
                    icon: AppIcons.search,
                    semanticLabel: l10n.search,
                  ),
                  filled: true,
                  fillColor: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: SemanticIcon(
                      icon: AppIcons.tune,
                      semanticLabel: l10n.filters,
                    ),
                    onPressed: () => _showFilters(context),
                  ),
                ),
                onSubmitted: (query) {
                  ref.read(templateProvider.notifier).loadPublicTemplates(
                    searchQuery: query,
                  );
                },
              ),
            ),
          ),

          // Category chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: TemplateCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(category.name.toUpperCase()),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(templateProvider.notifier).loadPublicTemplates(
                            category: category,
                          );
                        } else {
                          ref.read(templateProvider.notifier).loadPublicTemplates();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          // Public templates
          if (templateState.publicTemplates.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(l10n.noPublicTemplatesFound),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final template = templateState.publicTemplates[index];
                    return PublicTemplateCard(
                      template: template,
                      onTap: () => _viewPublicTemplate(context, template),
                      onDownload: () => _downloadTemplate(context, template),
                    );
                  },
                  childCount: templateState.publicTemplates.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrendingTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.trendUp,
            semanticLabel: l10n.trending,
            size: AppIconSize.xxlarge,
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.trendingComingSoon,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
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

class _WorkoutTemplateCard extends ConsumerWidget {
  const _WorkoutTemplateCard({
    required this.template,
    required this.onTap,
    required this.onStartWorkout,
    required this.onDuplicate,
    required this.onShare,
    required this.onDelete,
  });

  final workout_template.WorkoutTemplate template;
  final VoidCallback onTap; // Now goes to Edit
  final VoidCallback onStartWorkout; // Starts workout
  final VoidCallback onDuplicate; // Duplicates template
  final VoidCallback onShare; // Shares template
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(templateStatsProvider(template.id));

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
                                borderRadius: BorderRadius.circular(4),
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
                  statsAsync.when(
                    data: (stats) {
                      if (stats.totalCompletions > 0 && stats.avgDuration != null) {
                        return Text(
                          '${stats.avgDuration!.inMinutes}m',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        );
                      } else {
                        return Text(
                          '~${template.estimatedDuration}m',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        );
                      }
                    },
                    loading: () => Text(
                      '~${template.estimatedDuration}m',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    error: (_, __) => Text(
                      '~${template.estimatedDuration}m',
                      style: context.textTheme.bodySmall?.copyWith(
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
    );
  }
}
