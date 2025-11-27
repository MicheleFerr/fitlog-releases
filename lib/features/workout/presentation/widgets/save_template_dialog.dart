/// Save Template Dialog
///
/// Dialog for saving advanced exercise configurations (superset, dropset, rest-pause)
/// as reusable templates. Shows freemium limit for free users.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/workout/domain/entities/advanced_exercise_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/advanced_exercise_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Shows the save template dialog
Future<AdvancedExerciseTemplate?> showSaveTemplateDialog({
  required BuildContext context,
  required WidgetRef ref,
  SupersetExercise? superset,
  DropSetExercise? dropSet,
  RestPauseExercise? restPause,
}) async {
  // Validate that exactly one type is provided
  final typeCount = [superset, dropSet, restPause].where((e) => e != null).length;
  if (typeCount != 1) {
    throw ArgumentError('Exactly one exercise type must be provided');
  }

  return showDialog<AdvancedExerciseTemplate>(
    context: context,
    builder: (context) => SaveTemplateDialog(
      superset: superset,
      dropSet: dropSet,
      restPause: restPause,
    ),
  );
}

/// Dialog widget for saving templates
class SaveTemplateDialog extends ConsumerStatefulWidget {
  const SaveTemplateDialog({
    super.key,
    this.superset,
    this.dropSet,
    this.restPause,
  });

  final SupersetExercise? superset;
  final DropSetExercise? dropSet;
  final RestPauseExercise? restPause;

  @override
  ConsumerState<SaveTemplateDialog> createState() => _SaveTemplateDialogState();
}

