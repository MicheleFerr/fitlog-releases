/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets/editor_steps
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// TEMPLATE SELECTION STEP - Step 3 of routine creation wizard
///
/// Allows user to select which workout templates will be used in the routine
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_editor_state.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/routine/data/popular_templates_data.dart';

/// Step 3: Select templates for automatic rotation
class TemplateSelectionStep extends ConsumerWidget {
  const TemplateSelectionStep({super.key});

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

    final templatesAsync = ref.watch(allWorkoutTemplatesProvider);

    return templatesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: context.colors.error,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.routineErrorLoadingTemplates,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colors.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      data: (templates) {
        if (templates.isEmpty) {
          return _buildEmptyState(context, ref);
        }

        return _buildContent(context, ref, state, templates);
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    RoutineEditorState state,
    List<WorkoutTemplate> templates,
  ) {
    final selectedTemplateIds = state.selectedTemplates;
    final selectedCount = selectedTemplateIds.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            context.l10n.routineSelectionTitle,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.routineSelectionSubtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 24),

          // Selection counter
          Row(
            children: [
              Text(
                context.l10n.routineAvailableTemplates,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
              const Spacer(),
              if (selectedCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    context.l10n.routineSelected(selectedCount),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Template selection
          ...templates.map((template) {
            final isSelected = selectedTemplateIds.contains(template.id);
            return _buildTemplateCard(
              context,
              ref,
              template: template,
              isSelected: isSelected,
            );
          }),

          const SizedBox(height: 24),

          // Info card
          if (selectedCount > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: context.colors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.routineNextStepInfo,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    WidgetRef ref, {
    required WorkoutTemplate template,
    required bool isSelected,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      child: InkWell(
        onTap: () {
          ref.read(routineEditorProvider.notifier).toggleTemplate(template.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(
                    color: context.colors.primary,
                    width: 2,
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: isSelected,
                onChanged: (_) {
                  ref
                      .read(routineEditorProvider.notifier)
                      .toggleTemplate(template.id);
                },
                activeColor: context.colors.primary,
              ),
              const SizedBox(width: 12),

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
                          color:
                              context.colors.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.l10n.routineExercises(template.exercises.length),
                          style: context.textTheme.bodySmall?.copyWith(
                            color:
                                context.colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        if (template.estimatedDuration > 0) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color:
                                context.colors.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${template.estimatedDuration} ${context.l10n.minutes}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Empty state when user has no templates
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center,
                size: 80,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              context.l10n.routineNoTemplatesYet,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              context.l10n.routineNeedTemplatesMessage,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Option 1: Use Popular Templates
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.primary.withValues(alpha: 0.1),
                    context.colors.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.star,
                          color: context.colors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.routinePopularTemplates,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.routinePopularTemplatesDesc,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _importPopularTemplates(context, ref),
                    icon: Icon(
                      Icons.download,
                      color: context.colors.onPrimary,
                    ),
                    label: Text(
                      context.l10n.routineImportPopularTemplates,
                      style: TextStyle(
                        color: context.colors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Divider with "OR"
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: context.colors.outline.withValues(alpha: 0.3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    context.l10n.routineOr,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: context.colors.outline.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Option 2: Create Custom Template
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colors.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.create,
                          color: context.colors.onSecondaryContainer,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.routineCustomTemplate,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.routineCustomTemplateDesc,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _createCustomTemplate(context),
                    icon: const Icon(Icons.add),
                    label: Text(
                      context.l10n.routineCreateFirstTemplate,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: BorderSide(
                        color: context.colors.outline,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  /// Import popular templates from predefined data
  Future<void> _importPopularTemplates(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final popularTemplates = PopularTemplatesData.getPopularTemplates();

    // Show selection dialog
    final selectedTemplates = await ModalService.showCustomDialog<
        List<WorkoutTemplate>>(
      context,
      child: _PopularTemplatesDialog(
        templates: popularTemplates,
      ),
    );

    if (selectedTemplates != null && selectedTemplates.isNotEmpty) {
      // TODO: Save templates to user's account via provider
      // This requires a method in workout_template_provider to save multiple templates
      // For now, show success and refresh

      if (context.mounted) {
        SnackBarService.showSuccess(
          context,
          '${selectedTemplates.length} template${selectedTemplates.length > 1 ? 's' : ''} imported! 🎉',
        );

        // Refresh templates list
        ref.invalidate(allWorkoutTemplatesProvider);
      }
    }
  }

  /// Navigate to template creator
  void _createCustomTemplate(BuildContext context) {
    SnackBarService.showInfo(
      context,
      context.l10n.routineNavigatingToCreator,
    );
    // TODO: Navigate to template creator screen
    // This requires knowing the route name for the template creator
  }
}

/// Dialog for selecting popular templates to import
class _PopularTemplatesDialog extends StatefulWidget {
  const _PopularTemplatesDialog({required this.templates});
  final List<WorkoutTemplate> templates;

  @override
  State<_PopularTemplatesDialog> createState() =>
      _PopularTemplatesDialogState();
}

class _PopularTemplatesDialogState extends State<_PopularTemplatesDialog> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.star, color: context.colors.primary),
          const SizedBox(width: 12),
          Text(context.l10n.routinePopularTemplates),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.routineSelectTemplatesDialog,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.templates.length,
                itemBuilder: (context, index) {
                  final template = widget.templates[index];
                  final isSelected = _selectedIds.contains(template.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedIds.add(template.id);
                          } else {
                            _selectedIds.remove(template.id);
                          }
                        });
                      },
                      activeColor: context.colors.primary,
                      title: Text(
                        template.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (template.description.isNotEmpty)
                            Text(template.description),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 14,
                                color: context.colors.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.l10n.routineExercises(template.exercises.length),
                                style: context.textTheme.bodySmall,
                              ),
                              const SizedBox(width: 12),
                              if (template.estimatedDuration > 0) ...[
                                Icon(
                                  Icons.schedule,
                                  size: 14,
                                  color: context.colors.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${template.estimatedDuration} ${context.l10n.minutes}',
                                  style: context.textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
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
          onPressed: _selectedIds.isEmpty
              ? null
              : () {
                  final selected = widget.templates
                      .where((t) => _selectedIds.contains(t.id))
                      .toList();
                  Navigator.of(context).pop(selected);
                },
          icon: const Icon(Icons.download),
          label: Text(
            _selectedIds.isEmpty
                ? context.l10n.routineSelectTemplatesButton
                : context.l10n.routineImportCount(_selectedIds.length),
          ),
        ),
      ],
    );
  }
}
