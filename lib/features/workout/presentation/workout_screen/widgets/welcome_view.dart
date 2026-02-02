import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart'
    as wt;
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/swipeable_template_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Welcome/empty state view displayed when no workout is active.
///
/// Features a prominent "Quick Start" card at the top that triggers
/// the context-gathering flow, followed by tabbed template lists
/// (custom and predefined templates).
class WelcomeView extends ConsumerWidget {
  const WelcomeView({
    required this.onQuickStart,
    required this.onStartTemplate,
    required this.onShareTemplate,
    required this.onDuplicateTemplate,
    required this.onEditTemplate,
    required this.onDeleteTemplate,
    required this.onCreateTemplate,
    this.onScheduleTemplate,
    this.onRefreshTemplate,
    this.onViewTemplate,
    super.key,
  });

  /// Callback when the user taps the quick start button
  final VoidCallback onQuickStart;

  /// Callback when the user starts a workout from a template
  final void Function(wt.WorkoutTemplate template) onStartTemplate;

  /// Callback when the user wants to share a template as PDF
  final void Function(wt.WorkoutTemplate template) onShareTemplate;

  /// Callback when the user wants to duplicate a template
  final void Function(wt.WorkoutTemplate template) onDuplicateTemplate;

  /// Callback when the user wants to edit a template
  final void Function(wt.WorkoutTemplate template) onEditTemplate;

  /// Callback when the user wants to delete a template
  final void Function(wt.WorkoutTemplate template) onDeleteTemplate;

  /// Callback when the user wants to create a new template
  final VoidCallback onCreateTemplate;

  /// Callback when the user wants to schedule a template (swipe right action)
  final void Function(wt.WorkoutTemplate template)? onScheduleTemplate;

  /// Callback when the user wants to refresh template from database (sync TUT)
  final void Function(wt.WorkoutTemplate template)? onRefreshTemplate;

  /// Callback when the user wants to view a template in presentation mode
  final void Function(wt.WorkoutTemplate template)? onViewTemplate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Start Card - Most prominent (Elevated design with gradient)
            _buildQuickStartCard(context),
            const SizedBox(height: AppSpacing.md),

            // Quick Start e Template
            Expanded(child: _buildQuickStartList(context, ref)),
          ],
        ),
      ),
    );
  }

  /// Builds the prominent quick start card - Clean Apple-style CTA
  Widget _buildQuickStartCard(BuildContext context) {
    return Material(
      color: context.colors.surface.withValues(alpha: 0),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onQuickStart,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colors.primary,
                HSLColor.fromColor(context.colors.primary)
                    .withLightness(
                      (HSLColor.fromColor(context.colors.primary).lightness -
                              0.08)
                          .clamp(0.0, 1.0),
                    )
                    .toColor(),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                // Clean icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.colors.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SemanticIcon(
                    icon: AppIcons.flashOn,
                    semanticLabel: 'Start workout now',
                    size: AppIconSize.large,
                    color: context.colors.onPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.startNow,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.startImmediately,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onPrimary.withValues(
                            alpha: 0.85,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Simple chevron
                SemanticIcon(
                  icon: AppIcons.forwardIos,
                  semanticLabel: 'Start',
                  size: AppIconSize.small,
                  color: context.colors.onPrimary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the tabbed template list (custom and predefined)
  Widget _buildQuickStartList(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2, // I Tuoi Template, Schede Predefinite
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Bar - Clean text-only design matching Apple Fitness+ style
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              labelColor: context.colors.onSurface,
              unselectedLabelColor: context.colors.onSurface.withValues(
                alpha: 0.5,
              ),
              indicator: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.shadow.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: context.colors.surface.withValues(alpha: 0),
              labelStyle: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: context.textTheme.labelLarge,
              padding: const EdgeInsets.all(4),
              labelPadding: EdgeInsets.zero,
              tabs: [
                Tab(height: 36, text: context.l10n.yourTemplates),
                Tab(height: 36, text: context.l10n.predefinedWorkouts),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final customTemplatesAsync = ref.watch(
                  customWorkoutTemplatesProvider,
                );
                final allTemplatesAsync = ref.watch(
                  allWorkoutTemplatesProvider,
                );

                return TabBarView(
                  children: [
                    // Tab 1: I Tuoi Template (Custom)
                    customTemplatesAsync.when(
                      loading: () => const LoadingIndicator(),
                      error: (error, stack) => Center(
                        child: Text(
                          context.l10n.errorLoading(error.toString()),
                        ),
                      ),
                      data: (customTemplates) {
                        return _buildTemplateList(
                          context,
                          customTemplates,
                          isCustomTab: true,
                        );
                      },
                    ),

                    // Tab 2: Schede Predefinite (Predefined)
                    allTemplatesAsync.when(
                      loading: () => const LoadingIndicator(),
                      error: (error, stack) => Center(
                        child: Text(
                          context.l10n.errorLoading(error.toString()),
                        ),
                      ),
                      data: (allTemplates) {
                        // Filtra solo i template predefiniti (non custom)
                        final predefinedTemplates = allTemplates
                            .where((t) => !t.isCustom)
                            .toList();
                        return _buildTemplateList(
                          context,
                          predefinedTemplates,
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

  /// Builds a template list for a single tab
  Widget _buildTemplateList(
    BuildContext context,
    List<wt.WorkoutTemplate> templates, {
    required bool isCustomTab,
  }) {
    if (templates.isEmpty) {
      return _buildEmptyTemplateState(context, isCustomTab);
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
          onTap: () => onStartTemplate(template),
          onShare: () => onShareTemplate(template),
          onDuplicate: () => onDuplicateTemplate(template),
          onEdit: () => onEditTemplate(template),
          onDelete: () => onDeleteTemplate(template),
          onSchedule: onScheduleTemplate != null
              ? () => onScheduleTemplate!(template)
              : null,
          onRefresh: (onRefreshTemplate != null && template.isCustom)
              ? () => onRefreshTemplate!(template)
              : null,
          onView: onViewTemplate != null
              ? () => onViewTemplate!(template)
              : null,
        );
      },
    );
  }

  /// Builds the empty state when no templates are available
  Widget _buildEmptyTemplateState(BuildContext context, bool isCustomTab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: isCustomTab ? AppIcons.noteAdd : AppIcons.inventory2Outlined,
            semanticLabel: isCustomTab
                ? 'No custom templates'
                : 'No predefined workouts',
            size: AppIconSize.xxlarge,
            color: context.colors.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isCustomTab
                ? context.l10n.noCustomTemplates
                : context.l10n.noPredefinedWorkouts,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isCustomTab
                ? context.l10n.createFirstTemplate
                : context.l10n.predefinedWorkoutsComingSoon,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.4),
            ),
          ),
          if (isCustomTab) ...[
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onCreateTemplate,
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
}
