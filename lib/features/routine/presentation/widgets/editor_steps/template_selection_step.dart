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
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_editor_state.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/edit_template_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:uuid/uuid.dart';

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

    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);

    return templatesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.error,
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
                    AppIcons.info,
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
                  template.isCustom ? AppIcons.person : AppIcons.star,
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
                          AppIcons.workout,
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
                            AppIcons.schedule,
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Warning Icon
            Icon(
              AppIcons.warningAmberRounded,
              size: 80,
              color: context.colors.error,
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

            // Message
            Text(
              context.l10n.routineNeedTemplatesMessage,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Primary Action - Create Template
            ElevatedButton.icon(
              onPressed: () => _createCustomTemplate(context, ref),
              icon: Icon(AppIcons.add, color: context.colors.onPrimary),
              label: Text(
                context.l10n.routineCreateFirstTemplate,
                style: TextStyle(
                  color: context.colors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: context.colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Secondary Action - Go Back
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(AppIcons.back),
              label: Text(context.l10n.routineButtonBack),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                side: BorderSide(color: context.colors.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to template creator
  Future<void> _createCustomTemplate(BuildContext context, WidgetRef ref) async {
    // Create empty template for new template creation
    final emptyTemplate = WorkoutTemplate(
      id: const Uuid().v4(),
      name: 'New Template',
      description: '',
      exercises: [],
      userId: '', // Will be filled by EditTemplateScreen
      isCustom: true,
      isPublic: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Open template editor as fullscreen dialog
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditTemplateScreen(template: emptyTemplate),
        fullscreenDialog: true,
      ),
    );

    // If template was created, refresh provider
    if (result == true && context.mounted) {
      // Invalidate provider to trigger reload
      ref.invalidate(customWorkoutTemplatesProvider);

      // Show success feedback
      SnackBarService.showSuccess(
        context,
        context.l10n.routineTemplateCreatedSuccess,
      );
    }
  }
}