class _SaveTemplateDialogState extends ConsumerState<SaveTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();

  final List<String> _tags = [];
  bool _isSaving = false;

  AdvancedExerciseType get _type {
    if (widget.superset != null) return AdvancedExerciseType.superset;
    if (widget.dropSet != null) return AdvancedExerciseType.dropset;
    return AdvancedExerciseType.restPause;
  }

  String get _defaultName {
    switch (_type) {
      case AdvancedExerciseType.superset:
        final names = widget.superset!.exercises.map((e) => e.name).take(2);
        return '${names.join(' + ')} Superset';
      case AdvancedExerciseType.dropset:
        return '${widget.dropSet!.name} Drop Set';
      case AdvancedExerciseType.restPause:
        return '${widget.restPause!.name} Rest-Pause';
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = _defaultName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final limitInfo = ref.watch(templateLimitInfoProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context),
                const SizedBox(height: 20),

                // Limit warning for free users
                limitInfo.when(
                  data: (info) => info.isAtLimit
                      ? _buildLimitWarning(context, info)
                      : info.remainingSlots > 0 && info.remainingSlots <= 2
                          ? _buildLimitInfo(context, info)
                          : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: context.l10n.templateName,
                          hintText: context.l10n.enterTemplateName,
                          prefixIcon: Icon(
                            _getTypeIcon(),
                            color: context.colors.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.pleaseEnterName;
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: context.l10n.descriptionOptional,
                          hintText: context.l10n.addDescription,
                          prefixIcon: const Icon(AppIcons.document),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),

                      // Tags
                      _buildTagsSection(context),
                      const SizedBox(height: 16),

                      // Exercise info preview
                      _buildExercisePreview(context),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: Text(context.l10n.cancel),
                    ),
                    const SizedBox(width: 12),
                    limitInfo.when(
                      data: (info) => FilledButton.icon(
                        onPressed: _isSaving || info.isAtLimit
                            ? null
                            : () => _saveTemplate(context),
                        icon: _isSaving
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.colors.onPrimary,
                                ),
                              )
                            : const Icon(AppIcons.save, size: AppIconSize.small),
                        label: Text(context.l10n.saveTemplate),
                      ),
                      loading: () => const FilledButton(
                        onPressed: null,
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (_, __) => FilledButton.icon(
                        onPressed: () => _saveTemplate(context),
                        icon: const Icon(AppIcons.save, size: AppIconSize.small),
                        label: Text(context.l10n.saveTemplate),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SemanticIcon(
            icon: _getTypeIcon(),
            semanticLabel: _getTypeLabel(),
            size: AppIconSize.large,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.saveAsTemplate,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getTypeLabel(),
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

  Widget _buildLimitWarning(BuildContext context, TemplateLimitInfo info) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.warning,
            semanticLabel: context.l10n.warning,
            color: context.colors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.templateLimitReached(kFreeTemplateLimit),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.onErrorContainer,
                  ),
                ),
                Text(
                  context.l10n.upgradeToPremiumForUnlimited,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onErrorContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitInfo(BuildContext context, TemplateLimitInfo info) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.warningContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.info,
            semanticLabel: context.l10n.info,
            color: context.warningColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${info.remainingSlots} ${context.l10n.templateSlotsRemaining}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.tagsOptional,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._tags.map((tag) => Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(AppIcons.close, size: AppIconSize.tiny),
                  onDeleted: () {
                    setState(() => _tags.remove(tag));
                  },
                )),
            ActionChip(
              avatar: const Icon(AppIcons.add, size: AppIconSize.tiny),
              label: Text(context.l10n.addTag),
              onPressed: () => _showAddTagDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExercisePreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.templateConfiguration,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          _buildConfigDetails(context),
        ],
      ),
    );
  }

  Widget _buildConfigDetails(BuildContext context) {
    switch (_type) {
      case AdvancedExerciseType.superset:
        final exercises = widget.superset!.exercises;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...exercises.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      SemanticIcon(
                        icon: AppIcons.check,
                        semanticLabel: e.name,
                        size: AppIconSize.tiny,
                        color: context.colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(e.name, style: context.textTheme.bodySmall),
                    ],
                  ),
                )),
            const SizedBox(height: 4),
            Text(
              '${exercises.length} ${context.l10n.exercises} • ${widget.superset!.restTime ?? 90}s ${context.l10n.rest}',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        );

      case AdvancedExerciseType.dropset:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.trendingDown,
                  semanticLabel: context.l10n.dropSet,
                  size: AppIconSize.tiny,
                  color: context.colors.tertiary,
                ),
                const SizedBox(width: 8),
                Text(widget.dropSet!.name, style: context.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.dropSet!.stages.length} ${context.l10n.drops}',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        );

      case AdvancedExerciseType.restPause:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.pause,
                  semanticLabel: context.l10n.restPause,
                  size: AppIconSize.tiny,
                  color: context.colors.secondary,
                ),
                const SizedBox(width: 8),
                Text(widget.restPause!.name, style: context.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.restPause!.restPauseSets.length} ${context.l10n.miniSets} • ${widget.restPause!.restPauseSets.isNotEmpty ? widget.restPause!.restPauseSets.first.restSeconds : 15}s ${context.l10n.rest}',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        );
    }
  }

  IconData _getTypeIcon() {
    switch (_type) {
      case AdvancedExerciseType.superset:
        return AppIcons.link;
      case AdvancedExerciseType.dropset:
        return AppIcons.trendingDown;
      case AdvancedExerciseType.restPause:
        return AppIcons.pause;
    }
  }

  String _getTypeLabel() {
    switch (_type) {
      case AdvancedExerciseType.superset:
        return context.l10n.superset;
      case AdvancedExerciseType.dropset:
        return context.l10n.dropSet;
      case AdvancedExerciseType.restPause:
        return context.l10n.restPause;
    }
  }

  Future<void> _showAddTagDialog(BuildContext context) async {
    _tagController.clear();

    final tag = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.addTag),
        content: TextField(
          controller: _tagController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.l10n.enterTag,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _tagController.text),
            child: Text(context.l10n.add),
          ),
        ],
      ),
    );

    if (tag != null && tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
    }
  }

  Future<void> _saveTemplate(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();

    final notifier = ref.read(advancedExerciseTemplateNotifierProvider.notifier);

    AdvancedExerciseTemplate? result;

    try {
      switch (_type) {
        case AdvancedExerciseType.superset:
          result = await notifier.createFromSuperset(
            name: _nameController.text.trim(),
            superset: widget.superset!,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            tags: _tags,
          );
        case AdvancedExerciseType.dropset:
          result = await notifier.createFromDropSet(
            name: _nameController.text.trim(),
            dropSet: widget.dropSet!,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            tags: _tags,
          );
        case AdvancedExerciseType.restPause:
          result = await notifier.createFromRestPause(
            name: _nameController.text.trim(),
            restPause: widget.restPause!,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            tags: _tags,
          );
      }

      if (mounted) {
        if (result != null) {
          SnackBarService.showSuccess(
            context,
            context.l10n.templateSaved,
          );
          Navigator.pop(context, result);
        } else {
          SnackBarService.showError(
            context,
            context.l10n.errorSavingTemplate,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          context.l10n.errorSavingTemplate,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
