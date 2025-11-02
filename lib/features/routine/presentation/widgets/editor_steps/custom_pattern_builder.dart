/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets/editor_steps
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// CUSTOM PATTERN BUILDER - Build custom workout patterns day by day
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_editor_state.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Custom pattern builder widget
class CustomPatternBuilder extends ConsumerStatefulWidget {
  const CustomPatternBuilder({super.key});

  @override
  ConsumerState<CustomPatternBuilder> createState() =>
      _CustomPatternBuilderState();
}

class _CustomPatternBuilderState extends ConsumerState<CustomPatternBuilder> {
  final _dayNameController = TextEditingController();

  @override
  void dispose() {
    _dayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(routineEditorProvider);
    final customDays = state.customPatternDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.tertiaryContainer.withValues(alpha: 0.3),
            context.colors.tertiaryContainer.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.edit_calendar,
                color: context.colors.tertiary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.customPatternBuilderTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                    Text(
                      context.l10n.customPatternBuilderDescription,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Current days list
          if (customDays.isNotEmpty) ...[
            Text(
              context.l10n.customPatternYourSchedule(customDays.length),
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildDaysList(customDays),
            const SizedBox(height: 16),
          ],

          // Add day buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddWorkoutDialog(context),
                icon: const Icon(Icons.fitness_center, size: 18),
                label: Text(context.l10n.customPatternAddWorkout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _addRestDay,
                icon: const Icon(Icons.bed, size: 18),
                label: Text(context.l10n.customPatternAddRest),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.colors.secondary),
                  foregroundColor: context.colors.secondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),

          if (customDays.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                context.l10n.customPatternEmptyWarning,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.error,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDaysList(List<String> days) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      onReorder: (oldIndex, newIndex) {
        ref
            .read(routineEditorProvider.notifier)
            .reorderCustomPatternDay(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final day = days[index];
        final isRest = day.toLowerCase() == 'rest';

        return Card(
          key: ValueKey('day_$index'),
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.drag_handle,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isRest
                        ? context.colors.secondaryContainer
                        : context.colors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isRest ? Icons.bed : Icons.fitness_center,
                    color: isRest
                        ? context.colors.onSecondaryContainer
                        : context.colors.onPrimaryContainer,
                    size: 20,
                  ),
                ),
              ],
            ),
            title: Text(
              isRest ? context.l10n.customPatternRestDay : day,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              context.l10n.customPatternDayNumber(index + 1),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: context.colors.error),
              onPressed: () => _removeDay(index),
              tooltip: context.l10n.customPatternRemoveDay,
            ),
          ),
        );
      },
    );
  }

  void _showAddWorkoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: context.colors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.customPatternSelectTemplate,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Template list
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final templatesAsync = ref.watch(allWorkoutTemplatesProvider);

                    return templatesAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Center(
                        child: Text(
                          'Error: $error',
                          style: TextStyle(color: context.colors.error),
                        ),
                      ),
                      data: (templates) {
                        if (templates.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox,
                                  size: 64,
                                  color: context.colors.onSurface.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  context.l10n.customPatternNoTemplates,
                                  style: context.textTheme.bodyLarge?.copyWith(
                                    color: context.colors.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: templates.length,
                          itemBuilder: (context, index) {
                            final template = templates[index];
                            return _buildTemplateCard(
                              context,
                              template,
                              onTap: () {
                                Navigator.pop(sheetContext);
                                _addWorkoutDay(template.name);
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    WorkoutTemplate template,
    {required VoidCallback onTap}
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: template.isCustom
                      ? context.colors.primaryContainer
                      : context.colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  template.isCustom ? Icons.person : Icons.star,
                  color: template.isCustom
                      ? context.colors.onPrimaryContainer
                      : context.colors.onSecondaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Info
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
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 14,
                          color: context.colors.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${template.exercises.length} ${context.l10n.exercises}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        if (template.estimatedDuration > 0) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: context.colors.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${template.estimatedDuration} min',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: context.colors.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addWorkoutDay(String name) {
    ref.read(routineEditorProvider.notifier).addCustomPatternDay(name);
  }

  void _addRestDay() {
    ref.read(routineEditorProvider.notifier).addCustomPatternDay('Rest');
  }

  void _removeDay(int index) {
    ref.read(routineEditorProvider.notifier).removeCustomPatternDay(index);
  }
}
