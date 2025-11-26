import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart' as wt;
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
            Expanded(
              child: _buildQuickStartList(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the prominent quick start card with gradient and shadow
  Widget _buildQuickStartCard(BuildContext context) {
    return InkWell(
      onTap: onQuickStart,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.primary,
              context.colors.primary.withValues(alpha: 0.85),
              HSLColor.fromColor(context.colors.primary)
                  .withLightness(
                    (HSLColor.fromColor(context.colors.primary).lightness - 0.1)
                        .clamp(0.0, 1.0),
                  )
                  .toColor(),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: context.colors.onPrimary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Enhanced icon container with gradient
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    context.colors.onPrimary.withValues(alpha: 0.3),
                    context.colors.onPrimary.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.onPrimary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SemanticIcon(
                icon: AppIcons.flashOn,
                semanticLabel: 'Start workout now',
                size: AppIconSize.xlarge,
                color: context.colors.onPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
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
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    context.l10n.startImmediately,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            // Enhanced chevron with subtle background
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.colors.onPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SemanticIcon(
                icon: AppIcons.forwardIos,
                semanticLabel: 'Start',
                size: AppIconSize.small,
                color: context.colors.onPrimary,
              ),
            ),
          ],
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
          // Tab Bar
          ColoredBox(
            color: context.colors.surface,
            child: TabBar(
              labelColor: context.colors.primary,
              unselectedLabelColor:
                  context.colors.onSurface.withValues(alpha: 0.6),
              indicatorColor: context.colors.primary,
              indicatorWeight: 3,
              labelStyle: context.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
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
                final customTemplatesAsync =
                    ref.watch(customWorkoutTemplatesProvider);
                final allTemplatesAsync =
                    ref.watch(allWorkoutTemplatesProvider);

                return TabBarView(
                  children: [
                    // Tab 1: I Tuoi Template (Custom)
                    customTemplatesAsync.when(
                      loading: () => const LoadingIndicator(),
                      error: (error, stack) => Center(
                        child: Text(context.l10n.errorLoading(error.toString())),
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
                        child: Text(context.l10n.errorLoading(error.toString())),
                      ),
                      data: (allTemplates) {
                        // Filtra solo i template predefiniti (non custom)
                        final predefinedTemplates =
                            allTemplates.where((t) => !t.isCustom).toList();
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
            icon: isCustomTab
                ? AppIcons.noteAdd
                : AppIcons.inventory2Outlined,
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
