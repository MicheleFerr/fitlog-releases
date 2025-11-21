/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget (modal)
/// 🌍 Localization: Required (context.l10n)
/// 📱 Platform: Universal
///
/// TEMPLATE PICKER MODAL - Modal for Selecting Workout Templates
///
/// Features:
/// - Display list of user + public templates
/// - Show template details (name, exercises count, category)
/// - Allow template selection
/// - Return selected template to caller
/// - Handle empty state (no templates available)
/// - Integration with existing templateProvider from workout_templates feature
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/providers/template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Template Picker Modal - Show modal for selecting workout template
///
/// Usage:
/// ```dart
/// final template = await showTemplatePickerModal(
///   context: context,
///   dayNumber: 1, // Monday
///   currentTemplate: existingTemplate, // optional
/// );
/// if (template != null) {
///   // User selected a template
/// }
/// ```
Future<WorkoutTemplate?> showTemplatePickerModal({
  required BuildContext context,
  required int dayNumber,
  WorkoutTemplate? currentTemplate,
}) {
  return showModalBottomSheet<WorkoutTemplate>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => TemplatePickerModal(
      dayNumber: dayNumber,
      currentTemplate: currentTemplate,
    ),
  );
}

/// Template Picker Modal Widget
class TemplatePickerModal extends ConsumerWidget {
  const TemplatePickerModal({
    super.key,
    required this.dayNumber,
    this.currentTemplate,
  });

  /// Day number for context (1=Monday, 7=Sunday)
  final int dayNumber;

  /// Currently selected template (optional)
  final WorkoutTemplate? currentTemplate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateState = ref.watch(templateProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.selectTemplate,
                      style: context.textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Template list
            Expanded(
              child: templateState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTemplateList(
                      context,
                      ref,
                      scrollController: scrollController,
                      userTemplates: templateState.userTemplates,
                      publicTemplates: templateState.publicTemplates,
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTemplateList(
    BuildContext context,
    WidgetRef ref, {
    required ScrollController scrollController,
    required List<WorkoutTemplate> userTemplates,
    required List<WorkoutTemplate> publicTemplates,
  }) {
    final allTemplates = [...userTemplates, ...publicTemplates];

    if (allTemplates.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: allTemplates.length + (userTemplates.isNotEmpty && publicTemplates.isNotEmpty ? 2 : 1),
      itemBuilder: (context, index) {
        // Section header: User Templates
        if (index == 0 && userTemplates.isNotEmpty) {
          return _buildSectionHeader(context, context.l10n.myTemplates);
        }

        // User templates
        if (index > 0 && index <= userTemplates.length) {
          final template = userTemplates[index - 1];
          return _buildTemplateCard(context, template);
        }

        // Section header: Public Templates
        if (userTemplates.isNotEmpty && publicTemplates.isNotEmpty && index == userTemplates.length + 1) {
          return _buildSectionHeader(context, context.l10n.publicTemplates);
        }

        // Public templates
        final publicIndex = userTemplates.isNotEmpty && publicTemplates.isNotEmpty
            ? index - userTemplates.length - 2
            : index - 1;
        final template = publicTemplates[publicIndex];
        return _buildTemplateCard(context, template);
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, WorkoutTemplate template) {
    final isSelected = currentTemplate?.id == template.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? context.colors.primaryContainer
          : context.colors.surface,
      child: ListTile(
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.fitness_center,
          color: isSelected
              ? context.colors.primary
              : context.colors.onSurfaceVariant,
        ),
        title: Text(
          template.name,
          style: context.textTheme.titleMedium?.copyWith(
            color: isSelected
                ? context.colors.onPrimaryContainer
                : context.colors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          '${template.exercises.length} ${context.l10n.exercises} • ${_getCategoryName(context, template.category)}',
          style: context.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? context.colors.onPrimaryContainer
                : context.colors.onSurfaceVariant,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check, color: context.colors.primary)
            : const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).pop(template),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noTemplatesAvailable,
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.createTemplateFirst,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getCategoryName(BuildContext context, TemplateCategory category) {
    switch (category) {
      case TemplateCategory.strength:
        return context.l10n.strength;
      case TemplateCategory.hypertrophy:
        return context.l10n.hypertrophy;
      case TemplateCategory.endurance:
        return context.l10n.endurance;
      case TemplateCategory.powerlifting:
        return context.l10n.powerlifting;
      case TemplateCategory.bodybuilding:
        return context.l10n.bodybuilding;
      case TemplateCategory.crossfit:
        return context.l10n.crossfit;
      case TemplateCategory.calisthenics:
        return context.l10n.calisthenics;
      case TemplateCategory.cardio:
        return context.l10n.cardio;
      case TemplateCategory.mixed:
        return context.l10n.mixed;
      case TemplateCategory.custom:
        return context.l10n.custom;
    }
  }
}
