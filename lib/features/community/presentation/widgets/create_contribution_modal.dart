/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/community/presentation/widgets
/// 🎯 Feature: community
/// 🔧 Type: widget
///
/// Modal per creare nuovo contributo community
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/exercise_picker/quick_exercise_picker.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Modal per creare un nuovo contributo community
class CreateContributionModal extends ConsumerStatefulWidget {

  const CreateContributionModal({
    super.key,
    this.preselectedExerciseId,
    this.preselectedExerciseName,
  });
  final String? preselectedExerciseId;
  final String? preselectedExerciseName;

  @override
  ConsumerState<CreateContributionModal> createState() => _CreateContributionModalState();
}

class _CreateContributionModalState extends ConsumerState<CreateContributionModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _originalValueController = TextEditingController();
  final _suggestedValueController = TextEditingController();
  final _searchController = TextEditingController();

  ContributionType _selectedType = ContributionType.tip;
  String? _selectedExerciseId;
  String? _selectedExerciseName;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedExerciseId != null) {
      _selectedExerciseId = widget.preselectedExerciseId;
      _selectedExerciseName = widget.preselectedExerciseName;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _originalValueController.dispose();
    _suggestedValueController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.95);
    return DraggableScrollableSheet(
      initialChildSize: safeMax.clamp(0.0, 0.9),
      minChildSize: 0.5,
      maxChildSize: safeMax,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.newContribution,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const SemanticIcon(
  icon: AppIcons.close,
  semanticLabel: 'Close',
),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Exercise Selection
                      _buildExerciseSelector(theme),
                      const SizedBox(height: 20),

                      // Contribution Type
                      _buildTypeSelector(theme),
                      const SizedBox(height: 20),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: context.l10n.titleLabel,
                          hintText: context.l10n.titleHintContribution,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const SemanticIcon(
  icon: AppIcons.titleIcon,
  semanticLabel: 'Title icon',
),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.l10n.titleRequired;
                          }
                          if (value.trim().length < 10) {
                            return context.l10n.titleMinLength;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: context.l10n.descriptionLabel,
                          hintText: _getDescriptionHint(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const SemanticIcon(
  icon: AppIcons.template,
  semanticLabel: 'Template',
),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.l10n.descriptionRequired;
                          }
                          if (value.trim().length < 20) {
                            return context.l10n.descriptionMinLength;
                          }
                          return null;
                        },
                      ),

                      // Correction-specific fields
                      if (_selectedType == ContributionType.correction) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _originalValueController,
                          decoration: InputDecoration(
                            labelText: context.l10n.currentValueIncorrect,
                            hintText: context.l10n.currentValueHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const SemanticIcon(
  icon: AppIcons.error,
  semanticLabel: 'Error',
),
                          ),
                          validator: _selectedType == ContributionType.correction
                              ? (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return context.l10n.currentValueRequired;
                                  }
                                  return null;
                                }
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _suggestedValueController,
                          decoration: InputDecoration(
                            labelText: context.l10n.correctedValue,
                            hintText: context.l10n.correctedValueHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const SemanticIcon(
  icon: AppIcons.completeOutline,
  semanticLabel: 'Complete outline',
),
                          ),
                          validator: _selectedType == ContributionType.correction
                              ? (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return context.l10n.correctedValueRequired;
                                  }
                                  return null;
                                }
                              : null,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Info box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.info,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                context.l10n.contributionReviewInfo,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      FilledButton.icon(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const SemanticIcon(
  icon: AppIcons.send,
  semanticLabel: 'Send',
),
                        label: Text(_isSubmitting ? context.l10n.sending : context.l10n.submitContribution),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 80), // Space for keyboard
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseSelector(ThemeData theme) {
    if (_selectedExerciseName != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              AppIcons.workout,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.exerciseLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  Text(
                    _selectedExerciseName!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedExerciseId = null;
                  _selectedExerciseName = null;
                });
              },
              icon: const SemanticIcon(
  icon: AppIcons.edit,
  semanticLabel: 'Edit',
),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.selectExercise,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _showExercisePicker(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.workout,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.tapToSelectExercise,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                SemanticIcon(
  icon: AppIcons.forwardIos,
  semanticLabel: 'Forward ios',
  size: AppIconSize.tiny,
  color: theme.colorScheme.outline,
),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.contributionType,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ContributionType.values.map((type) {
            final isSelected = _selectedType == type;
            final color = _getTypeColor(type);

            return FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getTypeIcon(type),
                    size: 16,
                    color: isSelected ? context.colors.surface : color,
                  ),
                  const SizedBox(width: 6),
                  Text(_getTypeLabel(type)),
                ],
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedType = type);
                }
              },
              selectedColor: color,
              checkmarkColor: context.colors.surface,
              labelStyle: context.textTheme.bodyMedium?.copyWith(
                color: isSelected ? context.colors.surface : color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          _getTypeDescription(_selectedType),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  void _showExercisePicker() async {
    // Usa il nuovo QuickExercisePicker condiviso
    final result = await context.showQuickExercisePicker();

    if (result != null && mounted) {
      setState(() {
        _selectedExerciseId = result.id;
        _selectedExerciseName = result.nome;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedExerciseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.selectExerciseWarning),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(contributionSubmissionProvider.notifier).submitContribution(
            exerciseId: _selectedExerciseId!,
            exerciseName: _selectedExerciseName!,
            type: _selectedType,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            originalValue: _selectedType == ContributionType.correction
                ? _originalValueController.text.trim()
                : null,
            suggestedValue: _selectedType == ContributionType.correction
                ? _suggestedValueController.text.trim()
                : null,
          );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.contributionSubmittedSuccess),
          backgroundColor: context.colors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.errorWithMessage(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getDescriptionHint() {
    switch (_selectedType) {
      case ContributionType.tip:
        return context.l10n.descriptionHintTip;
      case ContributionType.warning:
        return context.l10n.descriptionHintWarning;
      case ContributionType.correction:
        return context.l10n.descriptionHintCorrection;
      case ContributionType.technique:
        return context.l10n.descriptionHintTechnique;
      case ContributionType.variant:
        return context.l10n.descriptionHintVariant;
      case ContributionType.translation:
        return context.l10n.descriptionHintTranslation;
    }
  }

  String _getTypeDescription(ContributionType type) {
    switch (type) {
      case ContributionType.tip:
        return context.l10n.typeDescriptionTip;
      case ContributionType.warning:
        return context.l10n.typeDescriptionWarning;
      case ContributionType.correction:
        return context.l10n.typeDescriptionCorrection;
      case ContributionType.technique:
        return context.l10n.typeDescriptionTechnique;
      case ContributionType.variant:
        return context.l10n.typeDescriptionVariant;
      case ContributionType.translation:
        return context.l10n.typeDescriptionTranslation;
    }
  }

  Color _getTypeColor(ContributionType type) {
    switch (type) {
      case ContributionType.tip:
        return context.colors.primary;
      case ContributionType.warning:
        return context.colors.secondary;
      case ContributionType.correction:
        return context.colors.error;
      case ContributionType.technique:
        return context.colors.success;
      case ContributionType.variant:
        return context.colors.tertiary;
      case ContributionType.translation:
        return context.colors.tertiary;
    }
  }

  IconData _getTypeIcon(ContributionType type) {
    switch (type) {
      case ContributionType.tip:
        return AppIcons.lightbulb;
      case ContributionType.warning:
        return AppIcons.warning;
      case ContributionType.correction:
        return AppIcons.edit;
      case ContributionType.technique:
        return AppIcons.education;
      case ContributionType.variant:
        return AppIcons.altRoute;
      case ContributionType.translation:
        return AppIcons.translate;
    }
  }

  String _getTypeLabel(ContributionType type) {
    switch (type) {
      case ContributionType.tip:
        return context.l10n.typeLabelTip;
      case ContributionType.warning:
        return context.l10n.typeLabelWarning;
      case ContributionType.correction:
        return context.l10n.typeLabelCorrection;
      case ContributionType.technique:
        return context.l10n.typeLabelTechnique;
      case ContributionType.variant:
        return context.l10n.typeLabelVariant;
      case ContributionType.translation:
        return context.l10n.typeLabelTranslation;
    }
  }
}
