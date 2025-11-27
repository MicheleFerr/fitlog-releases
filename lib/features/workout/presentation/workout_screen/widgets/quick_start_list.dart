import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart' as wt;
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen/widgets/template_grid.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Quick start list widget with tabs for custom and predefined templates
///
/// Displays two tabs:
/// - "Your Templates" (custom user-created templates)
/// - "Predefined Workouts" (system templates)
///
/// Each tab shows templates in a scrollable list with swipeable cards.
class QuickStartList extends ConsumerWidget {
  const QuickStartList({
    super.key,
    required this.onTemplateTap,
    required this.onTemplateShare,
    required this.onTemplateDuplicate,
    required this.onTemplateEdit,
    required this.onTemplateDelete,
    required this.onCreateTemplate,
    this.onTemplateSchedule,
  });

  /// Callback when user taps on a template to start workout
  final void Function(wt.WorkoutTemplate template) onTemplateTap;

  /// Callback when user shares a template as PDF
  final void Function(wt.WorkoutTemplate template) onTemplateShare;

  /// Callback when user duplicates a template
  final void Function(wt.WorkoutTemplate template) onTemplateDuplicate;

  /// Callback when user edits a template
  final void Function(wt.WorkoutTemplate template) onTemplateEdit;

  /// Callback when user deletes a template
  final void Function(wt.WorkoutTemplate template) onTemplateDelete;

  /// Callback when user creates a new template
  final VoidCallback onCreateTemplate;

  /// Callback when user schedules a template (swipe right action)
  final void Function(wt.WorkoutTemplate template)? onTemplateSchedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        return TemplateGrid(
                          templates: customTemplates,
                          categoryTitle: context.l10n.yourTemplates,
                          isCustomTab: true,
                          onTemplateTap: onTemplateTap,
                          onTemplateShare: onTemplateShare,
                          onTemplateDuplicate: onTemplateDuplicate,
                          onTemplateEdit: onTemplateEdit,
                          onTemplateDelete: onTemplateDelete,
                          onCreateTemplate: onCreateTemplate,
                          onTemplateSchedule: onTemplateSchedule,
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
                        return TemplateGrid(
                          templates: predefinedTemplates,
                          categoryTitle: context.l10n.predefinedWorkouts,
                          isCustomTab: false,
                          onTemplateTap: onTemplateTap,
                          onTemplateShare: onTemplateShare,
                          onTemplateDuplicate: onTemplateDuplicate,
                          onTemplateEdit: onTemplateEdit,
                          onTemplateDelete: onTemplateDelete,
                          onCreateTemplate: onCreateTemplate,
                          onTemplateSchedule: onTemplateSchedule,
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
}
