/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets/editor_steps
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// TEMPLATE ROTATION STEP - Step 4 of routine creation wizard
///
/// Allows user to reorder selected templates and preview their distribution
/// across workout days
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_editor_state.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';

/// Step 4: Arrange rotation order and preview distribution
class TemplateRotationStep extends ConsumerWidget {
  const TemplateRotationStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(routineEditorProvider);
    final pattern = state.finalPattern;

    if (pattern == null) {
      return Center(
        child: Text(
          context.l10n.routineNoPatternSelected,
          style: context.textTheme.bodyLarge,
        ),
      );
    }

    final selectedTemplateIds = state.selectedTemplates;

    if (selectedTemplateIds.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: context.colors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.routineNoTemplatesSelected,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.routineNoTemplatesMessage,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final templatesAsync = ref.watch(allWorkoutTemplatesProvider);

    return templatesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          context.l10n.routineErrorLoading(error.toString()),
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.error,
          ),
        ),
      ),
      data: (allTemplates) {
        // Map IDs to actual templates
        final selectedTemplates = selectedTemplateIds
            .map((id) => allTemplates.firstWhere(
                  (t) => t.id == id,
                  orElse: () => allTemplates.first,
                ))
            .toList();

        return _buildContent(context, ref, state, selectedTemplates);
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    RoutineEditorState state,
    List<WorkoutTemplate> selectedTemplates,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            context.l10n.routineRotationTitle,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.routineRotationSubtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 24),

          // Templates count info
          Row(
            children: [
              Icon(
                Icons.fitness_center,
                color: context.colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.routineTemplatesSelected(selectedTemplates.length),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Reorderable list of templates
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedTemplates.length,
            onReorder: (oldIndex, newIndex) {
              ref.read(routineEditorProvider.notifier).reorderTemplate(
                    oldIndex,
                    newIndex,
                  );
            },
            itemBuilder: (context, index) {
              final template = selectedTemplates[index];
              return _buildSelectedTemplateCard(
                context,
                ref,
                key: ValueKey(template.id),
                template: template,
                index: index,
              );
            },
          ),

          const SizedBox(height: 32),

          // Distribution preview
          _buildDistributionPreview(context, state, selectedTemplates),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSelectedTemplateCard(
    BuildContext context,
    WidgetRef ref, {
    required Key key,
    required WorkoutTemplate template,
    required int index,
  }) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.drag_handle,
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: context.colors.primaryContainer,
              child: Text(
                '${index + 1}',
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          template.name,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          context.l10n.routineExercises(template.exercises.length),
          style: context.textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.close,
            color: context.colors.error,
          ),
          onPressed: () {
            ref.read(routineEditorProvider.notifier).toggleTemplate(template.id);
          },
        ),
      ),
    );
  }

  Widget _buildDistributionPreview(
    BuildContext context,
    RoutineEditorState state,
    List<WorkoutTemplate> selectedTemplates,
  ) {
    final pattern = state.finalPattern!;
    final totalDays = state.endDate.difference(state.startDate).inDays + 1;

    // Calculate distribution
    final distribution = <_DayDistribution>[];
    int templateIndex = 0;

    for (int i = 0; i < totalDays && i < 10; i++) {
      // Show max 10 days preview
      final dayDate = state.startDate.add(Duration(days: i));
      final dayName = pattern.sequence[i % pattern.sequence.length];
      final isRest = dayName.toLowerCase() == 'rest';

      if (isRest) {
        distribution.add(_DayDistribution(
          dayNumber: i + 1,
          date: dayDate,
          dayName: dayName,
          template: null,
          isRest: true,
        ));
      } else {
        final template =
            selectedTemplates[templateIndex % selectedTemplates.length];
        distribution.add(_DayDistribution(
          dayNumber: i + 1,
          date: dayDate,
          dayName: dayName,
          template: template,
          isRest: false,
        ));
        templateIndex++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: context.colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.routineDistributionPreview,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.routineFirstDaysPreview(distribution.length, totalDays),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),

          ...distribution.map((day) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // Day badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: day.isRest
                          ? context.colors.secondaryContainer
                          : context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'D${day.dayNumber}',
                          style: context.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: day.isRest
                                ? context.colors.onSecondaryContainer
                                : context.colors.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          '${day.date.day}/${day.date.month}',
                          style: context.textTheme.labelSmall?.copyWith(
                            fontSize: 8,
                            color: (day.isRest
                                    ? context.colors.onSecondaryContainer
                                    : context.colors.onPrimaryContainer)
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Template info
                  Expanded(
                    child: day.isRest
                        ? Row(
                            children: [
                              Icon(
                                Icons.bed,
                                size: 16,
                                color: context.colors.secondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                context.l10n.routineRestDay,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colors.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 16,
                                color: context.colors.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  day.template!.name,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          }),

          if (totalDays > 10) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                context.l10n.routineMoreDays(totalDays - 10),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Helper class for distribution preview
class _DayDistribution {
  _DayDistribution({
    required this.dayNumber,
    required this.date,
    required this.dayName,
    required this.template,
    required this.isRest,
  });
  final int dayNumber;
  final DateTime date;
  final String dayName;
  final WorkoutTemplate? template;
  final bool isRest;
}
